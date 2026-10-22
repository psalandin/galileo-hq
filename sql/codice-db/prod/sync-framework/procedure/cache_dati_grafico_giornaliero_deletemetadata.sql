CREATE PROCEDURE [cache_dati_grafico_giornaliero_deletemetadata]
	@P_1 VarChar(15),
	@P_3 Date,
	@sync_check_concurrency Int,
	@sync_row_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; DELETE [side] FROM [cache_dati_grafico_giornaliero_tracking] [side] WHERE [CodMac] = @P_1 AND [DataRil] = @P_3 AND (@sync_check_concurrency = 0 or [local_update_peer_timestamp] = @sync_row_timestamp);SET @sync_row_count = @@ROWCOUNT;
END
