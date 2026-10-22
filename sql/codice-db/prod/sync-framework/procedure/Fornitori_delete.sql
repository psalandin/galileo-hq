CREATE PROCEDURE [Fornitori_delete]
	@P_1 VarChar(100),
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; DELETE [Fornitori] FROM [Fornitori] [base] JOIN [Fornitori_tracking] [side] ON [base].[Nome] = [side].[Nome] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[Nome] = @P_1); SET @sync_row_count = @@ROWCOUNT;
END
