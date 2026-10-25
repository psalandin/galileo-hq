# Galileo HQ — WinMT 10: Configurazione, operatori, licenza e periferiche

**Stato:** bozza · **Responsabile:** Piero · **Aggiornato:** 2026-10-23

**Fonte:** sorgente VB6 di WinMT (copia del 24/07/2026), file: `frmsetSys.frm`, `frmsetGen.frm`, `cls_Escp2Printer.cls`, `frmgesop.frm`, `clsSerialAutoDetect.cls`, `haspapidemo.cls`, `frmLogin1.frm`, `cls_setupV2.cls`, `SendMsg.bas`, `FrmSetSql.frm`, `FormMqtt.frm`, `cls_operatore.cls`, `EscNews.bas`, `WINMtSetup.cls`, `clsCCTalkPort.cls`, `frmKeyB.frm`, `modSerialDeviceTypes.bas`, `clsSerialDetectResult.cls`, `cls_autodiscover.cls`, `clsResolve.cls`, `ModRilevamento.bas`, `clsMailerPS.cls`, `HttpService.ctl`, `AuditLog.cls`, `FrmWServer.frm`, `haspvendorcode.bas`, `ModuleMultilocale.bas`, `FormAutodiscover.frm`, `FormESCP.frm`; letti in parte, perché indispensabili a capire `Setup`: `Module1.bas` (`Main`, `KeyLocate`, `CaricaSetup`, `CaricaVarMaster`, `SalvaVarNew`, `CaricaGen`, `CaricaPost`, `SaveSetPost`, `CaricaPassW`/`SalvaPassw`, `SaveLog2DB`, commenti di testata sui campi jolly), `Module6.bas` (`SetOp`, `EncPWord`/`DecPWord`, `SendEmail`, `ScadAbb`), `Module3.bas` (durata card), `ECL_database.cls` (creazione e default di `setup2`), `ECL_operatore.cls` (permessi operatore), `ECL_BonusHandler.cls` (scale bonus), `CreaRaccolte.bas` (righe `Setup` > 110), `Form1.frm` (login con card, controllo della sincronizzazione) · **Collegati:** `docs/db/db-01-schema.md`, `docs/db/db-02-catalogo.md`, `docs/db/db-03-risultati-01.md` (§ password), `docs/db/db-04-risultati-02.md` (§ 1, `Setup`), `docs/db/db-06-produzione-02.md` (§ 1), `docs/db/db-07-confronto-test-produzione.md` (`Setup_Descriptions`), `sql/risultati/Setup_Descriptions-test.tsv`, `sql/codice-db/test/applicativo/procedure/GetSetupAsTable.sql`

Legenda: **[V]** verificato nel codice (`file:riga`); **[D]** dedotto, da confermare.

> **Credenziali.** Nel codice di questa zona ci sono numerose credenziali in chiaro o offuscate in modo reversibile. Qui sono indicate solo con "credenziale scritta nel codice in `file:riga`"; i valori non sono riportati.

---

## 1. Perimetro

| File | Righe di codice | Ruolo | Lettura |
|------|----------------:|-------|---------|
| `frmsetSys.frm` | 3909 | **"Setup" di sistema e di postazione**: postazione (IdPost, Master/Slave), porte seriali e autodetect, stampante, lettore card, POS, ECL (parametri valuta, card di setup, Wi-Fi), sincronizzazione, multi-locale, app, email di servizio, server secondario, opzioni segrete | A fondo: `Command2_Click` (salvataggio), `Form_Load`, `CmbIdNet_Click`, `AggPost`, `SetPost`, `UserApp`/`SaveUserApp`, `ReadSyncInt`/`SaveSyncInt`, `SettaCSECL`/`SalvaCSECL`, email di servizio, `AutoDetectNew`, `cmdECLSetup`/`cmdCCSetup`, gesti nascosti. Scorsi: `AutoDetectLegacy`, test POS, `SetLang` |
| `frmsetGen.frm` | 1778 | **"Opzioni generali"** della sala: dati del locale, operazione/concorso, opzioni operatore/manager/supervisore, promozioni, abbuoni, ricevute, registra premio, registra incassi, inventario, 2° schermo, ritiro card, abbonamento VIP | A fondo: `Command2_Click`, `Form_Load` (parte dati), gestori delle caselle. Scorse le traduzioni |
| `frmLogin1.frm` | 590 | **Login operatore** con password, fondo cassa, cambio password, uscita con backup, accesso al setup senza connessione | Per intero |
| `frmgesop.frm` | 902 | **Gestione operatori**: crea, modifica, disattiva; livello; abilitazioni e limiti ECL; scrittura card operatore (magnetica o RFID) | Per intero |
| `cls_operatore.cls` | 215 | DTO di `Operatori` (solo lettura; `Inserisci`/`Aggiorna` commentati). Usato solo da `FrmInventario2` | Per intero |
| `AuditLog.cls` | 45 | Scrittura in `AuditLog` (`Access`, `DeviceStatus`). **Mai istanziata** in WinMT | Per intero |
| `cls_setupV2.cls` | 355 | Accesso chiave/valore a `setup2` (lettura, scrittura upsert, JSON di pulsanti e POS) | Per intero |
| `WINMtSetup.cls` | 181 | DTO con una proprietà per colonna di `Setup`; caricato da `ECL_database.LoadSetupParameters` decodificando i campi `MTCry` | Per intero |
| `FrmSetSql.frm` | 227 | **Impostazioni del server SQL** e **passaggio al server secondario** | Per intero |
| `haspapidemo.cls`, `haspvendorcode.bas` | 594 + 29 | **Licenza** con chiave hardware HASP (Aladdin/SafeNet): lettura della stringa di licenza dalla chiave | Lette `RunDemo`, `RunDemoNew`, `SessionInfoDemo`; il resto è codice d'esempio del produttore. Il vendor code non è riportato |
| `clsSerialAutoDetect.cls`, `clsSerialDetectResult.cls`, `modSerialDeviceTypes.bas` | 633 + 118 + 125 | **Autodetect delle periferiche seriali** con cache in `setup2` | Per intero |
| `clsCCTalkPort.cls` | 154 | Trasporto generico ccTalk (frame, checksum). **Mai istanziata** | Per intero |
| `cls_Escp2Printer.cls`, `FormESCP.frm` | 991 + 0 | **Stampa con modelli** in ESC/POS o ESC/P2, su seriale o TCP 9100; `FormESCP` ospita i controlli | Interfaccia pubblica e linguaggio dei modelli; rendering scorso |
| `FormMqtt.frm` | 223 | **Client MQTT** usato solo come **watchdog** del servizio `ecl2mqtt` (nome attuale; prima versione `ecs2mqtt`) | Per intero |
| `HttpService.ctl` | 47 | Client HTTP GET (non un server) verso `ecl2mqtt` sulla porta 58889 | Per intero |
| `FrmWServer.frm` | 29 | Finestra "Ricerca del Server…" all'avvio; i clic sull'etichetta aprono le impostazioni del server | Per intero |
| `cls_autodiscover.cls`, `FormAutodiscover.frm` | 103 + 7 | **Scoperta del server** in rete con broadcast UDP | Per intero |
| `clsResolve.cls` | 99 | Risoluzione nome → IP (Winsock), usata da `SimplePing` | Scorso |
| `SendMsg.bas` | 273 | Invio **push / email ai clienti** tramite il servizio web Elmac | Per intero |
| `clsMailerPS.cls` | 53 | Invio email SMTP tramite PowerShell (compleanni, redeem code) | Per intero |
| `EscNews.bas` | 202 | Inserimenti in anagrafiche ECS (`Owners`, `EcsMacchine`, `Manuf`, `Type`, `Machines`, `EcsDati`, `EcsErr`, `EcsModuli`), chiamati da `FrmConf` (altra zona) | Per intero |
| `ModRilevamento.bas` | 77 | Flag di "rilevamento forzato" in `Setup` 110. **Nessun chiamante** in WinMT | Per intero |
| `ModuleMultilocale.bas` | 14 | Scelta tra `IdContatto` e `IdLong` come identificativo cliente | Per intero |
| `frmKeyB.frm` | 143 | Tastiera virtuale a schermo (password, nome server) | Scorso |

---

## 2. Flussi

### W10-01 — Avvio della postazione e caricamento della configurazione

- **Attore e innesco:** sistema, all'avvio di WinMT (`Sub Main`, `Module1.bas:699`). **[V]**
- **Passi:**
  1. Legge dal **registro di Windows** (`HKCU\…\VB and VBA Program Settings\<EXE>\Settings`) server SQL, utente, password, nome DB della chiave, parametri Wake-on-LAN, tutti offuscati con `MTCry` (§ 4.4). **[V]** `Module1.bas:746-750`
  2. **Scoperta del server** in rete: broadcast UDP sulla porta 51049 con `ARQFIND ECLServer:<ip>`; se `ecl2mqtt` risponde, il nome del server SQL e la modalità (`AppMode`: `RT` = REALTIME, altrimenti ECL) vengono presi dalla risposta e sovrascrivono quelli del registro. Poi `VERSIONFIND` per leggere la versione di `ecl2mqtt` e del DB (default 2.28 / 20240625 se non risponde). **[V]** `Module1.bas:773-830`, `cls_autodiscover.cls:26-52`
  3. Se mancano server o password apre `frmSetSql` (W10-12). Se il server non risponde al ping mostra `FrmWServer`; un clic sull'etichetta cerca un **server secondario** (`SLAVEFIND`) e propone il passaggio. **[V]** `Module1.bas:880-965`
  4. Verifica la **licenza** (W10-11). **[V]** `Module1.bas:973`
  5. Verifica la struttura del DB e crea/aggiorna oggetti mancanti in base a `dbversion` (tra cui `setup2`, `Setup_Descriptions`, valori di default di `setup2`). **[V]** `Module1.bas:1003-1043`, `ECL_database.cls:27-95, 457-491`
  6. `CaricaSetup` → `CaricaGen` (opzioni generali, dalla **prima riga** di `Setup`, cioè 101, e dalla 102 e 110) → `CaricaPost` (opzioni della postazione, dalla riga il cui `MName` inizia con il nome del computer) → `CaricaVipPromotionParams` (`setup2`). Tutto finisce in variabili globali (`valsets`, `Reparti`, `TSSnumber`, `DatiInv`, `TRate` e decine di variabili sciolte). **[V]** `Module1.bas:1859-1895, 2373-2763, 2765-2788, 2790-2915`
  7. Legge da `setup2` la versione del secondo schermo (`2NdScreenVersion`) e la politica dei ticket hardware (`HardwareTicketsPolicy`; se manca scrive il default). **[V]** `Module1.bas:1059-1083`
  8. Se `CodEcs = 'ECL'` avvia il **watchdog MQTT** (W10-16). **[V]** `Module1.bas:1094-1107`
  9. Controlla che la chiave di licenza sia della sala: le cifre `DB####` lette dalla chiave devono coincidere con `Setup.NImp`, altrimenti "Incorrect Dongle Key!" ed esce. **[V]** `Module1.bas:1114-1121`
  10. **Controllo dell'orologio:** se `Setup.DataStop` (ora dell'ultima chiusura della postazione) è nel futuro, il programma si chiude ("orologio di sistema incongruente"). **[V]** `Module1.bas:1187-1197`
  11. Mostra `frmLogin1` (W10-06).
- **Dati letti:** `Setup` (tutte le colonne, righe 101, 102, 110, riga della postazione), `setup2` (101: `2NdScreenVersion`, `HardwareTicketsPolicy`, `VipSubscriptionParams`), `Operatori` (id 9999), `sys.columns`. **[V]**
- **Dati scritti:** `Setup` (default di `OraBIni`, `OraBEnd`, `DataBIni`, `DataBEnd`, `OpRig`, `N1` se nulli; `MName` della postazione), `setup2` (default), `Operatori` (crea l'operatore 9999 "Galileo App" se la sincronizzazione è attiva). **[V]** `Module1.bas:2488-2531, 2593-2597, 2722-2730`
- **Regole:** in caso di errore di connessione durante `CaricaGen`/`CaricaPost` il programma termina (`End`). **[V]** `Module1.bas:2757-2761, 2903-2906`
- **Periferiche/rete:** UDP broadcast, ping ICMP, chiave HASP, MQTT. Senza server SQL la postazione **non funziona**; si può solo entrare nel setup con la super password (W10-06).
- **Peso: L** — molte sorgenti di configurazione (registro, UDP, chiave, DB, `setup2`), migrazioni di schema, varianti per cliente.
- **Evidenze:** `Module1.bas:699-1200`, `Module1.bas:1859-2915`.

### W10-02 — Identificazione della postazione e assegnazione di IdPost

- **Attore e innesco:** sistema all'avvio (`CaricaPost`); amministratore in Setup di sistema, combo **ID postazione** (`CmbIdNet`, valori 101–110). **[V]**
- **Passi:**
  1. All'avvio scorre le righe di `Setup` con `IDPost < 110` e cerca quella con `MName` = `<nome computer>|<carattere>`. **[V]** `Module1.bas:2801-2812`
  2. Se non la trova occupa la prima riga con `MName` vuoto (e `IDPost > 101`); se non ce ne sono: "Too many users." e chiusura. **[V]** `Module1.bas:2813-2828`
  3. Il secondo elemento di `MName` è un **carattere che codifica la porta COM** del lettore barcode del secondo utente (split screen): `Chr(numcommBR2)`. **[V]** `Module1.bas:2829-2836`
  4. Dal Setup di sistema l'amministratore può scegliere un altro IdPost: se è già di un altro computer chiede conferma, sposta il proprio nome sulla nuova riga, svuota la vecchia e **chiude il programma**. Scegliere 101 rende la postazione **Master**. **[V]** `frmsetSys.frm:5814-5871`
  5. `AggPost` (Setup di sistema) fa la stessa ricerca e, se tutte le righe sono occupate, **si mette sulla riga 110**. **[V]** `frmsetSys.frm:9151-9204`
- **Dati letti/scritti:** `Setup.MName` (L/S), `Setup.IDPost` (L), registro `IDPost` (S). **[V]**
- **Regole:** le righe 101–110 devono **esistere già** nel DB: il ramo che creava una nuova riga (`NewUser`) è morto, perché `NewUser` è sempre falso. **[V]** `Module1.bas:736, 1870-1883`
- **Peso: M** — logica di assegnazione con casi limite (posti esauriti, riga 110 occupata da una postazione).
- **Evidenze:** `Module1.bas:2790-2915`, `frmsetSys.frm:5814-5871, 9151-9220`.

### W10-03 — Opzioni generali della sala (frmsetGen)

- **Attore e innesco:** amministratore (livello 0), menu *Setup → Opzioni generali*; pulsante di conferma `Command2`. **[V]** `frmsetGen.frm:4560`
- **Passi:**
  1. `Form_Load` presenta le opzioni a schede (dati del locale, operazione, orario, opzioni operatore/manager/supervisore, durata card, prenotazioni senza card, valore massimo scontrini, colore, cancellazione automatica ordini, registra premio, ricevuta premio, promozioni, abbuoni, promemoria card, schermo cliente, inventario, modo semplificato, registra incassi, 2° schermo, ritiro card, abbonamento VIP). **[V]** `frmsetGen.frm:5006-6035`
  2. Il salvataggio copia i controlli nelle variabili globali e chiama **`SaveSetPost`**, che scrive su `Setup` (W10-04, passo 5). **[V]** `frmsetGen.frm:4563-4910`
  3. Scrive su `setup2` (IdPost 101) `2NdScreenVersion` (`""` o `V2`), `RitiroCard` (`enabled`/`disabled`) e `VipSubscriptionParams` (JSON). **[V]** `frmsetGen.frm:4912-4964`
  4. Se il modulo privacy è attivo scrive la durata delle card in anni in `Setup.N1` della riga 102. **[V]** `frmsetGen.frm:4563-4565`, `Module3.bas:225-235`
  5. *Ricalcola tickets* (`CmdRicTic`) ricalcola i punti di tutti i clienti (`SettaTicBonClienti`); in multi-locale avverte che tutti i locali devono essere chiusi. **[V]** `frmsetGen.frm:4510-4548`
- **Dati scritti:** `Setup` (riga 101, vedi § 3), `setup2` (101). **[V]**
- **Regole notevoli:**
  - Le promozioni restano attive solo se la data di fine è futura (`AbPr` = casella **e** `DtASc > oggi`). **[V]** `frmsetGen.frm:4866-4870, 5328`
  - Un orario di fine promozione precedente a quello di inizio blocca il salvataggio. **[V]** `frmsetGen.frm:4748-4758`
  - `TotTick` = giorni di scadenza ordini × 1000 + giorni di preavviso (§ 3). **[V]** `frmsetGen.frm:4588`
  - La spunta **RFID obbligatorio** disattiva *barcode obbligatorio* e *banda magnetica obbligatoria*. **[V]** `frmsetGen.frm:4448-4453`
  - Il "Modo semplificato" (`Easys`) nasconde e azzera prenotazioni, abbuoni, promemoria, promozioni, registra premio, registra incassi. **[V]** `frmsetGen.frm:4384-4420`
  - Modelli VIP: `FidelizzazioneDatiPersonali`, `FidelizzazioneSottoscrizione` (importo, scadenza o durata in mesi), `FidelizzazioneUtilizzoContinuativo` (importo, durata), `FidelizzazioneSogliaMinima` (importo, durata fissa 24 mesi). **[V]** `frmsetGen.frm:4926-4962`
  - Riquadro nascosto **"Convalida automatica"**: compare solo con una sequenza di clic con Maiusc e tasto destro in un punto preciso della scheda. **[V]** `frmsetGen.frm:6043-6070`
- **Peso: L** — circa 120 opzioni, scrittura in due tabelle, regole di abilitazione incrociate, varianti per livello.
- **Evidenze:** `frmsetGen.frm:4292-4991, 5006-6161`.

### W10-04 — Setup di sistema e di postazione (frmsetSys)

- **Attore e innesco:** amministratore (livello 0) da *Setup*, oppure dal login senza connessione con super password (W10-06). Conferma con `Command2`. **[V]** `frmsetSys.frm:6895`
- **Passi:**
  1. `Form_Load` legge configurazione, elenco POS (`setup2.AvailablePosDevices`), credenziali app (`Setup.T0…T3`), intervallo di sincronizzazione (`Setup.N0` riga **110**), data di scadenza abbonamento (`Setup.D0` riga 102), porte disponibili. **[V]** `frmsetSys.frm:7534-8020`
  2. Se la postazione **non è Master** nasconde le opzioni globali (lingua, moltiplicatore punti, lista approvata, raccolte card, app, email di servizio, disco di backup, sostituzione barcode…). **[V]** `frmsetSys.frm:9132-9149`
  3. Al salvataggio valida le porte (stampante, barcode, lettore card, RFID, mangiatickets 1–5, POS), compone i parametri ECL in `AdmPass`, la scala bonus, l'email di servizio, il moltiplicatore punti (1, 2, 5, 10…100). **[V]** `frmsetSys.frm:6898-7430`
  4. Salva `MsgSco.bin` (messaggio scontrino) **su file locale**, verifica la connessione SQL, scrive nel registro server/utente/password e Wake-on-LAN. **[V]** `frmsetSys.frm:7432-7455`
  5. **`SaveSetPost`**: se la postazione è Master scrive **tutte** le opzioni (generali e di postazione) nella **prima riga** di `Setup` (101), poi alcune opzioni "segrete" nella **seconda riga** (102); se è Slave scrive solo le colonne di postazione nella propria riga (creandola se manca). **[V]** `Module1.bas:2917-3249`
  6. Salva le scale bonus (`ECL_BonusHandler.saveConfig` → `Setup.T10`, `T12` riga 101); se Master scrive `SyncEn`. **[V]** `frmsetSys.frm:7458-7472`, `ECL_BonusHandler.cls:177-197`
  7. Riavvia `MTLink` se presente e torna a `Form1`. **[V]** `frmsetSys.frm:7475-7506`
- **Dati scritti:** `Setup` (righe 101, 102, 110, postazione), `setup2`, registro, file `MsgSco.bin`. **[V]**
- **Funzioni nascoste:**
  - doppio clic sul riquadro di sistema (solo Master) → campo password che, con una **password scritta nel codice**, mostra le impostazioni di sincronizzazione (`frmsetSys.frm:8027-8030, 6811-6814`; credenziale scritta nel codice in `frmsetSys.frm:6813`);
  - sequenza di clic con Maiusc/tasto destro (solo IdPost 101) → riquadro **"Opzioni segrete"** con la variante cliente `HiddenOpt` (NORMALE, ASTORIA, ALBARELLA, GOLD). **[V]** `frmsetSys.frm:8032-8055, 7917-7922`
- **Peso: L** — tabella da 282 colonne scritta "a blocchi", logica Master/Slave, periferiche, registro, file locali.
- **Evidenze:** `frmsetSys.frm:6895-7513, 7534-8020, 9132-9296`; `Module1.bas:2917-3249`.

### W10-05 — Parametri estesi chiave/valore (setup2)

- **Attore e innesco:** qualsiasi parte del programma tramite l'oggetto globale `mySetup` (`cls_setupV2`). **[V]**
- **Passi:** `GetSetupValue(IdPost, Chiave)` legge `Valore` (stringa vuota se manca); `GetLongValue`/`GetIntValue`/`GetDateValue` convertono lato SQL; `SetSetupValue` fa un **upsert** (`IF EXISTS … UPDATE … ELSE INSERT`); `GetIsGiallone` conta le righe con `Valore LIKE '<chiave>%'`; `getAvailablePosDevices` e `IsButtonAvailable` interpretano JSON. Ogni chiamata ritenta una volta se la connessione è caduta. **[V]** `cls_setupV2.cls:84-475`
- **Dati:** `setup2.{IdPost, Chiave, Valore}` (L/S). Le chiavi usate sono elencate in § 3.3.
- **Regole:** SQL costruito per concatenazione (con escape degli apici); `GetDateValue` in realtà restituisce un **intero**. **[V]** `cls_setupV2.cls:272-328`
- **Peso: S** — accesso chiave/valore semplice; il peso sta nei flussi che lo usano.
- **Evidenze:** `cls_setupV2.cls`.

### W10-06 — Login operatore con password

- **Attore e innesco:** operatore all'avvio o dopo il log-off; `frmLogin1`, pulsante **OK**. **[V]** `frmLogin1.frm:1402`
- **Passi:**
  1. Carica gli operatori con `id < 1000` e `Attivo = 1` in una combo "000 - Cognome" (l'operatore 0 compare solo se è l'unico). Legge la password dell'operatore 0 come **password amministratore**. **[V]** `frmLogin1.frm:1599-1666`
  2. Confronta il testo con `DecPWord(Operatori.Password)`. Se coincide imposta operatore corrente, livello, inizio turno, applica i permessi (W10-09) e apre `Form1` (o `frmAstoria` per la variante Astoria). **[V]** `frmLogin1.frm:1408-1451`
  3. Se è attiva la **gestione cassa** (`GCassa`) chiede prima il **fondo cassa** con un tastierino (solo livelli 0 e 1 possono modificarlo) e lo memorizza in `valsets.VCassa`, poi salvato in `Setup.VCassa` della postazione. **[V]** `frmLogin1.frm:1426-1432, 1741-1774`
  4. Se il testo coincide con la **super password** (`Setup.T0` della riga 110, o un valore di fallback scritto nel codice) entra come primo operatore della tabella (l'amministratore). **[V]** `frmLogin1.frm:1453-1458`; credenziale scritta nel codice in `Module1.bas:2712`
  5. **Accesso nascosto** ("GodMode"): tre clic sul logo con combinazioni Maiusc/tasto destro compilano la super password ed entrano. **[V]** `frmLogin1.frm:1707-1731`
  6. **Cambio password**: vecchia password, nuova e conferma (minimo 4 caratteri), salvata con `EncPWord`. **[V]** `frmLogin1.frm:1350-1394`
  7. **Senza connessione al server**: si può solo entrare nel Setup di sistema digitando la super password o la password amministratore. **[V]** `frmLogin1.frm:1505-1521`
- **Dati letti/scritti:** `Operatori.{Id, Nome, Cognome, Password, Livello, Attivo}` (L), `Operatori.Password` (S, cambio password), `Setup` 110 `T0` (L). **[V]**
- **Periferiche:** tastiera virtuale (`frmKeyB`) se `Setup.Multiuser` è vero: la colonna "multiutenza" è **riusata** come "tastiera virtuale". **[V]** `frmLogin1.frm:1922-1931`, `frmsetSys.frm:7447-7451`
- **Peso: M** — più percorsi d'accesso (password, super password, gesto nascosto, senza rete) e la gestione del fondo cassa.
- **Evidenze:** `frmLogin1.frm:1350-1774`.

### W10-07 — Login operatore con card o barcode

- **Attore e innesco:** operatore che passa la propria card in `Form1`, in qualunque momento (cambio operatore al volo). **[V]**
- **Passi:**
  1. **Card RFID ECL:** il codice della card (UID) viene cercato in `Operatori.T0`; se trovato diventa l'operatore corrente con livello `Livello And 3`. **[V]** `Form1.frm:11373-11390`
  2. **Card magnetica:** dalla traccia si leggono id operatore (8 cifre) e data/ora di emissione; il login riesce solo se la data coincide con `Operatori.Data`. Una card riscritta **invalida** quella precedente. **[V]** `Form1.frm:12541-12560`, `frmgesop.frm:1324-1335`
  3. **Barcode:** il codice letto viene cercato in `Operatori.CodBar`. Se non c'è tra gli attivi ma esiste un operatore **disattivato** con quel barcode, `AbilitaOperatore` lo **riattiva** (`Attivo = 1`) e lo fa entrare. **[V]** `Form1.frm:14429-14466, 17233-17250`
  4. Con `GCassa` attivo il login con card apre comunque il fondo cassa di `frmLogin1`. **[V]** `Form1.frm:11389-11400, 14440-14451`
  5. Variante Astoria: per cambiare operatore occorre tornare al login. **[V]** `Form1.frm:11376-11381`
- **Dati letti/scritti:** `Operatori.{T0, CodBar, Data, Id, Nome, Cognome, Livello}` (L), `Operatori.Attivo` (S, riattivazione). **[V]**
- **Periferiche:** lettore RFID ECL, lettore di banda magnetica, scanner barcode.
- **Peso: M** — tre periferiche, regole di validità della card e la riattivazione implicita.
- **Evidenze:** `Form1.frm:11373-11400, 12541-12560, 14429-14466, 17233-17250`.

### W10-08 — Gestione operatori (frmgesop)

- **Attore e innesco:** amministratore o manager, menu *Operatori*. **[V]** `frmgesop.frm:1182`
- **Passi:**
  1. L'elenco dipende dal livello di chi opera: l'amministratore vede tutti (`id` 1–999), il manager solo operatori e supervisori, l'operatore solo gli operatori. I livelli assegnabili seguono la stessa regola. **[V]** `frmgesop.frm:1190-1204, 1291-1314`
  2. **Nuovo:** inserisce subito una riga con `Id = max(id < 1000) + 1`, livello 2, **password predefinita** (credenziale scritta nel codice in `frmgesop.frm:939`); se si esce senza salvare la riga viene cancellata. **[V]** `frmgesop.frm:588-624, 908-983, 1137-1144`
  3. **Salva:** nome, cognome, barcode della card (`CD`/`JV` + 9 caratteri), UID RFID, livello, flag *crediti di servizio* (`F0`), maschera delle abilitazioni (`N0`) e, in ECL, i **limiti giornalieri** salvati come JSON nella colonna `Foto`. **[V]** `frmgesop.frm:851-905`, `ECL_operatore.cls:185-228`
  4. **Reset password:** reimposta la password predefinita. **[V]** `frmgesop.frm:847-849`
  5. **Cancella:** non cancella, **disattiva** (`Attivo = 0`) e **svuota `CodBar`**; non si può eliminare l'ultimo amministratore; l'operatore 0 non è modificabile. **[V]** `frmgesop.frm:690-757, 1116-1120`
  6. **Card operatore:** con lettore magnetico scrive sulla traccia scelta (`NTrack`) id operatore, data/ora corrente e codice impianto, aggiornando `Operatori.Data`; con lettore RFID ECL inizializza la card con codice cliente e impianto ECL e imposta il flag "crediti di servizio" sulla card. **[V]** `frmgesop.frm:987-1029, 1315-1388, 1420-1546`
- **Dati letti/scritti:** `Operatori.{Id, Nome, Cognome, Password, Data, Livello, CodBar, Attivo, F0, T0, N0, Foto, NImp}`. **[V]**
- **Periferiche:** lettore magnetico (9600 8N1, comandi ESC), lettore RFID ECL (38400 8N1), scanner barcode.
- **Peso: L** — anagrafica con permessi su tre livelli di codifica, scrittura su due tipi di card.
- **Evidenze:** `frmgesop.frm:588-1546`, `ECL_operatore.cls:185-228`.

### W10-09 — Applicazione dei permessi (SetOp)

- **Attore e innesco:** sistema, dopo ogni login (`Module6.SetOp`). **[V]** `Module6.bas:181`
- **Passi:** carica l'operatore in `OperatoreInCanna` (`ECL_operatore`) e, in base a `LvLx`, mostra o nasconde menu e pulsanti di `Form1`:
  - **0 Amministratore:** tutto, incluso Setup, cancellazione archivi e pulizia (solo se Master), recupero card rotte (solo in GodMode), menu ECL se `CodEcs` contiene `ECL`;
  - **1 Manager:** quasi tutto tranne Setup, cancellazione archivi, pulizia; scontrino manuale salvo `HSMMa`;
  - **2 Operatore:** guidato dai flag di `Setup` 101: `OpRapp`, `OpMPremi`, `OpScoMan`/`PasswSM`/`HSMOp`, `OpCli`, `OpResi`, `OpRig`, `OpModCli`, `F0` (menu reparti);
  - **3 Supervisore:** guidato dalle 11 opzioni di `Setup.T4` (§ 3). **[V]** `Module6.bas:189-420`
- **Dati letti:** `Operatori` (via `ECL_operatore`), variabili da `Setup` 101. **[V]**
- **Peso: M** — matrice dei permessi distribuita su livello, flag di sala, opzioni del supervisore e maschera per operatore.
- **Evidenze:** `Module6.bas:181-420`.

### W10-10 — Chiusura del programma con backup

- **Attore e innesco:** operatore, pulsante **ESCI** del login (`CmdCancel`). **[V]** `frmLogin1.frm:1286`
- **Passi:**
  1. Se il log è attivo salva il file di log nella tabella `Logs` (`SaveLog2DB`). **[V]** `frmLogin1.frm:1293-1296`, `Module1.bas:3397-3424`
  2. Se è impostato un disco di backup (`Setup.BkDisk`) **e** il server è `localhost`, esegue `BACKUP DATABASE WinMtSqlDB` sul disco indicato. In caso di errore `BkpOk = False`. **[V]** `frmLogin1.frm:1298-1344`
  3. Imposta `EndOk = True`, `DataStop = Now` e chiama `SaveSetPost`. **[V]** `frmLogin1.frm:1319-1321`
- **Dati scritti:** `Logs.{IDPost, Data, LFile}`; `Setup.{BkpOk, EndOk, DataStop}` della postazione (e, se Master, tutta la riga 101). **[V]**
- **Peso: M** — backup del DB dalla postazione e salvataggio dello stato di chiusura.
- **Evidenze:** `frmLogin1.frm:1286-1348`.

### W10-11 — Verifica della licenza

- **Attore e innesco:** sistema, all'avvio e in alcuni accessi a funzioni (`KeyLocate`). **[V]** `Module1.bas:1311`
- **Passi:**
  1. Login alla chiave HASP (funzionalità di default, poi API nuova se la prima non risponde) e lettura di una **stringa di licenza** dalla memoria della chiave; legge anche l'id della chiave. **[V]** `haspapidemo.cls:699-760, 792-870, 668-694`
  2. La stringa determina i **moduli abilitati**: `Single User`; `4 Users` (multiutenza, 4 operatori contemporanei); `2 Users` (split screen); `Easy Software` / `WinBet Software` (modo semplificato); `Prize Hub`; `TotemSql`; `Jolly Key` (tutto, DB "Jolly"); `Sql` (versione SQL Server). Contiene anche `DB####`, il codice impianto. **[V]** `haspapidemo.cls:710-746`
  3. **Licenza software di riserva:** se la chiave non c'è, legge `Setup.F1` e `Setup.T1` della **riga 110**: con `F1 = 1` la stringa `T1` sostituisce quella della chiave; altrimenti "Chiave non trovata!" ed esce. **[V]** `Module1.bas:1336-1400`
  4. Il codice impianto della chiave deve coincidere con `Setup.NImp` (W10-01, passo 9).
- **Dati letti:** `Setup` 110 `F1`, `T1`; `Setup` 101 `NImp`. **[V]** Nessuna scrittura da WinMT. **[V]**
- **Periferiche:** chiave USB HASP.
- **Peso: M** — due canali di licenza e una tabella di moduli.
- **Evidenze:** `Module1.bas:1311-1405`, `haspapidemo.cls:699-870`.

### W10-12 — Impostazioni del server SQL e passaggio al server secondario

- **Attore e innesco:** tecnico all'avvio se mancano i parametri (`frmSetSql`), oppure all'avvio quando il server primario non risponde e un server secondario risponde al broadcast `SLAVEFIND`. **[V]** `Module1.bas:899-965`
- **Passi:**
  1. Chiede nome del server e password (con conferma); `localhost` diventa `LocalHost\WinMtSql`. Nel caso normale i campi password sono **precompilati** con un valore scritto nel codice (credenziale scritta nel codice in `FrmSetSql.frm:580-581`). **[V]** `FrmSetSql.frm:499-555, 578-584, 640-642`
  2. Per il **server secondario** chiede la password amministratore (o la super password) e una conferma, poi attende il ritardo di commutazione (`Setup.NRep4` riga 102, default 30 s). **[V]** `FrmSetSql.frm:511-539`
  3. Salva il server nel registro; nella riga 102 di `Setup` sposta `NRep3` (IP secondario) in `NRep2` (IP attivo) e svuota `NRep3`; ferma `MTLink`; chiama `http://<server>:58889/redundance/setprimary` su `ecl2mqtt`. **[V]** `FrmSetSql.frm:540-548, 707-724`
- **Dati scritti:** `Setup` 102 `NRep2`, `NRep3`; registro `SqlServ`, `SqlPass`. **[V]**
- **Peso: M** — failover manuale tra due server con aggiornamento di DB, registro e servizio.
- **Evidenze:** `FrmSetSql.frm:499-724`, `Module1.bas:899-965`.

### W10-13 — Autodetect delle periferiche seriali

- **Attore e innesco:** amministratore, Setup di sistema, pulsante *Auto* (`CmdAuto` → `AutoDetectNew`). **[V]** `frmsetSys.frm:6579-6583, 9648-9711`
- **Passi:**
  1. Enumera le porte COM e svuota le assegnazioni a video. **[V]** `frmsetSys.frm:9657-9673`
  2. Per ogni periferica abilitata prova prima la porta in **cache** (`setup2`, chiave `SERIAL_AUTODETECT.DEVICE.<tipo>` per la postazione), poi tutte le porte libere non marcate vuote. **[V]** `clsSerialAutoDetect.cls:277-317, 388-430`
  3. Sonde: **mangiatickets** (9600 8N1, attende 1 s il carattere `?` che inviano spontaneamente); **lettore magnetico** (ESC `a`, ESC `t`, risposta `3S`); **barcode** (ESC `Z1`, risposte `Ver`, `ZFCV`, `RBCV`, `OPR`, `RBJV`, `FL5`, `BD0`, `MDI:`); **stampante** (GS `I` 1, uno di alcuni byte attesi); **RFID ECL** (38400 8N1, comando `GetCodes`, risposta `ValImpRd … Parsing_Ok` con codice impianto, codice cliente e tipo lettore; tipo "CASSA"). **[V]** `clsSerialAutoDetect.cls:465-850`
  4. Salva ogni esito come JSON in `setup2` e marca come vuote le porte senza periferica (`SERIAL_AUTODETECT.EMPTY.COM<n>`). Il risultato riempie le combo; il salvataggio vero in `Setup` avviene con W10-04. **[V]** `clsSerialAutoDetect.cls:188-215`, `frmsetSys.frm:9713-9752`
- **Dati scritti:** `setup2` (IdPost della postazione). **[V]**
- **Periferiche:** fino a 5 mangiatickets, lettore magnetico, 2 barcode, stampante, lettore RFID ECL. Il POS è cercato solo dal vecchio autodetect (`AutoDetectLegacy`, 115200 8N1). **[V]** `frmsetSys.frm:6007-6576`
- **Peso: M** — molte periferiche con protocolli diversi, ma lineare.
- **Evidenze:** `clsSerialAutoDetect.cls`, `modSerialDeviceTypes.bas`, `frmsetSys.frm:9648-9776`.

### W10-14 — Card di setup e card di configurazione ECL

- **Attore e innesco:** amministratore, Setup di sistema, riquadro ECL. **[V]**
- **Passi:**
  1. **Card di setup** (`cmdECLSetup`): legge una card **vergine** sul lettore RFID e ne memorizza l'UID come `ECLSetupCard`, salvato nella seconda parte di `Setup.Passw` (§ 3). **[V]** `frmsetSys.frm:6677-6749`, `Module1.bas:3622-3632`
  2. **Card di configurazione** (`cmdCCSetup`): inizializza una card con codice cliente e codice impianto ECL (o zero, a scelta) e vi scrive **SSID e password Wi-Fi** delle schede ECL presi da `Setup.T8`. **[V]** `frmsetSys.frm:6595-6675`
  3. I parametri ECL (codice cliente, impianto, fattori di conversione, etichette) sono salvati in `Setup.AdmPass`; la connessione al DB remoto ECL e il Wi-Fi in `Setup.T7` (riga 102) e `T8` (riga 101). **[V]** `frmsetSys.frm:6968-6986, 9431-9500`
- **Dati letti/scritti:** `Setup.{Passw, AdmPass}` (101), `Setup.T7` (102), `Setup.T8` (101). **[V]**
- **Periferiche:** lettore RFID ECL (38400 8N1).
- **Peso: M** — interazione con card e parametri sensibili (Wi-Fi) in chiaro offuscato.
- **Evidenze:** `frmsetSys.frm:6595-6749, 9431-9500`.

### W10-15 — Configurazione e test del terminale POS

- **Attore e innesco:** amministratore, Setup di sistema, riquadro POS. **[V]**
- **Passi:** abilitazione POS, scelta del modello (elenco da `setup2.AvailablePosDevices`: Nayax VPOS, Ingenico IUP250, PAX IM20, PAX Q30, Nayax Saturn 1000, NayaxVPOSTouchPosHandler, NayaxVPosDummy, PosHandler), porta, "stampa doppio scontrino"; test di comunicazione seriale (115200 8N1) con decodifica delle risposte Amit e Ingenico. **[V]** `frmsetSys.frm:7566-7591, 6934-6942, 8260-8317, 9528-9619`
- **Dati scritti:** `Setup.N10` (modello), `N11` (porta), `N13` (doppio scontrino) della postazione. **[V]** `Module1.bas:3243-3246`
- **Periferiche:** POS seriale; per i POS TCP la configurazione è in `setup2.PosTcpConfig` (altra zona).
- **Peso: M** — più modelli e protocolli, ma solo configurazione e test.
- **Evidenze:** `frmsetSys.frm:8260-8542, 9528-9619`.

### W10-16 — Watchdog del servizio ecl2mqtt via MQTT

- **Attore e innesco:** sistema, solo se `CodEcs = 'ECL'`. **[V]** `Module1.bas:1094-1107`
- **Passi:**
  1. Si connette al broker MQTT **sullo stesso host del server SQL**, porta 1883, client id `ClientWinmt<computer>`, con credenziali scritte nel codice (credenziale scritta nel codice in `FormMqtt.frm:132`) e *last will* retained su `ECLClients/WinMt/<computer>` (`{"IsOnline":"0","state":…,"idpost":…}`). **[V]** `FormMqtt.frm:119-143, 281-285`
  2. Alla connessione pubblica lo stato `Started` (retained) e si abbona a `ElmacECL/Server`, `ECLClients/Server`, `ElmacECL/+`. **[V]** `FormMqtt.frm:148-166`, `Module1.bas:1097-1104`
  3. Un timer (30 s) chiede `IsServerOnline` (topic `ECLClients/Watchdog/IsServerOnline` se `setup2.ecs2mqttVer ≥ 2.36.0`, altrimenti `ElmacECL/IsServerOnline`). Dopo 60 s senza segnali mostra "servizio offline", **disabilita la riconversione delle card** (`canRebuildCard = False`) e pubblica `watchdog/restart`. Ogni messaggio con `ValCard` o una risposta `ServerOnline = 1` azzera il contatore. **[V]** `FormMqtt.frm:177-201, 309-319, 329-362`
- **Dati:** `setup2` 101 `ecs2mqttVer` (L). Nessun dato di business viaggia su MQTT da WinMT. **[V]**
- **Peso: M** — protocollo asincrono con stati, ma senza dati di dominio.
- **Evidenze:** `FormMqtt.frm`, `Module1.bas:1094-1107`.

### W10-17 — Notifiche: push e email ai clienti, email di servizio

- **Attore e innesco:** operatore (messaggio a un cliente da `Form1` o `FrmPMsg`); sistema (allarme sincronizzazione, card in blacklist; email di compleanno e redeem code da altre zone). **[V]**
- **Passi:**
  1. **Push/email al cliente via cloud Elmac:** compone `sendpush|oggetto|testo|IDTel|NImp|` (o `sendmail`, `pushmsg`), lo cifra (`EnCodeStr`), lo codifica in esadecimale e lo invia in **HTTP** (non HTTPS) a un servizio web Elmac; attende fino a 10 s. Il destinatario è `Clienti.IdTel` (id dell'utente nell'app). **[V]** `SendMsg.bas:2-108, 110-211, 213-295`
  2. **Email di servizio** (`SendEmail`, CDO su SMTP SSL con credenziali scritte nel codice in `Module6.bas:2178`): invia e poi scrive `Setup.D3 = GETDATE()` nella riga **101**. **[V]** `Module6.bas:2161-2205`
  3. **Allarme sincronizzazione:** se dall'ultimo sincronismo (`Setup.D1`, riga **110**) è passato più di 3 volte l'intervallo (`N0`, riga 110) e l'ultima email (`D3`, riga **110**) è di un giorno precedente, invia "Sync error" all'email di servizio (`Setup.T9` riga 101). **[V]** `Form1.frm:16118-16126`
  4. **Email via PowerShell** (`clsMailerPS`): SMTP 587 con credenziali scritte nel codice (`clsMailerPS.cls:41`); usata da compleanni e redeem code. **[V]** `clsMailerPS.cls:24-90`
- **Dati:** `Setup` 101 `T9`, `D3` (S); `Setup` 110 `D1`, `N0`, `D3` (L); `Clienti.IdTel` (L). **[V]**
- **Regole:** l'email di servizio aggiorna `D3` sulla riga 101 ma il controllo legge `D3` dalla riga 110: il limite "una email al giorno" **non funziona** se nessun altro aggiorna la 110 (§ 5). **[V]**
- **Peso: M** — tre canali di invio diversi, con dipendenze esterne.
- **Evidenze:** `SendMsg.bas`, `clsMailerPS.cls`, `Module6.bas:2161-2205`, `Form1.frm:16118-16175`.

### W10-18 — Stampa di scontrini con modelli (cls_Escp2Printer)

- **Attore e innesco:** altre zone (ricarica card, compleanni, Astoria, redeem code, `Form1`) creano un `cls_Escp2Printer`. **[V]** `Form1.frm:5389`, `FrmCCard.frm:1850`, `Module1.bas:3986, 4066`
- **Passi:** modalità ESC/POS o ESC/P2; connessione seriale (`Setup.numcommPR`, 9600) o TCP RAW 9100; numero di colonne letto da `setup2.NrColonnePrinter_<TypePrt>` della postazione (default 24, scritto se manca); modello testuale con tag `{field:…}`, `{[bold]}`, `{[align:center]}`, `{[title2H]}`, `{qr:…}`, `{barcode:…}`, `{image:…}`, `{logo}`, `{cut}`; il logo dipende da `TypePrt`. I modelli sono **scritti nel codice** dei chiamanti. **[V]** `cls_Escp2Printer.cls:9-60, 445-662, 1181-1245`, `Module1.bas:3980-4040`
- **Dati:** `setup2.NrColonnePrinter_<n>` (L/S), `Setup.TypePrt`, `numcommPR`. **[V]**
- **Periferiche:** stampante termica (NEOS, Bixolon STP-103, Xthea, Neo's Cutter, K3, P3).
- **Peso: M** — motore di layout riusabile; i contenuti sono nei flussi chiamanti.
- **Evidenze:** `cls_Escp2Printer.cls`.

### W10-19 — Indicatore di sincronizzazione

- **Attore e innesco:** timer di `Form1`. **[V]** `Form1.frm:16137-16175`
- **Passi:** senza multi-locale fa solo un test di connessione al DB; in multi-locale confronta `Setup.D1` con `N0 + 60` s sulla riga 110 e cambia l'icona (online/offline), registrando nel log i cambi di stato. **[V]**
- **Dati letti:** `Setup` 110 `D1`, `N0`. **[V]**
- **Peso: S** — consultazione.

### W10-20 — Anagrafiche ECS di supporto (EscNews)

- **Attore e innesco:** configurazione macchine (`FrmConf`, altra zona). **[V]** `FrmConf.frm:1309-1563`
- **Passi:** inserisce proprietari, macchine ECS, moduli, letture contatori ed errori nel DB di sala; **costruttori, tipi e modelli** di macchina li inserisce **nel DB cloud** se raggiungibile (`CSCloud`, da `Setup.T7` riga 102), altrimenti in locale. Gli id sono calcolati come `max(id) + 1`. **[V]** `EscNews.bas:2-202`
- **Dati scritti:** `Owners`, `EcsMacchine`, `Manuf`, `Type`, `Machines`, `EcsDati`, `EcsErr`, `EcsModuli`. **[V]**
- **Peso: S** — inserimenti singoli; il flusso vero è nella zona macchine.

---

## 3. Significato delle colonne

### 3.1 `Setup`: come è organizzata

`Setup` non è "una riga per postazione" pura. Le righe hanno **ruoli diversi a seconda di `IDPost`**, e la stessa colonna cambia significato da una riga all'altra. **[V]**

| IDPost | Ruolo | Chi la legge | Chi la scrive | Evidenza |
|--------|-------|--------------|---------------|----------|
| **101** | **Doppio ruolo:** configurazione **generale della sala** (letta da tutte le postazioni) **e** configurazione della postazione **Master** | `CaricaGen` (prima riga), `CaricaPost` del Master | `SaveSetPost` del Master scrive tutto qui | `Module1.bas:2384, 2926-3190` |
| **102** | **Doppio ruolo:** seconda postazione **e** "opzioni segrete" globali: IP server attivo/secondario e ritardo di commutazione, parametri Silver↔Gold, connessione DB remoto ECL, privacy, durata card, scadenza abbonamento | `CaricaGen` (`rs.MoveNext`), `SettaCSECL`, `ScadAbb`, `LeggiDurCard` | `SaveSetPost` del Master (seconda riga), `SalvaCSECL`, `FrmSetSql`, `Save_SwDelay`, `ScriviDurCard` | `Module1.bas:2669-2694, 3180-3190` |
| 103–109 | Postazioni Slave: solo colonne di postazione | `CaricaPost` | `SaveSetPost` (ramo Slave) | `Module1.bas:3206-3249` |
| **110** | Riga **di servizio**: super password, licenza software, intervallo e ultimo sincronismo, ultima email; può essere occupata da una postazione se le altre sono piene | `CaricaGen`, `KeyLocate`, `ReadSyncInt`, timer di sync | `SaveSyncInt`; il resto da altri programmi **[D]** | `Module1.bas:2708-2713, 1339`; `frmsetSys.frm:9185, 9271-9296` |
| **> 110** | **Raccolte card** (collezioni): 111 Mistral (`CodEcs = MS`), 112 Willy Wonka (`WW`), 113 … | Raccolte / rapporto | `CreaRaccolte.bas` | `CreaRaccolte.bas:3-140` |

Il "Master" è la postazione con `IDPost = 101` (`OptMas`); scegliendo un altro IdPost la postazione diventa Slave. **[V]** `frmsetSys.frm:5844-5848, 7421`

**Globale o di postazione.** Le colonne lette da `CaricaPost` sono **di postazione**; tutte le altre sono **globali** e valgono solo nella riga 101 (una postazione Slave le ignora nella propria riga). **[V]** `Module1.bas:2836-2895` vs `2373-2668`

| Ambito | Colonne |
|--------|---------|
| **Postazione** (ogni riga 101–110) | `MName`, `numcommMT1..5`, `numcommBR`, `numcommCR`, `numcommPR`, `N2` (porta RFID), `TypePrt`, `SecMonX`, `SecMonY`, `Log`, `CardReader`, `IdMT1..5`, `NRepMT1..5`, `ConnOk`, `MisData`, `MisCard`, `MisSerie`, `EndOk`, `DataStop`, `Master`, `AbBr0..3`, `PBRm0..3`, `AbMon3`, `Mon3H`, `Mon3V`, `Ab4Usr`, `Multiuser`, `GCassa`, `VCassa`, `N10`, `N11`, `N12`, `N13`, `F12`, `F1` (totem), `F2` (ignora errori POS) |
| **Globale** (riga 101) | tutte le altre: reparti, promozioni, bonus, abbuoni, fiscali, permessi operatore/manager, inventario, dati del locale, ECL, multi-locale, app, sincronizzazione, jolly `F0`, `F3–F11`, `N1`, `N3–N9`, `N14`, `T0–T12`, `D3` |
| **Globale** (riga 102) | `NRep2`, `NRep3`, `NRep4`, `MisVCard`, `MisVSerie`, `T7`, `F0`, `N1`, `D0` |
| **Globale** (riga 110) | `T0`, `F1`, `T1`, `N0`, `D1`, `D3` |

> **Risposta a `db-01` / `db-04`.** La riga 101 è sia "generale" sia "postazione Master"; 102–110 sono postazioni, ma la 102 contiene anche parametri globali e la 110 è una riga di servizio; > 110 sono le raccolte card. `MName` ha sempre un `|` finale perché il secondo elemento è un carattere che codifica la porta COM del secondo barcode (spesso `Chr(0)`). **[V]** `Module1.bas:2829-2836`

### 3.2 `Setup`: colonne decodificate

Le colonne non elencate hanno il significato riportato in `Setup_Descriptions` e confermato da `Module1.bas:283-480` (tipo `setupval`). Qui le colonne con significato **oscuro, riusato, dipendente dalla riga** o in **contrasto con `Setup_Descriptions`**.

| Colonna | Significato | Valori / codifiche | Evidenza | |
|---------|-------------|--------------------|----------|---|
| `Setup.IDPost` | Ruolo della riga (vedi § 3.1) | 101 generale+Master; 102–109 postazioni; 110 servizio; >110 raccolte | `Module1.bas:2790-2915`, `CreaRaccolte.bas` | V |
| `Setup.MName` | Nome del computer che occupa la riga + porta del 2° barcode | `<computer>\|<Chr(porta)>`; vuoto = riga libera | `Module1.bas:2829-2836`; `frmsetSys.frm:5842-5855` | V |
| `Setup.Master` | La postazione è il Master (la riga 101) | bit; nella 101 = 1 | `frmsetSys.frm:7421`; `Module1.bas:2873` | V |
| `Setup.NImp` | **Codice impianto** (sala): deve coincidere con `DB####` della licenza | intero | `Module1.bas:1114-1121, 1358`; `frmsetSys.frm:7089` | V |
| `Setup.CodEcs` | Tipo di sistema di raccolta contatori/card collegato; nelle righe > 110 codice della raccolta | 101: `ECL`, `ECLReader`, `EcsNetWiFly`, `EcsReader`, vuoto; >110: `MS`, `WW`… | `Module1.bas:87-92`; `frmsetSys.frm:6915-6919`; `CreaRaccolte.bas:18` | V |
| `Setup.Passw` | **Non è una password.** Opzioni: `OpCaRem\|ECLSetupCard` = operatore abilitato al carico remoto (0/1) e UID esadecimale della card di setup ECL | es. `1\|04A1B2…` | `Module1.bas:3609-3632`; `frmsetSys.frm:6736-6742` | V |
| `Setup.AdmPass` | **Non è una password** (il commento dice "password amministratore criptata"). Parametri ECL separati da `\|`: codice cliente ECL, codice impianto ECL, rapporto cent→valuta, nome dell'unità (`EUR`…), rapporto cent→crediti, flag, etichetta moneta, etichetta gettoni | default 0,01 / 1 / `TOKEN` / `COIN`; `EUR` ⇒ mostra simbolo valuta | `frmsetSys.frm:6981`; `Module1.bas:2733-2750, 21-29` | V |
| `Setup.PasswSM` | Flag: password obbligatoria per lo scontrino manuale | bit | `Module1.bas:364`; `Module6.bas:326-337` | V |
| `Setup.InvPass` | Flag: anche la password del manager può concludere l'inventario | bit | `Module1.bas:380` | V |
| `Setup.TotTick` | **Non è "totale tickets contati".** Cancellazione automatica degli ordini non riscossi: giorni di scadenza × 1000 + giorni di preavviso | es. 30005 = 30 giorni, avviso a 5 | `frmsetGen.frm:4588, 5061-5062`; `FrmPreLis.frm:559` | V |
| `Setup.ScoMan` | **Non è "scontrino manuale".** Abilita la cancellazione automatica degli ordini non riscossi (casella `CAutOrd`) | bit | `frmsetGen.frm:4300-4310, 5088-5096` | V |
| `Setup.MdbSaveInt` | **Riusata:** moltiplicatore punti `MolPun` (1 ticket = N punti) | 1, 2, 5, 10…100; < 0 o > 100 ⇒ 1 | `Module1.bas:2070, 2294, 2541, 3066`; `frmsetSys.frm:7142-7169` | V |
| `Setup.MagPremLoc` | **Riusata:** `TagRd`, RFID obbligatorio per creare la card | bit | `Module1.bas:2039, 2263, 2479, 3035` | V |
| `Setup.NewSet` | `AppEn`: app clienti in funzione | bit | `Module1.bas:2592`; `frmsetSys.frm:7002-7006` | V |
| `Setup.SyncEn` | Sincronizzazione abilitata (solo Master); se vera crea l'operatore 9999 "Galileo App" | bit | `frmsetSys.frm:7460-7472`; `Module1.bas:2722-2730` | V |
| `Setup.SyncRes` | Esito dell'ultima sincronizzazione (contiene "Failed"/"Success"); nelle righe > 110 **caratteri identificativi delle card** della raccolta | testo | `frmsetSys.frm:9165`; `Form1.frm:16892`; `CreaRaccolte.bas:23` | V |
| `Setup.Ric25` | **Registra premio**: abilita la registrazione fiscale con **ricevuta** dei premi di valore superiore a `Pre25` ("25" = soglia storica di 25 €) | bit | `frmsetGen.frm:2420-2460, 4791-4795`; `Form1.frm:6159-6177` | V (soglia storica D) |
| `Setup.Pre25` | Soglia di valore (costo del premio) per la registrazione/ricevuta; **usata anche** come soglia **Gold/Silver** dei premi e come filtro della lista premi | valuta | `Form1.frm:5691, 6078, 15086, 15726` | V |
| `Setup.NtickRic` / `FPpremio` | Stampa ricevuta premio se il premio vale almeno N ticket | intero / bit | `frmsetGen.frm:4670, 4761`; `Form1.frm:6153` | V |
| `Setup.DataIni`, `DataEnd`, `NConc` | "Estremi dell'Operazione": date e nome dell'operazione/concorso. `NConc` è stampato in testa agli scontrini premio; **le date non sono usate da nessuna logica** | date / testo | `frmsetGen.frm:360-440, 4759-4768`; `Form1.frm:6177` | V |
| `Setup.NewConc`, `IniConc` | "Cambio gestione": i rapporti separano i ticket pagati prima/dopo `IniConc` | bit / data | `frmsetSys.frm:7096-7101`; `FrmRappUs.frm:1922-1926` | V |
| `Setup.TypePrt` | Modello di stampante | 0 NEOS S4GN-PS, 1 Bixolon STP-103, 2 Xthea, 3 Neo's Cutter, 4 K3, 5 P3 | `frmsetSys.frm:7812-7818` | V |
| `Setup.CardReader` | Lettore di banda magnetica | 0 MSR106, 1 MSR206HiCo, 2 MSR206LoCo, 3 MiniMag (nessun comando ESC) | `frmsetSys.frm:7819-7823`; `frmgesop.frm:1213` | V |
| `Setup.NTrack` | Traccia della banda su cui scrivere | 1, 2, 3 | `frmsetSys.frm:7858-7861` | V |
| `Setup.Lang` | Lingua | 0 italiano, 1 inglese, 2 francese | `frmLogin1.frm:1335-1342` | V |
| `Setup.N2` | Porta COM del lettore RFID (postazione) | intero | `Module1.bas:2854, 2982, 3221` | V |
| `Setup.numcommMT1..5`, `IdMT1..5`, `NRepMT1..5` | Porta, indirizzo (1–50) e reparto delle mangiatickets 1–5 della postazione | interi | `frmsetSys.frm:7090-7094, 7426-7430` | V |
| `Setup.AbBr0..3`, `PBRm0..3`, `Ab4Usr` | Modalità **4 operatori**: abilitazione e porta dei 4 barcode | bit / porta | `Module1.bas:429-431` | V |
| `Setup.Multiuser` | **Riusata:** tastiera virtuale a schermo | bit | `frmsetSys.frm:7447-7451`; `frmLogin1.frm:1923` | V |
| `Setup.Mon3H` | Risoluzione orizzontale 3° monitor; nelle varianti Astoria/Albarella **valore del doblone / gettone × 100** | intero | `frmsetSys.frm:6928-6933`; `Module1.bas:2591` | V |
| `Setup.NTMolt` | Moltiplicatore numero ticket automatico; in Astoria contatore stampe | intero | `Module1.bas:353` | V (commento) |
| `Setup.MisVCard`, `MisVSerie` | Riga 101: valore card singola e serie Mistral. Riga 102: **parametri di conversione Gold / Silver** | interi | `Module1.bas:2671-2672, 3181-3182` | V |
| `Setup.TRed`, `TGru`, `TPus`, `TAlt` | IVA % per categoria di macchina nella registrazione incassi: Redemption, Gru, Pusher, Altri | decimali | `frmsetGen.frm:4589-4592, 3931-3960` | V |
| `Setup.TSSNum0..9` | Matricole delle ticket station non collegate i cui scontrini sono accettati (`TicStat`) | testo | `frmsetSys.frm:7388-7405` | V |
| `Setup.EndOk`, `DataStop` | Chiusura regolare e ora di chiusura della postazione; `DataStop` futura blocca l'avvio | bit / datetime | `frmLogin1.frm:1319-1320`; `Module1.bas:1187-1197` | V |
| `Setup.BkDisk`, `BkpOk` | Disco del backup alla chiusura (solo server locale) e suo esito | testo / bit | `frmLogin1.frm:1298-1344` | V |
| `Setup.GCassa`, `VCassa` | Gestione del fondo cassa della postazione e suo valore corrente | bit / money | `frmLogin1.frm:1426-1432`; `FrmCCard.frm:2843`; `FrmEcs.frm:3006` | V |
| `Setup.F0` | 101: menu reparti per l'operatore; 102: modulo **privacy** attivo; 110: (ModRilevamento) rilevamento forzato, **non usato** da WinMT; >110: raccolta attiva | bit | `Module1.bas:2598, 2690-2694`; `ModRilevamento.bas` | V |
| `Setup.F1` | 101–109: postazione **totem** (`Kiosk_Exists` se almeno una); 110: **licenza software valida** | bit | `Module1.bas:2715-2720, 1339-1356` | V |
| `Setup.F3`–`F7` | 101: codice premio sovrascritto dal barcode; manager modifica descrizione / barcode premi; nascondi avviso quantità negativa / punti abbuonati | bit | `Module1.bas:2623-2627` | V |
| `Setup.F9` | 101: **negazione** di "lascia al cliente la scelta e-ticket/ticket" | bit (1 = non lasciare scelta) | `Module1.bas:2628-2632` | V |
| `Setup.F10` | 101: modalità predefinita **ticketless** (e-ticket) invece di ticket cartacei | bit | `frmsetSys.frm:6943-6947` | V |
| `Setup.F11` | 101: aggiungi automaticamente gli UID sconosciuti a `UID_Ammessi` | bit | `Module1.bas:3634-3651` | V |
| `Setup.F12` | Postazione: scanner portatile (hand-held, senza comandi laser) | bit | `frmsetSys.frm:6898-6902`; `frmgesop.frm:679` | V |
| `Setup.N0` | 110: **intervallo di sincronizzazione** in secondi (non 101 come dice il dizionario); >110 non usato | intero | `frmsetSys.frm:9271-9296`; `Form1.frm:16123` | V |
| `Setup.N1` | 101: versione del DB; 102: durata in anni delle card cliente (0 = non scade) | intero | `Module1.bas:2593-2597`; `Module3.bas:225-250` | V |
| `Setup.N3`–`N9` | 101: nascondi quantità macchine; colore finestra; max punti scontrini manuali/reparto; prenotazioni senza card; `MSiteMode` (niente transazioni card con locale off-line: **salvato ma senza consumatori in WinMT**); ritardo scanner ms (0–1000); valore massimo premio con scontrini | interi | `Module1.bas:2639-2663`; `frmsetSys.frm:6967, 6992-6996` | V |
| `Setup.N10`–`N13` | Postazione: modello POS (= chiave di `AvailablePosDevices` + 1; 0 = disabilitato), porta POS, contatore stampe POS, doppio scontrino POS | interi | `Module1.bas:2891-2894, 3173-3176, 3243-3246`; `frmsetSys.frm:6934-6942` | V |
| `Setup.N14` | 101: variante cliente (`HiddenOpt`) | 0 Normale, 1 Astoria, 2 Albarella, 3 Gold | `Module1.bas:2656-2702`; `frmsetSys.frm:7917-7922` | V |
| `Setup.T0`–`T3` | 101: utente e password **admin** e **user** della console web dell'app, offuscati `MTCry`; >110: nome raccolta, valore serie, flag | testo | `frmsetSys.frm:9222-9269`; `CreaRaccolte.bas` | V |
| `Setup.T0` (110) | **Super password**, offuscata `MTCry` | testo | `Module1.bas:2708-2713` | V |
| `Setup.T1` (110) | **Tipo di licenza software** (stessa stringa della chiave HASP) | es. contiene `Sql`, `4 Users`… | `Module1.bas:1339-1398` | V |
| `Setup.T4` | 101: 11 opzioni del **Supervisore** separate da `\|`: riscrivi card, scontrino manuale, resi, rapporto, menu premi, gestione clienti, modifica clienti, auto log-off, nascondi scontrino manuale, menu reparti, carico remoto | `0`/`1` | `frmsetGen.frm:4576-4587`; `Module6.bas:381-420` | V |
| `Setup.T5` | 101: elenco locali per i **trasferimenti di magazzino** | `nome\|nome\|…` | `frmsetGen.frm:4572-4575` | V |
| `Setup.T6` | 101: locali collegati in **multi-locale** (`NetSites`); contiene `#` ⇒ disattivato. >110: nomi delle serie | `Nome\|0000\|Nome\|0001…` | `Module1.bas:2601-2605`; `frmsetSys.frm:9398-9409` | V |
| `Setup.T7` | 101: credenziali del server cloud per multi-locale (`CServer`, `MTCry`); 102: `ECL\|server\|db\|utente\|password` del DB remoto ECL (`MTCry`); >110: valori delle card | testo | `Module1.bas:2619, 74`; `frmsetSys.frm:9445-9485` | V |
| `Setup.T8` | 101: **SSID e password Wi-Fi** delle schede ECL (`MTCry`) | `ssid\|password` | `Module1.bas:2606-2617`; `frmsetSys.frm:9488-9489` | V |
| `Setup.T9` | 101: email di servizio | testo | `frmsetSys.frm:9502-9526` | V |
| `Setup.T10`, `T12` | 101: scala bonus sulle ricariche (crediti) e sui ticket | coppie `soglia\|bonus\|…` | `ECL_BonusHandler.cls:106, 197`; `Module1.bas:3663-3699` | V |
| `Setup.T11` | 101: importi di ricarica proposti con il POS | 7 valori `\|` | `Module1.bas:3675-3700` | V |
| `Setup.D0` (102) | Scadenza dell'**abbonamento** (in rosso se < 15 giorni) | data | `Module6.bas:2489-2505`; `frmsetSys.frm:8008-8012` | V |
| `Setup.D1` (110) | Ultimo sincronismo (scritto dall'agente di sync) | datetime | `Form1.frm:16123, 16152` | V (scrittore D) |
| `Setup.D3` | Ultima email di servizio: **scritta sulla 101, letta sulla 110** | datetime | `Module6.bas:2199`; `Form1.frm:16123` | V |
| `Setup.NRep2..9`, `ARep2..9` | 101: nome e abilitazione dei reparti 2–9 (`NRep2 = 'Cards Collections'` attiva i ticket manuali/raccolte); 102: `NRep2` IP server attivo, `NRep3` IP secondario, `NRep4` secondi di commutazione (default 30); >110: nomi delle card | testo / bit | `Module1.bas:2385-2386, 2673-2689`; `FrmSetSql.frm:707-724` | V |
| `Setup.CRaw` | Lettura di card magnetiche non standard (dati raw) | bit | `frmsetSys.frm:7406-7410` | V |
| `Setup.VBase` | Valore base per il calcolo ticket/valore nei contatori | decimale | `FrmCont.frm:8015-8017` | V |
| `Setup.ConnOk` | Connessione al server riuscita (postazione); se falso il login va in modalità "senza connessione" | bit | `frmLogin1.frm:1406, 1597-1606` | V |

> **`Setup_Descriptions` contiene errori rispetto al codice.** `ScoMan`, `TotTick`, `Passw` hanno significati diversi; `N0`, `D1` (sincronismo) e `T0` super password stanno nella riga 110 e non nella 101; 110 `F0` è descritto come split screen ma `ModRilevamento` lo usa come "rilevamento forzato"; diverse voci sono **nomi di variabile** e non colonne (`MolPun` → `MdbSaveInt`, `TagRd` → `MagPremLoc`, `numcommEN` → `N2`, `Logging` → `Log`, `ImgRem`, `FTPDir`, `FtpAppL`, `FtpCranes` non esistono come colonne). Il dizionario non è letto da WinMT: viene solo creato vuoto (`ECL_database.cls:475-491`). **[V]**

### 3.3 `setup2`: chiavi

`setup2` è usata con `IdPost = 101` per i **parametri globali nuovi** (dal 2025) e con l'IdPost della postazione per i **parametri di postazione** (stampante, autodetect). `IdPost = 0` è usato per riconoscere il micro-totem ("Giallone"). La procedura `GetSetupAsTable` la ruota in una riga per postazione. **[V]**

| Chiave | IdPost | Significato | Valori | Evidenza | |
|--------|--------|-------------|--------|----------|---|
| `2NdScreenVersion` | 101 | Versione del secondo schermo cliente | `""` = V1, `V2` | `frmsetGen.frm:4912-4917`; `Module1.bas:1062` | V |
| `RitiroCard` | 101 | Ritiro della card abilitato | `enabled` / `disabled` (default) | `frmsetGen.frm:4919-4923` | V |
| `VipSubscriptionParams` | 101 | Abbonamento VIP | JSON `{enabled, model, amount, expirydate, subscriptiondurationmonths, activationdate}` | `frmsetGen.frm:4926-4964`; `Module1.bas:2765-2788` | V |
| `HardwareTicketsPolicy` | 101 | Politica di erogazione ticket hardware | JSON `{FlagDropTicketsIfCoin, FlagDropTickets}`, default 0/0 ("ELMAC") | `Module1.bas:1069-1083` | V |
| `flagDropTicketsForGold` | 101 | Ticket automatici per card Gold (letto dalla SP `scriviTicketsAutomatici`) | `true`/`false` | `ECL_database.cls:59-64` | V |
| `PosTcpConfig` | 101 | IP e porta del POS di rete | JSON `{ip, port}` | `ECL_database.cls:67-72` | V |
| `AvailablePosDevices` | 101 | Modelli POS disponibili (combo del setup) | JSON `[{key, value}]`, 0–7 | `ECL_database.cls:27-42` | V |
| `AvailableButtons` | 101 | Pulsanti abilitati | JSON `{nome: 0/1}` | `cls_setupV2.cls:430-475` | V |
| `ecs2mqttVer` | 101 | Versione di `ecl2mqtt` (scritta da ecl2mqtt **[D]**) | es. `2.36.0` | `FormMqtt.frm:310` | V |
| `NrColonnePrinter_<TypePrt>` | postazione | Colonne della stampante | intero, default 24 | `Module1.bas:3997-4001` | V |
| `SERIAL_AUTODETECT.DEVICE.<MT1…POS>` | postazione | Ultimo esito dell'autodetect | JSON `{deviceType, deviceName, portNumber, settings, found, emptyPort, response, lastDetectDate, lastError, extra1..3}` | `clsSerialAutoDetect.cls:188-199`; `clsSerialDetectResult.cls:128-145` | V |
| `SERIAL_AUTODETECT.EMPTY.COM<n>` | postazione | Porta senza periferiche | JSON come sopra con `emptyPort: true` | `clsSerialAutoDetect.cls:201-215` | V |
| `MICROTOTEM…` (valore) | 0 | Presenza di un micro-totem | `Valore LIKE 'MICROTOTEM%'` | `cls_setupV2.cls:142-194`; `Form1.frm:7896` | V |
| Altre (altre zone) | 101 | `BirthdayDefaultHours`, `BirthdayLimitHours`, `BirthdayFreeCharge`, `ImportoRicariche`, `IsRimborsoGettoni`, `EnableSellToken`, `DefaultNewPlayer`, `DEBOUNCE_DELAY_MS`, `AstoriaTimeout`, `PosTransactionLimit`, `RechargeTransactionLimit`, `MaxTentativiNonConfermati`, `PrizeHub*` | — | `grep GetSetupValue` | V |

### 3.4 Altre tabelle

| Colonna | Significato | Valori / codifiche | Evidenza | |
|---------|-------------|--------------------|----------|---|
| `Operatori.Id` | Identificativo | **0** amministratore di sistema (non modificabile, la sua password è la "password amministratore"); 1–999 operatori; **9999** "Galileo App" (creato con la sync); **≥ 1000** totem / Prize Hub (`TotemPrizes`) | `frmgesop.frm:606, 1116`; `Module1.bas:2722-2730`; `Module1.bas:8-9` | V |
| `Operatori.Livello` | Ruolo | **0** Amministratore, **1** Manager, **2** Operatore, **3** Supervisore | `frmgesop.frm:1192-1195`; `Module6.bas:189-420` | V |
| `Operatori.Password` | Password, offuscata `MTCry` (reversibile); minimo 4 caratteri al cambio; password predefinita scritta nel codice per i nuovi | testo | `frmLogin1.frm:1356-1373`; `frmgesop.frm:861, 939` | V |
| `Operatori.CodBar` | Barcode della card operatore (`CD`/`JV` + 9) usato per il login; svuotato alla disattivazione | testo(15) | `frmgesop.frm:647-676, 747`; `Form1.frm:14429` | V |
| `Operatori.T0` | UID della card **RFID ECL** dell'operatore | testo | `frmgesop.frm:860, 942`; `Form1.frm:11373` | V |
| `Operatori.Data` | Data/ora di **emissione della card magnetica**: scritta sulla card e confrontata al login (versione della card) | datetime | `frmgesop.frm:1320-1335`; `Form1.frm:12550` | V |
| `Operatori.F0` | **Crediti di servizio** abilitati (anche scritto sulla card RFID) | bit | `frmgesop.frm:868-872, 1006-1010`; `ECL_operatore.cls:134` | V |
| `Operatori.N0` | **Maschera delle abilitazioni**: 1 rimborsi, 2 omaggi, 4 azzeramento cassa totem, 8 ricariche (carico crediti), 16 visualizzazione movimenti totem, 32 emissione rimborso ticket. Nei sistemi non ECL valeva 0–3 (rimborsi/omaggi) | intero | `ECL_operatore.cls:212-228`; `frmgesop.frm:1078-1090` | V |
| `Operatori.Foto` | **Riusata:** JSON dei limiti giornalieri `{MaxRefundsPerDay, MaxFreeTicketsPerDay, MaxServiceCreditsRefundsPerDay}` convertito in `varbinary` | JSON | `ECL_operatore.cls:185-200` | V |
| `Operatori.Attivo` | Operatore attivo; la "cancellazione" lo porta a 0. Lo **scanner lo riporta a 1** se si legge il barcode | bit | `frmgesop.frm:746`; `Form1.frm:17239-17242` | V |
| `Operatori.NImp` | Codice impianto | intero | `frmgesop.frm:613` | V |
| `AuditLog.tipoaudit`, `action`, `extra_data` | Tipo di evento (`Access`, `DeviceStatus`), azione, JSON `{status, description}`. **WinMT non scrive mai** in `AuditLog`: la classe esiste ma non è istanziata | testo / JSON | `AuditLog.cls:33-80` | V |
| `Logs.IDPost`, `Data`, `LFile`, `Filename` | File di log della sessione della postazione, salvato in binario alla chiusura | — | `Module1.bas:3397-3424` | V |
| `Clienti.IdTel` | Id dell'utente dell'app, destinatario di push ed email | intero | `SendMsg.bas:14`; `Form1.frm:7770` | V |

---

## 4. Regole, calcoli e comportamenti notevoli

### 4.1 Configurazione caricata una volta e tenuta in memoria

Tutta la configurazione di `Setup` viene letta all'avvio in variabili globali (`valsets` e circa 40 variabili sciolte) e riscritta **per intero** a ogni salvataggio (`SaveSetPost` aggiorna l'intera riga 101 dal Master). Un cambio fatto da un'altra postazione non è visto finché non si riavvia; due Master o un salvataggio concorrente sovrascrivono le modifiche altrui. Il cambio di IdPost richiede il riavvio. **[V]** `Module1.bas:2917-3178`; `frmsetSys.frm:5856-5869`

### 4.2 Master e Slave

Il Master è la riga 101. Solo il Master vede e salva le opzioni globali, abilita la sincronizzazione, può cancellare archivi e fare pulizia. Le postazioni Slave salvano solo le proprie porte e periferiche. **[V]** `frmsetSys.frm:9132-9149`; `Module6.bas:215-221`

### 4.3 Permessi: cinque fonti

Il permesso effettivo di un operatore nasce da: `Operatori.Livello` (0–3); flag globali in `Setup` 101 per gli operatori (`Op*`) e per i manager (`MM*`, `HSM*`, `ManAdd`, `POMan`, `FornMan`, `OpAppL`, `InvPass`, colonne `F4`, `F5`); opzioni del Supervisore in `Setup.T4`; maschera `Operatori.N0` e limiti in `Operatori.Foto` (ECL); `Operatori.F0` (crediti di servizio). **[V]** § 3. Il nuovo sistema dovrà decidere un modello di ruoli e permessi unico.

### 4.4 Offuscamento `MTCry`

`EncPWord` trasforma ogni carattere ASCII 32–131 in due cifre (riga e colonna di una tabella 10×10) con prefisso `MTCry`; `DecPWord` lo inverte; senza prefisso restituisce il testo. È **reversibile senza chiave**. È usato per le password degli operatori, la super password, le credenziali dell'app web, la connessione al cloud e al DB ECL, la password Wi-Fi e i parametri nel registro di Windows. **[V]** `Module6.bas:736-790`; `ECL_database.cls:562-615`

### 4.5 Le "quattro password" di `Setup`

Le quattro colonne con *pass* nel nome **non sono password**: `Passw` contiene opzioni (`OpCaRem|UID card di setup`), `AdmPass` i parametri ECL, `PasswSM` e `InvPass` sono flag. I segreti veri stanno nei campi jolly, offuscati `MTCry`: `T0`–`T3` (101, console web dell'app), `T7` (101 cloud multi-locale, 102 DB ECL), `T8` (101 Wi-Fi ECL), `T0` (110 super password). **[V]** § 3.2

### 4.6 Licenza

La licenza abilita il **numero di utenti/postazioni** e alcuni **moduli** (split screen, 4 operatori, modo semplificato, Prize Hub, totem SQL, versione SQL); il codice impianto è legato alla chiave. In assenza di chiave basta `Setup` 110 `F1 = 1` e una stringa in `T1`: la licenza si attiva scrivendo sul DB. **[V]** `Module1.bas:1336-1400`

### 4.7 Super password e accessi nascosti

Esistono una super password (DB, con un valore di fallback scritto nel codice), un accesso "GodMode" con una sequenza di clic, una password di sincronizzazione scritta nel codice e due riquadri nascosti raggiungibili con sequenze di clic. **[V]** `frmLogin1.frm:1453-1458, 1707-1731`; `frmsetSys.frm:6811-6814, 8032-8055`; `frmsetGen.frm:6043-6070`

### 4.8 Multi-locale

Se `Setup.T6` (101) è valorizzato la sala è **multi-locale**: l'identificativo del cliente usato in `Vincite`, `Prenotaz`, `Tickets`, `Resi` diventa `Clienti.IdLong` invece di `IdContatto`, e i clienti totali sono letti dal cloud (`Setup.T7`). **[V]** `ModuleMultilocale.bas`; `Module1.bas:63-64`

### 4.9 Comunicazione con ecl2mqtt

WinMT comunica con il servizio `ecl2mqtt` in tre modi: **UDP broadcast** 51049 per la scoperta del server e della versione; **HTTP GET** su porta 58889 (`/eclcommand?command=…`, `/redundance/setprimary`) per comandi; **MQTT** 1883 solo come watchdog. I dati di business passano per il DB SQL condiviso. WinMT **non espone** un web server: `HttpService.ctl` è un client. **[V]** `cls_autodiscover.cls`; `HttpService.ctl`; `FrmSetSql.frm:543-548`

### 4.10 Periferiche

| Periferica | Configurazione | Protocollo | Evidenza |
|------------|----------------|-----------|----------|
| Mangiatickets 1–5 | porta `numcommMT1..5`, indirizzo `IdMT1..5`, reparto `NRepMT1..5` | seriale 9600 8N1, invio spontaneo di `?` | `clsSerialAutoDetect.cls:465-500` |
| Lettore banda magnetica | `numcommCR`, `CardReader`, `NTrack`, `CRaw` | 9600 8N1, comandi ESC (MSR) | `frmgesop.frm:1208-1216, 1330-1335` |
| Lettore RFID ECL | `N2` (porta) | 38400 8N1, comandi testuali ECL (`GetCodes`, `InitCard`, `SetWiFi`) | `frmsetSys.frm:6595-6749` |
| Barcode 1, barcode 2 (split screen), 4 barcode (4 utenti) | `numcommBR`, `MName` (2°), `PBRm0..3` | 9600 8N1, comandi ESC (laser, lettura) | `frmgesop.frm:679-688` |
| Stampante termica | `numcommPR`, `TypePrt`, `setup2.NrColonnePrinter_n` | ESC/POS (anche ESC/P2, TCP 9100) | `cls_Escp2Printer.cls` |
| POS | `N10`, `N11`, `N13`, `setup2.PosTcpConfig` | seriale 115200 (Amit, Ingenico) o TCP | `frmsetSys.frm:8260-8542` |
| 2° e 3° monitor | `SecMonX/Y`, `AbMon3`, `Mon3H/V`, `setup2.2NdScreenVersion` | video | `Module1.bas:316-317, 432-434` |
| Tastiera virtuale | `Multiuser` | — | `frmKeyB.frm` |
| Gettoniere / hopper | **non gestite da WinMT**: `clsCCTalkPort` (ccTalk) non è mai usata | — | `clsCCTalkPort.cls` |

---

## 5. Problemi rilevanti per il nuovo disegno

1. **`Setup` mescola quattro entità** in una tabella da 282 colonne: configurazione di sala (101 e parte della 102), configurazione di postazione (101–110), riga di servizio (110: licenza, sync, super password), raccolte card (> 110). Il significato delle colonne cambia con la riga e molte sono **riusate** per altro (`Passw`, `AdmPass`, `TotTick`, `ScoMan`, `MdbSaveInt`, `MagPremLoc`, `Multiuser`, `Mon3H`, `MisVCard`, `SyncRes`, `Foto` in `Operatori`). Nel nuovo modello: entità separate (Sala, Postazione/Dispositivo, Licenza, Raccolta card) e parametri tipizzati con ambito esplicito (sala / postazione / sistema).
2. **`Setup_Descriptions` non è affidabile** (§ 3.2): non può essere la base del nuovo dizionario senza revisione.
3. **Segreti reversibili e credenziali nel codice**: password operatori e console app, Wi-Fi, connessioni cloud ed ECL offuscate in modo reversibile; credenziali SMTP (due), MQTT, MDB, password di sync, super password di fallback, utente SQL predefinito e password predefinita degli operatori scritte nel codice. Nel nuovo sistema: hash per le password, vault per i segreti, nessuna credenziale nel client.
4. **Accessi privilegiati non tracciati**: super password, GodMode, riquadri nascosti, riattivazione di operatori via barcode. `AuditLog` esiste ma **WinMT non lo scrive**; il log è un file di testo salvato in `Logs`. Il nuovo sistema deve avere un audit strutturato degli accessi e delle modifiche di configurazione.
5. **Permessi distribuiti** su cinque fonti (§ 4.3): da ridisegnare come ruoli + permessi espliciti, con limiti per operatore tipizzati.
6. **Licenza modificabile dal DB** (riga 110) e legata a un dongle locale: nel cloud la licenza diventa un'entità del tenant/sala con moduli attivabili.
7. **Configurazione in memoria e salvataggi a riga intera**: niente versionamento, niente notifica alle altre postazioni, rischio di sovrascrittura. Con il cloud: configurazione versionata, distribuita via MQTT, letta dal server di sala.
8. **Identità della postazione** affidata al nome del computer in `MName` e a un numero di righe fisso (101–110): nel nuovo sistema serve un'anagrafica dei dispositivi con identificativo stabile (risponde anche al problema `TransCard.CodMac` di `db-04`).
9. **Multi-locale** cambia la chiave del cliente nelle tabelle di movimento (`IdContatto` ↔ `IdLong`): il nuovo modello deve usare un solo identificativo globale del cliente.
10. **Anagrafiche macchina** (`Manuf`, `Type`, `Machines`) scritte sul cloud o in locale a seconda della rete, con `id = max + 1`: collisioni possibili. Servono identificativi globali (UUID) e un'autorità unica.
11. **Bug del controllo email di sincronizzazione** (`D3` scritto sulla 101, letto sulla 110). Da non riprodurre; il monitoraggio della sync va spostato lato server.
12. **Senza server SQL la postazione non funziona.** Il requisito "sala senza cloud" è soddisfatto perché il DB è in sala, ma la postazione dipende dal server di sala; il failover al secondario è manuale.

---

## 6. Domande aperte per il team

1. Chi scrive `Setup` riga 110 (`F1`, `T1` licenza software, `D1` ultimo sincronismo, `D3`) e `setup2.ecs2mqttVer`? `ecl2mqtt`, l'agente di sincronizzazione, uno strumento di installazione?
2. La **cancellazione automatica degli ordini non riscossi** (`ScoMan`, `TotTick`) è eseguita da un altro componente (EcsNet, HQ, una SP)? In WinMT non c'è chi la esegua.
3. `MSiteMode` (`N7`, "niente transazioni card con locale off-line") è letto da qualche altro componente (ecl2mqtt, totem)? In WinMT no.
4. `Setup_Descriptions`: chi la mantiene e dove viene usata? Va corretta (§ 3.2) o abbandonata?
5. Le varianti **Astoria, Albarella, Gold** (`N14`) e i moduli di licenza `Easy`/`WinBet`, `TotemSql`, `Jolly Key` sono ancora in uso? Quali vanno portati nel nuovo sistema?
6. **Ric25/Pre25**: su quale norma si basa la registrazione fiscale con ricevuta dei premi sopra soglia? È ancora richiesta? È voluto che `Pre25` faccia anche da soglia Gold/Silver dei premi?
7. `DataIni`, `DataEnd` ("Estremi dell'operazione") e `NConc` hanno ancora un significato (concorso a premi, autorizzazione)? Le date non sono usate da nessuna logica.
8. Il ruolo **Supervisore** (livello 3) è usato nelle sale? Quale matrice di permessi serve al nuovo sistema (Amministratore, Manager, Operatore, Supervisore, totem, app)?
9. `AuditLog`: chi lo scrive (app web, Laravel, ecl2mqtt)? In produzione ha righe?
10. Il servizio web Elmac per push ed email ai clienti è ancora attivo? Con quale contratto?
11. L'API HTTP di `ecl2mqtt` (porta 58889, `eclcommand`, `redundance/setprimary`) è documentata? Quali comandi esistono?
12. Il failover al server secondario è usato in produzione (`GALILEOSERVER-1/2` in `db-06`)? Con quali tempi?
