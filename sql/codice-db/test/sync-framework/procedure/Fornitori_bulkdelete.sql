CREATE PROCEDURE [Fornitori_bulkdelete]
	@sync_min_timestamp BigInt,
	@sync_scope_local_id Int,
	@changeTable [Fornitori_BulkType] READONLY
AS
BEGIN
-- use a temp table to store the list of PKs that successfully got updated/inserted
declare @changed TABLE ([Nome] varchar(100), PRIMARY KEY ([Nome]));
DELETE [Fornitori] 
OUTPUT DELETED.[Nome] INTO @changed FROM [Fornitori] base JOIN
(SELECT p.*, t.update_scope_local_id, t.scope_update_peer_key, t.local_update_peer_timestamp FROM @changeTable p JOIN [Fornitori_tracking] t ON p.[Nome] = t.[Nome]) as changes ON changes.[Nome] = base.[Nome] WHERE (changes.update_scope_local_id = @sync_scope_local_id AND changes.scope_update_peer_key = changes.sync_update_peer_key) OR changes.local_update_peer_timestamp <= @sync_min_timestamp
UPDATE side SET
sync_row_is_tombstone = 1, 
update_scope_local_id = @sync_scope_local_id, 
scope_update_peer_key = changes.sync_update_peer_key, 
scope_update_peer_timestamp = changes.sync_update_peer_timestamp,
local_update_peer_key = 0
FROM 
[Fornitori_tracking] side JOIN 
(SELECT p.[Nome], p.sync_update_peer_timestamp, p.sync_update_peer_key, p.sync_create_peer_key, p.sync_create_peer_timestamp FROM @changed t JOIN @changeTable p ON p.[Nome] = t.[Nome]) AS changes ON changes.[Nome] = side.[Nome]
SELECT [Nome] FROM @changeTable t WHERE NOT EXISTS (SELECT [Nome] from @changed i WHERE t.[Nome] = i.[Nome])
END
