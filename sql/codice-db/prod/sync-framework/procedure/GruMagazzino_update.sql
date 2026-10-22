CREATE PROCEDURE [GruMagazzino_update]
	@P_1 VarChar(20),
	@P_2 Bit,
	@P_3 DateTime,
	@P_4 DateTime,
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; UPDATE [GruMagazzino] SET [Enabled] = @P_2, [CreatedAt] = @P_3, [UpdatedAt] = @P_4 FROM [GruMagazzino] [base] JOIN [GruMagazzino_tracking] [side] ON [base].[CodMac] = [side].[CodMac] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[CodMac] = @P_1); SET @sync_row_count = @@ROWCOUNT;
END
