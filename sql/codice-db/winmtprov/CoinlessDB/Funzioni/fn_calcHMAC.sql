SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fn_calcHMAC]
( @device AS varchar(25) ,
  @cmd AS varchar(300) ,
  @cnt AS varchar(10)
)
RETURNS varchar(64)
AS
BEGIN
  -- routine body goes here, e.g.
  -- SELECT 'Navicat for SQL Server'
  RETURN ( SELECT convert(varchar(64),
					HASHBYTES('SHA2_256', @device+@cmd+@cnt+'<CHIAVE RIMOSSA: vedi il DB di sala>'),2) )

END
GO


