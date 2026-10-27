SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Vincite](
	[IdContatto] [bigint] NOT NULL,
	[Codice] [varchar](50) NOT NULL,
	[Descrizione] [varchar](255) NULL,
	[Costo] [money] NULL,
	[N_Tickets] [decimal](10, 0) NULL,
	[Fornitore] [varchar](255) NULL,
	[Data] [datetime] NULL,
	[Id] [decimal](5, 0) NULL,
	[NImp] [int] NULL,
	[Cons] [bit] NOT NULL,
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

ALTER TABLE [dbo].[Vincite] ADD  DEFAULT ((0)) FOR [Cons]
GO

ALTER TABLE [dbo].[Vincite] ADD  DEFAULT ((0)) FOR [F0]
GO

ALTER TABLE [dbo].[Vincite] ADD  DEFAULT ((0)) FOR [F1]
GO

ALTER TABLE [dbo].[Vincite] ADD  DEFAULT (newid()) FOR [Keys]
GO

CREATE NONCLUSTERED INDEX [IdIndex] ON [dbo].[Vincite]
(
	[Codice] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

