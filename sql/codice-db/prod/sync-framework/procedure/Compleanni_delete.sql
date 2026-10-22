CREATE PROCEDURE [Compleanni_delete]
	@P_1 BigInt,
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; DELETE [Compleanni] FROM [Compleanni] [base] JOIN [Compleanni_tracking] [side] ON [base].[IdCompleanno] = [side].[IdCompleanno] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[IdCompleanno] = @P_1); SET @sync_row_count = @@ROWCOUNT;
END
