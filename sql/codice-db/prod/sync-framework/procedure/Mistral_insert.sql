CREATE PROCEDURE [Mistral_insert]
	@P_1 VarChar(15),
	@P_2 Bit,
	@P_3 VarChar(10),
	@P_4 Decimal(5,0),
	@P_5 Bit,
	@P_6 VarChar(100),
	@P_7 Int,
	@P_8 DateTime,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; IF NOT EXISTS (SELECT * FROM [Mistral_tracking] WHERE [CodCard] = @P_1) BEGIN INSERT INTO [Mistral]([CodCard], [Sospeso], [Serie], [IDPost], [F0], [T0], [N0], [D0]) VALUES (@P_1, @P_2, @P_3, @P_4, @P_5, @P_6, @P_7, @P_8);  SET @sync_row_count = @@rowcount;  END 
END
