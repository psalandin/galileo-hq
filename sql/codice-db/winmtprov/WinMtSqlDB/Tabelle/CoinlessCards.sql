SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CoinlessCards] (
  [id] bigint  IDENTITY(1,1) NOT NULL,
  [cardid] varchar(16)   NULL,
  [IdContatto] bigint  NULL,
  [DataUltimaRicarica] datetime  NULL,
  [DataUltimaPresentazione] datetime DEFAULT getdate() NULL,
  [SaldoUltimaRicarica] bigint DEFAULT 0 NULL,
  [SaldoUltimaPresentazione] bigint DEFAULT 0 NULL,
  [BlackList] int DEFAULT 0 NULL,
  [N0] int  NULL,
  CONSTRAINT [PK__Coinless__3213E83F75EDF11D] PRIMARY KEY CLUSTERED ([id])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY],
  CONSTRAINT [idcard] UNIQUE NONCLUSTERED ([cardid] ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
)  
ON [PRIMARY]
GO

ALTER TABLE [dbo].[CoinlessCards] SET (LOCK_ESCALATION = TABLE)
GO

CREATE UNIQUE NONCLUSTERED INDEX [idx_card]
ON [dbo].[CoinlessCards] (
  [cardid] ASC
)
GO
