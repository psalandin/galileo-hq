CREATE PROCEDURE [Machines_update]
	@P_1 BigInt,
	@P_2 VarChar(50),
	@P_3 BigInt,
	@P_4 BigInt,
	@P_5 Bit,
	@P_6 Bit,
	@P_7 VarChar(100),
	@P_8 Int,
	@P_9 DateTime,
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; UPDATE [Machines] SET [MacName] = @P_2, [Manufacturer] = @P_3, [Type] = @P_4, [CntrOut] = @P_5, [F0] = @P_6, [T0] = @P_7, [N0] = @P_8, [D0] = @P_9 FROM [Machines] [base] JOIN [Machines_tracking] [side] ON [base].[Id] = [side].[Id] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[Id] = @P_1); SET @sync_row_count = @@ROWCOUNT;
END
