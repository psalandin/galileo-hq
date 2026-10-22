CREATE PROCEDURE [Abbuoni_delete]
	@P_10 Int,
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; DELETE [Abbuoni] FROM [Abbuoni] [base] JOIN [Abbuoni_tracking] [side] ON [base].[Keys] = [side].[Keys] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[Keys] = @P_10); SET @sync_row_count = @@ROWCOUNT;
END
