CREATE PROCEDURE [Tickets_bulkupdate]
	@sync_min_timestamp BigInt,
	@sync_scope_local_id Int,
	@changeTable [Tickets_BulkType] READONLY
AS
BEGIN
-- use a temp table to store the list of PKs that successfully got updated
declare @changed TABLE ([Keys] uniqueidentifier, PRIMARY KEY ([Keys]));

-- update the base table
MERGE [Tickets] AS base USING
-- join done here against the side table to get the local timestamp for concurrency check
(SELECT p.*, t.update_scope_local_id, t.scope_update_peer_key, t.local_update_peer_timestamp FROM @changeTable p LEFT JOIN [Tickets_tracking] t ON p.[Keys] = t.[Keys]) as changes ON changes.[Keys] = base.[Keys]
WHEN MATCHED AND (changes.update_scope_local_id = @sync_scope_local_id AND changes.scope_update_peer_key = changes.sync_update_peer_key) OR changes.local_update_peer_timestamp <= @sync_min_timestamp THEN
UPDATE SET [IdContatto] = changes.[IdContatto], [NumTickets] = changes.[NumTickets], [Data] = changes.[Data], [MangiaT] = changes.[MangiaT], [NumTrans] = changes.[NumTrans], [TPagati] = changes.[TPagati], [DataOut] = changes.[DataOut], [Oper] = changes.[Oper], [OperOut] = changes.[OperOut], [NonCont] = changes.[NonCont], [Id] = changes.[Id], [Aux] = changes.[Aux], [NRep] = changes.[NRep], [NImp] = changes.[NImp], [F0] = changes.[F0], [T0] = changes.[T0], [N0] = changes.[N0], [D0] = changes.[D0], [F1] = changes.[F1], [T1] = changes.[T1], [N1] = changes.[N1], [D1] = changes.[D1]
OUTPUT INSERTED.[Keys] into @changed; -- populates the temp table with successful PKs

UPDATE side SET
update_scope_local_id = @sync_scope_local_id, 
scope_update_peer_key = changes.sync_update_peer_key, 
scope_update_peer_timestamp = changes.sync_update_peer_timestamp,
local_update_peer_key = 0
FROM 
[Tickets_tracking] side JOIN 
(SELECT p.[Keys], p.sync_update_peer_timestamp, p.sync_update_peer_key, p.sync_create_peer_key, p.sync_create_peer_timestamp FROM @changed t JOIN @changeTable p ON p.[Keys] = t.[Keys]) as changes ON changes.[Keys] = side.[Keys]
SELECT [Keys] FROM @changeTable t WHERE NOT EXISTS (SELECT [Keys] from @changed i WHERE t.[Keys] = i.[Keys])
END
