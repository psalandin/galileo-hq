CREATE PROCEDURE [CoinlessTestataHappyHour_bulkdelete]
	@sync_min_timestamp BigInt,
	@sync_scope_local_id Int,
	@changeTable [CoinlessTestataHappyHour_BulkType] READONLY
AS
BEGIN
-- use a temp table to store the list of PKs that successfully got updated/inserted
declare @changed TABLE ([id_happyhour] bigint, PRIMARY KEY ([id_happyhour]));
DELETE [CoinlessTestataHappyHour] 
OUTPUT DELETED.[id_happyhour] INTO @changed FROM [CoinlessTestataHappyHour] base JOIN
(SELECT p.*, t.update_scope_local_id, t.scope_update_peer_key, t.local_update_peer_timestamp FROM @changeTable p JOIN [CoinlessTestataHappyHour_tracking] t ON p.[id_happyhour] = t.[id_happyhour]) as changes ON changes.[id_happyhour] = base.[id_happyhour] WHERE (changes.update_scope_local_id = @sync_scope_local_id AND changes.scope_update_peer_key = changes.sync_update_peer_key) OR changes.local_update_peer_timestamp <= @sync_min_timestamp
UPDATE side SET
sync_row_is_tombstone = 1, 
update_scope_local_id = @sync_scope_local_id, 
scope_update_peer_key = changes.sync_update_peer_key, 
scope_update_peer_timestamp = changes.sync_update_peer_timestamp,
local_update_peer_key = 0
FROM 
[CoinlessTestataHappyHour_tracking] side JOIN 
(SELECT p.[id_happyhour], p.sync_update_peer_timestamp, p.sync_update_peer_key, p.sync_create_peer_key, p.sync_create_peer_timestamp FROM @changed t JOIN @changeTable p ON p.[id_happyhour] = t.[id_happyhour]) AS changes ON changes.[id_happyhour] = side.[id_happyhour]
SELECT [id_happyhour] FROM @changeTable t WHERE NOT EXISTS (SELECT [id_happyhour] from @changed i WHERE t.[id_happyhour] = i.[id_happyhour])
END
