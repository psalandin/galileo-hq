SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TipoRicaricheCompleanni] (
  [id] int  IDENTITY(1,1) NOT NULL,
  [descrizione] varchar(255) NOT NULL,
  [ValorePrecaricatoCrediti] int DEFAULT 0 NOT NULL,
  [ValorePrecaricatoBonus] int DEFAULT 0 NOT NULL,
  [abilitato] int DEFAULT 1 NOT NULL,
  [CreatedBy] bigint  NULL,
  [CreatedAt] datetime2(7)  NULL,
  [UpdatedBy] bigint  NULL,
  [UpdatedAt] datetime2(7)  NULL,
  CONSTRAINT [PK__TipoRica__3213E83F3DD98FE2] PRIMARY KEY CLUSTERED ([id])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
)  
ON [PRIMARY]
GO

ALTER TABLE [dbo].[TipoRicaricheCompleanni] SET (LOCK_ESCALATION = TABLE)
GO

EXEC sp_addextendedproperty
'MS_Description', N'1-abilitato 0 disabilitato',
'SCHEMA', N'dbo',
'TABLE', N'TipoRicaricheCompleanni',
'COLUMN', N'abilitato'