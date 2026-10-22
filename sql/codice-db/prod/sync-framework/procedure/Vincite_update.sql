CREATE PROCEDURE [Vincite_update]
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
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; UPDATE [Vincite] SET [IdContatto] = @P_1, [Codice] = @P_2, [Descrizione] = @P_3, [Costo] = @P_4, [N_Tickets] = @P_5, [Fornitore] = @P_6, [Data] = @P_7, [Id] = @P_8, [NImp] = @P_9, [Cons] = @P_10, [F0] = @P_11, [T0] = @P_12, [N0] = @P_13, [D0] = @P_14, [F1] = @P_15, [T1] = @P_16, [N1] = @P_17, [D1] = @P_18 FROM [Vincite] [base] JOIN [Vincite_tracking] [side] ON [base].[Keys] = [side].[Keys] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[Keys] = @P_19); SET @sync_row_count = @@ROWCOUNT;
END
