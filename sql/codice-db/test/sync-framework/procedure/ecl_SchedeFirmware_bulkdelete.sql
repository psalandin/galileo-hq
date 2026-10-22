CREATE PROCEDURE [ecl_SchedeFirmware_bulkdelete]
	@sync_min_timestamp BigInt,
	@sync_scope_local_id Int,
	@changeTable [ecl_SchedeFirmware_BulkType] READONLY
AS
BEGIN
-- use a temp table to store the list of PKs that successfully got updated/inserted
declare @changed TABLE ([macaddress] varchar(17), PRIMARY KEY ([macaddress]));
DELETE [ecl_SchedeFirmware] 
OUTPUT DELETED.[macaddress] INTO @changed FROM [ecl_SchedeFirmware] base JOIN
(SELECT p.*, t.update_scope_local_id, t.scope_update_peer_key, t.local_update_peer_timestamp FROM @changeTable p JOIN [ecl_SchedeFirmware_tracking] t ON p.[macaddress] = t.[macaddress]) as changes ON changes.[macaddress] = base.[macaddress] WHERE (changes.update_scope_local_id = @sync_scope_local_id AND changes.scope_update_peer_key = changes.sync_update_peer_key) OR changes.local_update_peer_timestamp <= @sync_min_timestamp
UPDATE side SET
sync_row_is_tombstone = 1, 
update_scope_local_id = @sync_scope_local_id, 
scope_update_peer_key = changes.sync_update_peer_key, 
scope_update_peer_timestamp = changes.sync_update_peer_timestamp,
local_update_peer_key = 0
FROM 
[ecl_SchedeFirmware_tracking] side JOIN 
(SELECT p.[macaddress], p.sync_update_peer_timestamp, p.sync_update_peer_key, p.sync_create_peer_key, p.sync_create_peer_timestamp FROM @changed t JOIN @changeTable p ON p.[macaddress] = t.[macaddress]) AS changes ON changes.[macaddress] = side.[macaddress]
SELECT [macaddress] FROM @changeTable t WHERE NOT EXISTS (SELECT [macaddress] from @changed i WHERE t.[macaddress] = i.[macaddress])
END
