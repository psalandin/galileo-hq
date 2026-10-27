SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[AuditLog](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[tipoaudit] [varchar](255) NOT NULL,
	[data] [datetime] NOT NULL,
	[user_id] [int] NULL,
	[username] [varchar](255) NULL,
	[action] [varchar](255) NULL,
	[device_info] [varchar](255) NULL,
	[extra_data] [varchar](max) NOT NULL,
 CONSTRAINT [PK_AuditLog] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[AuditLog] SET (LOCK_ESCALATION = TABLE)
GO
