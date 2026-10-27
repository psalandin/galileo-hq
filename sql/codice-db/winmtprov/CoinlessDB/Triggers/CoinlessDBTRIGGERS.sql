CREATE TRIGGER [dbo].[aggiorno_clienti_winmt]
ON [dbo].[CoinlessCards]
AFTER UPDATE
AS
BEGIN
  -- type your statements here
update clienti 
set credito = inserted.SaldoUltimaPresentazione 
from 
inserted inner join WinMtSqlDB.dbo.Clienti on clienti.T0 = inserted.cardid+'00000000'
END
GO

ALTER TABLE [dbo].[CoinlessCards] DISABLE TRIGGER [aggiorno_clienti_winmt]
GO

CREATE TRIGGER [dbo].[verifico_esistenza]
ON [dbo].[CoinlessCards]
AFTER INSERT
AS
BEGIN


update CoinlessCards 
set BlackList = 1 
from 
inserted 
inner join CoinlessCards on coinlesscards.id = inserted.id
left  join WinMtSqlDB.dbo.Clienti c on c.T0 = inserted.cardid+'00000000'
where c.idcontatto is null


select  inserted.cardid
from 
inserted 
inner join CoinlessCards on coinlesscards.id = inserted.id
left  join WinMtSqlDB.dbo.Clienti c on c.T0 = inserted.cardid+'00000000'
where c.idcontatto is null

update clienti 
set credito = inserted.SaldoUltimaPresentazione 
from 
inserted inner join WinMtSqlDB.dbo.Clienti on clienti.T0 = inserted.cardid+'00000000'
END
GO

ALTER TABLE [dbo].[CoinlessCards] ENABLE TRIGGER [verifico_esistenza]
GO

CREATE TRIGGER [dbo].[bannaUtente]
ON [dbo].[CoinlessClonedCards]
AFTER INSERT
AS
BEGIN

update cards
set BlackList = 1 
from CoinlessCards as cards
inner join inserted on cards.cardid = inserted.cardid

UPDATE C set
 F1 = 1,
 T1 = inserted.CodMac+'|costo partita:'+convert(varchar(20),inserted.CostoPartita)+'|saldo card:'+convert(varchar(20),inserted.SaldoCard)+'|id clonate:'+convert(varchar(20),inserted.id_card_clonate),
 D1 = getdate()
FROM  WinMtSqlDB.dbo.Clienti  C
inner join inserted on C.T0 = inserted.cardid+'00000000'
END
GO

ALTER TABLE [dbo].[CoinlessClonedCards] ENABLE TRIGGER [bannaUtente]
GO

CREATE TRIGGER [dbo].[decodifica_flusso]
ON [dbo].[CoinlessDati]
AFTER INSERT
AS
BEGIN
  -- type your statements here
DECLARE @NEWdevice VARCHAR (10)
DECLARE @NEWcmd varchar(255)
DECLARE @NEWlogdate datetime2 
DECLARE @NEWhmac varchar(64)
DECLARE @NEWcnt bigint
DECLARE @CHKHMAC varchar(64)

DECLARE my_Cursor CURSOR FAST_FORWARD FOR 

SELECT device,cmd,logdate,cnt,hmac FROM INSERTED
OPEN my_Cursor 
 FETCH NEXT FROM my_Cursor into @NEWdevice,@NEWcmd,@NEWlogdate,@NEWcnt,@NEWhmac 

 WHILE @@FETCH_STATUS = 0 
 BEGIN
	set @CHKHMAC = (SELECT dbo.fn_calcHMAC( @NEWdevice,@NEWcmd,convert(varchar(10),@NEWcnt) ) )	
	IF @CHKHMAC = @NEWhmac 
	BEGIN
		exec decodifica_record @NEWdevice,@NEWcmd,@NEWlogdate
	END
	FETCH NEXT FROM my_Cursor into @NEWdevice,@NEWcmd,@NEWlogdate ,@NEWcnt,@NEWhmac 
 END 
DEALLOCATE my_Cursor
END
GO

ALTER TABLE [dbo].[CoinlessDati] ENABLE TRIGGER [decodifica_flusso]
GO

CREATE UNIQUE NONCLUSTERED INDEX [idx1] ON [dbo].[CoinlessDati]
(
	[cmd] ASC,
	[cnt] ASC,
	[hmac] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = ON, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE TRIGGER [dbo].[inseriscesuECS]
ON [dbo].[CoinlessDecodedData]
AFTER INSERT
AS
BEGIN
-- giochi mobile kiddy mi incrementano solo le partite e le monete 
-- sono movimenti che mi arrivano dalle bi/be quindi non sanno niente dei bonus che getisco tramite la CntrLet15 
declare @device varchar(30)
select @device = ( select top 1 device from INSERTED )
declare @bonustickets bigint
select @bonustickets = (select isnull((select CntrLet15 from WinMtSqlDB.dbo.EcsMacchine where device = @device ),0))
declare @codmac varchar(15) 
select @codmac = (select isnull((select codmac from WinMtSqlDB.dbo.EcsMacchine where device = @device ),''))

INSERT INTO WinMtSqlDB.dbo.EcsDati( CodMac,DataRil,In1,In2,In3,In4,In5,In6,In7,In8,In9,NImp,In16,In15)
SELECT
		b.CodMac
      , a.[dataril]
      , a.[gettoni]
      , a.[tickets]
      , a.[cnt3]
      , a.[cnt4]
      , case 
		when @bonustickets=0 then  a.[cnt5] 
      		else  a.[cnt5] + ( select max(In15) from WinMtSqlDB.dbo.EcsDati b where b.codmac = @codmac  )
	end
      , a.[cnt6]
      , a.[cnt7]
      , a.[cnt8]
      ,a.[partite]
	  ,1
	  , 0
      ,(select max(In15) from WinMtSqlDB.dbo.EcsDati b where b.codmac = @codmac  )
  FROM INSERTED as a
  inner join [WinMtSqlDB].[dbo].[EcsMacchine] as b on b.device = a.device
  where a.[cmd_inviato] = 7

END
GO

ALTER TABLE [dbo].[CoinlessDecodedData] ENABLE TRIGGER [inseriscesuECS]
GO

ALTER TABLE [dbo].[CoinlessDecodedData] ENABLE TRIGGER [inseriscesuECS]
GO

CREATE TRIGGER [dbo].[aggiornaCard]
ON [dbo].[CoinlessTransazioniCards]
AFTER INSERT
AS
BEGIN
  -- type your statements here
update CoinlessCards
set DataUltimaRicarica = a.datamovimento, SaldoUltimaRicarica = a.saldo,N0= a.N0
from 
CoinlessCards inner join 
(SELECT
cardid,
Max(DataMovimento) AS datamovimento,
Sum(SaldoCard) AS saldo,
Max(N0) as N0
FROM
inserted
WHERE
inserted.TipoMovimento = 'Carico'
GROUP BY
inserted.cardid ) as a

on a.cardid = CoinlessCards.cardid
where CoinlessCards.N0> a.N0

update CoinlessCards
set DataUltimaPresentazione = a.datamovimento, SaldoUltimaPresentazione = a.saldo
from 
CoinlessCards inner join 
(SELECT
cardid,
Max(DataMovimento) AS datamovimento,
Sum(SaldoCard) AS saldo,
Max(N0) as N0
FROM
inserted
WHERE
inserted.TipoMovimento = 'Scarico'
GROUP BY
inserted.cardid ) as a

on a.cardid = CoinlessCards.cardid
where CoinlessCards.N0> a.N0

-- SELECT top 1 SaldoCard FROM [dbo].[CoinlessTransazioniCards] WHERE cardid = 'd53965aa' ORDER BY DataMovimento DESC

insert into WinMtSqlDB.dbo.TransCard 
(IdCli,CodMac,Data,ValoreOperazione,ValoreFinale,N0) 
SELECT
convert(varchar(16),CoinlessCards.IdContatto),
inserted.CodMac,
inserted.DataMovimento,
dbo.CreditToCurrency(inserted.CostoPartita),
dbo.CreditToCurrency(inserted.SaldoCard),
inserted.N0

FROM inserted inner join CoinlessCards on inserted.cardid = CoinlessCards.cardid

END
GO

ALTER TABLE [dbo].[CoinlessTransazioniCards] ENABLE TRIGGER [aggiornaCard]
GO

