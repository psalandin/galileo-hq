CREATE PROCEDURE [CoinlessImages_insert]
	@P_1 Int,
	@P_2 VarChar(255),
	@P_3 VarBinary(max),
	@P_4 VarChar(3),
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; IF NOT EXISTS (SELECT * FROM [CoinlessImages_tracking] WHERE [id] = @P_1) BEGIN SET IDENTITY_INSERT [CoinlessImages] ON; INSERT INTO [CoinlessImages]([id], [ImageName], [imageBinaryData], [majorFirmware]) VALUES (@P_1, @P_2, @P_3, @P_4);  SET @sync_row_count = @@rowcount; SET IDENTITY_INSERT [CoinlessImages] OFF; END 
END
