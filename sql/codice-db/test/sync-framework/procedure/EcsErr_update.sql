CREATE PROCEDURE [EcsErr_update]
	@P_1 TinyInt,
	@P_2 DateTime,
	@P_3 TinyInt,
	@P_4 Int,
	@P_5 Bit,
	@P_6 VarChar(100),
	@P_7 Int,
	@P_8 DateTime,
	@P_9 UniqueIdentifier,
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; UPDATE [EcsErr] SET [IdMod] = @P_1, [Data] = @P_2, [CodErr] = @P_3, [NImp] = @P_4, [F0] = @P_5, [T0] = @P_6, [N0] = @P_7, [D0] = @P_8 FROM [EcsErr] [base] JOIN [EcsErr_tracking] [side] ON [base].[Keys] = [side].[Keys] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[Keys] = @P_9); SET @sync_row_count = @@ROWCOUNT;
END
