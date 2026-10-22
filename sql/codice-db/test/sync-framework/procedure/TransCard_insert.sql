CREATE PROCEDURE [TransCard_insert]
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
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; IF NOT EXISTS (SELECT * FROM [TransCard_tracking] WHERE [IDOperazione] = @P_15) BEGIN INSERT INTO [TransCard]([IdCli], [NImp], [CodMac], [Data], [ValoreOperazione], [ValoreFinale], [ValoreBonus], [F0], [T0], [N0], [D0], [Operatore], [ValoreCassa], [WinMt], [IDOperazione], [FlagOpDaVerificare]) VALUES (@P_1, @P_2, @P_3, @P_4, @P_5, @P_6, @P_7, @P_8, @P_9, @P_10, @P_11, @P_12, @P_13, @P_14, @P_15, @P_16);  SET @sync_row_count = @@rowcount;  END 
END
