SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
	
	IF NOT EXISTS (
				    SELECT * 
				    FROM sys.tables 
				    WHERE name = 'coinless_sbuilder_templates_svg' AND schema_id = SCHEMA_ID('dbo')
				)
				BEGIN
				CREATE TABLE [dbo].[coinless_sbuilder_templates_svg] (
						  [id] int  IDENTITY(1,1) NOT NULL,
						  [ClienteImpianto] varchar(255)  NOT NULL,
						  [NomeTemplate] varchar(255)  NOT NULL,
						  [pagina_su_be] varchar(255)  NOT NULL,
						  [ImageBinaryData] varbinary(max)  NULL,
						  CONSTRAINT [PK__template__3213E83F1714B8E1] PRIMARY KEY CLUSTERED ([id])
						WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
						ON [PRIMARY]
						)  
						ON [PRIMARY]
						TEXTIMAGE_ON [PRIMARY]

				END
GO
