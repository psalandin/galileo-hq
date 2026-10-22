CREATE PROCEDURE [Incassi_update]
	@P_1 DateTime,
	@P_2 Decimal(5,0),
	@P_3 Money,
	@P_4 Money,
	@P_5 Money,
	@P_6 Money,
	@P_7 Int,
	@P_8 Bit,
	@P_9 VarChar(100),
	@P_10 Int,
	@P_11 DateTime,
	@P_12 VarBinary(max),
	@P_13 UniqueIdentifier,
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; UPDATE [Incassi] SET [Data] = @P_1, [Oper] = @P_2, [Red] = @P_3, [Gru] = @P_4, [Alt] = @P_5, [Push] = @P_6, [NImp] = @P_7, [F0] = @P_8, [T0] = @P_9, [N0] = @P_10, [D0] = @P_11, [Mdb] = @P_12 FROM [Incassi] [base] JOIN [Incassi_tracking] [side] ON [base].[Keys] = [side].[Keys] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[Keys] = @P_13); SET @sync_row_count = @@ROWCOUNT;
END
