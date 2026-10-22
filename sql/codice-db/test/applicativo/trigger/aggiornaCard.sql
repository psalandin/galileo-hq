CREATE TRIGGER [dbo].[aggiornaCard]
ON [dbo].[CoinlessTransazioniCards]
AFTER INSERT
AS
BEGIN
  -- type your statements here


insert into dbo.TransCard 
(IdCli,CodMac,Data,ValoreOperazione,ValoreFinale,N0,ValoreBonus,FlagOpDaVerificare) 
SELECT
convert(varchar(16),clienti.IdContatto),
inserted.CodMac,
inserted.DataMovimento,
dbo.CreditToCurrency(inserted.CostoPartita),
dbo.CreditToCurrency(inserted.SaldoCard),
inserted.N0,
dbo.CreditToCurrency(inserted.Bonus),
inserted.FlagOpDaVerificare
FROM inserted inner join clienti on inserted.cardid = substring(clienti.t0,1,8)

END
