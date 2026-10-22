CREATE PROCEDURE [Compleanni_insert]
	@P_1 BigInt,
	@P_2 VarChar(255),
	@P_3 DateTime,
	@P_4 DateTime,
	@P_5 Char(1),
	@P_6 Int,
	@P_7 Int,
	@P_8 Int,
	@P_9 Int,
	@P_10 Int,
	@P_11 Int,
	@P_12 VarChar(16),
	@P_13 BigInt,
	@P_14 Decimal(10,2),
	@P_15 Decimal(10,2),
	@P_16 Decimal(10,2),
	@P_17 VarChar(128),
	@P_18 VarChar(128),
	@P_19 VarChar(15),
	@P_20 VarChar(15),
	@P_21 NVarChar(max),
	@P_22 BigInt,
	@P_23 DateTime2,
	@P_24 BigInt,
	@P_25 DateTime2,
	@P_26 Int,
	@P_27 BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; IF NOT EXISTS (SELECT * FROM [Compleanni_tracking] WHERE [IdCompleanno] = @P_1) BEGIN SET IDENTITY_INSERT [Compleanni] ON; INSERT INTO [Compleanni]([IdCompleanno], [Titolo], [DallaData], [AllaData], [ModalitaTickets], [MaxPartitePerCard], [PartiteConsecutive], [NrSecondiResetConsecutive], [Partecipanti], [PartecipantiExtra], [ValorePrecaricatoCrediti], [CardId], [IdContatto], [ImportoCompleanno], [ImportoExtra], [AccontoVersato], [EmailGenitore1], [EmailGenitore2], [CellulareGenitore1], [CellulareGenitore2], [Note], [CreatedBy], [CreatedAt], [UpdatedBy], [UpdatedAt], [ValorePrecaricatoBonus], [IdRicarica]) VALUES (@P_1, @P_2, @P_3, @P_4, @P_5, @P_6, @P_7, @P_8, @P_9, @P_10, @P_11, @P_12, @P_13, @P_14, @P_15, @P_16, @P_17, @P_18, @P_19, @P_20, @P_21, @P_22, @P_23, @P_24, @P_25, @P_26, @P_27);  SET @sync_row_count = @@rowcount; SET IDENTITY_INSERT [Compleanni] OFF; END 
END
