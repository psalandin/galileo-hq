CREATE PROCEDURE [cache_dati_grafico_giornaliero_update]
	@P_1 VarChar(15),
	@P_2 Int,
	@P_3 Date,
	@P_4 Money,
	@P_5 Money,
	@P_6 Money,
	@P_7 Money,
	@P_8 BigInt,
	@P_9 BigInt,
	@P_10 BigInt,
	@P_11 BigInt,
	@P_12 BigInt,
	@P_13 Money,
	@P_14 Decimal(10,1),
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; UPDATE [cache_dati_grafico_giornaliero] SET [tipo] = @P_2, [EUIncassiMonete] = @P_4, [EUIncassiGettoni] = @P_5, [EUPremiPagati] = @P_6, [EUTicketsPagati] = @P_7, [NrMonete] = @P_8, [NrGettoni] = @P_9, [NrPremi] = @P_10, [NrTickets] = @P_11, [NrGettoniOut] = @P_12, [NrMoneteOut] = @P_13, [NPartite] = @P_14 FROM [cache_dati_grafico_giornaliero] [base] JOIN [cache_dati_grafico_giornaliero_tracking] [side] ON [base].[CodMac] = [side].[CodMac] AND [base].[DataRil] = [side].[DataRil] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[CodMac] = @P_1 AND [base].[DataRil] = @P_3); SET @sync_row_count = @@ROWCOUNT;
END
