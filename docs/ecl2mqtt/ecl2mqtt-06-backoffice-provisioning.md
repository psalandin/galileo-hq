# Galileo HQ — ecl2mqtt 06: backoffice web, installazione macchine, firmware e schermate

**Stato:** bozza · **Responsabile:** Piero · **Aggiornato:** 2026-10-25

**Collegati:** [`ecl2mqtt-00-mappa.md`](ecl2mqtt-00-mappa.md) (mappa e sintesi trasversale). Nel testo, «zona NN» indica il documento ecl2mqtt NN.

Fonte: `legacy/ecl2mqtt/` (sola lettura). Evidenze `file:riga`; **V** = verificato nel codice, **D** = dedotto. Le funzioni `DBwinmt`/`DBcoinless` sono analizzate da altre zone: qui se ne indica solo l'effetto. Path relativi a `legacy/ecl2mqtt/` salvo diversa indicazione; `Main` = `ecs2mqtt.b4j`.

---

## 1. Moduli coperti

| Modulo | Righe | Ruolo |
|---|---:|---|
| LoginPage.bas | 94 | Login backoffice con username/password o QR della card operatore |
| LogoutHandler.bas | 33 | `/logout`: invalida la sessione HTTP |
| SessionCreator.bas | 36 | Filtro `/*`: crea la sessione, forza le pagine `.html` su HTTPS |
| ManualeHandler.bas | 96 | `/manuale/*`: manuale HTML diverso per operatore e superadmin |
| sidebarMenu.bas | 103 | Menu laterale; gruppi Firmware e Config solo per superadmin |
| Webutils.bas | 90 | Utility (escape HTML, redirect) |
| Dashboard.bas | 405 | Riepilogo sala: macchine, dispositivi, avvisi, code update, test mode, "install mode" |
| MacchineOnline.bas | 402 | Macchine online: setup, reboot, out of order, riallineamento contatori, testi e schermate |
| MacchineConfigurate.bas | 860 | Pagina "Database": anagrafica macchine, duplica, assegna BE, sostituzione BI |
| MacchineInsetup.bas | 806 | Macchine in setup: online, riprogrammazione, ingressi, costi partita, modalità ticket |
| MacchineInPending.bas | 97 | Coda di programmazione BE in memoria (superadmin) |
| InstallazioneNuovaMacchina.bas | 991 | Installazione guidata: configurazione dalla flotta cloud, duplica o default per tipo, wizard modello |
| GrigliaIO.bas | 356 | Editor condiviso della griglia ingressi/contatori (9×4) |
| HelpIngressi.bas | 94 | Tabella statica pin fisici ↔ ingressi |
| alldevices.bas | 894 | Tutti i dispositivi per tipo, manutenzione (format, reload, ping), adozione impianto, assegna BE |
| deviceprogrammer.bas | 450 | Macchina a stati in memoria per la riprogrammazione della configurazione BE |
| biprogrammer.bas | 269 | Macchina a stati in memoria per l'aggiornamento OTA del firmware BI |
| aggiornamentiFirmware.bas | 250 | Costruzione e invio dei comandi OTA (BE e BI) |
| DeviceFirmware.bas | 568 | Pagina aggiornamento firmware BE (superadmin) |
| DeviceFirmwareBI.bas | 395 | Pagina aggiornamento firmware BI (superadmin) |
| ElencoFirmware.bas | 535 | Manutenzione firmware BE: upload, eliminazione, sync cloud (superadmin) |
| ElencoFwBI.bas | 319 | Manutenzione firmware BI (`.srec`): upload, sync cloud (superadmin) |
| ScreenBuilder.bas | 952 | Generazione schermate BE da template SVG con `svghandler.exe`; DDL tabelle sbuilder |
| ElencoSchermate.bas | 259 | Schermate statiche (`CoinlessImages`): upload, sync cloud |
| TemplatesSchermate.bas | 274 | Template SVG: upload file e registrazione |
| gestioneLingue.bas | 378 | Lingue ed etichette del display BE |
| specialtimes.bas | 155 | Elenco (sola lettura) delle macchine ora in happy hour |
| TestModeMacchina.bas | 178 | Test mode: baseline contatori, incrementi, ripristino |
| testDevice.bas | 96 | "Test output": contatori dell'ultimo minuto di una macchina |
| MqttDebug.bas | 156 | Monitor dei messaggi MQTT con decodifica dei record ECL (superadmin) |
| ArmageddonPage.bas | 89 | Azzeramento totale contatori dell'impianto, una sola volta (superadmin) |
| model_setup.bas | 139 | Lettura/scrittura `setup2` |
| setupV2.bas | 44 | Wrapper di `model_setup` |
| SetUPParam.bas | 27 | Pagina vuota, **non registrata** in `Main` (codice morto) |
| EditMacchina.bas | 27 | WebSocket registrato, nessuna logica, nessuna pagina lo usa (morto) |
| Objects/www (pagine proprie) | — | 36 HTML; `b4j_ws.js` (client WebSocket B4J); `manuale-help.js` (link al manuale); `index.js`, `index2.js`, `webapisearch.js` sono residui del template grafico, senza logica di dominio |

Parti di `Main` lette perché portano la logica del ciclo di vita: `Main:3152-3930` (programmazione), `Main:4111-4720` (autorizzazioni, stato in memoria), `Main:1918-2200` (broker setup). **V**

---

## 2. Flussi

Peso secondo `analisi-01` § 1 (S semplice, M più tabelle o regole, L complesso/transazionale/periferiche).

| Id | Flusso | Descrizione | Trigger/attore | Peso | Tabelle (R/W/D/DDL) | Evidenza | Equiv. WinMT | Rapporto |
|---|---|---|---|---|---|---|---|---|
| E06-01 | Login con password | Cerca `Operatori` per nome, decodifica la password reversibile, mette in sessione `UserID`, `Username`, `Livello` | operatore web | S | Operatori R | LoginPage.bas:31-48; DBwinmt.bas:6100-6150 | W10-06 | **doppione** (regola diversa, § 5) |
| E06-02 | Login con QR della card operatore | Il QR decodificato nel browser (`getUserMedia`) è cercato in `Operatori.codbar` con `Attivo=1`; nessuna password | operatore web | S | Operatori R | LoginPage.bas:60-75; DBwinmt.bas:6160-6195 | W10-07 | **doppione** |
| E06-03 | Sessione, HTTPS, logout | Filtro `/*` che crea la sessione e reindirizza le `.html` sulla porta SSL; `/logout` invalida la sessione | browser | S | — | SessionCreator.bas:20-27; LogoutHandler.bas:20-26 | — | solo B4J |
| E06-04 | Autorizzazione pagine e menu | `ValidateUsers` (qualsiasi loggato), `ValidateSuperAdmin` (solo `UserID = 0`), menu Firmware/Config nascosto ai non superadmin | ogni pagina | S | — | Main:4111-4200; sidebarMenu.bas:33-90 | W10-09 | **doppione** (regola diversa) |
| E06-05 | Manuale per ruolo | Serve `manuale_html\operatore` o `\superadmin` in base a `UserID` | operatore web | S | file | ManualeHandler.bas:20-60 | — | solo B4J |
| E06-06 | Dashboard | Conteggi macchine (DB + liste MQTT), altri dispositivi, avvisi, code di update BE/BI, test mode, promozioni, compleanni, stato server (solo superadmin) | operatore web, refresh 10 s | M | vs_eclmacchine R, setup2 R, promozioni R (via DBwinmt) | Dashboard.bas:45-215 | — | solo B4J |
| E06-07 | "Install mode" di sala | Il superadmin commuta `Main.setupmode`: con `True` il server **smette di elaborare** le richieste di gioco in `send_client` | superadmin | S | — (memoria) | Dashboard.bas:398-406; Main:1530 | — | solo B4J |
| E06-08 | Comandi alle macchine online | Setup (attiva setup + reboot), reboot, "setup all" su `ElmacECL/<device>` | operatore web | S | — | MacchineOnline.bas:178-200, 387-400 | W08-07 (`jonline`, `jrebootAll`) | **doppione** (WinMT passa per HTTP) |
| E06-09 | Out of order / in servizio | `device_status = 'OOO'`/`'Online'`, `is_happyhour = 0`, comando su `Service/<mac>` | operatore web | S | EcsMacchine W | MacchineOnline.bas:363-385; alldevices.bas:704-725; Main:4618-4636; DBwinmt.bas:12891, 12932 | W08-07 (`jOutOfService`) | **complementare** (WinMT chiama l'endpoint del servizio) |
| E06-10 | Riallineamento contatori da snapshot | L'operatore sceglie una riga `EcsDati`; si cancellano le letture successive, si sospende la registrazione (`NoRec`) e si riprogramma la BE (fw ≥ 0094 subito, altrimenti `F0 = 1` + reboot) | operatore web | L | EcsDati R/D, EcsMacchine W (T0, F0) | MacchineOnline.bas:266-319 | W08-13 (parziale) | solo B4J |
| E06-11 | Aggiorna testi / schermate di una macchina | Cancella le righe `ecl_Provisioning` per forzare il reinvio; per le schermate rigenera i jpg e fa reboot | operatore web | M | ecl_Provisioning D, Coinless_sbuilder_page_provisioning D, file | MacchineOnline.bas:321-345; Main:3848-3920 | W08-03 passo 5 | **complementare** |
| E06-12 | Database macchine | Card per macchina con costi, impulsi, stato, swap BI; info configurazione e ingressi decodificati | operatore web, 10 s | M | vs_eclmacchine R, EcsMacchine R, EcsModuli R | MacchineConfigurate.bas:87-260, 560-640 | W08-20, W08-05 (lettura) | complementare |
| E06-13 | Duplicazione macchina | `INSERT…SELECT` dalla sorgente con nuovo `CodMac`, `Modu = MAX+1`, `device` dal massimo; poi costi e erogatori dalla maschera | operatore web | M | EcsMacchine I/U, EcsDati D/I | MacchineConfigurate.bas:490-530; InstallazioneNuovaMacchina.bas:660-670; DBwinmt.bas:6317-6400 | W08-06 | **doppione** |
| E06-14 | Rendi programmabile | Riabilita la riassegnazione della BE (`EcsModuli.Nimp = 1`) | operatore web | S | EcsModuli U | MacchineConfigurate.bas:269-275; DBwinmt.bas:9611 | — | solo B4J |
| E06-15 | Assegnazione BE a CodMac | La BE nuova (`0z0z0`, in setup) viene legata al CodMac: MERGE su `EcsModuli`, `Modu`/`device` su `EcsMacchine`, base contatori, programmazione scelta per versione firmware | operatore web (3 pagine) | L | EcsModuli D/I/U, EcsMacchine U, EcsDati I/D, ecl_SchedeFirmware R | MacchineConfigurate.bas:352-470; alldevices.bas:820-895; Main:3364-3437; DBwinmt.bas:1023-1150, 1587 | W08-07 (`jAdopt`) | **doppione** |
| E06-16 | Sostituzione scheda BI | Procedura a 4 passi (avvia → setup → scrivi contatori → termina) con stato persistito e audit | operatore web | L | EcsMacchine U (T0), audit log | MacchineConfigurate.bas:640-860 | — | solo B4J |
| E06-17 | Macchine in setup | Elenco schede configurate in setup (le `0z0z0` sono escluse), online, reboot, "tutte online" | operatore web, 10 s | M | vs_eclmacchine R, ecl_SchedeFirmware R | MacchineInsetup.bas:105-235, 784-806 | W08-07 (`jonline`) | **doppione** |
| E06-18 | Riprogrammazione da pagina setup | Come E06-15 ma con CodMac già noto; ramo per versione (131.110+, 900 mobile, >131.101.0015, vecchie) | operatore web | L | EcsDati I/D, EcsMacchine U (F0) | MacchineInsetup.bas:520-735 | W08-05 (`jSetupDevice`) | complementare (e doppione interno con E06-15) |
| E06-19 | Configurazione ingressi/contatori | Griglia 8 ingressi fisici × 4 contatori + riga E-coin; salva e opzionalmente riprogramma | operatore web | L | EcsMacchine R/U (ValIn, TipoIn, InCnt, CntrVal, CntrLet10) | GrigliaIO.bas:1-356; MacchineInsetup.bas:265-345; DBwinmt.bas:10695, 10750 | W08-05 | **doppione** (regola E-coin diversa) |
| E06-20 | Costi partita per livello | Silver/Gold/Platinum/Birthday in € → centesimi, `ValPar`; rigenera le schermate della BE | operatore web | M | EcsMacchine U (val_*, ValPar, CntrLet8/9) | MacchineInsetup.bas:360-440; DBwinmt.bas:15926 | W08-12 | **doppione** |
| E06-21 | Modalità ticket della BE | Ticketless da setup WinMT, ticket cartaceo forzato, "full online", normale | operatore web | S | Setup R (via DBwinmt) | MacchineInsetup.bas:745-783; Main:3650-3670 | — | complementare |
| E06-22 | Installazione nuova macchina | Modo A: configurazione di una macchina omonima della flotta (cloud); B: duplica locale; C: default per tipo. Crea il record, valore medio iniziale gru, lega la BE e avvia la programmazione | manutentore web | L | cloud R (CoinlessImpianti, vs_definizione_nome_macchina, sp_CoinlessMacchine, sp_ConfigurazioneMacchina, sp_DettaglioIngressiMacchina, `<DB>`.EcsMacchine, CoinlessDefaultTypeConfig, `<svc>`.Machines); setup2 W; EcsMacchine I; EcsDati I; EcsModuli; tabelle gru | InstallazioneNuovaMacchina.bas:60-760; DBcoinless.bas:5133-5880; DBwinmt.bas:15695-15800 | W08-03, W08-04, W07-11 | **doppione** |
| E06-23 | Wizard nuovo modello | Crea `Type` (UI disattivata, handler attivo), `Manuf`, `Machines` **sul DB di servizio cloud** | manutentore web | M | `elmaccloud.<svc>`: Type/Manuf/Machines R/I | InstallazioneNuovaMacchina.bas:780-991; DBcoinless.bas:5594-5720 | W08-01 | **doppione** |
| E06-24 | Programmazione BE dopo installazione / `jSetupDevice` | fw ≥ 110: cancella file e righe pagine, rigenera le immagini, mette in coda (stato 50); altrimenti reboot | installazione, WinMT via HTTP | L | EcsMacchine R, coinless_sbuilder_pages D, file | Main:3759-3846; eclcommand.bas:378-386 | W08-05 | **complementare** |
| E06-25 | Coda di riprogrammazione BE | Macchina a stati in memoria (stati 4→3→2→1→0, 20 mobile, 40 fw ≥ 0094, 50/49 fw ≥ 110), timer 5 s; a fine ciclo `F0 = 0` e "in servizio" | timer | L | EcsMacchine U (F0, device_status) | deviceprogrammer.bas:74-450; Main:4225-4240 | — | solo B4J (WinMT scrive `F0 = 1`: complementare) |
| E06-26 | Riprogrammazione automatica al boot | All'arrivo di `SetUp/.../macaddr` la BE passa a Ready; se `F0 = 1` entra in coda, altrimenti si applica lo stato happy hour | scheda BE | M | EcsMacchine R | mqttMessages.bas:882-935 | W08-05 (rete) | complementare |
| E06-27 | Tutti i dispositivi | Liste: game (configurati e nuovi), mobile, visualizzatori, reader, mangiaticket, mangiaticket/BE di altro impianto | operatore web, 10 s | M | ecl_SchedeFirmware R, vs_eclmacchine R | alldevices.bas:72-410 | — | solo B4J |
| E06-28 | Manutenzione dispositivo | Reload testi/schermate/firmware BI, factory reset BE, cancellazione EEPROM lettore, format visualizzatore, ping, log filtrato | operatore web | M | ecl_Provisioning D, file schermate D | alldevices.bas:414-520 | — | solo B4J |
| E06-29 | Adozione di un dispositivo di altro impianto | Riscrive wifi e impianto (`SetTotVal`) su un mangiaticket spostato da un'altra sala, o factory default | operatore web | S | — (memoria) | alldevices.bas:629-660; Main:3507-3567 | — | solo B4J |
| E06-30 | Happy hour attive | Mostra le macchine nella fascia attiva con prezzi per livello e anteprima della schermata generata | operatore web, 30 s | S | vs_CoinlessSpecialTimes R, EcsMacchine R, file | specialtimes.bas:39-155; DBwinmt.bas:2205 | W04-17 | **complementare** (WinMT configura, B4J legge e applica) |
| E06-31 | Guida ingressi | Tabella statica pin ↔ ingressi ↔ tipi | operatore web | S | — | HelpIngressi.bas:44-60 | — | solo B4J |
| E06-32 | Test mode macchina | Salva la baseline `EcsDati`, mostra gli incrementi valorizzati; alla fine ripristina la baseline e riprogramma; timeout 60' senza ripristino | operatore web, timer 5' | L | setup2 W/D, EcsDati R/D, EcsMacchine U (F0, T0), ecl_log W | TestModeMacchina.bas:72-178; DBwinmt.bas:10138-10380; Main:704-706 | — | solo B4J |
| E06-33 | Test output | Contatori registrati nell'ultimo minuto per una macchina online | operatore web | S | EcsDati R (via DBwinmt) | testDevice.bas:33-90 | — | solo B4J |
| E06-34 | Aggiornamento firmware BE (OTA) | Scelta scheda/firmware/versione; per macchina invia `OtaUpdate` su `Ota/<hw>/<fw>/<mac>` con l'URL HTTP del binario; aggiorna la versione richiesta | superadmin | M | ecl_firmware R, ecl_SchedeFirmware R/U/I, EcsMacchine R | DeviceFirmware.bas:412-560; aggiornamentiFirmware.bas:17-60; DBcoinless.bas:366, 721 | — | solo B4J |
| E06-35 | Aggiornamento firmware BI | Coda in memoria (5→0): setup, `BiUpdate` con nome `.srec` su `SetUp/<mac>/UpdateBI`, attesa esito, rimessa online | superadmin, timer 5 s | L | EcsMacchine U (T0 statoBI/errBI) | DeviceFirmwareBI.bas:277-320; biprogrammer.bas:18-269; Main:2114-2135 | — | solo B4J |
| E06-36 | Manutenzione firmware BE | Upload del binario (controlla che contenga la stringa di versione), salvataggio come blob, eliminazione, proposta versione successiva | superadmin | M | ecl_firmware I/D | ElencoFirmware.bas:354-475; FileHelper.bas:16-28; DBcoinless.bas:2566-2640 | — | solo B4J |
| E06-37 | Manutenzione firmware BI | Upload `.srec` in `CoinlessImages`, forza il reinvio alle schede | superadmin | M | CoinlessImages I/U, ecl_Provisioning D | ElencoFwBI.bas:206-250; DBcoinless.bas:1559, 2681 | — | solo B4J |
| E06-38 | Sincronizzazione cloud ↔ sala | Copia firmware BE/BI, immagini e lingue tra il DB di sala e `CoinlessDB` cloud (solo righe mancanti) | superadmin | M | ecl_firmware, CoinlessImages, CoinlessLanguages I (sala e cloud) | ElencoFirmware.bas:475-490; ElencoFwBI.bas:252-265; ElencoSchermate.bas:205-220; gestioneLingue.bas:318-330; DBwinmt.bas:10904-11060 | — | solo B4J |
| E06-39 | Schermate statiche | Upload immagini in `CoinlessImages`, forza il reinvio per immagine | superadmin | S | CoinlessImages I/U, ecl_Provisioning D | ElencoSchermate.bas:160-200; DBcoinless.bas:993, 1537, 2643 | — | solo B4J |
| E06-40 | Template SVG | Copia il file in `www\resources\templates`, registra il template per cliente/impianto e pagina BE | superadmin | S | coinless_sbuilder_templates_svg I/U, file | TemplatesSchermate.bas:161-200; DBcoinless.bas:4050, 4086 | — | solo B4J |
| E06-41 | Generazione schermate da template | Per ogni macchina e pagina standard (`Tap_to_play`, `ooo_qr`, `setup_qr`, happy hour) compila i campi (costi per livello, valuta, QR), scrive `svghandler.json`, lancia `svghandler.exe`, registra le pagine generate | BE al boot, installazione, costi, HH | L | coinless_sbuilder_pages R/I/U/D, vs_CoinlessSpecialTimes R, EcsMacchine R, DDL, file | ScreenBuilder.bas:47-760, 785-952 | W04-17 passo 4, W08-12 passo 3 | **complementare** (WinMT chiede `jRebuild…`) |
| E06-42 | Lingue ed etichette BE | Elenco etichette per lingua, nuova lingua (copia), modifica testo/colore/allineamento/font/posizione, reinvio a tutte le schede | superadmin | M | CoinlessLanguages R/I/U, ecl_Provisioning D | gestioneLingue.bas:60-300; DBcoinless.bas:1213-1420, 2336 | — | solo B4J |
| E06-43 | Monitor MQTT | Ultimi messaggi con filtro, decodifica dei record `3;0;7`, `3;0;16`, `3;0;17` | superadmin | S | — (memoria) | MqttDebug.bas:22-150 | — | solo B4J |
| E06-44 | Armageddon | Una sola volta: cancella lo storico `EcsDati` lasciando l'ultima riga, azzera In1–16, opzionalmente cancella tutto `TransCard`, mette tutte le macchine in pending e le riavvia | superadmin | L | EcsDati D/U, TransCard D, EcsMacchine U, setup2 W | ArmageddonPage.bas:28-89; DBwinmt.bas:1423-1590 | W08-10 (per singola macchina) | solo B4J (effetto simile a W08-10 su tutto l'impianto) |
| E06-45 | Coda di programmazione (vista) | Tabella della coda BE in memoria | superadmin, 5 s | S | — | MacchineInPending.bas:17-97 | — | solo B4J |
| E06-46 | Pulizie periodiche | Ogni 30': cancella le schede `0z0z0` non viste da 240'; ogni 5': chiude i test mode oltre 60' | timer | S | ecl_SchedeFirmware D, setup2 D, ecl_log W | Main:687-706; DBcoinless.bas:785-800 | — | solo B4J |

**Codice morto o pagine orfane.** **V** `SetUPParam` non è registrato; `/ws/EditMacchina` è registrato (Main:510) ma nessuna pagina lo usa; `devicedebugger.html` (`/ws/DeviceDebugger`), `edit_macchina.html` (`/MachineEdit`), `elencofirmware.html`, `lingue.html`, `screens.html`, `paginavuota.html` puntano a route non registrate; `parameters.html` riusa `/ws/ElencoFirmware`. La vecchia pagina HTML di `/eclcommand?command=elenco` (`Main.elencoDevice`, Main:2454-2930) offre ancora REBOOT/SETUP/ONLINE/RESET CNT/SET Wifi/aggiornamento firmware via link GET.

### 2.1 Dettaglio dei flussi L e dei doppioni

**E06-01/02/04 Login e ruoli.**
- **V** Il commento dice "riservato al superadmin", ma il controllo `foundId = 0 And foundLivello = 0` è commentato (DBwinmt.bas:6128). Chiunque abbia nome e password in `Operatori` entra. Il login con password **non controlla `Attivo`**, quello con QR sì (DBwinmt.bas:6119 contro 6178).
- **V** Ci sono solo due ruoli effettivi: superadmin = `Operatori.Id = 0` (Main:4153-4200; ManualeHandler.bas:31-34), tutti gli altri = "operatore". `Livello` va in sessione e serve solo a mostrare le card di sync verso il cloud (ElencoFirmware.bas:482-506: 0 admin, 1 manager, 2 operatore).
- **D** WinMT invece usa `Livello and 3` (0 superadmin, <2 gestione) (db-08 `Operatori.Livello`). Stessa tabella, due modelli di ruolo diversi.

**E06-15/18 Assegnazione e programmazione della BE.**
- **V** Lo stesso flusso è scritto tre volte con varianti. `Main.assegnaBEaCodMac` (Main:3364-3437) è usato da Database e All devices. `MacchineInsetup.riprogramma_device` (MacchineInsetup.bas:573-735) ripulisce `EcsDati` del CodMac *vecchio*. `eclcommand jAdopt` (eclcommand.bas:539-) è chiamato da WinMT e passa per la coda `adopt_new_device`.
- **V** Passi comuni:
  1. Rifiuta se la macchina è in test mode.
  2. Legge la versione da `ecl_SchedeFirmware.detectedversion`; senza riga si ferma.
  3. Base dei contatori: con `dataril` vuota scrive una lettura a zero (`scriviEcsDati`), altrimenti cancella le letture `EcsDati` successive alla riga scelta.
  4. Programma secondo la versione:
     - `131.110+`: un solo `cmd0` in "CompactMode" su `SetUp/<mac>`;
     - `900`: telefono;
     - `>131.101` e build `>0015`: `programmaDevice`, cioè setup, poi `cmd0`;
     - più vecchie: `creaDeviceDaWinmt`, sequenza `cmd0` wifi, `cmd1` memoria interna su `ElmacSetBI/<mac>`, `cmd2` contatori, `cmd3` crediti per livello, `cmd6` relè, ticketless, reboot.
- **V** Il legame BE↔macchina si fa così. `aggiornaModuloEcs` cancella tutte le righe `EcsModuli` duplicate per quel MAC e poi fa MERGE (`Id = MAX+1`). `assegnaModuloAMacchina` mette `Modu = MAX+1` e `device = prefisso + Modu` se mancanti, poi copia `N0 = Modu` e `ShortAd = device` su `EcsModuli` (DBwinmt.bas:1023-1150, 1587-1620). Nessuna transazione.
- **V** I confronti di versione sono **tra stringhe** (`minor >= "110"`, `build > "0093"`: Main:3403, MacchineInsetup.bas:690-700, DeviceFirmware.bas:440-460). Altrove si usa `minor.As(Int)` (Main:3804): due regole per la stessa decisione.

**E06-16 Swap BI.**
- **V** Lo stato `BISwap` e `BISwapStep` (0–4) sta in `EcsMacchine.T0` come JSON (DBwinmt.bas:10518, 10562). Il passo 1→2 avanza quando il MAC compare nella lista setup, il passo 3→4 quando torna online (MacchineConfigurate.bas:810-845).
- **V** C'è un cooldown di 20 s per reinviare "vai in setup" se la macchina era spenta. Inizio e fine sono registrati in `Main.Audit.AddDeviceStatusLog`.

**E06-19 Ingressi e regola E-coin (doppione con W08-03/05).**
- **V** Mappa dei pin uguale a WinMT: 1 A2 coin meccanico, 2 A1 ticket meccanici, 3 B14 coin elettronico, 4 A15 seconda gettoniera/banconote, 5 A10 erogatore ticket, 6–8 A3–A5 premi/aux, 9 E-coin (GrigliaIO.bas:232-280). Corrisponde a `winmt-08` W08-03.
- **V** B4J calcola `ValIn9 = ValPar / impulsi`, `TipoIn9 = 6`, `InCnt9 = 1`, `CntrLet10 = impulsi` (GrigliaIO.bas:132-150).
- **D** Secondo `winmt-08` W08-03, WinMT scrive `ValIn9 = valore impulso × impulsi per partita`. Le due formule danno valori diversi per lo stesso ingresso, salvo che `ValPar` non abbia significati diversi nelle due UI. **Da verificare** su righe reali.
- **V** L'editor B4J scrive solo le colonne toccate (UPDATE dinamico, DBwinmt.bas:10750). WinMT invece azzera e riscrive le colonne 5–100 (W08-05).

**E06-20 Costi per livello (doppione con W08-12).**
- **V** Si salvano in centesimi (`Round(€ × 100)`) e si rigenerano le schermate di setup. Non si invia `jUpdateCreditiRichiestiPerTipoCard` né si mette `F0 = 1` (MacchineInsetup.bas:395-440).
- **D** WinMT invece invia i crediti alle BE online o mette `F0 = 1` per le offline. Dalla pagina B4J il nuovo prezzo arriva alla BE solo alla prossima programmazione.

**E06-22/23 Installazione (doppione con W08-01/03/04).**
- **V** La ricerca usa `sp_CoinlessMacchine` sul linked server `elmaccloud`, prima nel proprio `DBSERVIZIO` e poi su tutta la flotta. Scarta i risultati con `Tipo` diverso da quello già registrato localmente per lo stesso modello (InstallazioneNuovaMacchina.bas:179-235).
- **V** `creaMacchinaDaConfig` (DBwinmt.bas:15695-15800):
  - fa l'INSERT con `F0 = 0`, `Propr = '100'`, `PerDiv = 100`, `NImp` = numero sala e `device` costruito da `MAX(device)`;
  - poi crea la prima riga `EcsDati` su un'altra connessione, senza transazione.
- **D** WinMT nasce con `F0 = 1` ed è transazionale nel wizard (W08-04).
- **V** I tipi gru (3, 9, 12, 17) chiedono il valore medio iniziale del premio (`DBCrane.Crane_SetInitialAvgValue`, InstallazioneNuovaMacchina.bas:690-700), in sovrapposizione con W07-11.
- **V** Il wizard modello fa INSERT con `ID = MAX+1` direttamente su `elmaccloud.<DBSERVIZIO>.dbo.Type/Manuf/Machines` (DBcoinless.bas:5594-5720), come W08-01. A differenza di W08-01, però, **non ripiega sul DB di sala** se il cloud manca. Installazione modo A/C e wizard **richiedono il cloud**.

**E06-25 Coda di riprogrammazione.**
- **V** La coda esiste solo in memoria (`programmableDevices`, chiave MAC) e si perde al riavvio. È però ricostruita dal flag `F0 = 1` al prossimo boot della BE (E06-26).
- **V** Allo stato 0 chiama `Main.InService`, che **riporta `device_status` a 'Online' anche se l'operatore aveva messo la macchina OOO** (deviceprogrammer.bas:291, 431).
- **V** In `ProcessTopicBeIsReady` il ramo per i telefoni sta dentro `If tipodiperiferica = "GAMES"`, quindi `add_mobile_to_queue` non viene mai chiamato (mqttMessages.bas:918-922).

**E06-32 Test mode.**
- **V** La baseline (In1–9, operatore, ora) è salvata in `setup2` (IdPost 101, `TestMode_<codmac>`).
- **V** La chiusura:
  1. scrive il riepilogo su `ecl_log`;
  2. imposta `NoRec = 1` (in `T0`);
  3. cancella `EcsDati` del periodo di test;
  4. mette `F0 = 1` e fa reboot.
- **V** Al timeout si rimuove solo lo stato, i contatori non vengono ripristinati (DBwinmt.bas:10302-10380).

**E06-35 BI OTA.**
- **V** La risposta della scheda arriva su `SetUp/<mac>/UpdateBI` (`StateUpdateBI`, `MsgErrBI` 0 ok, 1 riprova, 2 timeout, 3 file mancante) (Main:2114-2135; biprogrammer.bas:150-175). Lo stato viene reso persistente in `EcsMacchine.T0` (`statoBI`, `errBI`) se la BE è associata.

**E06-41 Generazione schermate.**
- **V** Il processo esterno è `cmd.exe /c <installpath>\svghandler\svghandler.exe -v`. Prende in input un file JSON e restituisce gli errori in `errors.json`; i jpg vanno in `www\resources\screens\<mac senza :>\` (ScreenBuilder.bas:680-750).
- **V** Il nome del file happy hour codifica i prezzi: `<template>_<normal>_<silver>_<gold>_<platinum>.jpg` (specialtimes.bas:103-113).
- **V** C'è un lock `is_busy` per serializzare le generazioni. È stato introdotto dopo un bug in produzione: con più BE riconnesse insieme, una restava senza righe in `coinless_sbuilder_pages` (ScreenBuilder.bas:760-783).

**E06-44 Armageddon.**
- **V** Coincide con `docs/fonti/ecl2mqtt/armageddon.md`.
- **V** Nessuna transazione: cancellazione storico, azzeramento e `TransCard` sono `ExecNonQuery` separati (DBwinmt.bas:1500-1560). Se un passo fallisce, l'impianto resta in stato misto ma la guardia "eseguito" viene comunque scritta alla fine.

---

## 3. Interlocutori

### 3.a MQTT

**V** Entrambi i client si collegano allo **stesso broker locale `tcp://localhost`**: `mqtt_main` (Main:717) e `mqtt_setup` (Main:1928). `settings.MqttSetup` non viene usato per la connessione. "Broker di setup" è quindi solo un secondo client con sottoscrizioni diverse. Utente e password del broker sono una **credenziale nel codice** (Main:723, Main:1941).

| Topic | Dir. | Client | Payload sintetico | Controparte | Evidenza |
|---|---|---|---|---|---|
| `SetUp/<ClientXzYzN>/<mac>/status` | in | setup | `Online`/`Offline` → lista setup, `is_setup` su DB | scheda BE in setup | Main:2051-2055; mqttMessages.bas:943-975 |
| `SetUp/<Client…|reader|mangiat|viewer>/macaddr` | in | setup | `{macaddr, ver BE/ver BI/ver MOBILE/verDisplay, IpAddress, SPIFSSUsed, RowCount, ValInp}`; classifica il dispositivo e lo fa passare a Ready | BE, lettori, mangiaticket, visualizzatori, telefoni, display Astoria | Main:2062-2112; mqttMessages.bas:60-170 |
| `SetUp/<mac>/UpdateBI` | in | setup | `{msg:StateUpdateBI, MsgErrBI}` | BE (per la BI) | Main:2114-2135 |
| `SetUp/provisioned` | in | setup | esito provisioning file | BE | Main:2141-2146 |
| `ElmacECL/<device>` | out | main | `attiva_setup_mode`, `reboot`, `cmd0` config | BE online | MacchineOnline.bas:178-200; deviceprogrammer.bas:340-365 |
| `SetUp/<mac>` | out | setup (QoS 1) | `disattiva_setup_mode`, `reboot`, `SetCnt`, `SetTotVal`, config `cmd0..cmd6`, `SetSysTickLess`, `formattaBe`, `formattaMemoriaLettore` | BE in setup, dispositivi non game | Main:2295-2310, 3507-3650; alldevices.bas:472-660 |
| `Service/<mac>` | out | main | out of service on/off; `cmd0` per fw ≥ 110 | BE | Main:4618-4636; deviceprogrammer.bas:281 |
| `ElmacSetBI/<mac>` | out | setup | scrittura memoria interna BI | BE vecchie | Main:3590 |
| `Ota/<tipoScheda>/<tipoFirmware>/<mac>` | out | setup o main | `{msg:OtaUpdate, Hw, Fw, host, port, binfile, ver}`; `host` = `SqlServer`, porta 58889 (o 80 nella versione 1) | BE, mangiaticket, lettori | aggiornamentiFirmware.bas:17-60, 110-125; ecl_cmds.bas:102-106 |
| `SetUp/<mac>/UpdateBI` | out | setup | `{msg:BiUpdate, fileName:"…srec"}` | BE (per la BI) | aggiornamentiFirmware.bas:236-250 |
| `ElmacECL` / `SetUp` (broadcast) | out | main e setup | `settime` (retained su `ElmacECL`), richieste di provisioning | tutte le schede | Main:3680-3720, 2159-2178 |
| `Errors/<Nimp>/<livello>` | out | main | testo errore | cloud (bridge MQTT, **D**) | Main:3979-3990 |

### 3.b Endpoint HTTP e WebSocket di questa zona

Le porte vengono da `dbsettings.txt` (default 58889 HTTP e 58443 HTTPS, Main:301-302). Keystore SSL con **credenziale nel codice** (Main:3736). **V**

| Endpoint | Tipo | Auth | Consumatore |
|---|---|---|---|
| `/ws/LoginPage` | WS | pubblico | browser |
| `/logout`, `/manuale/*` | HTTP | sessione (manuale) | browser |
| `/ws/Dashboard`, `/ws/MacchineOnline`, `/ws/MacchineInstallate`, `/ws/MacchineInsetup`, `/ws/InstallazioneNuovaMacchina`, `/ws/alldevices`, `/ws/specialtimes`, `/ws/guidaingressi`, `/ws/testmode`, `/ws/testdevice`, `/ws/EditMacchina` | WS | `ValidateUsers` (qualsiasi loggato, **non bloccante**, § 6) | browser operatore |
| `/ws/MqttDebug`, `/ws/armageddon`, `/ws/beMessages`, `/ws/ElencoFirmware`, `/ws/ElencoFwBI`, `/ws/ElencoSchermate`, `/ws/TemplatesSchermate`, `/ws/DeviceFirmware`, `/ws/DeviceFirmwareBI`, `/ws/MacchineInPending` | WS | `ValidateSuperAdmin` (bloccante) | browser superadmin |
| `/ws/filehelper` | HTTP multipart (max 2 MB) | nessun controllo proprio: usa il callback salvato in sessione dalla pagina superadmin | upload firmware, immagini, template |
| static `www/` (anche `resources/screens/<mac>/*.jpg`, `resources/templates/*.svg`) | HTTP | pubblico | browser; **D** le BE scaricano le schermate da qui |
| `/eclservices/getfirmware/OTA/<hw>/<fw>/<ver>.bin` | HTTP | pubblico; identifica il dispositivo dall'IP | schede in OTA (eclservice.bas:276-312, altra zona) |
| `/eclcommand?command=jSetupDevice|jAdopt|jOutOfService|jRebuild…|elenco|setupmode…` | HTTP | **nessuna** (altra zona) | WinMT (W08-07), pagina legacy |

Polling dalle pagine: 10 s (dashboard, online, setup, database, all devices), 30 s (firmware, happy hour), 8 s (test mode), 5 s (pending). **V** (`setInterval` negli HTML)

### 3.c Chiamate in uscita

| Verso | Come | Uso | Evidenza |
|---|---|---|---|
| Cloud `elmaccloud` (linked server SQL) | query a 4 parti ed `EXEC` remoti su `CoinlessDB`, `<DB>` della sala, `<DBSERVIZIO>` | installazione, wizard modello (**scrittura**), sync firmware/immagini/lingue | DBcoinless.bas:5133-5880; DBwinmt.bas:10904-11060 |
| Processo locale | `cmd.exe /c svghandler.exe -v` | rendering SVG → jpg | ScreenBuilder.bas:685-695 |
| Processo locale | `ping -n 1 <ip>` | diagnostica dispositivo | alldevices.bas:414-427 |
| File | `svghandler.json`, `errors.json`, `www\resources\screens\<mac>\`, `www\resources\templates\`, `manuale_html\`, `temp\` (upload), `keystore` | schermate, manuale, upload | ScreenBuilder.bas; utility.bas:78-86; ManualeHandler.bas:40-50 |
| Schede (MQTT) | credenziali wifi `wlessssid`/`wlesspwd` (da `dbsettings.txt`) in chiaro nel payload `cmd0`/`SetTotVal` | provisioning wifi | Main:3152-3160, 3507-3520 |

---

## 4. Dati

### 4.a Tabelle, viste e procedure usate (zona)

| Oggetto | DB | Operazioni | Note |
|---|---|---|---|
| EcsMacchine | sala | R, I (crea/duplica), U (config IO, costi, `F0`, `T0`, `device_status`, `Modu`, `device`, `is_happyhour`) | nessuna DELETE: l'eliminazione resta solo in WinMT (W08-10) **V** |
| EcsModuli | sala | R, MERGE, D (duplicati per MAC), U (`N0`, `ShortAd`, `Nimp`) | |
| EcsDati | sala | R, I (lettura zero), D (dopo snapshot, test mode, armageddon), U (armageddon) | |
| TransCard | sala | D (armageddon, opzionale) | |
| Operatori | sala | R | login |
| setup2 | sala | R/W/D | chiavi nuove in § 4.b |
| vs_eclmacchine | sala | R | fonte di `elencoMacchineInstallate` (DBwinmt.bas:511) |
| vs_CoinlessSpecialTimes, CoinlessTestataHappyHour, CoinlessMacchineHappyHour | sala | R; la **vista è (ri)creata da B4J** | ScreenBuilder.bas:115-170 |
| ecl_SchedeFirmware | sala/CoinlessDB | R, I, U, D | inventario schede e versioni |
| ecl_firmware | sala/CoinlessDB | R (blob), I, D | binari BE |
| CoinlessImages | sala/CoinlessDB | R, MERGE/I/U | immagini e firmware BI `.srec` |
| ecl_Provisioning | sala/CoinlessDB | D (forza il reinvio) | |
| CoinlessLanguages | sala/CoinlessDB | R, I, U | etichette display |
| coinless_sbuilder_templates_svg, coinless_sbuilder_pages, Coinless_sbuilder_page_provisioning | sala/CoinlessDB | R, I, U, D, DDL | |
| BEConfig | sala | R/U (via `setBEInfo`) | altra zona |
| ecl_log | sala/CoinlessDB | I | log MQTT se `mqtt_log=1`, test mode |
| Tabelle gru (DBCrane) | sala | via `Crane_SetInitialAvgValue` | altra zona |
| Cloud: CoinlessImpianti, vs_definizione_nome_macchina, CoinlessDefaultTypeConfig, sp_CoinlessMacchine, sp_ConfigurazioneMacchina, sp_DettaglioIngressiMacchina, `<DB>`.EcsMacchine, `<svc>`.Type/Manuf/Machines | cloud | R; **I** su Type/Manuf/Machines | |

**V** Il "DB coinless" è `CoinlessDB` o `WinMtSqlDB` a seconda di `SlaveIp`/`MasterIp`/`GamePark`/`coinlessServer` in `dbsettings.txt` (DBcoinless.bas:14-37). In alcune query il nome `WinMtSqlDB` è scritto fisso (DBcoinless.bas:407-430).

### 4.b Colonne e chiavi con significato nuovo o diverso da db-08

| Colonna/chiave | Significato in B4J | Rispetto a db-08 | Evidenza |
|---|---|---|---|
| `EcsMacchine.T0` | **JSON** `{valorepiatto, statoBI, errBI, BISwap, BISwapStep, NoRec}` | **contraddice db-08** (valore piatto/hopper testo numerico) | DBwinmt.bas:10389-10400, 10465, 10518, 10562, 10811 **V** |
| `EcsMacchine.NImp` | numero sala, scritto all'installazione web | **contraddice db-08** ("non scritto", riferito a WinMT) | DBwinmt.bas:15775-15782 **V** |
| `EcsMacchine.F0` | 1 = da riprogrammare (scritto da riallineamento, test mode, armageddon); 0 = fatto o creato da web | coerente; differenza: web crea con 0, WinMT con 1 | DBwinmt.bas:1155-1175, 10068 **V** |
| `EcsMacchine.device_status` | 'Online', 'Offline', 'Setup', 'OOO'; 'NotDetected' solo calcolato in query | coerente | MacchineConfigurate.bas:225-245; DBcoinless.bas:411 **V** |
| `EcsMacchine.Propr/PerDiv` | default '100'/100 all'installazione web | WinMT: scelta 0–100 (W08-03) | DBwinmt.bas:15770 **V** |
| `EcsModuli.ShortAd` | codice `device` (`<cliente>z<impianto>z<modu>`, ≤15 caratteri) | **contraddice db-08** (IP del modulo EcsNet) | DBwinmt.bas:1024-1027, 1595-1600 **V** |
| `EcsModuli.Nimp` | flag "programmabile": 1 = la BE può essere riassegnata | **non in db-08**; sovraccarico (altrove NImp = sala) | DBwinmt.bas:9418-9430, 9611-9620 **V** |
| `EcsModuli.T0`, `D0`, `Abil` | JSON con IP; ultimo aggiornamento; 1 | non in db-08 | DBwinmt.bas:1050-1060, 1110-1118 **V** |
| `ecl_SchedeFirmware.*` | `macaddress` (con `:` per BE/ESP, con `_` per display Astoria), `device` (`0z0z0` = non assegnata), `tipoScheda`/`tipoFirmware` (BE3/GAMES, MT/MANGIAT, RD/CASSATOT, VS/VISCREDTK, PHO/MOBILE, …), `requestedVersion`, `detectedVersion`, `bidetectedVersion`, `dataAggiornamento`, `dataVerifica`, `status` | non in db-08 (winmt-00 § 4: non usata da WinMT) | DBcoinless.bas:366-430, 599, 785; mqttMessages.bas:120-145 **V** |
| `setup2` (101) `TestMode_<codmac>` | JSON baseline del test mode | non in db-08 | DBwinmt.bas:10138-10230 **V** |
| `setup2` (101) `ArmageddonEseguito` | JSON guardia "una sola volta" | non in db-08 | DBwinmt.bas:1423-1440 **V** |
| `setup2` (101) `typename_<tipo>` | JSON configurazione di default per tipo, copiata dal cloud | non in db-08 | DBcoinless.bas:5823-5860 **V** |
| `Operatori.Id = 0` | unico criterio di superadmin nel backoffice | db-08: superadmin per `Livello` | Main:4153-4200 **V** |
| `Operatori.codbar` | credenziale unica del login QR, senza password | db-08 la descrive come barcode di login | DBwinmt.bas:6178 **V** |
| `EcsDati` In1–8 nell'UI | "Ing 1" = `coins_counter`, … "ECOIN" = `in8_counter` (nomi storici, mappatura posizionale) | da confrontare con db-08 `EcsDati` | MacchineOnline.bas:130-140 **V** |

### 4.c DDL eseguito dal codice

| DDL | Quando | Evidenza |
|---|---|---|
| `CREATE TABLE coinless_sbuilder_templates_svg` / `coinless_sbuilder_pages` / `Coinless_sbuilder_page_provisioning` se mancanti | a ogni `ScreenBuilder.Initialize` (Main e ogni apertura di `TemplatesSchermate`) | ScreenBuilder.bas:47-112, 172-175; TemplatesSchermate.bas (Initialize) **V** |
| `DROP VIEW` + `CREATE VIEW vs_CoinlessSpecialTimes` (con `nometemplate`, `coinval = valpar × 100`) se manca la colonna | idem | ScreenBuilder.bas:113-171 **V** |

**D** La vista viene creata sulla connessione "coinless". Se quel DB è `CoinlessDB` (configurazione a due DB), `dbo.EcsMacchine` non c'è e la creazione fallisce. La vista in `sql/codice-db/prod/applicativo/viste/vs_CoinlessSpecialTimes.sql` coincide con quella di B4J.

### 4.d Stato fuori dal DB che è di fatto un dato

| Stato | Dove | Contenuto | Evidenza |
|---|---|---|---|
| `elencoMacchineMqttSetup` | memoria | stringhe `device@mac@ip@Ready|NotReady` (formato posizionale) | mqttMessages.bas:974; Main:4465-4510 **V** |
| `elencoMacchineOnlineMqttMain`, `elencoMacchineOnlineConStato` | memoria | mappe `{device, macaddress, IpAddress}`; stringhe `device@mac@stato` | Main:4511-4590 **V** |
| `elencoAltriDevice`, `elencoBEImpiantoDiverso` | memoria | `{macaddress, model (reader/mangiat/viewer), IpAddress, impianto}` | Main:4533-4665 **V** |
| `elencoMacchineInstallate` | memoria (cache di `vs_eclmacchine`) | mappa `device` → riga | DBwinmt.bas:511 **V** |
| Coda BE `programmableDevices`, coda BI `programmableBIDevices` | memoria | stato della programmazione e dell'OTA per MAC | deviceprogrammer.bas:8; biprogrammer.bas:8 **V** |
| `Main.setupmode` ("install mode") | memoria | sospende l'elaborazione delle partite | Main:288, 1530 **V** |
| `Main.macchina` | memoria globale | variabile d'appoggio riempita da `macchinaFromMap` in tutte le pagine | MacchineOnline.bas:88; MacchineInsetup.bas:117 **V** |
| `elencoAvvisiSistema` (FIFO 50), `Provisionerror`, `elencoBISwapRetryCooldown` | memoria | avvisi, tentativi di provisioning, cooldown | Main:4704-4718, 230-238 **V** |
| `dbsettings.txt` | file | `wlessssid`/`wlesspwd`, `GamePark`, `fonts` (font BE), `tokenReaderLabel*`, `DecimalPlaces`, `ForceDecimalDisplay`, porte, `Master`/`Primario` | Main:290-420; Main:4001-4015 **V** |
| `www\resources\screens\<mac>\*.jpg|svg`, `www\resources\templates\*.svg` | file | schermate generate e template; il DB tiene solo i nomi | ScreenBuilder.bas:485-680 **V** |
| `manuale_html\{operatore,superadmin}` | file | manuale per ruolo | ManualeHandler.bas:40-50 **V** |

### 4.e Sovraccarichi semantici

- **V** `EcsMacchine.T0` è diventato un contenitore JSON per stato BI, swap e sospensione della registrazione, mentre WinMT lo legge come valore del piatto. **D** Rischio di parsing incrociato.
- **V** `EcsModuli.Nimp` è un flag di programmabilità, non un numero di sala. `EcsModuli.ShortAd` è un device, non un IP.
- **V** `device = "0z0z0"` è il valore sentinella "scheda non assegnata" in topic, liste, `ecl_SchedeFirmware` ed `EcsModuli` (Main:4668-4700; DBcoinless.bas:785).
- **V** Il tipo di dispositivo si ricava in tre modi diversi:
  - segmento del topic (`Client…`, `reader`, `mangiat`, `viewer`) (mqttMessages.bas:64-100);
  - prefisso della versione firmware: 131 BE GAMES, 123/133 mangiaticket, 132 lettore cassa/totem, 136 visualizzatore crediti, 311 display Astoria, 900 telefono (mqttMessages.bas:156-235);
  - campo modello in `ecl_SchedeFirmware` (alldevices.bas:262-265).
- **V** La Dashboard conta i `reader` come "writer" e i `viewer` come "reader" (Dashboard.bas:83-91).
- **D** Gru e coin reader non sono tipi di dispositivo. La gru è un tipo di macchina (`EcsMacchine.Tipo` 3, 9, 12, 17). "Coin reader" è l'etichetta prezzo che la BE mostra (`tokenReaderLabel`, Main:4001-4015).

---

## 5. Doppioni e sovrapposizioni con WinMT

**Risposta diretta.** Sì: la configurazione macchina si fa **sia da WinMT (`frmConfMacc`, `FormModificaPrezzi`, `FrmConf`) sia dal backoffice B4J**, sulle stesse colonne di `EcsMacchine`, con regole che non coincidono del tutto. **V** (codice B4J) / **D** (lato WinMT dai documenti `winmt-08`).

| # | Ambito | WinMT | B4J | Differenze di regola |
|---|---|---|---|---|
| 1 | Login e ruoli | W10-06/07/09 | E06-01/02/04 | B4J: superadmin = `Id = 0`, il login con password ignora `Attivo`, ruoli "operatore/superadmin". WinMT: `Livello and 3`. |
| 2 | Catalogo modelli (`Machines`/`Manuf`/`Type`) | W08-01 (cloud con ripiego locale) | E06-23 (solo cloud servizio) | Stesso `MAX+1` (`Type` < 100); B4J non ripiega in sala e non elimina. |
| 3 | Nuova macchina | W08-03/04 | E06-22 | B4J `F0 = 0` e programmazione immediata contro WinMT `F0 = 1`; B4J copia la configurazione da macchine **di altre sale** (flotta cloud); B4J non è transazionale (WinMT lo è nel wizard); `Propr/PerDiv = 100` fissi. |
| 4 | Duplicazione | W08-06 | E06-13 | Stesso `INSERT…SELECT` (copia `Keys`, `CntrLet`, `F0`, **`T0`**: B4J copia anche lo stato swap/NoRec della sorgente); B4J poi sovrascrive costi ed erogatori. |
| 5 | Ingressi/contatori | W08-05 | E06-19 | Formula `ValIn9` (E-coin) diversa (§ 2.1); WinMT riscrive le colonne 5–100, B4J solo quelle toccate; B4J non gestisce uscite/contascatti di uscita, macchine a tempo, relè. |
| 6 | Costi per livello | W08-12 | E06-20 | B4J non invia i crediti alla BE né mette `F0 = 1`; WinMT sì. |
| 7 | Adozione/programmazione BE | W08-07 (`jAdopt`, `jSetupDevice`, `jonline`, `jOutOfService`) | E06-08/09/15/18/24 | WinMT chiama gli endpoint del servizio (complementare). Dentro B4J però l'adozione è scritta 3 volte (§ 2.1). |
| 8 | Happy hour | W04-17 (configurazione) | E06-30, applicazione in `controlloMacchine_Tick` (Main:3073-3105, altra zona) | Complementare. B4J legge la vista che lui stesso ricrea; WinMT chiede la rigenerazione delle pagine. |
| 9 | Valore medio gru | W07-11 | E06-22 (`Crane_SetInitialAvgValue`) | Sovrapposizione all'installazione. |
| 10 | Azzeramento contatori | W08-10 (per macchina, cancella `EcsDati` + `TransCard`) | E06-44 (tutto l'impianto, `TransCard` opzionale), E06-10, E06-32 | B4J mantiene l'ultima riga `EcsDati` e azzera; WinMT cancella e riscrive una lettura a zero. |
| 11 | Disinstallazione/eliminazione | W08-10/11 | assente | Solo WinMT. **V** nessuna DELETE/`DataDis` nel B4J di zona. |

**Specialtimes e GrigliaIO.** `specialtimes.bas` è sola lettura, quindi non è un doppione della gestione W04-17. `GrigliaIO` sì è un doppione della parte ingressi di `frmConfMacc` (W08-03/05), con la stessa mappa dei pin.

**Divergenze con la documentazione di Fabrizio (`docs/fonti/ecl2mqtt/`).**

| Documento | Divergenza | Codice |
|---|---|---|
| `macchine_insetup.md` | Descrive 934 righe, liste `newdevicelist`/`offlinedevicelist`, `duplicate_and_assign_device`, `overwrite_be`, assegnazione `0z0z0` in questa pagina, elementi `device@macaddress`. Oggi il modulo ha 806 righe, **esclude le `0z0z0`** (l'assegnazione è passata a Database/All devices/Installazione) e gli elementi sono `device@mac@ip@stato`. | MacchineInsetup.bas:118; mqttMessages.bas:974 |
| `notebooklm/04-machines-setup-assegnazione.md` | "New device list" nella pagina Setup: non esiste più. | idem |
| `installazione_nuova_macchina.md` § 5 | `Propr`/`PerDiv` NULL: nel codice valgono '100'/100. Non cita il valore medio gru, il filtro per `Tipo` locale, né `avviaProgrammazioneBEAsync`. § 7-bis: la creazione di `Type` "disabilitata", ma l'handler `wizard_type_crea` resta invocabile da `b4j_raiseEvent`. | DBwinmt.bas:15770; InstallazioneNuovaMacchina.bas:213-232, 690-712, 816 |
| `boot_scheda_be.md` § 1 | "`mqtt_setup` → broker di setup": entrambi i client sono su `tcp://localhost`. I riferimenti di riga (`ecs2mqtt.b4j:1964`, `:1219`) non corrispondono più alla 2.39.55. | Main:717, 1928 |
| `metadata/menu-map.md` | Mancano Guida ingressi, Test Mode, Armageddon (menu attuale: sidebarMenu.bas:54-82). | sidebarMenu.bas |
| `notebooklm/01-login.md` | "la Dashboard non ha un menu proprio": vero in pratica (`index.html` non ha `#dynamicmenu`), anche se `Dashboard.bas` lo disegna. | Dashboard.bas:32-33 |
| `notebooklm/07-machines-database.md` | "La duplicazione non copia i contatori": copia invece le letture `CntrLet1..16` della sorgente; azzera solo `EcsDati`. | DBwinmt.bas:6320-6330, 6387 |
| `armageddon.md` | Coerente col codice; non segnala l'assenza di transazione. | DBwinmt.bas:1500-1560 |

---

## 6. Problemi e rischi

**Sicurezza**

1. **V** `ValidateUsers` non interrompe `WebSocket_Connected`: fa solo un redirect via `Eval` (Main:4111-4125). Un client non autenticato riceve comunque l'HTML generato. Gli eventi WebSocket (`toggle_ooo`, `setup_all`, `reboot_device_Button`, `assegnabe_riprogramma`, `installa_macchina`, `format_be`, `avvia_test`…) **non ricontrollano la sessione** e sono invocabili con `b4j_raiseEvent` dalla console. Solo Armageddon e il toggle install mode ripetono il controllo.
2. **V** Il login con password non è limitato al superadmin, al contrario di quanto dice il commento, e ignora `Attivo` (§ 2.1). Le password sono offuscate in modo reversibile (`sicurezza.DecPWord`, DBwinmt.bas:6125).
3. **V** Credenziali nel codice: broker MQTT (Main:723, 1941) e keystore SSL (Main:3736). Le credenziali wifi viaggiano in chiaro nei payload MQTT.
4. **V** SQL con concatenazione: `elencaSchedeFirmware` usa il MAC (DBcoinless.bas:420-428) e `TabellaTemplatesDisponibili` il cliente/impianto. `esisteRecordServizio` costruisce tabella e colonna con whitelist (`svcValido`, DBcoinless.bas:5551).
5. **V** Firmware, schermate e template sono serviti senza autenticazione; `getfirmware` identifica il chiamante dall'IP.

**Consistenza e transazioni**

6. **V** Nessuna transazione nei flussi multi-tabella: installazione, assegnazione BE (`aggiornaModuloEcs` cancella i duplicati prima del MERGE), duplicazione, riallineamento, test mode, Armageddon.
7. **V** Identificativi `MAX+1` (`EcsModuli.Id`, `EcsMacchine.Modu`, `device` da `MAX(device)`, `Type`/`Manuf`/`Machines` sul cloud) senza lock: rischio di duplicati con più operatori o tra WinMT e B4J.
8. **V** `device` costruito dal `MAX(device)` testuale: con prefissi di sala diversi o `Modu ≥ 10` l'ordinamento lessicografico può prendere un prefisso o un numero sbagliato. **D**
9. **V** La riprogrammazione rimette `device_status = 'Online'` anche alle macchine OOO (deviceprogrammer.bas:291, 431).
10. **V** `inviaComandoECLSETUP` ignora `timetosleep` (Main:2295-2310). Le sequenze `cmd0…cmd7` di `creaDeviceDaWinmt` partono senza intervalli e il `Wait For` su una sub che non si sospende è lo stesso schema che Fabrizio ha già corretto per `inviaComandoECL`.
11. **V** Confronti di versione firmware come stringhe (§ 2.1).
12. **V** L'installazione modo A/C e il wizard modello dipendono dal cloud: un nuovo dispositivo non si installa da web senza connettività (resta il modo B, duplica locale). Contrasta col requisito "sala autonoma dal cloud". **D**
13. **V** `EcsMacchine.T0` JSON scritto da B4J: se WinMT lo legge come numero (piatto/hopper, db-08) si rompe in uno dei due versi. **D**

**Concorrenza e stato**

14. **D** `Main.macchina` e le liste in memoria sono condivise tra i thread WebSocket di jServer senza sincronizzazione (lo nota anche `macchine_insetup.md` § 8.4).
15. **V** Lo stato del ciclo di vita (setup, online, Ready, code BE/BI, install mode) è in memoria e si perde al riavvio. Si ricostruisce dai topic retained (**D**) e dal flag `F0`.
16. **V** `TemplatesSchermate` crea un proprio `ScreenBuilder`, con un lock separato da quello di `Main` e la DDL ripetuta.
17. **V** "Install mode" sospende l'elaborazione delle partite di tutta la sala senza persistenza né timeout (Main:1530).

---

## 7. Domande aperte per il team

1. Il backoffice B4J deve diventare **l'unico** punto di configurazione macchine (WinMT `frmConfMacc`/`FormModificaPrezzi` dismessi) o i due restano in parallelo? Oggi le regole divergono su `F0`, E-coin, costi e `Propr`/`PerDiv`.
2. La formula `ValIn9` corretta è quella di WinMT (`valore impulso × impulsi`) o quella di B4J (`ValPar / impulsi`)? Serve un confronto su righe reali di produzione.
3. Ruoli: il modello `Id = 0` superadmin / tutti operatori è voluto? Il login con password va limitato al superadmin, come dice il commento?
4. Il cloud deve essere obbligatorio per installare una macchina (ricerca nella flotta, wizard modello)? Come si installa offline?
5. `EcsMacchine.T0` JSON: WinMT legge ancora `T0` come valore del piatto? Si può spostare lo stato BI/swap/NoRec in una tabella dedicata?
6. Le BE scaricano davvero schermate e testi dalla cartella statica `www` via HTTP? Con quale URL e protocollo, visto che `ProcessaTopicProvisioned` e `getProvisioningGames` sono in altra zona?
7. Le macchine OOO riprogrammate devono restare OOO? Oggi tornano Online.
8. "Install mode" (`setupmode`) è ancora usato in sala? Cosa deve succedere alle partite mentre è attivo?
9. Il broker "di setup" separato (`MqttSetup`) è stato abbandonato di proposito (tutto su localhost)? Va previsto nel nuovo disegno?
10. `ecl_SchedeFirmware`, `ecl_firmware`, `CoinlessImages`, `CoinlessLanguages` e le tabelle sbuilder: vanno nel DB di sala, in quello cloud o in entrambi, con quale verso di sincronizzazione (oggi manuale e bidirezionale "solo righe mancanti")?
