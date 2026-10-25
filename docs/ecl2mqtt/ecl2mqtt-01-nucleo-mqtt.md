# Galileo HQ — ecl2mqtt 01: nucleo, MQTT e protocollo ECL

**Stato:** bozza · **Responsabile:** Piero · **Aggiornato:** 2026-10-25

**Collegati:** [`ecl2mqtt-00-mappa.md`](ecl2mqtt-00-mappa.md) (mappa e sintesi trasversale). Nel testo, «zona NN» indica il documento ecl2mqtt NN.

**Fonte:** `legacy/ecl2mqtt/` versione 2.39.55 (path relativi a questa cartella). Modulo `Main` = `ecs2mqtt.b4j`. Confronto con `docs/winmt/*`, `docs/analisi/analisi-01-catalogo-flussi-winmt.md`, `docs/db/db-08-dizionario-dati.md`, `sql/codice-db/`.
**Legenda:** **V** = verificato nel codice · **D** = dedotto. Nessun segreto riportato: dove c'è, è indicato "credenziale nel codice (file:riga)".

---

## 0. Sintesi in dieci punti

1. **Un solo broker, due connessioni.** "main" e "setup" si collegano entrambe a `tcp://localhost` con le stesse credenziali (credenziale nel codice `ecs2mqtt.b4j:723`, `:1941`); i parametri `MqttDefault`/`MqttSetup` non servono più alla connessione (righe commentate `:719`, `:1930`). La separazione è solo **per spazio di topic** (`ElmacECL/…` contro `SetUp/…`), e il codice la attraversa di continuo (pubblica `SetUp/<mac>` dal client main, `eclcommand.bas:76`, `ecs2mqtt.b4j:3409`). **V**
2. **Il "cloud" via MQTT è il broker locale.** `InviaErroreSulCloud` e `InviaMessaggioSulCloud` pubblicano su `mqtt_main`, cioè su localhost (`ecs2mqtt.b4j:3982`, `:3995`); idem `ElmacAPI` → `ElmacAPIResponse`. Arrivano al cloud solo se il mosquitto di sala è in *bridge* verso Elmac: nel repository non c'è nessuna configurazione di bridge. **V** (codice) / **D** (bridge)
3. **Il cloud via SQL** passa da `DBwinmt.connectcloud`: con `Connected=1` usa il SQL Server locale e il *linked server* `[elmaccloud].`; altrimenti si collega direttamente a `winmt.elmaccloud.com:1433` (credenziali nel codice `DBwinmt.bas:203-204`, `:213-214`). Lo usano multilocale (`sp_last_trans`, `sp_preleva_punti`, `Tickets` di altre sale) e la replica di firmware, immagini e lingue. **V**
4. **Le sottoscrizioni si fanno una volta sola**, al termine dell'autodiscover (`Autodiscover.bas:101` → `ecs2mqtt.b4j:754`). Dopo una riconnessione al broker (`:708-752`, `:1918-1976`) non vengono rifatte: se il broker cade, il servizio resta connesso ma **sordo**. **V** (codice) / **D** (effetto, con *clean session* predefinita)
5. **Ridondanza master/slave** su due flag di `dbsettings.txt` (`Master`, `Primario`), un endpoint HTTP non autenticato (`/redundance/*`) e il broadcast UDP `SLAVEFIND`. Lo slave risponde a `SLAVEFIND` **con la password dell'amministratore WinMT** (riga `Operatori` Id 0, offuscata in modo reversibile) in chiaro sulla LAN (`Autodiscover.bas:242-267`). **V**
6. **Sicurezza debole su tutto il perimetro di sala.** `/eclcommand`, `/eclservices`, `/redundance`, `/config` non hanno autenticazione; l'HMAC calcolato in `eclcommand`/`eclservice` firma solo un timestamp e non viene mai verificato (`funzioni.bas:15-32`); `/config` sovrascrive `dbsettings.txt` e spegne il servizio (`config.bas:40-52`). L'unica verifica HMAC reale è nel trigger SQL `decodifica_flusso` sui record delle schede. **V**
7. **Doppioni con WinMT** nella scrittura di `TransCard` (ricarica e bonus della cassa mobile), nel bonus a scaglioni (porting di `ECL_BonusHandler`), nel login operatori (porting di `DecPWord`) e nella registrazione come postazione in `Setup`. Su multilocale ci sono **tre regole diverse** nello stesso programma per decidere `IdLong`/`IdContatto` (§ 5). **V**
8. **Sovraccarichi nuovi**: `EcsMacchine.T0` è usato come JSON di stato (`BISwap`, `NoRec`), in contrasto con db-08 (valore hopper); `TransCard.T0` riceve `Nimp` senza zeri; `Operatori` Id 1001-1009 riusati per l'operatore fittizio "Prizehub1". **V**
9. **Molto stato vive solo in memoria** (elenchi device online/offline/setup, stato "Ready", tentativi di provisioning, blacklist inviata, configurazione `Setup` 101 letta al boot) e va perso al riavvio; `dbsettings.txt` contiene configurazione e segreti (Wi-Fi delle schede). **V**
10. **Robustezza.** Un errore di scrittura del log MQTT su DB **termina l'applicazione** (`DBcoinless.bas:3009`, `:3017`, chiamato per ogni messaggio se `mqtt_log=1`); il `SetTime` è pubblicato *retained* su `ElmacECL` (`ecs2mqtt.b4j:3713`), quindi una scheda che si collega dopo riceve un orario vecchio. **V**

---

## 1. Moduli coperti

| Modulo | Righe | Ruolo |
|---|---:|---|
| `ecs2mqtt.b4j` (Main) | 4713 (codice da 122) | Avvio, configurazione, server HTTP/WS, due client MQTT, smistamento di tutti i messaggi, timer, programmazione BE, ridondanza, autorizzazioni backoffice |
| `mqttMessages.bas` | 1030 | Handler dei topic di annuncio, provisioning, stato BI/BE, visualizzatore |
| `ecl_cmds.bas` | 687 | Costruttore dei payload JSON del protocollo ECL verso le schede |
| `eclcommand.bas` | 911 | Endpoint `GET /eclcommand?command=…` (comandi da WinMT e da pagine HTML legacy) |
| `eclservice.bas` | 442 | Endpoint `/eclservices/*` per schede (lingue, immagini, firmware OTA) e app (login, card) |
| `eclwebutils.bas` | 39 | Reboot di rete da pagina WebSocket |
| `JsonCamelCaseECL.bas` | 179 | Conversione chiavi JSON in camelCase (risposte API cloud) |
| `Autodiscover.bas` | 534 | Discovery UDP 51049: risposte a schede, WinMT, totem, GiallOne, slave |
| `RedundaceHandler.bas` | 109 | Endpoint `/redundance/getstate|setprimary|resetprimary` |
| `settingsmanager.bas` | 122 | Lettura/scrittura `C:\ecs2mqtt\dbsettings.txt`, default, costanti di processo/errore |
| `funzioni.bas` | 439 | Utility: log, HMAC fittizio, `getSlaveStatus`, restart servizio, armageddon, bitmask |
| `utility.bas` | 415 | Risposte HTTP, invio file/immagini/firmware con notifiche WS, CRC |
| `SharedManager.bas` | 53 | Buffer degli ultimi 30 messaggi MQTT per la pagina MqttDebug |
| `config.bas` | 55 | Endpoint `/config`: riscrive `dbsettings.txt` e termina |
| `WINMtConfig.bas` | 367 | Configurazione letta da `Setup` 101 e `setup2`, registrazione postazione |
| `sicurezza.bas` | 357 | Token bearer (HMAC-SHA256), chiavi API, `DecPWord` (password WinMT) |
| `RequestThrottle.bas` | 140 | Debounce per chiave (lettura card PrizeHub) |
| `auditlog.bas` | 33 | Facciata verso `DBwinmt.AddAuditLog` (tabella `AuditLog`) |
| `WebSocketHandler.bas` | 121 | Registro delle pagine WS aperte e invio di toast |
| `DownloadsHandler.bas` | 26 | Contatori OTA/download, non usati |
| `FileHelper.bas` | 28 | Upload multipart (max 2 MB) in `TempDir` |
| `root.bas` | 24 | Handler vuoto, non registrato |

---

## 2. Flussi

Pesi secondo analisi-01 § 1 (S semplice, M più tabelle/regole, L complesso/transazionale/periferiche). R/W/D/DDL = lettura, scrittura, cancellazione, definizione.

| Id | Flusso | Descrizione | Trigger/attore | Peso | Tabelle | Evidenza | Equiv. WinMT | Rapporto |
|---|---|---|---|:-:|---|---|---|---|
| E01-01 | Avvio del servizio | Carica `dbsettings.txt` (o crea il default ed esce), controlla Master/Primario, apre i pool SQL, esegue la migrazione schema, avvia HTTP/HTTPS, legge macchine e ticketless, avvia autodiscover, broker e timer | Avvio servizio (NSSM) | L | `Setup` R; `vs_eclmacchine` R; `ecl_log` DDL; migrazioni `BEConfig` DDL (zona DB) | `ecs2mqtt.b4j:259-591`, `604-686`; `DBwinmt.bas:106-142`; `DBcoinless.bas:3082-3120` **V** | W10-01, W02-01 | complementare |
| E01-02 | Configurazione da WinMT e registrazione come postazione | Decodifica `Setup(101).AdmPass` (cliente, impianto, rapporti, valuta), `F9/F10`, `T6`, `N0`; si registra in `Setup` come postazione `PRIZEHUB01|` con `IDPost = MAX+1`, crea l'operatore "Prizehub1"; scrive `setup2.ecs2mqttVer` | E01-01 | M | `Setup` R/W (MERGE); `Operatori` R/W; `setup2` R/W | `WINMtConfig.bas:244-336`; `DBwinmt.bas:6766-6833`, `6835-6876`, `9182-9271` **V** | W02-02, W10-02 | **doppione** (identificazione postazione) |
| E01-03 | Ridondanza master/slave e failover | Il master al boot interroga lo slave (`/redundance/getstate`); si spegne se lo slave è primario o irraggiungibile; lo slave diventa primario con `setprimary`; `resetprimary` riavvia tutte le BE e spegne il master | Avvio; WinMT (`setprimary`); tecnico | M | `Operatori` R (password admin per `SLAVEFIND`) | `ecs2mqtt.b4j:417-427`, `604-656`; `funzioni.bas:177-205`; `RedundaceHandler.bas:31-110`; `Autodiscover.bas:242-267`, `355-359` **V** | W10-12 | complementare |
| E01-04 | Autodiscover UDP | Risponde su UDP 51049 a schede, WinMT, totem e GiallOne con IP del server SQL/MQTT, modalità, ora, codici impianto; annuncia sé stesso (`Hey ECL:`) per evitare due primari; registra i dispositivi GiallOne | Schede BE, WinMT, totem, GiallOne, slave | M | `ecl_SchedeFirmware`+`EcsModuli` R; `setup2` (IdPost 0) W; `Operatori` R | `Autodiscover.bas:75-103`, `151-301`, `304-482`; `model_setup.bas:83-130` **V** | W10-01 (client) | complementare |
| E01-05 | Presenza del server su MQTT e watchdog | Pubblica `ElmacECL/Server` *retained* (online/offline, *last will*); risponde a `ElmacECL/IsServerOnline` e `ECLClients/Watchdog/IsServerOnline` | Connessione broker; schede; WinMT ogni 30 s | S | — | `ecs2mqtt.b4j:722-725`, `789-801`, `880-891`, `940-959` **V** | W10-16 | complementare |
| E01-06 | Stato online/offline dei device | Da `ElmacECL/<tipo><device>/<mac>/status` aggiorna gli elenchi in memoria e `EcsMacchine` (`device_status`, contatori on/off); per `reader/mangiat/viewer` aggiorna `ecl_SchedeFirmware.status`; scarta e registra i device di un altro impianto | Schede (LWT/annuncio) | M | `EcsMacchine` W; `ecl_SchedeFirmware` W/D | `ecs2mqtt.b4j:1292-1450`, `4649-4692`; `DBwinmt.bas:1233-1291`; `DBcoinless.bas:3234-3253` **V** | W08-07 (legge `device_status`) | complementare |
| E01-07 | Stato setup dei device | Da `SetUp/<tipo><device>/<mac>/status` aggiorna l'elenco "in setup" e `EcsMacchine.device_status='Setup'` | Schede in setup | S | `EcsMacchine` W; `ecsmoduli` R | `ecs2mqtt.b4j:2051-2055`; `mqttMessages.bas:943-988` **V** | — | solo B4J |
| E01-08 | Annuncio scheda e provisioning file | Da `SetUp/<tipo>/macaddr` salva info BE (`BEConfig`), firmware rilevato, decide file mancanti (testi, immagini, schermate generate) e pubblica `updatelist`; per device non-game invia la configurazione compatta | Scheda all'accensione | L | `BEConfig` W; `ecl_SchedeFirmware` R/W; `ecl_Provisioning` R/W; `ecl_DeviceProvisioning` R/W; `CoinlessImages`, `CoinlessLanguages`, `ecl_firmware`, `coinless_sbuilder_pages` R | `ecs2mqtt.b4j:2062-2113`; `mqttMessages.bas:38-463` **V** | — | solo B4J |
| E01-09 | Eventi di provisioning | `ElmacECLEvents/<mac>/<device>` e `SetUp/provisioned`: segna i file ricevuti, conta i tentativi falliti (in memoria), a fine scarico riavvia o rimanda la lista | Scheda | M | `ecl_Provisioning` W; `Coinless_sbuilder_page_provisioning` W; `ecl_SchedeFirmware` R | `mqttMessages.bas:465-723`, `821-880`; `ecs2mqtt.b4j:933-936`, `2140-2146` **V** | — | solo B4J |
| E01-10 | Scheda pronta e configurazione in attesa | `StateBE/<mac>/<device>`: segna "Ready"; se `EcsMacchine.F0=1` (modifica pendente da WinMT) mette la macchina in coda di riprogrammazione, altrimenti invia l'eventuale happy hour attivo | Scheda | M | `EcsMacchine`, `EcsModuli`, `ecl_SchedeFirmware` R; `vs_CoinlessSpecialTimes` R | `ecs2mqtt.b4j:902-907`; `mqttMessages.bas:882-941`; `DBwinmt.bas:832-888` **V** | W08-07, W08-12 (WinMT scrive `F0`) | complementare |
| E01-11 | Stato BI e riprogrammazione automatica | `ElmacStatusBI/<mac>` (valori `GetValBI`) salvato in `BEConfig.BiConfig`, confrontato con la configurazione attesa; se diverso, accoda la riprogrammazione (salvo swap BI in corso). `ElmacECL/<dev>/Bi` e `SetUp/<x>/UpdateBI` aggiornano lo stato di aggiornamento BI | Scheda | M | `BEConfig` W; `ecl_SchedeFirmware`+`EcsMacchine` R | `mqttMessages.bas:753-819`; `ecs2mqtt.b4j:1014-1046`, `2114-2136` **V** | — | solo B4J |
| E01-12 | Record di gioco dalla scheda (`send_client`) | Il record ECL (`cmd`, ≥ 40 campi) è inserito in `CoinlessDati` (il trigger verifica l'HMAC e chiama `decodifica_record`); per gru elabora i contatori incrementali; per le transazioni card (tipo 8/16) legge il cliente e risponde `ValCard` alla scheda; poi riallinea la blacklist | Scheda BE (ogni evento) | L | `CoinlessDati` W (→ trigger); `ecsmacchine` R; `Clienti`, `TransCard` R; tabelle gru (zona DBCrane) | `ecs2mqtt.b4j:1504-1851`; `DBcoinless.bas:222-277`; `sql/codice-db/prod/applicativo/trigger/decodifica_flusso.sql` **V** | W04-26 (esterno) | complementare (B4J scrive, il DB decide) + **doppione** sulla validazione card (§ 5) |
| E01-13 | Partita autorizzata dal server (modalità online) | `send_client` con `GetCred` o lettura codice su `comdevice/<device>/stream`: il server verifica il saldo, scala crediti/bonus (priorità da `PrioritaBonus`), scrive il movimento e risponde; per i codici `CD…` sblocca anche il contapersone (`device`+10000) | Scheda in modalità online; lettore QR/barcode | L | `Clienti` W; `transcard` W; `EcsMacchine`, `vs_CoinlessSpecialTimes` R; `EcsDati` W (se `ApplicationMode`≠ECL); `Tickets` (bonus) | `ecs2mqtt.b4j:1532-1576`, `1866-1906`; `clsGestioneClienteOnline.bas:93-197`; `DBcoinless.bas:125-184` **V** | W04-26 (logica di addebito nel DB) | **doppione** |
| E01-14 | Card compleanno in gioco | Per card con livello 4 controlla se il compleanno è attivo e la sequenza di partite consentita; risponde con stato 1/4/5 e registra la partita dell'ospite | E01-12 | M | `Compleanni`, `Ospiti`, `PartiteOspiti` R/W | `ecs2mqtt.b4j:1723-1733`, `1755-1782`, `1815-1824` **V**; dettaglio in `clsCompleanni.bas` | W03-19, W03-20 | complementare |
| E01-15 | Ticket vinti accumulati per card | `ElmacECL/Buffers/<dev>/Tickets/Cards/<card>`: accumula i ticket in `CoinlessDataBuffer`; con valore 0 (fine sessione) li accredita al cliente se ticketless e risponde `ValTickets` | Scheda BE | L | `CoinlessDataBuffer` R/W; `clienti` R/W; `tickets` W; `Setup` R | `ecs2mqtt.b4j:1082-1098`, `4241-4351`; `DBcoinless.bas:1093-1154`; `DBwinmt.bas:2703-3001` **V** | W05-01, W01-06 (consumano `Tickets`) | complementare |
| E01-16 | Rimborso partita con card operatore | `ElmacECL/Refounds/<codmac>` con `opCardId` e `playerCardId`: se l'operatore è attivo e abilitato (`F0`), autorizza e registra un movimento `TransCard` tipo 12; se disabilitato prova a metterlo in blacklist | Operatore alla macchina | M | `Operatori` R; `clienti`, `TransCard` R; `TransCard` W (`NImp`=12); `CoinlessCards` (scrittura disattivata) | `ecs2mqtt.b4j:1099-1291`; `DBwinmt.bas:4275-4314`, `6712-6760`; `DBcoinless.bas:2973-2998` **V** | — (WinMT legge il tipo 12 nei report) | complementare |
| E01-17 | Cassa mobile | `ElmacECL/TransCards/<dev>/<azione>`: saldo cassa operatore, ricarica (con bonus ticket a scaglioni), bonus crediti, "pronto a scrivere"; risposta su `ElmacECL/<dev>/cassaMobile` | Dispositivo ECL mobile (fw 900) | L | `TransCard` R/W (`NImp` 2 e 6); `Tickets` W (bonus); `Setup` R (`T10/T12`); `Operatori`, `clienti` R | `ecs2mqtt.b4j:1451-1503`; `DBwinmt.bas:4384-4631`, `15425-15462`; `ECL_BonusHandler.bas` **V** | W05-02, W02-18, W04-13 | **doppione** |
| E01-18 | Stato card per visualizzatore | `VS/<codice>` con `cardid`/`codbar` (eventuali crediti/bonus): legge il cliente e risponde `ValCard` sul topic del visualizzatore | Visualizzatore crediti (fw 136) | S | `clienti`, `TransCard` R | `ecs2mqtt.b4j:893-895`; `mqttMessages.bas:725-751`; `ecs2mqtt.b4j:4241-4463` **V** | W04-04 (lettura cliente) | complementare |
| E01-19 | Info macchina e operatori su richiesta | `ElmacECL/GetMachineInfo/<dev>` → `ElmacECL/ReplyMachineInfo/<dev>`; `ElmacECL/GetOperatori/<dev>` → `ElmacECL/operatori/<dev>` *retained* con lo SHA-256 salato delle card operatore attive | Scheda/dispositivo mobile | S | `EcsMacchine`, `Setup`, `operatori` R | `ecs2mqtt.b4j:961-982`; `DBwinmt.bas:1674-1717`, `4225-4273` **V** | — | solo B4J |
| E01-20 | Push della blacklist | Compone le ultime 21 card bloccate (`Clienti.D1`, log blacklist, card clonate) e, se cambiate, pubblica `ElmacECL/BlackList` *retained*; dopo ogni `send_client` e su richiesta WinMT `jrefreshBlacklist` | E01-12; WinMT | M | `Clienti`, `CoinlessLogEventiBlacklist`, `CoinlessClonedCards` R | `DBwinmt.bas:1785-1893`; `ecs2mqtt.b4j:1850`; `eclcommand.bas:591-599` **V** | W01-14, W04-04 | complementare |
| E01-21 | Special time / happy hour e controlli periodici | Timer 40 s: chiede i contatori alle macchine senza dati oggi, attiva/disattiva happy hour sulle macchine online, aggiorna i compleanni attivi; alla sottoscrizione riallinea lo stato sul DB | Timer `controlloMacchine` | L | `vs_CoinlessSpecialTimes`, `EcsModuli`, `CoinlessDecodedData`, `ecl_SchedeFirmware` R; `EcsMacchine` W (`is_happyhour`); `compleanni`, `Ospiti`, `PartiteOspiti` R | `ecs2mqtt.b4j:672-674`, `802-803`, `3073-3117`; `DBwinmt.bas:1719-1783`, `1895-2203`, `2310-2362` **V** | W04-17, W08-14 | complementare |
| E01-22 | Sincronizzazione orario | Ogni ~5,5 min (11 tick da 30 s) pubblica `SetTime` *retained* su `ElmacECL` e non retained su `SetUp`; solo se non è slave secondario | Timer `inviaOrario` | S | — | `ecs2mqtt.b4j:670`, `3680-3718` **V** | — | solo B4J |
| E01-23 | API cloud via MQTT | `ElmacAPI/<metodo>` (AuthUser, CreateUser, AddCreditToUser, getMovimentiCard…) elaborato da `clsElmacAPI`, risposta su `ElmacAPIResponse/<metodo>`; solo il primario risponde | Cloud/app Elmac (via broker) | L | vedi zona API (`clsElmacAPI.bas`) | `ecs2mqtt.b4j:912-931`; `clsElmacAPI.bas:29-147` **V** | W03-01, W05-02 (stesse entità) | da valutare nella zona API |
| E01-24 | Comandi remoti dal cloud | `ElmacECL/Server/command` (`macchine` → stato e incassi 12 h su `ElmacECL/Server/macchine`), `…/command/jinsetup` → elenco device in setup su `…/answers/jinsetup/<mittente>`, `…/jsetFromWinmt` → programma una BE | Cloud (via broker) | M | `vs_eclmacchine`, `fn_dati_grafico_giornaliero`, `fn_EcsDatiGiornalieri` R; E01-26 | `ecs2mqtt.b4j:989-1012`, `1047-1077`; `DBwinmt.bas:5937-6005` **V** | — | solo B4J |
| E01-25 | Errori e avvisi | Errori di parsing/crash pubblicati su `Errors/<Nimp>/<livello>`; avvisi in memoria (FIFO 50) per la dashboard; log di ogni messaggio MQTT in `ecl_log` se `mqtt_log=1` | Tutti i flussi | S | `ecl_log` W | `ecs2mqtt.b4j:3979-3999`, `4704-4714`, `842-844`; `DBcoinless.bas:3000-3024` **V** | — | solo B4J |
| E01-26 | Programmazione di una BE da `EcsMacchine` | Costruisce i comandi (Wi-Fi, memoria BI, contatori, crediti per livello, relè, ticketless, time play) da `EcsMacchine` e li invia in setup, in sequenza o in forma compatta `SetTotVal` secondo il firmware; varianti: assegna BE a CodMac, riscrivi, figlio mobile, reboot | WinMT (`jSetupDevice`, `jAdopt`), pagine backoffice, cloud | L | `vs_eclmacchine`, `EcsDati` R; `EcsMacchine` W (`F0`); `EcsDati` W/D (azzeramento); `ecl_SchedeFirmware` R; `coinless_sbuilder_pages` R/W | `ecs2mqtt.b4j:3165-3659`, `3759-3932`; `DBwinmt.bas:3356-3777` (zona DB) **V** | W08-07, W08-12 | complementare |
| E01-27 | Comandi HTTP `/eclcommand` | ~50 comandi GET: reboot, setup/online, fuori servizio, provisioning, elenchi JSON/HTML, rigenerazione schermate, contatori, listino, info card | WinMT, pagine HTML legacy | M | varie (R su `EcsMacchine`, `Clienti`, `Setup`; W indirette) | `eclcommand.bas:17-895` **V** | W08-07, W04-04, W03-02 | complementare |
| E01-28 | Servizi HTTP `/eclservices` | GET per schede: testi (`getlanguage`), immagini statiche e generate, template, firmware OTA; GET `getkioskconfig`, `getscalettabonus`; POST `login`, `getCardInfo`, `getOperationList` | Schede BE/BI (HTTP), app/totem | M | `CoinlessLanguages`, `coinlessimages`, `coinless_sbuilder_pages`, `coinless_sbuilder_templates_svg`, `ecl_firmware`, `BEConfig` R; `operatori`, `Clienti`, `TransCard` R | `eclservice.bas:21-402` **V** | — | solo B4J |
| E01-29 | Fuori servizio / in servizio | Mette la macchina in stato `OOO` su DB, azzera l'happy hour e invia `OutOfService` su `Service/<mac>` | WinMT (`jOutOfService`), app di servizio | S | `ecsmacchine` W | `ecs2mqtt.b4j:4618-4637`; `DBwinmt.bas:12891-12970` **V** | W08-07 | complementare |
| E01-30 | Pulizie periodiche | Ogni 30 min elimina le schede mai assegnate ferme da 4 h; ogni 5 min chiude le sessioni di test mode più vecchie di 60 min (senza ripristino contatori) | Timer | S | `ecl_SchedeFirmware` D; `setup2` D (`TestMode_<codmac>`); `ecl_log` W | `ecs2mqtt.b4j:680-706`; `DBwinmt.bas:10357-10387` **V** | — | solo B4J |
| E01-31 | Coda aggiornamenti firmware/configurazione | Timer 5 s che fa avanzare le code di programmazione BE e BI | Timer `gestioneAggiornamenti` | M | zona programmatori | `ecs2mqtt.b4j:676-677`, `4225-4239` **V** | — | solo B4J |
| E01-32 | Login backoffice e permessi pagine | Login con nome+password (password WinMT decodificata) o QR del codice operatore; pagine riservate al superadmin (`Operatori.Id = 0`) | Operatore/superadmin via browser | M | `Operatori` R | `LoginPage.bas`; `DBwinmt.bas:6100-6195`; `ecs2mqtt.b4j:4111-4208` **V** | W10-06, W10-07 | **doppione** |
| E01-33 | Riconfigurazione remota `/config` | Riceve un JSON `settings`, **svuota** la mappa, salva solo 6 chiavi in `dbsettings.txt` e termina il processo | Chiunque in rete | S | file `dbsettings.txt` | `config.bas:18-52` **V** | — | solo B4J |
| E01-34 | Replica verso/dal cloud e multilocale | Copia `CoinlessImages`, `ecl_firmware`, `bi_firmware`, `CoinlessLanguages` tra DB locale e `coinlessdb` cloud; per multilocale chiama `sp_last_trans`, `sp_preleva_punti` e legge `Tickets` del DB di altri locali | Pagine backoffice (sync), prelievo premi | M | tabelle citate R/W (cloud); procedure cloud | `DBwinmt.bas:192-220`, `7862-8430`, `10904-11060` **V** | W02-16, W08-22 | **doppione** (multisala) |
| E01-35 | Debug MQTT in pagina | Gli ultimi 30 messaggi (main e setup) sono inoltrati alle pagine `MqttDebug` aperte | Superadmin | S | — | `SharedManager.bas:42-50`; `ecs2mqtt.b4j:876`, `2021` **V** | — | solo B4J |

### Dettaglio dei flussi L e dei doppioni

**E01-01 Avvio.** Ordine: default in memoria → `dbsettings.txt` (se manca: crea default, salva ed esce con −1, `:569-575`) → se `Master=1` e `Primario=0` esce (−2, riattivazione manuale) → pool `CoinlessDB` o `WinMtSqlDB` (scelta da `SlaveIp/MasterIp/GamePark/coinlessServer`, `DBcoinless.bas:14-51`) → pool `WinMtSqlDb` + `CheckDbMigration` → `StatusBiTicketMode/ForceBiTicketMode` sovrascritti con `Setup(101).F9F10` ("vince il DB", `:453-455`) → HTTP 58889 e HTTPS 58443 (keystore `C:\ecs2mqtt\keystore`, credenziale nel codice `ecs2mqtt.b4j:3736-3737`); se la porta è occupata esce (−2, istanza già attiva) → `leggimacchine`, moltiplicatori, ticketless, controllo log → ridondanza (E01-03) → broker → `WINMtConfig` → `connectcloud` → timer → autodiscover, che solo alla fine **sottoscrive i topic**. Se il DB non risponde dopo 15 tentativi (senza pausa: lo `Sleep` è commentato, `DBwinmt.bas:120`) il servizio esce. **V**

**E01-02 Registrazione postazione (doppione).** Come una postazione WinMT, il servizio si identifica in `Setup` per `MName`: `MERGE` con `MName = 'PRIZEHUB01|'`, `IDPost = MAX(IDPost)+1`, `NImp` della riga 101 (`DBwinmt.bas:6789-6797`). Differenze rispetto a WinMT (db-08 `MName`): nessun carattere di porta dopo `|`; il nome è fisso (`WINMtConfig.bas:289`, l'hostname reale è commentato); `MAX+1` non rispetta la semantica delle righe di `Setup` (101, 102, 110, > 110 = serie delle raccolte) **D**. Crea anche l'operatore `Prizehub1` con `Id = COUNT(id tra 1001 e 1009)+1001`, `Livello 2` (`DBwinmt.bas:6835-6876`): stesso intervallo degli operatori fittizi `TotemPrizes` di WinMT (db-08 `Operatori.Nome/Id`), con rischio di collisione **D**.

**E01-12 Record di gioco.** Il payload `send_client` è `{"device","cmd","cnt","hmac"[,"Status"]}`; `cmd` è la struttura ECL in decimale separata da `;`. Il servizio non decodifica né verifica l'HMAC: inserisce in `CoinlessDati` concatenando i valori nella stringa SQL (`DBcoinless.bas:236-262`), escludendo le macchine con `EcsMacchine.T0` che contiene `"BISwap":1` o `"NoRec":1`; `Status=2` marca `FlagOpDaVerificare=1` (dalla versione DB 20240625). Il trigger `decodifica_flusso` ricalcola l'HMAC con `fn_calcHMAC` e solo se coincide chiama `decodifica_record` (`decodifica_flusso.sql:24-30`). Dopo l'inserimento, per i tipi 8 e 16 il servizio rilegge il cliente e risponde `ValCard` con `Stato` 1 autorizzato, 2 card sconosciuta, 3 non autorizzato, 4 compleanno senza costo, 5 compleanno non consentito (`:1701-1810`; codici dei rami). La risposta è calcolata **dopo** che il trigger ha già aggiornato saldo e blacklist (stesso thread, nessuna transazione esplicita) **D**. Per le gru, dalla versione DB 20260424, `DBCrane.Crane_ProcessIncrementalCountersByDevice` (`:1679-1692`).

**E01-13 Partita online (doppione).** In modalità "full online" il credito non è sulla card: `CanPlay` confronta `Clienti.Credito` con il prezzo (`getGamePrice`, che considera gli special time) e scrive il movimento con `scriviTransazioneConCard` (UPDATE `Clienti` + INSERT `transcard`), scegliendo l'ordine bonus/crediti con il parametro di file `PrioritaBonus` (`clsGestioneClienteOnline.bas:110-186`). È la stessa regola di addebito che, in modalità card, applica `decodifica_record`/`aggiornaCard` nel DB (W04-26): due implementazioni dell'addebito partita, una in SQL e una in B4J, con il parametro di priorità in posti diversi **D**. Se `ApplicationMode` ≠ `ECL` aggiunge anche una partita in `EcsDati` (`DBwinmt.bas:12626-12654`).

**E01-15 Ticket per card.** La regola "la card è ticketless?" è: card nulla → sì; se `flagstkless[0]='0'` (scelta lasciata al cliente) legge `Clienti.N0`, altrimenti usa `flagstkless[1]` (`DBcoinless.bas:1101-1114`). È la stessa regola di WinMT su `F9/F10` e `Clienti.N0` (db-08), ma `Clienti.N0` ha in WinMT due convenzioni opposte e un valore 2 non spiegato: qui vale solo `=1` **V**/**D**. La scrittura effettiva in `Tickets`/`Clienti` dipende anche da `tiketlessMode` di `dbsettings.txt` (`DBwinmt.bas:2867`): un parametro di sala che vive fuori dal DB **V**.

**E01-17 Cassa mobile (doppione).** Ricarica: `INSERT TransCard` con `NImp=2`, `CodMac='CASSA-MOBILE'`, `WinMt=1`, `F0=0`, `T0=Nimp`, `N0=progressivo` della card; bonus: idem con `NImp=6` (`DBwinmt.bas:4384-4524`). Il bonus ticket sulla ricarica usa la scala `Setup.T10/T12` con `ECL_BonusHandler`, porting dichiarato della classe VB6 (`ECL_BonusHandler.bas:7-15`). Differenze rispetto a WinMT (`AddTransCard`, db-08): `F0` sempre 0 anche in multilocale (WinMT: 1 se multilocale); `T0` = `Nimp` numerico senza zeri (WinMT: 4 cifre); `Data` = `getdate()` (WinMT: testo dipendente dal DATEFORMAT); `IdCli` scelto con "`T6` non vuoto" (§ 5). Il saldo della cassa operatore è `SUM(ValoreOperazione)` dei movimenti `NImp=2`, `WinMt=1`, `D0` nullo (`DBwinmt.bas:4578-4631`), stessa logica di chiusura cassa di W04-13 ma ristretta al tipo 2. Nessun controllo di duplicato sul progressivo: un messaggio ripetuto crea una seconda ricarica **D**.

**E01-21 Happy hour.** Il timer non configura nulla: legge la configurazione scritta da WinMT (W04-17) tramite `vs_CoinlessSpecialTimes` e la applica (`SetHappyH` con percentuali per livello e sfondo `/<mac>/Happy_hour.jpg`; `ResHappyH`), scrivendo `EcsMacchine.is_happyhour` (`DBwinmt.bas:1976-2203`). Lo stato globale "happy hour in corso" è solo in memoria (`Main.HappyHourIsRunning`) **V**.

**E01-26 Programmazione BE.** La scelta del metodo dipende dalla versione firmware letta da `ecl_SchedeFirmware`: `131.110+` → comando compatto `SetTotVal` sul topic di setup; `900` (mobile) o `131.101+`/build > 0015 → `programmaDevice` (prima mette la scheda in setup, attende fino a 20 s); altrimenti la sequenza classica di sei messaggi con pause (`ecs2mqtt.b4j:3403-3428`, `3569-3648`). Durante la programmazione i timer happy hour e orario sono spenti (`controlloMacchine.Enabled=False`, `inviaOrario.Enabled=False`). Le versioni sono confrontate **come stringhe** (`minor >= "110"`, `build > "0093"`), corretto solo finché hanno la stessa lunghezza **D**.

**E01-32 Login (doppione).** Utenti = tabella WinMT `Operatori`. `UserLogin` cerca per `Nome` e confronta la password decodificata con `sicurezza.DecPWord` (porting del `DecPWord` VB6, reversibile); il controllo "solo superadmin" è commentato (`DBwinmt.bas:6128`), quindi entra qualunque operatore con password, anche non `Attivo`. `LoginByOperatorCode` usa `CodBar` e `Attivo`. Differenze rispetto a W10-06/W10-07: WinMT accede per card RFID (`T0`) e profila i menu per `Livello And 3`; qui il livello è salvato in sessione ma `ValidateUsers` non lo usa (`ecs2mqtt.b4j:4118-4127`, ramo vuoto) e l'unico ruolo distinto è `Id = 0`. Esiste un secondo login per app (`eclservice` `login` → `DBwinmt.loginUtente`) che costruisce l'SQL con `'$cardid'`/`'$password'` come testo letterale (non interpolato) e confronta la password in chiaro con quella offuscata: probabilmente non funziona **D** (`DBwinmt.bas:8805-8862`). `WINMtConfig.DecPWord` è una terza versione, non usata e scorretta **D**.

**E01-34 Multilocale (doppione).** Il punteggio in altri locali (`ricalcolaTicketsInAltroLocale`, `prelevapuntidaaltrolocale`) e il saldo multilocale (`sp_last_trans` sul DB `DbClientiMultilocale`, default `rdclienti`) replicano le funzioni di WinMT W02-16/W08-22 e le procedure cloud già censite in winmt-00 § "procedure solo nel cloud" **V**.

---

## 3. Interlocutori

### 3.a Topic MQTT

Broker: un solo mosquitto su `localhost:1883` (default jMQTT **D**), utente `ECL` (credenziale nel codice `ecs2mqtt.b4j:723`, `:1941`). "main" e "setup" sono **due client** sullo stesso broker. Le schede ricevono dall'autodiscover `ProductionMqtt = SetupMqtt = SqlServer` (`ecs2mqtt.b4j:579`) e nel comando Wi-Fi `mqtt_s = MqttDefault` (`ecl_cmds.bas:326-342`). QoS: `inviaComandoECL` usa `Publish` (QoS predefinito della libreria **D**); `inviaComandoECLSETUP` e `inviaComandoECLretained` QoS 1; gli altri `Publish2` QoS 0. Sottoscrizioni tutte QoS 0.

**Sottoscritti (in ingresso)**

| Topic | Client | Mittente | Payload | Handler → effetto | Evidenza |
|---|---|---|---|---|---|
| `ElmacECL/+/+/status` (`ElmacECL/<Client|reader|mangiat|viewer|vs><device>/<mac>/status`) | main | Schede (anche LWT) | `Online`/`Offline` | E01-06; `EcsMacchine` W | `:760`, `:1292-1450` |
| `send_client` | main | Schede BE, mobile | JSON `device,cmd,cnt,hmac[,Status]` / `GetCred,ValGame` / `PutTicket,Punti` (ignorato) / `MobileFConnect` | E01-12/13; `CoinlessDati` W; `MobileFConnect` → `replicaMovimentoMobile` | `:761`, `:1504-1851` |
| `ElmacECL/BlackList` | main | sé stesso (retained) | lista card | nessun effetto: cade nel ramo `ElmacECL` a 2 livelli che gestisce solo `IsServerOnline`; il `Case "BlackList"` è al primo livello e non è raggiungibile | `:762`, `:940-960`, `:1852` |
| `ElmacECL/GetMachineInfo/+` | main | Scheda/mobile | — | E01-19 | `:763`, `:961-974` |
| `ElmacECL/GetOperatori/+` | main | Scheda/mobile | — | E01-19 | `:764`, `:975-982` |
| `ElmacECL/Buffers/+/Tickets/Cards/+` | main | Scheda BE | `{n}` | E01-15; `CoinlessDataBuffer`, `Tickets`, `Clienti` W | `:765`, `:1082-1098` |
| `ElmacECL/TransCards/+/+` | main | ECL mobile | JSON `operatore,cliente,importo,saldo,progressivo` | E01-17; `TransCard` W | `:766`, `:1451-1503` |
| `ElmacECL/Server/+` | main | Cloud **D** | `command`=`macchine`; `jsetFromWinmt`=`{CodMac,macaddress}` | E01-24/26 | `:767`, `:989-1012` |
| `ElmacECL/IsServerOnline` | main | Schede, WinMT < 2.36 | — | E01-05 | `:768`, `:940-959` |
| `ElmacECL/Server/command/+` | main | Cloud **D** | `jinsetup {remotesender}`, `jsetFromWinmt {CodMac,macaddress}` | E01-24 | `:769`, `:1048-1077` |
| `ElmacECL/Refounds/+` | main | Scheda BE | `{opCardId,playerCardId}` | E01-16; `TransCard` W | `:770`, `:1099-1291` |
| `ECLClients/Watchdog/IsServerOnline` | main | WinMT ≥ 2.36 | — | E01-05 | `:772`, `:880-891` |
| `ElmacStatusBI/+` | main | Scheda BE | `{"msg":"GetValBI","GetValBI":[…]}` | E01-11; `BEConfig` W | `:774`, `:908-910` |
| `VS/+` | main | Visualizzatore | `{cardid|codbar[,crediti,bonus]}` | E01-18 | `:775`, `:893-895` |
| `comdevice/+/stream` | main | Lettore codici su device | testo (`CD…` 11/14 car., o UID 16) | E01-13 | `:776`, `:1866-1906` |
| `StateBE/+/+` | main | Scheda BE | — | E01-10 | `:779`, `:902-907` |
| `ElmacECL/+/Bi` | main | Scheda BE | `{"msg":"StateConnWorkBI",StateUpdateBI,MsgErrBI}` | E01-11 (stato in memoria del programmatore BI) | `:780`, `:1014-1046` |
| `ElmacAPI/+` | main | Cloud **D** | JSON con `sessionUID` | E01-23 | `:782`, `:912-931` |
| `ElmacECLEvents/+/+` | main | Scheda | `{errorcode,process,obj,description}` | E01-09; `ecl_Provisioning` W | `:784`, `:933-936` |
| `ECLservice/+/+` | main | Cellulari di servizio **D** | — | solo log (stub) | `:786`, `:897-898`; `serviceHandler.bas:19-46` |
| `SetUp/#` | setup | Schede in setup e **sé stesso** | vari | `…/<x>/<mac>/status` E01-07; `…/<x>/macaddr` E01-08; `…/<x>/UpdateBI` E01-11; `SetUp/provisioned` E01-09; i propri comandi `SetUp/<mac>` tornano indietro e sono ignorati (ma loggati) | `:815`, `:2050-2149` |
| `ElmacConfig` | setup | — | — | costruisce il JSON dei settings ma la pubblicazione è commentata (morto) | `:816`, `:2041-2049` |

Handler presenti ma **non raggiungibili** (topic non sottoscritto): `ElmacECL/<x>/response` (`ProcessTopicBeResponse`, stato happy hour, `:983-987`), primo livello `BlackList`/`GetMachineInfo`/`GetOperatori`/`ElmacSetBI` (`:900`, `:1852-1865`) **V**. Non sottoscritti benché presenti sul broker: `EEmem/<mac>`, `StateRdRfid/<mac>` (doc `boot_scheda_be.md` §1), `watchdog/restart` e `ECLClients/WinMt/<pc>` pubblicati da WinMT (winmt-10 W10-16) **V**.

**Pubblicati (in uscita)**

| Topic | Client / ret. | Destinatario | Payload | Origine | Evidenza |
|---|---|---|---|---|---|
| `ElmacECL/Server` | main, **retained**, anche **LWT** | Schede, WinMT | `{"msg":"ServerOnline","ServerOnline":"0|1","primario","serverip","state"}` | connessione, `IsServerOnline`, `setprimary` | `:724-725`, `:797`, `:948`; `RedundaceHandler.bas:71` |
| `ECLClients/Server` | main | WinMT | come sopra | watchdog | `:889` |
| `ElmacECL/<device>` | main | Scheda BE | `ValCard`, `ValTickets`, `Alert`, `Reboot`, `SetWifi` (`WifiWork` 0/1), `SetHappyH`, `ResHappyH`, `GetCnt`, `CntContapersone`, `SetRt`… | molti flussi | `ecl_cmds.bas`; `:1813`, `:1888`, `:4348`; `DBwinmt.bas:1772`, `1956-2184` |
| `ElmacECL` (broadcast) | main, **retained** per `SetTime` | Tutte le schede | `SetTime`; `ResHappyH`; `updatelist` (fw vecchi); firmware broadcast | E01-22, E01-21, E01-08 | `:3713`, `:2167`; `DBwinmt.bas:2097`; `aggiornamentiFirmware.bas:22` |
| `ElmacECL/BlackList` | main, **retained** QoS 1 | Schede | `{"msg":"BlackList","BlackLsElem":[UID16…],"BlNumElem":n}` (max 21) | E01-20 | `DBwinmt.bas:1890`; `ecl_cmds.bas:535-557` |
| `ElmacECL/operatori/<device>` | main, **retained** | Scheda/mobile | `{"stato":"OK","operatori":[sha256…]}` | E01-19 | `:978`, `:1865` |
| `ElmacECL/ReplyMachineInfo/<device>` | main | Scheda/mobile | dati macchina | E01-19 | `:972` |
| `ElmacECL/<device>/cassaMobile` | main | ECL mobile | `{"stato","saldo"}`, `{"stato":"PRONTO"}` | E01-17 | `:1467-1499` |
| `Service/<mac>` | main | Scheda (fw ≥ 110) | `updatelist`, `OutOfService`, `SetTotVal` compatto | E01-08, E01-29, programmatore | `:2186`, `:4624`; `deviceprogrammer.bas:289`; `funzioni.bas:379` |
| `SetUp/<mac>` | setup (QoS 1) e main | Scheda in setup | `wifi`, `SetCnt`, `SetCrediti`, `SetTmRl`, `SetSysTickLess`, `TmpPlay`, `SetTmpPlay`, `Reboot`, `SetWifi`, `ResetEEext`, `SetRt`, `SetTotVal`, comando arbitrario (`cfgCmd`) | E01-26, E01-27 | `:3136-3676`; `eclcommand.bas:76`, `663-665` |
| `SetUp` (broadcast) | setup **retained** / main | Schede in setup | `SetTime`, `updatelist` | E01-22, E01-08 | `:3711`, `:3716`, `:2168` |
| `ElmacSetBI/<mac>` | setup QoS 1 | Scheda (BI) | `SetRdr` (memoria interna BI) | E01-26 | `:3597`, `:3620` |
| `Ota/<tiposcheda>/<tipofw>/<mac>` | setup/main | Scheda | `OtaUpdate {Hw,Fw,host,port,binfile,ver}` | OTA (zona firmware) | `aggiornamentiFirmware.bas:35-149` |
| `HUB/<hubId>/eject` | main | PrizeHub | `{unit,slot,prize,qty}` | zona PrizeHub | `FlutterTicketsHandler.bas:351` |
| `Errors/<Nimp>/<livello>` | main | Cloud **D** (bridge) | testo errore | E01-25 | `:3982` |
| `ElmacAPIResponse/<metodo>` | main | Cloud **D** | JSON | E01-23 | `:925` |
| `ElmacECL/Server/macchine` | main | Cloud **D** | elenco macchine con stato e incassi 12 h | E01-24 | `DBwinmt.bas:5994` |
| `ElmacECL/Server/answers/jinsetup/<mittente>` | main | Cloud **D** | device in setup | E01-24 | `:1059` |

### 3.b Endpoint HTTP/WebSocket esposti

HTTP 58889 in chiaro, HTTPS 58443 (le sole pagine `.html` vengono reindirizzate su HTTPS, `SessionCreator.bas:23-31`). Gli handler sono registrati multi-thread (`AddHandler(…, False)`, `ecs2mqtt.b4j:488-540`) **V**.

| Endpoint | Auth | Consumatore | Note | Evidenza |
|---|---|---|---|---|
| `/eclcommand?command=…` | **nessuna** (HMAC calcolato e ignorato) | WinMT (`jProvisionable`, `jAdopt`, `jonline`, `jrebootAll`, `jOutOfService`, `jInService`, `jSetupDevice`, `jgetForWinmt`, `jRebuildSinglePageFromTemplate`, `jrefreshBlacklist`), pagine HTML legacy | include `restartservice`, `cfgCmd` (inoltra qualunque payload a una scheda), `jsetFromWinmt`, `getCardInfo`, `jgetListino` | `eclcommand.bas:34-892` |
| `/eclservices/*` | **nessuna** (bearer letto e non verificato) | Schede (GET testi/immagini/firmware), app/totem (POST `login`, `getCardInfo`, `getOperationList`, GET `getkioskconfig`, `getscalettabonus`) | il device è riconosciuto dall'IP sorgente (`BEConfig.BeInfo.IpAddress`); `getCardInfo` restituisce dati cliente a chiunque | `eclservice.bas:47-402` |
| `/redundance/getstate|setprimary|resetprimary` | **nessuna** | Master (getstate), WinMT (setprimary) | `resetprimary` riavvia tutte le BE e spegne il master | `RedundaceHandler.bas:47-104` |
| `/config?settings=…` | **nessuna** | sconosciuto (strumento d'installazione **D**) | svuota e riscrive `dbsettings.txt`, poi `ExitApplication` | `config.bas:18-52` |
| `/logout`, `/manuale/*` | sessione | browser | | `ecs2mqtt.b4j:488-489` |
| `/ws/filehelper` | sessione (callback in sessione) | pagine upload | multipart max 2 MB in `TempDir` | `FileHelper.bas:15-27` |
| `/ws/*` (pagine backoffice) | `ValidateUsers` (utente loggato) o `ValidateSuperAdmin` (Id 0) | browser | `ValidateUsers` non interrompe l'inizializzazione della pagina: i dati partono anche prima del redirect al login (es. `Dashboard.bas:31-35`) | `ecs2mqtt.b4j:487-523`, `4111-4184` |
| `/tickets/*`, `/crane/*`, `/app/*`, `/hub/*`, `/kiosk/*`, `/partner/*` | token bearer (`sicurezza.GeneraToken`) sulle POST; login GET con chiave API | app, gru, PrizeHub, kiosk, partner | solo `/partner` controlla che il token sia stato emesso per sé (`PartnerHandler.bas:85-88`); gli altri accettano qualsiasi token valido | zone app/API |
| `/api/*` | **nessuna** verifica del bearer | integrazioni | `validate-card`, `detach-card`, `purge-card`, `create-user` | `APIHandler.bas:60-130` (zona API) |
| `/playerscore`, `/ws/playerscore` | sessione giocatore (5 min) | cliente | | `ecs2mqtt.b4j:523-524`, `4203-4208` |

**Schema token** (`sicurezza.bas:80-132`): `base64(userId|ruolo|scadenza)` + `.` + HMAC-SHA256, validità 24 h; segreto e tre chiavi API nel codice (`sicurezza.bas:8-16`; la chiave partner è sovrascrivibile con `PartnerApiKey` in `dbsettings.txt`). La funzione HMAC è chiamata con chiave e messaggio invertiti (chiave = payload, messaggio = segreto): resta non falsificabile senza il segreto, ma è non standard **V**/**D**. Nessuna revoca, nessun legame con un utente reale (`userId` = nome dell'handler).

### 3.c Chiamate in uscita

| Verso | Mezzo | Cosa | Evidenza |
|---|---|---|---|
| SQL Server di sala (`SqlServer`:1433), DB `WinMtSqlDb` e `CoinlessDB`/`WinMtSqlDB` | JDBC, utente amministrativo | tutto | credenziale nel codice `DBwinmt.bas:62-63`, `DBcoinless.bas:46-47` |
| Cloud Elmac | JDBC diretto a `winmt.elmaccloud.com:1433` (`Connected≠1`) o linked server `[elmaccloud]` (`Connected=1`) | multilocale, replica firmware/immagini/lingue | `DBwinmt.bas:192-220`; credenziale nel codice `DBwinmt.bas:213-214` |
| Cloud Elmac | MQTT tramite broker locale (bridge **D**) | errori, risposte API, stato macchine | § 3.a |
| Server slave | HTTP GET `http://<SlaveIp>:58889/redundance/getstate` | stato primario | `funzioni.bas:182` |
| Rete locale | UDP broadcast/unicast 51049 | autodiscover (§ 3.d) | `Autodiscover.bas` |
| Processi | `net.exe stop ecl2mqtt` (routine senza chiamanti); `nssm stop ecs2mqtt`, col nome deprecato, usato da `/eclcommand restartservice` | riavvio (affidato al gestore servizi **D**). Con il servizio oggi chiamato `ecl2mqtt` il secondo comando probabilmente fallisce **D** | `ecs2mqtt.b4j:3960-3972`; `funzioni.bas:147-175` |
| File | `C:\ecs2mqtt\dbsettings.txt`, `keystore`, `www\`, `logs\`, `temp\`, `www\resources\screens\<mac>\`, `svghandler\` | configurazione, statici, schermate generate | `settingsmanager.bas:12-21`; `ecs2mqtt.b4j:140-145`, `276-279`, `481-483`; `utility.bas:78-86` |

### 3.d Autodiscover UDP (porta 51049, in ascolto e in invio)

| Richiesta ricevuta | Chi | Condizione | Risposta (unicast all'IP **scritto nel payload**, non all'IP sorgente) |
|---|---|---|---|
| `ARQFIND ECLServer:<ip>` | Schede BE, WinMT | primario, autodiscover `running`, app inizializzata | `ECLServer REPLY:{SqlServer,ProductionMqtt,SetupMqtt,AppMode,time,data }`; versione corta senza `AppMode`/ora per BE 131 < 110 o dopo 20 richieste in 30 s dallo stesso IP |
| `ARQFIND1:…:<ip>` | client generico | idem | come sopra |
| `ARQFIND ECLSvcManager:<ip>|<port>|<mac>|<device>|<servizio>` | GiallOne / service manager | idem | come sopra + `CodiceCliente`, `CodiceImpianto`, `DefaultTicketMode`; scrive `setup2` IdPost 0, chiave = MAC, JSON `{ip,port,macaddr,nomeservizio,nomedevice}` |
| `ARQFIND ECLTotem:<ip>|…` | Totem | idem | come sopra + valuta `EUR`, `TOK` e lingue **fisse nel codice** |
| `VERSION ECLServer:<ip>` | WinMT | primario | `VERSION REPLY:{"Ecl2Mqtt":ver,"dbversion":…}` |
| `SLAVEFIND ECLServer:<ip>` | WinMT in failover | **solo se `Primario=0`** | `ECLServer REPLY:{SqlServer,ProductionMqtt,SetupMqtt,"pwd":<password admin>}` |
| `Hey ECL:<ip>` | altro server all'avvio | primario | `ItsMe` |
| `ItsMe` | altro primario | — | questo server passa `disabled` e non risponde più a nulla fino al riavvio |

Evidenze: `Autodiscover.bas:10-15`, `75-103`, `151-301`, `304-482` **V**. Gli identificativi di messaggio sono confrontati per prefisso a lunghezza fissa; i payload non sono autenticati **V**.

### 3.e Master/slave/primario

- `Master` dice **quale macchina** è (1 master, 0 slave); `Primario` dice **chi eroga** (1 attivo). Default di un'installazione nuova: `Master=0`, `Primario=1`, senza slave (`settingsmanager.bas:87-91`) **V**.
- Master all'avvio: con `Primario=0` esce; con `SlaveIp` valorizzato interroga lo slave in ciclo: risposta 0 → parte; 1 → si declassa (`Primario=0`, salva) ed esce; nessuna risposta → errore critico al decimo tentativo, uscita al centesimo. Il ciclo non ha pause oltre al tempo della richiesta HTTP, quindi con lo slave spento (connessione rifiutata) il master si spegne in pochi secondi **V** (codice `ecs2mqtt.b4j:617-647`) / **D** (tempi).
- Slave: parte sempre; con `Primario=0` pubblica `ServerOnline=0`, non risponde a `ElmacAPI`, all'autodiscover (tranne `SLAVEFIND`) né all'orario, ma **elabora tutti gli altri messaggi** che arrivano al suo broker locale **V**.
- Failover: WinMT su `SLAVEFIND` ottiene IP e password admin, chiede conferma all'operatore, aggiorna `Setup(102).NRep2/NRep3` e chiama `/redundance/setprimary` (W10-12). Lo slave diventa primario e lo pubblica *retained* sul suo broker; le schede lo trovano al successivo `ARQFIND` **V**/**D**.
- Ritorno al master: solo manuale (`resetprimary` o modifica di `dbsettings.txt`) **V**. La sincronizzazione dei dati tra i due server ("ogni 60 secondi", `docs/fonti/ecl2mqtt/notebooklm/13-config-dbconfig-ridondanza.md`) **non è nel codice B4J** **D**.

### 3.f Punti di contatto diretti con WinMT

| Canale | Direzione | Cosa | Evidenza |
|---|---|---|---|
| DB condiviso | ↔ | quasi tutto (WinMT scrive configurazione e clienti, B4J scrive telemetria, partite, ticket, stato macchine) | § 4 |
| `Setup(101)` | WinMT → B4J | `AdmPass`, `F9/F10`, `T6`, `N0`, `T10/T12`, `Pre25`, `PInter`, `VisP0` — letti **una volta all'avvio** (salvo ticketless e scala bonus, riletti a ogni uso) | `WINMtConfig.bas:244-336` |
| `setup2` | B4J → WinMT | `ecs2mqttVer` (WinMT sceglie il topic del watchdog in base a questa versione); IdPost 0 dispositivi GiallOne | `WINMtConfig.bas:335`; `model_setup.bas` |
| `EcsMacchine.F0` | WinMT → B4J | configurazione pendente: B4J riprogramma e azzera | `DBwinmt.bas:832-888`, `1155-1193` |
| HTTP 58889 | WinMT → B4J | `/eclcommand` (comandi W08-07, blacklist, pagine), `/redundance/setprimary`; PrizeHub via `/app/*` | winmt-08 W08-07; winmt-10 W10-12; winmt-07 |
| UDP 51049 | WinMT → B4J | `ARQFIND`, `VERSION`, `SLAVEFIND` | § 3.d |
| MQTT | WinMT ↔ B4J | watchdog (W10-16): WinMT chiede `IsServerOnline` ogni 30 s e dopo 60 s senza risposta disabilita la riconversione card e pubblica `watchdog/restart`, che **nessun handler B4J ascolta**; WinMT ascolta anche `ElmacECL/+` (vede tutti i `ValCard`) | `ecs2mqtt.b4j:880-891`; winmt-10 righe 256-265 |
| `AuditLog` | B4J → (lettura WinMT?) | eventi `DeviceStatus` (fuori servizio, swap BI): risponde alla domanda aperta 9 di winmt-10 | `auditlog.bas`; `AppServiceHandler.bas:361-679` |

---

## 4. Dati

### 4.a Tabelle, viste e procedure usate dalla zona

| Oggetto | Operazioni | Flussi |
|---|---|---|
| `Setup` | R (101: `AdmPass`, `F9`, `F10`, `T6`, `N0`, `T10`, `T12`, `NomeLocale`, `CodEcs`…); W `MERGE` riga `PRIZEHUB01|` | E01-02, E01-17 |
| `setup2` | R/W (`ecs2mqttVer`, `flagDropTicketsForGold`, `VipSubscriptionParams`, `DbClientiMultilocale`, `TestMode_<codmac>`, IdPost 0 = MAC); D test mode | E01-02, E01-04, E01-30 |
| `Operatori` | R (login, `T0` card, `F0`, `Attivo`, password Id 0); W operatore `Prizehub1` | E01-02, E01-03, E01-16, E01-19, E01-32 |
| `EcsMacchine` | R; W `device_status`, `lastseen`, `onlinecount`, `offlinecount`, `is_online`, `is_happyhour`, `F0`, stato OOO | E01-06/07/10/21/26/29 |
| `EcsModuli`, `vs_eclmacchine`, `vs_CoinlessSpecialTimes` | R | E01-01, E01-10, E01-21 |
| `ecl_SchedeFirmware` | R/W/D (firmware rilevato, `status` dei device non game, device assegnato) | E01-06, E01-08, E01-30 |
| `BEConfig` | W (`BeInfo` da `macaddr`, `BiConfig` da `GetValBI`); R (device da IP) | E01-08, E01-11, E01-28 |
| `ecl_Provisioning`, `ecl_DeviceProvisioning`, `Coinless_sbuilder_page_provisioning`, `coinless_sbuilder_pages`, `coinless_sbuilder_templates_svg`, `CoinlessImages`, `CoinlessLanguages`, `ecl_firmware` | R/W | E01-08, E01-09, E01-28 |
| `CoinlessDati` (+ trigger `decodifica_flusso` → `decodifica_record`) | W | E01-12 |
| `CoinlessDecodedData` | R (primo invio del giorno); W (`replicaMovimentoMobile`) | E01-12, E01-21 |
| `CoinlessDataBuffer`, `Tickets`, `Clienti` | R/W | E01-13, E01-15 |
| `TransCard` | R; W (`NImp` 2, 6, 12; partite online) | E01-13, E01-16, E01-17 |
| `CoinlessCards` | W (MERGE blacklist, **disattivata**) | E01-16 |
| `CoinlessClonedCards`, `CoinlessLogEventiBlacklist` | R | E01-20 |
| `Compleanni`, `Ospiti`, `PartiteOspiti` | R/W | E01-14, E01-21 |
| `EcsDati` | R/W/D | E01-13, E01-26 |
| `fn_dati_grafico_giornaliero`, `fn_EcsDatiGiornalieri` | R | E01-24 |
| `ecl_log` | DDL, W | E01-01, E01-25, E01-30 |
| `AuditLog` | W | § 3.f |
| Cloud: `coinlessdb.CoinlessImages`, `ecl_firmware`, `bi_firmware`, `CoinlessLanguages`; `<DbClientiMultilocale>.sp_last_trans`, `rdclienti.sp_preleva_punti`, `<db>.Tickets` | R/W, EXEC | E01-34 |

### 4.b Colonne con significato nuovo o diverso da db-08

| Colonna | Significato in B4J | Rispetto a db-08 | Evidenza |
|---|---|---|---|
| `EcsMacchine.T0` | JSON di stato con flag `BISwap` e `NoRec` (sospende la registrazione dei record di gioco); persiste lo swap BI | **contraddice db-08** (valore piatto/hopper e lunghezza contascatti) | `DBcoinless.bas:247`, `259`; `ecs2mqtt.b4j:243-247` |
| `EcsMacchine.F0` | 1 = configurazione da inviare; B4J la consuma e la azzera | conferma db-08 | `DBwinmt.bas:832-888` |
| `EcsMacchine.device_status` | `Online`, `Offline`, `Setup`, `OOO`; `OOO` non viene sovrascritto dallo stato online/offline | completa db-08 (regola di precedenza) | `DBwinmt.bas:1249-1281` |
| `TransCard.NImp` = 12 | rimborso partita autorizzato da card operatore alla macchina, `ValoreOperazione` 0, `CodMac` = macchina | conferma "12 rimborso operatore" (db-08 [03]) e ne dà l'origine | `DBwinmt.bas:6737-6745` |
| `TransCard.CodMac` = `'CASSA-MOBILE'` | origine cassa mobile con `WinMt=1` | non in db-08 (per `WinMt=1` db-08 dice "nome computer") | `DBwinmt.bas:4408`, `4416` |
| `TransCard.T0` | `Nimp` della riga `Setup` del servizio, senza zeri iniziali; NULL nei rimborsi | **contraddice db-08** (4 cifre) | `DBwinmt.bas:4402-4420`, `6739` |
| `TransCard.F0` | sempre 0 dalla cassa mobile | **contraddice db-08** (1 se multilocale) | `DBwinmt.bas:4402-4420` |
| `Setup.MName` = `PRIZEHUB01|` | riga di postazione del servizio | non in db-08 | `DBwinmt.bas:6789-6797` |
| `Setup.AdmPass` campo 4 (`NomeMCM`) | usato come valuta digitale mostrata dalle BE (`EcoinCurrency`, `Curr`) | precisa db-08 | `WINMtConfig.bas:266`; `DBwinmt.bas:5817` |
| `Operatori` Id 1001–1009, `Cognome='Prizehub'`, `Livello 2` | operatore tecnico del servizio | sovrapposto agli Id 1001–1010 dei distributori `TotemPrizes` | `DBwinmt.bas:6835-6870` |
| `Operatori.T0` | card operatore; esposta come SHA-256 salato (sale nel codice) sul topic retained `ElmacECL/operatori/<dev>` | precisa db-08 | `DBwinmt.bas:4237` |
| `Operatori.F0` | abilita i rimborsi partita (stato 1 se ≥ 1, altrimenti 3 "non idoneo") | precisa db-08 ("crediti di servizio") | `DBwinmt.bas:4275-4314` |
| `setup2` IdPost 101 `ecs2mqttVer`, `DbClientiMultilocale`, `TestMode_<codmac>`; IdPost 0 chiave = MAC | scritte da B4J | `ecs2mqttVer` e IdPost 0 già in db-08 come "scrittore esterno": lo scrittore è B4J; le altre due non in db-08 | `WINMtConfig.bas:332-335`; `DBwinmt.bas:10141`, `10375`; `model_setup.bas` |
| `ecl_SchedeFirmware.status` | stato online/offline dei lettori, mangiaticket, visualizzatori | tabella non in db-08 | `DBcoinless.bas:3234-3253` |
| `BEConfig.BeInfo` / `BiConfig` | JSON con RSSI, IP, versioni, SPIFFS, memoria; configurazione BI decodificata (impulsi, fori ticket, modalità ticketless, drop ticket) | tabella non in db-08 | `DBcoinless.bas:4758-4911` |

### 4.c DDL eseguito dal codice

- `CREATE TABLE dbo.ecl_log` se manca (`DBcoinless.bas:3082-3120`) **V**.
- `CheckDbMigration`, `createBEConfig`, `updateBEConfig` a ogni avvio, secondo `dbversion` (`DBwinmt.bas:130-138`, `12770-12888`, `13559-13600`): dettaglio nella zona DB **V**.

### 4.d Stato fuori dal DB

**`C:\ecs2mqtt\dbsettings.txt`** (mappa chiave=valore di B4J; `File.WriteMap` riscrive l'intero file). Chiavi trovate nel codice:

| Chiave | Significato |
|---|---|
| `SqlServer` | IP del SQL Server; è anche l'IP che l'autodiscover comunica come broker di produzione e di setup e come host OTA |
| `MqttDefault` | IP broker comunicato alle schede nel comando Wi-Fi (`mqtt_s`) e come `serverip` nel `ServerOnline` |
| `MqttSetup` | storico; mostrato nelle pagine, non usato per connettersi |
| `ListenerPort`, `SSLPort` | 58889 / 58443 |
| `wlessssid`, `wlesspwd` | Wi-Fi delle schede (segreto; `~` sostituito da `%`); default nel codice `settingsmanager.bas:66-67` |
| `Master`, `Primario`, `MasterIp`, `SlaveIp` | ridondanza (§ 3.e); `SlaveIp`/`MasterIp` decidono anche il DB coinless (`CoinlessDB` o `WinMtSqlDB`) |
| `coinlessServer` | se non vuoto forza `WinMtSqlDB` come DB coinless |
| `GamePark` | variante Astoria: inizializza le BE con un `ValCard` vuoto, cambia il DB coinless |
| `Connected` | 1 = cloud tramite linked server `[elmaccloud]`; 0 = connessione diretta al cloud |
| `ApplicationMode` | `ECL` (default) o altro (`RT`, realtime: aggiunge partite in `EcsDati`); comunicato a WinMT via UDP |
| `tiketlessMode` | `Online` = i ticket del buffer sono accreditati sul DB |
| `ForceBiTicketMode`, `StatusBiTicketMode` | forzatura `TckSys/TckLess`; sovrascritti a ogni avvio da `Setup.F9F10` |
| `PrioritaBonus` | 1 = si consumano prima i bonus |
| `ForceDecimalDisplay` | decimali sul display BE |
| `currency`, `language` | valuta e lingua dei testi BE |
| `tokenReaderLabel`, `tokenReaderLabelRow1`, `tokenReaderLblCrediti` | etichette del display (`font|x|y|colore|testo` con segnaposto `{coin}`, `{saldo}`, `{currency}`…) |
| `ForceLabelMoneta`, `ForceLabelGettoni` | sostituiscono le etichette di `AdmPass` |
| `fonts` | JSON dei font BE |
| `ecl_log`, `mqtt_log` | log su `ecl_log` |
| `PrizeHubThrottleSec` | finestra anti-flood lettura card PrizeHub (default 3) |
| `PartnerApiKey` | chiave API partner (segreto) |
| `debug_no_autodiscover` | flag di debug |
| `process`, `errorcode` | tabelle di decodifica eventi, aggiunte in memoria a ogni caricamento (e quindi salvate nel file) |
| `txttokenreaderlblcrediti` | scritta dalla pagina DbConfig ma mai letta (la lettura usa `tokenReaderLblCrediti`) **D** |

**Mappe in memoria che fanno da dato** (perse al riavvio): elenchi device online/offline/setup e stato `Ready` (`ecs2mqtt.b4j:161-169`; stringhe `device@mac@ip@stato`), altri device e BE di altro impianto (`:164-165`), ultimo annuncio per device (`versioneMacchineFirmware`), tentativi di provisioning per MAC (`Provisionerror`), payload blacklist inviato (`BlackListPayload`), stato happy hour/time play globali, avvisi di sistema, cooldown swap BI, `ticketlessmode`, macchina "corrente" globale (`Main.macchina`, condivisa fra thread), cache macchine (`elencoMacchineInstallate`), configurazione `Setup(101)` (`myWinMtConfig`), richieste UDP per IP, ultimi 30 messaggi MQTT, throttle PrizeHub **V**. Il broker conserva come dato *retained*: stato server, blacklist, elenco operatori per device, ultimo `SetTime` **V**.

**File**: schermate generate per MAC sotto `www\resources\screens\<mac>\`, la cui coerenza con `coinless_sbuilder_pages` è riparata a posteriori (`mqttMessages.bas:273-308`) **V**.

### 4.e Sovraccarichi semantici

- `Setup.AdmPass` (nome da password) contiene la configurazione ECL; `Setup.F9/F10` sono anche il "ticket mode" scritto nei bit 6–7 della memoria BI (`ecl_cmds.bas:381-384`) **V**.
- `TransCard.NImp` = tipo operazione (già noto), `TransCard.T0` = sala (§ 4.b) **V**.
- `EcsMacchine.T0` = JSON di flag (§ 4.b) **V**.
- `device` (`<cliente>z<impianto>z<modulo>`) è insieme chiave tecnica, topic MQTT e controllo di appartenenza all'impianto (`validaimpianto`); `<modulo>+10000` indica il contapersone figlio di una macchina (`ecs2mqtt.b4j:1883-1887`, `3195-3197`) **V**.
- La password di `Operatori` Id 0 è anche il segreto del failover (`SLAVEFIND`) **V**.

---

## 5. Doppioni e sovrapposizioni con WinMT

1. **Movimenti `TransCard` di cassa** (E01-17 ↔ W05-02, W04-13): stessa tabella e stessi tipi, regole diverse su `F0`, `T0`, `Data`, `CodMac` (§ 2, E01-17). **V**
2. **Bonus a scaglioni sulla ricarica** (E01-17 ↔ W02-18): porting di `ECL_BonusHandler`, stessa configurazione `Setup.T10/T12`. Qui il bonus **crediti** non è calcolato dal server: arriva già calcolato dal dispositivo mobile (`ricaricaBonus`) **V**/**D**.
3. **Regola multilocale**: WinMT usa `IdLong` se `Setup(101).T6` elenca i locali (con `#` = disattivato, db-08). In B4J ci sono tre regole: "`T6` non vuoto" negli INSERT `TransCard` (`DBwinmt.bas:4405`, `4499`, `4551`, `6732`; anche i ticket, `2764`), "`T6` contiene `|`" in `WINMtConfig.multilocale` (`DBwinmt.bas:9213`), e il flag `multilocale` in `scriviTransazioneConCard` (`DBcoinless.bas:142`). Con `T6` disattivato da `#` la prima regola sceglie `IdLong` dove WinMT sceglie `IdContatto` **V** (codice) / **D** (effetto).
4. **Addebito della partita** (E01-13 ↔ W04-26/`decodifica_record`): due implementazioni (B4J in modalità online, SQL in modalità card) **V**.
5. **Validazione card in gioco** (E01-12): B4J risponde `ValCard` con regole proprie (cliente esistente, `Credito ≠ -1`, `f1`, compleanni) mentre `decodifica_record` applica nel DB anti-clonazione e blacklist; WinMT applica la sua verifica in cassa (W04-04) **D**.
6. **Login operatori** (E01-32 ↔ W10-06/07): stessa tabella e stessa decodifica password, controlli diversi (`Attivo`, `Livello`) **V**.
7. **Identificazione postazione** (E01-02 ↔ W02-02/W10-02): stessa riga `Setup` per `MName`, formati diversi **V**.
8. **Multisala** (E01-34 ↔ W02-16/W08-22): stessi punti e procedure cloud **V**.
9. **Ticketless** (E01-15): la regola `F9/F10` + `Clienti.N0` è in WinMT, in B4J e nel firmware (bit BI) **V**; in B4J c'è in più l'interruttore di file `tiketlessMode`.
10. **Blacklist** (E01-20 ↔ W01-14/W04-04): complementare (WinMT scrive, B4J distribuisce), ma B4J ha anche un proprio ramo di scrittura (operatore disabilitato) oggi spento (`DBcoinless.bas:2991`) **V**.

---

## 6. Problemi e rischi

**Consistenza e affidabilità**
- Nessuna risottoscrizione dopo riconnessione al broker (§ 0.4); al boot, se il broker non è ancora connesso quando finisce l'autodiscover (5 s), le sottoscrizioni vengono saltate (`ecs2mqtt.b4j:756`, `811`) **V**.
- `Scrivilog` termina l'applicazione su qualsiasi errore di scrittura del log (`DBcoinless.bas:3009`, `3017`); `getCoinMultiplier` termina su errore di lettura di `AdmPass` (`DBwinmt.bas:5826`) **V**.
- `SetTime` *retained* su `ElmacECL`: orario vecchio fino a 5,5 min per chi si collega dopo **V**/**D**.
- Nessuna transazione esplicita nei flussi di valore (ricarica, rimborso, partita online); nessuna idempotenza sui messaggi ripetuti (progressivo non controllato) **D**.
- Lo stato "in setup/online/pronto" è in memoria e il DB lo replica solo in parte: al riavvio il servizio non sa quali schede sono connesse finché non si riannunciano **V**.
- Le versioni firmware sono confrontate come stringhe (§ E01-26) **D**.
- Nel ramo `macaddr` il controllo "scheda formattata" legge la chiave `macaddress` mentre il payload usa `macaddr`: il forzamento del provisioning in `Main` non scatta (lo fa comunque `mqttMessages.bas:146-150`) (`ecs2mqtt.b4j:2098-2106`) **V**.
- `isOperatore` non restituisce mai 2: il ramo "operatore fuori soglia" è morto (`ecs2mqtt.b4j:1193`) **V**.
- `costruisciSetTotValNonGameDevice` usa `myWinMtConfig.MQTTsetup`, mai valorizzato: i device non game ricevono `mqtt_s` vuoto **V** (effetto **D**).
- Master che si spegne in pochi secondi se lo slave è spento (§ 3.e) **D**.

**Sicurezza** (senza segreti)
- Endpoint senza autenticazione con effetti distruttivi o di configurazione: `/config`, `/redundance/*`, `/eclcommand` (`restartservice`, `cfgCmd`, `jrebootAll`, `jsetFromWinmt`), `/eclservices` (`getCardInfo`, `login`), `/api/*` **V**.
- Password admin WinMT inviata in UDP a un IP indicato nel messaggio (`SLAVEFIND`) **V**.
- Credenziali nel codice: SQL locale e cloud (`DBwinmt.bas:62-63`, `203-204`, `213-214`; `DBcoinless.bas`), broker MQTT (`ecs2mqtt.b4j:723`, `1941`), keystore (`ecs2mqtt.b4j:3736-3737`), segreti token e chiavi API (`sicurezza.bas:8-16`), segreto HMAC fittizio (`funzioni.bas:10`), sale delle card operatore (`DBwinmt.bas:4237`), Wi-Fi di default (`settingsmanager.bas:66-67`). Connessione SQL con utente amministrativo e `trustServerCertificate=true` **V**.
- SQL costruito per concatenazione con dati di rete: `aggiornaDatiEcs` (payload MQTT, `DBcoinless.bas:236-262`), `cassaMobile` (card operatore, `DBwinmt.bas:4597`) **V**.
- Le pagine WebSocket protette da `ValidateUsers` continuano l'inizializzazione anche senza sessione; gli eventi delle pagine non ricontrollano la sessione **V**/**D**.
- Token bearer interscambiabili fra handler (tranne partner), senza revoca **V**.
- `getCardInfo` e `ElmacECL/operatori` espongono dati di clienti e operatori a chiunque abbia accesso alla rete o al broker **V**.

**Concorrenza**
- Handler HTTP multi-thread che modificano liste globali non thread-safe (`elencoMacchine…`) e la mappa globale `Main.macchina`, in concorrenza con i callback MQTT **V** (registrazione) / **D** (effetti).
- `Wait For` dentro handler HTTP multi-thread senza `StartMessageLoop` (es. `eclcommand.bas:77-80`): comportamento non garantito **D**.
- Programmazione BE che spegne i timer globali: due programmazioni concorrenti possono riaccenderli a metà dell'altra **D**.

---

## 7. Domande aperte per il team

1. Il mosquitto di sala è in *bridge* verso il cloud Elmac? Con quali topic (`Errors/#`, `ElmacAPI/#`, `ElmacAPIResponse/#`, `ElmacECL/Server/#`)? Chi consuma `Errors/<Nimp>/<livello>` nel cloud?
2. Chi pubblica i comandi `ElmacECL/Server/command/*` e `ElmacAPI/*` (HQ, app clienti, portale Elmac)?
3. Chi ascolta `watchdog/restart` pubblicato da WinMT? Esiste un servizio watchdog separato che riavvia `ecl2mqtt`?
4. Come si sincronizzano i DB di master e slave ("ogni 60 secondi")? Replica SQL, job, altro strumento?
5. Chi chiama `/config` (strumento di installazione)? Si può dismettere?
6. In produzione: `Connected` è 1 o 0 (linked server o connessione diretta al cloud)? Quanti impianti hanno `Master/Slave` configurati? Quali valori ha `ApplicationMode` (`ECL`/`RT`)?
7. La riga `Setup` `PRIZEHUB01|` e l'operatore `Prizehub1` esistono nel DB di produzione? Con quale `IDPost` e quale `Id`? Collidono con righe raccolte o con `TotemPrizes`?
8. Il bonus crediti della cassa mobile è calcolato dal dispositivo: è voluto? Va portato lato server nel nuovo sistema?
9. Il blocco della card operatore disabilitata (`mettiInBlackList`, scrittura commentata) è stato spento per scelta?
10. `EcsMacchine.T0` come JSON di flag: in produzione convive con il valore hopper descritto in db-08 su macchine diverse, o il vecchio uso è dismesso?
11. Per il nuovo sistema: la separazione "broker main / broker setup" ha ancora senso funzionale (rete di setup isolata) o è solo storica? I topic `SetUp/*`, `ElmacECL/*`, `Service/*` diventano un unico namespace versionato?
12. I comandi `jsetFromWinmt` via MQTT e via HTTP sono ancora usati da WinMT o HQ?
