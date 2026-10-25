# Galileo HQ — ecl2mqtt 05: API REST per totem, PrizeHub, app, partner, gru e ticket

**Stato:** bozza · **Responsabile:** Piero · **Aggiornato:** 2026-10-25

**Collegati:** [`ecl2mqtt-00-mappa.md`](ecl2mqtt-00-mappa.md) (mappa e sintesi trasversale). Nel testo, «zona NN» indica il documento ecl2mqtt NN.

Sorgente: `legacy/ecl2mqtt/` (B4J 2.39.55). Tutti i riferimenti `file:riga` sono relativi a quella cartella, salvo `docs/...` (relativi alla radice del repository). **V** = verificato nel codice, **D** = dedotto. Nessun segreto è riportato: dove il codice contiene chiavi o password è scritto "credenziale nel codice (file:riga)".

---

## 1. Moduli coperti

| Modulo | Righe | Ruolo |
|---|---:|---|
| `FlutterKioskHandler.bas` | 1.598 | `/kiosk/*`: API del **nuovo totem Flutter** (card, bonus, ricarica, log pagamenti, redeem QR, storico). |
| `FlutterTicketsHandler.bas` | 437 | `/hub/*`: API dell'app Flutter **PrizeHub** (lettura card, premi per hub, riscatto con espulsione via MQTT). |
| `AppTicketsHandler.bas` | 345 | `/app/*`: router verso tre sotto-handler per gruppo di azioni; login e immagini. |
| `AppPlayerHandler.bas` | 338 | `/app` gruppo PLAYER: lettura card, lista premi, prelievo premio, blocco/sblocco card. |
| `AppServiceHandler.bas` | 758 | `/app` gruppo SERVICE: app di servizio dell'operatore (stato sala, macchine, rimborsi, fuori servizio, reboot, swap scheda BI). |
| `AppPrizeHubHandler.bas` | 333 | `/app` gruppo PRIZEHUB: gestione slot del PrizeHub (carico, sostituzione, ticket medi, immagini). Usato anche da WinMT. |
| `APIHandler.bas` | 345 | `/api/*`: provisioning card (validate/detach/purge/create-user); i metodi sono riusati da `/kiosk`. |
| `PartnerHandler.bas` | 361 | `/partner/*`: integrazione terze parti (saldo e scarico ticket). |
| `TicketsHandler.bas` | 455 | `/tickets/*`: integrazione legacy Baytech (distributore premi "dis1"). |
| `CraneHandler.bas` | 498 | `/crane/*`: giacenze delle gru (carico, scarico, vincita, nuovo articolo) su `DBCrane`. |
| `clsElmacAPI.bas` | 1.396 | API cliente invocate **dal cloud via MQTT** (`ElmacAPI/<metodo>`): login app, profilo, password, crediti, punti, livello. Non fa chiamate HTTP in uscita. |
| `cliente.bas` | 972 | Classe dati del cliente: deserializzazione, attributi JSON in `Clienti.Foto`, anti-clonazione, regole VIP, ripristino livelli. |
| `clsGestioneCliente.bas` | 223 | Terza copia della gestione cliente; **non istanziata da nessuno** (codice morto) [V grep]. |
| `clsGestioneClienteOnline.bas` | 285 | Cliente nella modalità **"GetCred sempre online"** (saldo autoritativo nel DB); usato da `clsElmacAPI` e dal flusso MQTT di gioco. |
| `clsGestioneClienteSala.bas` | 329 | Cliente nella modalità **"carta con saldo"** (saldo anche sulla card, va riconciliato); usato da `/kiosk` e `/api`. |
| `clsGestioneMacchine.bas` | 13 | Classe vuota. |
| `clsCompleanni.bas` | 111 | Limiti di gioco delle card ospite di un compleanno (partite totali/consecutive); chiamata dal flusso MQTT di gioco (altra zona). |
| `premio.bas` | 78 | Classe dati del premio. |
| `scalettaBonus.bas` | 448 | Bonus da scaletta `Setup(101).T10/T12` (anteprima, calcolo per importo) e `DistribuisciImporto` (family card). |
| `ECL_BonusHandler.bas` | 198 | Porting del calcolo greedy a scaglioni di `ECL_BonusHandler.cls` VB6. |
| `GestioneEtickets.bas` | 155 | Riversamento e-ticket da `CoinlessDataBuffer`; **nessun chiamante** (codice morto) [V grep]. |
| `kioskConfig.bas` | 320 | Configurazione unificata del totem (WINMtConfig + setup2) servita da `/eclservices/getkioskconfig`. |
| `PlayerScore.bas` | 27 | WebSocket `/ws/playerscore` (pagina punteggi giocatore). |
| `redirectuserinfo.bas` | 20 | `/playerscore` → redirect a `/player_score.html`. |
| `serviceHandler.bas` | 103 | Topic MQTT `ECLservice/+/+`: **stub** che fa solo log [V `serviceHandler.bas:13-41`]. |
| `MacchineHandler.bas` | 10 | Modulo vuoto. |

Routing HTTP: `ecs2mqtt.b4j:525-534` (`/tickets`, `/crane`, `/app`, `/hub`, `/kiosk`, `/partner`, `/api`), `:519-520` (`/playerscore`, `/ws/playerscore`). Porta da `settings.ListenerPort` più SSL [V `ecs2mqtt.b4j:475-480`]. Ogni handler `AddHandler(..., False)`: nuova istanza per richiesta [D, semantica jServer].

---

## 2. Flussi

Pesi secondo `docs/analisi/analisi-01-catalogo-flussi-winmt.md` § 1 (S semplice, M più tabelle o regole, L complesso/transazionale/varianti).

| Id | Flusso | Descrizione | Trigger/attore | Peso | Tabelle (R/W/D) | Evidenza | WinMT | Rapporto |
|---|---|---|---|:-:|---|---|---|---|
| E05-01 | Login API key → token | Scambia una chiave statica con un token HMAC valido 24 h; `/kiosk`, `/hub`, `/app` restituiscono anche i parametri coinless. | totem, PrizeHub, app, WinMT, Baytech, gru, partner | S | — | `sicurezza.bas:42-92`; `FlutterKioskHandler.bas:124-135` | — | solo B4J |
| E05-02 | Lettura card totem (`read-card`) | Risolve `CD…`/`JV…` o UID a 16 caratteri e restituisce il cliente completo (`cliente.ToMap`). Rifiuta i codici `RD`. | totem | S | R `Clienti`, `TransCard` | `FlutterKioskHandler.bas:221-253`; `DBwinmt.bas:7157-7480` | W04-04 (lettura) | complementare |
| E05-03 | Validazione UID card (`validate-card`) | Verifica che l'UID sia in `UID_ammessi` e ne dà il codbar; su `/kiosk` aggiunge `detached` (card libera). | totem; `/api` | S | R `UID_ammessi`, `Operatori`, `Clienti` | `APIHandler.bas:172-206`; `DBcoinless.bas:4913-4945` | W02-11 | doppione (WinMT può anche auto-ammettere, B4J no) |
| E05-04 | Stacco card (`detach-card`) | Accoda l'UID in `ReissueCardList` (attributi in `Clienti.Foto`), esegue `sp_ripristinacard` e ripubblica la blacklist. | totem; `/api` | M | W `Clienti.Foto`; via SP: `Clienti.T0/CodBar`, dati coinless, legami promo/compleanno | `APIHandler.bas:244-255`; `clsGestioneClienteSala.bas:213-217`; `DBcoinless.bas:4947-4977`; `DBwinmt.bas:1881-1893` | W03-11 (standard) | doppione |
| E05-05 | Eliminazione cliente (`purge-card`) | `sp_eliminacliente`: cancellazione fisica del cliente e di tutta la storia. | totem; `/api` | M | D `Clienti`, `TransCard`, `Tickets`, `Vincite`, `Prenotaz`, `Resi`, `Figli` (via SP) | `APIHandler.bas:265-270`; `DBcoinless.bas:4978-5008` | W03-11 (elimina utente) | doppione (WinMT la protegge con codice di autorizzazione; B4J no) |
| E05-06 | Creazione cliente anonimo (`create-user`) | Codbar da `UID_ammessi`; livello da `ImpostaLivelloPromozione` (Gold se promozione attiva); insert con `UPDLOCK,HOLDLOCK` e 3 tentativi; opzionali promozione, crediti/bonus, ticket. | totem; `/api` | M | R `UID_ammessi`, `promozioni`; W `Clienti` (I), `promozioni_cards` (I), `TransCard` (I), `Clienti.Credito`, `Tickets` (I), `Clienti.Tickets` | `APIHandler.bas:287-346`; `DBwinmt.bas:11203-11213`, `11860-11925`; `DBcoinless.bas:3565-3666` | W03-07, W03-08, W02-09 | doppione (§ 5.2) |
| E05-07 | Sincronizzazione card totem (`sync-card`) | Rifiuta card di altro impianto; confronto anti-clonazione progressivo/saldo; accredito punti offline; ripristino livello di promozione o compleanno scaduti; promozione VIP automatica; restituisce i dati da riscrivere sulla card. | totem | L | R `Clienti`, `TransCard`, `promozioni_cards`, `promozioni`, `Ospiti`, `Compleanni`; W `Clienti.TipoCard`, `Tickets` (I), `Clienti.Tickets`; D `promozioni_cards` | `FlutterKioskHandler.bas:394-607`; `cliente.bas:793-972` | W04-04, W01-14, W03-18, W03-23, W04-23 | doppione (§ 5.3–5.5) |
| E05-08 | Calcolo bonus per importo (`calc-bonus`) | Bonus crediti e ticket dalla scaletta `T10`/`T12`, algoritmo greedy. Nessuna scrittura. | totem | S | R `Setup(101).T10,T12` | `FlutterKioskHandler.bas:649-668`; `scalettaBonus.bas:138-196`; `ECL_BonusHandler.bas` | W02-18 | doppione (§ 5.1) |
| E05-09 | Ripartizione su più card (`distribuisci-importo`) | Porting di `DistribuisciImporto` (Equa, Bilanciato, BonusTotale) e ripartizione dei ticket per eccesso. Nessuna scrittura. | totem | M | — | `FlutterKioskHandler.bas:684-742`; `scalettaBonus.bas:331-448` | W03-24 | doppione con regola cambiata (§ 5.6) |
| E05-10 | Log pagamenti totem (`start-`, `log-`, `close-transaction`) | UUID di sequenza; una riga `LogTransazioniTotem` per moneta, banconota o tentativo POS (`AC` = UUID, `CAut` = Pending o esito POS); chiusura a Completed/Error. | totem | M | R `Setup` (mname); W `LogTransazioniTotem` (I/U) | `FlutterKioskHandler.bas:758-908`; `DBwinmt.bas:13252-13347`, `6766-6833` | W04-06 | complementare (B4J scrive, WinMT recupera i Pending) |
| E05-11 | Ciclo POS (`pos-transaction-pending/result/progressivo/complete`) | Porting di `LogTransazioniPos.cls`: Pending → dati transazione → progressivo card → stato finale con `DataAck`. | totem | M | W `LogTransazioniPos` (I/U) | `FlutterKioskHandler.bas:919-1087`; `DBwinmt.bas:13366-13557` | W04-20, W04-05 | doppione (stessa macchina a stati) + complementare (recupero in WinMT) |
| E05-12 | Ricarica card totem (`recharge-card`, `recharge-card-tickets`) | Registra in `TransCard` la ricarica già scritta sulla card: bonus `NImp 6` a N0−1, crediti `NImp 1` a N0, `Clienti.Credito` assoluto, in transazione e idempotente; poi ticket bonus da `T12` (o espliciti). | totem | L | R `Operatori`, `transcard`; W `TransCard` (I), `Clienti.Credito`, `Tickets` (I), `Clienti.Tickets` | `FlutterKioskHandler.bas:1100-1289`; `DBcoinless.bas:3713-3847`; `DBwinmt.bas:3082-3159` | W05-02, W01-12, W03-24 (passo 4) | doppione (porting di `AddTransCard`, § 5.1) |
| E05-13 | Riscatto codice QR (`redeem-check`, `redeem-confirm`) | Prenotazione 5 min, PIN, poi `new` (nuovo cliente, livello, crediti, ticket, ospite di compleanno) o `recharge` (cliente loggato); conferma o annullo del codice. | totem | L | R/W `RedeemCodes` (via `sp_redeem_*`); W `Clienti` (I), `Ospiti` (I), `promozioni_cards`, `TransCard` (I), `Clienti.Credito`, `Tickets` (I) | `FlutterKioskHandler.bas:1303-1507`; `DBwinmt.bas:12084-12372` | W04-19, W01-24 | doppione (B4J implementa anche `recharge`, vuoto in WinMT) |
| E05-14 | Storico movimenti card (`card-history`) | Ultimi N (1–100) movimenti `TransCard` del cliente, da UID o codbar. | totem | S | R `UID_ammessi`, `TransCard` | `FlutterKioskHandler.bas:348-364`; `DBwinmt.bas:5462-5530` | W04-07 | doppione (consultazione) |
| E05-15 | Provisioning card `/api/*` | Le stesse azioni di E05-03…06 su `/api/validate-card` ecc., **senza autenticazione**. | sconosciuto (rete interna) | M | come E05-03…06 | `APIHandler.bas:59-159` | W03-07, W03-11 | doppione |
| E05-16 | PrizeHub: login, configurazione, immagini | Token; configurazione hub da `setup2` (`PrizeHub0<n>`); immagine articolo da `Premi`. | PrizeHub Flutter | S | R `setup2`, `Premi` | `FlutterTicketsHandler.bas:113-133`, `323-335` | W07-10 | complementare |
| E05-17 | PrizeHub: lettura card | Antiflood per hub (finestra consumata solo su lettura valida); rifiuta card disabilitate; ticket ricalcolati, più altri locali se multi-sala. | PrizeHub Flutter | M | R `Clienti`, `Tickets`; R altri DB di sala (`<db>.dbo.Tickets` sul linked server) | `FlutterTicketsHandler.bas:184-222`, `371-384`; `DBwinmt.bas:8319-8403` | W01-02, W02-16 | complementare |
| E05-18 | PrizeHub: premi disponibili | Premi dell'hub acquistabili con i ticket del cliente. | PrizeHub Flutter | S | R `Premi`, `PrizeHubSlots`, `gruppi` | `FlutterTicketsHandler.bas:224-241`; `DBwinmt.bas:14504-14620` | W07-10 | solo B4J |
| E05-19 | PrizeHub: riscatto premio | Controllo saldo; CAPSULE/LOCKER (`prelevaPremioDaHub`) o SPINDLE: decremento slot, consumo ticket FIFO, saldo, vincita in **una** transazione; poi MQTT `HUB/<id>/eject`; riconciliazione multi-sala best-effort. | PrizeHub Flutter | L | W `PrizeHubSlots`, `Tickets`, `Clienti.Tickets`, `Vincite` (I); cloud `sp_last_trans`, `sp_preleva_punti` | `FlutterTicketsHandler.bas:243-321`, `341-355`; `DBwinmt.bas:14703-15021` | W01-06 | doppione (§ 5.7) |
| E05-20 | App: lettura card (`READCARD`/`READCODBAR`) | Cliente e ticket (multi-sala). Non controlla `Abilita`. | app (player/servizio) | S | R `Clienti`, `Tickets` | `AppPlayerHandler.bas:47-92` | W01-02 | complementare |
| E05-21 | App: lista premi (`LIST`) | Premi acquistabili; tutti o solo quelli con giacenza secondo `VisP0`. | app | S | R `Premi` | `AppPlayerHandler.bas:99-144`; `DBwinmt.bas:8915-9072` | W01-05 | complementare |
| E05-22 | App: prelievo premio o soli punti (`GET`) | `prelevaPremio`/`prelevaSoloPunti`: consumo FIFO, saldo, vincita, giacenza; connessioni separate, nessuna transazione. | app | L | W `Tickets`, `Clienti.Tickets`, `Vincite` (I), `Premi.Quantita`; cloud `sp_last_trans`, `sp_preleva_punti` | `AppPlayerHandler.bas:151-216`; `DBwinmt.bas:7926-8262`, `8524-8637` | W01-06, W01-25 | doppione (§ 5.7) |
| E05-23 | App: blocco e sblocco card (`LOCKCARD`/`UNLOCKCARD`) | `Clienti.Abilita` = 0/1 per `T0`. | app | S | W `Clienti.Abilita` | `AppPlayerHandler.bas:217-279`; `DBwinmt.bas:5532-5561` | W02-23 | doppione (colonna con più significati, § 4e) |
| E05-24 | App servizio: operatore | Operatore da card (`SVCOPERATOR`); attività dell'operatore (`SVCCHKOP`). | app di servizio | S | R `Operatori`, `TransCard`, `ecsmacchine`, `tickets` | `AppServiceHandler.bas:94-118`, `434-455`; `DBwinmt.bas:4315-4383`, `8007-8089` | W02-05 | complementare |
| E05-25 | App servizio: stato sala, elenchi macchine, setup | Conteggi e liste (online, fuori servizio, happy hour, attive); `Setup(101)`. | app di servizio | S | R `EcsMacchine`, `vs_CoinlessSpecialTimes`, `setup` | `AppServiceHandler.bas:119-137`, `207-223`; `DBwinmt.bas:9719-10041`, `13145-13202` | W08 (consultazione) | complementare |
| E05-26 | App servizio: dettaglio e movimenti card | Cliente completo (`ToJson`, con password e token); movimenti, tutti o dall'ultima operazione. | app di servizio | S | R `Clienti`, `TransCard` | `AppServiceHandler.bas:139-206`; `DBwinmt.bas:5252-5342`, `11578-11619` | W04-07, W03-28 | doppione |
| E05-27 | App servizio: rimborso ticket (`SVCREFUNDTCK`) | Scontrino di ticket (1–999) per macchina e operatore indicati dal client; ricalcolo `Clienti.Tickets`. | app di servizio | M | W `Tickets` (I), `Clienti.Tickets` | `AppServiceHandler.bas:224-288`; `DBwinmt.bas:8707-8766`, `8286-8317` | W05-09 | doppione (D) |
| E05-28 | App servizio: rimborso crediti (`SVCREFUNDTRAN`) | Limite rimborsi per operatore in 12 h (`Operatori.Foto`); riga `TransCard` `NImp 8`, `CodMac 'ECL-SERVICE'`, con **saldo e progressivo inviati dall'app**. | app di servizio | M | R `Operatori`, `TransCard`; W `TransCard` (I) | `AppServiceHandler.bas:289-339`, `729-758`; `DBwinmt.bas:4433-4479`, `15503-15530` | W03-25 (rimborso) | doppione (D) |
| E05-29 | App servizio: fuori servizio, happy hour, reboot | Fuori servizio/in servizio (MQTT `Service/<mac>` + `AuditLog`); riallinea happy hour; reboot via `ElmacECL/<device>` o `SetUp/<mac>`. | app di servizio | M | R `EcsMacchine`, `EcsModuli`, `vs_CoinlessSpecialTimes`; W `AuditLog` (I), stato happy hour | `AppServiceHandler.bas:341-433`; `ecs2mqtt.b4j:4618-4640` | W04-17 | complementare |
| E05-30 | App servizio: sostituzione scheda BI (`SVCBISWAP*`) | Flag `BISwap` e passi 1–4; messa in setup; riprogrammazione completa (`programmaDevice`); uscita dal setup. La lista fa da polling di avanzamento. | app di servizio | L | R/W `EcsMacchine.BISwap`, `BISwapStep`; W `AuditLog`; MQTT setup | `AppServiceHandler.bas:508-694`; `DBwinmt.bas:10518-10592`, `10854-10901` | — | solo B4J (doppione interno con il pannello web) |
| E05-31 | App servizio: transazioni rimborsabili | `SVCAVAILABLEREFUNDTRAN`: implementazione vuota e **non registrata** tra le azioni ammesse, risponde 405. | — | S | — | `AppServiceHandler.bas:71`, `457-495`; `AppTicketsHandler.bas:268-288` | — | morto |
| E05-32 | Gestione PrizeHub: consultazione | Elenco hub (GET senza auth), slot vecchio modello (`Premi.PDis/QDis`) e nuovo (`PrizeHubSlots`), dettaglio premio, setup hub. | app operatore; WinMT `frmEditPrizeHub` (in prospettiva) | S | R `setup2`, `Premi`, `PrizeHubSlots` | `AppTicketsHandler.bas:183-189`; `AppPrizeHubHandler.bas:44-58`, `149-178`, `296-311` | W07-10 | complementare |
| E05-33 | Gestione PrizeHub: carico slot (`SVCPHLOADSLOT`) | Carico fisico di LOCKER/CAPSULE/SPINDLE in transazione: slot e giacenza. | WinMT `frmEditPrizeHub`; app operatore | L | W `PrizeHubSlots` (I/U/D), `Premi` (U) | `AppPrizeHubHandler.bas:205-231`; `DBwinmt.bas:15026-15204` | W07-08 | complementare (WinMT client sottile, logica qui) |
| E05-34 | Gestione PrizeHub: sostituzione premio e magazzino virtuale | `SVCPHREPLACEPRIZE`, `SVCPHMOVETOWHAREHOUSE`: rimozione/sostituzione nello slot, movimenti verso il magazzino virtuale. | app operatore | L | W `PrizeHubSlots`, `Premi` (I/U), `MovOut` (I), `MovMag` (I) | `AppPrizeHubHandler.bas:64-114`; `DBwinmt.bas:13860-14350` | — (W07 § 4.5: modello `PrizeHub_MoveToSlot`) | solo B4J |
| E05-35 | Gestione PrizeHub: ticket medi SPINDLE | Forza o ripristina `ticketsMedi`. | WinMT `frmEditPrizeHub`; app | S | W `PrizeHubSlots`, `Premi` | `AppPrizeHubHandler.bas:237-290`; `DBwinmt.bas:15275-15328` | W07-09 | complementare |
| E05-36 | Gestione PrizeHub: foto e icona articolo | Foto/icona in Base64 su `Premi` e sugli slot collegati. | app operatore | S | W `Premi` | `AppPrizeHubHandler.bas:120-147`; `DBwinmt.bas:14025-14123` | W06-05 | doppione |
| E05-37 | Partner: saldo e scarico ticket | `read`/`balance` (saldo, multi-sala), `withdraw` (`prelevaSoloPunti` senza operatore). Solo token partner. | partner terzo | M | R `Clienti`, `Tickets`; W `Tickets`, `Clienti.Tickets` | `PartnerHandler.bas:190-238` | W01-25 | doppione (scarico punti senza catalogo) |
| E05-38 | Baytech: lettura, lista, prelievo | `READ`, `LIST`/GET list (senza auth), `GET`: premio da distributore "1" (`QDis1`) o soli punti; **controllo saldo commentato**. | distributore Baytech | M | R `Premi`, `Clienti`, `Tickets`; W `Tickets`, `Clienti.Tickets`, `Vincite`, `Premi.Quantita/QDisN` | `TicketsHandler.bas:149-345`; `DBwinmt.bas:7862-7924` | W06-31 | complementare (vecchio modello `PDis/QDis`) |
| E05-39 | Gru: consultazione | Lista, dettaglio, articolo (GET senza auth). | app gru/operatore | S | R `sp_crane_list`, `vs_CraneStatus`, `GruMovimenti`, `Premi` | `CraneHandler.bas:152-181`, `444-461`; `DBCrane.bas:84-260`, `839-886` | W07-11 | complementare |
| E05-40 | Gru: carico e scarico slot | Slot 1–3: giacenza premi, movimenti di magazzino, dettaglio gru, movimento. Transazionale. | app gru/operatore | L | W `Premi`, `MovOut`/`MovMag` (I), `GruMagazzinoDettaglio`, `GruMovimenti` (I) | `CraneHandler.bas:231-290`; `DBCrane.bas:309-454`, `888-1030` | W07-11, W06-13 | complementare |
| E05-41 | Gru: vincita | Scala la giacenza dello slot e risincronizza i valori medi su `EcsMacchine`. | app gru/operatore | M | W `GruMagazzinoDettaglio`, `GruMovimenti`; SP `sp_crane_ensure_records`, `sp_crane_sync_ecsmacchine_values` | `CraneHandler.bas:293-324`; `DBCrane.bas:262-307`, `1036-1042`, `1160-1206` | — | solo B4J |
| E05-42 | Gru: nuovo articolo | Crea un premio con carico iniziale e movimento. | app gru/operatore | M | W `Premi` (I/U), `MovMag` (I) | `CraneHandler.bas:463-499`; `DBCrane.bas:749-837` | W06-03 | doppione |
| E05-43 | Cloud: autenticazione cliente dell'app | `AuthUser`, `AuthUserByEMail` (password opzionale), `AuthUserByToken`, `SetUserToken`, `RefreshUserToken`: profilo cliente, token in `Clienti.username`. | cloud Elmac (app player) via MQTT | M | R `Clienti`, `TransCard`, `ClientiTarget`; W `Clienti.username`, correzione codbar (`fixCodbarRotti`) | `clsElmacAPI.bas:187-465`; `DBwinmt.bas:5646-5744`, `13686-13741` | W03-04, W03-06 | complementare |
| E05-44 | Cloud: password, email, certificazione | `SetUserPassword` (V1 senza vecchia password), `SetUserPasswordV2`, `SetUserEMailV2`, `SetUserEMailCertified`. | cloud via MQTT | M | W `Clienti.password`, `email`, `EMailIsCertified`, `username` | `clsElmacAPI.bas:338-386`, `466-546`, `645-669`; `DBwinmt.bas:5568-5637`, `12460-12526` | W03-03 | doppione |
| E05-45 | Cloud: creazione cliente | `CreateUser` e `CreateUserV2` (prenotazione e finalizzazione di un codbar QR). | cloud via MQTT | M | W `Clienti` (I); SP `GetFreeUidCodbar`, `FinalizeUidCodbar` (`uid_reservations`, `UID_Ammessi`) | `clsElmacAPI.bas:547-616`; `DBwinmt.bas:11691-11837`, `15546-15617` | W03-06, W03-26 | doppione |
| E05-46 | Cloud: anagrafica e consensi | `UpdateUser*`, `UpdateUserProfile*` (consensi in `Clienti.Foto`), `GetUserProfile*`. | cloud via MQTT | M | R/W `Clienti`, `Clienti.Foto` | `clsElmacAPI.bas:617-644`, `677-714`, `964-1078`; `DBwinmt.bas:4819-5085`, `7728-7748` | W03-03 | doppione |
| E05-47 | Cloud: livello e promozione VIP | `SetCardType*`; `PromoteUser*` secondo `VipPromotionModel` (dati personali → `TipoCard`; sottoscrizione → flag `checkVipPromotion`). | cloud via MQTT | M | W `Clienti.TipoCard`, `Clienti.Foto` | `clsElmacAPI.bas:715-890`; `DBwinmt.bas:4756-4806`, `12534-12577` | W04-23 | doppione (§ 5.4) |
| E05-48 | Cloud: richiesta sostituzione card | Genera OTP di 4 cifre e `ReissueCardStatus = 1` negli attributi. | cloud via MQTT | S | W `Clienti.Foto` | `clsElmacAPI.bas:891-963`; `cliente.bas:319-328` | W04-24 | complementare (B4J chiede, WinMT sostituisce) |
| E05-49 | Cloud: ricarica crediti | `AddCreditToUser*`: bonus da `getListino` (solo `T10`), `TransCard` `NImp 0` crediti e `NImp 6` bonus, `CodMac 'CLOUD'`. | cloud via MQTT | M | R `Setup.T10`, `transcard`; W `Clienti.Credito`, `TransCard` (I) | `clsElmacAPI.bas:1079-1178`; `DBwinmt.bas:4643-4706`; `DBcoinless.bas:3565-3666` | W05-02 | doppione (§ 5.1) |
| E05-50 | Cloud: accredito punti | `AddPointToUser*`: scontrino di ticket e ricalcolo `Clienti.Tickets`. | cloud via MQTT | S | W `Tickets` (I), `Clienti.Tickets` | `clsElmacAPI.bas:1179-1273`; `DBwinmt.bas:8648-8705` | W05-01 | doppione |
| E05-51 | Cloud: movimenti, partite, operazioni | `getOperazioniCardV2`, `getPartiteCardV2`, `getMovimentiCardV2`. | cloud via MQTT | S | R `TransCard` | `clsElmacAPI.bas:1274-1306`; `DBwinmt.bas:5354-5443` | W04-07 | doppione |
| E05-52 | Cloud: creazione codice redeem | `getRedeemV2`: chiamata a `sp_redeem_create` con stringa malformata e nessuna risposta valorizzata. | cloud via MQTT | S | (W `RedeemCodes`, non funzionante) | `clsElmacAPI.bas:1307-1329`; `DBcoinless.bas:5027-5088` | W04-18 | morto/rotto |
| E05-53 | Configurazione del totem | `/eclservices/getkioskconfig?kioskId=…` (senza auth): WINMtConfig + `setup2` per postazione; `/eclservices/getscalettabonus` (sempre `IdPost 101`). | totem | S | R `Setup`, `setup2` | `eclservice.bas:95-102`; `kioskConfig.bas:21-320`; `scalettaBonus.bas:27-130` | W04-01 (configurazione) | solo B4J |
| E05-54 | Pagina punteggi giocatore | `/playerscore` → `/player_score.html`; WebSocket con `ValidatePlayer`. | browser del giocatore | S | (altra zona) | `redirectuserinfo.bas:14-19`; `PlayerScore.bas` | — | solo B4J |

### Dettaglio dei flussi L e dei doppioni

**E05-07 `sync-card` [V `FlutterKioskHandler.bas:394-543`].** Ordine delle regole: (1) errore hardware → 470; (2) `plant.owner/site` ≠ `CodiceCliente/CodiceImpianto` → 470 `PLANT_MISMATCH` (il `group` non è verificato); (3) `ConfrontaCardConCliente` (§ 5.3); (4) punti offline → `scriviTicketsManualiSuWINMT` e card da riscrivere; (5) promozione Gold scaduta → livello precedente da `promozioni_cards`; (6) Birthday con evento scaduto → Silver; (7) VIP automatico → Platinum (escluso il modello Sottoscrizione); (8) livello sulla card ≠ `Clienti.TipoCard` → da riscrivere. Se `clonata = True` il server **scrive solo un log**: niente blacklist e niente riscrittura (la `data` resta quella ricevuta) [V `:462-464`, `:534-540`].

**E05-12 `recharge-card` [V `DBcoinless.bas:3713-3847`].** N0 non da `MAX(N0)+1` ma dal progressivo già scritto sulla card (vecchio + 2). Bonus a N0−1 (o a N0 se ricarica di solo bonus, fix del 2026-09-15 [V `:3748-3760`]). `ValoreFinale` = saldo **dichiarato dal totem**. `T0` = codice impianto su 4 cifre. Idempotenza: riga principale già presente con stessi valori → `GIA_APPLICATA` (nessun doppio ticket); valori diversi → `CONFLITTO_PROGRESSIVO_GIA_USATO`. Contante: 0 oppure uguale ai crediti, mai parziale [V `FlutterKioskHandler.bas:1219`]. Il **bonus crediti arriva dal totem** e non è ricontrollato sulla scaletta [V `:1211`, `:1254`]; i ticket bonus invece sono calcolati dal server su `T12` [V `:1269-1279`].

**E05-13 redeem [V `FlutterKioskHandler.bas:1303-1507`].** I valori applicati sono riletti dal DB, non presi dal totem [V `:1400`]. Ramo `new`: Gold se promozione attiva (migliora il no-op VB6), `ticketless = 1`, birthday → riga `Ospiti` [V `:1438-1449`]. Ramo `recharge`: **implementato**, mentre in WinMT è vuoto e scritto "rechage" (W04-19). Le scritture (cliente, crediti, ticket, conferma) **non sono in transazione**; se `ConfirmRedeemCode` fallisce dopo l'accredito il codice resta solo prenotato e torna riscattabile alla scadenza dei 5 minuti [V `:1486-1491`; D l'effetto].

**E05-19 riscatto PrizeHub [V `DBwinmt.bas:14765-14882`].** Unica transazione (slot con `UPDLOCK`, consumo FIFO, saldo, vincita); `Premi.Quantita` non è toccata (lo stock è già uscito al carico dello slot) [D]. L'espulsione MQTT parte solo dopo il commit; se fallisce resta solo un log [V `FlutterTicketsHandler.bas:341-355`]. SPINDLE: articolo, hub, unità e slot sono ricavati da un codice `SPINDLE<hub>_<unit>-<slot>` [V `:275-285`].

**E05-22 prelievo premio dall'app [V `DBwinmt.bas:7926-7995`, `8173-8235`].** `toglipunti` contiene un `Wait For` (`DBwinmt.bas:8557`): diventa una sub riprendibile e il chiamante prosegue **prima** che il consumo dei ticket sia confermato [V la struttura; D l'effetto]. `prelevaPremio` e `prelevaSoloPunti` non dichiarano un tipo di ritorno ma sono usate come `Boolean` (`AppPlayerHandler.bas:186-188`, `PartnerHandler.bas:229`): il valore di `ok` va verificato a runtime [D]. `prelevaSoloPunti` legge l'operatore con la chiave `Id`, `prelevaPremio` con `UserID` [V `DBwinmt.bas:7979`, `8226`]; `toglipunti` scrive comunque `operout = 0` [V `:8545`].

**E05-30 sostituzione BI.** Logica duplicata col pannello web `MacchineConfigurate.bas` (commenti in `AppServiceHandler.bas:502-507`, `577-580`). `biSwapAutoRecover` dipende da stato in memoria (`Main.elencoMacchineMqttSetup`, `Main.elencoBISwapRetryCooldown`) [V `:526-549`, `:688-694`]. La documentazione dice "riscrive i contatori", il codice fa una riprogrammazione completa [V `:642`].

**E05-33/34 PrizeHub e E05-40 gru.** Transazioni su un'unica connessione con rollback [V lo schema di `DBwinmt.bas:15026-15204`, `DBCrane.bas:309-454`]. WinMT `frmEditPrizeHub` usa già queste API per scrivere (W07-08, W07-09): è l'unico caso in cui WinMT è cliente di B4J.

---

## 3. Interlocutori

### 3a. Topic MQTT (solo quelli della zona)

| Topic | Dir. | Broker | Payload | Controparte | Evidenza |
|---|---|---|---|---|---|
| `ElmacAPI/<metodo>` | in | main | JSON con `sessionUID` e parametri del metodo | **cloud Elmac** (backend dell'app player). Gestito solo se `Primario = 1` | `ecs2mqtt.b4j:782`, `912-929` [V] |
| `ElmacAPIResponse/<metodo>` | out | main | JSON V1 (`OperationOK`, `ElmacServer` = `<cliente>z<impianto>`) o V2 (`status`, `data`) | cloud | `ecs2mqtt.b4j:925` [V] |
| `HUB/<hubId>/eject` | out | main | `{unit, slot, prize, qty}` | controller fisico del PrizeHub | `FlutterTicketsHandler.bas:341-355`; `ecs2mqtt.b4j:2280-2290` [V] |
| `ElmacECL/BlackList` | out, retained | main | elenco blacklist | tutte le schede | `DBwinmt.bas:1881-1893` (da `detach-card`) [V] |
| `ElmacECL/<device>` | out | main | comando reboot | scheda BE online | `AppServiceHandler.bas:419` [V] |
| `SetUp/<macaddress>` | out | setup | reboot, `disattiva_setup_mode`, programmazione | scheda in setup | `AppServiceHandler.bas:430`, `676`; `Main.programmaDevice` [V] |
| `Service/<macaddress>` | out | main | fuori servizio / in servizio | scheda | `ecs2mqtt.b4j:4618-4640` [V] |
| `ECLservice/+/+` | in | main | — | "cellulari di servizio": stub, solo log | `serviceHandler.bas:13-41`; `ecs2mqtt.b4j:898` [V] |

### 3b. Endpoint HTTP/WebSocket esposti

Formato: `GET …/action/<azione>/key/<valore>` e `POST …/action/<azione>` con corpo JSON. **Auth:** "token" = Bearer verificato da `sicurezza.RichiedeAutenticazione`; "nessuna" = nessun controllo.

| Metodo e path | Auth | Consumatore | Cosa fa / funzione DB | Tabelle |
|---|---|---|---|---|
| GET `/kiosk/action/login/key/{k}` | nessuna (chiave) | totem | `calcolaTokenApp` + parametri coinless | — |
| POST `/kiosk/action/read-card` | token | totem | `leggiClienteByCodbarOrT0`/`getCliente` | R Clienti, TransCard |
| POST `/kiosk/action/validate-card` | token | totem | `DBcoinless.getUidAmmesso`; `IsCardDetached` | R UID_ammessi, Operatori, Clienti |
| POST `/kiosk/action/detach-card` | token | totem | `detachCustomerCard`; `sp_ripristinacard`; `verificaBlackList` | W Clienti(.Foto, T0, CodBar), dati coinless |
| POST `/kiosk/action/purge-card` | token | totem | `sp_eliminacliente` (cancellazione fisica a cascata) | D Clienti e storia |
| POST `/kiosk/action/create-user` | token | totem | `ImpostaLivelloPromozione`, `creaClienteAnonimo`, `assegnaCardAPromozione`, `addCreditiToUser`, `scriviTicketsManualiSuWINMT` | W Clienti, promozioni_cards, TransCard, Tickets |
| POST `/kiosk/action/sync-card` | token | totem | § 2 E05-07 | R/W Clienti, Tickets, promozioni_cards |
| POST `/kiosk/action/calc-bonus` | token | totem | `CalcolaBonusPerImporto` | R Setup |
| POST `/kiosk/action/distribuisci-importo` | token | totem | `DistribuisciImporto` | — |
| POST `/kiosk/action/start-transaction` | token | totem | UUID v4 | — |
| POST `/kiosk/action/log-transaction` | token | totem | `identificamiSuSetup`, `SalvaLogTransazioneTotem` | R Setup; I LogTransazioniTotem |
| POST `/kiosk/action/close-transaction` | token | totem | `ChiudiSequenzaContanteTotem` | U LogTransazioniTotem |
| POST `/kiosk/action/pos-transaction-pending/-result/-progressivo/-complete` | token | totem | `InserisciLogPosPending`, `AggiornaEsitoPosByUID`, `AggiornaProgressivoPosByUID`, `AggiornaStatoPosByUID` | I/U LogTransazioniPos |
| POST `/kiosk/action/recharge-card`, `recharge-card-tickets` | token | totem | `RicaricaCardTotem`, `GetIdOperatoreByNome`, `scriviTicketsManualiSuWINMT` | W TransCard, Clienti, Tickets |
| POST `/kiosk/action/redeem-check`, `redeem-confirm` | token | totem | `sp_redeem_check_and_reserve_no_pin`, `sp_redeem_verify_pin`, `LeggiRedeemCode`, `creaClienteAnonimo`, `addCreditiToUser`, `sp_redeem_confirm/cancel`, `AssegnaCardARedeemCompleanno` | W RedeemCodes, Clienti, Ospiti, TransCard, Tickets |
| POST `/kiosk/action/card-history` | token | totem | `getStoricoMovimentiCliente` | R TransCard |
| POST `/api/validate-card`, `detach-card`, `purge-card`, `create-user` | **nessuna** (token letto e scritto nel log, mai verificato) | non identificato | come sopra | come sopra |
| GET `/hub/action/login/key/{k}` | nessuna | PrizeHub | token | — |
| GET `/hub/action/image/key/{codice}` | nessuna | PrizeHub | `ReadArticleImage` | R Premi |
| POST `/hub/action/readcard`, `prizes`, `redeem`, `config` | token | PrizeHub | `getPrizesForHub`, `prelevaPremioDaHub`, `prelevaSpindleSlot`, `leggiSetupV2` | R/W PrizeHubSlots, Tickets, Clienti, Vincite, setup2 |
| GET `/app/action/login/key/{k}` | nessuna | app, WinMT | token | — |
| GET `/app/action/getimage/key/{c}`, `geticon/key/{c}` | nessuna | app | `ReadArticleImage` | R Premi |
| GET `/app/action/getprizehubs` | nessuna | app, WinMT | `getPrizeHubList` | R setup2 |
| POST `/app/action/READCARD`, `READCODBAR`, `LIST`, `GET`, `LOCKCARD`, `UNLOCKCARD` | token | app | E05-20…23 | R/W Clienti, Tickets, Vincite, Premi |
| POST `/app/action/SVCOPERATOR`, `SVCSTATOSALA`, `SVCMACCHINEOOO/ONLINE/HH/ATTIVE`, `SVCREADCARDDETAILS`, `SVCREADCARDTRANSACTIONS`, `SVCGETSETUP`, `SVCREFUNDTCK`, `SVCREFUNDTRAN`, `SVCOOO`, `SVCREFRESHHH`, `SVCREBOOTHH`, `SVCCHKOP`, `SVCBISWAPLIST/START/WRITE/END` | token | app di servizio | E05-24…30 | vedi § 2 |
| POST `/app/action/SVCPHGETSLOTS`, `_V2`, `SVCPHGETPRIZE`, `SVCPHGETSETUP`, `SVCPHLOADSLOT`, `SVCPHREPLACEPRIZE`, `SVCPHMOVETOWHAREHOUSE`, `SVCPHSETTICKETSMEDI`, `SVCPHRESET_TICKETSMEDI`, `SVCPHREPLACEIMAGE` | token | app operatore, WinMT | E05-32…36 | PrizeHubSlots, Premi, MovOut, MovMag |
| GET `/partner/action/login/key/{k}` | nessuna (chiave partner, sovrascrivibile da `PartnerApiKey`) | partner | `calcolaTokenPartner` | — |
| POST `/partner/action/read`, `balance`, `withdraw` | token **partner** (unico handler che controlla `userId`) | partner | `leggiClienteByCodbarOrT0`, `prelevaSoloPunti` | R/W Clienti, Tickets |
| GET `/tickets/action/login/key/{k}` | nessuna | Baytech | `calcolaToken` | — |
| GET `/tickets/action/list`, `getimage/key/{c}`, `geticon/key/{c}` | nessuna | Baytech | `getAllPrizehubPrizes("dis1")`, `ReadArticleImage` | R Premi |
| POST `/tickets/action/READ`, `GET`, `LIST` | token | Baytech | `prelevaPremioDaprizeHub`, `prelevaSoloPunti` | W Tickets, Clienti, Vincite, Premi |
| GET `/crane/action/login/key/{k}` | nessuna | gru/app | `calcolaToken` | — |
| GET `/crane/action/list`, `detail/key/{codmac}`, `article/key/{c}` | nessuna | gru/app | `Crane_List`, `Crane_GetDetail`, `Crane_GetArticle` | R viste gru, Premi |
| POST `/crane/action/LOAD`, `UNLOAD`, `WIN`, `ARTICLECREATE` | token | gru/app | `Crane_*` | W Premi, MovOut, MovMag, Gru* |
| GET `/eclservices/getkioskconfig?kioskId=`, `/eclservices/getscalettabonus` | nessuna | totem | `kioskConfig.GetConfigJson`, `BuildBonusScaleJson` | R Setup, setup2 |
| GET `/playerscore`; WS `/ws/playerscore` | sessione giocatore | browser | redirect; pagina | — |

**Autenticazione, come funziona davvero [V `sicurezza.bas:42-137`]:**
- Le chiavi sono quattro e statiche: tre sono credenziali nel codice (`sicurezza.bas:8-13`), la quarta, del partner, è sovrascrivibile da `dbsettings` (`:71`). Il segreto di firma è anch'esso una credenziale nel codice (`sicurezza.bas:16`).
- Il token vale `base64(userId|ruolo|scadenza)` più `HMAC(segreto)`. `VerificaToken` **non controlla `userId`**: la riga `:112` calcola un `secret` che non viene mai usato. Quindi un token emesso per la gru o per Baytech vale anche su `/kiosk`, `/app`, `/hub`, e viceversa. Solo `/partner` filtra per `userId` [V `PartnerHandler.bas:85`]; un token partner resta però valido sugli altri handler.
- Il campo `hash` delle risposte non firma il contenuto: `calcolaHmac` ignora il messaggio e firma solo `DateTime.Now` [V `sicurezza.bas:23-40`]. Il `nonce` (`DateTime.Now * 2`) non è verificato da nessuno: **non è un anti-replay** [D].
- Gli identificativi di operatore (`oper`, `operatore`) sono presi dal corpo della richiesta e non sono legati al token [V, per esempio `AppServiceHandler.bas:228`, `292`; `CraneHandler.bas:236`].

### 3c. Chiamate in uscita

| Verso | Mezzo | Per cosa | Evidenza |
|---|---|---|---|
| DB di sala (`WinMtSqlDB`, `pool`) | JDBC | tutte le letture e scritture; alcune query nominano il database per esteso `[WinMtSqlDB].[dbo]` | `DBwinmt.bas:3082-3159`, `8451-8478` [V] |
| DB del gruppo multi-sala (`cloudpool`) | JDBC: SQL locale con linked server `[elmaccloud]` **oppure** connessione diretta a `winmt.elmaccloud.com:1433`, secondo `settings.Connected` | `sp_last_trans`, `sp_preleva_punti` (DB `rdclienti` o `DbClientiMultilocale`); lettura dei `Tickets` degli altri locali. Credenziali nel codice (`DBwinmt.bas:190-219`) | `DBwinmt.bas:190-219`, `8366-8446`, `7926-7960` [V] |
| Broker MQTT main/setup | MQTT | § 3a | [V] |
| Cloud Elmac per `clsElmacAPI` | **nessuna chiamata HTTP**: il cloud entra via MQTT (§ 3a). La classe non chiama URL esterni [V grep `HttpJob`/`http` su tutti i moduli della zona] | — | [V] |
| File | nessuno nei moduli della zona (le statiche web stanno in `C:\ecs2mqtt\www`) | — | `ecs2mqtt.b4j:482` [V] |

**Online contro Sala (domanda della consegna).** `clsGestioneClienteOnline` e `clsGestioneClienteSala` **non** rappresentano cloud contro sala né la logica multisala. Distinguono due modalità di card [V `clsGestioneClienteSala.bas:225-234`]:
- *Online*: "GetCred sempre online", il saldo è nel DB e il server autorizza la partita (`CanPlay`).
- *Sala*: "carta con saldo", il saldo è anche sulla card e va riconciliato (`VerificaSyncCard`).

Le tre classi sono copie con derive: `CanPlay` è identico in Online e Sala, ha le scritture commentate nella terza classe, che è morta. La **logica multisala** sta in `myWinMtConfig.multilocale`, `IdLong` (`cliente.bas:376-380`), `ricalcolaTicketsInAltroLocale` e nelle procedure cloud `sp_last_trans`/`sp_preleva_punti` [V].

**Consumatori reali e altri canali verso gli stessi dati:**
- **Totem nuovo** (Flutter) → `/kiosk` + `/eclservices/getkioskconfig`. Il **totem attuale** scrive invece direttamente nel DB (analisi-00 § 4); WinMT riconosce le sue postazioni dal nome che contiene "OTEM" (W04-05). Due canali scrivono quindi `TransCard NImp 1`, `LogTransazioniTotem` e `LogTransazioniPos` con convenzioni diverse (§ 4b) [D].
- **PrizeHub Flutter** → `/hub`; il controller fisico riceve `HUB/<id>/eject`.
- **App di servizio dell'operatore** (B4A, "ECL Service") → `/app` gruppi SERVICE e PRIZEHUB [D da `docs/fonti/ecl2mqtt/istruzioni_vb6_prizehub_opzioneA.md`]. Il gruppo PLAYER (`/app` READCARD/LIST/GET) è chiamato "app player/operatore" nella documentazione: consumatore da confermare.
- **WinMT** (`frmEditPrizeHub`) → `/app` SVCPHLOADSLOT, SVCPHSETTICKETSMEDI, SVCPHRESET_TICKETSMEDI (W07-08/09).
- **App player** → cloud Elmac → MQTT `ElmacAPI` (non HTTP).
- **Baytech** → `/tickets`. **Partner** non nominato → `/partner`. **Gru/app gru** → `/crane`.
- `/api`: consumatore non identificato (forse micrototem o GiallOne, W04-22) [D].
- Altri canali sugli stessi dati: WinMT cassa (W01-06 premi, W05-02 ricariche, W04-19 redeem) e il flusso MQTT di gioco (`CanPlay`, altra zona).

---

## 4. Dati

### 4a. Tabelle, viste e procedure usate (zona)

| Oggetto | Operazioni | Da |
|---|---|---|
| `Clienti` | R; I (`creaClienteAnonimo`, `creacliente`); U `Credito`, `Tickets`, `TipoCard`, `Abilita`, `Foto`, `password`, `username`, `email`, `EMailIsCertified`, anagrafica | kiosk, api, app, hub, partner, tickets, cloud |
| `TransCard` | R; I (`NImp` 0, 1, 6, 8) | kiosk, cloud, app servizio |
| `Tickets` | R; I (ticket manuali, scontrini da app); U `TPagati` (FIFO) | quasi tutti |
| `Vincite` | I | hub, app, tickets |
| `Premi` | R; U `Quantita`, `QDisN`, `Foto`/`Icona`; I (nuovo articolo) | hub, app, tickets, gru |
| `PrizeHubSlots` | R/I/U/D | hub, app PRIZEHUB |
| `MovOut`, `MovMag` | I | app PRIZEHUB, gru |
| `GruMagazzinoDettaglio`, `GruMovimenti`, `vs_CraneStatus` | R/U/I | gru |
| `UID_ammessi`; `uid_reservations` (via SP) | R; prenotazione e finalizzazione | kiosk, api, cloud |
| `RedeemCodes` | R; U via `sp_redeem_*` | kiosk |
| `promozioni`, `promozioni_cards` | R; I; D | kiosk, api |
| `Compleanni`, `Ospiti`, `PartiteOspiti` | R; I `Ospiti` | kiosk (redeem), `clsCompleanni` |
| `LogTransazioniTotem`, `LogTransazioniPos` | I/U | kiosk |
| `Setup` | R (`T10`, `T12`, `mname`, `T6`) | bonus, kiosk |
| `setup2` | R (`PrizeHub0<n>`, chiavi del totem) | hub, kioskConfig |
| `Operatori` | R; I (`CreaOperatorePrizeub`) | app, kiosk |
| `EcsMacchine`, `EcsModuli`, `vs_CoinlessSpecialTimes`, `CoinlessDecodedData` | R; U `BISwap`, `BISwapStep` | app servizio |
| `AuditLog` | I | app servizio |
| `CoinlessLogEventiBlacklist` | R | `cliente.getReplaceHistory` |
| SP | `sp_ripristinacard`, `sp_eliminacliente`, `sp_redeem_check_and_reserve_no_pin`, `sp_redeem_verify_pin`, `sp_redeem_confirm`, `sp_redeem_cancel`, `sp_redeem_create`, `GetFreeUidCodbar`, `FinalizeUidCodbar`, `sp_crane_list`, `sp_crane_ensure_records`, `sp_crane_sync_ecsmacchine_values`; cloud: `sp_last_trans`, `sp_preleva_punti` | |

### 4b. Colonne con significato nuovo o diverso da db-08

| Colonna | Cosa fa B4J | Rispetto a db-08 | Evidenza |
|---|---|---|---|
| `Clienti.N0` | `create-user` senza `ticketLess` scrive **2** | **spiega** il "2 non spiegato" di db-08 [D forte] | `APIHandler.bas:310`; `DBwinmt.bas:11899-11906` [V] |
| `Clienti.UserName` | token di sessione dell'app (`NEWID()` o valore del cloud), letto come `cliente.Token` | db-08: "non scritto da WinMT" → **non in db-08** come significato | `DBwinmt.bas:5656-5730`; `cliente.bas:111` [V] |
| `Clienti.Password` | confronto in chiaro; restituita nelle risposte API | conferma db-08 (in chiaro), aggrava | `clsElmacAPI.bas:271`, `403`; `cliente.bas:539`, `609` [V] |
| `Clienti.Foto` | JSON degli attributi più la chiave `CardCreatedBy`; `ReissueCardList` serializzata come stringa con escape; scritto come `VARBINARY(MAX)` | `CardCreatedBy` **non in db-08** | `cliente.bas:81`, `285-288`, `704-724`; `DBwinmt.bas:7738` [V] |
| `Clienti.IdContatto` | `MAX(idcontatto)+1` per `nimp`, **senza** saltare i valori già in `TransCard.IdCli` | **contraddice** la regola di W02-09 | `DBwinmt.bas:11869-11906` [V] |
| `Clienti.Nome/Cognome` | cliente anonimo con stringhe vuote | db-08: segnaposto `Cliente - N` | `DBwinmt.bas:11899-11905` [V] |
| `Clienti.Abilita` | `LOCKCARD` = "tessera bloccata"; il PrizeHub rifiuta `Abilita = 0` con 423 | quarto significato oltre ai tre di db-08 (lock di postazione, card abilitata) | `AppPlayerHandler.bas:234`; `FlutterTicketsHandler.bas:201` [V] |
| `TransCard.NImp` 0 | crediti dal cloud, dal redeem e da `create-user` scritti come "carico da cassa fissa" con `ValoreCassa = crediti` | **contraddice** db-08 (14 = online, 13 = compleanni) | `DBcoinless.bas:3628-3660` [V] |
| `TransCard.N0` | totem: dal progressivo della card; cloud/redeem: `MAX(N0)+1` | due convenzioni nella stessa colonna | `DBcoinless.bas:3667-3681` [V] |
| `TransCard.T0` | impianto su 4 cifre (totem); `NULL` (cloud); `Nimp` (rimborso) | da uniformare | `DBcoinless.bas:3742`; `DBwinmt.bas:4451-4464` [V] |
| `TransCard.CodMac`, `Operatore` | `kioskId`, `'CLOUD'`, hostname, `'ECL-SERVICE'`; operatore = `Operatori.Id` con `Nome = kioskId` | non in db-08 | `FlutterKioskHandler.bas:1252`; `DBwinmt.bas:4456` [V] |
| `Tickets` scritti da `scriviTicketsManualiSuWINMT` | `MangiaT 64`, `Oper 10000`, `NRep 8`, `F1 1`, `T1` = postazione o etichetta (`kiosk-recharge`, `kiosk-synccard`, kioskId); `NumTrans` = 100.000.000 + secondi dall'inizio dell'anno | `T1`/`F1` hanno un **nuovo significato** (db-08: device ECL o campagna); `NumTrans` con formula diversa da `CalcSerNum` | `DBwinmt.bas:3115-3146` [V] |
| `LogTransazioniTotem.AC` | UUID della sequenza anche per le righe **POS** | db-08: solo contanti | `FlutterKioskHandler.bas:780-783` [V] |
| `LogTransazioniTotem.CAut` | nuovo stato **`Error`** | db-08: Pending, Completed, Recovered | `FlutterKioskHandler.bas:869-873` [V] |
| `LogTransazioniTotem.TCC` | mai scritto dal totem nuovo | WinMT lo usa per decidere il recupero (W04-06) | [V assenza in `DBwinmt.bas:13252-13347`] |
| `LogTransazioniPos.MName`, `IdPost` | nome della postazione in `Setup` e suo `IDPost`; `Stan` sempre vuoto | db-08: `<modello>_<computer>` | `DBwinmt.bas:13386-13444` [V] |
| `RedeemCodes.DbName` | `LeggiRedeemCode`/`sp_redeem_*`: `Nimp`; `creaCodiceRedeem`: `"DB" + Nimp` | il secondo **contraddice** db-08 | `DBwinmt.bas:12217`; `DBcoinless.bas:5061` [V] |
| `uid_reservations.ReservedBy` | `sessionUID` del cloud, TTL 60 s | db-08: IdPost, TTL 10 s | `clsElmacAPI.bas:580` [V] |
| `Operatori.Foto` | letto con chiavi `MaxRefoundsPerDay` (refuso) e restituito come `OPAttributes` (Map); `CanOperatorRefundNow` lo tratta come stringa JSON con chiave `MaxRefundsPerDay` | incoerenza di chiavi; il limite rimborsi probabilmente non funziona [D] | `DBwinmt.bas:8090-8172`; `AppServiceHandler.bas:729-758` [V] |
| `EcsMacchine.BISwap`, `BISwapStep` | stato della sostituzione BI | **non in db-08** | `DBwinmt.bas:10518-10592` [V] |
| `setup2` | chiavi `PrizeHub0<n>`, `localization`, `card`, `card.createNewCard.maxCardsPerPurchase`/`minFiatAmountPerCard`, `payments`, `tokens`, `features.*`, `totems.devices.policy` (101), per `IdPost` del totem | chiavi del totem **non in db-08** | `kioskConfig.bas:26-35`, `118-122`, `225-228` [V] |
| `PartiteOspiti` | scritto da B4J (MERGE) | conferma la deduzione di db-08 ("scrittore: server ECL") | `DBwinmt.bas:11446-11520` [V] |
| `Vincite` | `Cons = 1` sempre, `Id` = `IdOperatore` della config, `f0` = flag multi-sala | da allineare a db-08 | `DBwinmt.bas:14827-14830` [V] |

### 4c. DDL eseguito dal codice della zona

Nessuno [V grep `CREATE`/`ALTER` sui moduli della zona]. Le scritture di configurazione sono DML: `identificamiSuSetup` può creare una riga `Setup` con `IDPost = max+1` (qui sempre chiamato con `creaSeNonEsiste = False`) e `CreaOperatorePrizeub("Prizehub1")` inserisce un operatore se `IdOperatore = 0` sul primario [V `DBwinmt.bas:6766-6800`, `6853`].

### 4d. Stato fuori dal DB che è di fatto un dato

| Stato | Dove | Effetto |
|---|---|---|
| Chiavi API e segreto di firma | `sicurezza.bas:8-16` (credenziali nel codice); `PartnerApiKey` in dbsettings | identità dei client; per revocare serve un rilascio |
| `Main.throttle` (`PRIZEHUB_<id>`, `PRIZEHUB01`) | memoria, finestra `PrizeHubThrottleSec` | sessione PrizeHub implicita | 
| `Main.myWinMtConfig.nomemacchina` | fissato a `"PRIZEHUB01"` (`WINMtConfig.bas:289`) e **sovrascritto a ogni `identificamiSuSetup`** con il `kioskId` della richiesta (`DBwinmt.bas:6787`) | `TicketsHandler` ne prende l'ultima cifra come distributore (`TicketsHandler.bas:299`): stato globale condiviso tra richieste |
| `Main.BlackListPayload` | memoria | ultima blacklist pubblicata |
| `Main.elencoMacchineMqttSetup`, `elencoBISwapRetryCooldown` | memoria | avanzamento della sostituzione BI |
| Token emessi | solo nel token (24 h), nessuna tabella | nessuna revoca né elenco delle sessioni |
| Prenotazione redeem | `RedeemCodes` (5 min) | ok, già nel DB |

### 4e. Sovraccarichi semantici

- `Clienti.Abilita`: lock di postazione (WinMT), card abilitata, blocco da app (B4J); il PrizeHub tratta lo zero come "disabilitata".
- `Clienti.Foto`: attributi, consensi, OTP, elenco delle card sostituite, scadenza VIP, origine della card.
- `TransCard.NImp 0`: cassa fissa, ma anche cloud, redeem e totem/`create-user`.
- `Tickets.T1`: device ECL, campagna app, ora anche postazione o etichetta del flusso B4J.
- `LogTransazioniTotem.AC`/`CAut`: UUID e stato per i contanti, codice di autorizzazione per il POS (WinMT); B4J usa `AC` come UUID anche per il POS.
- `Clienti.Tickets`: in multi-sala `aggiornaTicketsCliente` scrive il totale di tutte le sale meno il prelievo (`DBwinmt.bas:8451-8478`, `14739`).

---

## 5. Doppioni e sovrapposizioni con WinMT

| # | Regola | WinMT | B4J | Uguale? |
|---|---|---|---|---|
| 5.1 | **Bonus da scaletta** su ricarica | `CalcBonus` greedy su `T10` (W02-18); `ECL_BonusHandler.cls` per crediti e ticket; ticket bonus come scontrino tipo 64 | tre implementazioni: `ECL_BonusHandler.bas` (porting greedy di T10/T12: kiosk, cassa mobile MQTT); `getListino` (`DBwinmt.bas:4643-4706`: per ogni scaglione dall'ultimo, `floor`, **solo crediti**: cloud `AddCreditToUser`, `eclcommand jgetListino`); `BuildBonusScaleJson` (tabella per il totem, sempre IdPost 101) | Equivalenti se gli scaglioni sono in ordine crescente [D]; il cloud **non dà ticket bonus**; nel totem il bonus crediti lo decide il client e non viene ricontrollato |
| 5.2 | **Creazione cliente** | `AddCliente`: `IdContatto` MAX+1 in SERIALIZABLE saltando `TransCard.IdCli`, 3 tentativi; `ImpostaLivello` (Gold con promozione); anonimo Silver, `Nome` "Cliente - N", ticketless da `Setup(101).F10` (W02-09, W03-07) | `UPDLOCK,HOLDLOCK`, 3 tentativi, `ImpostaLivelloPromozione` uguale; **non salta** `TransCard.IdCli`; nome vuoto; ticketless di default 2 (`/api`, `/kiosk`) o 1 (redeem) | Simile, con tre differenze |
| 5.3 | **Anti-clonazione** | `ConfrontaCardConCliente` + `VerificaCard` (ultimo movimento verificato) → riallineamento o blacklist dalla terza/quarta lettura incoerente (`F1/T1/D1`, `CoinlessClonedCards`) (W04-04, W02-08) | stesso confronto e tetto di 5.000.000 (`cliente.bas:793-883`); niente `VerificaCard`/`FlagOpDaVerificare`; **niente blacklist**, solo log | Confronto uguale, **conseguenza diversa** |
| 5.4 | **Livelli e VIP** | quattro modelli `VipPromotionModel`; `PagaCanone` `NImp 18`; `raggiungeSogliaMinima` confronta valuta con centesimi (W04-23) | stessa eleggibilità, ma la soglia è convertita in valuta (`cliente.bas:885-916`, correzione voluta); promozione **automatica** a Platinum in `sync-card`; canone non implementato; `PromoteUser` dal cloud | Diversa (unità della soglia, applicazione automatica) |
| 5.5 | **Compleanni** | a fine evento la card torna Silver alla lettura in cassa (W03-23); ospite = cliente fittizio con livello 3 (W03-20) | stesso ritorno a Silver in `sync-card` (`cliente.bas:962-972`); redeem compleanno → riga `Ospiti` senza i passi di W03-20 (nessuna ricarica `NImp 13`: crediti come `NImp 0`); limiti di gioco applicati da `clsCompleanni` (WinMT li configura soltanto) | Ritorno uguale; creazione e contabilizzazione diverse; limiti complementari |
| 5.6 | **Distribuzione su più card** | `DistribuisciImporto`: Equa, Bilanciato, BonusTotale; i crediti veri vanno alle prime card; "extra bonus" per arrotondare al gettone (W03-24) | Equa e Bilanciato uguali; **BonusTotale cambiato il 2026-10-21**: crediti divisi in parti uguali, il bonus assorbe l'arrotondamento; ticket per card = `ceil(totale/n)` | Diversa per BonusTotale e ticket |
| 5.7 | **Consegna premio e consumo ticket** | `PremiAuto`: multi-sala con `sp_last_trans` che **blocca** se la card è stata usata da poco altrove; `sp_preleva_punti` che, se fallisce, annulla; FIFO `TogliPunti` (Golden con Silver prima); `Vincite`, `Riserva`, `Vincite25`, ricevute (W01-06) | `sp_last_trans` chiamata ma **esito ignorato**; errori di `sp_preleva_punti` ignorati; FIFO senza Golden; niente riserva, ricevute, abbuoni; transazione solo sul PrizeHub (E05-19); `/tickets` senza controllo saldo | Diversa (multi-sala più permissiva) |
| 5.8 | **Redeem QR** | `cls_RedeemManager`, SP con parametro OUTPUT (WinMT riscrive le SP all'avvio, winmt-00 § 4); ramo `recharge` vuoto (W04-19) | stesse SP nella versione "adattata B4X" a resultset (db-07 § 6.4); ramo `recharge` implementato; crediti come `NImp 0` | Stessa regola, **contratto SP incompatibile** |
| 5.9 | **Stacco ed eliminazione card** | `FrmRecoverCard`: toglie anche la blacklist, scollega dai compleanni, formatta la card; "elimina utente" solo con codice di autorizzazione (W03-11) | `sp_ripristinacard`/`sp_eliminacliente` senza autorizzazione (su `/api` neppure il token); `detach` accoda l'UID in `ReissueCardList` | Stesse SP, **controlli diversi** |
| 5.10 | **POS e contanti del totem** | `LogTransazioniPos.cls`, `LogTransazioniTotem.cls`, recupero Pending (W04-05, W04-06), scassettamento (`DataOraChiusura`) | porting del ciclo POS e dei log contanti; **scassettamento assente** (nessuna chiusura cassa del totem) [V assenza; conferma `docs/fonti/ecl2mqtt/legacy_vb6_log_eventi_bonus_analysis.md` § 0] | Complementari; chiusura cassa del totem mancante |
| 5.11 | **Ricarica card** | `AddTransCard`: bonus `NImp 6` a N0−1, crediti `NImp 0/1`, `Clienti.Credito` (W05-02) | porting fedele in `RicaricaCardTotem` (`NImp 1`), con idempotenza e transazione in più | Uguale, migliorata |
| 5.12 | **Movimenti card**, **ticket manuali**, **blocco card**, **foto premio**, **nuovo articolo** | W04-07, W05-01, W02-23, W06-05, W06-03 | E05-14/26/51, E05-50, E05-23, E05-36, E05-42 | Stessa funzione, riscritta |

**Dove vive oggi ogni regola:**
- *Solo nella form WinMT*: blacklist alla lettura, `VerificaCard`, canone VIP, abbuoni, `Vincite25`, scassettamento, ricevute.
- *Solo lato server B4J*: promozione VIP automatica, ripartizione ticket `ceil`, idempotenza della ricarica totem, logica degli slot PrizeHub (WinMT la usa via API), gru, sostituzione BI.
- *In entrambi, con regole diverse*: le righe 5.2–5.9 della tabella.

---

## 6. Problemi e rischi

**Sicurezza**
1. Token intercambiabili tra tutti gli handler tranne `/partner`; chiavi e segreto di firma nel codice; nessuna revoca (§ 3b) [V].
2. `/api/*` senza autenticazione permette `purge-card`, cioè la **cancellazione fisica** di cliente e storia, a chiunque raggiunga la porta [V `APIHandler.bas:59-159`].
3. Endpoint GET senza auth: immagini, `/tickets/action/list`, `/crane/action/list|detail|article`, `/app/action/getprizehubs`, `/eclservices/getkioskconfig|getscalettabonus` [V].
4. `cliente.ToMap`/`ToJson` includono `Password` e `Token`: escono da `/kiosk read-card`, `sync-card`, `redeem-confirm`, `/app SVCREADCARDDETAILS`, `SVCREFUND*` e dalle risposte V2 di `ElmacAPI` [V `cliente.bas:539-540`, `609-610`].
5. `ElmacAPI`:
   - `AuthUserByEMail` senza password restituisce il profilo se l'email è certificata [V `clsElmacAPI.bas:248-270`];
   - `SetUserPassword` V1 cambia la password senza la vecchia [V `:466-502`];
   - le risposte vanno su `ElmacAPIResponse/<metodo>`, un topic per metodo e non per sessione: ogni sottoscrittore le vede tutte [V `ecs2mqtt.b4j:925`];
   - non c'è autenticazione del chiamante oltre all'accesso al broker [V].
6. Nei log finiscono corpi delle richieste (con PIN redeem e password) e token [V `AppTicketsHandler.bas:337`, `APIHandler.bas:67`, `CraneHandler.bas:140`, `TicketsHandler.bas:57`, `AppServiceHandler.bas:217-218`].
7. Identità dell'operatore presa dal client (`oper`) per rimborsi, ticket, gru e audit [V].
8. La documentazione riporta in chiaro una chiave API (`docs/fonti/ecl2mqtt/api_prizehub.md:36-37`) [V].

**Consistenza e transazioni**
9. Prelievi su `/app`, `/tickets` e `/partner` non transazionali; `toglipunti` è riprendibile (`Wait For`) e non viene atteso; valore di ritorno di `prelevaPremio`/`prelevaSoloPunti` non dichiarato (§ 2, E05-22) [V/D].
10. `/tickets GET`: controllo del saldo commentato, quindi saldo negativo possibile [V `TicketsHandler.bas:293-297`].
11. `redeem-confirm` non atomico: possibile doppio riscatto dopo 5 minuti se la conferma fallisce [V/D].
12. Il totem dichiara il saldo finale e il bonus crediti, e il server li registra senza confrontarli con il DB né con la scaletta [V `DBcoinless.bas:3667-3681`].
13. `addCreditiToUser` usa `MAX(N0)+1` in sub-select, fuori transazione e su tre statement [V `DBcoinless.bas:3565-3666`]. Con il totem che deriva N0 dalla card, i due canali possono collidere sul progressivo [D].
14. `create-user` non salta gli `IdContatto` presenti in `TransCard`: un nuovo cliente può ereditare movimenti orfani [D].
15. Doppio accredito tra canali: se il totem non chiude una sequenza contanti, la riga resta `Pending` con `TCC` vuoto e il recupero di WinMT (W04-06) riscrive card e `TransCard` anche se `recharge-card` è già stato applicato [D].
16. Contratti delle SP `sp_redeem_*` incompatibili tra WinMT (OUTPUT, riscritte all'avvio) e B4J (resultset): un avvio di WinMT può rompere il redeem del totem [D, db-07 § 6.4; winmt-00 § 4].
17. Bonus a crediti dal cloud, dal redeem e da `create-user` contabilizzati come incasso di cassa fissa (`NImp 0`, `ValoreCassa` valorizzato), con effetto probabile sui rapporti di cassa [D].

**Concorrenza**
18. `Main.myWinMtConfig.nomemacchina` riscritto per richiesta (§ 4d) [V].
19. Throttle PrizeHub in memoria: dopo un riavvio, o con due server (primario e secondario), non è condiviso [D].

**Codice morto e rotto**
20. Codice morto: `clsGestioneCliente`, `GestioneEtickets`, `serviceHandler` (stub), `SVCAVAILABLEREFUNDTRAN`, `HandleSvcPhSetPrize`, `clsGestioneMacchine`, `MacchineHandler` [V].
21. `getRedeemV2` non funziona: stringa di chiamata malformata (`? ?`), date passate come FLOAT, nessuna risposta [V `DBcoinless.bas:5051-5070`].
22. `APIHandler`: legge solo i primi 1024 byte del corpo; un'azione non riconosciuta, o riconosciuta per sottostringa, può chiudere la richiesta senza risposta; nessuna risposta d'errore nel `Catch` [V `APIHandler.bas:74-157`].

**Documentazione di Fabrizio superata o incompleta** (verificata sul codice):

| Documento | Punto | Stato reale |
|---|---|---|
| `api_index.md` § 1 | `/partner` con `calcolaTokenApp` | usa `calcolaTokenPartner` e filtra `userId` [V] |
| `api_index.md` § 2 | "tre famiglie di token non intercambiabili" | intercambiabili (§ 3b) [V] |
| `api_index.md` § 3.2 | `POST /kiosk/action/readcard`, risposta `ToJson` | l'azione è `read-card`, la risposta `ToMap` [V `FlutterKioskHandler.bas:160`, `251`] |
| `api_index.md` | manca `card-history`; manca `detached` in `validate-card` | presenti nel codice (documentati solo in `ECL_KIOSK_API_MANCANTI_rev009.md`) |
| `api_index.md`, `api_app_tickets_handler.md`, `specifica_flutter_prizehub.md` § 7.1, `analisi_tickets_handlers.md` | login `GET …/action/login/{pubKey}` | il path richiede `/login/key/{pubKey}`; senza `key` risponde 400 [V `AppTicketsHandler.bas:132-151`] |
| `api_app_tickets_handler.md` | "hash calcolato sul JSON della risposta" | firma solo l'ora [V `sicurezza.bas:23-40`] |
| `api_app_tickets_handler.md` | `SVCAVAILABLEREFUNDTRAN` documentato | non instradato, 405 [V] |
| `api_app_tickets_handler.md` | `SVCBISWAPWRITE` invia `SetCnt` | riprogrammazione completa con `programmaDevice` [V] |
| `specifica_flutter_prizehub.md` § 8 | nonce anti-replay; HMAC su ogni risposta | non verificati da nessuno; HMAC sul solo timestamp |
| `legacy_vb6_log_eventi_bonus_analysis.md` § 0 | `ECL_BonusHandler` mai usato per accreditare; `ClassPromozioni` senza ripristino | ora accredita i ticket (`FlutterKioskHandler.bas:1269-1279`) e il ripristino esiste (`cliente.bas:939-960`) |
| `legacy_vb6_cliente_analysis.md` § 4 | `leggiClienteByemail` inesistente | esiste (`DBwinmt.bas:7492`) |
| `ECL_KIOSK_API_MANCANTI_rev009.md` § 3 M4 | manca `redeem-create` | ancora mancante [V] |
| `ECL_KIOSK_API_MANCANTI_rev009.md` § 4 | `getscalettabonus` ignora `kioskId` | confermato [V `scalettaBonus.bas:96`] |
| `ECL_KIOSK_API_MANCANTI_rev009.md` § 4 | ricarica di solo bonus dà card "clonata" | corretto nel codice [V `DBcoinless.bas:3748-3760`] |
| `evento_gold.md` | il livello forzato in `redeem-check` | avviene in `redeem-confirm` [V `FlutterKioskHandler.bas:1438`] |
| `api_index.md` § 1 | `/api` "Bearer letto ma non verificato" | confermato [V] |
| Endpoint presenti nel codice e non documentati | `ElmacAPI` metodi V2 (`RefreshUserTokenV2`, `getOperazioni/Partite/MovimentiCardV2`, `getRedeemV2`), `/eclservices/getscalettabonus` (solo citato) | — |

---

## 7. Domande aperte per il team

1. Chi chiama `/api/*` oggi? Si può chiudere o almeno autenticare?
2. Chi consuma il gruppo PLAYER di `/app` (`READCARD`, `LIST`, `GET`, `LOCKCARD`)? Un'app del giocatore, l'app di servizio, il vecchio PrizeHub?
3. Il cloud Elmac (backend dell'app player) come raggiunge il broker main della sala: bridge MQTT? Con quali credenziali e ACL sui topic `ElmacAPI*`?
4. `sync-card` con card sospetta clonata: si vuole la blacklist come in WinMT (terza/quarta lettura) o il solo log è voluto?
5. Bonus crediti della ricarica totem: deve deciderlo il server dalla scaletta? Oggi è del client.
6. Crediti da cloud, redeem e `create-user`: quale `NImp` (13, 14?) e quale `ValoreCassa`? Oggi sono "cassa fissa".
7. Multi-sala: il blocco "card usata da poco in un altro locale" di WinMT (esito di `sp_last_trans`) va applicato anche alle API? Oggi l'esito è ignorato.
8. `BonusTotale` e ripartizione `ceil` dei ticket: la regola nuova del totem sostituisce quella di WinMT `frmCardFamily` o le due devono convivere?
9. Chiusura cassa (scassettamento) del totem nuovo: dove e da chi?
10. Il totem attuale, che scrive direttamente nel DB, convive con il nuovo? Per quanto tempo? Come si evitano i doppi recuperi `LogTransazioniTotem`?
11. `sp_redeem_*`: quale versione è in produzione in ogni sala? WinMT le riscrive all'avvio sopra quella B4X?
12. `Clienti.N0 = 2` creato da `create-user`: è voluto? Che significato ha per il firmware?
13. Il limite rimborsi per operatore (`MaxRefundsPerDay`) funziona in produzione? Il codice suggerisce di no.
14. `Clienti.UserName` come token dell'app: confermare che il cloud non lo usa anche come nome utente.
15. Le password dei clienti in chiaro, in `Clienti` e nelle risposte API: va deciso da subito un trattamento diverso per il nuovo modello dati.
