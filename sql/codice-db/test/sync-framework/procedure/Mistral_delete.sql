CREATE PROCEDURE [Mistral_delete]
	@P_1 VarChar(15),
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; DELETE [Mistral] FROM [Mistral] [base] JOIN [Mistral_tracking] [side] ON [base].[CodCard] = [side].[CodCard] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[CodCard] = @P_1); SET @sync_row_count = @@ROWCOUNT;
END
