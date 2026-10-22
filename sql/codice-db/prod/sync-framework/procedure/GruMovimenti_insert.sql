CREATE PROCEDURE [GruMovimenti_insert]
	@P_1 BigInt,
	@P_2 VarChar(20),
	@P_3 TinyInt,
	@P_4 VarChar(20),
	@P_5 VarChar(50),
	@P_6 VarChar(255),
	@P_7 Int,
	@P_8 Decimal(18,4),
	@P_9 Decimal(18,4),
	@P_10 Decimal(18,4),
	@P_11 Int,
	@P_12 Int,
	@P_13 Int,
	@P_14 VarChar(255),
	@P_15 DateTime,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; IF NOT EXISTS (SELECT * FROM [GruMovimenti_tracking] WHERE [IdMovGru] = @P_1) BEGIN SET IDENTITY_INSERT [GruMovimenti] ON; INSERT INTO [GruMovimenti]([IdMovGru], [CodMac], [SlotNo], [MovementType], [PrizeCode], [PrizeDesc], [Qty], [UnitValue], [AvgValueBefore], [AvgValueAfter], [QtyBefore], [QtyAfter], [OperatorId], [Note], [DataMov]) VALUES (@P_1, @P_2, @P_3, @P_4, @P_5, @P_6, @P_7, @P_8, @P_9, @P_10, @P_11, @P_12, @P_13, @P_14, @P_15);  SET @sync_row_count = @@rowcount; SET IDENTITY_INSERT [GruMovimenti] OFF; END 
END
