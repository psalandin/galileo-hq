CREATE TRIGGER [CoinlessClonedCards_update_trigger] ON [CoinlessClonedCards] FOR UPDATE AS
UPDATE [side] SET [local_update_peer_key] = 0, [restore_timestamp] = NULL, [update_scope_local_id] = NULL, [last_change_datetime] = GETDATE() FROM [CoinlessClonedCards_tracking] [side] JOIN INSERTED AS [i] ON [side].[id_card_clonate] = [i].[id_card_clonate]
