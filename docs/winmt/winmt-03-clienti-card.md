# Galileo HQ — WinMT 03: Clienti, card, livelli, compleanni e promozioni

**Stato:** bozza · **Responsabile:** Piero · **Aggiornato:** 2026-10-23

**Fonte:** sorgente VB6 di WinMT (copia del 24/07/2026), file: `FrmGenCard.frm`, `frmModCli.frm`, `FrmNewCliApp.frm`, `frmNewCliAppCli.frm`, `FormCCardAnonima.frm`, `frmCreaCards.frm`, `FrmCreaCardsBatch.frm`, `FrmRecoverCard.frm`, `FrmRecoverCardBatch.frm`, `FrmUCard.frm`, `FrmUnioneCard.frm`, `frmCardFamily.frm`, `frmAstoria.frm`, `frmPassAstoria.frm`, `frmCompleanni.frm`, `clsCompleanno.cls`, `FrmPromozioni.frm`, `ClassPromozioni.cls`, `FrmSil2Gld.frm`, `frmSil2Gold.frm`, `frmGold2Sil.frm`, `frmsetVip.frm`, `FrmDeCli.frm`, `FrmDeCliML.frm`, `FrmClaCli.frm`, `frmBlList.frm`, `frmBlackMsg.frm`, `FrmFigli.frm`, `frmFindCli.frm`, `Remote/frmAlertClienti.frm`, `cliente.frm`, `clienteV2.frm`, `cls_cliente.cls`; seguiti per quanto serve `ModAddNew.bas`, `Module1.bas`, `Module3.bas`, `Module6.bas`, `Module8.bas`, `ModuleMultilocale.bas`, `ECL_cliente.cls`, `ECL_command.cls`, `ECL_database.cls`, `ClassEventi.cls`, `Form1.frm` (solo i punti di ingresso) e le procedure SQL `GetFreeUidCodbar`, `FinalizeUidCodbar`, `sp_ripristinacard`, `sp_eliminacliente`, `sp_rimuovidabl`, `bannaUtente`, `fn_idcliente`, `fn_decode_mt_bitmask` · **Collegati:** `winmt-00-mappa.md`, `winmt-01-cassa-form1.md`, `winmt-02-moduli-comuni.md`, `docs/db/db-02-catalogo.md`, `docs/db/db-06-produzione-02.md`, `docs/db/db-07-confronto-test-produzione.md`

Legenda: **[V]** verificato nel codice, con riferimento `file:riga`; **[D]** dedotto, da confermare. Le righe citate sono quelle del file sorgente, designer compreso.

---

## 1. Perimetro

| File | Righe di codice | Ruolo | Lettura |
|------|----------------:|-------|---------|
| `frmAstoria.frm` | 3.210 | Cassa semplificata per la variante "Astoria": ricarica card in tempo reale sul DB, rimborso, POS (Nayax, Ingenico, PAX via seriale o TCP), creazione clienti QR | a fondo i flussi dati; scorso il protocollo POS e la vecchia `TagROld_OnComm` |
| `FrmDeCli.frm` | 2.970 | Scheda di dettaglio del cliente: punti Silver/Gold, premi ritirati, crediti acquistati e spesi; stampa ed export | a fondo `AggDati`, `CalTot`; scorse stampa ed export |
| `FrmDeCliML.frm` | 2.825 | Variante **multi-locale** della stessa scheda (confronto al § 2, W03-28) | per differenze |
| `frmCardFamily.frm` | 1.941 | **Family card**: un pagamento distribuito su più card | a fondo distribuzione e scrittura; scorso il POS |
| `frmCompleanni.frm` | 1.661 | Gestione delle feste di compleanno: evento, ospiti, card ospite, ricariche, redeem code, parametri | a fondo |
| `FrmGenCard.frm` | 1.329 | Creazione del cliente con card e **riscrittura** (sostituzione) della card | a fondo |
| `frmModCli.frm` | 980 | Modifica anagrafica, consensi, ticketless, master, scadenza, alert, verifica app | a fondo |
| `clsCompleanno.cls` | 816 | Classe dati dell'evento compleanno e degli ospiti; crea le tabelle se mancano | a fondo |
| `FrmClaCli.frm` | 699 | Classifica clienti (presenze), filtri, export Excel/CSV, riallineamento `Credito` | a fondo le query |
| `FrmNewCliApp.frm` | 681 | Registrazione al banco di un cliente pre-registrato da App | a fondo |
| `FrmRecoverCard.frm` | 622 | Recupero di una card per riuso, eliminazione cliente, sblocco blacklist | a fondo |
| `FrmCreaCardsBatch.frm` | 513 | Generazione di card in lotto sul micrototem ("giallone") | a fondo |
| `FrmPromozioni.frm` | 454 | Anagrafica delle promozioni Gold | a fondo |
| `frmCreaCards.frm` | 381 | Creazione di card anonime in serie al lettore, con ricarica opzionale | a fondo |
| `frmsetVip.frm` | 364 | Opzioni "clienti VIP" (con card): ticket omaggio, bonus a fasce orarie, interesse | scorsa |
| `FrmUCard.frm` | 352 | Unione card / somma punti a card master (punti cartacei) | a fondo |
| `clienteV2.frm`, `cliente.frm` | 324, 314 | Display cliente sul secondo monitor (due versioni quasi identiche) | per differenze |
| `FormCCardAnonima.frm` | 310 | Creazione di una card anonima al lettore | a fondo |
| `ClassPromozioni.cls` | 292 | Motore promozioni: forzatura Gold, memoria del livello precedente, ripristino | a fondo |
| `FrmRecoverCardBatch.frm` | 162 | Cancellazione card in lotto sul micrototem | a fondo |
| `FrmUnioneCard.frm` | 155 | Unione card ECL: **non implementata** (procedura vuota) | a fondo |
| `frmBlList.frm` | 140 | Elenco clienti e card in blacklist | a fondo |
| `FrmFigli.frm` | 117 | Minori associati al cliente (tabella `Figli`) | a fondo |
| `FrmSil2Gld.frm` | 110 | Conversione massiva dei punti Silver in Gold | a fondo |
| `frmGold2Sil.frm`, `frmSil2Gold.frm` | 101, 99 | Conversione punti Gold↔Silver del singolo cliente (simmetriche) | a fondo |
| `Remote/frmAlertClienti.frm` | 26 | Visualizza ed elimina l'alert su un cliente | a fondo |
| `frmFindCli.frm` | 24 | Ricerca cliente per nome | a fondo |
| `frmBlackMsg.frm` | 15 | Popup "card in blacklist" | a fondo |
| `frmPassAstoria.frm` | 14 | Richiesta di due password per `FrmEcs` (chiamata commentata) | a fondo |
| `cls_cliente.cls` | 10 | Classe vuota (solo `Private lPrivacy1`) | a fondo |
| `frmNewCliAppCli.frm` | 8 | Copia della form di registrazione mostrata al cliente sul secondo monitor | a fondo |

---

## 2. Flussi

### Premessa: identità del cliente e della card

Il modello che emerge dal codice è il seguente [V salvo dove indicato]:

- **`IdContatto`** è il numero progressivo del cliente **nella sala**. `AddCliente` lo calcola in transazione `SERIALIZABLE` come `MAX(IdContatto)+1`, saltando i valori già presenti come `TransCard.IdCli`, e ritenta fino a tre volte sulle violazioni di chiave [V `ModAddNew.bas:568-583`, `697-708`]. Il valore proposto dalle form (`Nidc`, calcolato anche con filtro `idlong % 10000 = NImp`) viene **ignorato** [V `ModAddNew.bas:580`, `FrmGenCard.frm:2643-2647`].
- **`IdLong` = `IdContatto × 10000 + NImp`**, dove `NImp` è il codice impianto della sala [V `ModAddNew.bas:624`]. Serve a rendere il cliente univoco nel gruppo multi-locale.
- **Quale dei due va nelle tabelle figlie dipende dalla configurazione**: in sala singola `TransCard.IdCli`, `Tickets.IdContatto`, `Vincite`, `Prenotaz`, `Resi` contengono `IdContatto`; in multi-locale contengono `IdLong` [V `ModuleMultilocale.bas:2-20`; `fn_idcliente`]. La sala è multi-locale quando `Setup(101).T6` contiene l'elenco dei locali (`nome|NImp|nome|NImp…`) e non contiene `#` [V `Module1.bas:2600-2605`]. **Risponde alla domanda di DB 01 su `IdContatto`/`IdLong`**: nelle sale analizzate, in sala singola, gli orfani verso `IdLong` sono il 100% perché i figli usano `IdContatto`.
- **`IdLong2` = 1** marca il cliente registrato da App [V `FrmNewCliApp.frm:1363`; `FrmClaCli.frm:1498` lo mostra come "App"/"Store"]. Non è un secondo identificativo.
- **`IdMaster1`, `IdMaster2`** contengono l'`IdLong` di al massimo due clienti *master* di una card *secondaria* (slave, "Children's Card" nell'interfaccia inglese) [V `FrmGenCard.frm:1840-1864`, `frmModCli.frm:1336-1345`].
- **`T0`** è l'UID della card RFID (16 caratteri) o, per i clienti "QR", il codice QR stesso [V `frmAstoria.frm:2928-2930`]. Il cliente si cerca sempre con `T0`.
- **`CodBar`** è il barcode stampato sulla card. Se non è fornito, `AddCliente` lo prende da `UID_Ammessi` confrontando i **primi 8 caratteri** dell'UID [V `ModAddNew.bas:712-743`].
- **`UserName`** non è scritto da nessun file della zona; `ClientiAPP.Username` viene letto ma non copiato [V `FrmNewCliApp.frm:1406-1408`, ricerca su tutto il sorgente].

### W03-01 Creazione del cliente con card (al banco)

- **Attore e innesco:** operatore, pulsante "Genera Card" di `Form1` (`Command4Cli_Click`, `status = 3`) [V `Form1.frm:8868-8872`] → `FrmGenCard`.
- **Passi:**
  1. La form propone la data d'iscrizione, il livello (preselezione `TC = 1`, Platinum) [V `FrmGenCard.frm:2312`] e il flag ticketless secondo `Setup(101).F9/F10`.
  2. Controlli sui campi obbligatori secondo `valsets.NCogn` (nome e cognome), `CIndir` (indirizzo), `CBarC` (barcode), `TagRD` (RFID obbligatorio) [V `VerCond`, `FrmGenCard.frm:2841-2971`].
  3. Sull'UID letto: rifiuto se già assegnato ad altro cliente (`T0` uguale e `IdLong` diverso) [V `2975-3065`]; avviso se nome e cognome esistono già [V `2980-3004`].
  4. Email univoca: per i barcode `JV…` (card LED) il controllo è fatto **su tutti i locali del gruppo** con la vista `vs_clienti_led` del database `winmtAPI`, altrimenti sulla sala [V `1924-1935`, `3076-3115`].
  5. Se c'è il lettore ECL, la card viene inizializzata con `InitCard(codice cliente ECL, codice impianto, livello)` [V `1952-1960`].
  6. `AddCliente` inserisce il cliente (vedi § 3) [V `1964`, `ModAddNew.bas:543-660`]; poi si scrivono `N0` e il flag ticketless sulla card [V `1976-1991`].
  7. Ticket omaggio di benvenuto `valsets.FTNew`: riga `Tickets` con `MangiaT = 64` (bonus) e aggiornamento di `DataUltVis` [V `1992-2000`].
- **Dati:** legge `Clienti`, `UID_Ammessi`, `vs_clienti_led` (altro DB); scrive `Clienti` (insert), `Tickets` (insert).
- **Regole:** il livello passa da `ClassPromozioni.ImpostaLivello`: con promozione attiva diventa Gold [V `ModAddNew.bas:626-627`]. Se la promozione è attiva, le opzioni Silver e Platinum sono bloccate su Gold [V `FrmGenCard.frm:2760-2770`]. Il campo `Password` generato (`RndStr(8)`) non viene passato ad `AddCliente` [V `1937`, `1964`].
- **Periferiche:** lettore RFID ECL (seriale, JSON), lettore/scrittore di banda magnetica (`CardRd`) nelle installazioni vecchie.
- **Peso: L** — molte varianti di configurazione, periferica, controlli cross-sala, regole di livello.
- **Evidenze:** `FrmGenCard.frm:1886-2006`, `2295-2690`; `ModAddNew.bas:543-660`.

### W03-02 Riscrittura (sostituzione) della card di un cliente

- **Attore e innesco:** operatore, pulsante di riscrittura in `Form1` (`status = 2`); se il cliente è in blacklist solo i livelli 0–1 (amministratore, manager) possono procedere; avviso se ci sono macchine offline [V `Form1.frm:8738-8780`].
- **Passi:**
  1. Ricarica il cliente; se il nuovo barcode è `JV…` e il vecchio no (prima card LED), **azzera l'anagrafica** del cliente [V `FrmGenCard.frm:2030-2046`].
  2. In ECL ricostruisce il saldo dalla storia: ultimo `TransCard.ValoreFinale` (escluse le operazioni da verificare) e somme di crediti e bonus per tipo di operazione [V `2062-2067`, `ModAddNew.bas:1359-1400`, `1522-1570`].
  3. Aggiorna anagrafica, `CodBar`, `T0` (nuovo UID), `TipoCard`, `N0`; azzera `T1`, `F1`, `D1` (stato blacklist) [V `2068-2094`, `ModAddNew.bas:1278-1334`].
  4. Toglie la nuova card dalla blacklist (cancella `CoinlessClonedCards`, `CoinlessCards`, i log) e marca come "rinominate" le transazioni coinless (`cardid + '__'`); mette in blacklist la **vecchia** card (`CoinlessCards.BlackList = 1` + log "card sostituita"); avvisa il server ECL via HTTP (`jrefreshBlacklist`) [V `2156-2159`, `3117-3159`].
  5. Riscrive la card: inizializzazione col livello, punti, crediti e bonus ricostruiti, progressivo = ultimo `TransCard.N0` **+ 50** [V `2179-2228`].
  6. Inserisce in `TransCard` un movimento di riscrittura (`NImp = 20`) col saldo e aggiorna `Clienti.Credito` [V `2230-2238`, `ModAddNew.bas:1641-1655`].
- **Dati:** legge `TransCard`, `Clienti`; scrive `Clienti`, `TransCard`, `CoinlessCards`, `CoinlessClonedCards`, `CoinlessLogEventiBlacklist`, `CoinlessTransazioniCards`.
- **Regole:** il cliente **conserva `IdContatto` e tutta la storia**; cambia solo il supporto. In multi-locale il ricalcolo dei punti passa da `FrmRicalc` su tutti i locali [V `2169-2178`]. La data di iscrizione è riscritta con +1 secondo "per non falsarla" [V `2602`].
- **Periferiche:** lettore ECL; chiamata HTTP al server ECL di sala (porta 58889).
- **Peso: L** — transazione distribuita tra DB, card e server ECL senza atomicità; ricostruzione del saldo.
- **Evidenze:** `FrmGenCard.frm:2008-2253`, `3117-3159`.

### W03-03 Modifica dell'anagrafica del cliente

- **Attore e innesco:** operatore, `Form1` → `FrmModCli` [V `Form1.frm:7662`].
- **Passi:**
  1. Carica il cliente (per `IdContatto` o `IdLong`) e gli attributi estesi dal campo `Foto` (JSON) [V `frmModCli.frm:1949-1960`].
  2. L'operatore modifica anagrafica, documento, consenso (`OptOut`), password, note, card master (anche leggendo il barcode di un'altra card `CD…`/`JV…`) [V `1295-1360`].
  3. Se è attiva la privacy 2018 (`valsets.AbPrv`), gestisce "Rinnovata" (`F0`) e la scadenza (`D0` = oggi + `Setup(102).N1` anni) [V `1373-1379`, `1578-1583`, `1604-1608`, `Module3.bas:237-250`].
  4. Il cambio ticketless richiede la card sul lettore: invia `SetTicketLess` e, se la card conferma, scrive `N0` [V `1635-1665`].
  5. Se cambiano email o cellulare, azzera `EMailIsCertified` [V `1595-1598`].
  6. Salva i consensi (profilazione, marketing, analytics) nel JSON di `Foto` [V `1957-1960`, `ECL_cliente.cls:1181-1200`].
- **Dati:** legge e scrive `Clienti`; scrive `Scocard` (W03-05).
- **Regole:** `Abilita` è rimesso a 1 al salvataggio [V `1634`]. Pulsante di stampa del barcode del cliente sulla stampante scontrini [V `1393-1418`].
- **Periferiche:** lettore barcode seriale, lettore ECL, stampante.
- **Peso: M** — molte colonne, regole sui consensi, ticketless con conferma da card.
- **Evidenze:** `frmModCli.frm:1514-1725`, `1739-2195`.

### W03-04 Verifica della registrazione all'App

- **Attore e innesco:** operatore, pulsante "Email Register" in `FrmModCli`, visibile se `FirstLogin` è falso e c'è un'email [V `frmModCli.frm:2061-2065`].
- **Passi:** compone una stringa cifrata `verifica|email|IdContatto|NImp`, chiama un servizio web del cloud Elmac e interpreta la risposta XML: stato 0 = App non installata, 1 = registrazione completata, 2 = da completare; `pk_device` = identificativo del telefono [V `1420-1512`].
- **Dati:** scrive `Clienti.FirstLogin`, `Clienti.IdTel`.
- **Periferiche:** rete (HTTP verso cloud); senza rete l'operazione fallisce in silenzio [V `1508-1511`].
- **Peso: S** — una chiamata e due colonne.
- **Evidenze:** `frmModCli.frm:1420-1512`.

### W03-05 Alert sul cliente

- **Attore e innesco:** operatore in `FrmModCli` (campo alert, visibile solo per un elenco di database scritto nel codice) [V `frmModCli.frm:2184-2187`]; alla presa in carico del cliente `Form1` mostra `frmAlertClienti` [V `Form1.frm:17540-17552`].
- **Passi:** salva il testo in `Scocard` (`IdContatto` = `IdLong` come testo, `T0` = testo, `F0 = 1`); in multi-locale lo replica **in ogni database dei locali collegati** [V `frmModCli.frm:2333-2396`]. Da `frmAlertClienti` i livelli 0–1 possono eliminarlo (`T0 = ''`, `F0 = 0`) [V `Remote/frmAlertClienti.frm:154-175`].
- **Dati:** `Scocard` (riuso di una tabella nata per altro).
- **Peso: S**.
- **Evidenze:** `frmModCli.frm:2310-2396`; `Remote/frmAlertClienti.frm:154-171`.

### W03-06 Registrazione al banco di un cliente pre-registrato da App

- **Attore e innesco:** operatore che legge con lo scanner un codice di 8 caratteri che inizia con `JOY` o `NAM` [V `Form1.frm:6880-6886`] → `FrmNewCliApp`; il cliente vede gli stessi dati sul secondo monitor (`frmNewCliAppCli`) [V `FrmNewCliApp.frm:1453`].
- **Passi:**
  1. Legge i dati da `ClientiAPP` nel database `winmtAPI` (anagrafica, documento, password, sesso, flag di certificazione) [V `1390-1448`]; il PDF del documento si può aprire [V `1312-1332`].
  2. L'operatore completa con la card; `AddCliente` crea il cliente con **livello 0 (Platinum, salvo promozione)** e ticketless [V `1352`].
  3. Imposta `IdLong2 = 1` e accredita i ticket omaggio `FTNew` [V `1355-1371`].
  4. **Cancella** il record da `ClientiAPP` [V `1872-1887`].
- **Dati:** legge e cancella `winmtAPI.ClientiAPP`; scrive `Clienti`, `Tickets`.
- **Regole:** la password dell'App viene copiata in chiaro in `Clienti.Password` [V `1430`, `1352`].
- **Periferiche:** scanner, lettore ECL, secondo monitor. Richiede il DB `winmtAPI` raggiungibile [D: è sul server indicato in `CServer`, verosimilmente cloud].
- **Peso: M** — due database, consumo del codice di registrazione.
- **Evidenze:** `FrmNewCliApp.frm:1334-1448`, `1872-1887`.

### W03-07 Creazione di una card anonima

- **Attore e innesco:** operatore, `Form1` → `FormCCardAnonima` [V `Form1.frm:6842`].
- **Passi:** attende una card vergine o non assegnata e **ammessa** (`UID_Ammessi`), non di un cliente né di un operatore; la inizializza come Silver (Gold se promozione), imposta ticketless secondo `Setup(101).F10`, la rilegge e crea un cliente senza dati anagrafici [V `FormCCardAnonima.frm:325-493`].
- **Dati:** legge `UID_Ammessi`, `Clienti`, `Operatori`; scrive `Clienti`.
- **Periferiche:** lettore ECL.
- **Peso: M** — macchina a stati con la periferica.
- **Evidenze:** `FormCCardAnonima.frm:446-493`.

### W03-08 Creazione di card in serie al lettore, con ricarica

- **Attore e innesco:** operatore, `Form1` → `frmCreaCards` [V `Form1.frm:9690`].
- **Passi:** per ogni card appoggiata: verifica `UID_Ammessi` e che non sia già assegnata; `InitCard` col livello scelto, `SetTicketLess`, `AddCliente` anonimo; se è scelta una ricarica, scrive crediti e bonus sulla card, poi `TransCard` (`NImp = 6` per il bonus con progressivo 1, `NImp = 0` per i crediti con progressivo 2) e ticket bonus da scaletta (`MangiaT = 64`) [V `frmCreaCards.frm:973-1069`].
- **Regole:** importi proposti come multipli di un moltiplicatore; bonus calcolati da `BonusHandler` [V `692-735`]. Promozione: selezionabile una promozione futura, che forza Gold [V `741-749`].
- **Dati:** legge `UID_Ammessi`, `Clienti`, `Operatori`, `promozioni`; scrive `Clienti`, `TransCard`, `Tickets`, `promozioni_cards`.
- **Periferiche:** lettore ECL.
- **Peso: M**.
- **Evidenze:** `frmCreaCards.frm:887-1069`.

### W03-09 Generazione di card in lotto sul micrototem ("giallone")

- **Attore e innesco:** operatore, `Form1` → `FrmCreaCardsBatch` [V `Form1.frm:9710`]; la stessa funzione è usata da `Form1` per creare un singolo giocatore Silver [V `Form1.frm:7927`].
- **Passi:** elenca i micrototem configurati in `setup2` (`IdPost = 0`, JSON con `MICROTOTEM`) [V `FrmCreaCardsBatch.frm:947-987`]; l'operatore sceglie quantità, livello, ricarica, ticketless e promozione; la richiesta parte via socket TCP al dispositivo con un UUID di transazione, e la form mostra l'avanzamento card per card [V `1212-1298`, `1419-1453`].
- **Dati:** WinMT legge `setup2`, `promozioni`; **non scrive i clienti**: lo fa il micrototem o il suo server [D].
- **Periferiche:** micrototem (classe `cls_GiallOne`, Winsock) [V `cls_GiallOne.cls:17`].
- **Peso: M** — integrazione con un dispositivo esterno.
- **Evidenze:** `FrmCreaCardsBatch.frm:1015-1106`, `1212-1298`.

### W03-10 Cancellazione di card in lotto sul micrototem

- **Attore e innesco:** operatore → `FrmRecoverCardBatch` [V `Form1.frm:9984`].
- **Passi:** stessa connessione di W03-09, comando `RequestCardsDeletion` [V `FrmRecoverCardBatch.frm:303-324`].
- **Dati:** nessuna scrittura da WinMT.
- **Peso: S**.
- **Evidenze:** `FrmRecoverCardBatch.frm:303-324`.

### W03-11 Recupero di una card per riuso, eliminazione del cliente, sblocco blacklist

- **Attore e innesco:** operatore → `FrmRecoverCard` [V `Form1.frm:10056`]. Tre modalità: standard; "elimina utente", abilitata con un codice di autorizzazione derivato da `Setup(101)` (hash MD5 di nome postazione e impianto) [V `FrmRecoverCard.frm:902-936`]; "solo blacklist", abilitata con un codice fisso scritto nel codice [V `238`].
- **Passi (card appoggiata e ammessa):**
  - *Card operatore:* su conferma, cancella i dati coinless e scollega il tag dall'operatore (`Operatori.T0 = NULL`, `CodBar = ''`), poi formatta la card [V `410-415`, `761-772`].
  - *Standard:* toglie la card dalla blacklist (`CoinlessClonedCards`; `Clienti.T1/D1 = NULL`, `F1 = 1`), stacca la card dagli ospiti di compleanno, esegue `sp_ripristinacard` e formatta la card [V `428-433`, `698-759`].
  - *Elimina utente:* come sopra ma con `sp_eliminacliente` [V `434-438`, `835-850`].
  - *Solo blacklist:* `sp_rimuovidabl` [V `439-441`, `681-697`].
  - Verifica che non restino tracce (clonazioni o clienti con quel `T0`) e notifica il server ECL [V `464-470`, `803-834`, `953-965`].
- **Cosa succede ai dati:**
  - `sp_ripristinacard`: cancella tutti i dati coinless della card, il legame promozionale, e **scollega la card dal cliente** (`Clienti.T0 = NULL`, `CodBar = NULL`) e da operatori e compleanni; **il cliente e la sua storia restano** [V `sql/.../sp_ripristinacard.sql`].
  - `sp_eliminacliente`: per ogni cliente con quel `T0` cancella **tutta la storia** (`TransCard`, `Prenotaz`, `Resi`, `Vincite`, `Figli`, `Tickets`) e poi il cliente [V `sql/.../sp_eliminacliente.sql`].
  - Nessuna delle due modifica `UID_Ammessi.DataEmissione` [V].
- **Periferiche:** lettore ECL; HTTP verso il server ECL.
- **Peso: L** — cancellazioni distruttive su molte tabelle, tre modalità, autorizzazione.
- **Evidenze:** `FrmRecoverCard.frm:379-501`, `681-965`.

### W03-12 Unione di card e somma dei punti alla card master (punti cartacei)

- **Attore e innesco:** operatore. Due ingressi: "Unisci Card" (si leggono le card origine) e "Somma Punti a Card Master" (le origini sono le card slave con `IdMaster1/2` = `IdLong` del cliente) [V `Form1.frm:6933-6996`, `8007`].
- **Passi:**
  1. Blocca origine e destinazione (`Abilita = 0`) [V `Form1.frm:6950`].
  2. Per ogni origine scarica i ticket residui dalle righe `Tickets` più vecchie: `TPagati` = `NumTickets`, `MangiaT |= 512` (passato ad altra card), `OperOut`, `DataOut` [V `FrmUCard.frm:776-822`].
  3. Accredita la somma alla destinazione con una riga `Tickets` (`MangiaT = 1024`, acquisito da altra card) [V `833-834`].
  4. Facoltativo: **cancella** i clienti origine; altrimenti aggiorna `Clienti.Tickets` di origini e destinazione [V `836-884`].
  5. Rilascia i lock [V `1022-1041`].
- **Regole:** la quantità da scaricare per card è modificabile [V `901-905`]. In multi-locale la stringa `exec sp_unione_card` è costruita ma **mai eseguita**, e la procedura non esiste nei DB analizzati [V `826-830`].
- **Dati:** `Tickets` (update, insert), `Clienti` (update, delete).
- **Peso: M**.
- **Evidenze:** `FrmUCard.frm:709-895`.

### W03-13 Unione di card ECL (crediti)

- `FrmUnioneCard` ha l'interfaccia a passi ma `analizzaMessaggio` è **vuota**: la funzione non è implementata [V `FrmUnioneCard.frm:283-286`]. Il trasferimento crediti tra card esiste come tipi di movimento `TransCard.NImp` 10, 11, 16 (vedi § 3) in altre zone. **Peso: S**.

### W03-14 Conversione massiva dei punti Silver in Gold

- **Attore e innesco:** operatore → `FrmSil2Gld` [V `Form1.frm:10113`]; disponibile nella variante "Golden".
- **Passi:** per **tutti** i clienti, crea per ogni riga `Tickets` Silver (`D0 IS NULL`, residuo > 0) una riga Gold con residuo × percentuale, `MangiaT = 16384`, `D0 = getdate()`, `NonCont = 1`; chiude le righe Silver (`TPagati = NumTickets`, `MangiaT += 16384`); poi ricalcola `Clienti.Tickets` e `Clienti.Bonus` [V `FrmSil2Gld.frm:478-537`].
- **Regole:** percentuale `ParCSil` da `Setup(102).MisVSerie` [V `Module1.bas:2672`].
- **Dati:** `Tickets` (insert, update massivo), `Clienti`.
- **Peso: M** — operazione massiva irreversibile.
- **Evidenze:** `FrmSil2Gld.frm:408-537`.

### W03-15 Conversione dei punti Silver↔Gold del singolo cliente

- **Attore e innesco:** operatore → `frmSil2Gold` o `frmGold2Sil` [V `Form1.frm:7828`, `7477`].
- **Passi:** consuma le righe `Tickets` più recenti della qualità di partenza e crea una riga della qualità di arrivo con punti × percentuale (`MangiaT = 16384`; `D0` valorizzato se l'arrivo è Gold) [V `frmSil2Gold.frm:363-424`, `frmGold2Sil.frm:362-422`]. Poi `SettaTicBonCliente` e ricalcolo multi-locale [V].
- **Differenze tra le due form:** solo il verso (`D0 IS NULL` / `IS NOT NULL`), la percentuale (`ParCSil` = `Setup(102).MisVSerie`, `ParCGld` = `MisVCard`), e una riga: in Silver→Gold uno scontrino non toccato viene trasformato in Gold con `MangiaT | 16384` senza applicare la percentuale; in Gold→Silver viene riscritto con `NumTickets × %` [V `diff` delle due form].
- **Peso: M**.

### W03-16 Opzioni dei clienti con card ("VIP")

- `frmsetVip` imposta: ticket omaggio alla creazione card (`FTNew`), ticket omaggio 24 ore e soglia minima (`FT24H`, `NT24H`), ticket omaggio per compleanno (`FTBDay`), percentuale di bonus ticket per giorni della settimana, fasce orarie e periodo, interesse annuo sui ticket (`PInter`), sconto o promozioni sui premi [V `frmsetVip.frm:869-994`]. Salva nella configurazione della postazione (`SaveSetPost`) e la copia in `VipSet` per le postazioni slave [V `944-967`].
- `FTBDay` non è usato da nessun'altra parte del codice: **il regalo di compleanno in ticket non è implementato** [V ricerca su tutto il sorgente]. `NascOk` e `GiornOk` di `Clienti` non sono mai scritti [V].
- **Peso: S**.

### W03-17 Gestione delle promozioni

- **Attore e innesco:** operatore → `FrmPromozioni` [V `Form1.frm:9869`].
- **Passi:** `MERGE` su `promozioni` (titolo, periodo, scadenza, due flag) [V `FrmPromozioni.frm:584-652`]; elenco delle card promosse con livello attuale [V `795-839`]; eliminazione con `DELETE` [V `527-562`].
- **Regole:** l'eliminazione di una promozione con card collegate fallisce per la chiave esterna `promozioni_cards → promozioni` [D, `ClassPromozioni.cls:152`]. La griglia etichetta `TipoCard` 3 come "platinum" e 0 come vuoto, in contrasto con la codifica usata altrove [V `822`].
- **Peso: S**.

### W03-18 Livello promozionale: applicazione e ripristino

- **Applicazione:** ogni creazione di cliente passa da `ImpostaLivello`. Se esiste una promozione con `GETDATE()` tra `dalla_data` e `alla_data` (o una promozione futura forzata dalla form), il livello diventa **Gold**, tranne per le card compleanno; la card promossa viene registrata in `promozioni_cards` con il livello precedente, una sola volta per card [V `ClassPromozioni.cls:74-116`, `199-246`].
- **Conversione delle vecchie Silver:** con `flagConvertiOldSilver = 'S'`, alla ricarica in cassa una card Silver esistente viene promossa a Gold [V `FrmCCard.frm:2775-2778`].
- **Ripristino:** alla lettura di una card Gold fuori promozione, se la card è in `promozioni_cards` con promozione scaduta (`ISNULL(scadenzaPromozione, alla_data) < GETDATE()`), WinMT cancella il legame e rimette `Clienti.TipoCard` al livello precedente (Silver se ignoto); con `flagRipristinaGoldInSilver = 'S'` riscrive anche il livello sulla card fisica [V `Form1.frm:11096-11110`, `ClassPromozioni.cls:257-365`].
- **Peso: M** — regola temporale distribuita tra creazione, ricarica e lettura.

### W03-19 Gestione degli eventi compleanno

- **Attore e innesco:** operatore → `frmCompleanni`, dal menu o portando la card di un ospite [V `Form1.frm:9564`, `10409-10414`].
- **Passi:** elenco delle feste future (prime 20) con ospiti previsti/effettivi e contatti dei genitori [V `frmCompleanni.frm:1890-1936`]; nuovo evento o modifica: titolo, periodo, modalità ticket, limiti di gioco per card, partecipanti, ricarica precaricata, importi, acconto, contatti dei genitori, note [V `clsCompleanno.cls:436-580`]; eliminazione consentita **solo se l'evento non è ancora iniziato** [V `582-606`]; anagrafica delle tipologie di ricarica (`TipoRicaricheCompleanni`, disabilitazione logica) [V `frmCompleanni.frm:2031-2159`]; parametri `BirthdayDefaultHours` (default 4), `BirthdayLimitHours` (default 24, massimo 168), `BirthdayFreeCharge` in `setup2` [V `1777-1795`, `1977-2020`]; stampa del conto ("riepilogo_compleanno") come report [V `1508-1574`].
- **Regole:** all'apertura, `bonificaOspiti` stacca le card dagli ospiti che non hanno movimenti `TransCard` di eventi finiti da più di 12 ore [V `3526-3557`]. `ImportoCompleanno` è ricalcolato come somma delle ricariche `NImp = 13` degli ospiti [V `clsCompleanno.cls:381-435`].
- **Dati:** `Compleanni`, `Ospiti`, `TipoRicaricheCompleanni`, `PartiteOspiti` (lettura), `TransCard` (lettura), `setup2`.
- **Peso: M**.

### W03-20 Emissione della card ospite di un compleanno

- **Attore e innesco:** operatore con l'evento aperto, card nuova appoggiata sul lettore.
- **Passi (macchina a stati `TimerCreaCard`):**
  1. Verifica: non operatore, ammessa, non già ospite; evento non completo né concluso [V `frmCompleanni.frm:2375-2533`].
  2. `InitCard` con livello **compleanno (3)** [V `2617-2624`].
  3. `AddCliente` di un cliente fittizio con cognome `Compleanno<IdCompleanno>_<n>`, livello 3 e ticketless secondo la modalità ticket [V `2627-2648`].
  4. `addOspite`: riga `Ospiti`; **il primo ospite diventa il festeggiato** (`Compleanni.CardId`, `IdContatto`) [V `clsCompleanno.cls:657-706`].
  5. Se c'è una ricarica precaricata: scrive crediti e bonus sulla card, poi `TransCard` (bonus `NImp = 6`, crediti `NImp = 13` con `ValoreCassa` = crediti), ticket bonus, ricalcolo dell'importo [V `frmCompleanni.frm:2650-2711`].
- **Periferiche:** lettore ECL.
- **Peso: L** — macchina a stati, creazione di clienti fittizi, movimenti economici.

### W03-21 Ricarica, recupero e conversione di card ospite

- **Ricarica** di un ospite durante l'evento: riesegue i passi 5 di W03-20 [V `frmCompleanni.frm:1726-1732`, `2662`].
- **Recupero** di una card ospite che non ha giocato: `eliminaOspite` cancella la riga `Ospiti`, **cancella tutti i movimenti `TransCard` del cliente** e scollega la card dal cliente (`T0`, `CodBar` = NULL); la card viene formattata [V `clsCompleanno.cls:994-1038`, `frmCompleanni.frm:2728-2747`].
- **Conversione** della card di un cliente esistente in card compleanno: `ChangeCardType(3)` sulla card, `Clienti.TipoCard = 3`, aggiunta come ospite [V `frmCompleanni.frm:2719-2725`, `clsCompleanno.cls:707-732`].
- **Peso: M**.

### W03-22 Redeem code per gli ospiti di un compleanno

- **Attore e innesco:** operatore, pulsante redeem sull'evento.
- **Passi:** per ogni partecipante previsto e non ancora presente crea un redeem code (livello compleanno, crediti e bonus precaricati, validità = periodo dell'evento, email del genitore) tramite `cls_RedeemManager`; lo invia via email in PDF o lo stampa [V `frmCompleanni.frm:1605-1724`].
- **Dati:** `RedeemCodes` (altra zona); report letti dal database cloud del fornitore. **Credenziale scritta nel codice** in `frmCompleanni.frm:1517`, `1519`, `1617`, `1619`.
- **Periferiche:** stampante, posta elettronica, rete verso cloud.
- **Peso: M**.

### W03-23 Fine dell'evento compleanno sulla card

- Alla lettura in cassa di una card di livello compleanno con evento scaduto, `Form1` riporta il livello a **Silver** (sempre), sul DB e sulla card [V `Form1.frm:11113-11126`, `ClassEventi.cls:37-56`, `114`]. Lo scollegamento della card da `Compleanni`/`Ospiti` usa una `UPDATE` con SQL **sintatticamente errata** (colonna `t0` inesistente in `Compleanni`, condizione `like` dentro una stringa) e non ha effetto [V `ClassEventi.cls:58-82`].
- **Peso: S**.

### W03-24 Family card: un pagamento distribuito su più card

- **Attore e innesco:** operatore → `frmCardFamily` [V `Form1.frm:7385`, `9449`].
- **Passi:**
  1. L'operatore inserisce importo, numero di card e modalità; bonus da scaletta più un "extra bonus" per arrotondare al valore del gettone (`valsets.ValGett`) [V `frmCardFamily.frm:3884-3910`]; importo minimo 10 gettoni [V `2437-2563`].
  2. Pagamento contanti o POS [V `2318-2435`].
  3. `DistribuisciImporto` produce un JSON per card in tre modalità: **Equa** (parti uguali a multipli del gettone, resto ai primi), **Bilanciato** (resto all'ultima), **BonusTotale** (stesso importo su tutte, differenza coperta da bonus); i crediti veri sono assegnati alle prime card, il resto come bonus [V `3957-4085`].
  4. Card per card: legge `N0` (ticketless) dal cliente (rifiuta se la card non è di un cliente), scrive crediti e bonus, registra `TransCard` (`NImp = 6` bonus, `NImp = 0` crediti con `ValoreCassa` solo se contanti) e ticket bonus [V `3509-3583`, `3585-3726`].
  5. "Abort" carica il resto su una sola card [V `2292-2307`].
- **Dati:** legge `Clienti`; scrive `TransCard`, `Clienti.Credito`, `Tickets`; `LogTransazioniPos` (POS).
- **Periferiche:** lettore ECL, POS, stampante.
- **Peso: L** — calcolo di ripartizione, pagamento, scrittura su N card senza transazione complessiva.

### W03-25 Cassa semplificata "Astoria": ricarica e rimborso in tempo reale

- **Attore e innesco:** operatore. È la schermata iniziale al posto di `Form1` quando `Setup(101).N14 = 1` ("Astoria") [V `Module1.bas:168-176`, `2697-2706`; `frmLogin1.frm:1435-1437`, `1756`, `1791`].
- **Passi:**
  1. Card RFID o QR sul lettore → cliente letto per `T0`; se il cliente non è "abilitato" lo sblocca e non procede [V `frmAstoria.frm:5532-5679`, `2828-2856`].
  2. Tastierino con importi rapidi; pagamento contanti o POS (sotto 650) [V `3417-3500`].
  3. **Ricarica senza scrivere sulla card**: `addCreditiToUser` inserisce in `TransCard` il bonus (`NImp = 6`) e i crediti (`NImp = 0`, o `8` per il rimborso), calcolando in SQL `ValoreFinale` = ultimo saldo + importo e `N0` = ultimo progressivo + 1, e incrementa `Clienti.Credito` [V `5849-5931`].
  4. Elenco movimenti della card e totale cassa della postazione dall'ultimo svuotamento (`TransCard.D0 IS NULL`) [V `5938-6041`, `5055-5089`].
- **Regole:** i limiti `RechargeTransactionLimit` (250) e `PosTransactionLimit` (650) sono letti da `setup2` ma **non usati**: le soglie effettive sono scritte nel codice (650 per il POS, 1.000 per l'importo) [V `3234-3244`, `3453`, `3682-3717`]. Nel rimborso l'aggiornamento del saldo in memoria **moltiplica** invece di dividere per il fattore di conversione [V `3641-3642`]. Il pannello "carico dobloni" non scrive più nulla (codice commentato) [V `3727-3807`]. Il campo `TransCard.F0` è scritto con il valore opposto rispetto a `AddTransCard` (1 in sala singola qui, 1 in multi-locale là) [V `5878`, `5901`, `ModAddNew.bas:1131`].
- **Periferiche:** lettore ECL, scanner QR, POS (Nayax, Ingenico, PAX, TCP), stampante. Nessuna operazione possibile senza DB.
- **Peso: L** — pagamenti, POS, saldo gestito solo lato server.
- **Evidenze:** `frmAstoria.frm:3200-3381`, `3417-3725`, `5849-5931`.

### W03-26 Creazione di un cliente "QR" (Coin card cartacea)

- **Attore e innesco:** operatore, pulsante con il numero di QR disponibili, visibile se c'è la stampante e il pulsante `AddQRUser` è abilitato [V `frmAstoria.frm:6042-6062`].
- **Passi:** prenota un codice libero con `GetFreeUidCodbar` (righe `UID_Ammessi` con `UID = CodBar`, non emesse, non usate, non prenotate; prenotazione in `uid_reservations` con scadenza) [V `2898-2920`, `sql/.../GetFreeUidCodbar.sql`]; crea il cliente con `T0 = CodBar = codice`, livello Silver (Gold se promozione), ticketless [V `2928-2930`]; `FinalizeUidCodbar` imposta `UID_Ammessi.DataEmissione` e libera la prenotazione [V `2932`]; stampa uno scontrino "COIN CARD" con QR, codice e id cliente [V `2964-2980`].
- **Peso: M**.

### W03-27 Cliente creato automaticamente da una card ammessa

- In `frmAstoria`, una card non assegnata viene accettata se presente in `UID_Ammessi` (o aggiunta, se `Setup(101).F11` lo consente) e diventa un cliente "Cliente - N" con `InitCard` di livello 0 [V `frmAstoria.frm:5099-5123`, `5838-5847`]. Lo stesso meccanismo di auto-ammissione esiste in `UID_Ammesso` (con `CodBar` = UID troncato a 15) [V `Module1.bas:3634-3661`]. **Peso: S**.

### W03-28 Scheda di dettaglio del cliente (`FrmDeCli` e `FrmDeCliML`)

- **Attore e innesco:** operatore, da `Form1` (anche da `frmAstoria`, in forma ridotta) e da HQ (`winmthq`, `winmthqro`, tramite la form `aclienti`) [V `Form1.frm:8479-8489`, `FrmDeCli.frm:4996-5012`].
- **Contenuto:** schede ticket/punti Silver (`Tickets.D0 IS NULL`, con reparto e tipo decodificato), punti Gold (`D0 IS NOT NULL`), premi ritirati (`Vincite`), crediti acquistati e crediti spesi per macchina (`TransCard`), totali (ticket contati, pagati, residui esclusi i cancellati `MangiaT & 4096`; crediti acquistati `NImp < 3`, bonus `NImp = 6`, omaggi `NImp = 9`) [V `FrmDeCli.frm:4802-4979`, `4981-5187`]. Stampe ed export Excel.
- **Differenze di `FrmDeCliML`:** si apre al posto di `FrmDeCli` quando la sala è multi-locale **e** `CSync` è attivo [V `Form1.frm:8482-8486`]; identifica il cliente con `IdLong`; somma i punti Silver/Gold interrogando **ogni database `DB<NImp>` dei locali** sullo stesso server [V `FrmDeCliML.frm:4715-4834`]; carica le liste con le procedure `sp_punti_cliente`, `sp_punti_cliente_gold`, `sp_vincite_cliente`, che **non esistono** nei database analizzati [V `4848-4860`]; non ha le schede dei crediti ECL (blocco vuoto) [V `4861-4862`].
- **Peso: M** — sola lettura, molte query, variante multi-locale.

### W03-29 Classifica dei clienti ed export

- `FrmClaCli` elenca i clienti con punti, Gold (`Bonus × 100`), crediti, ultima visita, **presenze** (giorni distinti con ticket o premi nel periodo) e percentuale di presenza; filtri per data di creazione, ultima visita, livello card, clienti senza ticket, consenso privacy (`F0 = 1` se privacy 2018, altrimenti `OptOut = 1`); export Excel o CSV con anagrafica completa [V `FrmClaCli.frm:1392-1544`, `993-1120`].
- `SettaCrediti` **riscrive `Clienti.Credito`** di tutti i clienti con card dall'ultimo `TransCard.ValoreFinale` [V `1653-1712`].
- **Peso: M**.

### W03-30 Blacklist: consultazione e avviso

- `frmBlList` mostra i clienti con `T1` valorizzato (data, macchina, operazione, crediti, punti, causa) e le card in `CoinlessClonedCards` [V `frmBlList.frm:330-398`]. `frmBlackMsg` è il popup; la funzione `Form1.BlackList` che lo apriva e mandava l'email all'amministratore **non è chiamata** da nessuna parte [V `Form1.frm:17371`]. **Peso: S**.

### W03-31 Ricerca del cliente per nome

- `frmFindCli`: ricerca `LIKE` su cognome e nome, restituisce `IdContatto` o `IdLong` a `Form1` [V `frmFindCli.frm:338-365`]. **Peso: S**.

### W03-32 Minori associati al cliente

- `FrmFigli` gestisce fino a tre minori per cliente (nome, cognome, sesso, data di nascita) in `Figli`, con `Id` = `MAX+1` [V `FrmFigli.frm:613-720`, `ModAddNew.bas:3-27`]. In HQ è in sola lettura. **Nel sorgente di WinMT nessuna form la apre** [V ricerca su tutto il sorgente]: o è raggiungibile solo da HQ, o è inutilizzata [D]. **Peso: S**.

### W03-33 Display del cliente sul secondo monitor

- `cliente.frm` e `clienteV2.frm` mostrano al cliente saldo, punti, slideshow di immagini e il messaggio di promozione a VIP; la V2 si sceglie con la chiave `setup2` `2NdScreenVersion` e differisce per gestione errori e testo "CARD PROMOSSA CON SUCCESSO" invece di "ADESSO SEI UN VIP" [V `frmsetVip.frm:983-989`, `diff` delle due form]. Nessuna scrittura. **Peso: S**.

---

## 3. Significato delle colonne

### `Clienti`

| Colonna | Significato | Valori/codifiche | Evidenza | |
|---------|-------------|------------------|----------|---|
| `IdContatto` | Progressivo del cliente nella sala | `MAX+1`, salta i valori presenti in `TransCard.IdCli`; 0 riservato ai ticket anonimi (`Tickets.IdContatto = 0`) e escluso da tutte le liste | `ModAddNew.bas:579`, `697-708`; `Form1.frm:6589` | V |
| `IdLong` | Identificativo nel gruppo | `IdContatto × 10000 + NImp`; chiave delle figlie in multi-locale | `ModAddNew.bas:624`; `ModuleMultilocale.bas:2-20` | V |
| `IdLong2` | Origine della registrazione | 1 = App; NULL/0 = banco ("Store") | `FrmNewCliApp.frm:1363`; `FrmClaCli.frm:1498` | V |
| `IdMaster1`, `IdMaster2` | Master di una card secondaria | `IdLong` del master; 0 o NULL = nessuno | `FrmGenCard.frm:1840-1864`; `Form1.frm:6978` | V |
| `NImp` | Codice impianto (sala) | `valsets.NImp` | `ModAddNew.bas:620` | V |
| `T0` | UID della card | 16 caratteri (8 esadecimali + 8 zeri); per i clienti QR = `CodBar` | `FrmGenCard.frm:3005-3074`; `frmAstoria.frm:2928-2930` | V |
| `CodBar` | Barcode stampato sulla card | da `UID_Ammessi` (primi 8 caratteri dell'UID); prefisso `JV` = card LED, `CD` = card con barcode | `ModAddNew.bas:712-743`; `FrmGenCard.frm:2792-2803` | V |
| `TipoCard` | Livello della card | 0 Platinum, 1 Gold, 2 Silver, 3 Compleanno (sul firmware "BDAY"/"VIP"); 999 non prodotto dal codice | `FrmGenCard.frm:1698`, `2584-2593`; `Module1.bas:754-757` | V |
| `N0` | Ticketless | 1 = vincite accreditate sulla card (e-ticket), 0 = ticket cartacei; replicato sulla card con `SetTicketLess`. **Due punti del codice usano la convenzione opposta** (commento di `AggCliente` e lettura in `FrmGenCard`) | `frmModCli.frm:1655-1665`, `2119-2125`; `ModAddNew.bas:1322`; `FrmGenCard.frm:2569-2573` | V |
| `F0` | Consenso privacy rinnovato ("Rinnovata") | bit; usato come "consenso" nei filtri quando è attiva la privacy 2018 | `frmModCli.frm:1604-1608`; `FrmClaCli.frm:1413-1418` | V |
| `D0` | Scadenza del consenso o della card | oggi + `Setup(102).N1` anni al rinnovo; NULL se 01/01/1901 | `frmModCli.frm:1373-1379`, `1578-1583`; `Module3.bas:237-250` | V |
| `F1`, `T1`, `D1` | Stato blacklist | `T1` = causa (`macchina|costo partita:x|saldo card:y|id clonate:z` dal trigger, `IdPost:PC| |saldo card:… prog[…]` da WinMT), `D1` = data. `F1`: 1 dal trigger alla clonazione; 0 dal blacklist di WinMT; **1 anche dopo lo sblocco** (`sp_rimuovidabl`, `FrmRecoverCard`, con `T1` NULL); 0 dopo la riscrittura card | `bannaUtente`; `Module6.bas:2366`; `FrmRecoverCard.frm:708`; `ModAddNew.bas:1323-1325` | V |
| `Abilita` | Lock "transazione in corso" | 0 = cliente in lavorazione su una postazione o in unione card; 1 = libero | `Form1.frm:6938-6951`; `frmAstoria.frm:4446-4464` | V |
| `Tickets` | Punti residui (copia calcolata) | Σ(`NumTickets − TPagati`) di `Tickets` con `Aux = 0`; in variante Golden solo Silver | `Module8.bas:403-450` | V |
| `Bonus` | In variante Golden: punti Gold / 100 | `decimal(6,2)` usato come contenitore; ×100 a video | `Module8.bas:346-347`, `424-428`; `FrmClaCli.frm:1468`, `1492` | V |
| `Credito` | Saldo della card (crediti + bonus) | in unità interne (centesimi): `ValoreFinale / CentConversionFactor` | `ModAddNew.bas:1135`; `frmAstoria.frm:5914-5917`; `FrmClaCli.frm:1692` | V |
| `Foto` | **Non è una foto**: JSON di attributi estesi | `checkProfiling`, `checkMarketing`, `checkAnalytics`, `checkVipPromotion`, `ReissueCardStatus/Count/OTP/Date/List`, `DailyRefundsAmount/Date`, `VipPromotionSubscriptionExpiryDate` | `ECL_cliente.cls:1129-1200`; `frmModCli.frm:1951` | V |
| `Password` | Password dell'App | in chiaro; copiata da `ClientiAPP` | `FrmNewCliApp.frm:1430`; `frmModCli.frm:1610` | V |
| `FirstLogin` | Registrazione App completata | bit | `frmModCli.frm:1460-1490` | V |
| `IdTel` | Identificativo del telefono (App) | `pk_device` dal servizio cloud | `frmModCli.frm:1491-1495` | V |
| `EMailIsCertified`, `HasTelephoneNumberCorrect` | Email/cellulare verificati | azzerati quando il valore cambia; impostati fuori da WinMT | `ModAddNew.bas:1300-1303`; `frmModCli.frm:1595-1598` | V/D |
| `OptOut` | Consenso al trattamento dei dati (nome fuorviante) | 1 = consenso dato | `FrmGenCard.frm:1938-1942`; `FrmClaCli.frm:1416` | V |
| `TipoDoc`, `Docum` | Documento d'identità | 0 patente, 1 carta d'identità, 2 passaporto, 3 codice fiscale; numero | `frmModCli.frm:1748-1755` | V |
| `Sesso` | Sesso | 0 = M, 1 = F | `frmModCli.frm:1611-1615` | V |
| `Nascita` | Data di nascita | 01/01/1900 se non impostata | `FrmGenCard.frm:1943-1947` | V |
| `Data` | Data di iscrizione | +1 secondo a ogni riscrittura card | `FrmGenCard.frm:2602` | V |
| `DataUltVis` | Ultima visita | aggiornata a ogni presa in carico e rilascio | `frmAstoria.frm:4453`; `Form1.frm:17261` | V |
| `Modificato`, `TimeMod`, `OperMod` | Marcatura di modifica | 1, ora, operatore; nessun reset nella zona | `ModAddNew.bas:621-622`, `1316-1317` | V |
| `Nome`, `Cognome` | Anagrafica | segnaposto `Cliente - N`, `Compleanno<id>_<n>`; cancellazione logica = nome "cliente", cognome "eliminato" | `frmAstoria.frm:5843`; `frmCompleanni.frm:2631`; `Form1.frm:5507` | V |
| `UserName`, `NascOk`, `GiornOk`, `LastOp`, `N1` | — | non scritti dalla zona (e `NascOk`/`GiornOk` da nessuna parte del sorgente) | ricerca su tutto il sorgente | V |

### Card, ammissione e promozioni

| Colonna | Significato | Valori/codifiche | Evidenza | |
|---------|-------------|------------------|----------|---|
| `UID_Ammessi.UID` | UID ammesso | 16 caratteri; confronto sempre sui primi 8. Se `UID = CodBar` è un **codice QR** (card virtuale) | `Module1.bas:3643`; `ECL_database.cls:1239` | V |
| `UID_Ammessi.CodBar` | Barcode stampato | `varchar(15)`; con auto-ammissione = UID troncato | `Module1.bas:3650` | V |
| `UID_Ammessi.DataCreazione` | Lotto di generazione dei QR | default `getdate()`; usato per contare i QR disponibili per giorno | `ECL_database.cls:1109`, `1233-1241` | V |
| `UID_Ammessi.DataEmissione` | Emissione del codice QR | valorizzato solo da `FinalizeUidCodbar`; mai per le card RFID | `FinalizeUidCodbar.sql` | V |
| `uid_reservations.*` | Prenotazione temporanea di un QR | `CodBar`, `ReservedBy` = IdPost, `ExpiresAt` (TTL 10 s da `frmAstoria`) | `GetFreeUidCodbar.sql`; `frmAstoria.frm:2912` | V |
| `promozioni.dalla_data`, `alla_data` | Finestra in cui le card nuove nascono Gold | | `ClassPromozioni.cls:84-90` | V |
| `promozioni.scadenzaPromozione` | Data dopo cui le card promosse tornano al livello precedente | default `alla_data` | `ClassPromozioni.cls:271-273` | V |
| `promozioni.flagConvertiOldSilver` | 'S' = le Silver esistenti diventano Gold alla ricarica | 'S'/'N' | `FrmCCard.frm:2775` | V |
| `promozioni.flagRipristinaGoldInSilver` | 'S' = al ripristino si riscrive anche il livello sulla card | 'S'/'N' | `Form1.frm:11105` | V |
| `promozioni_cards.livelloPrecedente` | Livello prima della promozione | NULL letto come 2 (Silver); `cardid` univoco | `ClassPromozioni.cls:229-246`, `264` | V |

### Compleanni

| Colonna | Significato | Valori/codifiche | Evidenza | |
|---------|-------------|------------------|----------|---|
| `Compleanni.ModalitaTickets` | Destinazione delle vincite degli ospiti | A = e-ticket al giocatore, **B** = e-ticket al festeggiato (default), C = nessun ticket, D = ticket cartacei; D → `N0 = 0`, altrimenti 1 | `frmCompleanni.frm:2986-2997`; `clsCompleanno.cls:839-845` | V |
| `Compleanni.MaxPartitePerCard`, `PartiteConsecutive`, `NrSecondiResetConsecutive` | Limiti di gioco per card ospite | 0–50, 0–50, 0–3600 s | `frmCompleanni.frm:1820-1822` | V (applicazione: D, fuori da WinMT) |
| `Compleanni.Partecipanti`, `PartecipantiExtra` | Ospiti previsti ed extra | | `clsCompleanno.cls:607-655` | V |
| `Compleanni.ValorePrecaricatoCrediti`, `ValorePrecaricatoBonus`, `IdRicarica` | Ricarica precaricata su ogni card ospite | centesimi; copiati da `TipoRicaricheCompleanni` | `frmCompleanni.frm:1474-1492` | V |
| `Compleanni.CardId`, `IdContatto` | Festeggiato | il primo ospite registrato | `clsCompleanno.cls:684-695` | V |
| `Compleanni.ImportoCompleanno` | Valore dell'evento | Σ `TransCard.ValoreOperazione` con `NImp = 13` degli ospiti | `clsCompleanno.cls:381-435` | V |
| `Compleanni.ImportoExtra`, `AccontoVersato`, `Note` | Dati economici manuali | | `clsCompleanno.cls:485-527` | V |
| `Compleanni.EmailGenitore1/2`, `CellulareGenitore1/2` | Contatti dei genitori | usati per l'invio dei redeem code | `frmCompleanni.frm:1625-1650` | V |
| `Compleanni.CreatedBy…UpdatedAt` | Audit | **non scritti** da `clsCompleanno` | `clsCompleanno.cls:485-580` | V |
| `Ospiti.CardId`, `IdContatto` | Card e cliente fittizio dell'ospite | `CardId = ''` quando la card è recuperata o "bonificata" | `clsCompleanno.cls:657-706`; `frmCompleanni.frm:3526-3557` | V |
| `PartiteOspiti.*` | Contatori di gioco per ospite e macchina | `device` = `EcsMacchine.device`; **non scritti da WinMT** | `frmCompleanni.frm:3323-3371` | V (scrittore: D, server ECL) |
| `TipoRicaricheCompleanni.*` | Tipologie di ricarica | crediti e bonus in centesimi; `abilitato` = cancellazione logica; `CreatedBy/UpdatedBy` = **IdPost**, non l'operatore; riga seme "Nessuna ricarica" | `frmCompleanni.frm:2051-2159`; `clsCompleanno.cls:933-937` | V |

### Altre tabelle toccate

| Colonna | Significato | Valori/codifiche | Evidenza | |
|---------|-------------|------------------|----------|---|
| `Figli.*` | Minori associati al cliente | `Id` = MAX+1; `Sesso` 'M'/'F'; `DDN`; al massimo 3 nell'interfaccia | `FrmFigli.frm:613-661` | V |
| `Scocard.IdContatto`, `T0`, `F0` | **Alert sul cliente** (riuso della tabella) | `IdContatto` = `IdLong` come testo; `T0` = testo; `F0 = 1` attivo | `frmModCli.frm:2310-2396` | V |
| `Tickets.D0` | Punto Gold | NOT NULL = Gold (data di conversione), NULL = Silver | `FrmSil2Gld.frm:530-534`; `Module8.bas:432-435` | V |
| `Tickets.MangiaT` (bit usati qui) | Origine del punto | 64 bonus/omaggio, 512 passato ad altra card, 1024 acquisito da altra card, 4096 cancellato da operatore, 16384 conversione Silver/Gold | `fn_decode_mt_bitmask`; `FrmUCard.frm:791`; `FrmDeCli.frm:4884` | V |
| `TransCard.NImp` (valori usati qui) | Tipo di movimento card | 0 cassa, 1 totem, 2 cassa mobile, 3–5 scarichi e dobloni/gettoni, 6 bonus, 7 svuotamento, 8 rimborso, 9 omaggio, 10/11 crediti trasferiti/acquisiti, 12 rimborso operatore, 13 ricarica compleanno, 14 online, 15 storno, 16 bonus acquisiti, 18 abbonamenti, 19 riallineamento, **20 riscrittura card** | `ModAddNew.bas:1090-1110`, `1641-1655` | V |
| `TransCard.T0` | Codice impianto che ha scritto il movimento | 4 cifre | `ModAddNew.bas:1130`; `frmAstoria.frm:5879` | V |
| `TransCard.D0` | Chiusura di cassa | NULL = movimento non ancora chiuso | `frmAstoria.frm:5065-5070` | V |
| `Setup(101).N14` | Variante cliente ("opzione segreta") | 0 normale, 1 Astoria, 2 Albarella, 3 Golden | `Module1.bas:168-176`, `2697-2706` | V |
| `Setup(101).F9`, `F10` | Ticketless | F9 = 1: scelta fissata dal sistema; F10 = valore (1 = e-ticket) | `Module1.bas:2628-2633` | V |
| `Setup(101).F11` | Auto-ammissione delle card sconosciute in `UID_Ammessi` | bit (il commento in testata indica 102\F1) | `Module1.bas:2634-2638`, `167` | V |
| `Setup(102).N1`, `MisVCard`, `MisVSerie` | Durata card in anni; % conversione Gold→Silver; % Silver→Gold | i due campi `MisV*` sono riusati | `Module3.bas:237-250`; `Module1.bas:2671-2672` | V |
| `setup2` (IdPost 101) | Parametri | `RechargeTransactionLimit`, `PosTransactionLimit`, `BirthdayDefaultHours`, `BirthdayLimitHours`, `BirthdayFreeCharge`, `2NdScreenVersion`; IdPost 0 = dispositivi micrototem (JSON) | `frmAstoria.frm:3234-3244`; `frmCompleanni.frm:1781-1795`; `FrmCreaCardsBatch.frm:947-987` | V |

---

## 4. Regole, calcoli e comportamenti notevoli

1. **Cliente ≠ card.** Il cliente è stabile (`IdContatto`), la card è un supporto sostituibile (`T0`, `CodBar`). La riscrittura conserva la storia; il recupero (`sp_ripristinacard`) stacca la card lasciando il cliente; l'eliminazione (`sp_eliminacliente`) cancella cliente e storia. Il nuovo modello deve avere un'entità card con stato (in scorta, emessa, assegnata, sostituita, in blacklist, recuperata) e lo storico delle assegnazioni, oggi perso: resta solo `T0` corrente e una traccia testuale nel log blacklist o nel JSON di `Foto` [V].
2. **Saldo della card.** Oggi coesistono tre copie: card, `TransCard` (ultimo `ValoreFinale`, progressivo `N0`) e `Clienti.Credito`. In riscrittura il saldo è ricostruito da `TransCard` e il progressivo della card salta di 50. La cassa "Astoria" lavora **solo lato server** (nessuna scrittura sulla card): è il modello più vicino al nuovo disegno [V].
3. **Livelli.** 0 Platinum, 1 Gold, 2 Silver, 3 Compleanno. Fonti del livello: scelta dell'operatore (preselezione Platinum in `FrmGenCard`), card anonime e in lotto (Silver), registrazione App (Platinum), promozione (Gold), compleanno (3), modelli VIP in `Form1` (Platinum). **Il 7,7% di `TipoCard = 3` in produzione (DB 06) è coerente con le card ospite di compleanno mai ripresentate in cassa dopo l'evento**: il ritorno a Silver avviene solo alla lettura della card [D; verificabile contando `Cognome LIKE 'Compleanno%'`].
4. **Due "Silver/Gold" diversi.** Il livello della card (`TipoCard`) e la qualità dei **punti** (`Tickets.D0`, variante Golden con conversione a percentuale) sono concetti distinti con lo stesso nome [V].
5. **Promozioni Gold** a finestra temporale, con memoria del livello precedente e ripristino pigro alla prima lettura dopo la scadenza [V].
6. **Compleanni**: ogni ospite è un cliente fittizio con card di livello 3 e ricarica precaricata (`NImp = 13`); il primo ospite è il festeggiato; limiti di gioco per card applicati dai dispositivi [V/D].
7. **Family card**: tre algoritmi di ripartizione a multipli del valore del gettone, con bonus extra di arrotondamento [V].
8. **Master/slave**: una card secondaria può avere fino a due master; serve a sommare i punti delle card dei figli su quella del genitore [V].
9. **Unicità**: email univoca nella sala o nel gruppo (card LED); UID univoco tra i clienti; avviso, non blocco, sui nomi duplicati [V].
10. **Configurazione per cliente scritta nel codice**: varianti Astoria/Albarella/Golden, elenco di database con l'alert clienti, flag di compilazione `kevin`, codici di registrazione `JOY`/`NAM` [V].

---

## 5. Problemi rilevanti per il nuovo disegno

1. **Identità dipendente dalla configurazione**: lo stesso campo delle figlie contiene `IdContatto` o `IdLong` a seconda della sala; il passaggio a multi-locale invalida i riferimenti. Nel nuovo modello serve un identificativo globale unico del cliente, indipendente dalla sala.
2. **Campi riusati**: `Foto` come JSON (consensi, OTP di riemissione, rimborsi, VIP), `Bonus` come punti Gold/100, `Scocard` come alert, `OptOut` come consenso, `Setup.MisV*` come percentuali. I consensi privacy vanno modellati esplicitamente, con data e versione.
3. **Semantiche incoerenti**: `N0` con due convenzioni opposte; `F1` con quattro significati; `TransCard.F0` invertito tra due funzioni; etichette dei livelli sbagliate in `FrmPromozioni`.
4. **Operazioni distruttive senza audit**: `sp_eliminacliente`, `eliminaOspite` (cancella **tutti** i movimenti del cliente), unione card con cancellazione dei clienti origine, conversione massiva Silver→Gold. Il nuovo sistema deve usare stati e movimenti di rettifica.
5. **Nessuna atomicità tra card, DB e server ECL** nella riscrittura, nella family card e nella creazione in serie.
6. **Dati personali e di minori**: `Figli` (dati di minori), contatti dei genitori in `Compleanni`, documento d'identità e password in chiaro in `Clienti`; PDF dei documenti in `winmtAPI.ClientiAPP`.
7. **Credenziali nel codice** (`frmCompleanni.frm:1517-1619`) e codice di sblocco fisso (`FrmRecoverCard.frm:238`).
8. **Codice incompleto o morto**: `FrmUnioneCard`, `sp_unione_card`, `sp_punti_cliente*`, `Form1.BlackList`, `FTBDay`, `FrmFigli` non raggiungibile, limiti POS letti e ignorati, SQL errato in `ClassEventi`.
9. **Date nel formato della sessione**: `clsCompleanno` scrive le date come `yyyy-dd-mm`, corretto solo con login SQL in italiano [V `clsCompleanno.cls:490-491`, `534-535`].
10. **Dipendenze cloud sincrone** al banco: registrazione App (`winmtAPI`), controllo email nel gruppo, verifica App, report dei compleanni. Il comportamento senza rete va deciso.

---

## 6. Domande aperte per il team

1. `Clienti.N0`: la convenzione giusta è 1 = ticketless? Le card scritte con `FrmGenCard` in riscrittura possono avere il flag invertito?
2. `TipoCard = 3`: i 3.043 clienti di produzione sono ospiti di compleanno (`Cognome LIKE 'Compleanno%'`)? Il 999 da dove viene?
3. La preselezione Platinum in `FrmGenCard` e il livello 0 per le registrazioni da App sono voluti (modello "fidelizzazione dati personali")?
4. Chi scrive `PartiteOspiti` e applica `MaxPartitePerCard`, `PartiteConsecutive`, `NrSecondiResetConsecutive`: il server ECL di sala?
5. Chi genera i lotti di codici QR in `UID_Ammessi` (`UID = CodBar`)?
6. Chi scrive i clienti creati dal micrototem in lotto, e con quale `IdContatto`?
7. `Clienti.UserName`, `EMailIsCertified`, `HasTelephoneNumberCorrect`: li scrive l'App o il backend cloud?
8. `FrmFigli` è usata da HQ? I dati di minori in `Figli` servono ancora?
9. Le varianti Astoria, Albarella e Golden sono ancora in uso, e in quali sale?
10. La cassa "Astoria" (saldo solo lato server, senza scrittura su card) è il modello da adottare per tutte le sale?
11. Il resto delle unioni di card in multi-locale (`sp_unione_card`) e la scheda multi-locale (`sp_punti_cliente*`) esistono su qualche server HQ?
