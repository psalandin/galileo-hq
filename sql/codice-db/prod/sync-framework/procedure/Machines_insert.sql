CREATE PROCEDURE [Machines_insert]
	@P_1 BigInt,
	@P_2 VarChar(50),
	@P_3 BigInt,
	@P_4 BigInt,
	@P_5 Bit,
	@P_6 Bit,
	@P_7 VarChar(100),
	@P_8 Int,
	@P_9 DateTime,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; IF NOT EXISTS (SELECT * FROM [Machines_tracking] WHERE [Id] = @P_1) BEGIN SET IDENTITY_INSERT [Machines] ON; INSERT INTO [Machines]([Id], [MacName], [Manufacturer], [Type], [CntrOut], [F0], [T0], [N0], [D0]) VALUES (@P_1, @P_2, @P_3, @P_4, @P_5, @P_6, @P_7, @P_8, @P_9);  SET @sync_row_count = @@rowcount; SET IDENTITY_INSERT [Machines] OFF; END 
END
