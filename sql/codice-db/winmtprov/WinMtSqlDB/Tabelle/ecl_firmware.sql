SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ecl_firmware] (
  [id] int  IDENTITY(1,1) NOT NULL,
  [filename] varchar(255) NOT NULL,
  [url] varchar(255) NOT NULL,
  [version] varchar(15) NOT NULL,
  [path] varchar(255) NULL,
  [tipoScheda] varchar(3) NULL,
  [tipoFirmware] varchar(9) NULL,
  [msgCount] int DEFAULT 55 NULL,
  [firmwareBinaryData] varbinary(max)  NULL,
  CONSTRAINT [PK__ecl_firm__3213E83F2C479179] PRIMARY KEY CLUSTERED ([id])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
)  
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[ecl_firmware] SET (LOCK_ESCALATION = TABLE)
GO

CREATE UNIQUE NONCLUSTERED INDEX [version]
ON [dbo].[ecl_firmware] (
  [version] ASC
)
GO
