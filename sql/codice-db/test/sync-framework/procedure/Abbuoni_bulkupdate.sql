CREATE PROCEDURE [Abbuoni_bulkupdate]
	@sync_min_timestamp BigInt,
	@sync_scope_local_id Int,
	@changeTable [Abbuoni_BulkType] READONLY
AS
BEGIN
-- use a temp table to store the list of PKs that successfully got updated
declare @changed TABLE ([Keys] int, PRIMARY KEY ([Keys]));

SET IDENTITY_INSERT [Abbuoni] ON;
-- update the base table
MERGE [Abbuoni] AS base USING
-- join done here against the side table to get the local timestamp for concurrency check
(SELECT p.*, t.update_scope_local_id, t.scope_update_peer_key, t.local_update_peer_timestamp FROM @changeTable p LEFT JOIN [Abbuoni_tracking] t ON p.[Keys] = t.[Keys]) as changes ON changes.[Keys] = base.[Keys]
WHEN MATCHED AND (changes.update_scope_local_id = @sync_scope_local_id AND changes.scope_update_peer_key = changes.sync_update_peer_key) OR changes.local_update_peer_timestamp <= @sync_min_timestamp THEN
UPDATE SET [Id] = changes.[Id], [Valore] = changes.[Valore], [Data] = changes.[Data], [Tickets] = changes.[Tickets], [NImp] = changes.[NImp], [F0] = changes.[F0], [T0] = changes.[T0], [N0] = changes.[N0], [D0] = changes.[D0]
OUTPUT INSERTED.[Keys] into @changed; -- populates the temp table with successful PKs

SET IDENTITY_INSERT [Abbuoni] OFF;
UPDATE side SET
update_scope_local_id = @sync_scope_local_id, 
scope_update_peer_key = changes.sync_update_peer_key, 
scope_update_peer_timestamp = changes.sync_update_peer_timestamp,
local_update_peer_key = 0
FROM 
[Abbuoni_tracking] side JOIN 
(SELECT p.[Keys], p.sync_update_peer_timestamp, p.sync_update_peer_key, p.sync_create_peer_key, p.sync_create_peer_timestamp FROM @changed t JOIN @changeTable p ON p.[Keys] = t.[Keys]) as changes ON changes.[Keys] = side.[Keys]
SELECT [Keys] FROM @changeTable t WHERE NOT EXISTS (SELECT [Keys] from @changed i WHERE t.[Keys] = i.[Keys])
END
