CREATE PROCEDURE [ecl_SchedeFirmware_insert]
	@P_1 VarChar(17),
	@P_2 VarChar(3),
	@P_3 VarChar(15),
	@P_4 DateTime,
	@P_5 VarChar(30),
	@P_6 VarChar(30),
	@P_7 VarChar(30),
	@P_8 DateTime,
	@P_9 VarChar(30),
	@P_10 VarChar(10),
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; IF NOT EXISTS (SELECT * FROM [ecl_SchedeFirmware_tracking] WHERE [macaddress] = @P_1) BEGIN INSERT INTO [ecl_SchedeFirmware]([macaddress], [tipoScheda], [tipoFirmware], [dataAggiornamento], [device], [requestedVersion], [detectedVersion], [dataVerifica], [bidetectedVersion], [status]) VALUES (@P_1, @P_2, @P_3, @P_4, @P_5, @P_6, @P_7, @P_8, @P_9, @P_10);  SET @sync_row_count = @@rowcount;  END 
END
