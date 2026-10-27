SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ecl_DeviceProvisioning] (
[macaddress] varchar(17) NOT NULL ,
[updated] datetime NULL DEFAULT (getdate()) 
)
GO
ALTER TABLE [dbo].[ecl_DeviceProvisioning] SET (LOCK_ESCALATION = TABLE)
GO
ALTER TABLE [dbo].[ecl_DeviceProvisioning] ADD CONSTRAINT [PK_ecl_DeviceProvisioning] PRIMARY KEY CLUSTERED ([macaddress])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO

