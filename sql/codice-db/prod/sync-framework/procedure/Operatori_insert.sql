CREATE PROCEDURE [Operatori_insert]
	@P_1 Int,
	@P_2 VarChar(100),
	@P_3 VarChar(100),
	@P_4 VarChar(100),
	@P_5 VarChar(50),
	@P_6 VarChar(50),
	@P_7 VarChar(50),
	@P_8 VarChar(50),
	@P_9 VarChar(30),
	@P_10 DateTime,
	@P_11 Decimal(2,0),
	@P_12 VarChar(15),
	@P_13 Bit,
	@P_14 VarBinary(max),
	@P_15 Int,
	@P_16 Bit,
	@P_17 VarChar(100),
	@P_18 Int,
	@P_19 DateTime,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; IF NOT EXISTS (SELECT * FROM [Operatori_tracking] WHERE [Id] = @P_1) BEGIN INSERT INTO [Operatori]([Id], [Nome], [Cognome], [Indirizzo], [CAP], [Password], [Citta], [Provincia], [Telefono], [Data], [Livello], [CodBar], [Attivo], [Foto], [NImp], [F0], [T0], [N0], [D0]) VALUES (@P_1, @P_2, @P_3, @P_4, @P_5, @P_6, @P_7, @P_8, @P_9, @P_10, @P_11, @P_12, @P_13, @P_14, @P_15, @P_16, @P_17, @P_18, @P_19);  SET @sync_row_count = @@rowcount;  END 
END
