CREATE PROCEDURE [CoinlessMacchineHappyHour_bulkupdate]
	@sync_min_timestamp BigInt,
	@sync_scope_local_id Int,
	@changeTable [CoinlessMacchineHappyHour_BulkType] READONLY
AS
BEGIN
-- use a temp table to store the list of PKs that successfully got updated
declare @changed TABLE ([id_macchineHappyHour] bigint, PRIMARY KEY ([id_macchineHappyHour]));

SET IDENTITY_INSERT [CoinlessMacchineHappyHour] ON;
-- update the base table
MERGE [CoinlessMacchineHappyHour] AS base USING
-- join done here against the side table to get the local timestamp for concurrency check
(SELECT p.*, t.update_scope_local_id, t.scope_update_peer_key, t.local_update_peer_timestamp FROM @changeTable p LEFT JOIN [CoinlessMacchineHappyHour_tracking] t ON p.[id_macchineHappyHour] = t.[id_macchineHappyHour]) as changes ON changes.[id_macchineHappyHour] = base.[id_macchineHappyHour]
WHEN MATCHED AND (changes.update_scope_local_id = @sync_scope_local_id AND changes.scope_update_peer_key = changes.sync_update_peer_key) OR changes.local_update_peer_timestamp <= @sync_min_timestamp THEN
UPDATE SET [fk_testata] = changes.[fk_testata], [codmac] = changes.[codmac], [device] = changes.[device], [perc_platinum] = changes.[perc_platinum], [perc_gold] = changes.[perc_gold], [perc_silver] = changes.[perc_silver], [perc_normal] = changes.[perc_normal]
OUTPUT INSERTED.[id_macchineHappyHour] into @changed; -- populates the temp table with successful PKs

SET IDENTITY_INSERT [CoinlessMacchineHappyHour] OFF;
UPDATE side SET
update_scope_local_id = @sync_scope_local_id, 
scope_update_peer_key = changes.sync_update_peer_key, 
scope_update_peer_timestamp = changes.sync_update_peer_timestamp,
local_update_peer_key = 0
FROM 
[CoinlessMacchineHappyHour_tracking] side JOIN 
(SELECT p.[id_macchineHappyHour], p.sync_update_peer_timestamp, p.sync_update_peer_key, p.sync_create_peer_key, p.sync_create_peer_timestamp FROM @changed t JOIN @changeTable p ON p.[id_macchineHappyHour] = t.[id_macchineHappyHour]) as changes ON changes.[id_macchineHappyHour] = side.[id_macchineHappyHour]
SELECT [id_macchineHappyHour] FROM @changeTable t WHERE NOT EXISTS (SELECT [id_macchineHappyHour] from @changed i WHERE t.[id_macchineHappyHour] = i.[id_macchineHappyHour])
END
