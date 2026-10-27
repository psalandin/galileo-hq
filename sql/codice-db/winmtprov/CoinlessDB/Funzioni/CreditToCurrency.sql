SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[CreditToCurrency]
( @credit AS money 
)
RETURNS money
AS
BEGIN
  -- routine body goes here, e.g.
  -- SELECT 'Navicat for SQL Server'
  RETURN (select item from split((SELECT AdmPass FROM WinMtSqlDB.dbo.Setup WHERE IDPost = 101),'|') where row = 3) * @credit
END
GO


