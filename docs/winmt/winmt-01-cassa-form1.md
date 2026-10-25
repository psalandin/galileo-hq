# Galileo HQ — WinMT 01: La form principale (cassa e banco)

**Stato:** bozza · **Responsabile:** Piero · **Aggiornato:** 2026-10-23

**Fonte:** sorgente VB6 di WinMT (copia del 24/07/2026), file: `Form1.frm`; seguiti in parte `ModAddNew.bas`, `Module6.bas`, `Module8.bas`, `Module1.bas` (commenti di testata), `ModuleMultilocale.bas`, `ECL_command.cls`, `frmCassa.frm`, `FrmCCard.frm`, `Frm4Usr.frm` · **Collegati:** `winmt-00-mappa.md`, `winmt-02` (moduli comuni), `winmt-03` (clienti e card), `winmt-04` (ECL e pagamenti), `winmt-05` (ticket e scontrini), `winmt-06` (premi e magazzino), `docs/db/db-02-catalogo.md`, `docs/db/db-06-produzione-02.md`, `docs/db/db-07-confronto-test-produzione.md`

Legenda: **[V]** verificato nel codice, con riferimento `file:riga`; **[D]** dedotto, da confermare. I riferimenti senza nome di file si intendono a `Form1.frm`.

---

## 1. Perimetro

| File | Righe di codice | Ruolo | Lettura |
|------|----------------:|-------|---------|
| `Form1.frm` | 11.273 (297 procedure, ~18.400 righe con il designer) | Form principale: banco premi, presa in carico della card, scontrini, consegna premi, prenotazioni, gestione clienti, menu verso tutte le altre funzioni, timer di servizio | A fondo le procedure con accesso ai dati; scorse quelle di sola interfaccia (scroll, colori, traduzioni, tastiera virtuale) |
| `ModAddNew.bas` | — | Inserimenti: `AddVincita`, `AddScon` (Tickets), `AddPrenot`, `AddAbbuono`, `AddVin25`, `AddTransCard`, `ManualTicket`, `AddSconCan` | Solo le funzioni chiamate da Form1 |
| `Module6.bas` | — | `SettaPuntiCard`, `TogliPunti`, `VerificaCard`, `MettiInBlackList`, `StampaSco`, `CalcSerNum`, `LockPrize`, `StampaCassa`, `AbilitaCard` | Solo le funzioni chiamate da Form1 |
| `Module8.bas` | — | `TrovaSco` (validazione scontrino), `TrovaPremio` | Solo queste due |
| `Module1.bas` | — | Commenti di testata che documentano `Setup`, `Tickets.MangiaT`, `TransCard`, cassa (righe 1–160) | Solo i commenti e il caricamento di `Golden` |
| `frmCassa.frm`, `FrmCCard.frm`, `Frm4Usr.frm` | — | Azzeramento cassa, ricarica, sistema 4 utenti | Solo i punti che chiariscono le domande di questa zona; l'analisi completa è nelle zone 04 e 05 |

**Mappa controllo dati → tabella** (designer di `Form1.frm`). Tutti i controlli puntano allo stesso database `WinMtSqlDB` (stringhe `CsMtconc1` e `CsPremi`, identiche) [V] `Module1.bas:969-971`.

| Controllo ADODC | Tabella | `RecordSource` iniziale | Uso principale |
|-----------------|---------|-------------------------|----------------|
| `Giocatori` | `Clienti` | `select * from Clienti where IdContatto=-1` (13394) | Cliente corrente, griglia clienti `DataGrid1Cli` |
| `Tickets` | `Tickets` | `select top 10 * from Tickets` (13410) | Scontrini letti, chiusura scontrini |
| `TicCan` | `TicketsCan` | vuoto; solo collegato (13387) | Usato da `Frm4Usr` e `FrmCCardAlba`, non da Form1 |
| `VinciteAdo` | `Vincite` | `select top 1 * from Vincite` (13391) | Solo `Refresh` (vedi § 5, difetto) |
| `Vin25` | `Vincite25` | `select * from Vincite25` (5862, 6415) | Ricevute premi di valore |
| `Premi` | `Premi` | costruito da `SqlPremi` (5489) | Griglia premi `GrdVPremi` |
| `Prenotaz` | `Prenotaz` | variabile (6447, 14719, 17038–17082) | Prenotazioni e ordini |
| `Abbuoni` | `Abbuoni` | `select * from abbuoni` (593) | Solo collegato; le scritture passano da `AddAbbuono` |
| `Mistral` | `Mistral` | `select * from Mistral where sospeso=1 and idpost=…` | Raccolte card |
| `Inc` | `Incassi` | `select top 10 * from Incassi order by data desc` (8166) | Solo avviso "incassi non registrati" |
| `Operatori` | `Operatori` | `select * from Operatori where Attivo=1` (13397) | Login con card o barcode |

Periferiche gestite direttamente da Form1: lettore RFID ECL su seriale (`TagR`, messaggi JSON), scanner barcode (`BarRd`), lettore di banda magnetica (`CardRd`), stampante termica ESC/POS (`Stmp`) [V] 5311-5314, 18179-18399. Il secondo monitor rivolto al cliente è la form `cliente`.

---

## 2. Flussi

### W01-01 Avvio della postazione e login operatore

- **Attore e innesco:** operatore; apertura di WinMT (`Form_Load`), poi passaggio della propria card RFID, del barcode operatore o della card magnetica.
- **Passi:**
  1. `Form_Load` apre le seriali, collega gli ADODC, carica le raccolte card (`SetRacCard`) e imposta il menu secondo `CodEcs` (ECL o no), `Golden`, `Easys`, `Ab4Usr` [V] 13265-13825.
  2. Solo sulla postazione master (`IdPost = 101`) e con modulo privacy attivo: `UPDATE clienti SET F0=0 WHERE D0 < getdate()`, cioè disattiva le tessere scadute [V] 13308-13319.
  3. Login: la card RFID è cercata in `Operatori.T0` [V] 11372-11405; il barcode in `Operatori.CodBar` [V] 14428-14453; la banda magnetica con `Id` + data di creazione confrontata con `Operatori.Data` [V] 12542-12575.
  4. Se il barcode appartiene a un operatore **disattivato**, `AbilitaOperatore` lo riattiva (`Attivo = 1`) e lo fa entrare [V] 14455-14467, 17233-17250.
  5. Con gestione cassa attiva (`GCassa`) il login passa da `frmLogin1`, che mostra e fa confermare il fondo cassa `VCassa` [V] 11389-11400.
- **Dati:** legge `Operatori` (`T0`, `CodBar`, `Data`, `Livello`, `Attivo`), `Setup`; scrive `Clienti.F0` (master), `Operatori.Attivo`.
- **Regole:** livello operatore `LvLx = Livello And 3` da card RFID, `Livello` intero da barcode e banda magnetica (incoerente) [V] 11384, 14434, 12555. `LvLx < 2` abilita avvisi e funzioni di gestione [V] 8157-8162.
- **Periferiche:** lettore RFID, scanner, lettore magnetico.
- **Peso: M** — più canali di login, effetti collaterali su `Clienti` e `Operatori`.
- **Evidenze:** `Form_Load` 13265; `TagR_OnComm` 11372; `BarRd_OnComm` 14428; `Decodifica` 12502.

### W01-02 Card RFID "in canna": lettura e presa in carico del cliente

- **Attore e innesco:** operatore di cassa; il cliente appoggia la card ECL sul lettore. Il lettore invia `card_set`, Form1 risponde con il comando di lettura, poi riceve `Val_card` con UID, crediti, bonus, ticket, progressivo e livello [V] 10830-10836, 11070-11088.
- **Passi:**
  1. Copia i dati letti nell'oggetto `form1CardInCanna` (`mettiCardInCanna`) [V] 18091-18102.
  2. Card promozionale Gold con promozione scaduta, o card "VIP" (compleanno) con evento scaduto: riscrive il livello sulla card e aggiorna il cliente [V] 11097-11132.
  3. Cerca il cliente con `Clienti.T0 = UID` (esclusi i "cancellati") [V] 11136. Promozione VIP secondo `VipPromotionModel` (quattro modelli: dati personali, sottoscrizione con canone, utilizzo continuativo, soglia minima) con eventuale riscrittura di livello e saldo [V] 11141-11231.
  4. Controlli bloccanti: cliente non trovato (mostra lo storico sostituzioni), `Abilita = 0` ("Cliente in uso"), tessera scaduta (`AbPrv` e `F0 = 0`), `T1` valorizzato (blacklist), card incoerente (W01-14) [V] 11527-11686.
  5. Ricalcola i ticket: in mono-sala `Clienti.Tickets = RicalTCli` se diverso; in multi-sala apre `FrmRicalc`, che ricalcola su tutte le sale collegate (solo se la sincronizzazione è attiva) [V] 11711-11737.
  6. **Blocca il cliente**: `UPDATE clienti SET abilita=0, dataultvis=getdate()` (`DisabilitaCliente`) [V] 11739, 17252-17279.
  7. Bonus 24 ore se dovuto (W01-17) [V] 11743-11755.
  8. Se la card contiene ticket (giocati in modalità ticketless): crea una riga `Tickets` (`MangiaT = 1`), aggiorna `Clienti.Tickets` e riscrive sulla card il totale con `Add_Punti`; alla conferma `Write_Ok` registra un'altra riga e rilegge [V] 11773-11795, 10940-10950.
  9. Se `Clienti.N1 > 0` (crediti sospesi da totem) avvia W01-13 [V] 11797-11804.
  10. Mostra saldo crediti (`(crediti+bonus) × CentConversionFactor`), ticket × `MolPun`, livello (`P`, `G`, `S`, `B`), filtra i premi raggiungibili (`SqlPremi`), cancella le raccolte sospese, apre le prenotazioni consegnabili (`GesOrdPren`) [V] 11806-11848.
- **Dati:** legge `Clienti`, `Tickets`, `TransCard`, `Prenotaz`, `Premi`, `promozioni`/`promozioni_cards` e `Compleanni` (tramite classi); scrive `Clienti.Abilita`, `DataUltVis`, `Tickets`, `TipoCard`; `Tickets` (insert); `Prenotaz.IdOpCo`.
- **Regole:** il cliente resta bloccato (`Abilita = 0`) per tutta l'operazione; lo sblocco avviene in `CmdAnn` (W01-11). Se la card viene tolta (`No_Card`) l'operazione è annullata [V] 10842-10913.
- **Periferiche:** lettore RFID ECL (seriale, protocollo JSON), secondo monitor.
- **Senza rete:** la lettura richiede il DB; senza DB la form è disabilitata (W01-20).
- **Peso: L** — macchina a stati sul lettore, molte varianti (promozioni, compleanni, conversioni, clonazioni), scritture su card e DB non transazionali.
- **Evidenze:** `TagR_OnComm` 10585-11866; `mettiCardInCanna` 18091; `DisabilitaCliente` 17252.

### W01-03 Identificazione del cliente con barcode, banda magnetica o codice

- **Attore e innesco:** operatore; lettura del barcode della tessera (prefisso `CD` o `JV`, almeno 11 caratteri), passaggio della card magnetica, oppure digitazione dell'ID e pulsante di ricerca.
- **Passi:** cerca `Clienti` per `CodBar` con `abilita=1` [V] 14578; per banda magnetica estrae `IdContatto` e data di creazione e la confronta con `Clienti.Data` [V] 12538-12620; per ID usa `IdContatto` o `IdLong` [V] 8502-8508. Poi `SettaCliente`: tessera scaduta, ricalcolo `Tickets` e `Bonus` (punti Gold), blocco `Abilita = 0`, bonus 24 ore, avvisi `Scocard` (W01-21), prenotazioni [V] 17604-17751.
- **Dati:** come W01-02, senza `TransCard`.
- **Peso: M** — tre canali, stessa logica di presa in carico.
- **Evidenze:** `BarRd_OnComm` 14395-14714; `Decodifica` 12502; `CmdMCli_Click` 8491; `SettaCliente` 17604.

### W01-04 Lettura e accumulo di scontrini cartacei e codici speciali

- **Attore e innesco:** operatore; lettura con lo scanner (o inserimento manuale di serie e importo) di scontrini stampati da mangia-ticket, giochi o dalla cassa stessa. Senza cliente o con cliente.
- **Passi:**
  1. Scontrino valido (controllo modulo 10, lunghezza 14 o 16): `TrovaSco` lo cerca in `Tickets` (`NumTrans`, `NumTickets`, `IdContatto = 0`, `TPagati = 0`, `Aux = 0`) e lo **blocca sulla postazione** scrivendo `TPagati = −IdPost` [V] 14781-14845, `Module8.bas:2-123`.
  2. Formati: prima cifra `1` = scontrino interno (vecchio EL2000/MT6 a 14 caratteri, Galileo a 16); altrimenti scontrino esterno (Galileo non connesso, Deltronic, ticket station). Se `TicStat` è attivo, lo scontrino esterno sconosciuto viene **creato** in `Tickets` (`MangiaT = 6`) [V] `Module8.bas:19-60`.
  3. Esiti: 3 annullato (previsto ma non implementato, vedi § 5), 4 inesistente, 5 già usato, 7 inserimento fallito, 8 scontrino Gold (modalità Golden) [V] 14846-14912.
  4. Limite `MaxPremioSco` sul totale accumulato con scontrini [V] 14796-14808.
  5. Inserimento manuale di serie e importo (`CmdAddMan`) con lo stesso blocco [V] 8235-8349.
  6. Codice `TK#####KT` (*manual tickets*): crea una riga `Tickets` con `T0 = 'MANUAL TICKETS'`, `MangiaT = 4`, bloccata sulla postazione [V] 14767-14773, `ModAddNew.bas:1054-1080`.
  7. Card di raccolta (prefisso della raccolta, 10–11 caratteri): inserisce in `Mistral` con `Sospeso = 1` e somma i punti della carta e dell'eventuale serie completa [V] 14323-14386.
  8. Comandi a barcode `NUM0x`, `CONFE`, `CANCE` (quantità, conferma, annulla) [V] 14300-14322.
  9. Ogni scontrino accettato si somma al totale (`SommaPunti`) [V] 17149-17171.
- **Dati:** legge e scrive `Tickets` (`TPagati`), inserisce `Tickets`, `Mistral`.
- **Regole:** il blocco `TPagati < 0` è un *lock* applicativo: il valore è il numero di postazione; il sistema 4 utenti usa `−(IdPost + 1 + n)` [V] `Frm4Usr.frm:4713`. Se la sessione si interrompe senza `CmdAnn` il lock resta.
- **Periferiche:** scanner barcode (con accensione e spegnimento del laser), secondo monitor.
- **Peso: L** — molti formati e varianti, lock su DB, raccolte card.
- **Evidenze:** `BarRd_OnComm` 14232-14993; `TrovaSco` `Module8.bas:2`; `CmdAddMan_Click` 8235.

### W01-05 Selezione dei premi al banco

- **Attore e innesco:** operatore; doppio clic sulla griglia premi o lettura del barcode del premio, dopo aver accumulato punti (card o scontrini).
- **Passi:**
  1. `SqlPremi` mostra solo i premi del banco (`Gru = 0`), attivi (salvo `VinPrInatt`), disponibili (`Quantita − QPren > 0`, salvo `VisP0`) e raggiungibili con i punti residui, applicando sconti e promozioni [V] 5489-5719.
  2. Al doppio clic: verifica giacenza (con `VisP0` si può andare sotto zero previa conferma), blocca il premio (`Premi.Locked = IdPost`), calcola i ticket spesi con lo sconto, verifica la copertura, **decrementa subito `Premi.Quantita`** e sblocca [V] 15442-15786.
  3. Punti insufficienti: con `Fforza` attivo l'operatore può **abbuonare** la differenza entro `NTAbb` ticket; il valore monetario dell'abbuono è `Costo / NTickets × ticket mancanti` [V] 15583-15691, 15720-15723.
  4. Annullamento di una riga (`CmdCanc`): restituisce la quantità a `Premi` e i punti al residuo [V] 14995-15143.
- **Regole di prezzo** (`N_Tickets` = prezzo pieno):
  - senza card: prezzo pieno; in promozione `N_Tickets × (100 − ScPromo)%`;
  - con card: sconto fedeltà `PBonus`%; in promozione `ScPromo` e `PBonus` si sommano (`AddSP`) o vale solo la promozione (`PrNoSc`);
  - promozione attiva se `AbPr`, giorno della settimana abilitato (`ScLun…ScDom`), fascia oraria `OraPIni–OraPEnd` e periodo `DataPIni–DataPEnd` [V] 5510-5593.
  - Modalità **Golden**: premi con `Costo ≤ Pre25` pagabili con punti Silver e Gold, premi più costosi solo con punti Gold [V] 5680-5695, 15574-15579, 15725-15746.
- **Dati:** legge `Premi`; scrive `Premi.Quantita`, `Premi.Locked`.
- **Peso: L** — regole di prezzo con molte varianti, lock e modifica della giacenza prima della conferma.
- **Evidenze:** `SqlPremi` 5489; `grdvpremi_DblClick` 15442; `CmdCanc_Click` 14995; `LockPrize` `Module6.bas:1446`.

### W01-06 Consegna premi a un cliente con card (`PremiAuto`)

- **Attore e innesco:** operatore; pulsante "SCARICA PREMI" (`cmdOk`) con un cliente in carico [V] 15145-15157.
- **Passi:**
  1. **Multi-sala con sincronizzazione attiva:** chiama sul server cloud `sp_last_trans`; se la card è stata usata "troppo di recente in un altro locale del gruppo" blocca l'operazione [V] 5822-5842.
  2. Calcola i punti mancanti in sala (`PuntiM`, `PGldManc`) e, se servono, li preleva dalle altre sale con `sp_preleva_punti` / `sp_preleva_punti_gold` sul cloud (intervallo massimo `Setup(101).N0 × 2 + 60` s); se il prelievo fallisce annulla tutto [V] 5867-6064. Le due procedure non sono nel DB di sala.
  3. Registra l'abbuono, se c'è (`AddAbbuono`) [V] 6068.
  4. Per ogni pezzo inserisce una riga `Vincite` (`Cons = Not Pren`, `D0 = Data` se consegnato) [V] 6126-6142.
  5. Consegna: `CheckRiserva` avvisa se la giacenza scende sotto `Riserva` [V] 6143-6144, 17107. Prenotazione: vedi W01-09.
  6. Scala i punti: `TogliPunti` consuma le righe `Tickets` del cliente in ordine di data (FIFO) portando `TPagati` a `NumTickets` e valorizzando `OperOut`, `DataOut`; in Golden `TogliPuntiGS` consuma prima i lotti Silver (`D0 IS NULL`) e poi i Gold [V] 6168, `Module6.bas:1877-1960`.
  7. Riscrive il saldo: `Clienti.Tickets = resto` (e in Golden `Clienti.Bonus = Gold/100`), `DataUltVis = getdate()` [V] 6206-6210, `Module6.bas:1822-1875`.
  8. Stampa il "Buono ritiro premi" se `FPpremio` e il premio vale almeno `NtickRic` ticket [V] 6153-6158, 6169-6199.
  9. Premi di valore (`Ric25`, costo oltre `Pre25`): stampa una ricevuta con dati del cliente, firma e consenso privacy e un barcode `hhmmss`+n, e la registra in `Vincite25` [V] 6240-6306.
  10. Per card ticketless riscrive sulla card il nuovo totale ticket (`Add_Punti`) [V] 6344.
  11. Chiude con `CmdAnn` (W01-11); con `OpALOff` l'operatore viene disconnesso dopo ogni consegna [V] 15167-15169.
- **Dati:** scrive `Vincite`, `Vincite25`, `Abbuoni`, `Prenotaz`, `Premi.QPren`, `Tickets` (`TPagati`, `OperOut`, `DataOut`), `Clienti` (`Tickets`, `Bonus`, `DataUltVis`, eventualmente `Nome`/`Cognome` digitati per la ricevuta); legge `Premi`, `Setup`; DB cloud.
- **Regole:** `Vincite.N_Tickets` è il prezzo **effettivamente pagato** per pezzo, dopo sconti. Nessuna transazione DB: le scritture sono una sequenza di connessioni separate.
- **Periferiche:** stampante, lettore RFID (riscrittura ticket), server cloud.
- **Senza rete verso il cloud:** se la sincronizzazione non è attiva (`CSync = False`) non tenta il prelievo remoto, ricalcola i ticket locali e, se non bastano, annulla i premi scelti [V] 6053-6066.
- **Peso: L** — transazione distribuita sala–cloud, FIFO sui lotti di ticket, stampe, varianti Golden/prenotazione.
- **Evidenze:** `PremiAuto` 5782-6357; `AddVincita` `ModAddNew.bas:29`; `TogliPunti` `Module6.bas:1877`.

### W01-07 Consegna premi senza card (`PremiManu`)

- **Attore e innesco:** operatore; "SCARICA PREMI" con soli scontrini (cliente 0).
- **Passi:**
  1. Righe `Vincite` con `IdContatto = 0`, una per pezzo, `N_Tickets` = prezzo applicato [V] 6423-6432.
  2. Stampa del buono, abbuono come in W01-06 [V] 6494-6559.
  3. Se resta un credito di ticket stampa uno **scontrino di resto** e lo registra in `Tickets` (`MangiaT = 32`, `NonCont = 1`, `Id = IdPost`) [V] 6561-6571.
  4. Chiude gli scontrini usati: `TPagati = NumTickets`, `OperOut`, `DataOut` [V] 6588-6601; marca come usati i *manual tickets* (`MangiaT = 132`) [V] 6602, `Module6.bas:2041-2050`.
  5. Raccolte card: crea una riga `Tickets` già consumata per i punti delle raccolte (`MangiaT = 1`, `T0 = prefisso|punti serie`) e conferma le carte in `Mistral` (`Sospeso = 0`) [V] 6603-6621.
  6. Ricevuta `Vincite25` come in W01-06, chiedendo nome e cognome [V] 6622-6670.
- **Dati:** scrive `Vincite`, `Vincite25`, `Abbuoni`, `Tickets`, `Mistral`, `Prenotaz`, `Premi.QPren`.
- **Peso: L** — chiusura multipla di scontrini, resto, raccolte, stampe.
- **Evidenze:** `PremiManu` 6359-6691.

### W01-08 Scontrino totale

- **Attore e innesco:** operatore; pulsante "Scontrino Totale" (o F8) con più scontrini letti e nessun premio scelto.
- **Passi:** annulla gli scontrini letti (`TPagati = NumTickets`, `MangiaT = MangiaT Or 128`), stampa un nuovo scontrino con il totale e lo registra (`MangiaT = 16`, `NonCont = 1`) [V] 8606-8695.
- **Regole:** massimo 99.999 punti per scontrino [V] 8619-8629. Il numero di serie è `ultima cifra dell'anno × 10^8 + 1 + secondi dall'inizio dell'anno` [V] `Module6.bas:887-905`.
- **Peso: M** — più righe aggiornate e stampa.
- **Evidenze:** `CmdStpTot_Click` 8606; `StampaSco` `Module6.bas:49`.

### W01-09 Prenotazione di premi

- **Attore e innesco:** operatore; pulsante "PRENOTA PREMI" (`CmdPrPr`) prima di scegliere i premi; solo con card salvo `PreSco` (`Setup(101).N6`) [V] 8586-8604.
- **Passi:** la scelta non decrementa la giacenza; alla conferma crea `Vincite` con `Cons = 0`, incrementa `Premi.QPren`, inserisce `Prenotaz` con `Quantita` **negativa**, `Conf = 1`, `MsgInv = 1`, `SerNum` calcolato, e stampa uno scontrino di prenotazione con barcode `P` + `SerNum` in esadecimale + `R` [V] 6143-6152, 6441-6456, 15875-15922. Senza card chiede i dati del cliente (`FrmInDat`) e usa `IdOpCo = 5555` [V] 6446-6454.
- **Regole:** `SerNum = (IdPost − 100) × 100000001 + secondi da una data base`, ma la base è il 01/01/2008 con card e il 01/01/2014 senza [V] 6149, 6444.
- **Peso: M** — più tabelle, stampa, chiave calcolata.
- **Evidenze:** `PremiAuto` 6143; `PremiManu` 6441; `StampaPren` 15875; `AddPrenot` `ModAddNew.bas:854`.

### W01-10 Consegna di prenotazioni e ordini

- **Attore e innesco:** automatico alla presa in carico del cliente (`GesOrdPren`); lettura del barcode `P…R`; pulsante "Ordini da Totem" (`cmdKioskPO`).
- **Passi:**
  1. `GesOrdPren` azzera i marcatori temporanei (`IdOpCo < 0` → 0), poi per ogni riga del cliente con `Conf = 1`, `Cons = 0`, `Quantita > 0` confronta la giacenza con il totale richiesto e marca `IdOpCo = −2` (consegnabile) o `−1` (non consegnabile); se ce ne sono di consegnabili apre `FrmPreCon` [V] 17032-17087, 17360-17369.
  2. Barcode `P…R`: con `Quantita < 0` risponde "premio prenotato non ancora disponibile"; per gli ordini da totem (`IdOp` 1009–1018) con `F0 = 0` risponde "prenotazione non ancora pronta"; altrimenti apre `FrmPreCon` [V] 14716-14765.
  3. "Ordini da Totem": elenca i `Prenotaz` con `IdOp` 1009–1018, `F0 = 0`, da preparare [V] 7480-7497.
- **Dati:** legge e scrive `Prenotaz` (`IdOpCo`), legge `Premi`. La consegna vera e propria è in `FrmPreCon` (zona 06).
- **Peso: M** — regole di disponibilità, stati codificati.
- **Evidenze:** `GesOrdPren` 17032; `BarRd_OnComm` 14716; `cmdKioskPO_Click` 7480.

### W01-11 Annulla e rilascio della postazione (`CmdAnn`)

- **Attore e innesco:** operatore (pulsante "ANNULLA", rimozione della card, fine di ogni consegna).
- **Passi:** riabilita il cliente (`Abilita = 1`); se c'erano premi scelti e non consegnati **restituisce le quantità** a `Premi`; cancella i *manual tickets* sospesi; sblocca gli scontrini (`TPagati` da `−IdPost` a 0); elimina le carte raccolta sospese della postazione (`DELETE Mistral … sospeso=1`); azzera l'interfaccia [V] 15172-15440, 17323-17341.
- **Peso: M** — compensazione manuale di tutte le scritture provvisorie.
- **Evidenze:** `CmdAnn_Click` 15172; `ClearCard` 17323; `AbilitaCard` `Module6.bas:1772`.

### W01-12 Ricarica crediti, carico ticket, vendita gettoni, info POS (orchestrazione)

- **Attore e innesco:** operatore; pulsanti "CARICA CREDITI", "CARICA TICKETS", vendita gettoni, info POS, con card in canna.
- **Passi in Form1:** chiude le periferiche di Form1, apre la form specializzata, verifica che la card sia ancora sul lettore, al ritorno aggiorna il saldo mostrato o annulla se la card è stata rimossa [V] 7012-7138, 7286-7330, 7790-7823, 7666-7735, 7159-7250.
- **Cosa scrive la ricarica (in `FrmCCard`, zona 04/05):** `TransCard` con `NImp = 0` e `ValoreCassa = importo − quota POS`; `NImp = 6` per il bonus; `NImp = 8`, `9`, `5` per rimborso, omaggio, dobloni; aggiorna `valsets.VCassa` e `Clienti.Credito` [V] `FrmCCard.frm:2843-2892`, `ModAddNew.bas:1086-1140`.
- **Peso: M** — in Form1 solo orchestrazione; il peso vero è nelle zone 04 e 05.
- **Evidenze:** `cmdCarCred_Click` 7012; `CmdCCard_Click` 7286; `closeFrmCCard` 7159.

### W01-13 Accredito dei crediti sospesi da totem

- **Attore e innesco:** automatico, quando la card in canna ha `Clienti.N1 > 0` (timer `tmrPTotem`, 1 s).
- **Passi:** scrive sulla card `crediti = N1 mod 100000` e registra `TransCard` `NImp = 0`; se `N1 / 100000 > 0` scrive anche il bonus e registra `NImp = 6`; poi `Clienti.N1 = 0` [V] 15942-15984, 11797-11804.
- **Regole:** `N1` codifica due importi in un intero: crediti + bonus × 100.000.
- **Periferiche:** lettore RFID; avviso "NON RIMUOVERE LA CARD".
- **Peso: M** — scrittura su card e DB con stato intermedio.
- **Evidenze:** `tmrPTotem_Timer` 15942.

### W01-14 Verifica anti-clonazione e blacklist

- **Attore e innesco:** automatico a ogni lettura di card ECL.
- **Passi:**
  1. `VerificaCard` confronta saldo (`crediti + bonus`) e progressivo della card con l'ultima riga `TransCard` del cliente per `N0` (verificata, cioè con `FlagOpDaVerificare` vuoto, e assoluta) [V] `Module6.bas:2219-2350`.
  2. Esiti: card coerente; card da **riallineare** (riscritta dai dati di `TransCard`, W01-15); card **incoerente**. Una card oltre 400.000 cent di saldo è considerata da riallineare [V] `Module6.bas:2226-2234`.
  3. Card incoerente letta più di due volte di seguito: `Clienti.F1 = 0`, `T1 = "IdPost:postazione| |saldo card:… prog[…]"`, `D1 = getdate()`; insert in `CoinlessClonedCards` (`CodMac = 'WinMt'`) e `CoinlessLogEventiBlacklist`; invio della blacklist alle BE [V] `Module6.bas:2352-2385`.
  4. La procedura `BlackList` (oggi disattivata nel timer) inviava un'email all'amministratore (`Setup(101).T9`) e marcava `F1 = 1` come "già notificato" [V] 17371-17451, 16870-16877.
- **Dati:** legge `TransCard`; scrive `Clienti.F1/T1/D1`, `CoinlessClonedCards`, `CoinlessLogEventiBlacklist`.
- **Peso: L** — regola critica di integrità del valore, con stato fra letture successive (`LastClonedCard`).
- **Evidenze:** `TagR_OnComm` 11600-11700; `VerificaCard` `Module6.bas:2219`; `MettiInBlackList` `Module6.bas:2352`.

### W01-15 Conversione, rigenerazione e cambio livello della card ECL

- **Attore e innesco:** automatico, card illeggibile o di formato vecchio (`Ecl.status = 33`), card da riallineare, promozione o compleanno scaduti, promozione VIP.
- **Passi:** sequenza di comandi al lettore guidata da `StatoConversioneCard` (formattazione `Card_Init`, scrittura ticket, crediti e bonus, progressivo, flag `StartGame` per le card operatore, cambio livello) [V] 10649-10743. I valori da riscrivere vengono da `TransCard`:
  - `convertCardToV2`: crediti = Σ `ValoreOperazione` delle righe di cassa con `NImp` in (0, 1, 2, 11, 13, 14) meno le righe di gioco (`NImp` nullo) e i trasferimenti (10, 18); bonus = Σ righe con `NImp` in (6, 8, 9, 16) meno i bonus giocati e i trasferiti (15); se non tornano con l'ultimo saldo, regola di riparto in quattro casi [V] 17763-17926;
  - `rigeneraCard`: ultimo saldo da `TransCard`, progressivo spostato in avanti di 100, riga di riallineamento in `TransCard` (`RiallineaSaldoSuTranscard`) [V] 17927-17973.
  - La conversione da V1 imposta `Clienti.TipoCard = 2` (Silver) [V] 11010-11012.
- **Peso: L** — logica di ricostruzione del saldo, protocollo con la card, rischio economico.
- **Evidenze:** `TagR_OnComm` 10649-11069; `convertCardToV2` 17763; `rigeneraCard` 17927.

### W01-16 Gestione dei clienti dalla form principale

- **Attore e innesco:** operatore (F1 o pulsante "Clienti"): pannello `FrameClienti`.
- **Passi:** ricerca con debounce (nome, cognome, barcode, ID, cellulare), paginazione con `row_number()`, ordinamento per colonna; riscrittura o generazione card (`FrmGenCard`, con controllo `UID_Ammessi` e unicità del tag), unione card (`FrmUCard`/`FrmUCardECL`), somma punti delle card slave sulla master, modifica, cancellazione (`ECL_cliente.EliminaCliente`, che nella prassi rinomina in "cliente eliminato") [V] 6752-6815, 6933-6996, 7942-8021, 8738-8807, 8928-9111, 11406-11484.
- **Dati:** `Clienti` (tutte le anagrafiche, `T0`, `CodBar`, `IdMaster1/2`, `Abilita` come lock durante unione), `UID_Ammessi`.
- **Regole:** `IdMaster1/2 = IdContatto_master × 10000 + NImp` [V] 6978, 17095. Riscrittura di una card in blacklist solo per amministratore o manager [V] 8766-8776. Riscrittura bloccata se il server non lo permette (`canRebuildCard`) e avviso se ci sono macchine offline [V] 8739-8763.
- **Peso: M** — CRUD con regole; il dettaglio è nella zona 03.
- **Evidenze:** `CmdFind_Click` 7406; `cmdDeleteCli_Click` 8928; `Command2Cli_Click` 8738; `decodificacli` 12078.

### W01-17 Bonus 24 ore e bonus nuova card

- **Attore e innesco:** automatico alla presa in carico (bonus 24 ore) o alla creazione della card magnetica (bonus nuova card).
- **Regole:** bonus 24 ore di `FT24H` ticket se `NT24H = 0`, il cliente non ha ticket oggi (`AggOggi = 0`) e `DataUltVis` non è oggi; bonus nuova card `FTNew`. Riga `Tickets` con `MangiaT = 64` e aggiornamento `Clienti.Tickets` [V] 11743-11755, 17672-17682, 12196-12204, `Module1.bas:3440-3460`.
- **Peso: S** — regola semplice, una tabella.

### W01-18 Stampa del bilancio card

- **Attore e innesco:** operatore, "STAMPA BILANCIO" (o automatica dopo la consegna con `FPrCr`).
- **Passi:** stampa saldo crediti (dalla card) e punti (`RicalTCli` × `MolPun`) [V] 8351-8390, 6337-6339.
- **Peso: S.**

### W01-19 Chiusura della sessione operatore e stampa cassa

- **Attore e innesco:** operatore, pulsante di chiusura.
- **Passi:** con `SaveScan` scrive un file di testo locale con il numero di ticket scansionati nella sessione; con `GCassa` stampa la "chiusura di cassa", che contiene **solo** operatore, inizio e fine turno e il valore `VCassa`; torna al login [V] 8435-8477, `Module6.bas:2592-2640`.
- **Regole:** la chiusura del turno **non** scrive nulla nel DB. L'azzeramento della cassa è un'altra funzione (`frmCassa`, menu "Controllo Cassa"): `UPDATE TransCard SET D0 = GETDATE()` sui movimenti `WinMt = 1` aperti della postazione e una riga `NImp = 7` di svuotamento [V] `frmCassa.frm:3419-3456`.
- **Peso: S.**

### W01-20 Connessione al DB, server secondario e stato della sincronizzazione

- **Attore e innesco:** timer `TmrSync` ogni 3 s [V] designer 944-945.
- **Passi:**
  1. Prova la connessione con timeout di 1 s. Se fallisce nasconde Form1 e mostra "Connessione col Server interrotta, tentativo di riconnessione" finché non torna [V] 16018-16117.
  2. Se l'operatore conferma: senza server secondario WinMT **termina**; sul master propone il passaggio al server secondario; sulle altre postazioni cerca un nuovo server con un broadcast UDP (`ARQFIND ECLServer`) e, se lo trova, salva il nome nel registro e riparte [V] 16044-16099.
  3. Sincronizzazione cloud: se `Setup(110).D1` (ultimo sync) è più vecchio di `3 × N0` secondi invia un'email di servizio, al massimo una al giorno (`D3`) [V] 16121-16127.
  4. Multi-sala: `CSync = (ora − D1 ≤ N0 + 60 s)`; da `CSync` dipendono i prelievi remoti di punti (W01-06) e l'icona di stato [V] 16147-16174.
  5. Stato dei totem: un totem (`Setup.F1 = 1`, `IdPost > 101`) con `FForza = 1` è segnalato in errore [V] 16176-16190.
- **Senza connessione al DB:** la cassa è ferma (form nascosta o disabilitata, `CmdAnn` esce subito se `Connesso = False`) [V] 15211-15217. Non esiste una modalità offline.
- **Peso: M** — failover e discovery, regole di stato.
- **Evidenze:** `TmrSync_Timer` 16006-16211.

### W01-21 Avvisi periodici e all'apertura

- **Attore e innesco:** `Form_Activate`, timer `TmrSaveDb` ogni 60 s, presa in carico del cliente.
- **Regole:**
  - lista premi inviata da HQ non ancora caricata: `RiepInv` con `F0 = 1` e `D0` nullo [V] 8157-8161, 17173-17191;
  - incassi non registrati da più di 7 giorni (`RegInc`, ultimo `Incassi.Data`) [V] 8163-8182;
  - ordini da caricare via FTP (`FtpPOrd`) [V] 8183-8186;
  - esito dell'ultima sincronizzazione (`Setup.SyncRes` contiene "Failed"), numero di messaggi dell'app (`Setup.IncIva`), conteggio prenotazioni (`Quantita < 0`) e ordini (`Quantita > 0`) non consegnati [V] 16884-16926;
  - avviso sul cliente in multi-sala: `Scocard` con `IdContatto = IdLong`, `F0 = 1`, testo in `T0` [V] 17538-17564.
- **Peso: S.**

### W01-22 Ricalcolo dei ticket di tutti i clienti

- **Attore e innesco:** all'avvio se `AggTiCli`; in multi-sala previa conferma che tutte le sale siano chiuse (`FrmRicalc`).
- **Passi:** per ogni cliente `Clienti.Tickets = Σ(NumTickets − TPagati)` su `Tickets` con `Aux = 0`; le differenze vanno in un file di log locale [V] 16475-16566.
- **Peso: M** — operazione massiva, ferma MTLink.

### W01-23 Pulizia dell'archivio ticket

- **Attore e innesco:** menu Utilità › Pulizia archivio.
- **Passi:** cancella da `Tickets` tutte le righe con `NumTickets = TPagati`, cioè tutti gli scontrini e lotti già consumati [V] 14118-14171.
- **Peso: S** — ma distruttiva: cancella lo storico dei movimenti di punti (§ 5).

### W01-24 Creazione di card al banco: codici redeem e micrototem

- **Attore e innesco:** lettura di un QR `RD…` (15 caratteri) o pulsante del micrototem ("Giallone"), solo se è configurato `MICROTOTEM`.
- **Passi:** `cls_RedeemManager` verifica e prenota il codice, chiede il PIN, crea la card con livello, crediti, bonus e ticket del codice (`FrmCreaCardsBatch.generaSingolaCard`), conferma il riscatto e, per il livello compleanno, associa il cliente all'evento. Il micrototem crea una card Silver con i valori di `setup2` `DefaultNewPlayer` (JSON) [V] 7830-7939, 14388-14393.
- **Regole:** il ramo "ricarica" del redeem è vuoto (`azione = "rechage"`, refuso compreso) [V] 7877-7879.
- **Peso: M.**

### W01-25 Modalità Easy: scarico punti senza catalogo

- **Attore e innesco:** sale con `Easys`: l'operatore digita i valori dei premi sul tastierino.
- **Passi:** scala i ticket dal cliente (FIFO) o chiude gli scontrini, scrive `Vincite` con `Codice = '0000000000000'`, `Descrizione = 'Easy Mode'`, `Costo = punti / 100`, `N_Tickets = punti`; resto e raccolte come W01-07 [V] 16613-16764.
- **Peso: M.**

---

## 3. Significato delle colonne

| Tabella.Colonna | Significato | Valori / codifiche | Evidenza | |
|-----------------|-------------|--------------------|----------|---|
| `Clienti.IdContatto` | Numero della card/cliente in sala | 0 = cliente anonimo (scontrini); −1 usato per "nessun cliente" nelle query | 13394, 6430 | V |
| `Clienti.IdLong` | Identificativo multi-sala | `IdContatto × 10000 + NImp`; usato al posto di `IdContatto` in `Tickets`, `Vincite`, `Prenotaz`, `TransCard` quando la sala è in gruppo | 12200, `ModuleMultilocale.bas:2-17` | V |
| `Clienti.IdMaster1`, `IdMaster2` | Card master di una card slave | `IdContatto_master × 10000 + NImp` | 6978, 17095 | V |
| `Clienti.T0` | UID della card RFID | stringa esadecimale di 16 caratteri | 11136, `Module1.bas:19` | V |
| `Clienti.CodBar` | Barcode della tessera | prefissi `CD`, `JV` | 14395, 14578 | V |
| `Clienti.Data` | Data e ora di creazione della card | scritta anche sulla banda magnetica e usata per validarla | 12611-12614, 6697-6708 | V |
| `Clienti.Abilita` | **Lock**: cliente in uso su una postazione | 0 = in carico a una cassa o in unione card; 1 = libero | 11555-11576, 17261, `Module6.bas:1772` | V |
| `Clienti.Tickets` | Saldo punti Silver (copia) | ricalcolato da `Tickets` (`Σ NumTickets − TPagati`, `Aux = 0`, `D0 IS NULL`); in multi-sala somma di tutte le sale | 17193-17211, 17645-17651 | V |
| `Clienti.Bonus` | Saldo punti **Gold** / 100 (modalità Golden) | ricalcolato da `Tickets` con `D0 IS NOT NULL`; **non** è il bonus in crediti della card ECL | 17646-17649, `Module6.bas:1852-1875` | V |
| `Clienti.Credito` | Saldo crediti della card in cent | `ValoreFinale / CentConversionFactor` dell'ultima operazione di cassa; mostrato come `credito × CentConversionFactor` | `ModAddNew.bas:1135`, 5448 | V |
| `Clienti.TipoCard` | Livello card | 0 Platinum (P), 1 Gold (G), 2 Silver (S), 3 VIP/compleanno (B) | 11758-11771, 17732-17742 | V |
| `Clienti.N0` | Card **ticketless** | 0/1, passato alla card come `SetTckLess` | 7998, 15953, 17838, `ECL_command.cls:340-346` | V |
| `Clienti.N1` | Crediti sospesi da totem, da scrivere sulla card in cassa | `crediti + bonus × 100000` (cent); azzerato dopo l'accredito | 15952-15978 | V |
| `Clienti.F0` | Tessera valida (modulo privacy) | 0 = scaduta, rifiutata in cassa se `AbPrv` | 11578, 13314 | V |
| `Clienti.D0` | Data di scadenza della tessera | il master pone `F0 = 0` se `D0 < oggi`; durata in anni in `Setup(102).N1` | 13314, `Module1.bas:81-82`, `Module3.bas:237` | V |
| `Clienti.T1` | Motivo della blacklist | testo "IdPost:postazione\| \|saldo card:…" (WinMT) o dati macchina (trigger) | `Module6.bas:2361-2369`, 17391 | V |
| `Clienti.F1` | Blacklist notificata | 0 = appena messa in blacklist da WinMT; 1 = email inviata | `Module6.bas:2369`, 17390-17419 | V |
| `Clienti.D1` | Data di messa in blacklist | | `Module6.bas:2369` | V |
| `Clienti.DataUltVis` | Ultima visita | aggiornata a ogni presa in carico e scrittura punti; regola del bonus 24 ore | 17261, 11743 | V |
| `Clienti.IdTel`, `FirstLogin` | Destinatario dei messaggi push dell'app | push solo se `FirstLogin = 1` | 7737-7774 | V |
| `Clienti.Nome`, `Cognome` | Anagrafica | `'cliente'`/`'eliminato'` = cliente cancellato logicamente | 13291-13292 | V |
| `Tickets.IdContatto` | Titolare del lotto di punti | 0 = scontrino al portatore; altrimenti cliente (`IdLong` in multi-sala) | 8272, 11784 | V |
| `Tickets.NumTickets` | Valore del lotto | | | V |
| `Tickets.TPagati` | Punti già consumati del lotto, **oppure lock** | `0..NumTickets`; **negativo = scontrino bloccato dalla postazione** `−IdPost` (`−(IdPost+1+n)` nel sistema 4 utenti) | 8328, 15396-15403, `Module1.bas:148-149` | V |
| `Tickets.MangiaT` | Origine del lotto, **bitmask** | 1 contati da MT Galileo (usato anche per punti scaricati dalla card ECL e raccolte card); 2 esterni; 4 manuali; 8 resi; 16 somma (scontrino totale); 32 resto; 64 bonus; 128 sommato; 256 caricato su card; 512 passato ad altra card; 1024 acquisito; 2048 prenotazione cancellata. Valori visti in Form1: 1, 4, 6, 16, 32, 64, 132 | `Module1.bas:100-112`, 6570, 8647, 8660, 11747, 11784 | V |
| `Tickets.NumTrans` | Numero di serie dello scontrino | `CalcSerNum`: cifra finale dell'anno × 10^8 + 1 + secondi dall'inizio dell'anno | `Module6.bas:887-905` | V |
| `Tickets.Data` / `DataOut` / `Oper` / `OperOut` | Creazione e consumo del lotto, con operatori | | `Module6.bas:1877-1910` | V |
| `Tickets.NonCont` | Escluso dal conteggio "ticket di oggi" | 1 per resto, totale, scontrini da sistema 4 utenti | 6570, 8660, `Module1.bas:3448` | V |
| `Tickets.Id` | Postazione che ha creato il lotto (`IdPost`) | | 6570 | V |
| `Tickets.NRep` | Reparto | 1 per manuali e raccolte | 6606, `ModAddNew.bas:1072` | V |
| `Tickets.Aux` | Scontrino ausiliario, escluso da saldi | sempre 0 nelle scritture di Form1 | 17201 | V |
| `Tickets.T0` | Etichetta del lotto | `'MANUAL TICKETS'`; prefisso della raccolta, barra verticale, punti della serie | 17348, 6606 | V |
| `Tickets.D0` | Lotto **Gold** (modalità Golden) | non nullo = punti Gold | `ModAddNew.bas:87`, 17221 | V |
| `Tickets.N0` | Sala che ha consumato i punti (multi-sala) | | `Module1.bas:156` | D |
| `Vincite.IdContatto` | Cliente (0 = consegna su scontrini) | | 6430 | V |
| `Vincite.N_Tickets` | Ticket effettivamente pagati per **un** pezzo | dopo sconti; una riga per pezzo | 6111, 6126 | V |
| `Vincite.Costo`, `Fornitore`, `Descrizione` | Copia dei dati del premio al momento della vincita | Easy mode: `Costo = punti/100` | 6128, 16652 | V |
| `Vincite.Id` | Operatore | | `ModAddNew.bas:44` | V |
| `Vincite.Cons` | Consegnato | 1 = consegna immediata; 0 = premio prenotato | 6128, `ModAddNew.bas:46` | V |
| `Vincite.D0` | Data di consegna | valorizzata se `Cons = 1` | `ModAddNew.bas:48` | V |
| `Vincite.N0` | Punti Gold usati per il premio | in Golden: quota Gold usata come Silver, o tutto il valore se il premio costa più di `Pre25`; vedi § 5 | 6127-6139 | V |
| `Vincite.F0` | Sala in gruppo multi-sala | | `ModAddNew.bas:47` | V |
| `Vincite25.*` | **Ricevuta di consegna dei premi di valore** | scritta se `Ric25` e costo oltre `Pre25` (default 25 €): `N_Tickets` = punti, `Costo = punti/100` (non il costo), `BarCode = hhmmss+n` stampato, `Nome`/`Cognome` copiati | 6240-6306, `ModAddNew.bas:894`, `Module1.bas:313-314` | V |
| `Abbuoni.Id` | Operatore che concede l'abbuono | | 6068, `ModAddNew.bas:830` | V |
| `Abbuoni.Tickets` / `Valore` | Ticket mancanti abbuonati e loro valore monetario | `Valore = Costo/N_Tickets × Tickets` | 15720-15722 | V |
| `Prenotaz.Quantita` | Quantità e tipo | **< 0 prenotazione** (premio non ancora disponibile); **> 0 ordine** consegnabile quando c'è giacenza | 6150, 14722, 16920-16925 | V (tipo D) |
| `Prenotaz.IdOp` | Operatore che ha creato | 1009–1018 = totem (operatori ≥ 1000) | 7488, 14734, `Module1.bas:9` | V |
| `Prenotaz.IdOpCo` | Operatore di consegna, o marcatore temporaneo | −2 consegnabile, −1 non consegnabile (ricalcolati a ogni cliente); 5555 = prenotazione senza card | 17065-17070, 6446 | V |
| `Prenotaz.SerNum` | Codice dello scontrino di prenotazione | `(IdPost − 100) × 100000001 + secondi da data base`; barcode `P`+hex+`R` | 6149, 15903 | V |
| `Prenotaz.F0` | Ordine da totem preparato | 0 = da preparare | 7488, 14734 | V |
| `Prenotaz.F1` | Sala in gruppo multi-sala | | `ModAddNew.bas:882` | V |
| `Prenotaz.T0` | Numero d'ordine | | `ModAddNew.bas:881` | V |
| `Prenotaz.NomeC`, `CognomeC`, `Tel` | Copia dei dati del cliente | | `ModAddNew.bas:869-871` | V |
| `Premi.Quantita` | Giacenza | decrementata **alla scelta**, ripristinata all'annullamento | 15711, 15249 | V |
| `Premi.QPren` | Quantità prenotata | disponibile = `Quantita − QPren` | 17758, 5660 | V |
| `Premi.Locked` | Lock del record | `IdPost` della postazione che modifica la quantità; 0 libero | `Module6.bas:1446-1480` | V |
| `Premi.Riserva` | Scorta minima | avviso sotto soglia | 17107 | V |
| `Premi.Gru` | Premio di gru | il banco mostra solo `Gru = 0` | 5697 | V |
| `Premi.Costo` | Costo del premio | soglia `Pre25` per ricevuta e per premi Gold | 6127, 15575 | V |
| `Mistral.CodCard` / `Serie` / `Sospeso` / `IDPost` | Carta di una raccolta letta | `Sospeso = 1` in sessione aperta, 0 confermata; `IDPost = IdPost − 100` | 14348, 17331, `ModAddNew.bas:433` | V |
| `Scocard.F0`, `T0` | Avviso da mostrare all'operatore sul cliente (multi-sala) | `IdContatto = IdLong`, `F0 = 1`, testo in `T0` | 17546 | V |
| `Operatori.T0` | UID della card RFID dell'operatore | | 11373 | V |
| `Operatori.CodBar` | Barcode di login | | 14429 | V |
| `Operatori.Livello` | Ruolo | `And 3` → 0..3; `LvLx < 2` gestione, `LvLx = 0` superadmin report | 11384, 8149 | V (ruoli D) |
| `Operatori.F0` | Card operatore abilitata a far partire giochi gratis | `StartGame ON/OFF` | 10691-10697 | V |
| `Operatori.N0` | Abilitazione omaggi e rimborsi | | `Module6.bas:2650` | V |
| `Operatori.Data` | Creazione della card magnetica dell'operatore | | 12546 | V |
| `TransCard.NImp` | **Tipo di operazione** (non il numero di impianto) | 0 cassa fissa, 1 totem, 2 cassa mobile, 3 scarico al totem, 4 hopper vuoto, 5 dobloni/gettoni, 6 bonus, 7 svuotamento cassa, 8 rimborso, 9 omaggio, 10/11 crediti trasferiti/acquisiti, 12 crediti di servizio, 13 compleanni, 14 acquisti online, 15 storno, 16 bonus acquisiti, 18 abbonamenti, 19 riallineamento | `ModAddNew.bas:1091-1110` | V |
| `TransCard.CodMac` | Postazione (`computername`) per le operazioni di cassa e totem; `'SVUOTAMENTO'`; codice del gioco per le partite | | `ModAddNew.bas:1121`, `frmCassa.frm:3977` | V |
| `TransCard.WinMt` | Operazione di cassa o totem | 1 sempre da `AddTransCard`; 0 dal circuito dei giochi | `ModAddNew.bas:1127`, `Module1.bas:7-9` | V |
| `TransCard.Operatore` | Operatore | < 1000 postazione, ≥ 1000 totem | `Module1.bas:9` | V |
| `TransCard.T0` | Numero di impianto (sala), 4 cifre | | `ModAddNew.bas:1130` | V |
| `TransCard.F0` | Sala in gruppo multi-sala | | `ModAddNew.bas:1131` | V |
| `TransCard.N0` | Progressivo della card | | 15959, `Module6.bas:2250-2280` | V |
| `TransCard.D0` | **Data di azzeramento della cassa** che comprende il movimento | nullo = movimento non ancora azzerato | `frmCassa.frm:3419, 3450-3453` | V |
| `TransCard.ValoreCassa` | Contante incassato (importo meno quota POS) | somma dei `D0` nulli = contenuto della cassa | `FrmCCard.frm:2852`, `frmCassa.frm:3419` | V |
| `TransCard.ValoreFinale` | Saldo della card dopo l'operazione, in valuta | base di `VerificaCard` e della rigenerazione | `Module6.bas:2236-2300` | V |
| `TransCard.Data` | Data inserita come **testo** `dd/mm/yyyy hh:nn:ss` | dipende dalla lingua del login SQL | `ModAddNew.bas:1122` (formato data) | V |
| `Setup.Ric25`, `Pre25` | Ricevuta premi di valore e soglia | default 25 €; in Golden è anche la soglia Silver/Gold | `Module1.bas:313-314` | V |
| `Setup.PBonus`, `ScPromo`, `AbPr`, `ScLun…ScDom`, `OraPIni/End`, `DataPIni/End`, `AddSP`, `PrNoSc` | Sconto fedeltà e promozioni a calendario | percentuali | 5510-5593 | V |
| `Setup.AbBT`, `BTLun…BTDom`, `OraBIni/End`, `DataBIni/End` | Fascia "bonus" a calendario (solo avviso a video) | | 16570-16612 | V |
| `Setup.Fforza`, `NTAbb`, `PercAbb` | Abbuono: abilitazione, massimo ticket, percentuale | | 5619-5624, 15608 | V |
| `Setup.FT24H`, `NT24H`, `FTNew` | Bonus 24 ore e nuova card | | 11743, 12196 | V |
| `Setup.MdbSaveInt` | **Riusato** come `MolPun`, moltiplicatore ticket → punti mostrati | 1..100 | `Module1.bas:2070-2072` | V |
| `Setup.FPpremio`, `NtickRic` | Stampa del buono premio e soglia | | 6153 | V |
| `Setup.VisP0`, `VinPrInatt` | Vendita sotto giacenza; premi inattivi in lista | | 5642-5664, 15483 | V |
| `Setup.GCassa`, `VCassa` | Gestione cassa; fondo cassa della postazione | `VCassa` aggiornato dalle ricariche | `Module1.bas:5-6, 463-464` | V |
| `Setup.OpALOff` | Logout dopo ogni consegna | | 15168 | V |
| `Setup.Ab4Usr`, `AbBr0..3`, `PBRm0..3`, `AbMon3` | Sistema 4 operatori: abilitazione, scanner e porte, terzo monitor | | `Module1.bas:429-432` | V |
| `Setup.N14` | Personalizzazione nascosta `HiddenOpt` | 1 Astoria, 2 Alba, 3 Golden | `Module1.bas:2659, 2697-2705` | V |
| `Setup.IncIva` | **Riusato**: messaggi dell'app da leggere | | `Module1.bas:137-139`, 16897 | V |
| `Setup(101).T6` | Elenco sale collegate (`NetSites`) | non vuoto = multi-sala | `Module1.bas:63`, 17805 | V |
| `Setup(101).T9` | Email dell'amministratore | | 17429 | V |
| `Setup(101).N6` | Prenotazioni senza card | | `Module1.bas:72` | V |
| `Setup(102).N1`, `F0` | Durata della tessera in anni; modulo privacy | | `Module1.bas:81-82` | V |
| `Setup(110).D1`, `N0`, `D3` | Ultimo sync, intervallo in secondi, ultima email di errore sync | | 16123, 16152 | V |
| `Setup.F1`, `FForza` (righe > 101) | Postazione totem; totem in errore | | 16178 | V |
| `Setup.SyncRes` | Esito dell'ultima sincronizzazione | contiene "Failed" se fallita | 16892 | V |
| `RiepInv.F0`, `D0` | Lista premi inviata da HQ; data di caricamento | `F0 = 1`, `D0` nullo = da caricare | 17181, `Module1.bas:44-47` | V |
| `EcsMacchine.device_status` | Stato della BE | `'Offline'` blocca o avvisa la riscrittura card | 17460 | V |
| `NImp` (tutte le tabelle scritte da Form1 tranne `TransCard`) | Numero di impianto della sala (`valsets.Nimp`) | | 6128, 6570, 6150 | V |

Risposte a domande aperte dei documenti DB:
- `Clienti.N0` (DB 06, § 4): è il flag **ticketless**, non un livello.
- `TipoCard = 3` (DB 06, § 4): livello **VIP**, usato per le card compleanno (lettera "B").
- `Clienti.T0`: confermato UID della card; WinMT cerca sempre il cliente con `T0 = UID` (DB 06, § 3; DB 07, § 6.2).
- `NImp = 146/9997` in `TransCard` (DB 03, § 6): nelle righe di cassa `NImp` è il **tipo di operazione**; il numero di sala sta in `T0`. Il significato di `NImp` nelle righe di gioco (`WinMt = 0`) non è in questa zona.
- `TransCard.D0` con poche date distinte (DB 03): sono le date di **azzeramento cassa**, applicate in blocco.
- `TransCard` con `Operatore`, `D0`, `T0` valorizzati (DB 05): sono le righe scritte da `AddTransCard` (cassa e totem).
- `Vincite25` e `Pre25`/`Ric25` (DB 01, § 7): ricevute firmate dei premi oltre 25 €.

---

## 4. Regole, calcoli e comportamenti notevoli

1. **Il saldo punti non è un numero, è un insieme di lotti.** Ogni scontrino, bonus, resto, scarico da card è una riga `Tickets`; il consumo procede FIFO per data su `TPagati`. `Clienti.Tickets` è una copia ricalcolata a ogni lettura [V] `Module6.bas:1877-1910`, 17193. Il nuovo modello può scegliere un registro di movimenti con saldo derivato; se servono i lotti (scadenze, origine), vanno modellati esplicitamente.
2. **Tre saldi diversi convivono:** punti/ticket (`Tickets`, `Clienti.Tickets`), crediti e bonus ECL (card, `TransCard.ValoreFinale`, `Clienti.Credito`), punti Gold (`Tickets.D0`, `Clienti.Bonus`). Il nome `Bonus` in `Clienti` non indica il bonus in crediti.
3. **La card ECL è la fonte del saldo crediti in cassa**; il DB serve a verificarla. Le regole di coerenza (progressivo e saldo contro `TransCard`) e di riallineamento vanno riprodotte nel servizio, non nel client [V] `Module6.bas:2219`.
4. **Lock applicativi nel DB:** `Clienti.Abilita = 0`, `Tickets.TPagati = −IdPost`, `Premi.Locked = IdPost`, `Mistral.Sospeso = 1`. Servono a far lavorare più postazioni sugli stessi dati e vengono rilasciati da `CmdAnn`. Nel nuovo sistema vanno sostituiti da transazioni o prenotazioni con scadenza.
5. **Prezzo applicato e sconti:** sconto fedeltà `PBonus` solo con card, promozioni a calendario, abbuono controllato. Il prezzo pagato è salvato in `Vincite.N_Tickets` per pezzo.
6. **Scontrini stampati dalla cassa** (resto, totale, prenotazione): numero di serie derivato dall'ora, con collisioni possibili tra postazioni nello stesso secondo [D].
7. **Multi-sala:** i punti si spendono dove si trovano; i mancanti vengono "prelevati" con procedure sul cloud, con un controllo anti-uso simultaneo (`sp_last_trans`). Se il cloud non risponde, la sala usa solo i propri punti [V] 5822-6066.
8. **Ricevute dei premi di valore** con dati personali e firma: requisito probabilmente fiscale o normativo (commento "Prezzo da cui parte la registrazione fiscale") [V] `Module1.bas:314`.
9. **Personalizzazioni per cliente nel codice:** `Astoria`, `Alba`, `Golden` da `Setup.N14`, con rami dedicati in Form1 (`FrmCCardAlba`, doppio saldo Silver/Gold) [V] `Module1.bas:2697-2705`, 7043.
10. **Cassa:** il fondo cassa è un campo per postazione (`Setup.VCassa`) aggiornato in memoria dalle ricariche; la "chiusura cassa" stampata al logout non lascia traccia nel DB; l'azzeramento registra `TransCard.D0` e una riga `NImp = 7`.

---

## 5. Problemi rilevanti per il nuovo disegno

1. **Nessuna transazione.** Consegna premi, chiusura scontrini, riscrittura saldo e scrittura su card sono passi separati, ognuno con la propria connessione e `On Error Resume Next` in molti punti. Un errore a metà lascia dati incoerenti (premio registrato senza punti scalati, giacenza decrementata, lock non rilasciati).
2. **Giacenza modificata prima della conferma** (`Premi.Quantita` alla scelta, ripristino all'annullamento): una caduta della postazione lascia la giacenza sbagliata.
3. **Nessuna modalità offline:** senza DB la cassa si ferma o il programma termina [V] 16044-16047. Il requisito di funzionamento senza cloud è oggi soddisfatto solo perché il DB è in sala.
4. **Campi riusati con significati diversi:** `TransCard.NImp` (tipo operazione) contro `NImp` altrove (sala); `Setup.MdbSaveInt` = moltiplicatore punti; `Setup.IncIva` = messaggi; `Scocard.F0/T0` = avvisi; `Clienti.N1` = due importi in un intero; `Tickets.MangiaT = 1` per origini diverse da quella documentata.
5. **Difetti visibili nel codice:**
   - in `PremiAuto` il controllo della ricevuta `Vincite25` usa `VinciteAdo.Recordset.Costo`, cioè una riga qualunque di `Vincite` (`select top 1`), non il premio corrente [V] 6160, 13391;
   - in `PremiAuto` la variabile `XGld` non viene azzerata tra un pezzo e l'altro, quindi `Vincite.N0` può ereditare il valore del pezzo precedente [V] 6130-6139;
   - `TrovaSco` dichiara l'esito 3 "trovato in TicketsCan" ma non interroga `TicketsCan`: dalla cassa principale uno scontrino annullato non viene riconosciuto come tale [V] `Module8.bas:2-123`;
   - base diversa del `SerNum` delle prenotazioni (2008 contro 2014) [V] 6149, 6444;
   - un operatore disattivato si riattiva leggendo il proprio barcode [V] 14455.
6. **Pulizia distruttiva:** "Pulizia archivio" cancella tutti i lotti consumati di `Tickets`, cioè lo storico di come sono stati spesi i punti [V] 14118-14171. Con Sync Framework la cancellazione si propaga al cloud.
7. **Sicurezza:** credenziale di servizio scritta nel codice in `Module1.bas:2712`; credenziali dell'app passate in chiaro nell'URL di una richiesta HTTP [V] 8044-8055; colonna `Password` dei clienti mostrata nella griglia clienti [V] designer di `DataGrid1Cli`.
8. **Date come testo** in `TransCard.Data` (`AddTransCard`): dipendono dalle impostazioni di lingua del login SQL.

---

## 6. Domande per il team

1. `Prenotaz.Quantita`: conferma che negativo = prenotazione in attesa di disponibilità e positivo = ordine? Chi trasforma l'una nell'altro (`FrmPreCon`, `FrmPreLis`)?
2. Le procedure cloud `sp_last_trans`, `sp_preleva_punti`, `sp_preleva_punti_gold` dove sono e come garantiscono l'atomicità del prelievo tra sale?
3. La modalità Golden (punti Silver e Gold) e le varianti Astoria e Alba sono ancora in uso? In quali sale?
4. La ricevuta `Vincite25` sopra 25 € risponde a un obbligo normativo? La soglia è per paese?
5. Il sistema 4 utenti (`Frm4Usr`) e la modalità Easy sono ancora venduti?
6. Il lettore di banda magnetica e le card magnetiche sono ancora in uso, o tutte le sale sono passate a RFID ECL?
7. Il fondo cassa (`Setup.VCassa`) e l'azzeramento in `frmCassa` sono la sola chiusura di cassa? Esiste una chiusura per operatore registrata nel DB?
8. "Pulizia archivio" viene usata nelle sale? Se sì, lo storico dei punti è già perso in alcune installazioni.
9. `Tickets.MangiaT = 1` per i punti scaricati dalla card ECL: è voluto (stessa origine "contati da MT") o andrebbe distinto?
10. Il blocco anti-clonazione considera da riallineare le card con saldo oltre 400.000 cent: da dove viene la soglia?
