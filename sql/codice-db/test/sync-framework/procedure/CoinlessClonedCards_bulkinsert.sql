CREATE PROCEDURE [CoinlessClonedCards_bulkinsert]
	@sync_min_timestamp BigInt,
	@sync_scope_local_id Int,
	@changeTable [CoinlessClonedCards_BulkType] READONLY
AS
BEGIN
-- use a temp table to store the list of PKs that successfully got updated/inserted
DECLARE @changed TABLE ([id_card_clonate] bigint, PRIMARY KEY ([id_card_clonate]));

SET IDENTITY_INSERT [CoinlessClonedCards] ON;
-- update/insert into the base table
MERGE [CoinlessClonedCards] AS base USING
-- join done here against the side table to get the local timestamp for concurrency check
(SELECT p.*, t.local_update_peer_timestamp FROM @changeTable p LEFT JOIN [CoinlessClonedCards_tracking] t ON p.[id_card_clonate] = t.[id_card_clonate]) AS changes ON changes.[id_card_clonate] = base.[id_card_clonate]
WHEN NOT MATCHED BY TARGET AND changes.local_update_peer_timestamp <= @sync_min_timestamp OR changes.local_update_peer_timestamp IS NULL THEN
INSERT ([id_card_clonate], [cardid], [DataMovimento], [TipoMovimento], [SaldoCard], [CostoPartita], [LivelloCard], [device], [CodMac], [N0]) VALUES (changes.[id_card_clonate], changes.[cardid], changes.[DataMovimento], changes.[TipoMovimento], changes.[SaldoCard], changes.[CostoPartita], changes.[LivelloCard], changes.[device], changes.[CodMac], changes.[N0])
OUTPUT INSERTED.[id_card_clonate] INTO @changed; -- populates the temp table with successful PKs

SET IDENTITY_INSERT [CoinlessClonedCards] OFF;
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
[CoinlessClonedCards_tracking] side JOIN 
(SELECT p.[id_card_clonate], p.sync_update_peer_timestamp, p.sync_update_peer_key, p.sync_create_peer_key, p.sync_create_peer_timestamp FROM @changed t JOIN @changeTable p ON p.[id_card_clonate] = t.[id_card_clonate]) AS changes ON changes.[id_card_clonate] = side.[id_card_clonate]
SELECT [id_card_clonate] FROM @changeTable t WHERE NOT EXISTS (SELECT [id_card_clonate] from @changed i WHERE t.[id_card_clonate] = i.[id_card_clonate])
END
