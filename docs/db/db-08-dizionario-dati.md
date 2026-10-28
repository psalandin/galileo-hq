# Galileo HQ — DB 08: dizionario dei dati ricavato dal codice di WinMT

**Stato:** bozza · **Responsabile:** Piero · **Aggiornato:** 2026-10-27

**Fonte:** analisi del sorgente VB6 di WinMT (`docs/winmt/winmt-01` … `winmt-10`), verifiche sui database di test e di produzione · **Collegati:** `db-01-schema.md`, `db-02-catalogo.md`, `db-06-produzione-02.md`, `db-07-confronto-test-produzione.md`, `docs/analisi/analisi-01-catalogo-flussi-winmt.md`

Il catalogo DB 02 dice come sono fatte le colonne. Questo documento dice **cosa significano**, secondo il codice che le legge e le scrive. Raccoglie le voci delle dieci zone di analisi di WinMT, risolve le domande aperte dei documenti DB 01–07 e segnala le colonne il cui significato cambia con il contesto.

- **Certezza.** **V** = verificato nel codice, con riferimento `file:riga`; **D** = dedotto, da confermare.
- **Limiti.** Copre solo le colonne che WinMT usa. Le tabelle scritte da altri componenti (motore di sala B4J, servizio .NET, HQ, trigger) vanno completate con quel codice (WinMT 00, § 4).

---

## 1. Risposte alle domande aperte

| Domanda (documento) | Risposta | Zone |
|---------------------|----------|------|
| `IdContatto` o `IdLong`: quale è il cliente? (DB 01, DB 03) | **`IdContatto`** è il cliente nella sala, generato come MAX + 1. **`IdLong` = `IdContatto` × 10000 + `NImp`** è il cliente nel gruppo multisala. Le tabelle figlie usano l'uno o l'altro secondo la configurazione della sala (`Setup(101).T6`): in una sala singola `IdContatto`, in un gruppo `IdLong` | 01, 02, 03 |
| Cosa significa `NImp`? (DB 01, DB 03) | **Dipende dalla tabella.** In `Clienti`, `Tickets`, `Premi`, `Operatori` è il **numero della sala**, che coincide con il numero del suo database nel cloud (`"DB" & NImp`). In `TransCard` è il **tipo di operazione** (§ 2.1). In `EcsDati` è una costante, sempre 1 | 02, 04, 05, 08, 09 |
| Cosa sono 146 e 9997 in `NImp` nel DB di test? (DB 03) | Numeri di sala. 9997 è con ogni probabilità una sala di laboratorio. In `Tickets`, `NImp = 0` indica righe scritte da procedure SQL o da altri componenti, non da WinMT | 05 |
| `TipoCard` (DB 04, DB 06) | **0 Platinum, 1 Gold, 2 Silver, 3 Compleanno** (VIP o "B" a video). Gli ospiti dei compleanni ricevono 3 e tornano a 2 solo quando la card viene riletta in cassa: questo spiega i 3.043 clienti con 3 in produzione. 999 compare solo nel test | 01–04 |
| `Clienti.N0` (DB 04, DB 06) | **Flag ticketless**: i punti vanno sulla card e non su scontrini cartacei. Due punti del codice usano però la convenzione opposta (§ 2.2) | 01–04 |
| `Clienti.T0` (DB 06) | UID della card RFID, 16 caratteri: gli 8 caratteri di `CoinlessCards.cardid` seguiti da 8 zeri. Per le card QR è uguale a `CodBar` | 01–04 |
| `Clienti.F1`, `T1`, `D1` (DB 07) | Blacklist e card clonate: `T1` è il motivo, `D1` la data, `F1` un flag con più significati (§ 2.2). In cassa il blocco effettivo dipende da `T1` valorizzato | 01–04 |
| `Clienti.F0`, `D0` | Tessera valida (consenso privacy rinnovato) e data di scadenza | 01, 03 |
| `Clienti.Foto` | **Non è una foto.** È un JSON con consensi privacy, stato e OTP della sostituzione card, rimborsi giornalieri, scadenza VIP | 03, 04 |
| `Clienti.IdLong2`, `IdMaster1/2` | `IdLong2 = 1`: cliente registrato dall'app. `IdMaster1/2`: `IdLong` del master di una card secondaria | 03 |
| `Tickets.F1` + `T1` (DB 05) | Ticket ticketless generati dal gioco: `T1` è il device ECL che li ha prodotti. Per i punti da app, `T1` contiene il nome della campagna | 05, 09 |
| `Tickets.DataOut = 1899-12-30` (DB 03) | Lotto mai usato: è la "data zero" di VB6 scritta alla creazione | 05 |
| `Vincite25`, `Ric25`, `Pre25` (DB 01) | Ricevuta firmata per i premi di valore superiore alla soglia `Setup.Pre25` (25 €); `Ric25` la abilita. `Pre25` fa anche da soglia Gold/Silver | 01, 05, 10 |
| `TransCard.CodMac` (DB 03, DB 05) | Per le operazioni di cassa e totem (`WinMt = 1`) è il **nome del computer** della postazione, oppure `SVUOTAMENTO`. Per le partite (`WinMt = 0`) è il codice della macchina | 01, 02, 04, 08 |
| `TransCard.D0` (DB 03) | Data della chiusura di cassa in cui è stato compreso il movimento. Le poche date distinte sono le chiusure | 01, 03, 04 |
| `TransCard.N0` (DB 03, DB 07) | Progressivo di transazione della card, usato contro la ripetizione delle transazioni: avanza di 2 a ogni scrittura di crediti e bonus | 01, 02, 04 |
| `TransCard.T0`, `F0` | `T0`: numero della sala su 4 cifre. `F0`: sala in gruppo multisala, scritto in modo incoerente (§ 2.2) | 01–04 |
| `MName` con `\|` finale (DB 04) | Il carattere dopo `\|` codifica una porta seriale della postazione | 02, 10 |
| Ruolo delle righe di `Setup` (DB 04, DB 06) | 101: sala e postazione Master. 102: postazione, ma con alcuni parametri globali. 103–109: altre postazioni. **110: riga di servizio** (licenza, super password, sincronizzazione), non una postazione. Oltre 110: raccolte card | 02, 10 |
| Le "quattro password" di `Setup` (DB 01) | Solo nominalmente: `Passw` e `AdmPass` contengono opzioni (abilitazioni, parametri ECL); `PasswSM` e `InvPass` sono flag. I segreti veri stanno nei campi jolly della riga 110, offuscati con una codifica reversibile | 10 |
| `DataIni`, `DataEnd` di `Setup` (DB 04) | Nessuna logica le usa | 10 |
| `RiepInv.Mdb`, `Incassi.Mdb` (DB 01) | Contengono davvero **file Access**: l'inventario e il conteggio incasso. `RiepInv` con `F0 = 1` contiene invece le liste premi inviate da HQ | 06, 07, 08 |
| `EcsMacchine.Propr`, `Owners` vuota (DB 03, DB 05) | `Propr` contiene la stessa percentuale di `PerDiv`, scritta come testo. `Owners` è vuota perché la sua gestione non è raggiungibile dal menu | 08 |
| `EcsMacchine.CntrLet15` | Ticket automatici della macchina | 08 |
| `Premi.QDis1..8`, `PDis1..8` (DB 01, DB 07) | Quantità e posizione nei distributori PrizeHub 1–8, gestione oggi superata. Sono vuote in entrambi i DB | 06 |
| `Premi.Quantita` (DB 01) | Giacenza aggiornata direttamente da una decina di percorsi. Almeno quattro non lasciano un movimento di magazzino | 06, 07 |
| Bit 13 e 14 di `fn_decode_mt_bitmask` (DB 07) | Sono usati dai rapporti (8192 = punti da app, 16384 = Silver in Gold): servono, e mancano nel DB di test | 09 |
| Il PAN in `LogTransazioniTotem` (DB 05) | WinMT non lo scrive. I campi delle transazioni POS vengono dalla risposta di PosHandler | 04 |
| `Scocard` (DB 01) | Riusata per gli avvisi sul cliente, propagati anche ai database delle sale collegate | 03, 05 |
| `Mistral` (DB 01) | "Raccolta card": promozione a carte collezionabili (Mistral, Willy Wonka, DC Comics), non card di terzi | 05 |

---

## 2. Colonne il cui significato cambia con il contesto

### 2.1 `TransCard.NImp`: tipo di operazione

Il codice stesso documenta i valori in un commento (`ModAddNew.bas:1091-1110`):

| Valore | Operazione |
|-------:|------------|
| NULL | Partita su un gioco (righe con `WinMt = 0`, scritte dal circuito dei giochi) |
| 0 | Carico da postazione di cassa fissa |
| 1 | Carico da totem |
| 2 | Carico da cassa mobile |
| 3 | Scarico su totem (gettoni acquistati, monete cambiate) |
| 4 | Carico per hopper vuoto su totem |
| 5 | Dobloni (Astoria) o gettoni (Albarella) |
| 6 | Bonus; riusato anche per l'azzeramento della cassa operatore |
| 7 | Svuotamento cassa |
| 8 | Rimborso al cliente |
| 9 | Omaggio al cliente |
| 10 / 11 | Crediti trasferiti ad altra card / acquisiti da altra card |
| 12 | Crediti di servizio rimborsati dall'operatore al cliente |
| 13 | Ricariche compleanni |
| 14 | Crediti acquistati online |
| 15 | Storno |
| 16 | Bonus acquisiti da altre card |
| 18 | Acquisto abbonamenti |
| 19 | Riallineamento o conversione della card |
| 20 | Riscrittura della card: saldo ricostruito alla sostituzione |

### 2.2 Colonne contraddittorie o riusate

| Colonna | Problema |
|---------|----------|
| `Clienti.N0` | Flag ticketless, ma con due convenzioni nel codice: la maggior parte dei punti usa 1 = ticketless, due punti l'opposto. Nel DB di test compare anche il valore 2, non spiegato |
| `Clienti.F1` | Il trigger `bannaUtente` scrive 1 per una card clonata; WinMT scrive 0 quando mette in blacklist e 1 quando ha inviato la notifica; lo sblocco (`sp_rimuovidabl`) scrive di nuovo 1. Spiega perché in produzione `F1 = 1` per 1.227 clienti, ma solo 56 hanno il testo della clonazione |
| `Clienti.Bonus` | Bonus in crediti, ma nella variante Golden contiene i punti Gold divisi per 100 |
| `Clienti.Tickets`, `Credito`, `Bonus` | Copie di saldi che vivono altrove (lotti in `Tickets`, ultimo `ValoreFinale` in `TransCard`, la card stessa), sovrascritte da più punti senza transazione |
| `TransCard.F0` | `AddTransCard` scrive 1 se la sala è in un gruppo multisala; `frmAstoria` scrive 1 se la sala è singola |
| `Tickets` | Una riga ha quattro ruoli: scontrino al portatore, lotto di punti del cliente (consumato aggiornando `TPagati`), blocco tra postazioni (`TPagati` negativo = `−IdPost`), portafoglio Silver/Gold (`D0`). La storia della riga è nella bitmask `MangiaT` |
| `Tickets.T1` | Device ECL per i ticket ticketless, nome della campagna per i punti da app |
| `Prenotaz.Quantita` | Il segno distingue la prenotazione (negativo) dall'ordine (positivo) |
| `MovMag.Motivo`, `MovOut.Motivo` | Causale scritta nella lingua dell'interfaccia (`CARICO`, `LOAD`…): un inventario fatto in una lingua non vede i movimenti registrati in un'altra |
| `MovOut.Fornitore` | Contiene il destinatario, non il fornitore |
| `EcsMacchine.CntrLet8..15`, `CntrVal10..16` | Riusate per i parametri della scheda (erogatore, durate, relè, politica dei ticket) |
| `Setup` | Una colonna cambia significato da riga a riga (101, 102, 110, raccolte). Molte colonne sono riusate per altro: `Passw`, `AdmPass`, `TotTick`, `ScoMan`, `MdbSaveInt` (= moltiplicatore "1 ticket = punti"), `SyncRes`. `Setup_Descriptions` contiene errori rispetto al codice |
| `Operatori.Foto` | JSON con i limiti dell'operatore |
| `Tickets.N1`, `TicketsCan.F0`, `TickRep.F0`, `Vincite25.F0`, `Abbuoni.F0` | **Aggiornamento 27/10 (sync 02 § 6).** Marcano la riga già convertita al formato di gruppo (`× 10000 + sala`) dalla conversione multisala di WinMtProv. In `Abbuoni` la conversione si applica a `Id`, che è l'operatore |
| `Setup.N0` (101 e 110) | **Aggiornamento 27/10 (sync 00 § 2.3).** L'intervallo di sincronizzazione sta in due righe: WinMT usa la 110, WinMtProv e `sp_last_trans` del DB di gruppo la 101 |

### 2.3 `Tickets.MangiaT`: origine e storia del ticket

Bitmask, documentata nel codice (`Module1.bas:100-112`) e completata dalle zone:

| Bit | Valore | Significato |
|----:|-------:|-------------|
| 0 | 1 | Contato da mangiaticket Galileo |
| 1 | 2 | Esterno (mangiaticket non connessa o di altri) |
| 2 | 4 | Manuale (1 + 2 + 4 = 6: convalidato) |
| 3 | 8 | Reso, generato per un premio restituito |
| 4 | 16 | Somma di più scontrini |
| 5 | 32 | Resto per un premio consegnato |
| 6 | 64 | Bonus (24 ore, compleanno, nuova card, ricarica) |
| 7 | 128 | Sommato: usato per generare uno scontrino totale |
| 8 | 256 | Caricato su card |
| 9 | 512 | Passato ad altra card |
| 10 | 1024 | Acquisito da altra card |
| 11 | 2048 | Prenotazione cancellata (con il bit 3: 2056) |
| 12 | 4096 | Cancellato da operatore |
| 13 | 8192 | Punti da app |
| 14 | 16384 | Silver convertiti in Gold |

Le categorie si sovrappongono: un ticket convalidato è contemporaneamente "contato" e "manuale", e i rapporti che sommano per bit lo contano due volte (WinMT 09).

---

## 3. Dizionario per tabella

Una riga per colonna. Se più zone descrivono la stessa colonna, le voci sono riportate tutte, con il numero della zona tra parentesi quadre: in genere si completano, e i casi di contraddizione sono quelli del § 2. Le evidenze rimandano ai file del sorgente WinMT; il dettaglio è nel documento della zona.

### Setup

| Colonna | Significato | Valori | Evidenza | Cert. |
|---|---|---|---|:-:|
| `IDPost` | [02] Ruolo del record<br>[10] Ruolo della riga: 101 generale di sala + postazione Master; 102 postazione + parametri globali (IP server, Silver/Gold, DB ECL, privacy, durata card, abbonamento); 103-109 postazioni; 110 riga di servizio (super passwor… | [02] 101 generale+postazione principale; 102 config aggiuntiva+postazione; 103-109 postazioni; 110 record riservato (super password, licenza); >=111 raccolte card<br>[10] 101; 102-109; 110; 111 Mistral, 112 Willy Wonka, 113... | Module1.bas:2801,2669,2708,1339; CreaRaccolte.bas:19<br>Module1.bas:2373-2915; CreaRaccolte.bas:3-140 | V |
| `MName` | [02] Postazione<br>[10] Nome del computer che occupa la riga + carattere che codifica la porta COM del 2o barcode (split screen); vuoto = riga libera | [02] nomecomputer\| + carattere = porta secondo lettore barcode<br>[10] <computer>\|<Chr(porta)> | Module1.bas:2830,3239<br>Module1.bas:2829-2836; frmsetSys.frm:5842-5855 | V |
| `NRep2` | (101) Reparto 2, Cards Collections se manual tickets; (102) IP server principale |  | Module1.bas:2386,2674; Module6.bas:2058 | V |
| `NRep3` | (102) IP server secondario |  | Module1.bas:2680 | V |
| `NRep4` | (102) Timeout switch server secondario | default 30 s | Module1.bas:2686 | V |
| `Passw` | [02] (101) Carico remoto e card setup ECL<br>[10] Non è una password: opzioni OpCaRem\|ECLSetupCard (operatore abilitato al carico remoto; UID esadecimale della card di setup ECL) | [02] 0/1\|codice card setup<br>[10] 0/1\|hex | Module1.bas:3609-3620<br>Module1.bas:3609-3632; frmsetSys.frm:6736-6742 | V |
| `TotTick` | [06] Usato anche come giorni di ritiro (TotTick div 1000) nel messaggio di premio disponibile<br>[10] Non è 'totale tickets contati': cancellazione automatica ordini non riscossi = giorni scadenza x 1000 + giorni preavviso | [06] -<br>[10] es. 30005 | FrmPreLis.frm:559<br>frmsetGen.frm:4588, 5061-5062; FrmPreLis.frm:559 | V |
| `DataEnd` | Estremi dell'operazione/concorso: data fine; nessuna logica la usa (valori 2999-12-31 in prod) | data | frmsetGen.frm:4759-4760, 5048-5049 | V |
| `DataIni` | Estremi dell'operazione/concorso: data inizio; nessuna logica la usa | data | frmsetGen.frm:4759-4760, 5048-5049 | V |
| `NImp` | [09] Numero impianto = numero del DB in cloud (SqlDB = 'DB' & NImp, IDPost 101); usato come gruppo dei report personalizzati<br>[10] Codice impianto della sala; deve coincidere con DB#### della licenza | [09] prod 196<br>[10] intero | Module1.bas:1358-1359; cls_reports.cls:319-355<br>Module1.bas:1114-1121, 1358; frmsetSys.frm:7089 | V |
| `NConc` | Nome dell'operazione/concorso; stampato in testa agli scontrini premio | testo | frmsetGen.frm:4768; Form1.frm:6177 | V |
| `NTrack` | Traccia della banda magnetica su cui scrivere | 1, 2, 3 | frmsetSys.frm:7858-7861 | V |
| `ScoMan` | Non è 'scontrino manuale': abilita la cancellazione automatica degli ordini non riscossi | bit | frmsetGen.frm:4300-4310, 5088-5096 | V |
| `Ric25` | Registra premio: registrazione fiscale con ricevuta dei premi di valore > Pre25 (25 = soglia storica in euro, D) | bit | frmsetGen.frm:2420-2460, 4791-4795; Form1.frm:6159-6177 | V |
| `Pre25` | Soglia di costo premio per registrazione/ricevuta; usata anche come soglia Gold/Silver dei premi e filtro lista premi | valuta | Form1.frm:5691, 6078, 15086, 15726 | V |
| `TypePrt` | [09] Modello di stampante termica (comandi di taglio diversi)<br>[10] Modello di stampante | [09] 2, 3, 4<br>[10] 0 NEOS S4GN-PS, 1 Bixolon STP-103, 2 Xthea, 3 Neo's Cutter, 4 K3, 5 P3 | frmrapp.frm:5714; frmrapp.frm:5806<br>frmsetSys.frm:7812-7818 | V |
| `Lang` | Lingua | 0 italiano, 1 inglese, 2 francese | frmLogin1.frm:1335-1342 | V |
| `Multiuser` | Riusata: tastiera virtuale a schermo | bit | frmsetSys.frm:7447-7451; frmLogin1.frm:1923 | V |
| `CardReader` | Lettore di banda magnetica | 0 MSR106, 1 MSR206HiCo, 2 MSR206LoCo, 3 MiniMag | frmsetSys.frm:7819-7823; frmgesop.frm:1213 | V |
| `TmOpen` | Orario di apertura, inizio default del Rapporto Settimanale |  | frmWrapp.frm:4430 | V |
| `TmClose` | Orario di chiusura, fine default del Rapporto Settimanale |  | frmWrapp.frm:4431 | V |
| `NTMolt` | Moltiplicatore numero ticket automatico; in Astoria contatore stampe | intero | Module1.bas:353 | V |
| `AutoConv` | Convalida automatica scontrini sconosciuti |  | FrmCTickets.frm:756; Frm4Usr.frm:4655 | V |
| `TicStat` | Mostra il contatore Esterni | bit | frmrapp.frm:5034-5037 | V |
| `BkDisk` | Disco del backup del DB alla chiusura (solo server localhost) | lettera unità | frmLogin1.frm:1298-1314 | V |
| `CRaw` | Lettura di card magnetiche non standard (raw) | bit | frmsetSys.frm:7406-7410 | V |
| `PasswSM` | Flag: password obbligatoria per lo scontrino manuale | bit | Module1.bas:364; Module6.bas:326-337 | V |
| `MagPremLoc` | Riusata: TagRd, RFID obbligatorio per creare la card | bit | Module1.bas:2039, 2263, 2479, 3035 | V |
| `InvPass` | [07] Anche un manager (Livello <= 1) puo' chiudere l'inventario<br>[10] Flag: anche la password manager può concludere l'inventario | [07] bit<br>[10] bit | FrmInventario.frm:2437-2452<br>Module1.bas:380 | V |
| `OpALOff` | Logout dopo ogni consegna |  | Form1.frm:15168 | V |
| `Inv0` | Colonna Q.ta' reale mostrata a zero all'apertura (qreal resta il teorico) | bit | FrmInventario.frm:4975 | V |
| `BkpOk` | Esito dell'ultimo backup | bit | frmLogin1.frm:1317, 1343 | V |
| `MdbSaveInt` | [01] Riusato come MolPun, moltiplicatore ticket → punti mostrati<br>[02] Riusata come moltiplicatore punti MolPun<br>[05] Riusata come MolPun: punti = ticket x MolPun<br>[10] Riusata: moltiplicatore punti MolPun (1 ticket = N punti) | [01] 1..100<br>[02] >=1<br>[05] 1..100<br>[10] 1,2,5,10..100; <0 o >100 => 1 | Module1.bas:2070-2072<br>Module1.bas:2541,3066<br>Module1.bas:2070-2072; Module6.bas:55<br>Module1.bas:2070, 2294, 2541, 3066; frmsetSys.frm:7142-7169 | V |
| `NewConc` | [09] Abilita gestione operazione/concorso a premi nel rapporto<br>[10] Cambio gestione: i rapporti separano i ticket pagati prima/dopo IniConc | [09] bit<br>[10] bit | frmrapp.frm:2738<br>frmsetSys.frm:7096-7101; FrmRappUs.frm:1922-1926 | V |
| `IniConc` | [09] Data di inizio dell'operazione/concorso corrente<br>[10] Data di inizio della nuova gestione | [10] data | frmrapp.frm:2739-2742<br>frmsetSys.frm:7096-7101 | V |
| `RegInc` | [07] Calcolo del riepilogo economico con gli incassi a salvataggio e sommario<br>[09] Abilita registrazione incassi e i rapporti Settimanale/Variazioni | [07] bit<br>[09] bit | FrmInventario.frm:3350<br>frmpremi.frm:2903-2907 | V |
| `IncIva` | [01] Riusato: messaggi dell'app da leggere<br>[02] Commento: numero messaggi in attesa; codice: percentuale IVA |  | Module1.bas:137-139, 16897<br>Module1.bas:139,2549 | D/V |
| `ValTick` | Valore del ticket: non usato dai rapporti (che usano 0,01 fisso), usato da sp_incasso | decimal(6,4) | FrmCont.frm:7648 | V |
| `NtickRic` | Stampa ricevuta premio se il premio vale almeno N ticket (con FPpremio) | intero | frmsetGen.frm:4670; Form1.frm:6153 | V |
| `Ab4Usr` | Sistema 4 utenti attivo |  | frmsetS4Usr.frm:899-918 | V |
| `Mon3H` | [05] Riusata: valore di dobloni/gettoni x100 (Astoria/Albarella)<br>[10] Risoluzione orizzontale 3o monitor; in Astoria/Albarella valore doblone/gettone x 100 | [10] intero | FrmCCardAlba.frm:2974; Module1.bas:433,2591<br>frmsetSys.frm:6928-6933; Module1.bas:2591 | V |
| `VBase` | Valore base per calcolo ticket/valore nei contatori | decimale | FrmCont.frm:8015-8017 | V |
| `ConnOk` | Connessione al server riuscita; se falso login in modalità senza connessione | bit | frmLogin1.frm:1406, 1597-1606 | V |
| `AdmPass` | [02] (101) Parametri ECL<br>[04] Configurazione ECL (IdPost 101), non password<br>[10] Non è una password: parametri ECL separati da \| (codice cliente, codice impianto, rapporto cent/valuta, nome unità, rapporto cent/crediti, flag, etichetta moneta, etichetta gettoni) | [02] codClienteECL\|codImpianto\|CentConversionFactor\|NomeMCM\|CentsToTokenFactor\|flag\|LabelMoneta\|LabelGettoni<br>[04] CodClienteECL\|CodImpianto\|CentConversionFactor\|NomeMCM\|CentsToTokenFactor\|flag valuta\|etichetta moneta\|etichetta gettoni<br>[10] default 0.01, 1, TOKEN, COIN; EUR => simbolo valuta | Module1.bas:21-30,2735-2754<br>Module1.bas:21-30, 2735-2752; CreditToCurrency.sql<br>frmsetSys.frm:6981; Module1.bas:2733-2754, 21-29 | V |
| `Mistral` | Raccolte card attive |  | Module1.bas:2119 | V |
| `MisCode` | Codice sala nel barcode delle carte (car. 3-6) |  | FrmCTickets.frm:572 | V |
| `MisVCard` | [03] Percentuale conversione Gold->Silver (IdPost 102)<br>[09] Valore in punti di una singola card Mistral (serie = 7 card)<br>[10] 101: valore card singola Mistral; 102: parametro conversione Gold (ParCGld) | [03] riuso del campo<br>[10] intero | Module1.bas:2671<br>FrmRappUs.frm:4349<br>Module1.bas:2671, 3181 | D/V |
| `MisVSerie` | [03] Percentuale conversione Silver->Gold (IdPost 102)<br>[09] Valore in punti di una serie della raccolta Mistral<br>[10] 101: valore serie Mistral; 102: parametro conversione Silver (ParCSil) | [03] riuso del campo<br>[10] intero | Module1.bas:2672<br>FrmRappUs.frm:4348<br>Module1.bas:2672, 3182 | D/V |
| `FtpPOrd` | porder.mdb scaricato, da importare | 0/1 | Module1.bas:444; FrmCPOrd.frm:347 | V |
| `EndOk` | Chiusura regolare della postazione | bit | frmLogin1.frm:1319 | V |
| `DataStop` | [02] Ora di chiusura del programma; controllo orologio all'avvio<br>[10] Ora di chiusura della postazione; se futura blocca l'avvio (controllo orologio) | [10] datetime | Module1.bas:454,1187<br>frmLogin1.frm:1320; Module1.bas:1187-1197 | V |
| `TRed` | Aliquota IVA % incassi redemption | % | frmWrapp.frm:3513 | V |
| `TGru` | Aliquota IVA % incassi gru | % | frmWrapp.frm:3514 | V |
| `TPus` | Aliquota IVA % incassi ruspe | % | frmWrapp.frm:3515 | V |
| `TAlt` | Aliquota IVA % incassi altri | % | frmWrapp.frm:3516 | V |
| `NewSet` | AppEn: app clienti in funzione | bit | Module1.bas:2592; frmsetSys.frm:7002-7006 | V |
| `Master` | Postazione Master (riga 101) | bit | frmsetSys.frm:7421; Module1.bas:2873 | V |
| `CodEcs` | [04] Tipo sistema<br>[09] Se valorizzato nasconde il riquadro Punti da APP<br>[10] 101: sistema contatori/card collegato; >110: codice della raccolta | [04] 'ECL' abilita il circuito coinless<br>[10] 101: ECL, ECLReader, EcsNetWiFly, EcsReader, vuoto; >110: MS, WW | fn_is_ecl.sql; FrmSetECL.frm:2098<br>frmrapp.frm:6169<br>Module1.bas:87-92; frmsetSys.frm:6915-6919; CreaRaccolte.bas:18 | V |
| `SyncRes` | [01] Esito dell'ultima sincronizzazione<br>[10] Esito ultima sincronizzazione; nelle righe >110 caratteri identificativi delle card della raccolta | [01] contiene "Failed" se fallita<br>[10] testo (Failed/Success) | Form1.frm:16892<br>frmsetSys.frm:9165; Form1.frm:16892; CreaRaccolte.bas:23 | V |
| `SyncEn` | Sincronizzazione abilitata (solo Master); se vera crea operatore 9999 Galileo App | bit | frmsetSys.frm:7460-7472; Module1.bas:2722-2730 | V |
| `F0` | 101: menu reparti per operatore; 102: modulo privacy attivo; 110: rilevamento forzato (ModRilevamento, non usato); >110: raccolta attiva | bit | Module1.bas:2598, 2690-2694; ModRilevamento.bas | V |
| `F1` | [02] (postazioni <110) Totem; (110) licenza valida<br>[10] 101-109: postazione totem; 110: licenza software valida | [10] bit | Module1.bas:2715,1340<br>Module1.bas:2715-2720, 1339-1356 | V |
| `F3` | [06] BCodeOver: nel carico da file il barcode prevale e sovrascrive il codice articolo<br>[10] 101: barcode sovrascrive codice premio se duplicato | [06] 0/1<br>[10] bit | Module1.bas:51; Module1.bas:2623<br>Module1.bas:2623 | V |
| `F4` | [06] Il Manager puo modificare la descrizione dei premi<br>[10] 101: manager modifica descrizione premi | [06] 0/1<br>[10] bit | Module1.bas:52<br>Module1.bas:2624 | V |
| `F5` | [06] Il Manager puo modificare il barcode dei premi<br>[10] 101: manager modifica barcode premi | [06] 0/1<br>[10] bit | Module1.bas:53<br>Module1.bas:2625 | V |
| `F6` | [06] Disabilita l'avviso di premio con quantita negativa<br>[10] 101: nascondi avviso premio con quantità negativa | [06] 0/1<br>[10] bit | Module1.bas:54<br>Module1.bas:2626 | V |
| `F7` | 101: nascondi avviso punti abbuonati | bit | Module1.bas:2627 | V |
| `T0` | 101: utente admin console web app (MTCry); 110: super password (MTCry); >110: nome raccolta | testo | frmsetSys.frm:9222-9269; Module1.bas:2708-2713 | V |
| `T1` | [02] (110) Tipo di licenza<br>[10] 101: password admin console web app (MTCry); 110: tipo di licenza software; >110: valore serie | [02] Single User, 4 Users, 2 Users, Easy, WinBet, Prize Hub, TotemSql, Jolly Key, Sql<br>[10] testo | Module1.bas:1356-1397<br>frmsetSys.frm:9233-9261; Module1.bas:1339-1398 | V |
| `T2` | 101: utente user console web app (MTCry); >110: flag card nelle serie | testo | frmsetSys.frm:9238-9262 | V |
| `T3` | 101: password user console web app (MTCry) | testo | frmsetSys.frm:9243-9263 | V |
| `T4` | [02] (101) Opzioni supervisore<br>[10] 101: 11 opzioni del Supervisore separate da \| (riscrivi card, scontrino manuale, resi, rapporto, menu premi, gestione clienti, modifica clienti, auto log-off, nascondi scontr. manuale, menu reparti, carico remoto) | [02] 10 flag separati da \|<br>[10] 0/1 x 11 | Module6.bas:384-448<br>frmsetGen.frm:4576-4587; Module6.bas:381-420 | V |
| `T5` | [02] (101) Locali per trasferimento<br>[06] Elenco dei locali per i trasferimenti tra locali<br>[10] 101: elenco locali per trasferimenti di magazzino | [06] nome1\|nome2\|...\|<br>[10] nome\|nome\|... | Module1.bas:62,2600<br>Module1.bas:69; Module1.bas:2600<br>frmsetGen.frm:4572-4575 | V |
| `(101) T6` | Elenco sale collegate (NetSites) | non vuoto = multi-sala | Module1.bas:63, 17805 | V |
| `T6` | [02] (101) Locali del gruppo multi-locale<br>[03] Elenco dei locali del gruppo (IdPost 101)<br>[04] Siti del gruppo multilocale (101)<br>[09] Elenco locali collegati (multi-locale) 'Nome\|NNNN\|...' con NNNN = numero DB cloud<br>[10] 101: locali collegati in multi-locale (NetSites); con # = disattivato; >110 nomi delle serie | [02] Nome\|0000\|...; # disattiva<br>[03] 'nome\|NImp\|...'; con '#' = sala singola<br>[04] con \| si usa IdLong invece di IdContatto<br>[09] con '#' = disattivato<br>[10] Nome\|0000\|Nome\|0001... | Module1.bas:63,2601-2605<br>Module1.bas:2600-2605<br>fn_idcliente.sql; sp_rimuovidabl.sql<br>Module1.bas:53; Module1.bas:2601-2605<br>Module1.bas:2601-2605; frmsetSys.frm:9398-9409 | V |
| `T7` | [02] (101) credenziali server cloud multi-locale; (102) connessione DB cloud servizi ECL<br>[04] Connessione al server ECL (102)<br>[10] 101: credenziali server cloud multi-locale (MTCry); 102: ECL\|server\|db\|utente\|password DB remoto ECL (MTCry); >110: valori card | [02] codificate EncPWord<br>[04] cifrato<br>[10] testo | Module1.bas:2619,3360-3362<br>FrmSetECL.frm:2186-2187<br>Module1.bas:2619, 64; frmsetSys.frm:9445-9485 | V |
| `N0` | 110: intervallo di sincronizzazione in secondi (non 101 come nel dizionario) | intero | frmsetSys.frm:9271-9296; Form1.frm:16123 | V |
| `N1` | [02] (102) Anni validità tessera; (101) versione DB<br>[03] Durata card/consenso in anni (IdPost 102)<br>[10] 101: versione del DB; 102: durata card cliente in anni (0 = non scade) | [03] int<br>[10] intero | Module3.bas:230; Module1.bas:2593<br>Module3.bas:237-250<br>Module1.bas:2593-2597; Module3.bas:225-250 | V |
| `N2` | Porta COM del lettore RFID (postazione) | intero | Module1.bas:2854, 2982, 3221 | V |
| `N3` | [07] Nasconde la colonna Q.ta' macchine in inventario (HideQMacc)<br>[10] 101: nascondi quantità macchine in inventario | [07] 0/1<br>[10] 0/1 | Module1.bas:69<br>Module1.bas:2639 | V |
| `N4` | 101: colore sfondo finestra principale | RGB | Module1.bas:2640 | V |
| `N5` | 101: massimo punti per scontrini manuali o da reparto | intero, 0 = nessun limite | Module1.bas:2641 | V |
| `(101) N6` | Prenotazioni senza card |  | Module1.bas:72 | V |
| `N6` | 101: prenotazioni senza card | 0/1 | Module1.bas:2642 | V |
| `N7` | [02] (101) MSiteMode: con sala offline niente transazioni card<br>[10] 101: MSiteMode, niente transazioni card con locale off-line; nessun consumatore in WinMT | [10] 0/1 | Module1.bas:461,2648<br>Module1.bas:2648-2652; frmsetSys.frm:6992-6996 | V |
| `D0` | [02] (102) Scadenza abbonamento<br>[10] 102: scadenza dell'abbonamento (rosso se < 15 giorni) | [10] data | Module6.bas:2497<br>Module6.bas:2489-2505; frmsetSys.frm:8008-8012 | V |
| `D1` | 110: ultimo sincronismo (scrittore esterno, D) | datetime | Form1.frm:16123, 16152 | V |
| `D3` | [02] (101) Ultima email di servizio<br>[10] Ultima email di servizio: scritta sulla riga 101, letta sulla 110 (bug) | [10] datetime | Module6.bas:2199<br>Module6.bas:2199; Form1.frm:16123 | V |
| `F9` | [03] Scelta ticketless fissata dal sistema (IdPost 101)<br>[04] Scelta ticket/eticket lasciata al cliente (101)<br>[10] 101: negazione di 'lascia al cliente la scelta e-ticket/ticket' | [03] 1 = fissata (ScETCli False), 0 = scelta del cliente<br>[04] salvato come negazione di ScETCli<br>[10] bit (1 = non lasciare scelta) | Module1.bas:2628-2632<br>Module1.bas:190, 3156-3160<br>Module1.bas:2628-2632 | V |
| `F10` | [03] Valore ticketless di default (IdPost 101)<br>[04] ETickets predefiniti (101)<br>[10] 101: modalità predefinita ticketless (e-ticket) invece di ticket cartacei | [03] 1 = e-ticket<br>[04] 1 = eticket<br>[10] bit | Module1.bas:2633<br>Module1.bas:189, 3161<br>frmsetSys.frm:6943-6947 | V |
| `F11` | [02] (101) Auto-inserimento UID non ammessi<br>[03] Auto-ammissione card sconosciute in UID_Ammessi (IdPost 101)<br>[10] 101: aggiungi automaticamente gli UID sconosciuti a UID_Ammessi | [03] bit; il commento di testata indica 102 F1<br>[10] bit | Module1.bas:2634<br>Module1.bas:167,2634-2638<br>Module1.bas:3634-3651 | V |
| `F12` | Postazione: scanner portatile hand-held | bit | frmsetSys.frm:6898-6902 | V |
| `T8` | [02] (101) WiFi ECL<br>[04] SSID e chiave Wi-Fi ECL (101)<br>[10] 101: SSID\|password Wi-Fi delle schede ECL (MTCry) | [02] SSID\|password codificati<br>[04] cifrato<br>[10] testo | Module1.bas:2608<br>Module1.bas:33; FrmSetECL.frm:2195-2197<br>Module1.bas:2606-2617; frmsetSys.frm:9488-9489 | V |
| `(101) T9` | Email dell'amministratore |  | Form1.frm:17429 | V |
| `T9` | 101: email di servizio | testo | frmsetSys.frm:9502-9526 | V |
| `T10` | [02] (101) Scaletta bonus<br>[04] Scaletta bonus crediti su ricarica (101)<br>[10] 101: scala bonus sulle ricariche (crediti) | [02] importo\|bonus x8<br>[04] 8 coppie soglia\|bonus in valuta<br>[10] coppie soglia\|bonus | Module1.bas:191<br>ECL_BonusHandler.cls:106-141; Module1.bas:191<br>ECL_BonusHandler.cls:106, 197; Module1.bas:3663 | V |
| `T11` | [02] (101) Importi ricarica POS<br>[04] Importi di ricarica proposti per POS (101)<br>[10] 101: importi di ricarica proposti con il POS | [02] separati da \|<br>[04] 7 valori separati da \|<br>[10] 7 valori \| | Module1.bas:2668<br>Module1.bas:174, 3151<br>Module1.bas:2668, 3675-3700 | V |
| `T12` | [04] Scaletta bonus ticket su ricarica (101)<br>[10] 101: scala bonus sui ticket | [04] 8 coppie soglia\|ticket; se vuota soglie di T10 con bonus 0<br>[10] coppie soglia\|bonus | ECL_BonusHandler.cls:106-141<br>ECL_BonusHandler.cls:106, 197 | V |
| `T14` | (101) Variabili di incasso (con T15) | separatori \| e [ | Module6.bas:2103 | V |
| `N8` | [05] Ritardo riattivazione scanner (BCDelay, ms)<br>[10] 101: ritardo lettura scanner in ms | [10] 0-1000 passo 100 | Module1.bas:2656<br>Module1.bas:2653-2657; frmsetSys.frm:6967 | V |
| `N9` | 101: valore massimo premio con scontrini cartacei | intero, 0 = nessun limite | Module1.bas:2663 | V |
| `N10` | [04] Modello POS<br>[10] Postazione: modello POS = chiave AvailablePosDevices + 1 | [04] 0 nessun POS; indice AvailablePosDevices+1; >=5 PosHandler TCP<br>[10] 0 = POS disabilitato | Module1.bas:2891; FrmSetECL.frm:1755, 2051<br>Module1.bas:2891; frmsetSys.frm:6934-6942 | V |
| `N11` | [04] Porta COM del POS<br>[10] Postazione: porta COM del POS | [04] numero porta<br>[10] intero | Module1.bas:2892<br>Module1.bas:2892 | V |
| `N12` | Postazione: contatore sequenziale stampe POS | intero | Module1.bas:2893, 3245 | V |
| `N13` | [04] Copie scontrino POS<br>[10] Postazione: stampa doppio scontrino POS | [04] numero<br>[10] 0/1 | Module1.bas:2894<br>Module1.bas:2894; frmsetSys.frm:6939 | V |
| `N14` | [01] Personalizzazione nascosta HiddenOpt<br>[02] (101) Variante cliente<br>[03] Variante cliente (IdPost 101)<br>[10] 101: variante cliente HiddenOpt | [01] 1 Astoria, 2 Alba, 3 Golden<br>[02] 0 normale, 1 Astoria, 2 Albarella, 3 Golden<br>[03] 0 normale, 1 Astoria, 2 Albarella, 3 Golden<br>[10] 0 Normale, 1 Astoria, 2 Albarella, 3 Gold | Module1.bas:2659, 2697-2705<br>Module1.bas:168-173,2698<br>Module1.bas:168-176,2697-2706<br>Module1.bas:2656-2702; frmsetSys.frm:7917-7922 | V |
| `GCassa` | [04] Gestione cassa abilitata<br>[10] Gestione del fondo cassa della postazione | [04] bit<br>[10] bit | Module1.bas:5<br>frmLogin1.frm:1426-1432 | V |
| `VCassa` | [04] Fondo cassa corrente<br>[10] Valore corrente del fondo cassa della postazione | [04] valuta<br>[10] money | Module1.bas:6<br>frmLogin1.frm:1751; FrmCCard.frm:2843; FrmEcs.frm:3006 | V |
| `(102) N1, F0` | Durata della tessera in anni; modulo privacy |  | Module1.bas:81-82 | V |
| `(110) D1, N0, D3` | Ultimo sync, intervallo in secondi, ultima email di errore sync |  | Form1.frm:16123, 16152 | V |
| `Ab4Usr, AbBr0..3, PBRm0..3, AbMon3` | Sistema 4 operatori: abilitazione, scanner e porte, terzo monitor |  | Module1.bas:429-432 | V |
| `AbBr0..3 / PBRm0..3 / Ab4Usr` | Modalità 4 operatori: abilitazione e porta dei 4 barcode | bit / porta | Module1.bas:429-431 | V |
| `AbBr0..AbBr3, PBRm0..PBRm3` | Scanner del sistema 4 utenti abilitati e porte COM |  | frmsetS4Usr.frm:901-909; Module1.bas:2103-2106 | V |
| `AbBT, BTLun…BTDom, OraBIni/End, DataBIni/End` | Fascia "bonus" a calendario (solo avviso a video) |  | Form1.frm:16570-16612 | V |
| `AbMon3, Mon3H, Mon3V` | Terzo monitor del 4 utenti e risoluzione |  | frmsetS4Usr.frm:910-916 | V |
| `AbOrInv, OrInv` | Ora prefissata dell'inventario; con AbOrInv un solo inventario al giorno | bit, hh:mm | FrmInventario.frm:4587; frmpremi.frm:2211 | V |
| `ARep2..9` | [09] Abilitazione dei reparti 1..8<br>[10] 101: abilitazione reparti 2-9 | [09] bit<br>[10] bit | frmrapp.frm:5919-5958<br>Module1.bas:2394-2401 | V |
| `CodEcs (>110)` | Prefisso di due caratteri del barcode della raccolta | MS, WW, DC | RacCard.cls:58 | V |
| `F0 (>110)` | Raccolta attiva | 1 | frmCRCard.frm:422 | V |
| `F1 (prima postazione)` | Flag conteggio macchine in corso | 1 durante FrmCont; in conflitto con la descrizione 'Totem' di Setup_Descriptions | FrmCont.frm:10782-10800 | V … |
| `F1, F2 (111)` | Abilitano la creazione delle raccolte 112 e 113 |  | CreaRaccolte.bas:58-59 | V |
| `F1, FForza (righe > 101)` | Postazione totem; totem in errore |  | Form1.frm:16178 | V |
| `Fforza, NTAbb, PercAbb` | Abbuono: abilitazione, massimo ticket, percentuale |  | Form1.frm:5619-5624, 15608 | V |
| `FForza, PercAbb, NTAbb` | Abbuono consentito, percentuale, massimo ticket |  | Frm4Usr.frm:5721-5727 | V |
| `FPpremio, NtickRic` | Stampa del buono premio e soglia |  | Form1.frm:6153 | V |
| `FT24H, NT24H, FTNew` | Bonus 24 ore e nuova card |  | Form1.frm:11743, 12196 | V |
| `FT24H, NT24H, TmOpen` | Bonus 24 ore: ticket regalati, soglia, inizio giornata |  | Module6.bas:860-885 | V |
| `FtpAppL` | Lista approvata scaricata, da importare | 0/1 | Module1.bas:383; FrmMovmag.frm:2823 | V |
| `GCassa, VCassa` | Gestione cassa; fondo cassa della postazione | VCassa aggiornato dalle ricariche | Module1.bas:5-6, 463-464 | V |
| `IdMT1..5` | Indirizzo delle mangiatickets 1-5 | 1-50 | frmsetSys.frm:7090-7094 | V |
| `IDPost (>110)` | Un record per raccolta di carte collezionabili | 111 Mistral; 112 Willy Wonka; 113 DC Comics | CreaRaccolte.bas:16,84,132 | V |
| `MisVCard, MisVSerie (101)` | Valori di default di carta e serie alla creazione | default 50 e 650 | CreaRaccolte.bas:24-42 | V |
| `MisVCard, MisVSerie (102)` | Riusate: parametri conversione Gold<->Silver |  | Module1.bas:161-162 | V |
| `N14 (101)` | Personalizzazione nascosta HiddenOpt | 0 normale; 1 Astoria; 2 Albarella; 3 Golden | Module1.bas:168-173,2658 | V |
| `N5 (101)` | Limite ticket per scontrini manuali e da reparto (MaxSco) | 0 = nessun limite | Module1.bas:71,2641 | V |
| `NewConc, IniConc` | Cambio gestione e data: separa nei report i ticket emessi prima/dopo |  | frmsetSys.frm:7096-7100; FrmRappUs.frm:1922-1926 | V |
| `NRep2..9` | [09] Nomi dei reparti 1..8<br>[10] 101: nomi reparti 2-9 (NRep2 = Cards Collections attiva ticket manuali/raccolte); 102: NRep2 IP server attivo, NRep3 IP secondario, NRep4 secondi commutazione (default 30); >110: nomi card | [10] testo | frmrapp.frm:5919-5958<br>Module1.bas:2385-2386, 2673-2689; FrmSetSql.frm:707-724 | V |
| `NRep2..9/ARep2..9` | Nome e abilitazione dei reparti ticket 2-9 (non destinazioni di magazzino) | reparto 1 Redemption fisso | FrmReparti.frm:671-829 | V |
| `NRep2..NRep9 (>110)` | Riusate: nomi delle carte concatenati | nome\|nome\|... | RacCard.cls:70 | V |
| `NRepMT1..5` | Reparto assegnato a ciascuna mangiatickets | indice reparto | frmsetSys.frm:7426-7430 | V |
| `numcommMT1..5` | Porta COM delle mangiatickets 1-5 (postazione) | intero | frmsetSys.frm:7285-7380 | V |
| `OpScoMan, PasswSM, MMMSco` | Scontrino manuale per operatore, con password, più copie |  | frmscontr.frm:668-696 | V |
| `PBonus, ScPromo, AbPr, ScLun…ScDom, OraPIni/End, DataPIni/End, AddSP, PrNoSc` | Sconto fedeltà e promozioni a calendario | percentuali | Form1.frm:5510-5593 | V |
| `Ric25, Pre25` | Ricevuta premi di valore e soglia | default 25 €; in Golden è anche la soglia Silver/Gold | Module1.bas:313-314 | V |
| `SyncRes (>110)` | Riusata: alfabeto dei caratteri che identificano le carte | MISTRAL; 0123456789; 0123456789ABCDEF | RacCard.cls:57,119-122 | V |
| `T0 (>110)` | Nome della raccolta |  | RacCard.cls:59 | V |
| `T1 (>110)` | Valore in punti di ciascuna serie | v1\|v2\|... | RacCard.cls:56,334-345 | V |
| `T14/T15 (IdPost 101)` | Definizione serializzata delle voci aggiuntive dell'incasso | nome[tipo[perc[sorgente[acconto[segnoEse[percEse[segnoGes[percGes\| ; percentuali come indice (valore/5) | FrmVarInc.frm:700-716,952-978 | V |
| `T2..T5 (>110)` | Matrice di appartenenza carta-serie | flag 0\|1 per carta, serie concatenate | RacCard.cls:75-82; CreaRaccolte.bas:156-158 | V |
| `T6 (>110)` | Nomi delle serie |  | RacCard.cls:69 | V |
| `T7 (>110)` | Valore in punti di ciascuna carta | v1\|v2\|... | RacCard.cls:55,321-332 | V |
| `TicStat, TSSNum0..TSSNum9` | Accettazione scontrini di ticket station esterne e prefissi registrati |  | Module8.bas:45; Frm4Usr.frm:5074-5085 | V |
| `TRed, TGru, TPus, TAlt` | Aliquota IVA per categoria d'incasso (netto = lordo/(1+T/100)) | % | FrmInventario.frm:5488-5491; Module1.bas:2139-2142 | V |
| `TRed/TGru/TPus/TAlt` | IVA % per categoria macchina in registra incassi: Redemption, Gru, Pusher, Altri | decimale | frmsetGen.frm:4589-4592, 3931-3960 | V |
| `TSSNum0..9` | Matricole delle ticket station non collegate accettate (TicStat) | testo | frmsetSys.frm:7388-7405 | V |
| `ValGett/ValTick (IdPost 101)` | Valore di gettone e ticket in euro; ValGett riscrivibile dal conteggio macchine | euro | FrmCont.frm:9101-9110; fn_dati_grafico_giornaliero.sql | V |
| `VisP0, VinPrInatt` | Vendita sotto giacenza; premi inattivi in lista |  | Form1.frm:5642-5664, 15483 | V |

### EcsMacchine

| Colonna | Significato | Valori | Evidenza | Cert. |
|---|---|---|---|:-:|
| `Keys` | Gruppo della macchina (multipostazione per stesso NomMac o raggruppamento libero); non chiave tecnica | NULL/0/<1 = nessun gruppo; n>0 gruppo, MAX+1 | frmConfMacc.frm:9191-9240; FormRaggruppaMacchine.frm:697-734 | V |
| `CodMac` | Codice macchina scelto dall'operatore; chiave usata dalle tabelle storiche | Testo univoco, nessuna FK | frmConfMacc.frm:7425-7436 | V |
| `Modu` | Numero modulo ECL, progressivo di sala, ultima parte di device | MAX(Modu)+1; +1000 con chkMVarco | Form1.frm:9643-9648; frmConfMacc.frm:6314-6320 | V |
| `NomMac` | Nome del modello = Machines.MacName; legame al catalogo per nome | Testo | frmConfMacc.frm:8037; FrmEcs.frm:3462 | V |
| `Tipo` | [07] Tipi gestiti come gru dalle procedure; mapping con 'Crane','Instant Redemptions','Dispenser','Merchandise' da confermare<br>[08] Tipologia = Type.Id del modello | [07] 3, 9, 12, 17 (vista e sp_crane_list solo 3)<br>[08] 1 cambiagettoni; 2 redemption; 3,9 gru; 4 video; 5,7,8,10,11 conteggiati come video; 14,154 casi speciali ticket/partita; 100 escluso; <100 normali | sp_crane_*.sql; vs_CraneStatus.sql; FormModificaPrezziGru.frm:750-785<br>FrmCont.frm:10351-10360; FrmEcs.frm:3499-3565 | D/V … |
| `CntrLet8` | Riusata: bitmap erogatore ticket 1 | bit0 a impulsi; bit1 motore attivo alto; bit2 ticket switch attivo alto; bit6-7 politica ticketless/cartacei (servizio) | frmConfMacc.frm:6228-6236,7839-7843 | V |
| `CntrLet9` | Riusata: bitmap erogatore 2 | come CntrLet8 | frmConfMacc.frm:6237 | V |
| `CntrLet10` | Riusata: impulsi per partita | 1-10; senza card ValPar/0,5 o gettoni per partita; ECLReader = ValPar | frmConfMacc.frm:7822-7828; frmConfMaccER.frm:2231 | V |
| `CntrLet11` | Riusata: durata impulso credito (ms) / unita di tempo (s) per macchine a tempo | 10-1000 ms; default 90 (vista) o 120 (wizard) | frmConfMacc.frm:7844,7975; vs_eclmacchine.sql | V |
| `CntrLet12` | Riusata: distanza tra impulsi credito (ms) / tempo gratuito (s) | 10-1000 ms; default 500 | frmConfMacc.frm:7845,7976 | V |
| `CntrLet13` | Riusata: durata foro ticket (ms) / tempo minimo in unita (0 = tempo fisso) | 1-100 ms; default 70 | frmConfMacc.frm:7846,7977,6659 | V |
| `CntrLet14` | Riusata: durata ticket (ms) | 10-500 ms; default 400 | frmConfMacc.frm:7847 | V |
| `CntrLet15` | [04] Ticket automatici per partita<br>[08] Riusata: ticket accreditati automaticamente alla card a ogni partita/credito | [04] >0 crea Tickets (MangiaT 8256); <0 aggiorna solo contatori<br>[08] 0-200; 0 nessuno; muove In5, In15, Tickets, Clienti.Tickets | scriviTicketsAutomatici.sql<br>frmConfMacc.frm:6243,7848; scriviTicketsAutomatici.sql:12; inserisces… | V |
| `CntrVal16` | Riusata: politica hardware dei ticket | bitmask: 16 scarica ticket se si inseriscono monete; 32 scarica tutti; NULL default di sala | frmConfMacc.frm:6737-6747,7916-7923 | V |
| `RapCnt16` | Solo ECLReader: gettoni per partita | 1-10 | frmConfMaccER.frm:1903,2230 | V |
| `Propr` | Nominalmente proprietario; in pratica la stessa percentuale di PerDiv scritta come testo | '0'..'100' | frmConfMacc.frm:8140; FormWizardMacchina.frm:1031,1045 | V |
| `PerDiv` | Percentuale Ns Avere (parte gestore) sull'incasso lordo della macchina | 0-100, default 100; nelle correzioni manuali usata come 100-PerDiv (contraddizione) | frmConfMacc.frm:7662-7665; FrmCont.frm:11316,9873 | V |
| `DataInst` | Data di installazione | data | frmConfMacc.frm:7897 | V |
| `DataDis` | Data di disinstallazione: cancellazione logica; esclude da incasso, rettifiche, rapporti, modifica prezzi | NULL = attiva | FrmEcs.frm:2957-2987; sp_incasso.sql:22 | V |
| `ValPar` | Costo della partita senza card | Euro (monete); gettoni per partita; 1 per macchine a tempo | frmConfMacc.frm:8056-8064,8250 | V |
| `NImp` | Non scritto dalla zona | NULL | FormWizardMacchina.frm:887 | V |
| `F0` | Configurazione modificata da inviare al dispositivo (Pending) | 1 pending; azzerato dal servizio | frmConfMacc.frm:7667,7924; FormModificaPrezzi.frm:992-997 | V … |
| `T0` | [02] Valore piatto/hopper \| 15 cifre di lunghezza dei contascatti<br>[08] Residuo: valore unitario del pezzo nell'hopper (versione precedente), usato per i cambiagettoni | [02] 0 = nessun deposito<br>[08] testo numerico | Module1.bas:35-37; API.bas:410-430<br>FrmModCont.frm:2828-2833; FrmCont.frm:11380 | V |
| `N0` | [02] Numero pezzi sul piatto/hopper<br>[07] Modificabile nell'editor gru; in generale numero di gettoni o monete sul piatto/hopper<br>[08] Residuo: pezzi nell'hopper; FrmModCont vi salva ancora la giacenza rettificata | [07] int<br>[08] intero | Module1.bas:38<br>FormModificaPrezziGru.frm:869-873; Module1.bas:38<br>FrmModCont.frm:2923; FrmCont.frm:11381 | D/V |
| `D0` | Data modifica manuale contatori |  | Module1.bas:39 | V |
| `ValPiatto` | Valore unitario del pezzo nell'hopper (piatto, fondo) | euro | frmConfMacc.frm:7905-7911; FrmCont.frm:10076-10091 | V |
| `PzPiatto` | Numero di pezzi nell'hopper | pezzi | frmConfMacc.frm:7905-7911; FrmModCont.frm:2999-3003 | V |
| `device` | Identificativo del dispositivo BE presso il servizio di sala | <CodClienteECL>z<CodImpianto>z<Modu>; macchine a tempo Modu+1000 | frmConfMacc.frm:8039,8206 | V |
| `device_status` | [01] Stato della BE<br>[08] Stato del dispositivo scritto dal servizio | [01] 'Offline' blocca o avvisa la riscrittura card<br>[08] 'Online','Offline','Setup','OOO' (fuori servizio) | Form1.frm:17460<br>frmConfMacc.frm:8343,8364,9289 | V |
| `val_platinum` | Costo partita normale livello Platinum | centesimi | frmEclHH.frm:4085 | V |
| `val_gold` | Costo partita normale livello Gold | centesimi | frmEclHH.frm:4084 | V |
| `val_silver` | Costo partita normale livello Silver | centesimi | frmEclHH.frm:4083 | V |
| `val_normal` | [04] Costo partita normale livello Compleanno<br>[08] Costo partita con card Compleanno (non card normale) | [04] centesimi<br>[08] centesimi | frmEclHH.frm:4086<br>frmConfMacc.frm:7818; FormModificaPrezzi.frm:656 | V |
| `is_timeplay` | Macchina a tempo (si paga il tempo, non la partita) | 1 = a tempo | frmConfMacc.frm:6652,8002 | V |
| `CntrLet1..7` | Ultima lettura del contatore N (alla chiusura dell'ultimo incasso o rettifica): lettura precedente del conteggio successivo | Intero | sp_incasso.sql; FrmCont.frm:10752-10780; FrmModCont.frm:2898-2912 | V |
| `CntrVal1..9` | Valore di uno scatto del contatore N | Euro o unita; 0,01 se il contatore mostra euro | frmConfMaccER.frm:1756-1757; sp_incasso.sql:117-120 | V |
| `CntrVal10..15` | Riusate: tempi ON/OFF dei rele 1-3 (s) | 10/11 rele 1; 12/13 rele 2; 14/15 rele 3 | frmConfMacc.frm:6244-6249,7912-7915 | V |
| `InCnt1..16` | Numero del contatore mosso dall'ingresso X | 1..16; NULL nessuno | vs_ingressi_contatori.sql; frmConfMacc.frm:8090,8123 | V |
| `IngressoCrediti/IngressoGettoni/IngressoTickets` | Quale InX contiene crediti, gettoni e ticket per il servizio | default 'In3','In1','In2'; WinMT non li modifica | FormWizardMacchina.frm:888,1032 | V … |
| `lastseen/offlinecount/onlinecount/cards_presentate/is_online/is_happyhour` | Telemetria e stato scritti dal servizio | - | FrmEcs.frm:2715-2753; vs_eclmacchine.sql | D |
| `RapCnt1..15` | Rapporto del contatore; non usato nei calcoli | 6 in ECLReader; significato forse numero di cifre del contascatti | frmConfMaccER.frm:2201; frmConfMacc.frm:8170 | V … |
| `TipoIn1..16` | Cosa conta l'ingresso X | 0 monete in; 1 gettoni in; 2 premi out (valore); 3 ticket out; 4 monete out; 5 gettoni out; 6 E-coin; 9 (diagnostica) partite card; NULL non usato | frmConfMacc.frm:6220-6227; sp_incasso.sql:94-114; FrmEcs.frm:2794-2805 | V |
| `val_platinum/val_gold/val_silver` | Costo partita con card per livello (macchine a tempo: per unita di tempo) | centesimi (crediti) | frmConfMacc.frm:7818-7821; FormModificaPrezzi.frm:955-965 | V |
| `ValIn1..16` | Valore di un impulso sull'ingresso X | Euro (monete, banconote, premi); gettoni o ticket per impulso; In9 valore partita card; macchine a tempo costo per unita | frmConfMacc.frm:8041,8056-8080; sp_incasso.sql:164-303 | V |
| `ValIn6, ValIn7, ValIn8` | Per le gru: valore unitario del premio degli slot 1-3, copia di GruMagazzinoDettaglio.AvgValue | euro | sp_crane_sync_ecsmacchine_values.sql | V |

### Clienti

| Colonna | Significato | Valori | Evidenza | Cert. |
|---|---|---|---|:-:|
| `IdContatto` | [01] Numero della card/cliente in sala<br>[02] Identificativo locale<br>[03] Progressivo del cliente nella sala | [01] 0 = cliente anonimo (scontrini); −1 usato per "nessun cliente" nelle query<br>[02] max+1, libero anche in TransCard.IdCli; 0 anonimo; -1 nessun cliente<br>[03] MAX+1 in transazione SERIALIZABLE, salta valori in TransCard.IdCli; 0 = ticket anonimi, escluso dalle liste; chiave delle figlie in sala singola | Form1.frm:13394, 6430<br>ModAddNew.bas:697-709; Form1.frm:11666<br>ModAddNew.bas:579,697-708; ModuleMultilocale.bas:2-20 | V |
| `Nome` | Nome (anche segnaposto) | 'Cliente - N'; 'cliente' + Cognome 'eliminato' = cancellazione logica | frmAstoria.frm:5844; Form1.frm:5507 | V |
| `Cognome` | Cognome (anche segnaposto) | 'Compleanno<IdCompleanno>_<n>' per ospiti; 'eliminato' = cancellazione logica | frmCompleanni.frm:2631; Form1.frm:5507 | V |
| `Tickets` | [01] Saldo punti Silver (copia)<br>[02] Punti residui (copia)<br>[03] Punti residui (copia calcolata) | [01] ricalcolato da Tickets (Σ NumTickets − TPagati, Aux = 0, D0 IS NULL); in multi-sala somma di tutte le sale<br>[02] Somma(NumTickets-TPagati) Tickets aux=0<br>[03] somma NumTickets-TPagati di Tickets con Aux=0; in variante Golden solo Silver | Form1.frm:17193-17211, 17645-17651<br>Module8.bas:349-366<br>Module8.bas:403-450 | V |
| `Data` | [01] Data e ora di creazione della card<br>[03] Data di iscrizione | [01] scritta anche sulla banda magnetica e usata per validarla<br>[03] +1 secondo a ogni riscrittura card | Form1.frm:12611-12614, 6697-6708<br>FrmGenCard.frm:2602 | V |
| `Bonus` | [01] Saldo punti Gold / 100 (modalità Golden)<br>[02] In variante Golden: punti gold/100<br>[03] In variante Golden: punti Gold / 100 | [01] ricalcolato da Tickets con D0 IS NOT NULL; non è il bonus in crediti della card ECL<br>[02] 0 alla creazione<br>[03] decimal(6,2) riusato; x100 a video | Form1.frm:17646-17649, Module6.bas:1852-1875<br>Module8.bas:347; Module6.bas:1863; ModAddNew.bas:595<br>Module8.bas:346-347,424-428; FrmClaCli.frm:1468,1492 | V |
| `CodBar` | [01] Barcode della tessera<br>[03] Barcode stampato sulla card | [01] prefissi CD, JV<br>[03] da UID_Ammessi sui primi 8 caratteri dell'UID; prefisso JV = card LED, CD = card barcode | Form1.frm:14395, 14578<br>ModAddNew.bas:712-743; FrmGenCard.frm:2792-2803 | V |
| `Abilita` | [01] Lock: cliente in uso su una postazione<br>[02] Card abilitata<br>[03] Lock: transazione in corso sulla card | [01] 0 = in carico a una cassa o in unione card; 1 = libero<br>[02] 1/0<br>[03] 0 = in lavorazione su una postazione o in unione card; 1 = libero | Form1.frm:11555-11576, 17261, Module6.bas:1772<br>Module6.bas:1783,1808<br>Form1.frm:6938-6951; frmAstoria.frm:4446-4464; Module6.bas:1772-1820 | V |
| `Nascita` | Data di nascita | 01/01/1900 se non impostata | FrmGenCard.frm:1943-1947 | V |
| `NascOk` | Non scritto da nessuna parte del sorgente | - | ricerca su tutto il sorgente | V |
| `GiornOk` | Non scritto da nessuna parte del sorgente | - | ricerca su tutto il sorgente | V |
| `DataUltVis` | [01] Ultima visita<br>[02] Ultima visita / ultimo aggiornamento punti<br>[03] Ultima visita | [01] aggiornata a ogni presa in carico e scrittura punti; regola del bonus 24 ore<br>[02] getdate()<br>[03] aggiornata a presa in carico e rilascio | Form1.frm:17261, 11743<br>Module6.bas:1833; ModAddNew.bas:935<br>frmAstoria.frm:4453; Form1.frm:17261 | V |
| `OptOut` | Consenso al trattamento dei dati (nome fuorviante) | 1 = consenso dato | FrmGenCard.frm:1938-1942; FrmClaCli.frm:1416 | V |
| `Password` | Password dell'App | in chiaro; copiata da winmtAPI.ClientiAPP | FrmNewCliApp.frm:1430; frmModCli.frm:1610 | V |
| `FirstLogin` | Registrazione App completata | bit, da servizio cloud | frmModCli.frm:1460-1490 | V |
| `Foto` | [03] JSON di attributi estesi (non una foto)<br>[04] Attributi JSON del cliente (non foto) | [03] checkProfiling, checkMarketing, checkAnalytics, checkVipPromotion, ReissueCardStatus/Count/OTP/Date/List, DailyRefundsAmount/Date, VipPromotionSubscriptionExpi…<br>[04] consensi checkProfiling/VipPromotion/Marketing/Analytics; ReissueCard*; DailyRefunds*; VipPromotionSubscriptionExpiryDate | ECL_cliente.cls:1129-1200; frmModCli.frm:1951<br>ECL_cliente.cls:1129-1171 | V |
| `IdTel` | [03] Identificativo del telefono dell'App<br>[10] Id dell'utente dell'app, destinatario di push ed email | [03] pk_device dal servizio cloud<br>[10] intero | frmModCli.frm:1491-1495<br>SendMsg.bas:14; Form1.frm:7770 | V |
| `Credito` | [01] Saldo crediti della card in cent<br>[02] Saldo card in centesimi<br>[03] Saldo della card (crediti+bonus)<br>[04] Saldo card (crediti+bonus) in unità card | [01] ValoreFinale / CentConversionFactor dell'ultima operazione di cassa; mostrato come credito × CentConversionFactor<br>[02] ValoreFinale/0,01<br>[03] unita interne (centesimi) = ValoreFinale/CentConversionFactor<br>[04] da cassa ValoreFinale/CentConversionFactor; da decodifica_record saldo nuovo | ModAddNew.bas:1135, 5448<br>ModAddNew.bas:1135<br>ModAddNew.bas:1135; frmAstoria.frm:5914-5917; FrmClaCli.frm:1692<br>ModAddNew.bas:1135; decodifica_record.sql:423 | V |
| `NImp` | Codice impianto (sala) del cliente | valsets.NImp | ModAddNew.bas:620 | V |
| `F0` | [01] Tessera valida (modulo privacy)<br>[03] Consenso privacy rinnovato (Rinnovata) | [01] 0 = scaduta, rifiutata in cassa se AbPrv<br>[03] bit; filtro consenso se privacy 2018 attiva | Form1.frm:11578, 13314<br>frmModCli.frm:1604-1608; FrmClaCli.frm:1413-1418 | V |
| `T0` | [01] UID della card RFID<br>[02] UID RFID della card<br>[03] UID della card assegnata<br>[04] UID completo della card (16 caratteri) | [01] stringa esadecimale di 16 caratteri<br>[02] 16 caratteri esadecimali<br>[03] 16 caratteri (8 hex + 8 zeri); per clienti QR = CodBar; univoco tra clienti<br>[04] primi 8 = CoinlessCards.cardid | Form1.frm:11136, Module1.bas:19<br>Module1.bas:19; ECL_command.cls:191<br>FrmGenCard.frm:3005-3074; frmAstoria.frm:2928-2930<br>Module1.bas:19; scriviTransazioneCard.sql | V |
| `N0` | [01] Card ticketless<br>[02] Tipo di ticket del cliente<br>[03] Flag ticketless replicato sulla card<br>[04] Flag ticketless della card | [01] 0/1, passato alla card come SetTckLess<br>[02] 0 ticketless, 1 ticket cartacei<br>[03] 1 = e-ticket sulla card, 0 = ticket cartacei; commento di AggCliente e lettura in FrmGenCard usano la convenzione opposta<br>[04] 0 ticket cartacei, 1 ticketless; 2 non spiegato | Form1.frm:7998, 15953, 17838, ECL_command.cls:340-346<br>ModAddNew.bas:1322,1286<br>frmModCli.frm:1655-1665,2119-2125; ModAddNew.bas:1322; FrmGenCard.frm…<br>FrmGenCard.frm:1976; frmVendiGettoni.frm:884 | V |
| `D0` | [01] Data di scadenza della tessera<br>[03] Scadenza consenso/card | [01] il master pone F0 = 0 se D0 < oggi; durata in anni in Setup(102).N1<br>[03] oggi + Setup(102).N1 anni al rinnovo; NULL se non impostata | Form1.frm:13314, Module1.bas:81-82, Module3.bas:237<br>frmModCli.frm:1373-1379,1578-1583; Module3.bas:237-250 | V |
| `F1` | [01] Blacklist notificata<br>[02] Segnalazione card incoerente/clonata<br>[03] Flag blacklist (semantica multipla)<br>[04] Flag card sospetta/clonata | [01] 0 = appena messa in blacklist da WinMT; 1 = email inviata<br>[02] WinMT scrive 0 (con T1/D1); trigger bannaUtente scrive 1; AggCliente azzera<br>[03] 1 dal trigger bannaUtente; 0 da MettiInBlackList; 1 anche dopo sblocco (sp_rimuovidabl, FrmRecoverCard) con T1 NULL; 0 dopo riscrittura card<br>[04] contraddittorio: 1 da bannaUtente, 0 da MettiInBlackList, 1 da sp_rimuovidabl | Module6.bas:2369, 17390-17419<br>Module6.bas:2366; ModAddNew.bas:1325<br>bannaUtente; Module6.bas:2366; FrmRecoverCard.frm:708; ModAddNew.bas:…<br>bannaUtente.sql; Module6.bas:2366; sp_rimuovidabl.sql | V |
| `T1` | [01] Motivo della blacklist<br>[02] Motivo della segnalazione<br>[03] Causa della blacklist<br>[04] Motivo blocco/clonazione | [01] testo "IdPost:postazione\| \|saldo card:…" (WinMT) o dati macchina (trigger)<br>[02] WinMT: IdPost:computer\| \|saldo card:...prog[...]; trigger: CodMac\|costo partita\|saldo\|id clonate<br>[03] 'macchina\|costo partita:x\|saldo card:y\|id clonate:z' (trigger) o 'IdPost:PC\| \|saldo card:..prog[..]' (WinMT); NULL dopo sblocco<br>[04] valorizzato = blocco in cassa (crediti mostrati ????) | Module6.bas:2361-2369, 17391<br>Module6.bas:2360<br>bannaUtente; Module6.bas:2357-2366; frmBlList.frm:330-398<br>Form1.frm:9200-9215; Module6.bas:2366; bannaUtente.sql | V |
| `N1` | Crediti sospesi da totem, da scrivere sulla card in cassa | crediti + bonus × 100000 (cent); azzerato dopo l'accredito | Form1.frm:15952-15978 | V |
| `D1` | [01] Data di messa in blacklist<br>[02] Data della segnalazione<br>[03] Data dell'evento di blacklist<br>[04] Data rilevazione blocco | [02] getdate()<br>[03] datetime; NULL dopo sblocco o riscrittura<br>[04] datetime | Module6.bas:2369<br>Module6.bas:2366<br>bannaUtente; Module6.bas:2366<br>Module6.bas:2366; bannaUtente.sql | V |
| `TimeMod` | [02] Ora di modifica<br>[03] Ora dell'ultima modifica | [03] getdate()/Now | ModAddNew.bas:594,1318<br>ModAddNew.bas:621,1317 | V |
| `OperMod` | [02] Operatore che ha creato il cliente<br>[03] Operatore che ha creato il cliente | [02] Id operatore<br>[03] idx operatore | ModAddNew.bas:623<br>ModAddNew.bas:623 | V |
| `IdMaster1` | Primo master di una card secondaria (slave) | IdLong del master; 0/NULL nessuno | FrmGenCard.frm:1840-1864; frmModCli.frm:1336-1345; Form1.frm:6978 | V |
| `IdMaster2` | Secondo master di una card secondaria | IdLong del master; 0/NULL nessuno | FrmGenCard.frm:1840-1864; Form1.frm:6978 | V |
| `TipoDoc` | Tipo di documento d'identita | 0 patente, 1 carta d'identita, 2 passaporto, 3 codice fiscale | frmModCli.frm:1748-1755 | V |
| `Docum` | Numero del documento | testo | frmModCli.frm:1616-1627 | V |
| `Sesso` | Sesso | 0 = M, 1 = F | frmModCli.frm:1611-1615 | V |
| `Modificato` | [02] Record modificato<br>[03] Marcatura di modifica | [02] 1<br>[03] 1 a ogni insert/aggiornamento; reset non trovato nella zona | ModAddNew.bas:594,1317<br>ModAddNew.bas:621,1316 | V |
| `IdLong` | [01] Identificativo multi-sala<br>[02] Identificativo cliente nel gruppo<br>[03] Identificativo del cliente nel gruppo multi-locale | [01] IdContatto × 10000 + NImp; usato al posto di IdContatto in Tickets, Vincite, Prenotaz, TransCard quando la sala è in gruppo<br>[02] IdContatto*10000+NImp<br>[03] IdContatto*10000+NImp; chiave delle figlie (TransCard.IdCli, Tickets, Vincite, Prenotaz, Resi) se Setup(101).T6 contiene i locali | Form1.frm:12200, ModuleMultilocale.bas:2-17<br>ModAddNew.bas:624<br>ModAddNew.bas:624; ModuleMultilocale.bas:2-20; fn_idcliente | V |
| `IdLong2` | Origine della registrazione | 1 = registrato da App; NULL/0 = al banco (Store) | FrmNewCliApp.frm:1363; FrmClaCli.frm:1498 | V |
| `EMailIsCertified` | [02] Email verificata<br>[03] Email verificata | [02] azzerato se cambia<br>[03] azzerato se l'email cambia; impostato fuori da WinMT | ModAddNew.bas:1302<br>ModAddNew.bas:1302; frmModCli.frm:1595-1598 | D/V |
| `HasTelephoneNumberCorrect` | [02] Cellulare verificato<br>[03] Cellulare verificato | [02] azzerato se cambia<br>[03] azzerato se il cellulare cambia; impostato fuori da WinMT | ModAddNew.bas:1300<br>ModAddNew.bas:1300 | D/V |
| `UserName` | Non scritto da WinMT | letto ClientiAPP.Username ma non copiato | FrmNewCliApp.frm:1406-1408 | V |
| `TipoCard` | [01] Livello card<br>[02] Livello della card<br>[03] Livello della card<br>[04] Livello card | [01] 0 Platinum (P), 1 Gold (G), 2 Silver (S), 3 VIP/compleanno (B)<br>[02] 0 Platinum, 1 Gold, 2 Silver, 3 Compleanno (a video VIP/B)<br>[03] 0 Platinum, 1 Gold, 2 Silver, 3 Compleanno (BDAY/VIP sul firmware); 999 non prodotto dal codice<br>[04] 0 Platinum, 1 Gold, 2 Silver, 3 Compleanno/VIP | Form1.frm:11758-11771, 17732-17742<br>Module1.bas:754-757; ClassPromozioni.cls:200; Form1.frm:11766<br>FrmGenCard.frm:1698,2584-2593; Module1.bas:754-757<br>Module1.bas:754-757; Form1.frm:11678; ECL_command.cls:394-420 | V |
| `IdMaster1, IdMaster2` | Card master di una card slave | IdContatto_master × 10000 + NImp | Form1.frm:6978, 17095 | V |
| `IdTel, FirstLogin` | Destinatario dei messaggi push dell'app | push solo se FirstLogin = 1 | Form1.frm:7737-7774 | V |
| `Nome, Cognome` | Anagrafica | 'cliente'/'eliminato' = cliente cancellato logicamente | Form1.frm:13291-13292 | V |

### Premi

| Colonna | Significato | Valori | Evidenza | Cert. |
|---|---|---|---|:-:|
| `Codice` | Codice interno articolo, PK; stampato come barcode CODE93 sulle etichette; modificabile senza aggiornare lo storico | min 5 car. 0-9 A-Z a-z . - _; se vuoto = CodOr | frmpremi.frm:2304-2331; frmpremi.frm:4163-4173; FrmLismovN.frm:3247-3… | V |
| `Costo` | [01] Costo del premio<br>[06] Costo d'acquisto unitario in valuta; valore magazzino = sum(Costo*Quantita) | [01] soglia Pre25 per ricevuta e per premi Gold<br>[06] >0 obbligatorio | Form1.frm:6127, 15575<br>frmpremi.frm:3289-3292; frmpremi.frm:5126 | V |
| `N_Tickets` | Prezzo dell'articolo in ticket/punti | >0; AutoNT: Costo*NTMolt arrotondato alla decina; modifica massiva Costo*moltiplicatore | frmpremi.frm:2796-2806; FrmNTickMod.frm:219 | V |
| `Fornitore` | Nome del fornitore abituale (testo, FK logica a Fornitori.Nome) | testo libero | frmpremi.frm:3250-3265 | V |
| `Quantita` | [01] Giacenza<br>[06] Giacenza attuale aggiornata direttamente da ogni flusso (non derivata)<br>[07] Giacenza: a fine inventario = contato meno vincite dopo l'istante di riferimento; nel Ricalcolo = quantita' presunta<br>[09] Giacenza di magazzino; Costo x Quantita = valore magazzino | [01] decrementata alla scelta, ripristinata all'annullamento<br>[06] troncata a 0 negli scarichi; sovrascrivibile da griglia (MQPrem) e ricalcolo inventario<br>[07] int | Form1.frm:15711, 15249<br>FrmKit.frm:1384-1386; frmpremi.frm:2648-2698; frmpremi.frm:2900-2902<br>FrmInventario.frm:3335-3436; frmpremi.frm:2681-2683<br>frmWrapp.frm:3313 | V |
| `Riserva` | [01] Scorta minima<br>[06] Scorta minima / soglia di riordino | [01] avviso sotto soglia<br>[06] lista riserva: quantita < riserva | Form1.frm:17107<br>frmpremi.frm:5117-5121; frmpremi.frm:4924-4953 | V |
| `CodOr` | [06] Codice originale = barcode del fornitore (EAN); univoco; chiave del WHERE in cls_premio.UpdatePremio<br>[07] Codice originale/barcode: chiave alternativa per lettore barcode, inventario precedente e PrizeHub | [06] se vuoto = Codice; min 5 car.; ricerca scanner Codice poi CodOr<br>[07] testo | frmpremi.frm:2125; frmpremi.frm:2582-2627; cls_premio.cls:251<br>FrmInventario.frm:1582, 4661; frmEditPrizeHub.frm:830-836 | V |
| `Foto` | Immagine jpg dell'articolo | generata da file | frmpremi.frm:5198-5248; frmpremi.frm:5330-5357 | V |
| `QPren` | [01] Quantità prenotata<br>[02] Quantità prenotata<br>[06] Quantita impegnata da prenotazioni/ordini clienti non consegnati | [01] disponibile = Quantita − QPren<br>[02] default 0 all'inserimento<br>[06] = sum(abs(Prenotaz.Quantita)) con cons=0; disponibile in cassa = Quantita-QPren | Form1.frm:17758, 5660<br>ModAddNew.bas:143<br>FrmPreLis.frm:660-709; Form1.frm:5697 | V |
| `Id` | Codice breve visualizzato e ricercabile in cassa | testo max 5 car. in griglia | frmpremi.frm:4123-4126; Form1.frm (filtro id like) | V |
| `Ordinato` | Quantita da ordinare / ordinata in attesa (significato misto) | proposta manuale -> Ordini.QOrd; +QOrd da ordine remoto; -arrivato a carico da ordine; azzerata da ModificaPremio nel carico da bolla | frmpremi.frm:4309-4351; FrmCPOrd.frm:406; FrmCariPO.frm:998; ModAddNe… | V |
| `Conf` | Pezzi per confezione | Ordinato multiplo di Conf; 0 blocca la creazione dell'ordine | frmpremi.frm:4349-4366; frmpremi.frm:4847-4859 | V |
| `Attivo` | Articolo attivo | default 1; Setup.NoInatt nasconde gli inattivi; il carico da file riattiva | frmpremi.frm:5097-5101; FrmMovmag.frm:3343 | V |
| `Gru` | [01] Premio di gru<br>[06] Tipo articolo<br>[09] Tipologia (premio gru) usata dal filtro Tipo | [01] il banco mostra solo Gru = 0<br>[06] 0 = T premio redemption a ticket; 1 = C premio gru o consumabile; la cassa mostra solo gru=0<br>[09] 0/1 | Form1.frm:5697<br>frmpremi.frm:3305-3313; frmpremi.frm:5167-5182; Form1.frm:5697<br>frmrapp.frm:2838 | V |
| `Riord` | Articolo riordinabile | 1 = entra negli ordini d'acquisto; default 1 | frmpremi.frm:4328-4342 | V |
| `Locked` | [01] Lock del record<br>[02] Postazione che modifica la quantità<br>[06] Blocco applicativo durante la modifica della quantita | [01] IdPost della postazione che modifica la quantità; 0 libero<br>[02] 0 libero, altrimenti IDPost<br>[06] 0 libero; IdPost della postazione (Frm4Usr: IdPost+1+indice utente) | Module6.bas:1446-1480<br>Module6.bas:1454,1473<br>Module6.bas:1446-1480; FrmPreCon.frm:723-741 | V |
| `Id2` | Nessun uso funzionale trovato | 0; 1 solo per errore di argomenti in FrmVisPO | ModAddNew.bas:151; FrmVisPO.frm:821 | D |
| `Icona` | Miniatura jpg dell'articolo | generata da file | frmpremi.frm:5198-5248 | V |
| `Prenotabile` | [02] Premio prenotabile<br>[06] Articolo prenotabile | [02] default 1<br>[06] default 1; nessun altro uso trovato nella zona | ModAddNew.bas:152<br>frmpremi.frm:3160-3163; ModAddNew.bas:152 | V |
| `NImp` | Numero impianto | valsets.Nimp | ModAddNew.bas:153 | V |
| `N0` | Letto dalla cassa nella lista premi, uso non individuato | ? | Form1.frm:5697 | D |
| `Costo, N_Tickets` | Costo d'acquisto e prezzo in ticket; profitto % = (N_Tickets/100 - Costo)*100/Costo (1 ticket = 0,01 euro); costo zero blocca l'inventario | money, decimal | FrmInventario.frm:4953, 5035-5045 | V |
| `F0,T0,D0,F1,T1,N1,D1` | Campi jolly non usati nella zona | - | ricerca nel sorgente | V |
| `PDis1..8` | [06] Posizione/slot dell'articolo nel distributore automatico n. 1-8<br>[09] Posizione (slot) del premio nel Prize Hub N | [06] es. X1, A3; superato da PrizeHubSlots<br>[09] <> '' = presente nel Prize Hub N | FrmRappDis.frm:542; frmEditPrizeHub.frm:518<br>FrmRappDis.frm:540 | V |
| `QDis1..8` | [06] Pezzi caricati nel distributore automatico (Prize HUB) n. 1-8<br>[09] Quantita del premio nel Prize Hub N | [06] superato da PrizeHubSlots; PrizeHub_MoveToSlot usa QDis1 su articoli virtuali | FrmRappDis.frm:542; PrizeHub_MoveToSlot.sql<br>FrmRappDis.frm:540; FrmRappDis.frm:584 | V |

### setup2

| Colonna | Significato | Valori | Evidenza | Cert. |
|---|---|---|---|:-:|
| `IdPost` | Ambito: 101 parametri globali; IdPost della postazione per parametri di postazione; 0 per riconoscere il micro-totem | 101; 101-110; 0 | cls_setupV2.cls; clsSerialAutoDetect.cls:188-215 | V |
| `Chiave` | Chiavi usate in zona | HardwareTicketsPolicy (JSON), VipSubscriptionParams (JSON), 2NdScreenVersion, NrColonnePrinter_<n> | Module1.bas:1062-1083,2768,3997 | V |
| `Valore` | Parametri chiave/valore usati in zona | IdPost 101: RechargeTransactionLimit, PosTransactionLimit, BirthdayDefaultHours, BirthdayLimitHours, BirthdayFreeCharge, 2NdScreenVersion; IdPost 0: JSON dispo… | frmAstoria.frm:3234-3244; frmCompleanni.frm:1781-1795; FrmCreaCardsBa… | V |
| `BirthdayFreeCharge (101)` | Ricarica compleanno dal cassiere | 1 = abilitata | FrmCCard.frm:2179 | V |
| `Chiave (101)` | Chiavi ECL | AvailablePosDevices, PosTcpConfig, RitiroCard, VipSubscriptionParams, flagDropTicketsForGold, 2NdScreenVersion, MaxTentativiNonConfermati | ECL_database.cls:27-90; decodifica_record.sql:30-36 | V |
| `Chiave, Valore` | Configurazione PrizeHub (IdPost 101): chiave PrizeHub<nn>, valore JSON {hubId, hubName, containers:[{type, range, unit}]} | type CAPSULE/SPINDLE/LOCKER; range es. A1-A18 | frmEditPrizeHub.frm:1131-1140, 1287-1323 | V |
| `Chiave=2NdScreenVersion` | Versione del secondo schermo cliente | '' = V1; V2 | frmsetGen.frm:4912-4917; Module1.bas:1062 | V |
| `Chiave=AvailableButtons` | Pulsanti abilitati | JSON {nome: 0/1} | cls_setupV2.cls:430-475 | V |
| `Chiave=AvailablePosDevices` | Modelli POS disponibili | JSON [{key,value}] 0 Nayax VPOS .. 7 PosHandler | ECL_database.cls:27-42 | V |
| `Chiave=ecs2mqttVer` | Versione del motore `ecl2mqtt` (la chiave conserva il nome vecchio `ecs2mqtt`; scrittore: il motore, vedi ecl2mqtt 01 § 3.f); >= 2.36.0 cambia topic MQTT | versione | FormMqtt.frm:310 | V |
| `Chiave=flagDropTicketsForGold` | Ticket automatici per card Gold (SP scriviTicketsAutomatici) | true/false | ECL_database.cls:59-64 | V |
| `Chiave=HardwareTicketsPolicy` | Politica di erogazione ticket hardware | JSON {FlagDropTicketsIfCoin, FlagDropTickets}, default 0/0 | Module1.bas:1069-1083 | V |
| `Chiave=NrColonnePrinter_<TypePrt>` | Colonne della stampante della postazione | intero, default 24 | Module1.bas:3997-4001 | V |
| `Chiave=PosTcpConfig` | IP e porta del POS di rete | JSON {ip, port} | ECL_database.cls:67-72 | V |
| `Chiave=RitiroCard` | Ritiro della card abilitato | enabled/disabled | frmsetGen.frm:4919-4923 | V |
| `Chiave=SERIAL_AUTODETECT.DEVICE.<tipo>` | Ultimo esito autodetect per periferica della postazione | JSON deviceType, portNumber, settings, found, ... | clsSerialAutoDetect.cls:188-199; clsSerialDetectResult.cls:128-145 | V |
| `Chiave=SERIAL_AUTODETECT.EMPTY.COM<n>` | Porta COM senza periferiche | JSON emptyPort=true | clsSerialAutoDetect.cls:201-215 | V |
| `Chiave=VipSubscriptionParams` | Abbonamento VIP | JSON {enabled, model, amount, expirydate, subscriptiondurationmonths, activationdate}; model: FidelizzazioneDatiPersonali\|Sottoscrizione\|UtilizzoContinuativo… | frmsetGen.frm:4926-4964; Module1.bas:2765-2788 | V |
| `ImportoRicariche (101)` | Tagli rapidi di ricarica | JSON num0..num4 | FrmCCard.frm:1751 | V |
| `IsRimborsoGettoni (101)` | Rimborso gettoni in crediti | JSON ValoregettoneDaRimborsare | FrmCCard.frm:4680 | V |
| `Valore (IdPost 0)` | Dispositivi di rete (GiallOne) | JSON ip, port, nomeservizio, nomedevice, macaddr | cls_GiallOne.cls:388-395 | V |

### Tickets

| Colonna | Significato | Valori | Evidenza | Cert. |
|---|---|---|---|:-:|
| `IdContatto` | [01] Titolare del lotto di punti<br>[02] Cliente<br>[05] Titolare del lotto di ticket<br>[09] Cliente proprietario | [01] 0 = scontrino al portatore; altrimenti cliente (IdLong in multi-sala)<br>[02] 0 scontrino anonimo; IdLong se multi-locale<br>[05] 0 = scontrino al portatore; altrimenti IdContatto o IdLong (multi-sala)<br>[09] 0 = scontrino cartaceo anonimo | Form1.frm:8272, 11784<br>Module8.bas:43; Form1.frm:12200<br>FrmCTickets.frm:1123; Module8.bas:43<br>frmrapp.frm:2750-2755 | V |
| `NumTickets` | [01] Valore del lotto<br>[05] Quantità del lotto | [05] intero; 4-5 cifre nel barcode | Module8.bas:20-38 | V |
| `Data` | Data di emissione del lotto |  | ModAddNew.bas:74 | V |
| `MangiaT` | [01] Origine del lotto, bitmask<br>[02] Origine e stato dello scontrino (bitmask)<br>[03] Bitmask origine (bit usati in zona)<br>[04] Bit di origine/stato del ticket<br>[05] Bitmask di origine e storia del lotto<br>[06] Codice di origine del ticket: 2056 = rimborso di prenotazione annullata<br>[09] Origine e stato del ticket (bitmask) | [01] 1 contati da MT Galileo (usato anche per punti scaricati dalla card ECL e raccolte card); 2 esterni; 4 manuali; 8 resi; 16 somma (scontrino totale); 32 resto; …<br>[02] 1 contato MT Galileo; 2 esterno; 4 manuale (6 convalidato); 8 reso; 16 somma; 32 resto; 64 bonus; 128 sommato; 256 caricato su card; 512 passato ad altra card;…<br>[03] 64 bonus/omaggio, 512 passato ad altra card, 1024 acquisito da altra card, 4096 cancellato da operatore, 16384 Silver/Gold<br>[04] 64 bonus su ricarica; 512 passato ad altra card; 8256 ticket automatici da partita<br>[05] 1 MT Galileo; 2 esterno; 4 manuale; 6 convalidato; 8 reso; 16 somma; 32 resto; 64 bonus; 128 sommato; 256 caricato su card; 512 passato ad altra card; 1024 acq…<br>[06] 2056<br>[09] 1 MT Galileo collegata; 2 esterno; 4 manuale; 6 convalidato; 8 reso; 16 somma; 32 resto; 64 bonus; 128 sommato; 256 caricato su card; 512 passato ad altra card… | Module1.bas:100-112, 6570, 8647, 8660, 11747, 11784<br>Module1.bas:100-112; API.bas:317-323; Module6.bas:2047<br>fn_decode_mt_bitmask; FrmUCard.frm:792,835; FrmDeCli.frm:4884<br>FrmCCard.frm:2876; FrmUCardECL.frm:2286; scriviTicketsAutomatici.sql<br>frmDScon.frm:622-670; Module1.bas:100-112; fn_decode_mt_bitmask.sql; …<br>FrmPreLis.frm:649; FrmPreCon.frm:539<br>Module6.bas:1719-1727; frmrapp.frm:6146; fn_decode_mt_bitmask.sql; sc… | V |
| `NumTrans` | [01] Numero di serie dello scontrino<br>[02] Numero di serie scontrino<br>[05] Numero di serie dello scontrino | [01] CalcSerNum: cifra finale dell'anno × 10^8 + 1 + secondi dall'inizio dell'anno<br>[02] cifra anno*10^8 + secondi dall'inizio anno<br>[05] 9 cifre da MT; CalcSerNum = ultima cifra anno + 00000001 + secondi dall'1/1 (unico al secondo) | Module6.bas:887-905<br>Module6.bas:887-903<br>Module6.bas:887-903 | V |
| `TPagati` | [01] Punti già consumati del lotto, oppure lock<br>[02] Ticket già usati<br>[05] Ticket già spesi del lotto oppure lock di postazione<br>[09] Ticket dello scontrino gia spesi | [01] 0..NumTickets; negativo = scontrino bloccato dalla postazione −IdPost (−(IdPost+1+n) nel sistema 4 utenti)<br>[02] 0 disponibile; =NumTickets consumato; negativo = bloccato dalla postazione -IdPost<br>[05] 0..NumTickets; -IdPost = bloccato dalla cassa; -(IdPost+1+n) = bloccato dal riquadro n del sistema 4 utenti (può collidere)<br>[09] residuo = NumTickets - TPagati | Form1.frm:8328, 15396-15403, Module1.bas:148-149<br>Module1.bas:148; Module8.bas:102<br>Module8.bas:86,102; Frm4Usr.frm:4713; Module1.bas:148-149<br>frmrapp.frm:2750; Module6.bas:1886-1905 | V |
| `DataOut` | [02] Data consumo o caricamento manuale su card<br>[05] Data dell'ultimo uso: consumo, somma o caricamento su card<br>[09] Data dell'ultimo pagamento (uso) dello scontrino | [05] 1899-12-30 = mai usato (data zero VB6 scritta da AddScon senza parametro); NULL per righe da procedure SQL<br>[09] DataOut > Data per vita media | Module1.bas:152; Module6.bas:1893<br>ModAddNew.bas:61,78; frmDScon.frm:527; Module1.bas:152<br>frmrapp.frm:2756; frmrapp.frm:2739 | V |
| `Oper` | [02] Operatore di emissione<br>[05] Operatore che ha emesso il lotto<br>[09] Operatore che ha registrato il ticket | [05] Operatori.Id; 0 da procedure SQL<br>[09] >=1000 operatori virtuali (Prize Hub), esclusi da Letti | ModAddNew.bas:79<br>ModAddNew.bas:79<br>FrmRappUs.frm:1903; Module6.bas:1728 | V |
| `OperOut` | [02] Operatore del consumo<br>[05] Operatore dell'ultimo uso<br>[09] Operatore che ha pagato (scalato) il ticket |  | Module6.bas:1892<br>FrmCTickets.frm:1128; Form1.frm:16641<br>FrmRappUs.frm:1895; Module6.bas:1892 | V |
| `NonCont` | [01] Escluso dal conteggio "ticket di oggi"<br>[02] Scontrino da non contare<br>[05] Escluso dai conteggi dei ticket vinti<br>[09] Ticket da non conteggiare nei totali (gia conteggiato altrove, es. scontrino sommato) | [01] 1 per resto, totale, scontrini da sistema 4 utenti<br>[02] resto, bonus, scontrino totale<br>[05] 1 resto, totale, acquisiti, Silver-Gold, annullati, bonus ricarica; 0 contati, esterni, manuali, resi, bonus 24h<br>[09] 0/1 | Form1.frm:6570, 8660, Module1.bas:3448<br>Module1.bas:119-120<br>FrmDeCli.frm:4292; Module6.bas:1719-1724; Module1.bas:119<br>Module6.bas:1719-1727; API.bas:309-311 | D/V |
| `Id` | [01] Postazione che ha creato il lotto (IdPost)<br>[02] Postazione<br>[05] Dispositivo o postazione di origine<br>[09] Numero della mangia-ticket o postazione che ha emesso/contato lo scontrino | [02] IDPost<br>[05] n. mangia-ticket (<100); IdPost per emissioni di cassa; 1 manual tickets e SP; 0 ticket station/convalidati (bug: variabile non valorizzata)<br>[09] 0 nessuna; 101-110 postazione manuale N=Id-100; FrmRappUs forza 1 se nullo | Form1.frm:6570<br>ModAddNew.bas:82<br>ModAddNew.bas:82; FrmCTickets.frm:1136-1142; FrmRappUs.frm:1809-1840<br>frmrapp.frm:2630-2690; FrmRappUs.frm:1823; ModAddNew.bas:82 | V |
| `Aux` | [01] Scontrino ausiliario, escluso da saldi<br>[02] Scontrino di mangiatickets ausiliaria<br>[05] Conteggio dall'ingresso ausiliario del mangia-ticket, escluso dai saldi<br>[09] Ticket da ingresso ausiliario della mangia-ticket (chips/gettoni); escluso da residui e conteggio per MT; corretto a multipli di 5 dal Rapporto Vendite | [01] sempre 0 nelle scritture di Form1<br>[02] escluso dai saldi<br>[05] 1 = ausiliario; WinMT scrive sempre 0<br>[09] 0/1 | Form1.frm:17201<br>Module6.bas:1726<br>Module6.bas:1726; frmrapp.frm:5976; FrmRappUs.frm:1781<br>frmrapp.frm:5976; frmrapp.frm:2630; frmrapp.frm:2750 | D/V |
| `NRep` | [01] Reparto<br>[02] Reparto<br>[05] Reparto del lotto<br>[09] Reparto di provenienza nei 4 bit bassi | [01] 1 per manuali e raccolte<br>[02] bit bassi (And 15)<br>[05] 0 Redemption; 1..8 = n-esimo reparto non vuoto fra Setup.NRep2..NRep9 (101); 1 per manual tickets e raccolte; report usano NRep And 15<br>[09] NRep and 15 = 1..8; 1 = raccolta card Mistral | Form1.frm:6606, ModAddNew.bas:1072<br>Module6.bas:1739<br>frmDScon.frm:574-577; FrmRepTick.frm:765-773<br>Module6.bas:1739; frmrapp.frm:5919 | V |
| `NImp` | Numero impianto della sala | valsets.Nimp in tutte le scritture WinMT; 0 nelle righe da procedure SQL e dallo scrittore esterno dei ticketless (terzo delle righe in produzione) | ModAddNew.bas:85; scriviTicketsAutomatici.sql:52 | V |
| `F0` | [02] Con N0>0: 1 punti ricevuti da altra sala, 0 pagati in altra sala<br>[05] Direzione dello scambio punti multi-sala<br>[09] Verso del movimento extra locale | [05] 1 ricevuti (rExtra), 0 pagati (pExtra) quando N0>0<br>[09] 1 = Avere (ricevuti); 0 = Dare (pagati) | Module6.bas:1725-1727<br>Module6.bas:1725-1735<br>Module6.bas:1725-1727 | D |
| `T0` | [01] Etichetta del lotto<br>[02] Prefisso raccolta o MANUAL TICKETS<br>[05] Etichetta del lotto<br>[09] Testo: 'MANUAL TICKETS' per ticket manuali oppure prefisso raccolta card (2 car.) + punti serie dalla 4a posizione | [01] 'MANUAL TICKETS'; prefisso della raccolta, barra verticale, punti della serie<br>[02] PrefRacc\|PuntiSerie<br>[05] 'MANUAL TICKETS'; 'prefisso\|punti serie' per raccolte card (es. MS\|0); NULL | Form1.frm:17348, 6606<br>Form1.frm:6606; ModAddNew.bas:1074<br>ModAddNew.bas:1074; FrmCTickets.frm:1162<br>frmrapp.frm:6096; frmrapp.frm:6028; frmrapp.frm:6044; ModAddNew.bas:86 | V |
| `N0` | [01] Sala che ha consumato i punti (multi-sala)<br>[02] Sala collegata che ha usato i punti<br>[05] Sala che ha consumato i punti (multi-sala)<br>[09] ID (numero DB cloud) del locale collegato in cui i punti sono stati usati | [02] id locale<br>[05] id sala<br>[09] >0 solo in multi-locale | Module1.bas:156<br>Module1.bas:156; Module6.bas:1732<br>Module1.bas:156; Module6.bas:1732<br>Module6.bas:1730-1737 | D/V |
| `D0` | [01] Lotto Gold (modalità Golden)<br>[02] Punti gold (variante Golden)<br>[03] Qualita del punto<br>[05] Lotto Gold (modalità Golden)<br>[09] Valorizzato per ticket Gold | [01] non nullo = punti Gold<br>[02] NULL = silver<br>[03] NOT NULL = Gold (data di conversione), NULL = Silver<br>[05] non nullo = Gold; nullo = Silver<br>[09] data o NULL | ModAddNew.bas:87, 17221<br>ModAddNew.bas:87; Module6.bas:1923,1946<br>FrmSil2Gld.frm:530-534; Module8.bas:432-435<br>ModAddNew.bas:87; Form1.frm:17201,17221<br>ModAddNew.bas:87; Module6.bas:1923-1946 | V |
| `F1` | Flag ticket ticketless generato da gioco ECL | 1 insieme a T1; non scritto da WinMT VB | FrmDeCli.frm:5042,5175 | D |
| `T1` | [05] Device ECL che ha generato il ticket ticketless<br>[09] Nome della campagna dei punti da APP | [05] EcsMacchine.device (fino a 7 car.)<br>[09] '??' se nullo | FrmDeCli.frm:5042,5175; frmrapp.frm:6146<br>frmrapp.frm:6146 | V |
| `Data / DataOut / Oper / OperOut` | Creazione e consumo del lotto, con operatori |  | Module6.bas:1877-1910 | V |

### Prenotaz

| Colonna | Significato | Valori | Evidenza | Cert. |
|---|---|---|---|:-:|
| `IdOp` | [01] Operatore che ha creato<br>[06] Chi ha creato la riga<br>[09] Operatore della prenotazione | [01] 1009–1018 = totem (operatori ≥ 1000)<br>[06] operatore di cassa; 1009-1018 = totem/kiosk | Form1.frm:7488, 14734, Module1.bas:9<br>Form1.frm:7488; FrmPreCon.frm:412<br>frmrapp.frm:2503 | D/V |
| `IdCli` | Cliente | IdContatto (IdLong in multilocale); 0 = senza card | Form1.frm:6150; Form1.frm:6446 | V |
| `N_Tickets` | Ticket pagati per pezzo dopo sconti promo/bonus | rimborsati all'annullamento (un solo pezzo) | Form1.frm:6111; FrmPreLis.frm:642-647 | V |
| `NomeC` | Nome cliente senza card |  | FrmInDat.frm:157 | V |
| `CognomeC` | Cognome cliente senza card |  | FrmInDat.frm:158 | V |
| `Tel` | Telefono cliente senza card |  | FrmInDat.frm:159 | V |
| `DataCon` | Data di consegna o annullamento | NULL alla creazione | FrmPreCon.frm:744; FrmPreLis.frm:628 | V |
| `Cons` | [06] Riga chiusa (consegnata o annullata)<br>[09] Prenotazione consegnata | [06] 0/1<br>[09] 0 = in attesa | FrmPreCon.frm:743<br>frmrapp.frm:2503 | V |
| `IdOpCo` | [01] Operatore di consegna, o marcatore temporaneo<br>[06] Operatore di consegna/annullamento e stato temporaneo | [01] −2 consegnabile, −1 non consegnabile (ricalcolati a ogni cliente); 5555 = prenotazione senza card<br>[06] -1 non consegnabile; -2 consegnabile (azzerati a 0); 5555 alla creazione senza card | Form1.frm:17065-17070, 6446<br>Form1.frm:17065-17070; Form1.frm:17366; Form1.frm:6446 | V |
| `Quantita` | [01] Quantità e tipo<br>[06] Pezzi con segno di stato | [01] < 0 prenotazione (premio non ancora disponibile); > 0 ordine consegnabile quando c'è giacenza<br>[06] <0 prenotazione (premio non disponibile); >0 ordine (prenotazione confermata, totem, app) | Form1.frm:6150, 14722, 16920-16925<br>Form1.frm:6150; FrmPreLis.frm:533 | D/V |
| `SerNum` | [01] Codice dello scontrino di prenotazione<br>[06] Numero della ricevuta stampato come barcode P<hex8>R | [01] (IdPost − 100) × 100000001 + secondi da data base; barcode P+hex+R<br>[06] (IdPost-100)*100000001 + secondi dal 01/01/2008 + centesimi | Form1.frm:6149, 15903<br>Form1.frm:6149; FrmPreCon.frm:583-584; FrmTotPre.frm:283 | V |
| `Conf` | Sempre 1 alla creazione; tutte le liste filtrano conf=1; la conferma usa il segno di Quantita | 1 | Form1.frm:6150 | V |
| `MsgInv` | Messaggio inviato al cliente | 1 alla creazione e all'annullamento | ModAddNew.bas:876; FrmPreLis.frm:631 | D |
| `Annul` | Annullata con rimborso | 0/1 | FrmPreLis.frm:629 | V |
| `DataConf` | Data di conferma della disponibilita (la prenotazione diventa ordine) | - | FrmPreLis.frm:534 | V |
| `F0` | [01] Ordine da totem preparato<br>[06] Ordine preparato (distinta stampata) | [01] 0 = da preparare<br>[06] 0/1 | Form1.frm:7488, 14734<br>FrmPrePre.frm:397 | V |
| `T0` | [01] Numero d'ordine<br>[02] Numero ordine<br>[06] Numero d'ordine che raggruppa piu righe (totem/app) | [06] 0 dalla cassa | ModAddNew.bas:881<br>ModAddNew.bas:881<br>FrmPrePre.frm:393-397; ModAddNew.bas:879 | V |
| `F1` | [01] Sala in gruppo multi-sala<br>[02] Sala multi-locale<br>[06] Cliente multilocale | [06] isMultilocale | ModAddNew.bas:882<br>ModAddNew.bas:882<br>ModAddNew.bas:880 | V |
| `NomeC, CognomeC, Tel` | Copia dei dati del cliente |  | ModAddNew.bas:869-871 | V |

### TransCard

| Colonna | Significato | Valori | Evidenza | Cert. |
|---|---|---|---|:-:|
| `IdCli` | [02] Cliente<br>[04] Cliente del movimento | [02] IdContatto; IdLong se multi-locale<br>[04] IdContatto come testo (IdLong se multilocale); 0 per svuotamento cassa principale; id operatore per azzeramento cassa operatore | Form1.frm:15959; ModuleMultilocale.bas:2<br>ModAddNew.bas:1120; aggiornaCard.sql; frmCassa.frm:3451, 3978 | V |
| `NImp` | [01] Tipo di operazione (non il numero di impianto)<br>[02] Tipo di operazione (NON numero impianto)<br>[03] Tipo di movimento card<br>[04] Tipo di operazione (non impianto)<br>[05] Tipo di operazione su card<br>[08] Tipo di operazione (letto e scritto nella zona) | [01] 0 cassa fissa, 1 totem, 2 cassa mobile, 3 scarico al totem, 4 hopper vuoto, 5 dobloni/gettoni, 6 bonus, 7 svuotamento cassa, 8 rimborso, 9 omaggio, 10/11 credi…<br>[02] 0 carico cassa fissa; 1 carico totem; 2 carico cassa mobile; 3 scarico su totem (gettoni/monete); 4 carico per hopper vuoto; 5 dobloni Astoria/gettoni Albarell…<br>[03] 0 cassa,1 totem,2 cassa mobile,3-5 scarichi/dobloni,6 bonus,7 svuotamento,8 rimborso,9 omaggio,10/11 trasferiti/acquisiti,12 rimborso operatore,13 ricarica com…<br>[04] NULL partita; 0 cassa fissa; 1 totem; 2 cassa mobile; 3 vendita gettoni/scarico totem; 4 carico hopper vuoto; 5 dobloni/gettoni (Astoria/Albarella, EXCHANGE); …<br>[05] 0 carico cassa; 1 totem; 2 cassa mobile; 3 scarico totem; 4 hopper vuoto; 5 dobloni/gettoni/rimborso gettoni; 6 bonus; 7 svuotamento; 8 rimborso; 9 omaggio; 10…<br>[08] NULL consumo su macchina; 0,1,2 ricariche (2 cassa mobile); 5 dobloni; 6 bonus; 7 svuotamento cassa; 8 rimborsi; 9 rimborsi/resi | ModAddNew.bas:1091-1110<br>ModAddNew.bas:1091-1110,1129,1378-1389,1650<br>ModAddNew.bas:1090-1110,1641-1655<br>ModAddNew.bas:1091-1110, 1630, 1650; frmInfoTransazioni.frm:385-402; …<br>ModAddNew.bas:1091-1110; FrmCCard.frm:2846-2891<br>frmIncAmm.frm:903-949; FrmEcs.frm:3006,3858-3894 | V/V … |
| `CodMac` | [01] Postazione (computername) per le operazioni di cassa e totem; 'SVUOTAMENTO'; codice del gioco per le partite<br>[02] Per operazioni WinMT: nome computer della postazione; per le giocate codice macchina<br>[04] Origine del movimento<br>[08] Macchina del consumo; 'SVUOTAMENTO' per lo svuotamento cassa | [02] Environ(computername)<br>[04] WinMt=1: nome computer della postazione; 'SVUOTAMENTO'; WinMt=0: EcsMacchine.CodMac<br>[08] testo | ModAddNew.bas:1121, frmCassa.frm:3977<br>ModAddNew.bas:1121<br>ModAddNew.bas:1121; aggiornaCard.sql; frmCassa.frm:3978<br>FrmEcs.frm:3006 | V |
| `Data` | [01] Data inserita come testo dd/mm/yyyy hh:nn:ss<br>[04] Data e ora operazione | [01] dipende dalla lingua del login SQL<br>[04] da WinMT testo dd/mm/yyyy hh:nn:ss (dipende da DATEFORMAT); dai giochi data BE o GETDATE() | ModAddNew.bas:1122 (formato data)<br>ModAddNew.bas:1122; decodifica_record.sql:380-402 | V |
| `ValoreOperazione` | [02] Importo del movimento in valuta<br>[04] Importo operazione in valuta | [02] segno per tipo<br>[04] positivo carichi, negativo storni/ritiri; partite = costo partita convertito | ModAddNew.bas:1123<br>ModAddNew.bas:1123; aggiornaCard.sql | V |
| `ValoreFinale` | [01] Saldo della card dopo l'operazione, in valuta<br>[02] Saldo della card dopo il movimento, in valuta<br>[04] Saldo card (crediti+bonus) in valuta dopo l'operazione | [01] base di VerificaCard e della rigenerazione<br>[02] ValoreFinale/CentConversionFactor = centesimi<br>[04] l'ultimo per N0 è il saldo di riferimento | Module6.bas:2236-2300<br>ModAddNew.bas:1135; Module6.bas:2309<br>ModAddNew.bas:1124; ECL_cliente.cls:397 | V |
| `ValoreBonus` | [02] Quota bonus del movimento<br>[04] Quota bonus | [02] scritta solo da addVenditaGettoni; sottratta per le giocate<br>[04] partite: bonus consumato; vendita gettoni: bonus scalato; altrimenti 0 | ModAddNew.bas:1691,1385<br>aggiornaCard.sql; ModAddNew.bas:1696 | V |
| `F0` | [01] Sala in gruppo multi-sala<br>[02] Sala in gruppo multi-locale<br>[03] Flag multi-locale (incoerente)<br>[04] Flag multilocale al momento della scrittura | [02] 1 sì / 0 no<br>[03] AddTransCard: 1 se multi-locale; frmAstoria: 1 se sala singola<br>[04] 1 se Setup(101).T6 indica multilocale | ModAddNew.bas:1131<br>ModAddNew.bas:1131<br>ModAddNew.bas:1131; frmAstoria.frm:5878,5901<br>ModAddNew.bas:1131 | V |
| `T0` | [01] Numero di impianto (sala), 4 cifre<br>[02] Numero impianto<br>[03] Impianto che ha scritto il movimento<br>[04] Codice sala/impianto | [02] 4 cifre con zeri (es. 0196)<br>[03] codice impianto a 4 cifre<br>[04] valsets.Nimp su 4 cifre | ModAddNew.bas:1130<br>ModAddNew.bas:1130<br>ModAddNew.bas:1130; frmAstoria.frm:5879<br>ModAddNew.bas:1130 | V |
| `N0` | [01] Progressivo della card<br>[02] Progressivo di transazione della card<br>[04] Progressivo di transazione della card (anti-replay) | [02] crescente per card<br>[04] ricarica: progressivo dopo scrittura; riga bonus: progressivo-1; +2 per scrittura crediti+bonus; partite: progressivo BE | Form1.frm:15959, Module6.bas:2250-2280<br>ModAddNew.bas:1128; Module6.bas:2300<br>FrmCCard.frm:2846, 2852; FrmUCardECL.frm:1737; decodifica_record.sql:… | V |
| `D0` | [01] Data di azzeramento della cassa che comprende il movimento<br>[03] Chiusura di cassa<br>[04] Data di chiusura (svuotamento) cassa | [01] nullo = movimento non ancora azzerato<br>[03] NULL = movimento non ancora chiuso<br>[04] NULL = non ancora chiuso; valorizzata in blocco allo svuotamento | frmCassa.frm:3419, 3450-3453<br>frmAstoria.frm:5065-5070<br>frmCassa.frm:3449, 3976; frmRappCard.frm:2327 | V |
| `Operatore` | [01] Operatore<br>[02] Id operatore<br>[04] Operatore del movimento | [01] < 1000 postazione, ≥ 1000 totem<br>[02] <1000 postazione, >=1000 totem<br>[04] id Operatori; <1000 postazione, >=1000 totem | Module1.bas:9<br>Module1.bas:9<br>Module1.bas:7-9; frmRappCard.frm:2011-2014 | V |
| `ValoreCassa` | [01] Contante incassato (importo meno quota POS)<br>[04] Parte incassata in contanti | [01] somma dei D0 nulli = contenuto della cassa<br>[04] ValoreOperazione-ValoreCassa = POS; 0 = POS o non monetario; negativo nel ritiro card; svuotamento = importo | FrmCCard.frm:2852, frmCassa.frm:3419<br>FrmCCard.frm:2852; frmCassa.frm:2766, 3071-3073 | V |
| `WinMt` | [01] Operazione di cassa o totem<br>[02] Operazione da postazione o totem<br>[04] Origine applicativa | [01] 1 sempre da AddTransCard; 0 dal circuito dei giochi<br>[02] 1<br>[04] 1 = postazione o totem; 0 = partita da gioco (trigger aggiornaCard) | ModAddNew.bas:1127, Module1.bas:7-9<br>ModAddNew.bas:1127; Module1.bas:8<br>Module1.bas:7-8; ModAddNew.bas:1127 | V |
| `IDOperazione` | Chiave GUID del movimento | usata dallo storno per DELETE | frmInfoTransazioni.frm:778 | V |
| `FlagOpDaVerificare` | [02] Movimento non verificato<br>[04] Partita non ancora confermata dalla card | [02] NULL = verificato<br>[04] 1 = provvisoria (sostituita dalla conferma tipo 23); NULL = confermata o movimento di cassa | Module6.bas:2256; ModAddNew.bas:1397<br>decodifica_record.sql:278-291; Module6.bas:2256 | V |

### Compleanni

| Colonna | Significato | Valori | Evidenza | Cert. |
|---|---|---|---|:-:|
| `ModalitaTickets` | Destinazione delle vincite degli ospiti | A e-ticket al giocatore, B e-ticket al festeggiato (default), C nessun ticket, D cartacei; D -> N0=0 altrimenti 1 | frmCompleanni.frm:2986-2997; clsCompleanno.cls:839-845 | V |
| `MaxPartitePerCard` | Limite di partite per card ospite | 0-50; applicato fuori da WinMT | frmCompleanni.frm:1820-1822 | D |
| `PartiteConsecutive` | Limite di partite consecutive | 0-50; applicato fuori da WinMT | frmCompleanni.frm:1820-1822 | D |
| `NrSecondiResetConsecutive` | Secondi dopo cui si azzera il conteggio consecutivo | 0-3600 | frmCompleanni.frm:1820-1822 | D |
| `Partecipanti` | Ospiti previsti | int; limite all'emissione delle card ospite | clsCompleanno.cls:607-655; frmCompleanni.frm:2375-2533 | V |
| `ValorePrecaricatoCrediti` | Crediti precaricati su ogni card ospite | centesimi, da TipoRicaricheCompleanni | frmCompleanni.frm:1474-1492 | V |
| `CardId` | Card del festeggiato | primo ospite registrato; '' se scollegata | clsCompleanno.cls:684-695,1017-1025 | V |
| `IdContatto` | Cliente festeggiato | primo ospite registrato | clsCompleanno.cls:684-695 | V |
| `ImportoCompleanno` | Valore dell'evento | somma TransCard.ValoreOperazione NImp=13 degli ospiti | clsCompleanno.cls:381-435 | V |
| `AccontoVersato` | Acconto versato | manuale | clsCompleanno.cls:485-527 | V |
| `EmailGenitore1` | Contatto del genitore | usato per inviare i redeem code | frmCompleanni.frm:1625-1650 | V |
| `CreatedBy` | Audit | non scritto da clsCompleanno | clsCompleanno.cls:485-580 | V |
| `ValorePrecaricatoBonus` | Bonus precaricato su ogni card ospite | centesimi, da TipoRicaricheCompleanni | frmCompleanni.frm:1474-1492 | V |
| `IdRicarica` | Tipologia di ricarica scelta | riferimento logico a TipoRicaricheCompleanni.id | frmCompleanni.frm:1474-1492 | V |

### UltimoInventario

| Colonna | Significato | Valori | Evidenza | Cert. |
|---|---|---|---|:-:|
| `qagg` | Quantita' caricata nel periodo (MovMag causale CARICO/LOAD) | int | FrmInventario.frm:4684-4694 | V |
| `qvend` | Premi consegnati nel periodo = numero di righe di Vincite (v1: Cons=1 e D0 nel periodo; v2: Data nel periodo); una riga = un pezzo | int | FrmInventario.frm:4879-4884; cls_inventario.cls:617-624 | V |
| `qini` | Quantita' iniziale = qreal dell'inventario precedente (per codice o CodOr); 0 se articolo nuovo; Premi.Quantita al primo inventario | int | FrmInventario.frm:4656-4675; cls_inventario.cls:546 | V |
| `Gru` | Copia di Premi.Gru, non usata nei calcoli | bit | FrmInventario.frm:4922 | V |
| `qmacc` | Quantita' dichiarata nelle macchine: solo informativa, non entra in qreal ne' qdiff | int | FrmInventario.frm:3083-3094 | V |
| `qpres` | Quantita' presunta = qini + entrate - uscite - qvend | int | FrmInventario.frm:4914; cls_inventario.cls:632 | V |
| `qreal` | Quantita' reale: inizialmente = qpres, poi il contato; articoli non contati restano al teorico (anche con Inv0) | int | FrmInventario.frm:4915, 4975-4979, 3107 | V |
| `dos` | Giorni di autonomia = qreal / (qvend / giorni dall'ultimo inventario); 999 se nessuna vendita | decimal | FrmInventario.frm:4929-4933 | V |
| `*` | Tabella di lavoro della versione 2 (creata e svuotata a runtime): ultimo inventario JSON espanso; stesse colonne della tabella inv del file Access | vedi colonne q* | cls_inventario.cls:648-775 | V |
| `key, oper, data, NBolla, foto` | Operatore (idx) e data dell'inventario; key = 1 fisso in v2; NBolla e foto vuoti |  | FrmInventario.frm:4927-4928; cls_inventario.cls:521-531 | V |
| `qdiff` | Variazione = contato - presunto (negativo = ammanco) | int | FrmInventario.frm:3106 | V |
| `qtrasin, qgrui, qconi, qevei, qpushi` | Entrate nel periodo da MovMag per causale: SPOSTA, GRU, CONSUMABILI, EVENTI, RUSPE | int | FrmInventario.frm:4697-4765 | V |
| `qtrasout, qguasta, qgruo, qcono, qeveo, qpusho` | Uscite nel periodo da MovOut per causale: SPOSTA, GUASTO, GRU, CONSUMABILI, EVENTI, RUSPE | int | FrmInventario.frm:4768-4870 | V |

### CoinlessTestataHappyHour

| Colonna | Significato | Valori | Evidenza | Cert. |
|---|---|---|---|:-:|
| `giorno` | Giorno della settimana | -1 = ogni giorno; altrimenti indice lista-1 confrontato con DATEPART(dw): possibile sfasamento | frmEclHH.frm:3965-3968; vs_CoinlessSpecialTimes.sql | D |
| `ampm` | Mattino/pomeriggio | 'a' se ora inizio <13, 'b' altrimenti | frmEclHH.frm:3960-3964 | V |
| `dalle` | Ora inizio | HH:MM | frmEclHH.frm:4535 | V |
| `alle` | Ora fine | HH:MM | frmEclHH.frm:4535 | V |
| `attivo` | Abilitazione | 1 attiva; 0 alla duplicazione | frmEclHH.frm:4535, 4640 | V |
| `platinum` | Prezzo HH predefinito livello Platinum | centesimi | frmEclHH.frm:4129 | V |
| `gold` | Prezzo HH predefinito livello Gold | centesimi | frmEclHH.frm:4128 | V |
| `silver` | Prezzo HH predefinito livello Silver | centesimi | frmEclHH.frm:4127 | V |
| `normal` | Prezzo HH predefinito livello Compleanno (BDAY) | centesimi | frmEclHH.frm:4130, 3970 | V |
| `dal` | Inizio periodo validità | data | vs_CoinlessSpecialTimes.sql | V |
| `al` | Fine periodo validità | data | vs_CoinlessSpecialTimes.sql | V |
| `T0` | Nome template grafico per le schede | default HappyHours | frmEclHH.frm:4535; vs_CoinlessSpecialTimes.sql | V |

### MovMag

| Colonna | Significato | Valori | Evidenza | Cert. |
|---|---|---|---|:-:|
| `Codice` | Codice articolo al momento del carico | non aggiornato su ricodifica o cancellazione | ModAddNew.bas:204-235 | V |
| `Quantita` | Pezzi caricati, sempre positivi | - | ModAddNew.bas:217 | V |
| `Data` | Data del carico | data scelta + ora; non anteriore all'ultimo inventario | FrmMovmag.frm:2496 | V |
| `Oper` | Operatore (Operatori.Id) | - | FrmLismovN.frm:4591 | V |
| `Fornitore` | Fornitore della merce | testo | ModAddNew.bas:216 | V |
| `Costo` | Costo unitario del carico (valore = Costo x Quantita) | EUR | frmWrapp.frm:3466 | V |
| `NBolla` | [02] CRddmmyyhhmmss per carichi remoti<br>[06] Numero documento | [06] MANU; AU+12 car. nome file; CR+ddmmyyhhmmss; bolla digitata; numero ordine (carico da ordine); numero consegna (FrmSiteIn); MANU_<slot> | Module1.bas:45<br>frmpremi.frm:2534; FrmMovmag.frm:3370-3384; FrmCariPO.frm:962; FrmSit… | V |
| `Motivo` | [06] Causale di carico, testo dipendente dalla lingua<br>[07] Causale del carico scritta nella lingua dell'interfaccia<br>[09] Causale del carico, testo nella lingua dell'interfaccia confrontato con LIKE '%X' | [06] CARICO/LOAD/CHARGE; GRU, CONSUMABILI, EVENTI, RUSPE (rientro da reparto); SPOSTA/TRANSFER/TRANSFERT (da altro locale); PRIZEHUB<br>[07] IT CARICO/SPOSTA/GUASTO/GRU/CONSUMABILI/EVENTI/RUSPE; EN LOAD/TRANSFER/WASTE/CRANES/CONSUMABLES/EVENTS/PUSHERS; FR CHARGE/TRANSFERT/GRUES/CONSOMMABLES/EVENEMEN…<br>[09] CARICO, GRU, GUASTO, SPOSTA, CONSUMABILI, EVENTI, RUSPE (+ EN/FR) | FrmLismovN.frm:4178-4203; FrmMovmag.frm:3714-3798; FrmSiteIn.frm:1276…<br>FrmInventario.frm:4383-4491; PrizeHub_MoveToSlot.sql<br>frmWrapp.frm:3466; frmWrapp.frm:4437-4531 | V |
| `Note` | Nota libera o locale di origine | SPOSTA: nome locale; Carico manuale/Automatico/Remoto | FrmMovmag.frm:2610; FrmLismovN.frm:4507-4511 | V |
| `NOrdine` | Secondo numero documento (ordine o consegna), semantica invertita tra flussi | - | FrmCariPO.frm:900; FrmCariPO.frm:962; FrmSiteIn.frm:1287 | V |
| `T0` | Solo Prize HUB: codice articolo controparte | - | PrizeHub_MoveToSlot.sql:72-74 | V |
| `CodOr,Descrizione,Costo,N_Tickets` | Fotografia dell'anagrafica al momento del carico | Costo*Quantita = valore nei report | FrmLismovN.frm:4589-4615 | V |

### Operatori

| Colonna | Significato | Valori | Evidenza | Cert. |
|---|---|---|---|:-:|
| `Id` | [02] 9999 = operatore tecnico Galileo App<br>[09] Id 1001-1008 = operatori virtuali dei Prize Hub 1-8 (nome contiene 'Prize Hub')<br>[10] Identificativo: 0 amministratore di sistema (non modificabile); 1-999 operatori; 9999 Galileo App; >=1000 totem/Prize Hub | [02] creato se sincronizzazione attiva<br>[10] intero | Module1.bas:2725-2727<br>frmrapp.frm:5060-5080<br>frmgesop.frm:606, 1116; Module1.bas:2722-2730, 9 | V |
| `Password` | Password offuscata MTCry (reversibile); minimo 4 caratteri; password predefinita scritta nel codice per i nuovi | testo | frmLogin1.frm:1356-1373; frmgesop.frm:861, 939 | V |
| `Data` | [01] Creazione della card magnetica dell'operatore<br>[10] Data/ora di emissione della card magnetica, scritta sulla card e confrontata al login | [10] datetime | Form1.frm:12546<br>frmgesop.frm:1320-1335; Form1.frm:12550 | V |
| `Livello` | [01] Ruolo<br>[02] Ruolo<br>[07] Livello per autorizzare la chiusura dell'inventario<br>[09] Livello di accesso; Livello and 3: 0-1 admin/manager, >=2 operatore<br>[10] Ruolo | [01] And 3 → 0..3; LvLx < 2 gestione, LvLx = 0 superadmin report<br>[02] And 3: 0 amministratore, 1 manager, 2 operatore, 3 supervisore<br>[07] 0 = amministratore, 1 = manager<br>[10] 0 Amministratore, 1 Manager, 2 Operatore, 3 Supervisore | Form1.frm:11384, 8149<br>Form1.frm:11384; Module6.bas:189-449<br>FrmInventario.frm:2446<br>Form1.frm:11384; frmrapp.frm:5118-5123<br>frmgesop.frm:1192-1195; Module6.bas:189-420 | D/V |
| `CodBar` | [01] Barcode di login<br>[10] Barcode della card operatore usato per il login; svuotato alla disattivazione | [10] CD/JV + 9 caratteri | Form1.frm:14429<br>frmgesop.frm:647-676, 747; Form1.frm:14429 | V |
| `Attivo` | Operatore attivo; la cancellazione lo porta a 0; la lettura del suo barcode lo riattiva | bit | frmgesop.frm:746; Form1.frm:17239-17242 | V |
| `Foto` | [04] Limiti giornalieri in JSON (non foto)<br>[10] Riusata: JSON dei limiti giornalieri {MaxRefundsPerDay, MaxFreeTicketsPerDay, MaxServiceCreditsRefundsPerDay} come varbinary | [04] MaxRefundsPerDay, MaxFreeTicketsPerDay, MaxServiceCreditsRefundsPerDay; controlli non implementati<br>[10] JSON | ECL_operatore.cls:152-208, 173-183<br>ECL_operatore.cls:185-200 | V |
| `NImp` | Codice impianto | intero | frmgesop.frm:613 | V |
| `F0` | [01] Card operatore abilitata a far partire giochi gratis<br>[04] Abilitato ai crediti di servizio<br>[10] Crediti di servizio abilitati (scritto anche sulla card RFID) | [01] StartGame ON/OFF<br>[04] bit<br>[10] bit | Form1.frm:10691-10697<br>ECL_operatore.cls:134<br>frmgesop.frm:868-872, 1006-1010; ECL_operatore.cls:134 | V |
| `T0` | [01] UID della card RFID dell'operatore<br>[02] UID card operatore<br>[10] UID della card RFID ECL dell'operatore | [10] testo | Form1.frm:11373<br>Form1.frm:11373; ModAddNew.bas:317<br>frmgesop.frm:860, 942; Form1.frm:11373 | V |
| `N0` | [01] Abilitazione omaggi e rimborsi<br>[02] Abilitazione omaggi e rimborsi<br>[04] Permessi a bitmask<br>[10] Maschera abilitazioni: 1 rimborsi, 2 omaggi, 4 azzeramento cassa totem, 8 ricariche, 16 visualizzazione movimenti totem, 32 emissione rimborso ticket (non ECL: 0-3) | [04] 1 rimborsi, 2 omaggi, 4 azzeramento cassa totem, 8 carico crediti, 16 visualizzazione movimenti, 32 rimborso ticket<br>[10] bitmask | Module6.bas:2650<br>Module6.bas:2651<br>ECL_operatore.cls:211-218<br>ECL_operatore.cls:212-228; frmgesop.frm:1078-1090 | V |
| `Nome/Id` | Distributori automatici di premi registrati come operatori fittizi | Nome='TotemPrizes', Id 1001-1010, Attivo = abilitato | FrmToPr.frm:238-288 | V |

### Incassi

| Colonna | Significato | Valori | Evidenza | Cert. |
|---|---|---|---|:-:|
| `Data` | Chiusura del conteggio (FineInc) o data della registrazione manuale; il MAX delimita il periodo di sp_incasso | datetime | sp_incasso.sql:29,354 | V |
| `Oper` | Operatore della registrazione manuale; non valorizzato per i conteggi (l'operatore sta nel riepilogo dell'mdb) | Id operatore | ModAddNew.bas:778; FrmCont.frm:8798 | V |
| `Red` | Incasso lordo giornaliero redemption | EUR | frmWrapp.frm:3502 | V |
| `Gru` | Incasso lordo gru (e instant redemption) | EUR | frmWrapp.frm:3503 | V |
| `Alt` | Incasso lordo altre macchine | EUR | frmWrapp.frm:3505 | V |
| `Push` | Incasso lordo ruspe (pusher) | EUR | frmWrapp.frm:3504 | V |
| `F0` | [02] Incasso generato da EcsNet<br>[07] Origine del record<br>[08] Tipo di riga: 1 conteggio macchine con Mdb; 0 registrazione manuale per categoria<br>[09] Record generato da EcsNet | [02] 1<br>[07] 0 = registrazione manuale incassi (FrmInc); 1 = incasso da lettura contatori (FrmCont/EcsNet)<br>[08] 0/1<br>[09] 0/1 | Module1.bas:41<br>Module1.bas:42; FrmCont.frm:10733-10744; FrmInc.frm:740<br>FrmCont.frm:10742; ModAddNew.bas:770-794<br>Module1.bas:41 | V |
| `Mdb` | [02] File .mdb dell'incasso<br>[07] F0=1: file Access Incas.mdb della lettura contatori (i file Access viaggiano nel DB)<br>[08] File Access dell'incasso (tabelle incas, riepilogo, lista, change, Riep_Tipi, Variabili) | [02] blob<br>[07] varbinary(max)<br>[08] varbinary | Module1.bas:41; Module6.bas:1312<br>FrmCont.frm:10724, 10744<br>FrmCont.frm:10732-10750,8700-8818 | V |
| `Red, Gru, Alt, Push` | Incassi lordi per categoria: Redemption; Gru e Instant Redemption; Altri (video, flipper); Ruspe | money | FrmInc.frm:740-743; manuale Registra Incassi | V |
| `Red/Gru/Alt/Push` | Incasso manuale giornaliero di Redemption, Gru, Altro, Ruspe (pusher) | euro lordi | FrmInc.frm:390-664,738 | V |

### LogTransazioniPos

| Colonna | Significato | Valori | Evidenza | Cert. |
|---|---|---|---|:-:|
| `MName` | Dispositivo POS | <modello>_<computer> | FrmCCard.frm:3105 | V |
| `Status` | Stato transazione POS | Pending, Completed, Recovered, Failed | LogTransazioniPos.cls:89; frmInfoPOS.frm:854 | V |
| `uidPOS` | UUID generato da WinMT, chiave verso PosHandler | uuid v4 | FrmCCard.frm:3099 | V |
| `IDTerm` | Ricevuta esercente (merchantReceiptRetailer) | testo | frmInfoPOS.frm:830-839 | V |
| `AId` | Id transazione PosHandler | testo | frmInfoPOS.frm:819-839 | V |
| `Appl` | Ricevuta carta (merchantReceiptCard) | testo | frmInfoPOS.frm:830-839 | V |
| `IC` | dtId della transazione | testo | frmInfoPOS.frm:819-839 | V |
| `PAN` | PAN mascherato (maskedPan) | testo | frmInfoPOS.frm:826, 837 | V |
| `N0` | Progressivo card dopo l'accredito | vuoto = mai caricata | FrmCCard.frm:2867 | V |
| `DataAck` | Data del cambio di stato (diverso da Pending) | datetime | LogTransazioniPos.cls:276 | V |

### RedeemCodes

| Colonna | Significato | Valori | Evidenza | Cert. |
|---|---|---|---|:-:|
| `DbName` | Sala | valsets.Nimp | Form1.frm:7833 | V |
| `Codice` | Codice redeem | 'RD' + 13 esadecimali; univoco con DbName | sp_redeem_create.sql | V |
| `Azione` | Uso del codice | new (nuova card, anonimo), recharge (cliente loggato) | sp_redeem_check_and_reserve_no_pin.sql | V |
| `Valore` | Crediti del codice | valuta | FormCreaRedeem.frm:574-587 | V |
| `CardLevel` | Livello della card da creare | come TipoCard (3 = compleanno) | FormCreaRedeem.frm:578 | V |
| `Pin` | PIN | 4 cifre casuali | sp_redeem_create.sql | V |
| `ReservedOnPost` | Postazione che ha prenotato | IdPost | cls_RedeemManager.cls:105 | V |
| `ReservedOnDevice` | Dispositivo che ha prenotato | nome computer | Form1.frm:7833 | V |
| `ReservationExpiresAt` | Scadenza prenotazione | ora + 5 minuti | cls_RedeemManager.cls:107 | V |
| `QRCode` | Immagine QR | JPEG da servizio esterno | cls_RedeemManager.cls:560, 597 | V |

### RiepInv

| Colonna | Significato | Valori | Evidenza | Cert. |
|---|---|---|---|:-:|
| `Data` | F0=0: istante di riferimento dell'inventario (ora prefissata OrInv del giorno o apertura finestra); F0=1: data della lista | datetime | FrmInventario.frm:3447, 4587-4591 | V |
| `F0` | [02] 1 kit premi inviato da HQ; 0 inventario reale<br>[06] Tipo di record<br>[07] Tipo di record: la tabella ha due usi<br>[09] Tipo di record | [06] 0 = riepilogo inventario; 1 = lista di carico inviata da HQ<br>[07] 0 = inventario; 1 = lista premi (KitPremi) inviata da WinMtHQ per carico remoto<br>[09] 0 = inventario di sala; 1 = kit premi inviato da WinMTHQ | Module1.bas:44; Module6.bas:840<br>Module1.bas:44-46<br>Module1.bas:44; FrmInventario.frm:4604; FrmMovmag.frm:4372-4426<br>Module1.bas:44; frmWrapp.frm:3321 | V |
| `T0` | [06] Nome del file della lista HQ (se F0=1)<br>[07] F0=1: nome della lista remota | [06] -<br>[07] es. <locale>_<ddmmyyhhmmss> | FrmMovmag.frm:4428<br>FrmMovmag.frm:4372, 4430; cls_inventario.cls:210 | V |
| `D0` | [02] Data/ora caricamento del kit<br>[06] Data/ora di carico della lista in sala (se F0=1)<br>[07] F0=0: istante di fine inventario (salvataggio), NULL prima del 10/11/2017; F0=1: istante del carico della lista, NULL = da caricare | [06] NULL = pendente<br>[07] datetime/NULL | Module1.bas:46<br>FrmMovmag.frm:4396<br>FrmInventario.frm:3448, 4607-4611; FrmMovmag.frm:4396; Form1.frm:17181 | V |
| `Mdb` | [02] File .mdb del kit premi<br>[06] File kitpremi.mdb della lista HQ (se F0=1)<br>[07] File Access intero: F0=0 inv.mdb (tabelle inv e riepilogo); F0=1 KitPremi.mdb; nella versione 2 JSON<br>[09] File Access dell'inventario con tabella Inv(qdiff, costo) | [02] blob<br>[06] blob<br>[07] varbinary(max) | Module1.bas:44<br>FrmMovmag.frm:4372-4373<br>FrmInventario.frm:3449, 5155; FrmMovmag.frm:4373; cls_inventario.cls:…<br>frmWrapp.frm:3326-3333 | V |
| `F1` | Usato solo come filtro nella versione 2 (f1=0); significato ignoto | ? | cls_inventario.cls:670 | D |
| `T1` | Usato solo come filtro nella versione 2 (t1 is null); significato ignoto | ? | cls_inventario.cls:300 | D |
| `N1` | Formato di Mdb per gli inventari (versione 2) | NULL o 10 = file Access; 1 = JSON | cls_inventario.cls:113, 204, 1266 | V |
| `F0, D0` | Lista premi inviata da HQ; data di caricamento | F0 = 1, D0 nullo = da caricare | Form1.frm:17181, Module1.bas:44-47 | V |
| `VVend..TotPer, QDiff, VarVal` | Non scritte dal codice attivo: replicano la tabella riepilogo interna al file Access (nomi in parte diversi), il cui contenuto resta nel blob Mdb | sempre NULL dal flusso attivo | FrmInventario.frm:3351-3399 contro 3443-3451 | V |

### Vincite

| Colonna | Significato | Valori | Evidenza | Cert. |
|---|---|---|---|:-:|
| `IdContatto` | [01] Cliente (0 = consegna su scontrini)<br>[09] Cliente; join su Clienti.IdContatto (sala singola) o Clienti.IdLong (multi-locale) | [09] 0 = senza card | Form1.frm:6430<br>frmrapp.frm:2499; frmrapp.frm:2527; ModuleMultilocale.bas:10-15 | V |
| `Costo` | Costo d'acquisto del pezzo, copiato dal premio alla consegna (una riga per pezzo) | EUR | ModAddNew.bas:40; Form1.frm:6427 | V |
| `N_Tickets` | [01] Ticket effettivamente pagati per un pezzo<br>[09] Prezzo in ticket del pezzo, copiato dal premio alla consegna | [01] dopo sconti; una riga per pezzo<br>[09] ticket; valore = N_Tickets x 0,01 EUR | Form1.frm:6111, 6126<br>ModAddNew.bas:41; frmrapp.frm:2564 | V |
| `Id` | [01] Operatore<br>[02] Operatore<br>[09] Operatore che ha consegnato il premio | [02] idx<br>[09] 1001-1008 = Prize Hub | ModAddNew.bas:44<br>ModAddNew.bas:44; Form1.frm:6128<br>frmrapp.frm:2499; ModAddNew.bas:44 | V |
| `Cons` | [01] Consegnato<br>[02] Premio consegnato<br>[06] Premio consegnato (anche premi prenotati)<br>[07] Premio consegnato<br>[09] Premio consegnato | [01] 1 = consegna immediata; 0 = premio prenotato<br>[02] Not prenotato; chiuse dopo 365 giorni all'avvio<br>[06] prenotazione 0; consegna 1<br>[07] 1 = consegnato<br>[09] 1 consegnato; 0 non consegnato (prenotazione) | Form1.frm:6128, ModAddNew.bas:46<br>ModAddNew.bas:46; Module1.bas:3711<br>ModAddNew.bas:46; FrmPreCon.frm:751<br>FrmInventario.frm:4647<br>frmrapp.frm:2499; ModAddNew.bas:46-48 | V |
| `F0` | [01] Sala in gruppo multi-sala<br>[02] Sala multi-locale<br>[09] Consegna in configurazione multi-locale | [09] 0/1 | ModAddNew.bas:47<br>ModAddNew.bas:47<br>ModAddNew.bas:47 | V |
| `N0` | [01] Punti Gold usati per il premio<br>[02] Punti gold usati per il premio<br>[05] Punti Gold usati per il premio (Golden)<br>[09] Punti Gold usati al posto dei Silver (PGldxSil) | [01] in Golden: quota Gold usata come Silver, o tutto il valore se il premio costa più di Pre25; vedi § 5<br>[09] intero | Form1.frm:6127-6139<br>ModAddNew.bas:49; Form1.frm:6139<br>frmresauto.frm:789-790<br>ModAddNew.bas:49 | D/V |
| `D0` | [01] Data di consegna<br>[02] Data consegna<br>[06] Data di consegna del premio<br>[07] Data di consegna del premio<br>[09] Data di consegna (se immediata = Data) | [01] valorizzata se Cons = 1<br>[06] getdate() alla consegna<br>[07] datetime | ModAddNew.bas:48<br>ModAddNew.bas:48; Module1.bas:3712<br>ModAddNew.bas:48; FrmPreCon.frm:751<br>ModAddNew.bas:48; FrmInventario.frm:4647<br>ModAddNew.bas:48 | V |
| `Costo, Fornitore, Descrizione` | Copia dei dati del premio al momento della vincita | Easy mode: Costo = punti/100 | Form1.frm:6128, 16652 | V |

### CoinlessTransazioniCards

| Colonna | Significato | Valori | Evidenza | Cert. |
|---|---|---|---|:-:|
| `cardid` | UID card troncato ai primi 8 caratteri | Clienti.T0 = cardid + '00000000' | decodifica_record.sql:179-190; aggiornaCard.sql | V |
| `TipoMovimento` | Tipo movimento | sempre 'Scarico' | decodifica_record.sql:432 | V |
| `SaldoCard` | Saldo card dopo la partita | unità card (centesimi), convertite con CreditToCurrency | aggiornaCard.sql | V |
| `CostoPartita` | Costo della partita | unità card | aggiornaCard.sql; decodifica_record.sql:200, 264 | V |
| `LivelloCard` | Livello card | 0 Platinum, 1 Gold, 2 Silver, 3 VIP/Compleanno | ECL_command.cls:394-420 | V |
| `N0` | Progressivo card | come TransCard.N0 | decodifica_record.sql:427-441 | V |
| `Bonus` | Bonus consumato nella partita | unità card; solo record BE 19-23 | decodifica_record.sql:271 | V |
| `FlagOpDaVerificare` | Partita provvisoria | 1 = non confermata | decodifica_record.sql:427-441 | V |

### PrizeHubSlots

| Colonna | Significato | Valori | Evidenza | Cert. |
|---|---|---|---|:-:|
| `hubId` | Hub (distributore) di appartenenza | int, da setup2 | frmEditPrizeHub.frm:733 | V |
| `tipo` | Tipo di contenitore | CAPSULE, SPINDLE, LOCKER (locker = 1 pezzo) | frmEditPrizeHub.frm:806-812 | V |
| `unit` | Unita' (modulo fisico) dell'hub | int >= 1, da containers[].unit | frmEditPrizeHub.frm:886 | V |
| `slot` | Posizione: lettera del contenitore + numero | A1-A18, B1-B14, C1-C10 (predefiniti) | frmEditPrizeHub.frm:1264-1271 | V |
| `codArticolo` | Codice premio (Premi.Codice) | testo | frmEditPrizeHub.frm:733 | V |
| `qtaDisp` | Pezzi presenti nello slot; > 0 = slot occupato | int | frmEditPrizeHub.frm:1372 | V |
| `attivo, updatedAt, updatedBy` | Slot attivo (NULL = attivo); ultimo aggiornamento e operatore |  | frmEditPrizeHub.frm:733, 765 | V |
| `ticketsMedi, ticketsMediaForzata` | Prezzo medio in ticket dello slot (spindle) e flag di valore forzato a mano; calcolo nel servizio | int, bit | frmEditPrizeHub.frm:744-750, 967-1012 | D |

### LogTransazioniTotem

| Colonna | Significato | Valori | Evidenza | Cert. |
|---|---|---|---|:-:|
| `tipo` | Mezzo di pagamento | POS, Bill, Coin | LogTransazioniTotem.cls:63, 120 | V |
| `CAut` | POS: codice autorizzazione; contanti: stato | Pending, Completed, Recovered | LogTransazioniTotem.cls:63-68, 285 | V |
| `TCC` | Contanti: progressivo card caricata | numero come testo | LogTransazioniTotem.cls:151, 268 | V |
| `AC` | Contanti: UUID sessione di pagamento | uuid v4 | LogTransazioniTotem.cls:78, 269 | V |
| `DataOraChiusura` | Data scassettamento totem | NULL = non scassettato | LogTransazioniTotem.cls:91-105 | V |
| `IdOperatore` | Operatore dello scassettamento | id Operatori | LogTransazioniTotem.cls:91-105 | V |

### MovOut

| Colonna | Significato | Valori | Evidenza | Cert. |
|---|---|---|---|:-:|
| `Codice` | Codice articolo al momento dello scarico | non aggiornato su ricodifica | ModAddNew.bas:237-268 | V |
| `Quantita` | Pezzi scaricati, sempre positivi | - | ModAddNew.bas:250 | V |
| `Fornitore` | Destinatario dello scarico (non il fornitore) | FrmKit: destinazione scelta o NomeLocale; FrmSiteOut: fornitore dell'articolo | FrmKit.frm:1397-1401; FrmSiteOut.frm:1321 | V |
| `Motivo` | [06] Causale di scarico, testo dipendente dalla lingua<br>[07] Causale dello scarico scritta nella lingua dell'interfaccia<br>[09] Causale dello scarico, come MovMag.Motivo | [06] SPOSTA, GUASTO, GRU, CONSUMABILI, EVENTI, RUSPE; TRANSFER (uscita verso altro locale); PRIZEHUB; il filtro elenca anche ROTTO, TICKETS<br>[07] IT VENDUTI/SPOSTA/GUASTO/GRU/CONSUMABILI/EVENTI/RUSPE; EN SOLD/TRANSFER/WASTE/CRANES/CONSUMABLES/EVENTS/PUSHERS; FR VENDU/TRANSFERT/DECHETS/GRUES/...; PRIZEHUB<br>[09] come MovMag.Motivo | FrmKit.frm:1739-1746; FrmSiteOut.frm:1321; FrmLismovN.frm:4229-4254<br>FrmInventario.frm:4383-4491; PrizeHub_MoveToSlot.sql<br>frmWrapp.frm:3469; frmWrapp.frm:4437-4531 | V |
| `Note` | Nota per riga o locale di destinazione | TRANSFER: nome locale di destinazione | FrmSiteOut.frm:1321; FrmKit.frm:1402 | V |
| `NBolla,NOrdine` | Numero bolla e numero ordine di scarico, entrambi obbligatori, coppia unica | digitati | FrmKit.frm:1307-1375 | V |

### CoinlessCards

| Colonna | Significato | Valori | Evidenza | Cert. |
|---|---|---|---|:-:|
| `SaldoUltimaRicarica` | Ultimo saldo noto alla ricarica | inizializzato all'ultimo saldo TransCard alla prima partita; aggiornamento successivo non trovato | decodifica_record.sql:226-232 | D |
| `SaldoUltimaPresentazione` | Ultimo saldo noto alla presentazione | come sopra | decodifica_record.sql:226-232 | D |
| `BlackList` | Card bloccata sulle schede | 1 = blacklist (bannaUtente, antifrode); rimossa cancellando la riga (sp_rimuovidabl) | bannaUtente.sql; decodifica_record.sql:367-369; sp_rimuovidabl.sql | V |
| `TentativiNonConfermati` | Contatore antifrode RFID non scrivibile | soglia setup2.MaxTentativiNonConfermati (default 3) | decodifica_record.sql:351-376 | V |
| `UltimoN0NonConfermato` | Progressivo ripresentato non confermato | azzerato alla conferma | decodifica_record.sql:351-376 | V |

### CoinlessMacchineHappyHour

| Colonna | Significato | Valori | Evidenza | Cert. |
|---|---|---|---|:-:|
| `device` | Device della macchina (atteso) | contiene il prezzo Compleanno per un bug di AddMaccHH | frmEclHH.frm:4454 | V |
| `perc_platinum` | Prezzo partita HH livello Platinum (non percentuale) | centesimi | frmEclHH.frm:3765, 4453-4454 | V |
| `perc_gold` | Prezzo partita HH livello Gold | centesimi | frmEclHH.frm:4453-4454 | V |
| `perc_silver` | Prezzo partita HH livello Silver | centesimi | frmEclHH.frm:4453-4454 | V |
| `perc_normal` | Prezzo partita HH livello Compleanno | centesimi | frmEclHH.frm:4453-4454 | V |

### EcsDati

| Colonna | Significato | Valori | Evidenza | Cert. |
|---|---|---|---|:-:|
| `DataRil` | Istante della rilevazione | datetime | inseriscesuECS.sql | V |
| `NImp` | Costante 1 in tutte le scritture | 1 | frmConfMacc.frm:8163; FormWizardMacchina.frm:971; inseriscesuECS.sql:… | V |
| `N0` | [02] RSSI<br>[08] Residuo ECS: RSSI del modulo radio | [08] intero | Module1.bas:34<br>EscNews.bas:137-158; FrmDatiEcs.frm:38-39 | V |
| `In1..In16` | Valori cumulativi degli ingressi: In1 contascatti IN (A2), In2 contascatti OUT ticket (A1), In3 gettoniera/monete (B14), In4 banconote o 2a gettoniera (A15), In5 ticket elettronici (+ automatici), In6-In8 uscite premi/t… | bigint cumulativo; consumi per differenza | frmConfMacc.frm:6252-6261; FrmEcs.frm:2779-2789; inseriscesuECS.sql:1… | V |
| `Stato/ValoreUscita` | Non usati dal codice attuale | NULL | FormWizardMacchina.frm:969-971 | V |

### Mistral

| Colonna | Significato | Valori | Evidenza | Cert. |
|---|---|---|---|:-:|
| `CodCard` | Barcode completo della carta raccolta letta (PK anti-riuso) | prefisso(2)+codice sala(4)+progressivo+carattere carta | ModAddNew.bas:430; FrmCTickets.frm:571-590 | V |
| `Sospeso` | Stato della lettura | 1 sessione aperta; 0 confermata | FrmCTickets.frm:1209-1215; Form1.frm:17331 | V |
| `Serie` | Carattere che identifica la carta nella raccolta (non la serie) | posizione in Setup.SyncRes | RacCard.cls:119-122 | V |
| `IDPost` | Postazione che ha letto la carta | IdPost-100 | FrmCTickets.frm:591 | V |
| `CodCard / Serie / Sospeso / IDPost` | Carta di una raccolta letta | Sospeso = 1 in sessione aperta, 0 confermata; IDPost = IdPost − 100 | Form1.frm:14348, 17331, ModAddNew.bas:433 | V |

### Ordini

| Colonna | Significato | Valori | Evidenza | Cert. |
|---|---|---|---|:-:|
| `QOrd` | Quantita ordinata | Completa la forza a QCons | FrmCariPO.frm:1116 | V |
| `NOrdine` | Numero ordine d'acquisto; testata implicita (righe con lo stesso numero) | digitato, unico per controllo applicativo | frmpremi.frm:4418-4528 | V |
| `QCons` | Quantita consegnata cumulata | ordine aperto se QCons < QOrd | FrmCariPO.frm:984; FrmCariPO.frm:1363 | V |
| `Codice,CodOr,Descrizione,Costo,N_Tickets,Fornitore` | Riga d'ordine con fotografia dell'anagrafica; fornitore come testo | - | ModAddNew.bas:796-826 | V |
| `NBolla,Motivo,Note` | Valorizzati solo copiando ordini remoti da porder.mdb | - | FrmCPOrd.frm:408 | V |

### promozioni

| Colonna | Significato | Valori | Evidenza | Cert. |
|---|---|---|---|:-:|
| `dalla_data` | Inizio finestra in cui le card nuove nascono Gold | datetime | ClassPromozioni.cls:84-90 | V |
| `alla_data` | Fine finestra in cui le card nuove nascono Gold | datetime | ClassPromozioni.cls:84-90 | V |
| `flagConvertiOldSilver` | Converte in Gold le Silver esistenti alla ricarica | 'S'/'N' | FrmCCard.frm:2775 | V |
| `flagRipristinaGoldInSilver` | Al ripristino riscrive il livello anche sulla card fisica | 'S'/'N' | Form1.frm:11105 | V |
| `scadenzaPromozione` | Data dopo cui le card promosse tornano al livello precedente | default alla_data | ClassPromozioni.cls:257-305 | V |

### Abbuoni

| Colonna | Significato | Valori | Evidenza | Cert. |
|---|---|---|---|:-:|
| `Id` | [01] Operatore che concede l'abbuono<br>[02] Operatore<br>[05] Operatore che ha concesso l'abbuono | [05] Operatori.Id | Form1.frm:6068, ModAddNew.bas:830<br>Form1.frm:6068<br>frmopabb.frm:334; Form1.frm:6068 | V |
| `Valore` | Valore in euro dell'abbuono |  | ModAddNew.bas:839 | V |
| `Tickets` | Ticket mancanti abbuonati |  | ModAddNew.bas:841 | V |
| `Tickets / Valore` | Ticket mancanti abbuonati e loro valore monetario | Valore = Costo/N_Tickets × Tickets | Form1.frm:15720-15722 | V |

### GruMovimenti

| Colonna | Significato | Valori | Evidenza | Cert. |
|---|---|---|---|:-:|
| `MovementType` | Tipo di movimento; WinMT scrive solo ADJUST+ come forzatura del valore medio con Qty = 0 | LOAD, UNLOAD, WIN, ADJUST+, ADJUST- | sp_crane_force_avg_value.sql | V |
| `AvgValueBefore, AvgValueAfter, QtyBefore, QtyAfter` | Stato dello slot prima e dopo il movimento |  | sp_crane_force_avg_value.sql | V |
| `PrizeCode, PrizeDesc` | Premio caricato (catalogo proprio, non sempre in Premi) |  | FormModificaPrezziGru.frm:469-485; db-03 | V |
| `Qty, UnitValue` | Pezzi del movimento e valore unitario (LOAD: valore premio caricato; ADJUST+: nuovo valore medio) |  | sp_crane_force_avg_value.sql; FormModificaPrezziGru.frm:469-485 | V |

### Scocard

| Colonna | Significato | Valori | Evidenza | Cert. |
|---|---|---|---|:-:|
| `IdContatto` | [03] Cliente dell'alert (riuso della tabella)<br>[05] Cliente dell'avviso | [03] IdLong come testo<br>[05] IdLong | frmModCli.frm:2310-2396<br>frmModCli.frm:2351 | V |
| `F0` | [03] Alert attivo<br>[05] Avviso sul cliente attivo (tabella riusata) | [03] 1 attivo, 0 eliminato<br>[05] 1 = attivo | frmModCli.frm:2333-2396; Remote/frmAlertClienti.frm:154-171<br>frmModCli.frm:2310-2390; Form1.frm:17546 | V |
| `T0` | [03] Testo dell'alert sul cliente<br>[05] Testo dell'avviso sul cliente | [03] testo; '' quando eliminato | frmModCli.frm:2333-2396; Remote/frmAlertClienti.frm:154-171<br>frmModCli.frm:2353; Remote/frmAlertClienti.frm:164 | V |
| `F0, T0` | Avviso da mostrare all'operatore sul cliente (multi-sala) | IdContatto = IdLong, F0 = 1, testo in T0 | Form1.frm:17546 | V |

### UID_Ammessi

| Colonna | Significato | Valori | Evidenza | Cert. |
|---|---|---|---|:-:|
| `UID` | [02] UID card fisica<br>[03] UID della card ammessa o codice QR | [02] confronto sui primi 8 caratteri<br>[03] 16 caratteri, confronto sui primi 8; UID=CodBar indica codice QR | Module1.bas:3643<br>Module1.bas:3643; ECL_database.cls:1239 | V |
| `CodBar` | [02] Barcode stampato<br>[03] Barcode stampato<br>[04] Barcode associato all'UID card | [02] = UID troncato a 15 se auto-inserito<br>[03] varchar(15); con auto-ammissione = UID troncato<br>[04] confronto sui primi 8 caratteri dell'UID | Module1.bas:3650<br>Module1.bas:3650<br>ECL_card.cls:31-56 | V |
| `DataCreazione` | Giorno del lotto (QR) | default getdate(); usato per contare i QR disponibili per giorno | ECL_database.cls:1109,1233-1241 | V |
| `DataEmissione` | Emissione del codice QR | valorizzato solo da FinalizeUidCodbar; mai per card RFID | FinalizeUidCodbar.sql; frmAstoria.frm:2932 | V |

### CoinlessClonedCards

| Colonna | Significato | Valori | Evidenza | Cert. |
|---|---|---|---|:-:|
| `cardid` | UID card | 8 caratteri dal DB, 16 dalla cassa (il trigger bannaUtente non trova card e cliente) | Module6.bas:2367; bannaUtente.sql | D |
| `TipoMovimento` | [02] Origine segnalazione<br>[04] Origine rilevazione | [02] Lettura (da WinMT)<br>[04] 'Scarico' dal DB (partita); 'Lettura' dalla cassa | Module6.bas:2367<br>decodifica_record.sql:537-548; Module6.bas:2367 | V |
| `CodMac` | [02] Origine segnalazione<br>[04] Macchina o postazione | [02] WinMt se da cassa<br>[04] codice macchina dal DB; 'WinMt' dalla cassa | Module6.bas:2367<br>decodifica_record.sql:537-548; Module6.bas:2367 | V |

### Differ

| Colonna | Significato | Valori | Evidenza | Cert. |
|---|---|---|---|:-:|
| `Data` | Istante di riferimento dell'inventario (DataInv) | datetime | FrmInventario.frm:3438 | V |
| `VarVal` | Valore a costo delle differenze d'inventario in valore assoluto: eccedenze + ammanchi (VEs - VMan, VMan negativo); nel riepilogo del file e' invece il netto | decimal | FrmInventario.frm:3398, 3438, 5548-5575 | V |
| `NImp` | Numero d'impianto della sala (valsets.Nimp) | int | ModAddNew.bas:1024 | V |

### EcsModuli

| Colonna | Significato | Valori | Evidenza | Cert. |
|---|---|---|---|:-:|
| `MacAd` | MAC address del modulo BE assegnato | testo | frmConfMacc.frm:7667; FormModificaPrezzi.frm:655 | V |
| `ShortAd` | Indirizzo IP del modulo EcsNet (versione precedente) | testo | FrmModCont.frm:2593 | V |
| `N0` | Numero del modulo = EcsMacchine.Modu (query attuali; le vecchie usano Id) | intero | frmConfMacc.frm:7667; FormModificaPrezzi.frm:658; FrmModCont.frm:2588 | V |

### Figli

| Colonna | Significato | Valori | Evidenza | Cert. |
|---|---|---|---|:-:|
| `Id` | Identificativo del minore | MAX+1 | FrmFigli.frm:626-631; ModAddNew.bas:3-27 | V |
| `IdContatto` | Cliente genitore | Clienti.IdContatto; massimo 3 nell'interfaccia | FrmFigli.frm:613-720 | V |
| `Sesso` | Sesso del minore | 'M'/'F' | FrmFigli.frm:613-661 | V |

### GruMagazzinoDettaglio

| Colonna | Significato | Valori | Evidenza | Cert. |
|---|---|---|---|:-:|
| `SlotNo` | Slot della gru, corrisponde ai contatori In6, In7, In8 | 1, 2, 3 | sp_crane_sync_ecsmacchine_values.sql | V |
| `LastLoadDate, LastWinDate` | Data ultimo carico e ultima vincita; scritti da componente esterno | datetime | vs_CraneStatus.sql | D |
| `QtyCurrent, AvgValue` | Pezzi nello slot e valore medio unitario del premio (euro) | int, decimal(18,4) | FormModificaPrezziGru.frm:494-518 | V |

### Resi

| Colonna | Significato | Valori | Evidenza | Cert. |
|---|---|---|---|:-:|
| `IdContatto` | Cliente; join su IdContatto o IdLong come Vincite |  | frmrapp.frm:2501; frmrapp.frm:2529 | V |
| `Id` | [05] Operatore che ha registrato il reso<br>[09] Operatore che ha registrato il reso | [05] Operatori.Id | frmresauto.frm:803<br>frmrapp.frm:2501 | V |
| `*` | Premio restituito dal cliente | IdContatto cliente o 0; dati copiati dalla consegna; consegna cancellata | ModAddNew.bas:99-125; frmresauto.frm:803-804 | V |

### uid_reservations

| Colonna | Significato | Valori | Evidenza | Cert. |
|---|---|---|---|:-:|
| `CodBar` | Codice QR prenotato | prenotazione temporanea | GetFreeUidCodbar.sql | V |
| `ReservedBy` | Chi ha prenotato | IdPost della postazione | frmAstoria.frm:2911-2912 | V |
| `ExpiresAt` | Scadenza della prenotazione | TTL 10 s da frmAstoria (default 120) | GetFreeUidCodbar.sql; frmAstoria.frm:2912 | V |

### AuditLog

| Colonna | Significato | Valori | Evidenza | Cert. |
|---|---|---|---|:-:|
| `tipoaudit` | Tipo di evento; la classe AuditLog non è mai istanziata in WinMT | Access, DeviceStatus | AuditLog.cls:33-80 | V |
| `extra_data` | Dati aggiuntivi JSON | {status, description} | AuditLog.cls:33-45 | V |

### Fornitori

| Colonna | Significato | Valori | Evidenza | Cert. |
|---|---|---|---|:-:|
| `Nome` | PK e nome del fornitore; riferito come testo in Premi/MovMag/MovOut/Ordini/Prenotaz | creato in automatico (solo nome) dai carichi | ModAddNew.bas:333-361; FrmMovmag.frm:2629-2636 | V |
| `Stato,Web_Site,Contact_Name` | Paese, sito, referente | solo da lista approvata | FrmMovmag.frm:2801-2815 | V |

### Ospiti

| Colonna | Significato | Valori | Evidenza | Cert. |
|---|---|---|---|:-:|
| `CardId` | Card dell'ospite | '' quando recuperata o bonificata | clsCompleanno.cls:657-706; frmCompleanni.frm:3526-3557 | V |
| `IdContatto` | Cliente fittizio creato per l'ospite | Clienti.IdContatto (TipoCard=3) | clsCompleanno.cls:657-706 | V |

### PartiteOspiti

| Colonna | Significato | Valori | Evidenza | Cert. |
|---|---|---|---|:-:|
| `device` | Dispositivo/macchina | = EcsMacchine.device; righe non scritte da WinMT (server ECL?) | frmCompleanni.frm:3323-3371 | D |
| `TotPartite` | Partite giocate dall'ospite su quella macchina | int | frmCompleanni.frm:3323-3371; clsCompleanno.cls:607-655 | V |

### promozioni_cards

| Colonna | Significato | Valori | Evidenza | Cert. |
|---|---|---|---|:-:|
| `cardid` | UID della card promossa | = Clienti.T0 | ClassPromozioni.cls:229-246; FrmPromozioni.frm:795-839 | V |
| `livelloPrecedente` | Livello della card prima della promozione | NULL letto come 2 (Silver); una riga per cardid (indice univoco) | ClassPromozioni.cls:229-246,264 | V |

### TicketsCan

| Colonna | Significato | Valori | Evidenza | Cert. |
|---|---|---|---|:-:|
| `DataCan` | [02] Data annullamento<br>[05] Data di annullamento mai valorizzata | [02] sempre NULL in scrittura<br>[05] sempre NULL | ModAddNew.bas:757<br>ModAddNew.bas:757 | V |
| `*` | Registro degli scontrini cartacei già trasformati in punti (anti-riuso) | IdContatto sempre 0; NumTrans/NumTickets dello scontrino; MangiaT originale\|256 oppure 101/301; TPagati 0 | ModAddNew.bas:743-768; FrmCTickets.frm:1129,1146-1151; Frm4Usr.frm:47… | V |

### TipoRicaricheCompleanni

| Colonna | Significato | Valori | Evidenza | Cert. |
|---|---|---|---|:-:|
| `abilitato` | Tipologia attiva | 1/0, cancellazione logica; seme 'Nessuna ricarica' | frmCompleanni.frm:2051-2083; clsCompleanno.cls:933-937 | V |
| `CreatedBy` | Postazione che ha creato la tipologia | IdPost, non operatore | frmCompleanni.frm:2085-2159 | V |

### Vincite25

| Colonna | Significato | Valori | Evidenza | Cert. |
|---|---|---|---|:-:|
| `(tabella)` | Registro premi oltre soglia fiscale | legato a Setup.Ric25 (ricevuta premio >25 euro) e Pre25 | Module1.bas:313-314; ModAddNew.bas:894 | D |
| `*` | [01] Ricevuta di consegna dei premi di valore<br>[05] Ricevuta firmata per premi oltre Pre25 | [01] scritta se Ric25 e costo oltre Pre25 (default 25 €): N_Tickets = punti, Costo = punti/100 (non il costo), BarCode = hhmmss+n stampato, Nome/Cognome copiati<br>[05] BarCode = hhmmss+progressivo; N_Tickets punti; nome e cognome copiati; indice univoco su Codice | Form1.frm:6240-6306, ModAddNew.bas:894, Module1.bas:313-314<br>Form1.frm:6268-6304; FrmRic.frm:557 | V |

### CoinlessLogEventiBlacklist

| Colonna | Significato | Valori | Evidenza | Cert. |
|---|---|---|---|:-:|
| `testo` | [02] Motivo blacklist<br>[04] Diario di blacklist, sostituzioni e incoerenze | [02] Crediti incongruenti ...<br>[04] testo libero; usato anche per ricerche LIKE sulla card | Module6.bas:2368<br>ECL_cliente.cls:1227; Module6.bas:2368; sp_rimuovidabl.sql | V |

### CraneCounterSyncLog

| Colonna | Significato | Valori | Evidenza | Cert. |
|---|---|---|---|:-:|
| `DeltaIn6, DeltaIn7, DeltaIn8` | Incrementi dei contatori premi degli slot gru elaborati da un servizio esterno; l'esistenza della tabella abilita il menu gru | int | Form1.frm:13647 | D |

### GruMagazzino

| Colonna | Significato | Valori | Evidenza | Cert. |
|---|---|---|---|:-:|
| `CodMac, Enabled` | Una riga per gru gestita a magazzino; Enabled non usato da WinMT |  | sp_crane_ensure_records.sql; sp_crane_list.sql | V |

### Logs

| Colonna | Significato | Valori | Evidenza | Cert. |
|---|---|---|---|:-:|
| `LFile` | [02] File di log della postazione<br>[10] File di log della sessione della postazione salvato alla chiusura | [02] blob<br>[10] varbinary | Module1.bas:3410-3414<br>Module1.bas:3397-3424 | V |

### Machines

| Colonna | Significato | Valori | Evidenza | Cert. |
|---|---|---|---|:-:|
| `MacName/Manufacturer/Type/CntrOut` | Catalogo modelli nel cloud (ripiego locale): nome, costruttore, tipo, presenza contascatti di uscita | CntrOut bit | FrmConf.frm:1630-1641; EscNews.bas:106-135 | V |

### Manuf

| Colonna | Significato | Valori | Evidenza | Cert. |
|---|---|---|---|:-:|
| `Id/ManufName` | Costruttori; Id = MAX+1 | - | EscNews.bas:49-75 | V |

### Owners

| Colonna | Significato | Valori | Evidenza | Cert. |
|---|---|---|---|:-:|
| `Id/OwnerName/OwnerAddress/OwnerPhone/Perc/NImp` | Proprietari con % incasso; gestione non raggiungibile dal menu, tabella vuota | - | FrmConf.frm:1472-1516; Form1.frm:9777-9783 | V |

### TickRep

| Colonna | Significato | Valori | Evidenza | Cert. |
|---|---|---|---|:-:|
| `*` | Ticket assegnati da reparto a un cliente (versione precedente di FrmRepTick) | nessuno scrittore attivo: AddTickRep mai chiamata | ModAddNew.bas:397-420 | D |

### Type

| Colonna | Significato | Valori | Evidenza | Cert. |
|---|---|---|---|:-:|
| `Id/TypeName/Color` | Tipologie di macchina con colore di sfondo nelle griglie | Id<100 creati da WinMT; 1 cambiagettoni | EscNews.bas:77-104 | V |
