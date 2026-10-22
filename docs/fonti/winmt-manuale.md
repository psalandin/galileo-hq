# Manuale WinMtSql (ELMAC II s.r.l.) — testo estratto

> Estratto da `WinMtSql_ITA_-_aggiornato.docx`. Le immagini sono sostituite da segnaposto `[img:nome]`.
> Il documento originale è in corso di aggiornamento: le note redazionali ("nuova funzione", "Nuova immagine", "Nuova sezione", "?????") sono conservate perché indicano parti non ancora documentate.

[img:image3.png]

[img:image4.png][img:image5.png]

[img:image6.png][img:image7.png][img:image8.png]

[img:image9.png]

ELMAC II s.r.l.

[img:image10.jpeg]Via G. Colombo,17 – 35030
Rubano (PD) – ITALY

Tel. 049.89.76.176 – Fax 049.89.76.179

[www.elmac.com](http://www.elmac.com) – <elmac@elmac.com>

**<span class="smallcaps">Sommario</span>**

[Come fare per… [6](#come-fare-per)](#come-fare-per)

[Descrizione del programma WinMtSql [7](#_Toc36563407)](#_Toc36563407)

[1 Finestra di Accesso [8](#finestra-di-accesso)](#finestra-di-accesso)

[1.1 Cambio Password Utente
[8](#cambio-password-utente)](#cambio-password-utente)

[1.2 Gestione Fondo Cassa
[8](#gestione-fondo-cassa)](#gestione-fondo-cassa)

[2.1 Opzioni di Sistema [9](#opzioni-di-sistema)](#opzioni-di-sistema)

[2.1.1 Opzioni Periferiche
[9](#opzioni-periferiche)](#opzioni-periferiche)

[2.1.2 Funzionalità [10](#funzionalità)](#funzionalità)

[2.1.3 Avanzate [11](#avanzate)](#avanzate)

[2.2 Opzioni Generali [13](#opzioni-generali)](#opzioni-generali)

[2.2.1 Impostazioni [13](#_Toc36563419)](#_Toc36563419)

[2.2.2 Funzionalità [14](#_Toc36563420)](#_Toc36563420)

[2.2.3 Opzioni Utente [16](#opzioni-utente)](#opzioni-utente)

[2.3 Opzioni Cards [19](#opzioni-clienti-vip)](#opzioni-clienti-vip)

[3 Finestra Principale Lato Cliente
[20](#finestra-principale-lato-cliente)](#finestra-principale-lato-cliente)

[4 Finestra Principale Lato Operatore
[21](#finestra-principale-lato-operatore)](#finestra-principale-lato-operatore)

[6 Prenotazioni con Card
[24](#prenotazioni-con-card)](#prenotazioni-con-card)

[7 Carica Card [25](#carica-tickets)](#carica-tickets)

[8 Vincite senza Card [26](#_Toc36563436)](#_Toc36563436)

[8.1 Vincite con Card [26](#vincite-con-card)](#vincite-con-card)

[9 Anagrafica Clienti [27](#anagrafica-clienti)](#anagrafica-clienti)

[9.1 Modifica Cliente [28](#_Toc36563439)](#_Toc36563439)

[9.2 Classifica Clienti [29](#classifica-clienti)](#classifica-clienti)

[9.3 Dettagli Cliente [30](#dettagli-cliente)](#dettagli-cliente)

[9.4 Genera Carta Master [30](#genera-vip-card)](#genera-vip-card)

[9.5 Genera Carta Slave [31](#genera-carta-slave)](#genera-carta-slave)

[9.6 Unisci Card [32](#unisci-card)](#unisci-card)

[9.7 Somma Punti [32](#somma-punti)](#somma-punti)

[10 ECL [35](#ecl)](#ecl)

[10.1 Rapporto Carte [35](#_Toc36563447)](#_Toc36563447)

[10.2 Rapporto Macchine [35](#_Toc36563448)](#_Toc36563448)

[10.3 Conteggio Macchine [36](#_Toc36563449)](#_Toc36563449)

[10.4 Modifica Contatori [37](#modifica-contatori)](#modifica-contatori)

[10.5 Macchine in Rete [38](#_Toc36563451)](#_Toc36563451)

[10.5.1 Configura Macchina Nuova [38](#_Toc36563452)](#_Toc36563452)

[10.5.2 Modifica Macchina Esistente [40](#_Toc36563453)](#_Toc36563453)

[10.6 Happy Hour [41](#_Toc36563454)](#_Toc36563454)

[11 Prenotazione dei Premi
[43](#prenotazione-dei-premi)](#prenotazione-dei-premi)

[12 Ordini – Consegna [44](#ordini-consegna)](#ordini-consegna)

[13 Ordini – Lista [45](#ordini-lista)](#ordini-lista)

[14 Prenotazioni – Lista [46](#prenotazioni-lista)](#prenotazioni-lista)

[15 Resi - Senza Card
[47](#resi-resi-per-non-vip)](#resi-resi-per-non-vip)

[16 Resi - Con Card [48](#resi-resi-per-vip)](#resi-resi-per-vip)

[17 Rapporto [49](#rapporti-1)](#rapporti-1)

[17.1 Menu Filtro [52](#menu-filtro)](#menu-filtro)

[17.2 Menu Mangia Tickets
[53](#menu-mangia-tickets)](#menu-mangia-tickets)

[18 Premi [54](#_Toc36563471)](#_Toc36563471)

[18.1 Movimenti - Carico [58](#movimenti---carico)](#movimenti---carico)

[18.1.1 Carico Magazzino Automatico
[58](#carico-magazzino-automatico)](#carico-magazzino-automatico)

[18.1.2 Carico Magazzino da Remoto
[59](#carico-magazzino-da-remoto)](#carico-magazzino-da-remoto)

[18.1.3 Carico Magazzino da Bolla
[60](#carico-magazzino-da-bolla)](#carico-magazzino-da-bolla)

[18.2 Movimenti - Scarico
[61](#movimenti---scarico)](#movimenti---scarico)

[18.3 Movimenti – Crea Ordine di Acquisto
[63](#movimenti-crea-ordine-di-acquisto)](#movimenti-crea-ordine-di-acquisto)

[18.4 Movimenti – Carico da Ordine di Acquisto
[64](#movimenti-carico-da-ordine-di-acquisto)](#movimenti-carico-da-ordine-di-acquisto)

[18.5 Movimenti – Trasferimenti Ingresso
[65](#movimenti-trasferimenti-ingresso)](#movimenti-trasferimenti-ingresso)

[18.6 Movimenti – Trasferimenti Uscita
[65](#movimenti-trasferimenti-uscita)](#movimenti-trasferimenti-uscita)

[18.7 Trasferimenti tra Locali
[65](#trasferimenti-tra-locali)](#trasferimenti-tra-locali)

[18.7.1 Carico Manuale [65](#carico-manuale)](#carico-manuale)

[18.7.2 Carico Automatico [66](#carico-automatico)](#carico-automatico)

[18.7.3 Scarico [66](#scarico)](#scarico)

[18.8 Visualizza Movimenti – Movimenti Magazzino
[67](#visualizza-movimenti-movimenti-magazzino)](#visualizza-movimenti-movimenti-magazzino)

[18.9 Visualizza Movimenti – Ordini di Acquisto
[69](#visualizza-movimenti-ordini-di-acquisto)](#visualizza-movimenti-ordini-di-acquisto)

[18.10 Rapporti – Andamento Premi in 6 settimane
[70](#rapporti-andamento-premi-in-6-settimane)](#rapporti-andamento-premi-in-6-settimane)

[18.11 Rapporti – Visualizza Inventario
[71](#rapporti-visualizza-inventario)](#rapporti-visualizza-inventario)

[18.12 Rapporti – Rapporto Settimanale
[72](#rapporti-rapporto-settimanale)](#rapporti-rapporto-settimanale)

[18.13 Rapporti – Rapporto Variazione
[73](#rapporti-rapporto-variazione)](#rapporti-rapporto-variazione)

[18.14 Rapporti – Rapporto Vendite
[74](#rapporti-rapporto-vendite)](#rapporti-rapporto-vendite)

[18.15 Rapporti – Rapporto Breve Utente
[74](#rapporti-rapporto-breve-utente)](#rapporti-rapporto-breve-utente)

[18.16 Fornitori [74](#fornitori)](#fornitori)

[18.17 Incassi – Registra Incassi
[75](#incassi-registra-incassi)](#incassi-registra-incassi)

[18.18 Incassi – Modifica Incassi
[75](#incassi-modifica-incassi)](#incassi-modifica-incassi)

[18.19 Inventario [76](#inventario)](#inventario)

[18.20 Salvataggio foto di un Articolo
[78](#salvataggio-foto-di-un-articolo)](#salvataggio-foto-di-un-articolo)

[19 Reparti [79](#_Toc36563511)](#_Toc36563511)

[20 Utilità [80](#utility)](#utility)

[20.1 Gestione Operatori [80](#gestione-operatori)](#gestione-operatori)

[20.2 Distributori [81](#_Toc36563524)](#_Toc36563524)

[20.3 Cancellazione Archivi [82](#_Toc36563525)](#_Toc36563525)

[20.4 Pulizia Archivi [83](#pulizia-archivi)](#pulizia-archivi)

[20.5 Conteggio Scontrini
[83](#conteggio-scontrini)](#conteggio-scontrini)

[20.6 Test Server Sql
[83](#test-velocità-sql-server)](#test-velocità-sql-server)

[20.7 Stampa [83](#stampa)](#stampa)

[20.8 Dettagli Scontrino [83](#dettagli-scontrino)](#dettagli-scontrino)

[21 Raccolta Carte [84](#raccolta-card)](#raccolta-card)

[21.1 Riabilita Carte [84](#_Toc36563538)](#_Toc36563538)

[21.2 Conteggio Carte [84](#conteggio-card)](#conteggio-card)

[22 Bonus Promozioni e Sconti
[85](#bonus-promozioni-e-sconti)](#bonus-promozioni-e-sconti)

[23 Aiuto – Manuale in linea [87](#_Toc36563541)](#_Toc36563541)

[24 Aiuto – Informazioni su WinMtSql [87](#_Toc36563542)](#_Toc36563542)

AVVERTENZA

Non si risponde di eventuali disservizi provocati da errato utilizzo del
PC.

Posizionare il computer in un’area adeguata e sufficientemente
arieggiata.

# Come fare per…

- [Generare una Card](#genera-vip-card)

- 

- [Dare un premio a un Cliente senza Card](\l)

- [Dare un premio a un Cliente con la Card](\l)

- [Reso di un premio da un Cliente senza card](\l)

- [Reso di un premio da un Cliente con card](\l)

- [Prenotare un premio a un Cliente senza Card](\l)

- [Prenotare un premio a un Cliente con la Card](\l)

- [Caricare degli scontrini su una Card](\l)[Visualizzare e stampare un
  rapporto](#rapporti-1)

Caricare dei premi nel Magazzino:

Ci sono 4 modi per caricare dei nuovi articoli:

- Usando il pulsante Nuovo della finestra [Gestione Magazzino
  Premi](#_Gestione_Magazzino_“Premi”)

- Usando il [Carico Automatico](#_Carico_Magazzino_Automatico)

- Usando il [Carico da Bolla](#carico-magazzino-da-bolla)

- Usando il software WinMtHQ – Carico da Lista Approvata - Carico Lista
  da Remoto

# Descrizione del programma WinMtSql

WinMtSql permette la gestione automatizzata delle raccolte punti nelle
sale giochi attraverso il collegamento alle macchine MANGIA-TICKETS
Galileo e Galileo PRO e l’uso di carte di identificazione e
fidelizzazione dei Clienti.

Vantaggi principali:

- Estrema rapidità nella lettura degli scontrini tramite codice a barre

- Controllo totale, nelle consegne dei premi ai Clienti

- Fidelizzazione dei Clienti attraverso l’uso della carta per le
  operazioni di Carico tickets e scarico premi.

- Gestione informatizzata del magazzino premi con l’uso dei codici a
  barre su tutti gli articoli

E’ previsto l’accesso al programma in modo AMMINISTRATORE, MANAGER,
SUPERVISORE o OPERATORE.

L’AMMINISTRATORE ha il controllo completo del programma con l’accesso a
tutti i menu e a tutti i dati disponibili.

Il MANAGER ha gli stessi diritti dell’Amministratore escluso quello di
accedere alle [Opzioni di configurazione](#_Opzioni).

Il SUPERVISORE e l’OPERATORE sono in grado di gestire solamente le
normali operazioni di conteggio dei punti e consegna dei premi.

L’Amministratore può abilitare Managers, Supervisori ed Operatori ad
eseguire altre attività selezionando le varie opzioni nel tab “Opzioni
Utente” della finestra “[Opzioni Generali](#opzioni-utente)”.

## [img:image11.png]Finestra di Accesso

E’ la finestra di avvio del programma, permette la scelta dell’operatore
e l’eventuale cambio della sua PASSWORD.

La password iniziale dell’Amministratore è: “elmac”, e si deve digitare
al primo avvio del programma e va poi cambiata. Quando l’Amministratore
genera i nuovi Operatori in “[GESTIONE OPERATORI](#utility)” , la
password di default è “password”; ogni Operatore, potrà cambiarla
seguendo le istruzioni che seguono.

L’accesso può essere effettuato anche con le Cards leggendone il codice
a barre o l’RFID. Vedere il paragrafo “[Gestione Operatori](#utility)”.

## [img:image12.png][img:image13.emf]Cambio Password Utente

Premere l’apposito pulsante, riempire i 3 campi e premere “CONFERMA”.

## Gestione Fondo Cassa

Se l’opzione “CASH MANAGEMENT” in Setup\Opzioni di Sistema\Opzioni
Periferiche è abilitata, appena effettuato il login, l’operatore vedrà
la finestra che gli permette di inserire il valore di fondo cassa a sua
disposizione per le operazioni che comportano movimenti di denaro nella
cards dei clienti.<span id="_Opzioni" class="anchor"></span>

Configurazione

Prima di poter utilizzare il programma è necessario procedere alla sua
configurazione accedendo al menu “Setup” della schermata principale.

Il menu Setup contiene 3 sotto menu:

- <u>Impostazione di Sistema</u>: per la configurazione base, l’hardware
  connesso, lingua, connessione al server ecc.

- <u>Impostazione Generali</u>: per la scelta delle opzioni di
  funzionamento, degli utenti ecc.

- Opzioni clienti VIP: per tutte le opzioni riguardanti le carte dei
  clienti.

- Impostazioni ECL: <span class="mark">nuova funzione</span>

- Impostazioni sistema 4 utenti: <span class="mark">nuova
  funzione</span>

## Opzioni di Sistema

Le opzioni di Sistema sono divise in 3 categorie:

- [img:image14.png]**Opzioni Periferiche**

- **Funzionalità**

- **Avanzate**

## Opzioni Periferiche

> <span class="mark">Nuova immagine</span>

- **Scelta porte di comunicazione**: questa opzione permette di
  scegliere le porte alle quali sono collegate le varie periferiche che
  compongono il sistema (stampante, lettore di codice a barre,
  lettore/scrittore di carte magnetiche, lettore RFID, Mangia Ticket).
  Per le Mangia Ticket c’è un numero identificativo (**ID**) per
  distinguere una Mangia Ticket dell’altra per il controllo, nella
  finestra “Rapporto” del numero di tickets contati da ogni singola
  macchina. Ogni Mangia Tickets può essere assegnata ad un diverso
  reparto (che deve essere stato preventivamente creato in “Gestione
  Reparti”. La scelta delle porte di comunicazione viene fatta
  normalmente in automatico premendo il pulsante “AUTODETECT
  Periferiche”.

- **Scelta Stampante**: Seleziona la stampante collegata al sistema.

- **Card Reader**: seleziona il modello del card reader collegato al
  sistema.

- **Traccia Card**: Seleziona la traccia delle cards utilizzata dal
  sistema, il numero della traccia deve essere 2; questa opzione è
  riservata ad utenti ESPERTI.

- **Risoluzione Mon.2**: Indicare negli appositi campi, la risoluzione
  orizzontale e verticale in punti, del monitor rivolto verso i clienti,
  questo per permettere al sistema di adattare le immagini al monitor
  stesso.

- **Messaggio per lo Scontrino**: scrivere in questo spazio il messaggio
  che verrà stampato in ogni scontrino generato dal sistema.

- **Tastiera Virtuale**: se il monitor dell’utente è touch screen questa
  opzione permette di compiere tutte le normali operazioni senza
  utilizzare la tastiera fisica.

- **Scanner delay**: il ritardo tra le letture dei codici a barre degli
  scontrini.

- **ECL**: varie opzioni che riguardano il sistema ECL e che saranno
  configurate dall’installatore del sistema stesso.

- L’opzione “**CASH MANAGEMENT**” abilita o meno la postazione al carico
  di crediti nelle cards.

- L’opzione **“CUSTOMER ID”/ “INSTALLATION ID”**: ad ogni cliente viene
  assegnato un codice numerico identificativo univoco ed un numero
  impianto.

- L’opzione **“NETWORK SETUP CARD”**: permette la creazione della card
  di configurazione. Appoggiare una card sul lettore da banco RFID e
  premere il pulsante “Network Setup Card”.

- L’opzione **“Tickets cartacei/ Ticketless”**: il gestore di sala può
  lasciare la scelta al Cliente finale se preferisce ad accumulare
  ticket cartacei oppure ticket elettronici. Se disabilitato il gestore
  decide il funzionamento della sala giochi.

- L’opzione **“BONUS”**: In fase di carico crediti sulla card si può
  decidere se in base all’importo caricato, per esempio per 50€ di
  “Importo” il cliente riceve 5€ di “Bonus”.

**  
**

## Funzionalità

> <span class="mark">Nuova immagine</span>

[img:image15.png]

- **Lingua**: Seleziona la lingua.

- **Cambio Gestione**: se selezionato, permette di scegliere la data
  inizio della nuova gestione.

- **Importa Lista Approvata**: Questa finestra serve per configurare le
  opzioni di carico in magazzino della [Lista
  Approvata](#movimenti---scarico) tramite il software WinMtHQ.

  - Selezionare le varie caselle di controllo per determinare i valori
    da sovrascrivere (Aggiorna Riserva, Aggiorna Barcode, Aggiorna
    Tickets, Aggiorna Costo).

- **Mangia Tickets non Collegate**: permette di abilitare l’accettazione
  di scontrini emessi da mangia tickets non collegate al sistema. Oltre
  ad abilitare l’opzione è necessario inserire le 4 cifre del codice
  macchina (0XXX) della mangia tickets da abilitare. Una volta inseriti
  i codici è necessario salvarli per farli comparire nella lista a
  discesa.

  - [img:image16.png][img:image17.png]**Vedi il manuale del
    Mangia Ticket utilizzato (anche non Elmac) per programmare il CODICE
    MACCHINA.**

[img:image20.png][img:image21.png]

[img:image24.png]

- **Opzioni Raccolta Carte**: se selezionato abilita il riconoscimento
  delle cards provenienti da varie macchine tipo la “Mistral” di Elaut o
  la “DC Comics” di Namco. Per abilitare l’opzione occorre disporre
  delle apposite cards fornite da ELMAC e provviste dell’apposito codice
  a barre. Scegliere “Abilita”, premere il pulsante SETTA CARD, leggere
  il codice di una card con lo scanner. Premere il pulsante “Modifica
  Valori” per accedere alla finestra che permette di cambiare i valori
  delle singole cards o delle serie di cards che i giochi prevedono.

- **Velocità diapositive**: E’ la velocità con cui scorrono le
  diapositive sul monitor secondario quando non è utilizzato. Il tempo è
  espresso in millesimi di secondo, quindi 3000 corrisponde a 3 secondi.

- 1 ticket = punti: <span class="mark">nuova funzione</span>

## Avanzate

<span class="mark">Nuova immagine</span>

[img:image25.png]

- **Sql Server Auth**: permette l’inserimento del nome del Server SQL e
  della password di accesso. Premere “Test Connessione” per verificare
  che il server scelto sia raggiungibile.

- **Registra eventi**: Se selezionato abilita il salvataggio di tutte le
  operazioni effettuate in un file di testo per successive verifiche.

- **Multiutenza**: quando sono presenti più di una postazione ognuna di
  esse deve avere un Id univoco che la identifica nella rete. L’id 101
  fa riferimento al pc master.

- **Salva Tick. Letti**: salva LOG degli scontrini letti.

- **Disco di backup**: impostare la lettera del dispositivo di memoria
  dove verrà fatto il backup degli archivi. Questa opzione è visibile
  solamente quando il server Sql risiede nella stessa macchina, quando è
  installato un Micro Server, il backup viene eseguito dal Micro Server
  stesso.

- **Sostituzione Codice**: se abilitato, durante il carico automatico,
  se il codice di un premio è duplicato viene sovrascritto dal codice a
  barre.

- **Modifica Codice Premi**: se selezionato rende possibile la modifica
  del codice dei premi nella finestra **Gestione Magazzino Premi.**

- **APP Mobile:** se selezionata, il cliente è in possesso
  dell’applicazione Galileo. L’opzione permette a due tipologie di user
  (admin e operatore) di accedere all’interfaccia web della
  configurazione dell’App.

- **Server Wake Up:** questo riquadro contiene le impostazioni usate
  dall’utilità di accensione remota del server. Vengono impostate da
  Elmac.

- **ECL Server Auth.**: parametri di accesso al server sul cloud per
  ECL. Vengono impostati da Elmac.

- **Elenco dei Locali collegati:** se abilitata da Elmac la funzione
  **MULTI - LOCALE**, in questo riquadro compaiono i nomi e i codici dei
  locali che fanno parte del gruppo. I clienti del gruppo, avranno la
  possibilità di usare la loro Card in qualsiasi locale del gruppo.
  L’opzione “Solo transazioni sicure” impedisce lo scarico dei punti
  dalle cards quando il locale si trova off line.

- **“Data di scadenza dell’abbonamento”**: qui viene riportata la data
  di scadenza del contratto di assistenza e dell’abbonamento dei servizi
  cloud.

- **Server Email Address**: inserire l’indirizzo mail per ricevere le
  notifiche per quanto riguarda le card che vanno in blacklist.

- **Secondary server: <span class="mark">nuova funzione</span>**

## Opzioni Generali

Le opzioni Generali sono divise in 3 categorie:

- **Impostazioni**

- **Funzionalità**

- **Opzioni Utente**

2.  

    1.  
    2.  

## Impostazioni

<span class="mark">Nuova immagine</span>

[img:image26.png]

- **Dati del Locale:** inserire il nome e l’indirizzo del locale, verrà
  visualizzato e stampato nei vari rapporti generati dal programma.

- **Estremi dell’Operazione:** inserire nome, data di inizio e di fine
  dell’Operazione Tickets.

- **Orario:** immettere l’ora di apertura e di chiusura del locale,
  verranno utilizzati nel calcolo dei rapporti.

- **Elenco locali per trasferimenti di magazzino:** se il cliente
  possiede più di un locale; l’opzione permette di generare un file dei
  premi e trasmetterlo verso un altro locale.

- impostazione promozione card a VIP: <span class="mark">nuova
  funzoine</span>

<span id="_Funzionalità" class="anchor"></span>

## Funzionalità

[img:image27.png]

- **Promozioni:** abilita e configura le Promozioni, vedere “[Bonus
  Promozioni e Sconti](#bonus-promozioni-e-sconti)” per informazioni più
  dettagliate.

- **Campi Obbligatori per nuova Card:** determina quali informazioni sul
  Cliente devono essere obbligatoriamente inserite per poter generare
  una nuova card.

- **Registra Incassi:** abilita e configura il sistema di registrazione
  degli incassi utilizzato nei rapporti di vendita.

- **Gestione Magazzino Premi:**

  - **N. Tickets Automatico**: permette al sistema di calcolare e
    memorizzare in maniera automatica il valore in tickets di un oggetto
    che si sta inserendo nel magazzino. Il valore in Euro dell’oggetto
    verrà moltiplicato per il numero immesso nel campo “Moltiplicatore”
    e il risultato sarà memorizzato come valore in tickets dell’oggetto
    stesso.

  - **Modifica Quantità Premi**: permette all’Amministratore di
    modificare direttamente nella tabella della finestra “Gestione
    Magazzino Premi”, le quantità dei singoli oggetti. Se disabilitato,
    la modifica della quantità sarà possibile solo attraverso operazioni
    di carico e scarico di magazzino con la conseguente tracciabilità di
    ogni movimento.

  - **Nascondi Movimenti:** se selezionato nasconde i menu relativi al
    carico e allo scarico del magazzino

  - **Nascondi Sistema Ordini di Acquisto:** per informazioni
    dettagliate vedere “[Ordini di
    Acquisto](#movimenti-crea-ordine-di-acquisto)”

  - **Consenti di cancellare Ordine di Acquisto:** se selezionato
    permette di cancellare gli Ordini di Acquisto.

<!-- -->

- **Registra premio**: Se selezionato, abilita la registrazione dei
  premi di valore superiore a quanto immesso nel campo “Massimo N.D.”
  (N.D = Non Dichiarabile).

- **Cancellazione Automatica Ordini non Riscossi:** imposta i giorni
  utili per il ritiro di un premio ordinato utilizzando l’App Galileo e
  per quanti giorni il cliente verrà avvisato via email della scadenza.
  Quando un ordine scade i punti equivalenti vengono ricaricati sulla
  card del cliente ed il premio reintegrato nel magazzino.

- **Opzioni Inventario:**

  - **Azzera Quantità reale**: se selezionato, la colonna Q.TA’ REALE
    sarà a zero.

  - **Ora prefissata**: abilita ora prefissata per il salvataggio
    dell’inventario.

  - **Nascondi quantità macchine:** <span class="mark">nuova
    funzione</span>

- **Scontrino Manuale:** Obbliga o meno l’inserimento di una password
  per poter stampare uno scontrino manuale.

- **Visualizza in Vincite:** specifica se, nella tabella della schermata
  “Vincite” verranno visualizzati i premi con quantità a zero e quelli
  impostati come inattivi.

- [img:image28.jpeg]**Disabilita Messaggio di
  avvertenza:** se selezionato durante lo scarico dei premi con

quantità=0, non verrà visualizzato il messaggio di avvertenza.

- **Schermo Cliente:** seleziona cosa visualizzare sullo schermo del
  cliente.

- **Modo Semplificato:** In questa modalità di funzionamento la finestra
  principale appare come a lato. In questa modalità non è prevista la
  gestione del magazzino premi. Il numero dei punti spesi viene digitato
  direttamente toccando i relativi tasti sullo schermo touch screen.
  Nell’esempio visualizzato si sta scaricando un premio del valore di 90
  punti dalla card del cliente n.3727 che contiene, in origine, 457
  punti. Premendo OK l’operazione se concluderà e nella card resteranno
  367 punti. Se invece si usano gli scontrini in “Punti accumulati”
  verrà evidenziata la somma degli stessi ed i “Punti rimanenti”
  verranno stampati sullo scontrino di resto alla conclusione
  dell’operazione.

- **Stampa Ricevuta Premio:** Se selezionato, attiva la stampa dello
  scontrino per il ritiro del premio.

- **Prenotazione Premi:** Abilita la possibilità di prenotare i premi ai
  clienti (vedi “[Prenotazione Premi](#ecl)”)

- **Pren.** Senza Card: se selezionato permette la prenotazione dei
  premi anche ai clienti sprovvisti di card.

- **Abbuoni:** Se selezionato abilita la possibilità di regalare al
  Cliente un certo numero di tickets per permettergli di avere un premio
  di valore superiore ai punti che in realtà possiede. Il valore
  dell’abbuono elargito, viene memorizzato con i dati relativi
  all’operatore che ha effettuato l’abbuono stesso nonché data e ora
  dell’operazione. Gli abbuoni si possono dare tenendo conto di questi 2
  parametri:

  - PERCENTUALE: Stabilisce la percentuale massima abbuonabile rispetto
    al valore in tickets dell’oggetto in questione.

  - N.TICKETS: Stabilisce il numero massimo di tickets abbuonabili.

> Se ad esempio impostiamo a 10 la percentuale e a 500 il numero massimo
> di tickets abbuonabili, con un premio del valore di 100 tickets
> potremmo abbuonarne al massimo 10 (10% di 100) mentre con un premio
> del valore di 10.000 potremmo abbuonarne al massimo 500.

- **Disabilita Messaggio di avvertenza:** se selezionato durante lo
  scarico dei premi non verrà visualizzato il messaggio di avvertenza.

<!-- -->

- **Promemoria Card:** Se selezionato, ad ogni operazione di scarico
  punti da una card, viene stampato uno scontrino con il saldo dei
  punti.

- **Valore Massimo Scontrini:** imposta il valore massimo degli
  scontrini manuali o da reparto.

- **Colore della Finestra Principale:** permette di personalizzare la
  schermata principale modificandone a piacere il colore dello sfondo.

- **Valore Massimo Operazioni con Scontrini**

  - **Valore Massimo Scontrino Manuale:** imposta il valore massimo
    degli scontrini manuali o da reparto.

  - **Valore Massimo Premio con Scontrini:** imposta il valore massimo
    del premio che si può scaricare con lo scontrino.

<!-- -->

- **Opzione V2:** <span class="mark">nuova funzione</span>

## Opzioni Utente

- [img:image29.jpeg]**Opzioni Operatore**:
  imposta le opzioni di lavoro per l’utente “Operatore”.

<!-- -->

- **ABILITA RISCRIVI CARD**: Se selezionato abilita la possibilità di
  riscrivere le card dei clienti.

- **ABILITA SCONTR. MANUALE**: Se selezionato permette di generare gli
  scontrini manuali con le opzioni selezionate nell’apposito riquadro.

- **ABILITA RESI**: Se selezionato, offre la possibilità di gestire i
  premi resi.

- **ABILITA RAPPORTO**: l’operatore ha la possibilità di accedere alla
  finestra “Rapporto”.

- **ABILITA MENU PREMI**: abilita l’apertura della finestra “Gestione
  Magazzino Premi” per fare operazioni di carico e scarico o di
  inventario.

- **ABILITA CARICO REMOTO**: abilita la possibilità di caricare nel
  magazzino premi le liste inviate al locale da remoto tramite il
  software WinMtHQ.

- **ABILITA GESTIONE CLIENTI**: permette di accedere alla finestra
  “[Anagrafica Clienti](#anagrafica-clienti)”

- **ABILITA MODIFICA CLIENTI**: se abilitato permette di modificare i
  dati del Cliente (Nome, Cognome, Telefono, Email, Indirizzo, Note,
  ecc.)

- **AUTO LOG-OFF**: se abilitato ad ogni consegna di un premio,
  l’operatore deve rientrare nel programma.

- **Nascondi pulsante Scontrino Manuale**: se abilitato il pulsante
  SCONTRINO MANUALE non verrà visualizzato nella finestra VINCITE.

- **ABILITA MENU REPARTI**: permette o meno la stampa di scontrini da
  Reparto.

<!-- -->

- **Opzioni Supervisore**: imposta le opzioni di lavoro per l’utente
  “Supervisore”.

<!-- -->

- **ABILITA RISCRIVI CARD**: Se selezionato abilita la possibilità di
  riscrivere le card cliente.

- **ABILITA SCONTR. MANUALE**: Se selezionato permette di generare gli
  scontrini manuali con le opzioni selezionate nell’apposito riquadro.

- **ABILITA RESI**: Se selezionato, offre la possibilità di gestire i
  premi resi.

- **ABILITA RAPPORTO**: l’operatore ha la possibilità di accedere alla
  finestra “Rapporto”.

- **ABILITA MENU PREMI**: abilita l’apertura della finestra “Gestione
  Magazzino Premi” per fare operazioni di carico e scarico o di
  inventario.

- ABILITA CARICO REMOTO: abilita la possibilità di caricare nel
  magazzino premi le liste inviate al locale da remoto tramite il
  software WinMtHQ.

- **ABILITA GESTIONE CLIENTI**: permette di accedere alla finestra
  “[Anagrafica Clienti](#anagrafica-clienti)”

- **ABILITA MODIFICA CLIENTI**: se abilitato permette di modificare i
  dati del Cliente (Nome, Cognome, Telefono, Email, Indirizzo, Note,
  ecc.)

- **AUTO LOG-OFF**: se abilitato ad ogni consegna di un premio,
  l’operatore deve rientrare nel programma.

- **Nascondi pulsante Scontrino Manuale**: se abilitato il pulsante
  SCONTRINO MANUALE non verrà visualizzato nella finestra VINCITE.

- ABILITA MENU REPARTI: permette o meno la stampa di scontrini da
  Reparto.

<!-- -->

- **Opzioni Manager**: imposta le opzioni per l’utente “Manager”.

  - **Password Inventario**: se abilitato consente al manager di salvare
    l’inventario.

  - **Ordini di Acquisto**: permette al Manager di accedere al sistema
    degli Ordini di Acquisto.

  - **Visualizza Opzioni in Carico Lista Approvata**: se selezionato,
    nella finestra “Carico Lista Approvata”, sarà possibile cambiare le
    opzioni di carico.

  - **Nascondi Cancella Premio**: se selezionato il Manager non può
    cancellare premi dal magazzino.

  - **Modifica Prezzi**: abilita o meno la possibilità di modificare i
    prezzi degli articoli in magazzino.

  - **Modifica Tickets**: abilita o meno la possibilità di modificare il
    valore in tickets degli articoli in magazzino.

  - **Modifica Descrizione**: abilita o meno la possibilità di
    modificare la descrizione degli articoli in magazzino.

  - **Modifica Barcode**: abilita o meno la possibilità di modificare il
    codice a barre degli articoli in magazzino.

  - **Aggiunge Nuovi Articoli**: se abilitato consente al Manager di
    aggiungere nuovi articoli premendo il tasto “Nuovo” nella finestra
    “Gestione Magazzino Premi”.

  - **Gestione Fornitori**: abilita il Manager alla gestione dei
    Fornitori.

  - **Nascondi pulsante Scontrino Manuale**: se abilitato il pulsante
    SCONTRINO MANUALE non verrà visualizzato nella finestra VINCITE.

  - **Scontrini Manuali Multipli**: abilita la stampa degli scontrini
    manuali multipli.

Inoltre nella finestra Opzioni Generali sono presenti 3 pulsanti:

- [img:image30.png]**Gestione Reparti**: apre
  la finestra visualizzata a lato, che permette l’inserimento del nome
  di 7 reparti, ciascun reparto è individualmente abilitabile. Il
  Reparto “1” è obbligatoriamente esistente ed assegnato ai tickets
  emessi dalle Redemptions. Se è abilitata l’opzione “Raccolta Cards” in
  Setup\Opzioni di Sistema, il Reparto “2” sarà assegnato
  automaticamente a questo scopo. Per ogni reparto è possibile emettere
  scontrini, a fronte per esempio di una consumazione, che verranno
  conteggiati separatamente. Immettere il nome del reparto nel campo
  “Nome” e selezionare la casella “Abilita” se si desidera abilitare
  quel reparto. L’abilitazione di un reparto necessita obbligatoriamente
  che ne sia stato inserito il nome; quando uno o più reparti sono
  abilitati, nella riga del menu della finestra “PRINCIPALE”, appare
  anche la voce “REPARTI” che permette di aprire la finestra “SCONTRINO
  REPARTI”.

- **Ricalcola Tickets nelle Cards:** alla chiusura della finestra e
  premendo il pulsante “Salva ed Esci” viene eseguita la verifica ed il
  ricalcolo dei punti accumulati da ciascun Cliente.

- [img:image31.jpeg]**Variabili Incasso ECL**:
  in base ai parametri impostati viene calcolato l’incasso dei giochi.

## [img:image32.jpeg]Opzioni Clienti VIP

**OPZIONI CLIENTI CON CARD**

- Sconto sul valore dei Premi: percentuale di sconto, su tutti i premi e
  senza limitazioni di tempo, a cui ha diritto il cliente possessore di
  card.

- Tickets Omaggio creazione card: Numero di tickets che vengono caricati
  automaticamente quando una nuova card viene generata.

- Tickets omaggio 24 ore: Numero di tickets che vengono regalati al
  cliente con la prima operazione effettuata dall’apertura giornaliera
  del locale. L’ora di apertura è quella fissata negli appositi campi
  del riquadro ORARIO della cartella GENERALI.

- Tickets minimi per omaggio 24 ore: per avere diritto al bonus di cui
  sopra, il cliente deve caricare nella card almeno il numero di tickets
  specificati. Quando estrarrà la card dalla Mangia Tickets, il display
  mostrerà il totale dei tickets accumulati dal cliente comprensivo di
  quelli appena contati e del bonus. Se il numero minimo di tickets per
  il “bonus 24 ore” è uguale a zero, il cliente avrà diritto al bonus
  semplicemente passando la card nel lettore della cassa. In questo caso
  il bonus acquisito verrà segnalato al cliente da un’apposita scritta
  lampeggiante sul suo monitor.

**SCONTO o PROMOZIONI**

- Somma Sconto a Promozioni: se abilitato, il cliente avrà diritto,
  oltre allo sconto specificato, anche alla promozione eventualmente in
  corso. Se non abilitato, si ha la possibilità di scegliere se
  applicare lo sconto o la promozione.

**TICKETS BONUS**

Permette di regalare ai Clienti **muniti di card**, un numero di tickets
in base alla percentuale impostata. Impostando l’opzione Tickets Bonus
come in figura avremo che un cliente con card che contasse 100 tickets
nel periodo durante il quale il BONUS è abilitato, otterrebbe un bonus
di 10 Ticket, se ne contasse 1000, ne otterrebbe 100. I tickets dati
come bonus, vengono conteggiati a parte e visualizzati nell’apposito
campo nella finestra RAPPORTO. Quando l’opzione Tickets Bonus è attiva,
viene segnalata da una scritta lampeggiante sul monitor cliente e da una
fissa nel monitor operatore.

Per dettagli vedi [BONUS PROMOZIONI E
SCONTI](#bonus-promozioni-e-sconti)

## Impostazioni ECL 

<span class="mark">Sezione nuova</span>

> [img:image33.png] style="width:7.59375in;height:4.27083in" />

- Scelta porte di comunicazione:

  - Lettore ECL:

  - Terminale POS:

- ECL server Auth:

  - Server name:

  - DB Name:

  - Password:

  - Confirm password:

  - User name:

- SSID:

- PRE-SHARED KEY:

- COSTUMER ID:

- INSTALATION ID:

- COIN/MONEY RATIO:

- LCM Name:

- COIN/LCM Ratio:

- COIN:

- TOKEN:

- BONUS ECL:

- IMPORTI RICARICA DA POS:

- Lascia la scelta al cliente se vuole Etickets o tickets

- Abilita gestione cassa

## [img:image34.png]Impostazione sistema 4 utenti

<span class="mark">Nuova sezione</span>

- Porte di comunicazione barcode readers 4 utenti:

- Abilita 4 operat.:

- Monitor 3:

- Messaggio pubblicitario:

- 

## Finestra Principale Lato Cliente

[img:image35.jpeg]E’
la finestra a disposizione dei Clienti. Normalmente visualizza delle
immagini pubblicitarie a tutto schermo, le immagini devono essere in
formato \*.jpeg e devono essere copiate nella cartella
C:\WinMtSql\immagini\\

Se un Cliente o l’operatore passa la card nel lettore, la
visualizzazione pubblicitaria si interromperà e verranno visualizzati i
dati relativi al Cliente, codice, nome, cognome (se abilitato), tickets
accumulati e premi disponibili con quel numero di tickets. Durante la
fase di ritiro dei premi, verranno inoltre mostrati i dati relativi
all’operazione stessa, tickets spesi, tickets rimanenti, ecc..

## Finestra Principale Lato Operatore

[img:image36.jpeg]

[img:image37.png][img:image38.png][img:image39.png]

Locale Singolo

> Multi – Locale non connesso
>
> Multi – Locale connesso

Totem Error: <span class="mark">nuova funzione</span>

[img:image43.png]

E’ la schermata principale del programma attraverso la quale si
effettuano le operazioni fondamentali: il pagamento delle vincite ai
clienti, la tabella mostra i premi in magazzino con Codice, Descrizione,
Numero Tickets e Quantità giacente. Cliccando sopra il titolo di una
colonna, gli articoli verranno ordinati in base alla colonna che abbiamo
cliccato, ri-cliccando sullo stesso titolo l’ordine si inverte, da
crescente a decrescente e viceversa. Il colore dello sfondo è
personalizzabile dalla finestra “Setup\Opzioni Generali”. Da questa
finestra si accede, attraverso il Menu, a tutte le altre schermate e
funzionalità del programma. I comandi principali sono facilmente
utilizzabili attraverso uno schermo tattile per un utilizzo più
immediato e veloce.

**Descrizione degli oggetti:**

Pulsante CLIENTI: passa alla schermata di gestione dei Clienti.

Pulsante SCONTRINO MANUALE: apre la relativa finestra che permette di
stampare gli scontrini manuali.

- Premi scelti: è la lista (visibile anche dal Cliente sul suo monitor)
  contenente gli articoli già scelti e pronti per lo scarico.

- Tickets accumulati: numero di tickets accumulati dal Cliente nella
  card o letti dagli scontrini (visibile anche dal Cliente).

- Tickets di resto: numero di tickets che rimarranno al Cliente dopo che
  sarà stata pagata la vincita (visibile anche sul monitor del Cliente).

Pulsante Cancella premio: comando per effettuare la cancellazione, dalla
lista dei premi scelti, del premio selezionato ed evidenziato (anche sul
monitor Cliente) sulla lista stessa.

- Tickets Manuali: permette l’inserimento manuale di uno scontrino nel
  caso in cui il codice a barre non risulti leggibile con il lettore di
  codici a barre. Inserire il numero di tickets e il numero di serie
  dello scontrino negli appositi campi e premere il tasto AGGIUNGI.

<!-- -->

- Quantità: immettere la quantità dell’oggetto che si intende scaricare
  PRIMA di sceglierlo.

Pulsante CARICA TICKETS: pulsante che apre la finestra “Carica Scontrini
su Card”.

Pulsante CARICA CREDITI: pulsante che apre la finestra “Carica Crediti
su Card”

Pulsante SCONTRINO TOTALE: comando che serve ad ottenere uno sco

ntrino somma degli scontrini precedentemente letti.

- Dati Cliente: visualizza i dati relativi al Cliente che sta
  effettuando l’operazione di ritiro dei premi (visibili anche sul
  monitor secondario).

- Codice – Barcode: immettere un Codice premio o un Codice a barre
  (secondo l’opzione abilitata sotto al campo) per filtrare i premi in
  tabella per Codice o Barcode.

- Descrizione: immettere la descrizione o una parte di essa per
  ricercare un premio che corrisponda a quella descrizione.

- ID: immettere un ID breve di un premio per filtrare la tabella secondo
  l’ID immesso.

[img:image44.jpeg]Pulsante CLIENTE: pulsante
che permette di selezionare una card cliente immettendone il relativo
codice (soli utenti ADMINISTRATOR o MANAGER): inserire il codice del
Cliente desiderato nel campo Codice e premere il pulsante “Cliente”
equivale a passare la card nel lettore/scrittore di banda magnetica o
leggerne il codice a barre.

Pulsante PRENOTA PREMI: (visibile se abilitata l’apposita opzione nella
finestra “[Opzioni Generali\Funzionalità](#_Funzionalità)”) quando
premuto, diventa arancione per indicare che si sta prenotando un premio
(vedi [Prenotazioni senza Card](#_Prenotazioni_senza_Card_1),
[Prenotazioni con Card](#prenotazioni-con-card))

Pulsante STAMPA BILANCIO: compare solamente se abilitata l’opzione
“Promemoria Card” in “[Opzioni Generali\Funzionalità](#_Funzionalità)”

Pulsante ANNULLA: comando che serve ad annullare un’operazione di ritiro
premi, corrisponde al tasto ESC della tastiera.

Pulsante SCARICA PREMI: comando che finalizza l’operazione di ritiro dei
premi da parte di un Cliente. Premendolo, i premi selezionati, vengono
scaricati dal magazzino e il relativo numero di tickets viene tolto al
Cliente. Nel caso il Cliente non possiede la CARD viene emesso uno
scontrino di resto.

Pulsante STAMPA BILANCIO: stampa il numero di punti disponibili nella
card inserita.

Pulsante CHIUDI SESSIONE: termina la sessione di lavoro per chiudere il
programma o passare ad altro operatore.

Pulsante PRENOTAZIONI: apre la finestra “Lista Prenotazioni”.

Pulsante ORDINI: apre la finestra “Lista Ordini”.

Pulsante MESSAGGI: apre, nel browser, il pannello di gestione messaggi
da App (visibile solo se l’opzione APP è abilitata).

Pulsante PREPARAZIONE ORDINI DA TOTEM: questo pulsante compare solo se
nel locale è stato installato un Totem.

Pulsante Family Card: <span class="mark">nuova funzione</span>

Family Card

[img:image45.png]<span class="mark">Nuova
sezione</span>

3.  <span id="_Prenotazioni_senza_Card_1" class="anchor"></span>

4.  

5.  Prenotazioni senza Card

[img:image46.jpeg]

Per poter effettuare prenotazioni a fronte di scontrini cartacei, la
relativa opzione in Setup\Opzioni Generali\Funzionalità deve essere
abilitata.

Di seguito verranno illustrate le operazioni da effettuare per la
prenotazione di premi a un Cliente che non possiede la Card.

- Premere PRENOTA PREMI (il pulsante diventerà arancione).

- Leggere gli scontrini del Cliente col lettore di codici a barre.

- Se uno scontrino non può essere letto dal lettore (sbiadito o
  stropicciato) inserire negli appositi campi del riquadro “Tickets
  Manuali”, il numero di tickets e il numero di serie dello scontrino e
  premere “AGGIUNGI”.

- Scegliere i premi richiesti facendo un doppio click sulla tabella
  all’estrema sinistra sulla linea corrispondente al premio scelto.

- Premendo sulla tastiera una lettera, in tabella verranno visualizzati
  solo i premi che iniziano per la lettera premuta.

- Il premio può essere scelto leggendone il codice (vedi menu
  File\Stampa NEOS\\ Singolo Barcode o tutti i barcode in [GESTIONE
  MAGAZZINO
  PREMI](file:///C:\Users\piero\Downloads\Telegram%20Desktop\Premi#_Gestione_Magazzino_)
  per le modalità di stampa dei codici dei premi).

- Il premio scelto viene visualizzato nel campo “premi scelti”.

- Se un premio è stato scelto per errore, è possibile toglierlo dalla
  lista selezionandolo dall’elenco e premendo “CANCELLA PREMIO”

- Terminata la scelta dei premi, premere “SCARICA PREMI” o F5 per
  concludere l’operazione.

- Verrà richiesto di inserire i dati del cliente: nome, cognome e numero
  telefonico.

- Verrà stampato uno scontrino con: Data, Nome e cognome del cliente,
  Codice del premio prenotato, Descrizione del premio prenotato, Valore
  in tickets del premio prenotato da consegnare al Cliente.

- Nel caso ci siano tickets di resto, verrà automaticamente stampato uno
  scontrino di resto per il Cliente.

## Prenotazioni con Card

Di seguito verranno illustrate le operazioni da effettuare per la
prenotazione di premi a un Cliente che possiede la Card.

- Premere PRENOTA PREMI (il pulsante diventerà arancione).

- Passare la card nel lettore, verranno visualizzati i dati del Cliente
  e il numero di tickets da lui accumulati.

- Scegliere i premi richiesti facendo un doppio click sulla tabella
  all’estrema sinistra sulla linea corrispondente al premio scelto.

- Premendo sulla tastiera una lettera, in tabella verranno visualizzati
  solo i premi che iniziano per la lettera premuta.

- Il premio può essere scelto leggendo col lettore di codici a barre, il
  codice del premio stesso (vedi menu File\Stampa NEOS\\ Singolo Barcode
  o tutti i barcode in [FINESTRA GESTIONE MAGAZZINO
  PREMI](file:///C:\Users\piero\Downloads\Telegram%20Desktop\Premi#_Gestione_Magazzino_)
  per le modalità di stampa dei codici dei premi).

- [img:image47.jpeg]Il premio scelto viene
  visualizzato nel campo “premi scelti”.

- Se un premio è stato scelto per errore, è possibile toglierlo dalla
  lista selezionandolo dall’elenco e premendo “CANCELLA PREMIO”

- Terminata la scelta dei premi, premere “SCARICA PREMI” o F5 per
  concludere l’operazione.

## Carica Tickets

[img:image48.png] Permette di:

- caricare uno o più scontrini sulla card appena letta.

- Al solo Amministratore di caricare un numero di tickets a piacere.

In alto è visualizzato il cognome ed il nome del cliente seguito, in
basso a sinistra, dal numero di tickets attualmente nella card. Il
riquadro centrale contiene l’elenco degli scontrini letti con codice a
sinistra e numero tickets a destra. Le due frecce laterali servono per
scorrere la lista. Subito sotto è visualizzato il numero totale dei
tickets contenuti negli scontrini letti seguito, subito sotto, dalla
somma dei due numeri precedenti.

Per caricare degli scontrini sulla card agire come segue:

- leggere lo scontrino con lo scanner che verrà aggiunto alla lista con
  numero di serie e numero tickets, se il codice non viene letto dal
  lettore riempire i campi nel riquadro “Scontrino non leggibile” e
  premere “+”.

- per aggiungere tickets senza che provengano da uno scontrino (solo
  amministratore), scriverne il numero nel campo in basso a sinistra e
  premere INVIO sulla tastiera del PC. Verrà generato uno scontrino
  virtuale che si aggiungerà alla lista.

- per eliminare dalla lista uno scontrino indesiderato sceglierlo con le
  frecce laterali e premere CANCELLA SCONTRINO

- per annullare l’operazione senza modificare il numero di tickets che
  il cliente ha sulla Card premere ANNULLA OPERAZIONE

- per terminare l’operazione e caricare l’ammontare dei tickets sulla
  card premere OK.

Una volta premuto il tasto OK la finestra sparisce, nel riquadro
“Tickets accumulati” comparirà il nuovo totale dei tickets nella card e
si potrà procedere allo scarico dei premi richiesti dal cliente.

##  Carica Crediti

> [img:image48.png] style="width:3.03472in;height:2.85903in" />Caricare crediti a fronte
> del loro valore in denaro. Questo valore andrà ad aggiungersi alla
> cassa per un controllo totale dei movimenti di moneta. Questa
> possibilità deve essere abilitata per la postazione con l’apposito
> parametro in “Setup\Opzioni di Sistema\Opzioni Periferiche”.

- Per aggiungere crediti alla card premere i tasti, sulla tastiera di
  destra, per formare l’importo in denaro che il cliente vuole caricare,
  il relativo numero di crediti verrà visualizzato nella relativa riga.
  Premere “OK” per confermare l’operazione e tornare alla pagina
  principale.

1.  

2.  

3.  

4.  1.  
    2.  
    3.  

## Vincite senza Card

Di seguito verranno illustrate le operazioni da effettuare per
l’assegnazione di premi a un Cliente che non possiede la Card.

- Leggere gli scontrini del Cliente col lettore di codici a barre.

- Se uno scontrino non può essere letto dal lettore (sbiadito o
  stropicciato) inserire negli appositi campi del riquadro “Tickets
  Manuali”, il numero di tickets e il numero di serie dello scontrino e
  premere “AGGIUNGI”

- Scegliere i premi richiesti facendo un doppio click sulla tabella
  (lista dei premi) all’estrema sinistra sulla linea corrispondente al
  premio scelto.

- Per velocizzare la ricerca il contenuto della tabella premi può essere
  limitato in vari modi:

  - Premendo sulla tastiera una lettera, in tabella verranno
    visualizzati solo i premi che iniziano per la lettera premuta.

  - Scrivendo negli appositi spazi (Ricerca per CODICE, DESCRIZIONE o
    ID) la lista viene limitata ai premi che soddisfano i criteri di
    ricerca.

- Il premio può essere scelto anche leggendone il codice a barre, (vedi
  menu File\Stampa NEOS\\ Singolo Barcode, o tutti i barcode in
  [GESTIONE MAGAZZINO
  PREMI](file:///C:\Users\piero\Downloads\Telegram%20Desktop\Premi#_Gestione_Magazzino_)
  per le modalità di stampa dei codici dei premi).

- Il premio scelto viene visualizzato nel campo “premi scelti”.

- Se un premio è stato scelto per errore, è possibile toglierlo dalla
  lista selezionandolo dall’elenco e premendo “CANCELLA PREMIO”

- Terminata la scelta dei premi, premere “SCARICA PREMI” o F5 per
  concludere l’operazione.

- Nel caso ci siano tickets di resto, verrà automaticamente stampato uno
  scontrino di resto per il Cliente.

## Vincite con Card

Di seguito verranno illustrate le operazioni da effettuare per
l’assegnazione di premi a un Cliente che possiede la Card.

- Passare la card nel lettore o leggere il barcode stampato sul retro;
  verranno visualizzati i dati del Cliente e il numero di tickets da lui
  accumulati

- Scegliere i premi richiesti facendo un doppio click sulla tabella
  all’estrema sinistra sulla linea corrispondente al premio scelto.

- Premendo sulla tastiera una lettera, in tabella verranno visualizzati
  solo i premi che iniziano per la lettera premuta.

- Il premio può essere scelto leggendo col lettore di codici a barre, il
  codice del premio stesso (vedi Stampa Locale Singolo o tutti i barcode
  in [GESTIONE MAGAZZINO
  PREMI](file:///C:\Users\piero\Downloads\Telegram%20Desktop\Premi#_Gestione_Magazzino_)
  per le modalità di stampa dei codici dei premi).

- Il premio scelto viene visualizzato nel campo “premi scelti”.

- Se un premio è stato scelto per errore, è possibile toglierlo dalla
  lista selezionandolo dall’elenco e premendo “CANCELLA PREMIO”

- Terminata la scelta dei premi, premere “SCARICA PREMI” per concludere
  l’operazione.

- I punti rimanenti verranno memorizzati sull’Anagrafica Clienti e
  visualizzati ripassando la Card sul lettore/ scrittore di carte
  magnetiche.

[img:image49.png]

## Anagrafica Clienti

Permette la gestione dell’anagrafica dei Clienti e relative Card.

Descrizione degli oggetti:

Pulsante GENERA CARDS: visualizza la finestra omonima per generare una
nuova card.

Pulsante LEGGI CARD: premendo questo pulsante, il sistema si pone in
attesa del passaggio di una card nel lettore (il pulsante lampeggia).
Passando una card, in tabella appariranno i dati relativi a quella card.

Pulsante RISCRIVI CARD: serve a fare una copia di una card già generata,
in caso di smarrimento o di mal funzionamento dell’originale. Scegliere
in tabella il Cliente in oggetto, premere RISCRIVI CARD, se è abilitato
il codice a barre della card, leggerlo con lo scanner e passare la card
nel lettore.

Pulsante FORMATTA CARD: effettua la cancellazione totale dei dati
presenti sulla card (formattazione). Questa operazione si rende
necessaria se una card risulta non scrivibile. Selezionando “Tutte le
tracce” la formattazione verrà eseguita su tutte e tre le tracce della
card altrimenti verrà formattata solo la traccia in uso.

Pulsante MODIFICA CLIENTE: premendo questo pulsante, si apre la finestra
“Modifica Cliente”, l’opzione che permette di modificare i dati del
Cliente (Nome, Cognome, Telefono, Email, Indirizzo ecc.)

Pulsante STOP: Interrompe l’operazione in corso (lettura, generazione di
cards o formattazione).

Pulsante CERCA:

- **Nome e Cognome**: permette la ricerca veloce di un cliente
  all’interno della tabella semplicemente digitandone il nome o il
  cognome all’interno dell’apposito campo.

- **Barcode**: permette la ricerca veloce di un cliente all’interno
  della tabella semplicemente digitando il codice a barre della card.

- **ID**: permette la ricerca tramite id.

Pulsante CLASSIFICA CLIENTI: apre la finestra [Classifica
Clienti](#classifica-clienti).

Pulsante DETTAGLI CLIENTI: apre la finestra [Dettagli
Cliente](#dettagli-cliente).

Pulsante UNISCI CARDS: serve per cancellare una o più cards e caricare i
punti in un’altra.(Unisci Cards)

Pulsante AGGIORNA: rigenera li lista Clienti in tabella.

Pulsante ELIMINA: serve a cancellare una card e tutti i dati ad essa
relativi. Prima della cancellazione verrà chiesta conferma.

Pulsante VINCITE: torna alla finestra
[Vincite](#finestra-principale-lato-operatore).

## Modifica Cliente

<span class="mark">Immagine nuova</span>

[img:image50.png]

Si apre questa finestra premendo il tasto omonimo. Si ha ora la
possibilità di modificare tutti i dati del Cliente selezionato.

Quando i campi “CARD MASTER 1” e “CARD MASTER 2” non sono entrambi vuoti
significa che il Cliente in questione possiede una Card Slave card cioè
“unita” alla card o alle cards identificate nei due campi “CARD MASTER”.
Per rendere Master una card Slave è sufficiente cancellare i due campi.

Per rendere Slave una card basta, in questa finestra, leggere una card
che non sia già, a sua volta, unita (Slave) ad altre cards. Il pulsante
“Registra email” serve ad abilitare un Cliente all’uso dell’App Galileo
per controllare i suoi punti e ordinare premi utilizzando lo smartphone.
Il pulsante “Salva ed Esci” chiude la finestra salvando i dati
modificati, il pulsante “Esci” chiude senza salvare le modifiche.

“Consenso” al trattamento dei dati personali – il cliente decide se dare
il consenso oppure no.

Pulsante “codice a barre” permette al stampa del barcode presente sulla
fidelity card.

“Ticket cartacei”/”Ticketless” offre la posibilità al cliente di
scegliere se accumulare ticket elettronici oppure cartacei.

<span class="mark">Nuova funzionalità:</span> checkbox con le seguenti
scelte: Consenti uso dei dati, Consenti invio messaggi, Consenti
condivisione a terzi. Inoltre un riquadro chiamato ECL con ID tessera e
tipo di tessera (PLATINUM per esempio)

## Classifica Clienti

In questa finestra è possibile visualizzare l’elenco dei Clienti
possessori di card.

[img:image51.png]Attraverso gli appositi
controlli è possibile filtrare la tabella in vari modi per
personalizzare la lista a piacere. Questa lista la si può stampare ed
esportare in formato csv o Excel per utilizzarla in programmi esterni
quali, per esempio, utilità di mass-mailing per l’invio di messaggi di
posta elettronica a tutti i clienti per promozioni, auguri o annunci
pubblicitari. <span class="mark">Nuova funzione</span>: filtro per tipo
di card

[img:image52.png][img:image53.png]

## Dettagli Cliente

[img:image54.png]

> <span class="mark">Immagine nuova</span>

Questa finestra permette la visualizzazione e la stampa delle operazioni
effettuate dal Cliente selezionato:

- Le operazioni di carico di punti nella tabella “Tickets”.

- I premi vinti nella tabella “Premi”.

- I crediti acquistati in cassa o al Totem.

- I crediti utilizzati nei vari giochi presenti in sala.

I dati nelle tabelle possono essere limitati per data, i punti per
quelli ancora disponibili.

Le liste visualizzate possono essere stampate e esportate cliccando su
menu File.

## [img:image55.jpeg]Genera VIP Card

I campi evidenziati in rosso, sono obbligatori (scegliere in [Opzioni
Generali](#opzioni-generali) quali lo devono essere).

Inserire i dati richiesti, selezionare il tipo di card che si vuole
generare tra le 3 possibili e leggere l’RFID o il barcode della card se
richiesti.

Dopo l’inserimento dei dati nei campi obbligatori, compare il pulsante
“Salva”.

Quando l’operazione va a buon fine il nuovo cliente viene aggiunto alla
tabella.

In fase di generazione della nuova card il campo Ticketless è abilitato.
Se il cliente desidera i ticket cartacei e necessario disabilitare
l’opzione “Ticketless”.

ATTENZIONE: Secondo le norme vigenti è necessario che il Cliente compili
e firmi il consenso al trattamento dei suoi dati.

## [img:image56.jpeg]Genera Carta Slave

Se, nella finestra precedente, si abilita l’opzione “Carta Slave” si
passerà alla generazione di una carta slave. La carta Slave deve essere
associata ad una o due carte Master sulle quali potranno essere
trasferiti i suoi punti (vedi Somma Punti”).

Le operazioni da fare sono le stesse di cui al punto precedente tranne
che si deve obbligatoriamente selezionare una o due carte Master.

[img:image57.jpeg]

Premendo MASTER 1 o MASTER 2 viene visualizzata la seguente schermata:

le carte master devono essere precedentemente registrate nel sistema;
possono essere scelte leggendone il relativo codice a barre, l’Rfid o
utilizzando lo strumento di ricerca per cognome. Quando i riquadri
mostrano i dati corretti, salvare. Si tornerà alla finestra precedente
che mostrerà anche i dati della carta master prescelta.

A questo punto sarà possibile premere il pulsante “Salva”.

## Unisci Card

Si arriva a questa finestra dopo aver scelto un cliente, che sarà il
destinatario dei punti, ed aver premuto il pulsante “Unisci Card”.
Selezionare adesso la carta o le carte i cui punti confluiranno nella
carta destinazione, per farlo occorre leggerne i codici a barre. I dati
salienti delle carte scelte appariranno in tabella, in basso il totale
dei punti della carta destinazione dopo l’operazione. Premere “Esegui” e
rispondere affermativamente alla successiva richiesta di conferma. Si
tornerà alla schermata precedente, la carta destinazione sarà stata
caricata con i punti delle carte sorgente le quali saranno state
azzerate.

[img:image58.png]Se si desidera cancellare
totalmente queste carte è necessario farlo, una ad una, scegliendole in
tabella e premendo “Elimina”.

<span class="mark">Immagine nuova</span>

## Somma Punti

Si arriva a questa finestra dopo aver scelto un cliente possessore di
una carta Master carta cioè, associata ad una o più carte Slave ed aver
premuto il pulsante “Somma Punti”. Questo sarà il destinatario dei punti
che decideremo di spostare dalle sue carte Slave che compariranno
automaticamente nella lista.

Per decidere quanti punti scaricare da ogni carta basterà fare un doppio
click sulla tabella in corrispondenza della carta desiderata:

Impostare nel campo “<u>Tickets da sottrarre</u>” il numero di punti
desiderato e premere “OK”. Tornati alla finestra precedente premere
“Esegui”.

Descrizione dei Menu della Finestra Principale

<span class="mark">Aggiornato (nuova versione)</span>

**Ordini**

- Consegna

- Lista

- Prepara

**Prenotazioni**

- Lista

**Resi**

- Resi per non VIP

- Resi per VIP

**RapportI**

**ECL**

- Generazione card rfid

- Generazione automatica card rfid

- Strumenti gestione carte RFID

- Incassi amministrativi

- Macchine

  - Nuova

  - Esistente

  - Modifica costo partita

  - Raggrupamenti macchine

- Promozioni

- Eventi

- Gestione HappyHours

- Visualizzazione blacklist

- Recupero card

- Cancellazione automatica card rfid

- Rapporti

  - Conteggio macchine

  - Controllo cassa

  - Movimenti card

  - Macchine

  - Crediti di servizio

  - Rapporti vari

  - Rapporti per amministratori

- Nuovo modello

**Magazzino**

- Premi

- Prize HUB

- Gestione GRU

**Aree**

**Utility**

- Gestione Operatori

- Distributori

- Manutenzione archivio

- Pulizia Archivio

- Conteggio Scontrini

- Test velocità SQL Server

- Stampa

  - Comandi

  - Numeri

- Dettagli Scontrino

**Raccolta Card**

- Riabilita Carte

  - Tutti

  - Mistral

- Conteggio Carte

  - Tutti

  - Mistral

**Setup**

- Impostazioni di Sistema

- Impostazioni Generali

- Opzioni Clienti VIP

- Opzioni Sistema 4 Utenti

**Guida**

- Manuale online

  - WinMtSql

- Informazioni su WinMT

## ECL

## Generazione card rfid

[img:image60.png]<span class="mark">Nuova
sezione</span>

## Generazione automatica card rfid

<span class="mark">Nuova sezione</span> l’opzione è in grigio dunque non
so cosa ci sia dentro

## Strumenti gestione card rfid

<span class="mark">Nuova sezione</span>, non conosco la password dunque
non posso scrivere le opzioni disponibili

## [img:image61.png]Incassi amministrativi

> <span class="mark">nuova sezione</span>
>
> periodo di incasso:
>
> aggiorna:
>
> esporta incasso:
>
> stampa incasso:
>
> esci:

## Macchine

## [img:image62.png]Nuova

<span class="mark">Immagine nuova</span>

Questa finestra permette l’inserimento e la configurazione di una nuova
macchina installata nel locale, nella rete ECL.

- Si inizia scegliendo, dal menu a discesa “Macchina”, il nome della
  macchina da installare. Scelto il nome della macchina verranno
  riempiti i campi “Costruttore” e “Tipo”.

- Inserire nel campo “Codice Macchina” un codice a piacere che deve
  essere univoco nella sala. Esempio: se dobbiamo installare 2 “Sega
  Rally 3” i codici delle 2 macchine potranno essere “SRally3Dx” e
  “SRally3Sx” per distinguere tra le 2 macchine quella di destra e
  quella di sinistra.

- Impostare la percentuale dell’incasso che andrà divisa con l’eventuale
  gestore del locale.

- Impostare i costi partita a seconda del tipo di carta utilizzata tra
  Carta Compleanno, Silver, Gold o Platinum.

- Impostare il numero di impulsi che il lettore ECL deve dare alla
  macchina per una partita.

- [img:image63.png]Impostare il costo partita
  senza la card.

- Impostare il valore dell’impulso di Coin in uscita dalla gettoniera
  verso la macchina.

- Impostare il valore dell’impulso in uscita dal lettore di banconote
  verso la macchina.

- Se la macchina è impostata con funzionamento a gettoni, selezionare
  l’apposito riquadro. In questo caso il riquadro precedente cambia con
  quello qui a lato per poter inserire i valori in numero di gettoni.

- Se la macchina eroga tickets, selezionare l’apposito riquadro.

- I valori preimpostati in “Simulazione Credito” e “Simulazione Ticket”
  non vanno modificati se non per macchine particolari in accordo con
  quanto suggerito da Elmac per quel particolare modello.

- Impostare e configurare i contascatti di ingresso (Monete o Gettoni).

  - [img:image64.png]Scegliere il numero di
    contascatti di ingresso presenti nella macchina: verrà aggiunta alla
    tabella una riga per ogni contascatti esistente.

  - Per poter inserire i valori occorre premere il pulsante si
    attiveranno i controlli sopra la tabella.

  - Nel menu a discesa “Mosso da IN” scegliere quale degli ingressi
    collegati alla scheda ECL fanno muovere il contascatti. Le
    possibilità sono: A2=ingresso collegato direttamente al contascatti
    di IN - A15=Uscita Bill - B14=Uscita Coin ed ECoin.

  - Impostare il valore dello scatto ovvero il valore che deve essere
    inserito nell’ingresso al quale il contascatti è collegato per farlo
    avanzare di uno scatto.

  - [img:image65.png]Impostare il numero
    visualizzato dal contascatti stesso.

  - Per poter salvare i valori impostati premere il pulsante

- Impostare e configurare i contascatti di uscita (Premi o Tickets)

  - [img:image64.png]Scegliere il numero di
    contascatti di uscita presenti nella macchina: verrà aggiunta alla
    tabella una riga per ogni contascatti esistente.

  - Per poter inserire i valori occorre premere il pulsante si
    attiveranno i controlli sopra la tabella.

  - Nel menu a discesa “Mosso da IN” scegliere quale degli ingressi
    collegati alla scheda ECL fanno muovere il contascatti. Le
    possibilità sono: A1=ingresso collegato direttamente al contascatti
    di OUT - A3-A4-A5=ingresso collegato direttamente all'uscita Premio
    1-2-3 - A10=ingresso collegato al Ticket Switch.

  - Impostare il valore dello scatto ovvero il valore dell’oggetto che
    viene erogato dalla macchina o il numero di tickets erogati che
    fanno avanzare il contatore di uno scatto.

  - [img:image65.png]Impostare il numero
    visualizzato dal contascatti stesso.

  - Per poter salvare i valori impostati premere il pulsante

- Scegliere cosa viene erogato dalla macchina sull’uscita collegata
  all’ingresso A3 del modulo ECL tra Premi, Tickets, Gettoni (in caso
  che la macchina sia una Cambia Gettoni) o Monete (se si tratta di una
  Cambia Monete) ed il valore del singolo pezzo erogato, nel caso di
  Tickets o Gettoni, andrà posto a 1.

- Ripetere l’operazione di cui sopra per eventuali altre uscite
  collegate ad A4 e A5.

- Impostare la data di installazione in sala della macchina, il valore
  impostato automaticamente è la data odierna.

- Se la macchina ospita una giacenza (monete o gettoni che restano
  all’interno di essa per assicurarne il funzionamento), impostare il
  loro numero ed il loro valore negli appositi campi, “Valore Pezzi
  Hopper” e “Numero Pezzi Hopper”.

- Finito l’inserimento di tutti i valori fin qui detti, premere il
  pulsante [img:image66.png] per salvare la macchina
  configurata e tornare alla pagina principale.

- Relè 1: <span class="mark">nuova funzione</span>

##  Configura servizio a tempo variabile o fisso

*Configurazione di un servizio a tempo variabile*

[img:image67.jpeg]Questa finestra permette
l’inserimento e la configurazione dei servizi a tempo variabile o fisso.

- Si inizia abilitando la voce “Timer” in alto a destra.

- Scegliere il nome macchina.

- Inserire nel campo “Codice Macchina” un codice a piacere che deve
  essere univoco.

- Abilitare “Tempo variabile”.

- Impostare il costo del servizio per ogni tipologia di card

- Impostare l’unità di tempo.

- Impostare il tempo gratuito. Se il tempo gratuito è uguale a zero il
  cliente dovrà pagare all’ingresso l’importo relativo al tempo minimo
  impostato, invece nel caso contrario, il tempo gratuito è maggiore di
  zero al termine del servizio dovrà pagare in uscita il tempo gratuito
  impostato più il valore relativo all’unità di tempo.

- Impostare la data di installazione.

- Finito l’inserimento di tutti i parametri, premere il pulsante
  [img:image66.png] per salvare.

*Configurazione di un servizio a tempo
fisso*[img:image68.jpeg]

- Si inizia abilitando la voce “Timer” in alto a destra.

- Scegliere il nome macchina.

- Inserire nel campo “Codice Macchina” un codice a piacere che deve
  essere univoco.

<!-- -->

- Abilitare “Tempo fisso”

- Impostare il costo del servizio per ogni tipologia di card.

- Impostare il tempo del servizio.

- Impostare la data di installazione.

- Finito l’inserimento di tutti i parametri, premere il pulsante
  [img:image66.png] per salvare.

## [img:image69.png]Esistente

<span class="mark">Immagine nuova</span>

Questa viene utilizzata per modificare i valori impostati per una
macchina già precedentemente installata, per cancellarne i dati di
incasso o per eliminare una macchina dalla rete.

- Selezionare la macchina in tabella cliccando sulla riga corrispondente
  alla macchina che si vuole eliminare o modificare: la riga verrà
  evidenziata.

- Per eliminarla premere [img:image70.png]

- Per modificarla premere [img:image71.png] : si aprirà la finestra
  con i dettagli della macchina scelta. Modificare i valori desiderati
  secondo quanto esposto nel paragrafo “Configura Macchina Nuova”. Per
  salvare la macchina con i dati modificati
  premere[img:image72.png]

- Se si desidera eliminare tutti i dati di incasso relativi alla
  macchina visualizzata, per esempio perché si sono effettuate delle
  prove in fase di installazione e non si vuole che queste vadano a
  falsare i dati di incasso, premere il pulsante
  [img:image73.png]

- Premere [img:image74.png] per uscire senza salvare le
  eventuali modifiche apportate.

<span class="mark">La nuova immagine ha tutti i simboli diversi e magari
procedure che non conosco diverse rispetto a quella vecchia, dunque, la
procedura soprastante andrebbe rivista e aggiornata con le nuove
funzioni</span>

## [img:image75.png]Modifica costo partita

<span class="mark">Nuova sezione</span>

## [img:image76.png]Raggruppamenti macchine

<span class="mark">Nuova sezione</span>

## [img:image77.png]Promozioni

<span class="mark">Nuova sezione</span>

## [img:image78.png]Eventi

<span class="mark">Nuova sezione</span>

## [img:image79.png]Gestione HappyHours

<span class="mark">Nuova immagine</span>

Happy Hour è il sistema che permette di creare delle fasce orarie nei
giorni desiderati nelle quali impostare degli sconti sul costo della
partita per i clienti possessori di una card. All’interno della fascia
oraria è possibile abilitare quali macchine avranno lo sconto e il costo
partita per macchina e per tipologia di carta.

Se non sono impostati filtri per tipologia (il relativo menu a discesa è
vuoto) e non è selezionata nessuna fascia Happy Hour nella tabella in
alto, la tabella di destra mostrerà l’elenco di tutte le macchine in
rete.

Per creare una fascia Happy Hour agire come segue:

- Impostare nei relativi 3 campi i valori di sconto pre-impostati per
  ognuno dei 3 tipi di carta. Questi valori verranno assegnati
  automaticamente a tutte le macchine che si aggiungeranno agli Happy
  Hours ma, come detto, potranno essere cambiati macchina per macchina.

- Premere il tasto [img:image80.png] : verrà aggiunta una riga
  nella tabella in alto.

- Scegliere per questa riga dai relativi menu a discesa il giorno della
  settimana, l’ora di inizio e di fine della fascia.

- A questo punto si devono scegliere le macchine che parteciperanno a
  questo Happy Hour. Per farlo occorre selezionare la macchina
  desiderata nella tabella di destra e premere
  [img:image81.png]: la macchina scelta verrà
  spostata dalla tabella di destra in quella di sinistra. Procedere
  nello stesso modo per tutte le altre macchine che si desidera
  aggiungere. Si possono filtrare le macchine per tipologia utilizzando
  l’apposito menu a discesa.

- Per togliere una macchina da quelle scelte è sufficiente selezionarla
  nella tabella di sinistra e premere [img:image82.png]: la macchina verrà tolta e
  rimessa nella tabella di destra.

- [img:image83.png]Per modificare il costo
  partita di una macchina per una tipologia di carte selezionare nella
  tabella di sinistra il prezzo che si vuole cambiare: apparirà un menu
  a discesa col quale scegliere il nuovo valore:

Per eliminare un Happy Hour selezionarlo nella tabella in alto e premere
[img:image84.png]

<span class="mark">Aggiunta la nuova l’opzione B-day</span>

## Visualizza blacklist

[img:image85.png]<span class="mark">Nuova
sezione</span>

## [img:image86.png]Recupero Card

> <span class="mark">Nuova sezione</span>

## Cancellazione automatica card rfid

> <span class="mark">Nuova sezione</span> non posso mettere lo screen
> perché la voce è grigia e non cliccabile

## Rapporti

## [img:image87.png]Conteggio macchine

Questa finestra permette di eseguire le operazioni di incasso della sala
in modo semplice, veloce e preciso. Premere “Calcola Incasso” per
popolare la finestra.

[img:image88.png]Il calcolo dell’incasso
attuale parte dalla data di quello eseguito precedentemente. Per ogni
macchina installata vengono visualizzati in tabella tutti i dati
necessari, ci sono anche i riferimenti ai contatori meccanici per un
controllo incrociato tra questi e quelli calcolati automaticamente da
ECL. Nel riquadro “CAMBIA GETTONI” ci sono i dati relativi alle macchine
cambia gettoni indispensabili qualora in sala giochi siano presenti
macchine “Pusher” che devono obbligatoriamente funzionare a gettoni. Il
pulsante “Imposta Valore Gettone” serve a fissare il valore del gettone
a quanto calcolato in base ai dati ricevuti da ECL e a rifare il calcolo
dell’incasso secondo il nuovo valore impostato. Cliccando sulla tabella
in corrispondenza di una macchina, si apre la finestra con tutti i
dettagli della macchina scelta. Questa finestra rende possibile
modificare i valori di incasso nel caso ci siano delle incongruenze, le
eventuali differenze vengono segnalate sia nella tabella generale che
nel sommario dell’incasso. Nel caso la macchina scelta abbia un “fondo”
di gettoni o monete (tipo il piatto della Gold Zone) comparirà anche il
riquadro per visualizzare o modificare la giacenza. All’uscita da questa
finestra verrà chiesto se salvare o meno le modifiche effettuate. In
caso affermativo le modifiche saranno salvate e la riga, relativa a
questa macchina, nella tabella generale verrà disabilitata e future
modifiche non saranno più possibili.

## [img:image89.png]Controllo cassa

<span class="mark">Nuova sezione</span>

## [img:image90.png]Movimenti card

<span class="mark">Nuova immagine</span>

Apre la finestra che permettere di visualizzare i movimenti di crediti
dalle e nelle carte. Abbiamo la possibilità di filtrare i movimenti per
data, per operatore che ha effettuato i movimenti ecc.

Le liste possono essere esportate e stampate.

<span class="mark">Funzioni nuove aggiunte:</span>  
nella sezione riepilogo periodo è presente il bonus

Nella sezione filtro è presente il checkbox “solo dobloni”

Presente una nuova sezione “situazione attuale” con dentro rimborsi, NR.
Card e residuo nelle card.

Nuovo pulsante resi

Nuova sezione “saldo operatore”

## Macchine

[img:image91.png]In questa finestra è
possibile controllare l’andamento degli incassi delle macchine che fanno
parte della rete ECL.

[img:image92.jpeg]Impostando la data di inizio
e di fine rapporto e premendo il pulsante nella tabella grande verranno
visualizzati i dati delle singole macchine, in quella a destra i
riepiloghi per tipologia, in basso i totali del periodo. Abilitando
l’opzione “Raggruppa Postazioni di Gioco” le macchine che in fase di
inserimento hanno l’opzione “Multi-postazione” abilitata verranno
raggruppate in una sola macchina. Nel riquadro “Cambia Gettoni” vengono
visualizzati i dati relativi alle cambia gettoni installate: valore
delle monete o banconote inserite, gettoni erogati e il valore medio del
gettone. Premendo il pulsante “IMPOSTA VALORE GETTONE” il valore medio
calcolato del gettone sostituirà quello impostato in basso e tutti i
conteggi verranno aggiornati secondo il nuovo valore. Il riquadro verde
da la possibilità di visualizzare un grafico dell’andamento nel tempo
dei dati di incasso, pagamento o incasso netto delle macchine
selezionate in tabella o di tutte le tipologie a confronto o, ancora, di
una singola tipologia di macchine. Il grafico può essere stampato.

I dati visualizzati nelle tabelle possono essere esportati e stampati
premendo gli appositi pulsanti.

## [img:image93.png]Crediti di servizio

<span class="mark">Nuova sezione</span>

## [img:image94.png]Rapporti vari

<span class="mark">Nuova sezione</span>

## Rapporti per amministratori

<span class="mark">Nuova sezione</span> chiede password che non so
dunque non posso aggiungere altro

## [img:image95.png]Nuovo modello

<span class="mark">Nuova sezione</span>

## Modifica Contatori

<span class="mark">deprecato</span>

[img:image96.png]Questa finestra viene
utilizzata per la modifica delle letture finali dei contascatti
meccanici delle macchine nel caso uno o più di essi non combacino con
quelli calcolati da ECL. Come specificato nella finestra stessa,
eventuali modifiche ai contatori vanno fatte DOPO aver effettuato
l’incasso con i valori letti dalle macchine prima che queste ricomincino
a lavorare. Si ha anche la possibilità di aggiornare le quantità di
pezzi giacenti nelle macchine provviste di una giacenza tipo le monete o
i gettoni che rimangono sul piatto della Gold Zone. Le colonne
modificabili sono quelle evidenziate in verde: portare il cursore nella
cella che si intende modificare, inserire il nuovo valore e battere
INVIO sulla tastiera: verrà visualizzata la differenza tra il valore
inserito e quello preesistente nella cella successiva, in rosso per
differenze negative, in verde per quelle positive, il cursore si
sposterà automaticamente nella cella modificabile successiva. Al termine
premere SALVA: i valori inseriti saranno i valori dai quali partirà il
calcolo degli scatti al prossimo incasso.

## Prenotazione dei Premi

[img:image97.emf]La prenotazione dei premi
consiste nel riservare ad un cliente, un articolo non fisicamente
presente a magazzino. Per fare ciò è necessario che nel SETUP-\>OPZIONI
GENERALI-\> FUNZIONALITA’, sia abilitata la voce “PRENOTAZIONE PREMI” ed
eseguire la seguente procedura:

- Nella Finestra Vincite, premere il pulsante PRENOTA PREMI, che
  diventerà di color arancione ed inizierà a lampeggiare

- Leggere gli scontrini del Cliente o la fidelity Card

- Scegliere i premi desiderati

- I premi scelti verranno visualizzati nel riquadro “Premi Scelti”.

- Se un premio è stato scelto per errore, è possibile toglierlo dalla
  lista selezionandolo dall’elenco e premendo “CANCELLA PREMIO”

- Terminata la scelta dei premi, premere “SCARICA PREMI” per concludere
  l’operazione.

- Verrà richiesto di inserire i dati del cliente: nome, cognome e numero
  telefonico.

- Verrà stampata una ricevuta con i dati della prenotazione effettuata

- Nel caso ci siano tickets di resto, verrà automaticamente stampato uno
  scontrino di resto per il Cliente.

Quando l’articolo prenotato sarà disponibile a magazzino (carico
automatico o carico da bolla) è necessario agire come segue:

- Entrare nel Menu Prenotazioni-\>Lista

- Scegliere la prenotazione da confermare e premere l’apposito pulsante;
  verrà richiesta la conferma dell’operazione.

- Una volta conclusa l’operazione la prenotazione diventerà un ORDINE

- A questo punto il premio è disponibile per il ritiro

- I pulsanti “Prenotazioni” ed “Ordini” visualizzeranno costantemente le
  prenotazioni e gli ordini pendenti.

Consegna ad un Cliente di un premio prenotato

L’operazione può essere effettuata sia con la ricevuta rilasciata dopo
aver conclusa la prenotazione che direttamente dalla lista degli ordini
o leggendo la card del cliente. Negli entrambi i casi l’operazione verrà
conclusa premendo l’apposito pulsante “Consegna”.

Una volta consegnato il premio, anche la quantità a magazzino verrà
scalata.

## Ordini – Consegna

[img:image98.emf]

Apre la finestra con la lista degli Ordini pronti per la consegna a
Clienti senza card:

selezionando una riga della tabella, in basso, comparirà il nome del
Cliente che ha effettuato l’ordine.

Per consegnargli il premio premere “Consegna”.

Premendo “X” verrà chiesta conferma dell’annullamento dell’ordine e, in
caso di risposta affermativa, sarà stampato uno scontrino col valore in
punti del premio prenotato e il premio stesso verrà reintegrato nel
magazzino come quantità disponibile.

Se si accede a questo menu dopo aver letto una carta Cliente, comparirà
la stessa finestra che mostrerà i premi ordinati dal Cliente in
questione e disponibili per la consegna. Agire come sopra per
distribuire il premio.

## Ordini – Lista

Questo menu apre la seguente finestra:

[img:image99.emf]

visualizza la lista degli ordini ed è possibile, con le apposite caselle
di controllo, scegliere quali vedere tra tutti, consegnati o annullati.

[img:image100.emf]Esporta la lista in Excel o
csv.

[img:image101.emf]Cancella un Ordine e, se il
Cliente relativo non ha la card, stampa uno scontrino con il valore in
punti del premio altrimenti carica gli stessi punti sulla card del
Cliente.

[img:image102.emf]Stampa la lista nella
stampante di sistema.

[img:image103.emf]

[img:image104.png]Chiude e torna alla finestra
principale.

##  Ordini – Prepara

<span class="mark">Nuova sezione</span>

## Prenotazioni – Lista

Questo menu apre la seguente finestra:

[img:image105.emf]

visualizza la lista delle prenotazioni ed è possibile, con le apposite
caselle di controllo, scegliere quali vedere tra tutte, consegnate o
annullate.

[img:image106.emf]Conferma la prenotazione
selezionata in tabella rendendo disponibile il premio al Cliente. Se
l’App Galileo è abilitata ed il Cliente l’ha installata nel suo
smartphone gli viene inviata un’email ed un messaggio push per avvisarlo
di passare in cassa per il ritiro.

[img:image100.emf]Esporta la lista in Excel o
csv.

[img:image101.emf]Cancella una Prenotazione e,
se il Cliente relativo non ha la card, stampa uno scontrino col valore
in punti del premio altrimenti carica gli stessi punti sulla card del
Cliente.

[img:image102.emf]Stampa la lista nella
stampante di sistema

[img:image103.emf]

Chiude e torna alla finestra principale

## Resi – Resi per non VIP

Permette ai Clienti senza Card di rendere un premio già consegnato.

> [img:image107.jpeg] style="width:5.47361in;height:3.32292in" />All’avvio, la tabella
> mostra gli ultimi 10 premi vinti da Clienti senza Card in ordine di
> tempo.

- Selezionare in tabella il premio che il Cliente intende restituire. La
  selezione può essere effettuata anche passando il lettore di codici a
  barre sul codice relativo all’articolo in questione (vedere “[Gestione
  Magazzino Premi](#_Gestione_Magazzino_“Premi”)” per come stampare le
  etichette con i codici a barre degli articoli nel magazzino premi). Se
  il premio desiderato non è in tabella lo si può anche cercare
  utilizzando l’apposito filtro “Trova Premio”, inoltre la tabella può
  essere messa in ordine crescente o decrescente per ognuno dei campi
  cliccando sul nome del campo stesso.

> Scelto il premio, la sua descrizione e il suo valore in numero di
> tickets verranno visualizzati nei relativi campi in basso.

- Premendo ANNULLA, la scelta effettuata verrà cancellata.

- Premendo OK si avrà la stampa dello scontrino con il valore in tickets
  del premio da consegnare al Cliente ed il premio reso verrà aggiunto
  al magazzino.

## [img:image108.emf]Resi – Resi per VIP

Permette ai Clienti muniti di Card, di restituire un premio già
consegnato.

- Passare la Card Cliente nel lettore, i relativi dati verranno
  visualizzati nel riquadro “CLIENTE” e la tabella mostrerà i premi
  vinti dal Cliente.

- Scegliere il premio che il Cliente intende rendere facendo doppio
  click all’estrema sinistra della tabella in corrispondenza del premio
  stesso. La selezione può essere effettuata anche passando il lettore
  di codici a barre sul codice relativo all’articolo in questione
  (vedere “[Gestione Magazzino Premi](#_Gestione_Magazzino_“Premi”)” per
  come stampare le etichette con i codici a barre degli articoli nel
  magazzino premi). E’ possibile limitare la lista ai soli premi che
  hanno la descrizione che inizia con una determinata lettera, premendo
  sulla tastiera la lettera desiderata. Premendo, per esempio la lettera
  “a” o “A”, verranno visualizzati solo i premi con la descrizione che
  inizia con la lettera “A”. Inoltre la tabella può essere messa in
  ordine crescente o decrescente per ognuno dei campi cliccando sul nome
  del campo stesso.

- La sua descrizione e il suo valore in numero di tickets verranno
  visualizzati nei relativi campi.

- Premendo ANNULLA, verrà annullata l’operazione e l’o credito dei punti
  sulla Card del Cliente.

- Premendo OK, l’operazione verrà conclusa con la stampa dello scontrino
  “PRO-MEMORIA” per il Cliente e l’aggiunta nel magazzino del premio
  reso.

## Rapporti

[img:image109.png]

<span class="mark">Nuova immagine</span>

Permette all’Operatore di visualizzare e stampare un rapporto con i
premi da lui consegnati ai Clienti, quelli resi e quelli prenotati.

Aprendo la finestra, automaticamente in “Dal” viene proposta la data del
giorno precedente e in “al” la data attuale. La giornata lavorativa
comincia alle 6:00 e finisce alla stessa ora del giorno dopo per
impostazione predefinita, eventualmente è possibile modificare le ore di
inizio e di fine rapporto.

Lasciando quindi invariati i due campi, si otterrà il rapporto relativo
alle ultime 24 ore, è però possibile, variando le date in “Dal” e “al”
ricavare i dati relativi a qualsiasi periodo.

- Inserire la data da cui si vuole iniziare il rapporto in “Dal:”.

- Inserire la data di fine rapporto in “al:”.

- Variare, se necessario, gli orari di inizio e fine rapporto.

- Premere il pulsante **Aggiorna.**

- Premere [img:image110.emf] per stampare il rapporto
  sulla stampante termica o [img:image111.emf] per stampare su quella di
  sistema.

L’Amministratore o il Manager possono scegliere, dall’apposito menu a
discesa, per quale operatore ottenere il rapporto, lasciandolo vuoto, si
otterrà il rapporto generale che comprende le operazioni effettuate da
tutti gli operatori. L’Operatore può visualizzare solo le sue.

Vita media scontrini: <span class="mark">nuova sezione</span>

Nel riquadro “Tickets del periodo” vengono visualizzati:

- **CONTATI**: tickets provenienti da scontrini emessi dalle
  MangiaTickets collegate e dai Reparti esistenti.

- **MANUALI**: tickets provenienti da scontrini emessi manualmente.

- **BONUS**: tickets omaggio ai clienti con Card (vedi Tickets BONUS)

- **RESI**: tickets caricati ai clienti a fronte di premi resi.

- **CONVALIDATI**: tickets provenienti da scontrini convalidati
  automaticamente (se la relativa opzione è abilitata in [Opzioni
  Generali](#opzioni-generali)).

- **PAGATI**: tickets pagati ai clienti come premi consegnati.

- **PRENOTATI**: tickets prelevati ai clienti a fronte di premi
  prenotati e non ancora consegnat

- **TOTALE IN**: è la somma dei tickets “entrati” contati + manuali +
  bonus

- **TOTALE OUT**: è la somma dei tickets “usciti” pagati + prenotati

- **NELLE CARDS**: sono i tickets non riscossi di clienti provvisti di
  card.

- **SCONTRINI**: sono i tickets in forma cartacea ancora in possesso dei
  clienti.

- **ESTERNI**: <span class="mark">nuova funzione</span>

I 3 pulsanti “**Punti dai Reparti**”, “**Punti Raccolta Carte**” e
“**Punti Extra Locale**” aprono i relativi 3 riquadri che visualizzano
le tabelle con i punti provenienti dalla fonte specificata.

> [img:image112.png] style="width:2.6875in;height:1.88542in" />

- Visualizza i punti provenienti dai vari reparti esistenti e il
  relativo totale. Tutti questi dati saranno evidenziati anche nelle
  stampe e potranno essere esportati.

> [img:image113.png] style="width:3.19792in;height:1.60417in" />

- Visualizza i punti provenienti dalle Raccolte Cards abilitate divise
  per nome della raccolta evidenziando, per ognuna, i punti totali,
  quelli provenienti dalle serie di carte e quelli relativi alle singole
  carte. Tutti questi dati saranno evidenziati anche nelle stampe e
  potranno essere esportati.

- [img:image114.png] Se il locale è inserito in
  un sistema Multi Locale, gli eventuali punti provenienti da altri
  locali del gruppo ed utilizzati da un cliente per acquistare un premio
  in questo locale vengono visualizzati, nella colonna “Dare”, nella
  riga corrispondente al locale di provenienza di quei punti. Nel caso
  invece che un cliente sia andato a ritirare un premio in un altro
  locale del gruppo utilizzando i punti che aveva guadagnato in questo
  locale, questi punti saranno visualizzati nella colonna “Avere” nella
  riga corrispondente al locale che ha consegnato il premio. Tutti
  questi dati saranno evidenziati anche nelle stampe e potranno essere
  esportati.

Nel riquadro **PROFITTO** vengono indicati il profitto **TOTALE**
calcolato come (valore in tickets del premio \* 0.01) – Costo del premio
(colonna **COSTO** della tabella della finestra [Magazzino
Premi](#_Gestione_Magazzino_“Premi”)). Il profitto medio indica il
profitto totale diviso per il numero dei premi consegnati.

L’utente Amministratore, ha la possibilità di visualizzare e stampare il
rapporto generale o per singolo operatore scegliendone il nome
nell’apposita lista a discesa.

Si possono ottenere tre tipi di stampa sulla stampante di sistema:

1.  STAMPA ESTESA: per ogni operatore vengono stampate tre liste dei
    premi: consegnati, resi e prenotati con i totali parziali e
    generali.

2.  STAMPA BREVE: per ogni operatore vengono stampati i totali relativi
    ai premi consegnati, prenotati e resi e, alla fine, i totali
    generali.

3.  STAMPA UNIONE: viene stampata una tabella riepilogativa contenente
    la lista degli operatori con i relativi totali dei tickets contati e
    dei premi consegnati, resi e prenotati.

E’ possibile inoltre, utilizzando gli appositi pulsanti di selezione,
ottenere i dati relativi ai soli clienti che non hanno la card, a solo
quelli con card o a entrambi.

## Menu Filtro

Nel riquadro “Filtra la tabella…” decidiamo quali tabelle filtrare:

- Premi Vinti

- Premi Resi

- Premi Prenotati

Nel riquadro “… per…” selezioniamo il campo in base a quale filtrare:

- Codice

- BarCode

- [img:image115.jpeg]ID

- Descrizione

- Fornitore

Nell’ esempio in figura abbiamo la tabella Premi Vinti per Descrizione
uguale a “accendino”. Premendo il pulsante APPLICA FILTRO si ritornerà
alla finestra del rapporto nella quale, nella tabella “Premi Consegnati”
solo gli articoli con descrizione che inizia con “accendino”.

## Menu Mangia Tickets

<span class="mark">Nuova:</span> non mi fa entrare in questa zona,
dunque, non posso essere certo che non sia cambiata

In questa tabella vengono visualizzati i tickets contati divisi per le
varie Mangia Tickets che li hanno contati.

[img:image116.jpeg]

##  Magazzino

## Premi

11. <span id="_Gestione_Magazzino_“Premi”" class="anchor"></span>

12. 

13. 

14. 

15. 

16. 

17. 

Struttura del menu:

- File

  - Stampe NEOS

    - Singolo barcode

    - Tutti i barcode

    - lista

    - Articoli in riserva

  - Stampe A4

    - Lista conteggio

    - Lista

    - Ordine d’acquisto

  - Modifica numero tickets

  - Esporta

- Movimenti

  - Carico

  - Scarico

  - Crea ordine d’acquisto

  - Carico da ordine d’acquisto

  - Trasferimenti in ingresso

  - Trasferimenti in uscita

  - Trasferimento tra Locali

    - Carico

      - Manuale

      - Automatico

    - Scarico

- Visualizza movimenti

  - Movimenti magazzini

  - Ordini d’acquisto

- Rapporti

  - Andamento premi in 6 settimane

  - Visualizza inventario

  - Rapporto settimanale (<span class="mark">deprecato?</span>)

  - Rapporto variazione (<span class="mark">deprecato?</span>)

  - Rapporto vendite

  - Rapporto breve utente

<!-- -->

- Fornitori

- Incassi (<span class="mark">nuovo: non più presente</span>)

  - Registra

  - Modifica

Attraverso questa finestra, si gestisce il magazzino dei premi.

La tabella mostra la situazione attuale con articoli e relative
giacenze; cliccando sull’intestazione di una colonna, si ordinano le
righe in base a quella colonna, ri-cliccando ancora l’ordinamento viene
invertito da crescente a decrescente e viceversa.

- Cerca: permette di trovare velocemente un articolo digitandone nelle
  apposite caselle il codice, il codice originale, il fornitore o la
  descrizione. Per tornare a vedere l’elenco completo degli articoli,
  premere “Aggiorna”.

  - Visualizza:

    1.  **TUTTO**: la lista conterrà tutti i premi.

    2.  **TICKETS**: la lista conterrà solo i premi di tipo “T” (Tickets
        premio per le Tickets Redemptions).

    3.  **GRU**: la lista conterrà solo i premi di tipo “C” (Crane= Gru
        premio per le Gru).

<!-- -->

- [img:image117.emf]Codice: visualizza solo i
  premi che col campo Codice che inizia con quanto inserito in questo
  spazio.

- Codice Originale: visualizza solo i premi che col campo Codice
  Originale che inizia con quanto inserito in questo spazio.

- Descrizione: visualizza solo i premi con descrizione che contiene (se
  selezionato Cont) o che Inizia (se selezionato Iniz) quanto inserito
  in questo campo.

- Fornitore: visualizza solo i premi del fornitore scelto.

- Visual. Quantità Inatt.: mostra solo i premi inattivi (Att.=N) con
  quantità diversa da zero.

- Nascondi Premi Inatt.: mostra solo i premi attivi (Att.=Y).

<!-- -->

- Riepilogo:

  - **TOTALE GENERALE**: mostra il valore totale dei premi giacenti in
    magazzino.

  - **ARTICOLI PRESENTI**: mostra il numero dei diversi articoli
    presenti in magazzino.

  - Questi numeri si riferiscono ai premi presenti nella lista dopo
    l’applicazione dei filtri di cui al paragrafo precedente.

- Aggiorna Barcode: serve per modificare il codice a barre di un
  articolo.

  - Selezionare l’articolo interessato.

  - Premere Aggiorna Barcode (il pulsante lampeggia e cambia etichetta).

  - Leggere il codice a barre col lo scanner (il campo Codice Originale
    viene aggiornato con il codice letto).

  - Premere Salva Barcode.

- Ricalcola: esegue il ricalcolo delle giacenze in base ai movimenti di
  carico/scarico di ogni articolo.

- Nuovo: serve per inserire un nuovo articolo in magazzino, premendolo
  comparirà un riquadro verde con i campi da riempire. L’inserimento di
  un nuovo articolo.

[img:image118.png]

- Per inserire un nuovo articolo:

<!-- -->

- Premere NUOVO, compare il riquadro verde visualizzato sopra, oppure:

- Leggere il codice a barre dell’oggetto che si deve inserire, anche in
  questo caso comparirà il riquadro verde con il campo “Codice
  Originale” che conterrà il codice letto.

- Riempire i campi “Descrizione”, “Costo”, “Num.Tickets” (se non è
  abilitata l’opzione “N.Tickets Automatico” in [Opzioni
  Generali](#opzioni-generali)), “Fornitore”, “Quantità” e “Tipo”. Gli
  altri campi sono opzionali, se “Codice” non contiene nulla, vi viene
  copiato il codice originale, “Riserva” viene messa a zero se vuota.

- Premere “SALVA”

- Aggiorna: ricarica la tabella con i dati in memoria (dopo qualche
  modifica effettuata).

- Inventario: apre la finestra Inventario per gestire gli inventari di
  magazzino.

- Elimina: cancella il premio selezionato, viene richiesta una conferma
  prima dell’effettiva eliminazione.

- Articoli Prenotati: visualizza gli articoli con “Q.Pren.” (Quantità
  Prenotata) maggiore di zero, articoli cioè che sono stati prenotati
  dai Clienti e che sono in attesa della consegna.

- Lista Articoli in Riserva: visualizza gli articoli che hanno la
  Quantità minore della Riserva.

- Stampa Barcode Articolo: serve per stampare il numero desiderato di
  etichette col codice a barre dell’articolo selezionato.

- Immagine Oggetto: cliccando sul riquadro immagine si ha la possibilità
  di assegnare all’oggetto selezionato una immagine. Cliccando col
  pulsante sinistro del mouse apparirà una finestra di dialogo che
  permetterà di scegliere l’immagine e di salvarla. Cliccando col
  pulsante destro del mouse si vedrà la foto dell’oggetto ingrandita.

- CHIUDI: chiude la finestra e torna a quella
  [principale](#finestra-principale-lato-operatore).

Descrizione dei menu:

- File:

  - [img:image119.jpeg]Stampe Neos: stampe sulla
    stampante Neos.

    - Singolo barcode: permette di stampare una o più etichette con
      descrizione, numero tickets e codice a barre dell’articolo
      selezionato (doppio click sulla freccia).

    - Tutti i barcode: permette di stampare un’etichetta con
      descrizione, numero tickets e codice a barre per ogni articolo
      presente nella lista.

    - Lista: lista degli articoli visualizzati con codice, descrizione e
      quantità.

    - Articoli in riserva: lista degli articoli con quantità inferiore
      alla riserva con codice, descrizione e quantità.

  - Stampe A4: stampe sulla stampante di sistema.

    - Lista Conteggio: stampa la lista degli articoli, nell’ordine con
      cui sono visualizzati, per il loro conteggio prima di effettuare
      l’inventario.

    - Lista: stampa della lista completa degli articoli in tabella.

    - Ordine d’Acquisto: stampa la lista degli articoli che hanno la
      quantità Ordinata maggiore di zero.

  <!-- -->

  - Modifica N. Tickets: apre la finestra: per la modifica automatica
    del numero tickets degli oggetti selezionati. Per farlo occorre:

    - Selezionare gli articoli da modificare direttamente in tabella
      cliccando sull’articolo mentre si tiene premuto il tasto CTRL
      sulla tastiera, oppure:

    - Visualizzare gli articoli interessati, per esempio immettendo un
      fornitore nell’apposito campo del riquadro “CERCA”

    - Scegliere “Modifica N.Tickets” dal menu “File”, comparirà la
      finestra visualizzata.

    - Impostare le opzioni per selezionare o meno l’intera tabella e per
      abilitare o meno l’arrotondamento.

    - Impostare il moltiplicatore.

    - Premere “ESEGUI”. Se un articolo ha un costo di 6.44€, il
      moltiplicatore è 100 e l’arrotondamento è abilitato, il numero
      tickets di quell’oggetto verrà messo a 650 (6.44 X 100=644,
      arrotondato alla decina superiore = 650).

  - Esporta: esporta la lista in formato Excel o csv.

<!-- -->

- Movimenti:

  - Carico: apre la finestra [CARICO MAGAZZINO](#movimenti---carico).

  - Scarico: apre la finestra [SCARICO PREMI.](#movimenti---scarico)

  - Crea Ordine di Acquisto: crea e stampa un Ordine di Acquisto
    contenete i premi con Quantità Ordinata maggiore di zero.

  - Carico da Ordine di Acquisto: apre la finestra [Consegna da Ordine
    di Acquisto](#movimenti-carico-da-ordine-di-acquisto).

  - Trasferimenti Ingresso: apre la finestra [Carico Magazzino da
    Bolla](#carico-magazzino-da-bolla).

  - Trasferimenti Uscita: apre la finestra [Scarico
    Premi](#movimenti---scarico).

  - Trasferimenti tra Locali:

> \- Carico: Manuale e Automatico
>
> \- Scarico

- Visualizza Movimenti:

  - Movimenti Magazzino: apre la finestra [Lista Movimenti
    Premi](#visualizza-movimenti-movimenti-magazzino).

  - Ordini di Acquisto: apre la finestra [Ordini di
    Acquisto](#visualizza-movimenti-ordini-di-acquisto).

- Rapporti

  - Andamento Premi in 6 settimane: apre la finestra [Andamento Premi in
    6 settimane](#rapporti-andamento-premi-in-6-settimane).

  - Visualizza Inventario: apre la finestra [Visualizza
    Inventario](#rapporti-visualizza-inventario).

  - Rapporto Settimanale: apre la finestra [Rapporto
    Settimanale](#_Rapporti_–_Rapporto).

  - Rapporto Variazioni: apre la finestra [Rapporto
    Variazione](#rapporti-rapporto-variazione).

  - Rapporto Vendite: apre la finestra [Rapporto](#rapporti-1).

  - Rapporto Breve Utente: apre la finestra [Rapporto Breve
    Utente](#rapporti-rapporto-breve-utente).

- Fornitori

  - Apre la finestra [Gestione Fornitori](#fornitori).

- Incassi

  - Registra: apre la finestra [Registrazione
    Incassi](#incassi-registra-incassi).

  - Modifica: apre la finestra [Modifica
    Incassi](#incassi-modifica-incassi).

Questo menu è visibile solo se è abilitato “Registra Incassi” nella
finestra [Opzioni Generali](#opzioni-generali).

## Movimenti - Carico

Finestra che permette di effettuare tutte le operazioni di carico del
magazzino divise in 3 tipologie:

- Carico Automatico

- Carico da Remoto

- Carico Bolla

1.  

2.  

3.  

4.  

5.  

6.  

7.  

8.  

9.  

10. 

11. 

12. 1.  

##  Carico Magazzino Automatico

[img:image120.png]

Permette di caricare automaticamente nel magazzino una lista di premi
creata dal programma “GesPremi” o dal nostro e-commerce
[www.elmacshop.com](http://www.elmacshop.com) :

1.  Scegliere “Carico Automatico”.

2.  Premere il pulsante “APRI FILE”

3.  Scegliere il file da caricare nella finestra di dialogo che apparirà
    e premere “APRI”

4.  La tabella visualizzerà la lista presente nell’archivio scelto e, in
    basso, verrà visualizzato il nome del file aperto, il valore totale
    ed il numero di articoli.

5.  Premere “IMPORTA” per caricare gli articoli nel magazzino.

6.  Per stampare la lista premere l’apposito pulsante, la stampa verrà
    inviata alla stampante di sistema.

7.  Il contenuto del file verrà aggiunto al magazzino, quantità e numero
    di articoli saranno aggiornati e si tornerà alla finestra [Gestione
    Magazzino Premi](#_Gestione_Magazzino_“Premi”)

## Carico Magazzino da Remoto

(<span class="mark">nuovo: nel menu non esiste più</span>)

[img:image121.png]Permette di caricare
automaticamente nel magazzino una lista di premi creata dal programma
“WinMtHQ” e inviato al locale da remoto. Quando un file remoto è stato
ricevuto ed è in attesa di essere caricato, un messaggio avvisa
l’operatore che, da questa finestra, deve fare le seguenti operazioni:

1.  Scegliere “Carico Remoto”

2.  Scegliere dal menu a discesa il file da caricare

3.  Premere il pulsante “APRI FILE”

4.  La tabella visualizzerà la lista presente nell’archivio scelto e, in
    basso, verrà visualizzato il valore totale ed il numero di articoli.

5.  Se, per qualche motivo, la quantità di uno o più articoli in tabella
    non corrisponde con quella realmente consegnata, l’operatore può
    modificarla direttamente nella colonna “Quantità”: il valore totale
    degli articoli da caricare verrà automaticamente aggiornato.

6.  Premere “IMPORTA” per caricare gli articoli nel magazzino.

7.  Per stampare la lista premere l’apposito pulsante, la stampa verrà
    inviata alla stampante di sistema.

8.  Il contenuto del file verrà aggiunto al magazzino, quantità e numero
    di articoli saranno aggiornati e si tornerà alla finestra [Gestione
    Magazzino Premi](#_Gestione_Magazzino_“Premi”)

## Carico Magazzino da Bolla

[img:image122.jpeg]

Permettere di aggiungere dei premi nuovi o già presenti a magazzino,
provenienti da una bolla di consegna:

1.  Inserire gli estremi della bolla, numero e data, scegliere la
    causale tra CARICO e MOVIMENTO dove CARICO significa aggiunta di
    materiale proveniente dai fornitori mentre MOVIMENTO sta ad indicare
    che gli oggetti inseriti provengono da altre fonti, per esempio dei
    palloni tolti da una gru e messi in palio come premi
    dell’operazione.

2.  Se la bolla proviene da un singolo fornitore sceglierlo dalla lista
    a discesa, comparirà l’elenco dei premi del fornitore e sarà
    possibile immetterli nella tabella con un doppio click sull’articolo
    desiderato. Una volta scelti tutti gli articoli, facendo click sulla
    tabella l’elenco sparirà e sarà possibile immettere le quantità da
    caricare per ogni articolo.

3.  Nel caso di articoli provenienti da fornitori diversi inserire i
    vari articoli scegliendone il codice dalla lista a discesa o
    leggendone il codice a barre, immettere la quantità da caricare e
    premere “Aggiungi”. Ripetere l’operazione per tutti gli oggetti da
    caricare.

4.  E’ possibile scrivere delle note per ogni articolo inserito:
    selezionarlo nella tabella e scrivere la nota nell’apposito campo.

5.  Per stampare la bolla di carico premere l’apposito tasto, la stampa
    verrà inviata alla stampante di sistema.

6.  Premere “Chiudi Bolla” per terminare l’operazione ed aggiornare il
    magazzino

[img:image123.jpeg]

## Movimenti - Scarico

Permette di scaricare gli articoli dal magazzino, stampare la lista
dello scarico effettuato salvandolo in un archivio direttamente
importabile nel programma di gestione del magazzino centrale “GesPremi”
o nei altri centri dello stesso titolare.

- Selezionare la motivazione dello scarico dalla lista a discesa tra:

<!-- -->

- SPOSTA

- GUASTO

- GRU

- CONSUMABILI

- EVENTI

- RUSPE

> La merce scaricata con ognuna di queste motivazioni viene conteggiata
> in maniera diversa nelle finestre [Rapporto
> Settimanale](#_Rapporti_–_Rapporto) e [Rapporto
> Variazioni](#rapporti-rapporto-variazione).

- Selezionare il Codice o la Descrizione dell’articolo da scaricare, nel
  campo GIACENZA, verrà visualizzata la quantità esistente in magazzino.

  1.  Nel caso si debba fare un reso a un particolare fornitore è
      possibile sceglierlo dalla lista a discesa. Una volta scelto
      comparirà l’elenco di tutti gli articoli di quel fornitore e sarà
      possibile, con un doppio click sull’oggetto, inserirlo nella
      tabella. Finita la selezione degli articoli del fornitore, facendo
      click sulla tabella la lista scomparirà e sarà possibile immettere
      le quantità da scaricare per ogni articolo.

  2.  In alternativa l’articolo può essere scelto anche leggendone il
      codice a barre.

<!-- -->

- Immettere la quantità da scaricare nel campo QUANTITA’.

- Premere il tasto “Aggiungi” o il tasto “+” della tastiera, l’articolo
  scelto verrà aggiunto nella tabella con la relativa quantità
  scaricata, il valore dello scarico in Euro, verrà sommato nella
  casella “Totale Euro”.

- Ripetere i tre punti precedenti per gli eventuali altri articoli da
  scaricare.

- Nel caso si debba togliere dalla lista un articolo inserito per
  errore, occorre selezionarlo e premere il tasto “Elimina”.

- Immettere un NUMERO BOLLA nell’apposito campo.

- Immettere un NUMERO ORDINE nell’apposito campo.

- NOME FILE contiene il nome del file archivio che verrà creato e, se
  non modificato, viene preimpostato con: “Scarico”, “nome” dove “nome”
  è il nome del locale specificato nella finestra “[OPZIONI
  GENERALI](#opzioni-generali)” nel campo “Nome del Locale” e data
  corrente. Il file generato dalle operazioni di scarico vengono salvati
  nella cartella “Unloads“ che si trova nella cartella di lavoro del
  programma: C:\WinMtSql.

- Selezionando la casella “Cancella Premi con Quantità azzerata”, i
  premi che, dopo lo scarico, si troveranno con quantità uguale a zero,
  verranno cancellati dall’archivio. In questo modo è possibile ad
  esempio, eliminare tutti quei premi che vengono offerti ai clienti in
  determinati periodi dell’anno come i gadget natalizi o quelli per S.
  Valentino o quelli specifici per l’estate. Il file creato con
  l’operazione di scarico potrà poi essere facilmente ricaricato con
  un’operazione di [CARICO AUTOMATICO](#_Carico_Magazzino_Automatico)
  quando i premi in questione ritorneranno di stagione.

- Se si desidera stampare la bolla di scarico premere l’apposito tasto,
  la stampa verrà mandata alla stampante di sistema.

- Premere il tasto “SCARICA” e rispondere affermativamente alla
  richiesta di conferma, per effettuare l’operazione.

Il tasto SVUOTA TUTTO, permette di scaricare l’intero magazzino alla
fine dell’operazione a premi.

**N.B**

**“GesPremi”** è un programma che si può acquistare a parte da Elmac II
srl ed è utilizzato per la gestione del magazzino centrale di un
operatore.

E’ particolarmente utile quando l’Operatore deve gestire più locali: per
ciascuno di questi prepara la bolla di “Scarico” da magazzino centrale
utilizzando questo software che creerà automaticamente una cartella
contenente i files necessari per caricare i premi nel locale
prestabilito.

## Movimenti – Crea Ordine di Acquisto

(<span class="mark">nuovo: il menu è grigio, dunque, non posso
controllare se presenti nuove funzioni</span>)

Il Sistema Ordini di Acquisto è un insieme di strumenti che facilitano
l’operazione di carico del Magazzino Premi.

Per creare un Ordine di Acquisto agire come segue:

- Nella finestra Gestione Magazzino Premi selezionare il Fornitore al
  quale si vuole effettuare l’ordine utilizzando l’apposita lista a
  discesa. La lista conterrà solo i premi provenienti dal Fornitore
  scelto.

- Nella colonna “Ordin” (quantità ordinata) inserire, articolo per
  articolo, le quantità desiderate.

- Dal menu “Movimenti” scegliere il sotto menu “Crea Ordini di
  Acquisto”.

- Verrà richiesta l’immissione di un Numero di Ordine. Dopo averlo
  inserito viene richiesto se si desidera stampare l’ordine.

- A questo punto l’ordine è stato creato:

[img:image124.jpeg]

- Una volta che il materiale viene consegnato bisogna caricarlo.

- Dal menu “Movimenti” scegliere sotto menu “[Carico da Ordine di
  Acquisto](#movimenti-carico-da-ordine-di-acquisto)”.

Nella stampa, gli indirizzi specificati in “indirizzo di spedizione” e
in “indirizzo di fatturazione” sono quelli inseriti negli appositi spazi
della finestra [Opzioni Generali](#opzioni-generali).

## Movimenti – Carico da Ordine di Acquisto

Questa finestra permette di caricare della merce che era stata ordinata
usando il Sistema Ordine di Acquisto di cui al paragrafo precedente.

Per effettuare una operazione di carico agire come segue:

- [img:image125.emf]Selezionare dalla lista a
  discesa l’ordine desiderato in base al suo numero.

- Nella tabella compariranno gli articoli ordinati.

- Nella colonna “Arr.” (quantità arrivata) inserire la quantità
  effettivamente arrivata. La colonna “Manc.” (quantità mancante) verrà
  aggiornata con la quantità mancante (quantità ordinata – quantità
  arrivata).

- Inserire il numero di consegna, premere il pulsante “Chiudi Bolla” e
  rispondere affermativamente alla successiva richiesta di conferma.

- Al Magazzino Premi verrà aggiunta la merce consegnata.

[img:image126.png]

## Movimenti – Trasferimenti Ingresso

<span class="mark">Aggiunta nuova immagine (prima non cera nessuna
immagine</span>)

Permette di ritrasferire a magazzino dei premi precedentemente spostati
in altri reparti del locale. Il menu a discesa “Motivo” permetterà di
scegliere solo tra 3 possibilità: Sposta, Gru o Consumabili. Vedere la
finestra “[Carico da Bolla](#carico-magazzino-da-bolla)” per le
istruzioni d’uso.

## [img:image127.png]Movimenti – Trasferimenti Uscita

<span class="mark">Aggiunta nuova immagine (prima non cera nessuna
immagine</span>)

Permette di trasferire dei premi dal magazzino verso altri reparti del
locale: Sposta, Gru, Consumabili, Eventi, Ruspe o scaricarli come
Guasti. Vedere la finestra “[Scarico](#movimenti---scarico)” per le
istruzioni d’uso.

## Trasferimenti tra Locali

Permette di trasferire i premi da un locale all’altro. I locali devono
essere inseriti precedentemente nel Setup Opzioni Generali.

### [img:image128.jpeg]Carico Manuale

Questa finestra permettere di inserire dei premi manualmente provenienti
da un altro locale:

1.  Se la bolla proviene da un singolo fornitore sceglierlo dalla lista
    a discesa, comparirà l’elenco dei premi del fornitore e sarà
    possibile immetterli nella tabella con un doppio click sull’articolo
    desiderato. Una volta scelti tutti gli articoli, facendo click sulla
    tabella l’elenco sparirà e sarà possibile immettere le quantità da
    caricare per ogni articolo.

2.  Nel caso di articoli provenienti da fornitori diversi inserire i
    vari articoli scegliendone il codice dalla lista a discesa o
    leggendone il codice a barre, immettere la quantità da caricare e
    premere “Aggiungi”. Ripetere l’operazione per tutti gli oggetti da
    caricare.

3.  Inserire il locale di Origine ed il numero di consegna negli
    appositi campi.

4.  [img:image129.jpeg]Per stampare la bolla di
    carico premere l’apposito tasto, la stampa verrà inviata alla
    stampante di sistema.

5.  Premere “Chiudi Bolla” per terminare l’operazione ed aggiornare il
    magazzino.

### Carico Automatico

Questo menu apre la finestra che permette di effettuare il carico
automatico di un file di premi proveniente da un altro locale (vedi par.
11.7.3 per la procedura di creazione di questo file). Il file da
caricare deve essere copiato nella cartella “Loads” che si trova nella
cartella di lavoro del programma (normalmente “C:\WinMtSql\\).

Scegliere il file dal menu a discesa in basso a sinistra e premere
“AGGIORNA”, la tabella visualizzerà gli articoli presenti nel file. Se
la quantità consegnata coincide con quella visualizzata a schermo,
premere il pulsante “SALVA”, altrimenti è possibile modificare la
quantità in tabella e poi premere “SALVA” per caricare la lista nel
magazzino premi.

### Scarico

[img:image130.jpeg]1.Scegliere il “fornitore”

2.Scegliere dalla lista i premi desiderati

3.Scegliere il locale di destinazione

4.Inserire: n° di bolla, n° d’ordine e la data dell’operazione

5\. Confermare l’operazione premendo il pulsante “SCARICA”

> Il file generato da questa operazione viene salvato nella cartella
> “Unloads” che si trova nella cartella di lavoro del programma
> (normalmente “C:\WinMtSql\\). Questo file dovrà essere inviato,
> insieme alla merce, al locale di destinazione e dovrà essere copiato
> nella cartella “Loads” che si trova nella cartella di lavoro del
> programma (normalmente “C:\WinMtSql\\).

## Visualizza Movimenti – Movimenti Magazzino

> Permette il controllo di tutti i movimenti effettuati sia di carico
> che di scarico.
>
> [img:image131.jpeg] style="width:5.43472in;height:3.05625in" />[img:image132.jpeg] style="width:5.10347in;height:2.87014in" />
>
> Si hanno a disposizione tutte le possibilità di filtro per
> visualizzare i movimenti di carico e scarico di tutti gli articoli. E’
> possibile per esempio, visualizzare qualsiasi bolla selezionandone il
> numero o fare una ricerca per articolo in modo da tracciarne tutti i
> movimenti. La finestra comprende alcuni controlli comuni sia al Carico
> che allo Scarico:

- **Scelta** date **“Da:” “A:”**: selezionare l’intervallo di tempo
  entro il quale compiere la ricerca.

- **Codice**: selezionare il codice dell’articolo da tracciare.

- **Codice Originale**: selezionare il codice originale dell’articolo da
  tracciare.

- **Descrizione**: selezionare la descrizione dell’articolo da
  tracciare.

- **Operatore**: selezionare l’operatore per visualizzare tutti i
  movimenti compiuti dallo stesso.

- **Aggiorna**: premere questo pulsante perché le tabelle vengano
  aggiornate secondo le scelte effettuate.

Abbiamo poi i controlli che riguardano solo la tabella **Carico**:

- **Articoli e Totale**: sono due campi che riepilogano rispettivamente
  il numero di articoli in tabella ed il loro valore totale.

- **Numero Bolla di Carico**: scegliere il numero della bolla da
  visualizzare.

- **Numero Ordine di Acquisto**: scegliere il numero d’ordine da
  visualizzare.

- **Tipologia di carico**: scegliere la tipologia di carico da
  visualizzare.

- **Fornitore**: scegliere il fornitore.

- **Stampa**: permette la stampa sulla stampante di sistema della
  tabella visualizzata

Controlli che riguardano solo la tabella **Scarico**:

- **Articoli e Totale**: sono due campi che riepilogano rispettivamente
  il numero di articoli in tabella ed il loro valore totale.

- **Numero Bolla di Scarico**: scegliere il numero della bolla da
  visualizzare.

- **Numero Ordine di Acquisto**: scegliere il numero d’ordine da
  visualizzare.

- **Tipologia di scarico**: scegliere la tipologia di scarico da
  visualizzare.

- **Destinatario**: scegliere il destinatario dello scarico.

- **Stampa**: permette la stampa sulla stampante di sistema della
  tabella visualizzata

## Visualizza Movimenti – Ordini di Acquisto

(<span class="mark">nuova immagine inserita perché sotto ha più pulsanti
di quella vecchia</span>)

[img:image133.png]Questa finestra permette di
visualizzare e/o stampare gli Ordini di Acquisto effettuati.

Scegliere dalla lista a discesa l’ordine desiderato in base al suo
numero.

## Rapporti – Andamento Premi in 6 settimane

[img:image134.jpeg]

Questa finestra serve per avere uno sguardo rapido sulla situazione del
Magazzino Premi. Per ogni oggetto viene visualizzato:

- Codice

- Descrizione

- Costo

- Tickets

- Quantità media uscita settimanalmente

- Giacenza attuale

- Quantità uscita nell’ultima settimana in esame

- Quantità uscita nelle 5 settimane precedenti

La lista può essere stampata sulla stampante di sistema premendo
l’apposito tasto oppure può essere salvata in un file in formato csv
compatibile con Excel premendo l’altro tasto.

## Rapporti – Visualizza Inventario

[img:image135.jpeg]

In questa finestra viene visualizzato l’inventario prescelto, si ha,
inoltre, la possibilità di stamparlo o esportarlo in un file Excel o
csv.

##  Rapporti – Rapporto Settimanale

<span class="mark">Nuovo: questa voce non è presente nel menù,
deprecata?</span>

Questa finestra permette di effettuare il calcolo dell’incasso netto
della Sala Giochi in un periodo desiderato.

1.  Scegliere la data di inizio e di fine del rapporto.

2.  [img:image136.emf]Premere il pulsante
    Aggiorna

- **CARICO**

<!-- -->

- **Caricati:** valore dei premi caricati nel periodo.

- **Gru:** valore dei premi caricati nelle gru.

- **Trasferiti:** valore dei premi trasferiti.

- **Consumabili:** valore dei consumabili caricati.

- **Totale:** somma delle voci sopra elencate.

<!-- -->

- **SCARICO**

<!-- -->

- **Venduti:** valore dei premi consegnati ai Clienti.

- **Gru:** valore dei premi scaricati nelle gru.

- **Ruspe:** valore dei premi scaricati nelle ruspe.

- **Trasferiti:** valore dei premi trasferiti.

- **Consumabili:** valore dei consumabili utilizzati.

- **Guasti:** valore dei premi guasti.

- **Eventi:** valore dei premi utilizzati negli Eventi.

- **Totale:** somma delle voci sopra elencate.

<!-- -->

- **INCASSI**

<!-- -->

- **Redemption:** incasso Lordo e Netto delle Redemptions.

- **Gru:** incasso Lordo e Netto delle Gru.

- **Ruspe:** incasso Lordo e Netto delle Ruspe.

- **Altri:** incasso Lordo e Netto delle altre machine.

- **Totale:** incasso Totale Lordo e Netto.

<!-- -->

- **RIEPILOGO**

<!-- -->

- **Rendimento Redemptions:** percentuale di rendimento delle
  Redemptions rispetto al totale degli incassi.

- **Rendimento Gru:** percentuale di rendimento delle gru rispetto al
  totale degli incassi.

- **Rendimento Ruspe:** percentuale di rendimento delle ruspe rispetto
  al totale degli incassi.

- **Incidenza Guasti:** percentuale di incidenza dei guasti rispetto al
  totale degli incassi.

- **Incidenza Consumabili:** percentuale di incidenza dei consumabili
  rispetto al totale degli incassi.

- **Indice di Pagamento Tot.:** incidenza delle spese rispetto ai
  ricavi.

- **Indice di Rendimento Tot.:** incidenza delle ricavi rispetto ai
  spese.

- **Totale:** incasso netto totale.

Il rapporto può essere esportato in Excel, csv o stampato utilizzando
gli appositi pulsanti.

## Rapporti – Rapporto Variazione

> <span class="mark">Nuovo: questa voce non è presente nel menù,
> deprecata?</span>

[img:image137.emf]Questa finestra permette di
effettuare il calcolo dell’incasso netto della Sala Giochi in un periodo
desiderato tenendo conto delle eventuali variazioni del Magazzino Premi
effettuate negli inventari eseguiti nel periodo compreso nel rapporto.

1.  Scegliere la data di inizio e di fine del rapporto.

2.  Premere il pulsante Aggiorna

- **CARICO**

<!-- -->

- **Caricati:** valore dei premi caricati nel periodo.

- **Gru:** valore dei premi caricati nelle gru.

- **Trasferiti:** valore dei premi trasferiti.

- **Consumabili:** valore dei consumabili caricati.

- **Totale:** somma delle voci sopra elencate.

<!-- -->

- **SCARICO**

<!-- -->

- **Venduti:** valore dei premi consegnati ai clienti.

- **Gru:** valore dei premi scaricati nelle gru.

- **Ruspe:** valore dei premi scaricati nelle ruspe.

- **Trasferiti:** valore dei premi trasferiti.

- **Consumabili:** valore dei consumabili utilizzati.

- **Guasti:** valore dei premi guasti.

- **Eventi:** valore dei premi utilizzati negli Eventi.

- **Totale:** somma delle voci sopra elencate.

<!-- -->

- **INCASSI**

<!-- -->

- **Redemption:** incasso Lordo e Netto delle Redemptions.

- **Gru:** incasso Lordo e Netto delle Gru.

- **Ruspe:** incasso Lordo e Netto delle Ruspe

- **Altri:** incasso Lordo e Netto delle altre machine.

- **Totale:** incasso Totale Lordo e Netto.

- **Variazione Valore:** variazione del valore del Magazzino Premi
  dovuto agli inventari eseguiti nel periodo.

<!-- -->

- **RIEPILOGO**

<!-- -->

- **Rendimento Redemptions:** percentuale di rendimento delle
  redemptions rispetto al totale degli incassi.

- **Rendimento Gru:** percentuale di rendimento delle gru rispetto al
  totale degli incassi.

- **Rendimento Ruspe:** percentuale di rendimento delle ruspe rispetto
  al totale degli incassi.

- **Incidenza Guasti:** percentuale di incidenza dei guasti rispetto al
  totale degli incassi.

Il rapporto può essere esportato in Excel, csv o stampato utilizzando
gli appositi pulsanti.

## Rapporti – Rapporto Vendite

Apre la finestra [Rapporto](#rapporti-1).

## Rapporti – Rapporto Breve Utente

Questa finestra offre la possibilità di dare uno sguardo rapido
all’operazione tickets in un periodo a scelta con la possibilità di
esportare (Excel o csv) e di stampare i risultati.

[img:image138.jpeg][img:image139.emf]

## Fornitori

Questa finestra permette la gestione dei Fornitori di premi con la
possibilità di aggiungere, modificare o cancellare un Fornitore. La
lista può essere stampata.

## Incassi – Registra Incassi

> <span class="mark">Nuovo: questa voce non è presente nel menù,
> deprecata?</span>

In questa finestra si immettono i dati di incasso della Sala Giochi
divisi in 4 categorie:

1.  [img:image140.emf]Redemptions

2.  Gru (e Instant Redemptions)

3.  Ruspe (Pushers)

4.  Altro (Videogiochi, Flippers, ecc. )

Selezionare la data dell’incasso (può essere anche retroattiva),
inserire quindi, negli appositi campi gli incassi lordi.

Il netto viene calcolato automaticamente in base alla percentuale di
I.V.A. specificata nel riquadro “Registra Incassi” nella finestra
[Opzioni Generali](#opzioni-generali).

Premere “Salva“ per registrare l’incasso.

## Incassi – Modifica Incassi

> <span class="mark">Nuovo: questa voce non è presente nel menù,
> deprecata?</span>

[img:image141.emf]

Questa finestra permette la modifica di incassi precedentemente
registrati.

Selezionare la data in cui è stato registrato l’incasso da modificare,
negli appositi campi appariranno i relativi valori .

Effettuare le modifiche desiderate è premere “Salva”.

[img:image142.png]

## Prize HUB

<span class="mark">Nuova sezione</span>

## [img:image143.png]Gestione GRU

<span class="mark">Nuova sezione</span>

## [img:image135.jpeg]Inventario

<span class="mark">(nuovo: dove trovo questa voce?????)</span>

Questa finestra permette di effettuare l’inventario del magazzino premi
in modalità “on fly” cioè senza dover fermare le operazioni di consegna
dei premi ai clienti se non durante il salvataggio dell’inventario
stesso.

**Procedura di Inventario:**

1.  Premere il pulsante “Lista Vuota” per stampare la lista con Codice,
    Descrizione e Numero Tickets degli articoli in magazzino, la lista
    comprenderà uno spazio vuoto in cui scrivere la quantità
    dell’articolo realmente contata.

2.  [img:image144.png]Inserire le quantità
    contate nella colonna “Q. Reale” e premere INVIO. Ad ogni
    inserimento, viene calcolata la differenza (se esiste) tra quantità
    presunta e quantità reale e viene aggiornata la colonna “Variazione
    Q.tà” ed i campi “Quantità in esubero”, “Valore in esubero”,
    “Quantità mancanti”, “Valore mancante”, “Differenza di valore” e
    “Valore giacenze reali”. L’inserimento della quantità può avvenire
    anche tramite la lettura dei codice a barre relativi ai numeri
    (occorre stamparli con l’[utilità](#stampa) “Stampa Numeri” ),
    leggere poi il codice di “Conferma” per immettere il numero in
    tabella.

3.  Se durante l’inserimento delle quantità contate ci si accorge di un
    errore, per esempio di inserimento di una bolla, relativo ad uno o
    più articoli, selezionare gli articoli interessati cliccando
    all’estrema sinistra della tabella. La riga selezionata diverrà blu.
    Per selezionare più di un articolo ripetere l’operazione.

4.  Premere il pulsante “Pausa” per tornare alla finestra “Gestione
    Magazzino Premi” dalla quale si può accedere alle finestre “Carico
    Magazzino” e “Scarico Premi – Resi” per effettuare le correzioni ai
    movimenti degli articoli interessati.

5.  Una volta modificati i movimenti, ripremere “Inventario”. Verrà
    rivisualizzata la finestra “Inventario” ed i movimenti relativi agli
    oggetti selezionati verranno aggiornati. Procedere poi con
    l’inserimento delle quantità contate.

6.  Premere “Salva Inventario” per concludere l’operazione.

7.  Verrà richiesta una password autorizzata alla chiusura
    dell’inventario (può essere anche quella di un manager se la
    relativa opzione in [Opzioni Generali](#opzioni-generali) e
    abilitata).

8.  Inserire la password e premere INVIO o il pulsante OK.

[img:image145.jpeg]

9.  Le quantità contate andranno a modificare le quantità in magazzino e
    l’inventario verrà salvato nella cartella “Inv”.

Il menu “Visualizza Inventario”, permette la visualizzazione e la stampa
di uno qualsiasi degli inventari precedentemente effettuati.

## Salvataggio foto di un Articolo

Per ogni oggetto in magazzino è possibile salvare la relativa foto che
viene visualizzata nello schermo rivolto verso il Cliente in fase di
consegna del premio. Le foto degli articoli sono obbligatorie nel caso
di utilizzo dell’App Galileo o di WinMtSql 4Utenti. Le foto che si
intendono associare a un articolo devono essere accessibili dal computer
ed in formato jpeg o bmp.

- Selezionare l’articolo desiderato in tabella.

- Cliccare nel riquadro “Immagine Oggetto” che si trova in basso a
  destra della finestra “Premi”

- Scegliere la foto nella finestra di dialogo che comparirà.

- Premere “Salva”

Per visualizzare le foto in grande cliccare nel riquadro di cui sopra
col tasto destro. Cliccare sull’immagine grande per farla sparire.

[img:image146.png]

## Aree

Questa finestra permette l’emissione di scontrini per i Clienti senza
card, oppure il carico di tickets sulla card del Cliente attribuendoli
ai vari reparti abilitati.

- **CLIENTI SENZA CARD**: selezionare il reparto, inserire il numero di
  tickets nell’apposito campo e premere OK.

- **CLIENTI CON CARD**: passare la card nel lettore e verificare il
  numero e il nome del cliente che compare in alto, selezionare il
  reparto, inserire il numero di tickets nell’apposito campo e premere
  OK.

Se nel menu a discesa per la selezione del Reparto viene scelto il
reparto “Raccolta Carte”, si abilita l’altro menu a discesa che permette
di scegliere a quale raccolta carte lo scontrino emesso sarà attribuito.

## Utility 

## Gestione Operatori 

<span class="mark">Nuova immagine</span>

[img:image147.png]Questa finestra permette di
gestire gli Utenti che useranno il programma.

Esistono quattro tipi di Utenti:

1.  **AMMINISTRATORE**: hanno accesso completo al sistema e possono
    generare tutti tre i tipi di Utenti.

2.  **MANAGER**: hanno accesso completo al sistema ad esclusione del
    menu SETUP, quindi non possono modificarne le impostazioni. Sono in
    grado di generare nuovi utenti di tipo Operatore.

3.  **SUPERVISIORE**: hanno accesso al sistema solo per le operazioni di
    normale utilizzo, non possono generare utenti e le loro facoltà
    possono essere decise dall’amministratore nell’apposita sezione
    della finestra [Opzioni Generali](#opzioni-generali)

4.  **OPERATORE**: hanno accesso al sistema solo per le operazioni di
    normale utilizzo, non possono generare utenti e le loro facoltà
    possono essere decise dall’amministratore nell’apposita sezione
    della finestra [Opzioni Generali](#opzioni-generali).

Per inserire un nuovo Utente:

- Premere il pulsante [img:image148.emf] , inserire il nome ed il
  cognome dell’operatore, scegliere il livello (Amministratore, Manager,
  Supervisore o Operatore), leggere con lo scanner il codice a barre
  della card (se si intende utilizzarla) e premere il pulsante
  [img:image149.emf].

- Comparirà una finestra di dialogo con la conferma alla creazione della
  CARD OPERATORE, nel caso si voglia generare la card, occorre passarla
  nel lettore.

Per modificare i dati di un Utente:

- Scegliere l’Operatore dalla lista a discesa e premere il pulsante
  [img:image150.emf]

- Cambiare i dati desiderati (eventualmente leggere con lo scanner il
  nuovo codice a barre della card) e premere
  [img:image149.emf]

Per cancellare un Utente:

- Selezionare l’Operatore da eliminare nella lista a discesa e premere
  il pulsante [img:image151.emf]

Per riscrivere una Card Utente:

- Selezionare l’Operatore dalla lista, premere il pulsante
  [img:image152.emf]e passare una card nel
  lettore

<span class="mark">Nuove sezioni aggiunte</span>: Abilitazioni e limiti
operatore crediti di servizio

Attenzione:

- Le carte magnetiche sono passibili di clonazione! Se viene generata
  una card Amministratore, abbiatene cura. In caso di smarrimento,
  generatene subito una nuova: quella vecchia non sarà più valida.

- La password dei nuovi utenti è: “password”; è necessario che, al primo
  accesso, venga cambiata.

18. 

19. 

<!-- -->

13. 
14. 
15. 
16. 
17. 
18. 
19. 
20. 

## [img:image153.jpeg]Distributori

Questa finestra permette di inserire nella rete uno o più Distributori
Automatici attraverso i quali i Clienti possono prelevare i premi
desiderati autonomamente. Viene creato un operatore per ogni
distributore connesso a partire dal n. 1 al quale faranno capo tutte le
operazioni effettuate dai Clienti con quel distributore in modo tale che
nelle stampe di riepilogo venga indicata l’origine di tutti i movimenti.

Premere NEW per aggiungere un Distributore, selezionare un numero nella
lista e premere DELETE per cancellarne uno che venga disinstallato.

## 

## Manutenzione Archivio

[img:image154.jpeg]

Visualizza la finestra di Cancellazione Archivi:

Questa finestra permette di cancellare tutti o una parte dei dati
presenti nei vari archivi utilizzati.

- **Archivio TICKETS**: contiene gli scontrini emessi, impostare la data
  entro la quale eliminare gli scontrini, selezionare la casella se si
  desidera includere nella cancellazione anche gli scontrini dei Clienti
  possessori di una Card. Selezionare l’apposita casella per cancellare
  anche gli scontrini utilizzati. Selezionare l’apposita casella per
  cancellare anche gli abbuoni.

- **Archivio PREMI**: selezionare le relative caselle per svuotare
  completamente il magazzino premi e/o i relativi movimenti e
  prenotazioni.

- **Archivio VINCITE**: impostare la data entro la quale eliminare le
  registrazioni delle vincite pagate, selezionare l’apposita casella per
  eliminare tutte le registrazioni relative ai premi resi. Selezionare
  l’apposita casella e selezionare la data per cancellare le ricevute
  dei premi consegnati con valore superiore al minimo di legge.

- **Archivio CLIENTI**: selezionare la casella per cancellare i Clienti
  che non hanno fatto nessuna operazione di carico tickets sulla card
  dalla data selezionata. Fatta questa operazione, tutte le cards
  relative ai clienti cancellati non saranno più riconosciute.

- **Archivio INCASSI:** Selezionare l’apposita casella e scegliere la
  data per cancellare tutti gli incassi registrati fino a la data
  selezionata.

- **Annulla**: chiude la finestra e ritorna a quella di Accesso senza
  toccare nessun archivio.

- **OK**: cancella i dati degli archivi secondo quanto impostato. Prima
  di ogni operazione viene chiesta conferma.

**  
**

## Pulizia Archivi

[img:image155.jpeg]Questo menu permette di
cancellare tutti gli scontrini emessi e già utilizzati. Occorre tener
presente che facendo questa operazione se poi si crea un rapporto con la
data di partenza antecedente la pulizia effettuata, questi dati non
saranno validi in quanto gli scontrini emessi nel passato ed utilizzati
non saranno più presenti in archivio e, quindi, non conteggiabili.

## Conteggio Scontrini

Utilità per effettuare il conteggio e la somma automatica dei tickets
contenuti in una serie di scontrini. Leggere i codici a barre degli
scontrini per inserirli nella lista e visualizzarne la somma.

## Test velocità SQL Server

Utilità per effettuare un test dei tempi di risposta del server sql
durante la fase di reset della finestra principale e di ricerca di un
Cliente.

## Stampa

Sono presenti 2 sotto menu: (<span class="mark">nuovo: ora è presente
solo la voce numeri</span>)

- Comandi: per stampare i codici a barre dei comandi utilizzati dalla
  versione 4 Utenti.

- Numeri: per stampare i codici a barre dei numeri utilizzati durante la
  creazione di un inventario.

## [img:image156.png]Dettagli Scontrino

Apre la finestra relativa per ottenere informazioni sullo scontrino che
si passerà sotto lo scanner. Leggendo uno scontrino, la finestra ne
mostrerà le informazioni. La prima riga mostra la data di creazione, la
sorgente che lo ha generato (in questo caso trattasi di scontrino
generato a fronte di un premio reso), il reparto e l’operatore che ha
effettuato l’operazione o che lavorava nel sistema al momento della
creazione dello scontrino se generato da una Mangia Tickets. Nella
seconda riga, se lo scontrino è stato già utilizzato, compare la data di
utilizzo, il motivo per il quale è stato utilizzato (in questo caso per
ritirare il premio indicato), e l’operatore che ha effettuato
l’operazione.

[img:image157.png]

## Raccolta Card

16. 

17. 

18. 

19. 

20. 

21. 

## Riabilita Card

I sotto menu esistenti dipendono dai moduli che sono stati acquistati e
che abilitano il riconoscimento delle cards provenienti dai vari giochi
che le possono distribuire. In ogni caso saranno visibili almeno 2 sotto
menu:

- Tutte: per riabilitare tutte le carte raccolte

- Mistral: per riabilitare solo le carte Mistral

[img:image158.png]Eventuali altri sotto menu
serviranno per riabilitare selettivamente le carte provenienti dai vari
giochi.

Esistono 2 modi per riabilitare le cards:

- Una per una: leggendole con lo scanner il codice relativo alla card
  letta sparirà dalla lista e la card sarà riabilitata.

- Premendo il pulsante “Riabilita TUTTE LE CARDS” che le riabiliterà
  tutte insieme senza controllo.

## Conteggio Card

Anche in questo caso avremo tanti sotto menu quante sono le macchine
abilitate alla distribuzione di carte. Permette di visualizzare ed
azzerare i contatori delle cards singole e delle serie complete lette.
La data di cancellazione dei contatori viene memorizzata per permettere
il controllo a fine periodo del numero di carte lette.

## Bonus Promozioni e Sconti

<span class="mark">(nuovo: dove trovo questa parte?????)</span>

WinMtSql dispone di un sistema di marketing molto versatile ed
articolato, pensato per ottenere i migliori risultati in termini di
fidelizzazione dei clienti e quindi di resa economica della Sala Giochi.

Per incentivare l’uso della card da parte dei clienti, ad essa sono
associate una serie di agevolazioni:

- [img:image159.jpeg]**Sconto sul valore dei
  premi**: dà la possibilità di diminuire il valore, in tickets, di
  tutti i premi. Passando la card nel lettore, le tabelle dei premi
  risulteranno colorate in celeste per indicare, all’operatore ed al
  cliente, che i valori indicati sono scontati.

- **Tickets omaggio creazione card**: all’atto di generazione della
  card, essa viene caricata gratuitamente con il numero di tickets
  preimpostato.

- **Tickets omaggio 24 ore**: il cliente riceve un bonus di tickets,
  pari al numero preimpostato, alla prima operazione di conteggio di
  tickets che superi il numero minimo necessario ad ottenere il bonus.
  Se questo numero è uguale a zero, il cliente, semplicemente passando
  la card nel lettore della cassa, [img:image160.jpeg]otterrà il bonus che verrà
  segnalato da una scritta lampeggiante sul monitor cliente.

- **Tickets minimi per omaggio 24 ore**: numero minimo di tickets da
  contare per avere diritto ai Tickets Omaggio 24 ore.

- **Tickets Bonus**: ogni conteggio di tickets effettuato nel periodo di
  validità dell’opzione, verrà maggiorato della percentuale impostata.
  Il periodo di validità viene segnalato con delle scritte su entrambi i
  monitors. I tickets in questo modo regalati al cliente si sommano ad
  eventuali altri bonus abilitati. Se, ad esempio, un cliente conta 1000
  tickets come prima operazione del giorno, il bonus Tickets omaggio 24
  ore è messo a 100 tickets e l’opzione Tickets Bonus è configurata a
  1.5 % come sopra: alla carta verranno aggiunti 1.115 tickets:

  - 1000 contati

  - 100 omaggio 24 ore

  - 15 bonus (1,5% di 1.000 tickets contati = 15)

[img:image161.png][img:image162.png]

Per tutti i clienti, compresi quelli senza card si possono offrire delle
Promozioni:

- **Promozioni**: nel periodo impostato, il valore in tickets dei premi
  verrà scontato della percentuale prefissata. Per il periodo nel quale
  questa opzione è attiva, sia sul monitor Operatore che su quello del
  Cliente il colore di sfondo delle tabelle premi cambia a seconda che
  ci sia avuto uno “Sconto” abbinata oppure no.

[img:image165.jpg][img:image166.png][img:image169.png][img:image170.png]Più precisamente, per i
Clienti con card, scegliere , nel caso sia abilitato lo sconto fisso, se
questo, durante la promozione

viene disabilitato lo sfondo del

monitor diventa verde sostituisce

la promozione stessa lo sfondo

diventa celeste, oppure se sconto

e promozione si sommano e lo

sfondo diventa rosa .

## [img:image173.png]Guida

## Manuale online

> Apre la finestra con le informazioni sul programma:

## Info su WinMt

> Permette di aprire questo manuale in versione pdf.

# 

[img:image174.png]
