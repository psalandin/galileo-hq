# Galileo HQ — ecl2mqtt 03: accesso al DB di WinMT, parte 2 (`DBwinmt.bas` righe 7717–15954)

**Stato:** bozza · **Responsabile:** Piero · **Aggiornato:** 2026-10-25

**Collegati:** [`ecl2mqtt-00-mappa.md`](ecl2mqtt-00-mappa.md) (mappa e sintesi trasversale). Nel testo, «zona NN» indica il documento ecl2mqtt NN.

Legenda: **V** verificato nel codice B4J (o nel VB6 di WinMT quando indicato), **D** dedotto. Tutti i path sono relativi a `legacy/ecl2mqtt/` salvo indicazione. Il confronto con WinMT usa `docs/winmt/*`, `docs/db/db-07`, `db-08` e, dove serviva, il sorgente VB6 in `legacy/WinMTsql/`.

---

## 1. Moduli coperti

| Modulo | Righe | Ruolo |
|---|---|---|
| `DBwinmt.bas` | 7717–15954 (≈125 Sub) | Strato di accesso al DB di sala `WinMtSqlDB` (pool `pool`) e, per il multisala e la replica, al DB cloud (pool `cloudpool`): clienti e card, saldi ticket, prelievo premi, PrizeHub, redeem, compleanni, log pagamenti totem/POS, macchine (test mode, swap BI, config I/O), BEConfig, setup. |

Per i chiamanti ho cercato `DBwinmt.<Sub>` in tutti i `.bas`/`.b4j` (esclusa `Objects/`). **Codice senza chiamanti** (V, ricerca su tutto il progetto, `www` compreso): `CursorToLog`, `ClassificaMangiaT`, `aggiornaAbilitazioneCliente`, `getAllPrizes`, `ReadArticleIcon`, `getAttributoMacchina`, `UnSetMacchinaRiprogrammabile`, `CBOelencoMacchineOffline`, `getIdcontattoByCardIdOrCodbar`, `aggiornaCliente`, `getCodmacFromDevice`, `decrementaQtaSlotHub`, `ListHasSlot`, `AddSlotToList`, `RemoveSlotFromList`, `NullIfEmpty`.

---

## 2. Flussi

| Id | Flusso | Descrizione | Trigger/attore | Peso | Tabelle (R/W/D/DDL) | Evidenza | Equiv. WinMT | Rapporto |
|---|---|---|---|---|---|---|---|---|
| E03-01 | Lettura cliente per token app | Cerca il cliente per `Clienti.UserName` (token UUID) e calcola crediti, bonus, ultimo saldo e progressivo da `TransCard`; default del JSON `Foto` | App clienti via cloud (MQTT `ElmacAPI/<id>` → `clsElmacAPI`) | M | Clienti R, TransCard R | `DBwinmt.bas:7717-7860`; `clsElmacAPI.bas:309,445,900,935` | W02-07 | **doppione** (formula diversa) |
| E03-02 | Attributi estesi cliente | Riscrive `Clienti.Foto` (JSON in varbinary): consensi, riemissione card con OTP, rimborsi giornalieri, scadenza VIP | Totem/app (`clsGestioneCliente*`) | S | Clienti W | `:7728-7748`; `clsGestioneCliente.bas:207-222` | W03-03, W04-23, W04-24 | **doppione** |
| E03-03 | Creazione cliente da app | Verifica email univoca, inserisce il cliente con `IdContatto`=MAX+1, `IdLong`, token e PIN; prenota/finalizza il CodBar con SP | App via cloud (`clsElmacAPI.CreateUser/V2`), `cliente.bas` | M | Clienti R/W; UID_Ammessi, uid_reservations via SP | `:11691-11837`, `:12578-12624`, `:15546-15617`; `clsElmacAPI.bas:540-594` | W02-09, W03-01, W03-26 | **doppione** (regole diverse) |
| E03-04 | Creazione cliente anonimo per card | Crea un cliente vuoto per una card ammessa, in transazione con UPDLOCK+HOLDLOCK e 3 tentativi | Totem (`APIHandler` create-user, `FlutterKioskHandler` redeem) | M | Clienti R/W | `:11860-11925`; `APIHandler.bas:278,310`; `FlutterKioskHandler.bas:1440` | W02-09, W03-07, W03-27 | **doppione** |
| E03-05 | Modifica anagrafica, email, livello da app | UPDATE anagrafica (codice morto), cambio email con verifica unicità e azzeramento certificazione, cambio `TipoCard` | App via cloud (`clsElmacAPI`) | S | Clienti R/W | `:12374-12577`; `clsElmacAPI.bas:657,725,750` | W02-10, W03-03 | **doppione** parziale |
| E03-06 | Livello card: promozione stagionale, VIP, fine compleanno | Promozione attiva → Gold e memoria del livello in `promozioni_cards`; ripristino a promozione scaduta (in transazione); VIP automatica a Platinum per incassi del periodo; Birthday scaduto → Silver | Totem sync-card (`cliente.bas`), `APIHandler`, `FlutterKioskHandler`, Dashboard | M | promozioni R, promozioni_cards R/W/D, Clienti W, TransCard R, Ospiti/Compleanni R | `:11134-11301`, `:11928-12065`; `cliente.bas:890-975` | W03-18, W03-23, W04-23 | **doppione** |
| E03-07 | Prelievo premio/punti (app giocatore, partner, PrizeHub vecchio) | Controllo multisala (`sp_last_trans`), prelievo dagli altri locali (`sp_preleva_punti`), consumo FIFO dei lotti `Tickets`, sovrascrittura di `Clienti.Tickets`, riga `Vincite`, scarico `Premi.Quantita`/`QDisN` | App giocatore `/app` (`AppPlayerHandler`), `/partner` (`PartnerHandler`), `/tickets` (`TicketsHandler`) | L | Tickets R/W, Clienti W, Vincite W, Premi W, Operatori R; cloud: sp_last_trans, rdclienti.sp_preleva_punti | `:7862-8235`, `:8406-8478`, `:8524-8573`, `:8598-8637` | W01-06, W02-14, W02-15 | **doppione** (regole diverse) |
| E03-08 | Calcolo del saldo ticket | Tre formule: somma con `aux=0` e `NonCont=0`; somma in altro locale con `aux=0`; ricalcolo di `Clienti.Tickets` senza filtri | App giocatore, Flutter hub, partner, `/tickets`, app servizio, `clsElmacAPI` | M | Tickets R, Clienti W; cloud: `<db>.dbo.Tickets` R | `:8286-8403` | W02-16 | **doppione** (formule diverse) |
| E03-09 | Accredito ticket da app e rimborso ticket da app di servizio | Inserisce un lotto `Tickets` al cliente (`MangiaT` 1 o 4, `NImp`=0, `Id`=IdPost, numero di serie `CalcSerNum`); il rimborso marca `F1`=1, `T1`=codice macchina | App via cloud (`AddPointToUser`), app di servizio (`SVCREFUNDTCK`) | M | Tickets W | `:8648-8803`; `clsElmacAPI.bas:1205,1247`; `AppServiceHandler.bas:273` | W02-12, W02-17, W05-09 | **doppione** (numero di serie identico) e scrittore esterno di W05 |
| E03-10 | Catalogo premi per app e PrizeHub vecchio | Elenco premi ≤ saldo con fasce NTILE(10), lista distributore `PDisN/QDisN`, immagini | App giocatore, `/tickets`, `/app`, Flutter hub | S | Premi R | `:8864-9180` | W06-01, W06-31 | **complementare** |
| E03-11 | Login e riconoscimento operatore | Login per card o per cognome+password; mappa operatore con limiti JSON; conteggio rimborsi `NImp`=8 nelle ultime 12 ore | `eclservice` (login), app di servizio (`SVCOPERATOR`, rimborsi), `clsGestioneCliente*` | M | Operatori R, TransCard R | `:8007-8172`, `:8805-8862`, `:15503-15530`; `AppServiceHandler.bas:103,731-760`; `eclservice.bas:358` | W10-06, W10-07, W10-08 | **doppione** (regole diverse) |
| E03-12 | PrizeHub: elenco hub, premi e slot | Hub da `setup2` (`PrizeHub%`), premi per hub (CAPSULE/LOCKER aggregati, SPINDLE per slot su articolo fittizio), slot con fasce NTILE(3), dettaglio articolo | App Flutter PrizeHub `/hub`, app operatore `/app` (SVCPH*) | M | setup2 R, PrizeHubSlots R, Premi R | `:13744-13852`, `:14199-14263`, `:14468-14620`, `:15334-15421` | W07-10 | **doppione** in lettura |
| E03-13 | PrizeHub: riscatto premio da slot | CAPSULE/LOCKER e SPINDLE: decremento slot con UPDLOCK, storno FIFO dei ticket, saldo cliente e `Vincite` **in un'unica transazione**; multisala dopo il commit | Cliente da app/totem Flutter (`/hub`) | L | PrizeHubSlots W, Tickets W, Clienti W, Vincite W, Premi R; cloud sp_last_trans/sp_preleva_punti | `:14703-15021`; `FlutterTicketsHandler.bas:285,297` | — (regole di W01-06/W02-14) | **solo B4J** (regole doppie) |
| E03-14 | PrizeHub: carico slot | Normalizza il codice (Codice/CodOr), vincoli per tipo (LOCKER 1 pezzo, CAPSULE stesso articolo, SPINDLE media ±100 ticket), scarico `Premi.Quantita`, `MovOut` 'PRIZEHUB', ricalcolo `ticketsMedi` e articolo fittizio `SPINDLE<hub>_<unit>-<slot>` | `SVCPHLOADSLOT`: WinMT `frmEditPrizeHub` e app operatore | L | PrizeHubSlots R/W/D, Premi R/W (MERGE), MovOut W | `:15026-15271`; `AppPrizeHubHandler.bas:222` | W07-08 | **complementare** (WinMT client, B4J server) |
| E03-15 | PrizeHub: sostituzione, rimozione, immagine | Sostituisce o rimuove l'articolo di uno slot con rientro a magazzino; aggiorna la foto del premio e dei fittizi SPINDLE | App operatore (`SVCPHREPLACEPRIZE`, `SVCPHREPLACEIMAGE`) | L | PrizeHubSlots W/D, Premi W, MovOut W, MovMag W | `:13860-14196`; `AppPrizeHubHandler.bas:84,111,138` | W06-05 (foto) | **solo B4J** |
| E03-16 | PrizeHub: ticket medi forzati | Forza o ripristina `ticketsMedi` e il `N_Tickets` del fittizio | `SVCPHSETTICKETSMEDI`, `SVCPHRESET_TICKETSMEDI` (WinMT e app) | S | PrizeHubSlots W, Premi W | `:15275-15328` | W07-09 | **complementare** |
| E03-17 | PrizeHub: trasferimento a magazzino virtuale | Porting di `PrizeHub_MoveToSlot`: articolo virtuale in `Premi`, `MovOut`/`MovMag` 'PRIZEHUB', `PDis1/QDis1` | `SVCPHMOVETOWHAREHOUSE` | M | Premi R/W, MovOut W, MovMag W | `:14265-14350`; `AppPrizeHubHandler.bas:85,88` | (SP `PrizeHub_MoveToSlot`) | **doppione** della SP, con difetti |
| E03-18 | Redeem code al totem | Formato `RD`+13, prenotazione 5 minuti, PIN, rilettura dei valori dal DB, consumo o rilascio; aggancio dell'ospite al compleanno | Totem Flutter `/kiosk` | L | RedeemCodes R/W (via SP), Compleanni R, Ospiti W | `:12084-12372`; `FlutterKioskHandler.bas:1295-1490` | W04-19, W03-22 | **doppione** |
| E03-19 | Compleanni: partite e limiti degli ospiti | Stato dell'evento per card, contatori di partita per ospite e macchina (MERGE), ticket della partita da `CoinlessDataBuffer`, ospiti attivi | Partita a macchina (MQTT `send_client`/`comdevice` → `clsCompleanni`), timer `controlloMacchine` | M | Ospiti R, Compleanni R, PartiteOspiti R/W, CoinlessDataBuffer R, Clienti R | `:11069-11123`, `:11303-11548`; `clsCompleanni.bas:33-111` | W03-19 (legge) | **complementare** (B4J scrive `PartiteOspiti`) |
| E03-20 | Log contanti totem | Una riga per moneta/banconota `Pending` con UUID di sequenza in `AC`; chiusura in blocco `Completed`/`Error` | Totem Flutter `/kiosk` | M | LogTransazioniTotem W | `:13252-13347`; `FlutterKioskHandler.bas:854,893` | W04-06 | **complementare** (WinMT recupera i `Pending`) |
| E03-21 | Log POS totem | Riga `Pending`, esito, progressivo card, stato con `DataAck` | Totem Flutter `/kiosk` | M | LogTransazioniPos W | `:13366-13557`; `FlutterKioskHandler.bas:952-1071` | W04-20, W04-05 | **doppione** (scrittura) + complementare (recupero) |
| E03-22 | Elenchi e stato macchine | Combo macchine per stato, stato sala, modelli in uso, ultime letture `EcsDati`, contatori dell'ultimo minuto, MAC del modulo | Backoffice web (websocket), app di servizio, `eclcommand` | S | EcsMacchine R, EcsModuli R, EcsDati R, BEConfig R, vs_CoinlessSpecialTimes R, fn_dati_grafico_giornaliero, TransCard R | `:9276-10041`, `:10652-10683`, `:12657-12768`, `:13078-13202`, `:15833-15862` | W08-20 | **complementare** |
| E03-23 | Prezzo partita per livello | Prezzo per Birthday/Silver/Gold/Platinum, con happy hour da `vs_CoinlessSpecialTimes` | Partita a macchina (MQTT → `clsGestioneCliente*.CanPlay`), `GestioneEtickets` | M | EcsMacchine R, vs_CoinlessSpecialTimes R | `:11621-11677` | W04-17, W08-12 | **complementare** (WinMT configura, B4J applica) |
| E03-24 | Fuori servizio macchina | `device_status` = 'OOO'/'Online' per codmac o device | `Main.OutOfService` (MQTT/`eclcommand`), app di servizio | S | EcsMacchine W, EcsModuli R | `:12891-13019`; `ecs2mqtt.b4j:4622,4632` | W08-07 (`jOutOfService`) | **complementare** |
| E03-25 | Moduli riprogrammabili | Flag `EcsModuli.NImp` = 1/0/NULL ("sono consapevole di poter fare danni"); elenchi programmabili e forzabili | Backoffice web (`MacchineConfigurate`, `MacchineInsetup`) | S | EcsModuli R/W, EcsMacchine R | `:9418-9659` | W08-07 | **solo B4J** |
| E03-26 | Test mode macchina | Baseline `EcsDati` salvata in `setup2`, calcolo degli incrementi valorizzati, chiusura con ripristino dei contatori, `NoRec`, pending e reboot della BE; pulizia a timeout | Backoffice web (`TestModeMacchina`, Dashboard), timer 5 min | L | setup2 R/W/D, EcsDati R/D, EcsMacchine R/W, ecl_log W (via DBcoinless) | `:10093-10387`; `ecs2mqtt.b4j:702-706` | — | **solo B4J** |
| E03-27 | Stato BI e sostituzione scheda BI | JSON di stato in `EcsMacchine.T0`: piatto, stato ed errore BI, `BISwap`, `BISwapStep` (0–4), `NoRec` | MQTT `ElmacStatusBI` (`mqttMessages`), `biprogrammer`, web, app di servizio (SVCBISWAP*) | L | EcsMacchine R/W, ecl_SchedeFirmware R, EcsModuli R | `:10389-10644`, `:10797-10901` | — | **solo B4J** |
| E03-28 | Config I/O, economici, nuova macchina da config cloud | Legge/scrive ValIn/TipoIn/InCnt/CntrVal 1–16; crea `EcsMacchine` da una riga cloud con `Modu`/`device` calcolati e prima lettura `EcsDati`; aggiorna i costi per livello | Backoffice web (`InstallazioneNuovaMacchina`, `MacchineInsetup`, `MacchineConfigurate`), `DBcoinless` | L | EcsMacchine R/W, EcsDati W | `:10685-10795`, `:15675-15954` | W08-03, W08-05, W08-06, W08-12 | **doppione** (regole diverse) |
| E03-29 | Partita in tempo reale sui contatori | Copia l'ultima `EcsDati` della macchina con `In9`+1 | MQTT `send_client`/`comdevice` quando `ApplicationMode` ≠ ECL | S | EcsDati R/W, EcsMacchine R | `:12626-12654`; `ecs2mqtt.b4j:1566,1891` | W08-14 (trigger DB) | **doppione** (lato DB) |
| E03-30 | BEConfig | Crea/altera la tabella; legge e fa MERGE di `BeInfo`/`BeConfig`/`BiConfig` per MAC, `DetectionDate`; elenco BE accese oggi | Avvio (`TestConnectionToDB`), `DBcoinless` (info dalla BE), `eclcommand` | M | BEConfig DDL/R/W, EcsModuli R, EcsMacchine R | `:13559-13679`, `:9897-9956`; `DBwinmt.bas:126-138` | — | **solo B4J** |
| E03-31 | Versione dello schema | Deduce `dbversion` dalla presenza di colonne/tabelle; abilita funzioni (gru ≥ 20260424, TransCard ≥ 20240625) | Avvio | S | INFORMATION_SCHEMA R | `:12770-12888`; `ecs2mqtt.b4j:1679`; `DBcoinless.bas:233` | W04-25 | **doppione** (stessa rilevazione; B4J non crea oggetti, tranne BEConfig) |
| E03-32 | Replica tabelle tecniche sala↔cloud | INSERT…SELECT NOT EXISTS di `CoinlessImages` (schermate e firmware BI `.srec`), `ecl_firmware`, `CoinlessLanguages` | Backoffice web (Elenco firmware, Fw BI, Schermate, Lingue, Sync config) | M | CoinlessImages, ecl_firmware, CoinlessLanguages R/W (DB locale e `CoinlessDB` cloud) | `:10904-11067` | — | **solo B4J** |
| E03-33 | Lettura configurazione di sala | `Setup` (101) in mappa, scaletta bonus `T10`/`T12`, DBSERVIZIO decodificato da `Setup(102).T7` | Avvio (`WINMtConfig`), app di servizio (`SVCGETSETUP`), MQTT `ricaricaCard`, `DBcoinless` | S | Setup R | `:9182-9271`, `:15425-15500` | W02-02, W10-01, W02-18 | **complementare** |
| E03-34 | Cassa mobile: ricariche dell'operatore | Elenco ricariche (`NImp` 2) e bonus (`NImp` 6) di `CASSA-MOBILE` dall'ultima chiusura (`NImp` 7) | `eclservice` | S | TransCard R, Clienti R, Operatori R | `:13021-13076` | W04-12, W04-13 | **complementare** (stesse convenzioni) |
| E03-35 | Audit log | INSERT in `AuditLog` (Access, DeviceStatus, CardRecovery, CardGeneration…) | `auditlog.bas` (vari) | S | AuditLog W | `:13204-13228`; `auditlog.bas:16-33` | — (WinMT non scrive) | **solo B4J** |
| E03-36 | Manutenzione e storia della card | Ripara `CodBar` vuoti da `UID_Ammessi` (primi 8 caratteri), legge dal testo di `CoinlessLogEventiBlacklist` la storia delle sostituzioni, data dell'ultima operazione | `clsElmacAPI` (login email, sostituzione card), `cliente.bas`, app di servizio | S | Clienti R/W, UID_Ammessi R, CoinlessLogEventiBlacklist R, TransCard R | `:13686-13741`, `:15634-15673`, `:11578-11619` | W02-11, W04-24 | **doppione** (CodBar) e complementare (log) |

### Dettaglio dei flussi L e dei doppioni

**E03-01 (saldi per token).** Crediti = Σ `NImp` (0, 1, 2, 11, 13, 14) − Σ `NImp` (NULL, 10); bonus = Σ `NImp` (6, 8, 9, 16) − `ValoreBonus` delle partite − `NImp` 15 [V `:7792-7794`]. WinMT, invece [V `winmt-04` § 4.3]:
- conta i crediti solo con `WinMt = 1`;
- sottrae anche `NImp` 18 (canone VIP).

B4J non fa né l'una né l'altra cosa: **per i clienti che hanno pagato il canone VIP, i crediti mostrati all'app sono più alti** [D]. Nel ramo "gamepark" i crediti sono l'ultimo `ValoreFinale` e il bonus è 0 [V `:7803-7825`].

**E03-03 (creazione da app) contro W02-09.**
- B4J calcola `IdContatto` = MAX+1 **senza lock e senza saltare i valori già presenti in `TransCard.IdCli`**, che WinMT salta [V `:11776`, `:11790`]. Il CodBar restituito è riletto con un altro MAX: con creazioni concorrenti si può restituire il cliente sbagliato [D].
- `TipoCard` è fisso a 2, Silver [V `:11793`]: **la promozione attiva non si applica**, mentre WinMT passa sempre da `ImpostaLivello` [V `winmt-03` W03-18].
- `UserName` = `NEWID()` (token), `Password` = PIN di 6 cifre generato in SQL, `N0` = 1 (ticketless), `Foto` = JSON di default [V `:11797`, `:11805-11807`].
- L'input JSON subisce `Replace("'", "''")` prima del parse, ma i valori vanno poi in parametri: **gli apostrofi nei nomi vengono salvati raddoppiati** [V `:11694`, `:11812`].
- Unicità controllata sull'email, non sul cellulare (codice commentato) [V `:11719-11732`].

**E03-04 (anonimo) contro W02-09.** Stessa idea della transazione `SERIALIZABLE` di WinMT, ma con lock sulla sola SELECT del candidato [V `:11889`]. Anche qui non si saltano gli id presenti in `TransCard.IdCli`. Il livello (promozione) lo applica il chiamante [V `FlutterKioskHandler.bas:1437-1440`].

**E03-06 (livelli).**
- Ripristino a promozione scaduta: stessa regola di WinMT, `ISNULL(scadenzaPromozione, alla_data) < GETDATE()`, livello NULL letto come 2 [V `:11991-11997`]. B4J lo fa in transazione [V `:12041-12051`], WinMT no.
- Card Birthday a evento scaduto → Silver, come W03-23. Nessuno dei due scollega la card da `Ospiti` [V `cliente.bas:960-975`].
- VIP: stessa lista `NImp` (0, 1, 2, 13, 14) di WinMT [V `:11240-11242`]. B4J scrive davvero il livello Platinum, mentre `updateCardLevel` di WinMT ignora il parametro [V `winmt-04` W04-23].
- La promozione "futura forzata dalla form" di WinMT non esiste in B4J [V].

**E03-07 (prelievo premio).** Rispetto a `TogliPunti` di WinMT [V `legacy/WinMTsql/Module6.bas:1877-1910`]:
- **filtra `isnull(NonCont,0)=0`**: un lotto `NonCont = 1` (resto, totale, acquisito da altra card, bonus della ricarica) **non è spendibile** in B4J ma lo è in WinMT [V `:8537`];
- scrive sempre `OperOut = 0`: il parametro `operout` è ignorato [V `:8545`];
- sul lotto consumato in parte non scrive `DataOut`/`OperOut` [V `:8548`].

Altre differenze:
- `Vincite`: **una riga sola** con `N_Tickets` = totale, qualunque sia `quantita` [V `:7991`, `:8598-8622`]; WinMT scrive una riga per pezzo con il prezzo unitario [V `winmt-01` W01-06].
- `Vincite.Id` è l'operatore configurato del servizio (`myWinMtConfig.IdOperatore`), non quello della card [V `:7920`, `:7991`]. `N0` (punti Gold) non è scritto.
- `Clienti.Tickets` viene sovrascritto con il valore in memoria meno i richiesti [V `:7915`, `:8463-8465`].
- Nessuna transazione tra lotti, vincita e giacenza.
- `toglipunti` contiene un `Wait For`: il chiamante prosegue senza aspettare la fine del batch [V `:8556-8557`; effetto D].
- Multisala: `sp_last_trans` è chiamata ma **il risultato non viene usato** (WinMT blocca se la card è stata usata di recente altrove) [V `:7885-7898`]. `sp_preleva_punti` riceve l'intero importo richiesto [V `:8429`]. `prelevapuntidaaltrolocale` cambia `DateTime.DateFormat` **globale** in `"dd/mm/yyyy hh:mm:ss"` (`mm` = minuti) e ha il DB `rdclienti` scritto nel codice [V `:8422-8424`].
- **Esiti verso il chiamante:**
  - `prelevaPremioDaprizeHub` è `As Boolean` ma non ha `Return True` [V `:7862-7924`];
  - `prelevaPremio` e `prelevaSoloPunti` non dichiarano un tipo di ritorno [V `:7926`, `:8173`];
  - i chiamanti fanno `If ok = False → 500` [V `AppPlayerHandler.bas:186-192`, `TicketsHandler.bas:309-317`, `PartnerHandler.bas:229`]: **ipotesi D, l'app riceve errore anche quando punti e premio sono già stati scalati**, con rischio di ripetizione.
- `prelevaSoloPunti` con card operatore legge la chiave `"Id"`, che la mappa non ha (usa `"UserID"`) [V `:8226`, `:8043`].

**E03-08 (saldo).** Il saldo ticket ha tre formule nel solo B4J:
- `ticketstocliente` non filtra `aux` né `NonCont` [V `:8298-8304`];
- `ricalcolaTickets` filtra `aux = 0` e `NonCont = 0` [V `:8339`];
- `ricalcolaTicketsInAltroLocale` e `HubStornaTicketInTransazione` filtrano solo `aux = 0` [V `:8379`, `:14708`].

WinMT (W02-16) usa Σ(`NumTickets` − `TPagati`) dei lotti non ausiliari [V `winmt-02`].

**E03-09 (accredito ticket).** `CalcSerNum` è il porting esatto di WinMT: ultima cifra dell'anno + `00000001` + secondi dall'1/1 [V `:8771-8803`; `winmt-02` W02-12]. Ne eredita i limiti: unico solo al secondo, si ripete ogni 10 anni.
- `aggiungiScontrino`: `MangiaT` = 1, cioè "contato da mangia-ticket", per ticket accreditati dall'app; `NImp` = 0; `Id` = IdPost; `DataOut` NULL invece di `1899-12-30` [V `:8677-8689`].
- `aggiungiScontrinoDaAppDiServizio`: `MangiaT` = 4 (manuale), `F1` = 1, `T1` = codice macchina [V `:8740-8750`]. **È uno degli scrittori "esterni" cercati da WinMT 05** (§ 6.1). `T1` qui è il codice macchina passato dall'app, non necessariamente `device`.
- Il chiamante del rimborso passa `IdContatto`, non `IDCli`: **in multisala il lotto finisce sotto la chiave sbagliata** [V `AppServiceHandler.bas:260,273`; `cliente.bas:376-378`].

**E03-11 (operatori).**
- `loginUtente` costruisce l'SQL concatenando username, password e card (**SQL injection**) e confronta la password **in chiaro**, mentre WinMT la salva offuscata MTCry [V `:8826-8828`; `winmt-10` W10-06]. Effetto D: il login con password non riesce mai sulle password create da WinMT.
- Nessun filtro su `Attivo` né su `Id < 1000` [V `:8025`, `:8828`].
- `getOperatoreByCard` restituisce sempre `UserID` (−1 se l'operatore non c'è): il controllo `ContainsKey("UserID")` di `SVCOPERATOR` passa anche per le card non di operatori [V `:8029`; `AppServiceHandler.bas:103-106`].
- I campi scalari dei limiti sono letti con la chiave errata `MaxRefoundsPerDay` [V `:8068`]. Il chiamante usa invece `OPAttributes` [V `AppServiceHandler.bas:731-742`].
- **B4J applica il limite giornaliero dei rimborsi** (`NImp` 8 nelle ultime 12 ore; 999999 in caso di errore = blocco) [V `:15512-15528`]. WinMT lo configura ma non lo applica [V `db-08`, `Operatori.Foto`].

**E03-13 (riscatto da PrizeHub).** È l'unico prelievo premi transazionale del sistema: slot, lotti `Tickets`, `Clienti.Tickets` e `Vincite` sulla stessa connessione [V `:14785-14833`]. Il multisala gira dopo il commit, senza compensazione se fallisce [V `:14848-14878`].
- **Non tocca `Premi.Quantita`**: la giacenza è già scaricata al carico dello slot (E03-14).
- Il premio SPINDLE è registrato in `Vincite` sul **codice fittizio** `SPINDLE<hub>_<unit>-<slot>` (Costo 0, Fornitore ELMAC), non sull'articolo reale [V `:14949-14969`, `:15252-15255`]. Effetto D:
  - l'inventario di WinMT, che conta i venduti dalle righe di `Vincite`, non vede l'uscita dell'articolo reale;
  - il costo del premio consegnato è 0.

**E03-14 / E03-15 (carico e sostituzione).**
- B4J è lo scrittore di `PrizeHubSlots` per conto di WinMT (W07-08, domanda aperta 3).
- `ticketsMedi` = Σ(`qtaDisp` × `N_Tickets`) / Σ `qtaDisp` sugli slot SPINDLE attivi della unit [V `:15165-15177`].
- `MovOut.Oper` = `TRY_CAST(operatore AS decimal)`, ma `operatore` è uno username: risulta NULL [V `:15209`; D].
- `ApiPrizehub_ReplacePrizeSlot` riporta a magazzino `qtyRemove` **senza scrivere `MovMag`** e usando la quantità richiesta, non quella effettiva [V `:13951-13955`]. `ApiPrizehub_RemovePrizeFromSlot` scrive `MovMag` e usa la quantità effettiva [V `:14174-14180`]: le due regole divergono.
- Con `newCode` = `oldCode` le quantità rimosse non rientrano in `Premi` [V `:13914-13920`, `:13944-13955`].

**E03-17 (magazzino virtuale) contro la SP `PrizeHub_MoveToSlot`.**
- Il codice destinazione è la **stringa letterale `"?_?_PH?"`** [V `:14275`]: tutti i trasferimenti finiscono in un unico articolo virtuale. La SP compone invece `<slot>_<tipo>_PH<hub>` [V `sql/codice-db/test/applicativo/procedure/PrizeHub_MoveToSlot.sql:34`].
- Cerca l'articolo per `CodOr` invece che per `Codice` [V `:14282`, `:14297`].
- Scrive sempre `PDis1`/`QDis1`, qualunque sia l'hub [V `:14341`].
- **Non chiude la connessione**, e `pool.GetConnection` è fuori da `Try` [V `:14266`, `:14345-14349`].

**E03-18 (redeem) contro W04-19.** Il flusso è lo stesso di `cls_RedeemManager`. Differenze:
- B4J implementa il ramo `recharge`, che in cassa WinMT è vuoto [V `FlutterKioskHandler.bas:1458-1474`];
- applica la promozione anche ai codici redeem [V `:1437`];
- rilegge i valori dal DB invece di fidarsi del totem [V `:12197-12241`];
- aggancia l'ospite senza la regola "il primo ospite diventa il festeggiato" di `addOspite` [V `:12355-12358`].

Se `ConfirmRedeemCode` fallisce dopo l'accredito, il codice resta solo prenotato e torna utilizzabile dopo 5 minuti: **doppio accredito possibile** [V commento `FlutterKioskHandler.bas:1487-1490`; D].

**E03-26 / E03-27 (test mode, swap BI).**
- La sessione di test vive in `setup2` (IdPost 101, `TestMode_<CodMac>`) [V `:10141`, `:10225`].
- La chiusura cancella le righe `EcsDati` successive alla baseline, mette `F0` = 1 e `NoRec` = 1 e manda il reboot via MQTT `ElmacECL/<device>` [V `:10314-10325`]. **Riscrive la storia dei contatori**: le letture del periodo di test spariscono, il log resta solo in `ecl_log` [V].
- Il timeout toglie solo lo stato e non ripristina i contatori [V `:10357-10386`].

**E03-28 (macchine) contro W08-03/05/06.**
- `creaMacchinaDaConfig` crea con `F0` = 0 [V `:15803`], WinMT con `F0` = 1 (pending).
- `Propr`/`PerDiv` = 100 di default [V `:15786-15788`]; `device` e `Modu` sono calcolati come nella duplicazione di WinMT (MAX, nessun lock) [V `:15801-15803`].
- `aggiornaConfigIO` riscrive solo ValIn/TipoIn/InCnt/CntrVal 1–16 e `CntrLet10`, non tutta la riga come `AggiornaMacc` [V `:10766-10776`].
- `aggiornaEconomici` non imposta `F0` = 1 [V `:15939-15941`]; WinMT lo fa per le macchine offline [V `winmt-08` W08-12].

---

## 3. Interlocutori

**(a) MQTT** (il modulo non sottoscrive; pubblica tramite `Main`)

| Topic | Dir. | Broker | Payload | Controparte | Evidenza |
|---|---|---|---|---|---|
| `ElmacECL/<device>` | out | main | comando ECL `reboot` (`ecl_cmds`) | scheda BE | `:10321-10325` |
| `ElmacAPI/<id>` → `ElmacAPIResponse/<id>` | in/out (trigger) | main | richiesta e risposta API dell'app clienti: creazione, saldo, email, livello, ticket | cloud Elmac / app | `ecs2mqtt.b4j:912-931` → E03-01/03/05/09/36 |
| `send_client`, `comdevice` | in (trigger) | main | partita con card | BE | `ecs2mqtt.b4j:1504-1566`, `1866-1891` → E03-19/23/29 |
| `ElmacStatusBI` | in (trigger) | main | stato BI | BE/BI | `mqttMessages.bas:770` → E03-27 |
| `ElmacECL/...` `ricaricaCard` | in (trigger) | main | ricarica da cassa mobile | app cassa mobile | `ecs2mqtt.b4j:1468-1480` → E03-33 |

**(b) HTTP/WebSocket** (consumatori delle Sub; gli endpoint sono di altre zone): `/hub/*` (Flutter PrizeHub), `/kiosk/*` (totem: redeem, log contanti/POS), `/api/*` (create-user), `/app/action/SVC*` (app di servizio e operatore PrizeHub, usata anche da WinMT `frmEditPrizeHub`), `/app/*` player, `/partner/*`, `/tickets/*` (PrizeHub vecchio), `/eclservices/*` (login, cassa mobile), `/eclcommand`, websocket del backoffice (`/ws/testmode`, `/ws/MacchineInstallate`, `/ws/InstallazioneNuovaMacchina`, `/ws/ElencoFirmware`…) [V `ecs2mqtt.b4j:473-540`].

**(c) Chiamate in uscita**

| Destinazione | Uso | Evidenza |
|---|---|---|
| SQL Server di sala `WinMtSqlDB` (`pool`) | tutte le Sub | `DBwinmt.bas:64` |
| SQL cloud (`cloudpool`): JDBC diretto a `winmt.elmaccloud.com:1433`, oppure server locale con linked server `[elmaccloud]` se `settings.Connected = 1` | `sp_last_trans` su `<DbClientiMultilocale>`, `rdclienti.dbo.sp_preleva_punti`, `<db>.dbo.Tickets` di un altro locale, replica `CoinlessDB` | `:7885`, `:8379`, `:8424`, `:10904-11067`; connessione in `DBwinmt.bas:192-219`, **credenziali nel codice** (`DBwinmt.bas:204`, `:214`) |
| DB `CoinlessDB` o `WinMtSqlDB` (`DBcoinless.coinlessServer`) con nome a tre parti | `CoinlessDataBuffer`, `split()`, sorgente/destinazione della replica | `:11507`, `:15801`, `:10922` |
| `ecl_log` (via `DBcoinless.ScriviLogSempre`) | audit del test mode | `:10312`, `:10385` |

---

## 4. Dati

### (a) Tabelle, viste e procedure

| Oggetto | Operazioni | Flussi |
|---|---|---|
| `Clienti` | R; I (`creaCliente`, `creaClienteAnonimo`); U (`Foto`, `Tickets`, `TipoCard`, anagrafica, email/`EMailIsCertified`, `CodBar`) | 01–07, 09, 36 |
| `Tickets` | R; I (lotti da app); U (`TPagati`, `OperOut`, `DataOut`) | 07–09, 13 |
| `TransCard` | R (saldi, VIP, rimborsi, cassa mobile, ultima operazione, contatori) | 01, 06, 11, 22, 34, 36 |
| `Vincite` | I | 07, 13 |
| `Premi` | R; U (`Quantita`, `QDisN`, `Foto`, `Icona`, `N_Tickets`); I/MERGE (fittizi SPINDLE, virtuale) | 07, 10, 12–17 |
| `PrizeHubSlots` | R/I/U/D | 12–16 |
| `MovOut`, `MovMag` | I (causale `PRIZEHUB`) | 14, 15, 17 |
| `Operatori` | R | 07, 11, 34 |
| `promozioni`, `promozioni_cards` | R; I/D | 06 |
| `Compleanni`, `Ospiti`, `PartiteOspiti`, `CoinlessDataBuffer` | R; I `Ospiti`; MERGE/U `PartiteOspiti` | 18, 19 |
| `RedeemCodes` | R (e U tramite SP) | 18 |
| `LogTransazioniTotem`, `LogTransazioniPos` | I/U con `OUTPUT … INTO @tabella`, per via dei trigger | 20, 21 |
| `AuditLog` | I | 35 |
| `Setup` (101, 102), `setup2` (101) | R; `setup2` R/W/D (test mode, hub) | 12, 26, 33 |
| `EcsMacchine`, `EcsModuli`, `EcsDati`, `ecl_SchedeFirmware`, `BEConfig` | R/U/I/D; `BEConfig` DDL | 22–30 |
| `UID_Ammessi`, `uid_reservations` (tramite SP), `CoinlessLogEventiBlacklist` | R/U | 03, 36 |
| `CoinlessImages`, `ecl_firmware`, `CoinlessLanguages` | R/I tra DB | 32 |
| Viste e funzioni: `vs_CoinlessSpecialTimes`, `fn_dati_grafico_giornaliero`, `fn_idcliente`, `CoinlessDB.dbo.split` | R | 19, 22, 23, 28 |

**Procedure chiamate e confronto con `sql/codice-db/`**

| Procedura | Chiamata | Test | Produzione | Nota |
|---|---|---|---|---|
| `sp_redeem_check_and_reserve_no_pin` | `EXEC` con 7 parametri, legge una riga [V `:12113`] | versione "B4X/JDBC", restituisce una riga | versione VB6 con `@ErrKey OUTPUT` obbligatorio, senza i valori del codice | **in produzione la chiamata va in errore** → `redeem_internal_error` [D] |
| `sp_redeem_verify_pin` | `EXEC` con 3 parametri [V `:12168`] | presente | **assente** (`db-07:109`) | redeem al totem non funzionante in produzione [D] |
| `sp_redeem_confirm`, `sp_redeem_cancel` | `EXEC`, riga di risultato [V `:12270`, `:12313`] | B4X | OUTPUT | come sopra |
| `GetFreeUidCodbar`, `FinalizeUidCodbar` | `CallProc` `{? = call …}` **con parametro OUTPUT** [V `:15562-15571`] | presenti | presenti (testo diverso fra i rami) | **contraddice la motivazione delle versioni "B4X" delle `sp_redeem_*`** ("B4X non gestisce gli OUTPUT"): il progetto li gestisce già |
| `sp_last_trans`, `sp_preleva_punti` | `CallProc` sul cloud [V `:7885`, `:8424`] | — | — | solo nel cloud (`winmt-00` § 7) |
| `PrizeHub_MoveToSlot` | non chiamata: riscritta in B4J con difetti (E03-17) | presente | assente | |

Nessuna chiamata a `sp_crane_*` né a `sp_consolida_*` in questa zona [V].

### (b) Colonne con significato nuovo o diverso da db-08

| Colonna | Uso in B4J | Rispetto a db-08 | Evidenza |
|---|---|---|---|
| `Clienti.UserName` | token UUID del cliente per l'app (`NEWID()` alla creazione, chiave di `GetClienteByToken`) | db-08: "non scritto da WinMT" → **nuovo significato** | `:7800`, `:11805` |
| `Clienti.Password` | PIN di 6 cifre generato con `CRYPT_GEN_RANDOM` (precedenza `&`/`%` errata: valori non uniformi) | db-08: password dell'App in chiaro da `ClientiAPP` → **origine diversa** | `:11806` |
| `Clienti.Foto` | chiave in più **`CardCreatedBy`** | non in db-08 | `:7718` |
| `Clienti.N0` | 1 per i clienti da app; `tless` per gli anonimi | coerente (1 = ticketless) | `:11797`, `:11906` |
| `Tickets.NonCont` | **escluso dal saldo spendibile** | db-08/W05: "escluso dai conteggi dei vinti", resta spendibile → **contraddice** | `:8339`, `:8537` |
| `Tickets.F1`/`T1` | `F1` = 1, `T1` = codice macchina sui ticket rimborsati dall'app di servizio (`MangiaT` 4) | db-08: ticketless dal gioco, `T1` = device → **altro scrittore, altro contenuto** | `:8735-8750` |
| `Tickets.MangiaT` = 1 | ticket accreditati dall'app | db-08: contati da mangia-ticket → **sovraccarico** | `:8680` |
| `Vincite.N_Tickets` | totale della richiesta, una riga per più pezzi | db-08/W01-06: prezzo per pezzo, una riga per pezzo → **contraddice** | `:7991`, `:14829` |
| `Vincite.Id` | operatore configurato del servizio | W02-15: operatore | `:7920` |
| `Vincite.Codice` | anche codice fittizio `SPINDLE<hub>_<unit>-<slot>` | non in db-08 | `:14949` |
| `Premi` fittizi `SPINDLE…` | `Attivo` = 0, `Costo` = 0, `N_Tickets` = media dello slot, `Foto` del premio esempio | db-08 cita solo `…_PH<n>` | `:15246-15256` |
| `Premi.QDis<N>`/`PDis<N>` | ancora scritte dal PrizeHub vecchio e da E03-17 | db-08: "superate, vuote" | `:8250`, `:14341` |
| `MovOut`/`MovMag` `NBolla`, `Note`, `Oper` | `HUB<n>_<slot>`, testo descrittivo, `Oper` NULL | non in db-08 | `:15206-15235` |
| `EcsMacchine.T0` | **JSON di stato BI** `{valorepiatto, statoBI, errBI, BISwap, NoRec, BISwapStep}` | db-08: "valore piatto \| 15 cifre", residuo → **contraddice** | `:10405-10489` |
| `EcsModuli.NImp` | flag "modulo riprogrammabile/forzabile" (1/0/NULL) | non in db-08 | `:9419-9448`, `:9611-9659` |
| `EcsModuli.ShortAd` | messa in join con `EcsMacchine.device` | db-08: IP EcsNet → **contraddice** [D] | `:9921` |
| `EcsMacchine.device_status` | anche `'OOO'` scritto e `'ooo'` letto (dipende dalla collation) | coerente | `:12911`, `:9802` |
| `LogTransazioniTotem.CAut` | `Pending`, `Completed`, **`Error`** | db-08/W04: `Pending`, `Completed`, `Recovered` → nuovo stato | `:13324` |
| `LogTransazioniTotem.AC` | UUID di sequenza **anche per le righe POS** | W04: solo contanti | `:13234-13236` |
| `LogTransazioniTotem.IdCli` | 0 se sconosciuto (in `LogTransazioniPos` NULL) | non in db-08 | `:13300`, `:13378` |
| `setup2` (101) `TestMode_<CodMac>` | stato della sessione di test in JSON | non in db-08 | `:10141` |
| `Setup(102).T7` | terzo campo decodificato = DBSERVIZIO | db-08: credenziali ECL; nuovo uso del campo | `:15483-15487` |
| `Setup(101).T6` | multisala se contiene `\|`; **ignora l'esclusione `#`** di WinMT | divergenza | `:9213`; `winmt-03` |
| `BEConfig.*` | `Macaddress` PK, `BeInfo`/`BeConfig`/`BiConfig` JSON, `DetectionDate` | db-08: tabella non usata da WinMT | `:13569-13575` |
| `PartiteOspiti.*` | scritte da B4J: `NrPartiteConsecutive`, `TotPartite`, `TotTickets`, `DataUltimaPartita` per (`IdContatto`, `device`) | **risponde a W03 domanda 4** | `:11456-11477`, `:11507` |

### (c) DDL eseguito dal codice

- `CREATE TABLE BEConfig` se manca, quando `dbversion` è tra 20250424 e 20250508; `ALTER TABLE BEConfig ADD DetectionDate` tra 20250508 e 20250527 [V `:13559-13603`; innesco `DBwinmt.bas:126-138`].
- Nessuna creazione di procedure in questa zona [V]. Altri DDL B4J fuori zona: `ecl_log`, `pinkbox_log` (`DBcoinless.bas:3097`, `3946`), tabelle `coinless_sbuilder_*` (`ScreenBuilder.bas:55-99`).
- **Le versioni "B4X" delle `sp_redeem_*` non sono create da B4J**: sono state installate a mano o da altri [D]. WinMT invece riscrive le sue versioni all'avvio (`winmt-04` § 4.8).

### (d) Stato fuori dal DB

- Configurazione in memoria: `Main.myWinMtConfig` (Nimp, IdPost, IdOperatore, multilocale, IntervalloSincronizzazione, VipPromotion*), `Main.settings` (`Connected`, `ApplicationMode`, `Primario`), `dbversion`.
- Gli stati del test mode e dello swap BI **sono nel DB**, per scelta, in `setup2` ed `EcsMacchine.T0`.

### (e) Sovraccarichi semantici

- `EcsMacchine.T0` (JSON di stato), `Clienti.UserName` (token), `Clienti.Foto` (attributi).
- `Tickets.MangiaT` = 1 e `F1`/`T1` riusati.
- `Premi` come contenitore di articoli fittizi o virtuali di slot.
- `LogTransazioniTotem.AC` come UUID di sequenza.
- `setup2` come archivio di stato operativo.
- `EcsModuli.NImp` come flag.

---

## 5. Doppioni e sovrapposizioni con WinMT

1. **Consumo dei punti (FIFO)**: B4J `toglipunti` e `HubStornaTicketInTransazione` contro `TogliPunti` di WinMT. Le differenze:
   - filtro `NonCont` in uno solo dei due;
   - `OperOut` sempre 0;
   - `DataOut` non scritto sul lotto parziale;
   - nessuna variante Golden (`TogliPuntiGS`).
2. **Ricalcolo del saldo ticket**: tre formule B4J (E03-08) contro W02-16.
3. **Registrazione delle vincite**: una riga per richiesta contro una riga per pezzo; operatore del servizio; `N0` mancante (E03-07, E03-13).
4. **Scarico della giacenza**: `aggiornaPremio` (`Quantita`, `QDisN`) al ritiro dall'app; WinMT scala `Premi.Quantita` alla selezione (`IncQty`, `Form1.frm:15711`). Nel PrizeHub nuovo lo scarico avviene invece al carico dello slot: **due modelli di giacenza nello stesso DB**.
5. **Saldi card dai movimenti** (E03-01 contro W02-07): manca la sottrazione di `NImp` 18 e il filtro `WinMt`.
6. **Creazione del cliente** (E03-03/04 contro W02-09): non salta gli id presenti in `TransCard.IdCli`; promozione non applicata nella creazione da app; `UserName` e `Password` hanno significati nuovi.
7. **Promozioni, VIP, fine compleanno** (E03-06 contro W03-18, W03-23, W04-23): stessa regola; B4J transazionale e corretto sul livello VIP.
8. **Redeem** (E03-18 contro W04-19): stessa sequenza, procedure **in versioni incompatibili**. Le procedure B4X sono solo nel test; in produzione ci sono le versioni OUTPUT e manca `verify_pin`.
9. **Log POS** (E03-21 contro W04-20): stessa mappatura posizionale delle colonne (`IDTerm` = ricevuta esercente, `AId` = id transazione, `Appl` = ricevuta carta, `IC` = dtId, `PAN` mascherato) e stessa regola su `DataAck`.
10. **Numero di serie degli scontrini** (`CalcSerNum`): algoritmo identico, stessi limiti.
11. **CodBar da `UID_Ammessi` sui primi 8 caratteri** (`fixCodbarRotti` contro W02-11): stessa regola, applicata da B4J in blocco su tutti i clienti a ogni login per email o sostituzione card.
12. **Rilevazione della versione dello schema** (`CheckDbMigration`): stessa logica in entrambi.
13. **Prezzo partita per livello e happy hour**: entrambi usano `vs_CoinlessSpecialTimes` (WinMT per la configurazione, B4J per decidere il prezzo).
14. **Partita sui contatori** (`aggiungiPartitaRealtime`, `In9`+1) contro `scriviTicketsAutomatici` (trigger DB, W08-14).
15. **Creazione e duplicazione della macchina** (E03-28 contro W08-03/W08-06): calcolo di `device`/`Modu` identico; `F0` diverso.
16. **Card operatore e limiti** (E03-11 contro W10-07/W10-08): B4J non filtra `Attivo`, non applica `Livello And 3`, confronta la password in chiaro, ma applica il limite dei rimborsi.

---

## 6. Problemi e rischi

**Consistenza e transazioni**
- Prelievo premi dall'app senza transazione. L'esito restituito è probabilmente sempre "errore" [D], con rischio di ripetizione e doppio scarico (E03-07).
- Multisala: `sp_last_trans` è chiamata ma ignorata; non c'è compensazione se il prelievo remoto fallisce dopo il commit locale (E03-07, E03-13).
- Redeem: il codice resta riutilizzabile se la conferma fallisce dopo l'accredito (E03-18).
- In multisala alcune Sub usano `IdContatto` dove servirebbe `IdLong`:
  - rimborso ticket [V `AppServiceHandler.bas:273`];
  - join della cassa mobile [V `:13049`];
  - data dell'ultima operazione [V `:11592`];
  - `usedBy` del redeem [D].
- Il test mode cancella righe `EcsDati` (storico dei contatori) [V `:10053`].
- Le scritture di `Premi.Quantita` sono asimmetriche fra sostituzione e rimozione dello slot (E03-15).
- `ApiPrizeHub_MoveToVirtualWharehouse` ha il codice destinazione letterale, lavora su un hub fisso e non chiude la connessione: **perde una connessione del pool a ogni chiamata** [V].

**Concorrenza**
- `IdContatto` = MAX+1 senza lock in `creaCliente`; `Modu`/`device` = MAX+1 in `creaMacchinaDaConfig`.
- `Clienti.Tickets` sovrascritto da più scrittori, B4J e WinMT, con valori calcolati in memoria.

**Sicurezza**
- SQL injection in `loginUtente` [V `:8826-8828`]. Nomi di colonna interpolati da parametri (`leggiBEConfig`/`scriviBEConfig` `campo`, `QDis${distributore}`, `PDis${HubId}`) [V `:13629`, `:13663`, `:8250`, `:13790`]: oggi i valori arrivano da codice interno [D].
- Password operatore confrontata in chiaro; il chiamante logga username e password in chiaro [V `eclservice.bas:357`].
- Credenziali del cloud nel codice (`DBwinmt.bas:204`, `:214`).
- `SVCGETSETUP` espone all'app l'intera riga `Setup(101)`, compresi `AdmPass`/`Passw` (parametri ECL, non segreti secondo db-08) [V `AppServiceHandler.bas:208-221`].

**Robustezza**
- `prelevapuntidaaltrolocale` cambia il formato data globale del processo [V `:8422`].
- Codice morto con SQL errato: `getAttributoMacchina` usa la colonna `macaddr`, `getCodmacFromDevice` un alias inesistente [V `:9583`, `:13123`].
- `ClassificaMangiaT` classifica il bit 8 ("reso", cioè ticket riaccreditati al cliente) come uscita, in contrasto con il significato di WinMT [V `:8590`; `winmt-05` § 3.1]. È codice morto.
- `saveTicketsPartitaCompleanno` somma tutti i ticket di `CoinlessDataBuffer` del device, senza filtro per card o per partita [V `:11507`; effetto D].
- `GetReplaceHistory` ricava dati dal **testo** del log blacklist, quindi dipende dalla lingua del messaggio [V `:15647-15655`; D].

---

## 7. Domande aperte per il team

1. Nelle sale di produzione le `sp_redeem_*` sono nella versione VB6 (OUTPUT) o B4X? Il redeem al totem funziona davvero? `sp_redeem_verify_pin` manca in produzione.
2. `Tickets.NonCont = 1`: i lotti così marcati devono essere spendibili (WinMT) o no (B4J)?
3. Il prelievo da app (`/app`, `/partner`, `/tickets`) risponde davvero 500 dopo aver scalato i punti? Ci sono reclami o doppi scarichi?
4. Modello di giacenza del PrizeHub: `Premi.Quantita` deve contare anche i pezzi negli slot? Le vincite SPINDLE sul codice fittizio con costo 0 come entrano nell'inventario e nei report?
5. `ApiPrizeHub_MoveToVirtualWharehouse` e `PDis/QDis` sono ancora usati? Esiste in qualche sala un articolo `?_?_PH?`?
6. `sp_last_trans` e `sp_preleva_punti` (cloud, DB `rdclienti`): `sp_preleva_punti` preleva l'intero importo o solo la parte mancante? Perché B4J ignora l'esito di `sp_last_trans`?
7. `Clienti.UserName` come token e `Password` come PIN: sono il contratto ufficiale con l'app/cloud? Chi altro li legge?
8. La creazione del cliente da app deve applicare la promozione stagionale, come fa WinMT?
9. Il login operatore di `eclservice` con cognome e password è in uso? Le password sono salvate in chiaro o MTCry?
10. Test mode: cancellare le letture `EcsDati` del periodo di test è accettato ai fini dell'incasso e dell'audit?
11. `EcsModuli.ShortAd` contiene oggi il `device` (B4J) o l'IP (db-08)?
