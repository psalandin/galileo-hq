# Galileo HQ — WinMT 04: Card elettroniche (ECL/coinless), cassa ECL e pagamenti

**Stato:** bozza · **Responsabile:** Piero · **Aggiornato:** 2026-10-23

**Fonte:** sorgente VB6 di WinMT (copia del 24/07/2026), file: `FrmSetECL.frm`, `ECL_database.cls`, `FrmReportsECL.frm`, `frmCassa.frm`, `ECL_cliente.cls`, `FrmUCardECL.frm`, `frmRappCard.frm`, `frmInfoPOS.frm`, `cls_NayaxManager.cls`, `frmEclHH.frm`, `cls_RedeemManager.cls`, `cls_GiallOne.cls`, `frmVendiGettoni.frm`, `ECL_command.cls`, `FormEclCardTool.frm`, `LogTransazioniPos.cls`, `frmInfoTransazioni.frm`, `FrmFreeCredits.frm`, `ClsEclReaderWriter.cls`, `ECL_operatore.cls`, `ECL_BonusHandler.cls`, `LogTransazioniTotem.cls`, `FormCreaRedeem.frm`, `cls_posmanager.cls`, `cls_PAXdevice.cls`, `ECL_Conversioni.cls`, `ECL_card.cls`, `FormEclMachineV2.frm`, `formEclReaderWriter.frm`, `formPOSReaderWriter.frm`, `FormPosSocket.frm`; codice DB in `sql/codice-db/test/applicativo/` · **Collegati:** `winmt-00-mappa.md`, `legacy/WinMTsql/doc/frmInfoPOS_analisi.md`, `docs/db/db-02-catalogo.md`, `docs/db/db-03-risultati-01.md`, `docs/db/db-04-risultati-02.md`, `docs/db/db-06-produzione-02.md`, `docs/db/db-07-confronto-test-produzione.md`

Legenda: **[V]** verificato nel codice (`file:riga`), **[D]** dedotto, da confermare. I riferimenti senza percorso sono file di `legacy/WinMTsql/`; quelli con `.sql` sono in `sql/codice-db/test/applicativo/`.

---

## 1. Perimetro

| File | Righe codice | Ruolo | Lettura |
|------|-------------:|-------|---------|
| `FrmSetECL.frm` | 1734 | Setup ECL: parametri card, scaletta bonus, importi POS, porte lettore e POS, modello POS, programmazione lettore e card tecniche | Salvataggio, caricamento, programmazione lettore a fondo; autodetect porte scorso |
| `ECL_database.cls` | 1610 | Versione dello schema per rilevamento di oggetti, creazione/migrazione di tabelle e procedure (POS, redeem, uid_reservations, setup2), copia anagrafiche dal cloud | `CheckDbMigration`, `aggiungi*Setup2`, `CreaRedeemProcedures` a fondo; resto scorso |
| `FrmReportsECL.frm` | 1519 | Motore di report parametrici con definizioni SQL lette da un DB centrale | Accesso ai dati; disegno griglie saltato |
| `frmCassa.frm` | 1192 | "Controllo movimenti cassa": riepiloghi su `TransCard`, svuotamento cassa principale, azzeramento cassa operatore | Query e scritture a fondo |
| `ECL_cliente.cls` | 1177 | Classe cliente ECL: lettura, saldi da `TransCard`, verifica card/DB, attributi JSON, sostituzione card, promozione VIP | A fondo |
| `FrmUCardECL.frm` | 1093 | Unione card: trasferimento di crediti, bonus e ticket da card origine a card destinazione | Flusso principale a fondo |
| `frmRappCard.frm` | 1077 | "Rapporto card": crediti acquistati, spesi, residui, corrispettivi per operatore | Query a fondo |
| `frmInfoPOS.frm` | 985 | Recupero transazioni POS e contanti rimaste `Pending` | **Non rianalizzato**: riassunto da `doc/frmInfoPOS_analisi.md` con verifiche puntuali |
| `cls_NayaxManager.cls` | 851 | Client TCP JSON-RPC verso PosHandler (Nayax e altri POS) | Metodi e stati; parser JSON scorso |
| `frmEclHH.frm` | 784 | Gestione happy hour: testate, macchine, prezzi per livello, template grafici | A fondo |
| `cls_RedeemManager.cls` | 518 | Codici redeem: verifica e prenotazione, PIN, conferma, annullo, creazione, QR | A fondo |
| `cls_GiallOne.cls` | 463 | Client TCP JSON-RPC verso il "GiallOne" (micrototem che genera card in batch) | A fondo |
| `frmVendiGettoni.frm` | 437 | Vendita di gettoni fisici scalando il saldo della card | A fondo |
| `ECL_command.cls` | 422 | Protocollo JSON con il lettore/scrittore di cassa: comandi e decodifica risposte | A fondo |
| `FormEclCardTool.frm` | 380 | Strumenti: card di reset rete, riprogrammazione lettore | Scorso |
| `LogTransazioniPos.cls` | 348 | Accesso a `LogTransazioniPos` | A fondo |
| `frmInfoTransazioni.frm` | 343 | Movimenti della card, storno ultima ricarica, ritiro card | A fondo |
| `FrmFreeCredits.frm` | 339 | Report dei crediti di servizio (`NImp = 12`) | Query a fondo |
| `ClsEclReaderWriter.cls` | 318 | Gestione seriale del lettore di cassa, eventi card on/off/letta/scritta | A fondo |
| `ECL_operatore.cls` | 314 | Operatore: permessi a bitmask, limiti giornalieri in JSON | A fondo |
| `ECL_BonusHandler.cls` | 252 | Scaletta bonus su ricarica (crediti e ticket) | A fondo |
| `LogTransazioniTotem.cls` | 225 | Accesso a `LogTransazioniTotem` (pagamenti dei totem) | A fondo |
| `FormCreaRedeem.frm` | 144 | Creazione codici redeem per gli ospiti di un compleanno, PDF e mail | A fondo |
| `cls_posmanager.cls` | 123 | POS su seriale (protocollo PAX) | Scorso |
| `cls_PAXdevice.cls` | 106 | Pacchetti STX/ETX con checksum per PAX | Scorso |
| `ECL_Conversioni.cls` | 78 | Conversioni centesimi ↔ valuta ↔ crediti (token) | A fondo |
| `ECL_card.cls` | 59 | Struttura della card letta; verifica in `UID_Ammessi` | A fondo |
| `FormEclMachineV2.frm`, `formEclReaderWriter.frm`, `formPOSReaderWriter.frm`, `FormPosSocket.frm` | 9 + 3 + 3 + 3 | Form contenitori dei controlli seriali/Winsock | Solo designer |

Letti fuori perimetro, quanto basta per i flussi: `ModAddNew.bas` (`AddTransCard`, `addVenditaGettoni`, calcolo saldi), `Module1.bas` (variabili ECL, `CaricaGen`, salvataggio Setup, migrazioni all'avvio), `Module6.bas` (`VerificaCard`, `MettiInBlackList`), `Form1.frm` (verifica card, riscatto redeem), `FrmCCard.frm` (scritture della ricarica), `FrmGenCard.frm` (ticketless); nel DB i trigger `aggiornaCard`, `bannaUtente`, `decodifica_flusso`, le procedure `decodifica_record`, `sp_redeem_*`, `sp_rimuovidabl`, `sp_ripristinacard`, `scriviTransazioneCard`, `scriviTicketsAutomatici`, le funzioni `CreditToCurrency`, `fn_DecodeCardTrans`, la vista `vs_CoinlessSpecialTimes`.

La **ricarica in cassa** (`FrmCCard.frm`) non è in questa zona: qui se ne descrivono solo le scritture su `TransCard` (§ 4.3), che sono il cuore del modello dati ECL.

---

## 2. Flussi

### W04-01 Configurazione ECL, bonus e POS
- **Attore e innesco:** amministratore, `FrmSetECL`, pulsante Salva (`cmdSave_Click`). Visibile per intero solo sulla postazione 101 [V] `FrmSetECL.frm:2162`.
- **Passi:**
  1. `Form_Load` carica da variabili globali (già lette da `Setup` 101 in `CaricaGen`/`CaricaPost`) codice cliente e impianto ECL, rapporti di conversione, scaletta bonus, importi POS, modello e porta POS, porta lettore, opzione ticket/eticket [V] `FrmSetECL.frm:1983-2170`.
  2. Elenco dei modelli POS da `setup2.AvailablePosDevices`; configurazione TCP di PosHandler da `setup2.PosTcpConfig` (default `localhost:9000`) [V] `FrmSetECL.frm:2019-2034`.
  3. Al salvataggio ricompone `Setup.AdmPass` come stringa a campi separati da `|` e salva `Setup` con `SaveSetPost` [V] `FrmSetECL.frm:1787`, `1827`; `Module1.bas:3140-3180`.
- **Dati:** scrive `Setup(101).AdmPass`, `T10` (scaletta bonus crediti), `T11` (importi POS), `F9`, `F10` (ticket/eticket), `N10` (modello POS), `N11` (porta POS), `N13` (copie scontrino POS), `GCassa`, `CodEcs`; `setup2.PosTcpConfig` [V] `Module1.bas:3150-3180`.
- **Regole:** `CentConversionFactor` vuoto o 0 → `0.01`; `CentsToTokenFactor` vuoto o 0 → `1` [V] `FrmSetECL.frm:1785-1786`, `Module1.bas:2738-2742`. Se il POS è abilitato e il modello è seriale (`PosMod < 4`) la porta è obbligatoria [V] `FrmSetECL.frm:1794`.
- **Periferiche:** test del POS via TCP (`cmdTestPos_Click`), test del server ECL (`cmdTestServerECL_Click`, stringa di connessione composta da `Setup` cifrato; credenziale composta nel codice in `FrmSetECL.frm:1956`).
- **Peso:** M — molti parametri codificati in campi jolly, ma CRUD.
- **Evidenze:** `FrmSetECL.frm:1725-1841`, `1983-2170`, `2172-2241`.

### W04-02 Programmazione del lettore di cassa e card tecniche
- **Attore e innesco:** installatore, `FrmSetECL` (pulsanti di setup) e `FormEclCardTool` (azioni "Crea card di reset network", "Riprogramma lettore").
- **Passi:**
  1. Inizializzazione card con codice cliente/impianto ECL e livello (`Card_Init`), poi invio SSID e chiave Wi-Fi (`wifi`) alla card: è la **card di reset rete**, che porta la configurazione Wi-Fi alle schede dei giochi [V] `FrmSetECL.frm:1576`, `1609`; `FormEclCardTool.frm:602-723`.
  2. Lettura della **card di setup** (`ECLSetupCard`): l'UID letto viene memorizzato e abilita la modifica delle macchine installate [V] `FrmSetECL.frm:1710-1715`; `Module1.bas:187`.
  3. Programmazione del lettore con il codice impianto (`Set_Rd_Impianto`) e del Wi-Fi del lettore (`SetWifiReader`) [V] `ECL_command.cls:473-493`; `FrmSetECL.frm:1859`.
- **Dati:** legge `Setup(101).T8` (SSID e chiave Wi-Fi, cifrati) e `Setup(102).T7` (connessione al server ECL, cifrata) [V] `FrmSetECL.frm:2186-2197`; `Module1.bas:33`.
- **Periferiche:** lettore/scrittore ECL su seriale 38400 8N1.
- **Peso:** M — protocollo con attese a tempo e conferme testuali.
- **Evidenze:** `FrmSetECL.frm:1505-1723`, `1843-1890`; `FormEclCardTool.frm:602-723`, `1032-1059`.

### W04-03 Dialogo con il lettore/scrittore card di cassa
- **Attore e innesco:** cliente che appoggia la card; tutte le form che leggono o scrivono la card (cassa, unione card, vendita gettoni, recupero POS).
- **Passi:**
  1. `ConnettiLettoreTag` apre la COM `valsets.numcommEN` a 38400 8N1 [V] `ClsEclReaderWriter.cls:97-120`.
  2. `TagRD_OnComm` accumula fino a CRLF e passa ogni riga a `analizzaMessaggio` → `ECL_command.parseFromReader` [V] `ClsEclReaderWriter.cls:122-166`, `193-288`.
  3. Messaggi del lettore: `card_set` (card presentata), `Val_card` (UID, `Crediti`, `Bonus`, `Punti`, `Liv`, `CntProg`), `No_Card` (rimossa), `Avvicina_card`, `card_no_imp` (card di altro impianto o versione 1), `card_null` (vergine), `card_no_firma`, conferme `Write_Ok`, `SetCredBonusOk`, `InitOk`, `ClearOk`, `SetTypeCard` [V] `ECL_command.cls:96-330`.
  4. Comandi di WinMT: `View_All` (rilettura), `Set_CredBonus` con **valori assoluti** di crediti e bonus e flag ticketless, `Add_Cred`, `Add_Punti`, `Card_Init`, `Clear`, `SetTypeCard`, `SetTicketLess`, `SetCntPrg`, `StartGameON/OFF`, `SetTime`, `wifi`, `Reboot` [V] `ECL_command.cls:332-505`.
  5. Ciclo di scrittura tipico: `Set_CredBonus(crediti attuali + delta, bonus attuali + delta, Clienti.N0)`, attesa dell'evento "scrittura completata", poi `View_All` e attesa della rilettura; limite 10 s con `DoEvents` [V] `frmInfoPOS.frm:649-722`; `FrmCCard.frm:4314-4420`.
- **Cosa resta sulla card:** UID (8 byte esadecimali, 16 caratteri), crediti e bonus in "centesimi", punti/ticket, livello, progressivo `CntProg`, codice impianto, flag ticketless, firma/versione (V1/V2) [V] `ECL_command.cls:201-213`, `239-278`; `ClsEclReaderWriter.cls:290-307`.
- **Regole:** stato del lettore occupato/libero; `OperationCompleted` = 1 completato, 2 timeout (5 s), 3 errore [V] `ClsEclReaderWriter.cls:363-383`. Nessun identificativo di comando: la conferma è associata all'ultimo comando inviato [D].
- **Periferiche:** seriale; nessuna rete necessaria.
- **Peso:** L — periferica, eventi asincroni, scrittura di valori assoluti, stati della card.
- **Evidenze:** `ClsEclReaderWriter.cls`, `ECL_command.cls`, `ECL_card.cls`.

### W04-04 Lettura del cliente da card e verifica card/DB (anti-clonazione lato cassa)
- **Attore e innesco:** cassiere; card appoggiata sul lettore di cassa (`Form1`, evento lettore).
- **Passi:**
  1. `LeggiCliente(T0 o CodBar)` legge `Clienti` (esclusi "cliente"/"cancellato"), decodifica gli attributi JSON in `Clienti.Foto`, calcola crediti, bonus, saldo e progressivo da `TransCard` (`leggiSaldoCreditiEBonus`) e li normalizza con `RiallineaCreditiBonus` [V] `ECL_cliente.cls:621-752`, `377-459`; `ModAddNew.bas:1149-1200`.
  2. `ConfrontaCardConCliente` confronta progressivo e saldo della card con l'ultima riga di `TransCard` [V] `ECL_cliente.cls:168-255`:
     - progressivo card > progressivo DB: ci sono partite non ancora trasmesse; valido solo se saldo card < saldo DB;
     - progressivi uguali: valido se saldo card ≤ saldo DB;
     - progressivo card = 0 con cliente attivo: card vergine da riscrivere;
     - progressivo card < DB: card non aggiornata, "da riallineare", vale il saldo DB.
  3. `VerificaCard` ripete il controllo usando l'ultimo movimento "verificato" (`FlagOpDaVerificare` nullo) e l'ultimo in assoluto; esiti: valida, da riallineare (`rallinea`), da blacklist [V] `Module6.bas:2219-2350`.
  4. Se da riallineare: `rigeneraCard` e riformattazione con `Card_Init` usando `Clienti.TipoCard` [V] `Form1.frm:11675-11679`. Altrimenti `MettiInBlackList`: dalla quarta lettura incoerente consecutiva della stessa card (contatore in memoria della postazione) scrive `Clienti.F1 = 0`, `T1 = motivo`, `D1`, inserisce `CoinlessClonedCards` (`TipoMovimento = 'Lettura'`, `CodMac = 'WinMt'`) e `CoinlessLogEventiBlacklist`, poi chiede al servizio ECL di ripubblicare la blacklist (`jrefreshBlacklist`) [V] `Module6.bas:2352-2384`, `2423-2432`.
  5. Con `Clienti.T1` valorizzato la cassa mostra "????" su crediti e ticket e blocca l'unione card [V] `Form1.frm:9195-9226`, `11600-11645`.
- **Dati:** legge `Clienti`, `TransCard`, `UID_Ammessi`; scrive `Clienti.F1/T1/D1`, `CoinlessClonedCards`, `CoinlessLogEventiBlacklist`.
- **Regole:** tetto saldo 5.000.000 centesimi [V] `ECL_cliente.cls:105`; in `RiallineaCreditiBonus` saldo > 60.000 € azzera tutto [V] `ModAddNew.bas:1161-1166`.
- **Periferiche:** lettore di cassa; chiamata HTTP al servizio ECL `http://<server>:58889/eclcommand`.
- **Peso:** L — logica antifrode con più fonti di verità e soglie.
- **Evidenze:** sopra.

### W04-05 Recupero transazioni POS rimaste in sospeso
Riassunto di `doc/frmInfoPOS_analisi.md` (§ 1, 3-bis, 3-octies), verificato a campione.
- **Attore e innesco:** cassiere, `Form1.CmdPosInfo` → `frmInfoPOS`, con la card del cliente sul lettore.
- **Passi:**
  1. Griglia delle righe `LogTransazioniPos` con `Status = 'Pending'` delle ultime 24 ore, del cliente o senza cliente.
  2. Clic: interrogazione di PosHandler (`getTransactionById` con `uidPOS`); se il pagamento risulta approvato e la riga non ha `N0`, conferma dell'operatore.
  3. Scrittura card (crediti + bonus da scaletta), poi `TransCard`: riga bonus `NImp 6` con `N0 = progressivo − 1` e riga ricarica con `ValoreCassa = 0` (cioè POS) e `NImp 0` o `1` se la postazione contiene "OTEM"; `Clienti.Credito` [V] `frmInfoPOS.frm:754-800`.
  4. `LogTransazioniPos`: dati della transazione (terminale, id, `dtId`, PAN mascherato, `IdCli`), ack a PosHandler, `N0`, `Status = 'Recovered'`. Se Nayax dà esito negativo: `Failed` + ack; se già caricata (`N0` presente): `Completed` [V] `frmInfoPOS.frm:817-854`.
  5. Ticket bonus su ricarica (`AddScon`, tipo 64).
- **Peso:** L — periferica, servizio esterno asincrono, scritture non transazionali.
- **Rischi già documentati:** scrittura DB anche se la card fallisce; doppio accredito con doppio clic; `UPDATE Clienti` dipendente dal separatore decimale; overflow di `N0` oltre 32767 (`Integer`).
- **Evidenze:** `frmInfoPOS.frm:734-866`, `1243-1330`, `1517-1577`.

### W04-06 Recupero contanti in sospeso dei totem
- **Attore e innesco:** cassiere, `frmInfoPOS`, griglia contanti.
- **Passi:** righe `LogTransazioniTotem` con `tipo` in (`Bill`, `Coin`), `CAut = 'Pending'`, ultime 24 ore, del cliente o senza cliente; se `TCC` (progressivo card) > 0 la riga passa a `Completed` senza domande; altrimenti scrittura card, `TransCard` (ricarica con `ValoreCassa` = importo), `TCC = progressivo`, `CAut = 'Recovered'` [V] `frmInfoPOS.frm:1641-1848`; `LogTransazioniTotem.cls:108-198`.
- **Peso:** M.
- **Nota:** la ricarica recuperata ha `ValoreCassa` = importo come un incasso di cassa, anche se il contante è nel totem: possibile doppio conteggio (rischio 29 dell'analisi di `frmInfoPOS`).
- **Evidenze:** sopra.

### W04-07 Consultazione dei movimenti della card
- **Attore e innesco:** cassiere, `frmInfoTransazioni` (e griglia tessera di `frmInfoPOS`).
- **Passi:** query su `TransCard` del cliente ordinata per `N0`, con decodifica del tipo da `NImp` (POS, RICARICA, STORNO, CAMBI, BONUS, RESI, OMAGGI, CREDITI/BONUS TRASFERITI/ACQUISITI, OP, ONLINE, SUBSCRIPTION, REALIGN) e separazione crediti/bonus; stampa [V] `frmInfoTransazioni.frm:366-499`.
- **Peso:** S.
- **Evidenze:** `frmInfoTransazioni.frm:366-499`, `631-675`.

### W04-08 Storno dell'ultima ricarica
- **Attore e innesco:** cassiere, clic sull'ultima riga in `frmInfoTransazioni`, con la card sul lettore.
- **Passi:** ammesso solo se la riga cliccata è l'ultimo `N0` del cliente e `NImp` in (0, 6, 8, 9) [V] `frmInfoTransazioni.frm:694-700`; **cancellazione fisica** della riga `TransCard` (`DELETE ... WHERE IDOperazione = …`) e riscrittura della card con crediti o bonus diminuiti dell'importo [V] `frmInfoTransazioni.frm:712-805`.
- **Peso:** M — cancellazione di un movimento economico e riscrittura card senza conferma di scrittura.
- **Nota:** spiega almeno in parte le cancellazioni di `TransCard` osservate nei DB (DB 04 § 2, DB 06 Q12) [D].
- **Evidenze:** `frmInfoTransazioni.frm:681-805`.

### W04-09 Ritiro della card (azzeramento del saldo)
- **Attore e innesco:** cassiere, `frmInfoTransazioni.cmdRitira`, abilitato se `setup2.RitiroCard = 'enabled'` [V] `frmInfoTransazioni.frm:575`.
- **Passi:** se c'è bonus, riga `NImp 6` negativa (`N0 = progr + 1`); riga `NImp 0` con `ValoreOperazione` e `ValoreCassa` negativi pari ai crediti (`N0 = progr + 2`); card riscritta a 0/0 [V] `frmInfoTransazioni.frm:510-554`.
- **Regola:** il ritiro restituisce contante (`ValoreCassa` negativo) solo per i crediti; il bonus si perde [V].
- **Peso:** M.

### W04-10 Unione card (trasferimento tra card)
- **Attore e innesco:** cassiere, `FrmUCardECL.CMdDo`, con elenco di card origine e una destinazione; opzioni "solo ticket", "solo crediti", "crediti e ticket", "elimina clienti origine".
- **Passi:**
  1. Per ogni card origine appoggiata: trasferimento ticket (`Tickets.TPagati` aggiornati, `MangiaT |= 512` "passato ad altra card", `OperOut`, `DataOut`) e ricalcolo `Clienti.Tickets` [V] `FrmUCardECL.frm:2269-2317`.
  2. Valore da trasferire tolto **prima dal bonus, poi dai crediti**; card origine riscritta; `TransCard` del donatore: `NImp 15` (bonus trasferiti, `N0 = progr + 1`) e `NImp 10` (crediti trasferiti, `N0 = progr + 2`) [V] `FrmUCardECL.frm:1710-1767`.
  3. Se la card origine è vuota e richiesto: `Clear` della card ed `EliminaCliente` (anonimizzazione logica) [V] `FrmUCardECL.frm:1776-1789`; `ECL_cliente.cls:942-968`.
  4. Card destinazione riscritta; `TransCard` del beneficiario `NImp 16` (bonus acquisiti) e `NImp 11` (crediti acquisiti) [V] `FrmUCardECL.frm:1845-1878`.
  5. Card senza RFID (solo barcode): trasferimento dei soli ticket [V] `FrmUCardECL.frm:2366-2452`.
- **Regola:** "ogni scrittura di crediti e bonus sulla card avanza [il progressivo] di 2" [V] commento `FrmUCardECL.frm:1737`.
- **Periferiche:** lettore di cassa, lettore barcode.
- **Peso:** L — più card in sequenza, più tabelle, nessuna transazione.

### W04-11 Vendita di gettoni dal saldo della card
- **Attore e innesco:** cassiere, `frmVendiGettoni` (tastierino), card sul lettore.
- **Passi:** gettoni vendibili = (crediti + bonus) / `CentsToTokenFactor`; importo = gettoni × `CentsToTokenFactor`, scalato **prima dai crediti poi dal bonus**; card riscritta; `TransCard` `NImp 3` con `ValoreOperazione` = crediti scalati, `ValoreBonus` = bonus scalati, `ValoreCassa = 0`; `Clienti.Credito` [V] `frmVendiGettoni.frm:995-1113`; `ModAddNew.bas:1660-1720`.
- **Peso:** M.
- **Nota:** le query di saldo non sottraggono `NImp 3` dai crediti (§ 4.3): il saldo regge solo grazie a `ValoreFinale` [D].

### W04-12 Controllo movimenti e svuotamento della cassa principale
- **Attore e innesco:** responsabile, `frmCassa` (aggiornamento, stampa, "SVUOTA CASSA").
- **Passi:**
  1. Riepiloghi per periodo da `TransCard` con `WinMt = 1`: rimborsi (`NImp 8`), omaggi (`9`), svuotamenti (`7`), cassa mobile (`2`), cassa fissa (`0`, `13`) separando contante (`ValoreCassa`) e POS (`ValoreOperazione − ValoreCassa`), totem (`1`), totali per postazione [V] `frmCassa.frm:2707-3395`.
  2. Svuotamento: somma di `ValoreCassa` con `D0` nullo e `NImp` in (0, 1, 2, 14) per la postazione; `UPDATE TransCard SET D0 = GETDATE()` sulle righe aperte; riga `NImp 7`, `IdCli 0`, `CodMac` = postazione, `ValoreOperazione = ValoreCassa` = importo; `VCassa = 0` [V] `frmCassa.frm:3401-3460`.
- **Peso:** M.

### W04-13 Azzeramento della cassa di un operatore
- **Attore e innesco:** responsabile, `frmCassa` o `frmRappCard`, pulsante "Azzera operatore".
- **Passi:** `UPDATE TransCard SET D0 = GETDATE()` sulle righe aperte dell'operatore (in `frmCassa` solo `CodMac = 'CASSA-MOBILE'`, in `frmRappCard` solo `NImp` 0); riga `NImp 6`, `CodMac = 'SVUOTAMENTO'`, **`IdCli` = id operatore**, `ValoreCassa = VCassa + importo`; `VCassa` aumentato [V] `frmCassa.frm:3962-3985`; `frmRappCard.frm:2313-2335`.
- **Peso:** S.
- **Nota:** `NImp 6` è anche il codice del bonus: le righe di azzeramento si confondono con i bonus nei saldi per cliente se un `IdCli` operatore coincide con un cliente [D].

### W04-14 Rapporto card
- **Attore e innesco:** responsabile, `frmRappCard`.
- **Passi:** crediti acquistati (`WinMt = 1`, `NImp` in 0, 1, 2, 5), spesi (`WinMt = 0`, join con `EcsMacchine`), residui (ultima riga per cliente), riepilogo per operatore e per canale (cassa: `Operatore < 1000`; totem: `Operatore ≥ 1000`), esclusa la card fittizia "resi resi" [V] `frmRappCard.frm:1898-2226`.
- **Peso:** M.

### W04-15 Rapporto crediti di servizio
- **Attore e innesco:** responsabile, `FrmFreeCredits`.
- **Passi:** righe `TransCard` con `NImp = 12` per periodo, raggruppate per cliente, operatore e macchina [V] `FrmFreeCredits.frm:1197-1277`.
- **Peso:** S.
- **Nota:** WinMT non scrive mai `NImp 12`. La card operatore abilitata con il flag `StartGame` avvia partite gratuite sul gioco [V] `frmgesop.frm:1007-1009`; la riga `NImp 12` viene probabilmente creata dal servizio ECL [D].

### W04-16 Report ECL parametrici
- **Attore e innesco:** responsabile, `FrmReportsECL`.
- **Passi:** elenco dei report e loro SQL letti con `cls_reports` da un DB centrale (`CoinlessDB` sul server cloud, credenziale scritta nel codice in `FrmReportsECL.frm:1244-1246`); esecuzione sul DB di sala con parametri (date, liste, filtri), eventuale SQL "prima della stampa", drill-down, esportazione Excel, rigenerazione della cache con `sp_generacache` [V] `FrmReportsECL.frm:1211-1261`, `1635-1748`, `2471-2526`.
- **Peso:** M — il motore è generico; i report sono dati.

### W04-17 Gestione happy hour
- **Attore e innesco:** responsabile, `frmEclHH`.
- **Passi:**
  1. Nuova testata: giorno (−1 = ogni giorno), `ampm` ('a' se inizio < 13, altrimenti 'b'), dalle/alle, periodo dal/al, attivo, prezzi per livello convertiti in centesimi, template grafico in `T0` [V] `frmEclHH.frm:3952-3975`, `4528-4539`.
  2. Aggiunta macchine: per ogni livello prezzo HH; se lasciato vuoto vale il prezzo normale della macchina (`EcsMacchine.val_*`), se negativo è uno sconto sul prezzo normale [V] `frmEclHH.frm:3791-3846`.
  3. Modifica cella prezzo; eliminazione; duplicazione (testata copiata disattivata) [V] `frmEclHH.frm:3761-3789`, `4620-4662`.
  4. All'uscita, richiesta HTTP al servizio ECL di rigenerare le pagine grafiche delle schede (`jRebuildPagesFromTemplate`); alla modifica, cancellazione delle pagine della macchina (`jDeleteGeneratedPageFromHH`) [V] `frmEclHH.frm:4460-4516`.
- **Applicazione:** la vista `vs_CoinlessSpecialTimes` seleziona le happy hour attive per data, giorno e ora e restituisce i prezzi per macchina; la usa anche `scriviTicketsAutomatici` [V] `vs_CoinlessSpecialTimes.sql`.
- **Peso:** M.

### W04-18 Creazione dei codici redeem per un compleanno
- **Attore e innesco:** operatore, `FormCreaRedeem` dalla gestione compleanni.
- **Passi:** per ogni ospite non ancora registrato, `sp_redeem_create` con `Azione = 'new'`, crediti e bonus precaricati del compleanno, livello `BIRTHDAY` (3), `IdCompleanno`, mail del genitore, validità = date del compleanno; codice `RD` + 13 caratteri esadecimali, PIN di 4 cifre; immagine QR ottenuta da un servizio pubblico esterno e salvata in `RedeemCodes.QRCode`; PDF per ospite e invio mail [V] `FormCreaRedeem.frm:519-630`; `cls_RedeemManager.cls:326-398`, `545-621`; `sp_redeem_create.sql`.
- **Peso:** M.

### W04-19 Riscatto di un codice redeem in cassa
- **Attore e innesco:** cassiere, lettura del QR in `Form1` → `RiscattaCodice`.
- **Passi:** `CheckRedeem` (formato `RD…`, 15 caratteri) → `sp_redeem_check_and_reserve_no_pin` (prenotazione 5 minuti su postazione e dispositivo) → richiesta PIN → `sp_redeem_verify_pin` → se `Azione = 'new'`: creazione card con livello, crediti, bonus, ticket (`FrmCreaCardsBatch.generaSingolaCard`) → `sp_redeem_confirm` → se livello compleanno, cliente aggiunto agli ospiti (`AssegnaACompleanno`); se la creazione fallisce, `sp_redeem_cancel` [V] `Form1.frm:7830-7894`; `cls_RedeemManager.cls:64-323`, `503-542`.
- **Regole SP:** errori `redeem_not_found`, `redeem_already_used`, `redeem_code_expired`, `redeem_code_reserved`, `redeem_requires_login` (cliente loggato solo `recharge`, anonimo solo `new`), `redeem_no_reservation`, `redeem_pin_wrong`; lock `UPDLOCK, ROWLOCK` [V] `sp_redeem_*.sql`.
- **Nota:** il ramo `recharge` in cassa è vuoto e scritto "rechage" [V] `Form1.frm:7877`. Confronto VB6/DB in § 4.8.
- **Peso:** M.

### W04-20 Pagamento con POS su PosHandler (Nayax e altri)
- **Attore e innesco:** cassiere in ricarica (`FrmCCard.AbilPOS`) con modello POS TCP.
- **Passi:** `uidPOS` = UUID v4 generato da WinMT; `LogTransazioniPos.InsertPOSPending` (`Status = 'Pending'`, `IdCli`, `IdPost`, `MName = <modello>_<computer>`, valore); `doTransaction` JSON-RPC con importo in centesimi; all'esito: scrittura card e `TransCard`, `ackTransaction`, `N0` nel log [V] `FrmCCard.frm:3089-3110`, `2859-2870`; `LogTransazioniPos.cls:66-120`; `cls_NayaxManager.cls:327-370`, `1080-1113`.
- **Metodi PosHandler:** `doTransaction`, `getUnackedTransactionList`, `getTransactionByVuid`, `getTransactionById`, `abortTransaction`, `getStatus`, `ackTransaction` [V] `cls_NayaxManager.cls:356-540`.
- **Riconciliazione:** le transazioni senza esito restano `Pending` e si recuperano con W04-05; lo stato finale è `Completed`, `Recovered` o `Failed`; `DataAck` registrata a ogni cambio di stato diverso da `Pending` [V] `LogTransazioniPos.cls:260-295`.
- **Peso:** L — servizio esterno asincrono, più stati, riconciliazione manuale.

### W04-21 Pagamento con POS seriale (PAX)
- **Attore e innesco:** come W04-20, modelli seriali.
- **Passi:** apertura COM a 115200 8N1, attivazione del dispositivo, pacchetti STX…ETX con checksum XOR [V] `cls_posmanager.cls:67-98`; `cls_PAXdevice.cls:38-70`. Nessuna scrittura su DB nelle classi.
- **Peso:** M.

### W04-22 Generazione di card in batch con il GiallOne
- **Attore e innesco:** operatore, `FrmCreaCardsBatch` (altra zona) o riscatto redeem, se la postazione ha un "MICROTOTEM".
- **Cos'è il GiallOne:** un dispositivo di rete (micrototem/distributore-codificatore di card) raggiunto via TCP con JSON-RPC; parametri `ip`, `port`, `nomeservizio`, `nomedevice`, `macaddr` in una riga di `setup2` con `IdPost = 0` [V] `cls_GiallOne.cls:368-427`.
- **Passi:** `batchInitCard` con numero di card, tipo, crediti, bonus, ticket, ticketless, `idCompleanno`, `idPromozione`, `paranoiaMode = 1` (stacco e verifica della card); `batchResetCard` per cancellare; risposte con `cardId`, `credits`, `bonus`, `tickets`, `status`, `index` [V] `cls_GiallOne.cls:428-528`, `285-339`.
- **Peso:** M.

### W04-23 Promozione VIP e abbonamento
- **Attore e innesco:** cassiere su richiesta del cliente.
- **Passi:** modello da `setup2.VipSubscriptionParams` (`FidelizzazioneDatiPersonali`, `…Sottoscrizione`, `…UtilizzoContinuativo`, `…SogliaMinima`); eleggibilità per saldo o per incassi del periodo (`NImp` 0, 1, 2, 13, 14); `PagaCanone` scrive `TransCard NImp 18` col canone, aggiorna `Clienti.TipoCard` e la scadenza nel JSON di `Clienti.Foto` [V] `ECL_cliente.cls:1276-1688`.
- **Nota:** `updateCardLevel` scrive il livello corrente e ignora il parametro `newlevel` [V] `ECL_cliente.cls:1515`.
- **Peso:** M.

### W04-24 Sostituzione della card del cliente
- **Attore e innesco:** cassiere (riemissione con OTP gestita dagli attributi del cliente).
- **Passi:** log in `CoinlessLogEventiBlacklist` ("Card sostituita…"), attributi di riemissione azzerati, `Clienti.T0` = nuova card, `CodBar` da `UID_Ammessi`, `F1 = 0`, `T1`, `D1` nulli [V] `ECL_cliente.cls:1213-1258`.
- **Peso:** M.
- **Nota:** il saldo resta legato al cliente (`TransCard.IdCli`), non alla card; la nuova card va scritta col saldo dal DB [D].

### W04-25 Adeguamento dello schema all'avvio
- **Attore e innesco:** avvio di WinMT (`Sub Main`).
- **Passi:** `CheckDbMigration` deduce la versione dalla presenza di oggetti (`Compleanni.IdCompleanno` → 20240311, `TransCard.FlagOpDaVerificare` → 20240625, … `PrizeHubSlots` → 20260501); in base alla versione crea `setup2` e valori predefiniti, `LogTransazioniPos` e `DataAck`, `uid_reservations`, `RedeemCodes` e procedure, `sp_eliminacliente`, `sp_ripristinacard`; cancella `Logs` più vecchi di 7 giorni a ogni avvio [V] `ECL_database.cls:100-222`, `1092-1096`; `Module1.bas:1003-1045`.
- **Nota:** la copia delle anagrafiche macchine dal cloud è disattivata "perché va in conflitto con il sincronismo" [V] `Module1.bas:1045`.
- **Peso:** M.

### W04-26 Partita su un gioco (lato DB, collegato)
- **Attore e innesco:** scheda del gioco (BE/BI) → servizio ECL → `INSERT` in `CoinlessDati`.
- **Passi:**
  1. `decodifica_flusso` verifica l'HMAC e chiama `decodifica_record` [V] `decodifica_flusso.sql`.
  2. Per i record con card (tipi 8, 13 da dispositivi via cavo; 19, 20, 22, 23 da BE, 20 e 23 "offline"): decodifica UID (8 caratteri), progressivo, saldo nuovo, costo partita, bonus, livello, data [V] `decodifica_record.sql:138-414`.
  3. Validazione: saldo nuovo ≤ ultimo saldo noto oppure progressivo nuovo; progressivo mai usato; card associata a un cliente. Se valida: `Clienti.Credito` = saldo nuovo, `INSERT CoinlessTransazioniCards`, `scriviTicketsAutomatici`. Altrimenti `CoinlessLogEventiBlacklist` e `CoinlessClonedCards` [V] `decodifica_record.sql:418-552`.
  4. `aggiornaCard` copia in `TransCard` con `NImp` nullo, `WinMt` = 0 (default), importi convertiti con `CreditToCurrency` [V] `aggiornaCard.sql`.
  5. `bannaUtente` su `CoinlessClonedCards`: `CoinlessCards.BlackList = 1`, `Clienti.F1 = 1`, `T1` = macchina, costo, saldo, id clonazione [V] `bannaUtente.sql`.
- **Anti-replay:** progressivo duplicato per cliente → blacklist; record provvisori (`FlagOpDaVerificare = 1`) sostituiti dalla conferma (tipo 23); ripresentazioni non confermate contate in `CoinlessCards.TentativiNonConfermati` fino alla soglia `setup2.MaxTentativiNonConfermati` (default 3) [V] `decodifica_record.sql:278-376`.
- **Peso:** L — fuori da WinMT, ma definisce il significato di metà delle righe di `TransCard`.

---

## 3. Significato delle colonne

### 3.1 `TransCard`

| Tabella.Colonna | Significato | Valori/codifiche | Evidenza | V/D |
|---|---|---|---|---|
| `TransCard.IdCli` | Cliente del movimento | `IdContatto` come testo, oppure `IdLong` se multilocale; `0` per lo svuotamento della cassa principale; **id operatore** per l'azzeramento cassa operatore | `ModAddNew.bas:1120`; `aggiornaCard.sql`; `frmCassa.frm:3451`, `3978` | V |
| `TransCard.NImp` | **Tipo di operazione** (non impianto) | NULL = partita su gioco; 0 cassa fissa; 1 totem; 2 cassa mobile; 3 vendita gettoni/scarico su totem; 4 carico per hopper vuoto (totem); 5 dobloni/gettoni (varianti Astoria/Albarella), "EXCHANGE"; 6 bonus (anche "SVUOTAMENTO" operatore); 7 svuotamento cassa; 8 rimborso al cliente (credito dato come bonus); 9 omaggio; 10 crediti trasferiti ad altra card; 11 crediti acquisiti; 12 crediti di servizio; 13 ricarica compleanno; 14 acquisto online; 15 bonus trasferiti ad altra card (il commento di `AddTransCard` dice "storno"); 16 bonus acquisiti; 18 abbonamento VIP; 19 riallineamento/conversione card; 20 riscrittura card | `ModAddNew.bas:1091-1110`, `1630`, `1650`; `frmInfoTransazioni.frm:385-402`; `FrmUCardECL.frm:1755`, `1766` | V |
| `TransCard.CodMac` | Origine del movimento | con `WinMt = 1`: nome computer della postazione (`Environ("computername")`); `'SVUOTAMENTO'`; con `WinMt = 0`: `EcsMacchine.CodMac` del gioco | `ModAddNew.bas:1121`; `aggiornaCard.sql`; `frmCassa.frm:3978` | V |
| `TransCard.Data` | Data e ora dell'operazione | da WinMT come testo `dd/mm/yyyy hh:nn:ss` (dipende dal `DATEFORMAT` del login); dai giochi data della BE o `GETDATE()` | `ModAddNew.bas:1122`; `decodifica_record.sql:380-402` | V |
| `TransCard.ValoreOperazione` | Importo dell'operazione in valuta | positivo per carichi, negativo per storni e ritiri; per le partite = costo partita convertito; per lo svuotamento = importo svuotato | `ModAddNew.bas:1123`; `aggiornaCard.sql`; `frmInfoTransazioni.frm:530-537` | V |
| `TransCard.ValoreFinale` | Saldo totale della card (crediti + bonus) in valuta **dopo** l'operazione | l'ultimo per `N0` è il saldo di riferimento del cliente | `ModAddNew.bas:1124`; `ECL_cliente.cls:397` | V |
| `TransCard.ValoreBonus` | Quota bonus | partite: bonus consumato; vendita gettoni: bonus scalato; altrimenti 0. Esiste solo nelle versioni con colonna (`valsets.IsBonusInTranscard`) | `aggiornaCard.sql`; `ModAddNew.bas:1696`; `Module1.bas:466` | V |
| `TransCard.F0` | Flag multilocale al momento della scrittura | 1 se `Setup(101).T6` indica multilocale | `ModAddNew.bas:1131` | V |
| `TransCard.T0` | Codice sala/impianto | `valsets.Nimp` su 4 cifre (es. `0001`) | `ModAddNew.bas:1130` | V |
| `TransCard.N0` | **Progressivo di transazione della card** (anti-replay) | ricarica: progressivo letto dopo la scrittura; riga bonus: progressivo − 1; ogni scrittura crediti+bonus avanza di 2; partite: progressivo della BE | `FrmCCard.frm:2846`, `2852`; `FrmUCardECL.frm:1737`; `decodifica_record.sql:165-172` | V |
| `TransCard.D0` | **Data di chiusura (svuotamento) della cassa** | NULL = movimento non ancora chiuso; valorizzata in blocco allo svuotamento: spiega le poche date distinte (DB 03 § 7) | `frmCassa.frm:3449`, `3976`; `frmRappCard.frm:2327` | V |
| `TransCard.Operatore` | Operatore che ha eseguito il movimento | id `Operatori`; `< 1000` postazione, `≥ 1000` totem | `Module1.bas:7-9`; `frmRappCard.frm:2011-2014` | V |
| `TransCard.ValoreCassa` | Parte dell'importo incassata in contanti | `ValoreOperazione − ValoreCassa` = parte POS; 0 = tutto POS (o operazione non monetaria); negativo nel ritiro card; nello svuotamento = importo; nell'azzeramento operatore = fondo cassa + importo | `FrmCCard.frm:2852`; `frmCassa.frm:2766`, `3071-3073` | V |
| `TransCard.WinMt` | Origine applicativa | 1 = operazione da postazione o totem (WinMT o totem); 0 = partita da gioco (trigger) | `Module1.bas:7-8`; `ModAddNew.bas:1127`; default `=(0)` | V |
| `TransCard.IDOperazione` | Chiave GUID del movimento | usata dallo storno per cancellare la riga | `frmInfoTransazioni.frm:778` | V |
| `TransCard.FlagOpDaVerificare` | Partita non ancora confermata dalla card | 1 = provvisoria (sostituita dalla conferma); NULL = confermata o movimento di cassa | `decodifica_record.sql:278-291`; `Module6.bas:2256` | V |

### 3.2 Tabelle coinless

| Tabella.Colonna | Significato | Valori/codifiche | Evidenza | V/D |
|---|---|---|---|---|
| `CoinlessTransazioniCards.cardid` | UID card troncato ai primi 8 caratteri esadecimali | `Clienti.T0 = cardid + '00000000'` | `decodifica_record.sql:179-190`; `aggiornaCard.sql` | V |
| `CoinlessTransazioniCards.TipoMovimento` | Tipo | sempre `'Scarico'` | `decodifica_record.sql:432` | V |
| `CoinlessTransazioniCards.SaldoCard`, `CostoPartita`, `Bonus` | Saldo dopo la partita, costo, bonus consumato | **unità card (centesimi)**, convertite in `TransCard` con `CreditToCurrency` | `aggiornaCard.sql` | V |
| `CoinlessTransazioniCards.LivelloCard` | Livello card | 0 Platinum, 1 Gold, 2 Silver, 3 VIP/Compleanno | `ECL_command.cls:394-420` | V |
| `CoinlessTransazioniCards.N0`, `FlagOpDaVerificare` | Progressivo card; provvisoria | come in `TransCard` | `decodifica_record.sql:427-441` | V |
| `CoinlessCards.BlackList` | Card bloccata sulle schede | 1 = blacklist (da `bannaUtente` o antifrode); azzerata da `sp_rimuovidabl` cancellando la riga | `bannaUtente.sql`; `decodifica_record.sql:367-369`; `sp_rimuovidabl.sql` | V |
| `CoinlessCards.SaldoUltimaRicarica`, `SaldoUltimaPresentazione` | Ultimo saldo noto | inizializzati all'ultimo saldo di `TransCard` alla prima partita; chi li aggiorna dopo non è in WinMT né nel DB | `decodifica_record.sql:226-232` | D |
| `CoinlessCards.TentativiNonConfermati`, `UltimoN0NonConfermato` | Contatore antifrode "RFID non scrivibile" | soglia `setup2.MaxTentativiNonConfermati` (3) | `decodifica_record.sql:351-376` | V |
| `CoinlessClonedCards.TipoMovimento`, `CodMac` | Origine della rilevazione | `'Scarico'` + macchina dal DB; `'Lettura'` + `'WinMt'` dalla cassa | `decodifica_record.sql:537-548`; `Module6.bas:2367` | V |
| `CoinlessClonedCards.cardid` | UID card | 8 caratteri dal DB, **16** dalla cassa: il trigger `bannaUtente` non trova la card né il cliente per le righe della cassa | `Module6.bas:2367`; `bannaUtente.sql` | D |
| `CoinlessLogEventiBlacklist.testo`, `cardid`, `data_operazione` | Diario di blacklist, sostituzioni e incoerenze | testo libero; usato anche per cercare la card (`LIKE`) | `ECL_cliente.cls:1227`; `Module6.bas:2368`; `sp_rimuovidabl.sql` | V |
| `CoinlessTestataHappyHour.giorno` | Giorno della settimana | −1 = ogni giorno; altrimenti indice della lista − 1, confrontato con `DATEPART(dw)`: possibile sfasamento di un giorno | `frmEclHH.frm:3965-3968`; `vs_CoinlessSpecialTimes.sql` | D |
| `CoinlessTestataHappyHour.ampm` | Mattino/pomeriggio | `'a'` se inizio < 13, `'b'` altrimenti | `frmEclHH.frm:3960-3964` | V |
| `CoinlessTestataHappyHour.dalle`, `alle`, `dal`, `al`, `attivo` | Fascia oraria `HH:MM`, periodo di validità, abilitazione | | `frmEclHH.frm:4535`; `vs_CoinlessSpecialTimes.sql` | V |
| `CoinlessTestataHappyHour.platinum`, `gold`, `silver`, `normal` | Prezzi HH predefiniti per livello | centesimi; `normal` = livello Compleanno (BDAY) | `frmEclHH.frm:4127-4130`, `3970` | V |
| `CoinlessTestataHappyHour.T0` | Nome del template grafico per le schede | default `HappyHours` | `frmEclHH.frm:4535`; vista (`nometemplate`) | V |
| `CoinlessMacchineHappyHour.perc_platinum`, `perc_gold`, `perc_silver`, `perc_normal` | **Prezzo** della partita in HH per livello (non percentuale) | centesimi; `perc_normal` = Compleanno | `frmEclHH.frm:3765`, `4453-4454` | V |
| `CoinlessMacchineHappyHour.device` | Dovrebbe essere il device della macchina | **contiene il prezzo Compleanno** (bug di `AddMaccHH`) | `frmEclHH.frm:4454` | V |
| `EcsMacchine.val_platinum`, `val_gold`, `val_silver`, `val_normal` | Costo partita normale per livello | centesimi; `val_normal` = Compleanno | `frmEclHH.frm:4083-4086` | V |

### 3.3 Clienti, operatori, setup

| Tabella.Colonna | Significato | Valori/codifiche | Evidenza | V/D |
|---|---|---|---|---|
| `Clienti.T0` | UID completo della card (16 caratteri) | i primi 8 = `CoinlessCards.cardid` | `Module1.bas:19`; `scriviTransazioneCard.sql` | V |
| `Clienti.Credito` | Saldo card (crediti + bonus) in **unità card** | aggiornato da cassa (`ValoreFinale / CentConversionFactor`) e da `decodifica_record` | `ModAddNew.bas:1135`; `decodifica_record.sql:423` | V |
| `Clienti.N0` | **Flag ticketless** della card | 0 ticket cartacei, 1 ticketless; 2 non spiegato. **Risponde a DB 04 § 5 e DB 06 § 4** | `FrmGenCard.frm:1976`; `frmVendiGettoni.frm:884` | V (0/1), D (2) |
| `Clienti.TipoCard` | Livello card | 0 Platinum, 1 Gold, 2 Silver, 3 Compleanno/VIP. **Risponde a DB 06 domanda 4** | `Module1.bas:754-757`; `Form1.frm:11678` | V |
| `Clienti.F1`, `T1`, `D1` | Card sospetta/clonata | `T1` valorizzato = blocco in cassa; `F1` ha significati opposti: 1 dal trigger `bannaUtente`, 0 da `MettiInBlackList`, 1 da `sp_rimuovidabl` | `bannaUtente.sql`; `Module6.bas:2366`; `sp_rimuovidabl.sql`; `Form1.frm:9214` | V |
| `Clienti.Foto` | **Attributi JSON**, non una foto | consensi (`checkProfiling`, …), riemissione card (`ReissueCard*`), rimborsi giornalieri, scadenza VIP | `ECL_cliente.cls:1129-1171` | V |
| `Operatori.N0` | Permessi a bitmask | 1 rimborsi, 2 omaggi, 4 azzeramento cassa totem, 8 carico crediti, 16 visualizzazione movimenti, 32 rimborso ticket; operatore 0 = tutti | `ECL_operatore.cls:211-218` | V |
| `Operatori.F0` | Abilitato ai crediti di servizio | | `ECL_operatore.cls:134` | V |
| `Operatori.Foto` | Limiti giornalieri in JSON | `MaxRefundsPerDay`, `MaxFreeTicketsPerDay`, `MaxServiceCreditsRefundsPerDay` (i controlli non sono implementati) | `ECL_operatore.cls:152-208`, `173-183` | V |
| `Setup.AdmPass` (101) | **Configurazione ECL**, non una password | `CodClienteECL`, `CodImpianto`, `CentConversionFactor`, `NomeMCM` (valuta), `CentsToTokenFactor`, flag simbolo valuta, etichetta moneta, etichetta gettoni, separati da `\|` | `Module1.bas:21-30`, `2735-2752`; `CreditToCurrency.sql` | V |
| `Setup.T10`, `T12` (101) | Scaletta bonus su ricarica: crediti, ticket | 8 coppie `soglia\|bonus` | `ECL_BonusHandler.cls:106-141` | V |
| `Setup.T11` (101) | Importi di ricarica proposti per il POS | 7 valori | `Module1.bas:174`, `3151` | V |
| `Setup.F9`, `F10` (101) | Scelta ticket/eticket | `F10` = eticket; `F9` = scelta lasciata al cliente | `Module1.bas:189-190`, `3156-3161` | V |
| `Setup.N10`, `N11`, `N13` | Modello POS, porta COM POS, copie scontrino | `N10`: 0 nessun POS, poi indice di `AvailablePosDevices` + 1; ≥ 5 = PosHandler TCP | `Module1.bas:2891-2894`; `FrmSetECL.frm:1755`, `2051` | V |
| `Setup.GCassa`, `VCassa` | Gestione cassa attiva; fondo cassa corrente | | `Module1.bas:5-6` | V |
| `Setup.CodEcs` | Tipo di sistema | `'ECL'` abilita il circuito coinless | `fn_is_ecl.sql`; `FrmSetECL.frm:2098` | V |
| `Setup.T6` (101) | Siti del gruppo multilocale | con `\|` → si usa `IdLong` invece di `IdContatto` | `fn_idcliente.sql`; `sp_rimuovidabl.sql` | V |
| `Setup.T8` (101), `T7` (102) | Wi-Fi ECL; connessione al server ECL | cifrati | `FrmSetECL.frm:2186-2197` | V |
| `setup2` (101) | Chiavi ECL | `AvailablePosDevices` (JSON), `PosTcpConfig`, `RitiroCard`, `VipSubscriptionParams`, `flagDropTicketsForGold`, `2NdScreenVersion`, `MaxTentativiNonConfermati` | `ECL_database.cls:27-90` | V |
| `setup2` (0) | Dispositivi di rete (GiallOne) | JSON con `ip`, `port`, `nomeservizio`, `nomedevice`, `macaddr` | `cls_GiallOne.cls:388-395` | V |
| `UID_Ammessi.UID`, `CodBar` | Card emesse e loro barcode | confronto sui primi 8 caratteri | `ECL_card.cls:31-56` | V |

### 3.4 Pagamenti e redeem

| Tabella.Colonna | Significato | Valori/codifiche | Evidenza | V/D |
|---|---|---|---|---|
| `LogTransazioniPos.Status` | Stato della transazione | `Pending`, `Completed`, `Recovered`, `Failed` | `LogTransazioniPos.cls:89`; `frmInfoPOS.frm:854` | V |
| `LogTransazioniPos.uidPOS` | UUID generato da WinMT, chiave verso PosHandler | | `FrmCCard.frm:3099` | V |
| `LogTransazioniPos.MName` | Dispositivo | `<modello>_<computer>` | `FrmCCard.frm:3105` | V |
| `LogTransazioniPos.N0` | Progressivo card dopo l'accredito | vuoto = mai caricata | `FrmCCard.frm:2867` | V |
| `LogTransazioniPos.IDTerm`, `AId`, `Appl`, `IC`, `PAN` | Ricevuta esercente, id transazione, ricevuta carta, `dtId`, PAN **mascherato** | da PosHandler | `frmInfoPOS.frm:819-839` | V |
| `LogTransazioniPos.DataAck` | Data del cambio di stato | | `LogTransazioniPos.cls:276` | V |
| `LogTransazioniTotem.tipo` | Mezzo di pagamento | `POS`, `Bill`, `Coin` | `LogTransazioniTotem.cls:63`, `120` | V |
| `LogTransazioniTotem.CAut` | POS: codice autorizzazione; contanti: **stato** | `Pending`, `Completed`, `Recovered` | `LogTransazioniTotem.cls:63-68`, `285` | V |
| `LogTransazioniTotem.TCC` | Contanti: progressivo della card caricata | | `LogTransazioniTotem.cls:151`, `268` | V |
| `LogTransazioniTotem.AC` | Contanti: UUID della sessione di pagamento | | `LogTransazioniTotem.cls:78`, `269` | V |
| `LogTransazioniTotem.DataOraChiusura`, `IdOperatore` | Scassettamento del totem | | `LogTransazioniTotem.cls:91-105` | V |
| `RedeemCodes.Azione` | Uso del codice | `new` (nuova card, cliente anonimo), `recharge` (cliente loggato) | `sp_redeem_check_and_reserve_no_pin.sql` | V |
| `RedeemCodes.Valore`, `Bonus`, `Tickets`, `CardLevel` | Contenuto del codice | valuta; livello come `TipoCard` | `FormCreaRedeem.frm:574-587` | V |
| `RedeemCodes.DbName` | Sala | `valsets.Nimp` | `Form1.frm:7833` | V |
| `RedeemCodes.Reserved*`, `Used*` | Prenotazione (5 minuti) e uso | post = `IdPost`, device = nome computer | `cls_RedeemManager.cls:105-107`, `227-228` | V |
| `RedeemCodes.QRCode` | Immagine JPEG del QR | da servizio esterno | `cls_RedeemManager.cls:560`, `597` | V |

### 3.5 Ticket (scritture di questa zona)

| Tabella.Colonna | Significato | Valori/codifiche | Evidenza | V/D |
|---|---|---|---|---|
| `Tickets.MangiaT` | Bit di origine/stato | 64 = bonus ticket su ricarica; 512 = passato ad altra card; 8256 (= 8192 + 64) = ticket automatici da partita | `FrmCCard.frm:2876`; `FrmUCardECL.frm:2286`; `scriviTicketsAutomatici.sql` | V (64, 512, 8256), D (significato di 8192) |

---

## 4. Regole, calcoli e comportamenti notevoli

### 4.1 Modello dei valori sulla card
- Sulla card ci sono **due saldi monetari separati**, crediti e bonus, in "centesimi" (unità card), più un contatore di **punti/ticket**, il **livello** e il **progressivo** [V] `ECL_command.cls:201-213`.
- `CentConversionFactor` (default 0,01) converte unità card → valuta; `CentsToTokenFactor` (default 1) converte unità card → "crediti/token" mostrati sui lettori: 1 token = `CentsToTokenFactor` centesimi [V] `ECL_Conversioni.cls:23-109`; `Module1.bas:24-26`. Esempio: con 0,01 e 10, 5 € = 500 unità = 50 token [D]. Questo risponde alla domanda del glossario sul rapporto token/crediti.
- Il saldo spendibile è crediti + bonus; i giochi consumano entrambi e riportano il bonus consumato [V] `decodifica_record.sql:271`.
- Ordine di consumo **non uniforme**: la vendita gettoni scala prima i crediti [V] `frmVendiGettoni.frm:1021-1038`; l'unione card trasferisce prima il bonus [V] `FrmUCardECL.frm:1715-1729`; il ritiro card rimborsa solo i crediti [V] `frmInfoTransazioni.frm:530-537`.
- I **ticket** non sono sulla card nella tabella `TransCard`: vivono in `Tickets`/`Clienti.Tickets` (con ticketless) o sulla card come "Punti" [V/D].

### 4.2 Bonus su ricarica
- Scaletta di 8 soglie in `Setup(101).T10` (bonus crediti) e `T12` (bonus ticket); se `T12` manca usa le soglie di `T10` con bonus 0 [V] `ECL_BonusHandler.cls:90-141`.
- Calcolo **avido**: finché resta importo, prende la soglia più alta ≤ residuo, somma il suo bonus e sottrae la soglia [V] `ECL_BonusHandler.cls:20-43`. Esempio con soglie 10→1 e 20→3: ricarica 50 € → 20 + 20 + 10 → bonus 3 + 3 + 1 = 7 [D].
- Per i compleanni la scaletta viene sostituita al volo con un rapporto minimo crediti/bonus ricavato dal MCD (`recalcForBirthday`) [V] `ECL_BonusHandler.cls:230-274`.
- Il bonus è scritto in `TransCard` come riga separata `NImp 6` con `N0` = progressivo − 1, senza contante (`ValoreCassa = 0`) [V] `FrmCCard.frm:2846`.

### 4.3 La primitiva `AddTransCard` e il calcolo dei saldi
- Ogni movimento di cassa passa da `AddTransCard`: `INSERT TransCard` + `UPDATE Clienti SET Credito = ValoreFinale / CentConversionFactor WHERE T0 = …`, **senza transazione** e con SQL composto a stringa [V] `ModAddNew.bas:1086-1147`.
- Il saldo del cliente si ricava in due modi [V] `ECL_cliente.cls:390-427`; `ModAddNew.bas:1370-1520`:
  - **saldo** = `ValoreFinale` dell'ultima riga per `N0` (eventualmente solo verificate);
  - **crediti** = somma `NImp` (0, 1, 2, 13, 14, 11) con `WinMt = 1` − somma `NImp` (NULL, 10, 18); **bonus** = somma `NImp` (8, 9, 6, 16) − `ValoreBonus` delle partite − `NImp 15`.
  Le somme ignorano `NImp` 3, 5, 7, 12, 19, 20; `RiallineaCreditiBonus` riporta crediti e bonus a coerenza col saldo [V] `ModAddNew.bas:1149-1200`.
- Ordine delle operazioni in cassa: **prima la card, poi il DB**. Se il DB fallisce la card è già scritta; c'è un tentativo di riallineamento a posteriori [V] `FrmCCard.frm:2899-2900`.

### 4.4 Progressivo e anti-replay
- Il progressivo `CntProg` è mantenuto dalla card/lettore; WinMT lo legge dopo ogni scrittura e lo registra in `TransCard.N0` [V].
- Lato DB una partita è accettata se il progressivo non è già usato per il cliente e se il saldo non cresce (o il progressivo avanza); in caso contrario la card va tra le clonate [V] `decodifica_record.sql:418-552`.
- Lato cassa la verifica confronta card e `TransCard` con le regole di W04-04; dalla quarta lettura incoerente consecutiva sulla stessa postazione la card va in blacklist [V] `Module6.bas:2355-2380`.
- La blacklist arriva alle schede tramite il servizio ECL (`jrefreshBlacklist`, push MQTT) [V] `Module6.bas:2427`; `decodifica_record.sql:344-346`.

### 4.5 Cassa e canali di pagamento
- Contante e POS si distinguono solo con `ValoreCassa` (contante) e `ValoreOperazione − ValoreCassa` (POS) [V] `frmCassa.frm:2766`.
- Postazione e totem si distinguono con `NImp` (0/2 contro 1) e con `Operatore` (< 1000 contro ≥ 1000) [V].
- La chiusura di cassa non crea una sessione: marca le righe con `D0` e aggiunge una riga `NImp 7` [V] `frmCassa.frm:3449-3455`.

### 4.6 Happy hour e tariffe per livello
- Prezzo partita per livello in `EcsMacchine.val_*`; in happy hour, per le macchine in `CoinlessMacchineHappyHour`, `perc_*` sostituisce il prezzo [V] `vs_CoinlessSpecialTimes.sql`; `scriviTicketsAutomatici.sql`.
- I nomi `perc_*` sono fuorvianti: contengono **prezzi** in centesimi [V] `frmEclHH.frm:3764-3765`.

### 4.7 Ticketless e ticket automatici
- Il flag ticketless è in `Clienti.N0` ed è riscritto sulla card a ogni `Set_CredBonus` [V].
- `EcsMacchine.CntrLet15` > 0 genera ticket automatici a ogni partita (riga `Tickets` con `MangiaT 8256`), < 0 aggiorna solo i contatori; con una promozione attiva, `setup2.flagDropTicketsForGold = true` e la card in `promozioni_cards`, i ticket automatici non vengono dati se il prezzo Gold (in happy hour o normale) è 0 [V] `scriviTicketsAutomatici.sql`.

### 4.8 Redeem: VB6 contro DB
- VB6 crea e chiama le procedure **con parametri OUTPUT** (`@ErrKey`, `@OutCodice`, `@OutPin`) [V] `ECL_database.cls:1490-1545`; `cls_RedeemManager.cls:108`, `185`, `245`, `364-366`.
- Nel DB di test `check_and_reserve`, `verify_pin`, `confirm` e `cancel` sono la versione "B4X/JDBC" che **restituisce una riga** e non ha OUTPUT; `sp_redeem_create` è rimasta con OUTPUT [V] `sp_redeem_*.sql`.
- Con le versioni B4X, la chiamata VB6 passerebbe un parametro inesistente (`@ErrKey`) e andrebbe in errore, oppure `CheckRedeem` leggerebbe la riga anche in caso di errore e darebbe esito positivo [D]. Inoltre WinMT, all'avvio su un DB con versione < 20260219, riscrive le procedure con la propria versione [V] `Module1.bas:1035`; `ECL_database.cls:1452`.
- La logica originale di `sp_redeem_verify_pin` **esiste** nel codice VB6 (`ECL_database.cls:1523-1537`), contrariamente al commento della versione di test che la dice "dedotta".

### 4.9 Configurazione distribuita
- Il codice usa un servizio HTTP del server di sala (`:58889/eclcommand`) per blacklist e pagine grafiche [V], un DB centrale `CoinlessDB` in cloud per le definizioni dei report [V], e un servizio pubblico esterno per generare i QR [V] `cls_RedeemManager.cls:560`.

---

## 5. Problemi rilevanti per il nuovo disegno

1. **Saldo in quattro posti:** card (crediti, bonus, progressivo), `TransCard` (ultimo `ValoreFinale`), `Clienti.Credito`, `CoinlessCards`. Le regole di prevalenza sono nel codice di cassa e in `decodifica_record`. Il nuovo modello deve scegliere una fonte di verità (registro dei movimenti) e trattare la card come cache firmata, con riconciliazione esplicita.
2. **`TransCard.NImp` è un tipo di operazione**, mentre in altre tabelle `NImp` è l'impianto; il codice 6 è usato anche per lo svuotamento operatore con `IdCli` = operatore; 15 ha due significati nei commenti. Serve un'enumerazione dei tipi di movimento e un'entità *sessione di cassa* al posto di `D0`.
3. **Movimenti cancellati fisicamente** (storno, pulizie in `sp_rimuovidabl`/`sp_ripristinacard`, provvisorie): il registro economico non è append-only.
4. **Identità della card in tre formati** (8 caratteri in coinless, 16 in `Clienti.T0`, 16 nelle righe di cassa di `CoinlessClonedCards`) e cliente identificato ora da `IdContatto`, ora da `IdLong`.
5. **Semantica di `Clienti.F1` contraddittoria** tra trigger, cassa e procedure; il blocco effettivo in cassa è `T1` valorizzato.
6. **Logica divisa tra VB6, trigger/procedure e servizio ECL (B4J)**, con versioni divergenti delle stesse procedure (redeem). Il requisito "logica una sola volta, lato server" è oggi violato su card, saldi e redeem.
7. **Scritture non transazionali e dipendenti dalla lingua** (date come testo, decimali con `Val`/`Str`), con rischio di doppio accredito (analisi `frmInfoPOS`, rischi 1-6).
8. **Pagamenti:** `LogTransazioniPos` e `LogTransazioniTotem` hanno schemi diversi per la stessa cosa e campi riusati (`CAut` come stato, `TCC` come progressivo, `AC` come UUID). Il nuovo disegno richiede un'unica entità *pagamento* con stato, idempotenza e collegamento al movimento card.
9. **Offline:** la cassa scrive la card anche se poi il DB fallisce; senza server il recupero e la verifica antifrode non funzionano. Da decidere quale parte della verifica card deve funzionare senza cloud (in sala sì, verso il cloud no).
10. **Credenziali e dipendenze esterne nel codice:** credenziali scritte nel codice in `FrmReportsECL.frm:1244-1246` e `FormCreaRedeem.frm:531-533`; il codice redeem viene inviato a un servizio QR pubblico.

---

## 6. Domande aperte per il team

1. Chi crea le righe `TransCard` con `NImp 12` (crediti di servizio) e con `Operatore ≥ 1000` (totem)? Il servizio ECL, il totem o entrambi?
2. `Clienti.N0 = 2`: esiste una terza modalità ticketless?
3. Il codice impianto sulla card (`Cod_Impianto` cliente/sede) impedisce l'uso della card in un'altra sala del gruppo? Come funziona oggi il multilocale con card di sale diverse?
4. Il progressivo avanza davvero di 2 a ogni `Set_CredBonus` e di 1 a ogni partita? È gestito dal firmware del lettore o dalla card?
5. Le procedure redeem in produzione sono le versioni VB6 (OUTPUT) o B4X (riga di risultato)? WinMT e totem le usano entrambi?
6. `CoinlessTestataHappyHour.giorno`: quale convenzione (0 = domenica? 1 = domenica?) e la vista applica il giorno giusto?
7. `CoinlessCards.SaldoUltimaRicarica`/`SaldoUltimaPresentazione`/`DataUltima*`: chi li aggiorna e a cosa servono?
8. Il ritiro card (bonus perso, crediti restituiti in contanti) e lo storno con cancellazione fisica sono comportamenti voluti, da mantenere?
9. `MettiInBlackList` scrive `F1 = 0` mentre `bannaUtente` scrive `F1 = 1`: qual è il significato corretto di `F1`?
10. La generazione dei QR tramite servizio esterno è accettata (privacy, disponibilità senza internet)?
11. Il GiallOne è un prodotto in uso nelle sale o un prototipo? È lo stesso "micrototem" citato in `TransCard.CodMac`?
