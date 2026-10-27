SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CoinlessLogEventiBlacklist](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[data_operazione] [datetime] NULL,
	[testo] [varchar](512) NULL,
	[cardid] [varchar](16) NULL,
 CONSTRAINT [PK__Coinless__3213E83F4872A686] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CoinlessLogEventiBlacklist] ADD  DEFAULT (getdate()) FOR [data_operazione]
GO
