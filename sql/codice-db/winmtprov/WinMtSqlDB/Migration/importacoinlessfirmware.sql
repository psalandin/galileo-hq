INSERT INTO [ecl_firmware]  (filename, 	url, 	version,	path,	tipoScheda, 	tipoFirmware, msgCount, 	firmwareBinaryData)
SELECT filename, 	url, 	version,	path,	tipoScheda, 	tipoFirmware , msgCount, 	firmwareBinaryData
FROM  [elmaccloud].[CoinlessDB].[dbo].ecl_firmware src 
WHERE
   NOT EXISTS (
    SELECT 1
    FROM [ecl_firmware] dest
    WHERE src.version = dest.version
  )
  AND src.flagactive=1;
GO
