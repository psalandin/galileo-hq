CREATE PROCEDURE [ecl_DeviceProvisioning_update]
	@P_1 VarChar(17),
	@P_2 DateTime,
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; UPDATE [ecl_DeviceProvisioning] SET [updated] = @P_2 FROM [ecl_DeviceProvisioning] [base] JOIN [ecl_DeviceProvisioning_tracking] [side] ON [base].[macaddress] = [side].[macaddress] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[macaddress] = @P_1); SET @sync_row_count = @@ROWCOUNT;
END
