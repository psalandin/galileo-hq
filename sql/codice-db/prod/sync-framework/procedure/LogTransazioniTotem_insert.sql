CREATE PROCEDURE [LogTransazioniTotem_insert]
	@P_1 BigInt,
	@P_2 BigInt,
	@P_3 DateTime,
	@P_4 Int,
	@P_5 VarChar(100),
	@P_6 VarChar(4),
	@P_7 Money,
	@P_8 VarChar(255),
	@P_9 VarChar(255),
	@P_10 VarChar(255),
	@P_11 VarChar(255),
	@P_12 VarChar(255),
	@P_13 VarChar(255),
	@P_14 VarChar(255),
	@P_15 VarChar(255),
	@P_16 VarChar(255),
	@P_17 VarChar(255),
	@P_18 VarChar(255),
	@P_19 DateTime,
	@P_20 BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; IF NOT EXISTS (SELECT * FROM [LogTransazioniTotem_tracking] WHERE [id] = @P_1) BEGIN SET IDENTITY_INSERT [LogTransazioniTotem] ON; INSERT INTO [LogTransazioniTotem]([id], [IdCli], [data], [idpost], [MName], [tipo], [valore], [IDTerm], [CAut], [TCC], [Stan], [AId], [Appl], [Cryptogram], [AC], [IAD], [IC], [PAN], [DataOraChiusura], [IdOperatore]) VALUES (@P_1, @P_2, @P_3, @P_4, @P_5, @P_6, @P_7, @P_8, @P_9, @P_10, @P_11, @P_12, @P_13, @P_14, @P_15, @P_16, @P_17, @P_18, @P_19, @P_20);  SET @sync_row_count = @@rowcount; SET IDENTITY_INSERT [LogTransazioniTotem] OFF; END 
END
