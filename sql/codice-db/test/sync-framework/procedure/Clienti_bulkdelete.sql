CREATE PROCEDURE [Clienti_bulkdelete]
	@sync_min_timestamp BigInt,
	@sync_scope_local_id Int,
	@changeTable [Clienti_BulkType] READONLY
AS
BEGIN
-- use a temp table to store the list of PKs that successfully got updated/inserted
declare @changed TABLE ([IdLong] bigint, PRIMARY KEY ([IdLong]));
DELETE [Clienti] 
OUTPUT DELETED.[IdLong] INTO @changed FROM [Clienti] base JOIN
(SELECT p.*, t.update_scope_local_id, t.scope_update_peer_key, t.local_update_peer_timestamp FROM @changeTable p JOIN [Clienti_tracking] t ON p.[IdLong] = t.[IdLong]) as changes ON changes.[IdLong] = base.[IdLong] WHERE (changes.update_scope_local_id = @sync_scope_local_id AND changes.scope_update_peer_key = changes.sync_update_peer_key) OR changes.local_update_peer_timestamp <= @sync_min_timestamp
UPDATE side SET
sync_row_is_tombstone = 1, 
update_scope_local_id = @sync_scope_local_id, 
scope_update_peer_key = changes.sync_update_peer_key, 
scope_update_peer_timestamp = changes.sync_update_peer_timestamp,
local_update_peer_key = 0
FROM 
[Clienti_tracking] side JOIN 
(SELECT p.[IdLong], p.sync_update_peer_timestamp, p.sync_update_peer_key, p.sync_create_peer_key, p.sync_create_peer_timestamp FROM @changed t JOIN @changeTable p ON p.[IdLong] = t.[IdLong]) AS changes ON changes.[IdLong] = side.[IdLong]
SELECT [IdLong] FROM @changeTable t WHERE NOT EXISTS (SELECT [IdLong] from @changed i WHERE t.[IdLong] = i.[IdLong])
END
