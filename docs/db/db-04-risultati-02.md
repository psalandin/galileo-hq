# Galileo HQ — DB 04: risultati del kit di query 02

**Stato:** bozza · **Responsabile:** Piero · **Aggiornato:** 2026-10-18

**Fonte:** copia locale di `[WinMtSqlDB]` da `.bak`, query Q11–Q17 · **Collegati:** `db-03-risultati-01.md` (le correzioni sono segnalate qui), `db-query-03.sql`


> **Nota del 20/10/2026:** il database analizzato è stato confermato come **database di test**, non di produzione. Le osservazioni sullo schema restano valide; volumi, date e statistiche vanno riverificati sul database di produzione (6–7 GB) e su quello di HQ, attesi a breve.

> **Nota del 22/10/2026:** alcune conclusioni di questo documento sono corrette da `db-06-produzione-02.md` (cancellazioni massive, `Clienti.T0`, livelli card): erano artefatti del database di test.
---

## 1. Il database non è solo di produzione

`Setup` (Q16) elenca **25 postazioni**:
- una sola è `Master`: `WINMTSQL`, con `CodEcs = ECL`;
- molte sono chiaramente di **sviluppo e test**: `TOBY-DEV-VM`, `GEANINA-DESKTOP`, `TOTEM-ECL-LAB`, `kiosk-repro-test`, `localhost`, `i9lenovofab` e quattro postazioni `NON-ESISTE-*`.

Anche `TransCard` (Q15) contiene movimenti generati da postazioni di sviluppo (`TOBY-DEV-VM`, `TOBY`, `micrototem_dev`, `TOTEM-ECL-LAB`) mescolati a quelli di cassa e totem.

> **Conseguenza.** Il team sviluppa e prova *contro* il database di questa sala, oppure questa è la sala-laboratorio di Elmac (Rubano?). In entrambi i casi:
> - le statistiche sono in parte contaminate da dati di prova;
> - nel nuovo sistema servono ambienti separati e un modo per marcare i dati di test.
>
> **Domanda:** di quale sala si tratta, e quali postazioni sono reali?

Altri dettagli emersi da `Setup`:
- `MName` ha sempre un `|` finale, un artefatto di formato;
- le date `DataIni` e `DataEnd` (2021–2023) sono scadute ovunque: probabilmente non hanno più effetto;
- l'ultima sincronizzazione `LocalSync` riuscita registrata dal Master risale all'**11/12/2024**, e una postazione segnala un fallimento il 13/05/2026.

---

## 2. Sincronizzazione

I due scope (Q11), `LocalSync` e `WinMtSync`, contengono **esattamente le stesse 40 tabelle**, senza filtri. Sono quindi due *peer* che ricevono tutto.

**Le cancellazioni avvengono a ondate** (Q12), e Sync Framework le propaga ai peer:

| Quando | Cosa | Righe |
|--------|------|------:|
| **22/05/2026 16:35** (stesso minuto) | Vincite, Resi, Prenotaz, MovMag | ≈ 116.000 |
| 10/11/2025 17:12 | MovMag, MovOut, Premi | ≈ 6.000 (fino a luglio 2026) |
| 05/02/2025 → in corso | EcsDati (contatori) | ≈ 15.200 |
| 05/02/2025 → in corso | TransCard (movimenti card) | ≈ 9.400 |
| 05/06/2026 | Operatori | 20 |

Il 22/05/2026 è stato **azzerato lo storico di premi e magazzino**, e i nuovi movimenti partono pochi minuti dopo (`MovMag` dal 22/05/2026 16:40). È compatibile con un "Cambio Gestione" o una "Pulizia Archivi".

> **Conseguenze.**
> 1. Le cancellazioni si propagano: anche **il cloud perde lo storico**, a meno che non venga archiviato altrove. Questo riguarda direttamente il requisito di migrazione "non perdere le transazioni".
> 2. La cancellazione progressiva di **movimenti card** (`TransCard`) e **contatori** (`EcsDati`) va spiegata. Si tratta di dati economici: il consolidamento di aprile 2026 (`TransCard_Consolidamento_*`) può spiegarne una parte, ma non tutta.

---

## 3. `TransCard.CodMac`: un campo con due significati

Q15 chiarisce gli "orfani" di Q05:
- **con `WinMt = 1`** contiene il **nome della postazione** che ha eseguito l'operazione: `WINMTSQL` (12.787 righe), `CASSA1`, `micrototem`, i vari `TOTEM-ECL-*`, `CLOUD`, `ECL-SERVICE`, `prizehub-reloaded`;
- **con `WinMt = 0`** contiene il **codice del gioco** (`006ExtremeHDX`, `018PacManSmash`, ecc.). Sono giochi non più presenti in `EcsMacchine`: **le macchine dismesse vengono cancellate** e lo storico resta senza anagrafica.

Q19 verifica la corrispondenza con `Setup.MName` una volta tolto il `|`.

Molte postazioni hanno l'ultimo movimento esattamente il **16/06/2026 alle 10:42**, e diverse altre il **13/04/2025 alle 05:59:59**. Sono timestamp "di lotto", probabilmente prodotti da operazioni massive come la chiusura delle sessioni di cassa o il consolidamento (`sp_consolida_transcard_sessioni_cash`).

**Operatori cancellati.** I movimenti degli operatori 10, 12, 11 e 7 (circa 5.400 righe tra il 2021 e il 2026) puntano a operatori non più presenti, cancellati il 05/06/2026. Lo storico perde chi ha eseguito l'operazione: per una cassa è un problema di tracciabilità.

---

## 4. Identificativo della card: ipotesi `Clienti.T0` smentita

Q13 smentisce l'ipotesi formulata in DB 03 (§ 4, § 7): `Clienti.T0` **non** contiene l'UID della card, e lo stesso vale per `UID_Ammessi.UID`. Ci sono quindi due risultati:
- `CoinlessCards.cardid` è coerente con `CoinlessTransazioniCards.cardid` (solo 123 orfani su 2.399) ed è collegato al cliente tramite `CoinlessCards.IdContatto`, senza orfani. **Il collegamento card → cliente passa per `CoinlessCards`.**
- `TransCard.IdCli` (5.493 valori distinti) non corrisponde ancora a nulla.

**Risolto con Q19:** `TransCard.IdCli` è **l'`IdContatto` del cliente scritto come testo**. Corrisponde in 19.837 righe su 19.895 (99,7%). È lo stesso dato con un tipo diverso: `varchar(16)` contro `bigint`. Le 58 righe senza corrispondenza sono clienti cancellati.

Per le postazioni, invece, `TransCard.CodMac` (con `WinMt = 1`) corrisponde a `Setup.MName` solo in 406 righe su 17.896, anche togliendo il `|`. Il nome della postazione è testo libero e non c'è un collegamento affidabile all'anagrafica delle postazioni.

---

## 5. Livelli card

Q17 mostra che `Clienti.TipoCard` assume i valori 0, 1, 2, 3 e, una volta, 999. Il 12/10 era stata descritta questa codifica: 0 = Platinum, 1 = Gold, 2 = Silver, 3 = Compleanno, con 0 come default. Se `TipoCard` è il livello:

| TipoCard | Livello | Clienti circa | Quota |
|---------:|---------|--------------:|------:|
| 2 | Silver | 3.670 | 60% |
| 0 | Platinum | 2.365 | 39% |
| 1 | Gold | 39 | |
| 3 | Compleanno | 57 | |

**Il 39% dei clienti risulterebbe Platinum**, cioè il livello più alto. È il comportamento atteso se molte card restano al valore di default 0, come temuto in riunione.

> **Da verificare con il team:** `TipoCard` è il livello della card? Il Platinum ha davvero tariffe migliori, e queste card lo stanno usando?

`Clienti.N0` (valori 0, 1, 2) non segue lo stesso schema: il significato resta da chiarire.

---

## 6. Numeri di carta di pagamento

Q14 mostra che quasi tutti i valori hanno la forma corretta "prime 6 + ultime 4" (`999999******9999`) o sono mascherati del tutto. Ci sono però alcune anomalie:
- **in `LogTransazioniTotem`, 2 righe contenevano 16 o più cifre consecutive.** La verifica con Q20 ha dato esito negativo:
  - entrambe provengono dalla postazione di sviluppo `TOBY`;
  - la prima è una stringa esadecimale (codifica ASCII di un codice alfanumerico), non un PAN;
  - la seconda contiene 16 cifre che **non superano il controllo di Luhn**, quindi non sono un numero di carta valido. È verosimilmente un dato di prova.
- valori come `: AA` (48 righe) e `999A9A99` (47 righe) indicano che il campo viene ricavato **analizzando il testo della ricevuta POS**, e che l'analisi a volte cattura frammenti sbagliati.

> **Indicazione.** Nel nuovo sistema il dato di pagamento va preso dalla risposta strutturata del terminale, e mascherato prima di qualsiasi scrittura. Restano due difetti: il campo può ricevere testo arbitrario non mascherato, e i dati di prova finiscono nel database della sala.

---

## 7. Domande per il team (aggiornate)

1. Di quale sala è questo database, e perché contiene postazioni di sviluppo?
2. Chi sono i peer di `LocalSync` e di `WinMtSync`?
3. Cosa è successo il 22/05/2026 alle 16:35? Le cancellazioni progressive di `TransCard` ed `EcsDati` sono volute?
4. Lo storico cancellato è archiviato da qualche parte?
5. `TipoCard` è il livello della card? Il 39% di Platinum è reale?
6. Perché macchine e operatori vengono cancellati invece che disattivati?
