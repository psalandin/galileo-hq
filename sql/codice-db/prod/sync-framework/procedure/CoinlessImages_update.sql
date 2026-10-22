CREATE PROCEDURE [CoinlessImages_update]
	@P_1 Int,
	@P_2 VarChar(255),
	@P_3 VarBinary(max),
	@P_4 VarChar(3),
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; UPDATE [CoinlessImages] SET [ImageName] = @P_2, [imageBinaryData] = @P_3, [majorFirmware] = @P_4 FROM [CoinlessImages] [base] JOIN [CoinlessImages_tracking] [side] ON [base].[id] = [side].[id] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[id] = @P_1); SET @sync_row_count = @@ROWCOUNT;
END
