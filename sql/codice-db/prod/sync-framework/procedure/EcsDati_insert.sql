CREATE PROCEDURE [EcsDati_insert]
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
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; IF NOT EXISTS (SELECT * FROM [EcsDati_tracking] WHERE [Keys] = @P_26) BEGIN INSERT INTO [EcsDati]([CodMac], [Stato], [DataRil], [In1], [In2], [In3], [In4], [In5], [In6], [In7], [In8], [In9], [In10], [In11], [In12], [In13], [In14], [In15], [In16], [NImp], [ValoreUscita], [F0], [T0], [N0], [D0], [Keys]) VALUES (@P_1, @P_2, @P_3, @P_4, @P_5, @P_6, @P_7, @P_8, @P_9, @P_10, @P_11, @P_12, @P_13, @P_14, @P_15, @P_16, @P_17, @P_18, @P_19, @P_20, @P_21, @P_22, @P_23, @P_24, @P_25, @P_26);  SET @sync_row_count = @@rowcount;  END 
END
