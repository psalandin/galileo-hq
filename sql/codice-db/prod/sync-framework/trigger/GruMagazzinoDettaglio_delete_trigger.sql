CREATE TRIGGER [GruMagazzinoDettaglio_delete_trigger] ON [GruMagazzinoDettaglio] FOR DELETE AS
UPDATE [side] SET [sync_row_is_tombstone] = 1, [local_update_peer_key] = 0, [restore_timestamp] = NULL, [update_scope_local_id] = NULL, [last_change_datetime] = GETDATE() FROM [GruMagazzinoDettaglio_tracking] [side] JOIN DELETED AS [d] ON [side].[CodMac] = [d].[CodMac] AND [side].[SlotNo] = [d].[SlotNo]
