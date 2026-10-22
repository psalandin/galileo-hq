CREATE FUNCTION [dbo].[CreditToCurrency]
( @credit AS money 
)
RETURNS money
AS
BEGIN
  -- routine body goes here, e.g.
  -- SELECT 'Navicat for SQL Server'
  RETURN (select item from split((SELECT AdmPass FROM dbo.Setup WHERE IDPost = 101),'|') where row = 3) * @credit
END
