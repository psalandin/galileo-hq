SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CoinlessDati](
	[device] [varchar](10) NULL,
	[cmd] [varchar](300) NULL,
	[cnt] [bigint] NULL,
	[logdate] [datetime2](7) NOT NULL,
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[hmac] [varchar](64) NOT NULL,
 CONSTRAINT [PK__Coinless__497F6CB44C180CAC] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CoinlessDati] ADD  DEFAULT (getdate()) FOR [logdate]
GO


