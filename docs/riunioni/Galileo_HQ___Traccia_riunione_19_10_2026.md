# Galileo HQ — Traccia riunione 19/10/2026

Oct 18, 2026 · @Piero Salandin

## Obiettivo della riunione

Uscire con gli elementi per stimare le **ore uomo necessarie a redigere il documento di analisi**, con un modello dati stabilizzato o quasi. Non si entra nel merito delle soluzioni: ogni domanda serve a fissare il perimetro o a ridurre l'incertezza della stima.

Regola di conduzione: se un argomento non cambia la stima, si annota e si rinvia alle interviste della fase 1.

## Cosa sappiamo già

Le fonti lette finora (manuale WinMT, riunioni del 07/10 e del 12/10, database di una sala) danno un quadro sufficiente per impostare la stima, ma con tre incognite grosse: il codice sorgente, il perimetro multi-sala e la qualità reale dei dati.

- **Dominio:** 8 zone funzionali provvisorie, da validare (la stima non dipende dal loro numero ma da quello dei flussi): identità e ruoli, clienti e card, valore a circuito chiuso, macchine e telemetria, premi e magazzino, promozioni, reportistica, multi-sala.
- **Database di sala:** 84 tabelle di dominio, quasi senza chiavi esterne. La logica nel DB è poca (26 procedure, 25 funzioni, 14 viste, 4 trigger attivi); il resto è nel codice VB6 e .NET.
- **Sincronizzazione:** Microsoft Sync Framework 2.1, riga per riga, con due scope sulle stesse 40 tabelle. Propaga anche le cancellazioni.
- **Modello dati:** chiavi GUID casuali (frammentazione oltre l'80%), campi jolly con significato reale nelle tabelle centrali, identificativi incoerenti (`IdContatto` è la chiave di fatto, scritto anche come testo).
- **Storico:** cancellazioni massive (116.000 consegne premi il 22/05/2026) e progressive su movimenti card e contatori.
- **Ambiente:** il DB contiene postazioni e movimenti di sviluppo e test.
- **Conformità:** nessun PAN in chiaro accertato; password non cifrate; dati di minori previsti dallo schema.

## Punti già fissati

Questi punti sono stati stabiliti prima della riunione e non vanno ridiscussi, salvo novità.

| Tema | Decisione |
| --- | --- |
| Destinatari | Il team (Antonio, Fabrizio, Piero), che deve rendere conto alla proprietà con una stima affidabile del tempo di analisi |
| "DB stabilizzato" | Modello **logico** che ragionevolmente subirà poche variazioni nelle fasi successive |
| Dettaglio dei flussi | Censiti e definiti quanto basta per contarli e stimarne il peso; nessun caso d'uso completo |
| Architettura | Il documento la fissa; molti aspetti sono già consolidati |
| Stima di fase 2 | Inclusa nel documento, con variabilità attesa fino al ±30% |
| Revisioni | Due riunioni con il team oltre a quella del 19/10 |
| Perimetro tecnico | Struttura dati generale, back end, servizi dei server, collegamento cloud–sala (soprattutto backup, poi configurazione) |
| Fuori perimetro | Firmware dei dispositivi. La comunicazione tra dispositivi e server di sala è compito della BE, unità quasi completamente definita e ingegnerizzata |
| Cassa e totem | Riscritti, probabilmente in Flutter, su API del server Laravel. Altri dispositivi: da decidere |

## Blocco B — Perimetro funzionale

Obiettivo: sapere quante delle 8 zone entrano nell'analisi e con quale profondità.

1. **HQ e back office.** Il 07/10 si è detto che saranno "due robe separate". Cosa fa l'uno e cosa fa l'altro?
2. **Multi-sala.** Il manuale descrive già card valide nel gruppo, Dare/Avere tra locali e trasferimenti. Cosa manca davvero: livello proprietario sopra le sale, magazzino centrale, report consolidati?
3. **Funzioni deprecabili.** Chi decide cosa si abbandona (sistema 4 utenti, conteggi manuali, Mistral, …)? Quando?
4. **Varianti di cliente.** Quante configurazioni vanno analizzate: proprietario-gestore (Albarella), noleggio (Rubano), integrazione con software terzo (Vicenza), mercato inglese? Esiste un elenco delle personalizzazioni già fatte?
5. **Altri dispositivi.** Oltre a cassa e totem, quali altri front end o dispositivi entrano nell'analisi (gru, PrizeHub, distributori, POS, web app installatori)? Chi decide e quando?
6. **Moduli commerciali.** Serve già in fase 1 l'elenco dei moduli attivabili per licenza?

## Blocco C — Fonti disponibili

Il fattore che sposta di più la stima è l'accesso al codice: senza, ogni regola nascosta (campi jolly, offline, calcolo dei contatori) va ricostruita a intervista.

1. **Codice sorgente di WinMT (VB6).** È disponibile? Completo e allineato alla versione in produzione? Si può analizzare con strumenti AI, considerando riservatezza e licenze?
2. **Codice del servizio di sala (.NET)**, del sincronizzatore, del totem e della web app installatori: stesse domande.
3. **Documentazione esistente.** Documenti di Toby, tabelle su Google Docs, documentazione di Fabrizio su HQ, gru e report, descrizione del DB iniziata anni fa: quando si possono avere?
4. **Altri database.** Serve almeno:
   - un DB di un'installazione grande (quella dei 2 milioni di record);
   - il DB del cloud HQ, per vedere la struttura multi-sala.
5. **Firmware e protocolli.** C'è una specifica del protocollo tra schede e servizio?

## Blocco D — Interlocutori e campo

Ogni ora di intervista impegna anche il team interno: va stimata e pianificata insieme alle ore di analisi.

1. **Chi sa cosa.** Per ciascuna zona, chi è il riferimento? Ipotesi da confermare: Fabrizio per HQ, ECL, gru e report; Antonio per totem, periferiche e MQTT; Giannina per magazzino, clienti e assistenza; Toby per la parte storica di WinMT.
2. **Disponibilità.** Quante ore a settimana può dare ciascuno, considerando la manutenzione delle installazioni attive?
3. **Validazione sul campo.** Quando sono possibili la visita in sala e in magazzino e l'incontro con l'assistenza? Il sommario Plaud indicava il 16 e il 18/10: sono confermati o da ripianificare?
4. **Revisione.** Chi rivede le bozze di analisi, e con quali tempi di risposta?
5. **Decisioni.** Chi decide sul perimetro quando ci sono alternative (committente, Fabrizio, entrambi)?

## Blocco E — Chiarimenti tecnici dal DB

Solo le domande la cui risposta cambia il lavoro di stabilizzazione del modello dati; le altre restano nei documenti DB 03 e DB 04.

| # | Domanda | Perché incide sulla stima |
| --- | --- | --- |
| 1 | Questo DB è di una sala reale o di laboratorio? Perché contiene postazioni di sviluppo? | Decide se i numeri sono rappresentativi o serve un altro DB |
| 2 | Chi sono i peer di `LocalSync` e `WinMtSync`? | Definisce la topologia attuale da sostituire |
| 3 | Cosa è successo il 22/05/2026 alle 16:35? Le cancellazioni di `TransCard` ed `EcsDati` sono volute? Lo storico è archiviato altrove? | Senza storico la migrazione cambia natura |
| 4 | Il DB cloud è uno per sala o unico? | Base del modello multi-sala |
| 5 | Cosa significano `NImp` 146 e 9997, e `NImp` in `TransCard`? | Serve per l'identità dei record tra sale |
| 6 | Come si generano `IdContatto` e `IdLong`? | Strategia delle chiavi |
| 7 | I campi jolly (`F0`, `T0`, `N0`, …) sono documentati? | Senza documentazione vanno decodificati dal codice |
| 8 | `TipoCard` è il livello della card? Il 39% di Platinum è reale? | Regola di dominio e possibile bug da correggere in migrazione |
| 9 | Esiste un piano di manutenzione degli indici? | Spiega la frammentazione diversa tra tabelle |

## Schema di stima da validare

Con i punti già fissati l'ipotesi è di **circa 200–370 ore di analista e 75–140 ore del team interno**, se il codice sorgente è accessibile. Senza codice sale a circa 240–450 ore di analista. Sono ordini di grandezza da calibrare, non un preventivo.

| Pacchetto di lavoro | Analista (h) | Team interno (h) | Cosa sposta la stima |
| --- | --- | --- | --- |
| 1. Censimento e pesatura dei flussi | 50–100 | 25–50 | L'indice del manuale ha 87 voci; con HQ, servizi e sezioni non documentate si stimano 100–130 flussi, a 0,5–0,8 h ciascuno |
| 2. Analisi del codice sorgente | 30–60 | 5–10 | Disponibilità del codice (C.1). Senza codice: +40–80 h nel pacchetto 1 |
| 3. Modello dati logico | 40–70 | 10–20 | Perimetro multi-sala (B.2), decodifica dei campi jolly |
| 4. Architettura sala–cloud | 20–35 | 10–15 | Molti aspetti già consolidati; restano sincronizzazione, backup e configurazione remota |
| 5. Validazione sul campo | 12–20 | 8–12 | Numero di sale e magazzini da vedere |
| 6. Requisiti non funzionali e conformità | 10–20 | 3–5 | PCI DSS, GDPR, ruoli, backup, conservazione dei log |
| 7. Migrazione, a livello logico | 15–25 | 5–10 | Storico disponibile, rapporto con Globo |
| 8. Stesura, tre riunioni di revisione, stima di fase 2 (±30%) | 25–40 | 10–15 | Tempi di risposta del team alle bozze |

I tre fattori che pesano di più sono, in ordine: l'**accesso al codice**, il **numero reale dei flussi** e il **perimetro multi-sala**.

## Esiti attesi a fine riunione

- [ ] Accesso al codice sorgente: sì o no, e quando
- [ ] Elenco delle zone e dei dispositivi dentro e fuori perimetro
- [ ] Ordine di grandezza dei flussi per zona, almeno per HQ e servizi non coperti dal manuale
- [ ] Date per documenti esistenti e per un secondo DB
- [ ] Interlocutori per zona, con ore disponibili a settimana
- [ ] Data della visita in sala e dell'incontro con l'assistenza
- [ ] Scadenza reale del documento (il 21/10 indicato da Plaud è confermato?)
