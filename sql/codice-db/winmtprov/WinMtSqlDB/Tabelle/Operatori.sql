SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Operatori](
	[Id] [int] NOT NULL,
	[Nome] [varchar](100) NULL,
	[Cognome] [varchar](100) NULL,
	[Indirizzo] [varchar](100) NULL,
	[CAP] [varchar](50) NULL,
	[Password] [varchar](50) NULL,
	[Citta] [varchar](50) NULL,
	[Provincia] [varchar](50) NULL,
	[Telefono] [varchar](30) NULL,
	[Data] [datetime] NULL,
	[Livello] [decimal](2, 0) NULL,
	[CodBar] [varchar](15) NULL,
	[Attivo] [bit] NULL,
	[Foto] [varbinary](max) NULL,
	[NImp] [int] NULL,
	[F0] [bit] NOT NULL,
	[T0] [varchar](100) NULL,
	[N0] [int] NULL,
	[D0] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[Operatori] ADD  DEFAULT ((1)) FOR [Attivo]
GO

ALTER TABLE [dbo].[Operatori] ADD  DEFAULT ((0)) FOR [F0]
GO

CREATE UNIQUE NONCLUSTERED INDEX [IdIndex] ON [dbo].[Operatori]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO


