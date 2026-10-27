SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CoinlessTransazioniCards](
	[id_transazione] [bigint] IDENTITY(1,1) NOT NULL,
	[cardid] [varchar](10) NOT NULL,
	[DataMovimento] [datetime] NOT NULL,
	[TipoMovimento] [varchar](10) NOT NULL,
	[SaldoCard] [bigint] NOT NULL,
	[CostoPartita] [bigint] NULL,
	[LivelloCard] [int] NULL,
	[device] [varchar](16) NULL,
	[CodMac] [varchar](16) NULL,
	[N0] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[id_transazione] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CoinlessTransazioniCards] ADD  DEFAULT (getdate()) FOR [DataMovimento]
GO

ALTER TABLE [dbo].[CoinlessTransazioniCards] ADD  DEFAULT ((0)) FOR [SaldoCard]
GO

