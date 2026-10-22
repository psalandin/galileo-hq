# Galileo HQ — Indice dei documenti di lavoro

**Stato:** bozza · **Responsabile:** Piero · **Aggiornato:** 2026-10-23

**Fase:** 0 (pre-analisi), in chiusura

## Analisi

| File | Contenuto | Stato |
|------|-----------|-------|
| [`analisi/analisi-00-prima-lettura.md`](analisi/analisi-00-prima-lettura.md) | Prima lettura di manuale e riunioni del 07/10 e 12/10: zone, architettura attuale, glossario, problemi, domande | Da aggiornare con la riunione del 19/10 |

## Database

| File | Contenuto | Stato |
|------|-----------|-------|
| [`db/db-01-schema.md`](db/db-01-schema.md) | Analisi dello schema del DB di sala | Basato su DB di **test** |
| [`db/db-02-catalogo.md`](db/db-02-catalogo.md) | Catalogo di tabelle e colonne | Basato su DB di **test** |
| [`db/db-03-risultati-01.md`](db/db-03-risultati-01.md) | Risultati delle query Q01–Q10 | Basato su DB di **test** |
| [`db/db-04-risultati-02.md`](db/db-04-risultati-02.md) | Risultati delle query Q11–Q20 | Basato su DB di **test** |
| [`db/db-05-produzione-01.md`](db/db-05-produzione-01.md) | DB di **produzione** (copia del 14/07/2026): Q01–Q10, volumi e crescita | In corso |
| [`db/db-06-produzione-02.md`](db/db-06-produzione-02.md) | DB di **produzione**: Q11–Q17, postazioni della sala (Central Park, Rimini), identificativi card, livelli; correzioni a DB 04 | In corso |
| [`db/db-07-confronto-test-produzione.md`](db/db-07-confronto-test-produzione.md) | Confronto della **struttura** tra test e produzione: perimetro di sync, codice divergente, nomi di DB fissi nel codice, indici, dizionario `Setup_Descriptions` | In corso |

## Riunioni

| Data | File | Note |
|------|------|------|
| 07/10 | [`trascrizione`](riunioni/2026-10-07_riunione_trascrizione.txt), [`sommario`](riunioni/2026-10-07_riunione_sommario.md) | Riunione esplorativa; sommario Plaud |
| 12/10 | [`trascrizione`](riunioni/2026-10-12_riunione_trascrizione.txt) | Riunione operativa |
| 19/10 | [`traccia`](riunioni/2026-10-19_riunione_traccia.md), [`trascrizione`](riunioni/2026-10-19_riunione_trascrizione.txt), [`riassunto`](riunioni/2026-10-19_riunione_riassunto.md), [`riassunto originale`](riunioni/2026-10-19_riunione_riassunto.txt) | Traccia preparata per la riunione (copia del Claude Doc); riassunto Plaud, rivisto (`.md`) e così come esportato, senza nomi (`.txt`). Trascrizione Whisper C++ attesa |

## Fonti

| File | Contenuto | Stato |
|------|-----------|-------|
| [`fonti/winmt-manuale.md`](fonti/winmt-manuale.md) | Testo integrale del manuale WinMtSql | Stabile |

## Kit di query (nel repository, non in KB)

In [`../sql/queries/`](../sql/queries/): `db-query-01.sql`, `-02.sql`, `-03.sql` e le versioni `-prod`, riutilizzabili anche sul DB di HQ. `db-query-04-struttura.sql` estrae il catalogo completo della struttura di un database, per confrontare sale diverse, test e produzione, sala e HQ. I risultati sono in [`../sql/risultati/`](../sql/risultati/).

[`../sql/codice-db/`](../sql/codice-db/) contiene il codice SQL di procedure, funzioni, viste e trigger dei DB di test e di produzione. Quello applicativo è separato da quello generato da Sync Framework (vedi il README della cartella).

[`../sql/esegui-query.ps1`](../sql/esegui-query.ps1) esegue i kit da PowerShell senza SSMS. Legge server e credenziali dal file `.env` nella radice del repository, escluso da git.

## Materiale ricevuto il 19/10, da analizzare

- Documentazione varia, non esaustiva
- Codice sorgente di WinMT (VB6)
- Codice sorgente del motore di sala in B4J

## Materiale atteso

- Codice di un motore .NET (ruolo da chiarire)
- DB di produzione di HQ (cloud). Il DB di produzione della sala (`WinMtSqlDBNuovo`, 6,9 GB) è stato ricevuto
- Trascrizione Whisper C++ della riunione del 19/10

## Fatti stabiliti

- Il primo DB analizzato (DB 01–04) è di **test**. Il DB di produzione (DB 05–06) è della salagiochi Central Park di Rimini, copia del 14/07/2026, usata in sola lettura come campione.
- I server di sala in produzione non sono SQL Server Express.
- Fase 1: modello dati logico, flussi censiti e pesati, architettura definita, stima della fase 2 con variabilità fino al ±30%, due riunioni di revisione.
- Fuori perimetro: firmware dei dispositivi. La comunicazione tra dispositivi e server di sala è affidata alla BE.
- Cassa e totem saranno riscritti, probabilmente in Flutter, su API Laravel.
