CREATE PROCEDURE [coinless_sbuilder_templates_svg_insert]
	@P_1 Int,
	@P_2 VarChar(255),
	@P_3 VarChar(255),
	@P_4 VarChar(255),
	@P_5 VarBinary(max),
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; IF NOT EXISTS (SELECT * FROM [coinless_sbuilder_templates_svg_tracking] WHERE [id] = @P_1) BEGIN SET IDENTITY_INSERT [coinless_sbuilder_templates_svg] ON; INSERT INTO [coinless_sbuilder_templates_svg]([id], [ClienteImpianto], [NomeTemplate], [pagina_su_be], [ImageBinaryData]) VALUES (@P_1, @P_2, @P_3, @P_4, @P_5);  SET @sync_row_count = @@rowcount; SET IDENTITY_INSERT [coinless_sbuilder_templates_svg] OFF; END 
END
