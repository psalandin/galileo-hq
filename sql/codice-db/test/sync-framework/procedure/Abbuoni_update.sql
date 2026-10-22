CREATE PROCEDURE [Abbuoni_update]
	@P_1 BigInt,
	@P_2 Decimal(6,2),
	@P_3 Date,
	@P_4 Int,
	@P_5 Int,
	@P_6 Bit,
	@P_7 VarChar(100),
	@P_8 Int,
	@P_9 DateTime,
	@P_10 Int,
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; UPDATE [Abbuoni] SET [Id] = @P_1, [Valore] = @P_2, [Data] = @P_3, [Tickets] = @P_4, [NImp] = @P_5, [F0] = @P_6, [T0] = @P_7, [N0] = @P_8, [D0] = @P_9 FROM [Abbuoni] [base] JOIN [Abbuoni_tracking] [side] ON [base].[Keys] = [side].[Keys] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[Keys] = @P_10); SET @sync_row_count = @@ROWCOUNT;
END
