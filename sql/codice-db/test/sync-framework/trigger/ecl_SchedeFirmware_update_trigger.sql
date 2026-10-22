CREATE TRIGGER [ecl_SchedeFirmware_update_trigger] ON [ecl_SchedeFirmware] FOR UPDATE AS
UPDATE [side] SET [local_update_peer_key] = 0, [restore_timestamp] = NULL, [update_scope_local_id] = NULL, [last_change_datetime] = GETDATE() FROM [ecl_SchedeFirmware_tracking] [side] JOIN INSERTED AS [i] ON [side].[macaddress] = [i].[macaddress]
