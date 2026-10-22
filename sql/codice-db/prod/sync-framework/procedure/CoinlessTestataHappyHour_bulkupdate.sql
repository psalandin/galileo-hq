CREATE PROCEDURE [CoinlessTestataHappyHour_bulkupdate]
	@sync_min_timestamp BigInt,
	@sync_scope_local_id Int,
	@changeTable [CoinlessTestataHappyHour_BulkType] READONLY
AS
BEGIN
-- use a temp table to store the list of PKs that successfully got updated
declare @changed TABLE ([id_happyhour] bigint, PRIMARY KEY ([id_happyhour]));

SET IDENTITY_INSERT [CoinlessTestataHappyHour] ON;
-- update the base table
MERGE [CoinlessTestataHappyHour] AS base USING
-- join done here against the side table to get the local timestamp for concurrency check
(SELECT p.*, t.update_scope_local_id, t.scope_update_peer_key, t.local_update_peer_timestamp FROM @changeTable p LEFT JOIN [CoinlessTestataHappyHour_tracking] t ON p.[id_happyhour] = t.[id_happyhour]) as changes ON changes.[id_happyhour] = base.[id_happyhour]
WHEN MATCHED AND (changes.update_scope_local_id = @sync_scope_local_id AND changes.scope_update_peer_key = changes.sync_update_peer_key) OR changes.local_update_peer_timestamp <= @sync_min_timestamp THEN
UPDATE SET [giorno] = changes.[giorno], [ampm] = changes.[ampm], [dalle] = changes.[dalle], [alle] = changes.[alle], [attivo] = changes.[attivo], [platinum] = changes.[platinum], [gold] = changes.[gold], [silver] = changes.[silver], [normal] = changes.[normal], [dal] = changes.[dal], [al] = changes.[al], [F0] = changes.[F0], [T0] = changes.[T0], [D0] = changes.[D0], [N0] = changes.[N0]
OUTPUT INSERTED.[id_happyhour] into @changed; -- populates the temp table with successful PKs

SET IDENTITY_INSERT [CoinlessTestataHappyHour] OFF;
UPDATE side SET
update_scope_local_id = @sync_scope_local_id, 
scope_update_peer_key = changes.sync_update_peer_key, 
scope_update_peer_timestamp = changes.sync_update_peer_timestamp,
local_update_peer_key = 0
FROM 
[CoinlessTestataHappyHour_tracking] side JOIN 
(SELECT p.[id_happyhour], p.sync_update_peer_timestamp, p.sync_update_peer_key, p.sync_create_peer_key, p.sync_create_peer_timestamp FROM @changed t JOIN @changeTable p ON p.[id_happyhour] = t.[id_happyhour]) as changes ON changes.[id_happyhour] = side.[id_happyhour]
SELECT [id_happyhour] FROM @changeTable t WHERE NOT EXISTS (SELECT [id_happyhour] from @changed i WHERE t.[id_happyhour] = i.[id_happyhour])
END
