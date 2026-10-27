SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CoinlessCards](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[cardid] [varchar](16) NULL,
	[IdContatto] [bigint] NULL,
	[DataUltimaRicarica] [datetime] NULL,
	[DataUltimaPresentazione] [datetime] NULL,
	[SaldoUltimaRicarica] [bigint] NULL,
	[SaldoUltimaPresentazione] [bigint] NULL,
	[BlackList] [int] NULL,
	[N0] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [idcard] UNIQUE NONCLUSTERED 
(
	[cardid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CoinlessCards] ADD  DEFAULT (getdate()) FOR [DataUltimaPresentazione]
GO

ALTER TABLE [dbo].[CoinlessCards] ADD  DEFAULT ((0)) FOR [SaldoUltimaRicarica]
GO

ALTER TABLE [dbo].[CoinlessCards] ADD  DEFAULT ((0)) FOR [SaldoUltimaPresentazione]
GO

ALTER TABLE [dbo].[CoinlessCards] ADD  DEFAULT ((0)) FOR [BlackList]
GO

CREATE UNIQUE NONCLUSTERED INDEX [idx_card] ON [dbo].[CoinlessCards]
(
	[cardid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = ON, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO


