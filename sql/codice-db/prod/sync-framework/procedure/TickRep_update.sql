CREATE PROCEDURE [TickRep_update]
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
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; UPDATE [TickRep] SET [IdOperatore] = @P_1, [IdCliente] = @P_2, [NumTickets] = @P_3, [NRep] = @P_4, [Data] = @P_5, [NImp] = @P_6, [F0] = @P_7, [T0] = @P_8, [N0] = @P_9, [D0] = @P_10 FROM [TickRep] [base] JOIN [TickRep_tracking] [side] ON [base].[Keys] = [side].[Keys] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[Keys] = @P_11); SET @sync_row_count = @@ROWCOUNT;
END
