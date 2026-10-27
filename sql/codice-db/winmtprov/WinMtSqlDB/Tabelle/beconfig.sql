SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TABLE [dbo].[BEConfig] (
  [Macaddress] varchar(17) COLLATE Latin1_General_CI_AS  NOT NULL,
  [BeInfo] nvarchar(max) COLLATE Latin1_General_CI_AS  NULL,
  [BeConfig] nvarchar(max) COLLATE Latin1_General_CI_AS  NULL,
  [BiConfig] nvarchar(max) COLLATE Latin1_General_CI_AS  NULL,
  [DetectionDate] datetime  NULL
)
GO

ALTER TABLE [dbo].[BEConfig] SET (LOCK_ESCALATION = TABLE)
GO


-- ----------------------------
-- Primary Key structure for table BEConfig
-- ----------------------------
ALTER TABLE [dbo].[BEConfig] ADD CONSTRAINT [PK_BEConfig] PRIMARY KEY CLUSTERED ([Macaddress])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO

