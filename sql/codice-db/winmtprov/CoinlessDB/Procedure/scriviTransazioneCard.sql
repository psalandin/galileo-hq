SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[scriviTransazioneCard]
  @idcard AS varchar(16),
	@device as varchar(10),
	@CostoPartita as bigint ,
	@livellocard as int 
AS
BEGIN
	declare @valoreUltimoSaldo bigint 
	declare @valoreNuovoSaldo as bigint
	declare @n0 bigint

	select @valoreNuovoSaldo = 0

  set @valoreUltimoSaldo = isnull(( SELECT top 1 credito FROM [WinMtSqlDB].[dbo].[clienti] WHERE T0 = @idcard+'00000000'   ),@valoreNuovoSaldo)
	set @valoreNuovoSaldo = @valoreUltimoSaldo - @CostoPartita


 insert into cacca (testo) values( '[REALTIME][scriviTransazioneCard] card='+@idcard+' valoreUltimoSaldo=' + isnull(convert(nvarchar(50),@valoreUltimoSaldo),'00')+' valoreNuovoSaldo='+isnull(convert(nvarchar(50),@valoreNuovoSaldo),'')+' valoreNuovoCostoPartita='+isnull(convert(nvarchar(50),@CostoPartita),''))
	update WinMtSqlDB.dbo.Clienti 
	set credito = @valoreNuovoSaldo 
	where clienti.T0 = @idcard+'00000000'

	insert into CoinlessTransazioniCards (device,CodMac,cardid,DataMovimento,TipoMovimento,SaldoCard,CostoPartita,LivelloCard)
			select 
			@device,
			isnull((select codmac from WinMtSqlDB.dbo.EcsMacchine where device = @device),''),
			@idcard,
			getdate(),
			'Scarico',			 
			@valoreNuovoSaldo as credito,
			@CostoPartita as valoremovimento,
			@livellocard as livellocard


END
GO

