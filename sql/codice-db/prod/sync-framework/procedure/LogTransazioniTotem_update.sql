CREATE PROCEDURE [LogTransazioniTotem_update]
	@P_1 BigInt,
	@P_2 BigInt,
	@P_3 DateTime,
	@P_4 Int,
	@P_5 VarChar(100),
	@P_6 VarChar(4),
	@P_7 Money,
	@P_8 VarChar(255),
	@P_9 VarChar(255),
	@P_10 VarChar(255),
	@P_11 VarChar(255),
	@P_12 VarChar(255),
	@P_13 VarChar(255),
	@P_14 VarChar(255),
	@P_15 VarChar(255),
	@P_16 VarChar(255),
	@P_17 VarChar(255),
	@P_18 VarChar(255),
	@P_19 DateTime,
	@P_20 BigInt,
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; UPDATE [LogTransazioniTotem] SET [IdCli] = @P_2, [data] = @P_3, [idpost] = @P_4, [MName] = @P_5, [tipo] = @P_6, [valore] = @P_7, [IDTerm] = @P_8, [CAut] = @P_9, [TCC] = @P_10, [Stan] = @P_11, [AId] = @P_12, [Appl] = @P_13, [Cryptogram] = @P_14, [AC] = @P_15, [IAD] = @P_16, [IC] = @P_17, [PAN] = @P_18, [DataOraChiusura] = @P_19, [IdOperatore] = @P_20 FROM [LogTransazioniTotem] [base] JOIN [LogTransazioniTotem_tracking] [side] ON [base].[id] = [side].[id] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[id] = @P_1); SET @sync_row_count = @@ROWCOUNT;
END
