CREATE PROCEDURE [MovMag_insert]
	@P_1 VarChar(50),
	@P_2 Decimal(10,0),
	@P_3 DateTime,
	@P_4 Decimal(5,0),
	@P_5 VarChar(50),
	@P_6 VarChar(255),
	@P_7 VarChar(255),
	@P_8 Money,
	@P_9 Decimal(10,0),
	@P_10 VarChar(100),
	@P_11 VarChar(255),
	@P_12 VarChar(255),
	@P_13 VarChar(100),
	@P_14 Int,
	@P_15 Bit,
	@P_16 VarChar(100),
	@P_17 Int,
	@P_18 DateTime,
	@P_19 UniqueIdentifier,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; IF NOT EXISTS (SELECT * FROM [MovMag_tracking] WHERE [Keys] = @P_19) BEGIN INSERT INTO [MovMag]([Codice], [Quantita], [Data], [Oper], [CodOr], [Fornitore], [Descrizione], [Costo], [N_Tickets], [NBolla], [Motivo], [Note], [NOrdine], [NImp], [F0], [T0], [N0], [D0], [Keys]) VALUES (@P_1, @P_2, @P_3, @P_4, @P_5, @P_6, @P_7, @P_8, @P_9, @P_10, @P_11, @P_12, @P_13, @P_14, @P_15, @P_16, @P_17, @P_18, @P_19);  SET @sync_row_count = @@rowcount;  END 
END
