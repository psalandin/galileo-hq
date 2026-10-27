SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CoinlessTransazioniCards] (
  [id_transazione] bigint  IDENTITY(1,1) NOT NULL,
  [cardid] varchar(10)   NOT NULL,
  [DataMovimento] datetime DEFAULT getdate() NOT NULL,
  [TipoMovimento] varchar(10)   NOT NULL,
  [SaldoCard] bigint DEFAULT 0 NOT NULL,
  [CostoPartita] bigint  NULL,
  [LivelloCard] int  NULL,
  [device] varchar(16)   NULL,
  [CodMac] varchar(16)   NULL,
  [N0] int  NULL,
  [Bonus] bigint  NULL,
  [FlagOpDaVerificare] int  NULL,
  CONSTRAINT [PK__Coinless__3980AD58E3080184] PRIMARY KEY CLUSTERED ([id_transazione])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
)  
ON [PRIMARY]
GO

ALTER TABLE [dbo].[CoinlessTransazioniCards] SET (LOCK_ESCALATION = TABLE)
GO

CREATE TRIGGER [dbo].[aggiornaCard]
ON [dbo].[CoinlessTransazioniCards]
WITH EXECUTE AS CALLER
FOR INSERT
AS
BEGIN
  -- type your statements here

insert into dbo.TransCard 
(IdCli,CodMac,Data,ValoreOperazione,ValoreFinale,N0,ValoreBonus,FlagOpDaVerificare) 
SELECT
convert(varchar(16),clienti.IdContatto),
inserted.CodMac,
inserted.DataMovimento,
dbo.CreditToCurrency(inserted.CostoPartita),
dbo.CreditToCurrency(inserted.SaldoCard),
inserted.N0,
dbo.CreditToCurrency(inserted.Bonus),
inserted.FlagOpDaVerificare
FROM inserted inner join clienti on inserted.cardid = substring(clienti.t0,1,8)

END
GO
ALTER TABLE [dbo].[CoinlessTransazioniCards] ENABLE TRIGGER [aggiornaCard]
GO
