SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[fn_between_time]
( @dalle AS varchar(5) ,
  @alle AS varchar(5) 
)
RETURNS int
AS
BEGIN
-- Ver 1.1
	declare @valore INT = 1
	--set @valore = (select case when 	convert(varchar(5),getdate(),114) >= @dalle and 	convert(varchar(5),getdate(),114) <= @alle then 1 else 0 end )
  RETURN @valore
END
GO
