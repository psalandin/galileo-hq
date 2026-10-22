CREATE PROCEDURE [Owners_insert]
	@P_1 Int,
	@P_2 VarChar(100),
	@P_3 VarChar(255),
	@P_4 VarChar(50),
	@P_5 Decimal(4,1),
	@P_6 Int,
	@P_7 Bit,
	@P_8 VarChar(100),
	@P_9 Int,
	@P_10 DateTime,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; IF NOT EXISTS (SELECT * FROM [Owners_tracking] WHERE [Id] = @P_1) BEGIN INSERT INTO [Owners]([Id], [OwnerName], [OwnerAddress], [OwnerPhone], [Perc], [NImp], [F0], [T0], [N0], [D0]) VALUES (@P_1, @P_2, @P_3, @P_4, @P_5, @P_6, @P_7, @P_8, @P_9, @P_10);  SET @sync_row_count = @@rowcount;  END 
END
