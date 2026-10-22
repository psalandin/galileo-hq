CREATE PROCEDURE [TipoRicaricheCompleanni_update]
	@P_1 Int,
	@P_2 VarChar(255),
	@P_3 Int,
	@P_4 Int,
	@P_5 Int,
	@P_6 BigInt,
	@P_7 DateTime2,
	@P_8 BigInt,
	@P_9 DateTime2,
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; UPDATE [TipoRicaricheCompleanni] SET [descrizione] = @P_2, [ValorePrecaricatoCrediti] = @P_3, [ValorePrecaricatoBonus] = @P_4, [abilitato] = @P_5, [CreatedBy] = @P_6, [CreatedAt] = @P_7, [UpdatedBy] = @P_8, [UpdatedAt] = @P_9 FROM [TipoRicaricheCompleanni] [base] JOIN [TipoRicaricheCompleanni_tracking] [side] ON [base].[id] = [side].[id] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[id] = @P_1); SET @sync_row_count = @@ROWCOUNT;
END
