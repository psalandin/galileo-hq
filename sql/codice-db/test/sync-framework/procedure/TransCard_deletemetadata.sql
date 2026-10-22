CREATE PROCEDURE [TransCard_deletemetadata]
	@P_15 UniqueIdentifier,
	@sync_check_concurrency Int,
	@sync_row_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; DELETE [side] FROM [TransCard_tracking] [side] WHERE [IDOperazione] = @P_15 AND (@sync_check_concurrency = 0 or [local_update_peer_timestamp] = @sync_row_timestamp);SET @sync_row_count = @@ROWCOUNT;
END
