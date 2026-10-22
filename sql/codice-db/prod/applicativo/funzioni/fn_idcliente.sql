CREATE FUNCTION [dbo].[fn_idcliente]
( @IdContatto AS bigint ,
  @Idlong AS bigint 
)
RETURNS bigint
AS
BEGIN
	RETURN (select case when CHARINDEX('|',ISNULL(T6,''))> 0 then @Idlong else @IdContatto end  from dbo.setup where idpost = 101)
   
END
