/* =====================================================================
   Galileo HQ — Kit di query 02 su [WinMtSqlDB] (copia locale)
   ---------------------------------------------------------------------
   Query mirate, derivate dai risultati del kit 01 (vedi
   db-03-risultati-01.md). Solo lettura e solo aggregati: codici
   macchina e operatore compaiono come valori perché non sono dati
   personali.
   Salvataggio: come per il kit 01, in .txt delimitato da tabulazioni.
   ===================================================================== */

USE [WinMtSqlDBNuovo];
SET NOCOUNT ON;
GO

/* ---------------------------------------------------------------------
   Q11 — Elenco completo delle tabelle per ciascuno scope di sync
   (in Q03 l'XML era troncato a 65535 caratteri)
   --------------------------------------------------------------------- */
SELECT si.sync_scope_name                                         AS scope,
       a.n.value('@Name', 'nvarchar(200)')                        AS tabella,
       a.n.value('count(Col)', 'int')                             AS n_colonne,
       a.n.value('@FilterClause', 'nvarchar(max)')                AS filtro_attr,
       a.n.value('(FilterClause/text())[1]', 'nvarchar(max)')     AS filtro_elem,
       a.n.value('count(FilterParam)', 'int')                     AS n_filter_param
FROM dbo.scope_info si
JOIN dbo.scope_config sc ON sc.config_id = si.scope_config_id
CROSS APPLY sc.config_data.nodes('/SqlSyncProviderScopeConfiguration/Adapter') a(n)
ORDER BY scope, tabella;
GO

/* ---------------------------------------------------------------------
   Q12 — Tombstone nelle tabelle di tracking
   Righe cancellate di cui il framework conserva i metadati, con il
   periodo in cui sono avvenute le cancellazioni.
   --------------------------------------------------------------------- */
IF OBJECT_ID('tempdb..#tomb') IS NOT NULL DROP TABLE #tomb;
CREATE TABLE #tomb (tabella_tracking sysname, righe bigint, tombstone bigint,
                    prima_cancellazione datetime NULL, ultima_cancellazione datetime NULL);
DECLARE @t sysname, @sql nvarchar(max);
DECLARE c CURSOR LOCAL FAST_FORWARD FOR
    SELECT name FROM sys.tables WHERE name LIKE '%[_]tracking';
OPEN c; FETCH NEXT FROM c INTO @t;
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = N'INSERT #tomb SELECT ' + QUOTENAME(@t,'''') + N', COUNT_BIG(*),
                 SUM(CASE WHEN sync_row_is_tombstone = 1 THEN 1 ELSE 0 END),
                 MIN(CASE WHEN sync_row_is_tombstone = 1 THEN last_change_datetime END),
                 MAX(CASE WHEN sync_row_is_tombstone = 1 THEN last_change_datetime END)
                 FROM dbo.' + QUOTENAME(@t) + N';';
    EXEC (@sql);
    FETCH NEXT FROM c INTO @t;
END
CLOSE c; DEALLOCATE c;
SELECT * FROM #tomb ORDER BY tombstone DESC;
GO

/* ---------------------------------------------------------------------
   Q13 — Identificativo della card: nuove ipotesi di relazione
   Clienti.T0 (varchar 16, quasi univoco) potrebbe contenere l'UID RFID.
   Stessa logica di Q05.
   --------------------------------------------------------------------- */
IF OBJECT_ID('tempdb..#rel') IS NOT NULL DROP TABLE #rel;
CREATE TABLE #rel (figlio sysname, col_figlio sysname, padre sysname, col_padre sysname,
                   righe_figlio bigint, nonnull_figlio bigint, orfani bigint, orfani_distinti bigint,
                   righe_padre bigint, distinti_padre bigint, errore nvarchar(4000));
INSERT #rel (figlio, col_figlio, padre, col_padre) VALUES
 ('TransCard','IdCli','Clienti','T0'),
 ('CoinlessCards','cardid','Clienti','T0'),
 ('CoinlessTransazioniCards','cardid','Clienti','T0'),
 ('UID_Ammessi','UID','Clienti','T0'),
 ('TransCard','IdCli','UID_Ammessi','UID'),
 ('CoinlessCards','cardid','UID_Ammessi','UID'),
 ('CoinlessClonedCards','cardid','Clienti','T0'),
 ('LogTransazioniPos','IdCli','Clienti','IdContatto'),
 ('TransCard','CodMac','Setup','MName');

DECLARE @f sysname, @cf sysname, @p sysname, @cp sysname, @q nvarchar(max),
        @r bigint, @nn bigint, @o bigint, @od bigint, @pr bigint, @pd bigint;
DECLARE k CURSOR LOCAL FAST_FORWARD FOR SELECT figlio, col_figlio, padre, col_padre FROM #rel;
OPEN k; FETCH NEXT FROM k INTO @f, @cf, @p, @cp;
WHILE @@FETCH_STATUS = 0
BEGIN
    BEGIN TRY
        SET @q = N'SELECT @r = COUNT_BIG(*), @nn = COUNT_BIG(c.' + QUOTENAME(@cf) + N') FROM dbo.' + QUOTENAME(@f) + N' c;
                   SELECT @o = COUNT_BIG(*), @od = COUNT_BIG(DISTINCT c.' + QUOTENAME(@cf) + N') FROM dbo.' + QUOTENAME(@f) + N' c
                   WHERE c.' + QUOTENAME(@cf) + N' IS NOT NULL
                     AND NOT EXISTS (SELECT 1 FROM dbo.' + QUOTENAME(@p) + N' p WHERE p.' + QUOTENAME(@cp) + N' = c.' + QUOTENAME(@cf) + N');
                   SELECT @pr = COUNT_BIG(*), @pd = COUNT_BIG(DISTINCT p.' + QUOTENAME(@cp) + N') FROM dbo.' + QUOTENAME(@p) + N' p;';
        EXEC sp_executesql @q, N'@r bigint OUTPUT, @nn bigint OUTPUT, @o bigint OUTPUT, @od bigint OUTPUT, @pr bigint OUTPUT, @pd bigint OUTPUT',
             @r OUTPUT, @nn OUTPUT, @o OUTPUT, @od OUTPUT, @pr OUTPUT, @pd OUTPUT;
        UPDATE #rel SET righe_figlio = @r, nonnull_figlio = @nn, orfani = @o, orfani_distinti = @od, righe_padre = @pr, distinti_padre = @pd
        WHERE figlio = @f AND col_figlio = @cf AND padre = @p AND col_padre = @cp;
    END TRY
    BEGIN CATCH
        UPDATE #rel SET errore = ERROR_MESSAGE()
        WHERE figlio = @f AND col_figlio = @cf AND padre = @p AND col_padre = @cp;
    END CATCH
    FETCH NEXT FROM k INTO @f, @cf, @p, @cp;
END
CLOSE k; DEALLOCATE k;
SELECT * FROM #rel;
GO

/* ---------------------------------------------------------------------
   Q14 — Forma dei valori PAN classificati come "altro" in Q07
   Le cifre diventano 9 e le lettere A: si vede la struttura (es.
   999999******9999), mai il valore.
   --------------------------------------------------------------------- */
WITH v AS (
    SELECT 'LogTransazioniPos' AS tabella, CONVERT(nvarchar(100), PAN) AS x FROM dbo.LogTransazioniPos
    UNION ALL SELECT 'LogTransazioniTotem', CONVERT(nvarchar(100), PAN) FROM dbo.LogTransazioniTotem
    UNION ALL SELECT 'pos_transaction', CONVERT(nvarchar(100), masked_pan) FROM dbo.pos_transaction
)
SELECT tabella,
       TRANSLATE(UPPER(x), N'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ', N'9999999999AAAAAAAAAAAAAAAAAAAAAAAAAA') AS forma,
       LEN(x) AS lunghezza,
       COUNT_BIG(*) AS righe
FROM v
WHERE x IS NOT NULL
GROUP BY tabella, TRANSLATE(UPPER(x), N'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ', N'9999999999AAAAAAAAAAAAAAAAAAAAAAAAAA'), LEN(x)
ORDER BY tabella, righe DESC;
GO

/* ---------------------------------------------------------------------
   Q15 — TransCard: codici macchina e operatori non trovati (da Q05)
   --------------------------------------------------------------------- */
SELECT 'CodMac' AS tipo, c.CodMac AS valore, c.WinMt, COUNT_BIG(*) AS righe, MIN(c.Data) AS dal, MAX(c.Data) AS al
FROM dbo.TransCard c
WHERE c.CodMac IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.EcsMacchine m WHERE m.CodMac = c.CodMac)
GROUP BY c.CodMac, c.WinMt
UNION ALL
SELECT 'Operatore', CONVERT(varchar(50), c.Operatore), c.WinMt, COUNT_BIG(*), MIN(c.Data), MAX(c.Data)
FROM dbo.TransCard c
WHERE c.Operatore IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Operatori o WHERE o.Id = c.Operatore)
GROUP BY c.Operatore, c.WinMt
ORDER BY tipo, righe DESC;
GO

/* ---------------------------------------------------------------------
   Q16 — Postazioni configurate (Setup), senza password
   --------------------------------------------------------------------- */
SELECT IDPost, MName, NImp, Master, MultiUser, SyncEn, SyncRes, CodEcs, Lang,
       NomeLocale, CittaLocale, DataIni, DataEnd, Easys, Ab4Usr
FROM dbo.Setup
ORDER BY IDPost;
GO

/* ---------------------------------------------------------------------
   Q17 — Livelli e tipi di card dei clienti (Clienti.N0 e TipoCard)
   Serve a capire dove sta il livello Silver/Platinum/Gold/Compleanno.
   --------------------------------------------------------------------- */
SELECT N0, TipoCard, F0, F1, COUNT_BIG(*) AS clienti
FROM dbo.Clienti
GROUP BY N0, TipoCard, F0, F1
ORDER BY clienti DESC;
GO
