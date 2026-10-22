CREATE PROCEDURE [Premi_delete]
	@P_1 VarChar(50),
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; DELETE [Premi] FROM [Premi] [base] JOIN [Premi_tracking] [side] ON [base].[Codice] = [side].[Codice] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[Codice] = @P_1); SET @sync_row_count = @@ROWCOUNT;
END
