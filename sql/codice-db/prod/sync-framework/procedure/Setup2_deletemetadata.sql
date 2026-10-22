CREATE PROCEDURE [Setup2_deletemetadata]
	@P_1 Int,
	@P_2 NVarChar(255),
	@sync_check_concurrency Int,
	@sync_row_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; DELETE [side] FROM [Setup2_tracking] [side] WHERE [IdPost] = @P_1 AND [Chiave] = @P_2 AND (@sync_check_concurrency = 0 or [local_update_peer_timestamp] = @sync_row_timestamp);SET @sync_row_count = @@ROWCOUNT;
END
