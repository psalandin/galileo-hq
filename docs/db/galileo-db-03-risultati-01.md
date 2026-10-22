# Galileo HQ — DB 03: risultati del kit di query 01

**Stato:** bozza di lavoro · **Data:** 18/10/2026 · **Fonte:** copia locale di `[WinMtSqlDB]` (dati fino al 15/10/2026), query Q01–Q10
**Collegati:** `galileo-db-01-schema.md`, `galileo-db-02-catalogo.md`, `galileo-db-query-02.sql`

Questo documento corregge o precisa alcune affermazioni di DB 01, segnalate di volta in volta.


> **Nota del 20/10/2026:** il database analizzato è stato confermato come **database di test**, non di produzione. Le osservazioni sullo schema restano valide; volumi, date e statistiche vanno riverificati sul database di produzione (6–7 GB) e su quello di HQ, attesi a breve.
---

## 1. Profilo della sala

- È una sala **piccola**: circa 6.100 clienti, 40 macchine censite, 186.000 righe di ticket in cinque anni. La tabella più grande è `CoinlessDecodedData`, con 396.000 righe.
- **Attività dal settembre 2021** (prime righe di `Clienti`, `Tickets` e `TransCard`).
- **Moduli recenti, con le date di prima comparsa:** ECL/telemetria nel 2023, POS a novembre 2025, RedeemCodes tra marzo e maggio 2026 (pilota?), gestione gru ad aprile 2026, PrizeHub a giugno 2026.
- **Funzioni non usate in questa sala** (tabelle vuote): Abbuoni, Incassi, Ordini, Resi, Scocard, TickRep, Differ, RiepInv, Owners, Machines, Manuf, Mistral, Figli, EcsErr, UltimoInventario.
- **Magazzino quasi inattivo:** 86 carichi e 104 scarichi, tutti dal 22/05/2026. Concorda con quanto detto il 12/10 sull'uso reale.

> **Conseguenza.** I problemi di prestazioni "oltre i 2 milioni di record" non nascono da questa sala. Bisogna sapere in quale installazione si manifestano, per avere un database rappresentativo dei volumi.

---

## 2. Sincronizzazione

**Due scope** (Q03), `LocalSync` e `WinMtSync`, entrambi su Sync Framework **2.1** (`schema_info`). Nessuno dei due ha filtri: in ciascuno lo stesso insieme di tabelle viene sincronizzato per intero. L'XML in Q03 è troncato a 65535 caratteri e mostra 31 tabelle su 40; Q11 ricava l'elenco completo.

> **Domanda.** Verso chi sincronizzano i due scope? Ipotesi: `LocalSync` tra le postazioni della sala o verso un micro server locale, `WinMtSync` verso il cloud.

**I trigger del framework** (Q02) sono 3 per ognuna delle 40 tabelle e sono stati creati tutti il **04/02/2025**: la sincronizzazione è stata riprovisionata in quella data.

**Tombstone non ripulite.** Le tabelle di tracking sono più grandi delle tabelle che tracciano:

| Tabella | Righe | Righe in tracking | Differenza |
|---------|------:|------------------:|-----------:|
| Vincite | 108 | 116.112 | ≈ 116.000 |
| UID_Ammessi | 23.114 | 33.218 | ≈ 10.000 |

Le righe cancellate restano come metadati e la pulizia delle tombstone non viene eseguita. Per `Vincite` vuol dire che circa 116.000 consegne di premi sono state **cancellate** dalla tabella, probabilmente con "Pulizia Archivi" o "Cambio Gestione", e che lo storico delle consegne prima del 28/05/2026 non è più in questo database. Q12 mostra quando sono avvenute le cancellazioni.

---

## 3. Logica nei trigger (correzione di DB 01)

Oltre ai 120 trigger di sincronizzazione ci sono **5 trigger applicativi**, tutti sul circuito coinless:

| Tabella | Trigger | Evento | Stato | Ruolo presunto |
|---------|---------|--------|-------|----------------|
| `CoinlessDati` | `decodifica_flusso` | INSERT | attivo | Decodifica il flusso grezzo ricevuto dalle schede |
| `CoinlessDecodedData` | `inseriscesuECS` | INSERT | attivo (modificato 22/05/2025) | Scrive i contatori in `EcsDati` |
| `CoinlessDecodedData` | `insertrecordWINMT` | INSTEAD OF INSERT | **disabilitato** | Versione precedente (circa 5.000 caratteri) |
| `CoinlessTransazioniCards` | `aggiornaCard` | INSERT | attivo | Aggiorna saldo e stato della card |
| `CoinlessClonedCards` | `bannaUtente` | INSERT | attivo | Mette in blacklist l'utente di una card clonata |

Il percorso della telemetria sembra quindi essere: schede → `CoinlessDati` → (trigger) → `CoinlessDecodedData` → (trigger) → `EcsDati`. **Una parte delle regole sui contatori e sulle card vive in questi trigger.** Il loro sorgente va letto: è il prossimo materiale da estrarre (§ 9).

---

## 4. Identità del cliente e della card

**La chiave "vera" del cliente è `IdContatto`, non `IdLong`.** In `Clienti` la chiave primaria è `IdLong`, ma tutte le tabelle figlie riferiscono `IdContatto` (univoco, 6.131 valori su 6.131) con orfani quasi nulli. Verso `IdLong` gli orfani sono invece il 100%.

**Orfani minori:**
- 18 righe di `Tickets` (6 clienti), probabilmente clienti cancellati senza propagare la cancellazione;
- 2 righe di `LogTransazioniTotem`.

**L'identificativo della card in `TransCard.IdCli` non corrisponde né a `CoinlessCards.cardid` né a `Clienti.CodBar`** (100% di orfani). Era stata avanzata l'ipotesi che l'UID della card stesse in `Clienti.T0`, ma **Q13 l'ha smentita** (vedi DB 04, § 4).

**`Clienti.CodBar` non è univoco**: 4.218 valori distinti su 6.131 righe, quindi ci sono duplicati o valori vuoti. Il barcode non può fare da identificativo.

`UID_Ammessi` (23.000 UID) è quasi tutto "scorta" non associata a clienti, come ci si aspetta da un lotto di card pre-generate.

---

## 5. Integrità di fatto

| Relazione | Esito | Lettura |
|-----------|-------|---------|
| `TransCard.CodMac` → `EcsMacchine` | 17.892 orfani su 19.901 (57 codici) | `CodMac` in `TransCard` contiene anche altro (cassa, totem?) oppure macchine rimosse. Q15 lo chiarisce |
| `CoinlessTransazioniCards.CodMac` → `EcsMacchine` | 765 orfani (8 codici) | Macchine dismesse cancellate: lo storico perde il riferimento |
| `TransCard.Operatore` → `Operatori` | 5.468 orfani (12 id) | Operatori cancellati, o id provenienti da altre postazioni o da HQ |
| `EcsMacchine.Propr` → `Owners` | 40 su 40 orfani; `Owners` è vuota | Il proprietario della macchina, essenziale per il noleggio, è testo libero (2 valori). La tabella `Owners` non è usata |
| Storico premi → `Premi` | Orfani in Vincite (11), MovOut (6), Prenotaz (4 su 5), PrizeHub (3), GruMovimenti (18 su 18) | Articoli cancellati o ricodificati (il manuale prevede "Modifica Codice Premi"). I premi delle gru usano un catalogo proprio |
| Fornitori, Gru → `EcsMacchine`, `EcsDati` → `EcsMacchine` | Nessun orfano | Coerenti |

> **Indicazione per il nuovo disegno.** Anagrafiche referenziate dallo storico (articoli, macchine, operatori) non si cancellano: si **disattivano**. I codici non si modificano: si usa un identificativo interno stabile e un codice esterno modificabile.

---

## 6. Numero impianto (`NImp`)

`NImp` **non** è un discriminante di impianto affidabile:
- in `Clienti`, `Tickets` e `Operatori` assume i valori **146** e **9997**, più 0 in `Tickets`;
- in `EcsDati` vale sempre 1;
- in `TransCard` va da 0 a 20, quindi lì ha un significato diverso, forse la postazione o il dispositivo.

Il valore 9997 compare in quasi tutte le anagrafiche e sembra un valore convenzionale (default, "creato da HQ", impianto di test?).

> **Domanda.** Cosa significano 146 e 9997, e cosa significa `NImp` in `TransCard`?

---

## 7. Campi jolly: dove portano significato

Nella maggior parte delle tabelle sono **vuoti**. Ma nelle tabelle centrali contengono dati veri:

| Tabella | Campo | Uso osservato | Ipotesi |
|---------|-------|---------------|---------|
| `Clienti` | `T0` | 4.245 valori, quasi tutti distinti, lunghezza ≤ 16 | Non è l'UID della card (smentito da Q13); da chiarire |
| `Clienti` | `N0` | Valorizzato su tutte le righe, 3 valori | Non è il livello card (il livello sembra essere `TipoCard`, vedi DB 04, § 5) |
| `Clienti` | `F1`, `T1`, `D1` | Circa 200 righe | Da chiarire |
| `Tickets` | `F1` + `T1` | Insieme su circa 83.800 righe (45%), 61 valori di `T1` | Origine del ticket (dispositivo, ticketless?) |
| `TransCard` | `N0` | Sempre valorizzato, 908 valori | Contatore di transazione della card (anti-replay; cfr. `CoinlessCards.UltimoN0NonConfermato`) |
| `TransCard` | `D0` | 17.763 righe ma solo 58 date distinte | Data di elaborazione a lotti (consolidamento, sync?) |
| `CoinlessTransazioniCards` | `N0` | 402 valori | Come `TransCard.N0` |
| `Setup` | `F0…F9`, `N0…N9`, `T0…T9` | Sparsi | Opzioni di configurazione aggiunte nel tempo |

> **Conseguenza.** Questi campi non si possono ignorare nella migrazione: per decodificarli serve il codice sorgente di WinMT e del servizio.

---

## 8. Qualità dei dati, pagamenti, credenziali

**Date anomale:**
- `CoinlessTransazioniCards.DataMovimento` arriva al **2056**: un orologio di dispositivo errato;
- `Clienti.Nascita` va da 1900-01-01 (segnaposto) al 2026;
- `1899-12-30`, la "data zero" di VB6/Access, compare in `Tickets.DataOut` e in `Setup`;
- `2001-01-01` è usato come "non impostato" in `Setup`.

Nel nuovo sistema le date mancanti devono essere `NULL`, e i timestamp provenienti dai dispositivi vanno validati all'ingresso.

**PAN** (Q07). **Nessun PAN in chiaro**: zero valori composti da 13–19 cifre. Restano però 335 valori in `LogTransazioniPos` e 63 in `LogTransazioniTotem` che non sono né cifre pure né mascherati con `*`, `X` o `#`. Potrebbero essere le ultime 4 cifre o un altro formato; Q14 ne mostra la struttura.

**Password** (Q09). **Nessuna ha l'aspetto di un hash**:
- in `Clienti` ci sono 780 password, con lunghezza 0–10 e solo 84 valori distinti;
- in `Operatori`, su 18 password ci sono solo 2 valori distinti, probabilmente in buona parte vuote;
- `Setup` ne contiene altre quattro.

Le password sono quindi in chiaro, o al più offuscate in modo reversibile. Nessuna coincide con quelle iniziali del manuale.

**Frammentazione** (Q10). La copia è stata ripristinata da un file `.bak`, quindi il layout fisico delle pagine è quello di produzione al momento del backup e i valori sono rappresentativi. Molto alta (83–99%) su EcsDati, TicketsCan, TransCard, Vincite_tracking e UID_Ammessi, ma anche su `Clienti`, che ha chiave `bigint`, quindi `IdLong` non è progressivo. Fa eccezione `Tickets` (14%), forse ricostruita da una manutenzione. L'ipotesi GUID → frammentazione è confermata nella tendenza. Su volumi così piccoli, però, l'impatto in questa sala è modesto.

**Indici sproporzionati.** `TransCard` ha 25 indici: 38 MB di indici contro 3,7 MB di dati. `Tickets` ha 102 MB di indici contro 24 MB di dati. Sono il segno di indici aggiunti per singoli report senza revisione. Rallentano le scritture e la sincronizzazione.

**Log.** `ecl_log` (circa 300.000 righe da giugno 2025, circa 1.000 al giorno) e `CoinlessDecodedData` crescono senza un limite visibile. Insieme al limite di 10 GB di SQL Server Express, serve una politica di conservazione.

---

## 9. Prossimi passi

1. **Sorgenti dei 5 trigger applicativi** (§ 3). In SSMS: *Esplora oggetti → tabella → Trigger → tasto destro → Crea script per trigger → CREATE in → File*. Bastano i quattro attivi; quello disabilitato è utile solo per confronto.
2. **Kit di query 02** (Q11–Q17): elenco completo degli scope, tombstone, ipotesi sull'UID card, forma dei PAN "altro", codici orfani di `TransCard`, postazioni di `Setup`, livelli card.
3. **Domande per il team:** destinazione dei due scope; significato di `NImp` (146, 9997); quale installazione ha superato i 2 milioni di record; quando e perché è stato svuotato lo storico di `Vincite`.
