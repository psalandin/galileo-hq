SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_preleva_punti]
	@locale AS varchar(10) ,
	@IdContatto AS bigint ,
	@Richiesti AS bigint ,	
	@intervallo as int ,
	@operatore as int ,
	@dataOPERAZIONE as varchar(22)
AS
BEGIN
	set nocount on 
	declare @dblist varchar(512) 
	declare @SQLcursor varchar(max) = ''
	declare @dbname varchar(50)
	declare @dummy int
	declare @sSQL nvarchar(500)
	DECLARE @ParmDefinition nvarchar(500)
	DECLARE @dataorasincro AS VARCHAR(22)
	--select  @dataorasincro =  convert(varchar(10),@dataOPERAZIONE,105) +' ' + convert(varchar(3),@dataOPERAZIONE,114) + substring(convert(varchar(12),getdate(),114),4,9)
  select  @dataorasincro =  substring(@dataOPERAZIONE,1,14) + substring(convert(varchar(12),getdate(),114),4,9)
--truncate table t_log

	set language italian
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
	FETCH NEXT FROM mycursor INTO  @dbname
	WHILE @@FETCH_STATUS = 0  
		BEGIN  
			FETCH NEXT FROM mycursor INTO  @dbname -- salto la label
			if @locale <> @dbname
				BEGIN
					SET @SQLcursor = @SQLcursor + 'select ''' +@dbname + ''' as locale,IdContatto,isnull(Tickets.NumTickets,0)- isnull(Tickets.TPagati,0) as tickets,isnull(Tickets.TPagati,0) as tpagati,Tickets.keys from DB'+ @dbname+ '.dbo.Tickets where Aux = 0 and IdContatto = ' 
					+ convert(varchar(15),@IdContatto) +' and isnull(Tickets.NumTickets,0)- isnull(Tickets.TPagati,0) > 0 and ' + (select convert(varchar(10),@intervallo))+ ' >= ( SELECT datediff(second,d1,'''+@dataorasincro+''') from DB'+ @dbname+ '.dbo.Setup as setup WHERE setup.IDPost = 101 )'
					+ ' union '
				END
			FETCH NEXT FROM mycursor INTO  @dbname
		END
	if CURSOR_STATUS('global','mycursor') >= 0 
		begin
			close mycursor
			deallocate mycursor 
		end
	if len(@SQLcursor) > 0 
		BEGIN
			set @SQLcursor = SUBSTRING(@SQLcursor, 0, len(@SQLcursor) - 5 ) 
		END

--truncate TABLE  cacca

--insert into t_log (log)  values ('insert into cacca (locale,idcontatto,tickets,tpagati,keys) select tb1.* from ( '+ @SQLcursor +' ) as tb1')	

--exec('insert into cacca (locale,idcontatto,tickets,tpagati,keys) select tb1.* from ( '+ @SQLcursor +' ) as tb1')  
	CREATE TABLE #temptable ([locale] varchar(20) NULL, [IdContatto] bigint NULL , [tickets] bigint null, [tpagati] bigint null, keys varchar(36))
	 --insert into t_log (log)  values (@SQLcursor)	
	exec('insert into #temptable (locale,idcontatto,tickets,tpagati,keys) select tb1.* from ( '+ @SQLcursor +' ) as tb1')  
	declare @Disponibili bigint = 0
	select @Disponibili = sum(tickets) from #temptable


		--se ho punti a disposizione vado ad aggiornare la tabella nei vari locali 
	declare @v1ocale varchar(25)
	declare @vtickets bigint
	declare @vpagati bigint
	declare @vkeys varchar(36)
	declare @risultato int
	declare @sqlupdate varchar(max)
	declare @aggiornoN0 as int 
--insert into t_log (log)  values ('disponibili '+convert(varchar(30),isnull(@Disponibili,-99))+' richiesti='+convert(varchar(30),isnull(@richiesti,-998)))
	IF @Disponibili >= @richiesti 
		BEGIN
			-- aggiorno la ultima transazione
			-- exec sp_last_trans @locale,@IdContatto,1
			DECLARE updtcursor CURSOR
			FOR select locale,tickets,tpagati,keys from #temptable where tickets > 0 
			OPEN updtcursor  
			FETCH NEXT FROM updtcursor INTO  @v1ocale,@vtickets,@vpagati,@vkeys
			WHILE @@FETCH_STATUS = 0  AND @richiesti > 0
				BEGIN  
				--	BEGIN TRANSACTION T1
 --insert into t_log (log)  values ('1')
 --insert into t_log (log)  values ('vpagati='+convert(varchar(20),isnull(@vpagati,0)) +' vtickets='+convert(varchar(20),isnull(@vtickets,0)) +' richiesti='+  convert(varchar(20),isnull(@richiesti,0))+ ' key='+@vkeys)	
					if @vpagati > 0
						BEGIN
							-- set @aggiornoN0 = 0
						
							if @vtickets <= @richiesti
								BEGIN
 --insert into t_log (log)  values ('2 clono vecchio registrando i pagati precedentemente')
									-- creo nel mio db un clone della transazione precedente con tickets pari ai tickets già pagati 
						set @sqlupdate = 'insert into DB'+ @v1ocale+ '.dbo.tickets (IdContatto,NumTickets,Data,MangiaT,NumTrans,TPagati,DataOut,Oper,OperOut,NonCont,Id,Aux,NRep,NImp,F0,T0,N0,D0) select IdContatto,'+(select convert(varchar(20),@vpagati)) +',data,MangiaT,NumTrans,'+(select convert(varchar(20),@vpagati)) +',DataOut,Oper,OperOut,0,Id,Aux,NRep,NImp,0,T0,null,D0 from DB'+ @v1ocale+ '.dbo.tickets where keys='''+@vkeys+''''			
 --insert into t_log (log)  values (@sqlupdate)							
						exec(@sqlupdate) 
 --insert into t_log (log)  values ('2b nuovo da me ed uso tutti i disponibili')
									-- creo nel mio db un nuovo ticket pagato pari al valore disponibile ( @vtickets  ) e fruitore il locale richiedente
						select  @dataorasincro =  substring(@dataOPERAZIONE,1,14) + substring(convert(varchar(12),getdate(),114),4,9)
						set @sqlupdate = 'insert into DB'+ @v1ocale+ '.dbo.tickets (IdContatto,NumTickets,Data,MangiaT,NumTrans,TPagati,DataOut,Oper,OperOut,NonCont,Id,Aux,NRep,NImp,F0,T0,N0,D0) select IdContatto,'+(select convert(varchar(20),@vtickets)) +',data,MangiaT,NumTrans,'+(select convert(varchar(20),@vtickets)) +','''+@dataorasincro+''',Oper,'+convert(varchar(10),@operatore)+',0,Id,Aux,NRep,NImp,0,T0,'''+@locale+''',D0 from DB'+ @v1ocale+ '.dbo.tickets where keys='''+@vkeys+''''				
 --insert into t_log (log)  values (@sqlupdate)							
						exec(@sqlupdate)
									-- creo nel db del richiedente come sopra nel locale richiedente 
 --insert into t_log (log)  values ('2c nuovo da te')
						select  @dataorasincro =  substring(@dataOPERAZIONE,1,14) + substring(convert(varchar(12),getdate(),114),4,9)
						set @sqlupdate = 'insert into DB'+ @locale+ '.dbo.tickets (IdContatto,NumTickets,Data,MangiaT,NumTrans,TPagati,DataOut,Oper,OperOut,NonCont,Id,Aux,NRep,NImp,F0,T0,N0,D0) select IdContatto,'+(select convert(varchar(20),@richiesti)) +','''+@dataorasincro+''',MangiaT,NumTrans,'+(select convert(varchar(20),@richiesti)) +','''+@dataorasincro+''','+convert(varchar(10),@operatore)+','+convert(varchar(10),@operatore)+',1,Id,Aux,NRep,NImp,1,T0,'''+@v1ocale+''',D0 from DB'+ @v1ocale+ '.dbo.tickets where keys='''+@vkeys+''''
 --insert into t_log (log)  values (@sqlupdate)	
						exec(@sqlupdate)
 --insert into t_log (log)  values ('2d cancello originale')
									-- cancello il record padre 
						set @sqlupdate = 'delete from DB'+ @v1ocale+ '.dbo.tickets where keys='''+@vkeys+''''
						exec(@sqlupdate)

								END
							ELSE
								BEGIN
 --insert into t_log (log)  values ('3 clono originale con i pagati ')
									-- creo nel mio db un clone della transazione precedente con tickets pari ai tickets già pagati 
						set @sqlupdate = 'insert into DB'+ @v1ocale+ '.dbo.tickets (IdContatto,NumTickets,Data,MangiaT,NumTrans,TPagati,DataOut,Oper,OperOut,NonCont,Id,Aux,NRep,NImp,F0,T0,N0,D0) select IdContatto,'+(select convert(varchar(20),@vpagati)) +',data,MangiaT,NumTrans,'+(select convert(varchar(20),@vpagati)) +',DataOut,Oper,OperOut,0,Id,Aux,NRep,NImp,0,T0,null,D0 from DB'+ @v1ocale+ '.dbo.tickets where keys='''+@vkeys+''''			
 --insert into t_log (log)  values (@sqlupdate)	
						exec(@sqlupdate) 
									-- creo nel mio db un nuovo ticket pagato pari al valore richiesto ( @richiesti  ) e fruitore il locale richiedente
 --insert into t_log (log)  values ('3a nuovo da me pari al richiesto e li uso tutti')
						select  @dataorasincro =  substring(@dataOPERAZIONE,1,14) + substring(convert(varchar(12),getdate(),114),4,9)
						set @sqlupdate = 'insert into DB'+ @v1ocale+ '.dbo.tickets (IdContatto,NumTickets,Data,MangiaT,NumTrans,TPagati,DataOut,Oper,OperOut,NonCont,Id,Aux,NRep,NImp,F0,T0,N0,D0) select IdContatto,'+(select convert(varchar(20),@richiesti)) +',data,MangiaT,NumTrans,'+(select convert(varchar(20),@richiesti)) +','''+@dataorasincro+''',Oper,'+convert(varchar(10),@operatore)+',0,Id,Aux,NRep,NImp,0,T0,'''+@locale+''',D0 from DB'+ @v1ocale+ '.dbo.tickets where keys='''+@vkeys+''''				
 --insert into t_log (log)  values (@sqlupdate)	
						exec(@sqlupdate)
									-- creo nel db del richiedente come sopra nel locale richiedente 
 --insert into t_log (log)  values ('3b nuovo da te')
						select  @dataorasincro = substring(@dataOPERAZIONE,1,14) + substring(convert(varchar(12),getdate(),114),4,9)
						set @sqlupdate = 'insert into DB'+ @locale+ '.dbo.tickets (IdContatto,NumTickets,Data,MangiaT,NumTrans,TPagati,DataOut,Oper,OperOut,NonCont,Id,Aux,NRep,NImp,F0,T0,N0,D0) select IdContatto,'+(select convert(varchar(20),@richiesti)) +','''+@dataorasincro+''',MangiaT,NumTrans,'+(select convert(varchar(20),@richiesti)) +','''+@dataorasincro+''','+convert(varchar(10),@operatore)+','+convert(varchar(10),@operatore)+',1,Id,Aux,NRep,NImp,1,T0,'''+@v1ocale+''',D0 from DB'+ @v1ocale+ '.dbo.tickets where keys='''+@vkeys+''''
 --insert into t_log (log)  values (@sqlupdate)	
						exec(@sqlupdate)
									-- creo il ticket con i punti residui
 --insert into t_log (log)  values ('3c creo tickets residui')
						select  @dataorasincro =  substring(@dataOPERAZIONE,1,14) + substring(convert(varchar(12),getdate(),114),4,9)
						set @sqlupdate = 'insert into DB'+ @v1ocale+ '.dbo.tickets (IdContatto,NumTickets,Data,MangiaT,NumTrans,TPagati,DataOut,Oper,OperOut,NonCont,Id,Aux,NRep,NImp,F0,T0,N0,D0) select IdContatto,'+(select convert(varchar(20),@vtickets - @richiesti)) +',data,MangiaT,NumTrans,0,'''+@dataorasincro+''','+convert(varchar(10),@operatore)+',null,0,Id,Aux,NRep,NImp,0,T0,null,D0 from DB'+ @v1ocale+ '.dbo.tickets where keys='''+@vkeys+''''				
 --insert into t_log (log)  values (@sqlupdate)	
						exec(@sqlupdate)
 --insert into t_log (log)  values ('3d cancello padre')
									-- cancello il record padre 
						set @sqlupdate = 'delete from DB'+ @v1ocale+ '.dbo.tickets where keys='''+@vkeys+''''
						exec(@sqlupdate)								
								END

						END
					ELSE
						BEGIN
 --insert into t_log (log)  values ('4 sonza pagati')
 --insert into t_log (log)  values ('vpagati='+convert(varchar(20),isnull(@vpagati,0)) +' vtickets='+convert(varchar(20),isnull(@vtickets,0)) +' richiesti='+  convert(varchar(20),isnull(@richiesti,0))+ ' key='+@vkeys)	
							if @vtickets <= @richiesti

								BEGIN
 --insert into t_log (log)  values ('5 uso tutto ')
								-- uso tutto il record e basta a chiudere operazione e aggiorno n0
								--set  @vtickets = (select case when @vtickets<=@richiesti then @vtickets else @richiesti end )
								select  @dataorasincro =  substring(@dataOPERAZIONE,1,14) + substring(convert(varchar(12),getdate(),114),4,9)
								set @sqlupdate = 'insert into DB'+ @locale+ '.dbo.tickets (IdContatto,NumTickets,Data,MangiaT,NumTrans,TPagati,DataOut,Oper,OperOut,NonCont,Id,Aux,NRep,NImp,F0,T0,N0,D0) select IdContatto,'+(select convert(varchar(20),@vtickets)) +',data,MangiaT,NumTrans,'+(select convert(varchar(20),@vtickets)) +','''+@dataorasincro+''',Oper,'+convert(varchar(10),@operatore)+',1,Id,Aux,NRep,NImp,1,T0,'''+@v1ocale+''',D0 from DB'+ @v1ocale+ '.dbo.tickets where keys='''+@vkeys+''''
 --insert into t_log (log)  values (@sqlupdate)		
								exec(@sqlupdate)
 --insert into t_log (log)  values ('5a aggiorno il padre')
								select  @dataorasincro =  substring(@dataOPERAZIONE,1,14) + substring(convert(varchar(12),getdate(),114),4,9)
								set @sqlupdate = 'update DB'+ @v1ocale+ '.dbo.tickets SET TPagati =  ' + (select convert(varchar(20),@vtickets )) + ', N0 = '+@locale+' ,DataOut = '''+@dataorasincro+''',OperOut= ' + (select convert(varchar(20),@operatore)) + ' where keys = '''+@vkeys+''''
 --insert into t_log (log)  values (@sqlupdate)		
								exec(@sqlupdate)
								END 
							else 
								BEGIN
 --insert into t_log (log)  values ('6 uso tutto')
								-- uso tutto il record e basta a chiudere operazione e aggiorno n0
								--set  @vtickets = (select case when @vtickets<=@richiesti then @vtickets else @richiesti end )
								select  @dataorasincro =  substring(@dataOPERAZIONE,1,14) + substring(convert(varchar(12),getdate(),114),4,9)
								set @sqlupdate = 'insert into DB'+ @locale+ '.dbo.tickets (IdContatto,NumTickets,Data,MangiaT,NumTrans,TPagati,DataOut,Oper,OperOut,NonCont,Id,Aux,NRep,NImp,F0,T0,N0,D0) select IdContatto,'+(select convert(varchar(20),@richiesti)) +',data,MangiaT,NumTrans,'+(select convert(varchar(20),@richiesti)) +','''+@dataorasincro+''',Oper,'+convert(varchar(10),@operatore)+',1,Id,Aux,NRep,NImp,1,T0,'''+@v1ocale+''',D0 from DB'+ @v1ocale+ '.dbo.tickets where keys='''+@vkeys+''''
 --insert into t_log (log)  values (@sqlupdate)		
								exec(@sqlupdate)
 --insert into t_log (log)  values ('6a aggiorno padre')
								select  @dataorasincro =  substring(@dataOPERAZIONE,1,14) + substring(convert(varchar(12),getdate(),114),4,9)
								set @sqlupdate = 'update DB'+ @v1ocale+ '.dbo.tickets SET TPagati =  ' + (select convert(varchar(20),@richiesti )) + ', N0 = '+@locale+' ,DataOut = '''+@dataorasincro+''',OperOut= ' + (select convert(varchar(20),@operatore)) + ' where keys = '''+@vkeys+''''
 --insert into t_log (log)  values (@sqlupdate)		
								exec(@sqlupdate)
								END 
					  END 
 --insert into t_log (log)  values ('7')
					select @richiesti = isnull(@richiesti,0) - isnull(@vtickets,0)
 --insert into t_log (log)  values ('8')
					FETCH NEXT FROM updtcursor INTO  @v1ocale,@vtickets,@vpagati,@vkeys
				END
			--	COMMIT TRANSACTION T1
				set @risultato = 1
 --insert into t_log (log)  values ('fine lavoro result=1')
			END 
		ELSE
			BEGIN
				set @risultato = 0
			END 
 --insert into t_log (log)  values ('i cursori')
	if CURSOR_STATUS('global','updtcursor') >= 0 
		begin
			close updtcursor
			deallocate updtcursor 
		end
	drop table #temptable
	select @risultato as result 
END
GO

