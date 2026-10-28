# Galileo HQ — Analisi 01: catalogo dei flussi di WinMT

**Stato:** bozza · **Responsabile:** Piero · **Aggiornato:** 2026-10-27

**Fonte:** analisi del sorgente VB6 di WinMT, documenti `docs/winmt/winmt-01` … `winmt-10` · **Collegati:** `analisi-00-prima-lettura.md` (zone concettuali, § 3), `docs/winmt/winmt-00-mappa.md`, `docs/db/db-08-dizionario-dati.md`

Questo documento è il **censimento dei flussi** che WinMT implementa oggi, pesati per complessità. È uno dei prodotti attesi della fase 1 e la base per stimare la fase 2. Non è ancora il catalogo dei flussi del nuovo sistema: alcuni flussi andranno eliminati (funzioni dismesse, varianti per singoli clienti), altri accorpati, altri aggiunti (cloud, multisala, app). Quel lavoro si fa nelle interviste di fase 1, partendo da qui.

---

## 1. Come è stato costruito

1. Il codice di WinMT (211 file, circa 132.000 righe) è stato diviso in dieci zone tecniche, analizzate separatamente (WinMT 01–10). Ogni zona ha elencato i suoi flussi con un identificativo `Wnn-nn`, un peso e le evidenze nel codice.
2. Le zone tecniche (file) non coincidono con le zone funzionali: lo stesso flusso, per esempio il login o la verifica anti-clonazione della card, compare in più documenti. Qui i 228 flussi trovati sono stati **ricondotti alle otto zone concettuali** di Analisi 00, più una zona trasversale di piattaforma, e classificati:
   - **attivo**: flusso reale di WinMT, contato una volta sola;
   - **duplicato**: lo stesso flusso descritto da un'altra zona; resta nel dettaglio con il rimando, ma non si conta;
   - **esterno**: documentato perché spiega i dati, ma eseguito da un altro componente (micrototem, trigger del database);
   - **morto**: codice presente ma non raggiungibile o disattivato.
3. **Peso.** Ogni zona ha assegnato un peso secondo la stessa regola:
   - **S**: consultazione o gestione semplice di un'anagrafica;
   - **M**: più tabelle o regole non banali;
   - **L**: logica complessa, transazionale, con periferiche o con molte varianti.

> **Ipotesi di lavoro per la stima.** La colonna "Punti" converte i pesi con S = 1, M = 3, L = 8. È solo un modo per confrontare le zone fra loro. La conversione in ore va tarata dal team su due o tre flussi campione per peso, rifatti nel nuovo stack (Laravel + Flutter), prima di usarla per la stima di fase 2.

---

## 2. Riepilogo

| Zona concettuale | Flussi attivi | S | M | L | Punti* | Duplicati | Esterni | Morti |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| Identità e accesso | 5 | 1 | 3 | 1 | 18 | 2 | 0 | 0 |
| Clienti e card | 26 | 8 | 11 | 7 | 97 | 6 | 2 | 1 |
| Valore a circuito chiuso (ticket, punti, crediti, cassa) | 32 | 6 | 15 | 11 | 139 | 11 | 0 | 0 |
| Macchine e telemetria | 17 | 4 | 9 | 4 | 63 | 0 | 2 | 1 |
| Premi e magazzino | 42 | 13 | 21 | 8 | 140 | 3 | 0 | 1 |
| Promozioni, compleanni, raccolte, redeem | 14 | 4 | 9 | 1 | 39 | 2 | 1 | 0 |
| Reportistica | 26 | 11 | 11 | 4 | 76 | 0 | 0 | 0 |
| Multi-sala e governo remoto | 6 | 1 | 5 | 0 | 16 | 0 | 0 | 0 |
| Piattaforma: avvio, configurazione, periferiche, licenza | 23 | 5 | 14 | 4 | 79 | 5 | 0 | 0 |
| **Totale** | **191** | **53** | **98** | **40** | **667** | **29** | **5** | **3** |

\* Punti con S = 1, M = 3, L = 8 (§ 1, ipotesi di lavoro).

**Lettura del riepilogo**
- **Premi e magazzino** e **Valore a circuito chiuso** pesano quasi la metà del totale. Il primo per numero di flussi (carichi, scarichi, ordini, prenotazioni, inventario), il secondo per complessità: ticket, punti, crediti e cassa hanno molte varianti e regole, e quasi tutti i flussi L riguardano il saldo del cliente.
- **Multi-sala** ha solo 6 flussi in WinMT, perché oggi la multisala vive soprattutto in HQ, nel sincronizzatore e nello scambio di file `.mdb`. Nel nuovo sistema questa zona crescerà: il numero attuale **sottostima** il lavoro.
- **Reportistica**: 26 report, ma diversi duplicati logici con formule diverse (WinMT 09). Nel nuovo sistema conviene ridefinire le misure una volta e derivarne i report, non rifare i report uno per uno.

---

## 3. Cosa il catalogo non contiene ancora

- **Flussi di altri componenti.** Motore di sala B4J (`ecl2mqtt`, già `ecs2mqtt`), servizio .NET, totem, app clienti, HQ, PosHandler: scrivono una parte importante del database (contatori, partite, ticket ticketless, gru, PrizeHub) e non sono qui. 35 tabelle del database non sono mai toccate da WinMT (WinMT 00, § 4). I flussi del motore B4J sono censiti per zona tecnica in ecl2mqtt 01–06 (240 flussi, non ancora deduplicati né confrontati con questo catalogo: ecl2mqtt 00 § 2). I flussi della sincronizzazione sala–cloud (`ExecuteSync`, `WinMtProv`) sono censiti in sync 00 § 4: 11 flussi attivi, 28 punti.
- **Funzioni da dismettere.** Il catalogo le conta, perché esistono. Vanno marcate come tali nelle interviste: per esempio il sistema 4 utenti, già indicato per la dismissione il 19/10 (W05-04, W05-05), le varianti Albarella, Golden ed Easy, i trasferimenti via file `.mdb`.
- **Varianti per cliente.** Diverse funzioni hanno rami per singole sale, attivati da `Setup.N14` (Astoria, Alba, Golden) o da costanti di compilazione. Sono contate dentro il flusso a cui appartengono, non come flussi a sé.

---

## 4. Dettaglio per zona concettuale

Il nome, il peso e le tabelle scritte vengono dai documenti di zona, dove ogni flusso è descritto passo per passo con le evidenze nel codice.


### Identità e accesso

| Id | Flusso | Peso | Stato | Tabelle scritte | Periferiche |
|---|---|:-:|---|---|---|
| W01-01 | Avvio postazione e login operatore | M | dup. di W10-06 | Clienti (F0 tessere scadute, solo master), Operatori (Attivo) | Lettore RFID ECL, scanner barcode, lett… |
| W01-19 | Chiusura sessione operatore e stampa cassa | S |  | File locale Scanned (nessuna scrittura DB) | Stampante termica |
| W02-05 | Apertura sessione operatore e profilazione menu | M | dup. di W10-09 |  |  |
| W10-06 | Login operatore con password | M |  | Operatori; Setup | tastiera virtuale |
| W10-07 | Login operatore con card o barcode | M |  | Operatori | lettore RFID ECL; lettore banda magneti… |
| W10-08 | Gestione operatori (frmgesop) | L |  | Operatori | lettore banda magnetica; lettore RFID E… |
| W10-09 | Applicazione dei permessi (SetOp) | M |  |  |  |

### Clienti e card

| Id | Flusso | Peso | Stato | Tabelle scritte | Periferiche |
|---|---|:-:|---|---|---|
| W01-02 | Card RFID in canna: lettura e presa in carico del cliente | L |  | Clienti (Abilita, DataUltVis, Tickets, TipoCard), Tickets, Prenotaz (… | Lettore RFID ECL (seriale JSON), second… |
| W01-03 | Identificazione cliente con barcode, banda magnetica o ID | M |  | Clienti (Abilita, DataUltVis, Tickets, Bonus), Tickets | Scanner barcode, lettore banda magnetica |
| W01-14 | Verifica anti-clonazione e blacklist | L | dup. di W04-04 | Clienti (F1, T1, D1), CoinlessClonedCards, CoinlessLogEventiBlacklist | Lettore RFID ECL, BE (push blacklist), … |
| W01-15 | Conversione, rigenerazione e cambio livello card ECL | L |  | TransCard (riallineamento), Clienti (TipoCard) | Lettore RFID ECL |
| W01-16 | Gestione anagrafica clienti dalla form principale | M | dup. di W03-03 | Clienti (anagrafica, T0, CodBar, IdMaster1/2, Abilita, cancellazione … | Lettore RFID, scanner, lettore magnetico |
| W02-07 | Ricostruzione del saldo card dai movimenti | L |  | TransCard (tipi 19, 20) | Lettore/scrittore card ECL |
| W02-08 | Verifica coerenza card e blacklist | L | dup. di W04-04 | Clienti (F1,T1,D1), CoinlessClonedCards, CoinlessLogEventiBlacklist | Lettore card ECL; HTTP servizio ECL por… |
| W02-09 | Creazione cliente | M | dup. di W03-01 | Clienti, promozioni_cards |  |
| W02-10 | Aggiornamento cliente | S | dup. di W03-03 | Clienti |  |
| W02-11 | Verifica card fisica ammessa | S |  | UID_Ammessi (auto-inserimento opzionale) | Lettore RFID |
| W02-23 | Abilitazione/disabilitazione card cliente | S |  | Clienti.Abilita |  |
| W03-01 | Creazione del cliente con card | L |  | Clienti, Tickets, promozioni_cards | lettore RFID ECL, lettore banda magneti… |
| W03-02 | Riscrittura (sostituzione) della card | L |  | Clienti, TransCard, CoinlessCards, CoinlessClonedCards, CoinlessLogEv… | lettore ECL, HTTP server ECL |
| W03-03 | Modifica anagrafica del cliente | M |  | Clienti | lettore barcode, lettore ECL, stampante |
| W03-04 | Verifica registrazione App | S |  | Clienti | HTTP cloud |
| W03-06 | Registrazione al banco di cliente pre-registrato da App | M |  | Clienti, Tickets, winmtAPI.ClientiAPP (delete) | scanner, lettore ECL, secondo monitor |
| W03-07 | Creazione card anonima | M |  | Clienti, promozioni_cards | lettore ECL |
| W03-08 | Creazione card in serie con ricarica | M |  | Clienti, TransCard, Tickets, promozioni_cards | lettore ECL |
| W03-09 | Generazione card in lotto sul micrototem | M | esterno: micrototem | (nessuna da WinMT; il micrototem crea i clienti) | micrototem via TCP |
| W03-10 | Cancellazione card in lotto sul micrototem | S | esterno: micrototem | (nessuna da WinMT) | micrototem via TCP |
| W03-11 | Recupero card, eliminazione cliente, sblocco blacklist | L |  | Clienti, Operatori, Ospiti, Compleanni, promozioni_cards, CoinlessCar… | lettore ECL, HTTP server ECL |
| W03-12 | Unione card / somma punti a card master | M |  | Tickets, Clienti (anche delete) | lettore card |
| W03-13 | Unione card ECL (non implementata) | S | morto: non implementata |  | lettore ECL |
| W03-14 | Conversione massiva punti Silver in Gold | M |  | Tickets, Clienti |  |
| W03-15 | Conversione punti Silver/Gold del singolo cliente | M |  | Tickets, Clienti |  |
| W03-26 | Creazione cliente QR (Coin card) | M |  | uid_reservations, UID_Ammessi.DataEmissione, Clienti | stampante |
| W03-27 | Cliente creato automaticamente da card ammessa | S |  | UID_Ammessi (se F11), Clienti | lettore ECL |
| W03-28 | Scheda dettaglio cliente (FrmDeCli/FrmDeCliML) | M |  | (nessuna) | stampante |
| W03-29 | Classifica clienti ed export | M |  | Clienti.Credito (riallineamento) |  |
| W03-30 | Blacklist: consultazione | S |  | (nessuna) |  |
| W03-31 | Ricerca cliente per nome | S |  | (nessuna) |  |
| W03-32 | Minori associati al cliente | S |  | Figli |  |
| W03-33 | Display cliente sul secondo monitor | S |  | (nessuna) | secondo monitor |
| W04-04 | Lettura cliente da card e verifica card/DB (anti-clonazione cassa) | L |  | Clienti, CoinlessClonedCards, CoinlessLogEventiBlacklist | lettore ECL; HTTP servizio ECL :58889 |
| W04-24 | Sostituzione card del cliente | M | dup. di W03-02 | Clienti, CoinlessLogEventiBlacklist | lettore ECL |

### Valore a circuito chiuso (ticket, punti, crediti, cassa)

| Id | Flusso | Peso | Stato | Tabelle scritte | Periferiche |
|---|---|:-:|---|---|---|
| W01-04 | Lettura e accumulo di scontrini e codici speciali | L |  | Tickets (TPagati lock, insert esterni e manual tickets), Mistral | Scanner barcode, secondo monitor |
| W01-08 | Scontrino totale | M |  | Tickets (vecchi MangiaT\|128, nuovo MangiaT 16), Mistral | Stampante termica |
| W01-11 | Annulla e rilascio della postazione | M |  | Clienti (Abilita=1), Premi (Quantita ripristinata), Tickets (TPagati=… | Lettore banda magnetica (riarmo) |
| W01-12 | Ricarica crediti, carico ticket, vendita gettoni, info POS (orchestra… | M | dup. di W05-02 | TransCard, Clienti (Credito), Setup (VCassa) tramite FrmCCard e altre… | Lettore RFID ECL, POS |
| W01-13 | Accredito crediti sospesi da totem | M |  | TransCard (NImp 0 e 6), Clienti (N1=0, Credito) | Lettore RFID ECL |
| W01-17 | Bonus 24 ore e bonus nuova card | S | dup. di W02-18 | Tickets (MangiaT 64), Clienti (Tickets) | - |
| W01-18 | Stampa bilancio card | S |  | - | Stampante termica |
| W01-22 | Ricalcolo ticket di tutti i clienti | M | dup. di W02-16 | Clienti (Tickets), file di log | - |
| W01-23 | Pulizia archivio ticket | S | dup. di W05-22 | Tickets (delete lotti consumati) | - |
| W01-25 | Modalita Easy: scarico punti senza catalogo | M |  | Tickets, Vincite (Codice 0000000000000), Clienti (Tickets), Mistral | Stampante termica |
| W02-06 | Registrazione movimento di valore su card ECL | M | dup. di W05-02 | TransCard, Clienti.Credito | Lettore/scrittore card ECL (a monte) |
| W02-12 | Emissione e stampa scontrino ticket | M |  | Tickets | Stampante termica seriale (6 modelli) |
| W02-13 | Lettura scontrino cartaceo e blocco alla postazione | M | dup. di W01-04 | Tickets | Lettore barcode |
| W02-14 | Aggiornamento punti del cliente | M | dup. di W01-06 | Tickets (TPagati, OperOut, DataOut), Clienti (Tickets, Bonus, DataUlt… |  |
| W02-15 | Registrazione e chiusura vincite | S | dup. di W01-06 | Vincite |  |
| W02-16 | Ricalcolo punti di tutti i clienti (anche multi-locale) | L |  | Clienti (Tickets, Bonus) | Server cloud SQL |
| W02-17 | Manual tickets | M | dup. di W05-09 | Tickets, Setup (NRep2) | Lettore barcode/QR |
| W02-18 | Bonus su ticket e su ricarica | M |  |  |  |
| W03-24 | Family card: pagamento distribuito su piu card | L |  | TransCard, Clienti.Credito, Tickets, LogTransazioniPos | lettore ECL, POS, stampante |
| W03-25 | Cassa semplificata Astoria: ricarica e rimborso | L |  | TransCard, Clienti.Credito, Clienti.Abilita, LogTransazioniPos | lettore ECL, scanner QR, POS (Nayax/Ing… |
| W04-05 | Recupero transazioni POS Pending | L |  | TransCard, Clienti, LogTransazioniPos, Tickets | lettore ECL; PosHandler TCP |
| W04-06 | Recupero contanti Pending dei totem | M |  | TransCard, Clienti, LogTransazioniTotem, Tickets | lettore ECL |
| W04-07 | Consultazione movimenti card | S |  | nessuna | stampante (stampa griglia) |
| W04-08 | Storno ultima ricarica | M |  | TransCard (DELETE) | lettore ECL |
| W04-09 | Ritiro card (azzeramento saldo) | M |  | TransCard, Clienti | lettore ECL |
| W04-10 | Unione card (trasferimento crediti, bonus, ticket) | L |  | Tickets, Clienti, TransCard | lettore ECL; lettore barcode |
| W04-11 | Vendita gettoni dal saldo card | M |  | TransCard, Clienti | lettore ECL |
| W04-12 | Controllo movimenti e svuotamento cassa principale | M |  | TransCard | stampante |
| W04-13 | Azzeramento cassa operatore | S |  | TransCard | nessuna |
| W04-20 | Pagamento POS su PosHandler (Nayax e altri) | L |  | LogTransazioniPos | POS via PosHandler TCP JSON-RPC |
| W04-21 | Pagamento POS seriale (PAX) | M |  | nessuna | POS seriale 115200 |
| W05-01 | Carico di scontrini, carte raccolta e ticket manuali sulla card del c… | L |  | Tickets; TicketsCan; Mistral; Clienti; Setup | Scanner barcode seriale; secondo monitor |
| W05-02 | Ricarica di crediti sulla card ECL | L |  | TransCard; Clienti; Tickets; LogTransazioniPos | Lettore/scrittore ECL; POS seriale o Na… |
| W05-03 | Variante Albarella: ticket, crediti e gettoni in una form | M |  | Tickets; TicketsCan; Mistral; Clienti; TransCard | Scanner; lettore ECL; POS seriale; stam… |
| W05-04 | Sistema 4 utenti: banco premi con quattro operatori | L |  | Tickets; TicketsCan; Clienti; Vincite; Premi | Fino a 4 scanner seriali; stampante ter… |
| W05-05 | Configurazione del sistema 4 utenti | S |  | Setup; file MsgSco.bin | Porte COM (autodetect scanner) |
| W05-09 | Scontrino manuale | M |  | Tickets | Stampante termica |
| W05-10 | Ticket da reparto | M |  | Tickets; Clienti | Stampante termica |
| W05-20 | Ticket sospesi (persi) nel buffer coinless | S |  |  |  |
| W05-21 | Cancellazione archivi | L |  | Delete su Tickets; TicketsCan; Abbuoni; Premi; MovMag; MovOut; Prenot… |  |
| W05-22 | Pulizia dell'archivio ticket | S |  | Tickets (delete usati) |  |
| W08-21 | Svuotamento della cassa | S | dup. di W04-12 | TransCard | nessuna |
| W08-22 | Ricalcolo punti clienti multi-sala | M | dup. di W02-16 | Clienti (Tickets, Bonus) | connessione diretta ai DB delle altre s… |

### Macchine e telemetria

| Id | Flusso | Peso | Stato | Tabelle scritte | Periferiche |
|---|---|:-:|---|---|---|
| W04-17 | Gestione happy hour | M |  | CoinlessTestataHappyHour, CoinlessMacchineHappyHour, coinless_sbuilde… | HTTP servizio ECL :58889 |
| W04-26 | Partita su gioco (lato DB, collegato) | L | esterno: trigger e procedure del DB | Clienti, CoinlessTransazioniCards, TransCard, CoinlessCards, Coinless… | scheda BE/BI via servizio ECL (MQTT) |
| W07-11 | Editor gru: stato degli slot e forzatura del valore medio | M |  | EcsMacchine (N0; ValIn6-8 via SP), GruMagazzino, GruMagazzinoDettagli… | nessuna |
| W08-01 | Catalogo dei modelli di macchina | M |  | Machines, Manuf, Type | nessuna (cloud) |
| W08-02 | Anagrafica proprietari (non raggiungibile) | S | morto: non raggiungibile dal menu | Owners | nessuna |
| W08-03 | Nuova macchina in modalita ECL | L |  | EcsMacchine, EcsDati | servizio di sala HTTP |
| W08-04 | Nuova macchina con procedura guidata | M |  | EcsMacchine, EcsDati | nessuna (cloud obbligatorio) |
| W08-05 | Modifica configurazione e invio alla scheda | L |  | EcsMacchine | servizio di sala HTTP (jSetupDevice) |
| W08-06 | Duplicazione di una macchina | M |  | EcsMacchine, EcsDati | nessuna |
| W08-07 | Provisioning del modulo BE e comandi al dispositivo | M |  | - (EcsModuli scritta dal servizio) | servizio di sala HTTP; lettore card del… |
| W08-08 | Configurazione macchina in modalita ECLReader | M |  | EcsMacchine, EcsDati | nessuna |
| W08-09 | Multipostazione e raggruppamenti | M |  | EcsMacchine | nessuna |
| W08-10 | Eliminazione macchina e cancellazione dati | S |  | EcsDati (D), TransCard (D), EcsMacchine (D), EcsDati (I lettura zero) | nessuna |
| W08-11 | Disinstallazione macchina | S |  | EcsMacchine | nessuna |
| W08-12 | Modifica costi partita per livello card | L |  | EcsMacchine | servizio di sala HTTP; socket TCP in as… |
| W08-13 | Rettifica manuale letture contatori meccanici | M |  | EcsMacchine | stampante (differenze) |
| W08-14 | Registrazione automatica letture contatori (lato DB) | M | esterno: trigger e procedure del DB | EcsDati, Tickets, Clienti | scheda BE (via servizio) |
| W08-15 | Conteggio macchine e incasso | L |  | EcsMacchine (CntrLet), Incassi (I con Mdb), Setup (F1, ValGett), file… | stampante; file Access locale |
| W08-17 | Voci aggiuntive dell'incasso (varianti incasso) | S |  | Setup (T14, T15) | nessuna |
| W08-18 | Registrazione manuale incassi per categoria | S |  | Incassi | nessuna |

### Premi e magazzino

| Id | Flusso | Peso | Stato | Tabelle scritte | Periferiche |
|---|---|:-:|---|---|---|
| W01-05 | Selezione premi al banco | L |  | Premi (Quantita, Locked) | Scanner barcode, secondo monitor |
| W01-06 | Consegna premi a cliente con card (PremiAuto) | L |  | Vincite, Vincite25, Abbuoni, Prenotaz, Premi (QPren), Tickets (TPagat… | Stampante termica, lettore RFID ECL, se… |
| W01-07 | Consegna premi senza card (PremiManu) | L |  | Vincite, Vincite25, Abbuoni, Prenotaz, Premi (QPren), Tickets (chiusu… | Stampante termica |
| W01-09 | Prenotazione premi | M |  | Vincite (Cons=0), Prenotaz (Quantita<0), Premi (QPren) | Stampante termica (barcode P..R) |
| W01-10 | Consegna prenotazioni e ordini (anche da totem) | M | dup. di W06-27 | Prenotaz (IdOpCo marcatori) | Scanner barcode |
| W05-13 | Restituzione premio da cliente con card | M |  | Tickets; Premi; Resi; Clienti; Vincite (delete) | Scanner barcode; lettore ECL |
| W05-14 | Restituzione premio senza card | M |  | Tickets; Premi; Resi; Vincite (delete) | Scanner barcode; stampante termica |
| W05-15 | Partite con la card resi | S |  |  |  |
| W05-16 | Abbuono alla consegna dei premi | M |  | Abbuoni |  |
| W05-19 | Ricalcolo massivo del prezzo in ticket dei premi | S |  | Premi |  |
| W06-01 | Consultazione del catalogo premi | S |  |  | Lettore barcode seriale |
| W06-02 | Modifica anagrafica in griglia (anche quantita e codici) | M |  | Premi |  |
| W06-03 | Nuovo articolo con carico iniziale | M |  | Premi;MovMag | Lettore barcode |
| W06-04 | Eliminazione articoli | S |  | Premi;MovMag;MovOut |  |
| W06-05 | Aggiornamento barcode e foto | S |  | Premi | Lettore barcode |
| W06-06 | Modifica massiva N.Tickets | S |  | Premi |  |
| W06-08 | Ricalcolo giacenze da inventario | M | dup. di W07-05 | Premi |  |
| W06-09 | Carico da bolla (anche trasferimento ingresso da reparto e ingresso m… | L |  | Premi;MovMag;Fornitori;kitpremi.mdb | Lettore barcode |
| W06-10 | Carico automatico da file .mdb | L |  | Premi;MovMag;Fornitori;loadnote.txt |  |
| W06-12 | Import della lista approvata | M |  | Premi;Fornitori;Setup |  |
| W06-13 | Scarico / trasferimento in uscita verso reparto / reso a fornitore | M |  | Premi;MovOut;file Unloads | Lettore barcode;stampante di sistema |
| W06-17 | Modifica singolo movimento (senza riallineare la giacenza) | S |  | MovMag;MovOut |  |
| W06-18 | Modifica bolla con riallineamento della giacenza | M |  | MovMag;MovOut;Premi |  |
| W06-19 | Cancellazione bolla con storno della giacenza | M |  | MovMag;MovOut;Premi |  |
| W06-20 | Creazione ordine d'acquisto | M |  | Ordini | Stampante di sistema |
| W06-21 | Visualizza, ricrea con nuovo numero, cancella ordine d'acquisto | M |  | Ordini;Premi | Stampante di sistema |
| W06-22 | Carico da ordine d'acquisto (consegne parziali, chiusura forzata) | M |  | Ordini;Premi;MovMag | Stampante di sistema |
| W06-24 | Anagrafica fornitori | S |  | Fornitori | Stampante di sistema |
| W06-25 | Liste prenotazioni/ordini e conferma disponibilita con notifica | M |  | Prenotaz | Push/email (SendPush, SendMail);Excel |
| W06-26 | Annullamento prenotazione/ordine con rimborso ticket | L |  | Prenotaz;Premi;Clienti;Tickets;Vincite | Stampante scontrini |
| W06-27 | Consegna premio prenotato o ordinato | M |  | Prenotaz;Premi;Vincite | Lettore card;stampante scontrini |
| W06-28 | Consegna da ricevuta (barcode P...R) | M |  | Prenotaz;Premi;Vincite | Lettore barcode |
| W06-29 | Preparazione ordini cliente e totem | M |  | Prenotaz | Stampante scontrini |
| W06-30 | Ricalcolo quantita prenotate | S |  | Premi |  |
| W06-31 | Distributori automatici: configurazione, inserimento premi, report | M |  | Operatori;premiph.mdb |  |
| W06-32 | Reparti dei ticket | S |  | Setup |  |
| W07-01 | Esecuzione e salvataggio dell'inventario premi | L |  | Premi (Quantita), Differ, RiepInv (Data, D0, Mdb = file inv.mdb); fil… | Lettore barcode seriale (SerComm); stam… |
| W07-02 | Pausa dell'inventario e correzione dei movimenti | M |  | file locale inv.mdb | Lettore barcode (passaggio porta tra fo… |
| W07-03 | Consultazione di un inventario precedente | M |  | file VInv.mdb (pulizia righe a costo zero) | Driver Jet Access |
| W07-05 | Ricalcolo delle giacenze senza inventario | M |  | Premi (Quantita = quantita presunta) | Driver Jet Access |
| W07-06 | Inventario versione 2 (SQL/JSON) - non attivo | M | morto: disattivata nel codice | Premi (Quantita), RiepInv (Data, F0=0, N1=1, Mdb=JSON), UltimoInventa… | Lettore barcode seriale |
| W07-08 | Carico di uno slot del PrizeHub | L |  | nessuna diretta: POST API SVCPHLOADSLOT al servizio di sala | Lettore barcode seriale; HTTP verso ser… |
| W07-09 | Forzatura e ripristino dei ticket medi di uno slot SPINDLE | S |  | nessuna diretta: POST API SVCPHSETTICKETSMEDI / SVCPHRESET_TICKETSMEDI | HTTP verso servizio PrizeHub |
| W07-10 | Consultazione e scelta del PrizeHub | S |  | nessuna | nessuna |
| W09-12 | Dati cliente senza card per prenotazione (fuori zona) | S | dup. di W01-09 | Prenotaz | nessuna |
| W09-13 | Modifica diretta di consegne, resi, prenotazioni dalle griglie dei ra… | S |  | Vincite, Resi, Prenotaz (D) | nessuna |

### Promozioni, compleanni, raccolte, redeem

| Id | Flusso | Peso | Stato | Tabelle scritte | Periferiche |
|---|---|:-:|---|---|---|
| W01-24 | Creazione card al banco: codici redeem e micrototem | M |  | RedeemCodes, Clienti, Compleanni/Ospiti (tramite classi) | Micrototem (erogatore card), scanner QR |
| W02-24 | Card compleanno: ricerca e ripristino livello | S | dup. di W03-23 | Clienti.TipoCard |  |
| W03-16 | Opzioni clienti con card (VIP) | S |  | Setup (configurazione postazione) |  |
| W03-17 | Gestione promozioni | S |  | promozioni |  |
| W03-18 | Livello promozionale: applicazione e ripristino | M |  | Clienti, promozioni_cards | lettore ECL |
| W03-19 | Gestione eventi compleanno | M |  | Compleanni, Ospiti, TipoRicaricheCompleanni, setup2 | stampante (report) |
| W03-20 | Emissione card ospite di compleanno | L |  | Clienti, Ospiti, Compleanni, TransCard, Tickets | lettore ECL |
| W03-21 | Ricarica, recupero e conversione card ospite | M |  | Ospiti, Clienti, TransCard (anche delete), Compleanni | lettore ECL |
| W03-22 | Redeem code per ospiti di compleanno | M | dup. di W04-18 | RedeemCodes | stampante, email, rete cloud |
| W03-23 | Fine evento compleanno sulla card | S |  | Clienti (TipoCard=2) | lettore ECL |
| W04-18 | Creazione codici redeem per compleanno | M |  | RedeemCodes | servizio QR esterno; mail; PDF |
| W04-19 | Riscatto codice redeem in cassa | M |  | RedeemCodes, Clienti, TransCard (via creazione card), Ospiti | lettore QR; lettore ECL |
| W04-22 | Generazione card in batch con GiallOne | M | esterno: dispositivo GiallOne | nessuna diretta (card generate dal dispositivo) | GiallOne/micrototem TCP JSON-RPC |
| W04-23 | Promozione VIP e abbonamento | M |  | TransCard, Clienti | lettore ECL |
| W05-06 | Raccolta di carte collezionabili: lettura in cassa | M |  | Mistral; Tickets; file contatori locali | Scanner barcode; secondo monitor (video… |
| W05-07 | Configurazione delle raccolte card | M |  | Setup |  |
| W05-08 | Riabilitazione delle carte raccolta | S |  | Mistral (delete) | Scanner barcode |

### Reportistica

| Id | Flusso | Peso | Stato | Tabelle scritte | Periferiche |
|---|---|:-:|---|---|---|
| W02-19 | Statistiche ticket per tipo | M |  |  |  |
| W04-14 | Rapporto card (acquistati, spesi, residui) | M |  | nessuna | stampante, export |
| W04-15 | Rapporto crediti di servizio | S |  | nessuna | stampante |
| W04-16 | Report ECL parametrici | M |  | cache_dati_grafico_giornaliero (sp_generacache) | stampante, Excel |
| W05-11 | Conteggio scontrini | S |  |  | Scanner barcode |
| W05-12 | Dettaglio di uno scontrino | S |  |  | Scanner barcode |
| W05-17 | Riepilogo abbuoni per operatore | S |  |  | Stampante di sistema |
| W05-18 | Riepilogo ricevute premi oltre soglia | S |  | Vincite25 (delete) | Scanner barcode; stampante di sistema |
| W06-07 | Stampe, etichette ed esportazioni del catalogo | M |  |  | Stampante termica seriale;stampante di … |
| W06-16 | Consultazione movimenti di carico e scarico | M |  |  | Stampante di sistema;Excel |
| W07-04 | Stampa, esportazione e sommario economico dell'inventario | M |  | nessuna (file Excel/CSV) | Stampante di sistema; Excel via COM |
| W07-07 | Andamento premi in 6 settimane (6 Weeks Stock Trend) | S |  | nessuna (file Excel/CSV) | Stampante; Excel via COM |
| W08-16 | Consultazione incasso precedente | S |  | file PrecInc.mdb | nessuna |
| W08-19 | Incasso amministrativo | M |  | - | stampante; esportazione Excel |
| W08-20 | Rapporto macchine | L |  | EcsMacchine (DataDis, via W08-11) | stampante; grafici |
| W09-01 | Rapporto Vendite: calcolo e visualizzazione | L |  | Tickets (via W09-04) | nessuna |
| W09-02 | Rapporto Vendite: stampa termica e di sistema (estesa, breve, unione) | M |  | - | stampante termica seriale ESC/POS; stam… |
| W09-03 | Rapporto Vendite: esportazione xlsx/csv | S |  | file xlsx/csv | Excel via COM (opzionale) |
| W09-04 | Correzione automatica ticket chips (Aux=1) a multipli di 5 +10 | S |  | Tickets | nessuna |
| W09-05 | Rapporto Mangia Tickets (ticket contati per macchina) | S |  | - | nessuna |
| W09-06 | Riquadri punti: reparti, raccolte card, extra locale (Dare/Avere), pu… | M |  | - | nessuna |
| W09-07 | Rapporto Breve Utente (per operatore, algoritmo client-side) | M |  | Tickets (Id=1 se nullo) | stampante termica; stampante Windows; E… |
| W09-08 | Rapporto Settimanale: incassi, carichi/scarichi, profitto lordo, payo… | L |  | - | stampante termica; stampante Windows; E… |
| W09-09 | Rapporto Variazioni: profitto con variazioni di inventario | M |  | file temporaneo VInv.mdb | nessuna |
| W09-10 | Situazione Prize Hub N (giacenza distributore) | S |  | PremiPH.mdb (Access, tabella di appoggio) | nessuna |
| W09-11 | Report dinamici (Rapporti Vari, Rapporti Amministratori, cassa, compl… | L |  | qualsiasi tabella (execute_sql_before_print, update_sql_after_print);… | stampante Windows; PDF; richiede connes… |

### Multi-sala e governo remoto

| Id | Flusso | Peso | Stato | Tabelle scritte | Periferiche |
|---|---|:-:|---|---|---|
| W02-22 | Scambio di file .mdb | M |  | File .mdb su disco | File system |
| W03-05 | Alert sul cliente | S |  | Scocard (anche nei DB dei locali collegati) |  |
| W06-11 | Carico remoto da HQ | M |  | Premi;MovMag;Fornitori;RiepInv |  |
| W06-14 | Trasferimento ad altro locale (uscita) | M |  | Premi;MovOut;file Unloads | Lettore barcode |
| W06-15 | Trasferimento da altro locale (ingresso automatico, consegne parziali) | M |  | Premi;MovMag;Fornitori;file Loads |  |
| W06-23 | Import di ordini d'acquisto remoti da porder.mdb | M |  | Ordini;Premi;Setup |  |

### Piattaforma: avvio, configurazione, periferiche, licenza

| Id | Flusso | Peso | Stato | Tabelle scritte | Periferiche |
|---|---|:-:|---|---|---|
| W01-20 | Connessione DB, server secondario e stato sincronizzazione | M | dup. di W10-12 | Registro di Windows (SqlServ) | Rete (broadcast UDP), email |
| W01-21 | Avvisi periodici e all'apertura | S |  | - | - |
| W02-01 | Avvio applicazione e connessione al database | L | dup. di W10-01 | Setup, setup2, Operatori, Vincite, DDL su più tabelle | Rete (autodiscovery UDP, ping), broker … |
| W02-02 | Identificazione postazione e caricamento configurazione | M | dup. di W10-02 | Setup (MName, default NULL), Operatori (id 9999) |  |
| W02-03 | Controllo licenza | M | dup. di W10-11 |  | Chiave USB HASP |
| W02-04 | Salvataggio configurazione | M | dup. di W10-04 | Setup |  |
| W02-20 | Servizi tecnici: backup, log, email, blocco premi, stampa cassa | S |  | Logs, Setup (D3), Premi (Quantita, Locked), backup .bak | Stampante seriale; SMTP |
| W02-21 | Traduzioni OTA e messaggi dei clienti dall'app | M |  | lstmsg.mdb (file Access locale) | HTTP/HTTPS verso servizi cloud Elmac |
| W04-01 | Configurazione ECL, bonus e POS | M |  | Setup, setup2 | nessuna (test POS TCP, test server ECL) |
| W04-02 | Programmazione lettore di cassa e card tecniche | M |  | nessuna | lettore ECL seriale |
| W04-03 | Dialogo con il lettore/scrittore card di cassa | L |  | nessuna | lettore ECL seriale 38400 |
| W04-25 | Adeguamento schema all'avvio | M |  | setup2, LogTransazioniPos, uid_reservations, RedeemCodes, Logs, proce… | nessuna |
| W10-01 | Avvio postazione e caricamento configurazione | L |  | Setup; setup2; Operatori | UDP broadcast 51049; chiave HASP; MQTT |
| W10-02 | Identificazione postazione e assegnazione IdPost | M |  | Setup; registro Windows |  |
| W10-03 | Opzioni generali della sala (frmsetGen) | L |  | Setup; setup2 |  |
| W10-04 | Setup di sistema e di postazione (frmsetSys) | L |  | Setup; setup2; registro Windows; file MsgSco.bin | porte seriali; stampante; lettore card;… |
| W10-05 | Parametri estesi chiave/valore (setup2) | S |  | setup2 |  |
| W10-10 | Chiusura del programma con backup | M |  | Logs; Setup | disco di backup |
| W10-11 | Verifica della licenza | M |  |  | chiave HASP |
| W10-12 | Impostazioni server SQL e passaggio al server secondario | M |  | Setup; registro Windows | UDP broadcast 51049; HTTP ecl2mqtt :588… |
| W10-13 | Autodetect periferiche seriali | M |  | setup2 | mangiatickets 1-5; lettore banda magnet… |
| W10-14 | Card di setup e card di configurazione ECL | M |  | Setup | lettore RFID ECL |
| W10-15 | Configurazione e test del terminale POS | M |  | Setup | POS seriale (Amit, Ingenico, PAX, Nayax) |
| W10-16 | Watchdog del servizio ecl2mqtt via MQTT | M |  |  | broker MQTT 1883 |
| W10-17 | Notifiche push/email ai clienti ed email di servizio | M |  | Setup | servizio web Elmac (HTTP); SMTP |
| W10-18 | Stampa di scontrini con modelli (cls_Escp2Printer) | M |  | setup2 | stampante termica ESC/POS (seriale o TC… |
| W10-19 | Indicatore di sincronizzazione | S |  |  |  |
| W10-20 | Anagrafiche ECS di supporto (EscNews) | S |  | Owners; EcsMacchine; Manuf; Type; Machines; EcsDati; EcsErr; EcsModuli |  |
