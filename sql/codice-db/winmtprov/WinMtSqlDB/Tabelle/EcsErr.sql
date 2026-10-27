SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[EcsErr](
	[IdMod] [tinyint] NULL,
	[Data] [datetime] NULL,
	[CodErr] [tinyint] NULL,
	[NImp] [int] NULL,
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

ALTER TABLE [dbo].[EcsErr] ADD  DEFAULT ((0)) FOR [F0]
GO

ALTER TABLE [dbo].[EcsErr] ADD  DEFAULT (newid()) FOR [Keys]
GO


