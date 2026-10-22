CREATE TRIGGER [Resi_update_trigger] ON [Resi] FOR UPDATE AS
UPDATE [side] SET [local_update_peer_key] = 0, [restore_timestamp] = NULL, [update_scope_local_id] = NULL, [last_change_datetime] = GETDATE() FROM [Resi_tracking] [side] JOIN INSERTED AS [i] ON [side].[Keys] = [i].[Keys]
