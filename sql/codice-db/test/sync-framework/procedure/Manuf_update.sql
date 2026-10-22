CREATE PROCEDURE [Manuf_update]
	@P_1 BigInt,
	@P_2 VarChar(50),
	@P_3 Bit,
	@P_4 VarChar(100),
	@P_5 Int,
	@P_6 DateTime,
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; UPDATE [Manuf] SET [ManufName] = @P_2, [F0] = @P_3, [T0] = @P_4, [N0] = @P_5, [D0] = @P_6 FROM [Manuf] [base] JOIN [Manuf_tracking] [side] ON [base].[Id] = [side].[Id] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[Id] = @P_1); SET @sync_row_count = @@ROWCOUNT;
END
