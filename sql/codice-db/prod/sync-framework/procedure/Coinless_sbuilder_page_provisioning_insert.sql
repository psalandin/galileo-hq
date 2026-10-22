CREATE PROCEDURE [Coinless_sbuilder_page_provisioning_insert]
	@P_1 BigInt,
	@P_2 VarChar(17),
	@P_3 VarChar(255),
	@P_4 BigInt,
	@P_5 VarChar(255),
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; IF NOT EXISTS (SELECT * FROM [Coinless_sbuilder_page_provisioning_tracking] WHERE [id] = @P_1) BEGIN SET IDENTITY_INSERT [Coinless_sbuilder_page_provisioning] ON; INSERT INTO [Coinless_sbuilder_page_provisioning]([id], [macaddress], [chiave], [idImmagine], [pagina_su_be]) VALUES (@P_1, @P_2, @P_3, @P_4, @P_5);  SET @sync_row_count = @@rowcount; SET IDENTITY_INSERT [Coinless_sbuilder_page_provisioning] OFF; END 
END
