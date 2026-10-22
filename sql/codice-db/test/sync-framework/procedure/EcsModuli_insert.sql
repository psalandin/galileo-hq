CREATE PROCEDURE [EcsModuli_insert]
	@P_1 Int,
	@P_2 VarChar(50),
	@P_3 VarChar(15),
	@P_4 Bit,
	@P_5 Int,
	@P_6 Bit,
	@P_7 VarChar(100),
	@P_8 Int,
	@P_9 DateTime,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; IF NOT EXISTS (SELECT * FROM [EcsModuli_tracking] WHERE [Id] = @P_1) BEGIN INSERT INTO [EcsModuli]([Id], [MacAd], [ShortAd], [Abil], [NImp], [F0], [T0], [N0], [D0]) VALUES (@P_1, @P_2, @P_3, @P_4, @P_5, @P_6, @P_7, @P_8, @P_9);  SET @sync_row_count = @@rowcount;  END 
END
