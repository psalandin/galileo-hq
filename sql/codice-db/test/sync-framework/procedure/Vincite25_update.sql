CREATE PROCEDURE [Vincite25_update]
	@P_1 BigInt,
	@P_2 VarChar(50),
	@P_3 VarChar(255),
	@P_4 Decimal(10,0),
	@P_5 DateTime,
	@P_6 VarChar(100),
	@P_7 VarChar(100),
	@P_8 VarChar(255),
	@P_9 Money,
	@P_10 Int,
	@P_11 Bit,
	@P_12 VarChar(100),
	@P_13 Int,
	@P_14 DateTime,
	@P_15 UniqueIdentifier,
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; UPDATE [Vincite25] SET [IdContatto] = @P_1, [Codice] = @P_2, [Descrizione] = @P_3, [N_Tickets] = @P_4, [Data] = @P_5, [Nome] = @P_6, [Cognome] = @P_7, [BarCode] = @P_8, [Costo] = @P_9, [NImp] = @P_10, [F0] = @P_11, [T0] = @P_12, [N0] = @P_13, [D0] = @P_14 FROM [Vincite25] [base] JOIN [Vincite25_tracking] [side] ON [base].[Keys] = [side].[Keys] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[Keys] = @P_15); SET @sync_row_count = @@ROWCOUNT;
END
