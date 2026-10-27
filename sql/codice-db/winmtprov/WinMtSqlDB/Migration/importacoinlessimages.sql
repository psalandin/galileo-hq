-- truncate table [CoinlessImages]

insert into [CoinlessImages]
(ImageName,imageBinaryData,majorFirmware)
SELECT ImageName, imageBinaryData, majorFirmware
FROM [elmaccloud].[CoinlessDB].[dbo].[CoinlessImages] src
WHERE
   NOT EXISTS (
    SELECT 1
    FROM [CoinlessImages] dest
    WHERE src.ImageName = dest.ImageName
  )
GO
