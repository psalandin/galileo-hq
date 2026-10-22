CREATE PROCEDURE [coinless_sbuilder_pages_insert]
	@P_1 Int,
	@P_2 VarChar(255),
	@P_3 VarChar(30),
	@P_4 VarChar(255),
	@P_5 VarChar(255),
	@P_6 VarChar(255),
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; IF NOT EXISTS (SELECT * FROM [coinless_sbuilder_pages_tracking] WHERE [id] = @P_1) BEGIN SET IDENTITY_INSERT [coinless_sbuilder_pages] ON; INSERT INTO [coinless_sbuilder_pages]([id], [ClienteImpianto], [Codmac], [NomeTemplate], [pagina_generata], [pagina_su_be]) VALUES (@P_1, @P_2, @P_3, @P_4, @P_5, @P_6);  SET @sync_row_count = @@rowcount; SET IDENTITY_INSERT [coinless_sbuilder_pages] OFF; END 
END
