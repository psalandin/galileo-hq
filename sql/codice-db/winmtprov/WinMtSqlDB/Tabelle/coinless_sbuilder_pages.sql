SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
	
				IF NOT EXISTS (
				    SELECT * 
				    FROM sys.tables 
				    WHERE name = 'coinless_sbuilder_pages' AND schema_id = SCHEMA_ID('dbo')
				)
				BEGIN
				CREATE TABLE [dbo].[coinless_sbuilder_pages] (
				  [id] int  IDENTITY(1,1) Not Null,
				  [ClienteImpianto] varchar(255)  Not Null,
				  [Codmac] varchar(30)  Not Null,
				  [NomeTemplate] varchar(255)  Not Null,
				  [pagina_generata] varchar(255)  Not Null,
				  [pagina_su_be] varchar(255)  Not Null,
				  CONSTRAINT [PK__coinless__3213E83F69366A39] PRIMARY KEY CLUSTERED ([id])
				WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
				ON [PRIMARY]
				)  
				ON [PRIMARY]
				END
GO
