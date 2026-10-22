CREATE PROCEDURE [Owners_update]
	@P_1 Int,
	@P_2 VarChar(100),
	@P_3 VarChar(255),
	@P_4 VarChar(50),
	@P_5 Decimal(4,1),
	@P_6 Int,
	@P_7 Bit,
	@P_8 VarChar(100),
	@P_9 Int,
	@P_10 DateTime,
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; UPDATE [Owners] SET [OwnerName] = @P_2, [OwnerAddress] = @P_3, [OwnerPhone] = @P_4, [Perc] = @P_5, [NImp] = @P_6, [F0] = @P_7, [T0] = @P_8, [N0] = @P_9, [D0] = @P_10 FROM [Owners] [base] JOIN [Owners_tracking] [side] ON [base].[Id] = [side].[Id] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[Id] = @P_1); SET @sync_row_count = @@ROWCOUNT;
END
