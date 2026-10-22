CREATE PROCEDURE [Differ_update]
	@P_1 DateTime,
	@P_2 Decimal(10,2),
	@P_3 Int,
	@P_4 Bit,
	@P_5 VarChar(100),
	@P_6 Int,
	@P_7 DateTime,
	@P_8 UniqueIdentifier,
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; UPDATE [Differ] SET [Data] = @P_1, [VarVal] = @P_2, [NImp] = @P_3, [F0] = @P_4, [T0] = @P_5, [N0] = @P_6, [D0] = @P_7 FROM [Differ] [base] JOIN [Differ_tracking] [side] ON [base].[Keys] = [side].[Keys] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[Keys] = @P_8); SET @sync_row_count = @@ROWCOUNT;
END
