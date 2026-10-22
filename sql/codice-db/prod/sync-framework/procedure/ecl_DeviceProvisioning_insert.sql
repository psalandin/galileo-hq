CREATE PROCEDURE [ecl_DeviceProvisioning_insert]
	@P_1 VarChar(17),
	@P_2 DateTime,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; IF NOT EXISTS (SELECT * FROM [ecl_DeviceProvisioning_tracking] WHERE [macaddress] = @P_1) BEGIN INSERT INTO [ecl_DeviceProvisioning]([macaddress], [updated]) VALUES (@P_1, @P_2);  SET @sync_row_count = @@rowcount;  END 
END
