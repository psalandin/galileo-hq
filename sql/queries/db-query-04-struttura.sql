/* =====================================================================
   Galileo HQ — Kit di query 04: catalogo completo della struttura
   ---------------------------------------------------------------------
   Estrae dal database corrente tutto ciò che serve a confrontare due
   schemi (test e produzione, sala e HQ): tabelle, colonne, indici,
   vincoli, trigger, codice di procedure/funzioni/viste, tipi,
   scope di Sync Framework, utenti e ruoli.

   Solo lettura, solo metadati: nessun dato applicativo.
   Ogni sezione (separata da GO) produce un result set e inizia con un
   commento con il nome della sezione preceduto da "@": lo script di
   esecuzione salva il risultato in un file con quel nome
   (es. colonne.tsv). In SSMS si può eseguire una sezione alla volta.

   Il codice dei moduli (sez. moduli_codice) è lungo: in SSMS conviene
   impostare "Risultati in griglia > Dati non XML > 2 MB".
   ===================================================================== */

SET NOCOUNT ON;
GO

-- @database
SELECT DB_NAME() AS db, d.compatibility_level, d.collation_name, d.recovery_model_desc,
       d.is_auto_close_on, d.is_auto_shrink_on, d.snapshot_isolation_state_desc,
       d.is_read_committed_snapshot_on, d.is_ansi_nulls_on, d.is_quoted_identifier_on,
       d.is_trustworthy_on, d.is_broker_enabled, d.page_verify_option_desc,
       d.create_date
FROM sys.databases d
WHERE d.name = DB_NAME();
GO

-- @file
SELECT f.name, f.type_desc, CAST(f.size * 8 / 1024.0 AS decimal(12,1)) AS mb,
       CAST(FILEPROPERTY(f.name, 'SpaceUsed') * 8 / 1024.0 AS decimal(12,1)) AS mb_usati,
       f.growth, f.is_percent_growth, f.max_size
FROM sys.database_files f;
GO

-- @oggetti
SELECT s.name AS schema_name, o.name, o.type, o.type_desc,
       OBJECT_NAME(o.parent_object_id) AS parent, o.is_ms_shipped,
       o.create_date, o.modify_date
FROM sys.objects o
JOIN sys.schemas s ON s.schema_id = o.schema_id
WHERE o.is_ms_shipped = 0
ORDER BY o.type, s.name, o.name;
GO

-- @tabelle
WITH r AS (
    SELECT object_id, SUM(rows) AS righe
    FROM sys.partitions WHERE index_id IN (0,1) GROUP BY object_id
)
SELECT s.name AS schema_name, t.name AS tabella, r.righe,
       (SELECT COUNT(*) FROM sys.columns c WHERE c.object_id = t.object_id) AS n_colonne,
       (SELECT COUNT(*) FROM sys.indexes i WHERE i.object_id = t.object_id AND i.index_id > 0) AS n_indici,
       OBJECTPROPERTY(t.object_id, 'TableHasPrimaryKey') AS ha_pk,
       CASE WHEN EXISTS (SELECT 1 FROM sys.indexes i WHERE i.object_id = t.object_id AND i.index_id = 1) THEN 1 ELSE 0 END AS ha_clustered,
       t.lock_escalation_desc, t.temporal_type_desc, t.is_memory_optimized,
       t.create_date, t.modify_date
FROM sys.tables t
JOIN sys.schemas s ON s.schema_id = t.schema_id
LEFT JOIN r ON r.object_id = t.object_id
WHERE t.is_ms_shipped = 0
ORDER BY s.name, t.name;
GO

-- @colonne
SELECT s.name AS schema_name, o.name AS oggetto, o.type AS tipo_oggetto,
       c.column_id, c.name AS colonna,
       TYPE_NAME(c.user_type_id) AS tipo,
       CASE WHEN TYPE_NAME(c.user_type_id) IN ('varchar','char','varbinary','binary')
                 THEN CASE WHEN c.max_length = -1 THEN 'max' ELSE CAST(c.max_length AS varchar(10)) END
            WHEN TYPE_NAME(c.user_type_id) IN ('nvarchar','nchar')
                 THEN CASE WHEN c.max_length = -1 THEN 'max' ELSE CAST(c.max_length / 2 AS varchar(10)) END
            WHEN TYPE_NAME(c.user_type_id) IN ('decimal','numeric')
                 THEN CAST(c.precision AS varchar(10)) + ',' + CAST(c.scale AS varchar(10))
            WHEN TYPE_NAME(c.user_type_id) IN ('datetime2','time','datetimeoffset')
                 THEN CAST(c.scale AS varchar(10))
            ELSE '' END AS lunghezza,
       c.is_nullable, c.is_identity,
       CASE WHEN c.is_identity = 1 THEN CONCAT(CONVERT(varchar(30), ic.seed_value), ',', CONVERT(varchar(30), ic.increment_value)) END AS identity_def,
       c.is_computed, cc.definition AS computed_def,
       dc.name AS default_nome, dc.definition AS default_def,
       c.collation_name, c.is_rowguidcol, c.is_sparse
FROM sys.columns c
JOIN sys.objects o ON o.object_id = c.object_id
JOIN sys.schemas s ON s.schema_id = o.schema_id
LEFT JOIN sys.identity_columns ic ON ic.object_id = c.object_id AND ic.column_id = c.column_id
LEFT JOIN sys.computed_columns cc ON cc.object_id = c.object_id AND cc.column_id = c.column_id
LEFT JOIN sys.default_constraints dc ON dc.parent_object_id = c.object_id AND dc.parent_column_id = c.column_id
WHERE o.is_ms_shipped = 0 AND o.type IN ('U','V','TF','IF')
ORDER BY s.name, o.name, c.column_id;
GO

-- @indici
SELECT s.name AS schema_name, t.name AS tabella, i.name AS indice, i.index_id,
       i.type_desc, i.is_unique, i.is_primary_key, i.is_unique_constraint, i.is_disabled,
       i.has_filter, i.filter_definition, i.fill_factor, i.ignore_dup_key,
       STUFF((SELECT ', ' + c.name + CASE WHEN ic.is_descending_key = 1 THEN ' DESC' ELSE '' END
              FROM sys.index_columns ic JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
              WHERE ic.object_id = i.object_id AND ic.index_id = i.index_id AND ic.is_included_column = 0
              ORDER BY ic.key_ordinal FOR XML PATH('')), 1, 2, '') AS chiave,
       STUFF((SELECT ', ' + c.name
              FROM sys.index_columns ic JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
              WHERE ic.object_id = i.object_id AND ic.index_id = i.index_id AND ic.is_included_column = 1
              ORDER BY c.name FOR XML PATH('')), 1, 2, '') AS incluse,
       CAST((SELECT SUM(a.total_pages) FROM sys.partitions p JOIN sys.allocation_units a ON a.container_id = p.partition_id
             WHERE p.object_id = i.object_id AND p.index_id = i.index_id) * 8 / 1024.0 AS decimal(12,2)) AS mb
FROM sys.indexes i
JOIN sys.tables t ON t.object_id = i.object_id
JOIN sys.schemas s ON s.schema_id = t.schema_id
WHERE i.index_id > 0 AND t.is_ms_shipped = 0
ORDER BY s.name, t.name, i.index_id;
GO

-- @chiavi_esterne
SELECT fk.name AS vincolo, OBJECT_NAME(fk.parent_object_id) AS tabella,
       STUFF((SELECT ', ' + COL_NAME(fc.parent_object_id, fc.parent_column_id)
              FROM sys.foreign_key_columns fc WHERE fc.constraint_object_id = fk.object_id
              ORDER BY fc.constraint_column_id FOR XML PATH('')), 1, 2, '') AS colonne,
       OBJECT_NAME(fk.referenced_object_id) AS tabella_rif,
       STUFF((SELECT ', ' + COL_NAME(fc.referenced_object_id, fc.referenced_column_id)
              FROM sys.foreign_key_columns fc WHERE fc.constraint_object_id = fk.object_id
              ORDER BY fc.constraint_column_id FOR XML PATH('')), 1, 2, '') AS colonne_rif,
       fk.delete_referential_action_desc, fk.update_referential_action_desc,
       fk.is_disabled, fk.is_not_trusted
FROM sys.foreign_keys fk
ORDER BY tabella, vincolo;
GO

-- @check
SELECT OBJECT_NAME(cc.parent_object_id) AS tabella, cc.name AS vincolo,
       COL_NAME(cc.parent_object_id, cc.parent_column_id) AS colonna,
       cc.definition, cc.is_disabled, cc.is_not_trusted
FROM sys.check_constraints cc
ORDER BY tabella, vincolo;
GO

-- @trigger
SELECT OBJECT_NAME(tr.parent_id) AS tabella, tr.name AS trigger_name,
       tr.is_disabled, tr.is_instead_of_trigger,
       STUFF((SELECT ', ' + te.type_desc FROM sys.trigger_events te WHERE te.object_id = tr.object_id
              ORDER BY te.type_desc FOR XML PATH('')), 1, 2, '') AS eventi,
       tr.create_date, tr.modify_date,
       LEN(m.definition) AS lunghezza,
       CONVERT(varchar(64), HASHBYTES('SHA2_256', REPLACE(REPLACE(REPLACE(m.definition, CHAR(13), ''), CHAR(10), ''), ' ', '')), 2) AS hash_norm
FROM sys.triggers tr
LEFT JOIN sys.sql_modules m ON m.object_id = tr.object_id
WHERE tr.parent_class = 1
ORDER BY tabella, trigger_name;
GO

-- @moduli
-- Hash calcolato sul testo senza spazi e a capo: due moduli con lo stesso
-- hash differiscono al più per la formattazione.
SELECT s.name AS schema_name, o.name, o.type_desc,
       o.create_date, o.modify_date,
       LEN(m.definition) AS lunghezza,
       CONVERT(varchar(64), HASHBYTES('SHA2_256', REPLACE(REPLACE(REPLACE(REPLACE(m.definition, CHAR(13), ''), CHAR(10), ''), CHAR(9), ''), ' ', '')), 2) AS hash_norm,
       m.uses_ansi_nulls, m.uses_quoted_identifier, m.is_schema_bound
FROM sys.sql_modules m
JOIN sys.objects o ON o.object_id = m.object_id
JOIN sys.schemas s ON s.schema_id = o.schema_id
WHERE o.is_ms_shipped = 0
ORDER BY o.type_desc, s.name, o.name;
GO

-- @parametri
SELECT OBJECT_NAME(p.object_id) AS modulo, p.parameter_id, p.name AS parametro,
       TYPE_NAME(p.user_type_id) AS tipo, p.max_length, p.precision, p.scale,
       p.is_output, p.has_default_value
FROM sys.parameters p
JOIN sys.objects o ON o.object_id = p.object_id
WHERE o.is_ms_shipped = 0
ORDER BY modulo, p.parameter_id;
GO

-- @moduli_codice
-- Una riga per modulo; nel file TSV tabulazioni e a capo vengono appiattiti,
-- quindi per leggere il codice conviene l'esportazione per file.
SELECT s.name AS schema_name, o.name, o.type_desc, m.definition
FROM sys.sql_modules m
JOIN sys.objects o ON o.object_id = m.object_id
JOIN sys.schemas s ON s.schema_id = o.schema_id
WHERE o.is_ms_shipped = 0
ORDER BY o.type_desc, s.name, o.name;
GO

-- @tipi
SELECT s.name AS schema_name, t.name AS tipo, t.is_table_type,
       TYPE_NAME(t.system_type_id) AS tipo_base, t.max_length, t.is_nullable
FROM sys.types t
JOIN sys.schemas s ON s.schema_id = t.schema_id
WHERE t.is_user_defined = 1
ORDER BY tipo;
GO

-- @dipendenze
SELECT OBJECT_NAME(d.referencing_id) AS oggetto,
       o.type_desc AS tipo_oggetto,
       COALESCE(d.referenced_schema_name + '.', '') + d.referenced_entity_name AS riferito,
       d.referenced_database_name, d.is_caller_dependent, d.is_ambiguous
FROM sys.sql_expression_dependencies d
JOIN sys.objects o ON o.object_id = d.referencing_id
WHERE o.is_ms_shipped = 0
ORDER BY oggetto, riferito;
GO

-- @principali
SELECT p.name, p.type_desc, p.authentication_type_desc, p.default_schema_name,
       STUFF((SELECT ', ' + r.name FROM sys.database_role_members rm
              JOIN sys.database_principals r ON r.principal_id = rm.role_principal_id
              WHERE rm.member_principal_id = p.principal_id ORDER BY r.name FOR XML PATH('')), 1, 2, '') AS ruoli,
       p.create_date
FROM sys.database_principals p
WHERE p.type IN ('S','U','G','R','E','X') AND p.is_fixed_role = 0
  AND p.name NOT IN ('public','dbo','guest','INFORMATION_SCHEMA','sys')
ORDER BY p.type_desc, p.name;
GO

-- @permessi
SELECT pr.name AS principale, pe.permission_name, pe.state_desc, pe.class_desc,
       COALESCE(OBJECT_NAME(pe.major_id), SCHEMA_NAME(pe.major_id)) AS oggetto
FROM sys.database_permissions pe
JOIN sys.database_principals pr ON pr.principal_id = pe.grantee_principal_id
WHERE pr.name NOT IN ('public','dbo','guest')
ORDER BY principale, oggetto, permission_name;
GO

-- @sync_scope
IF OBJECT_ID('dbo.scope_info') IS NOT NULL
    EXEC('SELECT sync_scope_name, scope_local_id, scope_config_id, scope_restore_count,
                 scope_user_comment, DATALENGTH(scope_sync_knowledge) AS knowledge_bytes
          FROM dbo.scope_info ORDER BY sync_scope_name');
ELSE SELECT 'scope_info assente' AS nota;
GO

-- @sync_tabelle
-- Tabelle di ciascuno scope, ricavate dall'XML di scope_config.
IF OBJECT_ID('dbo.scope_config') IS NOT NULL
    EXEC('
    SELECT si.sync_scope_name,
           a.t.value(''@Name'', ''nvarchar(256)'') AS tabella,
           a.t.value(''count(Col)'', ''int'') AS n_colonne,
           a.t.value(''(FilterClause)[1]'', ''nvarchar(max)'') AS filtro
    FROM dbo.scope_info si
    JOIN dbo.scope_config sc ON sc.config_id = si.scope_config_id
    CROSS APPLY (SELECT CAST(sc.config_data AS xml) AS x) c
    CROSS APPLY c.x.nodes(''//Adapter'') a(t)
    ORDER BY si.sync_scope_name, tabella');
ELSE SELECT 'scope_config assente' AS nota;
GO

-- @schema_info
IF OBJECT_ID('dbo.schema_info') IS NOT NULL
    EXEC('SELECT * FROM dbo.schema_info');
ELSE SELECT 'schema_info assente' AS nota;
GO
