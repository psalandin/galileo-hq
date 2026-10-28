# Galileo HQ — Analisi 02: note e domande per Fabrizio

**Stato:** da inviare · **Responsabile:** Piero · **Aggiornato:** 2026-10-28

**Fonti:** sync 00–03, ecl2mqtt 00 e 07, DB 09 · **Collegati:** [`../00-indice.md`](../00-indice.md)

Questo documento raccoglie, dall'analisi dei sorgenti ricevuti (motore `ecl2mqtt`, `ExecuteSync`, `ExecuteSyncSSH`, `WinMtProv`, DB `CliTest`), quello che può servire a te e quello che ci serve sapere da te.

- **§ 1, note.** Cose trovate nel codice e nei dati che riguardano anche le installazioni attive. Non chiedono risposta, salvo le conferme del § 1.3.
- **§ 2, domande.** Si può rispondere per codice (es. «S1: …»), anche in due righe. ★ indica le domande che condizionano il disegno del nuovo sistema o l'esercizio attuale.

Le evidenze sono `file:riga` sui sorgenti in `legacy/`. Le credenziali trovate nel codice non sono riportate qui né in altri documenti: si indica solo dove sono.

---

## 1. Note

### 1.1 Sicurezza: riguarda le installazioni attive

| # | Cosa | Dove |
|---|---|---|
| N1 | **Chiavi API in chiaro nella tua documentazione**, in sette righe di tre file. Per questo la cartella non è ancora nel repository | `istruzioni_vb6_prizehub_opzioneA.md` (righe 51, 53, 161), `api_prizehub.md` (29, 36, 37), `api_crane_handler.md` (142) |
| N2 | **`WinMtProv` contiene le password `sa` dei due server cloud**, nel sorgente e nell'eseguibile. Chi ha l'eseguibile ha `sa` su tutti i DB di tutte le sale dei due ambienti, compreso `DROP DATABASE`. I comandi SQL sono composti concatenando testo, senza parametri | `WinMtProv/Form1.vb:29-32` (sync 02 § 9) |
| N3 | **`ExecuteSync` ed `ExecuteSyncSSH` contengono la password di `WinMtSync`**, che è `db_owner` di ogni DB cloud, e la password `sa` della sala | `ExecuteSync/…/Program.cs:19-22`, `ExecuteSyncSSH/…/Program.cs:19, 21` (sync 01 § 5) |
| N4 | **Lo script `collegamentoserver.sql`** crea il linked server `elmaccloud` mappato su `sa` del cloud **per tutti i login** del server di sala: qualunque utente della sala arriva al cloud come `sa` | Script di WinMtProv, `WinMtSqlDB/Procedure/collegamentoserver.sql` (sync 03 § 5) |
| N5 | **`fn_calcHMAC` ha la chiave segreta scritta nel codice** della funzione, in entrambi i DB che la contengono | Script di WinMtProv (sync 03 § 5) |
| N6 | **Endpoint del motore senza verifica.** `/eclcommand`, `/eclservices`, `/redundance` e `/config` non hanno autenticazione; `/api/*` non verifica il bearer; l'HMAC di `eclcommand`/`eclservice` firma solo un timestamp e non viene mai verificato. La risposta a `SLAVEFIND` contiene la password dell'amministratore di WinMT, offuscata in modo reversibile | `APIHandler.bas:60-130`, `funzioni.bas:15-32`, `Autodiscover.bas:249-256` (ecl2mqtt 01 § 1, ecl2mqtt 00 § 4) |

### 1.2 Comportamenti dell'esercizio attuale

| # | Cosa | Evidenza |
|---|---|---|
| N7 | **L'indicatore di sincronizzazione di WinMT è sempre verde.** Il bordo del pulsante di chiusura legge `SyncRes` della prima riga di `Setup`, la 101, che a Central Park è ferma al 04/06/2024. L'esito vero si scrive nella riga 110. L'avviso via email usa invece la 110 e funziona | `Form1.frm:16889-16896` (indicatore), `16120-16127` (email); dati del 14/07/2026 (sync 00 § 2.3) |
| N8 | **L'intervallo di sincronizzazione è in due righe.** WinMtProv lo scrive in `Setup(101).N0`, WinMT lo legge e lo scrive in `Setup(110).N0`. `sp_last_trans` del DB di gruppo usa la 101 come finestra del blocco «card usata da poco in un'altra sala»: se l'intervallo si cambia da WinMT, il blocco non se ne accorge. A Central Park oggi valgono entrambe 600 | `frmsetSys.frm:9271-9296`; `sp_last_trans` (sync 00 § 2.3, DB 09 § 3) |
| N9 | **`LocalSync` (primario ↔ secondario) nel codice ricevuto si esegue solo a mano**, da WinMtProv. Se non c'è un altro componente che lo pianifica, al failover il secondario può essere indietro | `WinMtProv/Form1.vb:766-799, 1099-1144` (sync 02 § 5) |
| N10 | **Un secondario creato con WinMtProv non ha i trigger applicativi**: gli script di riferimento non li contengono e nessun programma ricevuto li crea | sync 03 § 2.1 |
| N11 | **`MULTI SITE SETUP` non si può rieseguire senza danni.** La guardia sui flag protegge solo le righe scritte con il flag a 1, mentre il motore scrive sempre `TransCard.F0 = 0`, `AddAbbuono` non valorizza `Abbuoni.F0` e `sp_preleva_punti` non valorizza `Tickets.N1`: quelle righe verrebbero moltiplicate una seconda volta. Converte inoltre `Abbuoni.Id`, che è l'operatore, e lavora senza transazione. A Central Park non risulta eseguita | `WinMtProv/Form1.vb:402-506` (sync 02 § 6) |
| N12 | **Il DB cloud si cancella con due conferme** («Delete it?», poi «Abort deletion?») a partire da un nome di sei caratteri digitabile a mano | `WinMtProv/Form1.vb:77-90` (sync 02 § 3.2) |
| N13 | **Difetto di WinMtProv con SSH attivo.** Il DB cloud si crea collegandosi al server scritto nella casella (`CmbCloudS.Text`), cioè quello pubblico, e poi si prepara passando dal tunnel | `WinMtProv/Form1.vb:359` (sync 02 § 3.2) |
| N14 | **`Versioni.txt` di WinMtProv 1.11 dice `102:NRep2`** per l'IP del secondario; il codice legge `NRep3`, come WinMT | sync 02 § 3.4 |
| N15 | **`ExecuteSync` non gestisce gli errori** (nessun `try`), sovrascrive `Sync.log` a ogni esecuzione e registra solo l'ultimo conflitto, e solo per le modifiche che scendono in sala | `ExecuteSync/…/Program.cs:38-75` (sync 01 § 2-3) |

### 1.3 Deduzioni da confermare (basta sì o no)

| # | Deduzione | Riferimento |
|---|---|---|
| C1 | Lo scope `WinMtSync` sincronizza `WinMtSqlDB` della sala con la sua copia `DBnnnn` nel cloud (`DB` + `Setup.NImp` su quattro cifre: Central Park = `DB0196`). `LocalSync` sincronizza il server primario (`Setup(102).NRep2`) con il secondario (`NRep3`). I due `GALILEOSERVER-1/-2` visti nei dati sono questi due server | sync 00 § 2.1 |
| C2 | Ci sono due ambienti cloud separati, `winmt.elmaccloud.com` (Elmac) e `sql.galileouk.cloud` (Galileo UK), con credenziali proprie | sync 00 § 2.1 |
| C3 | La struttura del DB di Central Park è stata ricostruita il 03/06/2026 dagli script distribuiti con WinMtProv: 73 tabelle su 74 coincidono, come tutte le funzioni, le viste e le procedure | sync 03 § 2 |
| C4 | `ExecuteSecSync.sln` e lo scope `SecWinMtSync` non sono più in uso: lo scope non c'è né in test né in produzione | sync 01 § 4 |
| C5 | Il ricordo sulla stringa di connessione dedicata è giusto: è `CServer`, in `Setup(101).T7`. `CliTest` è il DB clienti di un gruppo multisala di prova; ne esiste uno per gruppo, e `rdclienti` (predefinito nel motore) è quello di un gruppo reale | DB 09 § 1 |
| C6 | I flag `F0`, `F1` e `N1` di `Abbuoni`, `Prenotaz`, `Tickets`, `TicketsCan`, `TickRep`, `TransCard`, `Vincite` e `Vincite25` significano «riga già in formato di gruppo» | sync 02 § 6 |

---

## 2. Domande

### 2.1 Sincronizzazione sala–cloud

| # | Domanda | Perché serve |
|---|---|---|
| S1 ★ | **Chi lancia `ExecuteSync`, ogni quanto, e chi scrive `Setup(110).SyncRes` («Success on: …») e `D1`?** Un'operazione pianificata di Windows, un servizio, il «servizio .NET»? Possiamo averne il sorgente? | Nessun programma ricevuto fa queste cose: è l'ultimo pezzo della catena attuale (sync 00 § 2.3) |
| S2 ★ | **Chi esegue `LocalSync` in esercizio**, e con quale frequenza? La tua documentazione parla di «ogni 60 secondi» | Vedi N9: decide quanto il secondario è allineato al failover |
| S3 | Chi apre il tunnel SSH su `127.0.0.1:4433`, con quale chiave, e da quando è obbligatorio? | È la scelta predefinita di WinMtProv, ma nessun programma lo apre |
| S4 | Quali sale stanno su `winmt.elmaccloud.com` e quali su `sql.galileouk.cloud`? HQ lavora su entrambi? | Dimensiona la migrazione e il modello multi-tenant |
| S5 | Quale intervallo vale davvero, `Setup(101).N0` o `Setup(110).N0`? Le due righe vanno tenute uguali a mano? | Vedi N8 |
| S6 | Come si installano i trigger applicativi su una sala nuova e sul secondario? | Vedi N10 |
| S7 | In `CliTest` la tabella `Clienti` è sincronizzata con tre scope, `SyncCli1012`, `SyncCli1014` e `SyncCli1015`, uno per sala. **Chi li prepara e chi li esegue?** WinMtProv non li conosce | È un terzo canale di sincronizzazione, fuori dal codice ricevuto (DB 09 § 1) |
| S8 | Ci sono stati casi di conflitti o disallineamenti fra sala e cloud? Come si sono risolti? | Il nuovo sistema deve rifare la replica con la sala autonoma senza connessione: servono i casi reali |

### 2.2 Multisala e DB di gruppo

| # | Domanda | Perché serve |
|---|---|---|
| M1 ★ | **Quale regola fra `IdLong` e `IdContatto` vale per identificare il cliente nel gruppo?** Il blocco «card usata da poco in un'altra sala» va applicato anche alle API del motore? | Definisce l'identità del cliente nel nuovo modello (ecl2mqtt 00 § 7, domanda 4) |
| M2 | Le sale dei gruppi esistenti sono state convertite con `MULTI SITE SETUP`? La conversione di `Abbuoni.Id` (operatore) è voluta? | Vedi N11 |
| M3 | Quanti gruppi multisala esistono e come si chiamano i loro DB clienti? `CliTest` è ancora usato per le prove? | DB 09 § 6 |
| M4 | Le sale 1012, 1014 e 1015 di `CliTest` sono sale reali o di prova? | DB 09 § 6 |
| M5 | `Clienti.N0` con il codice di sala arriva davvero nelle sale del gruppo? | In `CliTest` la colonna ha un secondo significato (DB 09) |
| M6 | `sp_unione_card` esiste da qualche parte? WinMT ne costruisce la chiamata in multi-locale ma non la esegue | Non è né in sala né in `CliTest` (WinMT 03, DB 09 § 6) |
| M7 | Nel motore il DB `rdclienti` è fisso per `sp_preleva_punti`: è voluto? | `DBwinmt.bas:7885`, `8424` |
| M8 | Il DB di gruppo si installa ancora dagli script `MultiLocaleDB` distribuiti con WinMtProv, che sono del 10/01/2023 e più vecchi di `CliTest`? Dove sta la versione corrente? | sync 03 § 3 |

### 2.3 Motore `ecl2mqtt`

| # | Domanda | Perché serve |
|---|---|---|
| E1 ★ | **Strategia del porting.** Le regole VB6 portate nel motore (anti-clonazione, VIP, promozioni, ricarica, riscatto) servono solo al totem o devono sostituire la cassa? Quali delle regole divergenti valgono per tutti: unità VIP, card non aggiornata, BIRTHDAY → SILVER, `NonCont`, `Vincite` per richiesta? | Decide dove sta la logica unica del nuovo sistema (ecl2mqtt 00 § 3) |
| E2 ★ | **Saldo di riferimento.** Quale formula è quella giusta? Quale `NImp` devono avere gli accrediti da cloud, redeem e totem, che oggi risultano fatti dalla cassa fissa? | Modello dei movimenti e dei saldi |
| E3 | Ticket automatici: in modalità online girano sia la procedura sia il motore? Lo si vedrebbe da lotti `MangiaT 8256` doppi per la stessa partita | Possibile doppia emissione |
| E4 ★ | **Cloud.** Il cloud raggiunto con il linked server `elmaccloud` è lo stesso di HQ? Il mosquitto di sala è in bridge? Chi pubblica `ElmacAPI/*` e chi consuma `Errors/*`? In produzione `Connected` vale 0 o 1? Quali tabelle muovono `replicaTabelleDalCloud` e `replicaTabelleSulCloud`? | Architettura sala–cloud |
| E5 ★ | **Configurazione delle macchine.** Il backoffice B4J diventa l'unico punto di configurazione, o resta in parallelo a WinMT? | Requisito della configurazione remota |
| E6 ★ | **Protocollo dei dispositivi.** Il lato server del protocollo ECL (topic, decodifica dei record, provisioning, OTA) si riusa così com'è o si riscrive? Esiste una specifica? | Confine con la BE e con il firmware, fuori perimetro |
| E7 | Per quanto tempo il totem attuale (scrittura diretta nel DB) convivrà con quello nuovo (`/kiosk`)? | Pianificazione della fase 2 |
| E8 | Chi chiama `/api/*`, `/config` e il gruppo PLAYER di `/app`? | Consumatori da mantenere |
| E9 | WinMT legge ancora `EcsMacchine.T0` come valore del piatto, e sa interpretare i flag JSON (`BISwap`, `NoRec`) che ci scrive il motore? Chi scrive `EcsMacchine.F0`? | Doppio significato della colonna |
| E10 | Chi lancia `sp_generacache`: SQL Agent, WinMT, HQ o il servizio .NET? | Reportistica schedulata |
| E11 | `WinMtSqlDBGlobo` è il DB di un cliente? Allora «Globo» non è un sistema precedente | Glossario (Analisi 00 § 5) |
| E12 | `GamePark` ha due significati nel codice: quale è quello vero, o servono due flag distinti? | ecl2mqtt 07 § 6 |
| E13 | Il premio fittizio in `Premi` (`Attivo = 0 AND Prenotabile = 0`) e il riuso delle colonne EMV di `LogTransazioniPos` e `LogTransazioniTotem.AC`: nel nuovo modello li sostituiamo con entità e colonne dedicate. Hai obiezioni? | Orientamento per il modello dati |
| E14 | Le richieste del team del totem (id di transazione generato dal totem, M4 `redeem-create`, stati del POS, gruppi J, K e L) vanno chiuse nel motore attuale o passano al progetto nuovo? | Confine fra manutenzione e progetto |
| E15 | Gli endpoint senza autenticazione (N6) sono accettati perché c'è isolamento di rete? Vale anche per il cloud? | Requisiti di sicurezza |
| E16 | Il manuale del backoffice (bozze e `.odt`) è fonte per i casi d'uso o solo per la formazione? | Uso della documentazione |

### 2.4 Sicurezza

| # | Domanda | Perché serve |
|---|---|---|
| K1 ★ | Le chiavi API di N1, presenti anche nel VB6, sono quelle di produzione? Vanno ruotate? Possiamo mascherarle nei tuoi documenti per versionare la cartella? | Per ora la documentazione resta fuori dal repository |
| K2 ★ | Chi ha gli eseguibili di WinMtProv ed `ExecuteSync` (N2, N3)? È prevista una rotazione delle password `sa` dei server cloud e di `WinMtSync`? | Esposizione delle installazioni attive |

### 2.5 Materiale da ricevere

| # | Cosa | Perché serve |
|---|---|---|
| R1 ★ | Il sorgente del componente che pianifica la sincronizzazione e ne scrive l'esito (S1) | Completa la catena sala–cloud |
| R2 | Il `CLAUDE.md` e il `LAVORO_IN_CORSO.md` del progetto B4J, citati spesso nella documentazione | Decisioni e lavori in corso che non vediamo |
| R3 | La configurazione del mosquitto di sala | Bridge, topic, autenticazione (E4) |
| R4 | Una copia del DB di produzione più recente del 14/07/2026 | La copia attuale precede parte del porting (totem, redeem) |
| R5 | Il DB di produzione di HQ, se puoi fornirlo tu | Analisi del modello cloud |
