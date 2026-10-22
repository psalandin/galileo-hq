CREATE TRIGGER [Operatori_update_trigger] ON [Operatori] FOR UPDATE AS
UPDATE [side] SET [local_update_peer_key] = 0, [restore_timestamp] = NULL, [update_scope_local_id] = NULL, [last_change_datetime] = GETDATE() FROM [Operatori_tracking] [side] JOIN INSERTED AS [i] ON [side].[Id] = [i].[Id]
