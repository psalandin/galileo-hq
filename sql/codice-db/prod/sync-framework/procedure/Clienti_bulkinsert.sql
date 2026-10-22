CREATE PROCEDURE [Clienti_bulkinsert]
	@sync_min_timestamp BigInt,
	@sync_scope_local_id Int,
	@changeTable [Clienti_BulkType] READONLY
AS
BEGIN
-- use a temp table to store the list of PKs that successfully got updated/inserted
DECLARE @changed TABLE ([IdLong] bigint, PRIMARY KEY ([IdLong]));

-- update/insert into the base table
MERGE [Clienti] AS base USING
-- join done here against the side table to get the local timestamp for concurrency check
(SELECT p.*, t.local_update_peer_timestamp FROM @changeTable p LEFT JOIN [Clienti_tracking] t ON p.[IdLong] = t.[IdLong]) AS changes ON changes.[IdLong] = base.[IdLong]
WHEN NOT MATCHED BY TARGET AND changes.local_update_peer_timestamp <= @sync_min_timestamp OR changes.local_update_peer_timestamp IS NULL THEN
INSERT ([IdContatto], [Nome], [Cognome], [Indirizzo], [Citta], [Provincia], [CAP], [Telefono], [Tickets], [Data], [Bonus], [CodBar], [Abilita], [email], [Cell], [Nascita], [NascOk], [GiornOk], [DataUltVis], [OptOut], [Password], [FirstLogin], [Note], [Foto], [IdTel], [LastOp], [Credito], [NImp], [F0], [T0], [N0], [D0], [F1], [T1], [N1], [D1], [TimeMod], [OperMod], [IdMaster1], [IdMaster2], [TipoDoc], [Docum], [Sesso], [Modificato], [IdLong], [IdLong2], [EMailIsCertified], [HasTelephoneNumberCorrect], [UserName], [TipoCard]) VALUES (changes.[IdContatto], changes.[Nome], changes.[Cognome], changes.[Indirizzo], changes.[Citta], changes.[Provincia], changes.[CAP], changes.[Telefono], changes.[Tickets], changes.[Data], changes.[Bonus], changes.[CodBar], changes.[Abilita], changes.[email], changes.[Cell], changes.[Nascita], changes.[NascOk], changes.[GiornOk], changes.[DataUltVis], changes.[OptOut], changes.[Password], changes.[FirstLogin], changes.[Note], changes.[Foto], changes.[IdTel], changes.[LastOp], changes.[Credito], changes.[NImp], changes.[F0], changes.[T0], changes.[N0], changes.[D0], changes.[F1], changes.[T1], changes.[N1], changes.[D1], changes.[TimeMod], changes.[OperMod], changes.[IdMaster1], changes.[IdMaster2], changes.[TipoDoc], changes.[Docum], changes.[Sesso], changes.[Modificato], changes.[IdLong], changes.[IdLong2], changes.[EMailIsCertified], changes.[HasTelephoneNumberCorrect], changes.[UserName], changes.[TipoCard])
OUTPUT INSERTED.[IdLong] INTO @changed; -- populates the temp table with successful PKs

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
[Clienti_tracking] side JOIN 
(SELECT p.[IdLong], p.sync_update_peer_timestamp, p.sync_update_peer_key, p.sync_create_peer_key, p.sync_create_peer_timestamp FROM @changed t JOIN @changeTable p ON p.[IdLong] = t.[IdLong]) AS changes ON changes.[IdLong] = side.[IdLong]
SELECT [IdLong] FROM @changeTable t WHERE NOT EXISTS (SELECT [IdLong] from @changed i WHERE t.[IdLong] = i.[IdLong])
END
