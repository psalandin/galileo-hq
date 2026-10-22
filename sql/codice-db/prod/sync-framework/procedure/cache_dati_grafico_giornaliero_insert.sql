CREATE PROCEDURE [cache_dati_grafico_giornaliero_insert]
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
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; IF NOT EXISTS (SELECT * FROM [cache_dati_grafico_giornaliero_tracking] WHERE [CodMac] = @P_1 AND [DataRil] = @P_3) BEGIN INSERT INTO [cache_dati_grafico_giornaliero]([CodMac], [tipo], [DataRil], [EUIncassiMonete], [EUIncassiGettoni], [EUPremiPagati], [EUTicketsPagati], [NrMonete], [NrGettoni], [NrPremi], [NrTickets], [NrGettoniOut], [NrMoneteOut], [NPartite]) VALUES (@P_1, @P_2, @P_3, @P_4, @P_5, @P_6, @P_7, @P_8, @P_9, @P_10, @P_11, @P_12, @P_13, @P_14);  SET @sync_row_count = @@rowcount;  END 
END
