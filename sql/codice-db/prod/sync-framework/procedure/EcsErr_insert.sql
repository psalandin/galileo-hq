CREATE PROCEDURE [EcsErr_insert]
	@P_1 TinyInt,
	@P_2 DateTime,
	@P_3 TinyInt,
	@P_4 Int,
	@P_5 Bit,
	@P_6 VarChar(100),
	@P_7 Int,
	@P_8 DateTime,
	@P_9 UniqueIdentifier,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; IF NOT EXISTS (SELECT * FROM [EcsErr_tracking] WHERE [Keys] = @P_9) BEGIN INSERT INTO [EcsErr]([IdMod], [Data], [CodErr], [NImp], [F0], [T0], [N0], [D0], [Keys]) VALUES (@P_1, @P_2, @P_3, @P_4, @P_5, @P_6, @P_7, @P_8, @P_9);  SET @sync_row_count = @@rowcount;  END 
END
