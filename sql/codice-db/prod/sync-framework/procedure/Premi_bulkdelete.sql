CREATE PROCEDURE [Premi_bulkdelete]
	@sync_min_timestamp BigInt,
	@sync_scope_local_id Int,
	@changeTable [Premi_BulkType] READONLY
AS
BEGIN
-- use a temp table to store the list of PKs that successfully got updated/inserted
declare @changed TABLE ([Codice] varchar(50), PRIMARY KEY ([Codice]));
DELETE [Premi] 
OUTPUT DELETED.[Codice] INTO @changed FROM [Premi] base JOIN
(SELECT p.*, t.update_scope_local_id, t.scope_update_peer_key, t.local_update_peer_timestamp FROM @changeTable p JOIN [Premi_tracking] t ON p.[Codice] = t.[Codice]) as changes ON changes.[Codice] = base.[Codice] WHERE (changes.update_scope_local_id = @sync_scope_local_id AND changes.scope_update_peer_key = changes.sync_update_peer_key) OR changes.local_update_peer_timestamp <= @sync_min_timestamp
UPDATE side SET
sync_row_is_tombstone = 1, 
update_scope_local_id = @sync_scope_local_id, 
scope_update_peer_key = changes.sync_update_peer_key, 
scope_update_peer_timestamp = changes.sync_update_peer_timestamp,
local_update_peer_key = 0
FROM 
[Premi_tracking] side JOIN 
(SELECT p.[Codice], p.sync_update_peer_timestamp, p.sync_update_peer_key, p.sync_create_peer_key, p.sync_create_peer_timestamp FROM @changed t JOIN @changeTable p ON p.[Codice] = t.[Codice]) AS changes ON changes.[Codice] = side.[Codice]
SELECT [Codice] FROM @changeTable t WHERE NOT EXISTS (SELECT [Codice] from @changed i WHERE t.[Codice] = i.[Codice])
END
