CREATE PROCEDURE [GruMagazzino_insert]
	@P_1 VarChar(20),
	@P_2 Bit,
	@P_3 DateTime,
	@P_4 DateTime,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; IF NOT EXISTS (SELECT * FROM [GruMagazzino_tracking] WHERE [CodMac] = @P_1) BEGIN INSERT INTO [GruMagazzino]([CodMac], [Enabled], [CreatedAt], [UpdatedAt]) VALUES (@P_1, @P_2, @P_3, @P_4);  SET @sync_row_count = @@rowcount;  END 
END
