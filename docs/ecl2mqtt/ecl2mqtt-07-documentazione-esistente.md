# Galileo HQ — ecl2mqtt 07: la documentazione esistente in `docs/fonti/ecl2mqtt/`

**Stato:** bozza · **Responsabile:** Piero · **Aggiornato:** 2026-10-25

**Collegati:** [`ecl2mqtt-00-mappa.md`](ecl2mqtt-00-mappa.md) (mappa e sintesi trasversale). Nel testo, «zona NN» indica il documento ecl2mqtt NN.

Ambito: tutti i file di testo in `docs/fonti/ecl2mqtt/` (27 `.md` alla radice, `metadata/` 8 file, `notebooklm/` 23 file, `manuale/chapters/` 47 file, 2 `.odt`). Gli screenshot sono stati solo censiti. Il codice in `legacy/ecl2mqtt/` è stato aperto solo per i controlli puntuali del § 5.3.

Convenzioni: **V** = verificato nel codice; **D** = dedotto dalla documentazione o dal confronto fra documenti. I path dei documenti sono relativi a `docs/fonti/ecl2mqtt/`. Nei documenti compaiono chiavi API in chiaro: qui sono indicate solo come «credenziale nel documento (file:riga)».

**Premessa sull'autore.** I documenti sono scritti da Fabrizio insieme a un assistente IA. Lo dicono la forma («confermato dall'utente», «Destinatario: Claude che modifica il frontend VB6», `guida_vb6_prizehub.md` intestazione; «Istruzioni per l'IA», `istruzioni_vb6_prizehub_opzioneA.md`) e i rimandi a un `CLAUDE.md` e a un `LAVORO_IN_CORSO.md` del progetto B4J, che **non sono nel repository** (D). Quando i documenti dicono «l'utente», intendono quasi sempre Fabrizio. Fa eccezione `ECL_KIOSK_API_MANCANTI_rev009.md`: lo scrive il team del totem (rimanda a `project-kiosk-mockup/…` e a `libs/services/ecl_api_client/…`, repository che non abbiamo), e il lato server ci ha aggiunto le note «RISOLTO».

---

## 1. Inventario

Le date vengono dall'intestazione o dal testo; dove manca, è la data di modifica del file (mtime), segnata con `(m)`. Le date (m) del 2026-09-03 coincidono con una copia in blocco e non indicano la data di stesura.

### 1.1 API e contratti

| File | Data | Argomento | Tipo | Pubblico | Stato apparente |
|---|---|---|---|---|---|
| `api_index.md` | 2026-09-03 → 2026-10-21 (storico § 5) | Mappa di tutti gli handler HTTP; dettaglio di `/kiosk` (§ 3.1-3.12) e di `getkioskconfig` (§ 4) | specifica + change log | sviluppatori server, team del totem | **attuale**, con buchi (§ 5.1) |
| `api_app_tickets_handler.md` | 2026-07-29 (m) | `/app`: gruppi PLAYER, SERVICE, PRIZEHUB, swap BI | specifica | app ECL Service (operatori) | attuale, ma path di login errato |
| `api_prizehub.md` | 2026-07-24 | `/hub` (app Flutter PrizeHub) e azioni `SVCPH*` di `/app` | specifica | app PrizeHub, backoffice | **attuale**: la più aderente al codice |
| `specifica_flutter_prizehub.md` | 2026-05, v1.4 | Progetto di `FlutterTicketsHandler` e di `PrizeHubSlots` | specifica di progetto | sviluppatori | in parte **superata** (formato del codice fittizio SPINDLE) |
| `analisi_tickets_handlers.md` | 2026-05-19 (m) | Confronto fra `TicketsHandler` (Baytech) e `AppTicketsHandler` | analisi | sviluppatori | **superata** (elenca 5 azioni SVCPH, oggi sono 10) |
| `api_partner.md` | 2026-08-17 (m) | `/partner`: read, balance, withdraw | specifica | integratori terzi | attuale |
| `api_crane_handler.md` | 2026-05 | `/crane`: gestione gru, slot, magazzino | specifica | app di gestione gru | attuale |
| `ECL_KIOSK_API_MANCANTI_rev009.md` | 2026-10-14, con note fino al 2026-10-21 | API che mancano al totem (M1-M6), domande A-L, stile dei nomi | analisi / richiesta | chi scrive le API di sala | **bozza** («da studiare prima di girarla») |

### 1.2 Rapporto con WinMT VB6

| File | Data | Argomento | Tipo | Pubblico | Stato apparente |
|---|---|---|---|---|---|
| `legacy_vb6_cliente_analysis.md` | 2026-09-07 → 2026-10-20 | `ECL_cliente.cls` / `ECL_Conversioni.cls` confrontate con le classi B4J del cliente; anti-clonazione, VIP | analisi + piano di porting | sviluppatori | attuale, con aggiornamenti per strati |
| `legacy_vb6_log_eventi_bonus_analysis.md` | 2026-09-08/09 | AuditLog, LogTransazioniPos/Totem, eventi, compleanni, promozioni, BonusHandler | analisi + piano di porting | sviluppatori | in parte **superata** dagli aggiornamenti (incoerenze interne, § 5.1) |
| `guida_vb6_prizehub.md` | 2026-05 | Come WinMT passa da `Premi.PDis/QDis` a `PrizeHubSlots` con SQL diretto | guida operativa (per l'IA) | chi modifica WinMT | **superata per le scritture** dal 2026-07-10; valida per il modello dati e le letture |
| `istruzioni_vb6_prizehub_opzioneA.md` | 2026-07-10 (m) | `frmEditPrizeHub` di WinMT che chiama le REST invece di scrivere SQL | guida operativa (per l'IA) | chi modifica WinMT | attuale come decisione; contratto di login errato |

### 1.3 Schede, MQTT e provisioning

| File | Data | Argomento | Tipo | Pubblico | Stato apparente |
|---|---|---|---|---|---|
| `boot_scheda_be.md` | 2026-08-17 (m) | Cosa fa il server al boot di una BE (topic, handler, DB) | analisi di flusso | sviluppatori, assistenza | attuale nella logica; **numeri di riga spostati** |
| `magiaticket_flow.md` | 2026-08-18 | Connessione di una BE con firmware MagiaTicket | analisi di flusso + fix | sviluppatori | attuale |
| `macchine_insetup.md` | 2026-08-17 (m) | Pagina `MacchineInsetup`: assegnazione e riprogrammazione delle BE | analisi di flusso | sviluppatori | attuale (v2.38.x) |
| `installazione_nuova_macchina.md` | 2026-08-20 → v2.39.2 | Pagina mobile di prima installazione; uso del cloud via linked server | specifica di progetto + decisioni | sviluppatori | «IMPLEMENTATO … NON COMPILATO»: **bozza** di progetto |
| `armageddon.md` | 2026-10-02 (m) | Azzeramento totale dei contatori, una sola volta per impianto | analisi di flusso + fix | sviluppatori, superadmin | attuale |

### 1.4 Strutture dati e regole

| File | Data | Argomento | Tipo | Pubblico | Stato apparente |
|---|---|---|---|---|---|
| `tabella_tickets_e_bitmap_mangiat.md` | 2026-10-21 | `Tickets`, bitmap `MangiaT`, saldo FIFO, fix `NonCont` | analisi dati | sviluppatori, analisti | attuale |
| `tabella_vincite.md` | 2026-10-21 (m) | `Vincite`: chi la scrive, cosa si è perso rispetto a VB6 | analisi dati | sviluppatori, analisti | attuale |
| `evento_gold.md` | 2026-10-08 (m) | Promozione stagionale GOLD: livelli, prezzi, ticket sospesi | analisi di regola | gestione sala, sviluppatori | attuale |
| `gestione_transazioni_da_verificare.md` | 2026-10-14 (m) | Giocate «da verificare», blacklist automatica | guida divulgativa | gestori di sala | attuale (caso osservato a ottobre 2026) |
| `fn_ecsdatigiornalieri.md` | 2026-10-08 | Funzione SQL dei delta giornalieri + spesa a card | analisi dati | analisti | attuale |
| `storicizzazione_cache_dati_grafico_giornaliero.md` | 2026-10-16 (m) | `sp_generacache` e la cache giornaliera dei report | guida divulgativa | gestori, analisti | attuale |
| `gestione_gru_e_valore_premi.md` | 2026-10-11 (m) | Valore medio dei premi nelle gru e report | guida divulgativa | gestori | attuale |
| `gru_valore_medio_iniziale.md` | 2026-10-10 (m) | Perché `ValIn6/7/8` viene sovrascritto; proposta di valore iniziale | analisi + proposta | sviluppatori | **superata**: la proposta è stata implementata (§ 5.3) |
| `sql_svuota_prizehub.md` | 2026-06-12 (m) | Script manuale: svuota un hub e riporta i premi a magazzino | script / guida operativa | assistenza | attuale; si basa sulla regola «fittizio = Attivo 0 e Prenotabile 0» |

### 1.5 Incidenti

| File | Data | Argomento | Tipo | Pubblico | Stato apparente |
|---|---|---|---|---|---|
| `fix_timeout_rimborsi_transcard.md` | settembre 2026 | Rimborsi lenti su `TransCard`; indici, query non sargable, auto-provisioning in `Setup` | change log / post-mortem | sviluppatori, DBA | attuale; due attività dichiarate ancora da fare |

### 1.6 Manuale del backoffice e materiale derivato

| Cartella / file | Data | Argomento | Tipo | Pubblico | Stato apparente |
|---|---|---|---|---|---|
| `metadata/` (scope, menu-map, routes.json, topics.json, staging-verification, manual-review, final-report, worklog) | 2026-09-01/03 | Processo in 9 fasi di produzione del manuale; verifiche sullo staging `.38` | log di processo | redazione | concluso; la `final-report` dichiara 9 file di metadata, ne sono presenti 7 (mancano `screenshot-plan` e `screenshots`) |
| `manuale/chapters/analisi/` (19) | 2026-09-03 | Schede per pagina, ricavate dal codice, con i «DA VERIFICARE» | analisi | redazione | concluso; contiene informazioni di dominio date da Fabrizio (DbConfig, Master/Slave) |
| `manuale/chapters/bozza/` (22) | 2026-09-03 → 2026-10-05 | Capitoli del manuale per operatore e superadmin | manuale | operatori, superadmin | attuale; più recente degli `.odt` (07a Guida ingressi, 07b Test Mode, 18 Armageddon) |
| `manuale/chapters/ecl/` (6) | 2026-10-14/15 | «Come funziona ECL»: giocata, card, ticket, contatori, stati | manuale divulgativo | operatori | attuale, ma con un errore sul significato di BI (§ 4) |
| `manuale/manuale-operatore.odt` | 2026-09-03 | 8 capitoli: Accesso, Dashboard, Machines → Online/Setup/Installazione/Database/All devices/Happy hours | manuale | operatori | **superato** dalle bozze |
| `manuale/manuale-superadmin.odt` | 2026-09-03 | 12 capitoli: Accesso, Dashboard (riservate), Firmware BE/BI, Config → DbConfig/BE fw/BI fw/Screens/SVG/Languages/Sync/MQTT Debug | manuale | superadmin | **superato** dalle bozze |
| `notebooklm/` (indice, 21 fonti, `prompts.md`) | 2026-09-03 → 2026-10-05 | Fonti e prompt per «pillole» video | materiale didattico | formazione | derivato dal manuale; non aggiunge informazioni |
| `screenshots/` | — | 18 cartelle (una per pagina: login, dashboard, machines-*, firmware-*, config-*), 42 png | immagini | — | coerenti con il manuale di settembre |

---

## 2. Cosa dice sulle tre domande

### 2.1 (a) Rapporto con WinMT VB6

**Non esiste un piano dichiarato di «spostare WinMT nel motore».** Esiste invece un **porting a pezzi** della logica di business VB6 dentro il B4J, guidato dalle API del nuovo totem Flutter (`/kiosk`). Ogni documento dice di voler distribuire il codice VB6 sugli strati B4J (dato in `cliente.bas`, SQL in `DBwinmt.bas`, regola in `clsGestioneCliente*`) e di non ricreare il «god object» (`legacy_vb6_cliente_analysis.md` § 1). Il risultato sono **doppioni voluti**: la stessa regola vive in WinMT (cassa VB6) e nel B4J (totem), a volte con differenze dichiarate.

| Regola VB6 | Dove in B4J | Stato e differenze dichiarate | Fonte |
|---|---|---|---|
| `leggiSaldoCreditiEBonus` (saldo da `TransCard`) | 4 sub di lettura cliente in `DBwinmt` | «sostanzialmente equivalente». Mancano la sottrazione di `nimp=18`, il filtro `winmt=1` e il toggle `IsBonusInTranscard`. In più c'è un ramo `GamePark` | cliente § 3.1 |
| `ConfrontaCardConCliente` (anti-clonazione) | `cliente.ConfrontaCardConCliente` → `/kiosk/action/sync-card` | portato il 2026-09-07. Il ramo «card non aggiornata» **non segna più clonata**: è una scelta B4J diversa dal VB6. Confronta con `UltimoProgressivoTransCard`, non con `Clienti.N0` | cliente § 3.4 |
| Modelli VIP (`isEligibleForVIPpromotion`, `raggiungeSogliaMinima`, `updateCardLevel`) | `cliente.IsEligibleForVIPpromotion`, `ApplicaPromozioneVIPAutomatica` | portati il 2026-09-09. **Corretta l'unità** rispetto al VB6, che confrontava valuta con centesimi: la regola ora diverge dal VB6. Mancano `updateSubscription`, `PagaCanone`, `ReimpostaLivelloCard` | cliente § 3.5 |
| `ClassPromozioni.ImpostaLivello` (GOLD in promozione) | `DBwinmt.ImpostaLivelloPromozione` usata da `create-user` e dal riscatto | portato, con **fix** di `isPromozione` (prima confrontava `scadenzaPromozione`) | log_eventi § 5; `evento_gold.md` |
| Ripristino a fine promozione (`cercaCardPromozionale` …) | `cliente.RipristinaLivelloPromozionaleSeScaduto` in `sync-card` | portato il 2026-09-10; scatta solo quando la card passa al totem | cliente § 3.5 agg. 3 |
| BIRTHDAY → SILVER a fine evento | `RipristinaLivelloSeCompleannoScaduto` | **regola nuova**, senza equivalente VB6 | cliente § 3.5 agg. 3 |
| `LogTransazioniPos.cls` | `/kiosk/action/pos-transaction-*` | portato il 2026-09-08 | log_eventi § 0, api_index § 3.9 |
| `LogTransazioniTotem.cls` | `start-` / `log-` / `close-transaction` | parziale: manca lo `Scassettamento`. Il rollback ora scrive `Error`, il VB6 non toccava il DB | api_index § 3.6-3.8 |
| `ECL_BonusHandler` | `scalettaBonus` → `calc-bonus`, tickets bonus nella `recharge-card` | parziale: manca `recalcForBirthday` | log_eventi § 6, api_index § 3.5 |
| `AddTransCard` (ricarica) | `DBcoinless.RicaricaCardTotem` → `recharge-card` | portato. `NImp=1` per il totem contro `0` del cassiere; `N0` preso dal progressivo della card, non da `MAX(N0)+1` | api_index § 3.10 |
| `ModAddNew.AddCliente` (IdContatto in `SERIALIZABLE`) | `creaClienteAnonimo` con `UPDLOCK, HOLDLOCK` e 3 tentativi | stesso scopo, tecnica diversa | api_index § 3.3 |
| `cls_RedeemManager` / `RiscattaCodice` (codici RD) | `redeem-check` / `redeem-confirm`; SP `sp_redeem_*` riscritte per JDBC | portato. Il ramo `recharge`, **mai implementato in VB6**, è stato progettato da zero | api_index § 3.11 |
| `DistribuisciImporto` | `distribuisci-importo` | portato, con fix della divisione intera | api_index § 3.12 |
| `DisconnettiCliente` / `EliminaCliente` | `detach-card` (`sp_ripristinacard`) / `purge-card` (`sp_eliminacliente`) | `detach` equivale; `purge` è **un'altra cosa**: cancellazione fisica a cascata invece dell'anonimizzazione VB6 | cliente § 3.2-3.3 |
| `ClassEventi`, `clsCompleanno` (CRUD), `rimpiazzaLaMiaCard` | — | **non portati** | log_eventi § 4, § 7; cliente § 3.6 |

**PrizeHub: è l'unico caso con una decisione esplicita sulla separazione.** L'«Opzione A», decisa il 2026-07-10, dice che WinMT `frmEditPrizeHub` smette di scrivere SQL per carico e calibrazione degli slot e chiama le REST del B4J (`SVCPHLOADSLOT`, `SVCPHSETTICKETSMEDI`, `SVCPHRESET_TICKETSMEDI`). Le letture restano in SQL. Motivo dichiarato: «un'unica implementazione della logica → divergenza impossibile» (`istruzioni_vb6_prizehub_opzioneA.md` § 0; `guida_vb6_prizehub.md` riquadro iniziale). La decisione **è stata applicata**: l'analisi WinMT (`docs/winmt/winmt-07-inventario-prizehub-gru.md`, r. 21 e 137-138) dice che `frmEditPrizeHub` «scrive solo tramite API HTTP», verso `http://<server SQL>:58889` con porta fissa. Il punto § 1.1 delle istruzioni («rendere IP e porta configurabili») non risulta quindi seguito (D). Restano aperti il controllo di giacenza, che il server non fa (§ 5.1), e la scelta fra replace/mix da WinMT (§ 5.2).

**Complementarità dichiarata (l'uno scrive, l'altro legge):**
- le fasce **Happy Hour** si configurano in WinMT; il backoffice B4J le mostra soltanto (`manuale/chapters/bozza/07-machines-happyhours.md`, Note; worklog 2026-09-01, punto 1);
- la **data di disinstallazione** di una macchina si imposta in WinMT (`bozza/05-machines-database.md`, nota operativa);
- i **parametri globali** di `setup` `IdPost 101` (codice cliente e impianto, `RappCentValuta`, `RappCreditiCent`, label TOK) sono condivisi: modificarli da DbConfig li cambia anche per WinMT (`analisi/10-config-dbconfig.md`, Global settings);
- il campo «Coinless Server» va «sempre impostato su WinMT» (stesso file);
- al boot il server «chiede a WinMT se deve aggiornare la configurazione» leggendo il flag `EcsMacchine.F0` (`boot_scheda_be.md` § 6.1). Chi scrive `F0` non è detto: sembra WinMT, quando modifica una macchina (D).

### 2.2 (b) Interlocutori e architettura

| Interlocutore | Canale | Cosa scambia | Fonte |
|---|---|---|---|
| **Schede BE** (giochi, firmware major 131) con la loro **BI** | MQTT: broker main (`tcp://localhost`) e broker di setup | status, `send_client` (record `cmd` con HMAC), `ElmacStatusBI`, `StateBE`, `SetUp/<mac>`; comandi su `ElmacECL/<device>`, `Service/<mac>`, `SetUp/<mac>` | `boot_scheda_be.md` § 1-6; `armageddon.md` § 5.7 |
| **MagiaTicket** (MT, firmware 123/133), **cassa/totem** RD (132), **visualizzatore** VS (136), **mobile** PHO (900), «astoria» (311) | MQTT, provisioning dei file (`updatelist`, `SetTotVal`) | elenco file, immagini, lingue, configurazione dei device non-game | `magiaticket_flow.md` § 1, § 5; `boot_scheda_be.md` § 6 |
| **Totem self-service** (app Flutter + «engine» Python, client `EclKioskClient`) | HTTP `/kiosk/*` con bearer; `/eclservices/getkioskconfig` e `getscalettabonus` senza auth | card, ricariche, log del contante e del POS, riscatto, storico | `api_index.md` § 3-4; `ECL_KIOSK_API_MANCANTI_rev009.md` § 2, § 9 |
| **PosHandler** («servizio di sala che accentra tutti i POS», «super partes») | dal totem, non dal motore | il totem ottiene `uidPOS` e poi scrive `LogTransazioniPos` tramite il motore | rev009 § 2bis; api_index § 3.9 |
| **App PrizeHub** (Flutter, chiosco di riscatto dei premi) | HTTP `/hub/*` | lettura card, catalogo, riscatto | `api_prizehub.md` § 1 |
| **Hardware PrizeHub** | MQTT `HUB/{hubId}/eject` (in uscita) | `{unit, slot, prize, qty}` | `api_prizehub.md` § 1 redeem; V `FlutterTicketsHandler.bas:351` |
| **PrizeHub Baytech** (legacy hardware) | HTTP `/tickets/*`, token `calcolaToken` | READ, GET, LIST premi | `analisi_tickets_handlers.md` § 1 |
| **App «ECL Service»** (Android B4A, operatori) | HTTP `/app/*` | lock/unlock card, rimborsi, OOO, reboot, swap BI, gestione PrizeHub | `api_app_tickets_handler.md`; istruzioni § 0 |
| **WinMT** (`frmEditPrizeHub`) | HTTP `/app/action/SVCPH*` e DB condiviso | carichi PrizeHub | § 2.1 |
| **Partner terzi** | HTTP `/partner/*` | lettura e prelievo di tickets | `api_partner.md` |
| **Gestione gru** | HTTP `/crane/*`; contatori via MQTT | LOAD, UNLOAD, WIN, ARTICLECREATE; WIN automatico da `EcsDati.In6/7/8` | `api_crane_handler.md` § 5-6 |
| Provisioning card «da rete interna» | HTTP `/api/*`, **senza autenticazione** | validate, detach, purge, create | `api_index.md` § 1 |
| **Server gemello** (Master/Slave/Primario) | HTTP `/redundance/*`; DB sincronizzati «ogni 60 secondi» | `setprimary` / `resetprimary` | `analisi/10-config-dbconfig.md`, riquadro sulla ridondanza |
| **Cloud Elmac** | **linked server SQL `elmaccloud`**: `CoinlessDB` (`CoinlessImpianti`, `vs_definizione_nome_macchina`, `sp_CoinlessMacchine`, `sp_ConfigurazioneMacchina`, `CoinlessDefaultTypeConfig`), DB d'impianto `DB<Nimp>`, DB di servizio (`ElmacRemSrvc`) | letture, e **scritture** (wizard «Crea nuovo modello» su `Type`, `Manuf`, `Machines`) | `installazione_nuova_macchina.md` § 0, § 6, § 7-bis |
| Cloud Elmac: sincronizzazione manuale | `replicaTabelleDalCloud` / `replicaTabelleSulCloud` | «dati comuni» (tabelle, immagini, lingue), sempre tutti insieme | `analisi/16-config-syncconfig.md` |
| Cloud Elmac: altro | avvisi «sul cloud» quando un payload è errato; riconciliazione multilocale dopo un riscatto | — | `boot_scheda_be.md` § 6.1; `api_prizehub.md` redeem |
| «Reportistica schedulata» | lancia `sp_generacache` ogni giorno | cache dei report | `storicizzazione_cache_dati_grafico_giornaliero.md`; **chi sia non è detto** |
| File system | `dbsetting(s).txt` (`ListenerPort`, `PartnerApiKey`, `PrizeHubThrottleSec`), pagine servite da `C:\ecs2mqtt\www` | configurazione | istruzioni § 1.1; `api_partner.md` § 1; specifica § 7.3; installazione, intestazione |
| «Sync Framework» | — | nominato come meccanismo che *non* tocca certe tabelle di dominio | `legacy_vb6_log_eventi_bonus_analysis.md` § 0 |

La documentazione **non** tratta l'eventuale servizio .NET citato in `docs/winmt/winmt-00-mappa.md`, la natura del broker (prodotto, autenticazione) né HQ.

### 2.3 (c) Strutture dati

**Tabelle e oggetti nuovi o ridefiniti dal motore:**

| Oggetto | Cosa dicono i documenti | Fonte | In db-08? |
|---|---|---|---|
| `PrizeHubSlots` | schema completo (id, hubId, slot, tipo, unit, codArticolo, qtaDisp, ticketsMedi, ticketsMediaForzata, attivo, updatedAt/By; UNIQUE su hub+unit+slot+articolo). Sostituisce `Premi.PDis1-8` / `QDis1-8`, ora deprecate | `specifica_flutter_prizehub.md` § 5.1; `guida_vb6_prizehub.md` § 1 | sì (da WinMT 07) |
| Premi «fittizi» SPINDLE in `Premi` | una riga per slot SPINDLE, riconoscibile **solo** da `Attivo=0 AND Prenotabile=0`: è un sovraccarico semantico. `N_Tickets` contiene la media dello slot, `Foto` l'ultimo articolo caricato | specifica § 2.1, § 11 punto 3; `api_prizehub.md`, modello dati | da aggiungere |
| Regola tipo-lettera dello slot | A = CAPSULE, B = SPINDLE, C = LOCKER; configurazione dell'hub in `setup2` (`IdPost 101`, chiave `PrizeHub0{n}`, JSON `containers[]`) | `guida_vb6_prizehub.md` § 1.2, § 6 | parziale |
| `GruMagazzino`, `GruMagazzinoDettaglio`, `GruMovimenti` (LOAD/WIN/UNLOAD/ADJUST), `CraneCounterSyncLog`, `vs_CraneStatus`, `sp_crane_*` | magazzino a 3 slot con media ponderata `AvgValue`. Le gru sono i `Tipo` 3, 9, 12, 17. `ValIn6/7/8` è **sovrascritto** a ogni sincronizzazione da `AvgValue` | `api_crane_handler.md` § 1, § 7; `gru_valore_medio_iniziale.md` | sì |
| `LogTransazioniTotem` | una riga per moneta o banconota, più il POS per i resoconti. **`AC` riusato per il `transactionUid`** («decisione esplicita»), anche sulle righe POS dove `AC` è il cryptogram EMV. Stati `Pending`/`Completed`/`Error` in `CAut`. Trigger attivo: si usa `OUTPUT INTO` | `api_index.md` § 3.7-3.8; log_eventi § 3 | sì |
| `LogTransazioniPos` | correlazione per `uidPOS`. **Colonne EMV usate con un altro significato**: `IDTerm` = merchantReceiptRetailer, `AId` = transactionId, `Appl` = merchantReceiptCard, `IC` = dtId, `Stan` sempre vuoto | `api_index.md` § 3.9.2 | sì; **significato diverso dai nomi** |
| `promozioni`, `promozioni_cards` | finestra `dalla_data`–`alla_data`; `scadenzaPromozione` serve solo al ripristino; flag legacy non usati; **nessuna UI** per crearle | `evento_gold.md` | sì |
| `RedeemCodes` e `sp_redeem_*` | codici `RD`+13 caratteri, PIN di 4 cifre, prenotazione di 5 minuti, azioni `new`/`recharge`. Il parametro `DbName` contiene in realtà `Nimp` | `api_index.md` § 3.11 | sì (solo nome) |
| `setup2`, chiavi nuove | `PrizeHub0{n}`, `ArmageddonEseguito`, `typename_<tipo>` (default di macchina per tipo), `card.createNewCard.maxCardsPerPurchase` / `minFiatAmountPerCard`, `flagDropTicketsForGold`, `BirthdayFreeCharge` (VB6) e i blocchi JSON della config del totem per idpost | `armageddon.md` § 4; installazione § 7-ter; rev009 M3; `evento_gold.md` | parziale |
| `cache_dati_grafico_giornaliero` + `sp_generacache` | una riga per macchina e giorno. Finestra automatica «ieri e oggi», poi il giorno si **storicizza**; il ricalcolo è possibile su richiesta. Il valore dei premi delle gru usa la media **del momento in cui la riga viene scritta** | `storicizzazione_…md`; `gestione_gru_e_valore_premi.md` | **no** |
| `fn_EcsDatiGiornalieri` / `fn_RicalcolaContatoriGiornalieri` | delta giornaliero = MAX − MIN di contatori **cumulativi** (`In1..In16`); esclude `In16`; somma la spesa a card con `WinMt=0` | `fn_ecsdatigiornalieri.md` | parziale |
| `ecl_SchedeFirmware` (detected/requested version), `ecl_firmware`, `ecl_Provisioning`, `ecl_DeviceProvisioning`, `CoinlessImages` (con `majorFirmware`), `BEConfig`, `EcsModuli` | telemetria e provisioning delle schede | `boot_scheda_be.md` § 9-10; `magiaticket_flow.md` § 4-6, § 10 | **no** |
| `CoinlessDati` → trigger `decodifica_record` → `EcsDati`, `TransCard`, blacklist | la scrittura delle giocate passa da un trigger SQL; livello card e costo partita **arrivano già calcolati dalla BE** (token 27) | `boot_scheda_be.md` § 5; `evento_gold.md`, prezzo della partita | in parte |
| `CoinlessDataBuffer` | buffer dei ticket della mangiatickets e del «ticketless online»; svuotato da `salvaTicketsBuffer` | `tabella_tickets_…md`; `evento_gold.md` | **no** |

**Colonne con significato precisato o nuovo** (confronto con `docs/db/db-08-dizionario-dati.md`):

| Colonna | Significato secondo i documenti | Rapporto con db-08 |
|---|---|---|
| `TransCard.WinMt` | 0 = giocata (scritta dal trigger, `NImp` NULL); 1 = movimento di cassa o operatore. Sul `.38`: 17.872 righe a 1, 1.974 a 0 | conferma (db-08 r. 31 e 59) |
| `TransCard.NImp` | 1 = carico da totem (nuovo, B4J); 6 = bonus; 0 = carico del cassiere; 18 = canone VIP (VB6, mai scritto dal B4J) | **integra** |
| `TransCard.T0` | nelle ricariche: codice impianto con 4 cifre (`Right("0000"&Nimp,4)`), non l'uid della card | integra |
| `TransCard.CodMac` | nella ricarica da totem = `kioskId` | integra (db-08: nome del PC) |
| `TransCard.IDOperazione` | chiave clustered GUID `newid()`: causa di frammentazione fino al 99% | non in db-08 |
| `TransCard.FlagOpDaVerificare` | giocata «da verificare»: la BE non ha confermato la scrittura RFID. Le ripresentazioni con lo stesso progressivo sostituiscono la riga; dopo 3 ripresentazioni la card va in blacklist | integra (`gestione_transazioni_da_verificare.md`) |
| `Clienti.N0` | contatore proprio del cliente, **non** il progressivo di `TransCard` | integra (cliente § 3.4) |
| `Clienti.TipoCard` | enum `PLATINUM=0, GOLD=1, SILVER=2, BIRTHDAY=3` (V `ecs2mqtt.b4j:233-273`) | da confrontare |
| `Clienti.Foto` | JSON con consensi, riemissione (`ReissueCardList`), VIP: **dato strutturato in un campo «Foto»** | integra |
| `EcsMacchine.T0` | JSON con i flag `BISwap` e `NoRec`: con flag attivo, `aggiornaDatiEcs` scarta i `send_client` | sovraccarico; non in db-08 |
| `EcsMacchine.F0` | 1 = macchina «in pending» di riprogrammazione | integra |
| `EcsMacchine.val_platinum/gold/silver/normal` | costo partita per livello, in centesimi; `normal` vale per BIRTHDAY; una Happy Hour attiva (`CoinlessMacchineHappyHour.perc_*`) ha la precedenza | integra |
| `EcsMacchine.CntrLet8/9` | tipo di erogatore: 1 = PULSE; 0/2/4/6 = NORMAL con combinazioni di motore e switch | integra |
| `EcsMacchine.CntrLet15` | ticket automatici per partita → `Tickets.MangiaT=8256` | conferma (db-08 r. 306) |
| `Tickets.MangiaT` | bitmap di 15 bit; **valori davvero scritti: 1, 4, 64, 8256**. L'etichetta «Punti da App» (bit 13) è usata per i ticket automatici di macchina. `scriviTicketsDaCoinless.sql` vi scrive un seriale fuori scala | integra db-08 § 2.3 |
| `Tickets.NonCont` | esclude lo scontrino dal saldo; filtro aggiunto il 2026-10-21 (prima veniva ignorato) | integra |
| `Tickets.TPagati` | valore negativo `= −IdPost` come sentinella (VB6 `ManualTicket`) | conferma |
| `Vincite.Cons`, `D0`, `N0` | il B4J scrive sempre `Cons=1` e `D0=getdate()` e non scrive mai `N0` (punti Gold). Il VB6 lo faceva: **regola diversa** fra i due programmi | integra |
| `Vincite25`, `TicketsCan` | non usate da nessun codice del repository B4J | da segnalare |
| flag `GamePark` (impostazioni) | **due significati**: «hardware Ethernet, sempre online, parchi» (DbConfig) e «senza borsellino bonus» (cliente § 3.1) | sovraccarico |
| `PrioritaBonus` | ordine di consumo dei due borsellini (bonus o crediti prima); si decide all'installazione e poi non si tocca | non in db-08 |

**Stato fuori dal DB che è di fatto un dato:** le liste in memoria delle macchine online, offline e in setup (`elencoMacchineOnlineConStato`, `elencoMacchineMqttSetup` da topic retained), la coda di riprogrammazione `devicemanager`, il throttle `PRIZEHUB_{hubId}` e lo stato globale `Main.macchina` (`boot_scheda_be.md` § 3; `macchine_insetup.md` § 2; specifica § 7.3); il file `dbsetting.txt`; il dump della card fisica (saldo, progressivo, `offline_points`, livello, `plant.owner/site/group`), che è la copia del saldo **sulla card** e per il totem ha valore di verità (`api_index.md` § 3.4).

---

## 3. Decisioni e piani in corso

| # | Cosa | Tipo | Fonte |
|---|---|---|---|
| 1 | PrizeHub: WinMT scrive tramite REST (Opzione A); le letture restano SQL | **decisione** (2026-07-10), applicata in WinMT | istruzioni § 0; winmt-07 |
| 2 | Due registri distinti, `LogTransazioniPos` (trasversale) e `LogTransazioniTotem` (per totem); un POS del totem scrive in entrambi | **decisione** | log_eventi § 3, § 9.1 |
| 3 | `transactionUid` scritto in `LogTransazioniTotem.AC` anche sulle righe POS | **decisione** dell'utente | api_index § 3.7 |
| 4 | Ricarica da totem: `NImp=1`, `N0` dal progressivo della card, idempotenza, contante tutto o niente, `T0` = Nimp con 4 cifre | **decisione**, implementata | api_index § 3.10, § 5 |
| 5 | M1, ripartizione su più card: due chiamate (`calc-bonus` + `distribuisci-importo`), tickets `ceil(tot/N)`, nuova `recharge-card-tickets`; chiamate in sequenza | **decisione** (2026-10-21); end-to-end non provata | rev009 M1; api_index § 3.10bis, § 3.12 |
| 6 | M2 `card-history` (tickets e premio sempre 0/null), M3 default 5 e 10, M5 `writeTicketsOnCard=false` fisso, M6 `detached` | **decisione**, implementata il 2026-10-15 (V § 5.3) | rev009 M2, M3, M5, M6 |
| 7 | Correzione dell'unità VIP; regola BIRTHDAY → SILVER; solo `FidelizzazioneSottoscrizione` resta manuale | **decisione** dell'utente | cliente § 3.5 |
| 8 | `level_name` SILVER = "SILVER" | **decisione** concordata col team del totem (2026-10-20) | cliente § 3.5 agg. 2 |
| 9 | Armageddon: solo da pagina superadmin, una sola volta per impianto; vecchi endpoint `/eclcommand` disabilitati | **decisione**, implementata | `armageddon.md` § 2-4 |
| 10 | Conferme JS sulle 10 azioni ad alto impatto del backoffice | **decisione**, commit `76f98d1` | worklog, ultima voce |
| 11 | TransCard: rimossi 12 indici ridondanti in produzione; `rimborsaPartitaACliente` resa sargable; `identificamiSuSetup(…, creaSeNonEsiste)` | **decisione**, applicata | `fix_timeout_rimborsi_transcard.md` |
| 12 | Gru: valore medio iniziale impostato all'installazione con `sp_crane_force_avg_value` | proposta il 2026-10-10, **implementata** (V § 5.3) | `gru_valore_medio_iniziale.md`; `gestione_gru…md` |
| 13 | Cambiare la chiave clustered di `TransCard` (oggi un GUID) | **orientamento** («da valutare») | fix_timeout, «Da fare» |
| 14 | Rebuild degli indici frammentati in finestra di manutenzione | **orientamento** / attività aperta | idem |
| 15 | Fallback `detectedVersion → requestedVersion` in `leggiTipoMacchina_Fw` | **orientamento** («proposto, non applicato») | `boot_scheda_be.md` § 10 |
| 16 | M4 `redeem-create` (codice di riscatto quando la card non esce) | **richiesta aperta** del totem; il motore oggi lo simula | rev009 M4 |
| 17 | `transactionUid` generato dal totem, obbligatorio ovunque, presente anche negli errori; rinomina `transactionId` → `posTransactionId` | **richiesta** del totem (gruppo I); non applicata: `start-transaction` genera ancora l'id lato server | rev009 § 9 |
| 18 | `cardUid` nella pending POS; stati ammessi nella `complete`; retry POS | **domande aperte** | rev009 § 2bis, F |
| 19 | `cambioLivello` nella risposta della `recharge-card` (gruppo J); riconoscimento da QR e recupero card (gruppo K, «flusso ancora da disegnare»); sala che non risponde a metà giro (gruppo L) | **domande aperte** | rev009 § 7 |
| 20 | Uniformare i nomi (kebab-case per i path, camelCase per le chiavi, involucro `statusCode`/`responseData`) | **richiesta** del totem; parzialmente fatta (`read-card`, V) | rev009 § 8 |
| 21 | Bug noti, non chiusi: ricarica di solo bonus → card «clonata»; `pos-transaction-*` in errore 500 il 15/09; `getscalettabonus` ignora il `kioskId` (V); errore 400 invece di 401 senza token | **problemi aperti** | rev009 § 4, G |
| 22 | Porting ancora da fare: `updateSubscription`/`PagaCanone`, `rimpiazzaLaMiaCard` (sostituzione card), `ClassEventi` + `recalcForBirthday`, CRUD compleanni, `Scassettamento` | **orientamento** («da portare se…») | cliente § 5; log_eventi § 9 |
| 23 | Limiti di prodotto accettati: nessuna UI per le promozioni né per la blacklist; il GOLD torna indietro solo quando la card passa al totem; criteri diversi per sospendere i ticket GOLD (da armonizzare) | **stato di fatto**, nessuna decisione | `evento_gold.md`, Punti da verificare; `gestione_transazioni…md` |
| 24 | Ordine delle operazioni all'incasso (compleanno → promozione → bonus → log) | **ipotesi** dichiarata («dedotto dalla forma delle classi») | log_eventi § 8 |
| 25 | Multi-locale nel riscatto PrizeHub (storno nel locale giusto); prelievo multiplo `qty>1` | **aperti** | specifica § 11, punti 2 e 6 |

---

## 4. Glossario

| Termine | Definizione secondo la documentazione | Fonte | Rispetto ad analisi-00 § 5 |
|---|---|---|---|
| **BE** | Scheda elettronica installata nella macchina; parla col server via MQTT, legge la card, ha un codice device `cliente z impianto z macchina` (es. `97z1z68`); `0z0z0` = scheda nuova non assegnata | `boot_scheda_be.md` intestazione; `macchine_insetup.md` § 2 | **Risolve** il «nome da verificare»: BE è il dispositivo lettore sul gioco |
| **BI** | Scheda **contatori interna** abbinata alla BE («una scheda BE con la relativa BI»); ha un proprio firmware; si sostituisce con lo «swap BI» | `boot_scheda_be.md` intestazione; `api_app_tickets_handler.md`, swap BI | Integra. **Contraddizione interna**: `manuale/chapters/ecl/00-panoramica.md` chiama BI «lettori, scrittori e visualizzatori di card», che invece sono i device RD e VS (`magiaticket_flow.md` § 1) |
| **Swap BI** | Procedura LIST → START → sostituzione fisica → WRITE (riscrive i contatori da `EcsDati`) → END; il flag `BISwap` blocca i `send_client` nel frattempo | `api_app_tickets_handler.md` | Nuovo |
| **ECL / ECS** | ECL = funzionamento con card RFID; ECS = «solo rilevamento dati» per impianti senza card (Application Mode) | `analisi/10-config-dbconfig.md` | Integra |
| **Tipi di scheda** | BE3/GAMES (131), MT/MANGIAT (123 e 133), RD/CASSATOT (132), VS/VISCREDTK (136), PHO/MOBILE (900), astoria (311) | `magiaticket_flow.md` § 1; boot § 6 | Nuovo |
| **MagiaTicket / MANGIAT / MT** | Firmware e scheda della mangiatickets, con due famiglie di versione 123 e 133 | `magiaticket_flow.md` | Integra «Mangia-ticket» |
| **MangiaT** | Bitmap della causale di uno scontrino in `Tickets` | `tabella_tickets_…md` | Nuovo (db-08 § 2.3) |
| **Armageddon / MiniArmageddon** | Azzeramento di tutti i contatori `In1..In16`, compattazione di `EcsDati`, `TransCard` cancellata a scelta, riprogrammazione in coda; una sola volta per impianto | `armageddon.md` | Nuovo |
| **Ticketless / Ticketless online** | Ticket accreditati alla card invece che stampati; «online»: bufferizzati sul server e poi consegnati | `macchine_insetup.md` § 6; DbConfig, Behavior | Coerente |
| **Special times / Happy Hour / Time Play** | Fasce con prezzi speciali (`CoinlessMacchineHappyHour`, vista `vs_CoinlessSpecialTimes`), configurate in WinMT; Time Play: modalità mai configurata del tutto, con hardware aggiuntivo | `evento_gold.md`; bozza 05 e 07; worklog | Nuovo |
| **PrizeHub** | Distributore self-service di premi: hub → unit (contenitore fisico 1/2) → slot (A, B, C); tipi CAPSULE, SPINDLE (mix di articoli con media ticket), LOCKER (1 pezzo); «magazzino virtuale» | `api_prizehub.md`; specifica | **Risolve** «Prize HUB: non documentato» |
| **Premio fittizio SPINDLE** | Riga di `Premi` `SPINDLE{hubId}_{unit}-{slot}` con `Attivo=0`, `Prenotabile=0` | `api_prizehub.md` | Nuovo |
| **Baytech** | Fornitore dell'hardware e dell'interfaccia PrizeHub originari (`/tickets`), sostituiti dalla UI Flutter | `specifica_flutter_prizehub.md` § 1 | Nuovo |
| **TransCard / NImp** | Registro dei movimenti di card; `NImp` è la causale (legenda VB6 0-20 citata ma non riportata); `WinMt` distingue cassa e giocata | `api_index.md` § 3.10; `fn_ecsdatigiornalieri.md` | Integra |
| **Livelli card** | PLATINUM, GOLD, SILVER, BIRTHDAY; NORMAL era il nome provvisorio di SILVER | `evento_gold.md`; cliente § 3.5 | Nuovo |
| **Gold / evento GOLD** | Promozione stagionale: le card **nuove** nascono GOLD; prezzo GOLD della macchina; ripristino alla scadenza | `evento_gold.md` | Nuovo. I punti Gold e Silver di `Tickets.D0` e `Vincite.N0` sono un'altra cosa |
| **VIP / Fidelizzazione*** | 4 modelli (DatiPersonali, Sottoscrizione, UtilizzoContinuativo, SogliaMinima) per la promozione a PLATINUM | cliente § 3.5 | Nuovo |
| **Compleanni / Ospiti / BIRTHDAY** | Evento con tariffario dedicato e card ospiti di livello BIRTHDAY | log_eventi § 4, § 7 | Nuovo |
| **Carta con saldo / GetCred sempre-online** | Due modalità: saldo scritto sulla card (`clsGestioneClienteSala`) o card solo come identificativo (`clsGestioneClienteOnline`) | `api_index.md` § 3.4 | Integra «Card: contiene saldi» |
| **Da verificare** | Giocata registrata ma con scrittura sulla card non confermata | `gestione_transazioni_da_verificare.md` | Nuovo |
| **Blacklist** | Card bloccata in tutta la sala, distribuita via MQTT (`ElmacECL/BlackList`); si sblocca solo tramite l'assistenza | idem; `ecl/02-card-clienti.md` | Nuovo |
| **Borsellino bonus / PrioritaBonus / GamePark** | Saldo diviso fra crediti e bonus; ordine di consumo; `GamePark` ha due significati | DbConfig; cliente § 3.1 | Integra «Bonus» |
| **TOK / DigitalCurrency / ecoin** | Valuta virtuale mostrata sulle BE; `RappCentValuta`, `RappCreditiCent` (su un impianto vale 0,01); «ecoin» = giocata a card (`In9` calcolato) | DbConfig; `api_index.md` § 3.5; bozza 07a | **Risponde** in parte a «Token: rapporto da chiarire» |
| **Scaletta bonus** | Soglie «soglia\|bonus» in `Setup.t10/t12` (`IdPost 101`), applicate in modo greedy | log_eventi § 6 | Nuovo |
| **Codice RD (redeem)** | QR di 15 caratteri con PIN, per creare o ricaricare una card | `api_index.md` § 3.11 | Nuovo |
| **transactionUid / uidPOS / PosHandler** | id della sequenza totem; id del POS; servizio POS di sala | rev009 § 9 | Nuovo |
| **Master / Slave / Primario** | Coppia di server ridondata; il servizio gira solo sul primario | DbConfig | Nuovo |
| **Test Mode** | Sessione di prova dei contatori con baseline; dopo 60 minuti va in timeout **senza** ripristinare i contatori | bozza 07b | Nuovo |
| **Multilocale** | Card valida su più sale; `IdLong` contro `IdContatto`; impostazione in `setup.t6` | cliente § 2, § 3.2 | Coerente con «Gruppo multi-locale» |
| **Globo** | Compare come `WinMtSqlDBGlobo`, «backup di produzione» con più di 2 milioni di righe in `TransCard` | `fix_timeout_rimborsi_transcard.md`, Metodo | **Ipotesi**: Globo è il nome di un cliente o di una sala, non un sistema da migrare. Da confermare |
| **Gru** | Macchine `Tipo` 3 (gru), 9 (instant redemption), 12 (dispenser), 17 (merchandise); 3 slot contati su `In6/In7/In8` | `api_crane_handler.md` § 1 | **Corregge**: «usa un campo ticket» → usa gli ingressi 6, 7 e 8 |

---

## 5. Affidabilità

### 5.1 Incongruenze fra documenti

1. **Codice del premio fittizio SPINDLE.** `SPINDLE{unit}-{slot}` in `specifica_flutter_prizehub.md` § 2.1 e § 7, `api_app_tickets_handler.md` (effetti di SVCPHLOADSLOT) e `guida_vb6_prizehub.md` § 1.3, § 4.1 e § 5. `SPINDLE{hubId}_{unit}-{slot}` in `api_prizehub.md`, `guida_vb6_prizehub.md` § 1.2 e § 8.3 e `tabella_vincite.md`. Il codice usa il secondo formato (V § 5.3, controllo 1). Di conseguenza il filtro `NOT LIKE 'SPINDLE[0-9]-%'` raccomandato a WinMT (`guida_vb6_prizehub.md` § 5) **non esclude** i codici reali.
2. **URL di login.** `GET /app/action/login/{pubKey}` in `istruzioni_vb6_prizehub_opzioneA.md` § 1.2 (che si dichiara «contratto verificato»), `api_app_tickets_handler.md`, `analisi_tickets_handlers.md` e `specifica_flutter_prizehub.md` § 7.1. `…/login/key/{key}` in `api_prizehub.md` e `api_index.md`. È corretto il secondo (V, controllo 2).
3. **`leggiClienteByEmail`.** `legacy_vb6_cliente_analysis.md` § 3.1 lo cita alla r. 7249; il § 4 dello stesso documento dice che «non esiste in nessun punto del progetto». Il metodo esiste, scritto con un'altra combinazione di maiuscole, e gli identificatori B4X non distinguono le maiuscole (V, controllo 3): il § 4 è sbagliato.
4. **Stato del porting in `legacy_vb6_log_eventi_bonus_analysis.md`.** La tabella § 0 dice `LogTransazioniPos` «PORTATO», ma i titoli § 2 e § 3 dicono «NON PORTATO». Il § 0 e il § 5 dicono che il ripristino promozionale manca, mentre `legacy_vb6_cliente_analysis.md`, aggiornamento 3 (2026-09-10), lo dà per portato. Lo stesso accade in `api_index.md`: il § 3.3 dice «non ancora implementato», il § 3.4 lo descrive implementato.
5. **Valore medio iniziale delle gru.** Per `gru_valore_medio_iniziale.md` è una «proposta, non il comportamento attuale»; per `gestione_gru_e_valore_premi.md` e `ecl/04-contatori.md` «è stata introdotta». Il codice dà ragione ai secondi (V, controllo 5).
6. **Token per handler.** `api_index.md` § 1-2 dice che `/partner` usa `calcolaTokenApp` e non nomina `/crane` fra gli utenti di `calcolaToken`. Nel codice `/partner` usa una funzione propria e `/crane` usa `calcolaToken` come `/tickets` (V, controllo 6). Inoltre `api_crane_handler.md` § 2 dice che le GET di `/crane` non richiedono auth, mentre `api_index.md` dà «Bearer» per tutto `/crane`.
7. **`api_index.md` non è completo**, nonostante la regola «da tenere aggiornato» in testa: manca `card-history` (esiste, V); il § 3.2 documenta `readcard` mentre il codice accetta `read-card` (V); manca l'handler `/manuale/*` (V `ecs2mqtt.b4j:489`).
8. **`ECL_KIOSK_API_MANCANTI_rev009.md`.** La tabella § 1 dà M2 ancora mancante, il § 3 lo dà «RISOLTO 2026-10-15». La data di testa (2026-10-14) è precedente alle note che contiene (fino al 2026-10-21). La domanda D.5 («un `kioskId` sconosciuto crea una postazione») è superata dal fix di settembre (V, controllo 8): le catture risalgono al 15/09.
9. **BI** (§ 4): il manuale divulgativo `ecl/00-panoramica.md` contraddice i documenti tecnici.
10. **`GamePark`**: due significati (§ 2.3).
11. **`evento_gold.md`** attribuisce la creazione della card a `redeem-check`; secondo `api_index.md` § 3.11 la card la crea `redeem-confirm`. Differenza minore.
12. **Numeri di riga spostati.** `boot_scheda_be.md` colloca le sottoscrizioni a `ecs2mqtt.b4j:694-727` e quelle di setup a `:754-755`; oggi sono a `754-786` e `815-816` (V). La sincronizzazione delle gru è citata a `:1590-1603` in un documento e a `:1679-1692` in un altro. Le citazioni `file:riga` dei documenti vanno quindi trattate come indicative.
13. **Manuale**: gli `.odt` del 2026-09-03 non contengono i capitoli aggiunti dopo (ecl/, Guida ingressi, Test Mode, Armageddon). `final-report` dichiara 9 file di metadata su 9, ma ne sono presenti 7.
14. **Riferimenti mancanti**: `CLAUDE.md` e `LAVORO_IN_CORSO.md` del progetto B4J, `migrate_prizehubslots.sql`, `tools/db-diagnostics/`, la cartella `creazione archivi winmt/…` e i documenti del totem non sono nel nostro repository (D).

**Sicurezza.** Chiavi API in chiaro nei documenti: credenziale in `istruzioni_vb6_prizehub_opzioneA.md:51`, `:53` e `:161`, in `api_prizehub.md:29`, `:36` e `:37`, e in `api_crane_handler.md:142`, presentata come «esempio» ma con l'aspetto di una chiave reale. Sono anche cablate nel VB6 di esempio. Da non copiare nei nostri documenti; va valutata la rotazione.

### 5.2 Punti che i documenti dichiarano non verificati

- `installazione_nuova_macchina.md`: «IMPLEMENTATO … NON COMPILATO»; RPC sul linked server e scrittura sul cloud «da verificare a collaudo».
- `ECL_KIOSK_API_MANCANTI_rev009.md` § 4: ciclo POS, ricarica di solo bonus e riscatto «mai visti funzionare»; M1 non provata end-to-end.
- `api_index.md` § 3.4: il contratto di `sync-card` è «PROVVISORIO, non confermato con il team firmware del totem»; `card_type: "NOP"` è un refuso noto.
- `legacy_vb6_log_eventi_bonus_analysis.md` § 8: l'orchestrazione all'incasso è dedotta, perché il form del cassiere non è stato letto. § 1: `DBwinmt.AddAuditLog` «non letto in questa sessione».
- `legacy_vb6_cliente_analysis.md` § 3.4: l'uso di `cliente.N0` in `CanPlay` è «da verificare separatamente».
- `fn_ecsdatigiornalieri.md`: significato di `NImp` per le righe `WinMt=1` «non riverificato»; esclusione di `In16` non commentata.
- `tabella_tickets_…md`: `scriviTicketsDaCoinless.sql` (overflow di `MangiaT`) e bit mai scritti, forse ancora in uso nel VB6.
- `boot_scheda_be.md` § 10: fix proposto, non applicato.
- `metadata/staging-verification.md` § 6: tabella «Setup ready», «Time play», operazioni ad alto impatto e modali non verificati in staging.
- `evento_gold.md`: criteri diversi per la sospensione dei ticket, «non documentati come intenzionali».
- Tutte le verifiche sui dati sono fatte sul `.38` (circa 20.000 righe in `TransCard`) o su un backup di produzione; CLAUDE.md impone di riverificare in produzione.

### 5.3 Controlli puntuali sul codice

| # | Affermazione controllata | Esito | Evidenza |
|---|---|---|---|
| 1 | Formato del premio fittizio SPINDLE | **V**: è `SPINDLE{hubId}_{unit}-{slot}`; la specifica v1.4 è superata | `DBwinmt.bas:14088`, `:14537`; `FlutterTicketsHandler.bas:275` |
| 2 | Path del login `/app` | **V**: `/app/action/login/key/{key}` (5 segmenti, `Child_Id=4`); le istruzioni a WinMT sono sbagliate | `AppTicketsHandler.bas:133-140`; `ecs2mqtt.b4j:465-469` |
| 3 | Esistenza di `leggiClienteByEmail` | **V**: esiste (`leggiClienteByEMail`) | `DBwinmt.bas:7492`; chiamata in `clsGestioneClienteOnline.bas:29` |
| 4 | `card-history` (M2) e nome `read-card` | **V**: entrambi presenti, nessuno dei due documentato in `api_index` | `FlutterKioskHandler.bas:160`, `:198`, `:348`; `DBwinmt.bas:5462` |
| 5 | Valore medio iniziale delle gru all'installazione | **V**: implementato | `InstallazioneNuovaMacchina.bas:688`; `DBCrane.bas:460-496` (`EXEC sp_crane_force_avg_value`) |
| 6 | Funzioni di token per handler | **V**: `/partner` usa `calcolaTokenPartner`, `/crane` e `/tickets` usano `calcolaToken`, `/hub` e `/kiosk` usano `calcolaTokenApp` | `PartnerHandler.bas:134`; `CraneHandler.bas:139`; `TicketsHandler.bas:127`; `sicurezza.bas:42-70` |
| 7 | `/api` senza verifica del token | **V**: nessuna chiamata a `RichiedeAutenticazione` in `APIHandler.bas`, né in `RedundaceHandler.bas` | ricerca su `APIHandler.bas`, `RedundaceHandler.bas` |
| 8 | `identificamiSuSetup(…, creaSeNonEsiste)` | **V**: `True` solo in `WINMtConfig`, `False` nei percorsi del totem | `DBwinmt.bas:6766`; `WINMtConfig.bas:293`; `FlutterKioskHandler.bas:844`; `kioskConfig.bas:74` |
| 9 | Topic MQTT e uscita verso l'hub | **V**: sottoscrizioni presenti (oltre a quelle del documento di boot: `ElmacECL/Refounds/+`, `ElmacAPI/+`, `ElmacECLEvents/+/+`, `ECLservice/+/+`, `VS/+`, `comdevice/+/stream`…); `HUB/{id}/eject` pubblicato | `ecs2mqtt.b4j:754-816`; `FlutterTicketsHandler.bas:351` |
| 10 | Enum dei livelli card | **V**: BIRTHDAY=3, SILVER=2, GOLD=1 (PLATINUM=0 secondo il documento) | `ecs2mqtt.b4j:233-273` |
| 11 | `getscalettabonus` ignora il `kioskId` | **V**: `BuildBonusScaleJson()` non ha parametri | `eclservice.bas:101-102`; `scalettaBonus.bas:27` |
| 12 | M3, M5 e M6 implementati | **V** | `kioskConfig.bas:211-235`; `FlutterKioskHandler.bas:260-278` |
| 13 | Versione del motore | **V**: 2.39.55; `DBCloud.bas` è vuoto (la documentazione non lo cita) | `ecs2mqtt.b4j:133` |

Giudizio complessivo (D): i documenti **tecnici di flusso** (boot, magiaticket, armageddon, transazioni da verificare, `tabella_*`, fix timeout) sono accurati nella logica e citano il codice. I documenti **di contratto API** hanno derive puntuali (path, nomi, endpoint mancanti), e conviene fidarsi di quello aggiornato più di recente insieme al codice. I documenti **VB6** sono affidabili come inventario delle regole, ma lo stato del porting va letto negli «Aggiornamento» più recenti, non nelle tabelle di testa. Il **manuale divulgativo** semplifica e in un punto sbaglia (BI).

---

## 6. Domande aperte

1. **Strategia di separazione con WinMT.** Il porting di regole VB6 nel B4J (anti-clonazione, VIP, promozioni, ricarica, riscatto) è pensato per sostituire la cassa WinMT nel tempo, o solo per servire il totem? Le regole divergenti (unità VIP, «card non aggiornata» non più clonata, BIRTHDAY → SILVER, `Vincite.Cons/D0/N0`) valgono anche per la cassa?
2. Chi scrive `EcsMacchine.F0` (pending di riprogrammazione), e WinMT sa interpretare i flag JSON in `EcsMacchine.T0` (`BISwap`, `NoRec`)?
3. Chi lancia `sp_generacache` («reportistica schedulata»): SQL Agent, WinMT, HQ o il servizio .NET?
4. Il **cloud Elmac** raggiunto con il linked server `elmaccloud` (`CoinlessDB`, `DB<Nimp>`, DB di servizio) è lo stesso «cloud» di HQ? Quali tabelle muovono `replicaTabelleDalCloud` e `replicaTabelleSulCloud`? Che cosa resta della sincronizzazione Master/Slave «ogni 60 secondi», e con quale strumento (Sync Framework?)?
5. **Globo**: `WinMtSqlDBGlobo` è il DB di un cliente? Allora «Globo» nel glossario di analisi-00 non è un sistema precedente.
6. `GamePark`: quale dei due significati è quello vero, o servono due flag distinti?
7. Il modello «premio fittizio in `Premi` riconosciuto da `Attivo=0 AND Prenotabile=0`» e il riuso delle colonne EMV di `LogTransazioniPos` e `LogTransazioniTotem.AC`: nel nuovo modello dati vanno sostituiti da entità e colonne dedicate (orientamento consigliato)?
8. Le richieste del team del totem (id di transazione generato dal totem, M4 `redeem-create`, stati del POS, gruppi J, K e L, convenzioni dei nomi) vanno chiuse nel motore attuale o passano direttamente nel progetto nuovo (Laravel)?
9. Le chiavi API in chiaro nei documenti e nel VB6 sono quelle di produzione? Vanno ruotate?
10. `/api/*` e `/redundance/*` senza verifica del token, e `/eclservices/*` senza auth: sono accettati perché c'è isolamento di rete? Vale anche per il cloud?
11. Il manuale (bozze e `.odt`) va considerato fonte per i casi d'uso del backoffice di sala, o solo per la formazione? Gli `.odt` sono da rigenerare?
12. Il B4J ha un proprio `CLAUDE.md` e un `LAVORO_IN_CORSO.md` che i documenti citano spesso: possiamo averli? Contengono decisioni e lavori in corso che qui non vediamo.
