CREATE PROCEDURE [Figli_insert]
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
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; IF NOT EXISTS (SELECT * FROM [Figli_tracking] WHERE [Id] = @P_1) BEGIN INSERT INTO [Figli]([Id], [IdContatto], [Nome], [Cognome], [Sesso], [DDN], [Tickets], [Bnus], [CodBar], [Abilita], [email], [Cell], [GiornOk], [DataUltVis], [OptOut], [Password], [FirstLogin], [Note], [Foto], [IdTel], [LastOp], [Credito], [NImp]) VALUES (@P_1, @P_2, @P_3, @P_4, @P_5, @P_6, @P_7, @P_8, @P_9, @P_10, @P_11, @P_12, @P_13, @P_14, @P_15, @P_16, @P_17, @P_18, @P_19, @P_20, @P_21, @P_22, @P_23);  SET @sync_row_count = @@rowcount;  END 
END
