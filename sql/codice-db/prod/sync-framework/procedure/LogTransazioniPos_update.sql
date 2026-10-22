CREATE PROCEDURE [LogTransazioniPos_update]
	@P_1 BigInt,
	@P_2 BigInt,
	@P_3 Int,
	@P_4 DateTime,
	@P_5 Int,
	@P_6 VarChar(100),
	@P_7 VarChar(15),
	@P_8 VarChar(255),
	@P_9 Money,
	@P_10 VarChar(255),
	@P_11 VarChar(255),
	@P_12 VarChar(255),
	@P_13 VarChar(255),
	@P_14 VarChar(255),
	@P_15 VarChar(255),
	@P_16 DateTime,
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; UPDATE [LogTransazioniPos] SET [IdCli] = @P_2, [N0] = @P_3, [data] = @P_4, [idpost] = @P_5, [MName] = @P_6, [Status] = @P_7, [uidPOS] = @P_8, [valore] = @P_9, [IDTerm] = @P_10, [Stan] = @P_11, [AId] = @P_12, [Appl] = @P_13, [IC] = @P_14, [PAN] = @P_15, [DataAck] = @P_16 FROM [LogTransazioniPos] [base] JOIN [LogTransazioniPos_tracking] [side] ON [base].[id] = [side].[id] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[id] = @P_1); SET @sync_row_count = @@ROWCOUNT;
END
