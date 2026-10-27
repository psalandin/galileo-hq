SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Fornitori](
	[Nome] [varchar](100) NOT NULL,
	[Indir] [varchar](255) NULL,
	[CAP] [varchar](15) NULL,
	[Citta] [varchar](50) NULL,
	[Prov] [varchar](50) NULL,
	[Tel] [varchar](50) NULL,
	[Fax] [varchar](50) NULL,
	[email] [varchar](50) NULL,
	[Cell] [varchar](50) NULL,
	[Stato] [varchar](50) NULL,
	[Web_Site] [varchar](50) NULL,
	[Contact_Name] [varchar](50) NULL,
	[F0] [bit] NOT NULL,
	[T0] [varchar](100) NULL,
	[N0] [int] NULL,
	[D0] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[Nome] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Fornitori] ADD  DEFAULT ((0)) FOR [F0]
GO


