CREATE VIEW [dbo].[vs_contatori_per_macchina] AS 
SELECT distinct CodMac, Contatore
, dbo.fn_valore_contatore(CodMac, Contatore) as ValCnt
, dbo.fn_rapporto_contatore(CodMac, Contatore) as RappCnt
, dbo.fn_lettura_contatore(CodMac, Contatore) as CntrLet
FROM
( SELECT CodMac, InCnt1, InCnt2, InCnt3, InCnt4, InCnt5, InCnt6, InCnt7, InCnt8, InCnt9, InCnt10, InCnt11, InCnt12, InCnt13, InCnt14, InCnt15, InCnt16 
FROM EcsMacchine ) p
UNPIVOT 
( Contatore For NomeContatore in (
InCnt1, InCnt2, InCnt3, InCnt4, InCnt5, InCnt6, InCnt7, InCnt8, InCnt9, InCnt10, InCnt11, InCnt12, InCnt13, InCnt14, InCnt15, InCnt16 ) ) AS unpvt

where Contatore > 0;
