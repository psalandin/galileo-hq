CREATE PROCEDURE [UID_Ammessi_insert]
	@P_1 VarChar(16),
	@P_2 VarChar(15),
	@P_3 Date,
	@P_4 DateTime,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; IF NOT EXISTS (SELECT * FROM [UID_Ammessi_tracking] WHERE [UID] = @P_1) BEGIN INSERT INTO [UID_Ammessi]([UID], [CodBar], [DataCreazione], [DataEmissione]) VALUES (@P_1, @P_2, @P_3, @P_4);  SET @sync_row_count = @@rowcount;  END 
END
