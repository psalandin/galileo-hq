CREATE PROCEDURE [TransCard_update]
	@P_1 VarChar(16),
	@P_2 Int,
	@P_3 VarChar(50),
	@P_4 DateTime,
	@P_5 Money,
	@P_6 Money,
	@P_7 Money,
	@P_8 Bit,
	@P_9 VarChar(100),
	@P_10 Int,
	@P_11 DateTime,
	@P_12 Int,
	@P_13 Money,
	@P_14 Bit,
	@P_15 UniqueIdentifier,
	@P_16 Int,
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; UPDATE [TransCard] SET [IdCli] = @P_1, [NImp] = @P_2, [CodMac] = @P_3, [Data] = @P_4, [ValoreOperazione] = @P_5, [ValoreFinale] = @P_6, [ValoreBonus] = @P_7, [F0] = @P_8, [T0] = @P_9, [N0] = @P_10, [D0] = @P_11, [Operatore] = @P_12, [ValoreCassa] = @P_13, [WinMt] = @P_14, [FlagOpDaVerificare] = @P_16 FROM [TransCard] [base] JOIN [TransCard_tracking] [side] ON [base].[IDOperazione] = [side].[IDOperazione] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[IDOperazione] = @P_15); SET @sync_row_count = @@ROWCOUNT;
END
