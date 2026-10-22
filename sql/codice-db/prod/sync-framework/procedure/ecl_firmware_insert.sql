CREATE PROCEDURE [ecl_firmware_insert]
	@P_1 Int,
	@P_2 VarChar(255),
	@P_3 VarChar(255),
	@P_4 VarChar(15),
	@P_5 VarChar(255),
	@P_6 VarChar(3),
	@P_7 VarChar(9),
	@P_8 Int,
	@P_9 VarBinary(max),
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; IF NOT EXISTS (SELECT * FROM [ecl_firmware_tracking] WHERE [id] = @P_1) BEGIN SET IDENTITY_INSERT [ecl_firmware] ON; INSERT INTO [ecl_firmware]([id], [filename], [url], [version], [path], [tipoScheda], [tipoFirmware], [msgCount], [firmwareBinaryData]) VALUES (@P_1, @P_2, @P_3, @P_4, @P_5, @P_6, @P_7, @P_8, @P_9);  SET @sync_row_count = @@rowcount; SET IDENTITY_INSERT [ecl_firmware] OFF; END 
END
