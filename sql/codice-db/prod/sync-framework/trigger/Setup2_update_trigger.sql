CREATE TRIGGER [Setup2_update_trigger] ON [Setup2] FOR UPDATE AS
UPDATE [side] SET [local_update_peer_key] = 0, [restore_timestamp] = NULL, [update_scope_local_id] = NULL, [last_change_datetime] = GETDATE() FROM [Setup2_tracking] [side] JOIN INSERTED AS [i] ON [side].[IdPost] = [i].[IdPost] AND [side].[Chiave] = [i].[Chiave]
