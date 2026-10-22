CREATE PROCEDURE [UID_Ammessi_delete]
	@P_1 VarChar(16),
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; DELETE [UID_Ammessi] FROM [UID_Ammessi] [base] JOIN [UID_Ammessi_tracking] [side] ON [base].[UID] = [side].[UID] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[UID] = @P_1); SET @sync_row_count = @@ROWCOUNT;
END
