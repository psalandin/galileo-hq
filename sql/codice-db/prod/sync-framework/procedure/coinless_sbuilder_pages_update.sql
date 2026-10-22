CREATE PROCEDURE [coinless_sbuilder_pages_update]
	@P_1 Int,
	@P_2 VarChar(255),
	@P_3 VarChar(30),
	@P_4 VarChar(255),
	@P_5 VarChar(255),
	@P_6 VarChar(255),
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; UPDATE [coinless_sbuilder_pages] SET [ClienteImpianto] = @P_2, [Codmac] = @P_3, [NomeTemplate] = @P_4, [pagina_generata] = @P_5, [pagina_su_be] = @P_6 FROM [coinless_sbuilder_pages] [base] JOIN [coinless_sbuilder_pages_tracking] [side] ON [base].[id] = [side].[id] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[id] = @P_1); SET @sync_row_count = @@ROWCOUNT;
END
