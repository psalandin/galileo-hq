CREATE PROCEDURE [BEConfig_update]
	@P_1 VarChar(17),
	@P_2 NVarChar(max),
	@P_3 NVarChar(max),
	@P_4 NVarChar(max),
	@P_5 DateTime,
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; UPDATE [BEConfig] SET [BeInfo] = @P_2, [BeConfig] = @P_3, [BiConfig] = @P_4, [DetectionDate] = @P_5 FROM [BEConfig] [base] JOIN [BEConfig_tracking] [side] ON [base].[Macaddress] = [side].[Macaddress] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[Macaddress] = @P_1); SET @sync_row_count = @@ROWCOUNT;
END
