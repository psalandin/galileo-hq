CREATE PROCEDURE [CoinlessLogEventiBlacklist_update]
	@P_1 BigInt,
	@P_2 DateTime,
	@P_3 VarChar(512),
	@P_4 VarChar(16),
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; UPDATE [CoinlessLogEventiBlacklist] SET [data_operazione] = @P_2, [testo] = @P_3, [cardid] = @P_4 FROM [CoinlessLogEventiBlacklist] [base] JOIN [CoinlessLogEventiBlacklist_tracking] [side] ON [base].[id] = [side].[id] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[id] = @P_1); SET @sync_row_count = @@ROWCOUNT;
END
