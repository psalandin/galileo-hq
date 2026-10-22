CREATE PROCEDURE [ecl_SchedeFirmware_bulkinsert]
	@sync_min_timestamp BigInt,
	@sync_scope_local_id Int,
	@changeTable [ecl_SchedeFirmware_BulkType] READONLY
AS
BEGIN
-- use a temp table to store the list of PKs that successfully got updated/inserted
DECLARE @changed TABLE ([macaddress] varchar(17), PRIMARY KEY ([macaddress]));

-- update/insert into the base table
MERGE [ecl_SchedeFirmware] AS base USING
-- join done here against the side table to get the local timestamp for concurrency check
(SELECT p.*, t.local_update_peer_timestamp FROM @changeTable p LEFT JOIN [ecl_SchedeFirmware_tracking] t ON p.[macaddress] = t.[macaddress]) AS changes ON changes.[macaddress] = base.[macaddress]
WHEN NOT MATCHED BY TARGET AND changes.local_update_peer_timestamp <= @sync_min_timestamp OR changes.local_update_peer_timestamp IS NULL THEN
INSERT ([macaddress], [tipoScheda], [tipoFirmware], [dataAggiornamento], [device], [requestedVersion], [detectedVersion], [dataVerifica], [bidetectedVersion], [status]) VALUES (changes.[macaddress], changes.[tipoScheda], changes.[tipoFirmware], changes.[dataAggiornamento], changes.[device], changes.[requestedVersion], changes.[detectedVersion], changes.[dataVerifica], changes.[bidetectedVersion], changes.[status])
OUTPUT INSERTED.[macaddress] INTO @changed; -- populates the temp table with successful PKs

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
[ecl_SchedeFirmware_tracking] side JOIN 
(SELECT p.[macaddress], p.sync_update_peer_timestamp, p.sync_update_peer_key, p.sync_create_peer_key, p.sync_create_peer_timestamp FROM @changed t JOIN @changeTable p ON p.[macaddress] = t.[macaddress]) AS changes ON changes.[macaddress] = side.[macaddress]
SELECT [macaddress] FROM @changeTable t WHERE NOT EXISTS (SELECT [macaddress] from @changed i WHERE t.[macaddress] = i.[macaddress])
END
