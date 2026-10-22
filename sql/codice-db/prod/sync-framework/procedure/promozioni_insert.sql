CREATE PROCEDURE [promozioni_insert]
	@P_1 BigInt,
	@P_2 VarChar(255),
	@P_3 DateTime,
	@P_4 DateTime,
	@P_5 Char(1),
	@P_6 Char(1),
	@P_7 DateTime,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; IF NOT EXISTS (SELECT * FROM [promozioni_tracking] WHERE [id] = @P_1) BEGIN SET IDENTITY_INSERT [promozioni] ON; INSERT INTO [promozioni]([id], [titolo], [dalla_data], [alla_data], [flagConvertiOldSilver], [flagRipristinaGoldInSilver], [scadenzaPromozione]) VALUES (@P_1, @P_2, @P_3, @P_4, @P_5, @P_6, @P_7);  SET @sync_row_count = @@rowcount; SET IDENTITY_INSERT [promozioni] OFF; END 
END
