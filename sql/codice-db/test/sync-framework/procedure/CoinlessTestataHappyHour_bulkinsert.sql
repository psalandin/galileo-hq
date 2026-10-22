CREATE PROCEDURE [CoinlessTestataHappyHour_bulkinsert]
	@sync_min_timestamp BigInt,
	@sync_scope_local_id Int,
	@changeTable [CoinlessTestataHappyHour_BulkType] READONLY
AS
BEGIN
-- use a temp table to store the list of PKs that successfully got updated/inserted
DECLARE @changed TABLE ([id_happyhour] bigint, PRIMARY KEY ([id_happyhour]));

SET IDENTITY_INSERT [CoinlessTestataHappyHour] ON;
-- update/insert into the base table
MERGE [CoinlessTestataHappyHour] AS base USING
-- join done here against the side table to get the local timestamp for concurrency check
(SELECT p.*, t.local_update_peer_timestamp FROM @changeTable p LEFT JOIN [CoinlessTestataHappyHour_tracking] t ON p.[id_happyhour] = t.[id_happyhour]) AS changes ON changes.[id_happyhour] = base.[id_happyhour]
WHEN NOT MATCHED BY TARGET AND changes.local_update_peer_timestamp <= @sync_min_timestamp OR changes.local_update_peer_timestamp IS NULL THEN
INSERT ([id_happyhour], [giorno], [ampm], [dalle], [alle], [attivo], [platinum], [gold], [silver], [normal], [dal], [al], [F0], [T0], [D0], [N0]) VALUES (changes.[id_happyhour], changes.[giorno], changes.[ampm], changes.[dalle], changes.[alle], changes.[attivo], changes.[platinum], changes.[gold], changes.[silver], changes.[normal], changes.[dal], changes.[al], changes.[F0], changes.[T0], changes.[D0], changes.[N0])
OUTPUT INSERTED.[id_happyhour] INTO @changed; -- populates the temp table with successful PKs

SET IDENTITY_INSERT [CoinlessTestataHappyHour] OFF;
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
[CoinlessTestataHappyHour_tracking] side JOIN 
(SELECT p.[id_happyhour], p.sync_update_peer_timestamp, p.sync_update_peer_key, p.sync_create_peer_key, p.sync_create_peer_timestamp FROM @changed t JOIN @changeTable p ON p.[id_happyhour] = t.[id_happyhour]) AS changes ON changes.[id_happyhour] = side.[id_happyhour]
SELECT [id_happyhour] FROM @changeTable t WHERE NOT EXISTS (SELECT [id_happyhour] from @changed i WHERE t.[id_happyhour] = i.[id_happyhour])
END
