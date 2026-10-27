SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE FUNCTION [dbo].[fn_is_ecl]
( 
)
RETURNS int
AS
BEGIN
-- Ver 1.1
  RETURN (select case when CodEcs = 'ECL' then 1 else 0 end  from Setup where idpost = 101)
END
GO


