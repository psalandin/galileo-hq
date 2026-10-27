SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_leggiconfig]
  @locale AS varchar(4) ,
	@stringa as varchar(512) OUTPUT
AS
BEGIN
	declare @sSQL nvarchar(500)
	DECLARE @ParmDefinition nvarchar(500)
	set @sSQL = 'select @retvalOUT = substring(t6,charindex(''#'',t6)+1,len(t6)) from DB'+@locale+'.dbo.setup where idpost=101'
	SET @ParmDefinition = N'@retvalOUT varchar(512) OUTPUT'
	EXEC sp_executesql @sSQL, @ParmDefinition, @retvalOUT=@stringa OUTPUT
	select @stringa;
END
GO
