CREATE PROCEDURE [Incassi_insert]
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
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; IF NOT EXISTS (SELECT * FROM [Incassi_tracking] WHERE [Keys] = @P_13) BEGIN INSERT INTO [Incassi]([Data], [Oper], [Red], [Gru], [Alt], [Push], [NImp], [F0], [T0], [N0], [D0], [Mdb], [Keys]) VALUES (@P_1, @P_2, @P_3, @P_4, @P_5, @P_6, @P_7, @P_8, @P_9, @P_10, @P_11, @P_12, @P_13);  SET @sync_row_count = @@rowcount;  END 
END
