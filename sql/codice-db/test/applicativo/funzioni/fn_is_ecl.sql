CREATE FUNCTION [dbo].[fn_is_ecl]
( 
)
RETURNS int
AS
BEGIN
  RETURN (select case when CodEcs = 'ECL' then 1 else 0 end  from Setup where idpost = 101)
END
