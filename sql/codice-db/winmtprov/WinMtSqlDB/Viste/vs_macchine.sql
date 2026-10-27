SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[vs_macchine] AS 
SELECT
				dbo.EcsMacchine.DataDis,
				dbo.EcsMacchine.NomMac,
				dbo.EcsMacchine.CodMac,
				dbo.EcsMacchine.ValPar,
				dbo.EcsMacchine.Tipo,
				dbo.EcsMacchine.PerDiv,
				dbo.vs_ingressi_contatori.TipoIn,
				dbo.vs_ingressi_contatori.ValIn,
				dbo.vs_contatori_per_macchina.ValCnt,
				dbo.vs_contatori_per_macchina.CntrLet,
				dbo.vs_ingressi_contatori.ingresso,
				dbo.vs_ingressi_contatori.contatore,
				dbo.vs_contatori_per_macchina.RappCnt

				FROM
				dbo.EcsMacchine
				LEFT JOIN dbo.vs_ingressi_contatori ON dbo.vs_ingressi_contatori.CodMac = dbo.EcsMacchine.CodMac
				INNER JOIN dbo.vs_contatori_per_macchina ON dbo.vs_ingressi_contatori.CodMac = dbo.vs_contatori_per_macchina.CodMac AND dbo.vs_ingressi_contatori.contatore = dbo.vs_contatori_per_macchina.Contatore;
GO


