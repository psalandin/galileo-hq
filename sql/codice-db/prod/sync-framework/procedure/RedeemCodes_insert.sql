CREATE PROCEDURE [RedeemCodes_insert]
	@P_1 BigInt,
	@P_2 VarChar(6),
	@P_3 VarChar(15),
	@P_4 VarChar(20),
	@P_5 Money,
	@P_6 Money,
	@P_7 Int,
	@P_8 BigInt,
	@P_9 BigInt,
	@P_10 BigInt,
	@P_11 VarChar(255),
	@P_12 Int,
	@P_13 VarChar(4),
	@P_14 DateTime,
	@P_15 DateTime,
	@P_16 BigInt,
	@P_17 DateTime,
	@P_18 BigInt,
	@P_19 DateTime,
	@P_20 Int,
	@P_21 VarChar(50),
	@P_22 DateTime,
	@P_23 BigInt,
	@P_24 DateTime,
	@P_25 Int,
	@P_26 VarChar(50),
	@P_27 VarChar(200),
	@P_28 VarBinary(max),
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; IF NOT EXISTS (SELECT * FROM [RedeemCodes_tracking] WHERE [Id] = @P_1) BEGIN SET IDENTITY_INSERT [RedeemCodes] ON; INSERT INTO [RedeemCodes]([Id], [DbName], [Codice], [Azione], [Valore], [Bonus], [Tickets], [IdPromozione], [IdCompleanno], [IdContatto], [MailDestinatario], [CardLevel], [Pin], [ValidFrom], [ValidTo], [CreatedBy], [CreatedAt], [ReservedBy], [ReservedAt], [ReservedOnPost], [ReservedOnDevice], [ReservationExpiresAt], [UsedBy], [UsedAt], [UsedOnPost], [UsedOnDevice], [Note], [QRCode]) VALUES (@P_1, @P_2, @P_3, @P_4, @P_5, @P_6, @P_7, @P_8, @P_9, @P_10, @P_11, @P_12, @P_13, @P_14, @P_15, @P_16, @P_17, @P_18, @P_19, @P_20, @P_21, @P_22, @P_23, @P_24, @P_25, @P_26, @P_27, @P_28);  SET @sync_row_count = @@rowcount; SET IDENTITY_INSERT [RedeemCodes] OFF; END 
END
