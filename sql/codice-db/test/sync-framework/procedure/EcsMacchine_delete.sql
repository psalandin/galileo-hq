CREATE PROCEDURE [EcsMacchine_delete]
	@P_2 VarChar(15),
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; DELETE [EcsMacchine] FROM [EcsMacchine] [base] JOIN [EcsMacchine_tracking] [side] ON [base].[CodMac] = [side].[CodMac] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[CodMac] = @P_2); SET @sync_row_count = @@ROWCOUNT;
END
