SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[vs_valore_ingressi_per_macchina] AS 
SELECT distinct CodMac, ROW_NUMBER() OVER(partition by CodMac order by CodMac) as Ingresso,ValoreIngresso
FROM
( SELECT CodMac, ValIn1, ValIn2, ValIn3, ValIn4, ValIn5, ValIn6, ValIn7, ValIn8, ValIn9, ValIn10, ValIn11, ValIn12, ValIn13, ValIn14, ValIn15, ValIn16 
FROM EcsMacchine ) p
UNPIVOT 
( ValoreIngresso For Ingre in (
ValIn1, ValIn2, ValIn3, ValIn4, ValIn5, ValIn6, ValIn7, ValIn8, ValIn9, ValIn10, ValIn11, ValIn12, ValIn13, ValIn14, ValIn15, ValIn16 ) ) AS unpvt;
GO


