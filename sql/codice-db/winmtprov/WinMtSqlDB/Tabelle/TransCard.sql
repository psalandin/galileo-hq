SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[TransCard](
	[IdCli] [varchar](16) NULL,
	[NImp] [int] NULL,
	[CodMac] [varchar](50) NULL,
	[Data] [datetime] NULL,
	[ValoreOperazione] [money] NULL,
	[ValoreFinale] [money] NULL,
	[ValoreBonus] [money] NOT NULL DEFAULT 0,
	[F0] [bit] NOT NULL,
	[T0] [varchar](100) NULL,
	[N0] [int] NULL,
	[D0] [datetime] NULL,
	[Operatore] [int] NULL,
	[ValoreCassa] [money] NULL,
	[WinMt] [bit] NULL,
	[IDOperazione] [uniqueidentifier] NOT NULL,
	[FlagOpDaVerificare] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[IDOperazione] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[TransCard] ADD  DEFAULT ((0)) FOR [F0]
GO

ALTER TABLE [dbo].[TransCard] ADD  DEFAULT ((0)) FOR [WinMt]
GO

ALTER TABLE [dbo].[TransCard] ADD  DEFAULT (newid()) FOR [IDOperazione]
GO

CREATE NONCLUSTERED INDEX [IDInx] ON [dbo].[TransCard]
(
	[IDOperazione] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO


