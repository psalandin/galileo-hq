CREATE PROCEDURE [CoinlessTestataHappyHour_deletemetadata]
	@P_1 BigInt,
	@sync_check_concurrency Int,
	@sync_row_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; DELETE [side] FROM [CoinlessTestataHappyHour_tracking] [side] WHERE [id_happyhour] = @P_1 AND (@sync_check_concurrency = 0 or [local_update_peer_timestamp] = @sync_row_timestamp);SET @sync_row_count = @@ROWCOUNT;
END
