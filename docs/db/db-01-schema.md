# Galileo HQ — DB 01: analisi dello schema del database di sala

**Stato:** bozza · **Responsabile:** Piero · **Aggiornato:** 2026-10-18

**Fonte:** script SSMS di `[WinMtSqlDB]` generato il 18/10/2026 (1,18 milioni di caratteri; originale in UTF-16) · **Collegati:** `analisi-00-prima-lettura.md` (zone concettuali), `db-query-01.sql` (verifiche sui dati, Q01–Q10)

Questa è un'analisi del **solo schema**. Le affermazioni sull'uso effettivo dei dati sono ipotesi, da confermare con le query Q01–Q10.


> **Nota del 20/10/2026:** il database analizzato è stato confermato come **database di test**, non di produzione. Le osservazioni sullo schema restano valide; volumi, date e statistiche vanno riverificati sul database di produzione (6–7 GB) e su quello di HQ, attesi a breve.
---

## 1. Inventario

| Oggetto | Numero | Note |
|---------|-------:|------|
| Tabelle | 124 | 84 di dominio e servizio + **40 tabelle `_tracking`** |
| Stored procedure | 466 | **440 generate dal framework di sincronizzazione** (11 per tabella × 40); 26 applicative |
| Funzioni | 25 | Calcolo contatori, decodifica card, HMAC, date |
| Viste | 14 | Quasi tutte su macchine e contatori |
| Tipi tabella | 40 | Tutti `<Tabella>_BulkType`, usati dalla sincronizzazione |
| Trigger | 0 nello script | Assenti dallo script. Q02 ne ha trovati 125: 120 di Sync Framework e **5 applicativi** sul circuito coinless (vedi DB 03, § 3) |
| Chiavi esterne | **3** | Solo su `GruMagazzinoDettaglio`, `GruMovimenti`, `promozioni_cards` |

La logica applicativa nel database è quindi poca: 26 procedure, 25 funzioni, 14 viste e 5 trigger. Il resto sta nel codice VB6 e .NET.

**Configurazione del database:** SQL Server 2022 **Express** (`MSSQL16.SQLEXPRESS`), file dati di circa 840 MB, `RECOVERY SIMPLE`, `AUTO_CLOSE ON`, `ALLOW_SNAPSHOT_ISOLATION ON`, opzioni ANSI disattivate.
- **Express ha un limite di 10 GB per database.** Va considerato nel dimensionamento dello storico.
- **Il recovery model SIMPLE non consente il ripristino point-in-time.** È rilevante per la strategia di backup discussa il 07/10.
- `AUTO_CLOSE ON` è inadatto a un database usato in continuazione da un servizio.

**Utenti del database:** `WinMt` (db_owner) e `claude` (lettura **e scrittura**). Per l'analisi basta la sola lettura: nel kit di query è indicato come togliere la scrittura.

---

## 2. Il sincronizzatore è Microsoft Sync Framework

Le strutture non lasciano dubbi:
- `scope_info` con i blob di *knowledge*;
- `scope_config` con la configurazione in XML;
- `schema_info`;
- tabelle `_tracking` con colonne come `sync_row_is_tombstone`, `local_update_peer_timestamp`, `scope_update_peer_key`;
- procedure `_selectchanges`, `_bulkinsert`, `_insertmetadata` e simili per ogni tabella.

Si tratta del provider SQL di **Microsoft Sync Framework** in modalità collaborativa (peer-to-peer basata su *knowledge*). Il "software .NET schedulato ogni 5 minuti" descritto il 12/10 è con ogni probabilità un'applicazione che lo usa. Il framework installa sulle tabelle sincronizzate dei trigger di inserimento, aggiornamento e cancellazione, che alimentano le `_tracking`. **Lo script SSMS non li include**, probabilmente perché l'opzione di scripting dei trigger era disattivata.

**Conseguenze per il progetto**
- Sync Framework è una tecnologia di generazione .NET Framework che non è più sviluppata. Va trattata come debito tecnico, al pari di VB6.
- La sincronizzazione lavora **riga per riga**, senza semantica applicativa. Due modifiche concorrenti alla stessa riga (per esempio una giacenza modificata da HQ e dalla sala) si risolvono con le regole di conflitto del framework, non con regole di dominio. È la radice tecnica dei problemi di "autorità" emersi in riunione.
- Le chiavi GUID sulle tabelle transazionali (§ 3) sono coerenti con questo modello: servono a generare identificativi univoci in database diversi senza coordinamento.

**Tabelle sincronizzate (40):** Abbuoni, Clienti, CoinlessClonedCards, CoinlessLanguages, CoinlessMacchineHappyHour, CoinlessTestataHappyHour, Differ, EcsDati, EcsErr, EcsMacchine, EcsModuli, Figli, Fornitori, Incassi, LogTransazioniTotem, Machines, Manuf, Mistral, MovMag, MovOut, Operatori, Ordini, Owners, Premi, Prenotaz, Resi, RiepInv, Scocard, Setup, TickRep, Tickets, TicketsCan, TransCard, Type, UID_Ammessi, Vincite, Vincite25, ecl_Provisioning, ecl_SchedeFirmware, ecl_firmware.

**Non sincronizzate, ma rilevanti:** `CoinlessCards`, `CoinlessTransazioniCards`, `CoinlessDati`, `GruMagazzino`, `GruMagazzinoDettaglio`, `GruMovimenti`, `PrizeHubSlots`, `Compleanni`, `promozioni`, `promozioni_cards`, `RedeemCodes`, `LogTransazioniPos`, `pos_transaction`, `AuditLog`.

Ne seguono due domande:
- i dati coinless arrivano al cloud per un altro canale? Il manuale cita un "ECL Server" in cloud;
- la gestione gru che HQ mostra da dove legge i dati?

---

## 3. Chiavi e identità

**GUID clustered.** 18 tabelle transazionali hanno come chiave primaria clustered un `uniqueidentifier` con default `newid()`. Nessuna usa `newsequentialid()`. Sono: Tickets, TicketsCan, TickRep, Scocard, Vincite, Vincite25, Resi, Prenotaz, MovMag, MovOut, Ordini, Incassi, RiepInv, Differ, EcsDati, EcsErr, TransCard (e scope_config).

> **Ipotesi:** la "chiave a 32 bit e un hash" citata il 07/10 è in realtà questo GUID, che si scrive con 32 cifre esadecimali. Un GUID casuale usato come indice clustered provoca frammentazione e *page split* a ogni inserimento, e quindi degrado delle prestazioni proprio sulle tabelle che crescono di più. È coerente con i problemi segnalati oltre i 2 milioni di righe. Da confermare con Q10.

**Chiavi primarie mancanti.** 15 tabelle non hanno chiave primaria, tra cui `AuditLog`, `CoinlessDataBuffer`, `CoinlessDecodedData`, `pos_transaction`, `UltimoInventario` e `Nayax`.

**Identità del cliente.** È frammentata su più colonne:
- in `Clienti`: `IdContatto`, `IdLong` (chiave primaria), `IdLong2`, `IdMaster1`, `IdMaster2` (master/slave), `CodBar`, `UserName`;
- in `CoinlessCards`: `cardid varchar(16)`, probabilmente l'UID della card RFID;
- in `TransCard`: `IdCli varchar(16)`, mentre altrove i riferimenti al cliente sono `bigint`.

Le tabelle figlie usano nomi diversi per lo stesso concetto (`IdContatto`, `IdCli`, `IdCliente`). Q05 verifica quale colonna di `Clienti` è davvero referenziata.

**Altre incongruenze di tipo.** L'operatore è `Operatori.Id int` ma `decimal(5,0)` nelle tabelle figlie. Il fornitore ha come chiave primaria il **nome** (`Fornitori.Nome`) ed è riferito come testo libero. Il proprietario delle macchine è `EcsMacchine.Propr varchar(100)` contro `Owners.Id int`.

**Numero impianto.** `NImp` compare in 27 tabelle. Può essere il discriminante di impianto pensato per il multi-locale; Q04 mostra quanti valori distinti contiene un database di sala.

---

## 4. Osservazioni per zona funzionale

**Clienti e card** — `Clienti` (50 colonne), `Figli`, `CoinlessCards`, `CoinlessClonedCards`, `UID_Ammessi`, `uid_reservations`, `Mistral`, `Ospiti`, `PartiteOspiti`, `Compleanni`.
- I saldi (`Tickets`, `Bonus`, `Credito`) sono memorizzati **sulla riga del cliente**, oltre che sulla card e, presumibilmente, ricostruibili dai movimenti. Sono tre copie dello stesso dato.
- `Figli` contiene **dati di minori** (nome, data di nascita, sesso, contatti, foto). `Clienti` contiene documento d'identità, data di nascita, sesso e foto. Per il GDPR servono base giuridica, conservazione e minimizzazione.

**Valore e transazioni** — `TransCard` (movimenti ECL; ha **24 indici**, di cui almeno quattro con le stesse colonne chiave), `CoinlessTransazioniCards`, `Tickets`, `TicketsCan`, `Scocard`, `TickRep`, `Abbuoni`, `Incassi`, `RedeemCodes`, `LogTransazioniTotem`, `LogTransazioniPos`, `pos_request`, `pos_transaction`, `Nayax`.
- `LogTransazioniPos` e `LogTransazioniTotem` contengono una colonna `PAN varchar(255)` e dati EMV (`Cryptogram`, `AC`, `IAD`). `pos_transaction` ha `masked_pan` e un campo `dump nvarchar(max)`. **Se il PAN è in chiaro, si pone un problema PCI DSS.** Q07 lo verifica senza estrarre valori.
- `Nayax` è chiaramente l'importazione di un export (nomi di colonna con spazi finali, come "Numero carta").
- `TransCard_Consolidamento_*` indica un intervento di consolidamento o riparazione dei dati già eseguito.
- `RedeemCodes` e le procedure `sp_redeem_*` sono un modulo recente e ben strutturato: prenotazione con scadenza, PIN, tracciamento di dispositivo e postazione. Contiene anche `DbName`, quindi è già consapevole di più database.

**Macchine e telemetria** — `EcsMacchine` (129 colonne), `EcsDati`, `EcsErr`, `EcsModuli`, `Machines`, `Manuf`, `Type`, `Owners`, `BEConfig`, `ecl_*`, `CraneCounterSyncLog`, `cache_dati_grafico_giornaliero`.
- I contatori sono **16**, non 8 come detto in riunione: `In1…In16` in `EcsDati`. Per ciascuno, `EcsMacchine` ha sei gruppi di colonne (`ValIn`, `TipoIn`, `CntrLet`, `CntrVal`, `InCnt`, `RapCnt`), cioè 96 colonne ripetute.
- Ripartizione del noleggio per macchina: `Propr` e `PerDiv` in `EcsMacchine`; `Perc` in `Owners`.
- Livelli card e tariffe: `val_platinum`, `val_gold`, `val_silver`, `val_normal`.
- La logica di calcolo dei contatori è in una decina di funzioni (`fn_valore_contatore`, `fn_verifica_incremento_contatore`, `fn_RicalcolaContatori*`, ecc.). **È la parte di logica nel database che va letta per prima.**

**Premi e magazzino** — `Premi` (45 colonne), `MovMag` (carichi), `MovOut` (scarichi), `Ordini`, `Prenotaz`, `Resi`, `Vincite`, `Vincite25`, `RiepInv`, `UltimoInventario`, `Differ`, `Fornitori`, `PrizeHubSlots`, `Gru*`.
- La giacenza è un campo (`Premi.Quantita`) e non deriva dai movimenti. Questo conferma il problema dell'inventario segnalato il 12/10.
- `MovMag` e `MovOut` hanno struttura identica: sono la stessa entità divisa per segno.
- `Premi` ha 8 coppie `QDis1…8` / `PDis1…8`, cioè gruppi ripetuti per distributore.
- `RiepInv` e `Incassi` contengono una colonna `Mdb varbinary(max)`: **i file Access viaggiano dentro il database**, coerentemente con lo scambio di file `.mdb` descritto in riunione.
- Il modulo gru (`GruMagazzino`, `GruMagazzinoDettaglio` per slot, `GruMovimenti` con `AvgValueBefore`/`After`) è l'unico con chiavi esterne e vincoli CHECK. È progettato meglio del resto ed è un buon riferimento di stile.

**Configurazione** — `Setup` ha **282 colonne in una riga per postazione** (`IDPost`), comprese quattro password. Accanto c'è `setup2` (chiave/valore): sembra l'inizio di una migrazione verso un modello più flessibile.

---

## 5. Campi jolly e residui

- **37 tabelle** hanno campi generici `F0/T0/N0/D0` (bit, testo, intero, data), alcune anche `F1/T1/N1/D1`. Sono "estensioni" senza nome: per capire cosa contengono bisogna leggere il codice. Q06 misura dove sono effettivamente usati.
- Ci sono nomi con suffisso numerico senza spiegazione: `Vincite25` accanto a `Vincite`, `Ric25` e `Pre25` in `Setup`.
- Ci sono tabelle e procedure di servizio o residue: `save_ciapett`, `debug_log`, `sp_generacache_old`.

---

## 6. Implicazioni per il nuovo disegno (prime indicazioni)

1. **Le chiavi vanno decise subito.** Servono identificativi univoci tra sale e cloud senza la frammentazione del GUID casuale: GUID sequenziali o v7 come chiave alternativa, oppure chiave composta impianto + progressivo. Questa scelta condiziona tutto il resto.
2. **Sincronizzazione per eventi di dominio, non per righe.** Il passaggio da Sync Framework a MQTT è l'occasione per far viaggiare *fatti* ("premio consegnato", "carico registrato") invece di righe modificate, con un'autorità esplicita per ogni tipo di fatto.
3. **I saldi devono derivare da un registro di movimenti** (crediti, bonus, ticket, giacenze), non essere campi aggiornati in più posti.
4. **Pagamenti e dati personali** vanno trattati come requisito di progetto, non come dettaglio: PCI DSS per i PAN, GDPR per clienti e minori, password con hash.
5. **Recuperare i moduli recenti.** Gru, Redeem e PrizeHub mostrano che il team sa già lavorare con un modello più pulito.

---

## 7. Domande per il team

1. `IdContatto` e `IdLong` in `Clienti`: quale è l'identificativo "vero" e come vengono generati?
2. Cosa sono `Vincite25`, `Ric25` e `Pre25`?
3. I dati coinless e quelli delle gru arrivano al cloud? Se sì, per quale canale, visto che non sono nella sincronizzazione?
4. Il PAN nei log dei pagamenti è mascherato all'origine?
5. Il database HQ in cloud è uno per sala, con lo stesso schema, oppure un database unico che usa `NImp`?
6. I campi jolly hanno un significato documentato da qualche parte?
