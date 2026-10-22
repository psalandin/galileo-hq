CREATE PROCEDURE [Ospiti_bulkupdate]
	@sync_min_timestamp BigInt,
	@sync_scope_local_id Int,
	@changeTable [Ospiti_BulkType] READONLY
AS
BEGIN
-- use a temp table to store the list of PKs that successfully got updated
declare @changed TABLE ([IdOspite] bigint, PRIMARY KEY ([IdOspite]));

SET IDENTITY_INSERT [Ospiti] ON;
-- update the base table
MERGE [Ospiti] AS base USING
-- join done here against the side table to get the local timestamp for concurrency check
(SELECT p.*, t.update_scope_local_id, t.scope_update_peer_key, t.local_update_peer_timestamp FROM @changeTable p LEFT JOIN [Ospiti_tracking] t ON p.[IdOspite] = t.[IdOspite]) as changes ON changes.[IdOspite] = base.[IdOspite]
WHEN MATCHED AND (changes.update_scope_local_id = @sync_scope_local_id AND changes.scope_update_peer_key = changes.sync_update_peer_key) OR changes.local_update_peer_timestamp <= @sync_min_timestamp THEN
UPDATE SET [IdCompleanno] = changes.[IdCompleanno], [CardId] = changes.[CardId], [IdContatto] = changes.[IdContatto], [CreatedBy] = changes.[CreatedBy], [CreatedAt] = changes.[CreatedAt], [UpdatedBy] = changes.[UpdatedBy], [UpdatedAt] = changes.[UpdatedAt]
OUTPUT INSERTED.[IdOspite] into @changed; -- populates the temp table with successful PKs

SET IDENTITY_INSERT [Ospiti] OFF;
UPDATE side SET
update_scope_local_id = @sync_scope_local_id, 
scope_update_peer_key = changes.sync_update_peer_key, 
scope_update_peer_timestamp = changes.sync_update_peer_timestamp,
local_update_peer_key = 0
FROM 
[Ospiti_tracking] side JOIN 
(SELECT p.[IdOspite], p.sync_update_peer_timestamp, p.sync_update_peer_key, p.sync_create_peer_key, p.sync_create_peer_timestamp FROM @changed t JOIN @changeTable p ON p.[IdOspite] = t.[IdOspite]) as changes ON changes.[IdOspite] = side.[IdOspite]
SELECT [IdOspite] FROM @changeTable t WHERE NOT EXISTS (SELECT [IdOspite] from @changed i WHERE t.[IdOspite] = i.[IdOspite])
END
