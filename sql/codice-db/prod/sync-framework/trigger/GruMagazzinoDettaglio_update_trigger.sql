CREATE TRIGGER [GruMagazzinoDettaglio_update_trigger] ON [GruMagazzinoDettaglio] FOR UPDATE AS
UPDATE [side] SET [local_update_peer_key] = 0, [restore_timestamp] = NULL, [update_scope_local_id] = NULL, [last_change_datetime] = GETDATE() FROM [GruMagazzinoDettaglio_tracking] [side] JOIN INSERTED AS [i] ON [side].[CodMac] = [i].[CodMac] AND [side].[SlotNo] = [i].[SlotNo]
