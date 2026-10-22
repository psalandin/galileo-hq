CREATE TRIGGER [dbo].[inseriscesuECS]
ON [dbo].[CoinlessDecodedData]
WITH EXECUTE AS CALLER
AFTER INSERT
AS
BEGIN
declare @device varchar(30)
select @device = ( select top 1 device from INSERTED )
declare @bonustickets bigint = (select isnull((select CntrLet15 from dbo.EcsMacchine where device = @device ),0))
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
      ,isnull((select max(In15) from dbo.EcsDati b where b.codmac = @codmac  ),0)
  FROM INSERTED as a
  inner join [dbo].[EcsMacchine] as b on b.device = a.device
  where a.[cmd_inviato] = 7



END
