CREATE PROCEDURE [Resi_insert]
	@P_1 BigInt,
	@P_2 VarChar(50),
	@P_3 VarChar(255),
	@P_4 Money,
	@P_5 Decimal(10,0),
	@P_6 VarChar(255),
	@P_7 DateTime,
	@P_8 Decimal(5,0),
	@P_9 Int,
	@P_10 Bit,
	@P_11 VarChar(100),
	@P_12 Int,
	@P_13 DateTime,
	@P_14 UniqueIdentifier,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; IF NOT EXISTS (SELECT * FROM [Resi_tracking] WHERE [Keys] = @P_14) BEGIN INSERT INTO [Resi]([IdContatto], [Codice], [Descrizione], [Costo], [N_Tickets], [Fornitore], [Data], [Id], [NImp], [F0], [T0], [N0], [D0], [Keys]) VALUES (@P_1, @P_2, @P_3, @P_4, @P_5, @P_6, @P_7, @P_8, @P_9, @P_10, @P_11, @P_12, @P_13, @P_14);  SET @sync_row_count = @@rowcount;  END 
END
