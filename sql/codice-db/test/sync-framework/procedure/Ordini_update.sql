CREATE PROCEDURE [Ordini_update]
	@P_1 VarChar(50),
	@P_2 Decimal(10,0),
	@P_3 DateTime,
	@P_4 Decimal(5,0),
	@P_5 VarChar(50),
	@P_6 VarChar(100),
	@P_7 VarChar(255),
	@P_8 Decimal(10,2),
	@P_9 Decimal(10,0),
	@P_10 VarChar(100),
	@P_11 VarChar(255),
	@P_12 VarChar(255),
	@P_13 VarChar(100),
	@P_14 Decimal(10,0),
	@P_15 Int,
	@P_16 Bit,
	@P_17 VarChar(100),
	@P_18 Int,
	@P_19 DateTime,
	@P_20 UniqueIdentifier,
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; UPDATE [Ordini] SET [Codice] = @P_1, [QOrd] = @P_2, [Data] = @P_3, [Oper] = @P_4, [CodOr] = @P_5, [Fornitore] = @P_6, [Descrizione] = @P_7, [Costo] = @P_8, [N_Tickets] = @P_9, [NBolla] = @P_10, [Motivo] = @P_11, [Note] = @P_12, [NOrdine] = @P_13, [QCons] = @P_14, [NImp] = @P_15, [F0] = @P_16, [T0] = @P_17, [N0] = @P_18, [D0] = @P_19 FROM [Ordini] [base] JOIN [Ordini_tracking] [side] ON [base].[Keys] = [side].[Keys] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[Keys] = @P_20); SET @sync_row_count = @@ROWCOUNT;
END
