SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CoinlessTestataHappyHour](
	[id_happyhour] [bigint] IDENTITY(1,1) NOT NULL,
	[giorno] [int] NOT NULL,
	[ampm] [char](1) NOT NULL,
	[dalle] [varchar](5) NULL,
	[alle] [varchar](5) NULL,
	[attivo] [int] NOT NULL,
	[platinum] [int] NULL,
	[gold] [int] NULL,
	[silver] [int] NULL,
	[normal] [int] NULL,
	[dal] [datetime2](7) NULL,
	[al] [datetime2](7) NULL,
	[F0] [bit] NULL,
	[T0] [varchar](1000) NULL,
	[D0] [datetime2](7) NULL,
	[N0] [bigint] NULL,
PRIMARY KEY CLUSTERED 
(
	[id_happyhour] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CoinlessTestataHappyHour] ADD  DEFAULT ((1)) FOR [attivo]
GO


