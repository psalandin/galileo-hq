CREATE PROCEDURE [GruMovimenti_bulkinsert]
	@sync_min_timestamp BigInt,
	@sync_scope_local_id Int,
	@changeTable [GruMovimenti_BulkType] READONLY
AS
BEGIN
-- use a temp table to store the list of PKs that successfully got updated/inserted
DECLARE @changed TABLE ([IdMovGru] bigint, PRIMARY KEY ([IdMovGru]));

SET IDENTITY_INSERT [GruMovimenti] ON;
-- update/insert into the base table
MERGE [GruMovimenti] AS base USING
-- join done here against the side table to get the local timestamp for concurrency check
(SELECT p.*, t.local_update_peer_timestamp FROM @changeTable p LEFT JOIN [GruMovimenti_tracking] t ON p.[IdMovGru] = t.[IdMovGru]) AS changes ON changes.[IdMovGru] = base.[IdMovGru]
WHEN NOT MATCHED BY TARGET AND changes.local_update_peer_timestamp <= @sync_min_timestamp OR changes.local_update_peer_timestamp IS NULL THEN
INSERT ([IdMovGru], [CodMac], [SlotNo], [MovementType], [PrizeCode], [PrizeDesc], [Qty], [UnitValue], [AvgValueBefore], [AvgValueAfter], [QtyBefore], [QtyAfter], [OperatorId], [Note], [DataMov]) VALUES (changes.[IdMovGru], changes.[CodMac], changes.[SlotNo], changes.[MovementType], changes.[PrizeCode], changes.[PrizeDesc], changes.[Qty], changes.[UnitValue], changes.[AvgValueBefore], changes.[AvgValueAfter], changes.[QtyBefore], changes.[QtyAfter], changes.[OperatorId], changes.[Note], changes.[DataMov])
OUTPUT INSERTED.[IdMovGru] INTO @changed; -- populates the temp table with successful PKs

SET IDENTITY_INSERT [GruMovimenti] OFF;
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
[GruMovimenti_tracking] side JOIN 
(SELECT p.[IdMovGru], p.sync_update_peer_timestamp, p.sync_update_peer_key, p.sync_create_peer_key, p.sync_create_peer_timestamp FROM @changed t JOIN @changeTable p ON p.[IdMovGru] = t.[IdMovGru]) AS changes ON changes.[IdMovGru] = side.[IdMovGru]
SELECT [IdMovGru] FROM @changeTable t WHERE NOT EXISTS (SELECT [IdMovGru] from @changed i WHERE t.[IdMovGru] = i.[IdMovGru])
END
