# Galileo HQ

Analisi per la riprogettazione di WinMT e del sistema HQ: gestione cloud di sale giochi con meccanica redemption, configurazione remota delle macchine di sala e gestione multisala.

**Fase attuale:** 1 — analisi. Il repository contiene soprattutto documenti; il codice arriverà con la fase 2.

## Struttura

| Cartella | Contenuto |
|----------|-----------|
| `docs/analisi/` | Documenti di analisi e di sintesi (`analisi-NN-…`) |
| `docs/db/` | Analisi del database esistente: schema, catalogo, risultati delle query |
| `docs/use-case/` | Un file per use case, a partire da `_modello-use-case.md` |
| `docs/riunioni/` | Verbali, sommari e trascrizioni delle riunioni |
| `docs/fonti/` | Materiale ricevuto e convertito in testo (es. manuale WinMT). Non si modifica |
| `sql/` | Script e kit di query riutilizzabili sui DB di sala e di HQ |

L'indice ragionato dei documenti è in [`docs/00-indice.md`](docs/00-indice.md).

## Convenzioni

- **Lingua:** italiano.
- **Formato:** Markdown. Word, PDF e simili solo come allegati ricevuti, in `docs/fonti/`.
- **Date nei nomi dei file:** `AAAA-MM-GG`, così l'ordine alfabetico coincide con quello cronologico (es. `2026-10-19_verbale-riunione-2.md`).
- **Intestazione dei documenti:** stato e responsabile in testa a ogni documento di lavoro, ad esempio
  `**Stato:** bozza · **Responsabile:** Piero · **Aggiornato:** 2026-10-22`.
  Stati: `bozza`, `in revisione`, `approvato`, `superato`.
- **Use case:** `UC-NNN-titolo-breve.md`, numerazione progressiva senza riuso dei numeri.

## Cosa non va nel repository

- Dump e backup dei database (`.bak`, `.bacpac`, `.mdf`…): troppo grandi e contengono dati reali.
- Sorgenti di terzi ricevuti (WinMT VB6, motore B4J, motore .NET): conservati a parte.
- Credenziali e stringhe di connessione: in file `.env` o `*.local.*`, esclusi da `.gitignore`.
- Audio delle riunioni: si versionano solo trascrizioni e verbali.

## Come lavoriamo

- Si lavora direttamente su `main`; prima di ogni push: `git pull --rebase`.
- Per far rivedere un documento si può aprire una pull request (merge, squash o rebase, a scelta di chi la apre).
- Le domande aperte per la committente o l'assistenza si tracciano come **Issue**.

## Responsabilità

| Ambito / use case | Responsabile |
|-------------------|--------------|
| Documento di analisi complessivo | Piero |
| _da definire_ | |
