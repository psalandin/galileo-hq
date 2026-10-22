CREATE PROCEDURE [TransCard_bulkinsert]
	@sync_min_timestamp BigInt,
	@sync_scope_local_id Int,
	@changeTable [TransCard_BulkType] READONLY
AS
BEGIN
-- use a temp table to store the list of PKs that successfully got updated/inserted
DECLARE @changed TABLE ([IDOperazione] uniqueidentifier, PRIMARY KEY ([IDOperazione]));

-- update/insert into the base table
MERGE [TransCard] AS base USING
-- join done here against the side table to get the local timestamp for concurrency check
(SELECT p.*, t.local_update_peer_timestamp FROM @changeTable p LEFT JOIN [TransCard_tracking] t ON p.[IDOperazione] = t.[IDOperazione]) AS changes ON changes.[IDOperazione] = base.[IDOperazione]
WHEN NOT MATCHED BY TARGET AND changes.local_update_peer_timestamp <= @sync_min_timestamp OR changes.local_update_peer_timestamp IS NULL THEN
INSERT ([IdCli], [NImp], [CodMac], [Data], [ValoreOperazione], [ValoreFinale], [ValoreBonus], [F0], [T0], [N0], [D0], [Operatore], [ValoreCassa], [WinMt], [IDOperazione], [FlagOpDaVerificare]) VALUES (changes.[IdCli], changes.[NImp], changes.[CodMac], changes.[Data], changes.[ValoreOperazione], changes.[ValoreFinale], changes.[ValoreBonus], changes.[F0], changes.[T0], changes.[N0], changes.[D0], changes.[Operatore], changes.[ValoreCassa], changes.[WinMt], changes.[IDOperazione], changes.[FlagOpDaVerificare])
OUTPUT INSERTED.[IDOperazione] INTO @changed; -- populates the temp table with successful PKs

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
[TransCard_tracking] side JOIN 
(SELECT p.[IDOperazione], p.sync_update_peer_timestamp, p.sync_update_peer_key, p.sync_create_peer_key, p.sync_create_peer_timestamp FROM @changed t JOIN @changeTable p ON p.[IDOperazione] = t.[IDOperazione]) AS changes ON changes.[IDOperazione] = side.[IDOperazione]
SELECT [IDOperazione] FROM @changeTable t WHERE NOT EXISTS (SELECT [IDOperazione] from @changed i WHERE t.[IDOperazione] = i.[IDOperazione])
END
