CREATE PROCEDURE [BEConfig_insert]
	@P_1 VarChar(17),
	@P_2 NVarChar(max),
	@P_3 NVarChar(max),
	@P_4 NVarChar(max),
	@P_5 DateTime,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; IF NOT EXISTS (SELECT * FROM [BEConfig_tracking] WHERE [Macaddress] = @P_1) BEGIN INSERT INTO [BEConfig]([Macaddress], [BeInfo], [BeConfig], [BiConfig], [DetectionDate]) VALUES (@P_1, @P_2, @P_3, @P_4, @P_5);  SET @sync_row_count = @@rowcount;  END 
END
