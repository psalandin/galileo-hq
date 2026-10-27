SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Clienti](
	[IdContatto] [bigint] NOT NULL,
	[Nome] [varchar](100) NULL,
	[Cognome] [varchar](100) NULL,
	[Indirizzo] [varchar](100) NULL,
	[Citta] [varchar](50) NULL,
	[Provincia] [varchar](50) NULL,
	[CAP] [varchar](50) NULL,
	[Telefono] [varchar](30) NULL,
	[Tickets] [int] NULL,
	[Data] [datetime] NULL,
	[Bonus] [decimal](6, 2) NULL,
	[CodBar] [varchar](15) NULL,
	[Abilita] [bit] NULL,
	[email] [varchar](50) NULL,
	[Cell] [varchar](50) NULL,
	[Nascita] [date] NULL,
	[NascOk] [bit] NULL,
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
	[F0] [bit] NOT NULL,
	[T0] [varchar](100) NULL,
	[N0] [int] NULL,
	[D0] [datetime] NULL,
	[F1] [bit] NOT NULL,
	[T1] [varchar](100) NULL,
	[N1] [int] NULL,
	[D1] [datetime] NULL,
	[TimeMod] [datetime2](7) NULL,
	[OperMod] [int] NULL,
	[IdMaster1] [bigint] NULL,
	[IdMaster2] [bigint] NULL,
	[TipoDoc] [tinyint] NULL,
	[Docum] [varchar](50) NULL,
	[Sesso] [bit] NULL,
	[Modificato] [int] NULL,
	[IdLong] [bigint] NOT NULL,
	[IdLong2] [bigint] NULL,
	[EMailIsCertified] [int] NOT NULL,
	[HasTelephoneNumberCorrect] [int] NOT NULL,
	[UserName] [varchar](128) NULL,
	[TipoCard] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[IdLong] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[Clienti] ADD  DEFAULT ((-1)) FOR [Abilita]
GO

ALTER TABLE [dbo].[Clienti] ADD  DEFAULT ((0)) FOR [NascOk]
GO

ALTER TABLE [dbo].[Clienti] ADD  DEFAULT ((0)) FOR [GiornOk]
GO

ALTER TABLE [dbo].[Clienti] ADD  DEFAULT ((0)) FOR [OptOut]
GO

ALTER TABLE [dbo].[Clienti] ADD  DEFAULT ((0)) FOR [FirstLogin]
GO

ALTER TABLE [dbo].[Clienti] ADD  DEFAULT ((0)) FOR [F0]
GO

ALTER TABLE [dbo].[Clienti] ADD  DEFAULT ((0)) FOR [F1]
GO

ALTER TABLE [dbo].[Clienti] ADD  DEFAULT ((0)) FOR [EMailIsCertified]
GO

ALTER TABLE [dbo].[Clienti] ADD  DEFAULT ((0)) FOR [HasTelephoneNumberCorrect]
GO

ALTER TABLE [dbo].[Clienti] ADD  DEFAULT ((0)) FOR [TipoCard]
GO

CREATE UNIQUE NONCLUSTERED INDEX [IDIndex] ON [dbo].[Clienti]
(
	[IdLong] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = ON, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO


