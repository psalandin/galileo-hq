SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[promozioni_cards] (
  [id] bigint  IDENTITY(1,1) NOT NULL,
  [idpromozione] bigint  NOT NULL,
  [cardid] varchar(16) NOT NULL,
  [livelloPrecedente] int  NULL,
  [CreatedAt] datetime2(7) DEFAULT getdate() NULL,
  CONSTRAINT [PK__promozio__3213E83FD6ED0CED] PRIMARY KEY CLUSTERED ([id])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY],
  CONSTRAINT [fkcardid] FOREIGN KEY ([idpromozione]) REFERENCES [dbo].[promozioni] ([id]) ON DELETE NO ACTION ON UPDATE NO ACTION
)  
ON [PRIMARY]
GO

ALTER TABLE [dbo].[promozioni_cards] SET (LOCK_ESCALATION = TABLE)
GO

CREATE UNIQUE NONCLUSTERED INDEX [kcardid]
ON [dbo].[promozioni_cards] (
  [cardid] ASC
)