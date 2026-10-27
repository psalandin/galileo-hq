SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
	
			IF NOT EXISTS (
				    SELECT * 
				    FROM sys.tables 
				    WHERE name = 'Coinless_sbuilder_page_provisioning' AND schema_id = SCHEMA_ID('dbo')
				)
				BEGIN
			CREATE TABLE [dbo].[Coinless_sbuilder_page_provisioning] (
			  [id] bigint  IDENTITY(1,1) NOT NULL,
			  [macaddress] varchar(17)   NOT NULL,
			  [chiave] varchar(255)  DEFAULT '' NOT NULL,
			  [idImmagine] bigint  NOT NULL,
			  [pagina_su_be] varchar(255)   NOT NULL,
			  CONSTRAINT [PK__Coinless__3213E83FF82D192D] PRIMARY KEY CLUSTERED ([id])
			WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
			ON [PRIMARY]
			)  
			ON [PRIMARY]
			END
			
GO