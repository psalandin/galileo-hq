CREATE PROCEDURE [CoinlessMacchineHappyHour_insert]
	@P_1 BigInt,
	@P_2 BigInt,
	@P_3 VarChar(15),
	@P_4 VarChar(8),
	@P_5 Int,
	@P_6 Int,
	@P_7 Int,
	@P_8 Int,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; IF NOT EXISTS (SELECT * FROM [CoinlessMacchineHappyHour_tracking] WHERE [id_macchineHappyHour] = @P_1) BEGIN SET IDENTITY_INSERT [CoinlessMacchineHappyHour] ON; INSERT INTO [CoinlessMacchineHappyHour]([id_macchineHappyHour], [fk_testata], [codmac], [device], [perc_platinum], [perc_gold], [perc_silver], [perc_normal]) VALUES (@P_1, @P_2, @P_3, @P_4, @P_5, @P_6, @P_7, @P_8);  SET @sync_row_count = @@rowcount; SET IDENTITY_INSERT [CoinlessMacchineHappyHour] OFF; END 
END
