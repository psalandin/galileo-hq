CREATE PROCEDURE [Vincite25_insert]
	@P_1 BigInt,
	@P_2 VarChar(50),
	@P_3 VarChar(255),
	@P_4 Decimal(10,0),
	@P_5 DateTime,
	@P_6 VarChar(100),
	@P_7 VarChar(100),
	@P_8 VarChar(255),
	@P_9 Money,
	@P_10 Int,
	@P_11 Bit,
	@P_12 VarChar(100),
	@P_13 Int,
	@P_14 DateTime,
	@P_15 UniqueIdentifier,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; IF NOT EXISTS (SELECT * FROM [Vincite25_tracking] WHERE [Keys] = @P_15) BEGIN INSERT INTO [Vincite25]([IdContatto], [Codice], [Descrizione], [N_Tickets], [Data], [Nome], [Cognome], [BarCode], [Costo], [NImp], [F0], [T0], [N0], [D0], [Keys]) VALUES (@P_1, @P_2, @P_3, @P_4, @P_5, @P_6, @P_7, @P_8, @P_9, @P_10, @P_11, @P_12, @P_13, @P_14, @P_15);  SET @sync_row_count = @@rowcount;  END 
END
