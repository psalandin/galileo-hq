CREATE PROCEDURE [CoinlessMacchineHappyHour_bulkinsert]
	@sync_min_timestamp BigInt,
	@sync_scope_local_id Int,
	@changeTable [CoinlessMacchineHappyHour_BulkType] READONLY
AS
BEGIN
-- use a temp table to store the list of PKs that successfully got updated/inserted
DECLARE @changed TABLE ([id_macchineHappyHour] bigint, PRIMARY KEY ([id_macchineHappyHour]));

SET IDENTITY_INSERT [CoinlessMacchineHappyHour] ON;
-- update/insert into the base table
MERGE [CoinlessMacchineHappyHour] AS base USING
-- join done here against the side table to get the local timestamp for concurrency check
(SELECT p.*, t.local_update_peer_timestamp FROM @changeTable p LEFT JOIN [CoinlessMacchineHappyHour_tracking] t ON p.[id_macchineHappyHour] = t.[id_macchineHappyHour]) AS changes ON changes.[id_macchineHappyHour] = base.[id_macchineHappyHour]
WHEN NOT MATCHED BY TARGET AND changes.local_update_peer_timestamp <= @sync_min_timestamp OR changes.local_update_peer_timestamp IS NULL THEN
INSERT ([id_macchineHappyHour], [fk_testata], [codmac], [device], [perc_platinum], [perc_gold], [perc_silver], [perc_normal]) VALUES (changes.[id_macchineHappyHour], changes.[fk_testata], changes.[codmac], changes.[device], changes.[perc_platinum], changes.[perc_gold], changes.[perc_silver], changes.[perc_normal])
OUTPUT INSERTED.[id_macchineHappyHour] INTO @changed; -- populates the temp table with successful PKs

SET IDENTITY_INSERT [CoinlessMacchineHappyHour] OFF;
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
[CoinlessMacchineHappyHour_tracking] side JOIN 
(SELECT p.[id_macchineHappyHour], p.sync_update_peer_timestamp, p.sync_update_peer_key, p.sync_create_peer_key, p.sync_create_peer_timestamp FROM @changed t JOIN @changeTable p ON p.[id_macchineHappyHour] = t.[id_macchineHappyHour]) AS changes ON changes.[id_macchineHappyHour] = side.[id_macchineHappyHour]
SELECT [id_macchineHappyHour] FROM @changeTable t WHERE NOT EXISTS (SELECT [id_macchineHappyHour] from @changed i WHERE t.[id_macchineHappyHour] = i.[id_macchineHappyHour])
END
