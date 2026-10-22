CREATE PROCEDURE [LogTransazioniPos_insert]
	@P_1 BigInt,
	@P_2 BigInt,
	@P_3 Int,
	@P_4 DateTime,
	@P_5 Int,
	@P_6 VarChar(100),
	@P_7 VarChar(15),
	@P_8 VarChar(255),
	@P_9 Money,
	@P_10 VarChar(255),
	@P_11 VarChar(255),
	@P_12 VarChar(255),
	@P_13 VarChar(255),
	@P_14 VarChar(255),
	@P_15 VarChar(255),
	@P_16 DateTime,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; IF NOT EXISTS (SELECT * FROM [LogTransazioniPos_tracking] WHERE [id] = @P_1) BEGIN SET IDENTITY_INSERT [LogTransazioniPos] ON; INSERT INTO [LogTransazioniPos]([id], [IdCli], [N0], [data], [idpost], [MName], [Status], [uidPOS], [valore], [IDTerm], [Stan], [AId], [Appl], [IC], [PAN], [DataAck]) VALUES (@P_1, @P_2, @P_3, @P_4, @P_5, @P_6, @P_7, @P_8, @P_9, @P_10, @P_11, @P_12, @P_13, @P_14, @P_15, @P_16);  SET @sync_row_count = @@rowcount; SET IDENTITY_INSERT [LogTransazioniPos] OFF; END 
END
