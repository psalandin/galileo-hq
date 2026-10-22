CREATE PROCEDURE [RedeemCodes_bulkinsert]
	@sync_min_timestamp BigInt,
	@sync_scope_local_id Int,
	@changeTable [RedeemCodes_BulkType] READONLY
AS
BEGIN
-- use a temp table to store the list of PKs that successfully got updated/inserted
DECLARE @changed TABLE ([Id] bigint, PRIMARY KEY ([Id]));

SET IDENTITY_INSERT [RedeemCodes] ON;
-- update/insert into the base table
MERGE [RedeemCodes] AS base USING
-- join done here against the side table to get the local timestamp for concurrency check
(SELECT p.*, t.local_update_peer_timestamp FROM @changeTable p LEFT JOIN [RedeemCodes_tracking] t ON p.[Id] = t.[Id]) AS changes ON changes.[Id] = base.[Id]
WHEN NOT MATCHED BY TARGET AND changes.local_update_peer_timestamp <= @sync_min_timestamp OR changes.local_update_peer_timestamp IS NULL THEN
INSERT ([Id], [DbName], [Codice], [Azione], [Valore], [Bonus], [Tickets], [IdPromozione], [IdCompleanno], [IdContatto], [MailDestinatario], [CardLevel], [Pin], [ValidFrom], [ValidTo], [CreatedBy], [CreatedAt], [ReservedBy], [ReservedAt], [ReservedOnPost], [ReservedOnDevice], [ReservationExpiresAt], [UsedBy], [UsedAt], [UsedOnPost], [UsedOnDevice], [Note], [QRCode]) VALUES (changes.[Id], changes.[DbName], changes.[Codice], changes.[Azione], changes.[Valore], changes.[Bonus], changes.[Tickets], changes.[IdPromozione], changes.[IdCompleanno], changes.[IdContatto], changes.[MailDestinatario], changes.[CardLevel], changes.[Pin], changes.[ValidFrom], changes.[ValidTo], changes.[CreatedBy], changes.[CreatedAt], changes.[ReservedBy], changes.[ReservedAt], changes.[ReservedOnPost], changes.[ReservedOnDevice], changes.[ReservationExpiresAt], changes.[UsedBy], changes.[UsedAt], changes.[UsedOnPost], changes.[UsedOnDevice], changes.[Note], changes.[QRCode])
OUTPUT INSERTED.[Id] INTO @changed; -- populates the temp table with successful PKs

SET IDENTITY_INSERT [RedeemCodes] OFF;
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
[RedeemCodes_tracking] side JOIN 
(SELECT p.[Id], p.sync_update_peer_timestamp, p.sync_update_peer_key, p.sync_create_peer_key, p.sync_create_peer_timestamp FROM @changed t JOIN @changeTable p ON p.[Id] = t.[Id]) AS changes ON changes.[Id] = side.[Id]
SELECT [Id] FROM @changeTable t WHERE NOT EXISTS (SELECT [Id] from @changed i WHERE t.[Id] = i.[Id])
END
