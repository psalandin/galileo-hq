CREATE PROCEDURE [Tickets_insert]
	@P_1 BigInt,
	@P_2 Decimal(6,0),
	@P_3 DateTime,
	@P_4 Decimal(5,0),
	@P_5 Decimal(10,0),
	@P_6 Decimal(6,0),
	@P_7 DateTime,
	@P_8 Decimal(5,0),
	@P_9 Decimal(5,0),
	@P_10 Bit,
	@P_11 Decimal(5,0),
	@P_12 Bit,
	@P_13 TinyInt,
	@P_14 Int,
	@P_15 Bit,
	@P_16 VarChar(100),
	@P_17 Int,
	@P_18 DateTime,
	@P_19 Bit,
	@P_20 VarChar(100),
	@P_21 Int,
	@P_22 DateTime,
	@P_23 UniqueIdentifier,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; IF NOT EXISTS (SELECT * FROM [Tickets_tracking] WHERE [Keys] = @P_23) BEGIN INSERT INTO [Tickets]([IdContatto], [NumTickets], [Data], [MangiaT], [NumTrans], [TPagati], [DataOut], [Oper], [OperOut], [NonCont], [Id], [Aux], [NRep], [NImp], [F0], [T0], [N0], [D0], [F1], [T1], [N1], [D1], [Keys]) VALUES (@P_1, @P_2, @P_3, @P_4, @P_5, @P_6, @P_7, @P_8, @P_9, @P_10, @P_11, @P_12, @P_13, @P_14, @P_15, @P_16, @P_17, @P_18, @P_19, @P_20, @P_21, @P_22, @P_23);  SET @sync_row_count = @@rowcount;  END 
END
