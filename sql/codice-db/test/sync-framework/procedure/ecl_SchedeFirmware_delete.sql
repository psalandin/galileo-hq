CREATE PROCEDURE [ecl_SchedeFirmware_delete]
	@P_1 VarChar(17),
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; DELETE [ecl_SchedeFirmware] FROM [ecl_SchedeFirmware] [base] JOIN [ecl_SchedeFirmware_tracking] [side] ON [base].[macaddress] = [side].[macaddress] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[macaddress] = @P_1); SET @sync_row_count = @@ROWCOUNT;
END
