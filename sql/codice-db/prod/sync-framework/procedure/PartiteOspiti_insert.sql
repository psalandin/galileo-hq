CREATE PROCEDURE [PartiteOspiti_insert]
	@P_1 BigInt,
	@P_2 VarChar(16),
	@P_3 DateTime,
	@P_4 Int,
	@P_5 Int,
	@P_6 Int,
	@P_7 BigInt,
	@P_8 DateTime2,
	@P_9 BigInt,
	@P_10 DateTime2,
	@P_11 BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; IF NOT EXISTS (SELECT * FROM [PartiteOspiti_tracking] WHERE [id] = @P_11) BEGIN SET IDENTITY_INSERT [PartiteOspiti] ON; INSERT INTO [PartiteOspiti]([IdContatto], [device], [DataUltimaPartita], [NrPartiteConsecutive], [TotPartite], [TotTickets], [CreatedBy], [CreatedAt], [UpdatedBy], [UpdatedAt], [id]) VALUES (@P_1, @P_2, @P_3, @P_4, @P_5, @P_6, @P_7, @P_8, @P_9, @P_10, @P_11);  SET @sync_row_count = @@rowcount; SET IDENTITY_INSERT [PartiteOspiti] OFF; END 
END
