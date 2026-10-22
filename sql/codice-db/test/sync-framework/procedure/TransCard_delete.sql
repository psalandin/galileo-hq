CREATE PROCEDURE [TransCard_delete]
	@P_15 UniqueIdentifier,
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; DELETE [TransCard] FROM [TransCard] [base] JOIN [TransCard_tracking] [side] ON [base].[IDOperazione] = [side].[IDOperazione] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[IDOperazione] = @P_15); SET @sync_row_count = @@ROWCOUNT;
END
