CREATE PROCEDURE [CoinlessClonedCards_insert]
	@P_1 BigInt,
	@P_2 VarChar(16),
	@P_3 DateTime,
	@P_4 VarChar(10),
	@P_5 BigInt,
	@P_6 BigInt,
	@P_7 BigInt,
	@P_8 VarChar(16),
	@P_9 VarChar(16),
	@P_10 Int,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; IF NOT EXISTS (SELECT * FROM [CoinlessClonedCards_tracking] WHERE [id_card_clonate] = @P_1) BEGIN SET IDENTITY_INSERT [CoinlessClonedCards] ON; INSERT INTO [CoinlessClonedCards]([id_card_clonate], [cardid], [DataMovimento], [TipoMovimento], [SaldoCard], [CostoPartita], [LivelloCard], [device], [CodMac], [N0]) VALUES (@P_1, @P_2, @P_3, @P_4, @P_5, @P_6, @P_7, @P_8, @P_9, @P_10);  SET @sync_row_count = @@rowcount; SET IDENTITY_INSERT [CoinlessClonedCards] OFF; END 
END
