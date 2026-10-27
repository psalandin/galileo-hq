SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Ospiti] (
  [IdOspite] bigint  IDENTITY(1,1) NOT NULL,
  [IdCompleanno] bigint  NOT NULL,
  [CardId] varchar(16) NOT NULL,
  [IdContatto] bigint  NOT NULL,
  [CreatedBy] bigint  NULL,
  [CreatedAt] datetime2(7)  NULL,
  [UpdatedBy] bigint  NULL,
  [UpdatedAt] datetime2(7)  NULL,
  CONSTRAINT [PK__Ospiti__489F44AE278C0F16] PRIMARY KEY CLUSTERED ([IdOspite])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
)  
ON [PRIMARY]
GO

ALTER TABLE [dbo].[Ospiti] SET (LOCK_ESCALATION = TABLE)