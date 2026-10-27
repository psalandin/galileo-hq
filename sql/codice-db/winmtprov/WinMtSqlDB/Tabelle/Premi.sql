SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Premi](
	[Codice] [varchar](50) NOT NULL,
	[Descrizione] [varchar](255) NULL,
	[Costo] [money] NULL,
	[N_Tickets] [decimal](10, 0) NULL,
	[Fornitore] [varchar](255) NULL,
	[Quantita] [decimal](10, 0) NULL,
	[Riserva] [decimal](5, 0) NULL,
	[CodOr] [varchar](50) NOT NULL,
	[Foto] [varbinary](max) NULL,
	[QPren] [decimal](5, 0) NULL,
	[Id] [varchar](5) NULL,
	[Ordinato] [decimal](5, 0) NULL,
	[Conf] [decimal](5, 0) NULL,
	[QDis1] [int] NOT NULL,
	[PDis1] [varchar](255) NULL,
	[QDis2] [int] NOT NULL,
	[PDis2] [varchar](255) NULL,
	[QDis3] [int] NOT NULL,
	[PDis3] [varchar](255) NULL,
	[QDis4] [int] NOT NULL,
	[PDis4] [varchar](255) NULL,
	[QDis5] [int] NOT NULL,
	[PDis5] [varchar](255) NULL,
	[QDis6] [int] NOT NULL,
	[PDis6] [varchar](255) NULL,
	[QDis7] [int] NOT NULL,
	[PDis7] [varchar](255) NULL,
	[QDis8] [int] NOT NULL,
	[PDis8] [varchar](255) NULL,
	[Attivo] [bit] NULL,
	[Gru] [bit] NULL,
	[Riord] [bit] NULL,
	[Locked] [int] NOT NULL,
	[Id2] [int] NULL,
	[Icona] [varbinary](max) NULL,
	[Prenotabile] [bit] NOT NULL,
	[NImp] [int] NULL,
	[F0] [bit] NOT NULL,
	[T0] [varchar](100) NULL,
	[N0] [int] NULL,
	[D0] [datetime] NULL,
	[F1] [bit] NOT NULL,
	[T1] [varchar](100) NULL,
	[N1] [int] NULL,
	[D1] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[Codice] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[Premi] ADD  DEFAULT ((0)) FOR [QDis1]
GO

ALTER TABLE [dbo].[Premi] ADD  DEFAULT ((0)) FOR [QDis2]
GO

ALTER TABLE [dbo].[Premi] ADD  DEFAULT ((0)) FOR [QDis3]
GO

ALTER TABLE [dbo].[Premi] ADD  DEFAULT ((0)) FOR [QDis4]
GO

ALTER TABLE [dbo].[Premi] ADD  DEFAULT ((0)) FOR [QDis5]
GO

ALTER TABLE [dbo].[Premi] ADD  DEFAULT ((0)) FOR [QDis6]
GO

ALTER TABLE [dbo].[Premi] ADD  DEFAULT ((0)) FOR [QDis7]
GO

ALTER TABLE [dbo].[Premi] ADD  DEFAULT ((0)) FOR [QDis8]
GO

ALTER TABLE [dbo].[Premi] ADD  DEFAULT ((1)) FOR [Attivo]
GO

ALTER TABLE [dbo].[Premi] ADD  DEFAULT ((0)) FOR [Gru]
GO

ALTER TABLE [dbo].[Premi] ADD  DEFAULT ((0)) FOR [Riord]
GO

ALTER TABLE [dbo].[Premi] ADD  DEFAULT ((0)) FOR [Locked]
GO

ALTER TABLE [dbo].[Premi] ADD  DEFAULT ((0)) FOR [Prenotabile]
GO

ALTER TABLE [dbo].[Premi] ADD  DEFAULT ((0)) FOR [F0]
GO

ALTER TABLE [dbo].[Premi] ADD  DEFAULT ((0)) FOR [F1]
GO

SET ANSI_PADDING ON
GO

CREATE UNIQUE NONCLUSTERED INDEX [CodInx] ON [dbo].[Premi]
(
	[Codice] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE UNIQUE NONCLUSTERED INDEX [CodOrInx] ON [dbo].[Premi]
(
	[CodOr] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [TickInx] ON [dbo].[Premi]
(
	[N_Tickets] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO


