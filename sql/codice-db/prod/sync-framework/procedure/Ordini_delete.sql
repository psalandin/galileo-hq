CREATE PROCEDURE [Ordini_delete]
	@P_20 UniqueIdentifier,
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; DELETE [Ordini] FROM [Ordini] [base] JOIN [Ordini_tracking] [side] ON [base].[Keys] = [side].[Keys] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[Keys] = @P_20); SET @sync_row_count = @@ROWCOUNT;
END
