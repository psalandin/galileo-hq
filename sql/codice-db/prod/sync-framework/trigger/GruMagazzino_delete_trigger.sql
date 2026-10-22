CREATE TRIGGER [GruMagazzino_delete_trigger] ON [GruMagazzino] FOR DELETE AS
UPDATE [side] SET [sync_row_is_tombstone] = 1, [local_update_peer_key] = 0, [restore_timestamp] = NULL, [update_scope_local_id] = NULL, [last_change_datetime] = GETDATE() FROM [GruMagazzino_tracking] [side] JOIN DELETED AS [d] ON [side].[CodMac] = [d].[CodMac]
