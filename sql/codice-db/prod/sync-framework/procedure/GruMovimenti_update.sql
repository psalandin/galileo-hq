CREATE PROCEDURE [GruMovimenti_update]
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
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; UPDATE [GruMovimenti] SET [CodMac] = @P_2, [SlotNo] = @P_3, [MovementType] = @P_4, [PrizeCode] = @P_5, [PrizeDesc] = @P_6, [Qty] = @P_7, [UnitValue] = @P_8, [AvgValueBefore] = @P_9, [AvgValueAfter] = @P_10, [QtyBefore] = @P_11, [QtyAfter] = @P_12, [OperatorId] = @P_13, [Note] = @P_14, [DataMov] = @P_15 FROM [GruMovimenti] [base] JOIN [GruMovimenti_tracking] [side] ON [base].[IdMovGru] = [side].[IdMovGru] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[IdMovGru] = @P_1); SET @sync_row_count = @@ROWCOUNT;
END
