SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Prenotaz](
	[IdOp] [decimal](5, 0) NULL,
	[IdCli] [bigint] NOT NULL,
	[Codice] [varchar](50) NULL,
	[Descrizione] [varchar](255) NULL,
	[Costo] [money] NULL,
	[N_Tickets] [decimal](10, 0) NULL,
	[Fornitore] [varchar](255) NULL,
	[NomeC] [varchar](100) NULL,
	[CognomeC] [varchar](100) NULL,
	[Tel] [varchar](50) NULL,
	[Data] [datetime] NULL,
	[DataCon] [datetime] NULL,
	[Cons] [bit] NULL,
	[IdOpCo] [decimal](5, 0) NULL,
	[Quantita] [decimal](10, 0) NULL,
	[SerNum] [decimal](15, 0) NOT NULL,
	[Conf] [bit] NOT NULL,
	[MsgInv] [bit] NOT NULL,
	[NImp] [int] NULL,
	[Annul] [bit] NOT NULL,
	[DataConf] [datetime] NULL,
	[F0] [bit] NOT NULL,
	[T0] [varchar](100) NULL,
	[N0] [int] NULL,
	[D0] [datetime] NULL,
	[F1] [bit] NOT NULL,
	[T1] [varchar](100) NULL,
	[N1] [int] NULL,
	[D1] [datetime] NULL,
	[Keys] [uniqueidentifier] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Keys] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Prenotaz] ADD  DEFAULT ((0)) FOR [Conf]
GO

ALTER TABLE [dbo].[Prenotaz] ADD  DEFAULT ((0)) FOR [MsgInv]
GO

ALTER TABLE [dbo].[Prenotaz] ADD  DEFAULT ((0)) FOR [Annul]
GO

ALTER TABLE [dbo].[Prenotaz] ADD  DEFAULT ((0)) FOR [F0]
GO

ALTER TABLE [dbo].[Prenotaz] ADD  DEFAULT ((0)) FOR [F1]
GO

ALTER TABLE [dbo].[Prenotaz] ADD  DEFAULT (newid()) FOR [Keys]
GO

CREATE NONCLUSTERED INDEX [CodInx] ON [dbo].[Prenotaz]
(
	[SerNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO


