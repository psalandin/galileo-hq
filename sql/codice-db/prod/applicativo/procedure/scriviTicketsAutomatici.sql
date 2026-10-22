CREATE PROCEDURE [dbo].[scriviTicketsAutomatici]
  @idcard AS  varchar(20),
	@device as Varchar(30)
AS
BEGIN
				-- pulisco idcard 
				SET @idcard = LEFT(@idcard, 8);
				-- scrivo i tickets automatici se previsti 
				declare @IdContatto as bigint 
				declare @ticketsAutomatici as int 
				select @ticketsAutomatici = (select macchine.CntrLet15 from dbo.EcsMacchine macchine where macchine.device = @device)
				--set @idcontatto = (select idcontatto from dbo.Clienti where clienti.t0 = upper(@idcard)+'00000000')
				--set @idlong = (select idlong from dbo.Clienti where clienti.t0 = upper(@idcard)+'00000000')
				declare @codmac varchar(30) 
				select @codmac = (select isnull((select codmac from dbo.EcsMacchine where device = @device ),''))

				declare @ultimovalorebonus as bigint 
				declare @dropticketsautomatci as int
				select @dropticketsautomatci = (
											(SELECT count(*) as eventoattivo FROM promozioni WHERE GETDATE() BETWEEN dalla_data AND alla_data ) *
											(select count(*) from setup2 where idpost = 101 and chiave ='flagDropTicketsForGold' and valore = 'true' ) *
											(select count(*) from promozioni_cards where cardid = upper(@idcard)+'00000000')
											)

				declare @costopartitagold as int 
				if @dropticketsautomatci  > 0
					BEGIN 
					SELECT @costopartitagold = isnull(vs_CoinlessSpecialTimes.perc_gold, EcsMacchine.val_gold) 
									FROM
										EcsMacchine	LEFT JOIN	vs_CoinlessSpecialTimes
										ON EcsMacchine.CodMac = vs_CoinlessSpecialTimes.codmac
									where EcsMacchine.CodMac = @codmac or EcsMacchine.device = @codmac
					if @costopartitagold = 0
						BEGIN 
							set @ticketsAutomatici = 0 
						END
				END
				if @ticketsAutomatici > 0 
					BEGIN
						select @ultimovalorebonus = ( select max(In15) from dbo.EcsDati b where b.codmac = @codmac  )
						set @idcontatto = ( select dbo.fn_idcliente(idcontatto,idlong) from dbo.Clienti where clienti.t0 = upper(@idcard)+'00000000'   )

						IF @IdContatto is not null 
						BEGIN 
							
							declare @SCO bigint 
							select @SCO = (convert(bigint,substring(convert( varchar(4),year(getdate())),4,1) + '00000001' )+DATEDIFF(second, convert(varchar(4),year(getdate()))+'-01-01 00:00:00', getdate()) )

							insert into dbo.Tickets (IdContatto,NumTickets,Data,MangiaT,NumTrans,TPagati,DataOut,Oper,OperOut,NonCont,Id,Aux,NRep,NImp,F0,T0,N0,D0,F1,T1,N1,D1 ) 
											values( @IdContatto,@ticketsAutomatici,Getdate(),8256,@SCO ,0,Null,0,0,0,'1',0,0,0,0,null,null,null,0,null,null,null )
							
							update dbo.clienti set tickets = tickets+ @ticketsAutomatici where t0 = upper(@idcard)+'00000000'

							-- aggiorno in ecsdati il contatore tickets
							insert into dbo.EcsDati (codmac,Stato,DataRil,In1,In2,In3,In4,In5 ,In6,In7,In8,In9,NImp,In16,In15)
							SELECT top 1 
							EcsDati.codmac,EcsDati.Stato,getdate(),EcsDati.In1,EcsDati.In2,EcsDati.In3,EcsDati.In4
							,EcsDati.In5 +case when EcsMacchine.cntrlet15 <0 then EcsMacchine.cntrlet15 * -1 else EcsMacchine.cntrlet15 end
							,EcsDati.In6,EcsDati.In7,EcsDati.In8,EcsDati.In9 +1,EcsDati.NImp,EcsDati.In16
							,EcsDati.In15+case when EcsMacchine.cntrlet15 <0 then EcsMacchine.cntrlet15 * -1 else EcsMacchine.cntrlet15 end
							FROM
							dbo.EcsDati  inner join dbo.EcsMacchine on EcsMacchine.codmac = EcsDati.codmac
							where EcsDati.codmac = @codmac order by EcsDati.DataRil desc	

						END  
					END 
				if @ticketsAutomatici < 0 
					BEGIN
						select @ultimovalorebonus = ( select max(In15) from dbo.EcsDati b where b.codmac = @codmac  )
						-- macchina con erogatori di tickets non collegati alle BI 
						-- non devo scrivere tickets solo ecsdati
						select @ticketsAutomatici = (select @ticketsAutomatici *-1)		
						-- sono stati erogati tickets cartacei ma non vengono aggiornati i contatori perchÃ¨ non collegati
						insert into dbo.EcsDati (codmac,Stato,DataRil,In1,In2,In3,In4,In5 ,In6,In7,In8,In9,NImp,In16,In15)
						SELECT top 1 
						EcsDati.codmac,EcsDati.Stato,getdate(),EcsDati.In1,EcsDati.In2,EcsDati.In3,EcsDati.In4
						,EcsDati.In5 +case when EcsMacchine.cntrlet15 <0 then EcsMacchine.cntrlet15 * -1 else EcsMacchine.cntrlet15 end
						,EcsDati.In6,EcsDati.In7,EcsDati.In8,EcsDati.In9 +1,EcsDati.NImp,EcsDati.In16
						,EcsDati.In15+case when EcsMacchine.cntrlet15 <0 then EcsMacchine.cntrlet15 * -1 else EcsMacchine.cntrlet15 end
						FROM
						dbo.EcsDati  inner join dbo.EcsMacchine on EcsMacchine.codmac = EcsDati.codmac
						where EcsDati.codmac = @codmac order by EcsDati.DataRil desc

				  
					END 
			-- inserisco il record in ecsdati per muovere i contatori



END
