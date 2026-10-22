CREATE PROCEDURE [EcsMacchine_bulkdelete]
	@sync_min_timestamp BigInt,
	@sync_scope_local_id Int,
	@changeTable [EcsMacchine_BulkType] READONLY
AS
BEGIN
-- use a temp table to store the list of PKs that successfully got updated/inserted
declare @changed TABLE ([CodMac] varchar(15), PRIMARY KEY ([CodMac]));
DELETE [EcsMacchine] 
OUTPUT DELETED.[CodMac] INTO @changed FROM [EcsMacchine] base JOIN
(SELECT p.*, t.update_scope_local_id, t.scope_update_peer_key, t.local_update_peer_timestamp FROM @changeTable p JOIN [EcsMacchine_tracking] t ON p.[CodMac] = t.[CodMac]) as changes ON changes.[CodMac] = base.[CodMac] WHERE (changes.update_scope_local_id = @sync_scope_local_id AND changes.scope_update_peer_key = changes.sync_update_peer_key) OR changes.local_update_peer_timestamp <= @sync_min_timestamp
UPDATE side SET
sync_row_is_tombstone = 1, 
update_scope_local_id = @sync_scope_local_id, 
scope_update_peer_key = changes.sync_update_peer_key, 
scope_update_peer_timestamp = changes.sync_update_peer_timestamp,
local_update_peer_key = 0
FROM 
[EcsMacchine_tracking] side JOIN 
(SELECT p.[CodMac], p.sync_update_peer_timestamp, p.sync_update_peer_key, p.sync_create_peer_key, p.sync_create_peer_timestamp FROM @changed t JOIN @changeTable p ON p.[CodMac] = t.[CodMac]) AS changes ON changes.[CodMac] = side.[CodMac]
SELECT [CodMac] FROM @changeTable t WHERE NOT EXISTS (SELECT [CodMac] from @changed i WHERE t.[CodMac] = i.[CodMac])
END
