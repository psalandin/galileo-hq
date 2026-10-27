SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CoinlessDecodedData](
	[device] [varchar](10) NOT NULL,
	[datastore] [datetime2](7) NOT NULL,
	[Header ] [int] NULL,
	[risposta] [int] NULL,
	[cmd_inviato] [int] NULL,
	[numbyte] [int] NULL,
	[dataril] [datetime] NULL,
	[crediti] [bigint] NULL,
	[tickets] [bigint] NULL,
	[cnt3] [bigint] NULL,
	[cnt4] [bigint] NULL,
	[cnt5] [bigint] NULL,
	[cnt6] [bigint] NULL,
	[cnt7] [bigint] NULL,
	[cnt8] [bigint] NULL,
	[gettoni] [bigint] NULL,
	[tipocard] [int] NULL,
	[datarec] [datetime] NULL,
	[partite] [bigint] NULL,
	[carduid] [int] NULL,
	[saldocard] [bigint] NULL,
	[id] [bigint] IDENTITY(1,1) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CoinlessDecodedData] ADD  DEFAULT (getdate()) FOR [datarec]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
select @bonustickets = (select isnull((select CntrLet15 from dbo.EcsMacchine where device = @device ),0))
declare @codmac varchar(15) 
select @codmac = (select isnull((select codmac from dbo.EcsMacchine where device = @device ),''))

INSERT INTO dbo.EcsDati( CodMac,DataRil,In1,In2,In3,In4,In5,In6,In7,In8,In9,NImp,In16,In15)
SELECT
		b.CodMac
      , a.[dataril]
      , a.[gettoni]
      , a.[tickets]
      , a.[cnt3]
      , a.[cnt4]
      , case 
		when @bonustickets=0 then  a.[cnt5] 
      		else  a.[cnt5] + isnull(( select max(In15) from dbo.EcsDati b where b.codmac = @codmac  ),0)
	end
      , a.[cnt6]
      , a.[cnt7]
      , a.[cnt8]
      ,a.[partite]
	  ,1
	  , 0
      ,(select max(In15) from dbo.EcsDati b where b.codmac = @codmac  )
  FROM INSERTED as a
  inner join [dbo].[EcsMacchine] as b on b.device = a.device
  where a.[cmd_inviato] = 7



END
GO
ALTER TABLE [dbo].[CoinlessDecodedData] ENABLE TRIGGER [inseriscesuECS]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[insertrecordWINMT]
ON [dbo].[CoinlessDecodedData]
INSTEAD OF INSERT
AS
BEGIN
-- giochi mobile kiddy mi incrementano solo le partite e le monete 
-- sono movimenti che mi arrivano dalle bi/be quindi non sanno niente dei bonus che getisco tramite la CntrLet15 
declare @device varchar(30)
select @device = ( select top 1 device from INSERTED )
declare @bonustickets bigint
select @bonustickets = (select isnull((select CntrLet15 from dbo.EcsMacchine where device = @device ),0))
declare @codmac varchar(15) 
select @codmac = (select isnull((select codmac from dbo.EcsMacchine where device = @device ),''))

declare @ultimocrc varchar(100)
declare @ultimadatacrc date
SELECT top 1
@ultimocrc = isnull(concat(
RIGHT('000000000'+CONVERT(VARCHAR(9),isnull(dbo.CoinlessDecodedData.crediti,0)),9),
RIGHT('000000000'+CONVERT(VARCHAR(9),dbo.CoinlessDecodedData.tickets),9),
RIGHT('000000000'+CONVERT(VARCHAR(9),dbo.CoinlessDecodedData.cnt3),9),
RIGHT('000000000'+CONVERT(VARCHAR(9),dbo.CoinlessDecodedData.cnt4),9),
RIGHT('000000000'+CONVERT(VARCHAR(9),dbo.CoinlessDecodedData.cnt5),9),
RIGHT('000000000'+CONVERT(VARCHAR(9),dbo.CoinlessDecodedData.cnt6),9),
RIGHT('000000000'+CONVERT(VARCHAR(9),dbo.CoinlessDecodedData.cnt7),9),
RIGHT('000000000'+CONVERT(VARCHAR(9),dbo.CoinlessDecodedData.cnt8),9),
RIGHT('000000000'+CONVERT(VARCHAR(9),dbo.CoinlessDecodedData.gettoni),9),
RIGHT('000000000'+CONVERT(VARCHAR(9),dbo.CoinlessDecodedData.partite),9)),''),
@ultimadatacrc = isnull(convert(date,dbo.CoinlessDecodedData.datastore ),getdate())
FROM [dbo].[CoinlessDecodedData]
WHERE
device = @device
ORDER BY
id DESC

insert into [dbo].[debug_log] select '['+@device+']['+ convert(varchar(10),@ultimadatacrc) +']  '+@ultimocrc 
insert into [dbo].[debug_log] select  '------------------'
insert into [dbo].[debug_log] select  concat( '[', a.device,'][', convert(varchar(10),convert(date,a.datastore )) ,']  ',
RIGHT('000000000'+CONVERT(VARCHAR(9),isnull(a.crediti,0)),9),
RIGHT('000000000'+CONVERT(VARCHAR(9),a.tickets),9),
RIGHT('000000000'+CONVERT(VARCHAR(9),a.cnt3),9),
RIGHT('000000000'+CONVERT(VARCHAR(9),a.cnt4),9),
RIGHT('000000000'+CONVERT(VARCHAR(9),a.cnt5),9),
RIGHT('000000000'+CONVERT(VARCHAR(9),a.cnt6),9),
RIGHT('000000000'+CONVERT(VARCHAR(9),a.cnt7),9),
RIGHT('000000000'+CONVERT(VARCHAR(9),a.cnt8),9),
RIGHT('000000000'+CONVERT(VARCHAR(9),a.gettoni),9),
RIGHT('000000000'+CONVERT(VARCHAR(9),a.partite),9))  from INSERTED as a

insert into [dbo].[debug_log] select  'ultimo crc'
  FROM INSERTED as a
  inner join [dbo].[EcsMacchine] as b on b.device = a.device
  where a.[cmd_inviato] = 7
  and 
concat(
RIGHT('000000000'+CONVERT(VARCHAR(9),isnull(a.crediti,0)),9),
RIGHT('000000000'+CONVERT(VARCHAR(9),a.tickets),9),
RIGHT('000000000'+CONVERT(VARCHAR(9),a.cnt3),9),
RIGHT('000000000'+CONVERT(VARCHAR(9),a.cnt4),9),
RIGHT('000000000'+CONVERT(VARCHAR(9),a.cnt5),9),
RIGHT('000000000'+CONVERT(VARCHAR(9),a.cnt6),9),
RIGHT('000000000'+CONVERT(VARCHAR(9),a.cnt7),9),
RIGHT('000000000'+CONVERT(VARCHAR(9),a.cnt8),9),
RIGHT('000000000'+CONVERT(VARCHAR(9),a.gettoni),9),
RIGHT('000000000'+CONVERT(VARCHAR(9),a.partite),9)) != @ultimocrc 


insert into [dbo].[debug_log] select  'ultima data'
  FROM INSERTED as a
  inner join [dbo].[EcsMacchine] as b on b.device = a.device
  where a.[cmd_inviato] = 7
  and 
 @ultimadatacrc != convert(date,a.datastore )


INSERT INTO dbo.EcsDati( CodMac,DataRil,In1,In2,In3,In4,In5,In6,In7,In8,In9,NImp,In16,In15)
SELECT
		b.CodMac
      , a.[dataril]
      , a.[gettoni]
      , a.[tickets]
      , a.[cnt3]
      , a.[cnt4]
      , case 
		when @bonustickets=0 then  a.[cnt5] 
      		else  a.[cnt5] + ( select max(In15) from dbo.EcsDati b where b.codmac = @codmac  )
	end
      , a.[cnt6]
      , a.[cnt7]
      , a.[cnt8]
      ,a.[partite]
	  ,1
	  , 0
      ,(select max(In15) from dbo.EcsDati b where b.codmac = @codmac  )
  FROM INSERTED as a
  inner join [dbo].[EcsMacchine] as b on b.device = a.device
  where a.[cmd_inviato] = 7
  and (
concat(
RIGHT('000000000'+CONVERT(VARCHAR(9),isnull(a.crediti,0)),9),
RIGHT('000000000'+CONVERT(VARCHAR(9),a.tickets),9),
RIGHT('000000000'+CONVERT(VARCHAR(9),a.cnt3),9),
RIGHT('000000000'+CONVERT(VARCHAR(9),a.cnt4),9),
RIGHT('000000000'+CONVERT(VARCHAR(9),a.cnt5),9),
RIGHT('000000000'+CONVERT(VARCHAR(9),a.cnt6),9),
RIGHT('000000000'+CONVERT(VARCHAR(9),a.cnt7),9),
RIGHT('000000000'+CONVERT(VARCHAR(9),a.cnt8),9),
RIGHT('000000000'+CONVERT(VARCHAR(9),a.gettoni),9),
RIGHT('000000000'+CONVERT(VARCHAR(9),a.partite),9)) != @ultimocrc or @ultimadatacrc = convert(date,a.datastore ))


insert into CoinlessDecodedData (device,datastore,[Header ],risposta,cmd_inviato,numbyte,dataril,crediti,tickets,cnt3,cnt4,cnt5,cnt6,cnt7,cnt8,gettoni,tipocard,datarec,partite,carduid,saldocard)
select INSERTED.device,
INSERTED.datastore,
INSERTED.[Header ],
INSERTED.risposta,
INSERTED.cmd_inviato,
INSERTED.numbyte,
INSERTED.dataril,
INSERTED.crediti,
INSERTED.tickets,
INSERTED.cnt3,
INSERTED.cnt4,
INSERTED.cnt5,
INSERTED.cnt6,
INSERTED.cnt7,
INSERTED.cnt8,
INSERTED.gettoni,
INSERTED.tipocard,
INSERTED.datarec,
INSERTED.partite,
INSERTED.carduid,
INSERTED.saldocard

FROM INSERTED

END
GO
ALTER TABLE [dbo].[CoinlessDecodedData] DISABLE TRIGGER [insertrecordWINMT]
GO
