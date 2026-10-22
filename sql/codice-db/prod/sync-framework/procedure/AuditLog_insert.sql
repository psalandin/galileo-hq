CREATE PROCEDURE [AuditLog_insert]
	@P_1 BigInt,
	@P_2 VarChar(255),
	@P_3 DateTime,
	@P_4 Int,
	@P_5 VarChar(255),
	@P_6 VarChar(255),
	@P_7 VarChar(255),
	@P_8 VarChar(max),
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; IF NOT EXISTS (SELECT * FROM [AuditLog_tracking] WHERE [id] = @P_1) BEGIN SET IDENTITY_INSERT [AuditLog] ON; INSERT INTO [AuditLog]([id], [tipoaudit], [data], [user_id], [username], [action], [device_info], [extra_data]) VALUES (@P_1, @P_2, @P_3, @P_4, @P_5, @P_6, @P_7, @P_8);  SET @sync_row_count = @@rowcount; SET IDENTITY_INSERT [AuditLog] OFF; END 
END
