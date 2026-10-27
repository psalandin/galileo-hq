SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

			        CREATE VIEW vs_CoinlessSpecialTimes AS
			        SELECT
			            dbo.CoinlessTestataHappyHour.ampm,
			            dbo.CoinlessTestataHappyHour.dalle,
			            dbo.CoinlessTestataHappyHour.alle,
			            dbo.CoinlessMacchineHappyHour.codmac,
			            dbo.EcsMacchine.NomMac,
			            dbo.EcsMacchine.device,
			            CONVERT(int, dbo.CoinlessMacchineHappyHour.perc_platinum) AS perc_platinum,
			            CONVERT(int, dbo.CoinlessMacchineHappyHour.perc_gold) AS perc_gold,
			            CONVERT(int, dbo.CoinlessMacchineHappyHour.perc_silver) AS perc_silver,
			            CONVERT(int, dbo.CoinlessMacchineHappyHour.perc_normal) AS perc_normal,
			            EcsMacchine.valpar * 100 AS coinval,
			            CASE 
			                WHEN CONVERT(varchar(5), GETDATE(), 114) >= dbo.CoinlessTestataHappyHour.dalle 
			                     AND CONVERT(varchar(5), GETDATE(), 114) <= dbo.CoinlessTestataHappyHour.alle 
			                THEN 1 
			                ELSE 0 
			            END AS happyhour,
			            dbo.EcsMacchine.is_happyhour,
			            dbo.EcsMacchine.is_timeplay,
			            dbo.EcsMacchine.is_online,
			            dbo.CoinlessTestataHappyHour.giorno,
			            dbo.CoinlessTestataHappyHour.t0 AS nometemplate
			        FROM
			            dbo.CoinlessTestataHappyHour
			            INNER JOIN dbo.CoinlessMacchineHappyHour 
			                ON dbo.CoinlessTestataHappyHour.id_happyhour = dbo.CoinlessMacchineHappyHour.fk_testata
			            INNER JOIN dbo.EcsMacchine 
			                ON dbo.CoinlessMacchineHappyHour.codmac = dbo.EcsMacchine.CodMac
			        WHERE
			            CONVERT(date, dbo.CoinlessTestataHappyHour.dal) <= CONVERT(date, GETDATE()) 
			            AND CONVERT(date, dbo.CoinlessTestataHappyHour.al) >= CONVERT(date, GETDATE()) 
			            AND CASE 
			                    WHEN dbo.CoinlessTestataHappyHour.giorno = -1 
			                    THEN DATEPART(dw, GETDATE()) 
			                    ELSE dbo.CoinlessTestataHappyHour.giorno 
			                END = DATEPART(dw, GETDATE()) 
			            AND dbo.CoinlessTestataHappyHour.attivo <> 0
GO


