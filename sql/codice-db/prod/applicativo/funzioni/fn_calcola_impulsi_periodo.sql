CREATE FUNCTION [dbo].[fn_calcola_impulsi_periodo]
( @CodMac AS varchar(15) ,
   @DataRil  AS datetime 
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
			In15 int null
       )
AS
BEGIN
declare @ultimadt datetime = (SELECT max(dbo.EcsDati.DataRil) FROM dbo.EcsDati WHERE dbo.EcsDati.CodMac = @CodMac and DataRil > @DataRil)
declare @penultimadt datetime = (SELECT max(dbo.EcsDati.DataRil) FROM dbo.EcsDati WHERE dbo.EcsDati.CodMac = @CodMac and DataRil <= @DataRil )
if @penultimadt is null 
	begin 
		select @penultimadt = (SELECT min(dbo.EcsDati.DataRil) FROM dbo.EcsDati WHERE dbo.EcsDati.CodMac = @CodMac )
	end

 insert into @myReturn
select 
isnull(ultima.CodMac,@CodMac) as CodMac
,isnull(ultima.in1,0)-isnull(penultima.in1,0) as In1
,isnull(ultima.in2,0)-isnull(penultima.in2,0) as In2
,isnull(ultima.in3,0)-isnull(penultima.in3,0) as In3
,isnull(ultima.in4,0)-isnull(penultima.in4,0) as In4
,isnull(ultima.in5,0)-isnull(penultima.in5,0) as In5
,isnull(ultima.in6,0)-isnull(penultima.in6,0) as In6
,isnull(ultima.in7,0)-isnull(penultima.in7,0) as In7
,isnull(ultima.in8,0)-isnull(penultima.in8,0) as In8
,isnull(ultima.in9,0)-isnull(penultima.in9,0) as In9
,isnull(ultima.in10,0)-isnull(penultima.in10,0) as In10
,isnull(ultima.in11,0)-isnull(penultima.in11,0) as In11
,isnull(ultima.in12,0)-isnull(penultima.in12,0) as In12
,isnull(ultima.in13,0)-isnull(penultima.in13,0) as In13
,isnull(ultima.in14,0)-isnull(penultima.in14,0) as In14
,isnull(ultima.in15,0)-isnull(penultima.in15,0) as In15

from (
SELECT top 1
dbo.EcsDati.CodMac,
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
dbo.EcsDati.DataRil
FROM
dbo.EcsDati
WHERE
dbo.EcsDati.CodMac = @CodMac
and DataRil = @ultimadt
order by DataRil desc ) ultima
inner join (
SELECT top 1
dbo.EcsDati.CodMac,
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
dbo.EcsDati.DataRil
FROM
dbo.EcsDati
WHERE
dbo.EcsDati.CodMac = @CodMac
and DataRil = @penultimadt 
order by DataRil asc
) penultima
on ultima.CodMac = penultima.CodMac

return 
END;
