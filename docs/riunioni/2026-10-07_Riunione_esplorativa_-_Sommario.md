# Riunione esplorativa 07/10/2026 — Sommario Plaud (testo estratto)

> Estratto dalla pagina HTML salvata da Plaud. Riassunto generato automaticamente: le attribuzioni di nomi e le date nel piano d'azione sono inferite dallo strumento e vanno verificate.

1. Strategia di Progetto e Ristrutturazione Tecnologica
La discussione si centra sulla necessità di rilanciare un progetto esistente, trattandolo come un'iniziativa con un inizio e una fine chiari, poiché i competitor hanno superato il prodotto attuale e questa è considerata l'ultima opportunità di investimento. Il sistema attuale, basato su un database originariamente in Access e un front-end in VB6 emulato in HTML5, presenta gravi problemi di scalabilità, prestazioni (con archivi che superano i 2 milioni di record a causa di chiavi hash a 32 bit), manutenibilità e un rischio imminente di "hard stop" a causa della tecnologia obsoleta. Sebbene il sistema includa tutte le funzionalità utente necessarie, la sua interfaccia è datata e non è più vendibile.
La soluzione proposta è una riscrittura completa, partendo da un'analisi funzionale approfondita per definire cosa il prodotto deve fare, invece di replicare la struttura esistente che contiene scorciatoie e non rispecchia le reali necessità. Questo richiederà interviste per definire requisiti come la gestione multi-locale e una logica di magazzino rivista. Si affronterà anche la gestione dei ruoli, attualmente complessa e duplicata tra applicazione e permessi del database, con l'idea di centralizzarla a livello applicativo.
L'investimento passato di 2 milioni non ha generato ritorni diretti, ma è stato cruciale per il controllo delle operazioni dei clienti. Si ritiene che esista ancora spazio di mercato se il prodotto viene reso solido e moderno. L'urgenza del progetto è alta.
2. Piano di Analisi e Validazione Operativa
Si riconosce che una pre-analisi di 10-15 ore non è sufficiente. Si propone invece di investire in un'analisi strutturata per produrre un documento di progetto dettagliato (obiettivi, rischi, requisiti, roadmap) in collaborazione con gli stakeholder interni. Piero si occuperà di coordinare questa fase, partendo da un incontro informale con Antonio e Fabrizio per definire interlocutori e disponibilità.
Una parte cruciale dell'analisi sarà la validazione sul campo. È fondamentale osservare il software in azione, ad esempio in magazzino o in una sala giochi, per comprendere i flussi operativi reali e le deviazioni adottate dagli utenti, che spesso non seguono i percorsi previsti. Questo coinvolgerà l'osservazione diretta e interviste con il team di assistenza per raccogliere problemi ricorrenti e soluzioni pratiche, evitando di costruire funzionalità che non verranno utilizzate correttamente.
3. Strategia Commerciale, Modularità e Migrazione
Il progetto deve definire un nuovo modello di business. Si discuterà la strategia di pricing, considerando che il mercato italiano preferisce un investimento iniziale piuttosto che modelli "as a service", anche se esistono alternative cloud (es. Tigapo). Si analizzeranno voci come startup fee, maintenance e canoni, usando come riferimento benchmark storici. Un aspetto chiave sarà la progettazione di un'architettura modulare che permetta di attivare/disattivare funzionalità in base ai pagamenti del cliente. Collegata a questo, andrà definita la policy di proprietà del software: il cliente diventerà proprietario della versione acquistata in un dato momento, gestendo separatamente gli aggiornamenti futuri.
Infine, si pianificherà la migrazione dal vecchio sistema "Globo", con l'obiettivo di non perdere clienti e dati transazionali. Si valuterà quali log conservare, dato il loro valore in situazioni critiche, e si progetterà una nuova strategia di backup, decidendo se mantenere il modello attuale o adottarne uno più moderno.
4. Gestione delle Risorse e Piano d'Azione Complessivo
Il team interno (Giannina, Mauro, Toby e un nuovo ragazzo) ha risorse limitate e deve continuare a gestire il business corrente. Sarà necessario un piano di allocazione del tempo per bilanciare le attività operative con quelle di progetto. Le attività a minor rischio, come la revisione di documenti, potranno essere assegnate alla nuova risorsa per valorizzarla, mentre i profili esperti si concentreranno sugli aspetti critici.
Piano d’azione
Creare una stima di tempi e costi per il progetto e un quadro economico preliminare. -- 
[Inserire Nome]
Piero
Fase di Analisi:
Effettuare una pre-analisi (10-15 ore) per definire il perimetro del progetto. -- 
[Inserire Nome]
Organizzare un incontro informale (2 ore) tra Piero, Antonio e Fabrizio per chiarire contesto e interlocutori. -- 
Piero, Antonio, Fabrizio
 (2026-10-09)
Redigere un piano di disponibilità di Piero. -- 
Piero
 (2026-10-11)
Condurre una serie di interviste per raccogliere i requisiti funzionali del nuovo sistema (HQ, backoffice, totem). -- 
[Inserire Nome]
, 
Noi (team interno)
Elaborare un documento di analisi approfondito (obiettivi, rischi, requisiti, roadmap). -- 
Piero, Team interno
 (2026-10-21)
Validazione Operativa:
Effettuare una visita in una sala giochi (es. bowling di Rubano) e sessioni di osservazione in magazzino per mappare i flussi reali. -- 
[Inserire Nome]
, 
Piero, Giannina, Mauro
 (2026-10-18)
Intervistare il team di assistenza per raccogliere problemi ricorrenti. -- 
Piero, Team assistenza
 (2026-10-16)
Analisi Tecnica e Funzionale:
Analizzare il database esistente per comprenderne struttura e lacune. -- 
[Inserire Nome]
Proporre soluzioni per il nuovo "database 3.0" basate sull'analisi funzionale. -- 
[Inserire Nome]
Valutare il rapporto costi-benefici per la centralizzazione della gestione dei ruoli. -- 
[Inserire Nome]
, 
Noi (team interno)
Effettuare un'analisi SWOT per confrontare il prodotto con i competitor. -- 
[Inserire Nome]
Strategia Commerciale e Architettura:
Mappare i modelli di pricing possibili per il mercato italiano. -- 
Piero, [Inserire Nome]
 (2026-10-19)
Definire l'architettura di moduli "accendibili/spegnibili". -- 
Toby, Mauro
 (2026-10-28)
Stabilire le policy di proprietà del software e degli aggiornamenti. -- 
Piero, Giannina
 (2026-10-25)
Sviluppo e Migrazione:
Modificare il front-end monolitico (scritto in WB6). -- 
Noi (il team interno)
Aggiornare i firmware delle schede per risolvere i bug. -- 
Noi (il team interno)
Definire il piano di migrazione da "Globo". -- 
Mauro, Toby
 (2026-10-27)
Classificare i log da mantenere e progettare la nuova strategia di backup. -- 
Piero, Mauro, Toby
 (2026-10-23, 2026-10-26)
Gestione Risorse:
Redigere un piano di allocazione del tempo per il team interno. -- 
[Inserire Nome]
, 
Giannina, Mauro, Toby
 (2026-10-12)
Assegnare al nuovo ragazzo la revisione dei documenti di analisi. -- 
[Inserire Nome]
, 
"nuovo ragazzo"
 (2026-10-15)
Suggerimenti dell'IA
L'IA ha identificato i seguenti problemi che non sono stati conclusi nelle riunioni o che mancano di chiari piani d'azione; si prega di prestare attenzione:
Mancanza di Documentazione Funzionale e Governance:
 La conoscenza critica risiede "nelle teste" del team. Non è stato definito un piano formale per consolidarla in un documento di requisiti, né sono stati assegnati ruoli chiari (es. Project Manager, Analista Funzionale).
Definizione del Modello Commerciale:
 Manca una decisione finale sul modello di pricing (investimento upfront, canone o ibrido) e sulla policy di proprietà del software, inclusa la gestione degli aggiornamenti futuri per i clienti.
Priorità e Roadmap non Definite:
 Non è stata stabilita una roadmap o una prioritizzazione delle funzionalità (esistenti e nuove), lasciando incerto l'ambito della prima release del "progetto 3.0".
Decisioni Tecniche in Sospeso:
 Non è stata presa una decisione sulla gestione dei ruoli, sulla strategia di backup (mantenere l'attuale o adottarne una nuova) e sul perimetro esatto dei log da conservare.
Pianificazione e Budget:
 Manca un calendario preciso per le fasi di analisi e non è stato approvato un budget, rappresentando un rischio per l'avvio del progetto.
