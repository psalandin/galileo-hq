CREATE VIEW [dbo].[vs_reparti] AS 
select ROW_NUMBER() OVER(partition by MName order by MName) as id ,
Reparto
FROM
(
SELECT
MName,
dbo.Setup.NRep2,
dbo.Setup.NRep3,
dbo.Setup.NRep4,
dbo.Setup.NRep5,
dbo.Setup.NRep6,
dbo.Setup.NRep7,
dbo.Setup.NRep8,
dbo.Setup.NRep9

FROM [dbo].[Setup] where idpost = 101  ) p
UNPIVOT 
( Reparto For NomeReparto in (
NRep2, NRep3, NRep4, NRep5, NRep6, NRep7, NRep8, NRep9) ) AS unpvt

where len(Reparto) >0;
