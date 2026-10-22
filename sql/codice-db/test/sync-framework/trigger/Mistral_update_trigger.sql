CREATE TRIGGER [Mistral_update_trigger] ON [Mistral] FOR UPDATE AS
UPDATE [side] SET [local_update_peer_key] = 0, [restore_timestamp] = NULL, [update_scope_local_id] = NULL, [last_change_datetime] = GETDATE() FROM [Mistral_tracking] [side] JOIN INSERTED AS [i] ON [side].[CodCard] = [i].[CodCard]
