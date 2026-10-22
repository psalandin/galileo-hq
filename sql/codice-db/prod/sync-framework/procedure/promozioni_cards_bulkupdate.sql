CREATE PROCEDURE [promozioni_cards_bulkupdate]
	@sync_min_timestamp BigInt,
	@sync_scope_local_id Int,
	@changeTable [promozioni_cards_BulkType] READONLY
AS
BEGIN
-- use a temp table to store the list of PKs that successfully got updated
declare @changed TABLE ([id] bigint, PRIMARY KEY ([id]));

SET IDENTITY_INSERT [promozioni_cards] ON;
-- update the base table
MERGE [promozioni_cards] AS base USING
-- join done here against the side table to get the local timestamp for concurrency check
(SELECT p.*, t.update_scope_local_id, t.scope_update_peer_key, t.local_update_peer_timestamp FROM @changeTable p LEFT JOIN [promozioni_cards_tracking] t ON p.[id] = t.[id]) as changes ON changes.[id] = base.[id]
WHEN MATCHED AND (changes.update_scope_local_id = @sync_scope_local_id AND changes.scope_update_peer_key = changes.sync_update_peer_key) OR changes.local_update_peer_timestamp <= @sync_min_timestamp THEN
UPDATE SET [idpromozione] = changes.[idpromozione], [cardid] = changes.[cardid], [livelloPrecedente] = changes.[livelloPrecedente], [CreatedAt] = changes.[CreatedAt]
OUTPUT INSERTED.[id] into @changed; -- populates the temp table with successful PKs

SET IDENTITY_INSERT [promozioni_cards] OFF;
UPDATE side SET
update_scope_local_id = @sync_scope_local_id, 
scope_update_peer_key = changes.sync_update_peer_key, 
scope_update_peer_timestamp = changes.sync_update_peer_timestamp,
local_update_peer_key = 0
FROM 
[promozioni_cards_tracking] side JOIN 
(SELECT p.[id], p.sync_update_peer_timestamp, p.sync_update_peer_key, p.sync_create_peer_key, p.sync_create_peer_timestamp FROM @changed t JOIN @changeTable p ON p.[id] = t.[id]) as changes ON changes.[id] = side.[id]
SELECT [id] FROM @changeTable t WHERE NOT EXISTS (SELECT [id] from @changed i WHERE t.[id] = i.[id])
END
