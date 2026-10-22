CREATE PROCEDURE [ecl_firmware_update]
	@P_1 Int,
	@P_2 VarChar(255),
	@P_3 VarChar(255),
	@P_4 VarChar(15),
	@P_5 VarChar(255),
	@P_6 VarChar(3),
	@P_7 VarChar(9),
	@P_8 Int,
	@P_9 VarBinary(max),
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; UPDATE [ecl_firmware] SET [filename] = @P_2, [url] = @P_3, [version] = @P_4, [path] = @P_5, [tipoScheda] = @P_6, [tipoFirmware] = @P_7, [msgCount] = @P_8, [firmwareBinaryData] = @P_9 FROM [ecl_firmware] [base] JOIN [ecl_firmware_tracking] [side] ON [base].[id] = [side].[id] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[id] = @P_1); SET @sync_row_count = @@ROWCOUNT;
END
