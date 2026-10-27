SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[RiepInv](
	[Data] [datetime] NULL,
	[VVend] [money] NULL,
	[VCons] [money] NULL,
	[VGru] [money] NULL,
	[VRott] [money] NULL,
	[VEvents] [money] NULL,
	[TVPre] [money] NULL,
	[IncRed] [money] NULL,
	[IncGru] [money] NULL,
	[IncAlt] [money] NULL,
	[IncPush] [money] NULL,
	[RedPer] [decimal](6, 2) NULL,
	[GruPer] [decimal](6, 2) NULL,
	[ConPer] [decimal](6, 2) NULL,
	[RotPer] [decimal](6, 2) NULL,
	[TotPer] [decimal](6, 2) NULL,
	[QDiff] [int] NULL,
	[VarVal] [money] NULL,
	[NImp] [int] NULL,
	[F0] [bit] NOT NULL,
	[T0] [varchar](100) NULL,
	[N0] [int] NULL,
	[D0] [datetime] NULL,
	[Mdb] [varbinary](max) NULL,
	[F1] [bit] NOT NULL,
	[T1] [varchar](100) NULL,
	[N1] [int] NULL,
	[D1] [datetime] NULL,
	[Keys] [uniqueidentifier] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Keys] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[RiepInv] ADD  DEFAULT ((0)) FOR [F0]
GO

ALTER TABLE [dbo].[RiepInv] ADD  DEFAULT ((0)) FOR [F1]
GO

ALTER TABLE [dbo].[RiepInv] ADD  DEFAULT (newid()) FOR [Keys]
GO


