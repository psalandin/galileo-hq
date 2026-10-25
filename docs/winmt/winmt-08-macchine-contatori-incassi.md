# Galileo HQ — WinMT 08: Macchine, contatori e incassi

**Stato:** bozza · **Responsabile:** Piero · **Aggiornato:** 2026-10-23

**Fonte:** sorgente VB6 di WinMT (copia del 24/07/2026), file: `FrmCont.frm`, `frmConfMacc.frm`, `FrmEcs.frm`, `frmConfMaccER.frm`, `FrmModCont.frm`, `FormModificaPrezzi.frm`, `FormWizardMacchina.frm`, `FrmConf.frm`, `FormRaggruppaMacchine.frm`, `FrmVarInc.frm`, `frmIncAmm.frm`, `FrmInc.frm`, `FrmGrMac.frm`, `FrmGamesValues.frm`, `FrmRicalc.frm`, `FrmScegliInc.frm`, `FrmDisinstM.frm`, `FrmDatiEcs.frm`; letti in parte `Form1.frm` (menu), `EscNews.bas`, `ModAddNew.bas` (`AddIncas`), `Module6.bas` (`CarInc`, `CaricaVarInc`, `SalvaValGett`); codice SQL in `sql/codice-db/test/applicativo/` (`sp_incasso`, `sp_cambiagettoni`, `fn_calcola_impulsi_periodo`, `fn_RicalcolaContatori*`, `fn_EcsDatiGiornalieri`, `fn_dati_grafico_giornaliero`, `fn_valore_contatore` e simili, `fn_verifica_incremento_contatore`, viste `vs_macchine`, `vs_ingressi_contatori`, `vs_contatori_per_macchina`, `vs_eclmacchine`, trigger `inseriscesuECS`, procedura `scriviTicketsAutomatici`) · **Collegati:** `winmt-00-mappa.md`, `winmt-09-report.md`, `docs/db/db-01-schema.md` (§ 4), `docs/db/db-02-catalogo.md`, `docs/db/db-03-risultati-01.md` (§ 5, § 6), `docs/db/db-05-produzione-01.md`, `docs/db/db-07-confronto-test-produzione.md` (§ 6, `inseriscesuECS`, `fn_dati_grafico_giornaliero`)

Legenda: **[V]** verificato nel codice (`file:riga`); **[D]** dedotto, da confermare. I numeri di riga si riferiscono al file `.frm` completo (designer compreso).

---

## 1. Perimetro

| File | Righe di codice | Ruolo | Lettura |
|------|----------------:|-------|---------|
| `FrmCont.frm` | 3662 | **"Conteggio Macchine"**: calcolo dell'incasso del periodo dall'ultimo incasso, correzioni manuali, ripartizione esercente/gestore, voci aggiuntive, salvataggio come file Access dentro `Incassi.Mdb`, avanzamento delle letture dei contatori | A fondo `AggDatiNew`, `cmdSalva`, `cmdSave`, correzioni, `CopiaRigaDB`, `AggTots`, `SalvaCnt`, `SalvaIncasso`. `AggDati` (versione vecchia, non più chiamata), stampa ed esportazione solo scorse |
| `frmConfMacc.frm` | 2807 | **Anagrafica e configurazione macchina** in modalità ECL (scheda BE in rete): nuova, modifica, duplica, elimina, provisioning del modulo, comandi al servizio di sala | A fondo |
| `FrmEcs.frm` | 2690 | **"Rapporto Macchine"**: incassi, pagamenti, partite e indici per macchina in un periodo; diagnostica della configurazione; disinstallazione; svuotamento cassa | A fondo `AggDati` (prima metà), azioni col tasto destro, `cmdAzzCassa`. Grafici, stampa ed esportazione scorsi |
| `frmConfMaccER.frm` | 858 | Variante di `frmConfMacc` per la modalità **ECLReader** (contatori meccanici, senza programmazione della scheda). Differenze nel § 2, W08-08 | Confrontata con `frmConfMacc` |
| `FrmModCont.frm` | 749 | **"Modifica Contatori"**: rettifica manuale delle letture dei contascatti meccanici e della giacenza dell'hopper | A fondo |
| `FormModificaPrezzi.frm` | 636 | **"Modifica Costi Partita"**: costo della partita per livello card, rigenerazione delle immagini e invio alle schede | A fondo |
| `FormWizardMacchina.frm` | 573 | **Procedura guidata** di creazione macchina da modello del catalogo cloud, con configurazioni predefinite per categoria | A fondo |
| `FrmConf.frm` | 459 | **Catalogo modelli** (`Machines`, `Manuf`, `Type`) e **anagrafica proprietari** (`Owners`) | A fondo |
| `FormRaggruppaMacchine.frm` | 361 | **"Raggruppamenti"**: assegnazione di macchine a gruppi (`EcsMacchine.Keys`) per trascinamento | A fondo |
| `FrmVarInc.frm` | 305 | Definizione delle **voci aggiuntive dell'incasso** ("variabili incasso"), salvate in `Setup.T14/T15` | A fondo |
| `frmIncAmm.frm` | 268 | **"Incasso Amministrativo"**: incassi giornalieri per mese con query definita nel cloud, saldo residuo nelle card | A fondo |
| `FrmInc.frm` | 199 | **"Registrazione Incassi"**: inserimento manuale dell'incasso giornaliero per categoria (dal menu Magazzino premi) | A fondo |
| `FrmGrMac.frm` | 161 | Grafico gettoni per macchina. **Codice morto**: usa `FrmRM` e la tabella `datiecs`, che non esistono più | Scorso |
| `FrmGamesValues.frm` | 158 | Vecchia "Modifica Costo Partita". **Non raggiungibile**: la chiamata è commentata (`Form1.frm:9806`) | Letto |
| `FrmRicalc.frm` | 141 | **Ricalcolo punti dei clienti** sommando i ticket in tutti i locali collegati (multi-sala). Fuori tema rispetto alla zona | A fondo |
| `FrmScegliInc.frm` | 54 | Scelta di un incasso precedente da visualizzare | Per intero |
| `FrmDisinstM.frm` | 30 | Vecchia finestra di disinstallazione. **Non raggiungibile**: nessuna form la apre | Per intero |
| `FrmDatiEcs.frm` | 21 | Vecchia finestra dati/errori del modulo ECS. **Non raggiungibile**: la chiamata è commentata (`FrmEcs.frm:5693`) | Per intero |

**Menu.** Tutte le funzioni stanno sotto il menu *ECL* di `Form1` (`Form1.frm:4960-5040`): *Incasso Amministrativo*, *Modifica Contatori*, *Macchine in Rete* → *Configura Macchina Nuova* / *Modifica Macchina Esistente* / *Modifica Costi Partita* / *Raggruppamenti*, *Rapporti* → *Conteggio Macchine* / *Rapporto Macchine*, *Nuovo Modello*. La registrazione manuale degli incassi è invece nel menu del magazzino premi (`frmpremi.frm:3634`, `3839`), le voci aggiuntive nelle impostazioni generali (`frmsetGen.frm:4554`). **[V]**

**Due modalità di sala.** `Setup.CodEcs` decide quale form di configurazione si apre: `"ECL"` → `frmConfMacc`, `"ECLReader"` → `frmConfMaccER` (`Form1.frm:9579-9620`, `9631-9666`). **[V]**

---

## 2. Flussi

### W08-01 — Catalogo dei modelli di macchina

- **Attore e innesco:** amministratore; menu *ECL → Nuovo Modello* (`Form1.frm:9766-9775`), oppure dal wizard (`FormWizardMacchina.frm:296-301`). **[V]**
- **Passi:**
  1. Apre il catalogo `Machines` + `Manuf` + `Type` **sul database cloud** (`CSCloud`); se il cloud non risponde avvisa e ripiega sul database di sala. **[V]** `FrmConf.frm:1630-1641`
  2. *Nuova*: nome modello, costruttore, tipo (con colore), flag "contascatti di uscita". Se costruttore o tipo non esistono li crea (`NewManuf`, `NewTipo` con scelta del colore). **[V]** `FrmConf.frm:1518-1575`, `EscNews.bas:49-135`
  3. *Elimina*: cancella il modello (`Machines`) senza verificare se è in uso. **[V]** `FrmConf.frm:1313-1341`
  4. *Importa*: legge `machines`, `manuf`, `type` da un file Access scelto dall'utente e aggiunge le righe con `Id` non presente. **[V]** `FrmConf.frm:1379-1458`
- **Dati:** `Machines` (I, D), `Manuf` (I), `Type` (I) sul cloud o in sala.
- **Regole:** gli `Id` sono calcolati come massimo + 1 (`Type`: solo tra gli `Id < 100`). **[V]** `EscNews.bas:61-62`, `89-90`, `118-119`
- **Rete:** dipende dal cloud; offline scrive nel database di sala, che poi diverge dal catalogo centrale. **[V]**/**[D]**
- **Peso:** M — CRUD su tre tabelle con doppia destinazione cloud/sala e importazione da `.mdb`.
- **Evidenze:** `FrmConf.frm:1313-1656`; credenziale del file Access scritta nel codice in `FrmConf.frm:1403`.

### W08-02 — Anagrafica proprietari

- **Attore e innesco:** pannello "Gestione Proprietari" di `FrmConf` (`FrmProp`), aperto solo da `MnuEcsProp_Click` (`Form1.frm:9777-9783`). **Nel menu non esiste alcuna voce `MnuEcsProp`**: la funzione non è raggiungibile. **[V]**
- **Passi:** nuovo proprietario con nome, indirizzo, telefono, "% Incasso"; modifica e cancellazione. **[V]** `FrmConf.frm:1343-1358`, `1472-1516`, `EscNews.bas:2-25`
- **Dati:** `Owners` (I, U, D: `Id`, `OwnerName`, `OwnerAddress`, `OwnerPhone`, `Perc`, `NImp`).
- **Peso:** S — CRUD su una tabella, oggi inattivo.
- **Nota:** spiega perché `Owners` è vuota in test e in produzione (DB 03 § 5, DB 05). Il collegamento macchina–proprietario in `frmConfMacc` è commentato (`frmConfMacc.frm:6374-6379`, `7654-7661`). **[V]**

### W08-03 — Nuova macchina in modalità ECL

- **Attore e innesco:** amministratore; *Macchine in Rete → Configura Macchina Nuova* (`Form1.frm:9626-9657`): propone come codice modulo `MAX(Modu)+1`. Pulsante *Salva nuova macchina* (`CmdAdd`). **[V]**
- **Passi:**
  1. Sceglie il modello dal catalogo cloud (`Machines`); costruttore e tipo vengono mostrati, il flag `CntrOut` del modello abilita la sezione "contascatti di uscita". **[V]** `frmConfMacc.frm:6348-6368`, `7641-7653`
  2. Inserisce codice macchina (`CodMac`, univoco: `CheckCodMac`), codice modulo ECL, costi partita, valore degli impulsi, contatori di ingresso e uscita e loro collegamento agli ingressi fisici, parametri della scheda, percentuale "Ns Avere", date. **[V]** `frmConfMacc.frm:7425-7436`, `7749-7795`
  3. `AggiungiMacc` (o `AggiungiMaccTimer` per le macchine a tempo) crea la riga in `EcsMacchine` con `F0 = 1` ("Pending", configurazione da inviare). **[V]** `frmConfMacc.frm:8021-8158`, `8186-8256`
  4. Con `CodEcs = "ECL"` inserisce in `EcsDati` una **lettura iniziale a zero** (tutti gli `In` a 0, `NImp = 1`), che fa da base per i primi delta. Con `CodEcs = "ECLReader"` copia invece le letture correnti dei contascatti (`CopiaContatoriInEcsDati`). **[V]** `frmConfMacc.frm:8159-8172`, `9157-9189`
  5. Chiede al servizio di sala di rigenerare le pagine grafiche del dispositivo (`jRebuildSinglePageFromTemplate`, solo se servizio ≥ 2.27). **[V]** `frmConfMacc.frm:6435`, `9454-9480`
- **Dati scritti:** `EcsMacchine` (I: quasi tutte le colonne, vedi § 3), `EcsDati` (I).
- **Regole e calcoli:**
  - `device = CodClienteECL & "z" & CodImpianto & "z" & Modu`; per le macchine a tempo il suffisso è `Modu + 1000`. **[V]** `frmConfMacc.frm:8039`, `8206`
  - Macchina con card (`chkEcl`): ingresso 9 = E-coin (`TipoIn9 = 6`, `InCnt9 = 1`, `ValIn9 = valore impulso × impulsi per partita`), costi per livello in `val_*` divisi per `CentConversionFactor` (cioè in centesimi), `CntrLet10 = impulsi per partita`. Senza card: `CntrLet10 = ValPar / 0,5` (assume 0,50 € a impulso) o gettoni per partita. **[V]** `frmConfMacc.frm:8040-8055`
  - Macchina a monete: `ValIn3` = valore impulso moneta, `ValIn4` = valore impulso banconota, `ValPar` = costo partita in euro; a gettoni: `ValIn3/ValIn4` = gettoni per impulso delle due gettoniere, `ValPar` = gettoni per partita. **[V]** `frmConfMacc.frm:8056-8064`
  - Contatori: per ogni riga della griglia "contascatti di ingresso" scrive `CntrLetN` (lettura), `CntrValN` (valore scatto) e, per ciascun ingresso fisico collegato, `InCntX = N`; `TipoInX = 0` (monete) o `1` (gettoni), `6` per E-coin. Per i contatori di uscita il numero si accoda a quelli di ingresso; gli ingressi A1/A10 diventano `TipoIn = 2` (premi) o `3` (ticket). **[V]** `frmConfMacc.frm:8081-8137`
  - Uscite premio A3–A5 (ingressi 6–8): `ValInX` = valore, `TipoInX` = 2 premi, 3 ticket, 4 monete, 5 gettoni. **[V]** `frmConfMacc.frm:8075-8080`
  - Parametri scheda in colonne di contatore riusate: vedi § 3 (`CntrLet8…15`, `CntrVal10…16`). **[V]** `frmConfMacc.frm:8065-8074`, `8153-8156`
  - Macchina a tempo: `is_timeplay = 1`, `ValPar = 1`, `val_*` = costo per unità di tempo per livello, `CntrLet11` = unità di tempo (s), `CntrLet12` = tempo gratuito (s), `CntrLet13` = tempo minimo (in unità; 0 = tempo fisso). **[V]** `frmConfMacc.frm:8207-8250`
  - `Propr` e `PerDiv` ricevono **lo stesso valore**: la percentuale scelta da 0 a 100 (default 100). **[V]** `frmConfMacc.frm:7662-7665`, `8140-8145`
- **Anomalie:**
  - In `AggiungiMacc` il valore dello scatto per l'ingresso A2 finisce in `CntrValX` invece che in `ValInX`, come dice il commento; `AggiornaMacc` lo scrive correttamente in `ValIn`. **[V]** `frmConfMacc.frm:8091-8094` contro `7861-7863`
  - In modalità ECLReader un `UPDATE EcsMacchine SET RapCnt1=6 … RapCnt15=6` **senza `WHERE`** modifica tutte le macchine. **[V]** `frmConfMacc.frm:8170`, `8268`
  - `CopiaContatoriInEcsDati` scrive `ValS(8)` sia in `In9` sia in `In10`: da `In10` in poi i valori sono sfasati di una posizione. **[V]** `frmConfMacc.frm:9179`, `9184`, uguale in `frmConfMaccER.frm:2518`, `2523`
  - Il database è scritto con nome fisso `[WinMtSqlDB]` in sala e `[<nomedb>]` in HQ. **[V]** `frmConfMacc.frm:8160-8167`
- **Periferiche:** nessuna diretta; HTTP verso il servizio di sala (`SqlServ:58889/eclcommand`).
- **Peso:** L — una riga da 129 colonne con molte varianti (monete, gettoni, card, tempo, uscite), colonne riusate e lettura iniziale in `EcsDati`.
- **Evidenze:** `frmConfMacc.frm:6415-6448`, `7749-7795`, `8021-8282`.

### W08-04 — Nuova macchina con procedura guidata

- **Attore e innesco:** pulsante *Wizard* in `frmConfMacc` (`frmConfMacc.frm:7394-7409`). **[V]**
- **Passi:** (1) ricerca del modello **solo nel catalogo cloud**, senza ripiego locale; (2) codice macchina con verifica di unicità; (3) categoria *Redemption / Crane / Videogame / Pusher* e impulsi per partita (default 2, 2, 1, 1); (4) riepilogo e inserimento **in transazione** di `EcsMacchine` + lettura zero in `EcsDati`. **[V]** `FormWizardMacchina.frm:583-664`, `728-793`, `811-827`, `896-978`
- **Dati:** `Machines`, `Type` (S, cloud); `EcsMacchine` (I), `EcsDati` (I).
- **Regole:** un modello di riga per categoria (§ 4.2): `Modu = MAX(Modu)+1`, `F0 = 1`, `device_status = 'Offline'`, `IngressoCrediti/Gettoni/Tickets = 'In3'/'In1'/'In2'`, `CntrLet11…14 = 120/500/70/400`. Redemption, videogame e pusher nascono con `Propr = '100'`, `PerDiv = 100`, `val_* = 100`; crane con `Propr = '0'`, `PerDiv = 0`, `val_* = 0`. **[V]** `FormWizardMacchina.frm:1021-1076`
- **Rete:** senza cloud non si può cercare il modello. **[V]** `FormWizardMacchina.frm:597-600`
- **Peso:** M — inserimento transazionale con configurazioni predefinite per categoria.
- **Evidenze:** `FormWizardMacchina.frm:426-454`, `896-1076`.

### W08-05 — Modifica della configurazione e invio alla scheda

- **Attore e innesco:** amministratore; *Modifica Macchina Esistente* (`Form1.frm:9574-9624`) → selezione in griglia → *Modifica* → *Salva*. **[V]**
- **Passi:**
  1. `CmdMod` ricarica i campi dalla riga, decodificando le colonne riusate (bitmap dell'erogatore, durate, relè, politica ticket, costi per livello). **[V]** `frmConfMacc.frm:6638-6894`
  2. `cmdSave` chiede conferma e chiama `AggiornaMacc` (o `AggiornaMaccTimer`): **azzera le colonne da `ValIn1` a `RapCnt16`** (ordinali 5–100) e le riscrive dalla maschera, poi `F0 = 1`. **[V]** `frmConfMacc.frm:7054-7082`, `7797-7935`
  3. Invia al servizio `jSetupDevice` per `CodMac`; esce. Il codice successivo (procedura vecchia: setup, attesa del MAC, `jsetFromWinmt`, rimessa online) è irraggiungibile dopo `Exit Sub`. **[V]** `frmConfMacc.frm:7085-7109`, `7113-7314`
- **Dati:** `EcsMacchine` (S, U), `EcsModuli` (S: MAC del modulo, join `EcsModuli.N0 = EcsMacchine.Modu`). **[V]** `frmConfMacc.frm:7667`
- **Regole:** le letture `CntrLetN` vengono **riscritte con quanto mostrato in griglia**: una modifica di configurazione può quindi cambiare la base dell'incasso successivo (W08-15). **[V]**/**[D]**
- **Rete:** la configurazione resta in `EcsMacchine` con `F0 = 1` ("Pending" in griglia) finché il servizio non la applica. **[V]**/**[D]**
- **Peso:** L — decodifica e ricodifica di decine di parametri, riscrittura completa della riga, comando al dispositivo.
- **Evidenze:** `frmConfMacc.frm:6638-6894`, `7054-7110`, `7797-8019`.

### W08-06 — Duplicazione di una macchina

- **Attore e innesco:** doppio clic sulla griglia macchine, risposta *Sì* a "Vuoi duplicare la macchina". **[V]** `frmConfMacc.frm:8325-8340`
- **Passi:** `INSERT … SELECT` che copia tutte le colonne con nuovo `CodMac`, `Modu = MAX(Modu)+1`, `device` ricostruito dal `device` massimo, `DataInst = oggi`, `device_status` e `lastseen` a NULL; lettura zero in `EcsDati`; apre subito la modifica. **[V]** `frmConfMacc.frm:8409-8475`
- **Regole:** copia anche `Keys` (gruppo), le letture `CntrLet` e `F0`. **[V]**
- **Peso:** M — inserimento derivato con calcolo di identificativi.

### W08-07 — Provisioning del modulo e comandi al dispositivo

- **Attore e innesco:** amministratore in `frmConfMacc`. **[V]**
- **Comandi verso il servizio di sala** (HTTP `GET` su `SqlServ:58889/eclcommand`, parametro `command`): **[V]**

| Comando | Effetto dichiarato | Evidenza |
|---------|--------------------|----------|
| `jProvisionable` | Elenca i MAC dei moduli non assegnati | `frmConfMacc.frm:7014-7048` |
| `jAdopt` (CodMac, macaddress) | Assegna il modulo alla macchina | `frmConfMacc.frm:7317-7380` |
| `jonline` | Mette online un dispositivo in setup | `frmConfMacc.frm:6932-6976`, `8343-8361` |
| `jrebootAll` | Riavvia tutti i moduli accesi | `frmConfMacc.frm:6978-7012` |
| `jOutOfService` / `jInService` | Fuori servizio / in servizio (servizio ≥ 2.27) | `frmConfMacc.frm:8363-8402` |
| `jSetupDevice` | Applica la configurazione salvata | `frmConfMacc.frm:7090` |
| `jgetForWinmt` | Configurazione da scrivere su **card di programmazione** | `frmConfMacc.frm:6450-6551` |
| `jRebuildSinglePageFromTemplate` | Rigenera le pagine grafiche del dispositivo | `frmConfMacc.frm:9454-9480` |

- **Dati:** `EcsMacchine.device_status`, `F0` (S); `EcsModuli` è scritta dal servizio, non da WinMT (le funzioni `NewModu`/`NewEcsMacc` di `EscNews.bas` non sono chiamate). **[V]**/**[D]**
- **Periferiche:** lettore card della cassa per la card di programmazione (`Form1.TagR`, flag `Form1.PGMCard`). **[V]** `frmConfMacc.frm:6453-6541`, `Form1.frm:10790-10823`
- **Rete:** senza servizio di sala nessun comando funziona; il cloud non è coinvolto. **[V]**
- **Peso:** M — sequenze con il servizio e la card, nessuna logica dati complessa.

### W08-08 — Configurazione in modalità ECLReader (`frmConfMaccER`)

`frmConfMaccER` è una versione ridotta di `frmConfMacc` per le sale con `CodEcs = "ECLReader"`, dove le macchine non hanno una scheda BE programmabile e i dati vengono dai contascatti meccanici. Le differenze: **[V]** salvo dove indicato.

| Aspetto | `frmConfMacc` (ECL) | `frmConfMaccER` (ECLReader) |
|---------|---------------------|-----------------------------|
| Programmazione dispositivo, MAC, comandi HTTP, card di programmazione | Sì | **No** |
| Costi per livello card (`val_*`), E-coin (`ValIn9/TipoIn9`), macchine a tempo, relè, politica ticket | Sì | **No** |
| `Modu`, `device`, `F0` | Scritti | **Non scritti** |
| Collegamento ingressi ↔ contatori | Ingressi fisici scelti (A2, B14, A15, A1, A10, A3–A5) | **1:1**: il contatore N usa l'ingresso N (`InCntN = N`) |
| `ValInN` | Valore dell'impulso dell'ingresso | **Uguale a `CntrValN`** (valore dello scatto) |
| `TipoInN` | Dedotto da monete/gettoni/ticket | Scelto per contatore: ingresso Monete 0 / Gettoni 1; uscita Premi 2 / Tickets 3 / Monete 4 / Gettoni 5 |
| `RapCntN` | Non scritto (solo ECLReader in `AggiungiMacc`) | **6** per ogni contatore configurato |
| `RapCnt16` | — | **Gettoni per partita** (1–10) |
| `CntrLet10` | Impulsi per partita | **Uguale a `ValPar`** (costo partita) |
| Modifica | Azzera e riscrive le colonne 5–100 | Sovrascrive solo i contatori configurati |
| Lettura iniziale in `EcsDati` | Zero (ECL) | Letture correnti dei contatori (`CopiaContatoriInEcsDati`) |
| Eliminazione macchina e dati, multipostazione, `Propr`/`PerDiv`, hopper, catalogo cloud | Identici | Identici |

- **Anomalia:** nella versione inglese `Nometipo2Tipo` assegna a una variabile sbagliata (`Tipo2Nometipo`) e restituisce sempre 0 per i contatori di ingresso. **[V]** `frmConfMaccER.frm:2580-2586`
- **Peso:** M — stessa anagrafica con un modello di contatori più semplice.
- **Evidenze:** `frmConfMaccER.frm:1756-1759`, `1890-1945`, `2165-2305`, `2460-2614`.

### W08-09 — Macchine multipostazione e raggruppamenti

- **Attore e innesco:** (a) flag "Macchina Multipostazione" in `frmConfMacc`/`frmConfMaccER`; (b) *Macchine in Rete → Raggruppamenti* o dal Rapporto Macchine (`FormRaggruppaMacchine`). **[V]**
- **Passi:**
  - (a) `SettaMMPost`: assegna a **tutte le macchine con lo stesso `NomMac`** e senza gruppo il valore `Keys = MAX(Keys)+1`; togliendo il flag, `ResettaMMPost` rimette `Keys = 0` a tutto il gruppo. **[V]** `frmConfMacc.frm:9211-9240`
  - (b) Trascinamento di una macchina dall'elenco al riquadro del gruppo: `Keys` = gruppo selezionato o nuovo `MAX(Keys)+1`; trascinamento inverso: `Keys = NULL`. **[V]** `FormRaggruppaMacchine.frm:547-568`, `697-734`, `764-785`
- **Uso:** il Rapporto Macchine con "Raggruppa" somma le macchine con lo stesso `Keys` e mostra `<codice>[n]`. **[V]** `FrmEcs.frm:3295-3359`
- **Dati:** `EcsMacchine.Keys` (U).
- **Peso:** M — semplice, ma `Keys` ha due semantiche (multipostazione per nome e gruppo libero) e i valori "nessun gruppo" sono tre (NULL, 0, < 1).

### W08-10 — Eliminazione della macchina e cancellazione dei dati

- **Attore e innesco:** pulsante *Elimina macchina* (`cmdDelMacc`, visibile in modifica) e *Cancella i dati della macchina* (`cmdDelData`, nascosto nel designer e rimesso nascosto a fine `CmdMod`). **[V]** `Form1.frm:9595`, `frmConfMacc.frm:6877`, `6893`
- **Passi e dati:**
  - `cmdDelMacc`: `DELETE FROM EcsDati`, **`DELETE FROM TransCard`** e `DELETE FROM EcsMacchine` per il `CodMac`. **[V]** `frmConfMacc.frm:6587-6612`
  - `cmdDelData`: `DELETE` da `EcsDati` e `TransCard`, poi una lettura zero in `EcsDati`: è di fatto l'**azzeramento dei contatori** della macchina. **[V]** `frmConfMacc.frm:6553-6585`
  - Uguali in `frmConfMaccER.frm:1813-1872`. **[V]**
- **Regole:** nessun controllo su incassi aperti o su altre tabelle; nessun log applicativo. **[V]**
- **Conseguenze:** si perdono i movimenti card fatti su quella macchina (`TransCard` con `WinMt = 0`), cioè i consumi di credito dei clienti, e lo storico dei contatori. È la causa più probabile degli "orfani" e delle macchine scomparse osservati in DB 03 § 5 e DB 04. **[D]**
- **Peso:** S — tre `DELETE`, ma con impatto economico e sullo storico.

### W08-11 — Disinstallazione della macchina

- **Attore e innesco:** data di disinstallazione nella maschera di configurazione, oppure tasto destro sulla colonna "ultima visita" del Rapporto Macchine (propone la data di `lastseen`). **[V]** `frmConfMacc.frm:7898`, `FrmEcs.frm:2922-2952`, `2957-2987`
- **Dati:** `EcsMacchine.DataDis` (U). **[V]**
- **Effetti:** la macchina esce da conteggio incassi (`DataDis is null or DataDis > data calcolo`), modifica contatori (`datadis is null`), rapporti (periodo di attività) e modifica prezzi. Storico e anagrafica restano. **[V]** `sp_incasso.sql:22`, `361`; `FrmModCont.frm:2685`; `FrmEcs.frm:3207`; `FormModificaPrezzi.frm:660`
- **Nota:** `FrmDisinstM` (vecchia finestra dedicata) non è più aperta da nessuna form. **[V]**
- **Peso:** S — un campo data.

### W08-12 — Modifica dei costi partita per livello card

- **Attore e innesco:** *Macchine in Rete → Modifica Costi Partita* (`Form1.frm:9802-9813`). **[V]**
- **Passi:**
  1. Elenca le macchine installate collegate a un modulo (`INNER JOIN EcsModuli ON N0 = Modu`), con stato (`On`/`Of`), MAC e i quattro costi `val_silver`, `val_platinum`, `val_gold`, `val_normal` (etichetta "Birthday"); filtro per tipo. **[V]** `FormModificaPrezzi.frm:650-744`
  2. L'operatore modifica le celle (anche incollando blocchi da Excel); ogni macchina toccata entra nella lista "Editing". **[V]** `FormModificaPrezzi.frm:1206-1215`, `1304-1339`
  3. *[1] Build Images*: scrive i nuovi costi in `EcsMacchine` e chiede al servizio `jRebuildListOfPagesFromTemplate`, passando l'indirizzo di un socket TCP locale (porta 59095) su cui il servizio notifica l'avanzamento (`job_started`, `conversion_finished`, `job_completed`). **[V]** `FormModificaPrezzi.frm:1077-1091`, `597-620`, `873-893`
  4. *[2] Update BE*: per le macchine online invia `jUpdateCreditiRichiestiPerTipoCard`; per quelle offline imposta `F0 = 1` (da inviare). Interroga lo stato con `jGetDevicesUpdateStatus`. **[V]** `FormModificaPrezzi.frm:974-1003`, `1381-1397`
- **Dati:** `EcsMacchine.val_*` (U), `EcsMacchine.F0` (U); `EcsModuli`, `Type` (S).
- **Regole:** i valori sono interi nella stessa unità dei crediti (centesimi): la griglia accetta "####" senza conversione. **[V]** `FormModificaPrezzi.frm:685-692`, `955-965`
- **Periferiche e rete:** servizio di sala via HTTP e socket TCP in ascolto; senza servizio la modifica resta in DB. **[V]**
- **Peso:** L — flusso asincrono a passi con notifiche via socket e due percorsi online/offline.
- **Nota:** la vecchia `FrmGamesValues` faceva lo stesso aggiornamento moltiplicando per 100 e, all'apertura, **cancellava e ricopiava la tabella `Type` di sala dal cloud** (`FrmGamesValues.frm:1533-1539`). Non è più raggiungibile. **[V]**

### W08-13 — Rettifica manuale delle letture dei contatori

- **Attore e innesco:** *ECL → Modifica Contatori* (`Form1.frm:9891-9897`). Avviso a video: "La modifica dei contatori va effettuata solamente dopo aver fatto l'incasso e senza partite in corso". **[V]** `FrmModCont.frm:2336`
- **Passi:**
  1. Costruisce una tabella in memoria con una riga per contatore configurato (`CntrValN > 0`) di ogni macchina non disinstallata: tipo macchina (dal catalogo cloud), numero, tipo (dal `TipoIn` dell'ingresso collegato), lettura teorica = lettura reale = `CntrLetN`, giacenza hopper (`PzPiatto`). **[V]** `FrmModCont.frm:2934-3025`
  2. L'operatore digita la lettura reale; la differenza si colora (rosso se il contatore fisico è avanti). **[V]** `FrmModCont.frm:2720-2745`
  3. *Salva*: per ogni riga con differenza scrive `CntrLetN = lettura reale`; se la giacenza cambia la scrive in **`EcsMacchine.N0`**. **[V]** `FrmModCont.frm:2520-2575`, `2898-2932`
  4. *Stampa*: "Differenza Contatori al …". **[V]** `FrmModCont.frm:2505-2518`
- **Dati:** `EcsMacchine.CntrLet1…16`, `EcsMacchine.N0` (U); `Machines`, `Type`, `Manuf` (S, cloud).
- **Regole:** non scrive `EcsDati`: allinea solo la "lettura precedente" che il conteggio successivo userà come base (W08-15). **[V]**
- **Anomalie:** la giacenza viene letta da `PzPiatto` e salvata in `N0` (residuo della versione precedente, `CaricArr`, che usava `T0/N0`): la rettifica della giacenza non ha effetto visibile. **[V]** `FrmModCont.frm:2999-3003` contro `2914-2932`. Due pulsanti nascosti (`cmdAddData`, `Command`) contengono interventi di manutenzione con date fisse del 2020. **[V]** `FrmModCont.frm:2474-2499`, `2607-2631`
- **Periferiche:** in origine inviava le letture a uno "schedino EcsNetWiFly" via TCP porta 2000 (`SendCounters`, `InviaContatori`): oggi non è più chiamato. **[V]** `FrmModCont.frm:2577-2605`, `3139-3192`
- **Peso:** M — rettifica su più contatori con impatto sull'incasso.

### W08-14 — Registrazione automatica delle letture (lato database)

Non è codice VB6, ma è il flusso che alimenta tutto il resto della zona.

- **Attore e innesco:** la scheda BE invia un messaggio; `decodifica_flusso` lo decodifica in `CoinlessDecodedData`; il trigger `inseriscesuECS` scatta sui record con `cmd_inviato = 7` (contatori). **[V]** `inseriscesuECS.sql:1-34`; DB 03 § 3
- **Passi:** inserisce in `EcsDati` una riga con `In1 = gettoni`, `In2 = tickets`, `In3…In8 = cnt3…cnt8`, `In9 = partite`, `NImp = 1`, `In16 = 0`, `In15 = MAX(In15)` esistente; se la macchina ha ticket automatici (`CntrLet15 ≠ 0`) `In5 = cnt5 + MAX(In15)`. **[V]** `inseriscesuECS.sql:13-31`
- **Ticket automatici:** `scriviTicketsAutomatici`, a ogni partita con card, accredita `CntrLet15` ticket al cliente (`Tickets`, `Clienti.Tickets`) e inserisce in `EcsDati` una copia dell'ultima lettura con `In5` e `In15` aumentati di `CntrLet15` e `In9 + 1`. Durante una promozione, con `setup2.flagDropTicketsForGold`, le card in `promozioni_cards` non ricevono ticket automatici se il costo gold è 0. **[V]** `scriviTicketsAutomatici.sql:12-84`
- **Dati:** `EcsDati` (I), `Tickets` (I), `Clienti` (U).
- **Rete:** tutto nel database di sala. **[V]**
- **Peso:** M — logica in trigger con dipendenza dalla configurazione della macchina.

### W08-15 — Conteggio macchine e incasso (`FrmCont`)

- **Attore e innesco:** operatore; *ECL → Rapporti → Conteggio Macchine* (`Form1.frm:9758-9764`); pulsante *Calcola Incasso*. Il salvataggio richiede la password di un operatore di livello 0 (o 1 se `Setup.InvPass`) o la password di supervisore. **[V]** `FrmCont.frm:8226-8229`, `8621-8655`
- **Passi:**
  1. All'apertura imposta un flag di "conteggio in corso" in `Setup.F1` della prima postazione (`top 1 … order by idpost`) e lo toglie alla chiusura. **[V]** `FrmCont.frm:9542`, `9757`, `10782-10800`
  2. `FineInc = Now`: tutto ciò che arriva dopo appartiene all'incasso successivo. Se esiste un incasso precedente (`Incassi.F0 = 1`, il più recente) ne estrae il file Access in `PrecInc.mdb`. **[V]** `FrmCont.frm:7599-7619`, `10713-10730`
  3. Svuota le tabelle `incas` e `riepilogo` del file di lavoro `incas.mdb` (nella cartella Documenti dell'utente). **[V]** `FrmCont.frm:7620-7644`, `9549-9554`
  4. Chiama `sp_incasso(FineInc, lingua, ValGett, ValTick)` per le macchine con `Tipo` da 2 a 99 e `sp_cambiagettoni` per quelle di `Tipo = 1` (cambiagettoni); copia ogni riga, una per contatore, in `incas`, calcolando percentuale di pagamento, partite, ticket per partita e "Ns Avere". **[V]** `FrmCont.frm:7645-7728`, `11256-11387`
  5. Mostra la griglia per macchina e contatore e i totali per categoria (Redemption, Gru, Videogiochi). **[V]** `FrmCont.frm:10321-10410`
  6. **Correzioni manuali** sulla singola macchina: lettura reale del contatore diversa dalla teorica; totale contato in cassa diverso dal teorico, con la scelta di "assorbire la differenza nella giacenza" dell'hopper; giorni di guasto; data di ritiro. Le correzioni ricalcolano incasso, partite e percentuali e bloccano il totale (`LockTot`). **[V]** `FrmCont.frm:9814-9916`, `10056-10116`, `9761-9783`, `9510-9539`
  7. *Imposta valore gettone*: sostituisce `Setup.ValGett` con il valore medio dei cambiagettoni (monete inserite / gettoni erogati) e ricalcola. **[V]** `FrmCont.frm:9101-9110`, `Module6.bas:1411-1425`
  8. *Visualizza e Salva Incasso* (`cmdSave`): totali per tipologia (incasso monete, E-coin, totale, pagamento, parte esercente, parte gestore) e **voci aggiuntive** (W08-17), scritti nelle tabelle `Riep_Tipi` e `Variabili` dell'`.mdb`. **[V]** `FrmCont.frm:8844-9030`
  9. *Salva* (`cmdSalva`): password; compila `Lista`, `Change` e `Riepilogo` nell'`.mdb`; per ogni macchina **avanza le letture** (`EcsMacchine.CntrLetN = lettura reale`); salva l'intero file `incas.mdb` in una nuova riga di `Incassi` (`Data = FineInc`, `F0 = 1`, `Mdb`). **[V]** `FrmCont.frm:8662-8842`, `10732-10780`
- **Calcolo dell'incasso** (`sp_incasso`, una riga per coppia ingresso–contatore): **[V]** `sp_incasso.sql:29`, `91-339`, `fn_calcola_impulsi_periodo.sql`
  - **delta impulsi** per ingresso = ultima riga di `EcsDati` successiva all'ultimo incasso − ultima riga non successiva (se manca, la prima in assoluto); l'ultimo incasso è `MAX(Incassi.Data)` **senza filtro su `F0`**;
  - `Scatti = delta × ValIn / CntrVal`; `LetturaAttuale = CntrLet + Σ scatti` degli ingressi collegati allo stesso contatore; `LetturaPrecedente = CntrLet`;
  - per tipo d'ingresso: `TipoIn 0` → monete in euro = `delta × ValIn`; `1` → gettoni = `delta × ValIn` (in euro × `ValGett`); `2` → premi in euro = `delta × ValIn`; `3` → ticket = `delta × ValIn` (in euro × `ValTick`); `4`/`5` → monete/gettoni in uscita (cambiagettoni);
  - **E-coin** = Σ `TransCard.ValoreOperazione` con `WinMt = 0` e valore > 0 dall'ultimo incasso a `FineInc`;
  - **partite** = Σ `delta × ValIn / ValPar` sugli ingressi monete e gettoni + delta di `In9` (partite con card);
  - `Ticpar` = ticket / (partite × `CntrLet10`); `PerPag` = (ticket × `ValTick` + premi) / incasso × 100.
- **Ripartizione con il proprietario:** `Inc` = monete contate + gettoni contati × `ValGett` + E-coin, cioè l'**incasso lordo**, senza togliere i pagamenti. **"Ns Avere" = `Inc × PerDiv / 100`** ed è la "parte gestore"; la "parte esercente" è `Inc − Ns Avere`. Il commento del codice indica "Gestore = Elmac". **[V]** `FrmCont.frm:11292`, `11316`, `10349-10350`, `7539`
  - **Contraddizione:** nelle correzioni manuali la stessa grandezza diventa `Inc × (100 − PerDiv) / 100`. **[V]** `FrmCont.frm:9873`, `9887`, `10096`, `10103`
- **Dati:** letti `EcsMacchine`, `EcsDati`, `TransCard`, `Incassi`, `Operatori`, `Setup`, `Type` (cloud); scritti `EcsMacchine.CntrLet*` (U), `Incassi` (I), `Setup.F1` (U), `Setup.ValGett` (U), file `incas.mdb`.
- **Anomalie:**
  - Nel ramo cambiagettoni `SalvaCnt` riceve il `CodMac` della riga corrente di `Macc`, non quello della macchina in elaborazione. **[V]** `FrmCont.frm:8717`
  - `Setup.F1` della prima postazione è descritto in `Setup_Descriptions` come "la postazione è un Totem". **[V]**/**[D]**
  - `AggDati` (versione precedente, con "valore reale del ticket" calcolato da `Vincite`) non è più chiamata: `VTicR` resta 0 nel riepilogo. **[V]** `FrmCont.frm:7758-8183`, `7861-7874`
- **Rete:** tutto in sala, salvo il catalogo dei tipi letto dal cloud. **[V]**
- **Peso:** L — è il flusso economico centrale della zona: calcolo multi-tabella, correzioni, ripartizione, archivio in formato Access.
- **Evidenze:** `FrmCont.frm:7586-7756`, `8662-9030`, `9814-10116`, `10321-10410`, `10713-10800`, `11256-11387`; credenziale dei file Access scritta nel codice in `FrmCont.frm:7608`, `8699`, `9549`, `9552`, `11559`.

### W08-16 — Consultazione di un incasso precedente

- **Attore e innesco:** menu *Visualizza Incassi Precedenti degli Apparecchi* in `FrmCont`. **[V]** `FrmCont.frm:9937-9984`
- **Passi:** `FrmScegliInc` elenca le date degli `Incassi` con `F0 = 1`; `CarInc` estrae il campo `Mdb` della data scelta in `PrecInc.mdb`; `VisualizzaIncasso` lo mostra in sola lettura, ripristinando `ValGett` e `ValTick` dell'epoca. **[V]** `FrmScegliInc.frm:110-135`, `Module6.bas:1302-1318`, `FrmCont.frm:11552-11587`
- **Peso:** S — consultazione.

### W08-17 — Voci aggiuntive dell'incasso ("varianti incasso")

- **Attore e innesco:** impostazioni generali → `FrmVarInc` (`frmsetGen.frm:4554`). **[V]**
- **Cosa sono:** voci che si **tolgono o aggiungono** alla parte dell'esercente e/o del gestore al momento dell'incasso: per esempio spese, affitti o acconti. Ogni voce ha: nome; tipo (valore assoluto o percentuale); per le percentuali, la percentuale e la base di calcolo (incasso totale, esercente, gestore o di una tipologia di macchina); flag "acconto"; per esercente e gestore il segno (togliere/aggiungere) e la quota (0–100 % a passi di 5). **[V]** `FrmVarInc.frm:700-716`, `801-853`
- **Dati:** `Setup.T14` e `Setup.T15` di `IdPost = 101`, come stringa `nome[tipo[perc[sorgente[acconto[segnoEse[percEse[segnoGes[percGes|…`, spezzata su due campi da 1000 caratteri; le percentuali sono memorizzate come **indice di lista** (valore / 5). **[V]** `FrmVarInc.frm:952-978`, `Module6.bas:2091-2130`
- **Uso nell'incasso:** l'importo si digita al momento dell'incasso; la quota esercente = ±importo × percEse/100, la quota gestore = ±importo × percGes/100; se "acconto" va nella "rimanenza" invece che nei totali. **[V]** `FrmCont.frm:8971-9020`
- **Anomalia:** il calcolo automatico delle voci percentuali usa una formula diversa (non moltiplica l'indice per 5 e usa sempre l'incasso di una tipologia). **[V]** `FrmCont.frm:7735-7745`
- **Peso:** S — configurazione serializzata in un campo di `Setup`.

### W08-18 — Registrazione manuale degli incassi per categoria

- **Attore e innesco:** magazzino premi → *Registra incassi* / *Modifica incassi* (`frmpremi.frm:3630-3640`, `3836-3840`); visibile secondo un flag delle impostazioni (`frmsetGen.frm:4402`, `4417`). **[V]**
- **Passi:** data della raccolta (default ieri), importi di Redemptions, Gru, Altro e Ruspe, totale lordo e netto con le aliquote IVA per categoria (`TRate`); un solo incasso per giorno. **[V]** `FrmInc.frm:710-913`
- **Dati:** `Incassi` (I con `AddIncas`: `Oper`, `Red`, `Gru`, `Alt`, `Push`, `Data`, `NImp`; `F0` resta 0), (U in modifica). **[V]** `ModAddNew.bas:770-794`
- **Interferenza:** una registrazione manuale crea una riga di `Incassi` con data recente; `sp_incasso` usa `MAX(Incassi.Data)` senza filtrare `F0 = 1` e quindi **sposta l'inizio del periodo del conteggio macchine**. **[V]** (codice) / **[D]** (effetto in esercizio)
- **Peso:** S — inserimento di una riga.

### W08-19 — Incasso amministrativo

- **Attore e innesco:** *ECL → Incasso Amministrativo* (`Form1.frm:9827-9833`). **[V]**
- **Passi:**
  1. Si collega al database **cloud** `CoinlessDB` e legge la definizione della query in `t_dynamic_reports` (`nome_del_report = 'IncAmmHQ'`, gruppo `ReportsECL`). **[V]** `frmIncAmm.frm:776-858`
  2. Esegue la query sul database di sala per il periodo (mesi interi), con totali per mese e generale (monete, gettoni, card). **[V]** `frmIncAmm.frm:860-897`
  3. Calcola il **saldo residuo nelle card** e le "sopravvenienze attive" da `TransCard`: ricariche = `NImp` 0, 1, 2; rimborsi = 8, 9; consumi = `NImp` NULL; bonus spesi = `ValoreBonus`. **[V]** `frmIncAmm.frm:899-957`
  4. Stampa ed esportazione in Excel. **[V]**
- **Rete:** **senza connessione al cloud la funzione non parte.** **[V]**
- **Credenziali:** utente e password del database cloud scritti nel codice in `frmIncAmm.frm:777`, `779`.
- **Peso:** M — query remota e calcoli di saldo, sola lettura.

### W08-20 — Rapporto macchine (`FrmEcs`)

- **Attore e innesco:** *ECL → Rapporti → Rapporto Macchine* (`Form1.frm:9786-9792`). **[V]**
- **Passi:**
  1. Periodo (data e ora), filtro per tipologia, opzione "Raggruppa" (W08-09). **[V]**
  2. Per le macchine attive nel periodo (`DataInst ≤ fine` e `DataDis` nulla o successiva all'inizio) legge `fn_dati_grafico_giornaliero` (incassi e pagamenti per giorno dai contatori) e somma da `TransCard` (`WinMt = 0`) valore e bonus delle partite con card. **[V]** `FrmEcs.frm:3295-3412`
  3. Per macchina: incasso monete+gettoni, E-coin, totale, pagamento, partite, netto, % payout, media giornaliera, gettoni, ticket per partita, ticket o, tra parentesi quadre, **numero di premi** per le gru, giorni dall'ultima visita. **[V]** `FrmEcs.frm:3499-3645`
  4. Riquadri di cassa: rimborsi (`TransCard.NImp = 8`), bonus (`NImp = 6`), "dobloni" (`NImp = 5`), incassi di cassa per operatore (`WinMt = 1`, `NImp` 0, 2 o NULL). **[V]** `FrmEcs.frm:3858-3900`
  5. Tasto destro sul codice: **diagnostica della configurazione** di ogni ingresso 1–9, con la formula di calcolo e la gravità (OK/ATTENZIONE/ERRORE). Tasto destro sui premi: elenco delle erogazioni dal delta di `In6`. **[V]** `FrmEcs.frm:2755-2921`
  6. Collegamenti a Raggruppamenti e CraneManager. **[V]** `FrmEcs.frm:5813-5835`
- **Dati:** `EcsMacchine`, `EcsDati` (tramite funzioni), `TransCard`, `Operatori`, `Clienti`, `Machines`/`Manuf`/`Type` (cloud o sala) (S); `EcsMacchine.DataDis` (U, W08-11).
- **Regole:** il ticket per partita usa `NTaps = partite × (ValPar / ValGett)` se il costo partita supera il valore del gettone, altrimenti `partite × CntrLet10`. **[V]** `FrmEcs.frm:3584-3608`
- **Nota:** `fn_dati_grafico_giornaliero` differisce tra test e produzione (valori contro quantità, DB 07 § 6). Il pulsante "Compressione archivio" è disattivato ("Operazione non consentita"), ma il codice commentato mostra cosa faceva: svuotava le tabelle coinless, riscriveva `EcsDati` a zero e cancellava `TransCard`. **[V]** `FrmEcs.frm:3012-3090`
- **Peso:** L — molte sorgenti, raggruppamenti, diagnostica, grafici e indici.

### W08-21 — Svuotamento della cassa

- **Attore e innesco:** pulsante *Azzera cassa* nel Rapporto Macchine, se `valsets.VCassa > 0`. **[V]** `FrmEcs.frm:2993-3010`
- **Dati:** `TransCard` (I) con `IdCli = 0`, `NImp = 7`, `CodMac = 'SVUOTAMENTO'`, `ValoreOperazione = VCassa`, `Operatore`. **[V]**
- **Peso:** S — una riga. Appartiene funzionalmente alla cassa (zona 4).

### W08-22 — Ricalcolo dei punti clienti multi-sala

- **Attore e innesco:** automatico da `Form1` quando la sala è multi-locale, al riconoscimento di un cliente (`Form1.frm:11501`, `11727`, `12466`, `12719`). **[V]**
- **Passi:** per il cliente (o per tutti, con `idlong > 10000`) somma i ticket non pagati (`Tickets.NumTickets − TPagati`, `Aux = 0`) nel database locale e in quello di ogni locale collegato (`NetSites`), separando quelli con `D0` NULL (punti) da quelli con `D0` valorizzato ("punti gold"); scrive `Clienti.Tickets = punti` e `Clienti.Bonus = punti gold / 100`. **[V]** `FrmRicalc.frm:275-413`
- **Rete:** connessione diretta ai database delle altre sale `DB<locale>` con credenziali da configurazione (`CServer`); un locale irraggiungibile vale 0 senza errore. **[V]** `FrmRicalc.frm:337-357`
- **Peso:** M — accesso multi-database; appartiene funzionalmente alla zona clienti (zona 3).

---

## 3. Significato delle colonne

### 3.1 Il modello ingressi–contatori di `EcsMacchine`

`EcsMacchine` descrive **due insiemi distinti di 16 elementi**, legati da `InCnt`: **[V]** `vs_ingressi_contatori.sql`, `vs_contatori_per_macchina.sql`, `sp_incasso.sql`, `frmConfMacc.frm:8081-8137`

- **ingressi** `X` = 1…16: le linee della scheda che contano impulsi, registrate cumulativamente in `EcsDati.InX`. Per ciascuno: `ValInX` (valore di un impulso), `TipoInX` (che cosa conta), `InCntX` (a quale contatore è collegato);
- **contatori** `N` = 1…16: i contascatti meccanici (o virtuali) della macchina. Per ciascuno: `CntrLetN` (ultima lettura), `CntrValN` (valore di uno scatto), `RapCntN` (rapporto).

Più ingressi possono muovere lo stesso contatore (in maschera "A2+B14"). Le funzioni `fn_valore_contatore`, `fn_lettura_contatore`, `fn_rapporto_contatore` leggono il contatore N; `fn_valore_ingresso` e `fn_tipo_ingresso` leggono l'ingresso X; tutte si fermano a 15. **[V]**

Corrispondenza tra ingressi e morsetti della scheda BE: **[V]** `frmConfMacc.frm:6252-6261`, `8925-8948`, `FrmEcs.frm:2779-2789`

| Ingresso | Morsetto | Significato | Dato in `CoinlessDecodedData` |
|---------:|----------|-------------|-------------------------------|
| In1 | A2 | Contascatti meccanico di ingresso (gettoniera) | `gettoni` |
| In2 | A1 | Contascatti meccanico di uscita (ticket) | `tickets` |
| In3 | B14 | Gettoniera elettronica / monete (e E-coin) | `cnt3` |
| In4 | A15 | Seconda gettoniera / lettore banconote | `cnt4` |
| In5 | A10 (A13) | Ticket elettronici dal gioco (ticket switch), più i ticket automatici | `cnt5` (+ `In15`) |
| In6–In8 | A3, A4, A5 | Uscite ausiliarie: premi 1–3 o ticket ausiliari | `cnt6`–`cnt8` |
| In9 | — | Partite con card (E-coin) | `partite` |
| In15 | — | Ticket automatici cumulati | calcolato |
| In10–In14, In16 | — | Non usati (In16 sempre 0) | — |

### 3.2 Catalogo

| Tabella.Colonna | Significato | Valori/codifiche | Evidenza | V/D |
|-----------------|-------------|------------------|----------|-----|
| `EcsMacchine.CodMac` | Codice macchina scelto dall'operatore; chiave usata da tutte le tabelle storiche | Testo libero, univoco; nessuna FK | `frmConfMacc.frm:7425-7436`, `9297-9309` | V |
| `EcsMacchine.Keys` | **Gruppo** della macchina (multipostazione o raggruppamento). Non è una chiave tecnica, a differenza di `Keys` nelle altre tabelle | NULL, 0 o < 1 = nessun gruppo; n > 0 = gruppo; assegnato come `MAX+1` | `frmConfMacc.frm:9191-9240`, `FormRaggruppaMacchine.frm:697-734` | V |
| `EcsMacchine.Modu` | Numero del modulo ECL della macchina, progressivo di sala; ultima parte di `device` | `MAX(Modu)+1`; `chkMVarco` aggiunge 1000 | `Form1.frm:9643-9648`, `frmConfMacc.frm:6314-6320`, `8882-8895` | V |
| `EcsMacchine.device` | Identificativo del dispositivo BE presso il servizio | `<CodClienteECL>z<CodImpianto>z<Modu>`; macchine a tempo `Modu+1000` | `frmConfMacc.frm:8039`, `8206`, `FormWizardMacchina.frm:830-833` | V |
| `EcsMacchine.NomMac` | Nome del **modello** = `Machines.MacName`. Il legame con il catalogo è **per nome**, non per `Id` | Testo | `frmConfMacc.frm:8037`, `FrmModCont.frm:2984`, `FrmEcs.frm:3462-3464` | V |
| `EcsMacchine.Tipo` | Tipologia = `Type.Id` del modello | 1 cambiagettoni; 2 redemption; 3 e 9 gru; 4 videogiochi; 5, 7, 8, 10, 11 conteggiati come video; 14 e 154 trattati a parte per i ticket per partita; 100 escluso dai rapporti; < 100 tipi normali | `FrmCont.frm:10351-10360`, `FrmEcs.frm:3499`, `3510-3518`, `3565`, `sp_incasso.sql:345` | V (uso) / D (nomi) |
| `EcsMacchine.ValIn1…16` | Valore di **un impulso** sull'ingresso | Euro per monete, banconote e premi; numero di gettoni o ticket per impulso; per In9 valore della partita card (`ValCoin × impulsi per partita`); macchine a tempo: costo per unità di tempo | `frmConfMacc.frm:8041`, `8056-8064`, `8075-8080`; `sp_incasso.sql:164-303` | V |
| `EcsMacchine.TipoIn1…16` | **Che cosa conta l'ingresso** | 0 monete in; 1 gettoni in; 2 premi out (valore); 3 ticket out; 4 monete out; 5 gettoni out; 6 E-coin (partite con card); 9 citato dalla diagnostica come "numero partite card"; NULL = non usato | `frmConfMacc.frm:6220-6227`, `sp_incasso.sql:94-114`, `FrmEcs.frm:2794-2805` | V |
| `EcsMacchine.InCnt1…16` | Numero del **contatore** mosso dall'ingresso | 1…16; NULL = nessuno | `vs_ingressi_contatori.sql`, `frmConfMacc.frm:8090`, `8123` | V |
| `EcsMacchine.CntrLet1…7` | **Ultima lettura** del contatore N: la lettura alla chiusura dell'ultimo incasso o dell'ultima rettifica. È la "lettura precedente" del conteggio successivo | Intero | `sp_incasso.sql` (`LetturaPrecedente`), `FrmCont.frm:10752-10780`, `FrmModCont.frm:2898-2912` | V |
| `EcsMacchine.CntrLet8` | **Riusata**: bitmap dell'erogatore ticket 1 | bit 0: erogatore a impulsi; bit 1: motore attivo alto; bit 2: ticket switch attivo alto; bit 6–7: politica ticketless/cartacei (bit 7 = 1 ignora le impostazioni di sala, bit 6 = 1 sempre ticketless), scritti dal servizio | `frmConfMacc.frm:6228-6236`, `7839-7843` | V |
| `EcsMacchine.CntrLet9` | **Riusata**: bitmap erogatore 2 | Come `CntrLet8` | `frmConfMacc.frm:6237` | V (commento) |
| `EcsMacchine.CntrLet10` | **Riusata**: impulsi per partita | 1–10; senza card `ValPar / 0,5` o gettoni per partita. In ECLReader = `ValPar` | `frmConfMacc.frm:7822-7828`, `frmConfMaccER.frm:2231`, `vs_eclmacchine.sql` | V |
| `EcsMacchine.CntrLet11` | **Riusata**: durata impulso di credito (ms) / unità di tempo (s) per le macchine a tempo | 10–1000 ms; default vista 90, wizard 120 | `frmConfMacc.frm:7844`, `7975`, `vs_eclmacchine.sql` | V |
| `EcsMacchine.CntrLet12` | **Riusata**: distanza tra due impulsi di credito (ms) / tempo gratuito (s) | 10–1000 ms; default 500 | `frmConfMacc.frm:7845`, `7976` | V |
| `EcsMacchine.CntrLet13` | **Riusata**: durata del foro ticket (ms) / tempo minimo in unità (0 = tempo fisso) | 1–100 ms; default 70 | `frmConfMacc.frm:7846`, `7977`, `6659` | V |
| `EcsMacchine.CntrLet14` | **Riusata**: durata del ticket (ms) | 10–500 ms; default 400 | `frmConfMacc.frm:7847` | V |
| `EcsMacchine.CntrLet15` | **Riusata**: **ticket accreditati automaticamente** alla card a ogni partita/credito | 0–200; 0 = nessuno. Muove `In5`, `In15`, `Tickets`, `Clienti.Tickets` | `frmConfMacc.frm:6243`, `7848`, `scriviTicketsAutomatici.sql:12`, `inseriscesuECS.sql:9`, `vs_eclmacchine.sql` | V |
| `EcsMacchine.CntrVal1…9` | Valore di **uno scatto** del contatore N | Euro o unità; 0,01 se il contatore mostra direttamente gli euro | `frmConfMaccER.frm:1756-1757`, `sp_incasso.sql:117-120` | V |
| `EcsMacchine.CntrVal10…15` | **Riusate**: tempi ON e OFF dei relè 1–3 (s) | 10/11 relè 1, 12/13 relè 2, 14/15 relè 3 | `frmConfMacc.frm:6244-6249`, `7912-7915` | V |
| `EcsMacchine.CntrVal16` | **Riusata**: politica hardware dei ticket | bitmask: 16 = scarica i ticket se si inseriscono monete; 32 = scarica tutti i ticket; NULL = default di sala | `frmConfMacc.frm:6737-6747`, `7916-7923` | V |
| `EcsMacchine.RapCnt1…15` | "Rapporto" del contatore. Non usato nei calcoli; ECLReader lo imposta a 6 | 6 in ECLReader | `frmConfMaccER.frm:2201`, `frmConfMacc.frm:8170` | V (scrittura) / D (significato: forse numero di cifre del contascatti) |
| `EcsMacchine.RapCnt16` | Solo ECLReader: **gettoni per partita** | 1–10 | `frmConfMaccER.frm:1903`, `2230` | V |
| `EcsMacchine.Propr` | Nominalmente il proprietario; in pratica **la stessa percentuale di `PerDiv` scritta come testo** | "0"…"100"; il wizard scrive '100' o '0' | `frmConfMacc.frm:8140`, `FormWizardMacchina.frm:1031`, `1045` | V |
| `EcsMacchine.PerDiv` | Percentuale "Ns Avere" (parte **gestore**) sull'incasso lordo della macchina | 0–100, default 100; contraddizione nelle correzioni (`100 − PerDiv`) | `frmConfMacc.frm:7662-7665`, `FrmCont.frm:11316`, `9873` | V |
| `EcsMacchine.DataInst` / `DataDis` | Date di installazione e disinstallazione; `DataDis` valorizzata = macchina disinstallata (cancellazione logica) | — | `FrmEcs.frm:2957-2987`, `sp_incasso.sql:22` | V |
| `EcsMacchine.ValPar` | Costo di una partita senza card | Euro (monete); gettoni per partita (0,25…9); 1 per le macchine a tempo | `frmConfMacc.frm:8056-8064`, `8250` | V |
| `EcsMacchine.NImp` | Non scritto dalla zona | NULL nel wizard | `FormWizardMacchina.frm:887` | V |
| `EcsMacchine.F0` | **Configurazione modificata da inviare al dispositivo** ("Pending") | 1 = pending; azzerato dal servizio | `frmConfMacc.frm:7667`, `7924`, `FormModificaPrezzi.frm:992-997` | V (scrittura) / D (reset) |
| `EcsMacchine.T0` / `N0` | Residuo: valore unitario e numero di pezzi dell'hopper nella versione precedente. `FrmModCont` scrive ancora la giacenza in `N0`; `FrmCont` li usa per i cambiagettoni | `T0` testo numerico; `N0` intero | `FrmModCont.frm:2828-2833`, `2923`, `FrmCont.frm:11380-11381` | V |
| `EcsMacchine.ValPiatto` / `PzPiatto` | Valore unitario e numero di pezzi nell'**hopper** ("piatto", fondo) della macchina | Euro / pezzi | `frmConfMacc.frm:7905-7911`, `FrmCont.frm:10076-10091` | V |
| `EcsMacchine.IngressoCrediti/Gettoni/Tickets` | Quale `InX` contiene crediti, gettoni e ticket per il servizio | Default 'In3', 'In1', 'In2'; WinMT non li modifica | `FormWizardMacchina.frm:888`, `1032` | V (default) / D (uso) |
| `EcsMacchine.device_status` | Stato del dispositivo, scritto dal servizio | 'Online', 'Offline', 'Setup', 'OOO' (fuori servizio) | `frmConfMacc.frm:8343`, `8364`, `9289` | V |
| `EcsMacchine.lastseen`, `offlinecount`, `onlinecount`, `cards_presentate`, `is_online`, `is_happyhour` | Telemetria e stato scritti dal servizio | — | `FrmEcs.frm:2715-2753`, `vs_eclmacchine.sql` | D |
| `EcsMacchine.is_timeplay` | Macchina **a tempo** (si paga il tempo, non la partita) | 1 = a tempo | `frmConfMacc.frm:6652`, `8002` | V |
| `EcsMacchine.val_platinum/gold/silver` | Costo della partita con card per livello | **Centesimi** (= crediti); per le macchine a tempo costo per unità di tempo | `frmConfMacc.frm:7818-7821`, `FormModificaPrezzi.frm:955-965` | V |
| `EcsMacchine.val_normal` | Costo della partita con **card Compleanno** (etichette "Carta COMPLEANNI", "Birthday"; in inglese anche "VIP Card"), non con card "normale" | Centesimi | `frmConfMacc.frm:7818`, `FormModificaPrezzi.frm:656` | V |
| `EcsDati.In1…In16` | Valori **cumulativi** degli ingressi della macchina a un istante (vedi § 3.1). I consumi si ottengono per differenza | bigint ≥ 0; In16 = 0 | `inseriscesuECS.sql`, `fn_calcola_impulsi_periodo.sql` | V |
| `EcsDati.DataRil` | Istante della rilevazione | — | idem | V |
| `EcsDati.NImp` | **Costante 1** in tutte le scritture | 1 | `frmConfMacc.frm:8163`, `FormWizardMacchina.frm:971`, `inseriscesuECS.sql:30` | V |
| `EcsDati.Stato`, `ValoreUscita` | Non usati dal codice attuale (NULL) | — | `FormWizardMacchina.frm:969-971` | V |
| `EcsDati.N0` | Residuo ECS: **RSSI** del segnale radio del modulo | Intero | `EscNews.bas:137-158`, `FrmDatiEcs.frm:38-39` | V |
| `EcsModuli.N0` | Numero del modulo (= `EcsMacchine.Modu`) nelle query attuali; le query vecchie usano `Id` | — | `frmConfMacc.frm:7667`, `FormModificaPrezzi.frm:658` contro `FrmModCont.frm:2588` | V |
| `EcsModuli.MacAd` | **MAC address** del modulo BE assegnato | — | `frmConfMacc.frm:7667`, `FormModificaPrezzi.frm:655` | V |
| `EcsModuli.ShortAd` | Indirizzo IP del modulo EcsNet (versione precedente) | — | `FrmModCont.frm:2593` | V |
| `Machines.MacName` / `Manufacturer` / `Type` / `CntrOut` | Catalogo dei modelli (nome, costruttore, tipo, presenza del contascatti di uscita); vive **nel cloud** | `CntrOut` bit | `FrmConf.frm:1630-1641`, `EscNews.bas:106-135` | V |
| `Type.Id` / `TypeName` / `Color` | Tipologie di macchina con colore di sfondo nelle griglie | `Id < 100` creati da WinMT; 1 cambiagettoni | `EscNews.bas:77-104` | V |
| `Owners.*` | Proprietari con "% Incasso" (`Perc`). **Funzione non raggiungibile**: tabella vuota | — | `FrmConf.frm:1472-1516` | V |
| `Incassi.F0` | **Tipo di riga**: 1 = conteggio macchine (con `Mdb`); 0 = registrazione manuale per categoria | 0/1 | `FrmCont.frm:10742`, `ModAddNew.bas:770-794` | V |
| `Incassi.Mdb` | **File Access dell'incasso**: tabelle `incas` (righe per contatore), `riepilogo` (totali, `ValGett`, `ValTick`, operatore, data precedente), `lista` (righe per macchina), `change` (cambiagettoni), `Riep_Tipi`, `Variabili` | varbinary | `FrmCont.frm:10732-10750`, `8700-8818`, `8912-9010` | V |
| `Incassi.Data` | Istante di chiusura del conteggio (`FineInc`) o data della registrazione manuale. Il `MAX` delimita il periodo di `sp_incasso` | — | `sp_incasso.sql:29`, `354` | V |
| `Incassi.Oper` | Operatore della registrazione manuale. **Non valorizzato** per i conteggi (l'operatore è nel `riepilogo` dell'`.mdb`) | Id operatore | `ModAddNew.bas:778`, `FrmCont.frm:8798` | V |
| `Incassi.Red` / `Gru` / `Alt` / `Push` | Incasso manuale giornaliero di Redemption, Gru, Altro e **Ruspe** (pusher) | Euro lordi | `FrmInc.frm:390-664`, `738` | V |
| `TransCard.NImp` (letto nella zona) | **Tipo di operazione** di cassa | NULL consumo su macchina (`WinMt = 0`); 0, 1, 2 ricariche (2 = cassa mobile); 5 "dobloni"; 6 bonus; 7 svuotamento cassa; 8 rimborsi; 9 rimborsi/resi | `frmIncAmm.frm:903-949`, `FrmEcs.frm:3006`, `3858-3894` | V (uso) / D (nomi di 0, 1, 9) |
| `Setup.T14` / `T15` (101) | Definizione serializzata delle **voci aggiuntive dell'incasso** | Vedi W08-17 | `FrmVarInc.frm:700-716`, `973` | V |
| `Setup.F1` (prima postazione) | Flag "conteggio macchine in corso" | 1 durante `FrmCont` | `FrmCont.frm:10782-10800` | V (scrittura) / D (lettori) |
| `Setup.ValGett` / `ValTick` (101) | Valore di un gettone e di un ticket in euro, usati per valorizzare contatori e incassi; `ValGett` può essere riscritto dal conteggio | Euro | `FrmCont.frm:9101-9110`, `fn_dati_grafico_giornaliero.sql` | V |

**Risposte alle domande aperte dei documenti DB.**
- `EcsMacchine.Propr` "testo libero con 1–2 valori" (DB 03 § 5, DB 05): non è un nome di proprietario ma la percentuale di `PerDiv` copiata come testo; `Owners` è vuota perché la sua gestione non è raggiungibile dal menu. **[V]**
- `NImp` in `EcsDati` sempre 1 (DB 03 § 6): è una costante scritta da tutti i punti di inserimento. **[V]**
- `NImp` in `TransCard` da 0 a 20 (DB 03 § 6): è il tipo di operazione (ricarica, rimborso, bonus, svuotamento…), non un impianto. **[V]** per i codici 2, 5, 6, 7, 8; **[D]** per gli altri.
- `CntrLet15` = ticket automatici: confermato. **[V]**
- I contatori sono 16 per due insiemi distinti (ingressi e contascatti), non 16 "contatori" generici (DB 01 § 4). **[V]**

---

## 4. Regole, calcoli e comportamenti notevoli

### 4.1 Contatori e incassi

1. **Le letture sono cumulative e i consumi sono differenze.** Nessun dato di consumo è memorizzato per partita: tutto si ricava come differenza tra due righe di `EcsDati`. **[V]**
2. **Tre algoritmi di differenza diversi** per lo stesso dato: **[V]**
   - conteggio incasso: ultima lettura dopo l'ultimo incasso − ultima lettura non successiva (`fn_calcola_impulsi_periodo`);
   - rapporti giornalieri e orari: `MAX − MIN` delle letture **dentro** il giorno o l'ora (`fn_RicalcolaContatoriGiornalieri/Orari`). L'incremento tra l'ultima lettura di un giorno e la prima del successivo **non viene attribuito a nessun giorno**; con letture frequenti la perdita è piccola ma sistematica, e i totali giornalieri non coincidono con l'incasso del periodo. **[D]** (effetto)
   - diagnostica premi: `LAG` tra righe successive (`FrmEcs.frm:2897-2918`).
3. **Azzeramenti.** Nessun algoritmo gestisce un contatore che riparte da zero (sostituzione della scheda, reset): la differenza diventa negativa (incasso) o falsata (`MAX − MIN`). L'unico "azzeramento" previsto è la cancellazione dei dati della macchina con una lettura a zero (W08-10). **[V]**/**[D]**
4. `fn_verifica_incremento_contatore` (restituisce l'ultima lettura con tutti i contatori ≤ a quelli proposti, cioè verifica la monotonia) **non è usata né dal VB6 né da altre funzioni del database**: presumibilmente la usa il motore di sala. **[V]**/**[D]**
5. **Formula dell'incasso** (§ 2, W08-15) e **ripartizione sull'incasso lordo**: la parte gestore è `PerDiv %` dell'incasso lordo (monete + gettoni × valore gettone + E-coin), non del netto dopo i premi. **[V]**
6. Il **periodo dell'incasso** inizia da `MAX(Incassi.Data)` di qualunque tipo di riga e termina a `FineInc` per le card, ma all'ultima lettura disponibile per i contatori, anche se successiva. **[V]**
7. L'incasso aggiorna `EcsMacchine.CntrLet`: è l'unico "registro" delle letture fisiche, ed è sovrascritto (non storicizzato). Lo storico delle letture reali e delle correzioni esiste solo dentro i file `.mdb` salvati. **[V]**
8. I valori in euro di gettoni e ticket dipendono da `Setup.ValGett`/`ValTick` al momento del calcolo; l'`.mdb` conserva quelli usati. **[V]**

### 4.2 Configurazioni predefinite del wizard

| Categoria | Ingressi configurati | Contatori | Livelli e quota |
|-----------|---------------------|-----------|-----------------|
| Redemption | In3 monete (1 €), In4 (1), In5 ticket (1), In9 E-coin | InCnt1 = 1, InCnt3 = 2, InCnt7 = 1 (?) | `val_*` = 100, `PerDiv` 100 |
| Crane | In1 monete (1), In3, In4, In6 premi (5 €) | InCnt1 = 1, InCnt6 = 2 | `val_*` = 0, `PerDiv` 0 |
| Videogame | In3 monete, In4, In9 E-coin | InCnt2 = 1, InCnt8 = 1 | `val_*` = 100, `PerDiv` 100 |
| Pusher | In3 monete, In4, In6 ticket (100 per impulso), In9 E-coin | InCnt2 = 1, InCnt5 = 2, InCnt8 = 1 | `val_*` = 100, `PerDiv` 100 |

Fonte: `FormWizardMacchina.frm:1021-1076`. **[V]** Alcuni collegamenti (`InCnt7` nella redemption, `InCnt2/InCnt8` nel videogame) non corrispondono agli ingressi configurati e sembrano errori del modello: con queste impostazioni l'incasso calcolato può essere incompleto. **[D]**

### 4.3 Configurazione verso i dispositivi

- La configurazione autorevole è nella riga di `EcsMacchine`; il servizio la legge e la applica alla scheda. `F0 = 1` segnala le modifiche da applicare. **[V]**/**[D]**
- Ogni comando passa da HTTP verso il servizio sulla porta 58889 del server di sala; nessun comando usa MQTT direttamente da WinMT. **[V]**
- Il costo della partita è per livello card (Platinum, Gold, Silver, Compleanno); la tariffa per le card senza livello è `ValPar` (partita senza card). **[V]**

### 4.4 Da decidere consapevolmente

- Riprodurre o no l'**archivio dell'incasso come documento chiuso** (oggi un `.mdb`): il nuovo sistema dovrà avere tabelle *incasso*, *riga per macchina/contatore*, *correzione*, *voce aggiuntiva*, con l'incasso immutabile dopo la chiusura.
- La **cancellazione fisica** di macchine e dati (W08-10), da sostituire con disattivazione.
- Il **valore del gettone** modificabile dal conteggio (W08-15, passo 7): è un parametro globale di sala che cambia la valorizzazione di tutti i rapporti.

---

## 5. Problemi rilevanti per il nuovo disegno

1. **Tabella da 129 colonne con colonne riusate.** `CntrLet8–15` e `CntrVal10–16` contengono parametri della scheda, non letture: il nome della colonna non dice cosa contiene. Nel nuovo modello servono entità separate: *macchina*, *modello*, *ingresso* (tipo, valore impulso), *contatore* (valore scatto, letture), *parametri dispositivo*, *tariffa per livello*.
2. **Due modelli di configurazione** (ECL e ECLReader) sulla stessa tabella con regole diverse per gli stessi campi (`ValIn`, `CntrLet10`, `RapCnt`).
3. **Catalogo modelli centralizzato ma collegato per nome.** `Machines/Manuf/Type` stanno nel cloud con ripiego locale; `EcsMacchine` vi si lega con `NomMac` e `Tipo`. Rinominare un modello rompe i rapporti; offline il catalogo locale diverge.
4. **Cancellazione fisica dello storico economico.** Eliminare una macchina cancella `TransCard` (movimenti di credito dei clienti) ed `EcsDati`; Sync Framework propaga la cancellazione al cloud.
5. **Incasso salvato come file Access in un campo binario.** Non interrogabile, non sincronizzabile in modo utile, dipendente da DAO/ODBC Access a 32 bit; anche le credenziali del file sono nel codice.
6. **Ripartizione proprietario incoerente.** `PerDiv` vale "parte gestore" nel calcolo e "100 − parte gestore" nelle correzioni; `Propr` duplica la percentuale; `Owners` non è usata. Per il noleggio servono proprietario, percentuale per macchina con validità nel tempo, base di calcolo (lordo o netto) e voci aggiuntive.
7. **Periodo d'incasso implicito.** Il periodo è delimitato da `MAX(Incassi.Data)` e dalle letture disponibili, non da letture associate all'incasso: una registrazione manuale o una cancellazione in `Incassi` cambia il conteggio successivo.
8. **Letture cumulative senza gestione dei reset** e algoritmi giornalieri che perdono gli incrementi tra un giorno e l'altro: le letture vanno trasformate in **eventi di incremento** al momento della ricezione, con riconoscimento dei reset.
9. **Dipendenze di rete nascoste.** Wizard e Incasso Amministrativo non funzionano senza cloud; i comandi ai dispositivi non funzionano senza servizio di sala; `FrmRicalc` si collega direttamente ai database delle altre sale.
10. **HQ scrive sui dati di sala.** In WinMTHQ le stesse form inseriscono in `[<nomedb>].dbo.EcsDati` e modificano `EcsMacchine` sulla copia cloud (`frmConfMacc.frm:6568-6571`, `8160-8162`).
11. **Nomi di database fissi** (`[WinMtSqlDB]`) in diversi `INSERT` (vedi DB 07 § 7).

---

## 6. Domande aperte per il team

1. `PerDiv`: è la quota del **gestore** (chi possiede le macchine, "Elmac" nel commento del codice) o dell'esercente? Quale delle due formule di `FrmCont` è quella giusta? La ripartizione deve avvenire sul lordo o sul netto dei premi pagati?
2. Il noleggio con più proprietari nella stessa sala è un caso reale? Perché la gestione `Owners` è stata abbandonata?
3. `CntrLet7` o `CntrLet8` per il tipo di erogatore? `frmConfMacc` scrive la bitmap in `CntrLet8`, la vista `vs_eclmacchine` espone `CntrLet7` come `TipoErogatore`.
4. Che cosa significa `RapCnt` (6 in ECLReader)? È il numero di cifre del contascatti?
5. In modalità ECLReader chi scrive `EcsDati`? Esistono ancora sale in quella modalità?
6. Come si gestisce oggi la sostituzione di una scheda o l'azzeramento di un contatore della scheda? Si usa "Cancella dati macchina"?
7. Le registrazioni manuali per categoria (`FrmInc`) sono ancora usate? Se sì, sanno di spostare l'inizio del conteggio macchine?
8. L'Incasso Amministrativo dipende da una query nel cloud (`t_dynamic_reports.IncAmmHQ`): chi la mantiene e come si versiona?
9. Il "valore medio del gettone" calcolato dai cambiagettoni va davvero riscritto in `Setup.ValGett`?
10. I modelli predefiniti del wizard (§ 4.2) sono corretti, in particolare i collegamenti `InCnt` di redemption e videogame?
11. Chi azzera `EcsMacchine.F0` dopo aver applicato la configurazione, e cosa succede se la macchina resta offline a lungo?
12. Quali tipologie corrispondono ai codici `Type.Id` 3, 5, 7–11, 14, 100 e 154?
13. `TransCard.NImp` 0, 1 e 9: quali operazioni rappresentano esattamente?
