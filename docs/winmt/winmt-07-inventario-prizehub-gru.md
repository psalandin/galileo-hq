# Galileo HQ — WinMT 07: Inventario, PrizeHub e gru

**Stato:** bozza · **Responsabile:** Piero · **Aggiornato:** 2026-10-23

**Fonte:** sorgente VB6 di WinMT (copia del 24/07/2026), file: `FrmInventario.frm`, `FrmInventario2.frm`, `cls_inventario.cls`, `cls_rigainventario.cls`, `FrmScegliInv.frm`, `Frm6W.frm`, `frmEditPrizeHub.frm`, `FormModificaPrezziGru.frm`, `WinMtPH/clsCRC.cls`; procedure `sp_crane_*`, `PrizeHub_MoveToSlot` e vista `vs_CraneStatus` in `sql/codice-db/test/applicativo/` · **Collegati:** [`winmt-00-mappa.md`](winmt-00-mappa.md), [`../db/db-02-catalogo.md`](../db/db-02-catalogo.md), [`../db/db-01-schema.md`](../db/db-01-schema.md), [`../db/db-07-confronto-test-produzione.md`](../db/db-07-confronto-test-produzione.md), manuale § "Inventario", § "Andamento Premi in 6 settimane"

Legenda: **[V]** verificato nel codice (con riferimento `file:riga`), **[D]** dedotto, da confermare.

---

## 1. Perimetro

| File | Righe di codice | Ruolo | Lettura |
|------|----------------:|-------|---------|
| `FrmInventario.frm` | 3.423 | Inventario premi **attivo**: calcolo della giacenza teorica, conteggio, salvataggio, consultazione degli inventari precedenti, stampa ed esportazione; usato anche dal "Ricalcolo" di `frmpremi` | A fondo: `Form_Load`, `cmdSave_Click`, `GrdInv_KeyPress`, `MnuVisInv_Click`, `CalIncas`, `SettaTotDiff`, `Form_Activate`, `BarRd_OnComm`. Scorsi: `CmdStampaR_Click`, `CmdExp_Click` (stampa ed export, nessuna scrittura su DB) |
| `FrmInventario2.frm` | 2.479 | Seconda versione dell'inventario, basata su tabelle SQL e JSON. **Non raggiungibile**: si apre solo se `valsets.IsJsonInventory`, che è forzato a `False` all'avvio | Confrontata con la prima (§ 2, W07-06) |
| `cls_inventario.cls` | 1.040 | Classe di supporto della versione 2: SQL per generare l'inventario teorico, tabella di lavoro, salvataggio in JSON | A fondo |
| `cls_rigainventario.cls` | 38 | Struttura dati di una riga d'inventario (versione 2) | A fondo |
| `FrmScegliInv.frm` | 42 | Scelta dell'inventario precedente da visualizzare | A fondo |
| `Frm6W.frm` | 757 | Rapporto "Tendenza dello stock in 6 settimane" (*6 Weeks Stock Trend*) | A fondo `PopLstV`; export e stampa scorsi |
| `frmEditPrizeHub.frm` | 1.210 | Gestione del PrizeHub (distributore automatico di premi): consultazione degli slot, carico, forzatura del valore medio in ticket. Scrive **solo tramite API HTTP** del servizio di sala | A fondo |
| `FormModificaPrezziGru.frm` | 520 | "Cranes editor": stato dei tre slot delle gru e forzatura del valore medio del premio | A fondo |
| `WinMtPH/clsCRC.cls` | 378 | Libreria generica CRC16/CRC32 (di terzi, 2000). **Non è legata al PrizeHub**: serve ai protocolli seriali di lettori card e POS | Scorsa; verificato l'uso |

Fuori file, letti quanto basta: `frmpremi.frm` (punti d'ingresso e ricalcolo giacenze), `Module6.bas` (`UpdateQty`, `Field2File`, `File2Field`, `UltimoInv`), `ModAddNew.bas` (`AddDiffer`, `AddVincita`), `FrmCont.frm` e `FrmInc.frm` (scrittura di `Incassi`), `FrmMovmag.frm` (liste remote in `RiepInv`), `Module1.bas` (commenti sulle codifiche, CRC), `Form1.frm` e `FrmEcs.frm` (menu), `frmWrapp.frm` (rilettura degli inventari nel rapporto profitti).

---

## 2. Flussi

### W07-01 Esecuzione e salvataggio dell'inventario premi

- **Attore e innesco.** Operatore dal magazzino premi (`frmpremi`, pulsante "Inventario" `CmdInv_Click`, `frmpremi.frm:2207`). Se `Setup.AbOrInv` è attivo, è ammesso un solo inventario al giorno (controllo su `RiepInv`, `frmpremi.frm:2211`) [V]. Il salvataggio richiede la password di un operatore autorizzato.
- **Passi.**
  1. Apertura (`FrmInventario.Form_Load`, `FrmInventario.frm:4318`). Svuota la tabella `inv` del file Access locale `inv.mdb` nella cartella del programma [V `:4553-4567`].
  2. Fissa l'istante di riferimento `Adesso`: oggi all'ora `Setup.OrInv` se `AbOrInv` è attivo, altrimenti l'istante di apertura [V `:4587-4591`].
  3. Legge l'ultimo inventario: `select top 1 data, D0, mdb from riepinv where F0=0 order by data desc`. `DataMax` = `RiepInv.Data`. Estrae il blob `Mdb` nel file `VInv.mdb` e lo apre come "ultimo inventario" [V `:4604-4616`].
  4. Carica i movimenti successivi: `MovMag` e `MovOut` con `data > DataMax` (limite superiore commentato), `Vincite` con `D0 > DataMax and D0 < Adesso and Cons = 1` [V `:4636-4648`].
  5. Per ogni articolo di `Premi` (solo attivi se `Setup.NoInatt`), scrive una riga in `inv` con: quantità iniziale, carichi e scarichi per causale, venduto, quantità presunta, costo, ticket (§ 4.1) [V `:4649-4935`].
  6. L'operatore inserisce la quantità contata nella colonna "Q.tà Reale" (tastiera o lettore barcode che legge prima il codice articolo e poi i codici numerici "NUMx" e "CONFE" stampati con l'utilità "Stampa Numeri") [V `BarRd_OnComm`, `:1500-1638`]. A ogni conferma: `qdiff = contato − qpres`, `qreal = contato`, ricalcolo dei totali in eccedenza e in ammanco [V `:3106-3107`, `SettaTotDiff` `:5548`]. Facoltativa la "Q.tà Macchine" (`qmacc`), solo informativa (§ 4.1).
  7. "Salva Inventario" (`cmdSave_Click`, `:3300`): richiede almeno una modifica, poi la password (§ 4.4). Avvisa di non consegnare premi per alcuni secondi [V `:3321`].
  8. Per ogni riga con `qreal ≠ Premi.Quantita`: `UPDATE premi SET quantita = qreal` (`UpdateQty`, `Module6.bas:1427`) [V `:3335-3346`].
  9. Se `Setup.RegInc`: calcola gli incassi del periodo da `Incassi` e scrive il riepilogo economico nella tabella `riepilogo` **del file Access**, non nel DB (§ 4.3) [V `:3350-3399`].
  10. Sottrae da `Premi.Quantita` i premi vinti dopo l'istante di riferimento: una unità per ogni riga di `Vincite` con `data >= Adesso` [V `:3403-3436`].
  11. Scrive una riga in `Differ` (`AddDiffer`) con la data dell'inventario e il valore delle differenze [V `:3438`, `ModAddNew.bas:1015`].
  12. Inserisce in `RiepInv` una riga con `Data = Adesso`, `D0 = Now` (fine inventario) e `Mdb` = **intero file `inv.mdb`** (`File2Field`) [V `:3443-3451`].
- **Dati.**

  | Tabella.colonna | Operazione |
  |-----------------|------------|
  | `Premi.Codice, CodOr, Id, Descrizione, Costo, N_Tickets, Fornitore, Gru, Quantita, Attivo` | Lettura |
  | `RiepInv.Data, D0, Mdb, F0` | Lettura (ultimo inventario) e inserimento |
  | `MovMag.Codice, Motivo, Quantita, Data` · `MovOut.Codice, Motivo, Quantita, Data` | Lettura |
  | `Vincite.Codice, Data, D0, Cons, Costo` | Lettura |
  | `Prenotaz.DataCon, Cons` | Letta ma non usata (logica commentata) |
  | `Incassi.Data, Red, Gru, Alt, Push` | Lettura (se `RegInc`) |
  | `Operatori.Password, Livello` | Lettura (autorizzazione) |
  | `Premi.Quantita` | **Aggiornamento** (`UPDATE` diretto) |
  | `Differ.Data, VarVal, NImp` | Inserimento |
  | File locale `inv.mdb`: tabelle `inv`, `riepilogo` | Scrittura, poi copiato nel blob `RiepInv.Mdb` |

- **Regole.** Formule in § 4.1. Parametri di Setup: `AbOrInv`, `OrInv`, `NoInatt`, `Inv0`, `InvPass`, `RegInc`, `TRed/TGru/TPus/TAlt`, `N3` (nasconde la colonna macchine), `numcommBR` (porta del lettore barcode).
- **Periferiche.** Lettore barcode su seriale (`SerComm`), suoni di conferma. Richiede il driver ODBC/Jet di Access sulla postazione. Nessuna logica offline: lavora sul DB di sala.
- **Peso: L.** Molte tabelle, calcolo per articolo e per causale, file Access intermedio, aggiornamento massivo delle giacenze, riepilogo economico e varianti di Setup.
- **Evidenze:** `FrmInventario.frm:4318-5049` (`Form_Load`), `:3069-3233` (`GrdInv_KeyPress`), `:3300-3477` (`cmdSave_Click`), `:5466-5492` (`CalIncas`), `:5548-5575` (`SettaTotDiff`); `frmpremi.frm:2207-2258`.

### W07-02 Pausa dell'inventario e correzione dei movimenti

- **Attore e innesco.** Operatore, durante il conteggio: seleziona uno o più articoli (clic sul bordo sinistro della griglia, riga blu), preme "Pausa", corregge carichi o scarichi nelle finestre del magazzino, poi riapre l'inventario [V `GrdInv_Click` `:2972`, `CmdPause_Click` `:2454`]. Procedura descritta anche nel manuale.
- **Passi.** 1. `CmdPause` nasconde la finestra e torna a `frmpremi` (il lettore barcode passa a quella finestra). 2. L'operatore registra i movimenti mancanti (altra zona). 3. Alla riattivazione (`Form_Activate`, `:2653`) rilegge `Premi`, `MovMag`, `MovOut`, `Vincite` e ricalcola carichi e scarichi **solo degli articoli selezionati**, aggiornando la tabella `inv` [V].
- **Dati.** Lettura come W07-01; scrittura solo nel file `inv.mdb`.
- **Regole.** L'inventario resta aperto in memoria e nel file locale: è un inventario "al volo", senza fermare le consegne.
- **Periferiche.** Lettore barcode (passaggio di porta tra form).
- **Peso: M.** Ricalcolo parziale con regole uguali a W07-01.
- **Evidenze:** `FrmInventario.frm:2653-2950`, `:2454-2461`.

### W07-03 Consultazione di un inventario precedente

- **Attore e innesco.** Operatore da `frmpremi` ("Visualizza Inventario", `frmpremi.frm:3892`) o dal menu della finestra inventario; in WinMtHQ è l'unica modalità ammessa (la finestra non permette di salvare) [V `FrmInventario.frm:5017-5021`].
- **Passi.** 1. `FrmScegliInv` elenca `RiepInv.Data` con `F0=0` [V `FrmScegliInv.frm:113`]; l'inventario precedente nell'elenco dà la data d'inizio del periodo (`DataPre`). 2. Estrae il blob `RiepInv.Mdb` nel file `VInv.mdb` dei Documenti e lo apre con Jet [V `FrmInventario.frm:5155-5192`]. 3. Ricostruisce griglia, totali di eccedenze e ammanchi, carichi e scarichi per causale; legge la tabella `riepilogo` del file per gli incassi e i valori [V `:5397-5415`]. 4. Se il file ha righe con costo o ticket a zero, le cancella dal file e riapre [V `:5428-5437`].
- **Dati.** `RiepInv.Data, F0, Mdb` (lettura); file `VInv.mdb` (lettura, piccole correzioni).
- **Peso: M.** Una tabella sola, ma richiede di estrarre ed aprire un database Access contenuto in un blob.
- **Evidenze:** `FrmInventario.frm:5117-5445`; `FrmScegliInv.frm:84-124`.

### W07-04 Stampa, esportazione e sommario economico dell'inventario

- **Attore e innesco.** Operatore, pulsanti "Lista vuota/Foglio di conteggio" (`CmdStampaV`), "Stampa inventario" (`CmdStampaR`), "Mostra sommario" (`CmdVisSom`), "Stampa sommario" (`CmdStpSum`), "Esporta" (`CmdExp`).
- **Passi.** 1. Il foglio di conteggio stampa codice, descrizione e ticket con uno spazio per la quantità contata. 2. Il sommario ricalcola gli incassi del periodo (`CalIncas`, lettura `Incassi`) e mostra: totali presunto, reale, effettivo, valore giacenze, differenze, costo del venduto e degli scarichi per causale, incassi lordi e netti per categoria, "Rendimento" Redemption, Gru, Ruspe, "Incidenza" consumabili e guasti, indici di pagamento e di profitto, "Profitto attuale" (§ 4.3). 3. L'export produce un file Excel o CSV (e un `…Summ.csv` col sommario); in WinMtHQ "Cloud" va nella cartella Documenti\Exports.
- **Dati.** `Incassi.Data, Red, Gru, Alt, Push`, `Operatori.Cognome, Nome` (intestazione); nessuna scrittura su DB.
- **Periferiche.** Stampante di sistema; Excel tramite automazione COM se presente.
- **Peso: M.** Nessuna scrittura, ma formule economiche da riprodurre e diverse tra lingue (§ 4.3).
- **Evidenze:** `FrmInventario.frm:2463-2632`, `:3479-4316`, `:1660-2435`.

### W07-05 Ricalcolo delle giacenze senza inventario

- **Attore e innesco.** Operatore da `frmpremi`, pulsante "Ricalcolo" (`CmdRefr_Click`, `frmpremi.frm:2648`), dopo un avviso che l'operazione può danneggiare l'archivio se non esiste un inventario valido.
- **Passi.** 1. Imposta `Ricalcola = True` e carica `FrmInventario` senza mostrarla: `Form_Load` costruisce l'inventario teorico (W07-01, passi 1–5) con `Adesso = Now`. 2. Per ogni articolo, `UPDATE premi SET quantita = qreal`, dove `qreal` = quantità presunta (nessun conteggio). 3. Nessuna riga in `RiepInv` o `Differ` [V `frmpremi.frm:2665-2697`].
- **Dati.** Lettura come W07-01; aggiornamento `Premi.Quantita`.
- **Regole.** È la prova che la giacenza **può essere ricostruita** come "ultimo inventario + movimenti successivi": l'ultimo inventario fa da snapshot di partenza.
- **Peso: M.** Riusa W07-01, ma riscrive tutte le giacenze.
- **Evidenze:** `frmpremi.frm:2648-2697`.

### W07-06 Inventario versione 2 (SQL e JSON) — non attivo

- **Attore e innesco.** Come W07-01, ma solo se `valsets.IsJsonInventory = True`; il valore è forzato a `False` all'avvio e non viene mai cambiato [V `Module1.bas:743`; uniche altre occorrenze `frmpremi.frm:2230`, `:3895`]. In questa copia il flusso **non è raggiungibile**.
- **Passi (come scritti nel codice).** 1. Se esistono inventari in formato Access (`RiepInv.F0=0` e `N1` nullo o 10), li converte: estrae il file, lo trasforma in JSON e sovrascrive `RiepInv.Mdb` con il JSON, `N1 = 1` [V `cls_inventario.cls:151-216`; in WinMtHQ l'estrazione avviene sul server con `sp_OACreate 'ADODB.Stream'` nella cartella `C:\sqltemp`, `:285-326`]. 2. Crea, se manca, la tabella fisica `UltimoInventario` e la riempie con l'ultimo inventario JSON (`OPENJSON`) [V `:648-775`]. 3. Genera in una sola query la tabella fisica `TempTableInventario_<idoperatore>` con giacenza iniziale, carichi e scarichi per causale e venduto [V `:503-627`, `:628-636`]. 4. Ogni conteggio aggiorna la riga (`qmacc`, `qdiff`, `qreal`) [V `:1185-1199`]. 5. Il salvataggio fa `UPDATE Premi SET quantita = qreal` in un'unica istruzione e inserisce in `RiepInv` una riga con `Data = GETDATE()`, `F0 = 0`, `N1 = 1`, `Mdb` = JSON della tabella (`FOR JSON AUTO`) [V `:1247-1284`].
- **Differenze rispetto alla versione 1.**

  | Aspetto | Versione 1 (`FrmInventario`, attiva) | Versione 2 (`FrmInventario2` + `cls_inventario`, non attiva) |
  |---------|--------------------------------------|---------------------------------------------------------------|
  | Area di lavoro | File Access locale `inv.mdb` | Tabelle SQL `TempTableInventario_<id>` e `UltimoInventario`, create a runtime |
  | Contenuto di `RiepInv.Mdb` | File `.mdb` intero | JSON in `varbinary`, `N1 = 1` |
  | Ultimo inventario | `riepinv … order by data desc` | `getDatamax` senza `ORDER BY` (riga arbitraria) [V `cls_inventario.cls:328-344`]; `apriUltimoInventario` invece ordina |
  | Venduto (`qvend`) | Righe di `Vincite` con `Cons=1`, filtrate su `D0` (data consegna) | Righe di `Vincite` filtrate su `Data`, senza `Cons` |
  | Causali dei movimenti | Testo della lingua corrente | Italiano o inglese (`'CARICO' or 'LOAD'`…), francese escluso |
  | Filtro articoli inattivi (`NoInatt`) | Sì | No |
  | Riepilogo economico, `Differ`, correzione per vincite dopo `Adesso` | Sì | **No** |
  | Visualizzazione inventari precedenti | Sì | Codice interamente commentato |
  | Giacenza a fine inventario | `UPDATE` riga per riga | Un solo `UPDATE … FROM` |

- **Peso: M** (se riattivato: logica già scritta in SQL, ma incompleta).
- **Evidenze:** `FrmInventario2.frm:3717-4201`, `:2841-2872`, `:4284-4612`; `cls_inventario.cls` per intero.

### W07-07 Andamento premi in 6 settimane

- **Attore e innesco.** Operatore da `frmpremi`, menu `Mnu6W` (`frmpremi.frm:3328`). "6W" = *6 Weeks*: il titolo della finestra è "Tendenza dello Stock in 6 Settimane" / "6 Weeks Stock Trend" [V `Frm6W.frm:368`, `:673`].
- **Passi.** 1. L'operatore sceglie la data di fine periodo e l'ordinamento. 2. Per ogni premio (solo attivi se `NoInatt`), conta le righe di `Vincite` con `Data` nei 42 giorni precedenti, divise in 6 settimane. 3. Mostra uscita media settimanale (= righe / 6), giacenza (`Premi.Quantita`), settimane coperte (= giacenza / media, 999 se media nulla) e le uscite delle singole settimane. 4. Stampa o export Excel/CSV.
- **Dati.** Lettura `Premi.Codice, Descrizione, N_Tickets, Quantita, Costo, Attivo`, `Vincite.Codice, Data`.
- **Regole.** Ogni riga di `Vincite` vale un pezzo; non filtra consegnate, annullate o prenotate [V `Frm6W.frm:1139`].
- **Peso: S.** Rapporto in sola lettura, una query per articolo.
- **Evidenze:** `Frm6W.frm:1084-1216`, `:444-594`.

### W07-08 Carico di uno slot del PrizeHub

- **Attore e innesco.** Operatore da `Form1`, menu "Prize HUB" (`mnuPrizeHub_Click`, `Form1.frm:9835`), pulsante "Carica" o lettura del barcode dell'articolo.
- **Passi.** 1. Legge la configurazione degli hub da `setup2` (prima prova una tabella `Setup1`) con `IdPost = 101` e `Chiave LIKE 'PrizeHub%'`; il valore è un JSON con `hubId`, `hubName`, `containers[{type, range, unit}]` [V `frmEditPrizeHub.frm:1101-1140`, `:1245-1331`]. Senza configurazione usa tre contenitori: `CAPSULE` A1–A18, `SPINDLE` B1–B14, `LOCKER` C1–C10 [V `:1264-1271`]. 2. Mostra gli slot da `PrizeHubSlots` uniti a `Premi` e le posizioni libere (slot attivi con `qtaDisp > 0` = occupati) [V `:717-774`, `:1345-1404`]. 3. Risolve il codice letto su `Premi.Codice` o `Premi.CodOr` (attivi, esclusi i codici `SPINDLE<n>-…`) [V `:823-851`]. 4. Chiede lo slot (una sola posizione, validata sulla configurazione: il tipo di contenitore viene dalla posizione) e la quantità (1 fisso per `LOCKER`) [V `:776-821`, `:862-891`]. 5. Verifica `Premi.Quantita >= quantità` [V `:936-950`]. 6. Chiama l'API del servizio di sala: login `GET /app/action/login/key/<chiave>` (token tenuto 23 ore), poi `POST /app/action/SVCPHLOADSLOT` con `{hubid, slot, tipo, codArticolo, qtyAdd, operatore, unit}` [V `:1425-1493`]. 7. Ricarica la griglia.
- **Dati.** Lettura `PrizeHubSlots.*`, `Premi.Codice, CodOr, Descrizione, N_Tickets, Quantita, Attivo`, `setup2.Chiave, Valore`. **Nessuna scrittura diretta**: le scritture le fa il servizio dietro l'API [V]. Cosa scriva (`PrizeHubSlots`, `Premi.Quantita`, movimenti) non è visibile da qui [D].
- **Periferiche e rete.** Lettore barcode seriale (le periferiche di `Form1` vengono chiuse e riaperte, `:1891-1923`); HTTP verso `http://<server SQL>:58889` (stesso host del DB, porta fissa) [V `:1418-1423`]. Senza servizio raggiungibile il carico fallisce con messaggio. La chiave applicativa dell'API è una credenziale scritta nel codice (`frmEditPrizeHub.frm:560`).
- **Peso: L.** Dispositivo, configurazione JSON, validazione delle posizioni, integrazione API con autenticazione.
- **Evidenze:** `frmEditPrizeHub.frm:776-934`, `:1014-1140`, `:1245-1508`; `Form1.frm:9835-9863`.

### W07-09 Forzatura e ripristino dei ticket medi di uno slot SPINDLE

- **Attore e innesco.** Operatore, doppio clic sulla colonna "ticket medi" (forza) o "forzato" (ripristina) di una riga di tipo `SPINDLE` [V `frmEditPrizeHub.frm:967-980`].
- **Passi.** 1. Chiede il valore intero dei ticket medi. 2. `POST SVCPHSETTICKETSMEDI {hubid, slot, valore, operatore, unit}`, oppure `POST SVCPHRESET_TICKETSMEDI` per tornare al calcolo automatico [V `:1495-1508`]. 3. Ricarica.
- **Dati.** Effetto atteso su `PrizeHubSlots.ticketsMedi` e `ticketsMediaForzata` [D: scritti dal servizio].
- **Regole.** Solo gli spindle hanno un valore medio: uno spindle contiene premi diversi e il prezzo in ticket è una media; capsule e locker no [D, coerente con il controllo sul tipo].
- **Peso: S.** Una chiamata API per azione.
- **Evidenze:** `frmEditPrizeHub.frm:982-1012`, `:1495-1508`.

### W07-10 Consultazione e scelta del PrizeHub

- **Attore e innesco.** Operatore all'apertura della finestra o cambiando hub nella combo.
- **Passi.** Elenco degli hub da `setup2` (`PrizeHub%`), lettura della configurazione, griglia degli slot con unità, slot, tipo, codice, descrizione, quantità disponibile, ticket medi, forzato, ticket di listino (`Premi.N_Tickets`), giacenza magazzino (`Premi.Quantita`), ultimo aggiornamento e autore. "Salva" ricarica soltanto (non salva nulla) [V `:600-605`].
- **Dati.** Lettura `PrizeHubSlots`, `Premi`, `setup2`.
- **Peso: S.** Consultazione.
- **Evidenze:** `frmEditPrizeHub.frm:576-590`, `:658-774`, `:1014-1099`.

### W07-11 Editor gru: stato degli slot e forzatura del valore medio

- **Attore e innesco.** Operatore da `Form1` (`mnuCraneManager_Click`, visibile solo se esiste la tabella `CraneCounterSyncLog`, `Form1.frm:13647-13651`) o da `FrmEcs` (`mnuCranesEditor_Click`, `FrmEcs.frm:5812`).
- **Passi.** 1. Elenca le macchine non dismesse (`EcsMacchine.DataDis IS NULL`) dei tipi `Type.TypeName` in 'Crane', 'Instant Redemptions', 'Dispenser', 'Merchandise' [V `FormModificaPrezziGru.frm:750-785`]. 2. Se esiste `GruMagazzinoDettaglio`, per ciascuno dei tre slot mostra quantità corrente, valore medio, ultimo carico (`GruMovimenti` di tipo `LOAD` più recente: premio, quantità, valore unitario, data) e la differenza tra valore medio e valore dell'ultimo carico; altrimenti mostra `EcsMacchine.ValIn6/7/8` [V `:460-644`]. 3. L'operatore modifica `N0` o il valore medio di uno slot (anche incollando da Excel). 4. "Salva": per i valori medi modificati chiama `sp_crane_force_avg_value`; `N0` va in `EcsMacchine` con `UPDATE` diretto [V `:851-915`].
- **Dati.**

  | Tabella.colonna | Operazione |
  |-----------------|------------|
  | `EcsMacchine.Tipo, CodMac, NomMac, N0, DataDis, ValIn6, ValIn7, ValIn8` · `Type.Id, TypeName` | Lettura |
  | `GruMagazzinoDettaglio.QtyCurrent, AvgValue` · `GruMovimenti.*` (solo `LOAD`) | Lettura |
  | `EcsMacchine.N0` | Aggiornamento diretto |
  | Tramite `sp_crane_force_avg_value`: `GruMagazzino` (inserimento se manca), `GruMagazzinoDettaglio` (inserimento slot 1–3 se mancano; `AvgValue`, `UpdatedAt`), `GruMovimenti` (inserimento `ADJUST+`, `Qty = 0`), `EcsMacchine.ValIn6/7/8` (copia dei valori medi) | Scrittura |

- **Regole.** Valore medio ≥ 0, slot 1–3; la forzatura registra un movimento `ADJUST+` con quantità invariata e `AvgValueBefore/After` [V `sp_crane_force_avg_value.sql`]. **Difetto:** per gli slot 2 e 3 la form chiama la procedura con slot 1 e con il valore dello slot 1 [V `FormModificaPrezziGru.frm:887`, `:895`]; l'operatore non viene passato (`@Oper = 0`).
- **Peso: M.** Tre tabelle del modulo gru più `EcsMacchine`, procedura transazionale lato DB, griglia con incolla massivo.
- **Evidenze:** `FormModificaPrezziGru.frm:460-644`, `:851-950`; `sql/codice-db/test/applicativo/procedure/sp_crane_*.sql`.

---

## 3. Significato delle colonne

| Tabella.Colonna | Significato | Valori / codifiche | Evidenza | |
|-----------------|-------------|--------------------|----------|---|
| `RiepInv.F0` | Tipo di record: **la tabella ha due usi** | 0 = inventario; 1 = lista premi (KitPremi) inviata da WinMtHQ per il carico remoto in sala | `Module1.bas:44`; `FrmInventario.frm:4604`; `FrmMovmag.frm:4372-4426` | [V] |
| `RiepInv.Data` | F0=0: istante di riferimento dell'inventario (`Adesso`: ora prefissata del giorno o apertura della finestra); F0=1: data della lista | datetime | `FrmInventario.frm:3447`, `:4587-4591` | [V] |
| `RiepInv.D0` | F0=0: istante di **fine** inventario (salvataggio); NULL negli inventari precedenti al 10/11/2017. F0=1: istante del carico della lista; NULL = lista ancora da caricare | datetime / NULL | `FrmInventario.frm:3448`, `:4607-4611`; `FrmMovmag.frm:4396`; `Form1.frm:17181` | [V] |
| `RiepInv.Mdb` | **File Access intero dentro il DB.** F0=0: `inv.mdb` con le tabelle `inv` (righe d'inventario) e `riepilogo` (valori economici); F0=1: file `KitPremi` da caricare. Nella versione 2 contiene invece JSON | `varbinary(max)` | `FrmInventario.frm:3449`, `:5155`; `FrmMovmag.frm:4373`; `cls_inventario.cls:1253-1270` | [V] |
| `RiepInv.T0` | F0=1: nome della lista remota mostrato all'operatore (es. `<locale>_<ddmmyyhhmmss>`) | testo | `FrmMovmag.frm:4372`, `:4430`; esempio commentato `cls_inventario.cls:210` | [V] |
| `RiepInv.N1` | Formato di `Mdb` per gli inventari (solo versione 2) | NULL o 10 = file Access; 1 = JSON | `cls_inventario.cls:113`, `:204`, `:1266` | [V] |
| `RiepInv.T1`, `RiepInv.F1` | Usati solo come filtro nella versione 2 (`t1 is null`, `f1=0`) | ? | `cls_inventario.cls:300`, `:670` | [D] significato ignoto |
| `RiepInv.VVend … TotPer, QDiff, VarVal, NImp` | **Non scritte** dal codice attivo: sono le colonne della tabella `riepilogo` interna al file Access (con nomi in parte diversi: `VConS`, `vpush`, `IncPus`, `PusPer`), il cui contenuto resta nel blob. Risponde alla domanda aperta: le colonne SQL sono un residuo | sempre NULL dal flusso attivo | `FrmInventario.frm:3351-3399` contro `:3443-3451` | [V] |
| `Differ.Data` | Istante di riferimento dell'inventario (`DataInv`) | datetime | `FrmInventario.frm:3438` | [V] |
| `Differ.VarVal` | Valore a costo delle differenze d'inventario, **in valore assoluto**: eccedenze + ammanchi (`VEs − VMan`, con `VMan` negativo). Nel riepilogo dentro il file è invece il netto (`VEs + VMan`) | decimal | `FrmInventario.frm:3398`, `:3438`, `:5548-5575` | [V] |
| `Differ.NImp` | Numero d'impianto della sala (`valsets.Nimp`) | int | `ModAddNew.bas:1024` | [V] |
| `Differ` (uso) | Nessuna lettura in WinMT: una riga per inventario, letta forse da HQ | — | ricerca su tutto il sorgente | [D] |
| `UltimoInventario.*` | Tabella di lavoro della versione 2, creata e svuotata a runtime: l'ultimo inventario JSON espanso in righe. Stesse colonne della tabella `inv` del file Access | vedi righe seguenti | `cls_inventario.cls:648-775` | [V] |
| `inv.qini` / `UltimoInventario.qini` | Quantità iniziale = quantità contata (`qreal`) all'inventario precedente, cercata per codice o per `CodOr`; 0 se l'articolo è nuovo; `Premi.Quantita` al primo inventario | int | `FrmInventario.frm:4656-4675` | [V] |
| `inv.qagg` | Quantità caricata nel periodo (`MovMag`, causale CARICO/LOAD) | int | `:4684-4694` | [V] |
| `inv.qtrasin`, `qgrui`, `qconi`, `qevei`, `qpushi` | Entrate per trasferimento (SPOSTA), da gru (GRU), consumabili, eventi, ruspe (`MovMag.Motivo`) | int | `:4697-4765` | [V] |
| `inv.qtrasout`, `qguasta`, `qgruo`, `qcono`, `qeveo`, `qpusho` | Uscite per trasferimento, guasto, verso gru, consumabili, eventi, ruspe (`MovOut.Motivo`) | int | `:4768-4870` | [V] |
| `inv.qvend` | Premi consegnati nel periodo: **numero di righe** di `Vincite` con `Cons=1` e `D0` nel periodo (una riga = un pezzo). Sostituisce il valore da `MovOut` VENDUTI | int | `:4879-4884` | [V] |
| `inv.qpres` | Quantità presunta (giacenza teorica) = `qini + entrate − uscite − qvend` | int | `:4914` | [V] |
| `inv.qreal` | Quantità reale: inizialmente = `qpres`, poi il valore contato. Gli articoli non contati restano uguali al teorico, anche con `Inv0` (che azzera solo la cella mostrata) | int | `:4915`, `:4975-4979`, `:3107` | [V] |
| `inv.qdiff` | Variazione = contato − presunto (negativo = ammanco) | int | `:3106` | [V] |
| `inv.qmacc` | Quantità dichiarata "nelle macchine": solo informativa, non entra in `qreal` né in `qdiff` | int | `:3083-3094` | [V] |
| `inv.dos` | Giorni di autonomia = `qreal / (qvend / giorni dall'ultimo inventario)`; 999 se nessuna vendita | decimal | `:4929-4933` | [V] |
| `inv.Gru` | Copia di `Premi.Gru`; non usata nei calcoli | bit | `:4922` | [V] |
| `inv.key`, `inv.oper`, `inv.data`, `NBolla`, `foto` | Operatore (`idx`) e data dell'inventario; `key` = 1 fisso nella versione 2; `NBolla`, `foto` vuoti | — | `:4927-4928`; `cls_inventario.cls:521-531` | [V] |
| `Premi.Quantita` | Giacenza di magazzino. A fine inventario diventa la quantità contata, meno i premi vinti dopo l'istante di riferimento; nel "Ricalcolo" diventa la quantità presunta | int | `FrmInventario.frm:3335-3436`; `frmpremi.frm:2681-2683` | [V] |
| `Premi.Costo`, `Premi.N_Tickets` | Costo d'acquisto e prezzo in ticket. Profitto % = `(N_Tickets/100 − Costo) × 100 / Costo` (1 ticket = 0,01 €); costo zero blocca l'inventario | money, decimal | `FrmInventario.frm:4953`, `:5035-5045` | [V] |
| `Premi.CodOr` | Codice originale / barcode del fornitore: chiave alternativa per lettore barcode, inventario precedente e PrizeHub | testo | `:1582`, `:4661`; `frmEditPrizeHub.frm:830-836` | [V] |
| `MovMag.Motivo` | Causale del carico, **scritta nella lingua dell'interfaccia** | IT: CARICO, SPOSTA, GUASTO, GRU, CONSUMABILI, EVENTI, RUSPE; EN: LOAD, TRANSFER, WASTE, CRANES, CONSUMABLES, EVENTS, PUSHERS; FR: CHARGE, TRANSFERT, GRUES, CONSOMMABLES, ÉVÉNEMENTS, PUSHERS; anche `PRIZEHUB` | `FrmInventario.frm:4383-4491`; `PrizeHub_MoveToSlot.sql` | [V] |
| `MovOut.Motivo` | Causale dello scarico, nella lingua dell'interfaccia | IT: VENDUTI, SPOSTA, GUASTO, GRU, CONSUMABILI, EVENTI, RUSPE; EN: SOLD, TRANSFER, WASTE, CRANES, CONSUMABLES, EVENTS, PUSHERS; FR: VENDU, TRANSFERT, DÉCHETS, GRUES, …; anche `PRIZEHUB` | idem | [V] |
| `Vincite.D0` | Data di consegna del premio (valorizzata alla consegna immediata) | datetime | `ModAddNew.bas:48`; `FrmInventario.frm:4647` | [V] |
| `Vincite.Cons` | Premio consegnato | 1 = consegnato | `FrmInventario.frm:4647` | [V] |
| `Incassi.F0` | Origine del record | 0 = registrazione manuale degli incassi (`FrmInc`); 1 = incasso da lettura contatori (`FrmCont`, "EcsNet") | `Module1.bas:42`; `FrmCont.frm:10733-10744`; `FrmInc.frm:740` | [V] |
| `Incassi.Mdb` | F0=1: **file Access** `Incas.mdb` della lettura contatori. Risponde alla domanda aperta: sì, i file Access viaggiano nel DB (e, essendo `Incassi` e `RiepInv` sincronizzate, anche verso il cloud) | `varbinary(max)` | `FrmCont.frm:10744`, `:10724` | [V] |
| `Incassi.Red`, `Gru`, `Alt`, `Push` | Incassi lordi per categoria: Redemption; Gru (e Instant Redemption); Altri (videogiochi, flipper); Ruspe | money | `FrmInc.frm:740-743`; manuale § "Registra Incassi" | [V] |
| `Setup.TRed`, `TGru`, `TPus`, `TAlt` | Aliquota IVA per categoria d'incasso, per calcolare l'incasso netto (`lordo / (1 + T/100)`) | % | `FrmInventario.frm:5488-5491`; `Module1.bas:2139-2142` | [V] |
| `Setup.AbOrInv`, `OrInv` | Ora prefissata dell'inventario; con `AbOrInv` anche un solo inventario al giorno | bit, `hh:mm` | `FrmInventario.frm:4587`; `frmpremi.frm:2211` | [V] |
| `Setup.Inv0` | Colonna "Q.tà Reale" mostrata a zero all'apertura (non cambia `qreal`) | bit | `FrmInventario.frm:4974` | [V] |
| `Setup.InvPass` | Anche un manager (`Livello ≤ 1`) può chiudere l'inventario; altrimenti solo `Livello 0` | bit | `FrmInventario.frm:2437-2452` | [V] |
| `Setup.RegInc` | Calcolo del riepilogo con gli incassi al salvataggio e nel sommario | bit | `:3350` | [V] |
| `Setup.N3` | Nasconde la colonna "Q.tà Macchine" (`HideQMacc`) | 0 / 1 | `Module1.bas:69` | [V] |
| `Operatori.Livello` | Livello dell'operatore per l'autorizzazione | 0 = amministratore, 1 = manager | `FrmInventario.frm:2446` | [D] codifica |
| `setup2.Chiave`, `Valore` (IdPost 101) | Configurazione dei PrizeHub: chiave `PrizeHub<nn>`, valore JSON `{hubId, hubName, containers:[{type, range, unit}]}` | type ∈ CAPSULE, SPINDLE, LOCKER; range tipo `A1-A18` | `frmEditPrizeHub.frm:1131-1140`, `:1287-1323` | [V] |
| `PrizeHubSlots.hubId` | Hub (distributore) | int, da `setup2` | `frmEditPrizeHub.frm:733` | [V] |
| `PrizeHubSlots.unit` | Unità (modulo fisico) dell'hub che contiene lo slot | ≥ 1, da `containers[].unit` | `:886` | [V] |
| `PrizeHubSlots.slot` | Posizione: lettera del contenitore + numero | `A1…A18`, `B1…B14`, `C1…C10` (predefiniti) | `:1264-1271` | [V] |
| `PrizeHubSlots.tipo` | Tipo di contenitore | `CAPSULE`, `SPINDLE`, `LOCKER` (locker = 1 pezzo) | `:806-812` | [V] |
| `PrizeHubSlots.codArticolo` | Codice premio (`Premi.Codice`) | testo | `:733` | [V] |
| `PrizeHubSlots.qtaDisp` | Pezzi presenti nello slot; > 0 = slot occupato | int | `:1372` | [V] |
| `PrizeHubSlots.ticketsMedi`, `ticketsMediaForzata` | Prezzo medio in ticket dello slot (spindle) e flag di valore forzato a mano | int, bit | `:744-750`, `:967-1012` | [V] uso, [D] calcolo |
| `PrizeHubSlots.attivo`, `updatedAt`, `updatedBy` | Slot attivo (NULL = attivo); ultimo aggiornamento e operatore | — | `:733`, `:765` | [V] |
| `GruMagazzino.CodMac`, `Enabled` | Una riga per gru gestita a magazzino; `Enabled` non usato da WinMT | — | `sp_crane_ensure_records.sql`, `sp_crane_list.sql` | [V] |
| `GruMagazzinoDettaglio.SlotNo` | Slot della gru, sempre 1, 2, 3; corrisponde ai contatori `In6`, `In7`, `In8` | 1–3 | `sp_crane_sync_ecsmacchine_values.sql` | [V] |
| `GruMagazzinoDettaglio.QtyCurrent`, `AvgValue` | Pezzi presenti nello slot e valore medio unitario del premio (in €) | int, decimal(18,4) | `FormModificaPrezziGru.frm:494-518` | [V] |
| `GruMagazzinoDettaglio.LastLoadDate`, `LastWinDate` | Data dell'ultimo carico e dell'ultima vincita | datetime | `vs_CraneStatus.sql` | [D] chi li scrive |
| `GruMovimenti.MovementType` | Tipo di movimento | `LOAD`, `UNLOAD`, `WIN`, `ADJUST+`, `ADJUST-` (vincolo CHECK); WinMT scrive solo `ADJUST+` come forzatura del valore medio con `Qty = 0` | `sp_crane_force_avg_value.sql` | [V] |
| `GruMovimenti.Qty`, `UnitValue` | Pezzi del movimento e valore unitario (nel `LOAD`: valore del premio caricato; nell'`ADJUST+`: nuovo valore medio) | — | idem; `FormModificaPrezziGru.frm:469-485` | [V] |
| `GruMovimenti.AvgValueBefore/After`, `QtyBefore/After` | Stato dello slot prima e dopo il movimento | — | idem | [V] |
| `GruMovimenti.PrizeCode`, `PrizeDesc` | Premio caricato (catalogo proprio, non sempre in `Premi`) | — | `db-03` § 3; idem | [V] |
| `EcsMacchine.ValIn6`, `ValIn7`, `ValIn8` | Per le gru: valore unitario del premio degli slot 1, 2, 3, copiato da `GruMagazzinoDettaglio.AvgValue` | € | `sp_crane_sync_ecsmacchine_values.sql` | [V] |
| `EcsMacchine.N0` | Modificabile nell'editor gru; in generale "numero di gettoni o monete sul piatto o nell'hopper" | int | `FormModificaPrezziGru.frm:869-873`; `Module1.bas:38` | [D] nel contesto gru |
| `EcsMacchine.Tipo` | Tipi gestiti come gru dalle procedure | 3, 9, 12, 17 (la vista e `sp_crane_list` per gli slot solo 3) | `sp_crane_*.sql`, `vs_CraneStatus.sql` | [V] valori, [D] corrispondenza con 'Crane', 'Instant Redemptions', 'Dispenser', 'Merchandise' |
| `CraneCounterSyncLog.DeltaIn6/7/8` | Incrementi dei contatori premi degli slot gru elaborati da un servizio esterno; la sola esistenza della tabella abilita il menu gru | int | `Form1.frm:13647` | [D] |

---

## 4. Regole, calcoli e comportamenti notevoli

### 4.1 Giacenza teorica, conteggio e differenze

Per ogni articolo, nel periodo tra l'inventario precedente (`DataMax`) e l'istante di riferimento (`Adesso`):

```
qpres = qini
      + qagg + qtrasin + qgrui + qconi + qevei + qpushi        (MovMag per causale)
      − qtrasout − qguasta − qgruo − qcono − qeveo − qpusho     (MovOut per causale)
      − qvend                                                  (righe di Vincite consegnate)
qdiff = contato − qpres
Valore in eccedenza = Σ qdiff·Costo (qdiff > 0)   Valore mancante = Σ qdiff·Costo (qdiff < 0)
```

- **La giacenza teorica non è `Premi.Quantita`**: è ricostruita da snapshot + movimenti. `Premi.Quantita` viene solo confrontata (cella grigia se diversa) e poi sovrascritta [V `FrmInventario.frm:4971`, `:3335-3346`].
- **Fine inventario.** `Premi.Quantita := qreal`, poi `− (righe di Vincite con Data ≥ Adesso)`: l'inventario si considera "scattato" all'istante di riferimento e le consegne avvenute durante il conteggio vengono scalate [V `:3403-3436`]. Carichi e scarichi registrati durante il conteggio non sono invece riconciliati (il filtro sui movimenti non ha limite superiore) [V `:4638-4641`].
- **Articoli non contati** = uguali al teorico [V].
- **Q.tà macchine** (premi già messi nelle gru o nelle macchine) è registrata a parte e non cambia la giacenza [V].
- **Carico con causale GUASTO** (indice 2 della lista carichi) non è conteggiato in nessuna colonna [V `:4677-4767`: manca il `Case 2`]; in francese la lista dei carichi ha 6 voci invece di 7 e gli indici si spostano [V `:4479-4491`].
- **Un pezzo = una riga di `Vincite`**: la quantità della consegna non è considerata [V `:4879`].

### 4.2 Snapshot dell'inventario

L'inventario salvato non esiste come righe nel DB: è un **file Access dentro `RiepInv.Mdb`**. Per rileggerlo (consultazione, inventario successivo, rapporto profitti di `frmWrapp.frm:3321-3336`) bisogna estrarre il file e aprirlo con Jet. Il file è protetto da una password scritta nel codice (`FrmInventario.frm:4553`, `:4613`, `:5178`, `:5190`; `cls_inventario.cls:88`, `:228`). La versione 2 lo sostituisce con un JSON, sempre in un blob.

### 4.3 Legame tra inventario e incassi

Con `Setup.RegInc`, l'inventario somma gli incassi lordi registrati in `Incassi` tra l'inventario precedente e quello attuale (tutte le righe, senza filtro su `F0`), ne ricava il netto con le aliquote di Setup e calcola:

| Indicatore | Formula (salvata in `riepilogo` del file) | Note |
|------------|-------------------------------------------|------|
| `redper` "Rendimento Redemption" | costo dei premi venduti × 100 / incasso lordo Redemption | Nel sommario a video: su incasso **netto** |
| `gruper` "Rendimento Gru" | costo scaricato verso le gru × 100 / incasso lordo gru | Sommario inglese: (scarichi − carichi gru) / netto |
| `PusPer` "Rendimento Ruspe" | costo scaricato verso le ruspe × 100 / incasso lordo ruspe | Sommario a video usa per errore lo scarico **eventi** [V `:3969`, `:4268`] |
| `conper` | Identico a `redper` | Probabile errore [V `:3387`] |
| `rotper` "Incidenza guasti" | costo dei guasti / incasso netto totale | Senza × 100 |
| `totper` | (venduto + gru + guasti + consumabili + venduto) × 100 / (incasso red + gru + ruspe) | Il venduto è sommato due volte [V `:3396`] |
| `VarVal` | eccedenze + ammanchi (netto) | In `Differ` va il lordo |
| "Profitto attuale" (solo a video) | incasso netto totale − costo di tutti gli scarichi + differenza di valore | |

Gli incassi entrano quindi nell'inventario come **dato manuale per categoria** (`FrmInc`), non dalla telemetria delle macchine. Nel DB di produzione `Incassi`, `RiepInv`, `Differ` sono vuote (`Q01Prod`): questa parte non è in uso a Central Park, coerentemente con il magazzino fermo dal 2024.

### 4.4 Autorizzazione

Chiusura dell'inventario con la password di un operatore di livello 0, o ≤ 1 se `InvPass`, oppure con una "super password" letta da `Setup` (credenziale, `Module1.bas:215`) [V `FrmInventario.frm:2437-2452`]. Il confronto avviene sul client decifrando tutte le password degli operatori.

### 4.5 PrizeHub

- WinMT è un **client sottile**: legge `PrizeHubSlots`, `Premi` e la configurazione, ma ogni modifica passa dall'API REST del servizio di sala (porta 58889, autenticazione con chiave applicativa e token *bearer*). È il modello già coerente con l'architettura futura [V].
- Tipi di contenitore: **CAPSULE** (capsule, molti pezzi), **SPINDLE** (spirale/asta con premi in sequenza, prezzo medio in ticket, forzabile), **LOCKER** (armadietto, un pezzo) [V tipi e vincoli; D descrizione fisica].
- Esiste nel DB una procedura più vecchia, `PrizeHub_MoveToSlot`, che modella lo slot come **articolo virtuale in `Premi`** (codice `<slot>_<tipo>_PH<hub>`) con un trasferimento `MovOut`/`MovMag` causale `PRIZEHUB`. WinMT non la chiama; l'esclusione dei codici `SPINDLE<n>-…` nella ricerca articoli è un'altra traccia di quel modello [V `frmEditPrizeHub.frm:836`]. Due modelli coesistono.
- `clsCRC` (cartella `WinMtPH`) è un CRC16-CCITT (polinomio 0x1021, valore iniziale 0) usato per le trame seriali di lettori card e POS (`CalcolaCRC16`/`CheckCRC16` in `Module1.bas:3863-3897`, usati da `frmAstoria`, `frmCardFamily`, `FrmCCard`, `FrmCCardAlba`, `FrmSetECL`, `frmsetSys`) [V]. Non riguarda il PrizeHub.
- La licenza HASP ha un prodotto "Prize Hub" (`PrizeHubKey`, `Module1.bas:1384`) [V]; il menu PrizeHub non risulta condizionato da questo flag in `Form1` [D].

### 4.6 Gru

- Modello: una gru ha **tre slot** (premi diversi), ognuno con quantità e **valore medio unitario**. Il valore medio è copiato in `EcsMacchine.ValIn6/7/8`, cioè nel valore unitario dei contatori premi 6–8, per valorizzare i premi erogati nei rapporti di resa [V copia; D uso nei rapporti].
- **Calcolo del valore medio.** Nel codice disponibile (WinMT e procedure del DB) esiste solo la **forzatura manuale**. `LOAD`, `UNLOAD`, `WIN` e `ADJUST-` non sono scritti né da WinMT né da procedure o trigger del DB: li produce un altro componente [V per assenza]. Formula attesa, da confermare: al `LOAD` media ponderata `AvgAfter = (QtyBefore·AvgBefore + Qty·UnitValue) / (QtyBefore + Qty)`; al `WIN` quantità −1 con media invariata [D].
- `CraneCounterSyncLog` (incrementi dei contatori 6–8) fa pensare che le vincite `WIN` siano generate dai contatori della scheda [D]. In produzione il log ha 11.963 righe, `GruMagazzino` 9 e `GruMagazzinoDettaglio` 27, ma `GruMovimenti` è **vuota** [V `Q01Prod`]: il flusso carico/vincita non risulta usato.
- Incoerenze tra procedure: `sp_crane_ensure_records` accetta i tipi 3, 9, 12, 17; `sp_crane_list` crea gli slot solo per il tipo 3; la vista `vs_CraneStatus` mostra solo il tipo 3; la form filtra per nome del tipo [V].

---

## 5. Problemi rilevanti per il nuovo disegno

1. **Snapshot in blob Access/JSON.** Gli inventari non sono interrogabili, dipendono da Jet a 32 bit e da una password nel codice. Il nuovo modello deve avere testata e righe d'inventario come tabelle, con causale di rettifica per articolo.
2. **Giacenza come campo sovrascritto.** `Premi.Quantita` è aggiornata da vendite, inventario e ricalcolo; la rettifica d'inventario non genera movimenti per articolo (solo un totale in `Differ`). Il codice però dimostra che la giacenza si ricostruisce da snapshot + movimenti: è la base per un modello a movimenti.
3. **Causali in lingua.** `MovMag.Motivo` e `MovOut.Motivo` contengono il testo localizzato: un inventario fatto in una lingua non vede i movimenti scritti in un'altra. Servono codici di causale.
4. **"Venduto" definito in tre modi** (inventario v1: `Vincite` consegnate per data consegna; v2 e 6 settimane: tutte le righe per data vincita; quantità ignorata). Va definito una volta, lato server.
5. **Concorrenza.** Nessuna transazione; l'operatore viene invitato a non consegnare premi durante il salvataggio. Il nuovo sistema deve fissare l'istante dello snapshot e riconciliare in modo transazionale tutti i movimenti successivi, non solo le vincite.
6. **`RiepInv` ha due usi** (inventari e liste premi da HQ): da separare. Le colonne economiche SQL sono vuote.
7. **Indicatori economici** con errori e formule diverse tra salvataggio e sommario (§ 4.3): da ridefinire, non da copiare.
8. **Gru**: valore medio duplicato in due tabelle; logica di carico e vincita fuori da WinMT e dal DB; difetto sugli slot 2–3 nella forzatura; tipi incoerenti.
9. **PrizeHub**: buon modello (client sottile + API), ma configurazione JSON in `setup2`, chiave API nel codice, URL derivato dal nome del server SQL, controllo di giacenza non transazionale, due modelli di slot (tabella dedicata contro articoli virtuali), `PrizeHubSlots` non sincronizzata.
10. **Inventario v2 dormiente**: se riattivato convertirebbe tutti i blob in JSON e la versione 1 (e `frmWrapp`) non li leggerebbe più.

---

## 6. Domande aperte per il team

1. Quale componente scrive i movimenti `LOAD`, `UNLOAD`, `WIN`, `ADJUST-` delle gru, e con quale formula aggiorna `AvgValue`? Da dove arriva `CraneCounterSyncLog`?
2. Perché in produzione `GruMovimenti` è vuota mentre il log dei contatori gru è popolato? Il magazzino gru è in uso?
3. Cosa scrive il servizio PrizeHub (porta 58889, postazione `prizehub-reloaded` in `AuditLog`) a fronte di `SVCPHLOADSLOT`: `PrizeHubSlots`, `Premi.Quantita`, `MovOut`/`MovMag`? Come calcola `ticketsMedi`?
4. `PrizeHub_MoveToSlot` e gli articoli virtuali `…_PH<n>` sono ancora usati in qualche sala?
5. L'inventario JSON (v2) è abbandonato o da completare? Esistono sale con `RiepInv.N1 = 1`?
6. In quali sale l'inventario si fa davvero con WinMT? A Central Park `RiepInv` e `Differ` sono vuote: dove si fa l'inventario?
7. Chi legge `Differ` (HQ?) e con quale significato di `VarVal`?
8. Cosa rappresenta `EcsMacchine.N0` nell'editor gru (etichetta tradotta non disponibile)?
9. Corrispondenza tra gli id di `Type` 3, 9, 12, 17 e i nomi 'Crane', 'Instant Redemptions', 'Dispenser', 'Merchandise'.
10. Significato di `RiepInv.T1` e `RiepInv.F1`.
11. La registrazione manuale degli incassi per categoria (`FrmInc`), base dei rendimenti d'inventario, è ancora usata? Il manuale la segnala come forse deprecata.
