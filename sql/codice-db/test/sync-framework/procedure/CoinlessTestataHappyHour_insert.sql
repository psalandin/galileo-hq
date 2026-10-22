CREATE PROCEDURE [CoinlessTestataHappyHour_insert]
	@P_1 BigInt,
	@P_2 Int,
	@P_3 Char(1),
	@P_4 VarChar(5),
	@P_5 VarChar(5),
	@P_6 Int,
	@P_7 Int,
	@P_8 Int,
	@P_9 Int,
	@P_10 Int,
	@P_11 DateTime2,
	@P_12 DateTime2,
	@P_13 Bit,
	@P_14 VarChar(1000),
	@P_15 DateTime2,
	@P_16 BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; IF NOT EXISTS (SELECT * FROM [CoinlessTestataHappyHour_tracking] WHERE [id_happyhour] = @P_1) BEGIN SET IDENTITY_INSERT [CoinlessTestataHappyHour] ON; INSERT INTO [CoinlessTestataHappyHour]([id_happyhour], [giorno], [ampm], [dalle], [alle], [attivo], [platinum], [gold], [silver], [normal], [dal], [al], [F0], [T0], [D0], [N0]) VALUES (@P_1, @P_2, @P_3, @P_4, @P_5, @P_6, @P_7, @P_8, @P_9, @P_10, @P_11, @P_12, @P_13, @P_14, @P_15, @P_16);  SET @sync_row_count = @@rowcount; SET IDENTITY_INSERT [CoinlessTestataHappyHour] OFF; END 
END
