SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Vincite25](
	[IdContatto] [bigint] NULL,
	[Codice] [varchar](50) NOT NULL,
	[Descrizione] [varchar](255) NULL,
	[N_Tickets] [decimal](10, 0) NULL,
	[Data] [datetime] NULL,
	[Nome] [varchar](100) NULL,
	[Cognome] [varchar](100) NULL,
	[BarCode] [varchar](255) NULL,
	[Costo] [money] NULL,
	[NImp] [int] NULL,
	[F0] [bit] NOT NULL,
	[T0] [varchar](100) NULL,
	[N0] [int] NULL,
	[D0] [datetime] NULL,
	[Keys] [uniqueidentifier] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Keys] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Vincite25] ADD  DEFAULT ((0)) FOR [F0]
GO

ALTER TABLE [dbo].[Vincite25] ADD  DEFAULT (newid()) FOR [Keys]
GO

SET ANSI_PADDING ON
GO

CREATE UNIQUE NONCLUSTERED INDEX [CodInx] ON [dbo].[Vincite25]
(
	[Codice] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO


