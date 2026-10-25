
CREATE PROCEDURE [dbo].[sp_punti_cliente]
	@locale AS varchar(10) ,
  @IdContatto AS varchar(10) ,
  @dalladata AS varchar(19) ,	
	@alladata AS varchar(19) 
AS
BEGIN

		declare @dblist varchar(1000) 
		declare @SQLcursor varchar(max) = ''
		declare @dbname varchar(50)
		declare @nomeDB varchar(100)
		declare @dummy int

		declare @sSQL nvarchar(500)
		DECLARE @ParmDefinition nvarchar(500)
		declare @lingua varchar(1) 

		set @sSQL = 'select @retvalOUT = lang from DB'+@locale+'.dbo.setup where idpost=101'
		SET @ParmDefinition = N'@retvalOUT varchar(1) OUTPUT'
		EXEC sp_executesql @sSQL, @ParmDefinition, @retvalOUT=@lingua OUTPUT

		set @sSQL = 'select @retvalOUT = substring(t6,charindex(''#'',t6)+1,len(t6)) from DB'+@locale+'.dbo.setup where idpost=101'
		SET @ParmDefinition = N'@retvalOUT varchar(1000) OUTPUT'
		EXEC sp_executesql @sSQL, @ParmDefinition, @retvalOUT=@dblist OUTPUT

if CURSOR_STATUS('global','mycursor') >= 0 
begin
  close mycursor
  deallocate mycursor 
end

		DECLARE mycursor CURSOR
		FOR select * from STRING_SPLIT (@dblist,'|')

		OPEN mycursor  
		FETCH NEXT FROM mycursor INTO  @nomedb

		WHILE @@FETCH_STATUS = 0  
		BEGIN  
			--FETCH NEXT FROM mycursor INTO  @nomedb
			FETCH NEXT FROM mycursor INTO  @dbname -- salto la label
				SET @SQLcursor = @SQLcursor + 'SELECT Tickets.idcontatto,Clienti.cognome AS clinom,Clienti.nome AS clicogn,numtickets,Tickets.data,mangiat,numtrans,tpagati,dataout,oper,oper.cognome as opcognin,operout,operout.cognome as opcognout,
								noncont,tickets.id,aux,nrep,Tickets.nimp,Tickets.f0,reparti.reparto AS repnome,dbo.fn_decode_mt_bitmask (mangiat, '+@lingua+') AS nometipo,''' + @nomeDB + ''' as locale
								FROM
								(
								DB'+ @dbname+ '.dbo.Tickets
								LEFT JOIN (
								SELECT 0 AS id,''Redemption'' AS Reparto
								UNION
								SELECT ROW_NUMBER () OVER (partition BY MName ORDER BY MName) AS id,Reparto
								FROM
								(
								SELECT
								MName,Setup.NRep2,Setup.NRep3,Setup.NRep4,Setup.NRep5,Setup.NRep6,Setup.NRep7,Setup.NRep8,Setup.nrep9
								FROM
								DB'+ @dbname+ '.dbo.[Setup]
								WHERE
								IdPost = 101
								) p UNPIVOT (
								Reparto FOR NomeReparto IN (NRep2,NRep3,NRep4,NRep5,NRep6,NRep7,NRep8,nrep9)
								) AS unpvt
								WHERE
								Len(Reparto) > 0
								) reparti ON tickets.nrep = reparti.id
								)
								LEFT JOIN DB'+ @dbname+ '.dbo.clienti ON Tickets.IdContatto = Clienti.idlong
								LEFT JOIN DB'+ @dbname+ '.dbo.operatori AS oper ON Tickets.oper = oper.id
								LEFT JOIN DB'+ @dbname+ '.dbo.operatori AS operout ON Tickets.OperOut = operout.id
								WHERE
								Tickets.idcontatto = '+@IdContatto+'
								AND Tickets.D0 is null 
								AND mangiat <= 16384
								AND Tickets.data >= CONVERT (datetime,'''+@dalladata+''',101)
								AND Tickets.data <= CONVERT (datetime,'''+@alladata+''',101)
								AND aux = 0
 union 
'
			
			FETCH NEXT FROM mycursor INTO  @nomedb
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
				SET @SQLcursor = @SQLcursor + 'SELECT Tickets.idcontatto,Clienti.cognome AS clinom,Clienti.nome AS clicogn,numtickets,Tickets.data,mangiat,numtrans,tpagati,dataout,oper,oper.cognome as opcognin,operout,operout.cognome as opcognout,
								noncont,tickets.id,aux,nrep,Tickets.nimp,Tickets.f0,reparti.reparto AS repnome,dbo.fn_decode_mt_bitmask (mangiat, '+@lingua+') AS nometipo,''' + @nomeDB + ''' as locale
								FROM
								(
								DB'+ @dbname+ '.dbo.Tickets
								LEFT JOIN (
								SELECT 0 AS id,''Redemption'' AS Reparto
								UNION
								SELECT ROW_NUMBER () OVER (partition BY MName ORDER BY MName) AS id,Reparto
								FROM
								(
								SELECT
								MName,Setup.NRep2,Setup.NRep3,Setup.NRep4,Setup.NRep5,Setup.NRep6,Setup.NRep7,Setup.NRep8,Setup.nrep9
								FROM
								DB'+ @dbname+ '.dbo.[Setup]
								WHERE
								IdPost = 101
								) p UNPIVOT (
								Reparto FOR NomeReparto IN (NRep2,NRep3,NRep4,NRep5,NRep6,NRep7,NRep8,nrep9)
								) AS unpvt
								WHERE
								Len(Reparto) > 0
								) reparti ON tickets.nrep = reparti.id
								)
								LEFT JOIN DB'+ @dbname+ '.dbo.clienti ON Tickets.IdContatto = Clienti.idlong
								LEFT JOIN DB'+ @dbname+ '.dbo.operatori AS oper ON Tickets.oper = oper.id
								LEFT JOIN DB'+ @dbname+ '.dbo.operatori AS operout ON Tickets.OperOut = operout.id
								WHERE
								Tickets.idcontatto = '+@IdContatto+'
								AND Tickets.data >= CONVERT (datetime,'''+@dalladata+''',101)
								AND Tickets.data <= CONVERT (datetime,'''+@alladata+''',101)
								AND aux = 0
								ORDER BY
								Tickets.Data'	



	exec(@SQLcursor )  
--select @SQLcursor
END
