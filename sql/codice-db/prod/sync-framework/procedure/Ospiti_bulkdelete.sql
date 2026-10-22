CREATE PROCEDURE [Ospiti_bulkdelete]
	@sync_min_timestamp BigInt,
	@sync_scope_local_id Int,
	@changeTable [Ospiti_BulkType] READONLY
AS
BEGIN
-- use a temp table to store the list of PKs that successfully got updated/inserted
declare @changed TABLE ([IdOspite] bigint, PRIMARY KEY ([IdOspite]));
DELETE [Ospiti] 
OUTPUT DELETED.[IdOspite] INTO @changed FROM [Ospiti] base JOIN
(SELECT p.*, t.update_scope_local_id, t.scope_update_peer_key, t.local_update_peer_timestamp FROM @changeTable p JOIN [Ospiti_tracking] t ON p.[IdOspite] = t.[IdOspite]) as changes ON changes.[IdOspite] = base.[IdOspite] WHERE (changes.update_scope_local_id = @sync_scope_local_id AND changes.scope_update_peer_key = changes.sync_update_peer_key) OR changes.local_update_peer_timestamp <= @sync_min_timestamp
UPDATE side SET
sync_row_is_tombstone = 1, 
update_scope_local_id = @sync_scope_local_id, 
scope_update_peer_key = changes.sync_update_peer_key, 
scope_update_peer_timestamp = changes.sync_update_peer_timestamp,
local_update_peer_key = 0
FROM 
[Ospiti_tracking] side JOIN 
(SELECT p.[IdOspite], p.sync_update_peer_timestamp, p.sync_update_peer_key, p.sync_create_peer_key, p.sync_create_peer_timestamp FROM @changed t JOIN @changeTable p ON p.[IdOspite] = t.[IdOspite]) AS changes ON changes.[IdOspite] = side.[IdOspite]
SELECT [IdOspite] FROM @changeTable t WHERE NOT EXISTS (SELECT [IdOspite] from @changed i WHERE t.[IdOspite] = i.[IdOspite])
END
