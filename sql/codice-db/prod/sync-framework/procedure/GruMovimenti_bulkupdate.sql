CREATE PROCEDURE [GruMovimenti_bulkupdate]
	@sync_min_timestamp BigInt,
	@sync_scope_local_id Int,
	@changeTable [GruMovimenti_BulkType] READONLY
AS
BEGIN
-- use a temp table to store the list of PKs that successfully got updated
declare @changed TABLE ([IdMovGru] bigint, PRIMARY KEY ([IdMovGru]));

SET IDENTITY_INSERT [GruMovimenti] ON;
-- update the base table
MERGE [GruMovimenti] AS base USING
-- join done here against the side table to get the local timestamp for concurrency check
(SELECT p.*, t.update_scope_local_id, t.scope_update_peer_key, t.local_update_peer_timestamp FROM @changeTable p LEFT JOIN [GruMovimenti_tracking] t ON p.[IdMovGru] = t.[IdMovGru]) as changes ON changes.[IdMovGru] = base.[IdMovGru]
WHEN MATCHED AND (changes.update_scope_local_id = @sync_scope_local_id AND changes.scope_update_peer_key = changes.sync_update_peer_key) OR changes.local_update_peer_timestamp <= @sync_min_timestamp THEN
UPDATE SET [CodMac] = changes.[CodMac], [SlotNo] = changes.[SlotNo], [MovementType] = changes.[MovementType], [PrizeCode] = changes.[PrizeCode], [PrizeDesc] = changes.[PrizeDesc], [Qty] = changes.[Qty], [UnitValue] = changes.[UnitValue], [AvgValueBefore] = changes.[AvgValueBefore], [AvgValueAfter] = changes.[AvgValueAfter], [QtyBefore] = changes.[QtyBefore], [QtyAfter] = changes.[QtyAfter], [OperatorId] = changes.[OperatorId], [Note] = changes.[Note], [DataMov] = changes.[DataMov]
OUTPUT INSERTED.[IdMovGru] into @changed; -- populates the temp table with successful PKs

SET IDENTITY_INSERT [GruMovimenti] OFF;
UPDATE side SET
update_scope_local_id = @sync_scope_local_id, 
scope_update_peer_key = changes.sync_update_peer_key, 
scope_update_peer_timestamp = changes.sync_update_peer_timestamp,
local_update_peer_key = 0
FROM 
[GruMovimenti_tracking] side JOIN 
(SELECT p.[IdMovGru], p.sync_update_peer_timestamp, p.sync_update_peer_key, p.sync_create_peer_key, p.sync_create_peer_timestamp FROM @changed t JOIN @changeTable p ON p.[IdMovGru] = t.[IdMovGru]) as changes ON changes.[IdMovGru] = side.[IdMovGru]
SELECT [IdMovGru] FROM @changeTable t WHERE NOT EXISTS (SELECT [IdMovGru] from @changed i WHERE t.[IdMovGru] = i.[IdMovGru])
END
