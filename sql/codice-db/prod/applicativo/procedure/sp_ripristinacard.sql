CREATE   PROCEDURE sp_ripristinacard 
@idrfid As varchar(16)  
AS 
BEGIN 
-- Ver. 1.3
set @idrfid = (select LEFT(@idrfid + REPLICATE('0', 16), 16))declare @multilocale As Int  
Select @multilocale = (Select Case when charindex('#',t6)>0 then 0 else case when len(trim(t6))>0 then 1 else 0 end end  from setup where idpost = 101)  
declare @cliente As bigint 
     delete from WinMtSqlDB.dbo.CoinlessCards where cardid like convert(varchar(8),@idrfid) + '%' 
     delete from WinMtSqlDB.dbo.CoinlessTransazioniCards where cardid like convert(varchar(8),@idrfid) + '%' 
     delete from WinMtSqlDB.dbo.CoinlessClonedCards where cardid like convert(varchar(8),@idrfid) + '%' 
     delete from WinMtSqlDB.dbo.CoinlessLogEventiBlacklist where cardid like convert(varchar(8),@idrfid) + '%' 
     delete from WinMtSqlDB.dbo.CoinlessLogEventiBlacklist where testo like (Select '%'+convert(varchar(8),@idrfid)+'%') 
DECLARE cursor_clienti CURSOR 
    FOR Select Case when @multilocale = 0 Then idcontatto Else idlong end as cliente from clienti where t0 = @idrfid 
open cursor_clienti 
FETCH NEXT FROM cursor_clienti 
INTO @cliente 
WHILE @@FETCH_STATUS = 0  
BEGIN 
     delete from WinMtSqlDB.dbo.promozioni_cards where cardid like convert(varchar(8),@idrfid) + '%' 
     FETCH NEXT FROM cursor_clienti 
     INTO @cliente 
END 
CLOSE cursor_clienti 
DEALLOCATE cursor_clienti 
update clienti set t0 = null , codbar = null where t0 = @idrfid 
update operatori set t0 = null, codbar = null where t0 = @idrfid 
update compleanni set cardid = '' where cardid like convert(varchar(8),@idrfid) + '%' 
update ospiti set cardid = '' where cardid like convert(varchar(8),@idrfid) + '%' 
END 
