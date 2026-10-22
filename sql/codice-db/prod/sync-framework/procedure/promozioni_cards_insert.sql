CREATE PROCEDURE [promozioni_cards_insert]
	@P_1 BigInt,
	@P_2 BigInt,
	@P_3 VarChar(16),
	@P_4 Int,
	@P_5 DateTime2,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; IF NOT EXISTS (SELECT * FROM [promozioni_cards_tracking] WHERE [id] = @P_1) BEGIN SET IDENTITY_INSERT [promozioni_cards] ON; INSERT INTO [promozioni_cards]([id], [idpromozione], [cardid], [livelloPrecedente], [CreatedAt]) VALUES (@P_1, @P_2, @P_3, @P_4, @P_5);  SET @sync_row_count = @@rowcount; SET IDENTITY_INSERT [promozioni_cards] OFF; END 
END
