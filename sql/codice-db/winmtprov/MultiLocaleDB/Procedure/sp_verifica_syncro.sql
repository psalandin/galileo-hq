SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_verifica_syncro]
AS
BEGIN
	DECLARE @SQLcursor varchar(max) = ''
	declare @dbname varchar(10) = ''
	DECLARE mycursor CURSOR FOR
	SELECT name FROM master.dbo.sysdatabases where name like 'DB%'
	OPEN mycursor  
	FETCH NEXT FROM mycursor INTO  @dbname
	WHILE @@FETCH_STATUS = 0  
		BEGIN  
		set @SQLcursor = @SQLcursor + 'SELECT '''+@dbname+''' as DB, cast( MName as varchar(255)) COLLATE Latin1_General_CI_AS MName, cast( SyncRes as varchar(36)) COLLATE Latin1_General_CI_AS FROM '+@dbname+'.[dbo].[Setup] as setup WHERE setup.IDPost = 101 UNION'
		FETCH NEXT FROM mycursor INTO  @dbname 
		END
	if len(@SQLcursor) > 0 
		BEGIN
			set @SQLcursor = SUBSTRING(@SQLcursor, 0, len(@SQLcursor) - 5 )
		END
		-- select @SQLcursor
	exec (@SQLcursor)
END
GO