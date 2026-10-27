SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CoinlessDataBuffer](
	[device] [varchar](10) NOT NULL,
	[datastore] [datetime2](7) NOT NULL,
	[crediti] [bigint] NULL,
	[tickets] [bigint] NULL,
	[cnt3] [bigint] NULL,
	[cnt4] [bigint] NULL,
	[cnt5] [bigint] NULL,
	[cnt6] [bigint] NULL,
	[cnt7] [bigint] NULL,
	[cnt8] [bigint] NULL,
	[gettoni] [bigint] NULL,
	[tipocard] [int] NULL,
	[partite] [bigint] NULL,
	[carduid] [int] NULL,
	[saldocard] [bigint] NULL,
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[cardid] [varchar](16) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [device] ON [dbo].[CoinlessDataBuffer]
(
	[device] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [univoco] ON [dbo].[CoinlessDataBuffer]
(
	[device] ASC,
	[cardid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
