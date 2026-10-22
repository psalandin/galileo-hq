CREATE TRIGGER [coinless_sbuilder_pages_update_trigger] ON [coinless_sbuilder_pages] FOR UPDATE AS
UPDATE [side] SET [local_update_peer_key] = 0, [restore_timestamp] = NULL, [update_scope_local_id] = NULL, [last_change_datetime] = GETDATE() FROM [coinless_sbuilder_pages_tracking] [side] JOIN INSERTED AS [i] ON [side].[id] = [i].[id]
