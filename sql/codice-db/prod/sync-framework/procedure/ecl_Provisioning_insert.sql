CREATE PROCEDURE [ecl_Provisioning_insert]
	@P_1 VarChar(17),
	@P_2 Int,
	@P_3 BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; IF NOT EXISTS (SELECT * FROM [ecl_Provisioning_tracking] WHERE [id] = @P_3) BEGIN SET IDENTITY_INSERT [ecl_Provisioning] ON; INSERT INTO [ecl_Provisioning]([macaddress], [idImmagine], [id]) VALUES (@P_1, @P_2, @P_3);  SET @sync_row_count = @@rowcount; SET IDENTITY_INSERT [ecl_Provisioning] OFF; END 
END
