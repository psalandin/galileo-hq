SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[save_ciapett](
	[T0] [varchar](100) NULL,
	[TipoCard] [int] NULL,
	[checkcount] [bigint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[save_ciapett] ADD  DEFAULT ((0)) FOR [checkcount]
GO
