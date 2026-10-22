CREATE PROCEDURE [GruMagazzino_bulkinsert]
	@sync_min_timestamp BigInt,
	@sync_scope_local_id Int,
	@changeTable [GruMagazzino_BulkType] READONLY
AS
BEGIN
-- use a temp table to store the list of PKs that successfully got updated/inserted
DECLARE @changed TABLE ([CodMac] varchar(20), PRIMARY KEY ([CodMac]));

-- update/insert into the base table
MERGE [GruMagazzino] AS base USING
-- join done here against the side table to get the local timestamp for concurrency check
(SELECT p.*, t.local_update_peer_timestamp FROM @changeTable p LEFT JOIN [GruMagazzino_tracking] t ON p.[CodMac] = t.[CodMac]) AS changes ON changes.[CodMac] = base.[CodMac]
WHEN NOT MATCHED BY TARGET AND changes.local_update_peer_timestamp <= @sync_min_timestamp OR changes.local_update_peer_timestamp IS NULL THEN
INSERT ([CodMac], [Enabled], [CreatedAt], [UpdatedAt]) VALUES (changes.[CodMac], changes.[Enabled], changes.[CreatedAt], changes.[UpdatedAt])
OUTPUT INSERTED.[CodMac] INTO @changed; -- populates the temp table with successful PKs

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
[GruMagazzino_tracking] side JOIN 
(SELECT p.[CodMac], p.sync_update_peer_timestamp, p.sync_update_peer_key, p.sync_create_peer_key, p.sync_create_peer_timestamp FROM @changed t JOIN @changeTable p ON p.[CodMac] = t.[CodMac]) AS changes ON changes.[CodMac] = side.[CodMac]
SELECT [CodMac] FROM @changeTable t WHERE NOT EXISTS (SELECT [CodMac] from @changed i WHERE t.[CodMac] = i.[CodMac])
END
