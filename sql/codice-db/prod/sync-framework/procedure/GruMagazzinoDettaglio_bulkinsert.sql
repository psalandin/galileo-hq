CREATE PROCEDURE [GruMagazzinoDettaglio_bulkinsert]
	@sync_min_timestamp BigInt,
	@sync_scope_local_id Int,
	@changeTable [GruMagazzinoDettaglio_BulkType] READONLY
AS
BEGIN
-- use a temp table to store the list of PKs that successfully got updated/inserted
DECLARE @changed TABLE ([CodMac] varchar(20), [SlotNo] tinyint, PRIMARY KEY ([CodMac], [SlotNo]));

-- update/insert into the base table
MERGE [GruMagazzinoDettaglio] AS base USING
-- join done here against the side table to get the local timestamp for concurrency check
(SELECT p.*, t.local_update_peer_timestamp FROM @changeTable p LEFT JOIN [GruMagazzinoDettaglio_tracking] t ON p.[CodMac] = t.[CodMac] AND p.[SlotNo] = t.[SlotNo]) AS changes ON changes.[CodMac] = base.[CodMac] AND changes.[SlotNo] = base.[SlotNo]
WHEN NOT MATCHED BY TARGET AND changes.local_update_peer_timestamp <= @sync_min_timestamp OR changes.local_update_peer_timestamp IS NULL THEN
INSERT ([CodMac], [SlotNo], [QtyCurrent], [AvgValue], [LastLoadDate], [LastWinDate], [UpdatedAt]) VALUES (changes.[CodMac], changes.[SlotNo], changes.[QtyCurrent], changes.[AvgValue], changes.[LastLoadDate], changes.[LastWinDate], changes.[UpdatedAt])
OUTPUT INSERTED.[CodMac], INSERTED.[SlotNo] INTO @changed; -- populates the temp table with successful PKs

UPDATE side SET
update_scope_local_id = @sync_scope_local_id, 
scope_update_peer_key = changes.sync_update_peer_key, 
scope_update_peer_timestamp = changes.sync_update_peer_timestamp,
local_update_peer_key = 0,
create_scope_local_id = @sync_scope_local_id,
scope_create_peer_key = changes.sync_create_peer_key,
scope_create_peer_timestamp = changes.sync_create_peer_timestamp,
local_create_peer_key = 0
FROM 
[GruMagazzinoDettaglio_tracking] side JOIN 
(SELECT p.[CodMac], p.[SlotNo], p.sync_update_peer_timestamp, p.sync_update_peer_key, p.sync_create_peer_key, p.sync_create_peer_timestamp FROM @changed t JOIN @changeTable p ON p.[CodMac] = t.[CodMac] AND p.[SlotNo] = t.[SlotNo]) AS changes ON changes.[CodMac] = side.[CodMac] AND changes.[SlotNo] = side.[SlotNo]
SELECT [CodMac], [SlotNo] FROM @changeTable t WHERE NOT EXISTS (SELECT [CodMac], [SlotNo] from @changed i WHERE t.[CodMac] = i.[CodMac] AND t.[SlotNo] = i.[SlotNo])
END
