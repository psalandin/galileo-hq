CREATE PROCEDURE [UID_Ammessi_bulkdelete]
	@sync_min_timestamp BigInt,
	@sync_scope_local_id Int,
	@changeTable [UID_Ammessi_BulkType] READONLY
AS
BEGIN
-- use a temp table to store the list of PKs that successfully got updated/inserted
declare @changed TABLE ([UID] varchar(16), PRIMARY KEY ([UID]));
DELETE [UID_Ammessi] 
OUTPUT DELETED.[UID] INTO @changed FROM [UID_Ammessi] base JOIN
(SELECT p.*, t.update_scope_local_id, t.scope_update_peer_key, t.local_update_peer_timestamp FROM @changeTable p JOIN [UID_Ammessi_tracking] t ON p.[UID] = t.[UID]) as changes ON changes.[UID] = base.[UID] WHERE (changes.update_scope_local_id = @sync_scope_local_id AND changes.scope_update_peer_key = changes.sync_update_peer_key) OR changes.local_update_peer_timestamp <= @sync_min_timestamp
UPDATE side SET
sync_row_is_tombstone = 1, 
update_scope_local_id = @sync_scope_local_id, 
scope_update_peer_key = changes.sync_update_peer_key, 
scope_update_peer_timestamp = changes.sync_update_peer_timestamp,
local_update_peer_key = 0
FROM 
[UID_Ammessi_tracking] side JOIN 
(SELECT p.[UID], p.sync_update_peer_timestamp, p.sync_update_peer_key, p.sync_create_peer_key, p.sync_create_peer_timestamp FROM @changed t JOIN @changeTable p ON p.[UID] = t.[UID]) AS changes ON changes.[UID] = side.[UID]
SELECT [UID] FROM @changeTable t WHERE NOT EXISTS (SELECT [UID] from @changed i WHERE t.[UID] = i.[UID])
END
