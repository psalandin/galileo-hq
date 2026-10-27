SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vs_eclmacchine] AS 
SELECT
macchine.device,
macchine.CodMac,
macchine.NomMac,
macchine.device_status,
macchine.lastseen,
contatori.in1 as coins_counter,
contatori.in2 as tickets_counter,
contatori.in3 as coins,
contatori.in4 as bills,
contatori.in5 as tickets,
contatori.in6 as prizes_counter,
contatori.in7 as in7_counter,
contatori.in9 as in8_counter,
0 as Ingresso,
0 as Uscita1,
0 as Uscita2,
0 as Uscita3,
macchine.offlinecount,
macchine.onlinecount,
macchine.val_platinum,
macchine.val_gold,
macchine.val_silver,
macchine.val_normal,
macchine.cards_presentate,
macchine.is_happyhour,
macchine.is_timeplay,
macchine.is_online,
isnull(case when macchine.ValIn3 < 1 then 1 else macchine.ValIn3  end,1) as cnt_inp_coin,
isnull(case when macchine.ValIn4 < 1 then 1 else macchine.ValIn4  end,1) as cnt_inp_banc,
isnull(macchine.cntrlet10,1) as ImpulsiPerPartita,
isnull(macchine.cntrlet11,90) as width_inp_coin,
isnull(macchine.cntrlet12,500) as Lenght_coin,
isnull(macchine.cntrlet13,50) as hole_ticket,
isnull(macchine.cntrlet14,400) as Lenght_ticket,

tipo.typename,
tipo.color,
macchine.CntrLet15 as TicketsAutomaticiPerPartita,
isnull(macchine.cntrlet7,0) as TipoErogatore

FROM
dbo.EcsMacchine as macchine 
LEFT JOIN dbo.Type as tipo on tipo.id = macchine.tipo
left join (
select b.device,b.gettoni In1,b.tickets In2 , b.cnt3 In3  , b.cnt4 In4 , b.cnt5 In5 , b.cnt6 In6 , b.cnt7 In7 , b.cnt8 In8 ,b.partite In9 
from (
 SELECT device,Max(id) id FROM dbo.CoinlessDecodedData 
	GROUP BY device
) as a left join (

SELECT

id,
crediti,
tickets,
cnt3,
cnt4,
cnt5,
cnt6,
cnt7,
cnt8,
gettoni,
partite,
device

FROM [dbo].[CoinlessDecodedData] ) as b on b.id = a.id ) as contatori on contatori.device = macchine.device

where DataDis is null

GO


