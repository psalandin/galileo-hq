CREATE PROCEDURE [Premi_bulkinsert]
	@sync_min_timestamp BigInt,
	@sync_scope_local_id Int,
	@changeTable [Premi_BulkType] READONLY
AS
BEGIN
-- use a temp table to store the list of PKs that successfully got updated/inserted
DECLARE @changed TABLE ([Codice] varchar(50), PRIMARY KEY ([Codice]));

-- update/insert into the base table
MERGE [Premi] AS base USING
-- join done here against the side table to get the local timestamp for concurrency check
(SELECT p.*, t.local_update_peer_timestamp FROM @changeTable p LEFT JOIN [Premi_tracking] t ON p.[Codice] = t.[Codice]) AS changes ON changes.[Codice] = base.[Codice]
WHEN NOT MATCHED BY TARGET AND changes.local_update_peer_timestamp <= @sync_min_timestamp OR changes.local_update_peer_timestamp IS NULL THEN
INSERT ([Codice], [Descrizione], [Costo], [N_Tickets], [Fornitore], [Quantita], [Riserva], [CodOr], [Foto], [QPren], [Id], [Ordinato], [Conf], [QDis1], [PDis1], [QDis2], [PDis2], [QDis3], [PDis3], [QDis4], [PDis4], [QDis5], [PDis5], [QDis6], [PDis6], [QDis7], [PDis7], [QDis8], [PDis8], [Attivo], [Gru], [Riord], [Locked], [Id2], [Icona], [Prenotabile], [NImp], [F0], [T0], [N0], [D0], [F1], [T1], [N1], [D1]) VALUES (changes.[Codice], changes.[Descrizione], changes.[Costo], changes.[N_Tickets], changes.[Fornitore], changes.[Quantita], changes.[Riserva], changes.[CodOr], changes.[Foto], changes.[QPren], changes.[Id], changes.[Ordinato], changes.[Conf], changes.[QDis1], changes.[PDis1], changes.[QDis2], changes.[PDis2], changes.[QDis3], changes.[PDis3], changes.[QDis4], changes.[PDis4], changes.[QDis5], changes.[PDis5], changes.[QDis6], changes.[PDis6], changes.[QDis7], changes.[PDis7], changes.[QDis8], changes.[PDis8], changes.[Attivo], changes.[Gru], changes.[Riord], changes.[Locked], changes.[Id2], changes.[Icona], changes.[Prenotabile], changes.[NImp], changes.[F0], changes.[T0], changes.[N0], changes.[D0], changes.[F1], changes.[T1], changes.[N1], changes.[D1])
OUTPUT INSERTED.[Codice] INTO @changed; -- populates the temp table with successful PKs

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
[Premi_tracking] side JOIN 
(SELECT p.[Codice], p.sync_update_peer_timestamp, p.sync_update_peer_key, p.sync_create_peer_key, p.sync_create_peer_timestamp FROM @changed t JOIN @changeTable p ON p.[Codice] = t.[Codice]) AS changes ON changes.[Codice] = side.[Codice]
SELECT [Codice] FROM @changeTable t WHERE NOT EXISTS (SELECT [Codice] from @changed i WHERE t.[Codice] = i.[Codice])
END
