CREATE PROCEDURE [Ospiti_insert]
	@P_1 BigInt,
	@P_2 BigInt,
	@P_3 VarChar(16),
	@P_4 BigInt,
	@P_5 BigInt,
	@P_6 DateTime2,
	@P_7 BigInt,
	@P_8 DateTime2,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; IF NOT EXISTS (SELECT * FROM [Ospiti_tracking] WHERE [IdOspite] = @P_1) BEGIN SET IDENTITY_INSERT [Ospiti] ON; INSERT INTO [Ospiti]([IdOspite], [IdCompleanno], [CardId], [IdContatto], [CreatedBy], [CreatedAt], [UpdatedBy], [UpdatedAt]) VALUES (@P_1, @P_2, @P_3, @P_4, @P_5, @P_6, @P_7, @P_8);  SET @sync_row_count = @@rowcount; SET IDENTITY_INSERT [Ospiti] OFF; END 
END
