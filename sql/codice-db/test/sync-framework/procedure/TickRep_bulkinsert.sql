CREATE PROCEDURE [TickRep_bulkinsert]
	@sync_min_timestamp BigInt,
	@sync_scope_local_id Int,
	@changeTable [TickRep_BulkType] READONLY
AS
BEGIN
-- use a temp table to store the list of PKs that successfully got updated/inserted
DECLARE @changed TABLE ([Keys] uniqueidentifier, PRIMARY KEY ([Keys]));

-- update/insert into the base table
MERGE [TickRep] AS base USING
-- join done here against the side table to get the local timestamp for concurrency check
(SELECT p.*, t.local_update_peer_timestamp FROM @changeTable p LEFT JOIN [TickRep_tracking] t ON p.[Keys] = t.[Keys]) AS changes ON changes.[Keys] = base.[Keys]
WHEN NOT MATCHED BY TARGET AND changes.local_update_peer_timestamp <= @sync_min_timestamp OR changes.local_update_peer_timestamp IS NULL THEN
INSERT ([IdOperatore], [IdCliente], [NumTickets], [NRep], [Data], [NImp], [F0], [T0], [N0], [D0], [Keys]) VALUES (changes.[IdOperatore], changes.[IdCliente], changes.[NumTickets], changes.[NRep], changes.[Data], changes.[NImp], changes.[F0], changes.[T0], changes.[N0], changes.[D0], changes.[Keys])
OUTPUT INSERTED.[Keys] INTO @changed; -- populates the temp table with successful PKs

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
[TickRep_tracking] side JOIN 
(SELECT p.[Keys], p.sync_update_peer_timestamp, p.sync_update_peer_key, p.sync_create_peer_key, p.sync_create_peer_timestamp FROM @changed t JOIN @changeTable p ON p.[Keys] = t.[Keys]) AS changes ON changes.[Keys] = side.[Keys]
SELECT [Keys] FROM @changeTable t WHERE NOT EXISTS (SELECT [Keys] from @changed i WHERE t.[Keys] = i.[Keys])
END
