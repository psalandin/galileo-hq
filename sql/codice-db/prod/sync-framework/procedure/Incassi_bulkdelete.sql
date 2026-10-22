CREATE PROCEDURE [Incassi_bulkdelete]
	@sync_min_timestamp BigInt,
	@sync_scope_local_id Int,
	@changeTable [Incassi_BulkType] READONLY
AS
BEGIN
-- use a temp table to store the list of PKs that successfully got updated/inserted
declare @changed TABLE ([Keys] uniqueidentifier, PRIMARY KEY ([Keys]));
DELETE [Incassi] 
OUTPUT DELETED.[Keys] INTO @changed FROM [Incassi] base JOIN
(SELECT p.*, t.update_scope_local_id, t.scope_update_peer_key, t.local_update_peer_timestamp FROM @changeTable p JOIN [Incassi_tracking] t ON p.[Keys] = t.[Keys]) as changes ON changes.[Keys] = base.[Keys] WHERE (changes.update_scope_local_id = @sync_scope_local_id AND changes.scope_update_peer_key = changes.sync_update_peer_key) OR changes.local_update_peer_timestamp <= @sync_min_timestamp
UPDATE side SET
sync_row_is_tombstone = 1, 
update_scope_local_id = @sync_scope_local_id, 
scope_update_peer_key = changes.sync_update_peer_key, 
scope_update_peer_timestamp = changes.sync_update_peer_timestamp,
local_update_peer_key = 0
FROM 
[Incassi_tracking] side JOIN 
(SELECT p.[Keys], p.sync_update_peer_timestamp, p.sync_update_peer_key, p.sync_create_peer_key, p.sync_create_peer_timestamp FROM @changed t JOIN @changeTable p ON p.[Keys] = t.[Keys]) AS changes ON changes.[Keys] = side.[Keys]
SELECT [Keys] FROM @changeTable t WHERE NOT EXISTS (SELECT [Keys] from @changed i WHERE t.[Keys] = i.[Keys])
END
