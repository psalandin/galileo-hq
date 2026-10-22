CREATE PROCEDURE [Fornitori_bulkupdate]
	@sync_min_timestamp BigInt,
	@sync_scope_local_id Int,
	@changeTable [Fornitori_BulkType] READONLY
AS
BEGIN
-- use a temp table to store the list of PKs that successfully got updated
declare @changed TABLE ([Nome] varchar(100), PRIMARY KEY ([Nome]));

-- update the base table
MERGE [Fornitori] AS base USING
-- join done here against the side table to get the local timestamp for concurrency check
(SELECT p.*, t.update_scope_local_id, t.scope_update_peer_key, t.local_update_peer_timestamp FROM @changeTable p LEFT JOIN [Fornitori_tracking] t ON p.[Nome] = t.[Nome]) as changes ON changes.[Nome] = base.[Nome]
WHEN MATCHED AND (changes.update_scope_local_id = @sync_scope_local_id AND changes.scope_update_peer_key = changes.sync_update_peer_key) OR changes.local_update_peer_timestamp <= @sync_min_timestamp THEN
UPDATE SET [Indir] = changes.[Indir], [CAP] = changes.[CAP], [Citta] = changes.[Citta], [Prov] = changes.[Prov], [Tel] = changes.[Tel], [Fax] = changes.[Fax], [email] = changes.[email], [Cell] = changes.[Cell], [Stato] = changes.[Stato], [Web_Site] = changes.[Web_Site], [Contact_Name] = changes.[Contact_Name], [F0] = changes.[F0], [T0] = changes.[T0], [N0] = changes.[N0], [D0] = changes.[D0]
OUTPUT INSERTED.[Nome] into @changed; -- populates the temp table with successful PKs

UPDATE side SET
update_scope_local_id = @sync_scope_local_id, 
scope_update_peer_key = changes.sync_update_peer_key, 
scope_update_peer_timestamp = changes.sync_update_peer_timestamp,
local_update_peer_key = 0
FROM 
[Fornitori_tracking] side JOIN 
(SELECT p.[Nome], p.sync_update_peer_timestamp, p.sync_update_peer_key, p.sync_create_peer_key, p.sync_create_peer_timestamp FROM @changed t JOIN @changeTable p ON p.[Nome] = t.[Nome]) as changes ON changes.[Nome] = side.[Nome]
SELECT [Nome] FROM @changeTable t WHERE NOT EXISTS (SELECT [Nome] from @changed i WHERE t.[Nome] = i.[Nome])
END
