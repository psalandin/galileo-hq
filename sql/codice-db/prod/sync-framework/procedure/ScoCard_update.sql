CREATE PROCEDURE [ScoCard_update]
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
	@P_19 UniqueIdentifier,
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; UPDATE [ScoCard] SET [IdContatto] = @P_1, [NumTickets] = @P_2, [Data] = @P_3, [MangiaT] = @P_4, [NumTrans] = @P_5, [TPagati] = @P_6, [DataOut] = @P_7, [Oper] = @P_8, [OperOut] = @P_9, [NonCont] = @P_10, [Id] = @P_11, [Aux] = @P_12, [NRep] = @P_13, [NImp] = @P_14, [F0] = @P_15, [T0] = @P_16, [N0] = @P_17, [D0] = @P_18 FROM [ScoCard] [base] JOIN [ScoCard_tracking] [side] ON [base].[Keys] = [side].[Keys] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[Keys] = @P_19); SET @sync_row_count = @@ROWCOUNT;
END
