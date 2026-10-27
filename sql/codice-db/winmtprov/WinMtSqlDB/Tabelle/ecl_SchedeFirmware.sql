SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ecl_SchedeFirmware](
	[macaddress] [varchar](17) NOT NULL,
	[tipoScheda] [varchar](3) NOT NULL,
	[tipoFirmware] [varchar](15) NOT NULL,
	[dataAggiornamento] [datetime] NULL,
	[device] [varchar](30) NULL,
	[requestedVersion] [varchar](30) NULL,
	[detectedVersion] [varchar](30) NULL,
	[dataVerifica] [datetime] NULL,
	[bidetectedVersion] [varchar](30) NULL,
	[status] [varchar](10) NULL,
 CONSTRAINT [PK__ecl_Sche__A6142D01D68DCE35] PRIMARY KEY CLUSTERED 
(
	[macaddress] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
