SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[EcsDati](
	[CodMac] [varchar](100) NULL,
	[Stato] [tinyint] NULL,
	[DataRil] [datetime] NULL,
	[In1] [bigint] NOT NULL,
	[In2] [bigint] NOT NULL,
	[In3] [bigint] NOT NULL,
	[In4] [bigint] NOT NULL,
	[In5] [bigint] NOT NULL,
	[In6] [bigint] NOT NULL,
	[In7] [bigint] NOT NULL,
	[In8] [bigint] NOT NULL,
	[In9] [bigint] NOT NULL,
	[In10] [bigint] NOT NULL,
	[In11] [bigint] NOT NULL,
	[In12] [bigint] NOT NULL,
	[In13] [bigint] NOT NULL,
	[In14] [bigint] NOT NULL,
	[In15] [bigint] NOT NULL,
	[In16] [bigint] NOT NULL,
	[NImp] [int] NULL,
	[ValoreUscita] [money] NULL,
	[F0] [bit] NOT NULL,
	[T0] [varchar](100) NULL,
	[N0] [int] NULL,
	[D0] [datetime] NULL,
	[Keys] [uniqueidentifier] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Keys] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[EcsDati] ADD  DEFAULT ((0)) FOR [In1]
GO

ALTER TABLE [dbo].[EcsDati] ADD  DEFAULT ((0)) FOR [In2]
GO

ALTER TABLE [dbo].[EcsDati] ADD  DEFAULT ((0)) FOR [In3]
GO

ALTER TABLE [dbo].[EcsDati] ADD  DEFAULT ((0)) FOR [In4]
GO

ALTER TABLE [dbo].[EcsDati] ADD  DEFAULT ((0)) FOR [In5]
GO

ALTER TABLE [dbo].[EcsDati] ADD  DEFAULT ((0)) FOR [In6]
GO

ALTER TABLE [dbo].[EcsDati] ADD  DEFAULT ((0)) FOR [In7]
GO

ALTER TABLE [dbo].[EcsDati] ADD  DEFAULT ((0)) FOR [In8]
GO

ALTER TABLE [dbo].[EcsDati] ADD  DEFAULT ((0)) FOR [In9]
GO

ALTER TABLE [dbo].[EcsDati] ADD  DEFAULT ((0)) FOR [In10]
GO

ALTER TABLE [dbo].[EcsDati] ADD  DEFAULT ((0)) FOR [In11]
GO

ALTER TABLE [dbo].[EcsDati] ADD  DEFAULT ((0)) FOR [In12]
GO

ALTER TABLE [dbo].[EcsDati] ADD  DEFAULT ((0)) FOR [In13]
GO

ALTER TABLE [dbo].[EcsDati] ADD  DEFAULT ((0)) FOR [In14]
GO

ALTER TABLE [dbo].[EcsDati] ADD  DEFAULT ((0)) FOR [In15]
GO

ALTER TABLE [dbo].[EcsDati] ADD  DEFAULT ((0)) FOR [In16]
GO

ALTER TABLE [dbo].[EcsDati] ADD  DEFAULT ((0)) FOR [F0]
GO

ALTER TABLE [dbo].[EcsDati] ADD  DEFAULT (newid()) FOR [Keys]
GO

SET ANSI_PADDING ON
GO

CREATE NONCLUSTERED INDEX [CodMac] ON [dbo].[EcsDati]
(
	[CodMac] ASC
)
INCLUDE ( 	[DataRil],
	[In8]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO


