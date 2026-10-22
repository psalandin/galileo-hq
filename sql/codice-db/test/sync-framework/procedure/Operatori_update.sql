CREATE PROCEDURE [Operatori_update]
	@P_1 Int,
	@P_2 VarChar(100),
	@P_3 VarChar(100),
	@P_4 VarChar(100),
	@P_5 VarChar(50),
	@P_6 VarChar(50),
	@P_7 VarChar(50),
	@P_8 VarChar(50),
	@P_9 VarChar(30),
	@P_10 DateTime,
	@P_11 Decimal(2,0),
	@P_12 VarChar(15),
	@P_13 Bit,
	@P_14 VarBinary(max),
	@P_15 Int,
	@P_16 Bit,
	@P_17 VarChar(100),
	@P_18 Int,
	@P_19 DateTime,
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; UPDATE [Operatori] SET [Nome] = @P_2, [Cognome] = @P_3, [Indirizzo] = @P_4, [CAP] = @P_5, [Password] = @P_6, [Citta] = @P_7, [Provincia] = @P_8, [Telefono] = @P_9, [Data] = @P_10, [Livello] = @P_11, [CodBar] = @P_12, [Attivo] = @P_13, [Foto] = @P_14, [NImp] = @P_15, [F0] = @P_16, [T0] = @P_17, [N0] = @P_18, [D0] = @P_19 FROM [Operatori] [base] JOIN [Operatori_tracking] [side] ON [base].[Id] = [side].[Id] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[Id] = @P_1); SET @sync_row_count = @@ROWCOUNT;
END
