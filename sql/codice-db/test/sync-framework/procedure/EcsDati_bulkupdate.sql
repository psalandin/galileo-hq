CREATE PROCEDURE [EcsDati_bulkupdate]
	@sync_min_timestamp BigInt,
	@sync_scope_local_id Int,
	@changeTable [EcsDati_BulkType] READONLY
AS
BEGIN
-- use a temp table to store the list of PKs that successfully got updated
declare @changed TABLE ([Keys] uniqueidentifier, PRIMARY KEY ([Keys]));

-- update the base table
MERGE [EcsDati] AS base USING
-- join done here against the side table to get the local timestamp for concurrency check
(SELECT p.*, t.update_scope_local_id, t.scope_update_peer_key, t.local_update_peer_timestamp FROM @changeTable p LEFT JOIN [EcsDati_tracking] t ON p.[Keys] = t.[Keys]) as changes ON changes.[Keys] = base.[Keys]
WHEN MATCHED AND (changes.update_scope_local_id = @sync_scope_local_id AND changes.scope_update_peer_key = changes.sync_update_peer_key) OR changes.local_update_peer_timestamp <= @sync_min_timestamp THEN
UPDATE SET [CodMac] = changes.[CodMac], [Stato] = changes.[Stato], [DataRil] = changes.[DataRil], [In1] = changes.[In1], [In2] = changes.[In2], [In3] = changes.[In3], [In4] = changes.[In4], [In5] = changes.[In5], [In6] = changes.[In6], [In7] = changes.[In7], [In8] = changes.[In8], [In9] = changes.[In9], [In10] = changes.[In10], [In11] = changes.[In11], [In12] = changes.[In12], [In13] = changes.[In13], [In14] = changes.[In14], [In15] = changes.[In15], [In16] = changes.[In16], [NImp] = changes.[NImp], [ValoreUscita] = changes.[ValoreUscita], [F0] = changes.[F0], [T0] = changes.[T0], [N0] = changes.[N0], [D0] = changes.[D0]
OUTPUT INSERTED.[Keys] into @changed; -- populates the temp table with successful PKs

UPDATE side SET
update_scope_local_id = @sync_scope_local_id, 
scope_update_peer_key = changes.sync_update_peer_key, 
scope_update_peer_timestamp = changes.sync_update_peer_timestamp,
local_update_peer_key = 0
FROM 
[EcsDati_tracking] side JOIN 
(SELECT p.[Keys], p.sync_update_peer_timestamp, p.sync_update_peer_key, p.sync_create_peer_key, p.sync_create_peer_timestamp FROM @changed t JOIN @changeTable p ON p.[Keys] = t.[Keys]) as changes ON changes.[Keys] = side.[Keys]
SELECT [Keys] FROM @changeTable t WHERE NOT EXISTS (SELECT [Keys] from @changed i WHERE t.[Keys] = i.[Keys])
END
