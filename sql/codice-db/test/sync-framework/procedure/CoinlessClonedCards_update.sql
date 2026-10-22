CREATE PROCEDURE [CoinlessClonedCards_update]
	@P_1 BigInt,
	@P_2 VarChar(16),
	@P_3 DateTime,
	@P_4 VarChar(10),
	@P_5 BigInt,
	@P_6 BigInt,
	@P_7 BigInt,
	@P_8 VarChar(16),
	@P_9 VarChar(16),
	@P_10 Int,
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; UPDATE [CoinlessClonedCards] SET [cardid] = @P_2, [DataMovimento] = @P_3, [TipoMovimento] = @P_4, [SaldoCard] = @P_5, [CostoPartita] = @P_6, [LivelloCard] = @P_7, [device] = @P_8, [CodMac] = @P_9, [N0] = @P_10 FROM [CoinlessClonedCards] [base] JOIN [CoinlessClonedCards_tracking] [side] ON [base].[id_card_clonate] = [side].[id_card_clonate] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[id_card_clonate] = @P_1); SET @sync_row_count = @@ROWCOUNT;
END
