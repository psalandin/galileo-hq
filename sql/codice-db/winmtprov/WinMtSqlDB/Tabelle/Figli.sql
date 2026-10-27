SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Figli](
	[Id] [bigint] NOT NULL,
	[IdContatto] [bigint] NOT NULL,
	[Nome] [varchar](100) NULL,
	[Cognome] [varchar](100) NULL,
	[Sesso] [varchar](1) NULL,
	[DDN] [date] NULL,
	[Tickets] [int] NULL,
	[Bnus] [decimal](6, 2) NULL,
	[CodBar] [varchar](15) NULL,
	[Abilita] [bit] NULL,
	[email] [varchar](50) NULL,
	[Cell] [varchar](50) NULL,
	[GiornOk] [bit] NULL,
	[DataUltVis] [datetime] NULL,
	[OptOut] [bit] NULL,
	[Password] [varchar](50) NULL,
	[FirstLogin] [bit] NULL,
	[Note] [varchar](255) NULL,
	[Foto] [varbinary](max) NULL,
	[IdTel] [bigint] NULL,
	[LastOp] [bigint] NULL,
	[Credito] [money] NULL,
	[NImp] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[Figli] ADD  DEFAULT ((-1)) FOR [Abilita]
GO

ALTER TABLE [dbo].[Figli] ADD  DEFAULT ((0)) FOR [GiornOk]
GO

ALTER TABLE [dbo].[Figli] ADD  DEFAULT ((0)) FOR [OptOut]
GO

ALTER TABLE [dbo].[Figli] ADD  DEFAULT ((0)) FOR [FirstLogin]
GO


