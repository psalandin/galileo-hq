SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CoinlessClonedCards](
	[id_card_clonate] [bigint] IDENTITY(1,1) NOT NULL,
	[cardid] [varchar](16) NULL,
	[DataMovimento] [datetime] NOT NULL,
	[TipoMovimento] [varchar](10) NOT NULL,
	[SaldoCard] [bigint] NOT NULL,
	[CostoPartita] [bigint] NULL,
	[LivelloCard] [bigint] NULL,
	[device] [varchar](16) NULL,
	[CodMac] [varchar](16) NULL,
	[N0] [int] NULL,
 CONSTRAINT [PK__Coinless__E81E5C94A34D3038] PRIMARY KEY CLUSTERED 
(
	[id_card_clonate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CoinlessClonedCards] ADD  DEFAULT (getdate()) FOR [DataMovimento]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [dbo].[bannaUtente]
ON [dbo].[CoinlessClonedCards]
AFTER INSERT
AS
BEGIN

UPDATE C set
 F1 = 1,
 T1 = inserted.CodMac+'|costo partita:'+convert(varchar(20),inserted.CostoPartita)+'|saldo card:'+convert(varchar(20),inserted.SaldoCard)+'|id clonate:'+convert(varchar(20),inserted.id_card_clonate),
 D1 = getdate()
FROM  dbo.Clienti  C
inner join inserted on C.T0 = inserted.cardid+'00000000'
END
GO
ALTER TABLE [dbo].[CoinlessClonedCards] ENABLE TRIGGER [bannaUtente]
GO
