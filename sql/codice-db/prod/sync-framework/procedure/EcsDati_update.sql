CREATE PROCEDURE [EcsDati_update]
	@P_1 VarChar(100),
	@P_2 TinyInt,
	@P_3 DateTime,
	@P_4 BigInt,
	@P_5 BigInt,
	@P_6 BigInt,
	@P_7 BigInt,
	@P_8 BigInt,
	@P_9 BigInt,
	@P_10 BigInt,
	@P_11 BigInt,
	@P_12 BigInt,
	@P_13 BigInt,
	@P_14 BigInt,
	@P_15 BigInt,
	@P_16 BigInt,
	@P_17 BigInt,
	@P_18 BigInt,
	@P_19 BigInt,
	@P_20 Int,
	@P_21 Money,
	@P_22 Bit,
	@P_23 VarChar(100),
	@P_24 Int,
	@P_25 DateTime,
	@P_26 UniqueIdentifier,
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; UPDATE [EcsDati] SET [CodMac] = @P_1, [Stato] = @P_2, [DataRil] = @P_3, [In1] = @P_4, [In2] = @P_5, [In3] = @P_6, [In4] = @P_7, [In5] = @P_8, [In6] = @P_9, [In7] = @P_10, [In8] = @P_11, [In9] = @P_12, [In10] = @P_13, [In11] = @P_14, [In12] = @P_15, [In13] = @P_16, [In14] = @P_17, [In15] = @P_18, [In16] = @P_19, [NImp] = @P_20, [ValoreUscita] = @P_21, [F0] = @P_22, [T0] = @P_23, [N0] = @P_24, [D0] = @P_25 FROM [EcsDati] [base] JOIN [EcsDati_tracking] [side] ON [base].[Keys] = [side].[Keys] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[Keys] = @P_26); SET @sync_row_count = @@ROWCOUNT;
END
