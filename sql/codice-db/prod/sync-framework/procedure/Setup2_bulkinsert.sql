CREATE PROCEDURE [Setup2_bulkinsert]
	@sync_min_timestamp BigInt,
	@sync_scope_local_id Int,
	@changeTable [Setup2_BulkType] READONLY
AS
BEGIN
-- use a temp table to store the list of PKs that successfully got updated/inserted
DECLARE @changed TABLE ([IdPost] int, [Chiave] nvarchar(255), PRIMARY KEY ([IdPost], [Chiave]));

-- update/insert into the base table
MERGE [Setup2] AS base USING
-- join done here against the side table to get the local timestamp for concurrency check
(SELECT p.*, t.local_update_peer_timestamp FROM @changeTable p LEFT JOIN [Setup2_tracking] t ON p.[IdPost] = t.[IdPost] AND p.[Chiave] = t.[Chiave]) AS changes ON changes.[IdPost] = base.[IdPost] AND changes.[Chiave] = base.[Chiave]
WHEN NOT MATCHED BY TARGET AND changes.local_update_peer_timestamp <= @sync_min_timestamp OR changes.local_update_peer_timestamp IS NULL THEN
INSERT ([IdPost], [Chiave], [Valore]) VALUES (changes.[IdPost], changes.[Chiave], changes.[Valore])
OUTPUT INSERTED.[IdPost], INSERTED.[Chiave] INTO @changed; -- populates the temp table with successful PKs

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
[Setup2_tracking] side JOIN 
(SELECT p.[IdPost], p.[Chiave], p.sync_update_peer_timestamp, p.sync_update_peer_key, p.sync_create_peer_key, p.sync_create_peer_timestamp FROM @changed t JOIN @changeTable p ON p.[IdPost] = t.[IdPost] AND p.[Chiave] = t.[Chiave]) AS changes ON changes.[IdPost] = side.[IdPost] AND changes.[Chiave] = side.[Chiave]
SELECT [IdPost], [Chiave] FROM @changeTable t WHERE NOT EXISTS (SELECT [IdPost], [Chiave] from @changed i WHERE t.[IdPost] = i.[IdPost] AND t.[Chiave] = i.[Chiave])
END
