SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [dbo].[sp_incasso]

	@dataCalcolo AS datetime ,
	@lang as int ,
	@valgettone as money,
	@valticket as money
AS
BEGIN
-- Ver. 1.1
set NOCOUNT ON
declare @sql nvarchar(max)
declare @CodMac nvarchar(30)
declare @Contatore nvarchar(30)
DECLARE @ParmDefinition nvarchar(500)
DECLARE @adesso datetime = (select getdate())
DECLARE @progressivo1 as money

DECLARE @fileTemporaneo varchar(20) = (select replace(convert(varchar(19),isnull(@dataCalcolo,@adesso),126),':','_'))

set @sql = N''
set @ParmDefinition = ''
DECLARE db_cursor CURSOR FOR
	select CodMac from EcsMacchine where DataDis is null or DataDis > isnull(@dataCalcolo,@adesso) --and codmac = 'msmash'

OPEN db_cursor  
FETCH NEXT FROM db_cursor INTO @CodMac 

WHILE @@FETCH_STATUS = 0  
BEGIN  
	set @sql = @sql + N'SELECT * from fn_calcola_impulsi_periodo('''+@CodMac+''',(SELECT isnull (MAX (dbo.Incassi.Data), convert(datetime,''01/01/2001 00:00:00'',120)) as data FROM dbo.Incassi)) union '
	FETCH NEXT FROM db_cursor INTO @CodMac 
END  

CLOSE db_cursor  
DEALLOCATE db_cursor 

if @sql <> ''
BEGIN 
	set @sql = left(@sql,(len(@sql)-5))

	--set @sql = 'insert into @myReturn (CodMac,CntrVal,CntLett) select * from a (' +@sql +') a'
CREATE TABLE #myTable (
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

CREATE TABLE #myTable2 (
				NomeMac varchar(150),
				CodMac varchar(15) null,
				ValPar money null,
				TipoIn int null,
				TipoIngresso varchar(15) null,
				ValoreScatto money null,
				LetturaPrecedente int null,
				LetturaAttuale numeric(10,1) null,
				LetturaAttualeReale int null,
				scatti numeric(10,1) null,
				Gettoni bigint null,				
				Tickets bigint null,
				Monete money null,
				Premi money null,
				GettoniU bigint null,
				MoneteU money null,
				Ecoin money null,
				Npartite numeric(10,1) null,
				NPartiteEcoin bigint null,
  			Tipo int null,
				PerDiv int null,
				contatore int null
				 )



	insert into #myTable exec( @sql )

insert into #myTable2 
	select 
	Macchine.NomMac
	,Macchine.CodMac
	,Macchine.ValPar
  ,Macchine.TipoIn 
	,case when @lang = 0 then 
		case Macchine.TipoIn
		when 0 then 'Monete'
		when 1 then 'Gettoni'
		when 2 then 'Premi'
		when 3 then 'Tickets'
		when 4 then 'Monete'
		when 5 then 'Gettoni'
		When 6 then 'E-coin'
		end
	 else 
		case Macchine.TipoIn
		when 0 then 'Money'
		when 1 then 'Tokens'
		when 2 then 'Prizes'
		when 3 then 'Tickets'
		when 4 then 'Coins'
		when 5 then 'Tokens'
		When 6 then 'E-coin'
		end
	 --end as TipoIn,macchine.ingresso ,
	end as TipoIngresso,
	case macchine.ingresso when 9 
		then case when isnull(tb1.In9,0) = 0 or isnull(Macchine.Valcnt,0) =0 then 0 else  Tcards.valore / (convert(money,tb1.In9) * convert(money,Macchine.ValIn)/Macchine.ValCnt) end 	
		else 	Macchine.ValCnt 
	end as ValoreScatto,
	Macchine.CntrLet  as LetturaPrecedente,
	case when isnull(Macchine.ValCnt,0) = 0 then 0 else 
	(convert(money,case macchine.ingresso 
	 when 1 then isnull(tb1.In1,0) 
	 when 2 then isnull(tb1.In2,0) 
	 when 3 then isnull(tb1.In3,0) 
	 when 4 then isnull(tb1.In4,0) 
	 when 5 then isnull(tb1.In5,0)
	 when 6 then isnull(tb1.In6,0) 
	 when 7 then isnull(tb1.In7,0) 
	 when 8 then isnull(tb1.In8,0) 
	 when 9 then isnull(tb1.In9,0) 
	 when 10 then isnull(tb1.In10,0) 
	 when 11 then isnull(tb1.In11,0) 
	 when 12 then isnull(tb1.In12,0) 
	 when 13 then isnull(tb1.In13,0) 
	 when 14 then isnull(tb1.In14,0) 
	 when 15 then isnull(tb1.In15,0) 
  end ) * convert(money,Macchine.ValIn)	/ Macchine.ValCnt ) end
	 as LetturaAttuale,
	convert(money,0 ) as LetturaAttualeReale,
	case when isnull(Macchine.ValCnt,0) = 0 then 0 else 
	convert(money,case macchine.ingresso 
		 when 1 then isnull(tb1.In1,0) 
		 when 2 then isnull(tb1.In2,0) 
		 when 3 then isnull(tb1.In3,0) 
		 when 4 then isnull(tb1.In4,0) 
		 when 5 then isnull(tb1.In5,0)
		 when 6 then isnull(tb1.In6,0) 
		 when 7 then isnull(tb1.In7,0) 
		 when 8 then isnull(tb1.In8,0) 
		 when 9 then isnull(tb1.In9,0) 
		 when 10 then isnull(tb1.In10,0) 
		 when 11 then isnull(tb1.In11,0) 
		 when 12 then isnull(tb1.In12,0) 
		 when 13 then isnull(tb1.In13,0) 
		 when 14 then isnull(tb1.In14,0) 
		 when 15 then isnull(tb1.In15,0) 
		end )	* convert(money,Macchine.ValIn)

	/ Macchine.ValCnt end
  as Scatti,

case macchine.TipoIn
when 1 then 
  case macchine.ingresso 
	 when 1 then isnull(tb1.In1,0) 
	 when 2 then isnull(tb1.In2,0) 
	 when 3 then isnull(tb1.In3,0) 
	 when 4 then isnull(tb1.In4,0) 
	 when 5 then isnull(tb1.In5,0)
	 when 6 then isnull(tb1.In6,0) 
	 when 7 then isnull(tb1.In7,0) 
	 when 8 then isnull(tb1.In8,0) 
	 when 9 then isnull(tb1.In9,0) 
	 when 10 then isnull(tb1.In10,0) 
	 when 11 then isnull(tb1.In11,0) 
	 when 12 then isnull(tb1.In12,0) 
	 when 13 then isnull(tb1.In13,0) 
	 when 14 then isnull(tb1.In14,0) 
	 when 15 then isnull(tb1.In15,0) 
  end  * convert(money,Macchine.ValIn)
ELSE 0
end
as Gettoni ,

case macchine.TipoIn
when 3 then 
  case macchine.ingresso 
	 when 1 then isnull(tb1.In1,0) 
	 when 2 then isnull(tb1.In2,0) 
	 when 3 then isnull(tb1.In3,0) 
	 when 4 then isnull(tb1.In4,0) 
	 when 5 then isnull(tb1.In5,0)
	 when 6 then isnull(tb1.In6,0) 
	 when 7 then isnull(tb1.In7,0) 
	 when 8 then isnull(tb1.In8,0) 
	 when 9 then isnull(tb1.In9,0) 
	 when 10 then isnull(tb1.In10,0) 
	 when 11 then isnull(tb1.In11,0) 
	 when 12 then isnull(tb1.In12,0) 
	 when 13 then isnull(tb1.In13,0) 
	 when 14 then isnull(tb1.In14,0) 
	 when 15 then isnull(tb1.In15,0) 
  end  * convert(money,Macchine.ValIn)
else 0
end
as Tickets ,

case macchine.TipoIn
when 0 then 
	convert(money,case macchine.ingresso 
	 when 1 then isnull(tb1.In1,0) 
	 when 2 then isnull(tb1.In2,0) 
	 when 3 then isnull(tb1.In3,0) 
	 when 4 then isnull(tb1.In4,0) 
	 when 5 then isnull(tb1.In5,0)
	 when 6 then isnull(tb1.In6,0) 
	 when 7 then isnull(tb1.In7,0) 
	 when 8 then isnull(tb1.In8,0) 
	 when 9 then isnull(tb1.In9,0)
	 when 10 then isnull(tb1.In10,0) 
	 when 11 then isnull(tb1.In11,0) 
	 when 12 then isnull(tb1.In12,0) 
	 when 13 then isnull(tb1.In13,0) 
	 when 14 then isnull(tb1.In14,0) 
	 when 15 then isnull(tb1.In15,0) 
  end ) *  
	convert(money,Macchine.ValIn) 
end
as Monete,

case macchine.TipoIn
when 2 then 
	convert(money,case macchine.ingresso 
	 when 1 then isnull(tb1.In1,0) 
	 when 2 then isnull(tb1.In2,0) 
	 when 3 then isnull(tb1.In3,0) 
	 when 4 then isnull(tb1.In4,0) 
	 when 5 then isnull(tb1.In5,0)
	 when 6 then isnull(tb1.In6,0) 
	 when 7 then isnull(tb1.In7,0) 
	 when 8 then isnull(tb1.In8,0) 
	 when 9 then isnull(tb1.In9,0)
	 when 10 then isnull(tb1.In10,0) 
	 when 11 then isnull(tb1.In11,0) 
	 when 12 then isnull(tb1.In12,0) 
	 when 13 then isnull(tb1.In13,0) 
	 when 14 then isnull(tb1.In14,0) 
	 when 15 then isnull(tb1.In15,0) 
  end ) *  
	convert(money,Macchine.ValIn) 
else 0 
end 
as Premi,

case macchine.TipoIn
when 5 then 
   convert(bigint,
  case macchine.ingresso 
	 when 1 then isnull(tb1.In1,0) 
	 when 2 then isnull(tb1.In2,0) 
	 when 3 then isnull(tb1.In3,0) 
	 when 4 then isnull(tb1.In4,0) 
	 when 5 then isnull(tb1.In5,0)
	 when 6 then isnull(tb1.In6,0) 
	 when 7 then isnull(tb1.In7,0) 
	 when 8 then isnull(tb1.In8,0) 
	 when 9 then isnull(tb1.In9,0) 
	 when 10 then isnull(tb1.In10,0) 
	 when 11 then isnull(tb1.In11,0) 
	 when 12 then isnull(tb1.In12,0) 
	 when 13 then isnull(tb1.In13,0) 
	 when 14 then isnull(tb1.In14,0) 
	 when 15 then isnull(tb1.In15,0) 
  end ) * convert(money,Macchine.ValIn)
ELSE 0
end
as GettoniU ,

case macchine.TipoIn
when 4 then 
   convert(money,
  case macchine.ingresso 
	 when 1 then isnull(tb1.In1,0) 
	 when 2 then isnull(tb1.In2,0) 
	 when 3 then isnull(tb1.In3,0) 
	 when 4 then isnull(tb1.In4,0) 
	 when 5 then isnull(tb1.In5,0)
	 when 6 then isnull(tb1.In6,0) 
	 when 7 then isnull(tb1.In7,0) 
	 when 8 then isnull(tb1.In8,0) 
	 when 9 then isnull(tb1.In9,0) 
	 when 10 then isnull(tb1.In10,0) 
	 when 11 then isnull(tb1.In11,0) 
	 when 12 then isnull(tb1.In12,0) 
	 when 13 then isnull(tb1.In13,0) 
	 when 14 then isnull(tb1.In14,0) 
	 when 15 then isnull(tb1.In15,0) 
  end ) * convert(money,Macchine.ValIn)
ELSE 0
end
as MoneteU ,
	Tcards.valore as ECoin ,

case when macchine.ingresso != 9 then 
	case when macchine.TipoIn = 0 or macchine.TipoIn = 1 then 
		case when isnull(Macchine.ValCnt,0) = 0 or Macchine.ValPar = 0 then 0 else 
			convert(money,case macchine.ingresso 
				 when 1 then isnull(tb1.In1,0) 
				 when 2 then isnull(tb1.In2,0) 
				 when 3 then isnull(tb1.In3,0) 
				 when 4 then isnull(tb1.In4,0) 
				 when 5 then isnull(tb1.In5,0)
				 when 6 then isnull(tb1.In6,0) 
				 when 7 then isnull(tb1.In7,0) 
				 when 8 then isnull(tb1.In8,0) 
				 when 9 then isnull(tb1.In9,0) 
				 when 10 then isnull(tb1.In10,0) 
				 when 11 then isnull(tb1.In11,0) 
				 when 12 then isnull(tb1.In12,0) 
				 when 13 then isnull(tb1.In13,0) 
				 when 14 then isnull(tb1.In14,0) 
				 when 15 then isnull(tb1.In15,0) 
				end )	* convert(money,Macchine.ValIn)
			 
		end / Macchine.ValPar
	else 0
	end 
else 0 
end 

	,

	isnull(tb1.In9,0) as NPartiteEcoin,
	
	Macchine.Tipo ,
	convert(int,Macchine.PerDiv) as PerDiv,
	Macchine.contatore

	from (
				SELECT *
				FROM
				dbo.vs_macchine
				where vs_macchine.tipo > 1 and vs_macchine.tipo < 100
			) as Macchine
	left join #myTable tb1 on  Macchine.CodMac = tb1.CodMac

	left join (
			SELECT
			dbo.TransCard.CodMac,Sum(dbo.TransCard.ValoreOperazione) AS Valore,Count(dbo.TransCard.IDOperazione) AS nr_partite
			FROM
			dbo.TransCard WHERE dbo.TransCard.WinMt = 0 and dbo.TransCard.ValoreOperazione > 0
			and TransCard.data >= (SELECT isnull (MAX (dbo.Incassi.Data), convert(datetime,'01/01/2001 00:00:00',120)) as data FROM dbo.Incassi) 
			and TransCard.data <= isnull(@dataCalcolo,@adesso)
			GROUP BY
			dbo.TransCard.CodMac
	) as Tcards on Macchine.CodMac = tcards.CodMac 


	where macchine.DataDis is  null or macchine.DataDis > isnull(@dataCalcolo,@adesso)

  select 	
					contatore,
					NomeMac,
					CodMac,
					Tipo as TipoMac,
					ValPar,
					TipoIn,
					ValoreScatto,
					LetturaPrecedente,
					( select sum(isnull(b.LetturaAttuale,0)) from #myTable2 b where b.CodMac = a.CodMac and b.contatore=a.contatore)+a.LetturaPrecedente as LetturaAttuale,
					( select sum(isnull(b.scatti,0)) from #myTable2 b where b.CodMac = a.CodMac and b.contatore=a.contatore) as scatti,
					Gettoni,
					--( select sum(isnull(b.Gettoni,0)) from #myTable2 b where b.CodMac = a.CodMac and b.tipoin=a.tipoin) SommaGettoni ,
					( select sum(isnull(b.Gettoni,0)) from #myTable2 b where b.CodMac = a.CodMac) SommaGettoni ,
					Tickets,
					--( select sum(isnull(b.Tickets,0)) from #myTable2 b where b.CodMac = a.CodMac and b.tipoin=a.tipoin) SommaTickets,
					( select sum(isnull(b.Tickets,0)) from #myTable2 b where b.CodMac = a.CodMac) SommaTickets,
					Monete ,
					--( select sum(isnull(b.Monete,0)) from #myTable2 b where b.CodMac = a.CodMac and b.tipoin=a.tipoin)  SommaMonete,
					( select sum(isnull(b.Monete,0)) from #myTable2 b where b.CodMac = a.CodMac)  SommaMonete,
					Premi ,
					( select sum(isnull(b.Premi,0)) from #myTable2 b where b.CodMac = a.CodMac) SommaPremi,
					GettoniU,
					( select sum(isnull(b.GettoniU,0)) from #myTable2 b where b.CodMac = a.CodMac) SommaGettoniU,
					MoneteU,
					( select sum(isnull(b.MoneteU,0)) from #myTable2 b where b.CodMac = a.CodMac) SommaMoneteU,
					TipoIngresso,
					( select sum(isnull(b.Npartite,0)) +  max(isnull(b.NpartiteEcoin,0)) from #myTable2 b where b.CodMac = a.CodMac ) Npartite,
					( select max(isnull(b.Ecoin,0)) from #myTable2 b where b.CodMac = a.CodMac ) Ecoin
					

		from #myTable2 as a
	
 order by 3,2,5


  drop table #myTable
	drop table #myTable2

END
END
GO


