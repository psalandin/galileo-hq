/* =====================================================================
   Galileo HQ — Kit di query 01 sul database di sala [WinMtSqlDB]
   ---------------------------------------------------------------------
   Tutte le query sono di SOLA LETTURA e restituiscono solo dati
   aggregati: conteggi, lunghezze, date minime e massime. Nessuna query
   restituisce dati personali, password o numeri di carta.

   ESECUZIONE
   - In SSMS, una sezione alla volta (Q01 ... Q10). Ogni sezione produce
     un solo result set.
   - Salvataggio: tasto destro sulla griglia > "Salva risultati con nome"
     > CSV, con nome Q01.csv, Q02.csv, ... Q10.csv
   - Isolamento SNAPSHOT (già abilitato sul DB): le letture non bloccano
     le scritture della sala. Conviene comunque evitare le ore di
     apertura, perché alcune query scandiscono tabelle intere.

   PERMESSI (preliminare, da eseguire una volta come amministratore)
   L'utente [claude] oggi è db_datareader + db_datawriter. Per queste
   query la scrittura non serve; servono invece i permessi di lettura
   dei metadati.

     ALTER ROLE [db_datawriter] DROP MEMBER [claude];
     GRANT VIEW DEFINITION    TO [claude];
     GRANT VIEW DATABASE STATE TO [claude];
   ===================================================================== */

USE [WinMtSqlDB];
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
GO

/* ---------------------------------------------------------------------
   Q01 — Volumi: righe e spazio per tabella
   --------------------------------------------------------------------- */
WITH r AS (
    SELECT p.object_id, SUM(p.rows) AS righe
    FROM sys.partitions p
    WHERE p.index_id IN (0,1)
    GROUP BY p.object_id
), s AS (
    SELECT p.object_id,
           SUM(a.total_pages) * 8 / 1024.0 AS mb_totali,
           SUM(CASE WHEN p.index_id IN (0,1) THEN a.data_pages ELSE 0 END) * 8 / 1024.0 AS mb_dati,
           SUM(CASE WHEN p.index_id > 1 THEN a.total_pages ELSE 0 END) * 8 / 1024.0 AS mb_indici
    FROM sys.partitions p
    JOIN sys.allocation_units a ON a.container_id = p.partition_id
    GROUP BY p.object_id
)
SELECT t.name AS tabella, r.righe,
       CAST(s.mb_totali AS decimal(12,2)) AS mb_totali,
       CAST(s.mb_dati   AS decimal(12,2)) AS mb_dati,
       CAST(s.mb_indici AS decimal(12,2)) AS mb_indici,
       (SELECT COUNT(*) FROM sys.indexes i WHERE i.object_id = t.object_id AND i.index_id > 0) AS n_indici
FROM sys.tables t
JOIN r ON r.object_id = t.object_id
JOIN s ON s.object_id = t.object_id
ORDER BY r.righe DESC;
GO

/* ---------------------------------------------------------------------
   Q02 — Trigger (lo script SSMS fornito non li contiene)
   --------------------------------------------------------------------- */
SELECT OBJECT_NAME(tr.parent_id)            AS tabella,
       tr.name                              AS trigger_name,
       tr.is_disabled,
       tr.is_instead_of_trigger,
       STUFF((SELECT ',' + te.type_desc FROM sys.trigger_events te
              WHERE te.object_id = tr.object_id FOR XML PATH('')), 1, 1, '') AS eventi,
       LEN(OBJECT_DEFINITION(tr.object_id)) AS lunghezza_sorgente,
       tr.create_date, tr.modify_date
FROM sys.triggers tr
WHERE tr.parent_class = 1
ORDER BY tabella, trigger_name;
GO

/* ---------------------------------------------------------------------
   Q03 — Configurazione Microsoft Sync Framework
   (la colonna config_data è XML: elenca le tabelle sincronizzate)
   --------------------------------------------------------------------- */
SELECT 'scope_info' AS fonte, si.sync_scope_name AS nome, CONVERT(nvarchar(50), si.scope_id) AS id,
       CONVERT(nvarchar(50), si.scope_config_id) AS config_id, si.scope_restore_count AS restore_count,
       DATALENGTH(si.scope_sync_knowledge) AS knowledge_bytes, si.scope_user_comment AS dettaglio
FROM dbo.scope_info si
UNION ALL
SELECT 'scope_config', sc.scope_status, CONVERT(nvarchar(50), sc.config_id), NULL, NULL, NULL,
       CONVERT(nvarchar(max), sc.config_data)
FROM dbo.scope_config sc
UNION ALL
SELECT 'schema_info', CONVERT(nvarchar(20), schema_major_version) + '.' + CONVERT(nvarchar(20), schema_minor_version),
       NULL, NULL, NULL, NULL, schema_extended_info
FROM dbo.schema_info;
GO

/* ---------------------------------------------------------------------
   Q04 — Valori di NImp (numero impianto) per tabella
   Serve a capire se un DB di sala contiene dati di più impianti.
   --------------------------------------------------------------------- */
IF OBJECT_ID('tempdb..#nimp') IS NOT NULL DROP TABLE #nimp;
CREATE TABLE #nimp (tabella sysname, nimp int NULL, righe bigint);
DECLARE @t sysname, @sql nvarchar(max);
DECLARE c CURSOR LOCAL FAST_FORWARD FOR
    SELECT t.name FROM sys.tables t JOIN sys.columns col ON col.object_id = t.object_id
    WHERE col.name = 'NImp' AND t.name NOT LIKE '%[_]tracking';
OPEN c; FETCH NEXT FROM c INTO @t;
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = N'INSERT #nimp SELECT ' + QUOTENAME(@t,'''') + N', NImp, COUNT_BIG(*) FROM dbo.' + QUOTENAME(@t) + N' GROUP BY NImp;';
    EXEC (@sql);
    FETCH NEXT FROM c INTO @t;
END
CLOSE c; DEALLOCATE c;
SELECT * FROM #nimp ORDER BY tabella, nimp;
GO

/* ---------------------------------------------------------------------
   Q05 — Relazioni implicite candidate: verifica sui dati
   Per ogni coppia figlio -> padre:
   - orfani = righe del figlio con valore non nullo assente nel padre;
   - righe_padre > distinti_padre = il "padre" non è univoco su quella
     colonna, quindi la relazione è ambigua.
   conv = 1 confronta come testo (tipi incompatibili).
   --------------------------------------------------------------------- */
IF OBJECT_ID('tempdb..#rel') IS NOT NULL DROP TABLE #rel;
CREATE TABLE #rel (figlio sysname, col_figlio sysname, padre sysname, col_padre sysname, conv bit,
                   righe_figlio bigint, nonnull_figlio bigint, orfani bigint, orfani_distinti bigint,
                   righe_padre bigint, distinti_padre bigint, errore nvarchar(4000));
INSERT #rel (figlio, col_figlio, padre, col_padre, conv) VALUES
 ('Vincite','IdContatto','Clienti','IdContatto',0), ('Vincite','IdContatto','Clienti','IdLong',0),
 ('Vincite25','IdContatto','Clienti','IdContatto',0),
 ('Scocard','IdContatto','Clienti','IdContatto',0), ('Scocard','IdContatto','Clienti','IdLong',0),
 ('Tickets','IdContatto','Clienti','IdContatto',0),
 ('Resi','IdContatto','Clienti','IdContatto',0),
 ('TickRep','IdCliente','Clienti','IdContatto',0),
 ('Prenotaz','IdCli','Clienti','IdContatto',0),
 ('Figli','IdContatto','Clienti','IdContatto',0),
 ('Clienti','IdMaster1','Clienti','IdContatto',0),
 ('CoinlessCards','IdContatto','Clienti','IdContatto',0), ('CoinlessCards','IdContatto','Clienti','IdLong',0),
 ('LogTransazioniTotem','IdCli','Clienti','IdContatto',0),
 ('RedeemCodes','IdContatto','Clienti','IdContatto',0),
 ('TransCard','IdCli','CoinlessCards','cardid',0), ('TransCard','IdCli','Clienti','CodBar',0),
 ('CoinlessTransazioniCards','cardid','CoinlessCards','cardid',0),
 ('UID_Ammessi','CodBar','Clienti','CodBar',0),
 ('Vincite','Codice','Premi','Codice',0), ('Vincite25','Codice','Premi','Codice',0),
 ('MovMag','Codice','Premi','Codice',0), ('MovOut','Codice','Premi','Codice',0),
 ('Resi','Codice','Premi','Codice',0), ('Ordini','Codice','Premi','Codice',0),
 ('Prenotaz','Codice','Premi','Codice',0), ('GruMovimenti','PrizeCode','Premi','Codice',0),
 ('PrizeHubSlots','codArticolo','Premi','Codice',0),
 ('Premi','Fornitore','Fornitori','Nome',0), ('MovMag','Fornitore','Fornitori','Nome',0),
 ('MovMag','Oper','Operatori','Id',0), ('MovOut','Oper','Operatori','Id',0),
 ('Incassi','Oper','Operatori','Id',0), ('Scocard','Oper','Operatori','Id',0),
 ('TransCard','Operatore','Operatori','Id',0), ('Prenotaz','IdOp','Operatori','Id',0),
 ('EcsDati','CodMac','EcsMacchine','CodMac',0), ('TransCard','CodMac','EcsMacchine','CodMac',0),
 ('CoinlessTransazioniCards','CodMac','EcsMacchine','CodMac',0),
 ('GruMovimenti','CodMac','EcsMacchine','CodMac',0), ('GruMagazzino','CodMac','EcsMacchine','CodMac',0),
 ('EcsMacchine','Propr','Owners','Id',1), ('EcsMacchine','Propr','Owners','OwnerName',0),
 ('Machines','Manufacturer','Manuf','Id',0), ('Machines','Type','Type','Id',0);

DECLARE @f sysname, @cf sysname, @p sysname, @cp sysname, @cv bit, @q nvarchar(max), @ef nvarchar(400), @ep nvarchar(400),
        @r bigint, @nn bigint, @o bigint, @od bigint, @pr bigint, @pd bigint;
DECLARE k CURSOR LOCAL FAST_FORWARD FOR SELECT figlio, col_figlio, padre, col_padre, conv FROM #rel;
OPEN k; FETCH NEXT FROM k INTO @f, @cf, @p, @cp, @cv;
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @ef = CASE WHEN @cv = 1 THEN N'CONVERT(nvarchar(100), c.' + QUOTENAME(@cf) + N')' ELSE N'c.' + QUOTENAME(@cf) END;
    SET @ep = CASE WHEN @cv = 1 THEN N'CONVERT(nvarchar(100), p.' + QUOTENAME(@cp) + N')' ELSE N'p.' + QUOTENAME(@cp) END;
    BEGIN TRY
        SET @q = N'SELECT @r = COUNT_BIG(*), @nn = COUNT_BIG(c.' + QUOTENAME(@cf) + N') FROM dbo.' + QUOTENAME(@f) + N' c;
                   SELECT @o = COUNT_BIG(*), @od = COUNT_BIG(DISTINCT ' + @ef + N') FROM dbo.' + QUOTENAME(@f) + N' c
                   WHERE c.' + QUOTENAME(@cf) + N' IS NOT NULL
                     AND NOT EXISTS (SELECT 1 FROM dbo.' + QUOTENAME(@p) + N' p WHERE ' + @ep + N' = ' + @ef + N');
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
    FETCH NEXT FROM k INTO @f, @cf, @p, @cp, @cv;
END
CLOSE k; DEALLOCATE k;
SELECT * FROM #rel ORDER BY padre, figlio;
GO

/* ---------------------------------------------------------------------
   Q06 — Uso dei "campi jolly" (F0..F9, T0..T9, N0..N9, D0..D9)
   Solo conteggi: dice quali campi sono effettivamente usati e dove.
   --------------------------------------------------------------------- */
IF OBJECT_ID('tempdb..#jolly') IS NOT NULL DROP TABLE #jolly;
CREATE TABLE #jolly (tabella sysname, colonna sysname, tipo sysname, righe bigint, nonnull bigint,
                     distinti bigint, bit_a_1 bigint NULL, max_len int NULL);
DECLARE @tb sysname, @cl sysname, @ty sysname, @s nvarchar(max);
DECLARE j CURSOR LOCAL FAST_FORWARD FOR
    SELECT t.name, col.name, ty.name
    FROM sys.tables t
    JOIN sys.columns col ON col.object_id = t.object_id
    JOIN sys.types ty ON ty.user_type_id = col.user_type_id
    WHERE col.name LIKE '[FTND][0-9]' AND t.name NOT LIKE '%[_]tracking';
OPEN j; FETCH NEXT FROM j INTO @tb, @cl, @ty;
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @s = N'INSERT #jolly SELECT ' + QUOTENAME(@tb,'''') + N',' + QUOTENAME(@cl,'''') + N',' + QUOTENAME(@ty,'''') +
             N', COUNT_BIG(*), COUNT_BIG(' + QUOTENAME(@cl) + N'), COUNT_BIG(DISTINCT ' + QUOTENAME(@cl) + N'), ' +
             CASE WHEN @ty = 'bit' THEN N'SUM(CASE WHEN ' + QUOTENAME(@cl) + N' = 1 THEN 1 ELSE 0 END)' ELSE N'NULL' END + N', ' +
             CASE WHEN @ty LIKE '%char' THEN N'MAX(LEN(' + QUOTENAME(@cl) + N'))' ELSE N'NULL' END +
             N' FROM dbo.' + QUOTENAME(@tb) + N';';
    EXEC (@s);
    FETCH NEXT FROM j INTO @tb, @cl, @ty;
END
CLOSE j; DEALLOCATE j;
SELECT * FROM #jolly ORDER BY tabella, colonna;
GO

/* ---------------------------------------------------------------------
   Q07 — Forma dei numeri di carta di pagamento (NESSUN valore restituito)
   cifre_13_19 > 0 indica PAN potenzialmente in chiaro.
   --------------------------------------------------------------------- */
IF OBJECT_ID('tempdb..#pan') IS NOT NULL DROP TABLE #pan;
CREATE TABLE #pan (tabella sysname, colonna sysname, righe bigint, nonnull bigint,
                   cifre_13_19 bigint, con_mascheratura bigint, altro bigint, errore nvarchar(4000));
DECLARE @pt sysname, @pc sysname, @ps nvarchar(max);
DECLARE pc CURSOR LOCAL FAST_FORWARD FOR
    SELECT v.t, v.c FROM (VALUES ('LogTransazioniPos','PAN'), ('LogTransazioniTotem','PAN'),
                                 ('pos_transaction','masked_pan'), ('Nayax','Numero carta')) v(t, c);
OPEN pc; FETCH NEXT FROM pc INTO @pt, @pc;
WHILE @@FETCH_STATUS = 0
BEGIN
    BEGIN TRY
        SET @ps = N'INSERT #pan (tabella, colonna, righe, nonnull, cifre_13_19, con_mascheratura, altro)
          SELECT ' + QUOTENAME(@pt,'''') + N',' + QUOTENAME(@pc,'''') + N', COUNT_BIG(*), COUNT_BIG(x),
                 SUM(CASE WHEN x NOT LIKE ''%[^0-9]%'' AND LEN(x) BETWEEN 13 AND 19 THEN 1 ELSE 0 END),
                 SUM(CASE WHEN x LIKE ''%[*Xx#]%'' THEN 1 ELSE 0 END),
                 SUM(CASE WHEN x IS NOT NULL AND NOT (x NOT LIKE ''%[^0-9]%'' AND LEN(x) BETWEEN 13 AND 19)
                           AND x NOT LIKE ''%[*Xx#]%'' THEN 1 ELSE 0 END)
          FROM (SELECT LTRIM(RTRIM(REPLACE(CONVERT(nvarchar(100), ' + QUOTENAME(@pc) + N'), '' '', ''''))) AS x
                FROM dbo.' + QUOTENAME(@pt) + N') z;';
        EXEC (@ps);
    END TRY
    BEGIN CATCH
        INSERT #pan (tabella, colonna, errore) VALUES (@pt, @pc, ERROR_MESSAGE());
    END CATCH
    FETCH NEXT FROM pc INTO @pt, @pc;
END
CLOSE pc; DEALLOCATE pc;
SELECT * FROM #pan;
GO

/* ---------------------------------------------------------------------
   Q08 — Profondità storica: date minime e massime per colonna data
   (esclusi i campi jolly D0..D9, già coperti da Q06)
   --------------------------------------------------------------------- */
IF OBJECT_ID('tempdb..#date') IS NOT NULL DROP TABLE #date;
CREATE TABLE #date (tabella sysname, colonna sysname, nonnull bigint, data_min datetime2, data_max datetime2);
DECLARE @dt sysname, @dc sysname, @ds nvarchar(max);
DECLARE d CURSOR LOCAL FAST_FORWARD FOR
    SELECT t.name, col.name
    FROM sys.tables t
    JOIN sys.columns col ON col.object_id = t.object_id
    JOIN sys.types ty ON ty.user_type_id = col.user_type_id
    WHERE ty.name IN ('datetime','datetime2','date','smalldatetime')
      AND col.name NOT LIKE 'D[0-9]' AND t.name NOT LIKE '%[_]tracking';
OPEN d; FETCH NEXT FROM d INTO @dt, @dc;
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @ds = N'INSERT #date SELECT ' + QUOTENAME(@dt,'''') + N',' + QUOTENAME(@dc,'''') +
              N', COUNT_BIG(' + QUOTENAME(@dc) + N'), MIN(' + QUOTENAME(@dc) + N'), MAX(' + QUOTENAME(@dc) + N') FROM dbo.' + QUOTENAME(@dt) + N';';
    EXEC (@ds);
    FETCH NEXT FROM d INTO @dt, @dc;
END
CLOSE d; DEALLOCATE d;
SELECT * FROM #date ORDER BY tabella, colonna;
GO

/* ---------------------------------------------------------------------
   Q09 — Forma delle password memorizzate (NESSUN valore restituito)
   aspetto_hash = solo esadecimale, lunghezza 32/40/64 (MD5/SHA1/SHA256)
   valori_default = uguali alle password iniziali citate nel manuale
   --------------------------------------------------------------------- */
SELECT v.tabella, v.colonna,
       COUNT_BIG(v.x) AS nonnull,
       COUNT_BIG(DISTINCT v.x) AS distinti,
       MIN(LEN(v.x)) AS len_min, MAX(LEN(v.x)) AS len_max,
       SUM(CASE WHEN v.x NOT LIKE '%[^0-9A-Fa-f]%' AND LEN(v.x) IN (32,40,64) THEN 1 ELSE 0 END) AS aspetto_hash,
       SUM(CASE WHEN v.x IN ('password','elmac') THEN 1 ELSE 0 END) AS valori_default
FROM (
          SELECT 'Clienti'   AS tabella, 'Password' AS colonna, CONVERT(varchar(100), Password) AS x FROM dbo.Clienti
    UNION ALL SELECT 'Figli',     'Password', CONVERT(varchar(100), Password) FROM dbo.Figli
    UNION ALL SELECT 'Operatori', 'Password', CONVERT(varchar(100), Password) FROM dbo.Operatori
    UNION ALL SELECT 'Setup',     'Passw',    CONVERT(varchar(100), Passw)    FROM dbo.Setup
    UNION ALL SELECT 'Setup',     'AdmPass',  CONVERT(varchar(100), AdmPass)  FROM dbo.Setup
    UNION ALL SELECT 'Setup',     'PasswSM',  CONVERT(varchar(100), PasswSM)  FROM dbo.Setup
    UNION ALL SELECT 'Setup',     'InvPass',  CONVERT(varchar(100), InvPass)  FROM dbo.Setup
) v
GROUP BY v.tabella, v.colonna
ORDER BY v.tabella, v.colonna;
GO

/* ---------------------------------------------------------------------
   Q10 — Frammentazione degli indici clustered
   Verifica l'ipotesi GUID casuale -> frammentazione (vedi DB 01, § 3).
   Modalità LIMITED: leggera, legge solo i livelli non foglia.
   Richiede VIEW DATABASE STATE.
   --------------------------------------------------------------------- */
SELECT OBJECT_NAME(ips.object_id) AS tabella,
       i.name AS indice,
       ty.name AS tipo_prima_colonna_chiave,
       ips.page_count,
       CAST(ips.avg_fragmentation_in_percent AS decimal(5,1)) AS frammentazione_pct
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') ips
JOIN sys.indexes i ON i.object_id = ips.object_id AND i.index_id = ips.index_id
JOIN sys.index_columns ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id AND ic.key_ordinal = 1
JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
JOIN sys.types ty ON ty.user_type_id = c.user_type_id
WHERE i.index_id = 1 AND ips.page_count >= 100
ORDER BY ips.avg_fragmentation_in_percent DESC;
GO
