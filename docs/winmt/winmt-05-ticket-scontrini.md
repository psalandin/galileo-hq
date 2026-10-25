# Galileo HQ — WinMT 05: Ticket, card tradizionali, scontrini, resi e archivi

**Stato:** bozza · **Responsabile:** Piero · **Aggiornato:** 2026-10-23

**Fonte:** sorgente VB6 di WinMT (copia del 24/07/2026), file: `FrmCCard.frm`, `FrmCCardAlba.frm`, `Frm4Usr.frm`, `FrmCanArc.frm`, `FrmCTickets.frm`, `frmsetS4Usr.frm`, `Prova Carte/RacCard.cls`, `frmresauto.frm`, `FrmRic.frm`, `frmDScon.frm`, `frmresman.frm`, `FrmRepTick.frm`, `frmscontr.frm`, `Prova Carte/frmCRCard.frm`, `CreaRaccolte.bas`, `frmopabb.frm`, `FrmAbMis.frm`, `FrmNTickMod.frm`, `FrmCScon.frm`, `frmTckPersi.frm`, `frmResiConCard.frm`, `FrmPul.frm`; seguiti dove serve `ModAddNew.bas`, `Module1.bas`, `Module6.bas`, `Module8.bas`, `Form1.frm`, le procedure SQL `scriviTicketsAutomatici`, `scriviTicketsDaCoinless`, `fn_decode_mt_bitmask` · **Collegati:** `winmt-01-cassa-form1.md` (W01-04…W01-08, W01-23), `winmt-02` (moduli comuni), `winmt-03` (clienti e card), `winmt-04` (ECL e pagamenti), `winmt-06` (premi e magazzino), `docs/db/db-02-catalogo.md`, `docs/db/db-05-produzione-01.md`, `docs/db/db-06-produzione-02.md`, `docs/db/db-07-confronto-test-produzione.md`, `sql/risultati/Setup_Descriptions-test.tsv`

Legenda: **[V]** verificato nel codice, con riferimento `file:riga`; **[D]** dedotto, da confermare. Le credenziali presenti nel codice non sono riportate.

> **Avvertenza sul lessico.** Nel codice "scontrino" non indica quasi mai lo scontrino fiscale: è la **ricevuta con codice a barre** stampata dal mangia-ticket, da un gioco o dalla cassa, che rappresenta un certo numero di ticket. Nessun file di questa zona stampa scontrini fiscali (vedi § 4.6). Anche "resi" ha due significati: **premi restituiti dal cliente** (tabella `Resi`) e **"card resi"**, un cliente fittizio usato in un report (W05-15).

---

## 1. Perimetro

| File | Righe di codice | Ruolo | Lettura |
|------|----------------:|-------|---------|
| `FrmCCard.frm` | 2.565 | Ricarica di crediti sulla card ECL (contanti, POS seriale o Nayax TCP), rimborso, omaggio, rimborso gettoni, ticket bonus. Dal 10/2024 serve **solo alle ricariche in denaro** | A fondo `Num_Click`, `Form_Load`, scrittura e ripristino card; scorse la gestione dei protocolli POS e la stampa della ricevuta POS |
| `FrmCCardAlba.frm` | 1.952 | **Variante "Albarella"** (personalizzazione nascosta `HiddenOpt = 2`) che riunisce in una form il carico dei ticket, la ricarica crediti e il carico di gettoni/dobloni | Confrontata procedura per procedura con `FrmCTickets` e `FrmCCard` (§ 2, W05-03) |
| `Frm4Usr.frm` | 1.664 | **Sistema 4 utenti**: banco premi con quattro operatori in parallelo, ciascuno con il proprio scanner e un quarto del terzo monitor | A fondo |
| `FrmCanArc.frm` | 1.110 | "Cancellazione Archivi": cancellazioni massive per tabella e data | A fondo |
| `FrmCTickets.frm` | 867 | "Carica Tickets nella Card": scontrini cartacei, carte raccolta e ticket manuali accreditati sul cliente | A fondo |
| `frmsetS4Usr.frm` (form `FrmSet4Usr`) | 366 | Configurazione del sistema 4 utenti | A fondo |
| `Prova Carte/RacCard.cls` | 320 | Classe di una **raccolta di carte collezionabili** (valori, serie, contatori) | A fondo |
| `frmresauto.frm` | 276 | Restituzione di un premio da parte di un cliente con card | A fondo |
| `FrmRic.frm` | 272 | "Riepilogo Ricevute Premi": consultazione di `Vincite25` (non riguarda le ricariche) | A fondo |
| `frmDScon.frm` | 269 | "Dettagli Scontrino": decodifica di uno scontrino letto | A fondo |
| `frmresman.frm` (form `FrmResMan`) | 261 | Restituzione di un premio senza card | A fondo |
| `FrmRepTick.frm` | 247 | Ticket "da reparto" (manuali con reparto) | A fondo |
| `frmscontr.frm` | 245 | Scontrino manuale con password; usata anche come tastierino numerico | A fondo |
| `Prova Carte/frmCRCard.frm` | 212 | Configurazione dei valori di carte e serie delle raccolte | A fondo |
| `CreaRaccolte.bas` | 166 | Creazione dei record `Setup` delle raccolte (Mistral, Willy Wonka, DC Comics) | A fondo |
| `frmopabb.frm` | 139 | Riepilogo abbuoni per operatore | A fondo |
| `FrmAbMis.frm` (form `FrmAbCard`) | 116 | Riabilitazione delle carte raccolta già lette | A fondo |
| `FrmNTickMod.frm` | 62 | Ricalcolo massivo del prezzo in ticket dei premi | A fondo |
| `FrmCScon.frm` | 60 | "Conteggio scontrini": somma di scontrini letti, senza DB | A fondo |
| `frmTckPersi.frm` | 49 | "Tickets sospesi": ticket ticketless rimasti nel buffer coinless | A fondo |
| `frmResiConCard.frm` | 42 | "Elenco partite con card resi" | A fondo |
| `FrmPul.frm` | 8 | Solo la finestra di avanzamento "Pulizia archivi in corso…" | Letto |

Fuori file ma seguiti per chiudere i flussi: `ModAddNew.bas` (`AddScon`, `AddSconCan`, `ManualTicket`, `AddResi`, `AddMistral`, `AddAbbuono`, `AddTickRep`, `AddTransCard`, `AddTicCli`, `AddVincita`), `Module8.bas` (`TrovaSco`), `Module6.bas` (`StampaSco`, `Bon24`, `CalcSerNum`, `SettaPuntiCard`, gestione *manual tickets*), `Module1.bas` (commenti di testata 100-157, caricamento di `Setup`), i punti di `Form1.frm` che aprono le form della zona, e le procedure SQL che inseriscono in `Tickets`.

---

## 2. Flussi

### 0. Il ciclo di vita del ticket (quadro d'insieme)

La tabella `Tickets` non è una tabella di "ticket": è insieme **registro degli scontrini al portatore**, **libro dei lotti di punti** di ogni cliente, **tabella di lock** tra postazioni e, in modalità Golden, **portafoglio Silver/Gold**. Una riga è un *lotto* di `NumTickets` ticket, di cui `TPagati` già spesi [V] `Form1.frm:17201` (saldo = `SUM(NumTickets − TPagati)` con `Aux = 0`).

| Fase | Chi scrive | Effetto su `Tickets` | Evidenza |
|------|------------|----------------------|----------|
| **Emissione dal mangia-ticket** (Galileo) | Non WinMT: nessuna scrittura con `MangiaT = 1` e `IdContatto = 0` nel VB, a parte le raccolte card | Riga `IdContatto = 0`, `TPagati = 0`, `NumTrans` = numero di serie stampato, `Id` = numero del mangia-ticket | [D] assenza nel VB; `FrmRappUs.frm:1809-1840` raggruppa per `Id` "calcolo tickets per mangiatickets" |
| **Emissione ticketless dal gioco** (ECL) | Procedura `scriviTicketsAutomatici` (chiamata da `decodifica_record`) e un altro scrittore esterno | Riga intestata al cliente, `MangiaT = 8256` (8192 "generato in app" + 64 bonus), `NImp = 0`; `Clienti.Tickets` incrementato | [V] `scriviTicketsAutomatici.sql:51-54`; per le righe con `F1`/`T1` vedi § 3 |
| **Emissione dalla cassa** | `AddScon` / `StampaSco` | Resto (32), scontrino totale (16), manuale (4), reparto (4 con `NRep`), reso (8), bonus (64), prenotazione cancellata (2056), passaggio tra card (1024), Silver↔Gold (16384) | [V] `ModAddNew.bas:61-97`, elenco chiamate in § 3 |
| **Lettura e blocco** | `TrovaSco`, `FrmCTickets`, `Frm4Usr` | `TPagati = −IdPost` (cassa) o `−(IdPost+1+n)` (4 utenti): lo scontrino è "in mano" a una postazione | [V] `Module8.bas:86, 102`; `Frm4Usr.frm:4713` |
| **Rilascio** (annulla) | `CmdExit`/`CmdDel`, `IniUsr`, `CmdAnn` | `TPagati` torna a 0 | [V] `FrmCTickets.frm:932, 995`; `Frm4Usr.frm:5387-5393` |
| **Conversione in punti sulla card** | `FrmCTickets.cmdOk_Click` | La riga dello scontrino diventa un lotto del cliente: `IdContatto = cliente`, `TPagati = 0`, `MangiaT |= 256`, `DataOut`/`OperOut` = data e operatore del caricamento; copia in `TicketsCan` | [V] `FrmCTickets.frm:1123-1130` |
| **Consumo** (consegna premi) | `TogliPunti`, `ScaricaPunti`, `DaPremi` | `TPagati` sale fino a `NumTickets`, `DataOut`/`OperOut` = consumo | [V] `Form1.frm:16627-16645`; `Frm4Usr.frm:5499-5526, 5620-5634` |
| **Somma in uno scontrino totale** | Form1 | Scontrini sommati: `TPagati = NumTickets`, `MangiaT |= 128`; nuovo scontrino `MangiaT = 16`, `NonCont = 1` | [V] `Form1.frm:8641-8660` |
| **Annullamento da operatore** | `FrmDeCli` (zona 03) | `MangiaT |= 4096`, `NonCont = 1`; la riga **resta** | [V] `FrmDeCli.frm:4267-4292` |
| **Passaggio ad altra card** | `FrmUCard`, `FrmUCardECL` (zona 03) | Origine `MangiaT |= 512`; nuova riga `MangiaT = 1024` sul destinatario | [V] `FrmUCard.frm:792, 835` |
| **Cancellazione fisica** | `FrmCanArc`, `MnuPul` | `DELETE` per data o per "usati" (`NumTickets = TPagati`) | W05-21, W05-22 |

**`TicketsCan`** è il registro degli **scontrini cartacei già trasformati in punti**: serve a rifiutare un secondo caricamento dello stesso foglio [V] `FrmCTickets.frm:750-754`, `Frm4Usr.frm:4606-4608, 4643-4654`. **`TickRep`** e **`Scocard`** non partecipano al ciclo: la prima non ha più scrittori, la seconda è stata riusata per gli avvisi sul cliente (§ 3).

---

### W05-01 Carico di scontrini, carte raccolta e ticket manuali sulla card del cliente

- **Attore e innesco:** operatore di cassa, con il cliente identificato in Form1; pulsante di carico ticket, che apre `FrmCTickets` ("Carica Tickets nella Card") [V] `Form1.frm:7317-7325`. Input dallo scanner barcode seriale, oppure inserimento manuale di serie e numero ticket se lo scontrino è illeggibile, oppure digitazione di un importo manuale.
- **Passi:**
  1. All'apertura mostra i ticket del cliente (`Clienti.Tickets`; in multi-sala `RicalTCli`) e decide se l'operatore può digitare ticket manuali: sempre per livello < 2, altrimenti solo se `OpScoMan` e senza `PasswSM` [V] `FrmCTickets.frm:1318-1326, 1361-1368`.
  2. **Barcode di una carta raccolta** (se `Mistral` attivo, 10 o 11 caratteri con prefisso di una raccolta): verifica il codice sala `MisCode` nei caratteri 3-6, inserisce la carta in `Mistral` con `Sospeso = 1` (la chiave primaria impedisce la seconda lettura: "già letta"), ne calcola il valore con `RacCard.Valore` (carta più eventuali serie completate) e lo aggiunge alla lista come riga `XX-CARD` [V] 569-620.
  3. **Barcode `TK#####KT`** (*manual tickets*): alla prima lettura rinomina il reparto 2 in "Cards Collections"; crea una riga `Tickets` bloccata sulla postazione (`IdContatto = 0`, `MangiaT = 4`, `TPagati = −IdPost`, `T0 = 'MANUAL TICKETS'`, `NRep = 1`, `Id = 1`) [V] 621-632, `ModAddNew.bas:1054-1084`, `Module6.bas:2052-2062`.
  4. **Scontrino**: `TrovaSco` decodifica il barcode (vedi § 4.2), cerca in `Tickets` una riga libera (`IdContatto = 0`, `TPagati = 0`, `Aux = 0`) e la blocca (`TPagati = −IdPost`). Se non esiste e `TicStat` è attivo, uno scontrino "esterno" registrato (`TSSNum0..9`) viene **creato** con `MangiaT = 6` e già bloccato [V] `Module8.bas:2-120`. `CmdAdd_Click` rifiuta i doppioni nella lista, gli scontrini già intestati ad altri e quelli presenti in `TicketsCan`; con `AutoConv` accetta anche scontrini sconosciuti [V] `FrmCTickets.frm:692-853`.
  5. Inserimento manuale di serie e numero: cerca lo scontrino libero e lo blocca [V] 855-904. Importo digitato: genera un barcode fittizio `1` + serie + quantità + `9` e lo tratta come scontrino, marcato `#` [V] 1260-1297.
  6. **Conferma** (`cmdOk_Click`) [V] 1018-1246:
     - bonus 24 ore `Bon24` (vedi § 4.4) [V] 1073;
     - per ogni scontrino trovato in `Tickets`: lo intesta al cliente (`IdContatto`), azzera `TPagati`, aggiunge il bit 256, scrive `DataOut = Now`, `OperOut`, e ne registra una copia in `TicketsCan` [V] 1118-1130;
     - per ogni scontrino non presente: crea il lotto del cliente (`MangiaT` 2 da ticket station, 6 convalidato, 4 manuale con `Id = IdPost`) e una riga `TicketsCan` con `MangiaT` 301 o 101 [V] 1134-1151. Per la ticket station il commento dice "`Id` = mangia-ticket che ha generato lo scontrino", ma il codice legge una variabile mai valorizzata (`NumSerie`) e scrive 0 [V] 1136;
     - per ogni raccolta con punti: un lotto `MangiaT = 1`, `NRep = 1`, `T0 = prefisso|punti serie` [V] 1158-1165;
     - lotto bonus 24 ore `MangiaT = 64` [V] 1168-1178;
     - intesta al cliente i *manual tickets* sospesi (`TPagati = 0`, `MangiaT = 4`, `DataOut`, `OperOut`) [V] 1182, `Module6.bas:2064-2073`;
     - **sovrascrive** `Clienti.Tickets` con il nuovo totale e aggiorna `DataUltVis` (`SettaPuntiCard`), poi lo incrementa anche sul recordset di Form1 [V] 1183-1184, `Module6.bas:1822-1850`;
     - conferma le carte raccolta (`Mistral.Sospeso = 0`) e aggiorna i contatori locali delle raccolte [V] 1208-1219.
  7. **Annulla**: rilascia gli scontrini (`TPagati = 0`), cancella i *manual tickets* sospesi (`DELETE … T0 = 'MANUAL TICKETS'`), cancella le carte raccolta sospese [V] 953-1016, `Module6.bas:2017-2039`, `Form1.frm:17323-17341`.
- **Dati:** legge `Tickets`, `TicketsCan`, `Clienti`, `Mistral`, `Setup` (raccolte); scrive `Tickets` (insert, update, delete dei manual tickets), `TicketsCan` (insert), `Mistral` (insert, update, delete), `Clienti.Tickets`, `Clienti.DataUltVis`, `Setup.NRep2` (101).
- **Regole:** `AutoConv` (convalida automatica di scontrini sconosciuti), `TicStat` + `TSSNum0..9` (ticket station esterne), `OpScoMan`, `PasswSM`, `FT24H`/`NT24H`/`TmOpen` (bonus 24 ore), `Mistral`/`MisCode`, `Golden` (separazione Silver/Gold con `D0`).
- **Periferiche:** scanner barcode seriale (`BarRd`, comandi ESC per laser) [V] 549, 669-680, 1503-1526; secondo monitor (`cliente`) per video bonus delle raccolte [V] 608-615. **Nessuna scrittura sulla card ECL**: il carico vale solo nel DB (diversamente dalla variante Albarella, W05-03).
- **Senza rete:** richiede il SQL Server di sala; il cloud non serve.
- **Peso: L** — molte varianti di input, lock tra postazioni, tre tabelle più `Mistral`, regole di convalida e bonus.
- **Evidenze:** `FrmCTickets.frm:534-1246`, `Module8.bas:2-120`, `ModAddNew.bas:61-97, 743-768, 1054-1084`, `Module6.bas:860-903, 2017-2073`.

### W05-02 Ricarica di crediti sulla card ECL (`FrmCCard`)

- **Attore e innesco:** operatore di cassa, cliente con card ECL sul lettore; pulsante di carico crediti in Form1 quando la sala **non** è Albarella [V] `Form1.frm:7083-7137` (commento: "la formccard serve solo per le ricariche in denaro non tickets").
- **Passi:**
  1. Carica i diritti dell'operatore (`CaricoCreditiAbilitato`, `RimborsiAbilitati`, `OmaggiAbilitati`), gli importi rapidi da `setup2` (`ImportoRicariche`, JSON) o da `ImPOS`, il compleanno attivo (`BirthdayFreeCharge`), la configurazione del rimborso gettoni (`IsRimborsoGettoni`, JSON con `ValoregettoneDaRimborsare`) e il POS disponibile (seriale o TCP Nayax) [V] `FrmCCard.frm:2058-2241, 1746-1784, 4676-4702`.
  2. Modalità: **carico** (pagato), **rimborso** (`Num 13`), **omaggio** o **rimborso gettoni** (`Num 14`) [V] 2960-2996.
  3. Al pagamento POS attende l'esito (timeout 200 s sul TCP) e registra la transazione in `LogTransazioniPos` (`InsertPOSPending`, `UpdatePosTransactionByUID`) [V] 2562-2696, 3102-3103; in contanti chiede conferma [V] 2724-2736. Il rimborso gettoni accetta solo importi multipli esatti del valore del gettone [V] 2697-2723, 4703-4722.
  4. Verifica che la card sul lettore sia ancora quella del cliente, calcola crediti e bonus (`BonusHandler.CalcBonusCrediti`; zero bonus per rimborso e omaggio), scrive la card e la **rilegge** confrontando crediti, bonus e progressivo [V] 2746-2835, 4295-4307, 4314-4387.
  5. Registra in `TransCard` (vedi § 3, `TransCard.NImp`): bonus 6 e carico 0, oppure rimborso 8, rimborso gettoni 5, omaggio 9; ogni scrittura aggiorna anche `Clienti.Credito` [V] 2842-2897, `ModAddNew.bas:1086-1147`.
  6. Se la scrittura nel DB fallisce, **riporta la card ai valori precedenti** (`cicloDiRipristinoDellaCard`) [V] 2899-2935.
  7. Ticket bonus sulla ricarica (`BonusHandler.CalcBonusTickets`): lotto `Tickets` con `MangiaT = 64`, `NonCont = 1` [V] 2873-2878.
  8. Aggiorna il fondo cassa in memoria (`VCassa += importo − quota POS`) [V] 2843.
- **Dati:** scrive `TransCard`, `Clienti.Credito`, `Tickets`, `LogTransazioniPos`; legge `setup2`, `Operatori`, `Clienti`, `promozioni` (tramite classi).
- **Periferiche:** lettore/scrittore ECL (`ClsEclReaderWriter`), POS seriale (`PosRd`) o Nayax via socket TCP (`cls_NayaxManager`), stampante termica per la copia della ricevuta POS (non fiscale) [V] 3570-3800.
- **Peso: L** — transazione a due fasi card/DB con compensazione, periferiche, quattro tipi di operazione. Il dettaglio dei protocolli POS e di `TransCard` è della zona 04.
- **Evidenze:** `FrmCCard.frm:2058-2241, 2512-3013, 4295-4448, 4676-4722`.

### W05-03 Variante Albarella: ticket, crediti e gettoni in una form (`FrmCCardAlba`)

- **Attore e innesco:** come W05-01 e W05-02, ma solo se `Setup.N14` (`HiddenOpt`) = 2, "ALBARELLA" [V] `Module1.bas:168-176, 2695-2706`, `Form1.frm:7043-7081`, `frmsetSys.frm:7917-7920`.
- **Confronto con le form standard** (codice normalizzato e confrontato con `diff`):

| Parte | Differenza rispetto alla form standard | Evidenza |
|-------|----------------------------------------|----------|
| Lettura barcode (`BarRd_OnComm`) | Identica a `FrmCTickets`, senza il caso "scontrino Gold" (esito 8) | `FrmCCardAlba.frm:2226-2365` |
| `CmdAdd`, `CmdASco`, `CmdDel` | Identiche | 2408-2678 |
| Conferma ticket (`cmdOk_Click`) | Nessuna gestione Silver/Gold, nessuna protezione da doppia esecuzione; **scrive il totale punti sulla card ECL** (`AggiungiPunti`) e attende la conferma del lettore | 2734-2900, 2875 |
| Ricarica crediti (`Num_Click`) | POS solo seriale e solo sotto 650 €; bonus da `CalcBonus` scritto con una **seconda** scrittura della card; nessuna rilettura di verifica, nessun ripristino in caso di errore DB, nessun controllo dei diritti dell'operatore, nessun ticket bonus | 3310-3562 |
| **Carico gettoni/dobloni** (`NumD_Click`) | Solo qui: l'operatore conta i gettoni fisici restituiti, la card viene caricata di `n × VDobl` e si registra `TransCard` con `NImp = 5`. `VDobl = Setup.Mon3H / 100` (colonna del terzo monitor riusata) | 3923-3993, 2974, `Module1.bas:433, 2591` |

- **Dati:** come W05-01 e W05-02, più `TransCard` con `NImp = 5`.
- **Peso: M** — è una copia più vecchia di due flussi già contati; il solo elemento nuovo è il carico gettoni.
- **Evidenze:** sopra.

### W05-04 Sistema 4 utenti: banco premi con quattro operatori (`Frm4Usr`)

È il sistema che il team vuole dismettere; qui è descritto per intero.

- **Che cos'è:** una modalità **concessa dalla chiave di licenza** "Sql 4 Users" [V] `Module1.bas:123-128, 1368-1373, 1140`. Si attiva con `Setup.Ab4Usr` e, all'avvio di Form1, apre `Frm4Usr` a schermo intero sul **terzo monitor**, diviso in quattro riquadri colorati (rosso, verde, blu, giallo) [V] `Form1.frm:13748-13752`, `Frm4Usr.frm:5347-5368`. Ogni riquadro corrisponde a un **operatore in piedi con uno scanner barcode seriale** (porte `PBRm0..3`), senza tastiera né mouse: tutti i comandi sono **barcode stampati** su un foglio "COMANDI MULTI USER" (`MnuStpCom`) [V] `Form1.frm:10121-10140`. Il terzo monitor mostra anche immagini e messaggi pubblicitari a rotazione (`3rdScreenPics`, `MsgSco.bin`) [V] 4865-4903, 5885-5914.
- **Attore e innesco:** operatore del banco; lettura di barcode sul proprio scanner (`Br_OnComm(Index)`).
- **Passi** (per ciascun riquadro, in parallelo) [V] `Frm4Usr.frm:4292-4863`:
  1. **Login**: lettura del barcode dell'operatore (`CD…` o `JV…`, 11 caratteri, cercato in `Operatori.CodBar`); lo stesso operatore non può essere attivo su due riquadri; una seconda lettura chiude la sessione [V] 4523-4569.
  2. **Cliente con card**: lettura della card a barcode (`Clienti.CodBar`); un cliente non può essere servito da due riquadri; mostra nome o numero card e i punti (`Clienti.Tickets`) [V] 4742-4824.
  3. **Scontrini** (14 o 16 cifre, controllo modulo 10): rifiuta quelli già letti da qualunque riquadro; accetta scontrini esterni registrati (`TicStat`, `TSSNum`) creandoli con `MangiaT = 2`; accetta scontrini Galileo solo se esistono liberi in `Tickets` o, con `AutoConv`, creandoli con `MangiaT = 6`; rifiuta quelli in `TicketsCan` [V] 4571-4661. Con cliente: il lotto viene **intestato al cliente**, sommato a `Clienti.Tickets`, con bonus 24 ore e copia in `TicketsCan`. Senza cliente: lo scontrino viene **bloccato** con `TPagati = −(IdPost + 1 + indice)` [V] 4662-4741.
  4. **Scelta premi**: lettura del barcode del premio (`Premi.Codice` o `CodOr`), con controllo della giacenza al netto dei premi già scelti negli altri riquadri (`QuaPrePre`); il catalogo mostrato è filtrato sui punti disponibili, con sconto card (`PBonus`), promozioni per giorno e fascia oraria (`ScPromo`, `AddSP`, `PrNoSc`) e abbuono (`FForza`, `PercAbb`, `NTAbb`) [V] 4825-4858, 5640-5746, 5828-5859.
  5. **Modalità Easy** (`Easys`): al posto del catalogo l'operatore digita fino a 11 importi in punti (`NUM`, `AGGIU`, `CANCE`) [V] 4310-4495.
  6. **Fine** (`FINIT`, o rilettura della card del cliente): `DaPremi` [V] 5420-5638:
     - registra le consegne in `Vincite` (`AddVincita`, `Cons = 1`); in Easy una sola riga con codice `0000000000000` e costo = punti/100 [V] 5443, 5476;
     - decrementa `Premi.Quantita` usando `Premi.Locked = IdPost + 1 + indice` come semaforo, con attesa attiva [V] 5478-5494, 5545-5561;
     - con card: consuma i lotti del cliente (`TPagati`, `OperOut`, `DataOut`) e **sovrascrive** `Clienti.Tickets` con il residuo [V] 5497-5528;
     - senza card: stampa il "Buono Ritiro Premio", poi uno **scontrino di resto** (`MangiaT = 32`, `NonCont = 1`) per i punti avanzati e chiude gli scontrini usati (`TPagati = NumTickets`) [V] 5532-5634.
  7. **Scontrino totale** (`SCOTO`, solo senza card e con almeno due scontrini): chiude gli scontrini letti e ne stampa uno unico (`MangiaT = 16`) [V] 5916-5955.
  8. **Annulla** (`ABORT`) o nuova sessione: rilascia i lock `TPagati = −(IdPost+1+indice)` [V] 5387-5393.
- **Dati:** legge `Operatori`, `Clienti`, `Premi`, `Tickets`, `TicketsCan`; scrive `Tickets` (insert e update), `TicketsCan`, `Clienti.Tickets`, `Vincite`, `Premi.Quantita`, `Premi.Locked`.
- **Periferiche:** fino a quattro scanner seriali, stampante termica condivisa (`Form1.Stmp`), terzo monitor.
- **Senza rete:** come il resto di WinMT, dipende dal SQL Server di sala.
- **Peso: L** — concorrenza tra quattro sessioni nello stesso processo, lock nel DB, varianti con/senza card, Easy, promozioni.
- **Evidenze:** sopra. Per dismetterlo, vedi § 4.7.

### W05-05 Configurazione del sistema 4 utenti (`FrmSet4Usr`)

- **Attore e innesco:** amministratore, menu `MnuSet4Usr`, visibile solo con chiave 4 utenti [V] `Module6.bas:235`, `Form1.frm:10004-10013`.
- **Passi:** abilita il sistema (`Ab4Usr`), i singoli scanner (`AbBr0..3`) e le loro porte (`PBRm0..3`), il terzo monitor e la sua risoluzione (`AbMon3`, `Mon3H`, `Mon3V`), i dieci messaggi pubblicitari; l'**autodetect** scorre le porte COM del registro di Windows, esclude quelle già usate da mangia-ticket, scanner, lettore card e stampante, e riconosce gli scanner dalla risposta al comando di identificazione [V] `frmsetS4Usr.frm:789-879, 1075-1137`. Salva con `SaveSetPost` e scrive i messaggi in un **file locale** `MsgSco.bin` [V] 896-953.
- **Dati:** scrive `Setup` (colonne sopra, riga della postazione) e il file `MsgSco.bin`.
- **Peso: S** — configurazione.
- **Evidenze:** `frmsetS4Usr.frm:757-1137`.

### W05-06 Raccolta di carte collezionabili: lettura in cassa

- **Che cos'è:** non sono card di terzi né card di fidelizzazione. È una **promozione a carte collezionabili** (album): il cliente porta carte fisiche con barcode di una raccolta (Mistral, Willy Wonka, DC Comics); ogni carta vale punti e completare una **serie** dà un premio in punti. Le carte sono fisiche e riutilizzabili: la sala può "riabilitarle" (W05-08) [V] `CreaRaccolte.bas:3-170`, `RacCard.cls:90-117`.
- **Attore e innesco:** operatore; lettura del barcode della carta in `FrmCTickets` (cliente con card, W05-01) o in Form1 (senza card) [V] `FrmCTickets.frm:569-620`, `Form1.frm:14320-14360`.
- **Passi:**
  1. Riconosce la raccolta dal **prefisso di due caratteri** (`Setup.CodEcs` del record raccolta: `MS`, `WW`, `DC`) e verifica il **codice sala** nei caratteri 3-6 (`Setup.MisCode`); un codice diverso è una carta "non valida" (di un'altra sala) [V] `FrmCTickets.frm:571-583`.
  2. Inserisce la carta in `Mistral` (`CodCard` = barcode, `Serie` = ultimo carattere, `Sospeso = 1`, `IDPost = IdPost − 100`); se il codice c'è già la carta è "già letta" [V] 584-601, `ModAddNew.bas:422-444`.
  3. Calcola i punti: valore della carta (`T7`) più il valore di ogni serie (`T1`) che risulta completa con le carte lette nella sessione (`T2..T5` dicono quali carte compongono ciascuna serie) [V] `RacCard.cls:90-117`.
  4. Alla conferma: lotto `Tickets` (`MangiaT = 1`, `NRep = 1`, `T0 = 'prefisso|punti serie'`); intestato al cliente con card, oppure con `IdContatto = 0` e `TPagati = NumTickets` (consumato subito) senza card; `Mistral.Sospeso = 0`; contatori statistici aggiornati in file locali [V] `FrmCTickets.frm:1158-1165, 1208-1219`, `Form1.frm:6603-6621, 16694-16700`.
  5. All'annullamento cancella le carte sospese della postazione [V] `Form1.frm:17323-17341`.
- **Dati:** legge `Setup` (`IdPost > 110`); scrive `Mistral`, `Tickets`; contatori in `Documenti\<exe>\<prefisso>CCard.bin`, `CSerie.bin`, `CData.bin` [V] `RacCard.cls:193-286`.
- **Peso: M** — regole di serie, stato sospeso/confermato, contatori fuori DB.
- **Evidenze:** sopra.

### W05-07 Configurazione delle raccolte (`CreaRaccolte`, `frmCRCard`, `RacCard`)

- **Attore e innesco:** amministratore dal setup di sistema: abilitando `Mistral` viene chiamata `CreaMistral`; il pulsante dedicato apre `frmCRCard` [V] `frmsetSys.frm:7039-7040, 6891`.
- **Passi:**
  1. `CreaMistral` crea, se manca, il record `Setup` con `IdPost = 111` (raccolta Mistral: 7 carte M-I-S-T-R-A-L, una serie); se in quel record `F1` o `F2` è vero crea anche 112 (Willy Wonka, 10 carte) e 113 (DC Comics, 16 carte, tre serie: eroi, cattivi, tutti). Rinomina il reparto 2 in "Raccolta Carte" [V] `CreaRaccolte.bas:3-170`.
  2. `frmCRCard` carica le raccolte attive (`IdPost > 110 AND F0 = 1`) e permette di modificare valore delle carte e delle serie, che `RacCard` riscrive in `Setup.T7` e `Setup.T1` [V] `frmCRCard.frm:267-295, 412-446`, `RacCard.cls:321-345`.
- **Dati:** scrive `Setup` (record 111-113 e `NRep2` del 101).
- **Peso: M** — configurazione con struttura codificata in stringhe.
- **Evidenze:** sopra; codifica completa in § 3.

### W05-08 Riabilitazione delle carte raccolta (`FrmAbCard`)

- **Attore e innesco:** operatore, menu `MnuMistral` (per tutte le raccolte o per una) [V] `Form1.frm:9380-9420`.
- **Passi:** mostra le carte registrate in `Mistral`; leggendo una carta la cancella da `Mistral` (torna utilizzabile); "Riabilita TUTTE LE CARDS" cancella tutte le carte della raccolta [V] `FrmAbMis.frm:292-369`. Il nome interno della form è `FrmAbCard` mentre il file è `FrmAbMis.frm`.
- **Dati:** legge e cancella `Mistral`.
- **Peso: S**.
- **Evidenze:** sopra.

### W05-09 Scontrino manuale (`frmscontr`)

- **Attore e innesco:** operatore o supervisore; tasto F12 con Ctrl in Form1 (livello < 2, oppure `OpScoMan`) e altri punti della cassa [V] `Form1.frm:13241-13252`.
- **Passi:** se `PasswSM` chiede la password di un amministratore, manager o supervisore (o la super password), poi il numero di ticket e, se ammesso (`MMMSco` e livello), il numero di copie; controlla il limite `MaxSco` (`Setup.N5`); per ogni copia stampa lo scontrino con `StampaSco` e registra un lotto al portatore `MangiaT = 4` [V] `frmscontr.frm:649-705, 731-867`.
- **Uso secondario:** con `InsNum = True` la form fa da **tastierino numerico** e restituisce il valore negli appunti di Windows [V] 741-747.
- **Dati:** legge `Operatori` (password cifrata); scrive `Tickets`.
- **Periferiche:** stampante termica.
- **Peso: M** — autorizzazione, limiti, stampa e scrittura.
- **Evidenze:** sopra; credenziale di emergenza confrontata nel codice in `frmscontr.frm:789` (valore caricato da `Setup`, IdPost 110, con un default scritto nel codice in `Module1.bas:2712`).

### W05-10 Ticket da reparto (`FrmRepTick`)

- **Attore e innesco:** operatore abilitato, menu `mnureparti` [V] `Form1.frm:14111-14116`, `Module6.bas:236`.
- **Passi:** scelta del reparto tra `NRep2..NRep9` attivi (`ARep2..9`) e, per la "Raccolta Carte" con `Mistral`, della raccolta; numero di ticket entro `MaxSco`; senza cliente stampa uno scontrino "Reparto: …", con cliente usa un numero di serie calcolato; registra il lotto (`MangiaT = 4`, `NRep` = indice del reparto) e, con cliente, incrementa `Clienti.Tickets` (`AddTicCli`) [V] `FrmRepTick.frm:646-798, 823-858`, `ModAddNew.bas:923-945`.
- **Dati:** scrive `Tickets`, `Clienti.Tickets`, `Clienti.DataUltVis`.
- **Peso: M**.
- **Evidenze:** sopra.

### W05-11 Conteggio scontrini (`FrmCScon`)

- **Attore e innesco:** operatore, menu "Conteggio Scontrini" [V] `Form1.frm:9719-9724`.
- **Passi:** somma il valore degli scontrini letti, ignorando i doppioni; **nessun accesso al DB** [V] `FrmCScon.frm:82-119`.
- **Peso: S**.

### W05-12 Dettaglio di uno scontrino (`frmDScon`)

- **Attore e innesco:** operatore, menu "Dettagli Scontrino" [V] `Form1.frm:9726-9731`.
- **Passi:** legge il barcode, cerca la riga `Tickets` (serie e quantità, `Aux = 0`), decodifica origine e uso con `fn_decode_mt_bitmask`, il reparto da `Setup` 101, gli operatori di emissione e di utilizzo; se `DataOut` non è del 1899 mostra la data d'uso e lo **scopo**: "sommato", "caricato su card: cliente", oppure il premio pagato, cercato in `Vincite` per **data entro ±3 secondi** [V] `frmDScon.frm:474-567, 731-748`.
- **Dati:** legge `Tickets`, `Setup`, `Operatori`, `Vincite`.
- **Peso: S**.

### W05-13 Restituzione di un premio da cliente con card (`frmresauto`)

- **Attore e innesco:** operatore; "Restituzione Premi con Card" [V] `Form1.frm:14216`.
- **Passi:** lettura della card a barcode (`CD`/`JV`), elenco delle consegne del cliente (`Vincite`, `Cons = 1`); lettura del barcode del premio o doppio clic; alla conferma: lotto di **reso** `MangiaT = 8` con i punti del premio (in Golden diviso in Silver e Gold secondo `Vincite.N0`); `Premi.Quantita + 1` o, se l'articolo non esiste più, lo ricrea; riga in `Resi`; **cancella la riga `Vincite`**; sovrascrive `Clienti.Tickets`; con card ECL riscrive i punti sulla card. All'uscita forza `Clienti.Abilita = 1` [V] `frmresauto.frm:662-819, 915-939`.
- **Dati:** legge `Clienti`, `Vincite`, `Premi`; scrive `Tickets`, `Premi`, `Resi`, `Clienti.Tickets`, `Clienti.Abilita`; cancella `Vincite`.
- **Periferiche:** scanner, lettore ECL.
- **Peso: M**.

### W05-14 Restituzione di un premio senza card (`FrmResMan`)

- **Attore e innesco:** operatore; "Restituzione Premi senza Card".
- **Passi:** ricerca della consegna senza cliente (`Vincite.IdContatto = 0`, `Cons = 1`) per barcode, codice o descrizione; alla conferma stampa uno "Scontrino di Premio reso", registra il lotto al portatore `MangiaT = 8`, rimette il premio in giacenza (o lo ricrea), scrive `Resi` con `IdContatto = 0` e **cancella la riga `Vincite`** [V] `frmresman.frm:647-786, 872-909`.
- **Dati:** come W05-13, senza `Clienti`.
- **Periferiche:** scanner, stampante.
- **Peso: M**.

### W05-15 Partite con la "card resi" (`frmResiConCard`)

- **Attore e innesco:** report card, pulsante dedicato [V] `frmRappCard.frm:2237-2243`.
- **Passi:** elenca le operazioni sui giochi (`TransCard`, `WinMt = 0`, importo > 0) fatte con le card dei clienti chiamati **"resi resi"** (`Cognome = 'resi' AND Nome = 'resi'`) [V] `frmResiConCard.frm:141-172`. Lo stesso filtro compare nella cassa [V] `frmCassa.frm:2740`. È una card di servizio, presumibilmente usata dal personale per riprodurre o rimborsare partite [D].
- **Dati:** legge `TransCard`, `Clienti`, `EcsMacchine`.
- **Peso: S**.

### W05-16 Abbuono alla consegna dei premi

- **Attore e innesco:** operatore di cassa, durante la consegna premi in Form1, quando il cliente non ha punti sufficienti e `FForza` lo consente (W01-05).
- **Passi:** alla consegna registra in `Abbuoni` l'operatore, la data, i ticket mancanti e il loro valore monetario [V] `Form1.frm:6068, 6558`, `ModAddNew.bas:830-852`. Il limite è `NTAbb` ticket e `PercAbb` % del valore [V] `Frm4Usr.frm:5721-5727`. Lo stesso concetto esiste nel sistema 4 utenti, ma lì **non viene registrato** in `Abbuoni` (il catalogo include i premi raggiungibili con l'abbuono, `DaPremi` non scrive) [V] `Frm4Usr.frm:5420-5638`.
- **Dati:** scrive `Abbuoni`.
- **Peso: M** — regola economica; il calcolo è in Form1 (zona 01).

### W05-17 Riepilogo abbuoni per operatore (`frmopabb`)

- **Passi:** per ogni operatore somma `Abbuoni.Valore` (`Abbuoni.Id = Operatori.Id`) e stampa la "GIVEAWAY LIST" [V] `frmopabb.frm:148-221, 325-361`.
- **Peso: S**.

### W05-18 Riepilogo delle ricevute premi (`FrmRic`)

- **Che cos'è:** **non riguarda le ricariche**. Consulta `Vincite25`, le ricevute firmate dal cliente per i premi oltre la soglia `Pre25` (con dicitura sul trattamento dei dati personali), scritte da Form1 [V] `Form1.frm:6268-6304`.
- **Passi:** filtro per data, ricerca per barcode della ricevuta (8 caratteri, `hhmmss` + progressivo), stampa della "Lista Premi Consegnati" con valore = punti × 0,01, **cancellazione** di una ricevuta [V] `FrmRic.frm:529-719, 748-804`.
- **Dati:** legge e cancella `Vincite25`.
- **Peso: S**.

### W05-19 Ricalcolo massivo del prezzo in ticket dei premi (`FrmNTickMod`)

- **Attore e innesco:** gestione premi, pulsante "Modifica Numero Tickets" [V] `frmpremi.frm:4998-5001`.
- **Passi:** per i premi selezionati o per tutta la tabella, `N_Tickets = Costo × moltiplicatore`, con arrotondamento opzionale alla decina superiore [V] `FrmNTickMod.frm:219-258`.
- **Dati:** scrive `Premi.N_Tickets`.
- **Peso: S** (logicamente appartiene alla zona 06).

### W05-20 Ticket sospesi ("persi") (`frmTckPersi`)

- **Attore e innesco:** operatore, tasto F9 in Form1, solo con sistema ECL [V] `Form1.frm:13231-13235`.
- **Passi:** elenca, per cliente e macchina, i ticket ticketless ancora nel buffer (`CoinlessDataBuffer.tickets > 0`), cioè vinti sul gioco ma non ancora riportati in `Tickets` [V] `frmTckPersi.frm:245-270`. Sola consultazione: nessuna azione di recupero.
- **Dati:** legge `Clienti`, `CoinlessDataBuffer`, `EcsMacchine`.
- **Peso: S**.

### W05-21 Cancellazione archivi (`FrmCanArc`)

- **Attore e innesco:** **amministratore** (livello 0) e solo sulla postazione **Master** [V] `Module6.bas:203-224`; menu "Cancella Archivi" in Form1, che chiude Form1 e ferma MTLink prima di aprire la form [V] `Form1.frm:9435-9445`.
- **Cosa cancella**, nell'ordine di esecuzione (ogni blocco chiede conferma con il numero di righe, poi esegue un `DELETE` e scrive due righe nel log testuale) [V] `FrmCanArc.frm:715-1839`:

| # | Opzione | Istruzione eseguita | Evidenza |
|---|---------|---------------------|----------|
| 1 | "Cancella gli scontrini emessi fino al" | `DELETE Tickets WHERE Data <= data AND IdContatto = 0`; con "Cancella anche gli scontrini dei Clienti con CARD" **senza** il filtro sul cliente, quindi anche i lotti di punti non ancora spesi | 718-796 |
| 2 | (eseguita solo con la 1, con la data della 3 se selezionata) | `DELETE TicketsCan WHERE Data <= data` | 798-852 |
| 3 | "Cancella gli scontrini utilizzati fino al" | `DELETE Tickets WHERE Data <= data AND NumTickets = TPagati` | 867-916 |
| 4 | "Cancella TUTTI gli ABBUONI" | `DELETE Abbuoni` | 933-981 |
| 5 | "Elimina TUTTI gli articoli dal magazzino" | `DELETE Premi` | 997-1044 |
| 6 | "Cancella TUTTI i movimenti del magazzino" | `DELETE MovMag` e `DELETE MovOut` | 1060-1171 |
| 7 | "Cancella TUTTE le Prenotazioni e gli Ordini consegnati" | `DELETE Prenotaz WHERE Cons = 1` | 1187-1242 |
| 8 | "Cancella TUTTI i Fornitori" | `DELETE Fornitori` | 1257-1305 |
| 9 | "Cancella le Prenotazioni e gli Ordini effettuati prima del" | `DELETE Prenotaz WHERE Data <= data` (anche non consegnate) | 1320-1375 |
| 10 | "Cancella TUTTI gli articoli con QUANTITA' = 0" | `DELETE Premi WHERE Quantita <= 0` | 1391-1439 |
| 11 | "Cancella le vincite fino al" | `DELETE Vincite WHERE Data <= data` | 1455-1506 |
| 12 | "Cancella TUTTI i Premi RESI" | `DELETE Resi` | 1521-1569 |
| 13 | "Cancella TUTTE le RICEVUTE fino al" | `DELETE Vincite25 WHERE Data <= data` | 1584-1635 |
| 14 | "Cancella i Clienti assenti dal" | per ogni cliente con `DataUltVis <= data` e `IdContatto > 0`: `DELETE Tickets WHERE IdContatto = …` e cancellazione della riga `Clienti`. **Non** tocca `TransCard`, `Vincite`, `CoinlessCards`, `UID_Ammessi`, `Prenotaz` | 1651-1727 |
| 15 | "Cancella gli Incassi effettuati prima del" | `DELETE Incassi WHERE Data <= data` | 1743-1806 |

- **Archivia prima di cancellare? No.** La casella "Sposta i Records selezionati nell'Archivio Storico" (`ChkMove`) e i controlli dati `Storico` e `Stor2` esistono nel designer ma **non sono usati in nessuna riga di codice** [V] `FrmCanArc.frm:21-68, 518-553` (nessun riferimento in 655-1920). Non c'è backup, né transazione: ogni blocco è un `DELETE` autonomo. L'unica traccia è il log testuale della postazione (`[DELETE][PREV]` / `[DELETE][OK]`, con operatore, tabella, filtro e numero di righe).
- **Difetti:** `DecQPren` (decremento di `Premi.QPren` per le prenotazioni cancellate) usa una connessione mai aperta e ignora l'errore: le quantità prenotate **non vengono decrementate** [V] 1913-1920. Il messaggio di conferma dei blocchi conta le righe prima della cancellazione, non quelle effettivamente cancellate.
- **"Cambio gestione" non è una cancellazione.** È un'impostazione di sistema (`Setup.NewConc`, `Setup.IniConc` = data di inizio della nuova gestione) che nei rapporti separa i ticket pagati in base alla data di **emissione**, prima o dopo il cambio di gestore [V] `frmsetSys.frm:3025-3043, 7096-7100`, `FrmRappUs.frm:1922-1926`, `frmrapp.frm:2738-2742`. Serve a ripartire il debito in ticket tra vecchio e nuovo gestore [D].
- **Conseguenze per la sincronizzazione:** i `DELETE` sono intercettati dai trigger di Sync Framework e propagati al cloud (DB 06, § 2) [D].
- **Peso: L** — 15 operazioni distruttive su 13 tabelle, effetti sui saldi, sui dati di magazzino e sul cloud.

### W05-22 Pulizia dell'archivio ticket (`MnuPul`)

- **Attore e innesco:** amministratore sulla Master; menu "Pulizia archivio" (la form `FrmPul` è solo la barra di avanzamento).
- **Passi:** scorre **tutta** la tabella `Tickets` e cancella una per una le righe con `NumTickets = TPagati` [V] `Form1.frm:14118-14170`. Comprende quindi gli scontrini somma e convertiti e i lotti consumati dei clienti; non usa date.
- **Peso: S**. Già descritto come W01-23.

---

## 3. Significato delle colonne

### 3.1 `Tickets`

| Colonna | Significato | Valori e codifiche | Evidenza | |
|---------|-------------|--------------------|----------|---|
| `Tickets.IdContatto` | Titolare del lotto | 0 = scontrino al portatore (non ancora caricato su card); altrimenti cliente (`IdContatto`, o `IdLong` in multi-sala) | `FrmCTickets.frm:1123`; `Module8.bas:43` | V |
| `Tickets.NumTickets` | Quantità del lotto (ticket stampati o accreditati) | intero; il barcode ne porta 4 o 5 cifre | `Module8.bas:20-38` | V |
| `Tickets.Data` | Data di emissione del lotto | | `ModAddNew.bas:74` | V |
| `Tickets.MangiaT` | **Bitmask** di origine e storia | 1 contato da mangia-ticket Galileo (anche raccolte card e punti scaricati da card ECL); 2 esterno; 4 manuale; 6 = 2+4 convalidato; 8 reso; 16 somma; 32 resto; 64 bonus; 128 sommato in un totale; 256 caricato su card; 512 passato ad altra card; 1024 acquisito da altra card; 2048 (+8 = 2056) prenotazione cancellata; 4096 annullato dall'operatore; 8192 generato in app (ticketless ECL); 16384 conversione Silver↔Gold. Valori composti visti: 101 e 301 (solo in `TicketsCan`), 132 (manual tickets consumati senza card), 8256 (ticket automatici dal gioco). Decodifica SQL: `fn_decode_mt_bitmask` | `frmDScon.frm:622-670`; `Module1.bas:100-112`; `fn_decode_mt_bitmask.sql`; `Module6.bas:2047`; `scriviTicketsAutomatici.sql:52` | V |
| `Tickets.NumTrans` | Numero di serie dello scontrino | 9 cifre stampate dal mangia-ticket; per quelli della cassa `CalcSerNum` = ultima cifra dell'anno, poi `00000001` + secondi dall'1/1: unico solo al secondo e si ripete ogni 10 anni | `Module6.bas:887-903, 105-112` | V |
| `Tickets.TPagati` | Ticket già spesi del lotto, **oppure lock** | `0..NumTickets`; `−IdPost` = bloccato da una postazione di cassa; `−(IdPost+1+n)` = bloccato dal riquadro n del sistema 4 utenti. Il secondo schema può coincidere con il lock di un'altra postazione (es. IdPost 101, riquadro 0 = −102 = postazione 102) | `Module8.bas:86, 102`; `Frm4Usr.frm:4713`; `Module1.bas:148-149` | V |
| `Tickets.DataOut` | Data dell'ultimo **uso** del lotto: consumo (anche parziale), somma, **oppure caricamento su card** | **`1899-12-30` = mai usato**: è la data zero di VB6, scritta da `AddScon` quando il parametro opzionale non è passato (tutte le emissioni della cassa); `NULL` per le righe create dalle procedure SQL; `frmDScon` tratta l'anno 1899 come "non utilizzato". **Risponde alla domanda di DB 03, § 7** | `ModAddNew.bas:61, 78`; `frmDScon.frm:527`; `Module1.bas:152` | V |
| `Tickets.Oper` | Operatore che ha emesso il lotto | `Operatori.Id`; 0 per le righe delle procedure SQL; nel 4 utenti l'operatore del riquadro | `ModAddNew.bas:79`; `Frm4Usr.frm:4609` | V |
| `Tickets.OperOut` | Operatore dell'ultimo uso (consumo o caricamento su card) | | `FrmCTickets.frm:1128`; `Form1.frm:16641` | V |
| `Tickets.NonCont` | "Non contato": escluso dai conteggi dei ticket vinti | 1 per resto, totale, acquisiti, Silver↔Gold, annullati, bonus della ricarica; 0 per contati, esterni, manuali, resi, bonus 24 ore e nuova card (il bonus dipende dal punto di emissione) | `FrmDeCli.frm:4292`; `Module6.bas:1719-1724`; `Module1.bas:119` | V |
| `Tickets.Id` | Dispositivo o postazione di origine | numero del mangia-ticket per gli scontrini Galileo (< 100); `IdPost` della postazione per le emissioni di cassa; 1 per manual tickets e procedure SQL; 0 per gli scontrini da ticket station e convalidati caricati su card (intento dichiarato: prime 4 cifre della serie); 0 = escluso dalle statistiche per mangia-ticket | `ModAddNew.bas:82`; `FrmCTickets.frm:1136-1142`; `FrmRappUs.frm:1809-1840` | V |
| `Tickets.Aux` | Conteggio dall'**ingresso ausiliario** del mangia-ticket | 1 = escluso da saldi e scontrini; i report lo sommano come "Aux"/gettoni. Tutte le scritture di WinMT mettono 0 | `Module6.bas:1726`; `frmrapp.frm:5976, 6033`; `FrmRappUs.frm:1781` (commento) | D |
| `Tickets.NRep` | Reparto del lotto | 0 = "Redemption"; 1..8 = n-esimo reparto **non vuoto** fra `Setup.NRep2..NRep9` (riga 101); 1 per manual tickets e raccolte card; i report usano `NRep And 15` | `frmDScon.frm:574-577`; `FrmRepTick.frm:765-773`; `Module6.bas:1739` | V |
| `Tickets.NImp` | Numero d'impianto della sala | `valsets.Nimp` (196 a Central Park) in **tutte** le scritture di WinMT; **0 nelle righe inserite dalle procedure SQL e dallo scrittore esterno dei ticketless**. Il terzo di righe con 0 in produzione non è quindi un errore di dati ma il segno dell'origine "dal gioco". Risponde in parte a DB 05, § 6 | `ModAddNew.bas:85`; `scriviTicketsAutomatici.sql:52`; `scriviTicketsDaCoinless.sql:17` | V (WinMT, SP) / D (resto) |
| `Tickets.F0` | Direzione dello scambio multi-sala | 1 = punti ricevuti (`rExtra`), 0 = punti pagati (`pExtra`), quando `N0 > 0` | `Module6.bas:1725-1735` | D |
| `Tickets.N0` | Sala che ha consumato i punti (multi-sala) | `idSites` | `Module1.bas:156`; `Module6.bas:1732` | V |
| `Tickets.T0` | Etichetta del lotto | `'MANUAL TICKETS'` (manual tickets non ancora assegnati); `'prefisso|punti serie'` per le raccolte (es. `MS|0`); altrimenti `NULL` | `ModAddNew.bas:1074`; `FrmCTickets.frm:1162` | V |
| `Tickets.D0` | Lotto **Gold** (modalità Golden) | non nullo = punti Gold; nullo = Silver | `ModAddNew.bas:87`; `Form1.frm:17201, 17221` | V |
| `Tickets.F1`, `T1` | Ticket **ticketless** generato da un gioco ECL | `T1` = `EcsMacchine.device` (fino a 7 caratteri in produzione), `F1 = 1`. Nessuna riga del VB scrive `F1`/`T1` di `Tickets`; le procedure SQL di test li lasciano a 0/NULL. Lo scrittore è esterno a WinMT (servizio di sala .NET?) | `FrmDeCli.frm:5042, 5175`; `frmrapp.frm:6146` | V (lettura) / D (scrittore) |
| `Tickets.N1`, `D1` | Non usati | | ricerca nel sorgente | V |

### 3.2 Altre tabelle della zona

| Colonna | Significato | Valori e codifiche | Evidenza | |
|---------|-------------|--------------------|----------|---|
| `TicketsCan.*` | **Scontrini cartacei già trasformati in punti**, per impedirne il riuso | `IdContatto` sempre 0; `NumTickets`, `NumTrans` = quantità e serie dello scontrino; `Data` = emissione originale se nota, altrimenti data del caricamento; `MangiaT` = bitmask dello scontrino (con 256) oppure 101 (caricato su card) o 301 (da ticket station caricato su card); `TPagati` 0 | `ModAddNew.bas:743-768`; `FrmCTickets.frm:1129, 1146-1151`; `Frm4Usr.frm:4708` | V |
| `TicketsCan.DataCan` | Data di annullamento prevista ma mai valorizzata | sempre `NULL` (il codice scrive `Null` ignorando il parametro) | `ModAddNew.bas:757` | V |
| `TickRep.*` | Ticket assegnati a un cliente da un reparto (versione precedente di `FrmRepTick`) | `IdOperatore`, `IdCliente`, `NumTickets`, `NRep`, `Data`. **Nessuno chiama `AddTickRep`**: le 232 righe di produzione sono storiche | `ModAddNew.bas:397-420` | V (assenza) / D (significato) |
| `Scocard.*` | **Riusata come avviso sul cliente** | `IdContatto` = `IdLong`, `F0 = 1` avviso attivo, `T0` testo, `Data` ultima modifica; scritta da `frmModCli` su tutte le sale collegate, azzerata da `frmAlertClienti`; le altre colonne (copiate da `Tickets`) non sono usate | `frmModCli.frm:2310-2390`; `Form1.frm:17538-17564`; `Remote/frmAlertClienti.frm:164` | V |
| `Mistral.CodCard` | Barcode completo della carta raccolta (PK) | 10-11 caratteri: prefisso raccolta (2), codice sala (4), progressivo, carattere della carta | `ModAddNew.bas:430`; `FrmCTickets.frm:571-590` | V |
| `Mistral.Serie` | Carattere che identifica **quale carta** della raccolta (posizione in `Setup.SyncRes`), non la serie | | `RacCard.cls:119-122` | V |
| `Mistral.Sospeso` | Stato della lettura | 1 = letta in una sessione aperta, 0 = confermata | `FrmCTickets.frm:1209-1215`; `Form1.frm:17331` | V |
| `Mistral.IDPost` | Postazione che l'ha letta | `IdPost − 100` (1..10) | `FrmCTickets.frm:591` | V |
| `Mistral.F0..D0` | Non usati | | | V |
| `Resi.*` | **Premio restituito dal cliente** (non reso a fornitore) | `IdContatto` cliente o 0; `Codice`, `Descrizione`, `Costo`, `N_Tickets`, `Fornitore` copiati dalla consegna; `Data`; `Id` = **operatore**; nessun riferimento alla consegna, che viene cancellata | `ModAddNew.bas:99-125`; `frmresauto.frm:803-804` | V |
| `Abbuoni.Id` | Operatore che ha concesso l'abbuono | `Operatori.Id` | `frmopabb.frm:334` | V |
| `Abbuoni.Tickets`, `Valore`, `Data` | Ticket mancanti abbuonati, loro valore in euro, data | `Valore` in euro (vedi W01-05 per la formula) | `ModAddNew.bas:830-852` | V |
| `Vincite25.*` | Ricevuta firmata per premi oltre `Pre25` | `BarCode` = `hhmmss` + progressivo; `N_Tickets` punti; nome e cognome copiati. Indice **univoco** su `Codice` (DB 02): la seconda consegna dello stesso articolo violerebbe il vincolo | `Form1.frm:6277, 6292`; `FrmRic.frm:557` | V (codice) / D (effetto dell'indice) |
| `Vincite.N0` | Punti Gold usati per il premio (Golden) | | `frmresauto.frm:789-790` | V |
| `TransCard.NImp` | **Tipo di operazione** (non impianto) | 0 carico in cassa; 1 carico da totem; 2 cassa mobile; 3 scarico su totem; 4 hopper vuoto; 5 dobloni Astoria / gettoni Albarella / rimborso gettoni; 6 bonus; 7 svuotamento cassa; 8 rimborso; 9 omaggio; 10 crediti ceduti; 11 crediti acquisiti; 12 rimborso operatore; 13 compleanno; 14 online; 15 storno; 16 bonus acquisiti; 18 abbonamenti; 19 riallineamento | `ModAddNew.bas:1091-1110`; `FrmCCard.frm:2846-2891` | V |

### 3.3 `Setup`: raccolte card (`IdPost > 110`) e opzioni della zona

| Colonna | Significato | Valori e codifiche | Evidenza | |
|---------|-------------|--------------------|----------|---|
| `Setup.IDPost` (111, 112, 113…) | Un record per raccolta | 111 Mistral, 112 Willy Wonka, 113 DC Comics | `CreaRaccolte.bas:16, 84, 132` | V |
| `Setup.F0` (raccolta) | Raccolta attiva | 1 | `frmCRCard.frm:422` | V |
| `Setup.F1`, `F2` (111) | Abilitano la creazione di Willy Wonka e DC Comics | | `CreaRaccolte.bas:58-59` | V |
| `Setup.CodEcs` (raccolta) | **Prefisso di due caratteri** del barcode | `MS`, `WW`, `DC` | `RacCard.cls:58` | V |
| `Setup.T0` (raccolta) | Nome della raccolta | | `RacCard.cls:59` | V |
| `Setup.SyncRes` (raccolta) | **Riusata**: alfabeto dei caratteri che identificano le carte | `MISTRAL`, `0123456789`, `0123456789ABCDEF` | `RacCard.cls:57, 119-122` | V |
| `Setup.T7` (raccolta) | Valore in punti di ciascuna carta | `v1|v2|…` | `RacCard.cls:55, 321-332` | V |
| `Setup.NRep2..NRep9` (raccolta) | **Riusate**: nomi delle carte, concatenati | `nome|nome|…` spezzato su più colonne | `RacCard.cls:70` | V |
| `Setup.T1` (raccolta) | Valore in punti di ciascuna serie completata | `v1|v2|…` | `RacCard.cls:56` | V |
| `Setup.T6` (raccolta) | Nomi delle serie | | `RacCard.cls:69` | V |
| `Setup.T2..T5` (raccolta) | Matrice di appartenenza carta-serie | flag `0|1` per carta, una serie dopo l'altra, concatenati | `RacCard.cls:75-82`; `CreaRaccolte.bas:156-158` | V |
| `Setup.Mistral`, `MisCode` (101) | Raccolte attive; codice sala nel barcode (car. 3-6) | | `Module1.bas:2119-2120`; `FrmCTickets.frm:572` | V |
| `Setup.MisVCard`, `MisVSerie` (101) | Valori di default di carta e serie alla creazione | default 50 e 650 | `CreaRaccolte.bas:24-42` | V |
| `Setup.MisVCard`, `MisVSerie` (102) | **Riusate**: parametri di conversione Gold↔Silver | | `Module1.bas:161-162` | V (commento) |
| `Setup.MisData`, `MisCard`, `MisSerie` | Contatori di una versione precedente; oggi i contatori sono in file locali | | `Module1.bas:445`; `Form1.frm:16807-16818` (commentato) | D |
| `Setup.Ab4Usr`, `AbBr0..3`, `PBRm0..3` | Sistema 4 utenti attivo; scanner abilitati e loro porte COM | | `frmsetS4Usr.frm:896-919`; `Module1.bas:2102-2106` | V |
| `Setup.AbMon3`, `Mon3H`, `Mon3V` | Terzo monitor e risoluzione | `Mon3H` è **riusata** come valore di dobloni/gettoni (× 100) nelle sale Astoria/Albarella | `frmsetS4Usr.frm:910-916`; `FrmCCardAlba.frm:2974`; `Module1.bas:433, 2591` | V |
| `Setup.N14` (101) | Personalizzazione nascosta `HiddenOpt` | 0 normale, 1 Astoria, 2 Albarella, 3 Golden | `Module1.bas:168-173, 2658` | V |
| `Setup.N5` (101) | Limite di ticket per scontrini manuali e da reparto (`MaxSco`) | 0 = nessun limite | `Module1.bas:71, 2641` | V |
| `Setup.N8` | Ritardo di riattivazione dello scanner (`BCDelay`, ms) | | `Module1.bas:2656` | V |
| `Setup.MdbSaveInt` | **Riusata** come `MolPun`: punti mostrati e stampati = ticket × `MolPun` (la funzione "1 ticket = punti" del manuale) | 1..100 | `Module1.bas:2070-2072`; `Module6.bas:55` | V |
| `Setup.AutoConv` | Convalida automatica di scontrini sconosciuti | | `FrmCTickets.frm:756`; `Frm4Usr.frm:4655` | V |
| `Setup.TicStat`, `TSSNum0..9` | Accettazione di scontrini di ticket station esterne e prefissi registrati | | `Module8.bas:45`; `Frm4Usr.frm:5074-5085` | V |
| `Setup.OpScoMan`, `PasswSM`, `MMMSco` | Scontrino manuale per l'operatore; con password; più copie | | `frmscontr.frm:668-696` | V |
| `Setup.FT24H`, `NT24H`, `TmOpen` | Bonus 24 ore: ticket regalati e soglia, dall'orario di apertura | | `Module6.bas:860-885` | V |
| `Setup.NewConc`, `IniConc` | Cambio gestione e sua data | | `frmsetSys.frm:7096-7100` | V |
| `Setup.FForza`, `PercAbb`, `NTAbb` | Abbuono consentito, percentuale e massimo | | `Frm4Usr.frm:5721-5727` | V |
| `setup2` (101) `ImportoRicariche`, `IsRimborsoGettoni`, `BirthdayFreeCharge` | Tagli rapidi di ricarica (JSON `num0..num4`); rimborso gettoni (JSON `ValoregettoneDaRimborsare`); ricarica compleanno dal cassiere | | `FrmCCard.frm:1751, 4680, 2179` | V |

---

## 4. Regole, calcoli e comportamenti notevoli

1. **Il saldo punti è doppio.** `Clienti.Tickets` è un totale aggiornato in molti punti con logiche diverse: **sovrascritto** con un valore calcolato in memoria (`SettaPuntiCard` in W05-01, W05-13; `DaPremi` in W05-04), incrementato (`AddTicCli`, `Frm4Usr`), ricalcolato da `Tickets` solo in alcuni momenti (`RicalTCli`, W01-02). Accanto c'è la card ECL, su cui la variante Albarella e il reso scrivono i punti. Il nuovo modello deve avere un solo registro dei movimenti di punti e un saldo derivato.
2. **Formati del barcode dello scontrino** [V] `Module8.bas:20-38`, `FrmCTickets.frm:712-723`, `Frm4Usr.frm:4571-4629`:
   - inizia con `1`, 16 caratteri: Galileo / Galileo PRO, serie 9 cifre (car. 2-10), ticket 5 cifre (11-15), controllo;
   - inizia con `1`, 14 caratteri: vecchi EL2000 / MT6, serie 7, ticket 4;
   - inizia con altro (esterno): Deltronic, ticket station, Galileo non connesso; ammesso solo con `TicStat` e prefisso in `TSSNum`;
   - controllo modulo 10 nel sistema 4 utenti [V] `Frm4Usr.frm:4573` (e in Form1, W01-04), assente in `FrmCTickets`;
   - `TK#####KT`: manual tickets; `XX`+codice sala…: carta raccolta.
3. **Lock nel DB:** lo scontrino letto è "occupato" con un valore negativo in `TPagati` fino a conferma o annullamento; se la postazione si blocca, il lock resta (Form1 li rilascia all'annullamento: W01-11). Nel nuovo sistema servono prenotazioni con scadenza o transazioni lato server.
4. **Bonus 24 ore** [V] `Module6.bas:860-885`: se `FT24H > 0`, somma i ticket del cliente emessi da `TmOpen` di oggi; se prima del nuovo carico erano ≤ `NT24H` e dopo sono ≥ `NT24H`, regala `FT24H` ticket (lotto `MangiaT = 64`).
5. **Raccolte card** [V] `RacCard.cls:90-117`: punti = valore della carta + per ogni serie, se tutte le carte che la compongono sono state lette almeno una volta in più rispetto alle serie già pagate nella sessione, il valore della serie. I contatori storici di carte e serie sono **in file binari locali della postazione**, sommati a quelli di un'applicazione `WinMtSM` se presente [V] 193-286: non sono nel DB e non risalgono al cloud.
6. **Nessuno scontrino fiscale.** `frmscontr` stampa scontrini di ticket, `FrmCScon` li conta, `frmDScon` li decodifica; `FrmCCard` stampa la copia della ricevuta del POS ("ARRIVEDERCI E GRAZIE"); Form1 stampa "Buono Ritiro Premio" e la ricevuta `Vincite25` con firma e consenso privacy. La ricarica in contanti non produce alcun documento fiscale nel codice di questa zona [V] `FrmCCard.frm:3448-3800`, `Module6.bas:49-130`.
7. **Per dismettere il sistema 4 utenti** bisogna sapere che:
   - è legato a una **chiave di licenza** specifica e a un **terzo monitor** con pubblicità locale (`3rdScreenPics`, `MsgSco.bin`);
   - funziona solo con **card a barcode** (`Clienti.CodBar`), non con card ECL: non legge né scrive la card RFID;
   - replica in modo indipendente consegna premi, scontrino di resto e totale, promozioni e sconti, ma **non** registra gli abbuoni e non aggiorna i movimenti di magazzino (`MovOut`): decrementa direttamente `Premi.Quantita`;
   - usa codici di lock (`TPagati`, `Premi.Locked`) che possono collidere con quelli delle postazioni normali;
   - lascia tracce riconoscibili: `Tickets.Oper` = operatori del banco, `TPagati` negativi da −102 in giù, `Vincite` con `Descrizione = 'Easy Mode'` se in modalità Easy.
   - Verifica consigliata prima di dismetterlo: `Setup.Ab4Usr` su tutte le sale e tipo di chiave installata.
8. **Variante Albarella:** è un fork vecchio di `FrmCTickets` + `FrmCCard`, scelto da un'opzione nascosta. Il carico gettoni (`TransCard.NImp = 5`) è oggi coperto in `FrmCCard` dal "rimborso gettoni" configurabile, che usa lo stesso codice operazione [V] `FrmCCard.frm:2886`. Le differenze di sicurezza (nessuna rilettura, nessun ripristino) la rendono da non replicare.
9. **Reso premio:** il reso cancella la consegna (`Vincite`) e crea un lotto di ticket; la riga `Resi` non è collegata né alla consegna né al lotto.
10. **Legami senza chiave:** lo scontrino usato per pagare un premio si ricollega alla consegna solo per **coincidenza di orario entro 3 secondi** [V] `frmDScon.frm:738`.

---

## 5. Problemi rilevanti per il nuovo disegno

1. **`Tickets` è quattro entità in una** (scontrino al portatore, lotto di punti del cliente, lock, portafoglio Silver/Gold) e la sua storia è codificata in una bitmask (`MangiaT`) aggiornata in place. Il nuovo modello dovrebbe separare almeno: *voucher cartaceo* (con stato), *movimento punti* (registro immutabile), *prenotazione/lock* con scadenza.
2. **Saldo punti non derivato** (§ 4.1): sovrascritture con valori calcolati in memoria su `Clienti.Tickets`, più la card. Rischio di perdita di punti con postazioni concorrenti.
3. **Cancellazioni senza archivio** (W05-21, W05-22): l'opzione di archiviazione non è implementata; i `DELETE` arrivano al cloud. Con l'opzione "anche i clienti con card" si cancellano **lotti di punti non spesi**, e il saldo ricalcolato del cliente cambia. Per la migrazione, lo storico di `Tickets`, `Vincite`, `Resi`, `Incassi` di una sala può essere incompleto in modo non documentato; il log testuale delle postazioni è l'unica traccia.
4. **Numeri di serie non univoci**: `CalcSerNum` è unico solo al secondo e si ripete ogni dieci anni; due postazioni nello stesso secondo generano lo stesso `NumTrans`.
5. **Origini dei dati fuori da WinMT**: gli scontrini del mangia-ticket e i ticket ticketless con `F1`/`T1` sono scritti da componenti esterni (con `NImp = 0`). Il nuovo sistema deve avere un'unica API per l'emissione di ticket da dispositivi.
6. **Configurazione codificata in colonne riusate** (`Setup.SyncRes`, `NRep2..9`, `T1..T7`, `MdbSaveInt`, `Mon3H`, `MisVCard` su 102; `Scocard` per gli avvisi). Le raccolte card sono un'entità propria (raccolta, carta, serie, composizione) e il dizionario `Setup_Descriptions` copre solo in parte questi riusi.
7. **Stato in file locali delle postazioni:** contatori delle raccolte, messaggi pubblicitari, log delle cancellazioni.
8. **Personalizzazioni nel codice** (Albarella, Astoria, Golden, 4 utenti, Easy): vanno trasformate in moduli o configurazioni, oppure dismesse consapevolmente.
9. **Difetti da non riprodurre:** `DecQPren` senza connessione [V] `FrmCanArc.frm:1913-1920`; `scriviTicketsDaCoinless` scrive il numero di serie in `MangiaT` (colonne sfasate), che con `decimal(5,0)` andrebbe in overflow: la procedura è probabilmente inutilizzata [V] `scriviTicketsDaCoinless.sql:16-17`; `FrmRic` usa `CDate(...)` dentro l'SQL, sintassi Access non valida su SQL Server, quindi il filtro per date non funziona [V] `FrmRic.frm:568`; in `DaPremi` senza card il ciclo usa un indice mai aggiornato (`I`) e consegna più volte lo stesso premio [V] `Frm4Usr.frm:5535-5561`; in `RacCard` l'offset della matrice delle serie usa `UBound` invece del numero di carte [D] `RacCard.cls:78`.

---

## 6. Domande aperte per il team

1. Quale componente scrive in `Tickets` le righe dei **mangia-ticket Galileo** (`MangiaT = 1`, `IdContatto = 0`) e quelle **ticketless** con `F1 = 1`, `T1 = device`, `NImp = 0` (275.637 in produzione)? Il servizio di sala .NET? Query di verifica: distribuzione di `MangiaT`, `Id`, `NImp`, `F1` per anno.
2. Il saldo autorevole dei punti è `Clienti.Tickets`, la somma di `Tickets` o la card? Nelle sale ECL la card contiene ancora i punti?
3. Le sale usano ancora **Albarella**, **Astoria** o **Golden** (`Setup.N14`)? E il **sistema 4 utenti** (`Ab4Usr`, chiave "4 Users")? Se sì, dove?
4. Le **raccolte card** (Mistral, Willy Wonka, DC Comics) sono ancora attive? Ne servono altre, e vanno gestite centralmente (codice sala nel barcode)?
5. "Cancella Archivi" è stata usata dai clienti? La cancellazione del 22/05/2026 nel DB di test (DB 04) corrisponde a queste opzioni? Esiste da qualche parte un archivio storico esterno?
6. La ricevuta `Vincite25` (premi oltre 25 €, con firma e consenso privacy) risponde a un obbligo normativo? L'indice univoco su `Codice` è voluto?
7. Che cos'è la **card "resi resi"** e chi la usa?
8. `TickRep` (232 righe, nessuno scrittore) e `TicketsCan.DataCan` (mai valorizzata) si possono ignorare nella migrazione?
9. Il **cambio gestione** deve esistere anche nel nuovo sistema (ripartizione del debito in ticket tra gestori)?
10. Lo scontrino manuale e il ticket da reparto richiedono un'autorizzazione più forte (oggi: password o super password di emergenza)?
