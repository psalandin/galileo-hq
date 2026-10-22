CREATE PROCEDURE [Compleanni_bulkupdate]
	@sync_min_timestamp BigInt,
	@sync_scope_local_id Int,
	@changeTable [Compleanni_BulkType] READONLY
AS
BEGIN
-- use a temp table to store the list of PKs that successfully got updated
declare @changed TABLE ([IdCompleanno] bigint, PRIMARY KEY ([IdCompleanno]));

SET IDENTITY_INSERT [Compleanni] ON;
-- update the base table
MERGE [Compleanni] AS base USING
-- join done here against the side table to get the local timestamp for concurrency check
(SELECT p.*, t.update_scope_local_id, t.scope_update_peer_key, t.local_update_peer_timestamp FROM @changeTable p LEFT JOIN [Compleanni_tracking] t ON p.[IdCompleanno] = t.[IdCompleanno]) as changes ON changes.[IdCompleanno] = base.[IdCompleanno]
WHEN MATCHED AND (changes.update_scope_local_id = @sync_scope_local_id AND changes.scope_update_peer_key = changes.sync_update_peer_key) OR changes.local_update_peer_timestamp <= @sync_min_timestamp THEN
UPDATE SET [Titolo] = changes.[Titolo], [DallaData] = changes.[DallaData], [AllaData] = changes.[AllaData], [ModalitaTickets] = changes.[ModalitaTickets], [MaxPartitePerCard] = changes.[MaxPartitePerCard], [PartiteConsecutive] = changes.[PartiteConsecutive], [NrSecondiResetConsecutive] = changes.[NrSecondiResetConsecutive], [Partecipanti] = changes.[Partecipanti], [PartecipantiExtra] = changes.[PartecipantiExtra], [ValorePrecaricatoCrediti] = changes.[ValorePrecaricatoCrediti], [CardId] = changes.[CardId], [IdContatto] = changes.[IdContatto], [ImportoCompleanno] = changes.[ImportoCompleanno], [ImportoExtra] = changes.[ImportoExtra], [AccontoVersato] = changes.[AccontoVersato], [EmailGenitore1] = changes.[EmailGenitore1], [EmailGenitore2] = changes.[EmailGenitore2], [CellulareGenitore1] = changes.[CellulareGenitore1], [CellulareGenitore2] = changes.[CellulareGenitore2], [Note] = changes.[Note], [CreatedBy] = changes.[CreatedBy], [CreatedAt] = changes.[CreatedAt], [UpdatedBy] = changes.[UpdatedBy], [UpdatedAt] = changes.[UpdatedAt], [ValorePrecaricatoBonus] = changes.[ValorePrecaricatoBonus], [IdRicarica] = changes.[IdRicarica]
OUTPUT INSERTED.[IdCompleanno] into @changed; -- populates the temp table with successful PKs

SET IDENTITY_INSERT [Compleanni] OFF;
UPDATE side SET
update_scope_local_id = @sync_scope_local_id, 
scope_update_peer_key = changes.sync_update_peer_key, 
scope_update_peer_timestamp = changes.sync_update_peer_timestamp,
local_update_peer_key = 0
FROM 
[Compleanni_tracking] side JOIN 
(SELECT p.[IdCompleanno], p.sync_update_peer_timestamp, p.sync_update_peer_key, p.sync_create_peer_key, p.sync_create_peer_timestamp FROM @changed t JOIN @changeTable p ON p.[IdCompleanno] = t.[IdCompleanno]) as changes ON changes.[IdCompleanno] = side.[IdCompleanno]
SELECT [IdCompleanno] FROM @changeTable t WHERE NOT EXISTS (SELECT [IdCompleanno] from @changed i WHERE t.[IdCompleanno] = i.[IdCompleanno])
END
