CREATE PROCEDURE [EcsModuli_update]
	@P_1 Int,
	@P_2 VarChar(50),
	@P_3 VarChar(15),
	@P_4 Bit,
	@P_5 Int,
	@P_6 Bit,
	@P_7 VarChar(100),
	@P_8 Int,
	@P_9 DateTime,
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; UPDATE [EcsModuli] SET [MacAd] = @P_2, [ShortAd] = @P_3, [Abil] = @P_4, [NImp] = @P_5, [F0] = @P_6, [T0] = @P_7, [N0] = @P_8, [D0] = @P_9 FROM [EcsModuli] [base] JOIN [EcsModuli_tracking] [side] ON [base].[Id] = [side].[Id] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[Id] = @P_1); SET @sync_row_count = @@ROWCOUNT;
END
