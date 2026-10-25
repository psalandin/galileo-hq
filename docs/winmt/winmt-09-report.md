# Galileo HQ — WinMT 09: Rapporti e statistiche

**Stato:** bozza · **Responsabile:** Piero · **Aggiornato:** 2026-10-23

**Fonte:** sorgente VB6 di WinMT (copia del 24/07/2026), file: `frmrapp.frm`, `FrmRappUs.frm`, `frmWrapp.frm`, `cls_reports.cls`, `FrmRappDis.frm`, `frmSelezionaStampante.frm`, `FrmInDat.frm`, `FormStampaReport.frm`; letti in parte `Module6.bas` (`ContaTickets`), `API.bas` (`IdTicket`), `ModAddNew.bas` (`AddVincita`, `AddScon`), `Module1.bas` (note sui campi jolly, `NetSites`, `SqlDB`), `frmpremi.frm` e `Form1.frm` (menu), `sql/codice-db/test/applicativo/` (`fn_decode_mt_bitmask`, `scriviTicketsAutomatici`) · **Collegati:** `docs/fonti/winmt-manuale.md` (§ 17, § 18.10–18.15, "Rapporti vari", "Rapporti per amministratori"), `docs/db/db-01-schema.md`, `docs/db/db-02-catalogo.md`, `docs/db/db-03-risultati-01.md` (§ 6, `NImp`), `docs/db/db-05-produzione-01.md`, `docs/db/db-07-confronto-test-produzione.md`

Legenda: **[V]** verificato nel codice (`file:riga`); **[D]** dedotto, da confermare.

---

## 1. Perimetro

| File | Righe di codice | Ruolo | Lettura |
|------|----------------:|-------|---------|
| `frmrapp.frm` | 3524 | Finestra **"Rapporto"** (da `Form1`, menu *Rapporto*) e **"Rapporto Vendite"** (da Magazzino premi → Rapporti). Titolo inglese "Sales Report" / "Daily report". È il rapporto principale descritto nel manuale (§ 17) | A fondo: `AggDati`, filtri, `SistemaChips`, riquadri punti, `Form_Load`. Stampa ed esportazione scorse |
| `FrmRappUs.frm` | 2784 | **"Rapporto Breve Utente"** ("User Summary Report"). "Utente" = **operatore**, non cliente. È una copia più vecchia di `frmrapp` con un algoritmo di conteggio diverso | Confrontato con `frmrapp` riga per riga su `AggDati`; resto scorso |
| `frmWrapp.frm` | 1503 | **"Rapporto Settimanale"** e, con il flag `Variaz`, **"Rapporto Variazioni"**. Unico rapporto con incassi, costi di magazzino, profitto lordo e indici di payout | A fondo: `AggDati`, `Form_Load`. Stampa ed esportazione scorse |
| `cls_reports.cls` | 795 | **Motore dei report dinamici**: definizioni in tabella `t_dynamic_reports` su un database cloud, rendering con VSReport 8, stampa o PDF. Usato da `FrmReportsECL` ("Rapporti Vari", "Rapporti Amministratori"), `frmCassa`, `frmCompleanni`, `FormCreaRedeem` | Per intero |
| `FrmRappDis.frm` | 124 | **"Situazione Prize Hub N."**: giacenza dei premi nei distributori automatici Prize Hub 1–8 | Per intero |
| `frmSelezionaStampante.frm` | 29 | Scelta della stampante di Windows per i report dinamici | Per intero |
| `FormStampaReport.frm` | 9 | Contenitore dei controlli `VSPrinter8`/`VSReport8` usati da `cls_reports` | Per intero |
| `FrmInDat.frm` | 21 | **Non è un report**: chiede nome, cognome e telefono del cliente senza card durante una prenotazione (`Form1.frm:6450`) e li scrive in `Prenotaz` | Per intero; appartiene alla zona prenotazioni |

Fuori perimetro ma collegati: `FrmReportsECL.frm` (interfaccia dei report dinamici e grafici macchine, dove si usano `fn_dati_grafico_giornaliero` e `sp_generacache`), `FrmRic.frm` (report su `Vincite25`), `FrmInc` (registrazione incassi), `FrmIni`/`RapGen` (rapporto generale multi-sala di WinMTHQ, **non presenti** in questa copia del sorgente).

---

## 2. Flussi

### W09-01 — Rapporto Vendite: calcolo e visualizzazione

- **Attore e innesco:** operatore con permesso "Abilita rapporto"; `Form1` → menu *Rapporto* (`Form1.frm:14192-14201`, con `KeyLocate(NET_KEY_ACCESS)`) oppure Magazzino premi → *Rapporti → Rapporto Vendite* (`frmpremi.frm:3810`). Il calcolo parte all'apertura (`Form_Activate` → `Command1_Click`), al cambio operatore (`CmbOper_Click`) e con *Aggiorna*. **[V]**
- **Parametri:** dal/al (data + ora; default ieri 06:00 → ora attuale, `frmrapp.frm:5049-5052`); operatore (vuoto = tutti; un operatore di livello ≥ 2 vede solo sé stesso); clienti *Tutti / Card / No Card*; filtro testuale su Codice, BarCode, ID, Descrizione, Fornitore, Tipo (Gru) per ciascuna delle tre tabelle. **[V]**
- **Passi:**
  1. Corregge i ticket delle chips (W09-04) — **scrittura nascosta**. **[V]** `frmrapp.frm:2421`
  2. Se la sala è multi-locale (`Setup.T6` valorizzato) prepara l'elenco dei locali collegati. **[V]** `frmrapp.frm:2433-2443`
  3. Legge le tre liste del periodo: **premi consegnati** (`Vincite`, `cons=1`), **premi resi** (`Resi`), **premi prenotati non consegnati** (`Prenotaz`, `cons=0`), con join su `Operatori` e `Clienti`. **[V]** `frmrapp.frm:2494-2550`
  4. Somma valori, costi e ticket delle tre liste e calcola il profitto. **[V]** `frmrapp.frm:2559-2610`
  5. Classifica i ticket entrati nel periodo per tipo con `ContaTickets` (§ 4.1). **[V]** `frmrapp.frm:2623`, `Module6.bas:1693-1753`
  6. Calcola i riquadri accessori (W09-05, W09-06) e i residui "Nelle Cards" e "Scontrini". **[V]** `frmrapp.frm:2629-2759`
- **Dati letti:** `Vincite.{Codice, Descrizione, N_Tickets, Costo, Data, IdContatto, Id, Cons}`; `Resi.{Codice, Descrizione, N_Tickets, Costo, Data, IdContatto, Id}`; `Prenotaz.{Codice, Descrizione, N_Tickets, Costo, Data, IdCli, CognomeC, IdOp, Cons}`; `Operatori.{Id, Cognome, Nome, Livello, Attivo}`; `Clienti.{IdContatto | IdLong, Cognome}`; `Tickets.{NumTickets, TPagati, Data, DataOut, MangiaT, NonCont, Aux, NRep, N0, F0, Oper, Id, IdContatto}`; `Setup.{T6, NewConc, IniConc, TicStat, Mistral, NRep2..9, ARep2..9, CodEcs, Lang}`. **[V]**
- **Dati scritti:** `Tickets.NumTickets` (W09-04); righe di `Vincite`/`Resi`/`Prenotaz` se modificate nelle griglie (W09-13). **[V]/[D]**
- **Misure e formule** (dettaglio in § 4):

| Misura (etichetta a video) | Formula | Evidenza |
|---|---|---|
| Valore totale premi consegnati | Σ `Vincite.N_Tickets` × **0,01** (cons=1, periodo, filtri) | `frmrapp.frm:2564` [V] |
| Costo totale premi consegnati | Σ `Vincite.Costo` | `frmrapp.frm:2565` [V] |
| Profitto totale | Σ (`N_Tickets` × 0,01 − `Costo`) sulle righe di `Vincite` | `frmrapp.frm:2567` [V] |
| Profitto medio | Profitto totale / numero di righe di `Vincite` (= numero di pezzi consegnati) | `frmrapp.frm:2575` [V] |
| Costo totale premi resi | Σ `Resi.Costo` | `frmrapp.frm:2585` [V] |
| Ticket "Resi" | Σ `Resi.N_Tickets` | `frmrapp.frm:2586` [V] |
| Costo totale premi prenotati / Ticket "Prenotati" | Σ `Prenotaz.Costo` / Σ `Prenotaz.N_Tickets` (cons=0) | `frmrapp.frm:2602-2603` [V] |
| Ticket "Pagati" | Σ `Vincite.N_Tickets` (non `Tickets.TPagati`) | `frmrapp.frm:2566` [V] |
| Contati, Esterni, Convalidati, Manuali, Bonus | somme di `Tickets.NumTickets` per bit di `MangiaT` (§ 4.1) | `Module6.bas:1718-1728` [V] |
| Totale IN | Contati + Manuali + Bonus ("tolti i resi") | `frmrapp.frm:2736` [V] |
| Totale OUT | Pagati + Prenotati | `frmrapp.frm:2737` [V] |
| Scontrini (rimanenti) | Σ (`NumTickets` − `TPagati`) con `IdContatto=0`, `NonCont=0`, `Aux=0` — **su tutto lo storico**, non sul periodo | `frmrapp.frm:2750-2752` [V] |
| Nelle Cards (rimanenti) | stessa formula con `IdContatto>0` — su tutto lo storico | `frmrapp.frm:2753-2755` [V] |
| Vita media scontrini (giorni) | AVG(DATEDIFF(giorni, `Data`, `DataOut`)) sugli scontrini anonimi con `DataOut > Data` — su tutto lo storico | `frmrapp.frm:2756-2759` [V] |
| Ticket pagati concorso attuale / precedente (se `Setup.NewConc`) | attuale = Σ `Tickets.TPagati` con `DataOut` nel periodo e `Data ≥ Setup.IniConc`; precedente = Pagati − attuale | `frmrapp.frm:2738-2749` [V] |

- **Raggruppamenti:** liste ordinate per colonna scelta e descrizione; in stampa le righe consecutive con la stessa descrizione diventano una riga con quantità (§ W09-02). Per operatore se scelto, altrimenti totale. **[V]**
- **Regole:** invariante dichiarata in testa al modulo: *"Manuali + Contati − Pagati = Nelle Card + Scontrini"* (`frmrapp.frm:2346`) **[V]**; non è verificata dal codice. Il filtro "No Card" sulle prenotazioni usa `idcli > 0` invece di `= 0` (bug, `frmrapp.frm:2492`) **[V]**. Nei filtri, BarCode e ID sono ignorati per le tabelle che non hanno quelle colonne (`frmrapp.frm:2849-2854`) **[V]**.
- **Multi-locale:** se `Setup.T6` è valorizzato, `Vincite.IdContatto` e `Resi.IdContatto` si collegano a `Clienti.IdLong` invece che a `Clienti.IdContatto` (`frmrapp.frm:2527` contro `:2499`) **[V]**.
- **Periferiche:** nessuna nel calcolo. All'uscita riapre le porte seriali di lettore barcode e lettore card (`frmrapp.frm:5370-5371`). **[V]**
- **Senza rete verso il cloud:** funziona, legge solo il DB di sala. **[V]**
- **Peso: L** — tre tabelle di dettaglio più la classificazione dei ticket a bit, varianti per operatore, cliente, multi-locale, concorso, reparti e raccolte; una scrittura nascosta.
- **Evidenze:** `frmrapp.frm:2395-2775` (`AggDati`), `:2819-2857` (`CmdAppl_Click`), `:4977-5355` (`Form_Load`); `Module6.bas:1693-1753`.

### W09-02 — Rapporto Vendite: stampa (termica e di sistema)

- **Attore e innesco:** come W09-01; pulsante con icona stampante termica (`Stampa_Click`) o stampante di sistema (`Cmdpsys_Click`). **[V]**
- **Passi:**
  1. **Termica:** invia comandi ESC/POS sulla seriale `Form1.Stmp` (intestazione locale, periodo, operatore, liste raggruppate per descrizione con quantità, totali in ticket, taglio carta secondo `Setup.TypePrt` 2/3/4). Se l'operatore è vuoto stampa **un blocco per ogni operatore** richiamando `AggDati`, poi il totale generale. **[V]** `frmrapp.frm:5448-5816`
  2. **Sistema:** chiede la stampante (`PrinterSel`, non nella versione Cloud) e stampa con `gPrintListView` in tre modalità: **Estesa** (tre liste per operatore con subtotali), **Breve** (`ChkSB`: solo totali per operatore), **Unione** (`ChkSIns`: tabella riepilogativa per operatore). Aggiunge i riquadri reparti, extra locale, raccolte card, punti da APP e "MANUAL TICKETS" per operatore. **[V]** `frmrapp.frm:3514-4857`, `:3569-3570`, `:4059-4069`
- **Dati:** gli stessi di W09-01, ricalcolati per operatore. **[V]**
- **Regole notevoli:** sulla termica la riga "Valore totale premi" stampa `totdati`, che è la **somma dei costi**, non del valore in ticket (`frmrapp.frm:5563`) **[V]**. Nel totale generale di sistema le etichette "Concorso Attuale" e "Concorso Precedente" sono invertite rispetto alle variabili (`TPagPre`/`TPagAt`) **[V]**. I totali monetari passano per variabili `Long` (`GTValPr`, `GTCosPr`) e perdono i centesimi (`frmrapp.frm:3527-3528`) **[V]**.
- **Periferiche:** stampante termica seriale (ESC/POS); stampante di Windows. In WinMTHQ la stampa termica è nascosta. **[V]**
- **Peso: M** — tre impaginazioni e iterazione per operatore, nessuna logica nuova.
- **Evidenze:** `frmrapp.frm:5448-5816`, `:3514-4857`.

### W09-03 — Rapporto Vendite: esportazione

- **Innesco:** pulsante *Esporta*. **[V]**
- **Passi:** se Excel è installato crea un `.xlsx` via automazione COM, altrimenti un `.csv`; contiene le tre liste (codice, descrizione, costo, quantità), i totali e i riquadri accessori. In WinMTHQ compilato `Cloud` salva senza chiedere in `Documenti\Exports\<locale> Sales Report <data ora>`. **[V]** `frmrapp.frm:2867-3454`, `:2924-2934`
- **Peso: S** — trasformazione dei dati già calcolati.

### W09-04 — Correzione automatica dei ticket "chips" (scrittura nascosta)

- **Attore e innesco:** automatico, all'inizio di **ogni** calcolo del Rapporto Vendite. **[V]** `frmrapp.frm:2421`
- **Passi:** legge i `Tickets` del periodo con `Aux=1` e `NumTickets % 5 > 0` e per ciascuno **riscrive** `NumTickets = NumTickets + 5 − (NumTickets mod 5) + 10` (es. 23 → 35). Commento: *"serve per ovviare agli errori di conteggio delle chips da parte della mangiatickets"*. **[V]** `frmrapp.frm:5969-5986`
- **Dati:** lettura e **aggiornamento** di `Tickets.NumTickets`, filtro su `Tickets.Aux`, `Tickets.Data`. **[V]**
- **Regole:** dopo la prima correzione il valore è multiplo di 5 e non viene più toccato; quindi il risultato dipende da **chi apre per primo un rapporto** che copre quella data. **[V]** (logica) / **[D]** (conseguenza)
- **Peso: S** — un ciclo di update; rilevante come regola di business implicita da riprodurre altrove o eliminare.

### W09-05 — Rapporto Mangia Tickets

- **Innesco:** menu *Mangia Tickets* del Rapporto Vendite. **[V]**
- **Passi:** Σ `Tickets.NumTickets` del periodo con `Aux=0` e `NonCont=0`, raggruppati per `Tickets.Id` (numero della mangia-ticket); esclude `Id` 0 e 101–110 (postazioni manuali). **[V]** `frmrapp.frm:2630-2692`
- **Peso: S.**

### W09-06 — Riquadri punti: reparti, raccolte card, extra locale, punti da APP, ticket manuali

- **Innesco:** pulsanti "Punti dai Reparti", "Punti Raccolta Carte", "Punti Extra Locale", "Punti da APP" del Rapporto Vendite; i dati sono calcolati in `AggDati`. **[V]**
- **Passi e formule:**
  1. **Reparti:** per ogni reparto r = `NRep and 15` (1..8), somma di Aux + Contati + Manuali delle righe di quel reparto. Nomi e abilitazione da `Setup.NRep2..9` / `ARep2..9`; il reparto 1 è sempre la raccolta card Mistral. **[V]** `Module6.bas:1739-1740`, `frmrapp.frm:5867-5967`
  2. **Raccolte card (Mistral):** per ogni raccolta configurata (`ClsCard(a)`), `Tickets` del periodo con `T0 LIKE '<prime 2 lettere del prefisso>%'`; Punti = Σ `NumTickets`, P.Serie = Σ `Val(Mid(T0, 4, 10))`, Differenza = Punti − P.Serie. **[V]** `frmrapp.frm:5988-6069`
  3. **Extra locale (multi-locale):** per ogni locale collegato (ID = numero del DB in cloud, da `Setup.T6`): **Dare** = Σ `TPagati` dei ticket con `N0 = ID locale` e `F0 = 0`; **Avere** = Σ `TPagati` con `N0 = ID locale` e `F0 = 1`; Netto = Avere − Dare. **[V]** `Module6.bas:1725-1737`, `frmrapp.frm:5818-5865`
  4. **Punti da APP:** Σ `NumTickets` del periodo con bit 8192 di `MangiaT` attivo e bit 16384 spento, raggruppati per `Tickets.T1` (nome della campagna, `'??'` se nullo). Il pulsante è visibile solo se ci sono punti e `Setup.CodEcs` è vuoto. **[V]** `frmrapp.frm:6119-6174`
  5. **Manual tickets:** Σ `NumTickets` con `T0 = 'MANUAL TICKETS'` per operatore (`Tickets.Oper`), solo in stampa e se la raccolta "Cards Collections" è attiva. **[V]** `frmrapp.frm:6071-6117`, `Module1.bas:2386`
- **Peso: M** — cinque calcoli distinti, multi-locale e configurazione per sala.

### W09-07 — Rapporto Breve Utente

- **Attore e innesco:** Magazzino premi → *Rapporti → Rapporto Breve Utente* (`frmpremi.frm:3829`); il calcolo parte in `Form_Load`. **[V]**
- **Differenze rispetto a W09-01** (stesse liste, stesse formule di valore, costo e profitto, `FrmRappUs.frm:1691-1702`):
  1. classifica i ticket **riga per riga lato client** con `IdTicket` (`API.bas:293-324`) invece della query aggregata di `ContaTickets`; i bit usati sono gli stessi, ma il reparto riceve tutti i ticket non `NonCont`, compresi i bonus **[V]** `FrmRappUs.frm:1757`;
  2. "Scontrini" e "Nelle Cards" sono calcolati **sui soli ticket del periodo**, non su tutto lo storico **[V]** `FrmRappUs.frm:1798-1803`;
  3. calcola ancora "Letti" (Σ `NumTickets` dei ticket con `DataOut` nel periodo, anonimi o con `MangiaT > 200`, e `Oper < 1000`) **[V]** `FrmRappUs.frm:1895-1905`;
  4. il filtro per operatore usa `Tickets.Oper`, e il filtro cliente usa una variabile `Cust` mai valorizzata (nessun filtro) **[V]**;
  5. nessun riquadro extra locale, raccolte, punti da APP; nel riquadro reparti aggiunge il numero di serie Mistral calcolato con `Setup.MisVSerie` e `MisVCard` **[V]** `FrmRappUs.frm:4334-4423`;
  6. **scrive** `Tickets.Id = 1` sulle righe con `Id` nullo durante il conteggio per mangia-ticket (`FrmRappUs.frm:1823`, `:1829`) **[V]**; con ADODC la modifica viene salvata al `MoveNext` **[D]**.
- **Peso: M** — duplicato di W09-01 con varianti; da non riprodurre separatamente.

### W09-08 — Rapporto Settimanale (incassi, costi, profitto lordo, payout)

- **Attore e innesco:** Magazzino premi → *Rapporti → Rapporto Settimanale* (`frmpremi.frm:3920`). Il menu è visibile **solo se `Setup.RegInc`** (registrazione incassi) è attivo (`frmpremi.frm:2903-2907`): per questo il manuale lo segna come "deprecato?". **[V]**
- **Parametri:** dal/al (default ultimi 7 giorni, orari `Setup.TmOpen`/`TmClose`); opzione "Includi trasferiti" (`ChkIncTraOut`). Il filtro testuale e il combo operatore esistono ma **non entrano nelle query** (`FilTop = ""`). **[V]** `frmWrapp.frm:3306-3310`, `:4427-4431`
- **Passi:**
  1. Valore attuale del magazzino: Σ `Premi.Costo × Premi.Quantita`. **[V]** `frmWrapp.frm:3313-3316`
  2. Premi venduti: Σ `Vincite.N_Tickets`, Σ `Vincite.Costo`, conteggio righe — **senza filtro su `Cons`**. **[V]** `:3348-3365`
  3. Resi e prenotati: Σ `N_Tickets` e Σ `Costo` (prenotati **senza** filtro `cons=0`). **[V]** `:3371-3392`
  4. Ticket del periodo per tipo con `ContaTickets`. **[V]** `:3404-3409`
  5. Carichi e scarichi per motivo: Σ `MovMag.Costo × Quantita` e Σ `MovOut.Costo × Quantita` con `Motivo LIKE '%<motivo>'`, motivi nell'ordine CARICO, GRU, GUASTO, SPOSTA (trasferiti), CONSUMABILI, EVENTI, RUSPE (in inglese o francese se la lingua è diversa). **[V]** `:3462-3473`, `:4437-4531`
  6. Incassi lordi: Σ `Incassi.Red`, `Gru`, `Push`, `Alt` del periodo; netti = lordo / (1 + aliquota/100) con `Setup.TRed`, `TGru`, `TPus`, `TAlt`. **[V]** `:3493-3522`
  7. Profitto lordo e indici (tabella sotto). **[V]** `:3523-3564`
  8. In WinMTHQ, se chiamato dal rapporto generale, copia i risultati in `RapGen(NumLoc)` per l'aggregazione multi-sala. **[V]** `:3576-3607`
- **Formule:**

| Voce | Formula | Evidenza |
|---|---|---|
| Venduti (costo) | V = Σ `Vincite.Costo` | `frmWrapp.frm:3354-3356` [V] |
| Profitto totale / medio | Σ `N_Tickets` × 0,01 − V; / numero righe `Vincite` | `:3352-3365` [V] |
| Carico per motivo m | Cₘ = Σ `MovMag.Costo × Quantita` | `:3466-3468` [V] |
| Scarico per motivo m | Sₘ = Σ `MovOut.Costo × Quantita` | `:3469-3471` [V] |
| Totale carico | C_carico + C_gru + C_sposta + C_consumabili + C_eventi + C_ruspe | `:3480` [V] |
| Totale scarico | V + S_gru + S_guasto + [S_sposta] + S_consumabili + S_eventi + S_ruspe | `:3488-3492` [V] |
| Incasso netto categoria | lordo / (1 + aliquota/100) | `:3513-3516` [V] |
| **GP (profitto lordo)** | Σ netti − (V + Σₘ (Sₘ − Cₘ)) per m ∈ {gru, guasto, [sposta], consumabili, eventi, ruspe} | `:3523-3527` [V] |
| Rendimento Redemptions (payout) | V / netto redemption | `:3528-3532` [V] |
| Rendimento Gru | (S_gru − C_gru) / netto gru | `:3533-3537` [V] |
| Rendimento Ruspe | (S_ruspe − C_ruspe) / netto ruspe | `:3538-3542` [V] |
| Incidenza Guasti | S_guasto / Σ netti | `:3544` [V] |
| Incidenza Consumabili | (S_consumabili − C_consumabili) / Σ netti | `:3545` [V] |
| Indice di Rendimento Tot. ("GP index") | (GP + Variazione) / Σ netti | `:3550-3554` [V] |
| Indice di Pagamento Tot. ("total payout") | (V + Σₘ (Sₘ − Cₘ) − Variazione) / Σ netti | `:3555-3563` [V] |
| Totale ("GP value") | GP + Variazione | `:3564` [V] |

- **Dati letti:** `Premi.{Costo, Quantita}`; `Vincite.{N_Tickets, Costo, Data}`; `Resi.{N_Tickets, Costo, Data}`; `Prenotaz.{N_Tickets, Costo, Data}`; `Tickets` (via `ContaTickets`); `MovMag.{Costo, Quantita, Data, Motivo}`; `MovOut.{Costo, Quantita, Data, Motivo}`; `Incassi.{Data, Red, Gru, Push, Alt}`; `Setup.{TRed, TGru, TPus, TAlt, TmOpen, TmClose, RegInc}`. **[V]**
- **Periferiche:** stampa termica e di sistema, esportazione `.xls`/`.csv` come W09-02/03. **[V]**
- **Peso: L** — unico report economico; dieci formule, tre fonti indipendenti (vincite, movimenti di magazzino, incassi), aliquote, aggregazione multi-sala in HQ.
- **Evidenze:** `frmWrapp.frm:3295-3614`, `:4403-4611`.

### W09-09 — Rapporto Variazioni

- **Innesco:** Magazzino premi → *Rapporti → Rapporto Variazioni* (`frmpremi.frm:3818`), stessa finestra di W09-08 con `frmpremi.Variaz = True`; stessa condizione di visibilità (`Setup.RegInc`). **[V]**
- **Passi aggiuntivi:** per ogni inventario del periodo (`RiepInv` con `F0=0`) estrae il file Access contenuto in `RiepInv.Mdb` in `Documenti\<exe>\VInv.mdb`, lo apre (credenziale scritta nel codice in `frmWrapp.frm:3327`) e somma `qdiff × costo` della tabella `Inv`, separatamente per eccedenze (`qdiff > 0`) e ammanchi (`qdiff < 0`). Variazione = somma delle due. Entra negli indici di W09-08. **[V]** `frmWrapp.frm:3320-3346`
- **Dati:** lettura `RiepInv.{Data, F0, Mdb}`; scrittura di un file `.mdb` locale temporaneo. **[V]**
- **Peso: M** — dipende dal formato Access degli inventari.

### W09-10 — Situazione Prize Hub

- **Attore e innesco:** Rapporto Vendite → menu *Prize Hub → N.1…N.8* (visibile se esiste un operatore di nome "Prize Hub" con `Id` 1001–1008, `frmrapp.frm:5060-5080`), oppure dalla gestione Prize Hub (`FrmToPr.frm:276`). **[V]**
- **Passi:** legge `Premi.{Codice, Descrizione, PDisN, QDisN, CodOr, N_Tickets, Quantita}` dove `PDisN <> ''` (N = numero del Prize Hub); svuota e riempie la tabella `premi` di un database Access locale `PremiPH.mdb` e la mostra in griglia (Pos, Codice, Descrizione, Disponibili). **[V]** `FrmRappDis.frm:505-600`
- **Regole:** le date dal/al sono mostrate ma **non usate**; i pulsanti Stampa ed Esporta **non hanno codice** (nessuna procedura `CmdStp_Click`/`CmdExp_Click`). Da `FrmToPr` il numero scelto (`NDis`) viene ignorato: il form legge sempre `FrmRapp.NPHub`. **[V]**
- **Peso: S.**

### W09-11 — Report dinamici (Rapporti Vari, Rapporti Amministratori, report di cassa e compleanni)

- **Attore e innesco:** `Form1` → *Rapporti Vari* (gruppo `ReportsECLMT`) e *Rapporti Amministratori* (gruppo `ReportsSADM`, protetto da una password di servizio confrontata con `SupPass`) (`Form1.frm:18043-18086`); inoltre `frmCassa` (`rimborsi_omaggi`), `frmCompleanni` (`riepilogo_compleanno`, `redeem_code_compleanno`), `FormCreaRedeem`. **[V]**
- **Passi:**
  1. Si connette a un **database cloud** (`CoinlessDB` sul server Elmac, credenziale scritta nel codice in `FrmReportsECL.frm:1244-1246`) che contiene le definizioni. **[V]**
  2. Elenca i report del gruppo da `t_dynamic_reports`; i report con lo stesso nome nel gruppo `SqlDB` = `"DB" & Setup.NImp` **sostituiscono** quelli standard: è la personalizzazione per sala. **[V]** `cls_reports.cls:319-375`, `Module1.bas:1358-1359`
  3. Per il report scelto legge `recordset_sql`, sostituisce i parametri `{param:nome}` e le etichette `{tr:chiave}`, e lo esegue sul **DB di sala**. **[V]** `cls_reports.cls:469-515`, `:660-672`, `:941-1011`
  4. Filtri opzionali descritti dalla stessa riga: date dal/al, due listbox, una checkbox-list, un autocomplete, ciascuno con flag di obbligatorietà. **[V]** `:597-658`
  5. Stampa: esegue `execute_sql_before_print` sul DB di sala, carica il layout VSReport (da `report_xml` o salvando `source_xml` in `C:\sqltemp\rep_<nome>.xml`), rende su stampante scelta (`frmSelezionaStampante`), su PDF (`save_to_path` o percorso passato) o su "Microsoft Print to PDF"; poi esegue `update_sql_after_print`. **[V]** `:700-853`
  6. Stile delle griglie da `t_dynamic_reports_flexGridStyle` (formati, merge, subtotali in JSON). **[V]** `:91-185`
- **Dati:** cloud: `t_dynamic_reports.{id, gruppo, nome_del_report, titolo_report, recordset_sql, flexGridStyle, drilldown, testata_report, bound_picture, report_xml, source_xml, save_to_path, update_sql_after_print, execute_sql_before_print, note, dalla_data_*, alla_data_*, listbox1/2_*, checkboxlist1_*, autocomplete1_*}`, `t_dynamic_reports_flexGridStyle`, `t_dynamic_subreports` (codice commentato). Sala: qualunque tabella citata nelle query, **comprese scritture** prima e dopo la stampa. **[V]**
- **Senza rete verso il cloud:** l'elenco dei report non si carica e nessun report dinamico è eseguibile (log "Missing internet connection"). **[V]** `cls_reports.cls:230-233`
- **Peso: L** — motore generico con SQL arbitrario da database remoto, layout esterni, scritture prima e dopo la stampa. Il **contenuto** dei report (formule) non è nel sorgente: va estratto da `CoinlessDB`.

### W09-12 — Dati del cliente senza card in una prenotazione (fuori zona)

- **Innesco:** consegna con prenotazione dalla cassa (`Form1.frm:6448-6455`). **[V]**
- **Passi:** chiede nome, cognome, telefono e li scrive in `Prenotaz.NomeC`, `CognomeC`, `Tel` della prenotazione appena creata. **[V]** `FrmInDat.frm:156-162`
- **Peso: S.** Da spostare nella zona prenotazioni.

### W09-13 — Modifica diretta di consegne, resi e prenotazioni dalle griglie

- **Innesco:** per operatori di livello 0–1 le tre griglie del Rapporto Vendite e del Rapporto Breve Utente hanno `AllowUpdate = True`. **[V]** `frmrapp.frm:5126-5128`, `FrmRappUs.frm:3770-3772`
- **Effetto:** le celle (codice, descrizione, ticket, costo, data) sono legate agli ADODC su `Vincite`, `Resi`, `Prenotaz`; una modifica viene salvata sulla tabella di origine senza log né ricalcolo di saldi o giacenze. **[D]**
- **Peso: S.** Da non riprodurre (o da sostituire con una rettifica tracciata).

---

## 3. Significato delle colonne

| Tabella.Colonna | Significato | Valori / codifiche | Evidenza | |
|---|---|---|---|---|
| `Tickets.MangiaT` | Origine e stato del ticket, **bitmask** | 1 mangia-ticket Galileo collegata; 2 esterno (scontrino di MT non collegata); 4 manuale; 6 (=2+4) convalidato; 8 reso; 16 somma; 32 resto; 64 bonus; 128 sommato; 256 caricato sulla card; 512 passato ad altra card; 1024 acquisito da altra card; 2048 prenotazione cancellata; 4096 cancellato da operatore; 8192 punti da APP; 16384 Silver in Gold. Ticket automatici ECL = 8256 (8192+64) | `Module6.bas:1719-1727`, `frmrapp.frm:6146`, `fn_decode_mt_bitmask.sql`, `scriviTicketsAutomatici.sql:52` | V |
| `Tickets.NonCont` | Ticket da **non conteggiare** nei totali (già conteggiato altrove, es. scontrino sommato) | 0/1 | `Module6.bas:1719-1727`, commenti in `API.bas:309-311` | D |
| `Tickets.Aux` | Ticket da ingresso ausiliario della mangia-ticket (chips/gettoni); escluso da residui e conteggio per MT, corretto a multipli di 5 | 0/1 | `frmrapp.frm:5976`, `:2630`, `:2750` | V (uso) / D (significato) |
| `Tickets.NRep` | Reparto di provenienza nei 4 bit bassi | `NRep and 15` = 1..8 (1 = raccolta card Mistral); bit alti non usati qui | `Module6.bas:1739`, `frmrapp.frm:5919` | V |
| `Tickets.Id` | Numero della mangia-ticket o postazione che ha emesso/contato lo scontrino | 0 = nessuna; 101–110 = postazione manuale N (= Id − 100); `FrmRappUs` forza 1 se nullo | `frmrapp.frm:2630-2690`, `FrmRappUs.frm:1823`, `ModAddNew.bas:82` | V |
| `Tickets.Oper` / `OperOut` | Operatore che ha registrato il ticket / che lo ha pagato | `Oper ≥ 1000` escluso da "Letti" (operatori virtuali Prize Hub) | `Module6.bas` (`FilTop`), `FrmRappUs.frm:1895-1903` | V |
| `Tickets.TPagati` | Ticket dello scontrino già spesi | Residuo = `NumTickets − TPagati` | `frmrapp.frm:2750`, `Module6.bas:1886-1905` | V |
| `Tickets.Data` / `DataOut` | Emissione / ultimo pagamento | `DataOut > Data` per la vita media | `frmrapp.frm:2756` | V |
| `Tickets.IdContatto` | Cliente; 0 = scontrino cartaceo anonimo | 0 / id cliente | `frmrapp.frm:2750-2755` | V |
| `Tickets.N0` | ID del locale collegato (numero DB cloud) in cui i punti sono stati usati | > 0 solo in multi-locale | `Module6.bas:1730-1737` (commento "N0=ID locale che ha utilizzato i punti") | V |
| `Tickets.F0` | Verso del movimento extra locale | 1 → colonna *Avere* ("ricevuti"); 0 → colonna *Dare* ("pagati") | `Module6.bas:1725-1727` | V (codice) / D (semantica contabile) |
| `Tickets.T0` | Testo: `'MANUAL TICKETS'` per i ticket manuali, oppure prefisso della raccolta card (2 caratteri) seguito da punti serie dalla 4ª posizione | | `frmrapp.frm:6096`, `:6028`, `:6044`, `ModAddNew.bas:86` | V |
| `Tickets.T1` | Nome della campagna dei punti da APP | `'??'` se nullo. Risponde in parte a DB 05 § 4 (righe con `T1` e `NImp=0`) | `frmrapp.frm:6146` | V |
| `Tickets.D0` | Valorizzato per i ticket "Gold" | data di emissione o NULL | `ModAddNew.bas:87`, `Module6.bas:1923-1946` | V |
| `Vincite.Id` | **Operatore** che ha consegnato il premio (non un id di riga) | 1001–1008 = Prize Hub | `frmrapp.frm:2499`, `ModAddNew.bas:44` | V |
| `Vincite.Cons` | Premio consegnato | 1 consegnato; 0 vinto ma non consegnato (prenotazione) | `frmrapp.frm:2499`, `ModAddNew.bas:46-48` | V |
| `Vincite.Costo` / `N_Tickets` | Costo d'acquisto e prezzo in ticket **copiati dal premio al momento della consegna**; una riga per pezzo | € / ticket | `ModAddNew.bas:40-41`, `Form1.frm:6427` | V |
| `Vincite.IdContatto` | Cliente; si collega a `Clienti.IdContatto` in sala singola, a `Clienti.IdLong` in multi-locale | 0 = cliente senza card | `frmrapp.frm:2499` vs `:2527`, `ModuleMultilocale.bas:10-15` | V |
| `Vincite.F0` | Consegna avvenuta in configurazione multi-locale | 0/1 | `ModAddNew.bas:47` | V |
| `Vincite.D0` | Data di consegna (se immediata = `Data`) | | `ModAddNew.bas:48` | V |
| `Vincite.N0` | Punti Gold usati al posto dei Silver (`PGldxSil`) | intero | `ModAddNew.bas:49` | D |
| `Resi.Id` | Operatore che ha registrato il reso | | `frmrapp.frm:2501` | V |
| `Prenotaz.IdOp` / `IdCli` / `Cons` | Operatore, cliente, consegnata | `Cons=0` = in attesa | `frmrapp.frm:2503` | V |
| `Prenotaz.NomeC` / `CognomeC` / `Tel` | Dati del cliente senza card | | `FrmInDat.frm:157-159` | V |
| `Premi.PDis1..8` / `QDis1..8` | Posizione (slot) e quantità del premio nel **Prize Hub** N | `PDisN <> ''` = presente nel Prize Hub N | `FrmRappDis.frm:540` | V |
| `Premi.Costo` × `Premi.Quantita` | Valore di magazzino a costo | | `frmWrapp.frm:3313` | V |
| `Premi.Gru` | Tipologia usata dal filtro "Tipo" | 0/1 | `frmrapp.frm:2838` | V |
| `MovMag.Motivo` / `MovOut.Motivo` | Causale del carico / scarico, **testo nella lingua dell'interfaccia** | CARICO, GRU, GUASTO, SPOSTA, CONSUMABILI, EVENTI, RUSPE (EN: LOAD, CRANES, WASTE, TRANSFER, CONSUMABLES, EVENTS, PUSHERS; FR …), confrontate con `LIKE '%X'` | `frmWrapp.frm:3466-3469`, `:4437-4531` | V |
| `Incassi.Red` / `Gru` / `Push` / `Alt` | Incasso **lordo** del giorno per categoria: redemption, gru (e instant redemption), ruspe, altro | € | `frmWrapp.frm:3502-3505`; manuale "Registra Incassi" | V |
| `Incassi.F0` / `Incassi.Mdb` | Record generato da EcsNet / file `.mdb` dell'incasso | | `Module1.bas:41` (commento) | V |
| `RiepInv.F0` | 0 = inventario di sala; 1 = kit premi inviato da WinMTHQ | | `Module1.bas:44`, `frmWrapp.frm:3321` | V |
| `RiepInv.Mdb` | File Access dell'inventario con tabella `Inv(qdiff, costo, …)` | | `frmWrapp.frm:3326-3333` | V |
| `Operatori.Id` 1001–1008 | Operatori virtuali dei distributori Prize Hub 1–8 (nome contiene "Prize Hub") | | `frmrapp.frm:5060-5080` | V |
| `Operatori.Livello` | Livello di accesso; `Livello and 3` 0–1 = amministratore/manager (vedono tutti), ≥ 2 = operatore (vede sé stesso) | | `Form1.frm:11384`, `frmrapp.frm:5118-5123` | V |
| `Setup.T6` | Elenco locali collegati `Nome|NNNN|Nome|NNNN…` (NNNN = numero DB in cloud); con `#` = disattivato | | `Module1.bas:2601-2605`, `:53` | V |
| `Setup.NImp` (IDPost 101) | **Numero dell'impianto = numero del DB in cloud** (`SqlDB = "DB" & NImp`) | in produzione 196 | `Module1.bas:1358-1359` | V; risponde a DB 03 § 6 |
| `Setup.NewConc` / `IniConc` | Gestione "operazione/concorso" a premi: abilitazione e data di inizio dell'operazione corrente | | `frmrapp.frm:2738-2749` | V |
| `Setup.TRed` / `TGru` / `TPus` / `TAlt` | Aliquota IVA (%) per categoria di incasso | | `frmWrapp.frm:3513-3516`, `Module1.bas:2586-2587` | V |
| `Setup.RegInc` | Abilita registrazione incassi e i rapporti Settimanale/Variazioni | | `frmpremi.frm:2903-2907` | V |
| `Setup.TmOpen` / `TmClose` | Orari di apertura/chiusura, default del Rapporto Settimanale | | `frmWrapp.frm:4430-4431` | V |
| `Setup.TicStat` | Mostra il contatore "Esterni" | | `frmrapp.frm:5034-5037` | V |
| `Setup.NRep2..9` / `ARep2..9` | Nome e abilitazione dei reparti 1..8 | | `frmrapp.frm:5919-5958` | V |
| `Setup.MisVSerie` / `MisVCard` | Valore in punti di una serie e di una singola card della raccolta Mistral (serie = 7 card) | | `FrmRappUs.frm:4348-4349` | D |
| `Setup.CodEcs` | Se valorizzato nasconde "Punti da APP" | | `frmrapp.frm:6169` | V |
| `Setup.ValTick` | Valore del ticket: **non usato** dai rapporti di questa zona (usato da `sp_incasso`) | decimal(6,4) | `FrmCont.frm:7648`; assenza in zona | V |
| `Setup.TypePrt` | Modello di stampante termica (2, 3, 4 = comandi di taglio diversi) | | `frmrapp.frm` `Stampa_Click` | V |

---

## 4. Regole, calcoli e comportamenti notevoli

### 4.1 Classificazione dei ticket entrati (`ContaTickets`)

Tutte le somme sono su `Tickets.NumTickets` del periodo (`Data` tra dal e al, eventualmente `Oper = operatore`), raggruppate per `NRep, N0` e poi sommate **[V]** `Module6.bas:1718-1745`:

| Totale | Condizione |
|---|---|
| Contati | `NonCont=0` e (bit 1 o bit 2 o bit 2+4) — cioè mangia-ticket Galileo o esterni (i convalidati sono un sottoinsieme degli esterni) |
| Collegati | `NonCont=0` e bit 1 |
| Esterni | `NonCont=0` e bit 2 |
| Convalidati | `NonCont=0` e bit 2 e bit 4 |
| Bonus | `NonCont=0` e bit 64 |
| Manuali | `NonCont=0` e bit 4 (include i convalidati) |
| Aux | `Aux=1` e bit 1 (anche se `NonCont=1`) |
| Ricevuti / pagati extra locale | `N0 > 0`, `F0 = 1` / `F0 = 0`, somma di `TPagati` |

Le categorie **si sovrappongono** (un convalidato è contato in Contati, Esterni, Convalidati e Manuali). Totale IN = Contati + Manuali + Bonus somma quindi due volte i convalidati **[V]** (formula) / **[D]** (se sia voluto).

### 4.2 Valorizzazione di ticket e premi

- **1 ticket = 0,01 €**, scritto nel codice in tre punti (`frmrapp.frm:2564`, `FrmRappUs.frm:1691`, `frmWrapp.frm:3352`). `Setup.ValTick` esiste ma i rapporti non lo usano **[V]**. Il nuovo sistema deve avere **un solo** parametro per sala (o per paese/valuta).
- **Premio:** due valori distinti, `Costo` (acquisto, €) e `N_Tickets` (prezzo in ticket). Sono **copiati** in `Vincite`, `Resi` e `Prenotaz` al momento dell'operazione, una riga per pezzo **[V]** `ModAddNew.bas:29-59`, `Form1.frm:6426-6428`. I rapporti storici usano quindi i valori dell'epoca: comportamento corretto, da preservare.
- **"Valore" premi consegnati** = ticket × 0,01 (prezzo di vendita teorico); **"Costo"** = costo d'acquisto. Le etichette non sono coerenti: la stampa termica chiama "valore" il costo; i resi e i prenotati mostrano solo il costo.
- **Profitto** (Rapporto Vendite e Settimanale) = Σ (N_Tickets × 0,01 − Costo) sui premi consegnati. È un **margine teorico sul premio**, non un profitto della sala.
- **Profitto lordo della sala** (solo Rapporto Settimanale) = incassi netti IVA − costo dei premi venduti − saldo netto dei movimenti di magazzino per causale (§ W09-08).
- **Redemption rate / payout:** non esiste un "ticket riscattati / ticket emessi". Il payout calcolato è **costo premi venduti / incasso netto redemption** (`frmWrapp.frm:3529`). Il rapporto ticket emessi/riscattati si ricava solo confrontando Totale IN e Totale OUT del Rapporto Vendite.

### 4.3 Due fonti per i "ticket pagati"

Il Rapporto Vendite usa Σ `Vincite.N_Tickets` come "Pagati", mentre la sezione "concorso" usa Σ `Tickets.TPagati` (`frmrapp.frm:2566` vs `:2739-2748`). Le due grandezze coincidono solo se ogni consegna scala esattamente i ticket in `Tickets`. Il commento a `:2745` ammette che storicamente non era così ("gli scontrini sommati … falsavano il calcolo").

### 4.4 Periodi e storico

- Il periodo di default è la **giornata lavorativa 06:00 → ora attuale** (manuale: "la giornata lavorativa comincia alle 6:00"); il Settimanale usa `Setup.TmOpen`/`TmClose`. Serve un concetto esplicito di **giornata contabile** della sala.
- "Scontrini", "Nelle Cards" e "Vita media scontrini" ignorano il periodo e leggono **tutto lo storico** di `Tickets` (in produzione dal 2002, DB 05): costo crescente e numeri non confrontabili tra un rapporto e l'altro. In `FrmRappUs` invece sono limitati al periodo.

### 4.5 Report che scrivono

| Dove | Cosa scrive | |
|---|---|---|
| Rapporto Vendite (ogni calcolo) | `Tickets.NumTickets` delle righe `Aux=1` non multiple di 5 | V |
| Rapporto Breve Utente | `Tickets.Id = 1` dove nullo | V/D |
| Griglie dei due rapporti | righe di `Vincite`, `Resi`, `Prenotaz` | D |
| Report dinamici | SQL arbitrario `execute_sql_before_print` / `update_sql_after_print` sul DB di sala | V |
| Rapporto Variazioni | file temporaneo `VInv.mdb` | V |
| Situazione Prize Hub | tabella `premi` del file Access `PremiPH.mdb` (tabella di appoggio) | V |
| Report dinamici | file `C:\sqltemp\rep_<nome>.xml` | V |

Nessun report di questa zona scrive tabelle di cache in SQL Server; `cache_dati_grafico_giornaliero` e `sp_generacache` sono usati da `FrmReportsECL` e `FrmEcs` (altra zona). `fn_dati_grafico_giornaliero` non è chiamata da questi file.

### 4.6 Multi-impianto e multi-locale

- **Nessun report della zona filtra per `NImp`** **[V]** (assente in tutti gli otto file). Ogni database è una sala; `NImp` serve a nominare il DB in cloud (`"DB" & NImp`) e a scegliere i report personalizzati.
- Il **multi-locale** (`Setup.T6`) cambia la **chiave di join del cliente** (`IdContatto` → `IdLong`) e attiva il riquadro Dare/Avere tra locali.
- In WinMTHQ lo stesso form viene aperto su ogni DB di sala e i risultati sono raccolti in `RapGen(NumLoc)` per il rapporto generale: l'aggregazione multi-sala avviene **lato client, una sala alla volta** **[V]** `frmWrapp.frm:3576-3607`.

### 4.7 Report dinamici

Il motore `cls_reports` è l'unica parte della zona già "data-driven": definizioni, filtri, stili e layout stanno in tabelle. Le definizioni stanno però in un **database cloud del fornitore**, con credenziali nel client, e il SQL viene eseguito con i privilegi dell'utente di sala. È un buon modello concettuale (catalogo di report parametrici, override per sala) ma non un buon modello di sicurezza.

---

## 5. Problemi rilevanti per il nuovo disegno

1. **Formule non uniche.** Lo stesso indicatore ("Pagati", "Scontrini", reparti, profitto medio) ha implementazioni diverse in `frmrapp`, `FrmRappUs` e `frmWrapp`. Nel nuovo sistema ogni misura va definita **una volta** lato server (coerente con il principio "logica una sola volta").
2. **Bitmask `MangiaT` con categorie sovrapposte.** Va sostituita da attributi espliciti del movimento ticket (origine, canale, stato, flag bonus/promozione) e da regole di aggregazione documentate.
3. **Valore del ticket hard-coded** (0,01 €) e parametro `ValTick` ignorato: serve un parametro unico, versionato nel tempo.
4. **Report che modificano dati** (correzione chips, `Id` forzato, griglie editabili, SQL prima/dopo stampa). Nel nuovo sistema la reportistica deve essere in sola lettura; le correzioni diventano eventi tracciati.
5. **Causali di magazzino come testo localizzato** confrontato con `LIKE`: il Rapporto Settimanale dipende dalla lingua dell'interfaccia. Servono causali codificate.
6. **Incassi registrati a mano** (`Incassi`, categorie fisse Red/Gru/Push/Alt, IVA per categoria) separati dalla telemetria delle macchine: il profitto lordo dipende da un dato che in molte sale è vuoto (DB 03: `Incassi`, `RiepInv` vuote). Il nuovo modello deve decidere la fonte dell'incasso (contatori ECL) e la categoria di macchina.
7. **Dipendenze da Access e da Excel** (`RiepInv.Mdb`, `PremiPH.mdb`, automazione COM): da eliminare.
8. **Catalogo dei report dinamici fuori dal repository** (`CoinlessDB.t_dynamic_reports`): le formule dei "Rapporti Vari" e "Rapporti Amministratori" non sono analizzabili dal sorgente e i report non funzionano offline.
9. **Query su tutto lo storico** a ogni apertura: con 20 anni di `Tickets` serve un modello a saldi/snapshot periodici.

---

## 6. Domande aperte per il team

1. Quali rapporti sono davvero usati in sala oggi: "Rapporto" (Vendite), Breve Utente, Settimanale/Variazioni (visibili solo con `RegInc`), Rapporti Vari/Amministratori?
2. Si può avere un export di `t_dynamic_reports` (gruppi `ReportsECLMT`, `ReportsSADM`, `WinMT`, `ReportsECL` e quelli per `DBnnn`)? Contiene le formule dei rapporti amministratori e del profitto per macchina.
3. Il valore del ticket è sempre 0,01 € in tutte le sale e i paesi (Regno Unito, Francia)? Perché `Setup.ValTick` non è usato dai rapporti?
4. La correzione automatica dei ticket "chips" (`+5 − resto + 10`) è ancora necessaria? Su quale macchina o firmware nasce l'errore?
5. "Totale IN" somma due volte i convalidati (sono sia Contati sia Manuali): è voluto?
6. Semantica contabile di `Tickets.F0`/`N0` nel multi-locale: chi scrive queste colonne (non trovato nel sorgente WinMT) e "Dare/Avere" sono dal punto di vista della sala che consegna o di quella che ha emesso i punti?
7. I "Pagati" devono venire dai premi consegnati (`Vincite.N_Tickets`) o dai ticket scalati (`Tickets.TPagati`)?
8. Il Rapporto Settimanale conta tutte le `Vincite` (anche `Cons = 0`) e tutte le `Prenotaz` (anche consegnate): è corretto?
9. Le griglie modificabili del Rapporto Vendite sono usate come strumento di correzione? Da chi?
10. Il rapporto generale multi-sala di WinMTHQ (`FrmIni`, `RapGen`) non è in questa copia del sorgente: dove si trova?
