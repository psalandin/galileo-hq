CREATE VIEW [dbo].[vs_ingressi_contatori] AS 
select * from (
select CodMac,convert(int,substring(pvt.NrContatore,1,2)) as ingresso
,convert(int,substring(pvt.NrContatore,4,2)) as contatore 
,dbo.fn_tipo_ingresso(CodMac, convert(int,substring(pvt.NrContatore,1,2))) as TipoIn
,dbo.fn_valore_ingresso(CodMac,convert(int,substring(pvt.NrContatore,1,2))) as ValIn
from 
(
SELECT CodMac, 

			case when InCnt1> 0 then ' 1-'+convert(char(2),InCnt1) else '0' end as Ingresso1,
			case when InCnt2> 0 then ' 2-'+convert(char(2),InCnt2) else '0' end as Ingresso2,
			case when InCnt3> 0 then ' 3-'+convert(char(2),InCnt3) else '0' end as Ingresso3,
			case when InCnt4> 0 then ' 4-'+convert(char(2),InCnt4) else '0' end as Ingresso4,
			case when InCnt5> 0 then ' 5-'+convert(char(2),InCnt5) else '0' end as Ingresso5,
			case when InCnt6> 0 then ' 6-'+convert(char(2),InCnt6) else '0' end as Ingresso6,
			case when InCnt7> 0 then ' 7-'+convert(char(2),InCnt7) else '0' end as Ingresso7,
			case when InCnt8> 0 then ' 8-'+convert(char(2),InCnt8) else '0' end as Ingresso8,
			case when InCnt9> 0 then ' 9-'+convert(char(2),InCnt9) else '0' end as Ingresso9,
			case when InCnt10> 0 then '10-'+convert(char(2),InCnt10) else '0' end as Ingresso10,
			case when InCnt11> 0 then '11-'+convert(char(2),InCnt11) else '0' end as Ingresso11,
			case when InCnt12> 0 then '12-'+convert(char(2),InCnt12) else '0' end as Ingresso12,
			case when InCnt13> 0 then '13-'+convert(char(2),InCnt13) else '0' end as Ingresso13,
			case when InCnt14> 0 then '14-'+convert(char(2),InCnt14) else '0' end as Ingresso14,
			case when InCnt15> 0 then '15-'+convert(char(2),InCnt15) else '0' end as Ingresso15
FROM EcsMacchine 
 )  macchine 
UNPIVOT
(  NrContatore for InCnt in (Ingresso1, Ingresso2, Ingresso3, Ingresso4, Ingresso5, Ingresso6, Ingresso7, Ingresso8, Ingresso9, Ingresso10, Ingresso11, Ingresso12, Ingresso13, Ingresso14, Ingresso15) )  pvt

where pvt.NrContatore  <>'0' ) as elenco 
where elenco.tipoin is not null;
