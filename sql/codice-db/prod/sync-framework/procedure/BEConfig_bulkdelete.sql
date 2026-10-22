CREATE PROCEDURE [BEConfig_bulkdelete]
	@sync_min_timestamp BigInt,
	@sync_scope_local_id Int,
	@changeTable [BEConfig_BulkType] READONLY
AS
BEGIN
-- use a temp table to store the list of PKs that successfully got updated/inserted
declare @changed TABLE ([Macaddress] varchar(17), PRIMARY KEY ([Macaddress]));
DELETE [BEConfig] 
OUTPUT DELETED.[Macaddress] INTO @changed FROM [BEConfig] base JOIN
(SELECT p.*, t.update_scope_local_id, t.scope_update_peer_key, t.local_update_peer_timestamp FROM @changeTable p JOIN [BEConfig_tracking] t ON p.[Macaddress] = t.[Macaddress]) as changes ON changes.[Macaddress] = base.[Macaddress] WHERE (changes.update_scope_local_id = @sync_scope_local_id AND changes.scope_update_peer_key = changes.sync_update_peer_key) OR changes.local_update_peer_timestamp <= @sync_min_timestamp
UPDATE side SET
sync_row_is_tombstone = 1, 
update_scope_local_id = @sync_scope_local_id, 
scope_update_peer_key = changes.sync_update_peer_key, 
scope_update_peer_timestamp = changes.sync_update_peer_timestamp,
local_update_peer_key = 0
FROM 
[BEConfig_tracking] side JOIN 
(SELECT p.[Macaddress], p.sync_update_peer_timestamp, p.sync_update_peer_key, p.sync_create_peer_key, p.sync_create_peer_timestamp FROM @changed t JOIN @changeTable p ON p.[Macaddress] = t.[Macaddress]) AS changes ON changes.[Macaddress] = side.[Macaddress]
SELECT [Macaddress] FROM @changeTable t WHERE NOT EXISTS (SELECT [Macaddress] from @changed i WHERE t.[Macaddress] = i.[Macaddress])
END
