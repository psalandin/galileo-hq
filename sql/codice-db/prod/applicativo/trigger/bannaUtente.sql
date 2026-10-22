CREATE TRIGGER [dbo].[bannaUtente]
ON [dbo].[CoinlessClonedCards]
AFTER INSERT
AS
BEGIN

UPDATE C set
 F1 = 1,
 T1 = inserted.CodMac+'|costo partita:'+convert(varchar(20),inserted.CostoPartita)+'|saldo card:'+convert(varchar(20),inserted.SaldoCard)+'|id clonate:'+convert(varchar(20),inserted.id_card_clonate),
 D1 = getdate()
FROM  dbo.Clienti  C
inner join inserted on C.T0 = inserted.cardid+'00000000'
END
