CREATE PROCEDURE [Setup2_insert]
	@P_1 Int,
	@P_2 NVarChar(255),
	@P_3 NVarChar(max),
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; IF NOT EXISTS (SELECT * FROM [Setup2_tracking] WHERE [IdPost] = @P_1 AND [Chiave] = @P_2) BEGIN INSERT INTO [Setup2]([IdPost], [Chiave], [Valore]) VALUES (@P_1, @P_2, @P_3);  SET @sync_row_count = @@rowcount;  END 
END
