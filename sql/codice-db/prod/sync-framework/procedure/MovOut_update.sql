CREATE PROCEDURE [MovOut_update]
	@P_1 VarChar(50),
	@P_2 Decimal(10,0),
	@P_3 DateTime,
	@P_4 Decimal(5,0),
	@P_5 VarChar(50),
	@P_6 VarChar(255),
	@P_7 VarChar(255),
	@P_8 Money,
	@P_9 Decimal(10,0),
	@P_10 VarChar(100),
	@P_11 VarChar(255),
	@P_12 VarChar(255),
	@P_13 VarChar(100),
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
SET @sync_row_count = 0; UPDATE [MovOut] SET [Codice] = @P_1, [Quantita] = @P_2, [Data] = @P_3, [Oper] = @P_4, [CodOr] = @P_5, [Fornitore] = @P_6, [Descrizione] = @P_7, [Costo] = @P_8, [N_Tickets] = @P_9, [NBolla] = @P_10, [Motivo] = @P_11, [Note] = @P_12, [NOrdine] = @P_13, [NImp] = @P_14, [F0] = @P_15, [T0] = @P_16, [N0] = @P_17, [D0] = @P_18 FROM [MovOut] [base] JOIN [MovOut_tracking] [side] ON [base].[Keys] = [side].[Keys] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[Keys] = @P_19); SET @sync_row_count = @@ROWCOUNT;
END
