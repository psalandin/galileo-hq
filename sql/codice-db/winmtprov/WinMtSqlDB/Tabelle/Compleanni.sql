SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Compleanni] (
  [IdCompleanno] bigint  IDENTITY(1,1) NOT NULL,
  [Titolo] varchar(255) NOT NULL,
  [DallaData] datetime  NOT NULL,
  [AllaData] datetime  NOT NULL,
  [ModalitaTickets] char(1) NOT NULL,
  [MaxPartitePerCard] int DEFAULT 0 NOT NULL,
  [PartiteConsecutive] int DEFAULT 0 NOT NULL,
  [NrSecondiResetConsecutive] int  NOT NULL,
  [Partecipanti] int DEFAULT 1 NOT NULL,
  [PartecipantiExtra] int DEFAULT 0 NULL,
  [ValorePrecaricatoCrediti] int DEFAULT 0 NULL,
  [CardId] varchar(16) NULL,
  [IdContatto] bigint  NULL,
  [ImportoCompleanno] decimal(10,2)  NULL,
  [ImportoExtra] decimal(10,2)  NULL,
  [AccontoVersato] decimal(10,2)  NULL,
  [EmailGenitore1] varchar(128) NULL,
  [EmailGenitore2] varchar(128) NULL,
  [CellulareGenitore1] varchar(15) NULL,
  [CellulareGenitore2] varchar(15) NULL,
  [Note] nvarchar(max) NULL,
  [CreatedBy] bigint  NULL,
  [CreatedAt] datetime2(7)  NULL,
  [UpdatedBy] bigint  NULL,
  [UpdatedAt] datetime2(7)  NULL,
  [ValorePrecaricatoBonus] int DEFAULT 0 NULL,
  [IdRicarica] bigint  NULL,
  CONSTRAINT [PK__Complean__E67E2A9642CF88DA] PRIMARY KEY CLUSTERED ([IdCompleanno])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
)  
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[Compleanni] SET (LOCK_ESCALATION = TABLE)