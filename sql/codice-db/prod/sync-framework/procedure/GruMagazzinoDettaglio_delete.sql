CREATE PROCEDURE [GruMagazzinoDettaglio_delete]
	@P_1 VarChar(20),
	@P_2 TinyInt,
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; DELETE [GruMagazzinoDettaglio] FROM [GruMagazzinoDettaglio] [base] JOIN [GruMagazzinoDettaglio_tracking] [side] ON [base].[CodMac] = [side].[CodMac] AND [base].[SlotNo] = [side].[SlotNo] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[CodMac] = @P_1 AND [base].[SlotNo] = @P_2); SET @sync_row_count = @@ROWCOUNT;
END
