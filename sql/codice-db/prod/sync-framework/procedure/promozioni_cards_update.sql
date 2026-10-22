CREATE PROCEDURE [promozioni_cards_update]
	@P_1 BigInt,
	@P_2 BigInt,
	@P_3 VarChar(16),
	@P_4 Int,
	@P_5 DateTime2,
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; UPDATE [promozioni_cards] SET [idpromozione] = @P_2, [cardid] = @P_3, [livelloPrecedente] = @P_4, [CreatedAt] = @P_5 FROM [promozioni_cards] [base] JOIN [promozioni_cards_tracking] [side] ON [base].[id] = [side].[id] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[id] = @P_1); SET @sync_row_count = @@ROWCOUNT;
END
