CREATE PROCEDURE [GruMagazzinoDettaglio_bulkdelete]
	@sync_min_timestamp BigInt,
	@sync_scope_local_id Int,
	@changeTable [GruMagazzinoDettaglio_BulkType] READONLY
AS
BEGIN
-- use a temp table to store the list of PKs that successfully got updated/inserted
declare @changed TABLE ([CodMac] varchar(20), [SlotNo] tinyint, PRIMARY KEY ([CodMac], [SlotNo]));
DELETE [GruMagazzinoDettaglio] 
OUTPUT DELETED.[CodMac], DELETED.[SlotNo] INTO @changed FROM [GruMagazzinoDettaglio] base JOIN
(SELECT p.*, t.update_scope_local_id, t.scope_update_peer_key, t.local_update_peer_timestamp FROM @changeTable p JOIN [GruMagazzinoDettaglio_tracking] t ON p.[CodMac] = t.[CodMac] AND p.[SlotNo] = t.[SlotNo]) as changes ON changes.[CodMac] = base.[CodMac] AND changes.[SlotNo] = base.[SlotNo] WHERE (changes.update_scope_local_id = @sync_scope_local_id AND changes.scope_update_peer_key = changes.sync_update_peer_key) OR changes.local_update_peer_timestamp <= @sync_min_timestamp
UPDATE side SET
sync_row_is_tombstone = 1, 
update_scope_local_id = @sync_scope_local_id, 
scope_update_peer_key = changes.sync_update_peer_key, 
scope_update_peer_timestamp = changes.sync_update_peer_timestamp,
local_update_peer_key = 0
FROM 
[GruMagazzinoDettaglio_tracking] side JOIN 
(SELECT p.[CodMac], p.[SlotNo], p.sync_update_peer_timestamp, p.sync_update_peer_key, p.sync_create_peer_key, p.sync_create_peer_timestamp FROM @changed t JOIN @changeTable p ON p.[CodMac] = t.[CodMac] AND p.[SlotNo] = t.[SlotNo]) AS changes ON changes.[CodMac] = side.[CodMac] AND changes.[SlotNo] = side.[SlotNo]
SELECT [CodMac], [SlotNo] FROM @changeTable t WHERE NOT EXISTS (SELECT [CodMac], [SlotNo] from @changed i WHERE t.[CodMac] = i.[CodMac] AND t.[SlotNo] = i.[SlotNo])
END
