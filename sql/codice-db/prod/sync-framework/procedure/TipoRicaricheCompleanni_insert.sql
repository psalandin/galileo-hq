CREATE PROCEDURE [TipoRicaricheCompleanni_insert]
	@P_1 Int,
	@P_2 VarChar(255),
	@P_3 Int,
	@P_4 Int,
	@P_5 Int,
	@P_6 BigInt,
	@P_7 DateTime2,
	@P_8 BigInt,
	@P_9 DateTime2,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; IF NOT EXISTS (SELECT * FROM [TipoRicaricheCompleanni_tracking] WHERE [id] = @P_1) BEGIN SET IDENTITY_INSERT [TipoRicaricheCompleanni] ON; INSERT INTO [TipoRicaricheCompleanni]([id], [descrizione], [ValorePrecaricatoCrediti], [ValorePrecaricatoBonus], [abilitato], [CreatedBy], [CreatedAt], [UpdatedBy], [UpdatedAt]) VALUES (@P_1, @P_2, @P_3, @P_4, @P_5, @P_6, @P_7, @P_8, @P_9);  SET @sync_row_count = @@rowcount; SET IDENTITY_INSERT [TipoRicaricheCompleanni] OFF; END 
END
