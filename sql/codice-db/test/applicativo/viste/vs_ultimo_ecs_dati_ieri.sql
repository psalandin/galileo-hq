CREATE VIEW [dbo].[vs_ultimo_ecs_dati_ieri] AS 
select b.* from
(SELECT
Max(DataRil) DataRil,
CodMac

FROM
dbo.EcsDati
where dataril < convert (datetime,convert(varchar(10),getdate(),120)+' 00:00:00',120) 
GROUP BY
CodMac
) as a
INNER JOIN 
(SELECT
CodMac,
Stato,
DataRil,
In1,
In2,
In3,
In4,
In5,
In6,
In7,
In8,
In9,
In10,
In11,
In12,
In13,
In14,
In15,
In16,
NImp,
ValoreUscita,
F0,
T0,
N0,
D0

FROM
dbo.EcsDati
) as b on a.CodMac = b.CodMac and a.DataRil = b.DataRil
