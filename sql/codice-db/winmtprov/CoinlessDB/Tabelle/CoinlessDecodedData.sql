SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CoinlessDecodedData](
	[device] [varchar](10) NOT NULL,
	[datastore] [datetime2](7) NOT NULL,
	[Header ] [int] NULL,
	[risposta] [int] NULL,
	[cmd_inviato] [int] NULL,
	[numbyte] [int] NULL,
	[dataril] [datetime] NULL,
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
	[datarec] [datetime] NULL,
	[partite] [bigint] NULL,
	[carduid] [int] NULL,
	[saldocard] [bigint] NULL,
	[id] [bigint] IDENTITY(1,1) NOT NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CoinlessDecodedData] ADD  DEFAULT (getdate()) FOR [datarec]
GO

