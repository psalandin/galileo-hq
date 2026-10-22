CREATE PROCEDURE [Manuf_insert]
	@P_1 BigInt,
	@P_2 VarChar(50),
	@P_3 Bit,
	@P_4 VarChar(100),
	@P_5 Int,
	@P_6 DateTime,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; IF NOT EXISTS (SELECT * FROM [Manuf_tracking] WHERE [Id] = @P_1) BEGIN SET IDENTITY_INSERT [Manuf] ON; INSERT INTO [Manuf]([Id], [ManufName], [F0], [T0], [N0], [D0]) VALUES (@P_1, @P_2, @P_3, @P_4, @P_5, @P_6);  SET @sync_row_count = @@rowcount; SET IDENTITY_INSERT [Manuf] OFF; END 
END
