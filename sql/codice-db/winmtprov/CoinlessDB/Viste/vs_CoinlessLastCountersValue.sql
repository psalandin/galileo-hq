SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[vs_CoinlessLastCountersValue] AS 
SELECT
CoinlessDecodedData.device,
CoinlessDecodedData.datastore,
CoinlessDecodedData.gettoni as cnt1,

CoinlessDecodedData.tickets as cnt2,
CoinlessDecodedData.cnt3,
CoinlessDecodedData.cnt4,
CoinlessDecodedData.cnt5,
CoinlessDecodedData.cnt6,
CoinlessDecodedData.cnt7,
CoinlessDecodedData.cnt8,

CoinlessDecodedData.partite cnt9

FROM [coinlessdb].[dbo].[CoinlessDecodedData] inner join (

SELECT 
device,
max(CoinlessDecodedData.id) id

FROM [coinlessdb].[dbo].[CoinlessDecodedData]  where cmd_inviato = 7 group by device ) as a on a.id = CoinlessDecodedData.id
GO

