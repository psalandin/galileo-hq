CREATE PROCEDURE [Fornitori_bulkinsert]
	@sync_min_timestamp BigInt,
	@sync_scope_local_id Int,
	@changeTable [Fornitori_BulkType] READONLY
AS
BEGIN
-- use a temp table to store the list of PKs that successfully got updated/inserted
DECLARE @changed TABLE ([Nome] varchar(100), PRIMARY KEY ([Nome]));

-- update/insert into the base table
MERGE [Fornitori] AS base USING
-- join done here against the side table to get the local timestamp for concurrency check
(SELECT p.*, t.local_update_peer_timestamp FROM @changeTable p LEFT JOIN [Fornitori_tracking] t ON p.[Nome] = t.[Nome]) AS changes ON changes.[Nome] = base.[Nome]
WHEN NOT MATCHED BY TARGET AND changes.local_update_peer_timestamp <= @sync_min_timestamp OR changes.local_update_peer_timestamp IS NULL THEN
INSERT ([Nome], [Indir], [CAP], [Citta], [Prov], [Tel], [Fax], [email], [Cell], [Stato], [Web_Site], [Contact_Name], [F0], [T0], [N0], [D0]) VALUES (changes.[Nome], changes.[Indir], changes.[CAP], changes.[Citta], changes.[Prov], changes.[Tel], changes.[Fax], changes.[email], changes.[Cell], changes.[Stato], changes.[Web_Site], changes.[Contact_Name], changes.[F0], changes.[T0], changes.[N0], changes.[D0])
OUTPUT INSERTED.[Nome] INTO @changed; -- populates the temp table with successful PKs

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
[Fornitori_tracking] side JOIN 
(SELECT p.[Nome], p.sync_update_peer_timestamp, p.sync_update_peer_key, p.sync_create_peer_key, p.sync_create_peer_timestamp FROM @changed t JOIN @changeTable p ON p.[Nome] = t.[Nome]) AS changes ON changes.[Nome] = side.[Nome]
SELECT [Nome] FROM @changeTable t WHERE NOT EXISTS (SELECT [Nome] from @changed i WHERE t.[Nome] = i.[Nome])
END
