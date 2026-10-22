CREATE PROCEDURE [ecl_Provisioning_delete]
	@P_3 BigInt,
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; DELETE [ecl_Provisioning] FROM [ecl_Provisioning] [base] JOIN [ecl_Provisioning_tracking] [side] ON [base].[id] = [side].[id] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[id] = @P_3); SET @sync_row_count = @@ROWCOUNT;
END
