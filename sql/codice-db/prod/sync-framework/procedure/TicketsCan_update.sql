CREATE PROCEDURE [TicketsCan_update]
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
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; UPDATE [TicketsCan] SET [IdContatto] = @P_1, [NumTickets] = @P_2, [Data] = @P_3, [MangiaT] = @P_4, [NumTrans] = @P_5, [TPagati] = @P_6, [DataCan] = @P_7, [NImp] = @P_8, [F0] = @P_9, [T0] = @P_10, [N0] = @P_11, [D0] = @P_12 FROM [TicketsCan] [base] JOIN [TicketsCan_tracking] [side] ON [base].[Keys] = [side].[Keys] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[Keys] = @P_13); SET @sync_row_count = @@ROWCOUNT;
END
