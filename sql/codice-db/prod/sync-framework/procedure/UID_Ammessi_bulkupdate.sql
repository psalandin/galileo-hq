CREATE PROCEDURE [UID_Ammessi_bulkupdate]
	@sync_min_timestamp BigInt,
	@sync_scope_local_id Int,
	@changeTable [UID_Ammessi_BulkType] READONLY
AS
BEGIN
-- use a temp table to store the list of PKs that successfully got updated
declare @changed TABLE ([UID] varchar(16), PRIMARY KEY ([UID]));

-- update the base table
MERGE [UID_Ammessi] AS base USING
-- join done here against the side table to get the local timestamp for concurrency check
(SELECT p.*, t.update_scope_local_id, t.scope_update_peer_key, t.local_update_peer_timestamp FROM @changeTable p LEFT JOIN [UID_Ammessi_tracking] t ON p.[UID] = t.[UID]) as changes ON changes.[UID] = base.[UID]
WHEN MATCHED AND (changes.update_scope_local_id = @sync_scope_local_id AND changes.scope_update_peer_key = changes.sync_update_peer_key) OR changes.local_update_peer_timestamp <= @sync_min_timestamp THEN
UPDATE SET [CodBar] = changes.[CodBar], [DataCreazione] = changes.[DataCreazione], [DataEmissione] = changes.[DataEmissione]
OUTPUT INSERTED.[UID] into @changed; -- populates the temp table with successful PKs

UPDATE side SET
update_scope_local_id = @sync_scope_local_id, 
scope_update_peer_key = changes.sync_update_peer_key, 
scope_update_peer_timestamp = changes.sync_update_peer_timestamp,
local_update_peer_key = 0
FROM 
[UID_Ammessi_tracking] side JOIN 
(SELECT p.[UID], p.sync_update_peer_timestamp, p.sync_update_peer_key, p.sync_create_peer_key, p.sync_create_peer_timestamp FROM @changed t JOIN @changeTable p ON p.[UID] = t.[UID]) as changes ON changes.[UID] = side.[UID]
SELECT [UID] FROM @changeTable t WHERE NOT EXISTS (SELECT [UID] from @changed i WHERE t.[UID] = i.[UID])
END
