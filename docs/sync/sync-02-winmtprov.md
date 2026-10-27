# Galileo HQ — Sync 02: `WinMtProv`, preparazione della sincronizzazione e del DB cloud

**Stato:** bozza · **Responsabile:** Piero · **Aggiornato:** 2026-10-27

**Fonte:** sorgente in `legacy/WinMtProv/` (escluso dal repository), versione 1.12, `Form1.vb` del 16/06/2026 · **Collegati:** [`sync-00-mappa.md`](sync-00-mappa.md) (mappa e sintesi), [`sync-01-executesync.md`](sync-01-executesync.md), [`sync-03-script-sql.md`](sync-03-script-sql.md) (gli script SQL che lo strumento esegue), `docs/db/db-09-clitest-clienti-multisala.md`

Evidenze `Form1.vb:riga`, relative a `legacy/WinMtProv/WinMtProv/`. **V** = verificato nel codice, **D** = dedotto. Le credenziali scritte nel codice non sono riportate.

---

## 1. Cosa è

**WinMtProv** sta per *WinMT Provisioning*. È lo strumento con cui l'installatore prepara una sala alla sincronizzazione: in Sync Framework il *provisioning* crea in un database lo scope, le tabelle di tracciamento, i trigger e le procedure che registrano le modifiche da sincronizzare.

| | |
|---|---|
| Tecnologia | VB.NET Windows Forms, .NET Framework 4.8, Microsoft Sync Framework 2.1 |
| Dimensioni | `Form1.vb` 1.150 righe, una sola finestra (`Form1.Designer.vb` 291 righe) |
| Versione | 1.12.0.0 (`My Project/AssemblyInfo.vb`); copyright "ELMAC srl unip", 2016–2025 |
| Storico | `Versioni.txt` documenta solo la 1.11 (23/04/2026): secondi trascorsi durante la sincronizzazione e IP del server secondario letto dal DB |
| Dove gira | Sul **server di sala**: si collega sempre a `localhost\winmtsql` (`Form1.vb:51` e seguenti). **V** |
| Distribuzione | L'eseguibile e la cartella `SQLScripts\` accanto (sync 03) |

Fa sei cose, ciascuna con un pulsante:

| Pulsante | Funzione | § |
|---|---|---|
| `PROVISION` | Prepara la sala e crea il suo DB nel cloud; se è spuntato *Local Sync*, anche il DB del server secondario | 3 |
| `DE PROVISION` | Rimuove gli scope dal DB di sala | 3.5 |
| `CLOUD SYNC (1)` | Sincronizza adesso con il cloud | 5 |
| `LOCAL SYNC (2)` | Sincronizza adesso con il server secondario | 5 |
| `MULTI SITE SETUP` | Converte gli identificativi della sala per l'ingresso in un gruppo multisala | 6 |
| Menu *Sync Rate* | Imposta l'intervallo di sincronizzazione | 7 |

## 2. Configurazione nel codice

All'apertura la finestra propone due server cloud e prepara le credenziali (`Form1.vb:24-38`). **V**

| Indice | Server cloud | Con SSH | Credenziali |
|---:|---|---|---|
| 0 | `winmt.elmaccloud.com` | `127.0.0.1,4433` | `sa` del cloud e `sa` della sala, nel codice (`Form1.vb:29, 31`) |
| 1 | `sql.galileouk.cloud` | `127.0.0.1,4433` | `sa` del cloud e `sa` della sala, nel codice (`Form1.vb:30, 32`) |

- La scelta del server cloud sceglie **anche la password `sa` della sala**: le sale dei due ambienti hanno password locali diverse. La coppia è la stessa che compare nelle due varianti di `ExecuteSync` (sync 01 § 4). **V**
- La casella **SSH è spuntata all'avvio** (`Form1.vb:35`). Con SSH il programma si collega a `127.0.0.1:4433`, una porta locale che deve essere inoltrata al server cloud da un tunnel aperto da altri. Senza SSH si collega direttamente al nome pubblico (`Form1.vb:744-752`). Chi apre il tunnel non è nel codice. **V**
- Il cloud si raggiunge come **`sa`**, non con l'utente `WinMtSync` che usa `ExecuteSync`: serve per creare e cancellare database. **V**
- `IstanzaSQL` (`WINMTCLOUD`, `SQLSERVER`) è inizializzato ma mai usato (`Form1.vb:33-34`). **V**

## 3. `PROVISION`: preparare la sala e il cloud

Il pulsante si abilita quando il nome del DB cloud ha 6 caratteri e comincia per `DB` (`Form1.vb:275-283`). Il nome si compila da solo alla scelta del server: `"DB" + Setup(101).NImp` su quattro cifre (`Form1.vb:540-545`). Per Central Park, con `NImp` 196, il DB cloud è `DB0196`. **V**

### 3.1 Scope della sala (`WinMtSync`)

Sul DB di sala crea lo scope `WinMtSync` con l'elenco di tabelle del § 4 e `SetCreateTableDefault(Skip)`: le tabelle esistono già, si aggiungono solo gli oggetti di Sync Framework (`Form1.vb:50-63`). **V**

### 3.2 DB cloud della sala

Si collega al server cloud come `sa` e cerca `DBnnnn` in `master.dbo.sysdatabases` (`Form1.vb:64-73`). **V**

- **Se esiste**, chiede "Remote DB already exists. Delete it?" e poi "Abort deletion of remote DB?". Con *Sì* e poi *No* esegue `DROP DATABASE` e lo ricrea (`Form1.vb:77-90`). Con qualunque altra risposta tiene il DB esistente e prosegue con il provisioning.
- **Se non esiste**, chiede se crearlo (`Form1.vb:93-106`).
- **Creazione** (`CreaWinMtSqlDB`, `Form1.vb:356-377`): `CREATE DATABASE DBnnnn`, `CREATE USER [WinMtSync]` con ruolo `db_owner`, poi la struttura dagli script `SQLScripts\WinMtSqlDB\` nell'ordine Tabelle, Funzioni, Procedure, Viste (`Form1.vb:667-681`). Gli script sono descritti in sync 03.

> **Difetto.** La creazione usa il nome del server scritto nella casella (`CmbCloudS.Text`, `Form1.vb:359`), non l'indirizzo scelto con la casella SSH. Con SSH attivo, il DB si crea collegandosi direttamente al server pubblico e lo si prepara passando dal tunnel. Se il server cloud accetta solo il tunnel, la creazione fallisce. **V**

### 3.3 Scope del cloud

Legge dalla sala la descrizione dello scope appena creato e la applica al DB cloud, con un timeout di 40 minuti (`Form1.vb:110-118`). Le tabelle create dagli script vengono riusate; Sync Framework aggiunge tracciamento, trigger e le 11 procedure per tabella (`sql/codice-db/README.md`). **V**

### 3.4 Server secondario della sala (`LocalSync`)

Solo se è spuntata *Local Sync*. Ripete gli stessi passi verso il **server secondario** della sala, il cui IP sta nella casella `LServer`. Il valore iniziale è `192.168.169.60`, sostituito da `Setup(102).NRep3` se valorizzato (`Form1.vb:139-231, 551-562`). **V**

- Scope `LocalSync` con le stesse tabelle.
- Sul secondario crea `WinMtSqlDB` con l'utente `WinMt` (quello con cui si collega WinMT) e la stessa struttura (`Form1.vb:379-400`).
- Il secondario si raggiunge come `sa` con la stessa password della sala.

In produzione `Setup(102)` contiene `NRep2 = 192.168.169.50` (server principale) e `NRep3 = 192.168.169.60` (secondario). **`LocalSync` è quindi la replica fra il server primario e il secondario della sala**: è la risposta alla domanda aperta da DB 03, DB 04 e DB 06 (sync 00 § 8).

> **Nota.** `Versioni.txt` dice che la 1.11 legge l'IP del secondario da `102:NRep2`. Il codice legge `NRep3`, che è il secondario anche per WinMT (db-08, `Module1.bas:2680`). Vale il codice.

### 3.5 Deprovisioning

`DE PROVISION` rimuove dal DB di sala lo scope `WinMtSync` e, se spuntato *Local Sync*, `LocalSync` (`Form1.vb:236-273`). Non tocca il cloud né il secondario. **V**

### 3.6 Gestione degli errori

- Gli errori dei singoli script SQL compaiono in un `MsgBox`, poi lo strumento prosegue con lo script successivo (`Form1.vb:712-714`): un DB cloud può risultare creato a metà. **V**
- Il provisioning della sala avviene **prima** della domanda sul DB cloud. Se l'installatore rinuncia, la sala resta preparata per uno scope senza controparte. **V**

## 4. Il perimetro della sincronizzazione

L'elenco delle tabelle sincronizzate è **scritto nel codice** (`AddTables`, `Form1.vb:801-1050`) ed è lo stesso per i due scope. Sono 62 tabelle, senza filtri di riga né di colonna: ogni scope sincronizza tutte le colonne di tutte le righe. **V**

Confronto con lo scope `WinMtSync` della produzione (Central Park, copia del 14/07/2026, `sql/risultati/Q11Prod.txt`):

- le **61** tabelle della produzione ci sono tutte;
- WinMtProv 1.12 aggiunge `PrizeHubSlots`, che in produzione esiste ma non è sincronizzata. Lo script della tabella è del 22/05/2026 e il sorgente di WinMtProv del 16/06/2026, quindi dopo il riprovisioning della produzione del 03/06/2026 (DB 06 § 2).

In produzione gli scope hanno `scope_local_id` 3 (`WinMtSync`) e 4 (`LocalSync`): sono stati creati in quest'ordine, che è quello di `PROVISION`, dopo la rimozione di due scope precedenti. **D**

Le 62 tabelle, per area (la matrice di accesso è in ecl2mqtt 08):

| Area | Tabelle |
|---|---|
| Clienti e card | `Clienti`, `Figli`, `Compleanni`, `TipoRicaricheCompleanni`, `Ospiti`, `PartiteOspiti`, `CoinlessClonedCards`, `CoinlessLogEventiBlacklist`, `UID_Ammessi`, `Scocard`, `promozioni`, `promozioni_cards`, `RedeemCodes` |
| Valore | `TransCard`, `Tickets`, `TicketsCan`, `TickRep`, `Abbuoni`, `LogTransazioniTotem`, `LogTransazioniPos`, `Incassi`, `Differ`, `Mistral` |
| Macchine e telemetria | `EcsMacchine`, `EcsModuli`, `EcsDati`, `EcsErr`, `CoinlessMacchineHappyHour`, `CoinlessTestataHappyHour`, `cache_dati_grafico_giornaliero`, `Machines`, `Manuf`, `Type` |
| Schede e firmware | `BEConfig`, `ecl_DeviceProvisioning`, `ecl_Provisioning`, `ecl_firmware`, `ecl_SchedeFirmware`, `CoinlessImages`, `CoinlessLanguages`, `Coinless_sbuilder_page_provisioning`, `coinless_sbuilder_pages`, `coinless_sbuilder_templates_svg` |
| Premi e gru | `Premi`, `Vincite`, `Vincite25`, `Prenotaz`, `Resi`, `MovMag`, `MovOut`, `Ordini`, `Fornitori`, `RiepInv`, `GruMagazzino`, `GruMagazzinoDettaglio`, `GruMovimenti`, `PrizeHubSlots` |
| Configurazione e log | `Setup`, `Setup2`, `Operatori`, `Owners`, `AuditLog` |

**Restano fuori** dal perimetro, fra le altre: `CoinlessCards`, `CoinlessDati`, `CoinlessDataBuffer`, `CoinlessDecodedData`, `CoinlessTransazioniCards` (i dati grezzi e i saldi delle card ECL), `ecl_log`, `CraneCounterSyncLog`, `uid_reservations`, `Logs`, `debug_log`, `save_ciapett`. La telemetria grezza resta in sala; nel cloud arrivano i dati già decodificati (`EcsDati`) e i movimenti (`TransCard`). **V**

> **`Setup` e `Setup2` sono sincronizzate per intero.** Contengono configurazione di sala, configurazione di postazione e stato operativo (ecl2mqtt 08 § 3). La configurazione di una postazione si propaga quindi al secondario e al cloud, e una modifica fatta nel cloud scende in sala. **V** (effetto sulle singole chiavi **D**)

## 5. Sincronizzazione manuale

`CLOUD SYNC (1)` e `LOCAL SYNC (2)` eseguono, in un thread separato e con un cronometro a video, la stessa sessione di `ExecuteSync` (`UploadAndDownload`) sullo scope `WinMtSync` verso il cloud o su `LocalSync` verso il secondario (`Form1.vb:305-338, 766-799, 1052-1144`). Le differenze rispetto a `ExecuteSync`: **V**

- si collega al cloud come `sa`, non come `WinMtSync`;
- mostra l'esito o l'errore nella finestra e non scrive file né database;
- è l'**unico** punto del codice ricevuto che esegue lo scope `LocalSync`.

## 6. `MULTI SITE SETUP`: ingresso della sala in un gruppo

Converte gli identificativi dei clienti dal formato di sala a quello di gruppo: **`IdContatto × 10000 + codice sala`**, dove il codice sala è preso dal nome del DB cloud (`DB0196` → 196). È la formula di `Clienti.IdLong` già descritta in db-08 (`Form1.vb:402-506`). **V**

| Tabella | Istruzione | Marcatura della riga convertita |
|---|---|---|
| `Clienti` | `IdLong = IdContatto × 10000 + sala` per `IdContatto > 0` | Nessuna: si ricalcola ogni volta |
| `Abbuoni` | `Id = Id × 10000 + sala` | `F0 = 1`, solo righe con `F0 = 0` |
| `Prenotaz` | `IDCli = IDCli × 10000 + sala` | `F1 = 1`, solo righe con `F1 = 0` |
| `Tickets` | `IDContatto = IDContatto × 10000 + sala` | `N1 = 1`, solo righe con `N1` nullo o 0 |
| `TicketsCan` | `IDContatto = …` | `F0 = 1`, solo righe con `F0 = 0` |
| `TickRep` | `IDCliente = …` | `F0 = 1`, solo righe con `F0 = 0` |
| `TransCard` | `IDCli = …` | `F0 = 1`, solo righe con `F0 = 0` |
| `Vincite`, `Vincite25` | `IDContatto = …` | `F0 = 1`, solo righe con `F0 = 0` |

Le righe con cliente 0 (anonimo) restano invariate. Le istruzioni per portare `IdLong` a chiave primaria e le colonne a `bigint` sono commentate: lo schema degli script le ha già (sync 03). Non c'è transazione: un errore a metà lascia alcune tabelle convertite e altre no. **V**

**Cosa dice dei dati.**

1. **I flag `F0`/`F1`/`N1` di queste tabelle significano "riga in formato di gruppo".** È coerente con db-08 per `TransCard.F0`, `Vincite.F0` e `Prenotaz.F1` ("sala in gruppo multisala" al momento della scrittura). Per `Tickets.N1`, `TicketsCan.F0`, `TickRep.F0`, `Vincite25.F0` e `Abbuoni.F0` è un significato nuovo, da aggiungere a db-08. **V**
2. **In `Abbuoni` converte `Id`, che è l'operatore che ha concesso l'abbuono**, non il cliente (db-08; `ModAddNew.bas:830-838` di WinMT). Dopo la conversione l'abbuono non punta più a un operatore esistente. **V** sul codice; se sia voluto **non è noto**.
3. **Rieseguirla non è sicuro.** La guardia sul flag protegge solo le righe scritte con il flag a 1. Le righe scritte con il flag a 0 ma già in formato di gruppo verrebbero moltiplicate una seconda volta:
   - il motore `ecl2mqtt` scrive sempre `TransCard.F0 = 0` (ecl2mqtt 08 § 3), anche quando `IdCli` è un `IdLong`;
   - `AddAbbuono` di WinMT non valorizza `Abbuoni.F0`;
   - `sp_preleva_punti` inserisce lotti in `Tickets` senza `N1` (DB 09 § 3).

   **V** sul codice; nessun caso osservato.
4. **In produzione non risulta eseguita.** Central Park è una sala singola: `Abbuoni.F0` e `Tickets.N1` non valgono mai 1. **V** (dati del 14/07/2026)

## 7. Intervallo di sincronizzazione

Il menu *Sync Rate* chiede i secondi e scrive `Setup(101).N0`. La finestra mostra `Setup(101).SyncRes` e `N0` (`Form1.vb:536-546, 721-742`). Il valore è concatenato nell'istruzione SQL senza controlli (`Form1.vb:732`). **V**

WinMT invece legge e scrive l'intervallo in **`Setup(110).N0`** (`frmsetSys.frm:9271-9296`), e `sp_last_trans` del DB di gruppo lo legge in `Setup(101).N0` della copia cloud. Il conflitto è descritto in sync 00 § 2.3.

## 8. Codice morto

| Elemento | Dove | Cosa avrebbe fatto |
|---|---|---|
| `ModSetupTable` | `Form1.vb:508-529` | Allargare `Setup.T6` e `T7` a 1.000 caratteri; mai chiamata |
| `CreaSP`, `CreaViste`, `CreaFunzioni` | `Form1.vb:601-665` | Creare la struttura da file `.txt` (`SPWinMtSqlDB.txt` e simili): metodo precedente agli script per cartella; mai chiamate |
| `GetPK` | `Form1.vb:571-599` | Leggere il nome della chiave primaria di `Clienti` per ricrearla su `IdLong`; il risultato è usato solo dalle righe commentate |
| `SyncChg`, `SyncProgr`, `StateChanged` | `Form1.vb:18, 339-350` | Avanzamento della sincronizzazione; i gestori sono commentati |
| `IstanzaSQL`, `ClsaPW`, `LocsaPW`, `LHost`, `RHost` | `Form1.vb:12-20, 33-34` | Variabili non usate |

## 9. Credenziali e sicurezza

| Dove | Cosa |
|---|---|
| `Form1.vb:29-30` | Due password `sa` del DB di sala, una per ambiente |
| `Form1.vb:31-32` | Due password `sa` dei server cloud |
| `bin/*/WinMtProv.exe` | Le stesse, compilate |
| `bin/*/SQLScripts/WinMtSqlDB/Procedure/collegamentoserver.sql` | Password `sa` del linked server `elmaccloud` (sync 03 § 5) |

Con l'eseguibile si ottiene `sa` su entrambi i server cloud, quindi su tutti i DB di tutte le sale dei due ambienti, compreso `DROP DATABASE`. I comandi sono composti concatenando testo (nome del DB, intervallo), senza parametri. **V**

## 10. Flussi

| Id | Flusso | Descrizione | Trigger/attore | Peso | Tabelle (R/W/D/DDL) | Evidenza | Equiv. WinMT | Rapporto |
|---|---|---|---|:-:|---|---|---|---|
| SY02-01 | Lettura della configurazione di sync | Nome del DB cloud da `Setup(101).NImp`, esito e intervallo da `Setup(101)`, IP del secondario da `Setup(102).NRep3` | Installatore, scelta del server | S | Setup R | `Form1.vb:531-569` | W10 (configurazione di sistema) legge le stesse righe | Parziale: WinMT usa la riga 110 per l'intervallo |
| SY02-02 | Provisioning dello scope `WinMtSync` in sala | Scope con le 62 tabelle, oggetti di Sync Framework | Installatore | M | `scope_*`, `*_tracking`, trigger e procedure SF (DDL) | `Form1.vb:50-63, 801-1050` | — | Unico |
| SY02-03 | Creazione del DB cloud della sala | `CREATE DATABASE DBnnnn`, utente `WinMtSync` `db_owner`, struttura dagli script; con conferma, `DROP` del DB esistente | Installatore | M | DB cloud (DDL) | `Form1.vb:64-107, 356-377, 667-719` | — | Unico |
| SY02-04 | Provisioning dello scope nel cloud | Applica al DB cloud la descrizione dello scope della sala | Installatore | S | DB cloud (DDL) | `Form1.vb:109-122` | — | Unico |
| SY02-05 | Preparazione del server secondario | DB `WinMtSqlDB` sul secondario con utente `WinMt` e struttura dagli script, scope `LocalSync` su entrambi | Installatore, *Local Sync* | M | Sala e secondario (DDL) | `Form1.vb:139-231, 379-400` | — | Unico |
| SY02-06 | Deprovisioning | Rimuove gli scope dalla sala | Installatore | S | DDL | `Form1.vb:236-273` | — | Unico |
| SY02-07 | Sincronizzazione manuale con il cloud | Come SY01-01, con utente `sa` ed esito a video | Installatore | — | Come SY01-01 | `Form1.vb:305-338, 1052-1097` | — | **Duplicato** di SY01-01, non contato |
| SY02-08 | Sincronizzazione con il server secondario | Sessione `UploadAndDownload` su `LocalSync` | Installatore | M | Le 62 tabelle, sala e secondario | `Form1.vb:766-799, 1099-1144` | — | Unico; nessuna esecuzione periodica nel codice ricevuto |
| SY02-09 | Intervallo di sincronizzazione | Scrive i secondi in `Setup(101).N0` | Installatore, menu | S | Setup W | `Form1.vb:721-742` | `frmsetSys` scrive `Setup(110).N0` | **Doppione con regola diversa** (riga diversa) |
| SY02-10 | Conversione della sala per la multisala | Identificativi dei clienti in formato di gruppo in nove tabelle (§ 6) | Installatore | M | Clienti, Abbuoni, Prenotaz, Tickets, TicketsCan, TickRep, TransCard, Vincite, Vincite25 U | `Form1.vb:402-506` | WinMT scrive già `IdLong` alla creazione del cliente (db-08) | Unico; rischio di doppia conversione |
| SY02-11 | Allargamento di `Setup.T6/T7` | `ALTER TABLE` | — | — | Setup DDL | `Form1.vb:508-529` | — | **Morto** |
| SY02-12 | Creazione della struttura da file `.txt` | Metodo precedente agli script per cartella | — | — | — | `Form1.vb:601-665` | — | **Morto** |
