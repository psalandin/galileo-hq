SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LogTransazioniTotem] (
  [id] bigint  IDENTITY(1,1) NOT NULL,
  [IdCli] bigint  NULL,
  [data] datetime  NOT NULL,
  [idpost] int  NOT NULL,
  [MName] varchar(100) COLLATE Latin1_General_CI_AS  NULL,
  [tipo] varchar(4) COLLATE Latin1_General_CI_AS  NOT NULL,
  [valore] money  NOT NULL,
  [IDTerm] varchar(255) COLLATE Latin1_General_CI_AS  NULL,
  [CAut] varchar(255) COLLATE Latin1_General_CI_AS  NULL,
  [TCC] varchar(255) COLLATE Latin1_General_CI_AS  NULL,
  [Stan] varchar(255) COLLATE Latin1_General_CI_AS  NULL,
  [AId] varchar(255) COLLATE Latin1_General_CI_AS  NULL,
  [Appl] varchar(255) COLLATE Latin1_General_CI_AS  NULL,
  [Cryptogram] varchar(255) COLLATE Latin1_General_CI_AS  NULL,
  [AC] varchar(255) COLLATE Latin1_General_CI_AS  NULL,
  [IAD] varchar(255) COLLATE Latin1_General_CI_AS  NULL,
  [IC] varchar(255) COLLATE Latin1_General_CI_AS  NULL,
  [PAN] varchar(255) COLLATE Latin1_General_CI_AS  NULL,
  [DataOraChiusura] datetime  NULL,
  [IdOperatore] bigint  NULL,
  CONSTRAINT [PK__LogTrans__3213E83F60ECB517] PRIMARY KEY CLUSTERED ([id])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
)  
ON [PRIMARY]
GO

ALTER TABLE [dbo].[LogTransazioniTotem] SET (LOCK_ESCALATION = TABLE)
GO

EXEC sp_addextendedproperty
'MS_Description', N'''POS'',''BILL'',''COIN''',
'SCHEMA', N'dbo',
'TABLE', N'LogTransazioniTotem',
'COLUMN', N'tipo'
GO 