CREATE PROCEDURE [Coinless_sbuilder_page_provisioning_update]
	@P_1 BigInt,
	@P_2 VarChar(17),
	@P_3 VarChar(255),
	@P_4 BigInt,
	@P_5 VarChar(255),
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; UPDATE [Coinless_sbuilder_page_provisioning] SET [macaddress] = @P_2, [chiave] = @P_3, [idImmagine] = @P_4, [pagina_su_be] = @P_5 FROM [Coinless_sbuilder_page_provisioning] [base] JOIN [Coinless_sbuilder_page_provisioning_tracking] [side] ON [base].[id] = [side].[id] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[id] = @P_1); SET @sync_row_count = @@ROWCOUNT;
END
