CREATE PROCEDURE [CoinlessClonedCards_delete]
	@P_1 BigInt,
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; DELETE [CoinlessClonedCards] FROM [CoinlessClonedCards] [base] JOIN [CoinlessClonedCards_tracking] [side] ON [base].[id_card_clonate] = [side].[id_card_clonate] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[id_card_clonate] = @P_1); SET @sync_row_count = @@ROWCOUNT;
END
