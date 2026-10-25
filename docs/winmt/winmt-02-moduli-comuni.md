# Galileo HQ — WinMT 02: Moduli comuni e accesso ai dati

**Stato:** bozza · **Responsabile:** Piero · **Aggiornato:** 2026-10-23

**Fonte:** sorgente VB6 di WinMT (copia del 24/07/2026), file: `Module1.bas`, `Module6.bas`, `ModAddNew.bas`, `Module8.bas`, `Module5.bas`, `Module3.bas`, `Module2.bas`, `Module4.bas`, `API.bas`, `EncDec.bas`, `mdAesEcb.bas`, `jsonparser.bas`, `modPList.bas`, `cls_translator.cls`, `ClassEventi.cls`, `cDbSmartSelect.cls`, `DirectoryHandler.cls`, `AccSavePic.bas`, `basConvert.bas`, `KeyValueHandler.bas`, `FrmPMsg.frm` e utility di interfaccia (§ 1) · **Collegati:** `analisi/analisi-00-prima-lettura.md`, `db/db-01-schema.md`, `db/db-02-catalogo.md`, `db/db-06-produzione-02.md`, `db/db-07-confronto-test-produzione.md`, gli altri documenti `winmt/`

Questo documento è il **riferimento per le altre zone**: descrive come WinMT si collega ai database, quali variabili globali fanno da stato dell'applicazione e cosa leggono e scrivono le funzioni condivise. Il catalogo delle funzioni condivise è al § 2.0.

Legenda: **[V]** verificato nel codice, con riferimento `file:riga`; **[D]** dedotto, da confermare. Le credenziali presenti nel codice non sono riportate.

---

## 1. Perimetro

| File | Righe | Ruolo | Lettura |
|------|------:|-------|---------|
| `Module1.bas` | 3353 | Avvio (`Main`), connessioni, licenza, caricamento e salvataggio di `Setup`, variabili globali, utilità ticket (`UID_Ammesso`, `UpdateTicket`, `AggOggi`, `SetD0Vincite`, `CancellaVincita`), bonus a scaglioni, CRC per i POS | A fondo |
| `Module6.bas` | 2325 | Profilazione operatore (`SetOp`), punti cliente, manual tickets, verifica card e blacklist, saldo da `TransCard`, stampa scontrino e chiusura cassa, backup, email, blocco premi, codifica password | A fondo |
| `ModAddNew.bas` | 1346 | Funzioni di scrittura riusate: una per tabella (`Add*`), creazione e riscrittura cliente, movimenti `TransCard`, ricostruzione saldo card | A fondo |
| `Module8.bas` | 443 | Lettura scontrino cartaceo (`TrovaSco`), ricalcolo punti clienti anche multi-locale, test connessione | A fondo |
| `Module5.bas` | 502 | Verifica numero di serie (solo build speciali), esportazione Excel. **Non contiene le prenotazioni** | Scorso |
| `API.bas` | 321 | Scelta del provider SQL, classificazione ticket (`IdTicket`), separatori, valore piatto macchina | A fondo le parti dati |
| `Module3.bas` | 168 | Stato rete, salvataggio JPG, durata tessera (`Setup` 102 `N1`) | Parti dati |
| `Module4.bas` | 259 | Elenco IP locali per l'autodiscovery | Scorso |
| `Module2.bas` | 53 | Compressione zlib e utilità file (backup "DPK") | Scorso |
| `EncDec.bas` | 69 | Cifrario a scorrimento di caratteri. **Mai chiamato** | A fondo |
| `mdAesEcb.bas` | 350 | AES-256 tramite CNG (`bcrypt`), con PBKDF2. **Mai chiamato** | A fondo |
| `jsonparser.bas` | 686 | Libreria JSON (autodiscovery, valori JSON in `setup2`) | Scorso |
| `cls_translator.cls` | 281 | Traduzioni da `translations.tsv`, scaricato all'avvio da un URL HTTPS | Scorso |
| `ClassEventi.cls` | 111 | Card compleanno: ricerca, ripristino livello | A fondo |
| `cDbSmartSelect.cls`, `cSmartSelectItem.cls`, `frmSmartSelectPopup.frm` | 325 + 25 + 117 | Casella di ricerca con autocompletamento su SQL parametrico | Scorso |
| `DirectoryHandler.cls` | 143 | Cartelle per indirizzo email (usate da redeem e compleanni) | Scorso |
| `FrmPMsg.frm` | 236 | Messaggi dei clienti dall'app, letti da un servizio HTTP Elmac | A fondo |
| `AccSavePic.bas`, `basConvert.bas`, `KeyValueHandler.bas`, `KeyValuePair.cls`, `WaitExe.bas`, `ModLiveUpdt.bas` | 131, 126, 76, 27, 53, 6 | Blob↔file, esadecimale, collezioni chiave/valore, esecuzione sincrona di comandi, puntatore mouse | Scorsi |
| `cls_AdodcLite.cls` | 36 | Sostituto leggero dell'ADODC. **Nessun utilizzatore** | Scorso |
| Utility di interfaccia: `CFormBorder.cls` (353), `modPList.bas` (426, stampa ListView), `ModuMWheel.bas` (114), `frmAbout.frm` (114), `FormPopup.frm` (75), `FrmMsg.frm` (63), `FrmMsgX.frm` (24), `FrmWait.frm` (43), `FormWaitPlease.frm` (24), `formInputDate.frm` (24), `formInputBox.frm` (21), `fmDebugLogger.frm` (33), `FrmZoom.frm` (3), `FormSplash.frm`, `FrmPreView.frm` (0, nessun utilizzatore), `Docking.bas`, `cls_dockig.cls` (nessun utilizzatore) | — | Solo interfaccia | Elencati |

Per rispondere alle domande sono stati letti anche, solo nei punti indicati: `ModuleMultilocale.bas` (20 righe, intero), `ECL_database.cls` (versione DB), `cls_setupV2.cls` (`setup2`), `ClassPromozioni.cls:199` (livello card), `ECL_command.cls:191` (UID), `Form1.frm` (login operatore e lettura card), il trigger `bannaUtente`.

---

## 2. Flussi

### 2.0 Catalogo delle funzioni condivise

Ogni funzione apre e chiude una propria connessione ADO con `CsMtconc1`. Salvo `AddCliente`, **nessuna usa transazioni**. Le chiavi GUID (`Keys`, `IDOperazione`) **non sono mai valorizzate dal codice**: le genera il default `newid()` del database [V, tutte le `Add*` di `ModAddNew.bas`]. "Multi" indica che il comportamento cambia se la sala è in un gruppo multi-locale (`NetSites` ≠ "", § 4.2).

**Scritture (ModAddNew.bas)**

| Funzione | Riga | Tabella | Cosa scrive e con quali default | Chiamanti |
|----------|-----:|---------|--------------------------------|----------:|
| `AddCliente` | 543 | `Clienti` | Transazione `SERIALIZABLE`; `IdContatto` = primo valore libero sia in `Clienti.IdContatto` sia in `TransCard.IdCli` (`NextIdContattoTxn`, 697); `IdLong` = `IdContatto × 10000 + NImp`; `CodBar` da `UID_Ammessi` se non fornito; `T0` = UID; `TipoCard` da `ClassPromozioni.ImpostaLivello`; `N0` = 0 ticketless / 1 cartacei; `Modificato` = 1, `OperMod` = operatore, `TimeMod` = ora; `HasTelephoneNumberCorrect` = 0, `EMailIsCertified` = 0, `Bonus` = 0. Tre tentativi su violazione di chiave | 8 file |
| `AggCliente` | 1278 | `Clienti` | Riscrive l'anagrafica trovata per `IdLong`; azzera i flag di certificazione se email o cellulare cambiano; azzera la segnalazione di clonazione (`F1` = 0, `T1` = `D1` = NULL); `TipoCard` negativo → 0 | 4 file |
| `AddScon` | 61 | `Tickets` | Una riga ticket: `IdContatto` (0 = scontrino anonimo; in multi-locale è `IdLong`), `NumTickets`, `Data`, `MangiaT` (tipo, § 3), `NumTrans` (numero di serie), `TPagati`, `DataOut`, `Oper`, `OperOut`, `NonCont`, `Id` = postazione, `Aux`, `NRep`, `NImp`, `T0` = prefisso raccolta, `D0` = ora se punti "gold" | 23 file, 59 chiamate |
| `ManualTicket` | 1054 | `Tickets` | Ticket manuale in sospeso: `MangiaT` = 4, `TPagati` = −IdPost, `Id` = 1, `NRep` = 1, `T0` = `MANUAL TICKETS` | 4 file |
| `AddSconCan` | 743 | `TicketsCan` | Scontrino annullato; `DataCan` sempre NULL | 4 file |
| `AddTicCli` / `AddPunti` | 923 / 1037 | `Clienti` | `Tickets` += n, `DataUltVis` = ora. Multi: per `IdLong` | 4 / 1 file |
| `AddVincita` | 29 | `Vincite` | Premio consegnato o prenotato: `Id` = operatore, `Cons`, `D0` = data consegna se `Cons`, `F0` = multi-locale, `N0` = punti gold usati [D] | 3 file |
| `AddVin25` | 894 | `Vincite25` | Premio sopra soglia fiscale con nome, cognome e barcode (§ 3) | 2 file |
| `AddPrenot` | 854 | `Prenotaz` | Prenotazione: `T0` = numero ordine, `F1` = multi-locale, `DataCon` NULL | 2 file |
| `AddResi` | 99 | `Resi` | Premio reso; `Id` passato dal chiamante | 3 file |
| `AddPremio` / `AddPremioF` | 127 / 165 | `Premi` | Default: `QPren` = 0, `Ordinato` = 0, `Attivo` = 1, `Locked` = 0, `Prenotabile` = 1; `AddPremioF` aggiunge la foto | 7 / 2 file |
| `ModificaPremio` | 987 | `Premi` | Aggiorna codice, descrizione, costo, ticket, quantità, riserva | 2 file |
| `AddMovIn` / `AddMovOut` | 204 / 237 | `MovMag` / `MovOut` | Carico / scarico, stessi campi: `Oper`, `NBolla`, `NOrdine`, `Motivo`, `Note`, `NImp` | 5 / 3 file |
| `AddOrdine` | 796 | `Ordini` | Ordine a fornitore con `QOrd`, `QCons` | 4 file |
| `AddFornit` | 333 | `Fornitori` | Anagrafica fornitore (chiave = nome) | 4 file |
| `AddOper` | 364 | `Operatori` | Anagrafica operatore con `Livello`, `CodBar`, password | 4 file |
| `AddAbbuono` | 830 | `Abbuoni` | `Id` = operatore, `Valore`, `Tickets` | 2 file |
| `AddDiffer` | 1015 | `Differ` | Data e variazione di valore | 2 file |
| `AddIncas` | 770 | `Incassi` | Incasso per categoria (`Red`, `Gru`, `Alt`, `Push`) | 2 file |
| `AddTickRep` | 397 | `TickRep` | Ticket per reparto | 1 file |
| `AddMistral` | 422 | `Mistral` | Card di raccolta: `CodCard` = codice + serie, `IdPost`. `NImp` non scritto | 4 file |
| `AddFiglio` | 3 | `Figli` | Figlio del cliente | 2 file |
| `AddTransCard` | 1086 | `TransCard`, `Clienti` | Movimento di valore su card (§ 2.6) e `Clienti.Credito` | 12 file, ~40 chiamate |
| `addVenditaGettoni` | 1660 | `TransCard`, `Clienti` | Come sopra, tipo 3, con `ValoreBonus` | 2 file |
| `RiallineaSaldoSuTranscard` / `RiscriviSaldoSuTranscard` | 1621 / 1641 | `TransCard` | Movimento a valore 0 di tipo 19 / 20 che fissa il saldo | 1 / 1 |
| `pulisciDaTranscardUltimeTransazioniIncerte` | 1578 | `TransCard` | **DELETE** dei movimenti con progressivo oltre l'ultimo verificato. Nessun chiamante attivo | 0 |

**Letture e aggiornamenti condivisi (altri moduli)**

| Funzione | Posizione | Legge | Scrive |
|----------|-----------|-------|--------|
| `UID_Ammesso` | `Module1.bas:3634` | `UID_Ammessi` (primi 8 caratteri dell'UID, `CodBar` non vuoto) | `UID_Ammessi` se l'opzione di auto-inserimento è attiva |
| `getCodbarFromUID` | `ModAddNew.bas:712` | `UID_Ammessi` | — |
| `FindBCCard` / `FindRFID` | `ModAddNew.bas:270` / `302` | `Clienti.CodBar`/`T0`, `Operatori.CodBar`/`T0` | — (unicità della card tra clienti e operatori) |
| `UpdateTicket` | `Module1.bas:3958` | — | `Tickets` per `Keys`: `NumTickets`, `TPagati`, `MangiaT`, `D0` |
| `AggOggi` | `Module1.bas:3440` | `Tickets` di oggi del cliente | — |
| `SetD0Vincite` | `Module1.bas:3701` | — | `Vincite.Cons`, `Vincite.D0` (all'avvio) |
| `CancellaVincita` | `Module1.bas:3587` | — | **DELETE** `Vincite` per `Keys` |
| `TogliPunti` / `TogliPuntiGS` | `Module6.bas:1877` / `1912` | `Tickets` | `Tickets.TPagati`, `OperOut`, `DataOut` (consumo FIFO) |
| `SettaPuntiCard` / `SettaPuntiCardGS` | `Module6.bas:1822` / `1852` | — | `Clienti.Tickets` (e `Bonus`), `DataUltVis` |
| `AbilitaCard` / `DisabilitaCard` | `Module6.bas:1772` / `1797` | — | `Clienti.Abilita` |
| `VerificaCard` | `Module6.bas:2219` | `TransCard` | — (imposta lo stato globale `LastClonedCard`) |
| `MettiInBlackList` | `Module6.bas:2352` | — | `Clienti.F1/T1/D1`, `CoinlessClonedCards`, `CoinlessLogEventiBlacklist`; chiamata HTTP al server ECL |
| `cercaUltimiCreditiCliente` + `creaSQLPercercaUltimiCreditiCliente*` | `ModAddNew.bas:1522`, `1359–1521` | `TransCard`, `Setup` | — |
| `LastCntProg`, `ValoreRimanente` | `ModAddNew.bas:1598`, `Module6.bas:2510` | `TransCard` | — |
| `UpdateQty`, `LockPrize`, `UnLockPrize` | `Module6.bas:1427–1482` | — | `Premi.Quantita` (sovrascritta), `Premi.Locked` |
| `TrovaSco` | `Module8.bas:2` | `Tickets` | `Tickets` (blocco o inserimento scontrino esterno) |
| `TrovaPremio` | `Module8.bas:126` | `Premi.Codice`/`CodOr` | — |
| `SettaTicBonClienti` / `SettaTicBonCliente` | `Module8.bas:258` / `403` | `Tickets` locali o di tutte le sale del gruppo | `Clienti.Tickets`, `Clienti.Bonus` |
| `ContaTickets`, `IdTicket` | `Module6.bas:1693`, `API.bas:293` | `Tickets` | — |
| `Bon24`, `CalcBonus` | `Module6.bas:860`, `Module1.bas:3725` | `Tickets`; scaletta in memoria | — |
| `RilasciaManualTicket`, `UsaManualTickets`, `AssegnaManualTickets`, `SettaManualTickets` | `Module6.bas:2017–2073` | — | `Tickets` (DELETE/UPDATE), `Setup.NRep2` |
| `StampaSco`, `StampaCassa` | `Module6.bas:49`, `2592` | variabili globali | stampante seriale |
| `CaricaVarInc` | `Module6.bas:2091` | `Setup(101).T14+T15` | — |
| `AbilOmaRimb` | `Module6.bas:2650` | `Operatori.N0` | — |
| `LeggiMaccBL`, `LeggiOpBL`, `LeggiMotBL` | `Module6.bas:2529–2590` | `EcsMacchine`, `CoinlessClonedCards`, `CoinlessLogEventiBlacklist` | — |
| `UltimoInv`, `InvExists` | `Module6.bas:832`, `1246` | `RiepInv` con `F0` = 0 | — |
| `CarInc` | `Module6.bas:1302` | `Incassi.Mdb` con `F0` = 1 | file `PrecInc.mdb` |
| `ScriviDurCard` / `LeggiDurCard` | `Module3.bas:222` / `237` | `Setup(102).N1` | `Setup(102).N1` |
| `ScadAbb` | `Module6.bas:2489` | `Setup(102).D0` | — |
| `SaveLog2DB` | `Module1.bas:3397` | — | `Logs` (crea la tabella se manca) |
| `SaveSetPost`, `SalvaValGett` | `Module1.bas:2917`, `Module6.bas:1411` | — | `Setup` |
| `IdOrIdlong`, `stIdFieldFromClienti`, `isMultilocale` | `ModuleMultilocale.bas:2–20` | `NetSites` | — |
| `GetSetupValue` / `SetSetupValue` | `cls_setupV2.cls:84` / `330` | `setup2` | `setup2` (upsert) |

### W02-01 Avvio dell'applicazione e connessione al database

- **Attore e innesco:** l'operatore avvia `WinMtSql.exe` su una postazione o un totem. `Sub Main` [V `Module1.bas:699`].
- **Passi:**
  1. Esce se c'è già un'istanza; carica le traduzioni (§ W02-21) e la lingua del sistema operativo [V `Module1.bas:709–728`].
  2. Legge dal registro di Windows dell'utente server, utente, password e nome DB, codificati con `EncPWord` (§ 4.6) [V `Module1.bas:746–750`].
  3. **Autodiscovery**: invia sulla rete una richiesta di ricerca del server e attende fino a 3 s; la risposta JSON fornisce `SqlServer` e `AppMode` (`RT` → `REALTIME`, altrimenti `ECL`); una seconda richiesta fornisce le versioni di `Ecl2Mqtt` e del DB, con default fissi se non risponde. Il server trovato viene salvato nel registro [V `Module1.bas:771–830`].
  4. Se mancano utente o password usa un utente predefinito scritto nel codice (credenziale scritta nel codice in `Module1.bas:878`); se mancano server o password apre `frmSetSql` [V `Module1.bas:877–894`].
  5. Se il server non risponde al ping resta in attesa; su richiesta dell'operatore cerca un **server secondario** (`SLAVEFIND`) e propone il passaggio [V `Module1.bas:915–967`]. Prima di ritentare la connessione può **accendere il server via Wake-on-LAN** con uno strumento HP (`AccendiServer`, parametri cifrati nel registro) [V `Module1.bas:991`, `3580`].
  6. Costruisce le stringhe di connessione (§ 4.1) e verifica la licenza (W02-03) [V `Module1.bas:969–977`].
  7. Apre e chiude una connessione di prova con timeout di 1 s, ripetendo ogni 5 s in caso di errore [V `Module1.bas:979–995`, `1223–1226`].
  8. Imposta `CSCloud` (W02-02), capisce se i dati coinless stanno in un DB separato (`CoinlessDB`) [V `Module1.bas:996–1001`].
  9. **Aggiorna lo schema del database**: ricava la versione dello schema dalla presenza di tabelle e colonne (`ECL_database.dbversion`) e, se inferiore a soglie fisse, crea tabelle, colonne e stored procedure (`setup2`, `LogTransazioniPos`, `uid_reservations`, `RedeemCodes`, `sp_crane_force_avg_value`, ecc.) e corregge dati (`fixTicketsInClienti`); purga i log [V `Module1.bas:1003–1044`, `ECL_database.cls:185–203`].
  10. Carica la configurazione (W02-02), sceglie la versione del monitor cliente (`setup2` `2NdScreenVersion`), legge la politica ticket hardware (`setup2` `HardwareTicketsPolicy`, JSON, scritta con default se assente) [V `Module1.bas:1058–1083`].
  11. Se `Setup.CodEcs` = `ECL`, si connette al **broker MQTT locale** e si iscrive a `ElmacECL/Server`, `ECLClients/Server`, `ElmacECL/+` [V `Module1.bas:1093–1110`].
  12. Controlla che il numero impianto della licenza coincida con `Setup.NImp` (W02-03), salva `IDPost` nel registro, crea le raccolte Mistral se servono [V `Module1.bas:1115–1137`].
  13. Se la postazione ha mangiatickets seriali avvia `MTLinkSql.exe` e attende lo stato `RUNNING` [V `Module1.bas:1151–1169`].
  14. **Controllo dell'orologio**: se l'ora di chiusura salvata (`Setup.DataStop`) è nel futuro, il programma si chiude [V `Module1.bas:1187–1197`].
  15. Aggiorna le vincite (`SetD0Vincite`, W02-15), scrive `bootComplete.txt`, apre `Form1` e la finestra di login [V `Module1.bas:1200–1211`].
- **Dati:** `Setup` (L, e U per default mancanti), `setup2` (L/U), `Operatori` (L, I dell'operatore 9999), `Vincite` (U), DDL su varie tabelle.
- **Regole:** il nome del database è fisso (`WinMtSqlDB`); timeout di connessione di 1 s; versione schema dedotta per introspezione.
- **Periferiche:** rete (UDP di autodiscovery, ping), broker MQTT, `MTLinkSql` per le mangiatickets, Wake-on-LAN.
- **Senza rete:** senza server SQL l'applicazione **non parte**; resta in attesa o propone il server secondario. Non c'è modalità locale.
- **Peso: L** — molte varianti, periferiche, migrazioni di schema dal client, server secondario.
- **Evidenze:** `Module1.bas:699–1228`.

### W02-02 Identificazione della postazione e caricamento della configurazione

- **Attore e innesco:** automatico all'avvio (`CaricaSetup`) [V `Module1.bas:1859`].
- **Passi:**
  1. Controlla se `TransCard` ha la colonna `ValoreBonus` (`valsets.IsBonusInTranscard`) [V `Module1.bas:1898–1920`].
  2. `CaricaGen` legge il **primo record di `Setup`** (IDPost 101) in `valsets` e in decine di globali; se alcuni campi sono NULL li inizializza e li salva [V `Module1.bas:2373–2596`].
  3. Passa al secondo record (IDPost 102) per IP principale e secondario (`NRep2`, `NRep3`), timeout di switch (`NRep4`, default 30 s), privacy (`F0`), parametri di conversione Silver↔Gold (`MisVCard`, `MisVSerie`) [V `Module1.bas:2669–2694`].
  4. Legge `Setup(110).T0` (super password); in sua assenza usa un default scritto nel codice (credenziale scritta nel codice in `Module1.bas:2712`).
  5. Stabilisce se esiste un totem (`Setup.F1` = 1 su una postazione < 110); se la sincronizzazione è abilitata crea l'operatore 9999 "Galileo App" [V `Module1.bas:2715–2730`].
  6. Scompone `Setup(101).AdmPass` nei parametri ECL (§ 3) [V `Module1.bas:2735–2754`].
  7. `CaricaPost` cerca tra le righe `Setup` con IDPost < 110 quella il cui `MName` inizia con il **nome del computer**; se non la trova occupa la prima riga libera; se non ce ne sono, "Too many users" e chiusura. Scrive `MName` = `nomecomputer|` + un carattere che codifica la porta del secondo lettore barcode; carica porte seriali, stampante, POS, fondo cassa [V `Module1.bas:2790–2915`].
  8. `CaricaVipPromotionParams` legge `setup2` `VipSubscriptionParams` (JSON) [V `Module1.bas:2765`].
- **Dati:** `Setup` (L/U), `setup2` (L), `Operatori` (L/I).
- **Regole:** IDPost 101 = configurazione generale e postazione principale; 102 = configurazione aggiuntiva e seconda postazione; 103–109 = altre postazioni; 110 = record riservato; ≥ 111 = raccolte card (§ 3, `Setup.IDPost`). La creazione di una nuova postazione "slave" (`CaricaVarMaster`, `SalvaVarNew`) è codice morto: `NewUser` è sempre falso [V `Module1.bas:736`, `1870`].
- **Peso: M** — una tabella sola ma 282 colonne, campi jolly con significati diversi per record, inizializzazioni implicite.
- **Evidenze:** `Module1.bas:1859–2915`.

### W02-03 Controllo della licenza

- **Attore e innesco:** avvio (`KeyLocate`) [V `Module1.bas:973`, `1311`].
- **Passi:**
  1. Cerca la chiave hardware HASP (`HaspDemo.RunDemo`, `RunDemoNew`).
  2. In assenza, ricorre alla **licenza software** in `Setup(110)`: `F1` = licenza valida, `T1` = tipo di licenza ("Single User", "4 Users", "2 Users", "Easy Software", "WinBet Software", "Prize Hub", "TotemSql", "Jolly Key", "Sql"). Il nome del database cloud diventa `DB` + `Setup(101).NImp` [V `Module1.bas:1335–1398`].
  3. Il tipo di licenza imposta le modalità `MultiUsers`, `SScreen`, `EasyMode`, `PrizeHubKey`, `TotemSqlKey`.
  4. Se il numero impianto della licenza (`Mid(SqlDB, 3, 4)`) è diverso da `Setup.NImp`: "Incorrect Dongle Key!" e chiusura [V `Module1.bas:1115–1122`].
- **Dati:** `Setup(110).F1`, `T1` (L), `Setup(101).NImp` (L).
- **Regole:** il numero impianto è legato alla licenza. La licenza "Jolly" disattiva il controllo.
- **Periferiche:** chiave USB HASP.
- **Peso: M** — riguarda la modularità commerciale (moduli attivabili).
- **Evidenze:** `Module1.bas:1311–1410`, `1115–1122`.

### W02-04 Salvataggio della configurazione

- **Attore e innesco:** un amministratore conferma le impostazioni di sistema; 13 file chiamano `SaveSetPost` [V `Module1.bas:2917`].
- **Passi:**
  1. Se la postazione è **Master** scrive tutte le opzioni generali nel primo record di `Setup` (101), ricompone `AdmPass` dai parametri ECL, poi scrive nel record 102 il server SQL, l'IP secondario e i parametri Silver↔Gold [V `Module1.bas:2927–3204`].
  2. Altrimenti aggiorna (o aggiunge) solo il record della propria postazione: porte, stampante, POS, cassa, `MName` [V `Module1.bas:3206–3250`].
- **Dati:** `Setup` (U/I).
- **Regole:** `MdbSaveInt` è riusato per il moltiplicatore punti `MolPun` (sempre ≥ 1) [V `Module1.bas:2541`, `3066`].
- **Peso: M** — molte colonne, distinzione master/slave.
- **Evidenze:** `Module1.bas:2917–3264`.

### W02-05 Apertura della sessione operatore e profilazione dei menu

- **Attore e innesco:** l'operatore appoggia la propria card sul lettore o si autentica; `Form1` valorizza le globali e chiama `Module6.SetOp` [V `Form1.frm:11373–11387`, `Module6.bas:181`].
- **Passi:**
  1. `Form1` cerca l'operatore per `Operatori.T0` = UID della card e imposta `idx` = `Operatori.Id`, `LvLx` = `Livello And 3`, nome e cognome, `OpLog` = vero [V `Form1.frm:11373–11386`].
  2. `SetOp` carica l'oggetto `OperatoreInCanna` e mostra o nasconde menu e pulsanti secondo il livello: 0 amministratore, 1 manager, 2 operatore, 3 supervisore; per il supervisore usa le opzioni di `Setup(101).T4` separate da `|` [V `Module6.bas:181–449`].
  3. Se la gestione cassa è attiva (`Setup.GCassa`) apre il login con il fondo cassa [V `Form1.frm:11388–11400`].
- **Dati:** `Operatori` (L), `Setup` (in memoria).
- **Regole:** i permessi sono **solo nell'interfaccia** (menu visibili), non nelle funzioni né nel DB. Alcune opzioni dipendono anche dalla postazione Master e dalle varianti cliente (`Golden`, `Mistral`).
- **Peso: M** — quattro ruoli, opzioni per ruolo e per supervisore.
- **Evidenze:** `Module6.bas:181–469`.

### W02-06 Registrazione di un movimento di valore su card ECL

- **Attore e innesco:** qualunque operazione di cassa o totem che cambia il saldo della card (ricarica, bonus, rimborso, omaggio, trasferimento, compleanno, conversione). Chiamato da 12 file [V `ModAddNew.bas:1086`].
- **Passi:**
  1. Inserisce in `TransCard`: `IdCli` = cliente (`IdLong` in multi-locale), `CodMac` = **nome del computer**, `Data` come testo `dd/mm/yyyy hh:nn:ss`, `ValoreOperazione`, `ValoreFinale`, `Operatore`, `ValoreCassa`, `WinMt` = 1, `N0` = progressivo card, **`NImp` = codice tipo operazione**, **`T0` = numero impianto a 4 cifre**, `F0` = multi-locale [V `ModAddNew.bas:1119–1133`].
  2. Aggiorna `Clienti.Credito` = `ValoreFinale / CentConversionFactor` per la card con `T0` = UID [V `ModAddNew.bas:1135`].
  3. `addVenditaGettoni` fa lo stesso con tipo 3 e `ValoreBonus` [V `ModAddNew.bas:1691–1708`].
- **Dati:** `TransCard` (I), `Clienti.Credito` (U).
- **Regole:** codici di tipo in § 3 (`TransCard.NImp`). Due scritture separate senza transazione. La data passa come stringa nel formato italiano: dipende dall'impostazione di lingua della connessione [D].
- **Peso: M** — tabella centrale del valore, codifiche, effetti su `Clienti`.
- **Evidenze:** `ModAddNew.bas:1086–1147`, `1660–1721`.

### W02-07 Ricostruzione del saldo card dai movimenti

- **Attore e innesco:** lettura di una card da riallineare o rigenerare (cassa, recupero card, conversione) [V `ModAddNew.bas:1522`].
- **Passi:**
  1. Calcola da `TransCard` del cliente: ultimo saldo e progressivo dell'**ultimo movimento verificato** (`FlagOpDaVerificare` NULL), crediti e bonus come somme per tipo:
     - crediti = Σ `ValoreOperazione` dei tipi 0, 1, 2, 11, 13, 14 (da WinMT) − Σ dei tipi 10, 18 e dei movimenti senza tipo (giocate);
     - bonus = Σ dei tipi 6, 8, 9, 16 (da WinMT) − Σ `ValoreBonus` delle giocate − Σ del tipo 15 [V `ModAddNew.bas:1365–1401`].
  2. `RiallineaCreditiBonus` rende coerenti crediti e bonus con il saldo: se il saldo supera 60.000 (in valuta) azzera tutto come anomalia; altrimenti risolve i quattro casi di segno documentati nel codice [V `ModAddNew.bas:1149–1218`].
  3. Converte in centesimi e restituisce crediti, bonus e saldo; il chiamante riscrive la card e registra un movimento tipo 19 (riallineamento) o 20 (riscrittura) [V `ModAddNew.bas:1558–1572`, `1621–1658`].
- **Dati:** `TransCard` (L, I), `Setup.T6` (L, per scegliere `IdLong` o `IdContatto`).
- **Regole:** il saldo autorevole è l'ultimo `ValoreFinale` verificato, ordinato per progressivo `N0`; la ripartizione crediti/bonus è ricostruita, non memorizzata (salvo `ValoreBonus` per i movimenti più recenti).
- **Periferiche:** lettore/scrittore card ECL.
- **Peso: L** — logica di riconciliazione card–DB con casi limite.
- **Evidenze:** `ModAddNew.bas:1359–1658`.

### W02-08 Verifica di coerenza della card e messa in blacklist

- **Attore e innesco:** lettura di una card cliente in cassa (`Form1`, `frmAstoria`, `FrmUCardECL`) [V `Form1.frm:11672–11684`, `11774–11776`].
- **Passi:**
  1. `VerificaCard` legge da `TransCard` l'ultimo movimento verificato e l'ultimo in assoluto (per progressivo `N0`) e confronta con saldo e progressivo letti dalla card [V `Module6.bas:2239–2282`]:
     - progressivo card ≥ ultimo in DB e saldo card ≤ saldo DB → **valida** (ci possono essere giocate non ancora trasmesse);
     - progressivo card ≥ ultimo verificato e saldo card ≤ saldo verificato → **da riallineare** (`LastClonedCard(3)` = `rallinea`);
     - altrimenti → **sospetta clonazione**.
     - Nessun movimento → valida (card nuova o rigenerata).
  2. Se da riallineare, `Form1` riformatta la card e la riscrive dai dati del DB (W02-07) [V `Form1.frm:11676–11680`].
  3. Se sospetta, `MettiInBlackList` conta le letture consecutive della stessa card: **alla terza** scrive `Clienti.F1` = 0, `T1` = postazione, computer, saldo e progressivo, `D1` = ora; inserisce in `CoinlessClonedCards` (`TipoMovimento` = `Lettura`, `CodMac` = `WinMt`) e in `CoinlessLogEventiBlacklist`; chiama `http://<server>:58889/eclcommand?command=jrefreshBlacklist` per inviare la blacklist alle schede [V `Module6.bas:2352–2384`, `2423–2432`].
- **Dati:** `TransCard` (L), `Clienti` (U), `CoinlessClonedCards` (I, che fa scattare il trigger `bannaUtente`), `CoinlessLogEventiBlacklist` (I).
- **Regole e anomalie:**
  - il controllo "crediti + bonus > 400.000" imposta l'esito negativo ma non esce, e l'esito viene poi sovrascritto dai controlli successivi: **non ha effetto** [V `Module6.bas:2226–2233`];
  - la funzione forza la globale `CentConversionFactor` a `0.01` per tutta l'applicazione [V `Module6.bas:2294`];
  - la card viene identificata con l'UID a 16 caratteri (`T0`) [D, `ECL_command.cls:191`]. Il trigger `bannaUtente` cerca invece `Clienti.T0 = cardid + '00000000'` e `CoinlessCards.cardid` a 8 caratteri: **per le card messe in blacklist da WinMT il trigger probabilmente non trova né il cliente né la card coinless** [D].
- **Periferiche:** lettore card ECL; HTTP verso il servizio ECL sul server (porta 58889).
- **Peso: L** — antifrode, stato tra letture successive, effetti su schede e trigger.
- **Evidenze:** `Module6.bas:2219–2432`.

### W02-09 Creazione di un cliente

- **Attore e innesco:** operatore in emissione nuova card (8 file chiamanti) [V `ModAddNew.bas:543`].
- **Passi:**
  1. Ricava il barcode dall'UID tramite `UID_Ammessi` se non indicato [V `ModAddNew.bas:566`, `712–740`].
  2. In transazione serializzabile, calcola `IdContatto` = max + 1, saltando i valori già presenti in `Clienti` o in `TransCard.IdCli` [V `ModAddNew.bas:575–580`, `697–709`].
  3. Inserisce il cliente (§ 2.0) con il livello calcolato da `ImpostaLivello`: se c'è una promozione attiva la card diventa Gold e il livello originale va in `promozioni_cards` [V `ClassPromozioni.cls:199–217`].
  4. Ritenta fino a 3 volte su chiave duplicata.
- **Dati:** `Clienti` (I), `UID_Ammessi` (L), `TransCard` (L), `promozioni_cards` (I).
- **Regole:** `IdLong` = `IdContatto × 10000 + NImp` è l'identificativo globale nel gruppo multi-locale [V `ModAddNew.bas:624`].
- **Peso: M** — generazione dell'identificativo, livello, transazione.
- **Evidenze:** `ModAddNew.bas:543–740`.

### W02-10 Aggiornamento di un cliente

- **Attore e innesco:** modifica anagrafica o riscrittura card (4 file) [V `ModAddNew.bas:1278`].
- **Passi:** trova il cliente per `IdLong`, riscrive tutti i campi, azzera i flag di certificazione se email o cellulare cambiano, **cancella la segnalazione di clonazione** (`F1`, `T1`, `D1`) [V `ModAddNew.bas:1290–1326`].
- **Dati:** `Clienti` (U).
- **Peso: S** — un solo UPDATE, con una regola sui flag.
- **Evidenze:** `ModAddNew.bas:1278–1337`.

### W02-11 Verifica che una card fisica sia ammessa

- **Attore e innesco:** emissione o lettura di una card RFID (8 file) [V `Module1.bas:3634`].
- **Passi:** cerca in `UID_Ammessi` un UID con gli stessi **primi 8 caratteri** e barcode non vuoto; se non c'è e l'opzione "Aggiungi UID" è attiva (`Setup(101).F11`) inserisce l'UID con `CodBar` = UID troncato a 15 caratteri [V `Module1.bas:3643–3652`, `2634–2638`].
- **Dati:** `UID_Ammessi` (L/I).
- **Regole:** il commento della variabile indica `Setup\102\F1`, il codice legge `Setup(101).F11` [V `Module1.bas:167`, `2634`].
- **Peso: S**.
- **Evidenze:** `Module1.bas:3634–3661`.

### W02-12 Emissione e stampa di uno scontrino ticket

- **Attore e innesco:** operatore (scontrino manuale, resto, totale, reparto) o sistema (bonus); `AddScon` + `StampaSco` (9 file per la stampa) [V `ModAddNew.bas:61`, `Module6.bas:49`].
- **Passi:**
  1. Calcola il **numero di serie** = ultima cifra dell'anno × 10⁸ + secondi trascorsi dall'inizio dell'anno [V `Module6.bas:105–107`, `887–903`].
  2. Stampa intestazione (messaggio configurabile da `MsgSco.bin`), concorso, data, numero di serie, ticket e, se `MolPun` > 1, i punti = ticket × `MolPun` [V `Module6.bas:68–144`].
  3. Stampa il barcode: reparto (1 cifra) + numero di serie (9) + ticket (5) + cifra di controllo modulo 10 pesata 3/1 [V `Module6.bas:145–166`].
  4. Il chiamante registra lo scontrino con `AddScon` (§ 2.0).
- **Dati:** `Tickets` (I).
- **Regole:** il numero di serie dipende dall'orologio della postazione e si ripete ogni 10 anni; due scontrini nello stesso secondo hanno lo stesso numero [D].
- **Periferiche:** stampante termica seriale, sei modelli (`Setup.TypePrt`).
- **Peso: M** — formato del barcode, varianti di stampante.
- **Evidenze:** `Module6.bas:49–179`, `ModAddNew.bas:61–97`.

### W02-13 Lettura di uno scontrino cartaceo e blocco alla postazione

- **Attore e innesco:** l'operatore legge col lettore barcode uno scontrino emesso da mangiatickets o da altri apparecchi (4 file) [V `Module8.bas:2`].
- **Passi:**
  1. Decodifica il barcode: inizia con `1` = scontrino della sala (14 caratteri: vecchi EL2000/MT6; altrimenti Galileo/Galileo PRO); altrimenti scontrino esterno (16 caratteri: Galileo o Deltronic; altri: ticket station) [V `Module8.bas:20–38`].
  2. Cerca in `Tickets` uno scontrino anonimo (`IdContatto` = 0), non ausiliario, non pagato, con lo stesso numero di serie e numero di ticket.
  3. Se lo trova lo **blocca alla postazione**: `TPagati` = −IdPost [V `Module8.bas:100–108`].
  4. Se non lo trova ed è uno scontrino esterno con prefisso ammesso (`Setup.TSSNum0…9`) e il riconoscimento è attivo (`Setup.TicStat`), lo inserisce con `MangiaT` = 6 (convalidato) già bloccato [V `Module8.bas:45–54`].
  5. In modalità "Golden" non usa gli scontrini con `D0` valorizzato fuori dal carico su card (esito 8) [V `Module8.bas:81–98`].
- **Dati:** `Tickets` (L/U/I).
- **Regole:** codici di ritorno 0–8 documentati nel codice. Il blocco con `TPagati` negativo serve a più postazioni concorrenti; se l'operazione si annulla il chiamante deve rimetterlo a 0 [V `Module1.bas:148–149`].
- **Periferiche:** lettore barcode.
- **Peso: M** — formati di barcode, concorrenza tra postazioni.
- **Evidenze:** `Module8.bas:2–124`.

### W02-14 Aggiornamento dei punti del cliente

- **Attore e innesco:** consegna premio, caricamento ticket sulla card, bonus.
- **Passi:**
  1. **Consumo FIFO**: `TogliPunti` scorre i ticket del cliente con residuo, dal più vecchio, e porta `TPagati` a `NumTickets` finché i punti richiesti sono coperti, scrivendo `OperOut` e `DataOut` [V `Module6.bas:1877–1910`]. `TogliPuntiGS` consuma prima i punti "silver" (`D0` NULL), poi i "gold" (`D0` valorizzato) [V `Module6.bas:1912–1970`].
  2. **Saldo sul cliente**: `SettaPuntiCard` sovrascrive `Clienti.Tickets` (e `Bonus` in modalità Golden); `AddPunti` e `AddTicCli` lo incrementano; tutti aggiornano `DataUltVis` [V `Module6.bas:1822–1875`, `ModAddNew.bas:923–945`, `1037–1052`].
- **Dati:** `Tickets` (U), `Clienti.Tickets`, `Bonus`, `DataUltVis` (U).
- **Regole:** `Clienti.Tickets` è una copia del residuo dei `Tickets`, aggiornata a mano in più punti; il residuo si ricalcola con W02-16.
- **Peso: M**.
- **Evidenze:** `Module6.bas:1822–1970`.

### W02-15 Registrazione e chiusura delle vincite

- **Attore e innesco:** consegna o prenotazione di un premio (`AddVincita`), cancellazione (`CancellaVincita`), avvio (`SetD0Vincite`).
- **Passi:**
  1. `AddVincita` registra il premio con `Cons` = non prenotato e `D0` = data di consegna se consegnato subito [V `ModAddNew.bas:29–59`].
  2. All'avvio, se `Setup.AbPr` è attivo, le vincite non consegnate da oltre 365 giorni vengono **segnate come consegnate**; in ogni caso `D0` viene copiato da `Data` dove manca [V `Module1.bas:3710–3715`].
  3. `CancellaVincita` cancella fisicamente la riga [V `Module1.bas:3587–3603`].
- **Dati:** `Vincite` (I/U/D).
- **Regole:** il commento parla di "prenotazioni abilitate" ma il flag usato, `AbPr`, è descritto come "abilitazione promozioni" [V `Module1.bas:378`, `3710`].
- **Peso: S**.
- **Evidenze:** `Module1.bas:3587–3723`, `ModAddNew.bas:29–59`.

### W02-16 Ricalcolo dei punti di tutti i clienti

- **Attore e innesco:** funzione di manutenzione (3 file) [V `Module8.bas:258`, `403`].
- **Passi:**
  1. Se `Salva` è vero, salva in un file `CalcCard*.txt` le differenze tra `Clienti.Tickets` e il residuo calcolato [V `Module8.bas:280–343`].
  2. Aggiorna `Clienti.Tickets` = Σ (`NumTickets` − `TPagati`) dei ticket non ausiliari; in modalità Golden separa silver (`D0` NULL) e gold (`Bonus` = gold / 100) [V `Module8.bas:346–366`].
  3. **Multi-locale**: si collega al server cloud con `CServer` e calcola la somma sui database di **tutte le sale del gruppo** (`db0196.dbo.Tickets` UNION …), dopo aver atteso due intervalli di sincronizzazione più un minuto [V `Module8.bas:367–394`].
- **Dati:** `Tickets` (L), `Clienti` (U), sul DB locale o su più DB cloud.
- **Regole:** in multi-locale il cliente è identificato da `IdLong`, che i ticket portano nella colonna `IdContatto`. Nel ramo di confronto locale la join è su `IdLong` anche quando la sala non è multi-locale [V `Module8.bas:294`]: il file delle differenze può essere sbagliato [D].
- **Peso: L** — query tra database, attesa della sincronizzazione.
- **Evidenze:** `Module8.bas:258–482`.

### W02-17 Manual tickets

- **Attore e innesco:** l'operatore legge un codice `TK…KT` [V `Module1.bas:11–15`].
- **Passi:**
  1. Alla prima lettura `SettaManualTickets` imposta `Setup(101).NRep2` = `Cards Collections` [V `Module6.bas:2052–2062`].
  2. `ManualTicket` inserisce un ticket in sospeso (`TPagati` = −IdPost, `T0` = `MANUAL TICKETS`) [V `ModAddNew.bas:1054–1084`].
  3. Alla conferma: `UsaManualTickets` li segna come pagati (`MangiaT` = 132) oppure `AssegnaManualTickets` li attribuisce al cliente (`TPagati` = 0, `MangiaT` = 4); all'annullamento `RilasciaManualTicket` li cancella [V `Module6.bas:2017–2073`].
- **Dati:** `Tickets` (I/U/D), `Setup` (U).
- **Peso: M** — stato temporaneo per postazione, tre esiti.
- **Evidenze:** `Module6.bas:2017–2073`, `ModAddNew.bas:1054`.

### W02-18 Bonus su ticket e su ricarica

- **Attore e innesco:** emissione ticket o ricarica.
- **Passi:**
  1. `Bon24`: somma i ticket del cliente dall'ora di apertura di oggi; se con i nuovi si supera la soglia `Setup.NT24H`, concede `Setup.FT24H` ticket [V `Module6.bas:860–885`].
  2. `CalcBonus`: applica ripetutamente la scaletta `ScaVal` (8 coppie importo/bonus, da `Setup(101).T10`): per un importo prende lo scaglione più alto raggiungibile, somma il bonus e sottrae l'importo dello scaglione finché resta capienza [V `Module1.bas:3725–3762`].
- **Dati:** `Tickets` (L, tramite il controllo ADODC di `Form1`), `Setup` (in memoria).
- **Peso: M**.
- **Evidenze:** `Module6.bas:860`, `Module1.bas:3725`.

### W02-19 Statistiche dei ticket per tipo

- **Attore e innesco:** report e rapporti (3 file) [V `Module6.bas:1693`, `API.bas:293`].
- **Passi:** raggruppa `Tickets` del periodo per reparto (`NRep And 15`) e per sala collegata (`N0`), sommando contati, collegati, esterni, convalidati, bonus, manuali, ausiliari, ricevuti e pagati in altre sale secondo i bit di `MangiaT` (§ 3) [V `Module6.bas:1718–1745`]. `AggOggi` dà i ticket netti di oggi per cliente [V `Module1.bas:3440`].
- **Dati:** `Tickets` (L).
- **Peso: M** — la definizione delle misure dipende dalla bitmask.
- **Evidenze:** `Module6.bas:1693–1753`, `API.bas:293–324`.

### W02-20 Servizi tecnici: backup, log, email, blocco premi, stampa cassa

- **Backup del DB**: se il server è locale e `Setup.BkDisk` è valorizzato, `BACKUP DATABASE WinMtSqlDB` in `DbBk\` della postazione, conservando le ultime 24 copie [V `Module6.bas:685–720`].
- **Log su DB**: `SaveLog2DB` carica il file di log della postazione come blob in `Logs` [V `Module1.bas:3397–3424`].
- **Email di servizio**: SMTP con utente e password scritti nel codice (credenziale scritta nel codice in `Module6.bas:2180`); aggiorna `Setup(101).D3` [V `Module6.bas:2161–2207`].
- **Blocco premi**: `LockPrize` scrive in `Premi.Locked` l'IDPost della postazione che modifica la quantità; `UpdateQty` **sovrascrive** `Premi.Quantita` [V `Module6.bas:1427–1482`].
- **Chiusura di cassa**: stampa operatore, inizio e fine turno e valore di cassa `valsets.VCassa` [V `Module6.bas:2592–2648`].
- **Peso: S** — operazioni singole.

### W02-21 Traduzioni e messaggi dall'app

- **Traduzioni**: all'avvio scarica `translations.tsv` da un URL HTTPS con timeout di 1 s, altrimenti usa il file locale [V `cls_translator.cls:89–215`].
- **Messaggi dei clienti** (`FrmPMsg`): chiede a un servizio HTTP (non HTTPS) su un dominio cloud Elmac la lista dei messaggi della sala (`listmsg|<NImp>`), con la richiesta offuscata da `EnCodeStr` ed esadecimale; li salva in `lstmsg.mdb`; segna come letti (`readmsg`) e risponde con una notifica push [V `FrmPMsg.frm` `LstMsg`, `ReadMsg`, `CmdSend_Click`].
- **Dati:** `lstmsg.mdb` (D/I), nessuna tabella SQL.
- **Senza rete:** le funzioni falliscono in silenzio.
- **Peso: M** (messaggi), S (traduzioni).

### W02-22 Scambio di file `.mdb`

- **Copia dei modelli**: all'avvio copia in `Documenti\<exe>\` i file `Incas.mdb`, `PremiPH.mdb`, `KitPremi.mdb` e, in HQ, `GenWins.mdb` e `Suppliers.mdb` [V `Module6.bas:1984–1996`].
- **Connessione Access**: `CsKitpremi` apre `kitpremi.mdb` via ODBC (credenziale scritta nel codice in `Module1.bas:970`), usata dai kit premi e dal carico da lista [V `FrmCariPO.frm:1355`, `FrmKit.frm:1707`].
- **File dentro il DB**: `Field2File`/`File2Field` trasferiscono file tra disco e colonne `varbinary` [V `Module6.bas:1265–1300`]. `CarInc` estrae l'incasso `Incassi.Mdb` (righe `F0` = 1, generate da EcsNet) in `PrecInc.mdb` [V `Module6.bas:1302–1318`, `Module1.bas:41`]. I kit premi inviati da HQ arrivano in `RiepInv.Mdb` con `F0` = 1 [V commento `Module1.bas:43–46`].
- **Peso: M** — tre canali diversi, dati che viaggiano fuori dal modello relazionale.

### W02-23 Abilitazione e disabilitazione della card cliente

- `AbilitaCard`/`DisabilitaCard` scrivono `Clienti.Abilita` = 1/0 per `IdContatto`, o per `IdLong` in multi-locale [V `Module6.bas:1772–1820`]. **Peso: S**.

### W02-24 Card compleanno

- `ClassEventi.cercaCardCompleanno` cerca il cliente per `Clienti.T0` e, tramite `Ospiti.CardId` = `Clienti.T0`, l'evento `Compleanni` con crediti e bonus precaricati [V `ClassEventi.cls:83–138`]. A fine evento `aggiornaClienteWinMt` riporta `Clienti.TipoCard` al livello precedente, **sempre Silver** [V `ClassEventi.cls:37–56`, `113`].
- `rimuoviClienteDaCompleanno` contiene SQL malformato (`WHERE t0 = 'like …'` su tabelle senza colonna `T0`, e la seconda query concatenata alla prima): **non può funzionare** [V `ClassEventi.cls:58–82`].
- **Peso: S** (la gestione compleanni vera è in altre zone).

---

## 3. Significato delle colonne

| Tabella.Colonna | Significato | Valori / codifiche | Evidenza | |
|---|---|---|---|---|
| `TransCard.NImp` | **Tipo di operazione**, non numero impianto | 0 carico da cassa fissa; 1 carico da totem; 2 carico da cassa mobile; 3 scarico su totem (gettoni acquistati, monete cambiate); 4 carico per hopper vuoto; 5 dobloni (Astoria) o gettoni (Albarella); 6 bonus; 7 svuotamento cassa; 8 rimborso al cliente; 9 omaggio; 10 crediti trasferiti ad altra card; 11 crediti acquisiti da altra card; 12 rimborso dall'operatore; 13 ricarica compleanno; 14 acquisto online; 15 storno; 16 bonus acquisiti da altra card; 18 abbonamento; 19 riallineamento o conversione card; 20 riscrittura; NULL = movimento da macchina (giocata) | `ModAddNew.bas:1091–1110`, `1129`, `1378–1389`, `1650` | V |
| `TransCard.T0` | Numero impianto | 4 cifre con zeri (`0196`) | `ModAddNew.bas:1130` | V |
| `TransCard.F0` | Sala in gruppo multi-locale | 1 sì, 0 no | `ModAddNew.bas:1131` | V |
| `TransCard.CodMac` | Per le operazioni WinMT: nome del computer della postazione | `Environ("computername")`; per le giocate il codice macchina | `ModAddNew.bas:1121` | V (giocate: D) |
| `TransCard.WinMt` | Operazione fatta da postazione o totem | 1 | `ModAddNew.bas:1127`, `Module1.bas:8` | V |
| `TransCard.Operatore` | Id dell'operatore | < 1000 postazione, ≥ 1000 totem | `Module1.bas:9` (commento) | V |
| `TransCard.ValoreOperazione`, `ValoreFinale` | Importo e saldo dopo l'operazione, in valuta | `ValoreFinale` / `CentConversionFactor` = saldo in centesimi | `ModAddNew.bas:1135`, `Module6.bas:2309` | V |
| `TransCard.ValoreBonus` | Quota bonus del movimento | Scritta solo da `addVenditaGettoni`; sottratta per le giocate nel calcolo del bonus | `ModAddNew.bas:1691`, `1385` | V |
| `TransCard.N0` | Progressivo di transazione della card (conferma di DB 07) | Crescente per card | `ModAddNew.bas:1128`, `Module6.bas:2300` | V |
| `TransCard.FlagOpDaVerificare` | Movimento non ancora verificato | NULL = verificato | `Module6.bas:2256`, `ModAddNew.bas:1397` | V |
| `TransCard.IdCli` | Cliente | `IdContatto`; **`IdLong` se multi-locale** | `Form1.frm:15959` (`IdOrIdlong`) | V |
| `Clienti.IdLong` | Identificativo del cliente nel gruppo | `IdContatto × 10000 + NImp` | `ModAddNew.bas:624` | V |
| `Clienti.IdContatto` | Identificativo locale | max + 1, libero anche in `TransCard.IdCli`; 0 = cliente anonimo; −1 usato come "nessun cliente" | `ModAddNew.bas:697–709`, `Form1.frm:11666` | V |
| `Clienti.T0` | UID RFID della card (16 caratteri esadecimali) | Chiave di ricerca della card in cassa | `Module1.bas:19`, `ECL_command.cls:191` | V |
| `Clienti.TipoCard` | Livello della card | 0 Platinum, 1 Gold, 2 Silver, **3 Compleanno** (a video "VIP"/"B") | `Module1.bas:754–757`, `ClassPromozioni.cls:200`, `Form1.frm:11766` | V |
| `Clienti.N0` | Tipo di ticket del cliente | **0 ticketless, 1 ticket cartacei** | `ModAddNew.bas:1322`, `1286` | V |
| `Clienti.F1`, `T1`, `D1` | Segnalazione di card incoerente o clonata | WinMT: `F1` = 0, `T1` = `IdPost:computer| |saldo card:…prog[…]`, `D1` = data; trigger: `F1` = 1. `AggCliente` azzera i tre campi | `Module6.bas:2360–2366`, `ModAddNew.bas:1323–1325` | V |
| `Clienti.Credito` | Saldo della card in centesimi | `ValoreFinale / 0,01` | `ModAddNew.bas:1135` | V |
| `Clienti.Tickets` | Punti (ticket) residui | Copia di Σ(`NumTickets` − `TPagati`) dei `Tickets` non ausiliari | `Module8.bas:349–366` | V |
| `Clienti.Bonus` | In modalità Golden: punti gold / 100 | Altrove 0 alla creazione | `Module8.bas:347`, `Module6.bas:1863`, `ModAddNew.bas:595` | V |
| `Clienti.Modificato`, `OperMod`, `TimeMod` | Marca di modifica | 1, Id operatore, ora | `ModAddNew.bas:594`, `623`, `1317` | V |
| `Clienti.Abilita` | Card abilitata | 1/0 | `Module6.bas:1783` | V |
| `Clienti.HasTelephoneNumberCorrect`, `EMailIsCertified` | Contatto verificato | Azzerati se il valore cambia | `ModAddNew.bas:1300–1302` | V |
| `Tickets.MangiaT` | Origine e stato dello scontrino (bitmask) | 1 contato da MT Galileo; 2 esterno; 4 manuale (4+2 = 6 convalidato); 8 reso; 16 somma; 32 resto; 64 bonus; 128 sommato; 256 caricato su card; 512 passato ad altra card; 1024 acquisito da altra card; 2048 prenotazione cancellata (con 8) | `Module1.bas:100–112`, `API.bas:317–323` | V |
| `Tickets.TPagati` | Ticket già usati | 0 = disponibile; = `NumTickets` consumato; **negativo = bloccato dalla postazione −IdPost** | `Module1.bas:148`, `Module8.bas:102` | V |
| `Tickets.NonCont` | Scontrino da non contare | Resto, bonus, scontrino totale | `Module1.bas:119–120` | V |
| `Tickets.DataOut`, `OperOut` | Consumo o caricamento manuale su card | Data e operatore | `Module1.bas:152`, `Module6.bas:1892` | V |
| `Tickets.Id` | Postazione | IDPost | `ModAddNew.bas:82` | V |
| `Tickets.NRep` | Reparto | Bit bassi (`And 15`) | `Module6.bas:1739` | V |
| `Tickets.NumTrans` | Numero di serie dello scontrino | Cifra dell'anno × 10⁸ + secondi dell'anno | `Module6.bas:887` | V |
| `Tickets.IdContatto` | Cliente | 0 = scontrino anonimo; in multi-locale contiene `IdLong` | `Module8.bas:43`, `Form1.frm:12200` | V |
| `Tickets.N0` | Sala collegata che ha usato i punti | Id locale | `Module1.bas:156`, `Module6.bas:1732` | V |
| `Tickets.F0` | Con `N0` > 0: 1 = punti ricevuti da altra sala, 0 = pagati in altra sala | | `Module6.bas:1725–1727` | D |
| `Tickets.D0` | Punti "gold" (variante Golden) | NULL = silver | `ModAddNew.bas:87`, `Module6.bas:1923`, `1946` | V |
| `Tickets.T0` | Prefisso raccolta (`PrefRacc|PuntiSerie`) o `MANUAL TICKETS` | | `Form1.frm:6606`, `ModAddNew.bas:1074` | V |
| `Tickets.Aux` | Scontrino di mangiatickets ausiliaria | Escluso dai saldi | `Module6.bas:1726` | V |
| `TicketsCan.DataCan` | Data di annullamento | Sempre NULL in scrittura | `ModAddNew.bas:757` | V |
| `Vincite.Id` | Operatore | `idx` | `Form1.frm:6128` | V |
| `Vincite.Cons`, `D0` | Consegnato, data consegna | Vecchie di un anno → consegnate all'avvio | `ModAddNew.bas:46–48`, `Module1.bas:3711` | V |
| `Vincite.F0` | Sala multi-locale | | `ModAddNew.bas:47` | V |
| `Vincite.N0` | Punti gold usati per il premio | | `ModAddNew.bas:49`, `Form1.frm:6139` | D |
| `Vincite25` | Registro dei premi oltre la soglia fiscale | Legato a `Setup.Ric25` (stampa ricevuta premio > 25 €) e `Pre25` (prezzo da cui parte la registrazione fiscale) | `Module1.bas:313–314`, `ModAddNew.bas:894` | D (risponde a DB 01, domanda 2) |
| `Prenotaz.T0`, `F1` | Numero ordine; sala multi-locale | | `ModAddNew.bas:881–882` | V |
| `Premi.Locked` | Postazione che sta modificando la quantità | 0 libero, altrimenti IDPost | `Module6.bas:1454` | V |
| `Abbuoni.Id` | Operatore | | `Form1.frm:6068` | V |
| `Operatori.Livello` | Ruolo | `And 3`: 0 amministratore, 1 manager, 2 operatore, 3 supervisore | `Form1.frm:11384`, `Module6.bas:189–449` | V |
| `Operatori.T0` | UID della card operatore | | `Form1.frm:11373`, `ModAddNew.bas:317` | V |
| `Operatori.N0` | Abilitazione omaggi e rimborsi | | `Module6.bas:2651` | V |
| `Operatori.Id` = 9999 | Operatore tecnico "Galileo App" | Creato se la sincronizzazione è attiva | `Module1.bas:2725–2727` | V |
| `UID_Ammessi.UID` | UID card fisica | Confronto sui **primi 8 caratteri** | `Module1.bas:3643` | V |
| `CoinlessClonedCards.TipoMovimento`, `CodMac` | Origine della segnalazione | `Lettura`, `WinMt` se da cassa | `Module6.bas:2367` | V |
| `Logs.LFile` | File di log della postazione | Blob | `Module1.bas:3410–3414` | V |
| `Incassi.F0`, `Mdb` | Incasso generato da EcsNet, con il file `.mdb` | F0 = 1 | `Module1.bas:41` | V |
| `RiepInv.F0`, `Mdb`, `D0` | F0 = 1: kit premi inviato da HQ nel blob, `D0` = ora del carico; F0 = 0: inventario reale | | `Module1.bas:43–46`, `Module6.bas:840` | V |
| `MovMag.NBolla` | `CRddmmyyhhmmss` per i carichi remoti | | `Module1.bas:45` | V (commento) |
| `EcsMacchine.T0`, `N0`, `D0` | Valore del piatto o dell'hopper `|` 15 cifre di lunghezza dei contascatti; numero di pezzi sul piatto; data della modifica manuale dei contatori | | `Module1.bas:35–39`, `API.bas:410–430` | V |
| `EcsDati.N0` | RSSI | | `Module1.bas:34` | V (commento) |
| `Setup.IDPost` | Ruolo del record | 101 generale + postazione principale; 102 configurazione aggiuntiva + postazione; 103–109 postazioni; **110 record riservato (super password, licenza)**; ≥ 111 raccolte card | `Module1.bas:2801`, `2669`, `2708`, `1339`; `CreaRaccolte.bas:19` | V |
| `Setup.MName` | Postazione | `nomecomputer|` + carattere = porta del secondo lettore barcode | `Module1.bas:2830`, `3239` | V |
| `Setup(101).AdmPass` | Parametri ECL, separati da `|` | codice cliente ECL, codice impianto, `CentConversionFactor` (default 0,01), nome dell'unità (`EUR` → mostra valuta), `CentsToTokenFactor` (default 1), flag, etichetta monete, etichetta gettoni | `Module1.bas:21–30`, `2735–2754` | V |
| `Setup(101).Passw` | `0|1` abilitazione carico remoto `|` codice della card di setup macchine ECL | | `Module1.bas:3609–3620` | V |
| `Setup(101).T4` | Opzioni del supervisore, 10 flag `|` | | `Module6.bas:384–448` | V |
| `Setup(101).T5`, `T6` | Locali per il trasferimento; locali del gruppo `Nome|0000|…` (`#` = disattivato) | | `Module1.bas:62–63`, `2600–2605` | V |
| `Setup(101).T7`, `Setup(102).T7` | Credenziali del server cloud multi-locale; connessione ai DB cloud di servizio ECL | Codificate con `EncPWord` | `Module1.bas:2619`, `3360–3362` | V |
| `Setup(101).T8` | Rete WiFi ECL `SSID|password` | Codificata | `Module1.bas:2608` | V |
| `Setup(101).T10`, `T11`, `T14+T15` | Scaletta bonus; importi di ricarica POS; variabili di incasso | `|` | `Module1.bas:191`, `2668`, `Module6.bas:2103` | V |
| `Setup(101).N7` | `MSiteMode`: con sala offline non sono ammesse transazioni su card | | `Module1.bas:461`, `2648` | V |
| `Setup(101).N14` | Variante cliente | 0 normale, 1 Astoria, 2 Albarella, 3 Golden | `Module1.bas:168–173`, `2698` | V |
| `Setup(101).F11` | Auto-inserimento UID non ammessi | | `Module1.bas:2634` | V |
| `Setup.F1` (postazioni < 110) | Postazione totem | | `Module1.bas:2715` | V |
| `Setup.MdbSaveInt` | Riusata come moltiplicatore punti `MolPun` | ≥ 1 | `Module1.bas:2541` | V |
| `Setup.IncIva` | Commento: numero messaggi in attesa | In conflitto con "IVA sugli incassi" di `Setup_Descriptions` | `Module1.bas:139`, `2549` | D |
| `Setup(101).D3`; `Setup(102).D0`, `N1` | Ultima email di servizio; scadenza abbonamento; anni di validità tessera | | `Module6.bas:2199`, `2497`; `Module3.bas:230` | V |
| `setup2` | Chiave/valore per postazione | Chiavi viste: `HardwareTicketsPolicy` (JSON), `VipSubscriptionParams` (JSON), `2NdScreenVersion`, `NrColonnePrinter_<n>` | `Module1.bas:1062–1083`, `2768`, `3997` | V |

---

## 4. Regole, calcoli e comportamenti notevoli

### 4.1 Connessioni

| Variabile | Destinazione | Da dove viene |
|-----------|--------------|---------------|
| `CsMtconc1` (= `CsPremi`) | `WinMtSqlDB` sul server di sala, provider SQL Native Client 10/11 | Server da autodiscovery o registro; utente e password dal registro, con un utente predefinito scritto nel codice. `TestSql` la ricostruisce con un nome utente fisso [V `Module1.bas:969–971`, `Module8.bas:211–219`] |
| `CSCloud` | DB cloud dei servizi ECL (`Machines`, `Manuf`, `Type`) | `Setup(102).T7`; se vuota coincide con `CsMtconc1` [V `Module1.bas:3351–3372`, `997`] |
| `CServer` | Server cloud, con query su `db<NImp>.dbo.*` di più sale | `Setup(101).T7` [V `Module1.bas:2619`, `Module8.bas:299–314`] |
| `CoinlessDB` | Prefisso per un DB coinless separato (versioni vecchie) | Presenza della tabella `CoinlessDati` [V `Module1.bas:1230–1254`] |
| `CsKitpremi` | `kitpremi.mdb` locale via ODBC Access | Costante [V `Module1.bas:970`] |

- **Utente.** Il codice non usa `sa`: usa l'utente salvato nel registro, con un default applicativo che coincide verosimilmente con l'utente `WinMt` db_owner di DB 01 [D]. Il problema di sicurezza resta: un unico utente con pieni poteri, credenziale recuperabile dal registro di ogni postazione.
- **Nome del database fisso.** `WinMtSqlDB` è scritto in 34 punti di 12 file, compresi `BACKUP DATABASE` e query a tre parti [V]. Conferma DB 07, § 7, anche dal lato client.
- **Database cloud per sala.** In HQ ogni sala ha un database `db` + `NImp` a 4 cifre (es. `db0196`) [V `Module8.bas:301`]. Risponde a DB 01, domanda 5: un DB per sala, non un DB unico con `NImp`.
- **Nessuna transazione** tranne `AddCliente`. Le operazioni composte (movimento `TransCard` + `Clienti.Credito`, consumo ticket + saldo cliente) possono restare a metà.
- **Schema modificato dal client.** All'avvio WinMT crea tabelle e procedure se lo schema è "vecchio" [V `Module1.bas:1005–1044`]. È una delle vie per cui le sale divergono (DB 07).

### 4.2 Stato globale dell'applicazione

| Stato | Variabile | Valorizzata da |
|-------|-----------|----------------|
| Operatore corrente | `idx` (Id), `LvLx` (livello 0–3), `OperNome`, `OperCogn`, `OpLog`, `OperatoreInCanna` (`ECL_operatore`), `OraInTurno` | `Form1` alla lettura della card operatore o al login [V `Form1.frm:11382–11386`]; `SetOp` [V `Module6.bas:183–186`] |
| Postazione | `valsets.IdPost` (default 101), `valsets.Master` | `CaricaPost`, per nome del computer in `Setup.MName` [V `Module1.bas:2839`] |
| Impianto | `valsets.Nimp` | `Setup(101).NImp` [V `Module1.bas:2424`], vincolato alla licenza |
| Configurazione | `valsets` (≈ 190 campi), `Reparti`, `VipSet`, `TRate`, `ScaVal`, `ImPOS` e decine di globali | `CaricaGen`, `CaricaPost` |
| Gruppo multi-locale | `NetSites` | `Setup(101).T6` [V `Module1.bas:2601`] |
| Parametri ECL | `CentConversionFactor`, `CentsToTokenFactor`, `NomeMCM`, `CodClienteECL`, `CodImpianto` | `Setup(101).AdmPass` |
| Card in canna | Non globale: `Form1.form1CardInCanna`, `clienteincanna` (privati di `Form1`), `ClsEclReaderWriter.cardInCanna`; cliente corrente nel recordset `Form1.Giocatori` e nella casella `Form1.idcontatto` | `Form1.frm:5292`, `5299` [V] |
| Stato antifrode | `LastClonedCard(0..3)`: UID, letture consecutive, motivo, azione (`rallinea`) | `VerificaCard`, `MettiInBlackList` |
| Licenza e modalità | `SqlDB`, `MultiUsers`, `SScreen`, `EasyMode`, `PrizeHubKey`, `TotemSqlKey`, `Astoria`, `Alba`, `Golden` | `KeyLocate`, `Setup(101).N14` |
| Infrastruttura | `AppMode` (`ECL`/`REALTIME`), `VersionEcl2Mqtt`, `EclDatabase.dbversion`, `isMqttEnabled`, `mqttform` | Autodiscovery, introspezione, MQTT |

**Multi-locale.** Quando `NetSites` è valorizzato, l'identificativo del cliente nelle tabelle figlie (`Tickets.IdContatto`, `TransCard.IdCli`, `Prenotaz.IdCli`, ecc.) diventa `IdLong` invece di `IdContatto`. La scelta è fatta in oltre 20 file con `IdOrIdlong` e `stIdFieldFromClienti` [V `ModuleMultilocale.bas:2–17`]. Lo stesso campo ha quindi due significati a seconda della configurazione della sala.

### 4.3 Saldi e autorità

- Il **saldo valore** della card ha come riferimento l'ultimo `TransCard.ValoreFinale` verificato, ordinato per progressivo card; crediti e bonus si ricostruiscono per tipo di movimento (W02-07).
- Il **saldo punti** del cliente è `Clienti.Tickets`, copia del residuo dei `Tickets`; il consumo è FIFO sulle righe (W02-14) e il ricalcolo è una funzione di manutenzione (W02-16).
- La card è considerata attendibile se il suo progressivo è ≥ a quello del DB e il saldo non supera quello del DB (W02-08). È la regola di riconciliazione offline da preservare o ridefinire.

### 4.4 Identificativi generati

- `IdContatto` = max + 1 con controllo su `TransCard`; `IdLong` = `IdContatto × 10000 + NImp` (al massimo 9999 sale prima di collisioni).
- Numero di serie dello scontrino derivato dall'orologio, al secondo.
- Barcode dello scontrino: reparto + serie + ticket + modulo 10.

### 4.5 Comportamenti da decidere

- Vincite non ritirate da un anno chiuse automaticamente all'avvio di qualunque postazione.
- Blacklist dopo tre letture incoerenti consecutive della stessa card; la blacklist è inviata alle schede via HTTP al servizio ECL.
- Quantità dei premi sovrascritta, non movimentata (`UpdateQty`), con blocco per postazione.
- Controllo dell'orologio di sistema all'avvio.
- Permessi solo di interfaccia.

### 4.6 Cifratura e offuscamento

| Meccanismo | Dove | Uso | Valutazione |
|------------|------|-----|-------------|
| `EncPWord`/`DecPWord` (prefisso `MTCry`) | `Module6.bas:736–788` | Credenziali nel registro, `Setup.T7`, `T8`, super password, password SMTP e altre costanti | **Codifica reversibile senza chiave**: ogni carattere diventa la sua posizione in una tabella fissa. Equivale a testo in chiaro |
| `EnCodeStr` | `Module8.bas:227` | Offusca le richieste HTTP verso i servizi cloud (messaggi, push, email, verifica email) | Scorrimento con chiave casuale inclusa nel messaggio: offuscamento, non cifratura |
| `CreaUser`/`CreaPassW` | `Module1.bas:1277–1309` | Credenziali ricavate da posizioni di frasi fisse | Credenziale scritta nel codice |
| `EncDec.Encrypt`/`Decrypt` | `EncDec.bas` | Nessun chiamante | Codice morto |
| `mdAesEcb` (AES-256 CNG, PBKDF2, HMAC) | `mdAesEcb.bas` | Nessun chiamante; sale fisso nel codice | Codice morto, l'unico algoritmo robusto del progetto |
| Chiave HASP | `KeyLocate` | Licenza | Vendor code nella classe `haspapidemo.cls` (fuori zona) |

---

## 5. Problemi rilevanti per il nuovo disegno

1. **`NImp` non ha un significato unico.** Nelle altre tabelle è il numero impianto; in `TransCard` è il tipo di operazione e l'impianto è in `T0`. Ogni mappatura di migrazione su `NImp` deve distinguere i due casi.
2. **Identità del cliente dipendente dalla configurazione.** Le colonne cliente delle tabelle figlie contengono `IdContatto` o `IdLong` secondo `NetSites`. Una sala passata da singola a multi-locale ha dati misti [D]. Il nuovo modello deve avere un solo identificativo globale.
3. **Saldi duplicati e scritture non atomiche.** `Clienti.Credito`, `Clienti.Tickets`, `Clienti.Bonus` sono copie aggiornate in molti punti senza transazione; esistono funzioni di "ricalcolo" proprio per questo.
4. **Connessione diretta al DB da ogni postazione**, con credenziali db_owner facilmente recuperabili, schema modificato dal client e nome del DB fisso. Va sostituita da API lato server.
5. **Nessun funzionamento senza server SQL.** La postazione non parte se il server non risponde; l'unico ripiego è il server secondario.
6. **Stato in variabili globali e controlli dell'interfaccia** (`Form1.Giocatori`, `idx`): la logica non è separabile dall'interfaccia, va riscritta.
7. **Antifrode da rivedere**: soglia che non ha effetto, formato dell'UID diverso tra WinMT e trigger, `CentConversionFactor` forzato.
8. **Dati fuori dal modello relazionale**: file `.mdb` in blob, configurazione in stringhe con separatori, JSON in `setup2`, file locali.

---

## 6. Domande aperte per il team

1. `TransCard.NImp` è usato come tipo di operazione anche dal servizio di sala e dai totem? I report che filtrano `NImp` su `TransCard` lo sanno?
2. Le sale multi-locale hanno dati misti `IdContatto`/`IdLong` nelle tabelle figlie (per esempio sale entrate in un gruppo dopo l'avvio)?
3. `MettiInBlackList` scrive `Clienti.F1` = 0 e inserisce in `CoinlessClonedCards` l'UID a 16 caratteri: il trigger `bannaUtente` trova il cliente e la card coinless? Si spiega così la differenza tra i 1.227 clienti con `F1` = 1 e i 56 con il testo di clonazione?
4. Il record `Setup` con IDPost 110 è solo il record della licenza o anche l'host della sincronizzazione (DB 06, domanda 2)?
5. Le vincite non consegnate dopo un anno vanno davvero chiuse in automatico? Il flag che lo governa (`AbPr`) è quello giusto?
6. Il servizio messaggi e push su HTTP non cifrato è ancora in uso?
7. L'utente SQL predefinito del codice è lo stesso in tutte le sale?
8. `Setup.IncIva`: numero di messaggi in attesa (commento nel codice) o IVA sugli incassi (`Setup_Descriptions`)?
9. `Operatori.Livello` usa bit oltre i primi due (il codice fa `And 3` in un punto e no negli altri)?
10. Le varianti cliente (Astoria, Albarella, Golden) sono ancora installate? Determinano se `Tickets.D0` e `Clienti.Bonus` vanno migrati come "punti gold".
