CREATE PROCEDURE [cache_dati_grafico_giornaliero_bulkinsert]
	@sync_min_timestamp BigInt,
	@sync_scope_local_id Int,
	@changeTable [cache_dati_grafico_giornaliero_BulkType] READONLY
AS
BEGIN
-- use a temp table to store the list of PKs that successfully got updated/inserted
DECLARE @changed TABLE ([CodMac] varchar(15), [DataRil] date, PRIMARY KEY ([CodMac], [DataRil]));

-- update/insert into the base table
MERGE [cache_dati_grafico_giornaliero] AS base USING
-- join done here against the side table to get the local timestamp for concurrency check
(SELECT p.*, t.local_update_peer_timestamp FROM @changeTable p LEFT JOIN [cache_dati_grafico_giornaliero_tracking] t ON p.[CodMac] = t.[CodMac] AND p.[DataRil] = t.[DataRil]) AS changes ON changes.[CodMac] = base.[CodMac] AND changes.[DataRil] = base.[DataRil]
WHEN NOT MATCHED BY TARGET AND changes.local_update_peer_timestamp <= @sync_min_timestamp OR changes.local_update_peer_timestamp IS NULL THEN
INSERT ([CodMac], [tipo], [DataRil], [EUIncassiMonete], [EUIncassiGettoni], [EUPremiPagati], [EUTicketsPagati], [NrMonete], [NrGettoni], [NrPremi], [NrTickets], [NrGettoniOut], [NrMoneteOut], [NPartite]) VALUES (changes.[CodMac], changes.[tipo], changes.[DataRil], changes.[EUIncassiMonete], changes.[EUIncassiGettoni], changes.[EUPremiPagati], changes.[EUTicketsPagati], changes.[NrMonete], changes.[NrGettoni], changes.[NrPremi], changes.[NrTickets], changes.[NrGettoniOut], changes.[NrMoneteOut], changes.[NPartite])
OUTPUT INSERTED.[CodMac], INSERTED.[DataRil] INTO @changed; -- populates the temp table with successful PKs

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
[cache_dati_grafico_giornaliero_tracking] side JOIN 
(SELECT p.[CodMac], p.[DataRil], p.sync_update_peer_timestamp, p.sync_update_peer_key, p.sync_create_peer_key, p.sync_create_peer_timestamp FROM @changed t JOIN @changeTable p ON p.[CodMac] = t.[CodMac] AND p.[DataRil] = t.[DataRil]) AS changes ON changes.[CodMac] = side.[CodMac] AND changes.[DataRil] = side.[DataRil]
SELECT [CodMac], [DataRil] FROM @changeTable t WHERE NOT EXISTS (SELECT [CodMac], [DataRil] from @changed i WHERE t.[CodMac] = i.[CodMac] AND t.[DataRil] = i.[DataRil])
END
