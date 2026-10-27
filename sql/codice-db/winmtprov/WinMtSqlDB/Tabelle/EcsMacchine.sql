SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[EcsMacchine](
	[Keys] [int] NULL,
	[CodMac] [varchar](15) NOT NULL,
	[Modu] [tinyint] NULL,
	[NomMac] [varchar](100) NULL,
	[Tipo] [tinyint] NULL,
	[ValIn1] [smallmoney] NULL,
	[ValIn2] [smallmoney] NULL,
	[ValIn3] [smallmoney] NULL,
	[ValIn4] [smallmoney] NULL,
	[ValIn5] [smallmoney] NULL,
	[ValIn6] [smallmoney] NULL,
	[ValIn7] [smallmoney] NULL,
	[ValIn8] [smallmoney] NULL,
	[ValIn9] [smallmoney] NULL,
	[ValIn10] [smallmoney] NULL,
	[ValIn11] [smallmoney] NULL,
	[ValIn12] [smallmoney] NULL,
	[ValIn13] [smallmoney] NULL,
	[ValIn14] [smallmoney] NULL,
	[ValIn15] [smallmoney] NULL,
	[ValIn16] [smallmoney] NULL,
	[TipoIn1] [tinyint] NULL,
	[TipoIn2] [tinyint] NULL,
	[TipoIn3] [tinyint] NULL,
	[TipoIn4] [tinyint] NULL,
	[TipoIn5] [tinyint] NULL,
	[TipoIn6] [tinyint] NULL,
	[TipoIn7] [tinyint] NULL,
	[TipoIn8] [tinyint] NULL,
	[TipoIn9] [tinyint] NULL,
	[TipoIn10] [tinyint] NULL,
	[TipoIn11] [tinyint] NULL,
	[TipoIn12] [tinyint] NULL,
	[TipoIn13] [tinyint] NULL,
	[TipoIn14] [tinyint] NULL,
	[TipoIn15] [tinyint] NULL,
	[TipoIn16] [tinyint] NULL,
	[CntrLet1] [int] NULL,
	[CntrLet2] [int] NULL,
	[CntrLet3] [int] NULL,
	[CntrLet4] [int] NULL,
	[CntrLet5] [int] NULL,
	[CntrLet6] [int] NULL,
	[CntrLet7] [int] NULL,
	[CntrLet8] [int] NULL,
	[CntrLet9] [int] NULL,
	[CntrLet10] [int] NULL,
	[CntrLet11] [int] NULL,
	[CntrLet12] [int] NULL,
	[CntrLet13] [int] NULL,
	[CntrLet14] [int] NULL,
	[CntrLet15] [int] NULL,
	[CntrLet16] [int] NULL,
	[CntrVal1] [smallmoney] NULL,
	[CntrVal2] [smallmoney] NULL,
	[CntrVal3] [smallmoney] NULL,
	[CntrVal4] [smallmoney] NULL,
	[CntrVal5] [smallmoney] NULL,
	[CntrVal6] [smallmoney] NULL,
	[CntrVal7] [smallmoney] NULL,
	[CntrVal8] [smallmoney] NULL,
	[CntrVal9] [smallmoney] NULL,
	[CntrVal10] [smallmoney] NULL,
	[CntrVal11] [smallmoney] NULL,
	[CntrVal12] [smallmoney] NULL,
	[CntrVal13] [smallmoney] NULL,
	[CntrVal14] [smallmoney] NULL,
	[CntrVal15] [smallmoney] NULL,
	[CntrVal16] [smallmoney] NULL,
	[InCnt1] [tinyint] NULL,
	[InCnt2] [tinyint] NULL,
	[InCnt3] [tinyint] NULL,
	[InCnt4] [tinyint] NULL,
	[InCnt5] [tinyint] NULL,
	[InCnt6] [tinyint] NULL,
	[InCnt7] [tinyint] NULL,
	[InCnt8] [tinyint] NULL,
	[InCnt9] [tinyint] NULL,
	[InCnt10] [tinyint] NULL,
	[InCnt11] [tinyint] NULL,
	[InCnt12] [tinyint] NULL,
	[InCnt13] [tinyint] NULL,
	[InCnt14] [tinyint] NULL,
	[InCnt15] [tinyint] NULL,
	[InCnt16] [tinyint] NULL,
	[RapCnt1] [decimal](4, 1) NULL,
	[RapCnt2] [decimal](4, 1) NULL,
	[RapCnt3] [decimal](4, 1) NULL,
	[RapCnt4] [decimal](4, 1) NULL,
	[RapCnt5] [decimal](4, 1) NULL,
	[RapCnt6] [decimal](4, 1) NULL,
	[RapCnt7] [decimal](4, 1) NULL,
	[RapCnt8] [decimal](4, 1) NULL,
	[RapCnt9] [decimal](4, 1) NULL,
	[RapCnt10] [decimal](4, 1) NULL,
	[RapCnt11] [decimal](4, 1) NULL,
	[RapCnt12] [decimal](4, 1) NULL,
	[RapCnt13] [decimal](4, 1) NULL,
	[RapCnt14] [decimal](4, 1) NULL,
	[RapCnt15] [decimal](4, 1) NULL,
	[RapCnt16] [decimal](4, 1) NULL,
	[Propr] [varchar](100) NULL,
	[PerDiv] [decimal](4, 1) NULL,
	[DataInst] [datetime] NULL,
	[DataDis] [datetime] NULL,
	[ValPar] [decimal](3, 2) NULL,
	[NImp] [int] NULL,
	[F0] [bit] NOT NULL,
	[T0] [varchar](100) NULL,
	[N0] [int] NULL,
	[D0] [datetime] NULL,
	[ValPiatto] [smallmoney] NULL,
	[PzPiatto] [int] NULL,
	[device] [varchar](16) NULL,
	[IngressoCrediti] [varchar](5) NULL,
	[IngressoGettoni] [varchar](5) NULL,
	[IngressoTickets] [varchar](5) NULL,
	[device_status] [varchar](10) NULL,
	[lastseen] [datetime] NULL,
	[offlinecount] [bigint] NULL,
	[onlinecount] [bigint] NULL,
	[cards_presentate] [bigint] NULL,
	[val_platinum] [int] NULL,
	[val_gold] [int] NULL,
	[val_silver] [int] NULL,
	[val_normal] [int] NULL,
	[is_happyhour] [int] NULL,
	[is_timeplay] [int] NULL,
	[is_online] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[CodMac] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[EcsMacchine] ADD  DEFAULT ((0)) FOR [F0]
GO

ALTER TABLE [dbo].[EcsMacchine] ADD  DEFAULT ((0)) FOR [ValPiatto]
GO

ALTER TABLE [dbo].[EcsMacchine] ADD  DEFAULT ((0)) FOR [PzPiatto]
GO

ALTER TABLE [dbo].[EcsMacchine] ADD  DEFAULT ('In3') FOR [IngressoCrediti]
GO

ALTER TABLE [dbo].[EcsMacchine] ADD  DEFAULT ('In1') FOR [IngressoGettoni]
GO

ALTER TABLE [dbo].[EcsMacchine] ADD  DEFAULT ('In2') FOR [IngressoTickets]
GO

ALTER TABLE [dbo].[EcsMacchine] ADD  DEFAULT ((0)) FOR [val_platinum]
GO

ALTER TABLE [dbo].[EcsMacchine] ADD  DEFAULT ((0)) FOR [val_gold]
GO

ALTER TABLE [dbo].[EcsMacchine] ADD  DEFAULT ((0)) FOR [val_silver]
GO

ALTER TABLE [dbo].[EcsMacchine] ADD  DEFAULT ((0)) FOR [val_normal]
GO

ALTER TABLE [dbo].[EcsMacchine] ADD  DEFAULT ((0)) FOR [is_happyhour]
GO

ALTER TABLE [dbo].[EcsMacchine] ADD  DEFAULT ((0)) FOR [is_timeplay]
GO

ALTER TABLE [dbo].[EcsMacchine] ADD  DEFAULT ((0)) FOR [is_online]
GO


