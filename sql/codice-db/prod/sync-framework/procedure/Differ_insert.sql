CREATE PROCEDURE [Differ_insert]
	@P_1 DateTime,
	@P_2 Decimal(10,2),
	@P_3 Int,
	@P_4 Bit,
	@P_5 VarChar(100),
	@P_6 Int,
	@P_7 DateTime,
	@P_8 UniqueIdentifier,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; IF NOT EXISTS (SELECT * FROM [Differ_tracking] WHERE [Keys] = @P_8) BEGIN INSERT INTO [Differ]([Data], [VarVal], [NImp], [F0], [T0], [N0], [D0], [Keys]) VALUES (@P_1, @P_2, @P_3, @P_4, @P_5, @P_6, @P_7, @P_8);  SET @sync_row_count = @@rowcount;  END 
END
