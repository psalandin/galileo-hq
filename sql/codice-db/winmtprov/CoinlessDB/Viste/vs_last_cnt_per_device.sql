SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[vs_last_cnt_per_device] AS 
select b.device,b.dataril,
b.gettoni as cntGamesPlayed,
b.tickets as cntTickets,
b.cnt3 as cntCoins,
b.cnt4 as cntBills,
b.cnt5 as cntETickets,
b.cnt6 as cntPrizes,
b.cnt7 as cntPrizes2,
b.cnt8 as cntPrizes3
from dbo.CoinlessDecodedData b
INNER JOIN  
(SELECT
dbo.CoinlessDecodedData.device,
Max(dbo.CoinlessDecodedData.id) as id
FROM
dbo.CoinlessDecodedData 
GROUP BY
dbo.CoinlessDecodedData.device
) as a
ON a.id = b.id
GO

