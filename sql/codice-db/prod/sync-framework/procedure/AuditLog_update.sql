CREATE PROCEDURE [AuditLog_update]
	@P_1 BigInt,
	@P_2 VarChar(255),
	@P_3 DateTime,
	@P_4 Int,
	@P_5 VarChar(255),
	@P_6 VarChar(255),
	@P_7 VarChar(255),
	@P_8 VarChar(max),
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; UPDATE [AuditLog] SET [tipoaudit] = @P_2, [data] = @P_3, [user_id] = @P_4, [username] = @P_5, [action] = @P_6, [device_info] = @P_7, [extra_data] = @P_8 FROM [AuditLog] [base] JOIN [AuditLog_tracking] [side] ON [base].[id] = [side].[id] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[id] = @P_1); SET @sync_row_count = @@ROWCOUNT;
END
