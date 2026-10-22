CREATE PROCEDURE [Resi_update]
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
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; UPDATE [Resi] SET [IdContatto] = @P_1, [Codice] = @P_2, [Descrizione] = @P_3, [Costo] = @P_4, [N_Tickets] = @P_5, [Fornitore] = @P_6, [Data] = @P_7, [Id] = @P_8, [NImp] = @P_9, [F0] = @P_10, [T0] = @P_11, [N0] = @P_12, [D0] = @P_13 FROM [Resi] [base] JOIN [Resi_tracking] [side] ON [base].[Keys] = [side].[Keys] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[Keys] = @P_14); SET @sync_row_count = @@ROWCOUNT;
END
