# Galileo HQ — Analisi 00: prima lettura delle fonti

**Stato:** bozza · **Responsabile:** Piero · **Aggiornato:** 2026-10-18

**Fonti:** riunione esplorativa 07/10/2026 (trascrizione e sommario Plaud), riunione operativa 12/10/2026 (trascrizione con relatori), manuale WinMtSql (ELMAC II s.r.l.)

Questo documento non è ancora l'analisi funzionale. Fissa ciò che le fonti dicono, ciò che danno per scontato e ciò che è in contraddizione, per orientare le interviste successive.

---

## 1. Qualità delle fonti

**Trascrizioni.** Il riconoscimento vocale è di qualità media. I termini tecnici sono spesso storpiati: "WB6" sta per VB6, "ICL/ACL/CL" per ECL, "Helmac/Ermac" per Elmac, "mercolio/Aminferto" quasi certamente per MIFARE. Nella trascrizione del 12/10 l'attribuzione dei relatori non è affidabile: diverse battute assegnate a Piero sono di Fabrizio o Antonio, e viceversa. Nessuna affermazione va citata come "detta da X" senza verifica.

**Sommario Plaud.** È utile come indice, ma il piano d'azione contiene nomi e date inferiti dallo strumento. Alcune scadenze, per esempio il documento di analisi al 21/10 e la visita in sala al 18/10, vanno confermate.

**Manuale.** È un documento in corso di aggiornamento, rivolto all'operatore e non al tecnico. Contiene 24 "Nuova sezione", 11 "nuova funzione" e 12 "Nuova immagine" senza contenuto, oltre a una nota "dove trovo questa voce?????". Tra le parti non documentate ci sono Prize HUB, Gestione GRU, Impostazioni ECL, Sistema 4 utenti, Secondary server e "1 ticket = punti". La numerazione dei capitoli nell'indice non coincide con i riferimenti interni.

---

## 2. Contesto di progetto (dalla riunione esplorativa)

- **Committente:** Elmac (Rubano, PD), produttore e rivenditore di giochi e sistemi per sale. Il sistema non è mai stato venduto come prodotto: serve a controllare le operazioni proprie e quelle dei clienti. Sono stati investiti circa 2 milioni di euro senza ritorno diretto.
- **Posizione:** il progetto è dichiarato come "ultima chance". I competitor hanno superato il prodotto, a gennaio è stata rifiutata un'alternativa (distribuire il software di un competitor cloud) e c'è urgenza dovuta al rischio di *hard stop* tecnologico (VB6/OCX).
- **Modalità richiesta:** progetto con inizio e fine, separato dalla manutenzione dell'esistente (Fabrizio e Antonio restano sulle installazioni attive).
- **Percorso concordato:** fase 0 di pre-analisi (10–15 ore di interviste), poi fase 1 di analisi completa che produce un documento e una stima, poi fase 2 di realizzazione.
- **Principio di metodo** (sostenuto da Piero e accettato): progettare il "database 3.0" a partire dalle funzionalità, non dal database attuale, che contiene scorciatoie e non va preso come fonte di verità.
- **Priorità:** prima replicare tutte le funzionalità in un'applicazione robusta e manutenibile, poi UX e dashboard. La committente considera però UX e dashboard indispensabili per vendere.
- **Punto di forza da preservare:** la sala non si ferma quando cade la connettività wireless locale. Secondo il team, questo è ciò che distingue il prodotto dai competitor.
- **Elementi commerciali che condizionano l'architettura:** moduli attivabili e disattivabili in base a quanto il cliente paga; mercato italiano orientato all'investimento iniziale più che al canone; policy di proprietà della versione acquistata ancora da definire.
- **Migrazione:** non si devono perdere clienti né transazioni del sistema "Globo". I log vanno classificati, perché in alcuni casi si sono rivelati decisivi.

---

## 3. Mappa concettuale provvisoria

Prima suddivisione in zone, ricavata incrociando la riunione del 12/10 con l'indice del manuale. È un'ipotesi da validare: alla riunione si era chiesto di arrivare a 3–8 zone senza riuscirci.

| # | Zona | Contenuto principale | Dove vive oggi |
|---|------|----------------------|----------------|
| 1 | **Identità e accesso** | Operatori e ruoli (Amministratore, Manager, Supervisore, Operatore), login con card, visibilità per sala in HQ | WinMT, tabelle, permessi DB, utenti Windows (HQ) |
| 2 | **Clienti e card** | Anagrafica, card RFID/barcode, master/slave, unione card, livelli (Silver/Platinum/Gold/Compleanno), blacklist, raccolta card di terzi | WinMT, card fisica, DB |
| 3 | **Valore a circuito chiuso** | Crediti veri e bonus, token, ticket cartacei e ticketless, punti, ricariche, crediti di servizio, fondo cassa, chiusure di cassa | Card (saldi), DB (movimenti), cassa, totem |
| 4 | **Macchine e telemetria** | Giochi, contatori incrementali, partite, mangia-ticket, gru, configurazione macchine, happy hour, tariffe per livello | Schede/firmware, servizio di sala, DB |
| 5 | **Premi e magazzino** | Articoli, giacenze, carichi, scarichi, ordini, prenotazioni, resi, reparti, fornitori, inventario, trasferimenti tra locali, lista approvata, distributori automatici | WinMT, DB, file `.mdb`/liste remote |
| 6 | **Promozioni** | Campagne (es. compleanno), eventi, happy hour, bonus su ricarica | WinMT/ECL, server |
| 7 | **Reportistica e analisi** | Rapporto macchine, movimenti card, rapporti amministratori, andamento premi, profitto, dashboard HQ | WinMT, HQ |
| 8 | **Multi-sala e governo remoto** | Gruppi di locali, card valide nel gruppo, Dare/Avere tra locali, magazzino centrale, configurazione remota, replica cloud | HQ, sincronizzatore |

Trasversali a tutte le zone: **dispositivi e periferiche** (cassa, totem, lettori, stampanti, erogatori, pagamenti POS) e **modalità offline**.

---

## 4. Architettura attuale (as-is) per come emerge dalle fonti

**In sala**
- SQL Server locale, uno per sala.
- **WinMT**: monolite VB6 con molte variabili globali, controlli ADOX e OCX deprecati. Si collega al database con un utente **`sa`**; gli operatori sono scelti da una tabella. Comprende cassa, back office di sala e setup. Le periferiche sono collegate via seriale, anche USB-seriale virtuale.
- **Servizio di sala** (monolite .NET): parla con le schede delle macchine, le configura, espone API per la web app e per i token, gestisce i buffer dei ticket. È in corso di scomposizione.
- **Broker MQTT di sala**, che dialoga anche con l'esterno.
- **Motore periferiche** (sviluppato da Antonio): rileva i dispositivi sulle seriali (lettore QR, RFID, erogatore card, stampante, accettatore banconote) e li espone via MQTT con broker locale alla postazione. È già usato o pensato per totem e cassa.
- **Totem**: oggi scrive direttamente nel database; il nuovo totem userà le API. Esiste un mockup multilingua.
- **Web app per installatori**: crea e configura macchine collegandosi al server di sala, con test e scrittura firmware. Esiste anche una nuova interfaccia di configurazione dei giochi basata su API, da integrare.

**In cloud (HQ)**
- Una copia del database per ogni sala.
- Il **sincronizzatore** è un software .NET schedulato ogni 5 minuti. Dei trigger scrivono una tabella di log per ogni tabella sincronizzata; il sincronizzatore confronta i log di sala e cloud, li ordina cronologicamente e applica le operazioni in entrambe le direzioni. Fabrizio lo definisce "un tema delicato".
- L'**applicazione HQ** riusa molte maschere di WinMT, gira su VB6 in terminal server ed è esposta via emulazione HTML5. È soprattutto consultazione (dashboard, report, cassa, clienti), più la configurazione delle macchine e la gestione remota del magazzino sulla copia del database.
- La **visibilità sulle sale** dipende dall'utente Windows, da una tabella mantenuta a mano e dai permessi sui database.

**Comportamento offline**

| Dispositivo | Senza server |
|-------------|--------------|
| Gioco | Funziona: scrive ticket e saldi sulla card, bufferizza; riconcilia al successivo appoggio della card su mangia-ticket, totem o cassa |
| Mangia-ticket | Si ferma con errore; va in offline solo se configurato manualmente, e allora stampa scontrino cartaceo |
| Totem | Fuori servizio |
| Cassa | Concettualmente fuori servizio |

---

## 5. Glossario iniziale

| Termine | Significato provvisorio | Note |
|---------|-------------------------|------|
| **Sala / Locale** | Punto vendita con il proprio database | In HQ ogni sala corrisponde a un database |
| **Gruppo multi-locale** | Insieme di sale in cui la card del cliente è valida | Già presente nel manuale (§ 6) |
| **Operatore** | Utente del software (cassiere, supervisore, ecc.) | Da non confondere con il cliente |
| **Cliente** | Giocatore | Nel parlato talvolta chiamato "utente" |
| **Card** | Tessera RFID (presumibilmente MIFARE) o barcode | Contiene **saldi**, non movimenti; settori cifrati |
| **Credito** | Denaro caricato, spendibile solo in sala | Non riconvertibile in euro (rischio riciclaggio) |
| **Bonus** | Credito omaggio legato alla ricarica | Escluso dai conteggi fiscali, incluso nei conteggi di resa macchina |
| **Token** | Unità di gioco venduta al totem (es. 5 € = 50 token) | Rapporto con i "crediti" da chiarire |
| **Ticket** | Unità di vincita; 1 ticket = 0,01 € di valore premio | Cartacei: anonimi, al portatore. Ticketless: attribuiti alla card |
| **Punti** | Ticket accumulati sulla card | Il manuale cita "1 ticket = punti" come funzione nuova, senza descriverla |
| **Mangia-ticket** | Macchina che conta i ticket cartacei (Galileo / Galileo PRO) | Probabile origine del nome "MT" |
| **Gioco / Macchina** | Apparecchio redemption | Ha 8 contatori incrementali |
| **Dispositivo lettore card sul gioco** | Lettore su cui il cliente appoggia la card | Trascritto come "BI", "BE", "ABE", "vie": **nome da verificare** |
| **Gru** | Macchina che eroga direttamente premi fisici | Il valore del premio dipende dal carico; usa un campo "ticket" per contare i premi |
| **ECL** | Sistema coinless (cashless) Elmac | Abilitabile per sala; senza ECL si gestiscono solo i ticket |
| **Totem** | Chiosco self-service: acquisto e ricarica card, redeem | Accettatore banconote, POS, erogatore card |
| **Cassa** | Postazione operatore | Ricariche, consegna premi, chiusure, consultazioni |
| **Chiusura di cassa** | Riepilogo e chiusura del periodo per operatore | Anche per i totem |
| **Crediti di servizio** | Partite gratuite concesse dall'operatore a fronte di un disservizio | |
| **Reparto** | Destinazione interna dei premi (Gru, Consumabili, Eventi, Ruspe, Guasti) | |
| **Lista approvata** | Elenco dei premi ordinabili sala per sala, definito centralmente | Nata per il mercato inglese |
| **Prize HUB** | Non documentato | |
| **Globo** | Sistema precedente da cui migrare | **Da chiarire se coincide con WinMT** |
| **Noleggio** | Giochi di un proprietario installati in una sala di altri | Ripartizione dell'incasso con percentuale per singola macchina |

---

## 6. Problemi noti emersi

**Dati e database**
1. Le chiavi sono hash a 32 bit invece di progressivi numerici, con problemi di prestazioni oltre i 2 milioni di record.
2. Il database è quasi del tutto privo di chiavi esterne.
3. L'accesso avviene come `sa`: nessun audit significativo e nessun confine di sicurezza.
4. I ruoli sono gestiti due volte, nell'applicazione e nei permessi del database (in HQ).
5. Carichi e scarichi stanno in tabelle distinte.
6. **L'inventario sovrascrive la quantità a giacenza senza generare un movimento di rettifica.** È il difetto più grave per un gestionale di magazzino.
7. Si riusano campi con significato diverso: nella gru il campo "ticket" conta i premi, distinti a video da parentesi quadre.
8. Il livello card ha default 0, che corrisponde a Platinum, cioè al livello più alto. Un errore di inizializzazione promuove quindi tutte le card.

**Processi e dispositivi**
9. Liste premi e carichi viaggiano come file `.mdb` spediti o copiati, anche via chiavetta USB.
10. Il dispositivo sul gioco avvia la partita *prima* di scrivere sulla card. Una correzione firmware è in corso.
11. In HQ si possono generare movimenti di magazzino remoti su dati di cui l'autorità è la sala.
12. La configurazione remota delle macchine è possibile anche a sala aperta.
13. Lo stesso barcode compare su articoli diversi, per fornitori diversi o per prassi di carico.

**Organizzativi**
14. Gli operatori non registrano i carichi delle gru, o li registrano con giorni di ritardo, e la resa delle macchine risulta falsata. Nel noleggio questo diventa un rischio economico per il proprietario dei giochi.
15. La conoscenza critica, cioè il "perché è fatto così", è nella testa delle persone.

---

## 7. Orientamenti emersi (non ancora decisioni formali)

- La logica applicativa va implementata **una sola volta, lato server**; i client restano sottili.
- **Web** per back office, statistiche, magazzino, reportistica e dashboard (HQ).
- **Cassa** come applicazione locale (Flutter + API), con le periferiche gestite dal motore MQTT e non dall'applicazione.
- **Totem** in Flutter + API, partendo dal mockup esistente.
- I movimenti fisici di sala (consegna premi, carichi effettivi) hanno come **autorità la sala**.
- Configurazione remota delle macchine vietata o limitata durante l'apertura, oppure se la macchina risulta attiva.
- Valorizzazione dei premi delle gru con **ricalcolo retroattivo** quando il carico viene dichiarato in ritardo, accompagnata da alert e da report che spieghino all'operatore da dove nasce un numero anomalo.
- Ruoli spostati a livello applicativo, con un unico utente DB a privilegi limitati. Il rapporto costi/benefici è ancora da valutare.
- Stack desktop: sono stati considerati Python/Qt e Flutter. Per Qt è emerso il **costo della licenza commerciale** come ostacolo in un prodotto da distribuire, il che va nella direzione di Flutter.

---

## 8. Incongruenze tra le fonti

| Tema | Riunione | Manuale | Da chiarire |
|------|----------|---------|-------------|
| Multi-sala | "Deve avere anche il multilocale", presentato come requisito nuovo | Esiste già: card valida nel gruppo, Dare/Avere tra locali, trasferimenti tra locali, opzione "Solo transazioni sicure" | Cosa manca davvero rispetto all'esistente: gestione per proprietario/operatore, magazzino centrale, report consolidati? |
| Ruoli | Gestiti sui permessi DB | Quattro ruoli applicativi con opzioni abilitabili | I permessi DB riguardano solo HQ (visibilità delle sale)? |
| Globo | "Il vecchio sistema" da migrare | Non citato | È WinMT/HQ attuale o un sistema ancora precedente? |
| Rapporto ticket/valore | 1 ticket = 1 centesimo | Profitto = ticket × 0,01 − costo | È fisso o configurabile ("1 ticket = punti")? |

---

## 9. Presupposti impliciti della riunione esplorativa

La riunione esplorativa dà per noti questi elementi, che vanno esplicitati.

1. I tipi di cliente e i loro modelli di gestione: sala in affitto con giochi a noleggio, proprietario e gestore coincidenti (Albarella), integrazione con il software del proprietario (Vicenza), mercato inglese.
2. Cosa distingue funzionalmente **HQ** dal **back office di WinMT**: si è detto che "saranno due robe separate".
3. Le "altre cose" già sviluppate in parallelo e "pronte per interfacciarsi" con il nuovo sistema.
4. Il perimetro delle personalizzazioni già fatte per i singoli clienti, che diventerebbe requisito di un framework di personalizzazione.
5. Le funzionalità deprecabili, usate solo da clienti molto vecchi.
6. La documentazione esistente: i documenti di Toby, le tabelle su Google Docs, la "descrizione di tutto il DB" iniziata anni fa.
7. Il quadro normativo applicabile ai giochi redemption e ai premi, e i requisiti fiscali sui crediti (si è citata la maturazione del ricavo al momento della spesa).

---

## 10. Domande aperte per la fase 0

In ordine di impatto sull'architettura.

1. **Fonte di verità e offline.** Per ogni entità della zona 3 (crediti, bonus, ticket, punti): chi è l'autorità tra card, database di sala e cloud? Quali operazioni sono ammesse offline e con quale riconciliazione?
2. **Multi-sala.** I punti e i crediti sono spendibili ovunque nel gruppo? Con quale garanzia di consistenza quando una sala è offline, oggi coperta da "Solo transazioni sicure"? Esiste un livello "operatore/proprietario" sopra le sale, e uno "Elmac" sopra gli operatori?
3. **Identità dei record.** Come si identificano clienti, card e articoli in modo univoco tra sale diverse e nel cloud?
4. **Sincronizzazione.** Si mantiene la replica database-su-database o si passa a eventi applicativi via MQTT? Quali dati devono davvero risalire al cloud, con quale latenza, e quali devono scendere?
5. **Dispositivi.** Quali dispositivi esistono, con quale protocollo e quale comportamento offline? Cosa resta firmware e cosa diventa servizio?
6. **Magazzino.** Il modello dei documenti (bolle, ordini, trasferimenti, rettifiche) e il ruolo del magazzino centrale.
7. **Noleggio e ripartizioni.** Le regole di calcolo per macchina e i requisiti di affidabilità del dato.
8. **Modularità commerciale.** L'elenco dei moduli vendibili e il meccanismo di licenza.
9. **Migrazione da Globo.** Quali dati sono obbligatori e quali log vanno conservati.
10. **Normativa.** I vincoli ADM, fiscali e antiriciclaggio applicabili.

---

## 11. Prossimi passi proposti

1. **Database di sala.** Introspezione via script: inventario tabelle, colonne, stored procedure, trigger (inclusi quelli del sincronizzatore), viste, ricerca delle relazioni implicite.
2. **Manuale.** Mappatura capitolo per capitolo verso le zone del § 3, ed elenco delle maschere come base per il censimento delle funzionalità.
3. **Raccolta documenti esistenti.** Documenti di Toby, tabelle Google Docs, documentazione di Fabrizio su HQ, gru e report.
4. **Riunione del 19/10.** Usare i §§ 8–10 come traccia, puntando a chiudere almeno le domande 1, 2 e 3.
