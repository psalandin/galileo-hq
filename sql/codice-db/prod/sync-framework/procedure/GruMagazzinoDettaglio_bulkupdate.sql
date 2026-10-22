CREATE PROCEDURE [GruMagazzinoDettaglio_bulkupdate]
	@sync_min_timestamp BigInt,
	@sync_scope_local_id Int,
	@changeTable [GruMagazzinoDettaglio_BulkType] READONLY
AS
BEGIN
-- use a temp table to store the list of PKs that successfully got updated
declare @changed TABLE ([CodMac] varchar(20), [SlotNo] tinyint, PRIMARY KEY ([CodMac], [SlotNo]));

-- update the base table
MERGE [GruMagazzinoDettaglio] AS base USING
-- join done here against the side table to get the local timestamp for concurrency check
(SELECT p.*, t.update_scope_local_id, t.scope_update_peer_key, t.local_update_peer_timestamp FROM @changeTable p LEFT JOIN [GruMagazzinoDettaglio_tracking] t ON p.[CodMac] = t.[CodMac] AND p.[SlotNo] = t.[SlotNo]) as changes ON changes.[CodMac] = base.[CodMac] AND changes.[SlotNo] = base.[SlotNo]
WHEN MATCHED AND (changes.update_scope_local_id = @sync_scope_local_id AND changes.scope_update_peer_key = changes.sync_update_peer_key) OR changes.local_update_peer_timestamp <= @sync_min_timestamp THEN
UPDATE SET [QtyCurrent] = changes.[QtyCurrent], [AvgValue] = changes.[AvgValue], [LastLoadDate] = changes.[LastLoadDate], [LastWinDate] = changes.[LastWinDate], [UpdatedAt] = changes.[UpdatedAt]
OUTPUT INSERTED.[CodMac], INSERTED.[SlotNo] into @changed; -- populates the temp table with successful PKs

UPDATE side SET
update_scope_local_id = @sync_scope_local_id, 
scope_update_peer_key = changes.sync_update_peer_key, 
scope_update_peer_timestamp = changes.sync_update_peer_timestamp,
local_update_peer_key = 0
FROM 
[GruMagazzinoDettaglio_tracking] side JOIN 
(SELECT p.[CodMac], p.[SlotNo], p.sync_update_peer_timestamp, p.sync_update_peer_key, p.sync_create_peer_key, p.sync_create_peer_timestamp FROM @changed t JOIN @changeTable p ON p.[CodMac] = t.[CodMac] AND p.[SlotNo] = t.[SlotNo]) as changes ON changes.[CodMac] = side.[CodMac] AND changes.[SlotNo] = side.[SlotNo]
SELECT [CodMac], [SlotNo] FROM @changeTable t WHERE NOT EXISTS (SELECT [CodMac], [SlotNo] from @changed i WHERE t.[CodMac] = i.[CodMac] AND t.[SlotNo] = i.[SlotNo])
END
