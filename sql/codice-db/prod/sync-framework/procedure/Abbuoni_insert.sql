CREATE PROCEDURE [Abbuoni_insert]
	@P_1 BigInt,
	@P_2 Decimal(6,2),
	@P_3 Date,
	@P_4 Int,
	@P_5 Int,
	@P_6 Bit,
	@P_7 VarChar(100),
	@P_8 Int,
	@P_9 DateTime,
	@P_10 Int,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; IF NOT EXISTS (SELECT * FROM [Abbuoni_tracking] WHERE [Keys] = @P_10) BEGIN SET IDENTITY_INSERT [Abbuoni] ON; INSERT INTO [Abbuoni]([Id], [Valore], [Data], [Tickets], [NImp], [F0], [T0], [N0], [D0], [Keys]) VALUES (@P_1, @P_2, @P_3, @P_4, @P_5, @P_6, @P_7, @P_8, @P_9, @P_10);  SET @sync_row_count = @@rowcount; SET IDENTITY_INSERT [Abbuoni] OFF; END 
END
