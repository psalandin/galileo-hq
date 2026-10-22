CREATE PROCEDURE [Premi_bulkupdate]
	@sync_min_timestamp BigInt,
	@sync_scope_local_id Int,
	@changeTable [Premi_BulkType] READONLY
AS
BEGIN
-- use a temp table to store the list of PKs that successfully got updated
declare @changed TABLE ([Codice] varchar(50), PRIMARY KEY ([Codice]));

-- update the base table
MERGE [Premi] AS base USING
-- join done here against the side table to get the local timestamp for concurrency check
(SELECT p.*, t.update_scope_local_id, t.scope_update_peer_key, t.local_update_peer_timestamp FROM @changeTable p LEFT JOIN [Premi_tracking] t ON p.[Codice] = t.[Codice]) as changes ON changes.[Codice] = base.[Codice]
WHEN MATCHED AND (changes.update_scope_local_id = @sync_scope_local_id AND changes.scope_update_peer_key = changes.sync_update_peer_key) OR changes.local_update_peer_timestamp <= @sync_min_timestamp THEN
UPDATE SET [Descrizione] = changes.[Descrizione], [Costo] = changes.[Costo], [N_Tickets] = changes.[N_Tickets], [Fornitore] = changes.[Fornitore], [Quantita] = changes.[Quantita], [Riserva] = changes.[Riserva], [CodOr] = changes.[CodOr], [Foto] = changes.[Foto], [QPren] = changes.[QPren], [Id] = changes.[Id], [Ordinato] = changes.[Ordinato], [Conf] = changes.[Conf], [QDis1] = changes.[QDis1], [PDis1] = changes.[PDis1], [QDis2] = changes.[QDis2], [PDis2] = changes.[PDis2], [QDis3] = changes.[QDis3], [PDis3] = changes.[PDis3], [QDis4] = changes.[QDis4], [PDis4] = changes.[PDis4], [QDis5] = changes.[QDis5], [PDis5] = changes.[PDis5], [QDis6] = changes.[QDis6], [PDis6] = changes.[PDis6], [QDis7] = changes.[QDis7], [PDis7] = changes.[PDis7], [QDis8] = changes.[QDis8], [PDis8] = changes.[PDis8], [Attivo] = changes.[Attivo], [Gru] = changes.[Gru], [Riord] = changes.[Riord], [Locked] = changes.[Locked], [Id2] = changes.[Id2], [Icona] = changes.[Icona], [Prenotabile] = changes.[Prenotabile], [NImp] = changes.[NImp], [F0] = changes.[F0], [T0] = changes.[T0], [N0] = changes.[N0], [D0] = changes.[D0], [F1] = changes.[F1], [T1] = changes.[T1], [N1] = changes.[N1], [D1] = changes.[D1]
OUTPUT INSERTED.[Codice] into @changed; -- populates the temp table with successful PKs

UPDATE side SET
update_scope_local_id = @sync_scope_local_id, 
scope_update_peer_key = changes.sync_update_peer_key, 
scope_update_peer_timestamp = changes.sync_update_peer_timestamp,
local_update_peer_key = 0
FROM 
[Premi_tracking] side JOIN 
(SELECT p.[Codice], p.sync_update_peer_timestamp, p.sync_update_peer_key, p.sync_create_peer_key, p.sync_create_peer_timestamp FROM @changed t JOIN @changeTable p ON p.[Codice] = t.[Codice]) as changes ON changes.[Codice] = side.[Codice]
SELECT [Codice] FROM @changeTable t WHERE NOT EXISTS (SELECT [Codice] from @changed i WHERE t.[Codice] = i.[Codice])
END
