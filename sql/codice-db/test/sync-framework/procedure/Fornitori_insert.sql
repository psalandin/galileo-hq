CREATE PROCEDURE [Fornitori_insert]
	@P_1 VarChar(100),
	@P_2 VarChar(255),
	@P_3 VarChar(15),
	@P_4 VarChar(50),
	@P_5 VarChar(50),
	@P_6 VarChar(50),
	@P_7 VarChar(50),
	@P_8 VarChar(50),
	@P_9 VarChar(50),
	@P_10 VarChar(50),
	@P_11 VarChar(50),
	@P_12 VarChar(50),
	@P_13 Bit,
	@P_14 VarChar(100),
	@P_15 Int,
	@P_16 DateTime,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; IF NOT EXISTS (SELECT * FROM [Fornitori_tracking] WHERE [Nome] = @P_1) BEGIN INSERT INTO [Fornitori]([Nome], [Indir], [CAP], [Citta], [Prov], [Tel], [Fax], [email], [Cell], [Stato], [Web_Site], [Contact_Name], [F0], [T0], [N0], [D0]) VALUES (@P_1, @P_2, @P_3, @P_4, @P_5, @P_6, @P_7, @P_8, @P_9, @P_10, @P_11, @P_12, @P_13, @P_14, @P_15, @P_16);  SET @sync_row_count = @@rowcount;  END 
END
