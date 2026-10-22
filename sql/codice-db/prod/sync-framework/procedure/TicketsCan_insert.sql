CREATE PROCEDURE [TicketsCan_insert]
	@P_1 BigInt,
	@P_2 Decimal(6,0),
	@P_3 DateTime,
	@P_4 Decimal(5,0),
	@P_5 Decimal(10,0),
	@P_6 Decimal(6,0),
	@P_7 DateTime,
	@P_8 Int,
	@P_9 Bit,
	@P_10 VarChar(100),
	@P_11 Int,
	@P_12 DateTime,
	@P_13 UniqueIdentifier,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; IF NOT EXISTS (SELECT * FROM [TicketsCan_tracking] WHERE [Keys] = @P_13) BEGIN INSERT INTO [TicketsCan]([IdContatto], [NumTickets], [Data], [MangiaT], [NumTrans], [TPagati], [DataCan], [NImp], [F0], [T0], [N0], [D0], [Keys]) VALUES (@P_1, @P_2, @P_3, @P_4, @P_5, @P_6, @P_7, @P_8, @P_9, @P_10, @P_11, @P_12, @P_13);  SET @sync_row_count = @@rowcount;  END 
END
