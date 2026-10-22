CREATE PROCEDURE [Figli_update]
	@P_1 BigInt,
	@P_2 BigInt,
	@P_3 VarChar(100),
	@P_4 VarChar(100),
	@P_5 VarChar(1),
	@P_6 Date,
	@P_7 Int,
	@P_8 Decimal(6,2),
	@P_9 VarChar(15),
	@P_10 Bit,
	@P_11 VarChar(50),
	@P_12 VarChar(50),
	@P_13 Bit,
	@P_14 DateTime,
	@P_15 Bit,
	@P_16 VarChar(50),
	@P_17 Bit,
	@P_18 VarChar(255),
	@P_19 VarBinary(max),
	@P_20 BigInt,
	@P_21 BigInt,
	@P_22 Money,
	@P_23 Int,
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; UPDATE [Figli] SET [IdContatto] = @P_2, [Nome] = @P_3, [Cognome] = @P_4, [Sesso] = @P_5, [DDN] = @P_6, [Tickets] = @P_7, [Bnus] = @P_8, [CodBar] = @P_9, [Abilita] = @P_10, [email] = @P_11, [Cell] = @P_12, [GiornOk] = @P_13, [DataUltVis] = @P_14, [OptOut] = @P_15, [Password] = @P_16, [FirstLogin] = @P_17, [Note] = @P_18, [Foto] = @P_19, [IdTel] = @P_20, [LastOp] = @P_21, [Credito] = @P_22, [NImp] = @P_23 FROM [Figli] [base] JOIN [Figli_tracking] [side] ON [base].[Id] = [side].[Id] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[Id] = @P_1); SET @sync_row_count = @@ROWCOUNT;
END
