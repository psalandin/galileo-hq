CREATE PROCEDURE [promozioni_update]
	@P_1 BigInt,
	@P_2 VarChar(255),
	@P_3 DateTime,
	@P_4 DateTime,
	@P_5 Char(1),
	@P_6 Char(1),
	@P_7 DateTime,
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; UPDATE [promozioni] SET [titolo] = @P_2, [dalla_data] = @P_3, [alla_data] = @P_4, [flagConvertiOldSilver] = @P_5, [flagRipristinaGoldInSilver] = @P_6, [scadenzaPromozione] = @P_7 FROM [promozioni] [base] JOIN [promozioni_tracking] [side] ON [base].[id] = [side].[id] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[id] = @P_1); SET @sync_row_count = @@ROWCOUNT;
END
