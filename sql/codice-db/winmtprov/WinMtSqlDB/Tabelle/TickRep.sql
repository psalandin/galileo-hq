SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[TickRep](
	[IdOperatore] [decimal](5, 0) NULL,
	[IdCliente] [bigint] NOT NULL,
	[NumTickets] [decimal](6, 0) NULL,
	[NRep] [decimal](2, 0) NULL,
	[Data] [datetime] NULL,
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

ALTER TABLE [dbo].[TickRep] ADD  DEFAULT ((0)) FOR [F0]
GO

ALTER TABLE [dbo].[TickRep] ADD  DEFAULT (newid()) FOR [Keys]
GO

CREATE NONCLUSTERED INDEX [IdIndex] ON [dbo].[TickRep]
(
	[IdCliente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO


