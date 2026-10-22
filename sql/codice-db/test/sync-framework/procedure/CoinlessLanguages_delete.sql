CREATE PROCEDURE [CoinlessLanguages_delete]
	@P_1 Int,
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; DELETE [CoinlessLanguages] FROM [CoinlessLanguages] [base] JOIN [CoinlessLanguages_tracking] [side] ON [base].[id] = [side].[id] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[id] = @P_1); SET @sync_row_count = @@ROWCOUNT;
END
