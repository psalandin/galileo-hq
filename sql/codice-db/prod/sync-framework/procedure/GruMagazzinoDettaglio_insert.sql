CREATE PROCEDURE [GruMagazzinoDettaglio_insert]
	@P_1 VarChar(20),
	@P_2 TinyInt,
	@P_3 Int,
	@P_4 Decimal(18,4),
	@P_5 DateTime,
	@P_6 DateTime,
	@P_7 DateTime,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; IF NOT EXISTS (SELECT * FROM [GruMagazzinoDettaglio_tracking] WHERE [CodMac] = @P_1 AND [SlotNo] = @P_2) BEGIN INSERT INTO [GruMagazzinoDettaglio]([CodMac], [SlotNo], [QtyCurrent], [AvgValue], [LastLoadDate], [LastWinDate], [UpdatedAt]) VALUES (@P_1, @P_2, @P_3, @P_4, @P_5, @P_6, @P_7);  SET @sync_row_count = @@rowcount;  END 
END
