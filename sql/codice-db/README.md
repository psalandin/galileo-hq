# Codice SQL dei database di sala

**Stato:** bozza · **Responsabile:** Piero · **Aggiornato:** 2026-10-27

Codice di stored procedure, funzioni, viste e trigger estratto da `sys.sql_modules` dei database analizzati (DB 07, DB 09). È stato scritto dal team, soprattutto da Fabrizio: fa parte della struttura del sistema attuale e si versiona qui come riferimento per l'analisi. **Non è codice del nuovo sistema.**

| Cartella | Database | Note |
|----------|----------|------|
| `test/` | `WinMtSqlDB` | Database di test, estratto il 23/10/2026 |
| `prod/` | `WinMtSqlDBProd` | Produzione Central Park Rimini, copia del 14/07/2026, ricostruita il 03/06/2026 |
$1| `winmtprov/` | Script di riferimento | Script distribuiti con WinMtProv 1.12 (build `Release`, file fino al 03/06/2026) per creare i DB `WinMtSqlDB`, `CoinlessDB` e `MultiLocaleDB` (sync 03). Struttura diversa dalle altre cartelle: una sottocartella per database, poi `Tabelle`, `Funzioni`, `Procedure`, `Viste`, `Triggers`, `Migration`, come nell'originale. Contiene anche le `CREATE TABLE` |

Gli script Navicat esportati dal cloud (`clitest.dbo.sql`, `dbo.sql` di `GloboGameRemSrvc`, `Locali.sql` di `ElmacRemSrvc`) stanno nella radice della cartella e **sono esclusi da git** (`.gitignore`): contengono anche dati, in parte personali. Si versiona solo il codice estratto.

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
$1 In `winmtprov/` sono sostituite anche la chiave delle due copie di `fn_calcHMAC` e la password del linked server in `collegamentoserver.sql`.
- **Confronto tra i due rami:** `git diff --no-index sql/codice-db/test/applicativo sql/codice-db/prod/applicativo`.
- **Caricare uno script Navicat** sull'istanza di analisi richiede due accorgimenti: `SET DATEFORMAT ymd` prima delle `INSERT` (il login ha lingua italiana) e la rimozione dalle `INSERT` delle colonne di tipo `timestamp` (`scope_info.scope_timestamp`, `<tabella>_tracking.local_update_peer_timestamp`), che SQL Server non accetta.
- **Per rigenerare** il contenuto: `sql/queries/db-query-04-struttura.sql` per il catalogo, oppure un'esportazione di `sys.sql_modules` con `sql/esegui-query.ps1`. Prima di versionarlo, ripetere il controllo sui segreti.
