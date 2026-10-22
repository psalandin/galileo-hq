CREATE PROCEDURE [Setup2_bulkdelete]
	@sync_min_timestamp BigInt,
	@sync_scope_local_id Int,
	@changeTable [Setup2_BulkType] READONLY
AS
BEGIN
-- use a temp table to store the list of PKs that successfully got updated/inserted
declare @changed TABLE ([IdPost] int, [Chiave] nvarchar(255), PRIMARY KEY ([IdPost], [Chiave]));
DELETE [Setup2] 
OUTPUT DELETED.[IdPost], DELETED.[Chiave] INTO @changed FROM [Setup2] base JOIN
(SELECT p.*, t.update_scope_local_id, t.scope_update_peer_key, t.local_update_peer_timestamp FROM @changeTable p JOIN [Setup2_tracking] t ON p.[IdPost] = t.[IdPost] AND p.[Chiave] = t.[Chiave]) as changes ON changes.[IdPost] = base.[IdPost] AND changes.[Chiave] = base.[Chiave] WHERE (changes.update_scope_local_id = @sync_scope_local_id AND changes.scope_update_peer_key = changes.sync_update_peer_key) OR changes.local_update_peer_timestamp <= @sync_min_timestamp
UPDATE side SET
sync_row_is_tombstone = 1, 
update_scope_local_id = @sync_scope_local_id, 
scope_update_peer_key = changes.sync_update_peer_key, 
scope_update_peer_timestamp = changes.sync_update_peer_timestamp,
local_update_peer_key = 0
FROM 
[Setup2_tracking] side JOIN 
(SELECT p.[IdPost], p.[Chiave], p.sync_update_peer_timestamp, p.sync_update_peer_key, p.sync_create_peer_key, p.sync_create_peer_timestamp FROM @changed t JOIN @changeTable p ON p.[IdPost] = t.[IdPost] AND p.[Chiave] = t.[Chiave]) AS changes ON changes.[IdPost] = side.[IdPost] AND changes.[Chiave] = side.[Chiave]
SELECT [IdPost], [Chiave] FROM @changeTable t WHERE NOT EXISTS (SELECT [IdPost], [Chiave] from @changed i WHERE t.[IdPost] = i.[IdPost] AND t.[Chiave] = i.[Chiave])
END
