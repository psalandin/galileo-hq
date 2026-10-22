CREATE PROCEDURE [Clienti_bulkupdate]
	@sync_min_timestamp BigInt,
	@sync_scope_local_id Int,
	@changeTable [Clienti_BulkType] READONLY
AS
BEGIN
-- use a temp table to store the list of PKs that successfully got updated
declare @changed TABLE ([IdLong] bigint, PRIMARY KEY ([IdLong]));

-- update the base table
MERGE [Clienti] AS base USING
-- join done here against the side table to get the local timestamp for concurrency check
(SELECT p.*, t.update_scope_local_id, t.scope_update_peer_key, t.local_update_peer_timestamp FROM @changeTable p LEFT JOIN [Clienti_tracking] t ON p.[IdLong] = t.[IdLong]) as changes ON changes.[IdLong] = base.[IdLong]
WHEN MATCHED AND (changes.update_scope_local_id = @sync_scope_local_id AND changes.scope_update_peer_key = changes.sync_update_peer_key) OR changes.local_update_peer_timestamp <= @sync_min_timestamp THEN
UPDATE SET [IdContatto] = changes.[IdContatto], [Nome] = changes.[Nome], [Cognome] = changes.[Cognome], [Indirizzo] = changes.[Indirizzo], [Citta] = changes.[Citta], [Provincia] = changes.[Provincia], [CAP] = changes.[CAP], [Telefono] = changes.[Telefono], [Tickets] = changes.[Tickets], [Data] = changes.[Data], [Bonus] = changes.[Bonus], [CodBar] = changes.[CodBar], [Abilita] = changes.[Abilita], [email] = changes.[email], [Cell] = changes.[Cell], [Nascita] = changes.[Nascita], [NascOk] = changes.[NascOk], [GiornOk] = changes.[GiornOk], [DataUltVis] = changes.[DataUltVis], [OptOut] = changes.[OptOut], [Password] = changes.[Password], [FirstLogin] = changes.[FirstLogin], [Note] = changes.[Note], [Foto] = changes.[Foto], [IdTel] = changes.[IdTel], [LastOp] = changes.[LastOp], [Credito] = changes.[Credito], [NImp] = changes.[NImp], [F0] = changes.[F0], [T0] = changes.[T0], [N0] = changes.[N0], [D0] = changes.[D0], [F1] = changes.[F1], [T1] = changes.[T1], [N1] = changes.[N1], [D1] = changes.[D1], [TimeMod] = changes.[TimeMod], [OperMod] = changes.[OperMod], [IdMaster1] = changes.[IdMaster1], [IdMaster2] = changes.[IdMaster2], [TipoDoc] = changes.[TipoDoc], [Docum] = changes.[Docum], [Sesso] = changes.[Sesso], [Modificato] = changes.[Modificato], [IdLong2] = changes.[IdLong2], [EMailIsCertified] = changes.[EMailIsCertified], [HasTelephoneNumberCorrect] = changes.[HasTelephoneNumberCorrect], [UserName] = changes.[UserName], [TipoCard] = changes.[TipoCard]
OUTPUT INSERTED.[IdLong] into @changed; -- populates the temp table with successful PKs

UPDATE side SET
update_scope_local_id = @sync_scope_local_id, 
scope_update_peer_key = changes.sync_update_peer_key, 
scope_update_peer_timestamp = changes.sync_update_peer_timestamp,
local_update_peer_key = 0
FROM 
[Clienti_tracking] side JOIN 
(SELECT p.[IdLong], p.sync_update_peer_timestamp, p.sync_update_peer_key, p.sync_create_peer_key, p.sync_create_peer_timestamp FROM @changed t JOIN @changeTable p ON p.[IdLong] = t.[IdLong]) as changes ON changes.[IdLong] = side.[IdLong]
SELECT [IdLong] FROM @changeTable t WHERE NOT EXISTS (SELECT [IdLong] from @changed i WHERE t.[IdLong] = i.[IdLong])
END
