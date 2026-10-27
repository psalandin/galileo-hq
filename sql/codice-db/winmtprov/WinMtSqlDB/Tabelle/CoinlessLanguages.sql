SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CoinlessLanguages](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[testo] [varchar](255) NOT NULL,
	[lingua] [varchar](3) NOT NULL,
	[nr_campo] [int] NOT NULL,
	[posx] [int] NULL,
	[posy] [int] NULL,
	[color] [int] NULL,
	[font] [varchar](10) NULL,
	[note] [varchar](255) NULL,
	[align] [char](1) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CoinlessLanguages] ADD  DEFAULT ('C') FOR [align]
GO

