CREATE PROCEDURE [cache_dati_grafico_giornaliero_bulkupdate]
	@sync_min_timestamp BigInt,
	@sync_scope_local_id Int,
	@changeTable [cache_dati_grafico_giornaliero_BulkType] READONLY
AS
BEGIN
-- use a temp table to store the list of PKs that successfully got updated
declare @changed TABLE ([CodMac] varchar(15), [DataRil] date, PRIMARY KEY ([CodMac], [DataRil]));

-- update the base table
MERGE [cache_dati_grafico_giornaliero] AS base USING
-- join done here against the side table to get the local timestamp for concurrency check
(SELECT p.*, t.update_scope_local_id, t.scope_update_peer_key, t.local_update_peer_timestamp FROM @changeTable p LEFT JOIN [cache_dati_grafico_giornaliero_tracking] t ON p.[CodMac] = t.[CodMac] AND p.[DataRil] = t.[DataRil]) as changes ON changes.[CodMac] = base.[CodMac] AND changes.[DataRil] = base.[DataRil]
WHEN MATCHED AND (changes.update_scope_local_id = @sync_scope_local_id AND changes.scope_update_peer_key = changes.sync_update_peer_key) OR changes.local_update_peer_timestamp <= @sync_min_timestamp THEN
UPDATE SET [tipo] = changes.[tipo], [EUIncassiMonete] = changes.[EUIncassiMonete], [EUIncassiGettoni] = changes.[EUIncassiGettoni], [EUPremiPagati] = changes.[EUPremiPagati], [EUTicketsPagati] = changes.[EUTicketsPagati], [NrMonete] = changes.[NrMonete], [NrGettoni] = changes.[NrGettoni], [NrPremi] = changes.[NrPremi], [NrTickets] = changes.[NrTickets], [NrGettoniOut] = changes.[NrGettoniOut], [NrMoneteOut] = changes.[NrMoneteOut], [NPartite] = changes.[NPartite]
OUTPUT INSERTED.[CodMac], INSERTED.[DataRil] into @changed; -- populates the temp table with successful PKs

UPDATE side SET
update_scope_local_id = @sync_scope_local_id, 
scope_update_peer_key = changes.sync_update_peer_key, 
scope_update_peer_timestamp = changes.sync_update_peer_timestamp,
local_update_peer_key = 0
FROM 
[cache_dati_grafico_giornaliero_tracking] side JOIN 
(SELECT p.[CodMac], p.[DataRil], p.sync_update_peer_timestamp, p.sync_update_peer_key, p.sync_create_peer_key, p.sync_create_peer_timestamp FROM @changed t JOIN @changeTable p ON p.[CodMac] = t.[CodMac] AND p.[DataRil] = t.[DataRil]) as changes ON changes.[CodMac] = side.[CodMac] AND changes.[DataRil] = side.[DataRil]
SELECT [CodMac], [DataRil] FROM @changeTable t WHERE NOT EXISTS (SELECT [CodMac], [DataRil] from @changed i WHERE t.[CodMac] = i.[CodMac] AND t.[DataRil] = i.[DataRil])
END
