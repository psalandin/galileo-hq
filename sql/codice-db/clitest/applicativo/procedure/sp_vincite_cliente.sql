
CREATE PROCEDURE [dbo].[sp_vincite_cliente]
	@locale AS varchar(10) ,
	@IdContatto AS varchar(10) ,
	@dalladata AS varchar(19) ,	
	@alladata AS varchar(19) 
AS
BEGIN
	declare @dblist varchar(512) 
	declare @SQLcursor varchar(max) = ''
	declare @dbname varchar(50)
	declare @nomeDB varchar(100)
	declare @dummy int
	declare @sSQL nvarchar(500)
	DECLARE @ParmDefinition nvarchar(500)
	set @sSQL = 'select @retvalOUT = substring(t6,charindex(''#'',t6)+1,len(t6)) from DB'+@locale+'.dbo.setup where idpost=101'
	SET @ParmDefinition = N'@retvalOUT varchar(512) OUTPUT'
	EXEC sp_executesql @sSQL, @ParmDefinition, @retvalOUT=@dblist OUTPUT
	if CURSOR_STATUS('global','mycursor') >= 0 
		begin
			close mycursor
			deallocate mycursor 
		end
	DECLARE mycursor CURSOR
	FOR select * from STRING_SPLIT (@dblist,'|')
	OPEN mycursor  
	FETCH NEXT FROM mycursor INTO  @nomeDB
	WHILE @@FETCH_STATUS = 0  
		BEGIN  
			FETCH NEXT FROM mycursor INTO  @dbname -- salto la label
			SET @SQLcursor = @SQLcursor + 'SELECT
							idcontatto,	codice,	descrizione,	costo,	n_tickets, n_tickets-isnull(vincite.n0,0) t_silver,isnull(vincite.n0,0) t_gold,	vincite.data,	operatori.cognome AS opcogn,'''+ @nomeDB +''' as locale
						FROM
							(
								DB'+@dbname+'.dbo.Vincite
								LEFT JOIN DB'+@locale+'.dbo.operatori ON vincite.id = operatori.id
							)
						WHERE
							IdContatto = '+@IdContatto+'
								AND vincite.data >= CONVERT (datetime,'''+@dalladata+''',101)
								AND vincite.data <= CONVERT (datetime,'''+@alladata+''',101) union '
			FETCH NEXT FROM mycursor INTO  @nomeDB
		END
	if CURSOR_STATUS('global','mycursor') >= 0 
		begin
			close mycursor
		deallocate mycursor 
		end
	set @dbname = @locale					
	set @sSQL = 'select @retvalOUT = NomeLocale from DB'+@locale+'.dbo.setup where idpost=101'
	SET @ParmDefinition = N'@retvalOUT varchar(1000) OUTPUT'
	EXEC sp_executesql @sSQL, @ParmDefinition, @retvalOUT=@nomeDB OUTPUT
	SET @SQLcursor = @SQLcursor + 'SELECT
							idcontatto,	codice,	descrizione,	costo,	n_tickets, n_tickets-isnull(vincite.n0,0) t_silver,isnull(vincite.n0,0) t_gold,	vincite.data,	operatori.cognome AS opcogn,'''+@nomeDB+''' as locale
						FROM
							(
								DB'+@locale+'.dbo.Vincite
								LEFT JOIN DB'+@locale+'.dbo.operatori ON vincite.id = operatori.id
							)
						WHERE
							IdContatto = '+@IdContatto+'
								AND vincite.data >= CONVERT (datetime,'''+@dalladata+''',101)
								AND vincite.data <= CONVERT (datetime,'''+@alladata+''',101) 
						order by vincite.data'	

	exec(@SQLcursor )  
--select @SQLcursor
END
