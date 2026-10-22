CREATE TRIGGER [Ordini_delete_trigger] ON [Ordini] FOR DELETE AS
UPDATE [side] SET [sync_row_is_tombstone] = 1, [local_update_peer_key] = 0, [restore_timestamp] = NULL, [update_scope_local_id] = NULL, [last_change_datetime] = GETDATE() FROM [Ordini_tracking] [side] JOIN DELETED AS [d] ON [side].[Keys] = [d].[Keys]
