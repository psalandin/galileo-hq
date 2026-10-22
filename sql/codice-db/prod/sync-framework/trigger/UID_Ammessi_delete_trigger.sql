CREATE TRIGGER [UID_Ammessi_delete_trigger] ON [UID_Ammessi] FOR DELETE AS
UPDATE [side] SET [sync_row_is_tombstone] = 1, [local_update_peer_key] = 0, [restore_timestamp] = NULL, [update_scope_local_id] = NULL, [last_change_datetime] = GETDATE() FROM [UID_Ammessi_tracking] [side] JOIN DELETED AS [d] ON [side].[UID] = [d].[UID]
