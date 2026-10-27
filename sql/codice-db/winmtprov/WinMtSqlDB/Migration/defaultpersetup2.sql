IF NOT EXISTS (SELECT 1 FROM dbo.setup2)
BEGIN
	insert into [setup2] (IdPost,Chiave,Valore) values 
	(101,'2NdScreenVersion',''),
	(101,'flagDropTicketsForGold','false'),
	(101,'PosTcpConfig','{"ip":"192.168.169.50","port":"54321"}'),
	(101,'RitiroCard','disabled'),
	(101,'BirthdayDefaultHours','4'),
	(101,'BirthdayLimitHours','24'),
	(101,'VipSubscriptionParams','{"enabled":0,"model":"FidelizzazioneDatiPersonali","amount":0,"expirydate":"","subscriptiondurationmonths":0,"activationdate":""}'),
	(101,'AvailablePosDevices','[{"key":0,"value":"Nayax VPOS"},{"key":1,"value":"Ingenico IUP250"},{"key":2,"value":"PAX IM20"},{"key":3,"value":"PAX Q30"},{"key":4,"value":"NayaxSaturn1000"},{"key":5,"value":"NayaxVPOSTouchPosHandler"},{"key":6,"value":"NayaxNovaC4_8080"},{"key":7,"value":"NayaxNovaC4"}
	]')
END
GO