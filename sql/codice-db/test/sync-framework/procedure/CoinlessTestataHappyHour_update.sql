CREATE PROCEDURE [CoinlessTestataHappyHour_update]
	@P_1 BigInt,
	@P_2 Int,
	@P_3 Char(1),
	@P_4 VarChar(5),
	@P_5 VarChar(5),
	@P_6 Int,
	@P_7 Int,
	@P_8 Int,
	@P_9 Int,
	@P_10 Int,
	@P_11 DateTime2,
	@P_12 DateTime2,
	@P_13 Bit,
	@P_14 VarChar(1000),
	@P_15 DateTime2,
	@P_16 BigInt,
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; UPDATE [CoinlessTestataHappyHour] SET [giorno] = @P_2, [ampm] = @P_3, [dalle] = @P_4, [alle] = @P_5, [attivo] = @P_6, [platinum] = @P_7, [gold] = @P_8, [silver] = @P_9, [normal] = @P_10, [dal] = @P_11, [al] = @P_12, [F0] = @P_13, [T0] = @P_14, [D0] = @P_15, [N0] = @P_16 FROM [CoinlessTestataHappyHour] [base] JOIN [CoinlessTestataHappyHour_tracking] [side] ON [base].[id_happyhour] = [side].[id_happyhour] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[id_happyhour] = @P_1); SET @sync_row_count = @@ROWCOUNT;
END
