CREATE FUNCTION [dbo].[fn_verifica_incremento_contatore]
( @device varchar(30) 
				,@crediti bigint 
				,@tickets bigint 
				,@cnt3 bigint 
				,@cnt4 bigint 
				,@cnt5 bigint 
				,@cnt6 bigint 
				,@cnt7 bigint 
				,@cnt8 bigint 
				,@gettoni bigint 
				,@partite bigint 
)
RETURNS bigint
AS
BEGIN
  -- routine body goes here, e.g.
  -- SELECT 'Navicat for SQL Server'
  RETURN (
SELECT top 1
isnull(crediti,0) +isnull(tickets,0) +isnull(cnt3,0) +isnull(cnt4,0) +isnull(cnt5,0) +isnull(cnt6,0) +isnull(cnt7,0) +isnull(cnt8,0) +isnull(gettoni,0) +isnull(partite,0)
FROM [dbo].[CoinlessDecodedData]
WHERE
device = @device AND
isnull(crediti,0) <= @crediti AND
isnull(tickets,0) <= @tickets AND
isnull(cnt3,0) <= @cnt3 AND
isnull(cnt4,0) <= @cnt4 AND
isnull(cnt5,0) <= @cnt5 AND
isnull(cnt6,0) <= @cnt6 AND
isnull(cnt7,0) <= @cnt7 AND
isnull(cnt8,0) <= @cnt8 AND
isnull(gettoni,0) <= @gettoni AND
isnull(partite,0) <= @partite

ORDER BY datastore DESC )
END
