# Galileo HQ — Indice dei documenti di lavoro

**Aggiornato:** 20/10/2026 · **Fase:** 0 (pre-analisi), in chiusura

## Documenti di sintesi

| File | Contenuto | Stato |
|------|-----------|-------|
| `galileo-analisi-00-prima-lettura.md` | Prima lettura di manuale e riunioni del 07/10 e 12/10: zone, architettura attuale, glossario, problemi, domande | Da aggiornare con la riunione del 19/10 |
| `winmt-manuale.md` | Testo integrale del manuale WinMtSql | Stabile |
| `galileo-db-01-schema.md` | Analisi dello schema del DB di sala | Basato su DB di **test** |
| `galileo-db-02-catalogo.md` | Catalogo di tabelle e colonne | Basato su DB di **test** |
| `galileo-db-03-risultati-01.md` | Risultati delle query Q01–Q10 | Basato su DB di **test** |
| `galileo-db-04-risultati-02.md` | Risultati delle query Q11–Q20 | Basato su DB di **test** |
| Traccia riunione 19/10 (Claude Doc, copia su Google Drive) | Domande e schema di stima della fase 1 | Usata il 19/10 |

## Fonti primarie

- Trascrizioni delle riunioni del 07/10 (con sommario Plaud) e del 12/10
- Riunione del 19/10: trascrizione e riassunto Plaud; trascrizione Whisper C++ attesa

## Kit di query (nel repository, non in KB)

`galileo-db-query-01.sql`, `-02.sql`, `-03.sql`: riutilizzabili sul DB di produzione e su quello di HQ.

## Materiale ricevuto il 19/10, da analizzare

- Documentazione varia, non esaustiva
- Codice sorgente di WinMT (VB6)
- Codice sorgente del motore di sala in B4J

## Materiale atteso

- Codice di un motore .NET (ruolo da chiarire)
- DB di produzione di una sala (6–7 GB) e DB di produzione di HQ (cloud)
- Trascrizione Whisper C++ della riunione del 19/10

## Fatti stabiliti

- Il DB analizzato finora è di test.
- Fase 1: modello dati logico, flussi censiti e pesati, architettura definita, stima della fase 2 con variabilità fino al ±30%, due riunioni di revisione.
- Fuori perimetro: firmware dei dispositivi. La comunicazione tra dispositivi e server di sala è affidata alla BE.
- Cassa e totem saranno riscritti, probabilmente in Flutter, su API Laravel.
