CREATE PROCEDURE [cache_dati_grafico_giornaliero_delete]
	@P_1 VarChar(15),
	@P_3 Date,
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; DELETE [cache_dati_grafico_giornaliero] FROM [cache_dati_grafico_giornaliero] [base] JOIN [cache_dati_grafico_giornaliero_tracking] [side] ON [base].[CodMac] = [side].[CodMac] AND [base].[DataRil] = [side].[DataRil] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[CodMac] = @P_1 AND [base].[DataRil] = @P_3); SET @sync_row_count = @@ROWCOUNT;
END
