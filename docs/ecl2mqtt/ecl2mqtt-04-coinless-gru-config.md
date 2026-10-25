# Galileo HQ — ecl2mqtt 04: DB coinless ed ECL, gru, configurazione del DB

**Stato:** bozza · **Responsabile:** Piero · **Aggiornato:** 2026-10-25

**Collegati:** [`ecl2mqtt-00-mappa.md`](ecl2mqtt-00-mappa.md) (mappa e sintesi trasversale). Nel testo, «zona NN» indica il documento ecl2mqtt NN.

Fonte: `legacy/ecl2mqtt/` v2.39.55. I percorsi senza cartella sono relativi a `legacy/ecl2mqtt/`; `sql/…` e `docs/…` sono relativi alla radice del repository.
Legenda: **V** = verificato nel codice · **D** = dedotto. Credenziali: mai riportate.

---

## 1. Moduli coperti

| Modulo | Righe | Sub | Ruolo |
|---|---:|---:|---|
| `DBcoinless.bas` | 5.892 | 115 | Accesso "coinless": telemetria ECL grezza, partite e ricariche su `TransCard`, catalogo firmware e immagini, provisioning delle schede, traduzioni BE, screen builder, log, whitelist UID, linked server cloud `elmaccloud` (wizard nuova macchina e nuovo modello) |
| `DBCrane.bas` | 1.254 | 30 | Classe del magazzino gru: slot 1–3, carico, scarico, vincita, valore medio, vincite automatiche dai contatori `EcsDati` |
| `DBCloud.bas` | 9 | 1 | Modulo vuoto (solo `Process_Globals`) [V `DBCloud.bas:8-10`]. L'accesso al cloud sta in `DBwinmt.cloudpool` e nelle query a 4 parti di `DBcoinless` |
| `DbConfig.bas` | 271 | 6 | Pagina WebSocket `/ws/DbConfig` (solo superadmin): modifica `dbsettings.txt` e la stringa `Setup(101).AdmPass` |
| `syncConfig.bas` | 102 | 8 | Pagina WebSocket `/ws/syncconfig`: pulsanti di replica sala↔cloud di firmware, immagini e lingue (via `DBwinmt.replicaTabelle*`) |

---

## 2. Flussi

Pesi secondo `analisi-01` § 1 (S semplice, M più tabelle o regole, L complesso, transazionale, con periferiche o con molte varianti).

| Id | Flusso | Descrizione | Trigger/attore | Peso | Tabelle (R/W/D/DDL) | Evidenza | Equivalente WinMT | Rapporto |
|---|---|---|---|:-:|---|---|---|---|
| E04-01 | Connessione al DB "coinless" | Sceglie il database (`CoinlessDB` o `WinMtSqlDB`), crea il pool c3p0 (5–50 connessioni, checkout 10 s) e fa 15 tentativi. Se fallisce il processo termina | Avvio (AppStart) | S | — | `DBcoinless.bas:14-121`; `ecs2mqtt.b4j:438-443` [V] | W02-01 | solo B4J (parallelo) |
| E04-02 | Acquisizione record ECL (`send_client`) | Scrive il messaggio grezzo della BE in `CoinlessDati`, salvo i device con flag `BISwap`/`NoRec`. Il trigger `decodifica_flusso` verifica l'HMAC e chiama `decodifica_record` → `CoinlessDecodedData` → `EcsDati`; per le card: `Clienti.Credito`, `CoinlessTransazioniCards`, `TransCard`, blacklist | BE/BI via MQTT `send_client` | L | W `CoinlessDati`; R `EcsMacchine.T0`; (trigger) W `CoinlessDecodedData`, `EcsDati`, `Clienti`, `CoinlessTransazioniCards`, `CoinlessCards`, `CoinlessClonedCards`, `CoinlessLogEventiBlacklist`, `TransCard` | `DBcoinless.bas:222-277`; `ecs2mqtt.b4j:1660-1674`; `sql/codice-db/prod/applicativo/trigger/decodifica_flusso.sql`; `…/procedure/decodifica_record.sql` [V] | W04-26, W08-14 (esterni, lato DB) | complementare (B4J scrive, il DB decodifica, WinMT legge) |
| E04-03 | Decodifica in memoria della struttura ECL | Spezza `cmd` (byte esadecimali separati da `;`), ricostruisce i campi little-endian a 32/16 bit e restituisce una mappa (contatori In1–In8 e partite per il tipo 7; N0, ticket, saldo, UID, costo, bonus, livello per i tipi 16–23). Serve alla risposta "stato card" (tipi 8/16) e alla pagina di debug MQTT | `send_client` tipi 8/16; `MqttDebug` | M | — | `DBcoinless.bas:3255-3548`; `ecs2mqtt.b4j:1700-1704`; `MqttDebug.bas:112,125` [V] | W04-26 (stessa decodifica in `decodifica_record`) | **doppione** (con la stored procedure, regole diverse: § 5) |
| E04-04 | Partita in modalità sempre-online | Scala `Clienti.Credito` e inserisce la partita in `TransCard` (`N0 = MAX+1`, `ValoreFinale` incatenato all'ultimo), senza transazione | Lettura card con `GetCred` (`clsGestioneClienteOnline/Sala.CanPlay`) | M | W `Clienti.credito`, `TransCard`; R `EcsMacchine` | `DBcoinless.bas:125-184`; `clsGestioneClienteSala.bas:117-155`; `clsGestioneClienteOnline.bas:140-178` [V] | W04-26 (trigger `aggiornaCard`) | **doppione** (della scrittura partita che il DB fa per la modalità card) |
| E04-05 | Accredito crediti/bonus a un cliente | Incrementa `Clienti.Credito` e scrive in `TransCard` una riga bonus (`NImp = 6`) e una crediti (`NImp = 0`, `ValoreCassa = importo`), `CodMac` = hostname, `N0 = MAX+1` | API cloud (`clsElmacAPI`, `"CLOUD"`), `/api` (`APIHandler`), kiosk Flutter (creazione utente) | M | W `Clienti.credito`, `TransCard` | `DBcoinless.bas:3565-3666`; `APIHandler.bas:330`; `FlutterKioskHandler.bas:1452,1473`; `clsElmacAPI.bas:1105,1154` [V] | W02-06, W05-02 | **doppione** (regole diverse: § 5) |
| E04-06 | Ricarica card da totem Flutter | Porting di `AddTransCard`: riga bonus (`NImp = 6`, `N0 = progressivo−1`) e riga crediti (`NImp = 1`, `N0` = progressivo letto dalla card), `T0` = impianto su 4 cifre, `Clienti.Credito` impostato al saldo assoluto. Idempotente: verifica la riga "principale" prima di scrivere. Unica transazione SQL del modulo | Totem/kiosk Flutter `/kiosk` | L | R/W `TransCard`; W `Clienti.credito` | `DBcoinless.bas:3668-3847` (tx `:3800-3828`); `FlutterKioskHandler.bas:1140,1254` [V] | W02-06, W01-13 | **doppione** (porting dichiarato, transazionale) |
| E04-07 | Buffer dei ticket vinti per card | Accumula i ticket per (device, card) in `CoinlessDataBuffer`. Con payload `0` scarica il buffer in `Tickets` (`DBwinmt.scriviTicketsSuWINMT`), se la card è ticketless (`Clienti.N0`, oppure `flagstkless`) | BE via MQTT `ElmacECL/Buffers/<device>/Tickets/Cards/<cardid>` | M | R/W `CoinlessDataBuffer`; R `Clienti.N0` | `DBcoinless.bas:1093-1154`; `ecs2mqtt.b4j:1080-1092` [V] | — (W02-14 lato cassa) | complementare (WinMT legge `Tickets`) |
| E04-08 | Movimento "mobile" replicato | Per un device smartphone (`MobileFConnect`) copia l'ultimo snapshot in `CoinlessDecodedData`, con `gettoni` e `cnt4…cnt8` a 0, e inserisce in `CoinlessDati` un `cmd` fisso con HMAC vuoto | App mobile via `send_client` | S | R/W `CoinlessDecodedData`; W `CoinlessDati` | `DBcoinless.bas:279-320`; `ecs2mqtt.b4j:1641-1643` [V] | — | solo B4J |
| E04-09 | Stato dei lettori | Aggiorna `ecl_SchedeFirmware.status` dai messaggi di stato di lettori, mangiaticket e visualizzatori | MQTT `ElmacECL/+/+/status` | S | W `ecl_SchedeFirmware.status` | `DBcoinless.bas:3234-3253`; `ecs2mqtt.b4j:1357,1371,1385` [V] | — | solo B4J |
| E04-10 | Fotografia della configurazione BE/BI | Fonde nel JSON `BEConfig.BeInfo` i dati del messaggio `macaddr` e nel JSON `BEConfig.BiConfig` i parametri `GetValBI` della BI (impulsi, fori ticket, bitmask modalità) | MQTT setup `SetUp/…/macaddr`; `ElmacStatusBI/+` | M | R/W `BEConfig` (MERGE) | `DBcoinless.bas:4758-4911`; `DBwinmt.bas:13604-13690`; `ecs2mqtt.b4j:2084`; `mqttMessages.bas:760` [V] | — | solo B4J |
| E04-11 | Censimento schede e firmware rilevato | Al boot della BE registra o aggiorna `EcsModuli` (MAC, IP) e la riga `ecl_SchedeFirmware`, riclassificando tipo scheda e firmware dal prefisso della versione. Se la versione non esiste in `ecl_firmware` manda un warning al cloud | MQTT setup `macaddr`; `eclservice` | M | R/W `ecl_SchedeFirmware`; R `ecl_firmware`; W `EcsModuli` (via `DBwinmt`) | `DBcoinless.bas:640-719, 3186-3232`; `mqttMessages.bas:127-141` [V] | W08-07 | complementare (`EcsModuli` è scritta solo dal motore) |
| E04-12 | Schede nuove e pulizia | Elenca le schede vergini (`device = '0z0z0'`) segnalando i MAC duplicati; cancella quelle non assegnate da più di N minuti (timer, default 4 h); restituisce modello e versioni di un MAC | WinMT `eclcommand?command=jProvisionable`; timer; pagine web | M | R/D `ecl_SchedeFirmware` | `DBcoinless.bas:599-638, 774-873`; `eclcommand.bas:537`; `ecs2mqtt.b4j:185,697` [V] | W08-07 (`jProvisionable`) | complementare |
| E04-13 | Adozione di un modulo | Assegna il MAC al device (`ecl_SchedeFirmware.device`) e fa un MERGE su `EcsModuli` (`ShortAd` = device, `N0` = `EcsMacchine.Modu`, `Id = MAX+1`) | WinMT `jAdopt` → `eclcommand` | M | W `ecl_SchedeFirmware`, `EcsModuli`; R `EcsMacchine` | `DBcoinless.bas:547-597`; `eclcommand.bas:559` [V] | W08-07 (`jAdopt`) | complementare |
| E04-14 | Catalogo firmware BE | Carica un `.bin` come blob in `ecl_firmware` (`url` = host del broker MQTT), elimina, elenca, trova l'ultima versione, legge il blob da servire in HTTP | Operatore web (`/ws/ElencoFirmware`, `/ws/DeviceFirmware`); BE in HTTP `/eclservices/getfirmware/…` | M | R/W/D `ecl_firmware` | `DBcoinless.bas:721-770, 875-991, 2566-2641, 2731-2764, 2914-2971`; `ElencoFirmware.bas:356,393,413`; `eclservice.bas:307` [V] | — | solo B4J |
| E04-15 | Aggiornamento OTA del firmware | Imposta `requestedVersion` per una scheda o per tipo (broadcast) ed elenca i MAC da aggiornare. La class `aggiornamentiFirmware` pubblica `{"msg":"OtaUpdate","host","binfile","ver"}` sul broker di setup | Operatore web; WinMT `eclcommand` (`FirmwareStatus`, `rasamilapatata`) | L | R/W `ecl_SchedeFirmware`; R `ecl_firmware`, `EcsMacchine` | `DBcoinless.bas:321-502, 1034-1091, 1180-1211`; `aggiornamentiFirmware.bas:16-140`; `eclcommand.bas:168-250` [V] | — | solo B4J |
| E04-16 | Firmware della BI (`.srec`) | Carica il firmware BI in `CoinlessImages` (`majorFirmware` fisso `'131'`), lo elenca (leggendo anche i blob) e ne forza il reinvio cancellando le righe di `ecl_Provisioning` | Operatore web (`/ws/ElencoFwBI`, `/ws/DeviceFirmwareBI`); boot di schede formattate | M | R/W `CoinlessImages`; D `ecl_Provisioning` | `DBcoinless.bas:906-948, 1559-1579, 2531-2563, 2681-2729`; `ElencoFwBI.bas:45,214,232` [V] | — | solo B4J |
| E04-17 | Schermate statiche | Carica (MERGE per nome) ed elenca le immagini, le serve alle BE e ne forza il reinvio | Operatore web (`/ws/ElencoSchermate`); BE HTTP `/eclservices/getimages` | S | R/W `CoinlessImages`; D `ecl_Provisioning` | `DBcoinless.bas:993-1029, 1537-1557, 2643-2678, 2766-2798`; `eclservice.bas:134,227` [V] | — | solo B4J |
| E04-18 | Traduzioni ed etichette della BE | CRUD di `CoinlessLanguages` (nuova lingua = copia di `ita`); compone le righe `font\|x\|y\|colore\|testo` per `lingue.txt`; calcola quante etichette supporta il firmware (`msgCount`); forza il reinvio delle lingue (una scheda o tutte) | Operatore web (`/ws/beMessages`); BE HTTP `/eclservices/getlanguage` | M | R/W `CoinlessLanguages`; R `ecl_SchedeFirmware`, `ecl_firmware`; D `ecl_Provisioning` (id 0) | `DBcoinless.bas:1213-1535, 2336-2392`; `gestioneLingue.bas:82-296`; `eclservice.bas:63-159` [V] | — (W02-21 sono le traduzioni di WinMT, altra cosa) | solo B4J |
| E04-19 | Provisioning dei file accessori | Per MAC e versione firmware calcola i file non ancora consegnati (immagini statiche, `lingue.txt`, pagine dinamiche). Sono 6 varianti per famiglia e versione, con prefissi URL e CRC32 diversi. A consegna confermata registra la riga; ne forza il reinvio cancellandola | MQTT setup (boot BE, `ElmacECLEvents` di fine download); operatore web | L | R `CoinlessImages`, `ecl_SchedeFirmware`, `ecl_firmware`, `coinless_sbuilder_pages`, `EcsModuli`, `EcsMacchine`; R/W/D `ecl_Provisioning`, `Coinless_sbuilder_page_provisioning` | `DBcoinless.bas:1582-2333, 2487-2530`; `mqttMessages.bas:200-310, 480-500, 620-650` [V] | — | solo B4J |
| E04-20 | Provisioning dei device non-game | Una riga per MAC in `ecl_DeviceProvisioning` indica che la configurazione di cassa/totem/mangiaticket è già stata inviata; viene cancellata dopo un cambio versione o una formattazione | Boot BE (famiglie 123/132/133) | S | R/W/D `ecl_DeviceProvisioning`; D `ecl_Provisioning`, `Coinless_sbuilder_page_provisioning` | `DBcoinless.bas:2393-2485`; `mqttMessages.bas:219-221, 376-390, 148` [V] | — | solo B4J |
| E04-21 | Screen builder | Template SVG per sala; calcola le pagine da generare per ogni macchina (Tap_to_play, ooo_qr, Happy hour, setup) con chiave = prezzi per livello; registra, legge e cancella le pagine generate; serve le immagini ai device | Operatore web (`/ws/TemplatesSchermate`, rigenerazioni); `specialtimes`; BE HTTP `/eclservices/gettplimages` | L | R/W/D `coinless_sbuilder_templates_svg`, `coinless_sbuilder_pages`; R `EcsMacchine`, `EcsModuli`, `CoinlessTestataHappyHour`, `CoinlessMacchineHappyHour`, `vs_CoinlessSpecialTimes` | `DBcoinless.bas:1669-1753, 2800-2912, 4050-4715`; `ScreenBuilder.bas:259-910` [V] | W04-17 (happy hour), W08-12 (prezzi), W08-07 (`jRebuildSinglePageFromTemplate`) | complementare (WinMT scrive prezzi e happy hour, B4J genera le pagine) |
| E04-22 | DDL e migrazioni | Crea `ecl_log` se manca; esegue gli script dello screen builder (3 tabelle e la vista `vs_CoinlessSpecialTimes`); crea `pinkbox_log` (codice mai chiamato) | Avvio; `ScreenBuilder` init | S | DDL `ecl_log`, `coinless_sbuilder_*`, `Coinless_sbuilder_page_provisioning`, `vs_CoinlessSpecialTimes`, `pinkbox_log` | `DBcoinless.bas:3082-3120, 3939-3981, 4160-4179`; `ScreenBuilder.bas:48-176`; `ecs2mqtt.b4j:562` [V] | W04-25 (adeguamento schema all'avvio) | **doppione** concettuale (ognuno migra il "suo" schema) |
| E04-23 | Log applicativo | `Scrivilog`: tutto il traffico MQTT in ingresso e in uscita (se `ecl_log` e `mqtt_log` = 1, i default). `ScriviLogSempre`: audit di Test Mode e Armageddon. `ScriviDebugLog`: prelievi da hub e distributori | Ogni messaggio MQTT; operatore | S | W `ecl_log`, `debug_log` | `DBcoinless.bas:3000-3080`; chiamate in `ecs2mqtt.b4j:799…3997`, `DBwinmt.bas:1578,10312,10385,7922,14880,15019` [V] | W02-20 (log tecnici) | solo B4J |
| E04-24 | Whitelist UID e card via API | Risolve UID↔codbar in `UID_Ammessi`; ripristina la card (`sp_ripristinacard`) o elimina il cliente (`sp_eliminacliente`) | API `/api` (`APIHandler`), kiosk | M | R `UID_Ammessi`; procedure | `DBcoinless.bas:4913-5008`; `APIHandler.bas:164-294`; `FlutterKioskHandler.bas:1427` [V] | W02-11, W03-11 | **doppione** (W02-11 con regola diversa; W03-11 con le stesse procedure) |
| E04-25 | Creazione di un codice redeem | Chiama `sp_redeem_create` (13 parametri di ingresso e 3 di uscita) | API cloud (`clsElmacAPI`, stub con parametri fissi) | S | procedura → `RedeemCodes` | `DBcoinless.bas:5010-5088`; `clsElmacAPI.bas:1301-1308` [V] | W04-18, W01-24 | **doppione** (lato B4J non funzionante: § 6) |
| E04-26 | Autodiscover UDP | Alla richiesta `ARQFIND ECLServer:<ip>` cerca la versione della BE (e le info del modulo) a partire dall'IP, per decidere la risposta | BE in broadcast UDP | S | R `EcsModuli`, `ecl_SchedeFirmware`, `EcsMacchine` | `DBcoinless.bas:3903-3937, 4717-4755`; `Autodiscover.bas:405-430` [V] | — | solo B4J |
| E04-27 | Wizard nuova macchina: configurazione dal cloud | Legge dal linked server l'impianto corrente, i modelli della flotta, la configurazione e gli ingressi di una macchina omonima in un'altra sala (anche `EcsMacchine` del DB di un'altra sala); costruisce la configurazione di default per tipo e la salva in `setup2` | Operatore web `/ws/InstallazioneNuovaMacchina` | L | R `elmaccloud.CoinlessDB.dbo.{CoinlessImpianti, vs_definizione_nome_macchina, CoinlessDefaultTypeConfig}`, procedure `sp_CoinlessMacchine`, `sp_ConfigurazioneMacchina`, `sp_DettaglioIngressiMacchina`, `elmaccloud.DBnnnn.dbo.EcsMacchine`, `elmaccloud.<svc>.dbo.Machines`; R/W `setup2` | `DBcoinless.bas:5090-5410, 5712-5892`; `InstallazioneNuovaMacchina.bas:81-424` [V] | W08-04, W08-06 | **doppione** (WinMT crea e duplica macchine con un proprio wizard) |
| E04-28 | Wizard "crea nuovo modello" sul cloud | Elenca e crea `Type` (id < 100), `Manuf` e `Machines` **direttamente nel DB di servizio cloud** `elmaccloud.<DBSERVIZIO>`, con id = MAX+1 | Operatore web (stesso wizard) | M | R/W `elmaccloud.<svc>.dbo.{Type, Manuf, Machines}` | `DBcoinless.bas:5412-5710`; `InstallazioneNuovaMacchina.bas:796-977` [V] | W08-01 | **doppione** (WinMT gestisce il catalogo nel DB di sala) |
| E04-29 | Gru: elenco e dettaglio | Stato dei 3 slot (quantità, valore medio, ultimo carico e ultima vincita) e ultimi 20 movimenti | API HTTP `GET /crane/…` | S | R `vs_CraneStatus`, `GruMovimenti`; W (procedure) `GruMagazzino*` | `DBCrane.bas:84-260`; `CraneHandler.bas:150-180` [V] | W07-11 | **doppione** (lettura) |
| E04-30 | Gru: carico di un premio in uno slot | Scarica il premio dal magazzino (`Premi.Quantita`, `MovOut` causale `GRU`), ricalcola la media pesata dello slot, registra `LOAD` e copia la media in `EcsMacchine.ValIn6/7/8` | API `POST /crane/action/LOAD` | L | R/W `Premi`, `GruMagazzinoDettaglio`; W `MovOut`, `GruMovimenti`, `EcsMacchine` | `DBCrane.bas:309-454` [V] | W06-13 (scarico causale GRU), W07-11 | complementare (WinMT legge `MovOut.Motivo = GRU` nell'inventario) |
| E04-31 | Gru: rientro di un premio da uno slot | Rimette il premio in magazzino (`Premi`, `MovMag` `CARICO`), ricalcola la media "a ritroso" e registra `UNLOAD` | API `POST /crane/action/UNLOAD` | L | R/W `Premi`, `GruMagazzinoDettaglio`, `GruMovimenti`; W `MovMag`, `EcsMacchine` | `DBCrane.bas:888-1030` [V] | W06-09 (carico) | **doppione** (causale diversa da quella che l'inventario WinMT si aspetta, § 5) |
| E04-32 | Gru: vincita manuale | Decrementa lo slot e registra `WIN`; la media resta invariata | API `POST /crane/action/WIN` | M | R/W `GruMagazzinoDettaglio`; W `GruMovimenti`, `EcsMacchine` | `DBCrane.bas:262-307, 1160-1206` [V] | — | solo B4J |
| E04-33 | Gru: vincite automatiche dai contatori | A ogni `send_client` di una gru (tipi 3, 9, 12, 17) confronta le ultime due righe `EcsDati` (`In6/7/8` = slot 1/2/3), registra `WIN` per i delta e deduplica con `CraneCounterSyncLog` | BE via `send_client` (se `dbversion` ≥ 20260424) | L | R `EcsDati`, `EcsMacchine`; R/W `CraneCounterSyncLog`, `GruMagazzinoDettaglio`; W `GruMovimenti`, `EcsMacchine` | `DBCrane.bas:518-747`; `ecs2mqtt.b4j:1676-1692` [V] | — (WinMT mostra solo il menu se esiste il log) | solo B4J |
| E04-34 | Gru: valore medio iniziale all'installazione | Per i 3 slot chiama `sp_crane_force_avg_value` (movimento `ADJUST+`) | Wizard nuova macchina | S | via procedura: `GruMagazzino*`, `GruMovimenti`, `EcsMacchine` | `DBCrane.bas:456-516`; `InstallazioneNuovaMacchina.bas:690-699` [V] | W07-11 | **doppione** (stessa procedura; WinMT ha il difetto sugli slot 2–3) |
| E04-35 | Gru: articoli premio | Crea un articolo in `Premi` (`Gru = 1`, fornitore `Elmac`, `N_Tickets` = valore×100) con carico `MovMag`; legge un articolo per codice o `CodOr` | API `POST /crane/action/ARTICLECREATE`, `GET …/article` | M | R/W `Premi`; W `MovMag` | `DBCrane.bas:749-886` [V] | W06-03 | **doppione** (regola diversa sul prezzo in ticket) |
| E04-36 | Configurazione del motore | Legge e scrive `C:\ecs2mqtt\dbsettings.txt` (server SQL, broker, WiFi delle BE, master/slave, log, modalità) e ricompone `Setup(101).AdmPass` (8 campi separati da `\|`) | Superadmin web `/ws/DbConfig` | M | R/W `Setup.AdmPass` (IdPost 101); file | `DbConfig.bas:54-272`; `DBwinmt.bas:5839-5925`; `settingsmanager.bas:12-21` [V] | W04-01, W10-12 | **doppione** (`AdmPass` scritto da entrambi, stesso formato) |
| E04-37 | Replica sala↔cloud di firmware, immagini e lingue | "From cloud" / "to cloud": `INSERT … WHERE NOT EXISTS` di `CoinlessImages`, firmware BI, `ecl_firmware`, `CoinlessLanguages` tra il DB locale e `CoinlessDB` del cloud. "To cloud" solo per livello 0 | Superadmin web `/ws/syncconfig` | M | R/W `CoinlessImages`, `ecl_firmware`, `CoinlessLanguages` (locali e cloud) | `syncConfig.bas:41-67`; `DBwinmt.bas:10904-11060` [V] | — (W10-19 è solo un indicatore) | solo B4J |
| E04-38 | Codice morto o inattivo | `mettiInBlackList` (esecuzione commentata), `controllaDuplicatoTranscard`, `assegnaMacaddressDevice`, `azzeraTicketsBuffer`, `getAllMachinesForFaker`, `getPaginaHHPerBe`, `pinkbox_log` (3 Sub), `isSaveCiapett`/`checkChapett` (chiamate commentate), `DBCloud.bas` | — | — | (`CoinlessCards`, `save_ciapett`, `pinkbox_log`) | `DBcoinless.bas:186-220, 504-545, 1156-1178, 2973-2998, 3122-3184, 3849-4046, 4518-4545`; `ecs2mqtt.b4j:1200,1587,1804` [V con grep dei chiamanti] | — | — |

Riepilogo pesi (flussi attivi E04-01…E04-37): S 11, M 17, L 9 (37 flussi).

### Dettaglio dei flussi L e dei doppioni

**E04-02 Acquisizione record ECL (L).**
- Il motore costruisce l'`INSERT` in `CoinlessDati` concatenando `device`, `cmd`, `cnt` e `hmac` presi dal payload MQTT [V `DBcoinless.bas:238-259`].
- Il record si scarta se `EcsMacchine.T0` contiene `"BISwap":1` (sostituzione della BI) oppure `"NoRec":1` (riprogrammazione in corso) [V `:247,259`; `DBwinmt.bas:10502-10510, 10796-10802`].
- `FlagOpDaVerificare`: `Status = 2` → 1, cioè scrittura sulla card non confermata; `Status = 1` o assente → NULL. Con `dbversion` < 20240625 il flag è ignorato [V `:233-255`; `ecs2mqtt.b4j:1665-1673`].
- Tutta la logica successiva sta nel DB: HMAC verificato dal trigger, con il segreto dentro `fn_calcHMAC`; decodifica, saldo, anti-replay e blacklist dentro `decodifica_record`; `EcsDati` scritto dal trigger `inseriscesuECS`. L'indice unico `CoinlessDati(cmd, cnt, hmac)` scarta i reinvii identici [V `docs/db/db-02-catalogo.md` § CoinlessDati].
- Nel DB di test `decodifica_record` contiene in più l'antifrode "RFID non scrivibile" (`CoinlessCards.TentativiNonConfermati`, soglia `setup2.MaxTentativiNonConfermati`); nella copia di produzione non c'è [V `diff` test/prod].
- **Effetto collaterale [V SQL, D impatto]:** per i record di tipo 19/20 (BE senza BI), `decodifica_record` inserisce un "record di servizio" in `CoinlessDecodedData` con `cnt3…cnt8` e `gettoni` a 0. `inseriscesuECS` lo copia in `EcsDati` con `In1` e `In3…In8` = 0, cioè contatori cumulativi azzerati in una riga (`decodifica_record.sql:392-444`; `inseriscesuECS.sql`).

**E04-03 Decodifica ECL (doppione con `decodifica_record`).** Vedi la tabella dei byte in § 4.6. Le differenze verificate sono due:
- **Bonus.** B4J legge i byte 35–36 (indice da 0) [V `DBcoinless.bas:3501-3508`]; la stored procedure legge le righe 37–38, cioè i byte 36–37 [V `decodifica_record.sql:264-268`]. Una delle due è sfasata di un byte.
- **UID card del tipo 8.** B4J la prende dai byte 16–19 per i tipi 8 e 16 [V `ecs2mqtt.b4j:1709-1716`]; la procedura, per i tipi 8/13, dai byte 20–23 [V `decodifica_record.sql:172-175`]. Può trattarsi di messaggi diversi (richiesta di stato contro transazione) [D].

Per il tipo 8 B4J non decodifica nulla (ramo vuoto), quindi `CostoPartita` e `Bonus` letti a `ecs2mqtt.b4j:1829-1830` sono nulli [V `DBcoinless.bas:3412`].

**E04-04 Partita sempre-online (doppione).**
- `Clienti.Credito` viene ridotto di (crediti + bonus) / `RappCentValuta`, cioè in centesimi [V `:139-153`].
- In `TransCard`: `NImp` NULL, `T0` NULL, `WinMt` = 0, `ValoreOperazione` = costo in crediti, `ValoreBonus` = costo in bonus, `ValoreFinale` = ultimo `ValoreFinale` − crediti − bonus (NULL se il cliente non ha righe), `N0` = MAX+1 [V `:158-178`].
- Rispetto al trigger `aggiornaCard`, che scrive le partite delle card, qui `N0` non viene dalla card ma dal DB, e non c'è transazione tra `UPDATE` e `INSERT` [V].

**E04-05 Accredito crediti/bonus (doppione di W02-06, regole diverse).** Le differenze con `AddTransCard` di WinMT e con `RicaricaCardTotem`:

| Aspetto | W02-06 (WinMT) | E04-06 `RicaricaCardTotem` | E04-05 `addCreditiToUser` |
|---|---|---|---|
| `Clienti.Credito` | valore assoluto = ValoreFinale/CentConversionFactor | valore assoluto (centesimi) | **incremento** di (crediti + bonus)/RappCentValuta [V `:3581-3596`] |
| `NImp` riga crediti | tipo dell'operazione (0 cassa, 1 totem, 14 online…) | 1 | **0** ("carico da cassa fissa") anche per gli accrediti `"CLOUD"` [V `:3638`] |
| `ValoreCassa` | contante incassato | contante (0 se elettronico) | **= importo crediti** [V `:3649,3656`] |
| `T0` | impianto su 4 cifre | impianto su 4 cifre | **NULL** [V `:3615,3645`] |
| `N0` | progressivo della card | dalla card (−1 per il bonus) | MAX(N0)+1 dal DB |
| `CodMac` | nome del computer | id del kiosk | hostname o `"CLOUD"` |
| Transazione | no | sì | no |

Conseguenza [D]: gli accrediti `"CLOUD"` figurano come contante di una cassa fissa (`NImp = 0`, `ValoreCassa > 0`, `D0` NULL), quindi possono entrare nella somma della cassa principale (W04-12) e sfuggire ai filtri per impianto (`T0`).

**E04-06 Ricarica da totem (L, doppione dichiarato).** È il porting più fedele di `AddTransCard`.
- Idempotenza: se la riga "principale" esiste ed è identica, risponde `GIA_APPLICATA`; se esiste ma diversa, `CONFLITTO_PROGRESSIVO_GIA_USATO` [V `:3780-3798`].
- Con il solo bonus, la riga bonus occupa lo slot pieno del progressivo; serve a evitare il falso positivo "card clonata", bug datato 2026-09-15 nel commento [V `:3750-3760`].

**E04-15 OTA (L).**
- Il messaggio OTA porta `host` = `ecl_firmware.url`, che all'upload è valorizzato con il broker MQTT principale [V `:2619`]: il server HTTP e il broker devono avere lo stesso host [D].
- `verificaFirmware` restituisce la versione più alta senza filtrare il tipo di scheda [V `:335`]. Usata da `rasamilapatata` (`eclcommand.bas:172-178`), può inviare a un MAC un firmware di un'altra famiglia [D].

**E04-19 Provisioning (L).**
- Una riga `ecl_Provisioning(macaddress, idImmagine)` significa "file già consegnato": `idImmagine` è `CoinlessImages.id`, con **0 = `lingue.txt`**. Una riga in `Coinless_sbuilder_page_provisioning` vale lo stesso per le pagine dinamiche. "Da inviare" = assenza della riga [V `:1596-1607, 2183-2199`].
- Le varianti dipendono dalla famiglia firmware (123/133 mangiaticket, 131 giochi, 132 cassa/totem, 136 visualizzatore) e dalla versione. Il percorso cambia (`getimages/CZ/…` prima di 131.107.0053, `/…` dopo, `CZ/…` nelle V2/V3); le lingue sono `getlanguage/lingue.txt` prima di 131.106.0028, poi `<msgCount>/lingue.txt`; le immagini partono da 131.106.0035; la V3 (build ≥ 13) aggiunge `!CRC32` [V `:1632-1656, 1803-2162`].
- La conferma `AggiornaProvisioning` usa `charindex(imagename, '<elencofile>')` con `elencofile` preso dal payload MQTT [V `:2184,2196`]: oltre al rischio di injection, un nome contenuto in un altro (es. `a.jpg` e `aa.jpg`) viene confermato per errore [D].

**E04-21 Screen builder (L).**
- Nome della pagina generata: `<template>_<coin>_<normal>_<silver>_<gold>_<platinum>.jpg`. `coin` = `ValPar` se l'ingresso 3 è a monete (`ValIn3 > 0` e `TipoIn3 = 0`), altrimenti `CntrLet10` (impulsi per partita). I valori sono `EcsMacchine.val_*` [V `:4193-4217`]. Per le happy hour la chiave usa `CoinlessMacchineHappyHour.perc_*` e il template `CoinlessTestataHappyHour.T0` [V `:4219-4242`].
- Il nome del file **codifica i prezzi**: cambiato un prezzo, la pagina va rigenerata (la query cerca le pagine mancanti con quel nome) [V].
- `coinless_sbuilder_pages.Codmac` contiene il `CodMac` per le pagine standard e il **MAC** per `setup_qr` [V commento `:1701-1704`, query `:1890`].

**E04-27 / E04-28 Wizard cloud (doppioni di W08-04 e W08-01).**
- Il motore legge il catalogo della flotta e la configurazione di macchine di **altre sale** (`elmaccloud.DB0193.dbo.EcsMacchine`), e scrive nuovi `Type`/`Manuf`/`Machines` nel DB di servizio cloud del cliente [V `:5388, 5612, 5650, 5695`].
- Il nome di DB e servizio è validato con regex prima di essere interpolato [V `:5372, 5422-5426`].
- Lo stesso `macname` può avere `Type` diversi su servizi diversi ("Arctic" 2 contro 7) [V commento `:5180-5185`]. Il catalogo dei modelli non è globale.

**E04-30 / E04-31 / E04-33 Gru (L).** Regole verificate in `DBCrane.bas`:

| Operazione | Quantità slot | Valore medio | Magazzino premi | Movimento |
|---|---|---|---|---|
| LOAD | +qty | (q·avg + qty·costo)/(q+qty) [`:366-372`] | `Premi.Quantita −qty`; `MovOut` (`Motivo 'GRU'`, `Note` = macchina e slot) poi `UPDATE MovOut` che copia descrizione/costo/ticket/fornitore su **tutte** le righe di quel codice con descrizione NULL [`:379-404`] | `LOAD` |
| UNLOAD | −qty (≥ 0) | (q·avg − qty·costo)/(q−qty); se lo slot si svuota resta la media precedente [`:949-959`] | `Premi.Quantita +qty`; `MovMag` (`NBolla 'MANU'`, `Motivo 'CARICO'`) [`:967-978`] | `UNLOAD` |
| WIN | −qty (rifiutata se la quantità non basta) | invariato [`:1180-1181`] | — | `WIN` (`UnitValue` = media) |
| Auto (contatori) | delta = max(0, In_n ultimo − In_n precedente) per `In6/7/8`; se un contatore cala (reset) nessuna vincita, solo log [`:671-708`] | invariato | — | `WIN` con nota `AUTO ECSDATI <DataRil>` + `CraneCounterSyncLog` |
| Dopo ogni operazione | — | `sp_crane_sync_ecsmacchine_values`: `EcsMacchine.ValIn6/7/8` = media degli slot | — | — |

- **Prezzo d'acquisto.** `UNLOAD` controlla solo che l'articolo sia **mai stato caricato** nello slot (somma dei `LOAD`, senza sottrarre `UNLOAD` e `WIN`) [V `:1139-1158`].
- **Risposta a `winmt-07` § Domande 1–2.** I movimenti `LOAD`/`UNLOAD`/`WIN` li scrive il motore B4J. `CraneCounterSyncLog` è il registro di deduplica di E04-33 [V]. Perché in produzione `GruMovimenti` è vuota con 11.963 righe di log [D, da verificare con una query]: finché nessuno carica premi, `QtyCurrent = 0` e ogni delta positivo fa fallire `WIN` (`ERR_SLOT_STOCK_NOT_ENOUGH`). La transazione va in rollback e **non si scrive nemmeno il log**, quindi il log contiene solo campioni con delta 0 o reset. Le vincite dei campioni falliti si perdono: il campione successivo si confronta con il precedente. Verifica: `SELECT COUNT(*) FROM CraneCounterSyncLog WHERE DeltaIn6 + DeltaIn7 + DeltaIn8 > 0` dovrebbe dare 0.
- **Doc superata.** `docs/fonti/ecl2mqtt/gru_valore_medio_iniziale.md` § "Stato attuale" dice che il valore iniziale non è implementato. Il codice ora c'è (`DBCrane.bas:473-516`, `InstallazioneNuovaMacchina.bas:690-699`) [V].

**E04-36 Configurazione (doppione di W04-01).** `AdmPass` = `CodClienteECL|CodImpianto|RapportoCentesimoValuta|NomeDelCoin|RapportoValoreVisualizzatoSullaBE|VisCurr|LabelMoneta|LabelGettoni`, lo stesso formato di `FrmSetECL` [V `DBwinmt.bas:5839-5911`]. A differenza di WinMT, il motore non applica i default (`0.01`, `1`) se il campo è vuoto [V `DbConfig.bas:260-269` contro `winmt-04` W04-01].

---

## 3. Interlocutori

### (a) MQTT

I moduli della zona non pubblicano né sottoscrivono direttamente, salvo una pubblicazione. Sono invocati da questi topic:

| Topic | Broker | Dir. | Payload | Controparte | Flusso |
|---|---|---|---|---|---|
| `send_client` | main | in | JSON `{device, cmd, cnt, hmac, Status?, GetCred?/PutTicket?/MobileFConnect?}` | BE/BI, app mobile | E04-02, 03, 04, 08, 33 |
| `ElmacECL/Buffers/<device>/Tickets/Cards/<cardid>` | main | in | `{n}` ticket | BE | E04-07 |
| `ElmacECL/<tipo>/<mac>/status` (tipo reader, mangiat, viewer, vs) | main | in | stato | lettori | E04-09 |
| `SetUp/<client>/macaddr` | setup | in | `{macaddr, ver BE, ver BI, IpAddress, RSSI, SPIFSSUsed, …}` | BE al boot | E04-10, 11, 19, 20 |
| `ElmacStatusBI/+` | main | in | `{"GetValBI":[…]}` | BI | E04-10 |
| `ElmacECLEvents/+/+` (fine download) | main | in | esito con nome file | BE | E04-19 |
| `Errors/<Nimp>/warning` | main | out | testo "firmware non esiste" | cloud | E04-11 [V `DBcoinless.bas:712`; `ecs2mqtt.b4j:3982-3985`] |
| `SetUp/<mac>` | setup | out | `{"msg":"OtaUpdate",host,binfile,ver}` | BE | E04-15 (da `aggiornamentiFirmware`) |

`Scrivilog` copia in `ecl_log` **ogni** messaggio MQTT in ingresso (main e setup, escluso `SetTime`) e in uscita (retain, publish, setup, cloud) [V `ecs2mqtt.b4j:799, 843, 980, 1189, 2036, 2175-2195, 2269-2301, 3984, 3997`].

### (b) HTTP e WebSocket esposti

| Endpoint | Auth | Consumatore | Flusso |
|---|---|---|---|
| `/crane/*` GET (`list`, `detail/<codmac>`, `article/<code>`, `login/<pubKey>`) | **nessuna** sui GET; `login` rilascia il token | client esterno, non identificato nel codice [D] | E04-29, 35 |
| `/crane/action/{LOAD,UNLOAD,WIN,ARTICLECREATE}` POST | Bearer (`sicurezza.RichiedeAutenticazione`), ma **operatore preso dal body** (`oper`) | idem | E04-30…35 |
| `/eclservices/getlanguage`, `getimages`, `gettemplate`, `gettplimages`, `getfirmware/OTA/<tipo>/<fw>/<ver>` | il token viene letto ma non controllato nelle righe esaminate [D] | BE, visualizzatori, mangiaticket | E04-14, 17, 18, 21 |
| `/eclcommand?command=jProvisionable, jAdopt, FirmwareStatus, rasamilapatata, …` | — | WinMT (`frmConfMacc`), tecnici | E04-12, 13, 15 |
| `/api/*`, `/kiosk/*` (chiamano `addCreditiToUser`, `RicaricaCardTotem`, `getUidAmmesso`, `ripristinacard`, `eliminacliente`) | dalle rispettive zone | app, totem Flutter | E04-05, 06, 24 |
| WebSocket `/ws/DbConfig`, `/ws/syncconfig` | `Main.ValidateSuperAdmin` | superadmin | E04-36, 37 |
| WebSocket `/ws/ElencoFirmware`, `ElencoFwBI`, `ElencoSchermate`, `TemplatesSchermate`, `beMessages`, `DeviceFirmware*`, `InstallazioneNuovaMacchina` | sessione web | operatori/tecnici | E04-14…21, 27, 28 |

### (c) Chiamate in uscita

| Destinazione | Mezzo | Uso | Evidenza |
|---|---|---|---|
| SQL Server di sala, DB `WinMtSqlDB` (o `CoinlessDB`), porta 1433, utente `sa` | JDBC, pool proprio di `DBcoinless` | tutta la zona | `DBcoinless.bas:37-48` (credenziale nel codice `:46-47`) [V] |
| Riferimenti cross-database **fissi** a `WinMtSqlDB.dbo.*` | stessa istanza | `Clienti`, `TransCard`, `EcsMacchine` | `DBcoinless.bas:197-198, 433, 447, 1109, 3160` [V] |
| Linked server `[elmaccloud]` → `CoinlessDB` (catalogo ECL centrale), `DBnnnn` (DB delle altre sale), `<DBSERVIZIO>` (catalogo modelli del cliente) | query a 4 parti ed `EXEC` remoti (servono RPC OUT e scrittura distribuita) | E04-27, 28 | `DBcoinless.bas:5090-5892` [V] |
| `DBwinmt.cloudpool`: se `Connected = 1` usa il server locale con prefisso `[elmaccloud].`; altrimenti si collega direttamente a un host cloud su `WinMtSqlDb` senza prefisso | JDBC | E04-37 | `DBwinmt.bas:192-214, 10904-11060` [V] |
| `sp_crane_*` sul DB di sala | `ExecQuery`/`ExecNonQuery2` (`EXEC`) | gru | `DBCrane.bas:101, 496, 1037, 1041` [V] |
| `sp_ripristinacard`, `sp_eliminacliente`, `sp_redeem_create` | `CallProc` | E04-24, 25 | `DBcoinless.bas:4960, 4991, 5058` [V] |
| File system: `C:\ecs2mqtt\dbsettings.txt`; file temporanei di upload; `<installpath>\www\resources\screens\<mac>\` (esistenza e CRC delle pagine) | file | E04-36, 14, 16, 17, 21 | `settingsmanager.bas:12-21`; `DBcoinless.bas:2616, 2027-2032` [V] |

---

## 4. Dati

### 4.1 Database usato da `DBcoinless`

- **Scelta del DB [V `DBcoinless.bas:18-36`].** `coinlessServer` vale `WinMtSqlDB` se è valorizzato il parametro `coinlessServer`, oppure `GamePark = 1`, oppure sono valorizzati **sia** `SlaveIp` **sia** `MasterIp`. Altrimenti vale `CoinlessDB`: il vecchio DB coinless separato, sulla stessa istanza `SqlServer`. `DBwinmt.init` ripete la stessa logica [V `DBwinmt.bas:27-52`].
- **Nella pratica è lo stesso DB di WinMT [D].** Molte query non sono qualificate (`dbo.Clienti`, `transcard`, `EcsMacchine`, `EcsModuli`), altre puntano fisse a `WinMtSqlDB.dbo.*`: in modalità `CoinlessDB` scriverebbero su tabelle inesistenti o diverse. Il commento "nuova versione con singolo db" [V `:26`] conferma che l'assetto attuale è un DB unico. Attenzione: il DB di produzione analizzato si chiama `WinMtSqlDBNuovo` (`db-05`), mentre il nome `WinMtSqlDB` è scritto nel codice.
- **`CoinlessDB` è anche il nome del DB centrale in cloud** (`elmaccloud.CoinlessDB`), master di firmware, immagini, lingue e catalogo flotta [V `DBwinmt.bas:10917-10970`; `DBcoinless.bas:5153-5205`].
- **Pool separato**, con la credenziale `sa` scritta nel codice: `DBcoinless` non usa il pool di `DBwinmt`. `DBCrane` invece usa `DBwinmt.pool` [V `CraneHandler.bas:25`; `ecs2mqtt.b4j:1681`].

### 4.2 Tabelle, viste e procedure usate (operazioni)

| Oggetto | Op. | Flussi | Sync Framework (prod) |
|---|---|---|---|
| `CoinlessDati` | W | E04-02, 08 | no |
| `CoinlessDecodedData` | R/W | E04-08 (diretta), E04-02 (trigger) | no |
| `CoinlessDataBuffer` | R/W | E04-07 | no |
| `CoinlessImages` | R/W | E04-14, 16, 17, 19, 37 | **sì** |
| `CoinlessLanguages` | R/W | E04-18, 37 | **sì** |
| `ecl_firmware` | R/W/D | E04-11, 14, 15, 18, 19, 37 | **sì** |
| `ecl_SchedeFirmware` | R/W/D | E04-09, 11-15, 18, 19, 26 | **sì** |
| `ecl_Provisioning` | R/W/D | E04-16-20 | **sì** |
| `ecl_DeviceProvisioning` | R/W/D | E04-20 | **sì** |
| `Coinless_sbuilder_page_provisioning` | R/W/D, DDL | E04-19-22 | **sì** |
| `coinless_sbuilder_pages` | R/W/D, DDL | E04-19, 21, 22 | **sì** |
| `coinless_sbuilder_templates_svg` | R/W, DDL | E04-21, 22 | **sì** |
| `BEConfig` | R/W | E04-10 | **sì** |
| `ecl_log` | W, DDL | E04-22, 23 | no |
| `debug_log` | W | E04-23 | no |
| `pinkbox_log` | DDL/R/W (morto) | E04-38 | — |
| `save_ciapett`, `CoinlessCards` | R/W (morto) | E04-38 | no |
| `Clienti` | R/W (`credito`) | E04-04-07 | sì |
| `TransCard` | R/W | E04-04-06 | sì |
| `EcsMacchine` | R (W `ValIn6/7/8` via procedura) | quasi tutti | sì |
| `EcsModuli` | R/W (MERGE) | E04-13, 19, 21, 26 | sì |
| `EcsDati` | R | E04-33 | sì |
| `UID_Ammessi` | R | E04-24 | sì |
| `CoinlessTestataHappyHour`, `CoinlessMacchineHappyHour`, `vs_CoinlessSpecialTimes` | R (vista: DDL) | E04-21 | sì / vista |
| `Premi`, `MovOut`, `MovMag` | R/W | E04-30, 31, 35 | sì |
| `GruMagazzino`, `GruMagazzinoDettaglio`, `GruMovimenti` | R/W | E04-29-35 | **sì** (prod) |
| `CraneCounterSyncLog` | R/W | E04-33 | no |
| `vs_CraneStatus` | R | E04-29 | — |
| `Setup` (IdPost 101 `AdmPass`), `setup2` (IdPost 101, chiave `typename_<tipo>`) | R/W | E04-36, 27 | sì |
| Procedure: `sp_crane_list`, `sp_crane_ensure_records`, `sp_crane_sync_ecsmacchine_values`, `sp_crane_force_avg_value`, `sp_ripristinacard`, `sp_eliminacliente`, `sp_redeem_create` | EXEC | gru, E04-24, 25 | — |
| Cloud: `CoinlessImpianti`, `vs_definizione_nome_macchina`, `CoinlessDefaultTypeConfig`, `sp_CoinlessMacchine`, `sp_ConfigurazioneMacchina`, `sp_DettaglioIngressiMacchina`, `DBnnnn.EcsMacchine`, `<svc>.Type/Manuf/Machines` | R; W su `<svc>` | E04-27, 28 | — |

Fonte della colonna Sync: elenco `_selectchanges` in `sql/codice-db/prod/sync-framework/` (61 tabelle) [V].

### 4.3 Significato delle colonne (non in db-08, salvo dove indicato)

**`CoinlessDati`** (non in db-08). Messaggio grezzo della BE.
- `device`: `<CodClienteECL>z<CodImpianto>z<Modu>`.
- `cmd`: byte esadecimali senza `0x` separati da `;`, vedi § 4.6.
- `cnt`: contatore dei messaggi della BE, entra nell'HMAC.
- `hmac`: firma calcolata dalla BE su device + cmd + cnt, verificata da `fn_calcHMAC`.
- `logdate`: istante di ricezione.
- `FlagOpDaVerificare`: 1 = scrittura card non confermata (`Status = 2`), NULL altrimenti.
- L'indice unico `(cmd, cnt, hmac)` scarta i duplicati [V `DBcoinless.bas:238-259`; `decodifica_flusso.sql`].

**`CoinlessDecodedData`** (non in db-08). Snapshot dei contatori decodificato (record tipo 7).
- `datastore` e `dataril`: `GETDATE()` del server, **non** l'ora della scheda. `datarec` = `CoinlessDati.logdate`.
- `Header`, `risposta`, `cmd_inviato`, `numbyte`: byte 0–3; `cmd_inviato` = tipo record, 7 = snapshot.
- `gettoni`: byte 12–15 → `EcsDati.In1`. Nel codice SQL è commentato "crediti", ma va nella colonna `gettoni`.
- `tickets`: byte 16–19 → `In2`. `cnt3`…`cnt8`: → `In3`…`In8`. `partite`: byte 44–47 → `In9`.
- `tipocard`: byte 48.
- `crediti`, `carduid`, `saldocard`: **mai valorizzati** dai flussi tipo 7. `crediti` lo valorizza solo il record di servizio 19/20 copiandolo dal precedente.
- Le righe con `gettoni` e `cnt3-8` a 0 sono **record di servizio** (E04-08, tipi 19/20), non letture reali [V `decodifica_record.sql:62-129, 392-444`; `inseriscesuECS.sql`; `DBcoinless.bas:289-301`].

**`CoinlessDataBuffer`** (non in db-08). Ticket vinti e non ancora scritti in `Tickets`, per (`device`, `cardid` a 16 caratteri). `tickets` è cumulato; `datastore` = ultimo aggiornamento. Le altre colonne (`crediti`, `cnt3-8`, `saldocard`…) non sono usate dal motore [V `DBcoinless.bas:1093-1154`].

**`CoinlessImages`** (non in db-08). Contiene due cose diverse. Le **immagini statiche** delle schermate BE: `ImageName` = nome file; `majorFirmware` = famiglia firmware destinataria (`131` giochi, `136` visualizzatore, `123/133` mangiaticket). I **firmware della BI**: `ImageName` `*.srec`, `majorFirmware` sempre `'131'` [V `:2711-2712, 1600, 1772, 1818`].

**`CoinlessLanguages`** (non in db-08). Etichetta n. `nr_campo` (1…`msgCount`) della lingua `lingua` (3 lettere; `ita` è la lingua master da cui si copia una lingua nuova).
- `testo`; `posx`, `posy`: coordinate; `color`: int; `font`: chiave della mappa `BEFonts` (parametro `fonts`).
- `align`: `C` centra, `posx` → 0.
- `note`: descrizione, presente solo sulle righe `ita`.
- Alla BE arriva la riga `codicefont|x|y|colore|testo` [V `:1244-1535`].

**`ecl_firmware`** (non in db-08). Catalogo dei firmware BE.
- `version`: `MMM.mmm.bbbb`, con `MMM` = famiglia: 131 giochi, 123/133 mangiaticket, 132 cassa/totem, 136 visualizzatore crediti, 900 app mobile.
- `tipoScheda` (`BE3`, `MT`, `RD`, `VS`, `PHO`) e `tipoFirmware` (`GAMES`, `MANGIAT`, `CASSATOT`, `VISCREDTK`, `MOBILE`).
- `filename` = `<version>.bin`; `url` = host HTTP del download (all'upload = host del broker); `path` = `/`.
- `msgCount`: numero di etichette della lingua supportate dal firmware (default 55).
- `firmwareBinaryData`: blob. Se manca → stato `warning` "file vuoto" [V `:677-693, 959-961, 2618-2630, 3203`].

**`ecl_SchedeFirmware`** (non in db-08). Anagrafica delle schede fisiche.
- `macaddress`: chiave, in **due formati**: con `:` per le BE, con `_` per i display Astoria.
- `device`: device assegnato, `'0z0z0'` = scheda vergine o non assegnata.
- `tipoScheda`/`tipoFirmware`: riclassificati dal prefisso della versione. Compaiono anche `TOTEM`, `CASSA`, `MANGIATICKET`, che la pulizia esclude.
- `requestedVersion`: versione richiesta in OTA. `dataAggiornamento`: data della richiesta.
- `detectedVersion`: versione riportata dalla BE. `bidetectedVersion`: versione della BI (`n/a` per il mobile).
- `dataVerifica`: ultimo boot visto, usato dalla pulizia.
- `status`: `Online` al boot, oppure lo stato dei messaggi `status` [V `:429-453, 640-719, 785-803, 3234-3253`; `mqttMessages.bas:134`].

**`ecl_Provisioning`** (non in db-08). (`macaddress`, `idImmagine`) = file già consegnato alla scheda; `idImmagine` = `CoinlessImages.id`, **0 = `lingue.txt`** [V `:2185, 2352, 2381`].

**`ecl_DeviceProvisioning`** (non in db-08). Un MAC di device non-game (cassa, totem, mangiaticket) già configurato; `updated` = data dell'invio (NULL appena inserito) [V `:2393-2445`].

**`Coinless_sbuilder_page_provisioning`** (non in db-08). Pagina dinamica consegnata.
- `idImmagine` = `coinless_sbuilder_pages.id`; `chiave` = `pagina_generata`.
- `pagina_su_be`: nome logico sulla BE (`Tap_to_play`, `ooo_qr`, `setup_qr`, `Happy_hour`) [V `:2261-2318`].

**`coinless_sbuilder_pages`** (non in db-08). Pagina generata per una macchina.
- `ClienteImpianto` = `<CodiceCliente>_<CodiceImpianto>`.
- `Codmac`: CodMac, oppure **MAC** per `setup_qr`.
- `NomeTemplate`; `pagina_generata`: nome del file che codifica i prezzi (§ 2 E04-21); `pagina_su_be` [V `:4445-4489`].

**`coinless_sbuilder_templates_svg`** (non in db-08). Template SVG per sala (`ClienteImpianto`), `NomeTemplate`, `pagina_su_be` di destinazione, `ImageBinaryData` [V `:4086-4123`].

**`BEConfig`** (non in db-08). Una riga per MAC; `DetectionDate` = ultimo aggiornamento.
- `BeInfo`: JSON `{macaddr, ver BE, ver BI, RowCount, IpAddress, RSSI, SPIFSSUsed, MaxEEDim, ValSetEEDim, EENumelemSave, EENumElemRd, StateRfid}`. `SPIFSSUsed = 0` vuol dire scheda formattata e innesca il reprovisioning.
- `BiConfig`: JSON `{LunghezzaImpulsoCoin, DimensioneForoTicket, DistanzaForiTicket, ImpulsiPerPartita, MoltiplicatoreImpulsiGettoniera, MoltiplicatoreImpulsiBanconote, DistanzaImpulsiGettoniera, TipoErogatoreTickets, TicketModeFromSystem (bit 7), SystemTicketMode (bit 6), chkDropAllTickets (bit 5, "modalità francesi"), chkDropTicketsIfCoin (bit 4, "modalità kevin")}`, dalle posizioni 0–6 e 9 dell'array `GetValBI`.
- `BeConfig`: non scritto in questa zona [V `DBcoinless.bas:4758-4911`; `DBwinmt.bas:13604-13650`].

**`ecl_log`** (non in db-08).
- `type`: categoria (`MQTT[in] MAIN`, `MQTT[in] SETUP`, `MQTT Main retain`, `MQTT Main`, `MQTT MAIN`, `MQTT Setup`, `MQTT CLOUD`, `TestMode`, `Armageddon`).
- `data`: payload o messaggio, `nvarchar(1024)`.
- `group`: topic, oppure CodMac, oppure `SYSTEM` [V].

**`debug_log`** (non in db-08). `testo` libero: prelievi da hub e spindle, vendite da distributore [V].

**`CraneCounterSyncLog`** (**precisa db-08**, che lo dà per "servizio esterno" [D]). È scritto dal motore B4J. PK (`CodMac`, `DataRil` della riga `EcsDati` elaborata); `DeltaIn6/7/8` = incrementi applicati come `WIN` (0 se reset) [V `DBCrane.bas:711-715`].

**`GruMovimenti`** (**integra db-08**). Il motore scrive `LOAD` (`UnitValue` = `Premi.Costo`), `UNLOAD`, `WIN` (`PrizeCode` NULL, `UnitValue` = media, `OperatorId` 0 se automatico, `Note` `AUTO ECSDATI <data>`). `ADJUST-` non lo scrive nessuno [V `DBCrane.bas:413-421, 987-995, 1190-1197`].

**`GruMagazzinoDettaglio.LastLoadDate/LastWinDate`** (db-08 [D] "chi li scrive"). Li scrive `DBCrane`: LOAD aggiorna `LastLoadDate`, WIN aggiorna `LastWinDate` [V `:408, 1185`].

### 4.4 Colonne note con significato diverso o in contraddizione con db-08

| Colonna | db-08 | Nel motore | Evidenza |
|---|---|---|---|
| `EcsMacchine.T0` | valore piatto/hopper (+ lunghezza contascatti) | **JSON di stato BI**: `{valorepiatto, statoBI, errBI, BISwap, NoRec}` | `DBcoinless.bas:247`; `DBwinmt.bas:10502-10510, 10796-10802` [V] — **contraddice db-08** (nella forma) |
| `EcsModuli.ShortAd` | IP del modulo EcsNet (versione precedente) | **device** della macchina (`<cliente>z<impianto>z<modu>`); l'IP è in `EcsModuli.T0` | `DBcoinless.bas:570-581, 3915-3921, 4734-4735` [V] — **contraddice db-08** |
| `EcsModuli.Id` contro `N0` | `N0` = `EcsMacchine.Modu` | `Id` = MAX+1 nel MERGE; una query fa ancora il join su `Id = Modu` | `DBcoinless.bas:581, 4606` [V] |
| `LivelloCard`/`TipoCard` della card | 0 Platinum, 1 Gold, 2 Silver, 3 VIP/Compleanno | **4 = card compleanni** nel ramo stato card | `ecs2mqtt.b4j:1721, 1755` [V] — **estende o contraddice db-08** |
| `TransCard.NImp = 0` | carico da postazione di cassa fissa | anche gli accrediti da cloud, app e kiosk-creazione utente (`addCreditiToUser`) | `DBcoinless.bas:3638` [V] |
| `TransCard.NImp = 1` | carico da totem | ricarica del totem Flutter (coerente) | `:3810` [V] |
| `TransCard.T0` | impianto su 4 cifre | NULL nelle righe di E04-04 ed E04-05 | `:168, 3615, 3645` [V] |
| `EcsMacchine.ValIn6/7/8` | valore unitario premio slot 1–3 (copia) | conferma; viene riscritto **a ogni `send_client`** di una gru | `ecs2mqtt.b4j:1679-1692` [V] |
| `setup2` IdPost 101 `typename_<tipo>` | — | JSON della configurazione di default per tipo macchina (cache di `CoinlessDefaultTypeConfig` del cloud) | `DBcoinless.bas:5827-5890` [V] — non in db-08 |

### 4.5 DDL eseguito dal codice

| Oggetto | Dove | Note |
|---|---|---|
| `CREATE TABLE ecl_log` (se manca) | `DBcoinless.bas:3094-3111`, all'avvio se `ecl_log` ≠ 0 | [V] |
| `CREATE TABLE pinkbox_log` | `DBcoinless.bas:3940-3961` | mai chiamato; contiene `GO`, che JDBC non accetta [V] |
| `CREATE TABLE coinless_sbuilder_templates_svg`, `coinless_sbuilder_pages`, `Coinless_sbuilder_page_provisioning`; `DROP/CREATE VIEW vs_CoinlessSpecialTimes` | `ScreenBuilder.bas:48-171` eseguiti da `DBcoinless.sbuilderMigration` (esecutore generico) | [V] |
| Controllo dell'esistenza di `save_ciapett` | `DBcoinless.bas:3131-3133` | morto [V] |

### 4.6 Struttura del record ECL (`cmd`)

Indici da 0, come in B4J (la stored procedure numera da 1). I valori multibyte sono little-endian (B4J li ribalta e converte con `HexToLong`) [V `DBcoinless.bas:3255-3548`; `decodifica_record.sql`].

| Byte | Tipo 7 (snapshot contatori) | Tipi 16/17/19/20/22/23 (card su BE con BI "nuova") | Tipi 8/13 (device via cavo, secondo la SP) |
|---|---|---|---|
| 0–3 | Header (3), risposta, **tipo**, numbyte (48) | idem | idem |
| 4–7 | — | **N0** progressivo card | N0 |
| 8–11 | — | Ticket (solo B4J) | — |
| 12–15 | **In1** gettoni/coin | **NuovoSaldo** (unità card = centesimi) | — |
| 16–19 | **In2** ticket | **UID card** (SP: 4 byte + `00000000`; B4J: 8 byte 16–23) | nuovo saldo |
| 20–23 | In3 | (UID, solo B4J) | UID card (SP) |
| 24–27 | In4 | costo partita (24–25); **livello** (26); punti/crediti (27) | — |
| 28–31 | In5 | SP: gg (28), mm (29), aaaa (30–31) | costo (28), livello (29), punti (30) |
| 32–35 | In6 (slot gru 1) | SP: hh (32), mi (33), ss (34); B4J: bonus basso (35) | — |
| 36–39 | In7 (slot gru 2) | bonus: B4J 35–36, SP 36–37 (**sfasamento**) | — |
| 40–43 | In8 (slot gru 3) | — | — |
| 44–47 | **partite** (→ `In9`) | — | — |
| 48 | tipocard (SP) | — | — |

### 4.7 Stato fuori dal DB

| Stato | Dove | Contenuto | Nota |
|---|---|---|---|
| `C:\ecs2mqtt\dbsettings.txt` (`File.WriteMap`) | `settingsmanager.bas:12-21`; `DbConfig.bas:172-257` | `SqlServer`, `MqttDefault`, `MqttSetup`, `coinlessServer`, `MasterIp`/`SlaveIp`, `Master`, `Primario`, `Connected`, `GamePark`, `ApplicationMode`, `tiketlessMode`, `ecl_log`, `mqtt_log`, `PrioritaBonus`, `ForceDecimalDisplay`, `currency`, `language`, `tokenReaderLabel(Row1)` (`x\|y\|size\|colore\|testo`), `txttokenreaderlblcrediti`, `fonts` (JSON), **`wlessssid`/`wlesspwd` (WiFi delle BE, in chiaro)** | [V] È configurazione di sala vera e propria, non sincronizzata |
| `DBcoinless.elencoFirmwareDisponibili` (Map) | `DBcoinless.bas:9, 875-905` | descrizione → querystring firmware | cache [V] |
| `Main.elencoMacchineMqttSetup` (List `device@mac@ip@stato`) | `DBcoinless.bas:4377-4394`; `mqttMessages.bas:974` | schede in setup; decide le pagine `setup` da generare | stato in memoria che pilota scritture DB [V] |
| `Main.BEFonts` (Map) | `DBcoinless.bas:1519` | codice font per chiave | da `settings.fonts` [V] |
| File delle pagine generate `www\resources\screens\<mac>\*.jpg` | `DBcoinless.bas:2027-2037` | immagini servite alle BE, CRC calcolato sul file | il DB registra il nome, il file è il dato [V] |
| `Main.Provisionerror`, `Main.versioneMacchineFirmware` | `mqttMessages.bas:120-130, 750-760` | tentativi ed errori di provisioning per MAC, versioni al boot | volatile [V] |

### 4.8 Sovraccarichi semantici

- `CoinlessImages` contiene sia le immagini sia i firmware BI (distinti dal suffisso `.srec`) [V].
- `ecl_Provisioning.idImmagine = 0` vale "file lingue" invece di un id [V].
- `coinless_sbuilder_pages.Codmac` contiene un CodMac oppure un MAC [V].
- `pagina_generata` codifica nel nome file i prezzi per livello: è usata come chiave e come dato [V].
- `ecl_SchedeFirmware.device = '0z0z0'` è un valore sentinella; `macaddress` ha due formati [V].
- `ecl_firmware.url` = host del broker MQTT [V].
- `EcsMacchine.T0` contiene un JSON di flag [V].
- `EcsMacchine.ValIn6/7/8` è valore dell'ingresso per tutte le macchine e valore medio del premio per le gru [V].
- `BiConfig.TipoErogatoreTickets` è il byte intero 9, i cui bit 4–7 sono anche flag di modalità [V `DBcoinless.bas:4875-4882`].
- `TransCard.NImp = 0` copre anche gli accrediti da cloud (§ 4.4).

---

## 5. Doppioni e sovrapposizioni con WinMT

1. **Scrittura del valore su card (W02-06).** Esistono tre implementazioni B4J (E04-04, E04-05, E04-06) oltre a `AddTransCard` di WinMT e ai trigger del DB. Divergono su `NImp`, `T0`, `ValoreCassa`, `N0`, sul modo di aggiornare `Clienti.Credito` (assoluto o incremento) e sulla transazione (tabella in § 2, E04-05). Solo `RicaricaCardTotem` è un porting fedele.
2. **Decodifica del record ECL.** È implementata in `decodificaStrutturaECL` (B4J) e in `decodifica_record` (SQL), con due differenze di posizione (bonus; UID del tipo 8). Il commento in `ecs2mqtt.b4j:1820-1823` dichiara l'intenzione di sostituire la procedura con `clsGestioneCliente`.
3. **Verifica UID ammesso (W02-11).** WinMT confronta i **primi 8 caratteri** dell'UID e può auto-inserire; il motore cerca l'UID esatto **oppure** il codbar, senza inserimento [V `DBcoinless.bas:4923-4927`].
4. **Recupero ed eliminazione card (W03-11).** Usano le stesse procedure `sp_ripristinacard`/`sp_eliminacliente`. WinMT però toglie anche la blacklist, stacca gli ospiti e controlla le tracce residue; il motore chiama solo la procedura (più `detachCustomerCard`, fuori zona) [V `APIHandler.bas:246-268`].
5. **Codici redeem (W04-18/W01-24).** Stessa procedura `sp_redeem_create`; la chiamata B4J è malformata (§ 6).
6. **Configurazione ECL (W04-01).** `Setup(101).AdmPass` è scritto da entrambi nello stesso formato; il motore non applica i default su campi vuoti.
7. **Catalogo modelli e creazione macchina (W08-01, W08-04, W08-06).** WinMT lavora sul DB di sala (`Type`/`Manuf`/`Machines` sincronizzate); il motore crea i modelli **nel DB di servizio cloud** e recupera la configurazione da altre sale. Le fonti di verità sono due [V].
8. **Gru (W07-11).** Lettura dello stato e forzatura del valore medio con la stessa procedura (WinMT ha il difetto sugli slot 2–3). Il motore è l'unico che carica, scarica e registra vincite.
9. **Magazzino premi (W06-03, W06-09, W06-13).**
   - `Crane_CreateArticle` crea premi con `N_Tickets = valore × 100`, fornitore `Elmac`, `Gru = 1`. In WinMT il prezzo in ticket è un dato di catalogo [V `DBCrane.bas:792-793`].
   - Il carico in gru usa `MovOut.Motivo = 'GRU'`, la causale italiana che l'inventario WinMT conta come "uscite verso gru" (coerente). Il rientro usa `MovMag.Motivo = 'CARICO'` e non `'GRU'`: l'inventario WinMT lo conta come carico ordinario e non come "entrate da gru" (`qgrui`) [V `DBCrane.bas:976`; `winmt-07` righe 197, 210].
   - Il motore non valorizza `NBolla`/`NOrdine` del `MovOut`, che `FrmKit` vuole come coppia obbligatoria [V].
10. **Migrazione dello schema all'avvio (W04-25).** Ognuno crea le sue tabelle; non c'è un unico registro di versione (il motore usa `DBwinmt.dbversion` come soglia: 20240625, 20260424).
11. **Provisioning dei moduli (W08-07).** WinMT comanda (`jProvisionable`, `jAdopt`), il motore esegue e scrive `EcsModuli`/`ecl_SchedeFirmware`: complementari, ma la regola "una scheda per device" sta solo nel motore.

---

## 6. Problemi e rischi

**Consistenza e transazioni**
- Le uniche transazioni sono `RicaricaCardTotem` e i metodi di `DBCrane`. `scriviTransazioneConCard` e `addCreditiToUser` aggiornano `Clienti` e inseriscono in `TransCard` con statement separati: un errore a metà lascia il credito disallineato [V].
- `N0 = MAX(N0)+1` su `TransCard` (E04-04, E04-05), `Id = MAX+1` su `EcsModuli`, `ID = MAX+1` su `Type`/`Manuf`/`Machines` **nel cloud condiviso da più sale**: tutti esposti a race [V `DBcoinless.bas:169, 581, 5607, 5645, 5690`].
- In `DBCrane`, le verifiche (`Crane_Exists`, giacenza `Premi`, stato dello slot) sono fatte prima di `BeginTransaction` o su un'altra connessione; `Premi.Quantita` può andare in negativo con carichi concorrenti [V `DBCrane.bas:313-377`].
- Vincite gru perse: un campione con delta che non trova giacenza va in rollback senza log e non viene più rielaborato (§ 2) [V logica, D effetto].
- Il record di servizio 19/20 azzera `In1` e `In3…In8` in una riga `EcsDati` [V SQL]. Per una gru il campione successivo produrrebbe un delta pari all'intero contatore cumulativo [D].
- `replicaMovimentoMobile`: il secondo `INSERT` in `CoinlessDati` (stesso `cmd`, `cnt = "0"`, `hmac = ""`) collide con l'indice unico dopo la prima volta, e comunque non passa la verifica HMAC [D].

**Robustezza**
- `Scrivilog` termina il processo (`ExitApplication2(-10)`) se non ottiene una connessione o se l'`INSERT` fallisce [V `DBcoinless.bas:3009, 3017`]. `ecl_log.data` è `nvarchar(1024)`: un payload MQTT più lungo darebbe "string or binary data would be truncated" e quindi l'uscita del processo [D, da verificare con le impostazioni ANSI della connessione JDBC].
- Volumi di `ecl_log`: con `ecl_log` e `mqtt_log` a 1 (i default di `settingsmanager.bas:23-28, 81-82`) si scrive una riga per ogni messaggio MQTT in ingresso e in uscita. In produzione: **1.020.638 righe in 41 giorni (≈ 25.000/giorno, ≈ 2 GB/anno)**; nel DB di test ≈ 1.000/giorno [V `docs/db/db-05-produzione-01.md:35,45`; `docs/db/db-03-risultati-01.md:146`]. Il motore non ha alcuna pulizia [V grep].
- Bug latenti verificati:
  - `ReadTemplate` interroga `coinless_sbuilder_templates_svg.ImageName`, colonna che non esiste (le colonne sono `id`, `ClienteImpianto`, `NomeTemplate`, `pagina_su_be`, `ImageBinaryData`) [V `:4143`; `db-02`].
  - `creaCodiceRedeem`: la stringa di chiamata ha `? ?` senza virgola e passa date e `CreatedBy` come `SQLFLOAT` [V `:5058, 5071-5073`].
  - `getLastPinkBoxLog` legge `msgCount`, che non esiste [V `:4009`].
  - `vs_CraneStatus` e `sp_crane_list` gestiscono solo il tipo 3, mentre `Crane_Exists` accetta 3, 9, 12, 17: `Crane_GetDetail` di un tipo 9/12/17 risponde "Gru non trovata" [V].
  - `ElencoLabels` va in errore se il font della riga manca in `BEFonts` [D `:1519`].
  - `TabellaFirmwareBIDisponibili` carica tutti i blob solo per elencarli [V `:916-937`].
- Replica cloud (E04-37): con `Connected = 0` la connessione va direttamente al server cloud e le tabelle "locali" (`WinMtSqlDB.dbo.*`) sono quelle del **cloud**, non della sala [D da `DBwinmt.bas:192-214, 10917-10970`]. La barra di avanzamento è disattivata, quindi non c'è riscontro.

**Sicurezza (senza segreti)**
- Credenziale `sa` del DB scritta nel codice [V `DBcoinless.bas:46-47`].
- Password del WiFi delle BE in chiaro in `dbsettings.txt` e mostrata nella pagina [V `DbConfig.bas:57, 226`].
- SQL costruito per concatenazione con dati esterni:
  - payload MQTT: `aggiornaDatiEcs` [V `:238-259`], `AggiornaProvisioning`, `AggiornaProvisioning_sbuilder_page` [V `:2184, 2196, 2273, 2310`];
  - parametro HTTP `macaddress` di `eclcommand`: `elencaSchedeFirmware` [V `:438, 452`];
  - lista dalla rete di setup: `generaElencoMacchineInSetup` [V `:4386`];
  - parametri di configurazione: `ElencoLabels`, `getBeVersionByIp`, `TabellaTemplatesDisponibili`, `ScriviPaginaGenerataDaTemplate` [V];
  - `sbuilderMigration` esegue qualunque statement gli venga passato [V `:4160-4179`].
- `/crane` GET senza autenticazione; nei POST l'operatore è preso dal body, non dal token: non c'è attribuzione affidabile dei movimenti di magazzino [V `CraneHandler.bas:54-75, 236, 274, 297, 468`].
- Il wizard scrive sul DB di servizio cloud di **tutto il cliente** da una sala, tramite linked server con diritti di scrittura distribuita [V `DBcoinless.bas:5412-5419`].

**Architettura (rispetto ai principi del progetto)**
- La logica della card è in tre posti: trigger e procedure SQL, `DBcoinless`, WinMT. È il contrario di "logica una sola volta lato server".
- La sincronizzazione con il cloud passa da tre canali indipendenti:
  - Sync Framework, esterno al motore: in produzione copre `ecl_*`, `BEConfig`, `CoinlessImages`, `coinless_sbuilder_*`, `Gru*` (anche `GruMovimenti`), ma **non** `CraneCounterSyncLog`, `CoinlessDati`, `CoinlessDecodedData`, `ecl_log`;
  - la replica manuale `replicaTabelle*`;
  - il linked server.
- Il motore non usa le tabelle `scope_*` [V grep] e partecipa al Sync Framework solo indirettamente, perché le sue scritture alimentano i trigger `_tracking`.

---

## 7. Domande aperte per il team

1. In produzione `coinlessServer` vale sempre `WinMtSqlDB`, cioè DB unico? Esistono ancora sale con `CoinlessDB` separato? Il nome fisso `WinMtSqlDB` come convive con `WinMtSqlDBNuovo`?
2. Bonus nel record card: byte 35–36 (B4J) o 36–37 (SP)? E l'UID del tipo 8: byte 16–19 o 20–23? Serve la specifica del protocollo firmware della BE.
3. `CraneCounterSyncLog`: in produzione ci sono righe con delta > 0? Se no, si conferma che le vincite automatiche falliscono per giacenza zero. Il magazzino gru va reso tollerante (giacenza negativa, o vincita senza giacenza)?
4. Chi consuma le API `/crane` (app handheld, PrizeHub, HQ)? Va previsto un operatore autenticato?
5. `addCreditiToUser` con `NImp = 0` e `ValoreCassa` = importo per le ricariche "CLOUD": è voluto? Gli accrediti online dovrebbero essere `NImp = 14` e senza contante, come in WinMT?
6. Livello card 4 = compleanno (motore) contro 3 = VIP/compleanno (db-08): quale codifica scrive la card?
7. Quale politica di conservazione per `ecl_log`, `CoinlessDati` e `CoinlessDecodedData`? È voluto che `mqtt_log` sia attivo di default in produzione?
8. Il wizard che crea `Type`/`Manuf`/`Machines` nel DB di servizio cloud è in uso? Nel nuovo sistema il catalogo dei modelli sarà per cliente (`DBSERVIZIO`) o globale?
9. Il firmware BI è salvato in `CoinlessImages` con `majorFirmware = '131'`: esistono BI per altre famiglie di BE?
10. `syncConfig` con `Connected = 0`: qualcuno lo usa? Il comportamento (copia interna al cloud) è noto?
11. Le pagine generate (file `.jpg` su disco) sono dati da migrare, o si rigenerano sempre dai template e dai prezzi?
