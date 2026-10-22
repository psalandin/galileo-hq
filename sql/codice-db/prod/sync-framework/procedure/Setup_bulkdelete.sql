CREATE PROCEDURE [Setup_bulkdelete]
	@sync_min_timestamp BigInt,
	@sync_scope_local_id Int,
	@changeTable [Setup_BulkType] READONLY
AS
BEGIN
-- use a temp table to store the list of PKs that successfully got updated/inserted
declare @changed TABLE ([IDPost] tinyint, PRIMARY KEY ([IDPost]));
DELETE [Setup] 
OUTPUT DELETED.[IDPost] INTO @changed FROM [Setup] base JOIN
(SELECT p.*, t.update_scope_local_id, t.scope_update_peer_key, t.local_update_peer_timestamp FROM @changeTable p JOIN [Setup_tracking] t ON p.[IDPost] = t.[IDPost]) as changes ON changes.[IDPost] = base.[IDPost] WHERE (changes.update_scope_local_id = @sync_scope_local_id AND changes.scope_update_peer_key = changes.sync_update_peer_key) OR changes.local_update_peer_timestamp <= @sync_min_timestamp
UPDATE side SET
sync_row_is_tombstone = 1, 
update_scope_local_id = @sync_scope_local_id, 
scope_update_peer_key = changes.sync_update_peer_key, 
scope_update_peer_timestamp = changes.sync_update_peer_timestamp,
local_update_peer_key = 0
FROM 
[Setup_tracking] side JOIN 
(SELECT p.[IDPost], p.sync_update_peer_timestamp, p.sync_update_peer_key, p.sync_create_peer_key, p.sync_create_peer_timestamp FROM @changed t JOIN @changeTable p ON p.[IDPost] = t.[IDPost]) AS changes ON changes.[IDPost] = side.[IDPost]
SELECT [IDPost] FROM @changeTable t WHERE NOT EXISTS (SELECT [IDPost] from @changed i WHERE t.[IDPost] = i.[IDPost])
END
