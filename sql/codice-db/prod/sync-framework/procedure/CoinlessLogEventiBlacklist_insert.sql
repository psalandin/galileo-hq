CREATE PROCEDURE [CoinlessLogEventiBlacklist_insert]
	@P_1 BigInt,
	@P_2 DateTime,
	@P_3 VarChar(512),
	@P_4 VarChar(16),
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; IF NOT EXISTS (SELECT * FROM [CoinlessLogEventiBlacklist_tracking] WHERE [id] = @P_1) BEGIN SET IDENTITY_INSERT [CoinlessLogEventiBlacklist] ON; INSERT INTO [CoinlessLogEventiBlacklist]([id], [data_operazione], [testo], [cardid]) VALUES (@P_1, @P_2, @P_3, @P_4);  SET @sync_row_count = @@rowcount; SET IDENTITY_INSERT [CoinlessLogEventiBlacklist] OFF; END 
END
