CREATE PROCEDURE [Ospiti_update]
	@P_1 BigInt,
	@P_2 BigInt,
	@P_3 VarChar(16),
	@P_4 BigInt,
	@P_5 BigInt,
	@P_6 DateTime2,
	@P_7 BigInt,
	@P_8 DateTime2,
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; UPDATE [Ospiti] SET [IdCompleanno] = @P_2, [CardId] = @P_3, [IdContatto] = @P_4, [CreatedBy] = @P_5, [CreatedAt] = @P_6, [UpdatedBy] = @P_7, [UpdatedAt] = @P_8 FROM [Ospiti] [base] JOIN [Ospiti_tracking] [side] ON [base].[IdOspite] = [side].[IdOspite] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[IdOspite] = @P_1); SET @sync_row_count = @@ROWCOUNT;
END
