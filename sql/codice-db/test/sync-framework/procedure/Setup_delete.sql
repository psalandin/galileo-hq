CREATE PROCEDURE [Setup_delete]
	@P_1 TinyInt,
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; DELETE [Setup] FROM [Setup] [base] JOIN [Setup_tracking] [side] ON [base].[IDPost] = [side].[IDPost] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[IDPost] = @P_1); SET @sync_row_count = @@ROWCOUNT;
END
