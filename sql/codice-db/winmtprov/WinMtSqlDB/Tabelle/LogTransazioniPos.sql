CREATE TABLE [dbo].[LogTransazioniPos] (
  [id] bigint  IDENTITY(1,1) NOT NULL,
  [IdCli] bigint  NULL,
  [N0] int  NULL,
  [data] datetime  NOT NULL,
  [idpost] int  NOT NULL,
  [MName] varchar(100) NULL,
  [Status] varchar(15) NOT NULL,
  [uidPOS] varchar(255) NULL,
  [valore] money  NOT NULL,
  [IDTerm] varchar(255) NULL,
  [Stan] varchar(255) NULL,
  [AId] varchar(255) NULL,
  [Appl] varchar(255) NULL,
  [IC] varchar(255) NULL,
  [PAN] varchar(255) NULL,
  [DataAck] datetime  NULL,  
  CONSTRAINT [PK__LogTransPos__3213E83F60ECB517] PRIMARY KEY CLUSTERED ([id])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
)  
ON [PRIMARY]
GO
