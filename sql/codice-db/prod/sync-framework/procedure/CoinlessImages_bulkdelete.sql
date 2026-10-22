CREATE PROCEDURE [CoinlessImages_bulkdelete]
	@sync_min_timestamp BigInt,
	@sync_scope_local_id Int,
	@changeTable [CoinlessImages_BulkType] READONLY
AS
BEGIN
-- use a temp table to store the list of PKs that successfully got updated/inserted
declare @changed TABLE ([id] int, PRIMARY KEY ([id]));
DELETE [CoinlessImages] 
OUTPUT DELETED.[id] INTO @changed FROM [CoinlessImages] base JOIN
(SELECT p.*, t.update_scope_local_id, t.scope_update_peer_key, t.local_update_peer_timestamp FROM @changeTable p JOIN [CoinlessImages_tracking] t ON p.[id] = t.[id]) as changes ON changes.[id] = base.[id] WHERE (changes.update_scope_local_id = @sync_scope_local_id AND changes.scope_update_peer_key = changes.sync_update_peer_key) OR changes.local_update_peer_timestamp <= @sync_min_timestamp
UPDATE side SET
sync_row_is_tombstone = 1, 
update_scope_local_id = @sync_scope_local_id, 
scope_update_peer_key = changes.sync_update_peer_key, 
scope_update_peer_timestamp = changes.sync_update_peer_timestamp,
local_update_peer_key = 0
FROM 
[CoinlessImages_tracking] side JOIN 
(SELECT p.[id], p.sync_update_peer_timestamp, p.sync_update_peer_key, p.sync_create_peer_key, p.sync_create_peer_timestamp FROM @changed t JOIN @changeTable p ON p.[id] = t.[id]) AS changes ON changes.[id] = side.[id]
SELECT [id] FROM @changeTable t WHERE NOT EXISTS (SELECT [id] from @changed i WHERE t.[id] = i.[id])
END
