CREATE PROCEDURE [CoinlessLanguages_insert]
	@P_1 Int,
	@P_2 VarChar(255),
	@P_3 VarChar(3),
	@P_4 Int,
	@P_5 Int,
	@P_6 Int,
	@P_7 Int,
	@P_8 VarChar(10),
	@P_9 VarChar(255),
	@P_10 Char(1),
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; IF NOT EXISTS (SELECT * FROM [CoinlessLanguages_tracking] WHERE [id] = @P_1) BEGIN SET IDENTITY_INSERT [CoinlessLanguages] ON; INSERT INTO [CoinlessLanguages]([id], [testo], [lingua], [nr_campo], [posx], [posy], [color], [font], [note], [align]) VALUES (@P_1, @P_2, @P_3, @P_4, @P_5, @P_6, @P_7, @P_8, @P_9, @P_10);  SET @sync_row_count = @@rowcount; SET IDENTITY_INSERT [CoinlessLanguages] OFF; END 
END
