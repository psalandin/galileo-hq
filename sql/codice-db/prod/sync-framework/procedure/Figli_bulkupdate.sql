CREATE PROCEDURE [Figli_bulkupdate]
	@sync_min_timestamp BigInt,
	@sync_scope_local_id Int,
	@changeTable [Figli_BulkType] READONLY
AS
BEGIN
-- use a temp table to store the list of PKs that successfully got updated
declare @changed TABLE ([Id] bigint, PRIMARY KEY ([Id]));

-- update the base table
MERGE [Figli] AS base USING
-- join done here against the side table to get the local timestamp for concurrency check
(SELECT p.*, t.update_scope_local_id, t.scope_update_peer_key, t.local_update_peer_timestamp FROM @changeTable p LEFT JOIN [Figli_tracking] t ON p.[Id] = t.[Id]) as changes ON changes.[Id] = base.[Id]
WHEN MATCHED AND (changes.update_scope_local_id = @sync_scope_local_id AND changes.scope_update_peer_key = changes.sync_update_peer_key) OR changes.local_update_peer_timestamp <= @sync_min_timestamp THEN
UPDATE SET [IdContatto] = changes.[IdContatto], [Nome] = changes.[Nome], [Cognome] = changes.[Cognome], [Sesso] = changes.[Sesso], [DDN] = changes.[DDN], [Tickets] = changes.[Tickets], [Bnus] = changes.[Bnus], [CodBar] = changes.[CodBar], [Abilita] = changes.[Abilita], [email] = changes.[email], [Cell] = changes.[Cell], [GiornOk] = changes.[GiornOk], [DataUltVis] = changes.[DataUltVis], [OptOut] = changes.[OptOut], [Password] = changes.[Password], [FirstLogin] = changes.[FirstLogin], [Note] = changes.[Note], [Foto] = changes.[Foto], [IdTel] = changes.[IdTel], [LastOp] = changes.[LastOp], [Credito] = changes.[Credito], [NImp] = changes.[NImp]
OUTPUT INSERTED.[Id] into @changed; -- populates the temp table with successful PKs

UPDATE side SET
update_scope_local_id = @sync_scope_local_id, 
scope_update_peer_key = changes.sync_update_peer_key, 
scope_update_peer_timestamp = changes.sync_update_peer_timestamp,
local_update_peer_key = 0
FROM 
[Figli_tracking] side JOIN 
(SELECT p.[Id], p.sync_update_peer_timestamp, p.sync_update_peer_key, p.sync_create_peer_key, p.sync_create_peer_timestamp FROM @changed t JOIN @changeTable p ON p.[Id] = t.[Id]) as changes ON changes.[Id] = side.[Id]
SELECT [Id] FROM @changeTable t WHERE NOT EXISTS (SELECT [Id] from @changed i WHERE t.[Id] = i.[Id])
END
