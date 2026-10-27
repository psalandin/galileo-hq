SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE FUNCTION [dbo].[fn_EcsDatiPeriodici]
( 
	@CodMac AS varchar(15) = '%',
	@DallaData AS datetime ,
  @AllaData AS datetime 
)
RETURNS @myReturn TABLE (
			CodMac varchar(15) null,
			MvIngressi int null,
			MvUscite int null,
			MvCambiamonete int null,
			dal varchar(17),
			al varchar(17),
			ore int null
       )
AS
BEGIN
-- Ver 1.1
declare @MyTable TABLE (
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
			In15 int null
       )
	insert into @MyTable
		
		SELECT
		dbo.EcsDati.CodMac,
		Max(dbo.EcsDati.In1) In11,
		Max(dbo.EcsDati.In2) In12,
		Max(dbo.EcsDati.In3) In13,
		Max(dbo.EcsDati.In4) In14,
		Max(dbo.EcsDati.In5) In15,
		Max(dbo.EcsDati.In6) In16,
		Max(dbo.EcsDati.In7) In17,
		Max(dbo.EcsDati.In8) In18,
		Max(dbo.EcsDati.In9) In19,
		Max(dbo.EcsDati.In10) In110,
		Max(dbo.EcsDati.In11) In111,
		Max(dbo.EcsDati.In12) In112,
		Max(dbo.EcsDati.In13) In113,
		Max(dbo.EcsDati.In14) In114,
		Max(dbo.EcsDati.In15) In115

		FROM
		
		dbo.EcsDati WHERE 
		dbo.EcsDati.CodMac like @CodMac and
		convert(datetime,dbo.EcsDati.DataRil) >= @DallaData and convert(datetime,dbo.EcsDati.DataRil) <= @AllaData
		 
		GROUP BY
		dbo.EcsDati.CodMac,convert(date,dbo.EcsDati.DataRil) 

insert into @myReturn
select CodMac, sum(ingressi) as mvingressi ,sum(uscite) as mvuscite ,sum(cambiamonete) as mvcambiamonete,convert(varchar(17),@dalladata,113) dal,convert(varchar(17),@alladata,113) al ,convert(varchar(5),DATEDIFF(hour, @dalladata, @alladata)) ore
from (		
		select 
				p.CodMAc,macchine.tipoin,
				case 
				when macchine.tipoin in(0,1)
				then 
					case macchine.ingresso 
					 when 1 then isnull(d.In1,0) - isnull(p.In1,0)
					 when 2 then isnull(d.In2,0) - isnull(p.In2,0)
					 when 3 then isnull(d.In3,0) - isnull(p.In3,0) 
					 when 4 then isnull(d.In4,0) - isnull(p.In4,0) 
					 when 5 then isnull(d.In5,0) - isnull(p.In5,0)
					 when 6 then isnull(d.In6,0) - isnull(p.In6,0) 
					 when 7 then isnull(d.In7,0) - isnull(p.In7,0) 
					 when 8 then isnull(d.In8,0) - isnull(p.In8,0) 
					 when 9 then isnull(d.In9,0) - isnull(p.In9,0) 
					 when 10 then isnull(d.In10,0) - isnull(p.In10,0) 
					 when 11 then isnull(d.In11,0) - isnull(p.In11,0) 
					 when 12 then isnull(d.In12,0) - isnull(p.In12,0) 
					 when 13 then isnull(d.In13,0) - isnull(p.In13,0) 
					 when 14 then isnull(d.In14,0) - isnull(p.In14,0) 
					 when 15 then isnull(d.In15,0) - isnull(p.In15,0) 
					end
				end as ingressi,
				case when macchine.tipoin in (2,3)
				then 
					case macchine.ingresso 
					 when 1 then isnull(d.In1,0) - isnull(p.In1,0)
					 when 2 then isnull(d.In2,0) - isnull(p.In2,0)
					 when 3 then isnull(d.In3,0) - isnull(p.In3,0) 
					 when 4 then isnull(d.In4,0) - isnull(p.In4,0) 
					 when 5 then isnull(d.In5,0) - isnull(p.In5,0)
					 when 6 then isnull(d.In6,0) - isnull(p.In6,0) 
					 when 7 then isnull(d.In7,0) - isnull(p.In7,0) 
					 when 8 then isnull(d.In8,0) - isnull(p.In8,0) 
					 when 9 then isnull(d.In9,0) - isnull(p.In9,0) 
					 when 10 then isnull(d.In10,0) - isnull(p.In10,0) 
					 when 11 then isnull(d.In11,0) - isnull(p.In11,0) 
					 when 12 then isnull(d.In12,0) - isnull(p.In12,0) 
					 when 13 then isnull(d.In13,0) - isnull(p.In13,0) 
					 when 14 then isnull(d.In14,0) - isnull(p.In14,0) 
					 when 15 then isnull(d.In15,0) - isnull(p.In15,0) 
					end
				end as uscite,
				case when macchine.tipoin in (4,5)
				then 
					case macchine.ingresso 
					 when 1 then isnull(d.In1,0) - isnull(p.In1,0)
					 when 2 then isnull(d.In2,0) - isnull(p.In2,0)
					 when 3 then isnull(d.In3,0) - isnull(p.In3,0) 
					 when 4 then isnull(d.In4,0) - isnull(p.In4,0) 
					 when 5 then isnull(d.In5,0) - isnull(p.In5,0)
					 when 6 then isnull(d.In6,0) - isnull(p.In6,0) 
					 when 7 then isnull(d.In7,0) - isnull(p.In7,0) 
					 when 8 then isnull(d.In8,0) - isnull(p.In8,0) 
					 when 9 then isnull(d.In9,0) - isnull(p.In9,0) 
					 when 10 then isnull(d.In10,0) - isnull(p.In10,0) 
					 when 11 then isnull(d.In11,0) - isnull(p.In11,0) 
					 when 12 then isnull(d.In12,0) - isnull(p.In12,0) 
					 when 13 then isnull(d.In13,0) - isnull(p.In13,0) 
					 when 14 then isnull(d.In14,0) - isnull(p.In14,0) 
					 when 15 then isnull(d.In15,0) - isnull(p.In15,0) 
					end
				end as cambiamonete

		from (
				select EcsDati.CodMac,EcsDati.In1,EcsDati.In2,EcsDati.In3,EcsDati.In4,EcsDati.In5,EcsDati.In6,EcsDati.In7,EcsDati.In8,EcsDati.In9,EcsDati.In10,EcsDati.In11,EcsDati.In12,EcsDati.In13,EcsDati.In14,EcsDati.In15
				from 
					(		SELECT  
								EcsDati.CodMac,
								max(dbo.EcsDati.DataRil) as DataRil

							FROM vs_macchine
							left join dbo.EcsDati on EcsDati.codmac = vs_macchine.codmac and vs_macchine.datadis is null
							
							WHERE 
							dbo.EcsDati.CodMac like @CodMac and
							convert(datetime,dbo.EcsDati.DataRil) < @DallaData
							group by EcsDati.CodMac ) ul INNER JOIN dbo.EcsDati on ul.CodMac= EcsDati.CodMac and ul.DataRil = EcsDati.DataRil

 ) as p 
		inner join @MyTable as d on p.CodMac = d.codmac
		inner JOIN vs_macchine as macchine on p.codmac = macchine.codmac and macchine.datadis is null
) as zz GROUP BY CodMac
 
 

  RETURN 
END;
GO


