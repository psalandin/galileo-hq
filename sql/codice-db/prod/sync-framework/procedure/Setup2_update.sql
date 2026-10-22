CREATE PROCEDURE [Setup2_update]
	@P_1 Int,
	@P_2 NVarChar(255),
	@P_3 NVarChar(max),
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; UPDATE [Setup2] SET [Valore] = @P_3 FROM [Setup2] [base] JOIN [Setup2_tracking] [side] ON [base].[IdPost] = [side].[IdPost] AND [base].[Chiave] = [side].[Chiave] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[IdPost] = @P_1 AND [base].[Chiave] = @P_2); SET @sync_row_count = @@ROWCOUNT;
END
