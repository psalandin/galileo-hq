CREATE PROCEDURE [Incassi_delete]
	@P_13 UniqueIdentifier,
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; DELETE [Incassi] FROM [Incassi] [base] JOIN [Incassi_tracking] [side] ON [base].[Keys] = [side].[Keys] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[Keys] = @P_13); SET @sync_row_count = @@ROWCOUNT;
END
