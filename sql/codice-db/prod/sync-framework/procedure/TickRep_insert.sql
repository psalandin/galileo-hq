CREATE PROCEDURE [TickRep_insert]
	@P_1 Decimal(5,0),
	@P_2 BigInt,
	@P_3 Decimal(6,0),
	@P_4 Decimal(2,0),
	@P_5 DateTime,
	@P_6 Int,
	@P_7 Bit,
	@P_8 VarChar(100),
	@P_9 Int,
	@P_10 DateTime,
	@P_11 UniqueIdentifier,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; IF NOT EXISTS (SELECT * FROM [TickRep_tracking] WHERE [Keys] = @P_11) BEGIN INSERT INTO [TickRep]([IdOperatore], [IdCliente], [NumTickets], [NRep], [Data], [NImp], [F0], [T0], [N0], [D0], [Keys]) VALUES (@P_1, @P_2, @P_3, @P_4, @P_5, @P_6, @P_7, @P_8, @P_9, @P_10, @P_11);  SET @sync_row_count = @@rowcount;  END 
END
