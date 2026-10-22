CREATE PROCEDURE [EcsErr_delete]
	@P_9 UniqueIdentifier,
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; DELETE [EcsErr] FROM [EcsErr] [base] JOIN [EcsErr_tracking] [side] ON [base].[Keys] = [side].[Keys] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[Keys] = @P_9); SET @sync_row_count = @@ROWCOUNT;
END
