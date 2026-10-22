CREATE PROCEDURE [CoinlessMacchineHappyHour_update]
	@P_1 BigInt,
	@P_2 BigInt,
	@P_3 VarChar(15),
	@P_4 VarChar(8),
	@P_5 Int,
	@P_6 Int,
	@P_7 Int,
	@P_8 Int,
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; UPDATE [CoinlessMacchineHappyHour] SET [fk_testata] = @P_2, [codmac] = @P_3, [device] = @P_4, [perc_platinum] = @P_5, [perc_gold] = @P_6, [perc_silver] = @P_7, [perc_normal] = @P_8 FROM [CoinlessMacchineHappyHour] [base] JOIN [CoinlessMacchineHappyHour_tracking] [side] ON [base].[id_macchineHappyHour] = [side].[id_macchineHappyHour] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[id_macchineHappyHour] = @P_1); SET @sync_row_count = @@ROWCOUNT;
END
