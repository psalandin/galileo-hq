CREATE PROCEDURE [ecl_SchedeFirmware_update]
	@P_1 VarChar(17),
	@P_2 VarChar(3),
	@P_3 VarChar(15),
	@P_4 DateTime,
	@P_5 VarChar(30),
	@P_6 VarChar(30),
	@P_7 VarChar(30),
	@P_8 DateTime,
	@P_9 VarChar(30),
	@P_10 VarChar(10),
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; UPDATE [ecl_SchedeFirmware] SET [tipoScheda] = @P_2, [tipoFirmware] = @P_3, [dataAggiornamento] = @P_4, [device] = @P_5, [requestedVersion] = @P_6, [detectedVersion] = @P_7, [dataVerifica] = @P_8, [bidetectedVersion] = @P_9, [status] = @P_10 FROM [ecl_SchedeFirmware] [base] JOIN [ecl_SchedeFirmware_tracking] [side] ON [base].[macaddress] = [side].[macaddress] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[macaddress] = @P_1); SET @sync_row_count = @@ROWCOUNT;
END
