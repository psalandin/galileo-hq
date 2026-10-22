CREATE PROCEDURE [Vincite_insert]
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
	@P_11 Bit,
	@P_12 VarChar(100),
	@P_13 Int,
	@P_14 DateTime,
	@P_15 Bit,
	@P_16 VarChar(100),
	@P_17 Int,
	@P_18 DateTime,
	@P_19 UniqueIdentifier,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; IF NOT EXISTS (SELECT * FROM [Vincite_tracking] WHERE [Keys] = @P_19) BEGIN INSERT INTO [Vincite]([IdContatto], [Codice], [Descrizione], [Costo], [N_Tickets], [Fornitore], [Data], [Id], [NImp], [Cons], [F0], [T0], [N0], [D0], [F1], [T1], [N1], [D1], [Keys]) VALUES (@P_1, @P_2, @P_3, @P_4, @P_5, @P_6, @P_7, @P_8, @P_9, @P_10, @P_11, @P_12, @P_13, @P_14, @P_15, @P_16, @P_17, @P_18, @P_19);  SET @sync_row_count = @@rowcount;  END 
END
