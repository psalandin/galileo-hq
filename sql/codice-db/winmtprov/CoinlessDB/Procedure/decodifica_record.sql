SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[decodifica_record]
  @device AS varchar(16) ,
  @comando AS varchar (255),
	@logdate as datetime2 
AS
BEGIN


declare @cmdtable as TABLE
( row bigint, Item varchar(100)) 
																		 
insert into @cmdtable select *  from split(@comando,';') 
declare @tiporecord int 
set @tiporecord = (select convert(int, convert(VARBINARY ,case when len(item) % 2 = 0 then '0x' else '0x0' end + trim(item),1)) as tiporecord from @cmdtable where row =3)


if @tiporecord = 7 
BEGIN
-- controllo che la scheda interna sia inizalizzata verificando che partite non sia = a 4294967295
--if (convert(bigint, 
--		convert(VARBINARY ,'0x'+(select right('00'+item,2) from @cmdtable where row =48)+(select right('00'+item,2) from @cmdtable where row =47),1)+convert(VARBINARY ,'0x'+(select right('00'+item,2) from @cmdtable where row =46)+(select right('00'+item,2) from @cmdtable where row =45),1)
--			) ) < 4294967295
--BEGIN 
insert into CoinlessDecodedData (device,datastore,[Header ],risposta,cmd_inviato,numbyte,dataril,partite,tickets,cnt3,cnt4,cnt5,cnt6,cnt7,cnt8,gettoni,tipocard,datarec) 
select @device as device,getdate() as datastore,
( select convert(int, convert(VARBINARY ,case when len(item) % 2 = 0 then '0x' else '0x0' end + trim(item),1)) from @cmdtable where row =1) as header,
( select convert(int, convert(VARBINARY ,case when len(item) % 2 = 0 then '0x' else '0x0' end + trim(item),1)) from @cmdtable where row =2) as risposta,
( select convert(int, convert(VARBINARY ,case when len(item) % 2 = 0 then '0x' else '0x0' end + trim(item),1)) from @cmdtable where row =3) as cmd_inviato,
( select convert(int, convert(VARBINARY ,case when len(item) % 2 = 0 then '0x' else '0x0' end + trim(item),1)) from @cmdtable where row =4) as numbyte,
--right('0'+convert(varchar(2),( select convert(int, convert(VARBINARY ,case when len(item) % 2 = 0 then '0x' else '0x0' end + trim(item),1)) from @cmdtable where row =5)),2) 
--+'-'
--+right('0'+convert(varchar(2),( select convert(int, convert(VARBINARY ,case when len(item) % 2 = 0 then '0x' else '0x0' end + trim(item),1)) from @cmdtable where row =6)),2) 
--+'-'
--+convert(varchar(4), 
--	convert(int, 
--		convert(VARBINARY ,'0x'+(select right('00'+item,2) from @cmdtable where row =8)+(select right('00'+item,2) from @cmdtable where row =7),1)
--))
--+ ' '
--+right('0'+convert(varchar(2),( select convert(int, convert(VARBINARY ,case when len(item) % 2 = 0 then '0x' else '0x0' end + trim(item),1)) from @cmdtable where row =9)),2)+':' 
--+right('0'+convert(varchar(2),( select convert(int, convert(VARBINARY ,case when len(item) % 2 = 0 then '0x' else '0x0' end + trim(item),1)) from @cmdtable where row =10)),2)+':' 
--+right('0'+convert(varchar(2),( select convert(int, convert(VARBINARY ,case when len(item) % 2 = 0 then '0x' else '0x0' end + trim(item),1)) from @cmdtable where row =11)),2) 
getdate() as dataril,
convert(varchar(10), 
	convert(bigint, 
		convert(VARBINARY ,'0x'+(select right('00'+item,2) from @cmdtable where row =48)+(select right('00'+item,2) from @cmdtable where row =47),1)+convert(VARBINARY ,'0x'+(select right('00'+item,2) from @cmdtable where row =46)+(select right('00'+item,2) from @cmdtable where row =45),1)
)) as partite,

convert(varchar(10), 
	convert(bigint, 
		convert(VARBINARY ,'0x'+(select right('00'+item,2) from @cmdtable where row =20)+(select right('00'+item,2) from @cmdtable where row =19)+(select right('00'+item,2) from @cmdtable where row =18)+(select right('00'+item,2) from @cmdtable where row =17),1)
)) as tickets,
convert(varchar(10), 
	convert(bigint, 
		convert(VARBINARY ,'0x'+(select right('00'+item,2) from @cmdtable where row =24)+(select right('00'+item,2) from @cmdtable where row =23)+(select right('00'+item,2) from @cmdtable where row =22)+(select right('00'+item,2) from @cmdtable where row =21),1)
)) as cnt3,
convert(varchar(10), 
	convert(bigint, 
		convert(VARBINARY ,'0x'+(select right('00'+item,2) from @cmdtable where row =28)+(select right('00'+item,2) from @cmdtable where row =27)+(select right('00'+item,2) from @cmdtable where row =26)+(select right('00'+item,2) from @cmdtable where row =25),1)
)) as cnt4,
convert(varchar(10), 
	convert(bigint, 
		convert(VARBINARY ,'0x'+(select right('00'+item,2) from @cmdtable where row =32)+(select right('00'+item,2) from @cmdtable where row =31)+(select right('00'+item,2) from @cmdtable where row =30)+(select right('00'+item,2) from @cmdtable where row =29),1)
)) as cnt5,
convert(varchar(10), 
	convert(bigint, 
		convert(VARBINARY ,'0x'+(select right('00'+item,2) from @cmdtable where row =36)+(select right('00'+item,2) from @cmdtable where row =35)+(select right('00'+item,2) from @cmdtable where row =34)+(select right('00'+item,2) from @cmdtable where row =33),1)
)) as cnt6,
convert(varchar(10), 
	convert(bigint, 
		convert(VARBINARY ,'0x'+(select right('00'+item,2) from @cmdtable where row =40)+(select right('00'+item,2) from @cmdtable where row =39)+(select right('00'+item,2) from @cmdtable where row =38)+(select right('00'+item,2) from @cmdtable where row =37),1)
)) as cnt7,
convert(varchar(10), 
	convert(bigint, 
		convert(VARBINARY ,'0x'+(select right('00'+item,2) from @cmdtable where row =44)+(select right('00'+item,2) from @cmdtable where row =43)+(select right('00'+item,2) from @cmdtable where row =42)+(select right('00'+item,2) from @cmdtable where row =41),1)
)) as cnt8,
convert(varchar(10), 
	convert(bigint, 
		convert(VARBINARY ,'0x'+(select right('00'+item,2) from @cmdtable where row =16)+(select right('00'+item,2) from @cmdtable where row =15)+(select right('00'+item,2) from @cmdtable where row =14)+(select right('00'+item,2) from @cmdtable where row =13),1)
)) as crediti,
convert(varchar(10), 
	convert(bigint, 
		convert(VARBINARY ,'0x'+(select right('0000'+item,4) from @cmdtable where row =49),1)
)) as tipo_card,
@logdate
END
--END -- controllo scheda interna
--insert into debug_log (testo) values('test tipo record['+convert(varchar(10),@tiporecord)+']')
if @tiporecord in (8 ,13,19,20,22,23) -- transazione con card
	BEGIN

	declare @idcard varchar(8)
    -- set @idcard = ( select isnull(item,'') from @cmdtable where row =19)+( select isnull(item,'') from @cmdtable where row =20)+( select isnull(item,'') from @cmdtable where row =21)+( select isnull(item,'') from @cmdtable where row =22)
	

	-- blacklist verifica card 
--insert into debug_log (testo) values('tipo record['+convert(varchar(20),@tiporecord)+'][card] ['+@idcard+']'+@comando)
	-- cerco ultima transazione fatta da card 
	declare @valoreUltimoSaldo bigint
	declare @valoreNuovoSaldo bigint 
	declare @valoreNuovoCostoPartita bigint 
	declare @n0 bigint,@dt datetime, @progressivo int
	declare @moltiplicatore money 
	declare @puntiocrediti int 
	declare @idcontatto bigint 
	declare @progressivogiausato bigint
	declare @lsMotivo varchar(512)
	declare @lsLogDebug varchar(512)
	declare @livellocard int 
	
	set @moltiplicatore = (select dbo.CreditToCurrency(1)) 
	set @progressivo = 	convert(int, 
			convert(VARBINARY ,'0x'+(select right('00'+item,2) from @cmdtable where row =8)+(select right('00'+item,2) from @cmdtable where row =7)+(select right('00'+item,2) from @cmdtable where row =6)+(select right('00'+item,2) from @cmdtable where row =5),1)
		)
		
	declare @datatransazione datetime
	if @tiporecord in (8,13)
		begin		
    set @idcard = ( select isnull(right('00'+item,2) ,'00') from @cmdtable where row =21)
		set @idcard = @idcard +( select isnull(right('00'+item,2) ,'00') from @cmdtable where row =22)
		set @idcard = @idcard+( select isnull(right('00'+item,2) ,'00') from @cmdtable where row =23)
		set @idcard = @idcard+( select isnull(right('00'+item,2) ,'00') from @cmdtable where row =24)	
			
			set @valoreNuovoSaldo = ( SELECT convert(bigint, convert(VARBINARY ,'0x'+(select right('00'+item,2) from @cmdtable where row =20)+(select right('00'+item,2) from @cmdtable where row =19)+(select right('00'+item,2) from @cmdtable where row =18)+(select right('00'+item,2) from @cmdtable where row =17),1)))
			set @valoreNuovoCostoPartita = ( select convert(bigint,	convert(VARBINARY ,'0x'+(select right('0000'+item,4) from @cmdtable where row =29),1)) )
			set @progressivogiausato = (SELECT count(*)  FROM [dbo].[CoinlessTransazioniCards] WHERE [cardid] = @idcard and N0 = @progressivo)
			-- set @puntiocrediti = 	convert(int,convert(VARBINARY ,'0x'+(select right('00'+item,2) from @cmdtable where row =31) ))
			set @puntiocrediti = 	convert(int,convert(VARBINARY ,'0x'+(select right('00'+item,2) from @cmdtable where row =31),1 ))
			select top 1 @n0=TransCard.N0,@valoreUltimoSaldo = TransCard.ValoreFinale/@moltiplicatore,@dt=DATEADD(millisecond, TransCard.N0, TransCard.data)  
				from  WinMtSqlDB.dbo.TransCard INNER JOIN WinMtSqlDB.dbo.Clienti ON TransCard.IdCli = convert(varchar(30),  dbo.fn_idcliente(Clienti.IdContatto,Clienti.idlong))
				where clienti.t0 = @idcard+'00000000' and TransCard.N0 <= @progressivo order by TransCard.N0 -- provo ad usare il progressivo x verifica blacklist TransCard.data desc
			
			set @lsLogDebug = 'T0 = ' +@idcard+'00000000' 
																		+' valoreUltimoSaldo=' + isnull(convert(nvarchar(50),@valoreUltimoSaldo),'00')
										+' valoreNuovoSaldo='+isnull(convert(nvarchar(50),@valoreNuovoSaldo),'')
										+' valoreNuovoCostoPartita='+isnull(convert(nvarchar(50),@valoreNuovoCostoPartita),'')
																		+' N0='+isnull(convert(nvarchar(50),@progressivo),'')
																		+' puntiocrediti='+isnull(convert(nvarchar(50),@puntiocrediti),'')
																		+' progressivogiausato=' + isnull(convert(varchar(10),@progressivogiausato),'null')
			--insert into debug_log (testo) values('[scrivo da card]'+@lsLogDebug)			
			set @idcontatto = (select dbo.fn_idcliente(Clienti.IdContatto,Clienti.idlong) from WinMtSqlDB.dbo.Clienti where clienti.t0 = @idcard+'00000000')

--insert into debug_log (testo) values('[idcontatto]'+convert(varchar(100),@idcontatto))	

			IF NOT EXISTS (SELECT dbo.CoinlessCards.id, dbo.CoinlessCards.cardid FROM [dbo].[CoinlessCards] 
								WHERE dbo.CoinlessCards.cardid = @idcard )
				BEGIN
					INSERT INTO CoinlessCards ( cardid,IdContatto,SaldoUltimaRicarica,SaldoUltimaPresentazione)
						VALUES (@idcard , isnull(@idcontatto,0),@valoreUltimoSaldo,@valoreUltimoSaldo)
								 
				END
			
			set @datatransazione = (select getdate()) -- sono transazioni con i device collegati
			set @livellocard = ( select convert(int, convert(VARBINARY ,'0x'+(select right('0000'+item,4) from @cmdtable where row =30),1)) )
		end 
	else -- @tiporecord in (19,20,22,23)
		begin 
			set @idcard = ( select isnull(right('00'+item,2) ,'00') from @cmdtable where row =17)
			set @idcard = @idcard +( select isnull(right('00'+item,2) ,'00') from @cmdtable where row =18)
			set @idcard = @idcard+( select isnull(right('00'+item,2) ,'00') from @cmdtable where row =19)
			set @idcard = @idcard+( select isnull(right('00'+item,2) ,'00') from @cmdtable where row =20)	

			set @valoreNuovoSaldo = ( SELECT convert(bigint, convert(VARBINARY ,'0x'+(select right('00'+item,2) from @cmdtable where row =16)+(select right('00'+item,2) from @cmdtable where row =15)+(select right('00'+item,2) from @cmdtable where row =14)+(select right('00'+item,2) from @cmdtable where row =13),1)))

			set @valoreNuovoCostoPartita = ( SELECT convert(bigint, convert(VARBINARY ,'0x'+(select right('00'+item,2) from @cmdtable where row =26)+(select right('00'+item,2) from @cmdtable where row =25),1)) )

			set @progressivogiausato = (SELECT count(*)  FROM [dbo].[CoinlessTransazioniCards] WHERE [cardid] = @idcard and N0 = @progressivo)

			set @puntiocrediti = 	convert(int,convert(VARBINARY ,'0x'+(select right('00'+item,2) from @cmdtable where row =28) ,1))

			select top 1 @n0=TransCard.N0,@valoreUltimoSaldo = TransCard.ValoreFinale/@moltiplicatore,@dt=DATEADD(millisecond, TransCard.N0, TransCard.data)  
				from  WinMtSqlDB.dbo.TransCard INNER JOIN WinMtSqlDB.dbo.Clienti ON TransCard.IdCli = convert(varchar(30),dbo.fn_idcliente(Clienti.IdContatto,Clienti.idlong))
				where clienti.t0 = @idcard+'00000000' and TransCard.N0 <= @progressivo order by TransCard.N0 desc -- provo ad usare il progressivo x verifica blacklist TransCard.data desc

			select @lsLogDebug = 'T0 = ' +@idcard+'00000000' 
										+' valoreUltimoSaldo=' + isnull(convert(varchar(50),@valoreUltimoSaldo),'00')
										+' valoreNuovoSaldo='+isnull(convert(varchar(50),@valoreNuovoSaldo),'')
										+' valoreNuovoCostoPartita='+isnull(convert(varchar(50),@valoreNuovoCostoPartita),'')
										+' N0='+isnull(convert(varchar(50),@progressivo),'')
										+' puntiocrediti='+isnull(convert(varchar(50),@puntiocrediti),'')
										+' progressivogiausato=' + isnull(convert(varchar(10),@progressivogiausato),'null')
	
--insert into debug_log (testo) values('[stato card ]'+@lsLogDebug)

			set @idcontatto = (select dbo.fn_idcliente(Clienti.IdContatto,Clienti.idlong) from WinMtSqlDB.dbo.Clienti where clienti.t0 = @idcard+'00000000')
--insert into debug_log (testo) values('[idcontatto]'+convert(varchar(100),@idcontatto))	

			IF NOT EXISTS (SELECT dbo.CoinlessCards.id, dbo.CoinlessCards.cardid FROM [dbo].[CoinlessCards] 
								WHERE dbo.CoinlessCards.cardid = @idcard )
				BEGIN
					INSERT INTO CoinlessCards ( cardid,IdContatto,SaldoUltimaRicarica,SaldoUltimaPresentazione)
						VALUES (@idcard , isnull(@idcontatto,0),@valoreUltimoSaldo,@valoreUltimoSaldo)
								 
				END				
		-- decodifico la data inviata dalla be 

			if convert(bigint,convert(VARBINARY ,'0x'+(select right('00'+item,2) from @cmdtable where row =32)+(select right('00'+item,2) from @cmdtable where row =31),1)) > 2020
				begin 
				set @datatransazione = (
					select convert(datetime,
						convert (varchar(255),
						concat(

						convert(varchar(255),convert(bigint,convert(VARBINARY ,'0x'+(select right('00'+item,2) from @cmdtable where row =32)+(select right('00'+item,2) from @cmdtable where row =31),1))),'-',
						convert(varchar(255),convert(bigint,convert(VARBINARY ,'0x'+(select right('00'+item,2) from @cmdtable where row =30),1))),'-',
						convert(varchar(255),convert(bigint,convert(VARBINARY ,'0x'+(select right('00'+item,2) from @cmdtable where row =29),1))),' ',
						convert(varchar(255),convert(bigint,convert(VARBINARY ,'0x'+(select right('00'+item,2) from @cmdtable where row =33),1))),':',
						convert(varchar(255),convert(bigint,convert(VARBINARY ,'0x'+(select right('00'+item,2) from @cmdtable where row =34),1))),':',
						convert(varchar(255),convert(bigint,convert(VARBINARY ,'0x'+(select right('00'+item,2) from @cmdtable where row =35),1)))
						)
					),20 )
					)

				end
			else 
				begin 
					 set @datatransazione = (select convert(datetime,@dt))
				end 				
			set @livellocard = ( select convert(int, convert(VARBINARY ,'0x'+(select right('0000'+item,4) from @cmdtable where row =27),1)) )	
	


		end
--insert into debug_log (testo) values('[scrivo da card][datatrans]'+convert(varchar(25),@datatransazione))
	-- -------------------
	if @valoreNuovoCostoPartita > 0 
	BEGIN
	-- controllo black list
	if  isnull(@valoreUltimoSaldo,0) >= @valoreNuovoSaldo and isnull(@n0,0) <> @progressivo and @progressivogiausato=0 and isnull(@idcontatto,0) > 0
		BEGIN 

				update WinMtSqlDB.dbo.Clienti 
				set credito = @valoreNuovoSaldo 
				where clienti.T0 = upper(@idcard)+'00000000'

				insert into CoinlessTransazioniCards (device,CodMac,cardid,DataMovimento,TipoMovimento,SaldoCard,CostoPartita,LivelloCard,N0)
				select 
				@device,

				isnull((select codmac from WinMtSqlDB.dbo.EcsMacchine where device = @device),''),
				upper(@idcard),
				
				@datatransazione,
				
				'Scarico',			 
					@valoreNuovoSaldo as credito,
					@valoreNuovoCostoPartita as valoremovimento,
					@livellocard,
				@progressivo

				exec scriviTicketsAutomatici @idcard,@device

				if @tiporecord in (19,20) -- transazione con card da device senza BI
					BEGIN
				-- adesso scrivo il movimento in ecs dati 
				--insert into debug_log (testo) values('tipo record['+convert(varchar(10),@tiporecord)+']')
					insert into CoinlessDecodedData (device,datastore,Header ,risposta,cmd_inviato,numbyte,dataril,crediti,tickets,cnt3,cnt4,cnt5,cnt6,cnt7,cnt8,gettoni,tipocard,datarec,partite,carduid,saldocard)  
								SELECT top 1
								device,@datatransazione  datastore,Header ,risposta,cmd_inviato,numbyte,@datatransazione dataril,crediti,tickets,cnt3,cnt4,cnt5,cnt6,cnt7,cnt8,gettoni,tipocard,datarec,partite,carduid,saldocard
								from(

								select device,datastore,Header ,risposta,cmd_inviato,numbyte,dataril,crediti,tickets,cnt3,cnt4,cnt5,cnt6,cnt7,cnt8,gettoni,tipocard,datarec,partite,carduid,saldocard,ordine 
								from (SELECT top 1
								device,datastore,Header ,risposta,cmd_inviato,numbyte,dataril,crediti,tickets,0 cnt3,0 cnt4,0 cnt5,0 cnt6,0 cnt7,0 cnt8,0 gettoni,tipocard,getdate() datarec,partite+1 partite,null carduid,null saldocard,0 as ordine 
								FROM [dbo].[CoinlessDecodedData]
								where device = @device
								order by dataril desc ) as a
								union
								select @device,getdate(),3 ,0,7,48,getdate(),null,0,0,0,0,0,0,0,0,0,getdate(),1,null,null,1 as ordine

								 ) as recordset order by recordset.ordine
					END
			
		END 
	ELSE 
		BEGIN 
			set @lsMotivo = ''
			if isnull(@valoreUltimoSaldo,0) < @valoreNuovoSaldo 
			BEGIN 
				select @lsMotivo = @lsMotivo + 'Il saldo attuale ('+ isnull(convert(nvarchar(50),@valoreUltimoSaldo),'00') +
                        ') è superiore al''ultimo saldo memorizzato ('+isnull(convert(nvarchar(50),@valoreNuovoSaldo),')') 
			END
			if isnull(@n0,0) = @progressivo
			BEGIN 
				select @lsMotivo = @lsMotivo + 'Il progressivo non è valido('+ isnull(convert(nvarchar(50),@progressivo),'') +') '
			END
			if @progressivogiausato > 0
			BEGIN 
				select @lsMotivo = @lsMotivo + 'Il progressivo è duplicato('+ isnull(convert(nvarchar(50),@progressivo),'') +') '
			END
			if isnull(@idcontatto,0) = 0
			BEGIN 
				select @lsMotivo = @lsMotivo + 'card ['+upper(@idcard)+']non associata ad un cliente '
			END
			insert into CoinlessLogEventiBlacklist (testo) values(@lsLogDebug)
			insert into CoinlessLogEventiBlacklist (testo,cardid) values(@lsMotivo,upper(@idcard))
			insert into CoinlessClonedCards (device,CodMac,cardid,DataMovimento,TipoMovimento,SaldoCard,CostoPartita,LivelloCard,N0)
			select 
			@device,
			isnull((select codmac from WinMtSqlDB.dbo.EcsMacchine where device = @device),''),
			upper(@idcard),
			getdate(),
			'Scarico',		 
				@valoreNuovoSaldo  as credito,
				@valoreNuovoCostoPartita as valoremovimento,
				@livellocard,
			@progressivo
		END  
  END
	END -- costopartita >0 non sono tickets
END
GO