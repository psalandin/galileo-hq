# Galileo HQ — ecl2mqtt 02: accesso al DB di WinMT, parte 1 (`DBwinmt.bas` righe 1–7716)

**Stato:** bozza · **Responsabile:** Piero · **Aggiornato:** 2026-10-25

**Collegati:** [`ecl2mqtt-00-mappa.md`](ecl2mqtt-00-mappa.md) (mappa e sintesi trasversale). Nel testo, «zona NN» indica il documento ecl2mqtt NN.

Legenda: **V** = verificato nel codice; **D** = dedotto. Percorsi relativi a `legacy/ecl2mqtt/` salvo diversa indicazione. Nessun segreto è riportato: dove il codice ne contiene uno è scritto "credenziale nel codice (file:riga)".

---

## 1. Moduli coperti

| Modulo | Righe | Ruolo |
|---|---|---|
| `DBwinmt.bas` (StaticCode) | 1-7716 (109 Sub su 222, da `Process_Globals` a `leggiClienteByEMail`) | Strato di accesso diretto, via JDBC e pool c3p0, al **database di sala `WinMtSqlDb`** (lo stesso di WinMT) e, per alcune tabelle ECL, al DB "coinless" (`CoinlessDB` o `WinMtSqlDB`). Contiene sia letture (cache macchine, clienti, saldi) sia **scritture sulle tabelle di WinMT** (`Clienti`, `Tickets`, `TransCard`, `EcsMacchine`, `EcsModuli`, `EcsDati`, `Setup`, `setup2`, `Operatori`). |

Il modulo non ha logica propria di trasporto: viene chiamato da `Main` (MQTT, timer), dagli handler HTTP (`eclcommand`, `eclservice`, `APIHandler`, `FlutterKioskHandler`, `TicketsHandler`, `AppTicketsHandler` → `AppPlayerHandler`/`AppServiceHandler`), da `clsElmacAPI` (topic `ElmacAPI` dal cloud) e dalle pagine WebSocket del backoffice. **V** (grep dei chiamanti `DBwinmt.<Sub>` su tutto il progetto).

**Transazioni: nessuna** in tutto l'intervallo. Nessun `BeginTransaction`, `BEGIN TRAN`, batch o `CallProcedure` tra le righe 1 e 7716 **V**. Ogni Sub prende una connessione dal pool, esegue una o più istruzioni in autocommit e la chiude.

---

## 2. Flussi

Peso secondo `analisi-01` § 1: S anagrafica/consultazione semplice; M più tabelle o regole non banali; L logica complessa, varianti, periferiche o saldi.

| Id | Flusso | Descrizione | Trigger/attore | Peso | Tabelle (R/W/D/DDL) | Evidenza | Equivalente WinMT | Rapporto con WinMT |
|---|---|---|---|:-:|---|---|---|---|
| E02-01 | Avvio e salute della connessione al DB di sala | Crea il pool JDBC su `WinMtSqlDb` (login unico, cifratura senza verifica certificato), lo dimensiona (5-50, checkout 10 s), sceglie il DB "coinless", prova 15 volte la connessione e poi lancia la migrazione dello schema (`CheckDbMigration`, `createBEConfig`, `updateBEConfig`, parte 2). Ping ogni 30 s | `Main.AppStart` (`ecs2mqtt.b4j:445-447`), timer `inviaOrario` (`ecs2mqtt.b4j:3681`) | M | DDL indiretto: `BEConfig` (CREATE/ALTER, parte 2) | `DBwinmt.bas:27-142`, `144-184`, `94-104`; credenziale nel codice (`DBwinmt.bas:62-63`) | W02-01, W04-25 | **doppione** della gestione schema all'avvio (entrambi alterano il DB) |
| E02-02 | Connessione al DB cloud | Inizializza `cloudpool`: con `settings.Connected = 1` sul server di sala (prefisso linked server `[elmaccloud].`), altrimenti diretto su `winmt.elmaccloud.com:1433`, DB `WinMtSqlDb`, utente di sincronizzazione. Usato dalla parte 2 (multisala, `sp_last_trans`) | `Main.verificaMasterSlave` (`ecs2mqtt.b4j:665`) | S | — | `DBwinmt.bas:192-220`; credenziali nel codice (`DBwinmt.bas:203-204`, `213-214`); uso `DBwinmt.bas:7875,7885` | W01-20 (connessione cloud `"DB" & NImp`) | complementare |
| E02-03 | Cache e scheda delle macchine | Legge le macchine installate da `vs_eclmacchine` + firmware, e le tiene in memoria (`Main.elencoMacchineInstallate`, chiave `device`, o `__nodevice__<CodMac>`); legge una macchina per device/MAC/CodMac con ultimi contatori da `CoinlessDecodedData`, decodifica erogatori; info macchina per la BE; riepilogo dashboard | AppStart, `eclcommand` `jelenco`/`Refresh`, pagine web, deviceprogrammer, MQTT `ElmacECL/GetMachineInfo/<device>` | M | R: `vs_eclmacchine`, `EcsMacchine`, `Type`, `CoinlessDecodedData`, `ecl_SchedeFirmware`, `EcsModuli`, `Setup` (NomeLocale) | `DBwinmt.bas:511-639`, `643-830`, `326-458`, `223-324`, `1674-1717`, `6197-6251` | W08-03/05 (scrittura config) | complementare (WinMT scrive, B4J legge) |
| E02-04 | Registrazione e assegnazione dei moduli BE | Upsert (`MERGE`) di `EcsModuli` per MAC o per device, con pulizia dei MAC duplicati e IP salvato in `T0` come JSON; assegnazione modulo→macchina con generazione di `Modu` e `device` sintetici; lettura IP e info BE da `BEConfig`; verifica "pending" (`F0 = 1`) al `BeIsReady` | MQTT `BeIsReady`/setup (`mqttMessages.bas:896,974`), pagine `alldevices`, `InstallazioneNuovaMacchina`, `MacchineConfigurate`; `eclservice` (identifica il chiamante per IP) | L | W: `EcsModuli` (I/U/D), `EcsMacchine` (U `Modu`, `device`); R: `BEConfig`, `ecl_SchedeFirmware` | `DBwinmt.bas:1023-1152`, `1587-1671`, `832-888`, `901-1022`, `3807-3872` | W08-07 ("EcsModuli scritta dal servizio") | complementare; regola di `device` = **doppione** di W08-03 |
| E02-05 | Stato online/offline/setup e pending | Aggiorna `device_status`, `lastseen`, `is_online`, contatori on/off (rispetta `OOO`), `F0` (stato aggiornamento); su online cancella le righe firmware dello stesso device con altro MAC | MQTT `ElmacECL/…/<mac>/status`, setup (`ecs2mqtt.b4j:1425,1435`; `mqttMessages.bas:976,985`), deviceprogrammer/biprogrammer, `eclcommand resetoffonlinecounter` | M | W: `EcsMacchine`; D: `ecl_SchedeFirmware` | `DBwinmt.bas:1155-1314`, `1259`; `resettaOnlineOffline` senza chiamanti `2364-2387` | W08-05 (WinMT pone `F0 = 1`) | complementare |
| E02-06 | Happy hour / special time | Ogni 40 s, per le macchine online nella fascia di `vs_CoinlessSpecialTimes`, invia `setHappyHourV2` (prezzi HH per livello, `coinval`, `ValPar`×moltiplicatore) e pone `is_happyhour = 1`; a fine fascia `resetHappyHour` (per device o broadcast) e `is_happyhour = 0`. Al riavvio delle sottoscrizioni riallinea tutte le macchine; HH all'arrivo online di una macchina | timer `controlloMacchine` 40 s (`ecs2mqtt.b4j:672,3101`), `sottoscriviTopic` (`802-803`), MQTT online, `OutOfService`, pagina `specialtimes` | L | R: `vs_CoinlessSpecialTimes`, `EcsMacchine`, `EcsModuli`; W: `EcsMacchine.is_happyhour` | `DBwinmt.bas:1895-2362`, `1195-1229` | W04-17 | complementare (WinMT definisce, B4J applica) |
| E02-07 | Armageddon | Operazione una tantum (guardia in `setup2` 101 `ArmageddonEseguito`): cancella tutto lo storico `EcsDati` tranne l'ultima riga per macchina, azzera `In1..In16`, opzionalmente **cancella tutta `TransCard`**, blocca la registrazione (`NoRec`), mette in pending e riavvia ogni BE. Le versioni vecchie `armageddon`/`miniarmageddon` sono raggiungibili solo da `funzioni.scatenaArmageddon`, mai chiamata | pagina web `/ws/armageddon` (superadmin); endpoint HTTP vecchio disabilitato (`eclcommand.bas:455-465`) | L | D: `EcsDati`, `TransCard`; U: `EcsDati`, `EcsMacchine` (`F0`, `T0` via `setNoRec`); W: `setup2` | `DBwinmt.bas:1415-1584`, `1316-1413` | W05-21, W08-10 (cancellazioni) | **solo B4J** (affine a W05-21, regola diversa) |
| E02-08 | Primo invio quotidiano dei contatori | Per le macchine online senza record contatori oggi in `CoinlessDecodedData`: chiede `leggi_contatori`; per i firmware "AST" (mobile) simula il record duplicando l'ultimo movimento | timer 40 s (`ecs2mqtt.b4j:3100`) | M | R: `EcsMacchine`, `CoinlessDecodedData`, `ecl_SchedeFirmware` | `DBwinmt.bas:1719-1783` | — | solo B4J |
| E02-09 | Blacklist verso le BE | Compone le **ultime 21** card bloccate (unione di `Clienti` con `D1`, `CoinlessLogEventiBlacklist`, `CoinlessClonedCards`, normalizzate a 16 caratteri) e la pubblica *retained* su `ElmacECL/BlackList` se cambiata | rimborsi con operatore disabilitato (`ecs2mqtt.b4j:1201`), MQTT `BlackList`, HTTP `jrefreshBlacklist` (chiamato da WinMT), `/api`, kiosk | M | R: `Clienti`, `CoinlessLogEventiBlacklist`, `CoinlessClonedCards` | `DBwinmt.bas:1785-1893` | W01-14 passo 3, W02-08 | complementare (WinMT blocca e chiede l'invio; B4J costruisce la lista), regola di selezione **diversa** |
| E02-10 | Informazioni card e saldo per BE/servizi | Restituisce nome, `Credito`, ticket, `N1`, stato (`F1`) di una card per `T0`/`CodBar`; tre varianti con **formule di saldo diverse** (§ 5); proprietario card; JSON cliente per `getCardInfo` | MQTT `playerInfo`/`playerInfoExtended` (`ecs2mqtt.b4j:4257,4369`), `ElmacECL/Refounds/<device>`, `send_client` (`1722`); HTTP `getCardInfo`, `jverifyCardOwner`, `eclservice` | L | R: `Clienti`, `TransCard` | `DBwinmt.bas:2390-2656`, `4711-4747`, `5167-5250` | W04-04, W01-14, winmt-04 § 4.3 | **doppione** (calcolo saldo) con regola diversa |
| E02-11 | Accredito e-ticket dal buffer | A fine sessione (payload `0` sul topic buffer) attribuisce i ticket bufferizzati: recupero al boot sull'ultimo proprietario, compleanno (tutti al festeggiato o scarto), promozione Gold a costo 0 (scarto), modalità `tiketlessMode` Online (tutti alla prima card del buffer: `Clienti.Tickets += Σ`, riga `Tickets` per card) od Offline (solo riassegnazione); poi svuota il buffer | MQTT `ElmacECL/Buffers/<device>/Tickets/Cards/<card>` → `DBcoinless.salvaTicketsBuffer` (`DBcoinless.bas:1128-1138`) | L | R: `CoinlessDataBuffer`, `TransCard`, `Setup.T6`, `Clienti`; W: `Clienti.Tickets` (U), `Tickets` (I), `CoinlessDataBuffer` (U/D) | `DBwinmt.bas:2657-3001` | W08-14 (lato DB), W02-14, W05-01 | **doppione** dell'accredito punti, regola diversa |
| E02-12 | Ticket automatici per partita | Alla partita autorizzata con card: ticket = `round(costo/RappCreditiCent) × setup2.TickPerTok` se configurato, altrimenti `CntrLet15` della macchina; `Clienti.Tickets +=` e riga `Tickets` `MangiaT = 8256` | `clsGestioneCliente*.CanPlay` (MQTT `send_client`, `comdevice`) | M | R: `setup2`, cache macchine; W: `Clienti.Tickets`, `Tickets` | `DBwinmt.bas:6059-6084`, `3003-3080` | SP `scriviTicketsAutomatici` (W08-14, esterno) | **doppione** con regola diversa |
| E02-13 | Ticket manuali su card | `Clienti.Tickets +=` e riga `Tickets` `MangiaT = 64`, `T1` = postazione | `/api` (`APIHandler.bas:334`), kiosk (`FlutterKioskHandler.bas:1278,1455,1476`), `kioskConfig.bas:212`, `clsGestioneClienteSala.bas:246,257` | M | W: `Clienti.Tickets`, `Tickets` | `DBwinmt.bas:3082-3159` | W02-17, W05-09, W01-17 | **doppione**, regola diversa |
| E02-14 | Sovrascrittura contatori BI | Prepara il comando `scriviContatori` dall'ultima riga `EcsDati`. **Senza chiamanti** | — | S | R: `EcsDati` | `DBwinmt.bas:3161-3201` | — | solo B4J (morto) |
| E02-15 | Modalità ticketless di sala | Legge `Setup(101).F9/F10`; costruisce il comando `imposta_ticketless` (in memoria `Main.ticketlessmode`) e la stringa `F9F10` che all'avvio sovrascrive `settings.StatusBiTicketMode`/`ForceBiTicketMode` ("vince il database") | AppStart (`ecs2mqtt.b4j:454-455,558`), `impostaTicketlessMode` (`3652`), `ecl_cmds.bas:381,659`, E02-16, E02-17 | S | R: `Setup` | `DBwinmt.bas:460-508`, `3203-3241` | W04-01, W10-03 (scrittura F9/F10) | complementare |
| E02-16 | Programmazione completa della macchina | Dalla riga `EcsMacchine` + ultima `EcsDati` compone wifi/MQTT, contatori (il DB riscrive i contatori della BI), prezzi per livello (`CreditiRichiestiPerTipoCard`, bonus disabilitato per `Tipo = 17`), relè, memoria interna BI, macchine a tempo (fisso/variabile), ticketless; tre formati (`StandardMode`, `CompactMode` `SetTotVal`, `CardMode`); toglie `NoRec`. `SetCreditiMobile` è senza chiamanti e non restituisce nulla | deviceprogrammer (coda aggiornamenti), `eclcommand jsetFromWinmt`/`jgetForWinmt` (WinMT), MQTT `ElmacECL/Server/command/jsetFromWinmt`, pagine web | L | R: `EcsMacchine`, `EcsDati`; U: `EcsMacchine.T0`/`F0` (via `setNoRec`) | `DBwinmt.bas:3356-3805`, `3243-3352` | W08-05 | complementare (WinMT scrive config + `F0`, B4J traduce e invia); semantica colonne **diversa** (§ 4b) |
| E02-17 | Verifica configurazione BI | Confronta i valori che la BI riporta (`GetValBI`) con `EcsMacchine` e con la bitmask erogatore ricostruita (`CntrLet8` + bit 4/5 da `CntrVal16` + bit 6/7 da `Setup F10/F9`); per BI < 21 con BE ≥ 131.110.0020 salta il controllo | MQTT `ElmacStatusBI` (`mqttMessages.bas:762`) | M | R: `EcsMacchine`, `ecl_SchedeFirmware`, `Setup` | `DBwinmt.bas:3874-4004` | — | solo B4J |
| E02-18 | Contatori, ultimi dati e diagnostica ingressi | Elenco contatori = ultima lettura `CntrLetN` + impulsi da ultimo incasso (`fn_calcola_impulsi_periodo`); ultimi dati trasmessi vs `EcsDati`; descrizione ingressi (`vs_macchine`); stato macchine 12 h pubblicato su `ElmacECL/Server/macchine`. Due Sub diagnostiche senza chiamanti (una con `#TempResult` mai creata) | HTTP `jelenco2`, `jgetrawdata` (`eclcommand.bas:504,509`), MQTT `ElmacECL/Server/command` "macchine" (`ecs2mqtt.b4j:989-992`), pagina `MacchineConfigurate` | M | R: `vs_ingressi_contatori`, `EcsMacchine`, `Incassi`, `vs_CoinlessLastCountersValue`, `EcsDati`, `vs_macchine`, `vs_eclmacchine`, `fn_dati_grafico_giornaliero`, `fn_EcsDatiGiornalieri` | `DBwinmt.bas:4008-4223`, `5937-6005`, `6448-6709` | W08-15, W08-20 | **doppione** della misura "valore contatore" (stessa funzione SQL, **D**) |
| E02-19 | Card operatore per le BE | Pubblica gli hash SHA-256 delle card operatore attive (*retained* `ElmacECL/operatori/<device>`); classifica una card (0 non operatore, 1 con crediti di servizio `F0`, 3 senza); totali giornalieri dell'operatore (rimborsi, crediti di servizio, ticket manuali) | MQTT `GetOperatori` (`ecs2mqtt.b4j:977,1862`), `Refounds` (`1120-1121`), `AppServiceHandler.bas:444` | M | R: `Operatori`, `TransCard`, `EcsMacchine`, `Tickets` | `DBwinmt.bas:4225-4383`; sale di hash nel codice (`DBwinmt.bas:4237`) | W10-07 (card operatore) | complementare |
| E02-20 | Login al backoffice web | Login con nome + password (decodifica reversibile `sicurezza.DecPWord`) e login con QR = `Operatori.CodBar` | `LoginPage.bas:30,35,63` (`/ws/LoginPage`) | M | R: `Operatori` | `DBwinmt.bas:6086-6195` | W10-06, W10-07 | **doppione**, regola diversa (§ 5) |
| E02-21 | Postazione B4J in `Setup` e operatori virtuali | Crea (MERGE) la riga `Setup` `PRIZEHUB01\|` con `IDPost = MAX+1` e `NImp` della 101; crea l'operatore virtuale `Prizehub1` (cognome `Prizehub`, `Id = count+1001`, livello 2); risolve operatori per nome; legge l'amministratore (id 0) con password per l'autodiscovery UDP | `WINMtConfig.bas:293-296`, kiosk (`FlutterKioskHandler.bas:779-942`, `kioskConfig.bas:74,93`), `DBcoinless.bas:3709`, `Autodiscover.bas:249` | M | W: `Setup` (I), `Operatori` (I); R: `Setup`, `Operatori` | `DBwinmt.bas:6766-6991`; `WINMtConfig.bas:289` | W02-02, W10-02, W06-31 | **doppione** (identificazione postazione, operatori distributori), regola diversa |
| E02-22 | Cassa mobile: ricarica, bonus, saldo, listino | Inserisce in `TransCard` la ricarica (`NImp 2`) o il bonus (`NImp 6`) della cassa mobile con `CodMac = 'CASSA-MOBILE'`, `T0` = sala, `N0` = progressivo card; accredita i ticket bonus della scaletta (via `aggiungiScontrinoDaAppDiServizio`, parte 2); calcola il saldo cassa dell'operatore (`NImp 2`, `D0` nullo); calcola il bonus da `Setup.T10` | MQTT `ElmacECL/TransCards/<device>/{cassaMobile, ricaricaCard, ricaricaBonus}` (`ecs2mqtt.b4j:1451-1500`); HTTP `jgetListino`, `clsElmacAPI.bas:1099,1148` | L | W: `TransCard` (I), `Tickets` (I, parte 2); R: `Clienti`, `Operatori`, `Setup` | `DBwinmt.bas:4384-4431`, `4481-4709` | W02-06, W02-18, W04-12, W04-13 | **doppione** (registrazione movimento, scaletta bonus) con differenze |
| E02-23 | Rimborsi e crediti di servizio | Rimborso (`NImp 8`, `CodMac = 'ECL-SERVICE'`) dall'app di servizio; "partita rimborsata" (`NImp 12`, valore 0, `ValoreFinale` e `N0` copiati dall'ultima riga) quando una card operatore avvia una partita gratuita | `AppServiceHandler.bas:325`; MQTT `ElmacECL/Refounds/<device>` (`ecs2mqtt.b4j:1099-1180`) | M | W: `TransCard` (I); R: `Clienti`, `Operatori`, `EcsMacchine`, `Setup` | `DBwinmt.bas:4433-4479`, `6712-6760` | W04-15 (lettura `NImp 12`), W03-25 | complementare per `NImp 12` (**B4J è lo scrittore che WinMT cercava**); **doppione** per il rimborso |
| E02-24 | Anagrafica e profilo cliente dall'app | Aggiorna l'anagrafica dal JSON (SQL composto, con controllo email duplicata); promuove `TipoCard`; legge il profilo privacy da `Clienti.Foto`; serializza il cliente in JSON V1 | MQTT `ElmacAPI` → `clsElmacAPI` (`627,687,774-855,1022,181-1207`) | M | W: `Clienti` (U); R: `Clienti` | `DBwinmt.bas:4748-5165` | W03-03, W04-23 | **doppione** (modifica anagrafica, livello) |
| E02-25 | Credenziali e token app del cliente | `EMailIsCertified`, password app **in chiaro**, token in `UserName` (dato dall'app in V1, `NEWID()` in V2; con password casuale a 6 cifre se mancante) | `clsElmacAPI.bas:357-524` | M | W: `Clienti` (U) | `DBwinmt.bas:5563-5744` | W03-04 (solo lettura) | complementare (WinMT non scrive `UserName`) |
| E02-26 | Blocco/sblocco card dall'app giocatore | `Clienti.Abilita = 0/1` per `CodBar` o `T0` | `AppPlayerHandler.bas:234,266` (`LOCKCARD`/`UNLOCKCARD`, `/app/*`) | S | W: `Clienti.Abilita` | `DBwinmt.bas:5532-5561` | W02-23, W01-02, W01-11 | **doppione** con significato in conflitto (§ 5) |
| E02-27 | Storico movimenti del cliente | Tre letture di `TransCard` con classificazione per `NImp` (frasi italiane, chiavi inglesi per il totem, importi × `coinMultiplier` o in centesimi) | `AppServiceHandler.bas:180,194`, `clsElmacAPI.bas:1283-1289`, `FlutterKioskHandler.bas:360` | M | R: `TransCard` | `DBwinmt.bas:5252-5530` | W04-07 | **doppione** (consultazione movimenti) |
| E02-28 | Lettura cliente completa con saldi | Legge il cliente per `T0`/`CodBar`/email in JSON (`FOR JSON AUTO`) con crediti/bonus calcolati da `TransCard` e ultimo `ValoreFinale`/`N0`; ramo `GamePark = 1` senza borsellino bonus; `IdLong` o `IdContatto` secondo `myWinMtConfig.multilocale` | 16 chiamanti (`AppPlayerHandler`, `AppServiceHandler`, `clsElmacAPI`, `clsGestioneCliente*`, kiosk, `TicketsHandler`, `PartnerHandler`, `GestioneEtickets`) | L | R: `Clienti`, `TransCard` | `DBwinmt.bas:7144-7716` | W04-04, winmt-04 § 4.3 (`ECL_cliente.cls`) | **doppione** del calcolo saldo |
| E02-29 | Valuta e moltiplicatori da `AdmPass` | Decodifica `Setup(101).AdmPass` (rapporto cent/valuta, nome unità, rapporto cent/crediti, etichette) in variabili globali; **riscrive `AdmPass`** dalla pagina `DbConfig`. Se la lettura fallisce l'applicazione **termina** (`ExitApplication2(-10)`) | AppStart (`ecs2mqtt.b4j:556`), `eclcommand` `jelenco`/`Refresh`, `DbConfig.bas:158,269` | M | R/W: `Setup.AdmPass` | `DBwinmt.bas:5745-5931`, `5826` | W04-01, W10-04 | **doppione** (configurazione ECL) |
| E02-30 | Impulsi per partita ed etichette BE | Legge `ValIn3`, `TipoIn3`, `ValPar`, ingressi, `CntrLet10`, `val_*` per comporre l'etichetta prezzo della BE (es. "1 PLAY 2 TOKENS") | `Main.DecodificaLabelCoinReaderBE` (`ecs2mqtt.b4j:4019`) | S | R: `EcsMacchine` | `DBwinmt.bas:6007-6057` | — | complementare |
| E02-31 | Creazione e duplicazione di macchina | Lettura iniziale in `EcsDati` (valori dati o zero, `IF NOT EXISTS`); duplicazione `INSERT…SELECT` con nuovo `CodMac`, `Modu = MAX+1`, `device` dal device massimo; `cercaCodmacDuplicato` senza chiamanti | `ecs2mqtt.b4j:3387` (`assegnaBEaCodMac`), `MacchineInsetup.bas:609`, `InstallazioneNuovaMacchina.bas:665`, `MacchineConfigurate.bas:519` | M | W: `EcsMacchine` (I), `EcsDati` (I/D) | `DBwinmt.bas:6253-6446` | W08-03 passo 4, W08-06 | **doppione**, regola quasi uguale |
| E02-32 | Premi per PrizeHub e app | Cerca un premio per codice slot nella colonna `PDis<n>` (n = ultima cifra di `PRIZEHUB01`) o per `Codice` | `TicketsHandler.bas:303` (`/tickets/*`), `AppPlayerHandler.bas:181` | S | R: `Premi` | `DBwinmt.bas:6996-7091` | W06-31, W07-08 | complementare |

Utility senza flusso: `CInt` (`DBwinmt.bas:5933`), `IdOrIdlong` (`7144`), `LogCmdVuoto`/`SafeSubString2` (`3779-3805`), `ecsmoduliT0toJson/fromJson` (`890-900`). **V**

### Dettaglio dei flussi L e dei doppioni

**E02-04 Moduli BE.** `aggiornaModuloEcs` (`DBwinmt.bas:1023-1152`): se il device è `0z0z0` la chiave del `MERGE` è il MAC, altrimenti il device (`ShortAd`), e "vince il device": il MAC del modulo viene sovrascritto. Prima del MERGE, se un MAC compare più volte, **cancella tutte** le righe con quel MAC (`1112-1119`). `id = MAX(id)+1` dentro il MERGE (`1045`). `assegnaModuloAMacchina` genera `Modu = MAX(Modu)+1` se nullo e `device = <CodiceCliente>z<CodiceImpianto>z<Modu>` se vuoto, poi copia `Modu` e `device` in `EcsModuli.N0`/`ShortAd` (`1603-1625`). **V**. Stessa formula di WinMT per il device (db-08 `EcsMacchine.device`), ma WinMT aggiunge +1000 per le macchine a tempo, B4J no **V**/**D**.

**E02-06 Happy hour.** La fascia attraversa la mezzanotte (`dalle > alle`) (`1998-1999`); se nessuna riga è attiva e lo stato in memoria è sconosciuto rilegge la configurazione (`2041-2044`); lo stato globale `Main.HappyHourIsRunning` è solo in memoria. I prezzi inviati sono `perc_*` della vista (prezzi, non percentuali, come in db-08); `coinval` vuoto vale 50 (`2021`). Le macchine in aggiornamento firmware non ricevono l'HH (`2024-2025`). `aggiornaStatoHappyHourSuDb` ha un controllo di versione inerte: `minor` è la costante `"0"`, quindi aggiorna sempre (`1212-1220`). `is_timeplay` non è gestito (`1255`, codice commentato `2289-2301`). **V**

**E02-07 Armageddon.** Irreversibile e senza transazione: le DELETE ed UPDATE sono istruzioni separate con errori solo loggati (`1524-1545`); la guardia `ArmageddonEseguito` è scritta **dopo** (`1576`), quindi un errore a metà lascia dati cancellati e operazione ripetibile. **V**

**E02-10 / E02-28 Saldi.** Vedi § 5 (doppione 1).

**E02-11 E-ticket.** Con card `0000000000000000` (transazione al boot) il proprietario è l'ultima card del buffer o dell'ultima `TransCard` sulla macchina (`2657-2701`). In modalità `Online` tutti i ticket del device vanno alla **prima** card presentata (`2872-2877`), poi viene inserita una riga `Tickets` per ogni card del buffer (`2914-2938`): poiché il buffer è stato prima riassegnato tutto alla prima card (`2893-2897`), le righe vanno a quella card **D**. In modalità `Offline` (default di `config.bas:38`) il buffer è solo riassegnato e poi cancellato (`2958-2975`, `2982-2990`): nessuna scrittura su `Clienti`/`Tickets` **V**; si deduce che il saldo ticket resti sulla card **D**. Con compleanno attivo: modalità `B` tutti al festeggiato, `C` scarto (`2798-2829`); con `flagDropTicketsForGold` e promozione attiva, card Gold con prezzo Gold 0 → scarto (`2833-2863`). La stessa logica esiste anche in `GestioneEtickets.bas` (`52`, `134`): possibile doppione interno a B4J **D**.

**E02-16 Programmazione.** Il DB è il master dei contatori: alla riprogrammazione la BI riceve gli `In1..In9` dell'ultima `EcsDati` (`3497`). Macchine a tempo (`is_timeplay`): `CntrLet11` = durata unità (s), `CntrLet12` = tempo gratuito, `CntrLet13` = moltiplicatore minimo; `CntrLet13 = 0` → tempo fisso ("lettino") (`3514-3547`). `hostname` = `CodMac`, `wallmode = 1` (`3695-3697`). **V**

**E02-22 Cassa mobile.** Differenze da `AddTransCard` di WinMT (winmt-04 § 4.3): B4J **non aggiorna `Clienti.Credito`** dopo l'inserimento (`4417-4419`); `CodMac` fisso `'CASSA-MOBILE'` (il parametro `codicemacchina` è ignorato, `4400-4408`); `F0 = 0` sempre (terza convenzione rispetto a db-08 § 2.2); `Data = getdate()` invece del testo `dd/mm/yyyy`; `T0` = `myWinMtConfig.Nimp` letto come numero, quindi senza zeri iniziali (WinMT: 4 cifre) **D**; il bonus scrive `ValoreCassa = importo` (`4504-4511`), mentre per WinMT `ValoreCassa` è il contante incassato **V**/**D**. `getListino` ripete l'algoritmo `CalcBonus` di WinMT (scaglione più alto, ripetuto finché c'è capienza) ma scorre `T10` dall'ultima coppia alla prima, quindi presuppone soglie ordinate in modo crescente (`4673-4690`) **V**/**D**.

---

## 3. Interlocutori

### (a) Topic MQTT (tutti sul broker **main**, via `Main.inviaComandoECL`/`inviaComandoECLretained`/`mqtt_main.Publish2`)

| Topic | Dir. | Payload | Controparte | Evidenza |
|---|---|---|---|---|
| `ElmacECL/<device>` | out | `setHappyHourV2`, `resetHappyHour`, `reboot`, `leggi_contatori` | BE | `DBwinmt.bas:1956,2029,2071,2136,1563,1772` |
| `ElmacECL` | out | `resetHappyHour` broadcast | tutte le BE | `DBwinmt.bas:2097` |
| `ElmacECL/BlackList` | out, retained QoS 1 | lista ≤ 21 card | tutte le BE | `DBwinmt.bas:1890` |
| `ElmacECL/ReplyMachineInfo/<device>` | out | JSON `CodMac`, `NomMac`, `NomeLocale` | BE | `ecs2mqtt.b4j:961-973` |
| `ElmacECL/operatori/<device>` | out, retained | hash card operatori | BE | `ecs2mqtt.b4j:975-978`, `1860-1865` |
| `ElmacECL/<device>/cassaMobile` | out | `{stato, saldo}` | cassa mobile (BE/app) | `ecs2mqtt.b4j:1464-1500` |
| `ElmacECL/Server/macchine` | out | JSON stato macchine 12 h | cloud/monitor (il nome `InviaMessaggioSulCloud` pubblica in realtà sul broker main) | `DBwinmt.bas:5994`; `ecs2mqtt.b4j:3992-3995` |
| `ElmacECL/GetMachineInfo/<device>`, `GetMachineInfo/<device>` | in | — | BE | `ecs2mqtt.b4j:961,1854` |
| `ElmacECL/GetOperatori/<device>`, `GetOperatori` | in | — | BE | `ecs2mqtt.b4j:975,1860` |
| `ElmacECL/Refounds/<device>` | in | `{opCardId, playerCardId}` | BE (card operatore) | `ecs2mqtt.b4j:1099-1206` |
| `ElmacECL/TransCards/<device>/<cmd>` | in | `{operatore, cliente, importo, saldo, progressivo}` | cassa mobile | `ecs2mqtt.b4j:1451-1500` |
| `ElmacECL/Buffers/<device>/Tickets/Cards/<card>` | in | numero ticket (0 = chiusura) | BE | `ecs2mqtt.b4j:1080-1096` |
| `ElmacECL/…/<mac>/status`, topic di setup | in | stato | BE | `ecs2mqtt.b4j:1292-1436`; `mqttMessages.bas:970-985` |
| `ElmacECL/Server/command` | in | `macchine`, `jsetFromWinmt` | WinMT/cloud | `ecs2mqtt.b4j:989-1012` |
| `ElmacAPI/…` | in | chiamate API | cloud/app clienti → `clsElmacAPI` | `ecs2mqtt.b4j:912-932` |
| `ElmacStatusBI`, `BeIsReady` | in | `GetValBI`, boot | BI/BE | `mqttMessages.bas:755-762,890-900` |

### (b) Endpoint HTTP/WebSocket che raggiungono questo codice

| Endpoint | Auth | Consumatore | Sub |
|---|---|---|---|
| `/eclcommand?command=…` (`jelenco`, `jelenco2`, `jgetrawdata`, `jgetListino`, `jverifyCardOwner`, `jrefreshBlacklist`, `Refresh`, `jsetFromWinmt`, `jgetForWinmt`, `getCardInfo`, `jUpdateCreditiRichiestiPerTipoCard`, `resetoffonlinecounter`) | nessuna (D: l'endpoint vecchio di Armageddon è stato disabilitato proprio per questo, `eclcommand.bas:456-458`) | **WinMT** (HTTP `:58889/eclcommand`, winmt-08 W08-07) | E02-03, 09, 10, 16, 18, 22, 29, 05 |
| `/eclservices/*` | identificazione del chiamante **per IP** tramite `BEConfig` (D) | BE/servizi | `GetDeviceInfoFromIP`, `GetClienteByCard` |
| `/api/*`, `/kiosk/*`, `/tickets/*`, `/app/*`, `/partner/*`, `/hub/*` | dei rispettivi handler (altre zone) | totem Flutter, app giocatore/servizio, PrizeHub, partner | E02-09, 13, 21, 23, 26, 27, 28, 32 |
| `/ws/LoginPage`, `/ws/armageddon`, `/ws/DbConfig`, `/ws/Dashboard`, `/ws/MacchineInstallate`, `/ws/MacchineInsetup`, `/ws/InstallazioneNuovaMacchina`, `/ws/alldevices`, `/ws/specialtimes`, `/ws/testmode` | sessione del backoffice | operatore web | E02-03, 04, 06, 07, 20, 29, 31 |

### (c) Chiamate in uscita

| Destinazione | Uso | Evidenza |
|---|---|---|
| SQL Server di sala, DB `WinMtSqlDb`, porta 1433 fissa, `encrypt=true;trustServerCertificate=true`, login unico | tutto il modulo | `DBwinmt.bas:56-64` |
| DB "coinless": `CoinlessDB` se manca `SlaveIp` o `MasterIp`, altrimenti `WinMtSqlDB`; `WinMtSqlDB` anche se esiste l'impostazione `coinlessServer` (il suo valore è ignorato) | `ecl_SchedeFirmware`, `CoinlessDecodedData`, `CoinlessDataBuffer`, funzione `split` | `DBwinmt.bas:34-51`. Esiste una seconda variabile omonima in `DBcoinless` (`DBcoinless.bas:24-35`), usata nelle stesse query (`346`, `552`, `2743`): le due possono divergere **D** |
| Nomi di DB fissi in query a tre parti: `WinMtSqlDB.dbo.clienti`, `WinMtSqlDB.dbo.tickets`, `WinMtSqlDb.dbo.vs_CoinlessLastCountersValue` | e-ticket, ticket, diagnostica | `DBwinmt.bas:2745,2761,2875,3022,3037,3116,4129` |
| SQL Server cloud `winmt.elmaccloud.com:1433` / linked server `[elmaccloud]` | `cloudpool` (parte 2) | `DBwinmt.bas:192-220` |
| UDP autodiscovery | `GetAdminOperator` fornisce la password (offuscata) dell'operatore 0, che `Autodiscover.publishSlaveServer` invia in broadcast insieme all'indirizzo del server SQL | `DBwinmt.bas:6950-6991`; `Autodiscover.bas:248-262` |
| File | nessuno in questa zona | — |

---

## 4. Dati

### (a) Oggetti usati

| Oggetto | Operazioni | Sub principali |
|---|---|---|
| `EcsMacchine` | R; U (`device_status`, `lastseen`, `is_online`, on/offlinecount, `F0`, `is_happyhour`, `Modu`, `device`); I (duplicazione) | E02-03/04/05/06/16/17/30/31 |
| `EcsModuli` | R; I/U (`MERGE`); D (MAC duplicati); U (`N0`, `ShortAd`) | E02-04 |
| `EcsDati` | R; I (lettura zero o data); D (storico, duplicazione); U (azzeramento) | E02-07/14/16/18/31 |
| `Clienti` | R; U (`Tickets`, anagrafica, `TipoCard`, `Abilita`, `EMailIsCertified`, `Password`, `UserName`) | E02-09/10/11/12/13/24/25/26/28 |
| `Tickets` | I (MangiaT 1, 64, 8256); R | E02-11/12/13/19 |
| `TransCard` | I (`NImp` 2, 6, 8, 12); R (saldi, storico); D (tutta, Armageddon) | E02-07/10/19/22/23/27/28 |
| `Setup` | R (101: `F9`, `F10`, `T6`, `T10`, `AdmPass`, `NomeLocale`, `NImp`); U (`AdmPass`); I (riga `PRIZEHUB01\|`) | E02-15/21/22/29 |
| `setup2` | R/W `ArmageddonEseguito`; R `TickPerTok` | E02-07/12 |
| `Operatori` | R; I (`Prizehub1`) | E02-19/20/21/22/23 |
| `Premi` | R (`PDis<n>`, `QDis<n>`, `Codice`) | E02-32 |
| `Type`, `Incassi` | R | E02-03/18 |
| `BEConfig` | R (JSON `BeInfo`, `BiConfig`); DDL in parte 2 | E02-04 |
| `ecl_SchedeFirmware` | R; D (righe con stesso device e altro MAC) | E02-03/04/05/17 |
| `CoinlessDecodedData` | R (ultimi contatori, prima trasmissione del giorno) | E02-03/08 |
| `CoinlessDataBuffer` | R/U/D | E02-11 |
| `CoinlessLogEventiBlacklist`, `CoinlessClonedCards` | R | E02-09 |
| Viste: `vs_eclmacchine`, `vs_CoinlessSpecialTimes`, `vs_ingressi_contatori`, `vs_macchine`, `vs_CoinlessLastCountersValue` | R | E02-03/06/18 |
| Funzioni: `fn_calcola_impulsi_periodo`, `fn_dati_grafico_giornaliero`, `fn_EcsDatiGiornalieri`, `split` (DB coinless) | R | E02-18/31 |

### (b) Colonne con significato nuovo o diverso da db-08

| Colonna | Uso in B4J | Rispetto a db-08 | Evidenza | Cert. |
|---|---|---|---|:-:|
| `EcsModuli.ShortAd` | **device MQTT** (`1z2z9`), chiave del MERGE e della join con `EcsMacchine.device` | **contraddice db-08** ("IP del modulo EcsNet") | `DBwinmt.bas:1074,1618`, `989` | V |
| `EcsModuli.T0` | JSON `{"ip":"…"}`, ultimo IP della BE | non in db-08 | `DBwinmt.bas:890-931`, `1056` | V |
| `EcsModuli.D0`, `Abil`, `id` | data dell'ultimo aggiornamento; 1 alla creazione; `MAX+1` | non in db-08 | `DBwinmt.bas:1039-1045` | V |
| `EcsMacchine.T0` | JSON `{valorepiatto, statoBI, errBI, BISwap, NoRec, BISwapStep}` (scritto da `setNoRec`, parte 2, chiamato da E02-07 ed E02-16) | **contraddice db-08** (valore piatto \| lunghezza contascatti) | `DBwinmt.bas:10796-10819`; chiamate `1521`, `3470` | V |
| `EcsMacchine.CntrLet16` | n. di impulsi per tick della gettoniera (`cnt_inp_coin`) | non in db-08 | `DBwinmt.bas:3411`, `3906`, `3951-3952` | V |
| `EcsMacchine.CntrLet9` | in programmazione e verifica BI = impulsi per tick del lettore banconote (`cnt_inp_banc`); in `leggiMacchina` = "Tipo erogatore 2" | **contraddice db-08** (bitmap erogatore 2) e contraddice sé stesso | `DBwinmt.bas:3412`, `3907`, `710-717` | V |
| `EcsMacchine.ValIn3`, `ValIn4` | in `leggiMacchina`/`SetCreditiMobile` = `cnt_inp_coin`/`cnt_inp_banc` (min 1) | doppio significato rispetto a CntrLet16/CntrLet9 usati per la stessa grandezza | `DBwinmt.bas:686-687`, `3286-3287` | V |
| `EcsMacchine.CntrLet13`, `CntrLet14` | default 50 e 400 se NULL; `CntrLet14` descritto come "distanza in ms tra due buchi" | db-08: default 70; `CntrLet14` = "durata ticket" | `DBwinmt.bas:691-692`, `3942-3946` | V |
| `EcsMacchine.CntrLet8` | bit 0-2 erogatore; per BI ≥ 25 i bit 4/5 vengono da `CntrVal16` e i bit 6/7 da `Setup.F10/F9` (la sala vince sulla macchina) | coerente con db-08, ma con sovrascrittura della politica ticketless dalla sala | `DBwinmt.bas:3966-3979` | V |
| `EcsMacchine.CntrVal16` | NULL trattato come 0 (nessuno scarico) | db-08: NULL = default di sala; qui il default di sala non è applicato | `DBwinmt.bas:3910`, `3435` | V/D |
| `EcsMacchine.CntrVal10..15` | moltiplicati × 100 prima dell'invio ai relè | db-08: secondi | `DBwinmt.bas:3429-3434` | V |
| `EcsMacchine.Tipo = 17` | disabilita il bonus sulla BE (`DisableBonus`) | db-08: tipo gestito come gru | `DBwinmt.bas:3408`, `3285` | V |
| `EcsMacchine.ValPar` | × `currecyMultiplier` = `coinval` inviato alla BE | coerente | `DBwinmt.bas:3406` | V |
| `EcsMacchine.is_happyhour`, `device_status`, `lastseen`, `is_online`, `onlinecount`, `offlinecount` | scritti da B4J; `device_status` ∈ Online/Offline/Setup/OOO, `OOO` protetto | db-08 li dava "scritti dal servizio" con certezza D: ora **V** | `DBwinmt.bas:1246-1277`, `2144` | V |
| `EcsMacchine.F0` | 1 = pending, letto al boot della BE; scritto anche da B4J (`impostaStatoAggiornamento` con valori di stato) | db-08: 1 pending, azzerato dal servizio; B4J vi scrive anche altri stati | `DBwinmt.bas:1168-1176`, `841`, `693` | V/D |
| `TransCard.CodMac` | `'CASSA-MOBILE'`, `'ECL-SERVICE'`; per `NImp 12` il **codice macchina** con `WinMt = 1` | **contraddice db-08** (con `WinMt = 1` è il nome della postazione) | `DBwinmt.bas:4408`, `4456`, `6739` | V |
| `TransCard.NImp 12` | partita gratuita avviata dalla card operatore, `ValoreOperazione = 0`; il valore è ricostruito in lettura da `EcsMacchine.val_silver/100` | db-08 lo dà come "crediti di servizio rimborsati"; WinMT non sapeva chi lo scrive (winmt-04 domanda 1) | `DBwinmt.bas:6739`, `4339` | V |
| `TransCard.NImp 15` | etichettato "BONUS TRASFERITI" e sottratto dal bonus | db-08: "Storno" | `DBwinmt.bas:5291`, `5488`, `7264` | V |
| `TransCard.N0` | per `NImp 12` è **copiato** dall'ultima riga: due righe con lo stesso progressivo | db-08: progressivo anti-replay | `DBwinmt.bas:6739` | V |
| `TransCard.F0` | sempre 0 | db-08 § 2.2: due convenzioni; questa è una terza | `DBwinmt.bas:4413`, `4461`, `4506`, `6739` | V |
| `TransCard.ValoreCassa` | = importo anche per il bonus (`NImp 6`) | db-08: contante incassato | `DBwinmt.bas:4504` | V |
| `Tickets.MangiaT` | 1 per e-ticket dal buffer (bit "contato da mangiaticket Galileo"); 8256 = 64 + 8192 per i ticket automatici; 64 per i ticket manuali | 8192 in db-08 = "punti da app": i ticket automatici finiscono nei rapporti dei punti da app; i manuali di WinMT sono 4, non 64 | `DBwinmt.bas:2768`, `3044`, `3123` | V |
| `Tickets.NRep = 8`, `Oper = 10000`, `NImp = 0`, `F1 = 1`, `T1` = device o postazione, `DataOut = NULL`, `Id = 0` | valori fissi delle righe scritte da B4J | `NRep 8` in db-08 è l'ottavo reparto; `Oper 10000` non documentato | `DBwinmt.bas:2761-2781` | V |
| `Tickets.NumTrans` | `secondi dall'inizio dell'anno + 100000000` | WinMT e la SP: cifra finale dell'anno × 10^8 + 1 + secondi; **formula diversa**, e righe nello stesso secondo hanno lo stesso numero | `DBwinmt.bas:2770`; `scriviTicketsAutomatici.sql:47` | V |
| `Clienti.UserName` | token app (V1 dall'app, V2 `NEWID()`) | db-08: "non scritto da WinMT"; nuovo significato | `DBwinmt.bas:5658`, `5696`, `5730` | V |
| `Clienti.Password` | password app in chiaro; creata casuale a 6 cifre | coerente con db-08 (in chiaro) | `DBwinmt.bas:5620`, `5731` | V |
| `Clienti.Abilita` | 0 = card bloccata dal giocatore via app | db-08: lock di postazione (0 = in carico a una cassa) | `DBwinmt.bas:5544-5547` | V |
| `Clienti.F1` | letto come `statocard` e `IsBlackListed` | db-08: flag con più significati | `DBwinmt.bas:2576`, `5190` | V |
| `Clienti.Bonus × 100` = "gold", `Clienti.Tickets` = "silver" | campi JSON verso app | coerente con la variante Golden | `DBwinmt.bas:5137-5138`, `7204-7205` | V |
| `Operatori.Id` 1001+ con `Cognome = 'Prizehub'` | operatori virtuali creati da B4J (`count(id tra 1001 e 1009) + 1001`) | db-08: `Nome = 'TotemPrizes'`, Id 1001-1010; possibile collisione | `DBwinmt.bas:6846-6867` | V/D |
| `Operatori.CodBar` | credenziale unica per il login web via QR | db-08: barcode di login; qui senza password | `DBwinmt.bas:6178` | V |
| `Setup` riga `MName = 'PRIZEHUB01\|'` | postazione B4J, `IDPost = MAX(IDPost)+1` | db-08: 101-110 postazioni, oltre 110 raccolte card | `DBwinmt.bas:6789-6798`; `WINMtConfig.bas:289` | V |
| `Setup(101).T6` | non vuoto → `IdLong` | regola diversa da `fn_idcliente` (contiene `\|`) e da WinMT (`#` = disattivato) | `DBwinmt.bas:2764`, `4405`; `sql/codice-db/prod/applicativo/funzioni/fn_idcliente.sql` | V |
| `Premi.PDis<n>`, `QDis<n>` | ricerca del premio per codice slot del PrizeHub 1 | db-08: "gestione superata, vuote" | `DBwinmt.bas:7013-7016`; `TicketsHandler.bas:299` | V |
| `setup2(101).ArmageddonEseguito` | JSON {operatore, eseguitoIl, cancellaTransCard, macchineAccodate, macchineTotali} | non in db-08 | `DBwinmt.bas:1426`, `1576` | V |
| `setup2(101).TickPerTok` | ticket per gettone di partita | non in db-08; nessuno lo scrive nel progetto B4J | `DBwinmt.bas:6070` | V |
| `BEConfig.BeInfo`, `BiConfig`, `Macaddress`, `DetectionDate` | JSON con RSSI, IP, versioni BE/BI, memoria EEPROM; parametri BI (moltiplicatori, impulsi, fori ticket, drop) | tabella non in db-08 | `DBwinmt.bas:948-993` | V |
| `ecl_SchedeFirmware` (`macaddress`, `device`, `tipoFirmware`, `detectedVersion`, `bidetectedVersion`, `requestedVersion`, `status`) | anagrafica firmware delle schede | non in db-08 | `DBwinmt.bas:346`, `3821-3836` | V |

### (c) DDL eseguito dal codice

- **In questa zona nessun `CREATE`/`ALTER`/`DROP` diretto.** **V** (grep delle righe 1-7716).
- `TestConnectionToDB` lancia ad ogni avvio `CheckDbMigration` (rileva la versione dello schema da `INFORMATION_SCHEMA`) e, secondo la versione, `createBEConfig` (`CREATE TABLE BEConfig` se manca) e `updateBEConfig` (`ALTER TABLE BEConfig ADD DetectionDate`) (`DBwinmt.bas:130-138` → `12770`, `13559`, `13593`). Dettaglio nella zona della parte 2. **V**
- `verificaConnesioniLogicheMacchina` usa `#TempResult` e `DROP TABLE #TempResult` senza crearla: query rotta, Sub senza chiamanti (`DBwinmt.bas:6625-6670`). **V**

### (d) Stato fuori dal DB che fa da dato

| Stato | Contenuto | Evidenza |
|---|---|---|
| `Main.elencoMacchineInstallate` | cache di tutte le macchine (prezzi, parametri, `TicketsAutomaticiPerPartita`); `BonusTickets` decide i ticket da qui, non dal DB | `DBwinmt.bas:634-635`, `6061-6077` |
| `Main.macchina` | "macchina in canna" globale, sovrascritta da più flussi | `DBwinmt.bas:225`, `341` |
| `Main.ticketlessmode`, `settings.StatusBiTicketMode`/`ForceBiTicketMode` | comando ticketless di sala | `DBwinmt.bas:490-492`; `ecs2mqtt.b4j:454-455` |
| `Main.HappyHourIsRunning`, `Main.is_busy` | stato globale HH e semaforo del timer | `DBwinmt.bas:1977`, `2032`, `2080`, `2329-2341` |
| `Main.BlackListPayload` | ultima blacklist inviata, per il confronto | `DBwinmt.bas:1887-1889` |
| `currecyMultiplier`, `coinMultiplier`, `currency`, `LabelMoneta`, `LabelGettoni`, `admPass`, `Main.myWinMtConfig.RappCentValuta/RappCreditiCent/EcoinCurrency` | parametri valuta da `AdmPass` | `DBwinmt.bas:5774-5817`, `5911-5914` |
| `Main.myWinMtConfig.IdOperatore`, `nomemacchina`, `Nimp`, `multilocale` | identità della postazione B4J e regola multisala | `DBwinmt.bas:6787`, `6898`, `7145` |
| `settings` (`SqlServer`, `SlaveIp`, `MasterIp`, `coinlessServer`, `Connected`, `GamePark`, `tiketlessMode`, `PrioritaBonus`, `ForceDecimalDisplay`, `ForceLabelGettoni/Moneta`, `Primario`) | configurazione che cambia le regole sui dati (es. `GamePark = 1` elimina il borsellino bonus nei saldi; `tiketlessMode` decide se i ticket vanno nel DB) | `DBwinmt.bas:31-35`, `194`, `2867`, `3338`, `5787-5813`, `6781`, `7169` |
| `dbversion` | versione dello schema rilevata, in memoria | `DBwinmt.bas:24`, `130-138` |

### (e) Sovraccarichi semantici

- `EcsMacchine.CntrLet9` è al tempo stesso "tipo erogatore 2" e "impulsi per tick del lettore banconote" (§ 4b). `cnt_inp_coin`/`cnt_inp_banc` vengono da `ValIn3`/`ValIn4` in lettura e da `CntrLet16`/`CntrLet9` in programmazione. **V**
- `EcsMacchine.CntrLet11..13` hanno due significati secondo `is_timeplay` (ms per i giochi, secondi e moltiplicatori per le macchine a tempo). **V**
- `TransCard` con `WinMt = 1`: `CodMac` è postazione, etichetta fissa o macchina secondo chi scrive. **V**
- `Tickets`: B4J aggiunge un quinto ruolo, "lotto ticketless da gioco", distinto solo da `F1 = 1`/`Oper = 10000`/`NRep = 8`. **V**
- `Clienti.UserName` = token; `Clienti.Abilita` = lock di postazione per WinMT, blocco da app per B4J. **V**

---

## 5. Doppioni e sovrapposizioni con WinMT

1. **Saldo crediti/bonus del cliente (E02-10, E02-28): quattro formule.**
   - WinMT (winmt-04 § 4.3): crediti = Σ `NImp` (0,1,2,11,13,14) **con `WinMt = 1`** − Σ (NULL, 10, **18**); bonus = Σ (6,8,9,16) − `ValoreBonus` partite − `NImp 15`.
   - B4J `getCliente`/`leggiClienteByCodbarOrT0`/`leggiClienteByEMail`/`GetClienteByCard`: come WinMT ma **senza filtro `WinMt = 1` e senza sottrarre `NImp 18`** (`DBwinmt.bas:7245-7266`, `7415-7416`, `5212-5213`). **V**
   - B4J `richiediInformazioniCard(Extended)`: crediti = Σ (0,1,2,13,14) − Σ NULL; bonus = Σ 6 − `ValoreBonus` (`2413-2414`, `2525-2528`). Il credito restituito alla BE è però `ValoreFinale`/`RappCentValuta` (`2444`) o, nella versione estesa, **il valore che la card stessa ha dichiarato** (`2557-2565`). **V**
   - Join: `richiediInformazioniCard`, `richiediTransazioneConCard` e `GetClienteByCard` legano `TransCard.IdCli` a `IdContatto` anche in multisala (`2418`, `2610`, `5218`); le letture di E02-28 usano `IdLong` o `IdContatto` secondo `myWinMtConfig.multilocale` (`7144-7146`). Le scritture usano una terza regola su `Setup.T6` (`4405`). In multisala il saldo letto per la BE risulterebbe 0 **D**.
2. **Accredito ticket su card (E02-11, E02-12, E02-13)** vs WinMT W02-14 e SP `scriviTicketsAutomatici`. WinMT tratta `Clienti.Tickets` come copia ricalcolata dai lotti (W02-16); B4J la **incrementa** senza transazione, e nel ramo buffer senza `ISNULL` (`2742`, `2872`: un `NULL` resta `NULL`). Lotti con `MangiaT`, `NRep`, `Oper`, `NumTrans` diversi da WinMT e dalla SP (§ 4b). **V**
3. **Ticket automatici: due implementazioni attive.** La SP `scriviTicketsAutomatici` è chiamata da `decodifica_record` a ogni partita (`sql/codice-db/prod/applicativo/procedure/decodifica_record.sql:390`) e aggiorna anche `EcsDati.In5/In15/In9`; B4J `BonusTickets` accredita all'autorizzazione della partita (`CanPlay`) e non tocca `EcsDati`. Se per la stessa partita girano entrambe, il cliente riceve i ticket **due volte** **D** (da verificare in produzione). Differenze di regola: B4J supporta `TickPerTok` e non applica la regola "Gold a costo 0 nessun ticket" della SP; la SP usa `fn_idcliente`, B4J `Setup.T6`. **V**
4. **Ticket manuali (E02-13)** vs W02-17/W05-09: WinMT `MangiaT = 4` e `T0 = 'MANUAL TICKETS'`, B4J `MangiaT = 64` (bonus) e `T1` = postazione: nei rapporti i manuali del totem compaiono come bonus. **V**
5. **Movimenti di valore della cassa mobile (E02-22)** vs `AddTransCard` (W02-06): B4J non aggiorna `Clienti.Credito`, usa `CodMac` fisso, `F0 = 0`, data `datetime`. `getListino` = `CalcBonus` di WinMT (W02-18), stessa regola salvo l'ordine delle soglie. **V**/**D**
6. **Rimborso (E02-23)** vs varianti WinMT (W03-25 Astoria): stessa `NImp 8`, `CodMac` diverso. **V**
7. **Login (E02-20)** vs W10-06/W10-07: WinMT filtra `Attivo = 1` e `id < 1000`; `UserLogin` cerca per `Nome` senza filtro `Attivo` e, nonostante il commento ("riservato al superadmin"), il controllo `id = 0 / livello = 0` è **commentato**: qualunque operatore con nome e password entra (`DBwinmt.bas:6119`, `6128`). Il login QR non chiede password. **V**
8. **Identificazione postazione (E02-21)** vs W02-02/W10-02: entrambi creano righe `Setup` con `MAX+1`; B4J lo fa con nome fisso `PRIZEHUB01`. Operatori distributori: WinMT `TotemPrizes` 1001-1010, B4J `Prizehub` `count+1001`. **V**
9. **Duplicazione macchina (E02-31)** vs W08-06: stessa regola (`Modu = MAX+1`, device dal device massimo, `DataInst` oggi, stato NULL, lettura zero). B4J calcola il prefisso del device come `MAX(device)` testuale (`6371-6373`): con device di lunghezza diversa il massimo testuale può non essere l'ultimo **D**. **V**
10. **Configurazione ECL in `AdmPass` (E02-29)** vs W04-01/W10-04: entrambi scrivono la stessa stringa a 8 campi. **V**
11. **Anagrafica da app (E02-24)** vs W03-03: B4J non azzera `EMailIsCertified`/`HasTelephoneNumberCorrect` quando cambiano email o cellulare (WinMT sì, db-08). **V** (assenza nel codice `4965-5065`)
12. **`Clienti.Abilita` (E02-26)** vs W02-23/W01-11: WinMT rimette `Abilita = 1` al rilascio della postazione: una card bloccata dal giocatore via app verrebbe sbloccata dalla cassa **D**.
13. **Blacklist (E02-09)** vs W01-14: WinMT blocca scrivendo `Clienti.F1/T1/D1` e i log; lo sblocco (`sp_rimuovidabl`) azzera `D1` ma non i log, mentre B4J include **tutti** i log storici e i cloni: una card sbloccata può continuare a essere inviata alle BE; il limite di 21 card fa uscire dalla lista le card bloccate più vecchie. `CoinlessCards.BlackList` (antifrode) non è inclusa (la versione commentata la includeva, `1807-1810`). **V**/**D**
14. **Schema all'avvio (E02-01)** vs W02-01/W04-25: entrambi i programmi modificano lo schema al proprio avvio. **V**

---

## 6. Problemi e rischi

- **Nessuna transazione** in operazioni multi-istruzione sui saldi (E02-11: UPDATE `Clienti` + INSERT `Tickets` + DELETE buffer; E02-12/13: UPDATE + INSERT; E02-22: INSERT `TransCard` + ticket bonus; E02-07: cancellazioni massive). Ogni errore è solo loggato e il flusso prosegue. **V**
- **Cancellazioni irreversibili**: Armageddon (`DELETE FROM TransCard` senza filtro, storico `EcsDati`), pulizia dei MAC duplicati in `EcsModuli`, cancellazione di `ecl_SchedeFirmware` per device. **V**
- **Concorrenza**: `MAX+1` per `EcsModuli.id`, `EcsMacchine.Modu`, `Setup.IDPost`, `Operatori.Id` senza lock; `NumTrans` uguale nello stesso secondo; `leggimacchineIsBusy` e `Main.is_busy` sono flag non atomici. **V**/**D**
- **SQL composto a stringa con dati esterni**: device da topic MQTT in `InformazioniMacchina` (`1690`), `ultimiDatiTrasmessi` (`4133-4141`), `verificaSpecialTime` (`1995`); card operatore da payload MQTT in `cassaMobile` (`4597`); codice in `leggiMacchina` (`754-761`) e `SovrascriviContatori` (`3178`); anagrafica in `updateClienteByJson` (solo raddoppio degli apici). **V**
- **Sicurezza**: credenziali del DB di sala e del cloud nel codice (`62-63`, `203-204`, `213-214`), login `sa`; `trustServerCertificate=true`; sale dell'hash operatori nel codice (`4237`); password app dei clienti in chiaro (`5620`); password admin (offuscata reversibile) inviata in broadcast UDP (`6950-6991` → `Autodiscover.bas:248-262`); `UserLogin` senza il controllo superadmin e senza `Attivo` (`6128`); `/eclcommand` senza autenticazione raggiunge scritture (E02-05, E02-16, E02-29). **V**
- **Dipendenza dal DB per funzionare**: senza DB all'avvio l'applicazione esce (`ecs2mqtt.b4j:447-450`); se la lettura di `AdmPass` fallisce in qualunque momento (anche su `Refresh` HTTP) l'applicazione termina (`5826`). I 15 tentativi di connessione sono consecutivi perché lo `Sleep` è commentato (`120`). Il motore B4J non è autonomo dal DB di sala. **V**
- **Bug e incoerenze**: `leggiPremioDaPrizehub` non chiude la connessione se il codice è `0` o vuoto (`7001-7008`); `verificaOperatore` prende la connessione fuori da `Try` (`4326`); `getCoinMultiplier` non chiude la connessione nel ramo d'errore prima di uscire (`5823-5826`); `BonusTickets` è chiamato con un parametro chiamato `codmac` ma cerca la cache per device (`clsGestioneCliente.bas:161`; `DBwinmt.bas:6061`) **D**; `macchinaFromMap` mette `bills = coins` (`293`, `374`). **V**
- **Codice morto** (nessun chiamante): `resettaOnlineOffline`, `SovrascriviContatori`, `SetCreditiMobile`, `cercaCodmacDuplicato`, `verificaConnessioniFisicheMacchina`, `verificaConnesioniLogicheMacchina`, `ClosePool`, `CInt`; `armageddon`/`miniarmageddon` raggiungibili solo da Sub mai chiamate. **V**

---

## 7. Domande aperte per il team

1. Per la stessa partita girano sia `decodifica_record` → `scriviTicketsAutomatici` sia `DBwinmt.BonusTickets`? In produzione si vedono lotti `MangiaT 8256` doppi (uno con `Oper 0`, uno con `Oper 10000`)?
2. In modalità `tiketlessMode = Offline` (default) i ticket del buffer restano solo sulla card? Chi li riporta poi nel DB?
3. Quale regola multisala è quella giusta: `Setup.T6` non vuoto (B4J scritture), `T6` con `|` (`fn_idcliente`), `myWinMtConfig.multilocale` (B4J letture), o quella di WinMT con `#`?
4. Il saldo di riferimento del cliente per il nuovo sistema: `ValoreFinale` dell'ultima riga, la somma per `NImp` (quale delle quattro formule) o il valore che dichiara la card? `NImp 15` è "storno" o "bonus trasferiti"?
5. `CntrLet9` e `CntrLet16`: qual è oggi il significato reale nelle sale (erogatore 2 o moltiplicatore banconote)? Chi scrive `CntrLet16`, visto che WinMT (db-08) non lo documenta?
6. `TickPerTok` in `setup2`: chi lo imposta e in quali sale è usato?
7. Le righe `Setup` create da B4J (`PRIZEHUB01|`) con `IDPost` > 110 si sovrappongono alle raccolte card? E gli operatori `Prizehub` a `TotemPrizes`?
8. `Clienti.Abilita`: il blocco della card da app deve sopravvivere al rilascio in cassa? Va separato dal lock di postazione?
9. La blacklist inviata alle BE deve contenere solo le card attualmente bloccate? Il limite di 21 è un vincolo del firmware?
10. Armageddon: è stato eseguito in qualche sala? Con `cancellaTransCard`? (`setup2` 101 `ArmageddonEseguito`.)
11. `NImp 12`: il valore dei crediti di servizio va registrato nella riga (oggi 0) invece di essere ricostruito dal prezzo Silver attuale della macchina?
12. La password dell'operatore 0 in broadcast UDP: quali client la usano e possono farne a meno?
