CREATE PROCEDURE [PartiteOspiti_update]
	@P_1 BigInt,
	@P_2 VarChar(16),
	@P_3 DateTime,
	@P_4 Int,
	@P_5 Int,
	@P_6 Int,
	@P_7 BigInt,
	@P_8 DateTime2,
	@P_9 BigInt,
	@P_10 DateTime2,
	@P_11 BigInt,
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; UPDATE [PartiteOspiti] SET [IdContatto] = @P_1, [device] = @P_2, [DataUltimaPartita] = @P_3, [NrPartiteConsecutive] = @P_4, [TotPartite] = @P_5, [TotTickets] = @P_6, [CreatedBy] = @P_7, [CreatedAt] = @P_8, [UpdatedBy] = @P_9, [UpdatedAt] = @P_10 FROM [PartiteOspiti] [base] JOIN [PartiteOspiti_tracking] [side] ON [base].[id] = [side].[id] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[id] = @P_11); SET @sync_row_count = @@ROWCOUNT;
END
