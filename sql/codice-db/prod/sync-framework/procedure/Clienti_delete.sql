CREATE PROCEDURE [Clienti_delete]
	@P_45 BigInt,
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; DELETE [Clienti] FROM [Clienti] [base] JOIN [Clienti_tracking] [side] ON [base].[IdLong] = [side].[IdLong] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[IdLong] = @P_45); SET @sync_row_count = @@ROWCOUNT;
END
