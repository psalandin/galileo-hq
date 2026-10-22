CREATE PROCEDURE [coinless_sbuilder_pages_bulkupdate]
	@sync_min_timestamp BigInt,
	@sync_scope_local_id Int,
	@changeTable [coinless_sbuilder_pages_BulkType] READONLY
AS
BEGIN
-- use a temp table to store the list of PKs that successfully got updated
declare @changed TABLE ([id] int, PRIMARY KEY ([id]));

SET IDENTITY_INSERT [coinless_sbuilder_pages] ON;
-- update the base table
MERGE [coinless_sbuilder_pages] AS base USING
-- join done here against the side table to get the local timestamp for concurrency check
(SELECT p.*, t.update_scope_local_id, t.scope_update_peer_key, t.local_update_peer_timestamp FROM @changeTable p LEFT JOIN [coinless_sbuilder_pages_tracking] t ON p.[id] = t.[id]) as changes ON changes.[id] = base.[id]
WHEN MATCHED AND (changes.update_scope_local_id = @sync_scope_local_id AND changes.scope_update_peer_key = changes.sync_update_peer_key) OR changes.local_update_peer_timestamp <= @sync_min_timestamp THEN
UPDATE SET [ClienteImpianto] = changes.[ClienteImpianto], [Codmac] = changes.[Codmac], [NomeTemplate] = changes.[NomeTemplate], [pagina_generata] = changes.[pagina_generata], [pagina_su_be] = changes.[pagina_su_be]
OUTPUT INSERTED.[id] into @changed; -- populates the temp table with successful PKs

SET IDENTITY_INSERT [coinless_sbuilder_pages] OFF;
UPDATE side SET
update_scope_local_id = @sync_scope_local_id, 
scope_update_peer_key = changes.sync_update_peer_key, 
scope_update_peer_timestamp = changes.sync_update_peer_timestamp,
local_update_peer_key = 0
FROM 
[coinless_sbuilder_pages_tracking] side JOIN 
(SELECT p.[id], p.sync_update_peer_timestamp, p.sync_update_peer_key, p.sync_create_peer_key, p.sync_create_peer_timestamp FROM @changed t JOIN @changeTable p ON p.[id] = t.[id]) as changes ON changes.[id] = side.[id]
SELECT [id] FROM @changeTable t WHERE NOT EXISTS (SELECT [id] from @changed i WHERE t.[id] = i.[id])
END
