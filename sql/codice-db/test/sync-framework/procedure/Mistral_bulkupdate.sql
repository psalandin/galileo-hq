CREATE PROCEDURE [Mistral_bulkupdate]
	@sync_min_timestamp BigInt,
	@sync_scope_local_id Int,
	@changeTable [Mistral_BulkType] READONLY
AS
BEGIN
-- use a temp table to store the list of PKs that successfully got updated
declare @changed TABLE ([CodCard] varchar(15), PRIMARY KEY ([CodCard]));

-- update the base table
MERGE [Mistral] AS base USING
-- join done here against the side table to get the local timestamp for concurrency check
(SELECT p.*, t.update_scope_local_id, t.scope_update_peer_key, t.local_update_peer_timestamp FROM @changeTable p LEFT JOIN [Mistral_tracking] t ON p.[CodCard] = t.[CodCard]) as changes ON changes.[CodCard] = base.[CodCard]
WHEN MATCHED AND (changes.update_scope_local_id = @sync_scope_local_id AND changes.scope_update_peer_key = changes.sync_update_peer_key) OR changes.local_update_peer_timestamp <= @sync_min_timestamp THEN
UPDATE SET [Sospeso] = changes.[Sospeso], [Serie] = changes.[Serie], [IDPost] = changes.[IDPost], [F0] = changes.[F0], [T0] = changes.[T0], [N0] = changes.[N0], [D0] = changes.[D0]
OUTPUT INSERTED.[CodCard] into @changed; -- populates the temp table with successful PKs

UPDATE side SET
update_scope_local_id = @sync_scope_local_id, 
scope_update_peer_key = changes.sync_update_peer_key, 
scope_update_peer_timestamp = changes.sync_update_peer_timestamp,
local_update_peer_key = 0
FROM 
[Mistral_tracking] side JOIN 
(SELECT p.[CodCard], p.sync_update_peer_timestamp, p.sync_update_peer_key, p.sync_create_peer_key, p.sync_create_peer_timestamp FROM @changed t JOIN @changeTable p ON p.[CodCard] = t.[CodCard]) as changes ON changes.[CodCard] = side.[CodCard]
SELECT [CodCard] FROM @changeTable t WHERE NOT EXISTS (SELECT [CodCard] from @changed i WHERE t.[CodCard] = i.[CodCard])
END
