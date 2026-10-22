CREATE PROCEDURE [Mistral_update]
	@P_1 VarChar(15),
	@P_2 Bit,
	@P_3 VarChar(10),
	@P_4 Decimal(5,0),
	@P_5 Bit,
	@P_6 VarChar(100),
	@P_7 Int,
	@P_8 DateTime,
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; UPDATE [Mistral] SET [Sospeso] = @P_2, [Serie] = @P_3, [IDPost] = @P_4, [F0] = @P_5, [T0] = @P_6, [N0] = @P_7, [D0] = @P_8 FROM [Mistral] [base] JOIN [Mistral_tracking] [side] ON [base].[CodCard] = [side].[CodCard] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[CodCard] = @P_1); SET @sync_row_count = @@ROWCOUNT;
END
