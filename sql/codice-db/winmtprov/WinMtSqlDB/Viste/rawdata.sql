SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[rawdata] AS 
SELECT
dbo.CoinlessDati.device,
macch.codmac,
dbo.CoinlessDati.cmd,
dbo.CoinlessDati.cnt,
dbo.CoinlessDati.logdate,
dbo.CoinlessDati.id,
dbo.CoinlessDati.hmac,
cda.crediti,
cda.tickets,
cda.cnt3,
cda.cnt4,
cda.cnt5,
cda.cnt6,
cda.cnt7,
cda.cnt8,
cda.gettoni,
cda.tipocard,
cda.datarec,
cda.partite,
cda.carduid,
cda.saldocard

FROM
dbo.CoinlessDati
left join dbo.EcsMacchine as macch on macch.device = CoinlessDati.device
left join CoinlessDecodedData cda on cda.device = CoinlessDati.device and convert(varchar(19),cda.dataril,120) = convert(varchar(19),CoinlessDati.logdate,120)
GO
