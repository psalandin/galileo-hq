SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RedeemCodes] (
  [Id] bigint  IDENTITY(1,1) NOT NULL,
  [DbName] varchar(6) COLLATE Latin1_General_CI_AS DEFAULT '' NOT NULL,
  [Codice] varchar(15) COLLATE Latin1_General_CI_AS  NOT NULL,
  [Azione] varchar(20) COLLATE Latin1_General_CI_AS  NOT NULL,
  [Valore] money  NULL,
  [Bonus] money  NULL,
  [Tickets] int  NULL,
  [IdPromozione] bigint  NULL,
  [IdCompleanno] bigint  NULL,
  [IdContatto] bigint  NULL,
  [MailDestinatario] varchar(255) COLLATE Latin1_General_CI_AS  NULL,
  [CardLevel] int  NULL,
  [Pin] varchar(4) COLLATE Latin1_General_CI_AS  NOT NULL,
  [ValidFrom] datetime  NULL,
  [ValidTo] datetime  NULL,
  [CreatedBy] bigint  NOT NULL,
  [CreatedAt] datetime DEFAULT getdate() NOT NULL,
  [ReservedBy] bigint  NULL,
  [ReservedAt] datetime  NULL,
  [ReservedOnPost] int  NULL,
  [ReservedOnDevice] varchar(50) COLLATE Latin1_General_CI_AS  NULL,
  [ReservationExpiresAt] datetime  NULL,
  [UsedBy] bigint  NULL,
  [UsedAt] datetime  NULL,
  [UsedOnPost] int  NULL,
  [UsedOnDevice] varchar(50) COLLATE Latin1_General_CI_AS  NULL,
  [Note] varchar(200) COLLATE Latin1_General_CI_AS  NULL,
  [QRCode] VARBINARY(MAX) NULL,
  CONSTRAINT [PK_RedeemCodes] PRIMARY KEY CLUSTERED ([Id])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
)  
ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_RedeemCodes_DbName_Codice]
ON [dbo].[RedeemCodes] (
  [DbName] ASC,
  [Codice] ASC
)
GO

CREATE NONCLUSTERED INDEX [IX_RedeemCodes_Status]
ON [dbo].[RedeemCodes] (
  [DbName] ASC,
  [UsedAt] ASC,
  [ReservedAt] ASC,
  [CreatedAt] ASC
)
GO 