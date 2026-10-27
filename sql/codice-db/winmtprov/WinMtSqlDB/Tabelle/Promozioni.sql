SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[promozioni] (
  [id] bigint  IDENTITY(1,1) NOT NULL,
  [titolo] varchar(255) NOT NULL,
  [dalla_data] datetime  NOT NULL,
  [alla_data] datetime  NOT NULL,
  [flagConvertiOldSilver] char(1) DEFAULT 'N' NULL,
  [flagRipristinaGoldInSilver] char(1) DEFAULT 'N' NULL,
  [scadenzaPromozione] datetime  NULL,
  CONSTRAINT [PK__promozio__3213E83F41C94B1F] PRIMARY KEY CLUSTERED ([id])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
)  
ON [PRIMARY]
GO
