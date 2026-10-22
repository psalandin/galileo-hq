CREATE PROCEDURE [GruMovimenti_delete]
	@P_1 BigInt,
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; DELETE [GruMovimenti] FROM [GruMovimenti] [base] JOIN [GruMovimenti_tracking] [side] ON [base].[IdMovGru] = [side].[IdMovGru] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[IdMovGru] = @P_1); SET @sync_row_count = @@ROWCOUNT;
END
