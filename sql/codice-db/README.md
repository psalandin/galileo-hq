# Codice SQL dei database di sala

**Stato:** bozza · **Responsabile:** Piero · **Aggiornato:** 2026-10-23

Codice di stored procedure, funzioni, viste e trigger estratto da `sys.sql_modules` dei due database analizzati in DB 07. È stato scritto dal team, soprattutto da Fabrizio: fa parte della struttura del sistema attuale e si versiona qui come riferimento per l'analisi. **Non è codice del nuovo sistema.**

| Cartella | Database | Note |
|----------|----------|------|
| `test/` | `WinMtSqlDB` | Database di test, estratto il 23/10/2026 |
| `prod/` | `WinMtSqlDBProd` | Produzione Central Park Rimini, copia del 14/07/2026, ricostruita il 03/06/2026 |

In ciascuna cartella il codice è diviso in due gruppi:

- **`applicativo/`**: la logica scritta a mano, organizzata in `procedure/`, `funzioni/`, `viste/` e `trigger/`. È la parte da leggere.
- **`sync-framework/`**: oggetti **generati** da Microsoft Sync Framework per ogni tabella sincronizzata. Sono 11 procedure (`<tabella>_selectchanges`, `_insert`, `_bulkupdate`, …) e 3 trigger (`<tabella>_insert_trigger`, …) per tabella. Non contengono regole di dominio. Servono solo a vedere quali colonne vengono sincronizzate e se le procedure sono allineate allo schema (DB 07, § 4.2).

Conteggi:

| | Test | Produzione |
|---|---:|---:|
| Procedure applicative | 26 | 21 |
| Funzioni | 25 | 25 |
| Viste | 14 | 14 |
| Trigger applicativi | 5 | 5 |
| Procedure Sync Framework | 440 (40 tabelle) | 671 (61 tabelle) |
| Trigger Sync Framework | 120 | 183 |

## Note

- **Un file per oggetto**, con il nome dell'oggetto (lo schema è sempre `dbo`). Il testo è quello restituito da SQL Server, con fine riga normalizzati: un `CREATE`, non uno script di deploy.
- **Codifica della produzione.** In `prod/` le lettere accentate sono corrotte (`giÃ ` invece di `già`): è un difetto del database, non dell'estrazione (DB 07, § 6.3).
- **Segreti rimossi.** `fn_calcHMAC` concatena al messaggio una chiave segreta scritta nel codice. In questa copia la chiave è sostituita da un segnaposto.
- **Confronto tra i due rami:** `git diff --no-index sql/codice-db/test/applicativo sql/codice-db/prod/applicativo`.
- **Per rigenerare** il contenuto: `sql/queries/db-query-04-struttura.sql` per il catalogo, oppure un'esportazione di `sys.sql_modules` con `sql/esegui-query.ps1`. Prima di versionarlo, ripetere il controllo sui segreti.
