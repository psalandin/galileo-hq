SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [dbo].[vs_contatori_letti] AS 
select pvtLet.CodMac, isnull([0],0) ContatoreMonete,isnull([1],0) ContatoreGettoni,isnull([2],0) ContatorePremi,isnull([3],0) ContatoreTickets
from (
SELECT
dbo.EcsMacchine.CodMac,
dbo.vs_ingressi_contatori.TipoIn,
dbo.vs_contatori_per_macchina.CntrLet

FROM
dbo.EcsMacchine
INNER JOIN dbo.vs_ingressi_contatori ON dbo.EcsMacchine.CodMac = dbo.vs_ingressi_contatori.CodMac
INNER JOIN dbo.vs_contatori_per_macchina ON dbo.vs_ingressi_contatori.CodMac = dbo.vs_contatori_per_macchina.CodMac AND dbo.vs_ingressi_contatori.contatore = dbo.vs_contatori_per_macchina.Contatore
) as src
PIVOT (
	max(src.CntrLet) 
	for TipoIn in ([0],[1],[2],[3])
) as pvtLet;
GO


