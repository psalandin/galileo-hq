CREATE PROCEDURE [CoinlessLanguages_update]
	@P_1 Int,
	@P_2 VarChar(255),
	@P_3 VarChar(3),
	@P_4 Int,
	@P_5 Int,
	@P_6 Int,
	@P_7 Int,
	@P_8 VarChar(10),
	@P_9 VarChar(255),
	@P_10 Char(1),
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; UPDATE [CoinlessLanguages] SET [testo] = @P_2, [lingua] = @P_3, [nr_campo] = @P_4, [posx] = @P_5, [posy] = @P_6, [color] = @P_7, [font] = @P_8, [note] = @P_9, [align] = @P_10 FROM [CoinlessLanguages] [base] JOIN [CoinlessLanguages_tracking] [side] ON [base].[id] = [side].[id] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[id] = @P_1); SET @sync_row_count = @@ROWCOUNT;
END
