SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CoinlessMacchineHappyHour](
	[id_macchineHappyHour] [bigint] IDENTITY(1,1) NOT NULL,
	[fk_testata] [bigint] NOT NULL,
	[codmac] [varchar](15) NOT NULL,
	[device] [varchar](8) NOT NULL,
	[perc_platinum] [int] NOT NULL,
	[perc_gold] [int] NOT NULL,
	[perc_silver] [int] NOT NULL,
	[perc_normal] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id_macchineHappyHour] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


