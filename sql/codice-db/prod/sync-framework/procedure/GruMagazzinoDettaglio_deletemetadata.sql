CREATE PROCEDURE [GruMagazzinoDettaglio_deletemetadata]
	@P_1 VarChar(20),
	@P_2 TinyInt,
	@sync_check_concurrency Int,
	@sync_row_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; DELETE [side] FROM [GruMagazzinoDettaglio_tracking] [side] WHERE [CodMac] = @P_1 AND [SlotNo] = @P_2 AND (@sync_check_concurrency = 0 or [local_update_peer_timestamp] = @sync_row_timestamp);SET @sync_row_count = @@ROWCOUNT;
END
