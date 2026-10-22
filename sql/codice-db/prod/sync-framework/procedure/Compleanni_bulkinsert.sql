CREATE PROCEDURE [Compleanni_bulkinsert]
	@sync_min_timestamp BigInt,
	@sync_scope_local_id Int,
	@changeTable [Compleanni_BulkType] READONLY
AS
BEGIN
-- use a temp table to store the list of PKs that successfully got updated/inserted
DECLARE @changed TABLE ([IdCompleanno] bigint, PRIMARY KEY ([IdCompleanno]));

SET IDENTITY_INSERT [Compleanni] ON;
-- update/insert into the base table
MERGE [Compleanni] AS base USING
-- join done here against the side table to get the local timestamp for concurrency check
(SELECT p.*, t.local_update_peer_timestamp FROM @changeTable p LEFT JOIN [Compleanni_tracking] t ON p.[IdCompleanno] = t.[IdCompleanno]) AS changes ON changes.[IdCompleanno] = base.[IdCompleanno]
WHEN NOT MATCHED BY TARGET AND changes.local_update_peer_timestamp <= @sync_min_timestamp OR changes.local_update_peer_timestamp IS NULL THEN
INSERT ([IdCompleanno], [Titolo], [DallaData], [AllaData], [ModalitaTickets], [MaxPartitePerCard], [PartiteConsecutive], [NrSecondiResetConsecutive], [Partecipanti], [PartecipantiExtra], [ValorePrecaricatoCrediti], [CardId], [IdContatto], [ImportoCompleanno], [ImportoExtra], [AccontoVersato], [EmailGenitore1], [EmailGenitore2], [CellulareGenitore1], [CellulareGenitore2], [Note], [CreatedBy], [CreatedAt], [UpdatedBy], [UpdatedAt], [ValorePrecaricatoBonus], [IdRicarica]) VALUES (changes.[IdCompleanno], changes.[Titolo], changes.[DallaData], changes.[AllaData], changes.[ModalitaTickets], changes.[MaxPartitePerCard], changes.[PartiteConsecutive], changes.[NrSecondiResetConsecutive], changes.[Partecipanti], changes.[PartecipantiExtra], changes.[ValorePrecaricatoCrediti], changes.[CardId], changes.[IdContatto], changes.[ImportoCompleanno], changes.[ImportoExtra], changes.[AccontoVersato], changes.[EmailGenitore1], changes.[EmailGenitore2], changes.[CellulareGenitore1], changes.[CellulareGenitore2], changes.[Note], changes.[CreatedBy], changes.[CreatedAt], changes.[UpdatedBy], changes.[UpdatedAt], changes.[ValorePrecaricatoBonus], changes.[IdRicarica])
OUTPUT INSERTED.[IdCompleanno] INTO @changed; -- populates the temp table with successful PKs

SET IDENTITY_INSERT [Compleanni] OFF;
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
[Compleanni_tracking] side JOIN 
(SELECT p.[IdCompleanno], p.sync_update_peer_timestamp, p.sync_update_peer_key, p.sync_create_peer_key, p.sync_create_peer_timestamp FROM @changed t JOIN @changeTable p ON p.[IdCompleanno] = t.[IdCompleanno]) AS changes ON changes.[IdCompleanno] = side.[IdCompleanno]
SELECT [IdCompleanno] FROM @changeTable t WHERE NOT EXISTS (SELECT [IdCompleanno] from @changed i WHERE t.[IdCompleanno] = i.[IdCompleanno])
END
