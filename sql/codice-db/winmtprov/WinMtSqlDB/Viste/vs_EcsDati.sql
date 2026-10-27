SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[vs_EcsDati] AS 
SELECT
 ROW_NUMBER() OVER( partition by dbo.EcsDati.codmac order by dbo.EcsDati.codmac,dbo.EcsDati.dataril) riga,
dbo.EcsDati.CodMac,
dbo.EcsDati.DataRil,
dbo.EcsDati.In1,
dbo.EcsDati.In2,
dbo.EcsDati.In3,
dbo.EcsDati.In4,
dbo.EcsDati.In5,
dbo.EcsDati.In6,
dbo.EcsDati.In7,
dbo.EcsDati.In8,
dbo.EcsDati.In9,
dbo.EcsDati.In10,
dbo.EcsDati.In11,
dbo.EcsDati.In12,
dbo.EcsDati.In13,
dbo.EcsDati.In14,
dbo.EcsDati.In15,
dbo.EcsDati.In16,
dbo.EcsDati.NImp,
dbo.EcsDati.F0,
dbo.EcsDati.T0,
dbo.EcsDati.N0,
dbo.EcsDati.D0
FROM [dbo].[EcsDati];
GO


