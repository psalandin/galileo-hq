# Galileo HQ — WinMT 06: Premi, magazzino, ordini e prenotazioni

**Stato:** bozza · **Responsabile:** Piero · **Aggiornato:** 2026-10-23

**Fonte:** sorgente VB6 di WinMT (copia del 24/07/2026), file: `frmpremi.frm`, `FrmLismovN.frm`, `FrmMovmag.frm`, `FrmKit.frm`, `FrmSiteOut.frm`, `FrmPreLis.frm`, `FrmCariPO.frm`, `FrmVisPO.frm`, `cls_premio.cls`, `FrmSiteIn.frm`, `FrmFornit.frm`, `FrmPreCon.frm`, `FrmPrePre.frm`, `FrmReparti.frm`, `FrmCPOrd.frm`, `FrmTotPre.frm`, `FrmToPr.frm`; letti in parte `ModAddNew.bas`, `Module1.bas`, `Module6.bas`, `Form1.frm`, `FrmNTickMod.frm`, `FrmRappDis.frm`, `sql/codice-db/test/applicativo/procedure/PrizeHub_MoveToSlot.sql` · **Collegati:** `docs/db/db-01-schema.md`, `docs/db/db-02-catalogo.md`, `docs/db/db-03-risultati-01.md`, `docs/db/db-05-produzione-01.md`, `docs/fonti/winmt-manuale.md` (capitoli Prenotazioni, Ordini, Movimenti, Trasferimenti)

Legenda: **[V]** verificato nel codice (`file:riga`, righe del file originale); **[D]** dedotto, da confermare.

---

## 1. Perimetro

| File | Righe di codice | Ruolo | Lettura |
|------|----------------:|-------|---------|
| `frmpremi.frm` | 3097 | "Gestione Magazzino Premi": catalogo articoli, nuovo articolo, modifiche in griglia, stampe ed etichette, creazione ordine d'acquisto, menu verso tutte le altre maschere della zona | A fondo |
| `FrmLismovN.frm` (form `FrmLismov`) | 1997 | "Lista movimenti Premi": consultazione di carichi (`MovMag`) e scarichi (`MovOut`), modifica e cancellazione di bolle | A fondo |
| `FrmMovmag.frm` | 1995 | "Carico Magazzino": carico da bolla, carico automatico da file `.mdb`, carico remoto da HQ, lista approvata, trasferimenti in ingresso | A fondo (salvo stampe) |
| `FrmKit.frm` | 801 | "Scarico Premi - Resi": scarico e trasferimento in uscita verso i reparti del locale, resi a fornitore | A fondo |
| `FrmSiteOut.frm` | 721 | "Trasferimento ad altro Locale" (uscita) | A fondo |
| `FrmPreLis.frm` | 624 | Lista prenotazioni / lista ordini dei clienti, conferma, annullamento | A fondo |
| `FrmCariPO.frm` | 586 | Carico da ordine d'acquisto (consegne parziali) | A fondo |
| `FrmVisPO.frm` | 582 | Visualizza, ricrea, cancella ordini d'acquisto | A fondo (stampa scorsa) |
| `cls_premio.cls` | 540 | Classe di accesso a `Premi` (lettura, insert, update). **Non usata nella zona**: la usano `FrmInventario2` e `frmEditPrizeHub` | Scorsa |
| `FrmSiteIn.frm` | 454 | "Trasferimento da Locale" (ingresso automatico da file) | A fondo |
| `FrmFornit.frm` | 338 | Anagrafica fornitori | A fondo |
| `FrmPreCon.frm` | 282 | Consegna di prenotazioni e ordini al cliente | A fondo |
| `FrmPrePre.frm` | 213 | Preparazione ordini (cliente e totem/kiosk) con stampa | A fondo |
| `FrmReparti.frm` | 161 | Nomi e abilitazione dei "reparti" 2–9 | A fondo |
| `FrmCPOrd.frm` | 123 | Import automatico di ordini d'acquisto remoti (`porder.mdb`) | A fondo |
| `FrmTotPre.frm` | 89 | Consegna di un ordine leggendo il barcode della ricevuta | A fondo |
| `FrmToPr.frm` | 85 | Configurazione dei distributori automatici di premi ("TotemPrizes") | A fondo |

Fuori perimetro ma toccati per seguire i flussi: la consegna premi in cassa (`Form1`, `Frm4Usr`), l'inventario (`FrmInventario*`), i report (`frmrapp`, `frmWrapp`, `FrmRappUs`), le bolle (`FrmBolle`, `FrmBollIO`, `Frmmovdata`), i resi (`frmresauto`, `frmresman`).

---

## 2. Flussi

Attori: **Amm.** = livello 0 (Administrator), **Man.** = livello 1 (Manager), **Op.** = livello 2 (Operator), **Sup.** = livello 3 (Supervisor) [V `frmgesop.frm:1190-1202`, `Module1.bas:225`]. **HQ** = stesso eseguibile avviato come `WinMtHQ` (il codice ramifica su `App.EXEName`).

Quasi tutte le maschere che compongono un documento (bolla, scarico, trasferimento, ordine) usano come **area di appoggio la tabella `kitpremi` di un file Access locale `kitpremi.mdb`** nella cartella del programma [V `Module1.bas:970`; credenziale scritta nel codice in `Module1.bas:970`]. Il nome "Kit" viene da qui: **non esistono kit di premi** nel senso di articoli composti.

### W06-01 Consultazione del catalogo premi

- **Attore e innesco:** tutti i livelli, "Gestione Magazzino Premi" (`frmpremi`); filtri per codice, codice originale, descrizione, fornitore; combo Tutto/Tickets/Gru; "Solo premi attivi", "Visual. Q.tà inatt.", "LISTA Riserva", "Articoli prenotati".
- **Passi:** 1. `SqlPremi` compone la `SELECT` con i filtri; 2. calcola il valore del magazzino `sum(costo*quantita)` sullo stesso filtro; 3. mostra righe e numero articoli.
- **Dati:** `Premi.*` (lettura). L'operatore (livello ≥2) vede solo codice, codor, id, descrizione, tickets, quantità, icona.
- **Regole:** "Riserva" = `quantita < riserva`; "Prenotati" = `qpren > 0`; "Inattivi con quantità" = `attivo = 0 and quantita <> 0`; `Setup.NoInatt` nasconde gli inattivi; ordinamento per colonna.
- **Periferiche:** lettore barcode seriale (`BarRd`): la lettura cerca prima per `codice`, poi per `codor` e posiziona la griglia.
- **Peso:** S — consultazione con filtri.
- **Evidenze:** `frmpremi.frm:5052-5144` (SqlPremi), `2096-2156` (barcode), `2812-3194` (Form_Load e permessi).

### W06-02 Modifica dell'anagrafica in griglia

- **Attore e innesco:** Amm./Man. (con limiti), griglia di `frmpremi`; ogni modifica di cella viene salvata subito (`UpdateBatch`).
- **Passi:** 1. modifica di una cella; 2. `grdDataGrid_BeforeColUpdate` rifiuta costo o tickets ≤ 0; 3. `AfterColEdit` salva il record.
- **Dati scritti:** `Premi.Descrizione, Costo, N_Tickets, Fornitore, Riserva, Conf, Ordinato, Attivo, Gru, Riord, Prenotabile`; **`Premi.Quantita`** se `Setup.MQPrem`; **`Premi.Codice` e `Premi.CodOr`** se livello 0 e `Setup.ModCode` ("Modifica Codice Premi").
- **Regole:** per il Manager `Setup.MMCosto`/`MMTick` bloccano costo/tickets, `Setup.F4` (descrizione) e `Setup.F5` (barcode) li sbloccano, `Setup.ManAdd` abilita "Nuovo", `Setup.NoCanPr` nasconde "Elimina" [V `frmpremi.frm:2840-2856`, `3157-3159`; `Module1.bas:57-58`]. In HQ tutte le colonne sono bloccate tranne `Ordinato` [V `frmpremi.frm:3151-3154`].
- **Comportamento critico:** la modifica di `Quantita` **sovrascrive la giacenza senza generare movimenti**; la modifica di `Codice` **non aggiorna lo storico** (`MovMag`, `MovOut`, `Vincite`, `Prenotaz`, `Ordini` restano col vecchio codice) e non ci sono trigger su `Premi` che lo facciano [V `frmpremi.frm:2900-2913`, `3267-3287`; trigger in `sql/codice-db/test/applicativo/trigger/`].
- **Peso:** M — una tabella ma molte regole di permesso da `Setup`.
- **Evidenze:** `frmpremi.frm:3267-3293`, `2900-2913`.

### W06-03 Nuovo articolo con carico iniziale

- **Attore e innesco:** Amm. (Man. se `Setup.ManAdd`), pulsante "Nuovo" → "Salva"; si apre anche leggendo un barcode sconosciuto.
- **Passi:** 1. se manca uno dei due codici prende l'altro; 2. controlla caratteri (`CodiceOk`: `0-9 A-Z a-z . - _`) e lunghezza ≥5 per codice e barcode; 3. obbligatori costo >0, tickets >0, quantità, fornitore, descrizione; 4. verifica che né `Codice` né `CodOr` esistano già come codice o barcode di un altro articolo; 5. `AddPremio`; 6. crea foto e icona di default; 7. `AddMovIn` con motivo `CARICO` e nota "Carico manuale", bolla `MANU`, quantità = quantità iniziale. Se il fornitore non esiste apre l'anagrafica fornitori.
- **Dati:** `Premi` (insert: `QPren=0, Ordinato=0, Attivo=1, Locked=0, Prenotabile=1, Riord=1, Id2=0, Gru` da Tipo T/C), `MovMag` (insert), `Fornitori` (lettura).
- **Regole:** `Setup.AutoNT`: `N_Tickets = arrotondamento alla decina di Costo × Setup.NTMolt` (≥5 arrotonda per eccesso) [V `frmpremi.frm:2796-2806`].
- **Peso:** M — due tabelle e controlli di unicità incrociati.
- **Evidenze:** `frmpremi.frm:2272-2574`; `ModAddNew.bas:127-163`, `204-235`; `Module6.bas:1755-1770`.

### W06-04 Eliminazione di articoli

- **Attore e innesco:** Amm./Man. (salvo `Setup.NoCanPr`), "Elimina", anche multiselezione.
- **Passi:** `delete from premi where codice=…`; solo nella build con costante `Ceschina` chiede se cancellare anche i movimenti (`MovMag`, `MovOut`).
- **Dati:** `Premi` (delete), eventualmente `MovMag`, `MovOut` (delete).
- **Regole:** nessun controllo su giacenza, prenotazioni, ordini o storico: lo storico resta orfano. Spiega gli orfani misurati in DB 03 e DB 05.
- **Peso:** S.
- **Evidenze:** `frmpremi.frm:3952-4020`, `5266-5302`.

### W06-05 Aggiornamento barcode e foto

- **Attore e innesco:** Amm. (Man. se `Setup.F5`), "Aggiorna Barcode" + lettura scanner, doppio clic su `CodLet`; clic sull'immagine per caricare una foto.
- **Dati:** `Premi.CodOr` (update; se il barcode è già usato l'errore di indice unico viene intercettato e il valore ripristinato); `Premi.Foto` (jpg ridimensionato) e `Premi.Icona` (miniatura).
- **Peso:** S.
- **Evidenze:** `frmpremi.frm:2582-2627`, `2636-2641`, `4195-4259`, `5330-5357`.

### W06-06 Modifica massiva del numero di tickets

- **Attore e innesco:** Amm./Man., menu "Modifica N.Tickets" (`FrmNTickMod`) su selezione o su tutti.
- **Regola:** `N_Tickets = Costo × moltiplicatore`, con opzione di arrotondamento alla decina superiore. Nessuno storico del prezzo in ticket.
- **Dati:** `Premi.N_Tickets` (update).
- **Peso:** S.
- **Evidenze:** `FrmNTickMod.frm:219-226`; `frmpremi.frm:4998-5001`.

### W06-07 Stampe, etichette ed esportazioni del catalogo

- **Attore e innesco:** Amm./Man., menu File.
- **Varianti:** etichetta barcode singola o di tutti gli articoli su stampante termica (Neos, Lola, K3: identificazione della stampante con comando ESC/POS, barcode CODE93 del **Codice**, non del barcode del fornitore); lista e "Articoli in riserva" su termica; lista A4 di magazzino, "Lista conteggio" per l'inventario (colonne vuote Macchine/Negozio/Magazzino); esportazione Excel o CSV; programma esterno `WinMtEtic` per etichette personalizzate.
- **Dati:** `Premi` (lettura).
- **Periferiche:** stampante scontrini seriale (`Form1.Stmp`), stampante di sistema, Excel.
- **Peso:** M — molte varianti di stampa, nessuna scrittura.
- **Evidenze:** `frmpremi.frm:4129-4193`, `4865-4986`, `3670-3808`, `3456-3620`, `4277-4293`.

### W06-08 Ricalcolo delle giacenze dall'inventario

- **Attore e innesco:** Amm. con `Setup.ModCode`, pulsante "Ricalcola"/"Quantity Refresh"; avviso "potrebbe danneggiare l'archivio Premi".
- **Passi:** legge `inv` dal file locale `inv.mdb` dell'inventario e, per ogni articolo con `Premi.Quantita <> qreal`, esegue `UpdateQty` (`update premi set quantita=…`).
- **Dati:** `Premi.Quantita` (update), `inv.mdb` (lettura).
- **Regole:** nessun movimento di rettifica (è il difetto n. 6 di Analisi 00, § 6).
- **Peso:** M — dipende dall'inventario (zona inventario).
- **Evidenze:** `frmpremi.frm:2648-2698`; `Module6.bas:1427-1444`; `FrmInventario.frm:4553`.

### W06-09 Carico da bolla (e varianti manuali)

- **Attore e innesco:** Amm./Man., "Movimenti → Carico" scheda "Carico Bolla"; stesse maschera e logica per **"Trasferimenti Ingresso"** (rientro da reparto) e per **"Trasferimenti tra Locali → Carico → Manuale"**.
- **Passi:** 1. scelta fornitore (mostra i suoi articoli) o lettura barcode; 2. righe aggiunte in `kitpremi.mdb` con controllo di coerenza codice/barcode; 3. "Chiudi Bolla": data non anteriore all'ultimo inventario, numero bolla e fornitore obbligatori, coppia (`nbolla`, `nordine`) non già presente in `MovMag`; 4. per ogni riga: se l'articolo non esiste → `AddPremio` (giacenza = quantità caricata) + `AddMovIn`; se esiste → `AddMovIn` + `ModificaPremio` (sovrascrive codor, descrizione, costo, tickets, riserva e somma la quantità); 5. crea il fornitore se non esiste.
- **Dati:** `MovMag` (insert), `Premi` (insert/update), `Fornitori` (insert), `kitpremi.mdb`.
- **Regole:** il motivo è `CARICO` nel carico normale; `GRU`/`CONSUMABILI`/`EVENTI`/`RUSPE` nei trasferimenti in ingresso; `SPOSTA` (o `TRANSFER`/`TRANSFERT` secondo la lingua) per il trasferimento manuale, con il **locale di origine in `MovMag.Note`** scelto da `Setup.T5`. Nei trasferimenti in ingresso, un articolo nuovo viene creato con `Gru = (indice motivo > 1)` [V `FrmMovmag.frm:2604-2608`]. `ModificaPremio` scrive `Ordinato = False`, cioè **azzera la quantità da ordinare** a ogni carico di un articolo esistente [V `FrmMovmag.frm:2620`, `ModAddNew.bas:987-1003`].
- **Periferiche:** lettore barcode; il lettore accetta anche codici speciali `NUMx`, `CANCE`, `CONFE` per digitare la quantità [V `FrmMovmag.frm:4219-4243`].
- **Peso:** L — tre varianti, area di appoggio su file, regole di deduplicazione codice/barcode.
- **Evidenze:** `FrmMovmag.frm:2345-2490`, `2492-2678`, `3714-3903`.

### W06-10 Carico automatico da file

- **Attore e innesco:** Amm./Man., scheda "Carico Automatico": file `.mdb` (tabella `kitpremi`) prodotto dal magazzino centrale "GesPremi" o da un altro locale, con eventuale cartella foto accanto.
- **Passi:** 1. il nome file deve avere almeno 16 caratteri con 12 caratteri prima del punto; 2. un file già caricato viene rifiutato (registro in `loadnote.txt`); 3. per ogni riga con costo > 0: codice nuovo e barcode nuovo → `AddPremio`; stesso barcode e codice diverso → se `Setup.F3` (`BCodeOver`) **sostituisce il codice dell'articolo esistente** col codice del file, altrimenti la riga resta nel file; stesso codice e barcode diverso → la riga resta; stesso codice e barcode → aggiorna anagrafica e somma la quantità; 4. `AddMovIn` con motivo `CARICO`, nota "Carico Automatico", bolla `AU` + 12 caratteri del nome file; 5. importa foto e icona.
- **Dati:** `Premi` (insert/update, anche `Codice`), `MovMag` (insert), `Fornitori` (insert); file `.mdb` esterno, `loadnote.txt`.
- **Peso:** L — regole di riconciliazione dei codici, file esterni, foto.
- **Evidenze:** `FrmMovmag.frm:3142-3208`, `3210-3559`; `Module1.bas:2623`, `Module1.bas:49`.

### W06-11 Carico remoto da HQ

- **Attore e innesco:** Amm./Man. (Op. se `Setup.OpCaRem`), scheda "Carico Remoto", visibile solo se esiste una lista pendente; la cassa avvisa [V `Form1.frm:17181-17185`].
- **Passi:** 1. `ListaFileRemoti`: `select * from riepinv where F0=1 and d0 is null`; 2. estrae il blob `RiepInv.Mdb` in `KitPremiRem.mdb`; 3. l'operatore può correggere le quantità consegnate; 4. stessa logica di W06-10 con nota "Carico Remoto", `NBolla = NOrdine = "CR" + ddmmyyhhmmss` (data di creazione della lista); 5. `update Riepinv set D0=getdate()`.
- **Dati:** `RiepInv` (lettura, update `D0`), `Premi`, `MovMag`, `Fornitori`.
- **Comportamento senza rete:** la lista arriva in sala via sincronizzazione di `RiepInv`; il carico in sé è locale [D].
- **Peso:** M.
- **Evidenze:** `FrmMovmag.frm:4365-4435`, `3142-3166`, `3369-3378`; documentazione nel codice `Module1.bas:43-46`.

### W06-12 Import della lista approvata

- **Attore e innesco:** Amm. (Man. se `Setup.OpAppL`), menu "Lista Approvata": file `.mdb` nella cartella `Approved_List` con tabelle `AppList` e `suppliers` (nata per il mercato inglese).
- **Passi:** 1. rifiuta il file se qualche descrizione contiene caratteri non validi; 2. per ogni articolo: se manca → `AddPremio` con giacenza 0; se esiste → aggiorna descrizione, fornitore, `Id`, `Conf`, `Riord` e, secondo le caselle `ALAggCosto`, `ALAggBarc`, `ALAggTick`, `ALAggRis`, costo, barcode, tickets, riserva; 3. copia le foto; 4. inserisce o aggiorna i fornitori; 5. azzera `Setup.FtpAppL`.
- **Dati:** `Premi` (insert/update), `Fornitori` (insert/update), `Setup.FtpAppL`.
- **Peso:** M.
- **Evidenze:** `FrmMovmag.frm:2316-2343` (credenziale scritta nel codice in `FrmMovmag.frm:2325`), `2716-2837`.

### W06-13 Scarico, trasferimento in uscita verso reparto, reso a fornitore

- **Attore e innesco:** Amm./Man., "Movimenti → Scarico", "Trasferimenti Uscita", "Resi" (`FrmKit`).
- **Passi:** 1. motivo obbligatorio: `SPOSTA`, `GUASTO`, `GRU`, `CONSUMABILI`, `EVENTI`, `RUSPE` (default `GRU`); 2. righe in `kitpremi.mdb` scelte per codice, descrizione, fornitore o barcode (solo articoli con giacenza > 0); "Svuota tutto" mette in lista tutta la giacenza; 3. "Scarica": numero bolla **e** numero ordine obbligatori, coppia non già usata in `MovOut`, data non anteriore all'ultimo inventario, nessuna riga a quantità 0; 4. per ogni riga `Premi.Quantita -= q`, **se diventa negativa viene forzata a 0** con un avviso; `AddMovOut`; se spuntato "Cancella premi con quantità azzerata" **cancella l'articolo** (in realtà ogni articolo scaricato, non solo quelli azzerati); 5. copia `kitpremi.mdb` in `Unloads\<nome>.mdb`.
- **Dati:** `Premi` (update/delete), `MovOut` (insert: `Fornitore` = destinazione scelta o nome del locale, `Motivo`, `Note` per riga, `NBolla`, `NOrdine`, `Oper`), file in `Unloads`.
- **Regole:** il valore dello scarico è `Σ quantità × Premi.Costo`.
- **Peso:** M.
- **Evidenze:** `FrmKit.frm:1205-1249`, `1295-1455`, `1603-1636`, `1739-1746`.

### W06-14 Trasferimento ad altro locale (uscita)

- **Attore e innesco:** Amm./Man., "Trasferimenti tra Locali → Scarico" (`FrmSiteOut`).
- **Passi:** come W06-13 ma con **locale di destinazione** obbligatorio (elenco da `Setup.T5`), motivo fisso `TRANSFER`, `MovOut.Note` = locale di destinazione; il file viene copiato in `Unloads\<nome>.txt` (estensione `.txt` per un contenuto Access).
- **Dati:** `Premi` (update/delete), `MovOut` (insert), file in `Unloads`.
- **Regole:** il destinatario è un **nome libero di locale**, non un'entità. Il trasporto del file al locale di destinazione è manuale (allegato alla merce, chiavetta, email) [V manuale § "Trasferimenti tra Locali"; D sul mezzo].
- **Peso:** M.
- **Evidenze:** `FrmSiteOut.frm:1280-1342`, `1570-1578`, `1718`.

### W06-15 Trasferimento da altro locale (ingresso automatico)

- **Attore e innesco:** Amm./Man., "Trasferimenti tra Locali → Carico → Automatico" (`FrmSiteIn`); i file vanno copiati a mano nella cartella `Loads`.
- **Passi:** 1. "Aggiorna" rinomina `*.txt` in `*.mdb`; 2. apertura: copia la quantità originale in `kitpremi.Oper` per il confronto finale; 3. l'operatore corregge le quantità consegnate; 4. "Salva": numero consegna obbligatorio; per ogni riga stessa riconciliazione codice/barcode di W06-10 (senza `BCodeOver`); `AddMovIn` con motivo `SPOSTA`/`TRANSFER`, `NBolla` = numero consegna e `NOrdine` = numero bolla del file; 5. le righe consegnate per intero vengono tolte dal file, quelle parziali restano con il residuo; il file si cancella quando è vuoto.
- **Dati:** `Premi` (insert/update, anche foto), `MovMag` (insert), `Fornitori` (insert).
- **Regole:** il "locale di origine" mostrato è letto da `kitpremi.Note`, che il mittente ha valorizzato con il **locale di destinazione** [V `FrmSiteIn.frm:977` contro `FrmSiteOut.frm:1718`]. La nota del movimento è "Carico Automatico" in italiano e il nome del locale in inglese.
- **Peso:** M — consegne parziali su file.
- **Evidenze:** `FrmSiteIn.frm:969-990`, `1161-1180`, `1182-1338` (credenziale scritta nel codice in `FrmSiteIn.frm:972`).

### W06-16 Consultazione dei movimenti

- **Attore e innesco:** Amm./Man., "Visualizza Movimenti → Movimenti Magazzino" (`FrmLismov`), schede Carico e Scarico.
- **Passi:** filtri per periodo e ora, codice, barcode, descrizione, numero bolla, numero ordine, operatore, fornitore/destinatario, motivo (e locale se motivo `SPOSTA`); totali articoli e valore `Σ costo × quantità`; esportazione Excel/CSV e stampa A4.
- **Dati:** `MovMag`, `MovOut` (lettura, join `Operatori` su `Oper`), `Premi`, `Fornitori`.
- **Peso:** M — due liste, molti filtri, esportazioni.
- **Evidenze:** `FrmLismovN.frm:4087-4467`, `4488-4634`, `2938-3190`, `3477-4080`.

### W06-17 Modifica di un singolo movimento

- **Attore e innesco:** Amm./Man., doppio clic su una riga di `FrmLismov`, "Movement Save".
- **Passi:** ritrova la riga confrontando tutti i campi (non c'è una chiave usata dal codice) e aggiorna `Quantita` e `Note`.
- **Regole:** **la giacenza `Premi.Quantita` non viene riallineata** [V `FrmLismovN.frm:3409-3475`].
- **Peso:** S.

### W06-18 Modifica di una bolla

- **Attore e innesco:** Amm./Man., "Modifica Bolla" su una bolla filtrata.
- **Passi:** copia le righe della bolla in `kitpremi.mdb`, consente la modifica in griglia, poi riporta le differenze: per lo scarico ricalcola `Premi.Quantita` e `MovOut.Quantita`; per il carico propaga a `Premi` **e** a `MovMag` le modifiche di codice, barcode, descrizione, quantità (con riallineamento della giacenza), costo e tickets.
- **Dati:** `MovMag`/`MovOut` (update), `Premi` (update, **anche `Codice`**).
- **Peso:** M.
- **Evidenze:** `FrmLismovN.frm:3192-3407`.

### W06-19 Cancellazione di una bolla

- **Attore e innesco:** Amm./Man. (nascosto con `Setup.HideMov`), "Cancella" su carichi o scarichi filtrati per numero bolla o ordine.
- **Passi:** rifiuta se la bolla è anteriore all'ultimo inventario; storna la giacenza riga per riga (`UpdateQty`: carico → sottrae, scarico → somma) e poi `delete from movmag|movout where nbolla=…`.
- **Regole:** la cancellazione usa **solo il numero bolla**, anche se il filtro era sul numero ordine; i movimenti vengono cancellati fisicamente (e la cancellazione si propaga al cloud via sincronizzazione).
- **Peso:** M.
- **Evidenze:** `FrmLismovN.frm:2711-2801`, `2842-2932`.

### W06-20 Creazione di un ordine d'acquisto

- **Attore e innesco:** Amm./Man. (`Setup.POMan`), in `frmpremi` si valorizza la colonna "Ordin." (`Premi.Ordinato`) e si sceglie "Crea Ordine di Acquisto" (abilitato dopo aver filtrato un fornitore) o "Ordine d'Acquisto" (solo stampa).
- **Passi:** 1. filtra `ordinato > 0`; 2. in sala esclude gli articoli con `riord = 0` e quelli con `ordinato % conf <> 0` (confezioni incomplete); `Conf = 0` blocca l'operazione; 3. chiede il numero d'ordine, che deve essere nuovo; 4. `AddOrdine` per ogni riga (`QOrd = Ordinato`, `QCons = 0`); 5. in HQ imposta un flag su file `POFlags.bin`; 6. stampa A4 con indirizzo di spedizione (`Setup.NomeSped…`) e di fatturazione.
- **Dati:** `Premi` (lettura), `Ordini` (insert).
- **Regole:** **`Premi.Ordinato` non viene azzerato** dopo la creazione dell'ordine [V `frmpremi.frm:4529-4547`]. Il fornitore dell'ordine è il testo `Premi.Fornitore`.
- **Peso:** M.
- **Evidenze:** `frmpremi.frm:4295-4863`, `3348-3356`.

### W06-21 Visualizzazione, duplicazione e cancellazione di ordini d'acquisto

- **Attore e innesco:** Amm./Man., "Visualizza Movimenti → Ordini di Acquisto" (`FrmVisPO`); in HQ anche "Ordini in attesa".
- **Passi:** carica un ordine in `kitpremi.mdb`; consente di salvarlo con un **nuovo numero** (gli articoli inesistenti vengono creati con giacenza 0) e imposta `Premi.Ordinato = quantità`; cancellazione dell'intero ordine se `Setup.CanPO`; in HQ cancellazione di una riga.
- **Dati:** `Ordini` (lettura/insert/delete), `Premi` (insert/update). In HQ legge `porder` da `C:\WinMt\remote\data\<locale>\porder.mdb` (percorso legato alla vecchia versione remota) [V `FrmVisPO.frm:1205`].
- **Regole:** chiamata ad `AddPremio` con argomenti sfalsati: l'articolo nuovo nasce con `Id2 = 1`, `Conf = 0` e **`Gru = True`** [V `FrmVisPO.frm:821`].
- **Peso:** M.
- **Evidenze:** `FrmVisPO.frm:678-922`.

### W06-22 Carico da ordine d'acquisto

- **Attore e innesco:** Amm./Man., "Carico da Ordine di Acquisto" (`FrmCariPO`).
- **Passi:** 1. elenca gli ordini con almeno una riga `qcons < qord`; 2. carica le righe in `kitpremi.mdb` (`Quantità` = ordinato, `Riserva` = già consegnato, `Note` = residuo, `Oper` = quantità arrivata da inserire); 3. l'operatore inserisce le quantità arrivate (non oltre il residuo); 4. "Chiudi Bolla": numero consegna obbligatorio, coppia non già usata, data non anteriore all'inventario; per ogni riga: `AddMovIn` (motivo `CARICO`), `Ordini.QCons += arrivato`, `Premi.Quantita += arrivato`, `Premi.Ordinato -= arrivato` (articolo esistente) oppure `AddPremio` (articolo nuovo); 5. "Completa" chiude l'ordine forzando `QOrd = QCons` su tutte le righe.
- **Dati:** `Ordini` (update), `MovMag` (insert), `Premi` (update/insert).
- **Regole:** **inversione dei campi**: il movimento ha `NBolla` = numero d'ordine e `NOrdine` = numero di consegna, mentre il controllo di duplicato li cerca invertiti [V `FrmCariPO.frm:900`, `962`, `991`].
- **Peso:** M.
- **Evidenze:** `FrmCariPO.frm:812-856`, `862-1044`, `1097-1146`, `1324-1329`.

### W06-23 Import di ordini d'acquisto remoti

- **Attore e innesco:** automatico all'avvio della cassa se `Setup.FtpPOrd` = vero ("scaricato POrder.mdb"), con 10 secondi per annullare (`Setup.NoAnnAPl` nasconde "Annulla").
- **Passi:** legge `porder.mdb` nella cartella del programma; per ogni ordine non già presente: `Premi.Ordinato += QOrd` e `AddOrdine` copiando tutti i campi; un ordine già presente viene scartato; cancella il file e azzera il flag.
- **Dati:** `Premi.Ordinato` (update), `Ordini` (insert), `Setup.FtpPOrd`.
- **Regole:** chi scarica il file e alza il flag non è in questo sorgente [D: un programma esterno o il vecchio canale FTP].
- **Peso:** M.
- **Evidenze:** `FrmCPOrd.frm:351-444` (credenziale scritta nel codice in `FrmCPOrd.frm:372`); `Form1.frm:8183-8185`.

### W06-24 Anagrafica fornitori

- **Attore e innesco:** Amm. (Man. se `Setup.FornMan`), menu "Fornitori"; si apre anche dal nuovo articolo se il fornitore digitato non esiste.
- **Dati:** `Fornitori` (insert, update in griglia, delete).
- **Regole:** chiave = `Nome`; nessun controllo di utilizzo alla cancellazione e nessuna propagazione di un cambio di nome a `Premi.Fornitore`, `MovMag.Fornitore`, `Ordini.Fornitore`.
- **Peso:** S.
- **Evidenze:** `FrmFornit.frm:773-826`, `980-1000`, `1026-1094`.

### W06-25 Liste di prenotazioni e ordini, conferma di disponibilità

- **Attore e innesco:** operatori di cassa, menu "Prenotazioni → Lista" e "Ordini → Lista" (`FrmPreLis`).
- **Passi:** 1. elenca le righe `Prenotaz` con `conf = 1` e `quantita < 0` (prenotazioni) oppure `quantita > 0` (ordini), con filtri "da consegnare" e "annullate"; 2. **"Conferma"** (solo prenotazioni): `Quantita = abs(Quantita)` e `DataConf = Now`, cioè la prenotazione **diventa un ordine**; se il cliente ha l'app (`Clienti.IdTel`) invia notifica push ed email "il premio è disponibile, ritiralo entro N giorni" (N = `Setup.TotTick \ 1000`); 3. esportazione Excel e stampa.
- **Dati:** `Prenotaz` (lettura/update), `Clienti.IdTel` (lettura), `Operatori` (join per i nomi).
- **Periferiche:** servizio di notifica (`SendPush`, `SendMail`).
- **Peso:** M.
- **Evidenze:** `FrmPreLis.frm:509-574`, `985-1069`; manuale § "Prenotazione dei Premi".

### W06-26 Annullamento di prenotazione o ordine con rimborso

- **Attore e innesco:** solo Amm. (livello 0), "X"/"Elimina" in `FrmPreLis` o `FrmPreCon` [V `FrmPreLis.frm:1055-1059`, `FrmPreCon.frm:664`].
- **Passi:** 1. `Prenotaz.Cons = Annul = Conf = MsgInv = 1`, `DataCon = Now`, `IdOpCo` = operatore; 2. `Premi.QPren -= |Quantita|`; 3. rimborso di `Prenotaz.N_Tickets`: cliente senza card → stampa uno scontrino di resto; cliente con card → `Clienti.Tickets += N_Tickets`; 4. `AddScon` scrive un `Tickets` con `MangiaT = 2056`; 5. cancella una `Vincite` dello stesso cliente, codice e giorno.
- **Dati:** `Prenotaz` (update), `Premi.QPren` (update), `Clienti.Tickets` (update), `Tickets` (insert), `Vincite` (delete).
- **Regole:** il rimborso è **per un pezzo**: con quantità > 1 si rimborsa e si cancella una sola vincita [V `FrmPreLis.frm:642-655`]. Le due maschere scrivono il `Tickets` di rimborso con `NonCont` e `NRep` diversi (`True,0` contro `False,1`) [V `FrmPreLis.frm:649`, `FrmPreCon.frm:539`].
- **Periferiche:** stampante scontrini.
- **Peso:** L — tocca quattro tabelle di due zone e la stampante, senza transazione.
- **Evidenze:** `FrmPreLis.frm:576-658`; `FrmPreCon.frm:496-547`; `ModAddNew.bas:61-97`, `AddTicCli`.

### W06-27 Consegna di un premio prenotato o ordinato

- **Attore e innesco:** operatore di cassa; si apre da solo alla lettura della card se il cliente ha ordini consegnabili (`Form1.GesOrdPren`), oppure da menu "Ordini → Consegna" / "Prenotazioni → Consegna" (`FrmPreCon`).
- **Passi:** 1. `GesOrdPren` marca ogni ordine del cliente con `IdOpCo = -2` se `Premi.Quantita ≥ Σ ordini aperti` del codice, altrimenti `-1`, e mostra i consegnabili; 2. "Consegna": blocco applicativo `Premi.Locked = IdPost`, `Premi.Quantita -= |q|`, `Premi.QPren -= |q|`, sblocco; `Prenotaz.Cons = 1`, `DataCon`, `IdOpCo`; `update vincite set Cons=1, D0=getdate()` sulle vincite dello stesso cliente, codice e giorno; 3. per gli ordini con `IdOp` tra 1009 e 1018 consegna tutte le righe in un colpo; 4. ristampa della ricevuta con barcode `P<SerNum esadecimale>R`.
- **Dati:** `Prenotaz` (update), `Premi.Quantita, QPren, Locked` (update), `Vincite.Cons, D0` (update).
- **Regole:** **nessun `MovOut`**: la consegna riduce la giacenza senza movimento di magazzino (come la consegna normale in cassa, `Form1.frm:15711`).
- **Periferiche:** stampante scontrini, lettore card.
- **Peso:** M.
- **Evidenze:** `FrmPreCon.frm:409-494`, `553-603`, `691-755`; `Form1.frm:17032-17093`.

### W06-28 Consegna da ricevuta

- **Attore e innesco:** operatore di cassa che legge col lettore il barcode della ricevuta (`P…R`) → `FrmTotPre`.
- **Passi:** `SerNum` = parte esadecimale del barcode; mostra le righe `quantita > 0` non consegnate; "Consegna" come W06-27 (con blocco solo se `Setup.MultiUser`).
- **Dati:** `Prenotaz`, `Premi`, `Vincite` (update).
- **Peso:** M.
- **Evidenze:** `FrmTotPre.frm:225-319`.

### W06-29 Preparazione degli ordini (cliente e totem)

- **Attore e innesco:** operatore di cassa, "Ordini → Prepara" (cliente selezionato) o pulsante "Kiosk Orders" (visibile se esiste un totem: ordini con `IdOp` 1009–1018).
- **Passi:** elenca gli ordini `quantita > 0`, `F0 = 0`; "Prepara" stampa la distinta di tutte le righe con lo stesso `T0` (numero d'ordine) e il barcode della ricevuta, poi `update Prenotaz set F0=1 where T0=…`.
- **Dati:** `Prenotaz.F0` (update).
- **Periferiche:** stampante scontrini.
- **Peso:** M.
- **Evidenze:** `FrmPrePre.frm:378-476`, `487-511`; `Form1.frm:7480-7497`.

### W06-30 Ricalcolo delle quantità prenotate

- **Attore e innesco:** Amm., clic destro su "Elimina" in `FrmPreLis`.
- **Regola:** `QPren = 0` per tutti, poi `QPren = Σ |Prenotaz.Quantita|` delle righe `cons = 0` per codice.
- **Dati:** `Premi.QPren` (update), `Prenotaz` (lettura).
- **Peso:** S.
- **Evidenze:** `FrmPreLis.frm:660-709`.

### W06-31 Distributori automatici di premi

- **Attore e innesco:** Amm./Man.; `FrmToPr` (crea, abilita, disabilita distributori), menu "Inserisci nel Distributore Automatico" in `frmpremi`, report giacenza distributore `FrmRappDis`.
- **Passi:** 1. un distributore è un record `Operatori` con `Nome = 'TotemPrizes'` e `Id` 1001–1010 (massimo 10); 2. l'inserimento scrive gli articoli selezionati nel file locale `premiph.mdb` (posizione `X1, X2…`, quantità 0, quantità di magazzino); 3. il report legge `Premi.PDisN`/`QDisN` del distributore N.
- **Dati:** `Operatori` (insert/update), `Premi.PDis1..8`, `QDis1..8` (lettura), `premiph.mdb`.
- **Regole:** la funzione storica è superata dal Prize HUB (`PrizeHubSlots`, `frmEditPrizeHub` dichiara di non usare più `PDis/QDis`) [V `frmEditPrizeHub.frm:518`].
- **Peso:** M.
- **Evidenze:** `FrmToPr.frm:238-322`; `frmpremi.frm:3380-3454` (credenziale scritta nel codice in `frmpremi.frm:3388`); `FrmRappDis.frm:542`.

### W06-32 Reparti dei ticket

- **Attore e innesco:** Amm., Setup generale → "Gestione Reparti".
- **Dati:** `Setup.NRep2..9` (nome) e `Setup.ARep2..9` (abilitato) via la struttura `Reparti`; reparto 1 fisso "Redemption", reparto 2 "sempre Mistral" secondo un commento in `FrmRappUs`.
- **Regole:** questi reparti classificano i **ticket emessi** (`Tickets.NRep`, scontrini da reparto), **non** le destinazioni di magazzino, che sono i motivi `GRU`, `CONSUMABILI`, `EVENTI`, `RUSPE`, `GUASTO` [V `FrmReparti.frm:671-829`; `FrmRappUs.frm:3698`, `4374`; `FrmRepTick.frm:766`].
- **Peso:** S.

---

## 3. Significato delle colonne

### Premi

| Colonna | Significato | Valori / codifiche | Evidenza | |
|---------|-------------|--------------------|----------|---|
| `Premi.Codice` | Codice interno dell'articolo, chiave primaria; è il codice stampato come barcode CODE93 sulle etichette | ≥5 caratteri `0-9 A-Z a-z . - _`; se vuoto = `CodOr`; **modificabile** (ModCode, modifica bolla, `BCodeOver`) senza aggiornare lo storico | `frmpremi.frm:2304-2331`, `4163-4173`, `3267-3287`; `FrmLismovN.frm:3247-3256`; `FrmMovmag.frm:3320-3323` | V |
| `Premi.CodOr` | "Codice Originale" / "Barcode": codice a barre del fornitore (EAN) | Indice unico; se vuoto = `Codice`; ≥5 caratteri; la ricerca da scanner prova prima `Codice` poi `CodOr`. `cls_premio.UpdatePremio` lo usa come chiave del `WHERE` | `frmpremi.frm:2125`, `2582-2627`; `cls_premio.cls:251` | V |
| `Premi.Id` | Codice breve visualizzato e ricercabile in cassa ("ID") | Testo libero, max 5 caratteri in griglia; da lista approvata o file di carico | `frmpremi.frm:4123-4126`; `Form1.frm` (filtro `id like`) | V |
| `Premi.Id2` | Nessun uso funzionale trovato | Sempre 0; 1 solo per un errore di argomenti in `FrmVisPO.frm:821` | `ModAddNew.bas:151` | D |
| `Premi.Descrizione` | Descrizione | Ripulita da apici nei carichi da file | — | V |
| `Premi.Costo` | Costo d'acquisto unitario in valuta | >0 obbligatorio; sovrascritto da carichi e lista approvata; valore magazzino = `Σ Costo × Quantita` | `frmpremi.frm:3289-3292`, `5126` | V |
| `Premi.N_Tickets` | Prezzo dell'articolo in ticket/punti | >0; calcolabile come `Costo × NTMolt` arrotondato alla decina; in cassa scontato da promo e bonus | `frmpremi.frm:2796-2806`; `FrmNTickMod.frm:219` | V |
| `Premi.Fornitore` | Nome del fornitore abituale | Testo = `Fornitori.Nome`, senza vincolo | `frmpremi.frm:3250-3265` | V |
| `Premi.Quantita` | **Giacenza attuale**, campo aggiornato direttamente da ogni flusso (vedi § 4) | Può andare a 0 forzato negli scarichi; sovrascrivibile in griglia (`MQPrem`) e dal ricalcolo inventario | § 4 | V |
| `Premi.Riserva` | Scorta minima (soglia di riordino) | "LISTA Riserva" = `quantita < riserva`; avviso in cassa (`CheckRiserva`) | `frmpremi.frm:5117-5121`, `4924-4953` | V |
| `Premi.QPren` | Quantità impegnata da prenotazioni/ordini clienti non ancora consegnati | `Σ |Prenotaz.Quantita|` con `cons=0`; in cassa la disponibilità è `Quantita − QPren` | `FrmPreLis.frm:660-709`; `Form1.frm:5697` | V |
| `Premi.Ordinato` | Quantità **da ordinare / ordinata in attesa** (significato misto) | Inserita a mano come proposta; diventa `Ordini.QOrd`; `+QOrd` da ordine remoto; `−arrivato` al carico da ordine; azzerata (`False`) da `ModificaPremio` a ogni carico da bolla | `frmpremi.frm:4309-4351`; `FrmCPOrd.frm:406`; `FrmCariPO.frm:998`; `ModAddNew.bas:1001` | V |
| `Premi.Conf` | Pezzi per confezione | ≥1; `Ordinato` deve esserne multiplo; 0 blocca la creazione dell'ordine | `frmpremi.frm:4349-4366`, `4847-4859` | V |
| `Premi.Riord` | Articolo riordinabile | 1 = entra negli ordini d'acquisto; default 1 | `frmpremi.frm:4328-4342` | V |
| `Premi.Gru` | Tipo articolo | 0 = "T" premio redemption a ticket; 1 = "C" premio per gru o consumabile; la cassa mostra solo `gru=0` | `frmpremi.frm:3305-3313`, `5167-5182`; `Form1.frm:5697` | V |
| `Premi.Attivo` | Articolo attivo | Default 1; `Setup.NoInatt` nasconde gli inattivi; il carico da file riattiva | `frmpremi.frm:5097-5101` | V |
| `Premi.Prenotabile` | Articolo prenotabile | Default 1; colonna nascosta se prenotazioni e app disabilitate; nessun altro uso trovato nella zona | `frmpremi.frm:3160-3163` | V |
| `Premi.Locked` | Blocco applicativo durante la modifica della quantità | 0 = libero; altrimenti `IdPost` della postazione (in `Frm4Usr` `IdPost+1+indice` utente) | `Module6.bas:1446-1480`; `FrmPreCon.frm:723-741` | V |
| `Premi.QDis1..8` / `PDis1..8` | Quantità e posizione dell'articolo nel distributore automatico (Prize HUB) n. 1–8 | `PDisN` = slot (es. `X1`, `A3`), `QDisN` = pezzi caricati; superati da `PrizeHubSlots`; `PrizeHub_MoveToSlot` usa `PDis1/QDis1` sugli articoli virtuali `<slot>_<tipo>_PH<hub>` | `FrmRappDis.frm:542`; `ModAddNew.bas:968-969` (commentato); `PrizeHub_MoveToSlot.sql` | V |
| `Premi.Foto` / `Icona` | Immagine jpg e miniatura | Generate da file; in carico da file anche da cartella foto | `frmpremi.frm:5198-5248` | V |
| `Premi.NImp` | Numero impianto | `valsets.Nimp` | `ModAddNew.bas:153` | V |
| `Premi.N0` | Letto dalla cassa nella lista premi, uso non individuato | ? | `Form1.frm:5697` | D |
| `Premi.F0,T0,D0,F1,T1,N1,D1` | Non usati nella zona | — | ricerca nel sorgente | V |

### MovMag (carichi) e MovOut (scarichi)

| Colonna | Significato | Valori / codifiche | Evidenza | |
|---------|-------------|--------------------|----------|---|
| `MovMag.Codice`, `MovOut.Codice` | Codice articolo al momento del movimento | Non aggiornato se l'articolo viene ricodificato o cancellato | `ModAddNew.bas:204-268` | V |
| `.CodOr, .Descrizione, .Costo, .N_Tickets` | Fotografia dell'anagrafica al momento del movimento | Costo × Quantita = valore del movimento nei report | `FrmLismovN.frm:4589-4615` | V |
| `.Quantita` | Pezzi, **sempre positivi**; il verso è dato dalla tabella | — | — | V |
| `.Data` | Data del movimento | Data scelta + ora corrente; mai anteriore all'ultimo inventario (`UltimoInv`) | `FrmMovmag.frm:2496`; `FrmKit.frm:1318` | V |
| `.Oper` | Operatore (`Operatori.Id`) | Join in `FrmLismov` | `FrmLismovN.frm:4589` | V |
| `MovMag.Fornitore` | Fornitore della merce | Testo | — | V |
| `MovOut.Fornitore` | **Destinatario** dello scarico | `FrmKit`: file/destinazione scelti o `NomeLocale`; `FrmSiteOut`: il fornitore dell'articolo | `FrmKit.frm:1397-1401`; `FrmSiteOut.frm:1321` | V |
| `MovMag.Motivo` | Causale di carico | `CARICO`/`LOAD`/`CHARGE`; `GRU`, `CONSUMABILI`, `EVENTI`, `RUSPE` (rientro da reparto); `SPOSTA`/`TRANSFER`/`TRANSFERT` (da altro locale); `PRIZEHUB`. Il filtro elenca anche `GUASTO`, `TICKETS`. **Il valore dipende dalla lingua dell'installazione** | `FrmLismovN.frm:4178-4203`; `FrmMovmag.frm:3714-3798`; `FrmSiteIn.frm:1276-1286` | V |
| `MovOut.Motivo` | Causale di scarico | `SPOSTA`, `GUASTO`, `GRU`, `CONSUMABILI`, `EVENTI`, `RUSPE` (tradotti in EN/FR); `TRANSFER` fisso per l'uscita verso altro locale; `PRIZEHUB`; il filtro elenca anche `ROTTO`, `TICKETS` | `FrmKit.frm:1739-1746`; `FrmSiteOut.frm:1321`; `FrmLismovN.frm:4229-4254` | V |
| `.Note` | Nota libera **o locale controparte** | `SPOSTA`/`TRANSFER`: nome del locale (origine nei carichi manuali, destinazione nell'uscita); "Carico manuale", "Carico Automatico", "Carico Remoto" | `FrmLismovN.frm:4507-4521`; `FrmMovmag.frm:2610` | V |
| `.NBolla` | Numero documento | `MANU` (nuovo articolo), `AU`+12 car. del nome file (carico automatico), `CR`+ddmmyyhhmmss (carico remoto), numero bolla digitato, **numero d'ordine** nel carico da ordine, numero consegna in `FrmSiteIn`, `MANU_<slot>` (Prize HUB) | `frmpremi.frm:2534`; `FrmMovmag.frm:3370-3384`; `FrmCariPO.frm:962`; `FrmSiteIn.frm:1287` | V |
| `.NOrdine` | Secondo numero di documento (ordine o consegna) | Semantica invertita tra i flussi (vedi W06-22, W06-15) | idem | V |
| `.NImp` | Numero impianto | — | — | V |
| `.T0` | Solo `PrizeHub_MoveToSlot`: codice dell'articolo controparte | — | `PrizeHub_MoveToSlot.sql:68-74` | V |
| `.F0, .N0, .D0` | Non usati nella zona | — | — | V |

### Ordini

| Colonna | Significato | Valori / codifiche | Evidenza | |
|---------|-------------|--------------------|----------|---|
| `Ordini.NOrdine` | Numero dell'ordine d'acquisto, digitato; **testata implicita** (le righe con lo stesso numero formano l'ordine) | Unico per costruzione applicativa | `frmpremi.frm:4418-4528` | V |
| `Ordini.Codice, CodOr, Descrizione, Costo, N_Tickets, Fornitore` | Riga d'ordine con fotografia dell'anagrafica | Fornitore = testo | `ModAddNew.bas:796-826` | V |
| `Ordini.QOrd` | Quantità ordinata | "Completa" la forza a `QCons` | `FrmCariPO.frm:1116` | V |
| `Ordini.QCons` | Quantità consegnata cumulata | Ordine aperto se `QCons < QOrd` | `FrmCariPO.frm:984`, `1363` | V |
| `Ordini.Data, Oper` | Data di creazione e operatore | — | — | V |
| `Ordini.NBolla, Motivo, Note` | Valorizzati solo copiando ordini remoti | — | `FrmCPOrd.frm:408` | V |
| `Ordini.F0..D0` | Non usati | — | — | V |

### Prenotaz (prenotazioni e ordini dei clienti)

| Colonna | Significato | Valori / codifiche | Evidenza | |
|---------|-------------|--------------------|----------|---|
| `Prenotaz.Quantita` | Pezzi **con segno di stato** | `< 0` = prenotazione (premio non disponibile); `> 0` = ordine (prenotazione confermata, ordine da totem o app) | `Form1.frm:6150`; `FrmPreLis.frm:533` | V |
| `Prenotaz.IdCli` | Cliente | `IdContatto` (o `IdLong` in multilocale); 0 = senza card | `Form1.frm:6150`, `6446` | V |
| `Prenotaz.NomeC, CognomeC, Tel` | Copia dei dati del cliente | — | `ModAddNew.bas:854-890` | V |
| `Prenotaz.Codice, Descrizione, Costo, Fornitore` | Fotografia dell'articolo | — | idem | V |
| `Prenotaz.N_Tickets` | Ticket pagati **per pezzo** (dopo sconti promo/bonus) | Rimborsati all'annullamento | `Form1.frm:6111`, `6150` | V |
| `Prenotaz.IdOp` | Chi ha creato la riga | Operatore di cassa; 1009–1018 = totem/kiosk | `Form1.frm:7488`; `FrmPreCon.frm:412` | V/D |
| `Prenotaz.IdOpCo` | Operatore di consegna o annullamento; **anche stato temporaneo** | `-1` non consegnabile, `-2` consegnabile (azzerati a 0 da `Ann_Pren_Cons`); 5555 alla creazione senza card | `Form1.frm:17065-17070`, `17366`, `6446` | V |
| `Prenotaz.Data, DataConf, DataCon` | Creazione, conferma di disponibilità, consegna/annullamento | `DataCon` alla creazione è NULL | `FrmPreLis.frm:534`, `628` | V |
| `Prenotaz.Cons` | Chiusa (consegnata **o annullata**) | — | `FrmPreCon.frm:743` | V |
| `Prenotaz.Annul` | Annullata con rimborso | — | `FrmPreLis.frm:629` | V |
| `Prenotaz.Conf` | Sempre 1 alla creazione da cassa; tutte le liste filtrano `conf = 1` | La conferma usa il segno di `Quantita`, non questo campo | `Form1.frm:6150` | V |
| `Prenotaz.MsgInv` | Messaggio inviato al cliente | 1 alla creazione e all'annullamento | `ModAddNew.bas:876` | D |
| `Prenotaz.SerNum` | Numero della ricevuta, stampato come barcode `P<hex 8>R` | `(IdPost−100)·100000001 + secondi dal 01/01/2008 + centesimi` | `Form1.frm:6149` (variante senza card con base 2014: `6444`); `FrmPreCon.frm:583-584`; `FrmTotPre.frm:283` | V |
| `Prenotaz.T0` | Numero d'ordine che raggruppa più righe (ordini da totem/app) | 0 dalla cassa | `FrmPrePre.frm:393-397` | V |
| `Prenotaz.F0` | Ordine preparato (distinta stampata) | 0/1 | `FrmPrePre.frm:397` | V |
| `Prenotaz.F1` | Cliente multilocale | `isMultilocale` | `ModAddNew.bas:880` | V |
| `Prenotaz.NImp` | Numero impianto | — | — | V |

### Altre tabelle toccate

| Colonna | Significato | Valori / codifiche | Evidenza | |
|---------|-------------|--------------------|----------|---|
| `Fornitori.Nome` | Chiave e nome del fornitore | Creato in automatico (solo nome) dai carichi | `ModAddNew.bas:333-361`; `FrmMovmag.frm:2629-2636` | V |
| `Fornitori.Stato, Web_Site, Contact_Name` | Paese, sito, referente | Valorizzati solo dalla lista approvata | `FrmMovmag.frm:2801-2815` | V |
| `RiepInv.F0` | Tipo di record | 0 = riepilogo inventario; **1 = lista di carico inviata da HQ** | `Module1.bas:44-46` | V |
| `RiepInv.Mdb` | File `kitpremi.mdb` della lista (se `F0=1`) | blob | `FrmMovmag.frm:4372-4373` | V |
| `RiepInv.T0` | Nome del file della lista | — | `FrmMovmag.frm:4428` | V |
| `RiepInv.D0` | Data/ora di carico della lista in sala | NULL = pendente | `FrmMovmag.frm:4396` | V |
| `Vincite.Cons`, `Vincite.D0` | Premio consegnato e data di consegna (anche per premi prenotati) | Prenotazione: `Cons=0`; consegna: `Cons=1, D0=getdate()` | `ModAddNew.bas:46-48`; `FrmPreCon.frm:751` | V |
| `Tickets.MangiaT = 2056` | Ticket di rimborso per prenotazione annullata | — | `FrmPreLis.frm:649` | V |
| `Operatori` con `Nome='TotemPrizes'` | Distributori automatici di premi | `Id` 1001–1010, `Attivo` = abilitato | `FrmToPr.frm:238-288` | V |
| `Setup.T5` | Elenco dei locali per i trasferimenti | `nome1|nome2|…|` | `Module1.bas:69`, `2600` | V |
| `Setup.F3` | `BCodeOver`: nel carico da file il barcode prevale e il codice dell'articolo viene sovrascritto | 0/1 | `Module1.bas:51`, `2623` | V |
| `Setup.F4`, `Setup.F5` | Manager può modificare descrizione / barcode | 0/1 | `Module1.bas:52-53` | V |
| `Setup.F6` | Disabilita l'avviso di premio con quantità negativa | 0/1 | `Module1.bas:54` | V |
| `Setup.NRep2..9`, `ARep2..9` | Nomi e abilitazione dei reparti ticket 2–9 | — | `FrmReparti.frm:671-829` | V |
| `Setup.FtpPOrd`, `FtpAppL` | Ordine d'acquisto remoto / lista approvata scaricati e da importare | 0/1 | `Module1.bas:383`, `444` | V |
| `Setup.TotTick` | Usato anche come giorni di ritiro (`TotTick \ 1000`) nel messaggio di premio disponibile | — | `FrmPreLis.frm:559` | V |

---

## 4. Regole, calcoli e comportamenti notevoli

**Giacenza.** `Premi.Quantita` è un campo aggiornato direttamente, non un saldo derivato [V]. Lo modificano:

| Flusso | Effetto | Movimento registrato |
|--------|---------|----------------------|
| Nuovo articolo (W06-03) | = quantità iniziale | `MovMag` |
| Carichi: bolla, file, remoto, trasferimenti, da ordine (W06-09…11, 15, 22) | `+q` | `MovMag` |
| Scarichi e trasferimenti in uscita (W06-13, 14) | `−q`, **troncato a 0** | `MovOut` |
| Prize HUB (`PrizeHub_MoveToSlot`) | `−q` sorgente, `+q` articolo virtuale | `MovOut` + `MovMag`, in transazione |
| Consegna premi in cassa (`Form1.frm:15711`, `Frm4Usr.frm:5492`) | `−q` | **nessuno** (solo `Vincite`) |
| Consegna di prenotazioni/ordini (W06-27, 28) | `−q` | **nessuno** (solo `Vincite.Cons`) |
| Resi da cliente (`frmresauto`, `frmresman`) | `+1` | `Resi` (altra zona) |
| Modifica bolla, cancellazione bolla (W06-18, 19) | ricalcolo | modifica/cancellazione fisica del movimento |
| Modifica movimento singolo (W06-17) | **nessuno** | movimento modificato |
| Modifica in griglia con `MQPrem`, ricalcolo da inventario (W06-02, 08) | sovrascrittura | **nessuno** |

**MovMag e MovOut** hanno la stessa struttura e lo stesso significato di colonna, con due eccezioni: in `MovOut` `Fornitore` è il destinatario e i motivi sono diversi. Sono quindi la stessa entità "movimento di magazzino" con verso opposto [V], ma **non coprono tutti i movimenti**: le uscite per consegna premi stanno in `Vincite` e i rientri da cliente in `Resi`. La giacenza teorica si ricostruisce solo da cinque tabelle (giacenza di un inventario + `MovMag` − `MovOut` − `Vincite` consegnate + `Resi`), ed è quello che fa l'inventario (`FrmInventario.frm:4879-4882`) [V/D].

**Documenti.** Bolle, scarichi, trasferimenti e ordini non hanno una testata: sono righe che condividono `NBolla`/`NOrdine` (o `NOrdine` in `Ordini`), il cui significato si inverte tra flussi. L'unicità della coppia bolla/ordine è controllata solo dall'applicazione.

**Codici.** `Codice` e `CodOr` sono entrambi univoci e intercambiabili nella ricerca; il codice può cambiare in tre modi (griglia con `ModCode`, modifica bolla di carico, `BCodeOver` nel carico da file) e lo storico non viene aggiornato. È la causa più probabile degli articoli orfani misurati in DB 03 e DB 05. La cancellazione dell'articolo produce lo stesso effetto.

**Valore.** Valore del magazzino = `Σ Costo × Quantita` [V `frmpremi.frm:5126`, `frmWrapp.frm:3313`]. Nei rapporti il **ricavo** di un premio consegnato è `N_Tickets × 0,01` e il **profitto** `N_Tickets × 0,01 − Costo`, con 0,01 scritto nel codice anche se `Setup.ValTick` esiste [V `frmrapp.frm:2564-2567`, `FrmRappUs.frm:1691-1694`]. Il costo e i ticket vengono fotografati su ogni movimento, vincita e prenotazione.

**Prezzo in ticket.** `N_Tickets` è derivabile dal costo (`AutoNT`, `NTMolt`, modifica massiva) ma resta un campo libero; non c'è storico delle variazioni di prezzo.

**Inventario come chiusura.** Nessun movimento può avere data anteriore all'ultimo inventario (`UltimoInv`) e nessuna bolla anteriore può essere cancellata [V].

**Prenotazioni.** Ciclo di vita [V]: prenotazione in cassa (ticket scalati subito, `Vincite` con `Cons=0`, `QPren += q`, `Quantita` negativa) → conferma (segno positivo, `DataConf`, notifica app/email) → consegna (`Quantita −= q`, `QPren −= q`, `Vincite.Cons=1`) oppure annullamento (rimborso, cancellazione della vincita). Gli ordini da totem/app entrano già positivi e passano dalla preparazione (`F0`). La scadenza automatica degli ordini non ritirati è descritta nel manuale (`Setup` "Cancellazione automatica ordini non riscossi") ma non è in questi file.

**Scambio con l'esterno tramite file Access.** Scarichi e trasferimenti producono un `.mdb` in `Unloads`; i trasferimenti in ingresso lo leggono da `Loads`; i carichi automatici e la lista approvata leggono `.mdb` scelti dall'utente; gli ordini remoti arrivano come `porder.mdb`; le liste di HQ viaggiano come blob in `RiepInv.Mdb`. I file sono protetti da password scritte nel codice (`Module1.bas:970`, `frmpremi.frm:3388`, `FrmMovmag.frm:2325`, `3154`, `3192`, `3904`, `4163`, `FrmSiteIn.frm:972`, `FrmCPOrd.frm:372`).

**HQ.** Lo stesso `frmpremi` in modalità HQ è in sola lettura salvo `Ordinato` e la creazione di ordini d'acquisto; i menu di carico e scarico sono nascosti [V `frmpremi.frm:3110-3154`]. Le liste di carico per la sala sono prodotte da HQ in `RiepInv` (il codice di generazione non è in questa zona).

---

## 5. Problemi rilevanti per il nuovo disegno

1. **La giacenza non è derivabile dai movimenti**: una decina di percorsi la modificano, almeno quattro senza alcun movimento di magazzino, e il troncamento a 0 negli scarichi perde le differenze. Serve un registro unico dei movimenti con causale (carico, scarico, consegna, reso, rettifica, trasferimento) e la giacenza come saldo o proiezione.
2. **Identità dell'articolo instabile**: codice modificabile e cancellazione libera. Il nuovo modello richiede un identificativo tecnico immutabile, codici e barcode come attributi (anche multipli per fornitore: cfr. Analisi 00 § 6 punto 13) e la disattivazione al posto della cancellazione.
3. **Documenti senza testata** e numeri bolla/ordine con semantica invertita: servono entità documento (bolla, ordine d'acquisto con righe e consegne, trasferimento) con stato.
4. **Causali in testo localizzato**: `Motivo` vale `CARICO` o `LOAD` secondo la lingua dell'installazione; serve un'anagrafica di causali con codice stabile.
5. **Trasferimenti tra locali via file**: nessuna conferma di ricezione, locale indicato per nome libero e con origine/destinazione confuse. Nel modello multisala il trasferimento diventa un documento con due autorità (uscita della sala mittente, ingresso della ricevente) e un'eventuale differenza di consegna.
6. **Fornitore come testo** in cinque tabelle, con chiave `Fornitori.Nome` rinominabile: serve un'anagrafica con identificativo.
7. **Prenotazioni**: lo stato è codificato nel segno della quantità e in valori magici di `IdOpCo`; il rimborso multi-pezzo è errato; l'annullamento cancella la vincita cercandola per giorno. Serve un'entità ordine cliente con righe, stati espliciti e collegamento diretto al movimento di ticket del cliente (zona 3).
8. **Distributori in colonne ripetute** (`QDis/PDis` 1–8, distributori come operatori fittizi 1001–1010, totem come operatori 1009–1018): da sostituire con l'entità dispositivo/slot, già abbozzata in `PrizeHubSlots`.
9. **Nessuna transazione** nei flussi multi-tabella (carichi, annullamenti); il solo `PrizeHub_MoveToSlot` è transazionale ed è il modello da seguire.
10. **Valore ticket fisso a 0,01** nei report nonostante il parametro.

---

## 6. Domande aperte per il team

1. Chi produce oggi i file di carico automatico ("GesPremi", magazzino centrale) e `porder.mdb`, e chi imposta `Setup.FtpPOrd`? Il canale FTP è ancora attivo?
2. Il trasferimento tra locali via file `Unloads`/`Loads` è ancora usato? Con quale mezzo viaggia il file?
3. `Premi.Ordinato` deve restare "da ordinare" o "ordinato in attesa"? È voluto che un carico da bolla lo azzeri?
4. "Modifica codice premi" e `Sostituzione codice` (`BCodeOver`) sono usati in produzione? Lo storico orfano è un problema noto?
5. Gli ordini con `IdOp` 1009–1018 vengono dal totem, dall'app Galileo o da entrambi? Chi scrive le righe positive di `Prenotaz` e chi gestisce la scadenza degli ordini non riscossi?
6. `Premi.Id2`, `Premi.N0` e `Premi.Prenotabile` hanno un uso al di fuori di WinMT (totem, web app, HQ)?
7. I reparti 2–9 di `Setup` (ticket) e le destinazioni di magazzino (`GRU`, `CONSUMABILI`, `EVENTI`, `RUSPE`) vanno unificati in un'unica anagrafica di "reparti"?
8. Il valore del ticket nei report deve diventare configurabile (`Setup.ValTick`) o resta 0,01 per contratto?
9. `PDis/QDis` sono ancora valorizzati in qualche sala, o il Prize HUB li ha del tutto sostituiti?
