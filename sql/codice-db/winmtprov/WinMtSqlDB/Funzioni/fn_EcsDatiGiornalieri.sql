SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fn_EcsDatiGiornalieri]
( 
	@CodMac AS varchar(15) = '%',
	@DallaData AS datetime ,
  @AllaData AS datetime 
)
RETURNS @myReturn TABLE (
			CodMac varchar(15) null,
			In1 int null,
			In2 int null,
			In3 int null,
			In4 int null,
			In5 int null,
			In6 int null,
			In7 int null,
			In8 int null,
			In9 int null,
			In10 int null,
			In11 int null,
			In12 int null,
			In13 int null,
			In14 int null,
			In15 int null,
			ValoreEcoin money null, 
			nr_partite_ecoin numeric(6,2) null,
			DataRil date null,
			ValoreOperazioneEcoin money null, 
			ValoreBonusEcoin money null
       )
AS
BEGIN
-- Ver 1.1
	insert into @myReturn
			select contatori.CodMac
					 ,contatori.In1,contatori.In2,contatori.In3,contatori.In4,contatori.In5,contatori.In6,contatori.In7
					 ,contatori.In8,contatori.In9,contatori.In10,contatori.In11,contatori.In12,contatori.In13,contatori.In14,contatori.In15
					 ,isnull(Tcards.Valore,0) as ValoreEcoin
					 ,isnull(Tcards.nr_partite,0) as nr_partite_ecoin	
					 ,contatori.DataRil
					 ,isnull(Tcards.ValoreOperazione,0) as ValoreOperazioneEcoin
					 ,isnull(Tcards.ValoreBonus,0) as ValoreBonusEcoin
		FROM (
			select CodMac, DataRil, In1, In2, In3, In4, In5, In6, In7, In8, In9, In10, In11, In12, In13, In14, In15
			from dbo.fn_RicalcolaContatoriGiornalieri (@CodMac,@DallaData,@AllaData)
		) as contatori
		LEFT JOIN 
		(SELECT
			dbo.TransCard.CodMac,convert(date ,TransCard.data) as dataril,
			Sum(dbo.TransCard.ValoreOperazione + dbo.TransCard.ValoreBonus ) AS Valore
			,Count(dbo.TransCard.IDOperazione) AS nr_partite
			,Sum(dbo.TransCard.ValoreOperazione ) AS ValoreOperazione
			,Sum(dbo.TransCard.ValoreBonus ) AS ValoreBonus
			FROM
			dbo.TransCard WHERE dbo.TransCard.WinMt = 0 
				and ( dbo.TransCard.ValoreOperazione > 0 or dbo.TransCard.ValoreBonus > 0) 
				and dbo.TransCard.codmac like @CodMac
			GROUP BY
			dbo.TransCard.CodMac,convert(date ,TransCard.data)

			) as  Tcards on contatori.CodMac = tcards.CodMac and contatori.dataril = Tcards.dataril
  RETURN 
END;
GO


