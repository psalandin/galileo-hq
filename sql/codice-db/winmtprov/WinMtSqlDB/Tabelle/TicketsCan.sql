SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[TicketsCan](
	[IdContatto] [bigint] NOT NULL,
	[NumTickets] [decimal](6, 0) NULL,
	[Data] [datetime] NULL,
	[MangiaT] [decimal](5, 0) NULL,
	[NumTrans] [decimal](10, 0) NOT NULL,
	[TPagati] [decimal](6, 0) NULL,
	[DataCan] [datetime] NULL,
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

ALTER TABLE [dbo].[TicketsCan] ADD  DEFAULT ((0)) FOR [F0]
GO

ALTER TABLE [dbo].[TicketsCan] ADD  DEFAULT (newid()) FOR [Keys]
GO

CREATE NONCLUSTERED INDEX [IdIndex] ON [dbo].[TicketsCan]
(
	[NumTrans] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO


