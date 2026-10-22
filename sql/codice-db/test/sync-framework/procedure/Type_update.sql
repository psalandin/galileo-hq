CREATE PROCEDURE [Type_update]
	@P_1 BigInt,
	@P_2 VarChar(50),
	@P_3 BigInt,
	@P_4 Bit,
	@P_5 VarChar(100),
	@P_6 Int,
	@P_7 DateTime,
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; UPDATE [Type] SET [TypeName] = @P_2, [Color] = @P_3, [F0] = @P_4, [T0] = @P_5, [N0] = @P_6, [D0] = @P_7 FROM [Type] [base] JOIN [Type_tracking] [side] ON [base].[Id] = [side].[Id] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[Id] = @P_1); SET @sync_row_count = @@ROWCOUNT;
END
