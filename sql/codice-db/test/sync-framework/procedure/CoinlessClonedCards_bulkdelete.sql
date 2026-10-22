CREATE PROCEDURE [CoinlessClonedCards_bulkdelete]
	@sync_min_timestamp BigInt,
	@sync_scope_local_id Int,
	@changeTable [CoinlessClonedCards_BulkType] READONLY
AS
BEGIN
-- use a temp table to store the list of PKs that successfully got updated/inserted
declare @changed TABLE ([id_card_clonate] bigint, PRIMARY KEY ([id_card_clonate]));
DELETE [CoinlessClonedCards] 
OUTPUT DELETED.[id_card_clonate] INTO @changed FROM [CoinlessClonedCards] base JOIN
(SELECT p.*, t.update_scope_local_id, t.scope_update_peer_key, t.local_update_peer_timestamp FROM @changeTable p JOIN [CoinlessClonedCards_tracking] t ON p.[id_card_clonate] = t.[id_card_clonate]) as changes ON changes.[id_card_clonate] = base.[id_card_clonate] WHERE (changes.update_scope_local_id = @sync_scope_local_id AND changes.scope_update_peer_key = changes.sync_update_peer_key) OR changes.local_update_peer_timestamp <= @sync_min_timestamp
UPDATE side SET
sync_row_is_tombstone = 1, 
update_scope_local_id = @sync_scope_local_id, 
scope_update_peer_key = changes.sync_update_peer_key, 
scope_update_peer_timestamp = changes.sync_update_peer_timestamp,
local_update_peer_key = 0
FROM 
[CoinlessClonedCards_tracking] side JOIN 
(SELECT p.[id_card_clonate], p.sync_update_peer_timestamp, p.sync_update_peer_key, p.sync_create_peer_key, p.sync_create_peer_timestamp FROM @changed t JOIN @changeTable p ON p.[id_card_clonate] = t.[id_card_clonate]) AS changes ON changes.[id_card_clonate] = side.[id_card_clonate]
SELECT [id_card_clonate] FROM @changeTable t WHERE NOT EXISTS (SELECT [id_card_clonate] from @changed i WHERE t.[id_card_clonate] = i.[id_card_clonate])
END
