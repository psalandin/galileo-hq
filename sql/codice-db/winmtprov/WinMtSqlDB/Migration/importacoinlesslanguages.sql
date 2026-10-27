--truncate table [WinMtSqlDB].dbo.[CoinlessLanguages]

insert into [CoinlessLanguages] (testo,lingua,nr_campo,posx,posy,color,font,note,align)
SELECT testo,lingua,nr_campo,posx,posy,color,font,note,align
FROM [elmaccloud].[CoinlessDB].[dbo].[CoinlessLanguages] src 
WHERE
   NOT EXISTS (
    SELECT 1
    FROM [CoinlessLanguages] dest
    WHERE src.nr_campo = dest.nr_campo and src.lingua = dest.lingua
  )
GO
