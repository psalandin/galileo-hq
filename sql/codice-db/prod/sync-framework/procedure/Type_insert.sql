CREATE PROCEDURE [Type_insert]
	@P_1 BigInt,
	@P_2 VarChar(50),
	@P_3 BigInt,
	@P_4 Bit,
	@P_5 VarChar(100),
	@P_6 Int,
	@P_7 DateTime,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; IF NOT EXISTS (SELECT * FROM [Type_tracking] WHERE [Id] = @P_1) BEGIN INSERT INTO [Type]([Id], [TypeName], [Color], [F0], [T0], [N0], [D0]) VALUES (@P_1, @P_2, @P_3, @P_4, @P_5, @P_6, @P_7);  SET @sync_row_count = @@rowcount;  END 
END
