# Galileo HQ — DB 09: `CliTest`, il DB clienti centrale di un gruppo multisala

**Stato:** bozza · **Responsabile:** Piero · **Aggiornato:** 2026-10-25

**Fonte:** esportazione Navicat di `CliTest` dal server cloud `winmt.elmaccloud.com` (25/10/2026, `sql/codice-db/clitest.dbo.sql`, esclusa da git), ricostruita sull'istanza di analisi `ThinkCentre-2\SQLEXPRESS`; codice estratto in `sql/codice-db/clitest/`; sorgenti di WinMT e del motore `ecl2mqtt` · **Collegati:** `docs/winmt/winmt-02-moduli-comuni.md` (§ multi-locale), `docs/ecl2mqtt/ecl2mqtt-00-mappa.md` (§ 4.3), `db-08-dizionario-dati.md`

Fabrizio descrive `CliTest` come "un DB che sta nel cloud, ma che non è nessuno di quelli menzionati", e ricorda che "in WinMT c'è una connectionstring dedicata". **Entrambe le affermazioni sono confermate.** `CliTest` è il **database clienti centrale di un gruppo multisala**, in versione di test: tiene la copia condivisa di `Clienti` e le procedure con cui una sala usa i punti guadagnati nelle altre. Non è `CoinlessDB`, né un `DBnnnn` di sala, né un DB di servizio.

---

## 1. Le evidenze

| Evidenza | Dove |
|---|---|
| WinMT ha una stringa di connessione dedicata: `CServer`, letta da `Setup(101).T7` e decodificata con `DecPWord`, nel formato `server\|utente\|password\|database` | `Module1.bas:2619`; uso in `Form1.frm:5808-5826`, `10366-10368`; `FrmDeCliML.frm:4124-4125` |
| Sul database `CCred(3)` di quella connessione WinMT chiama `sp_last_trans`, `sp_preleva_punti`, `sp_preleva_punti_gold` e le altre procedure "solo cloud" di WinMT 00 § 7 | `Form1.frm:5826`, `5916`, `5969`, `6023`, `10368` |
| `CliTest` contiene proprio quelle procedure: `sp_last_trans(_gold)`, `sp_preleva_punti(_gold)`, `sp_punti_cliente(_gold)`, `sp_vincite_cliente`, più `sp_leggiconfig` e `sp_verifica_syncro` | `sql/codice-db/clitest/applicativo/procedure/` |
| Il suo log (`t_log`, 391 righe) registra esecuzioni reali di `SP_PRELEVA_PUNTI` e `SP_PRELEVA_PUNTI_GOLD` tra il 2021 e il 2023 | dati di `CliTest.t_log` |
| `Clienti` vi è sincronizzata con Sync Framework in tre scope, `SyncCli1012`, `SyncCli1014` e `SyncCli1015`: uno per sala, su tutte le 50 colonne, chiave `IdLong` | `scope_info`, `scope_config` |
| I 91 clienti appartengono alle sale 1012 (3), 1014 (8) e 1015 (80), con `IdLong = IdContatto × 10000 + NImp` | dati di `CliTest.Clienti` |
| Il motore chiama le stesse procedure su un DB configurabile, `setup2.DbClientiMultilocale`, con valore predefinito `rdclienti` | `WINMtConfig.bas:332-333`; `DBwinmt.bas:7885`, `8424` |

> **Deduzione.** Esiste un DB di questo tipo per ogni gruppo multisala. Il nome lo sceglie l'installazione: è in `Setup(101).T7` per WinMT e in `setup2.DbClientiMultilocale` per il motore. `rdclienti` è probabilmente quello di un gruppo reale, `CliTest` quello di prova. Le due copie di sala che abbiamo (Central Park 196 e test 9997) hanno `T7` e `T6` vuoti: non sono in un gruppo, quindi non lo si può verificare dai loro dati.

## 2. Contenuto

| Oggetto | Tipo | Ruolo |
|---|---|---|
| `Clienti` | tabella, 50 colonne | Copia condivisa dei clienti del gruppo, stessa struttura della sala. Sincronizzata con ogni sala |
| `Clienti_tracking`, `scope_info`, `scope_config`, `schema_info` | tabelle Sync Framework | Metadati della sincronizzazione |
| `t_log` | tabella, una colonna `nvarchar(max)` | Log di debug delle procedure |
| `cacca` | tabella | Tabella di lavoro di `sp_preleva_punti`: i lotti di ticket raccolti dalle sale (`locale`, `IdContatto`, `tickets`, `tpagati`, `keys`) |
| `sp_last_trans`, `sp_last_trans_gold` | procedure | Blocco della card usata da poco in un'altra sala (§ 3) |
| `sp_preleva_punti`, `sp_preleva_punti_gold` | procedure | Prelievo dei punti dalle altre sale del gruppo (§ 3) |
| `sp_punti_cliente(_gold)`, `sp_vincite_cliente` | procedure | Punti e vincite di un cliente nel gruppo, per periodo; leggono anche `Operatori` e `Vincite` delle sale |
| `sp_leggiconfig` | procedura | Elenco delle sale del gruppo, da `DB<locale>.Setup(101).T6` dopo il `#` |
| `sp_verifica_syncro` | procedura | Stato della sincronizzazione (`Setup.MName`, `SyncRes`) di tutti i `DB%` del server |
| `fn_decode_mt_bitmask` | funzione | Decodifica di `Tickets.MangiaT` |

## 3. Come funziona oggi la multisala

Il quadro che emerge: sul server cloud stanno insieme le copie di ogni sala (`DBnnnn`, sincronizzate con la sala) e il DB clienti del gruppo. **Le regole multisala girano lì**, con query costruite dinamicamente sui database delle sale.

1. **Blocco della card (`sp_last_trans`).** L'intervallo minimo si legge da `DB<locale>.Setup(101).N0`, in secondi. Se la card è stata usata in un'altra sala da meno tempo (`Clienti.D0`, con `Clienti.N0` = sala diversa), la procedura risponde 0 e WinMT blocca l'operazione. Altrimenti risponde 1 e, se richiesto, scrive `N0 = sala`, `D0 = adesso` e i ticket. In `sp_last_trans_gold` l'aggiornamento è commentato e resta solo un `print`.
2. **Prelievo dei punti (`sp_preleva_punti`).** La sala consuma prima i suoi punti; per la parte mancante chiama la procedura, che:
   - legge l'elenco delle sale del gruppo (`T6`);
   - raccoglie i lotti con saldo delle **altre** sale, ma solo da quelle sincronizzate da meno di `@intervallo` secondi (`DB<sala>.Setup(101).D1`, ultimo sincronismo);
   - se i punti bastano, li consuma un lotto alla volta. Nel DB della sala d'origine, se il lotto va consumato tutto ne aggiorna `TPagati` e `N0` (la sala che ha consumato). Se è già consumato in parte, lo **divide e cancella l'originale**: un lotto con la parte già pagata, uno saldato con `N0` = sala richiedente e, se avanza, uno con il residuo;
   - nel DB della sala richiedente inserisce un lotto "specchio" già saldato, con `NonCont = 1`, `F0 = 1` e `N0` = sala d'origine (`sp_preleva_punti.sql:95-117`).

   Questo spiega due colonne di `Tickets` in sala: `NonCont = 1` marca i lotti specchio dei prelievi multisala, che non vanno contati come vinti; `N0` indica la sala d'origine o quella che ha consumato.
3. **Propagazione.** Le modifiche fatte sulle copie cloud tornano nelle sale con il sincronizzatore.

## 4. Cosa significa per l'analisi

| Punto | Tipo |
|---|---|
| Le "procedure che esistono solo nel cloud" di WinMT 00 § 7 sono localizzate. Manca solo `sp_unione_card`, che in `CliTest` non c'è | fatto |
| **`Clienti.N0` ha due significati nella stessa tabella sincronizzata.** In sala è il flag ticketless (0/1, db-08). Nel DB centrale `sp_last_trans` ci scrive il codice dell'ultima sala (1012, 1014, 1015) con `D0`. Nei dati convivono entrambi: 77 righe con 0/1, 12 con un codice di sala, 2 vuote. Lo scope sincronizza tutte le colonne, quindi il codice di sala può arrivare nel `Clienti.N0` della sala, dove WinMT e il motore lo leggono come flag ticketless | fatto (dati e codice); effetto in sala **ipotesi**, da verificare su una sala in gruppo |
| Il prelievo dei punti scrive su più database senza transazione: `BEGIN TRANSACTION` e `COMMIT` sono commentati (righe 88 e 193). Un errore a metà lascia i lotti di una sala saldati e quelli dell'altra no | fatto |
| La tabella di lavoro `cacca` è globale e svuotata a ogni chiamata: due prelievi contemporanei la sovrascrivono. La logica usa una tabella temporanea, quindi l'effetto è solo sul log | fatto |
| Il motore usa `setup2.DbClientiMultilocale` per `sp_last_trans`, ma per `sp_preleva_punti` ha `rdclienti` fisso nel codice (`DBwinmt.bas:8424`). In un gruppo con un DB di nome diverso, il prelievo dal totem o dall'app andrebbe sul database sbagliato | fatto (codice); effetto **ipotesi** |
| Per il nuovo sistema: la multisala oggi dipende dalla freschezza della sincronizzazione (`Setup.D1`) e da scritture incrociate tra i DB delle sale. Un registro unico dei movimenti nel cloud, con le sale come client, eliminerebbe sia il blocco a intervallo sia il lotto "specchio" | orientamento |

## 5. Come è stato ricostruito

- Creato `CliTest` sull'istanza di analisi ed eseguita una copia dello script Navicat con due correzioni: `SET DATEFORMAT ymd` prima delle `INSERT` (il login ha lingua italiana) e la rimozione dalle `INSERT` delle colonne `timestamp` (`scope_info.scope_timestamp`, `Clienti_tracking.local_update_peer_timestamp`). Lo script originale non è stato modificato.
- **Risultato:** tutte le righe caricate (`Clienti` 91, `Clienti_tracking` 100, `t_log` 391, `cacca` 3, scope 3). Create 9 procedure e una funzione applicative, 8 procedure e 3 trigger di Sync Framework.
- **Mancanti:** `Clienti_bulkinsert`, `Clienti_bulkupdate` e `Clienti_bulkdelete`, perché Navicat non esporta il tipo tabella `Clienti_BulkType`. Sono generate da Sync Framework e non servono all'analisi.
- **Dati personali:** `Clienti` contiene nomi e alcuni recapiti. Lo script resta fuori da git; si versiona solo il codice.

## 6. Domande aperte

1. Quanti gruppi multisala esistono e come si chiamano i loro DB clienti (`rdclienti` e altri)? `CliTest` è ancora usato per le prove?
2. Le sale 1012, 1014 e 1015 sono sale reali o di prova?
3. `Clienti.N0` con il codice di sala arriva davvero nelle sale del gruppo? Serve il DB di una sala in gruppo, oppure la configurazione degli scope lato sala.
4. `sp_unione_card`, chiamata da WinMT, dove si trova?
5. Nel motore, `rdclienti` fisso per `sp_preleva_punti`: è voluto?
