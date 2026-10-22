/* =====================================================================
   Galileo HQ — Kit di query 03 su [WinMtSqlDB] (copia locale)
   ---------------------------------------------------------------------
   Q19 restituisce solo conteggi: si può inviare. (Q18 non serve più ed è stata tolta.)
   Q20 è SOLO PER CONTROLLO LOCALE: mostra due righe con un possibile PAN
   in chiaro. Il risultato NON va inviato: serve a te per verificare.
   ===================================================================== */

USE [WinMtSqlDBNuovo];
SET NOCOUNT ON;
GO

/* ---------------------------------------------------------------------
   Q19 — Ulteriori ipotesi di relazione
   1) TransCard.IdCli come IdContatto scritto in testo
   2) TransCard.CodMac come nome postazione (Setup.MName senza il "|" finale)
   --------------------------------------------------------------------- */
SELECT 'TransCard.IdCli -> Clienti.IdContatto (testo)' AS ipotesi,
       (SELECT COUNT_BIG(*) FROM dbo.TransCard c WHERE c.IdCli IS NOT NULL) AS righe_nonnull,
       (SELECT COUNT_BIG(*) FROM dbo.TransCard c
         WHERE c.IdCli IS NOT NULL
           AND EXISTS (SELECT 1 FROM dbo.Clienti k
                       WHERE CONVERT(varchar(20), k.IdContatto) = LTRIM(RTRIM(c.IdCli)))) AS trovate
UNION ALL
SELECT 'TransCard.IdCli -> CoinlessCards.cardid (maiuscolo, senza spazi)',
       (SELECT COUNT_BIG(*) FROM dbo.TransCard c WHERE c.IdCli IS NOT NULL),
       (SELECT COUNT_BIG(*) FROM dbo.TransCard c
         WHERE c.IdCli IS NOT NULL
           AND EXISTS (SELECT 1 FROM dbo.CoinlessCards k
                       WHERE UPPER(LTRIM(RTRIM(k.cardid))) = UPPER(LTRIM(RTRIM(c.IdCli)))))
UNION ALL
SELECT 'TransCard.CodMac (WinMt=1) -> Setup.MName senza |',
       (SELECT COUNT_BIG(*) FROM dbo.TransCard c WHERE c.WinMt = 1 AND c.CodMac IS NOT NULL),
       (SELECT COUNT_BIG(*) FROM dbo.TransCard c
         WHERE c.WinMt = 1 AND c.CodMac IS NOT NULL
           AND EXISTS (SELECT 1 FROM dbo.Setup s
                       WHERE REPLACE(s.MName, '|', '') = c.CodMac));
GO

/* ---------------------------------------------------------------------
   Q20 — SOLO CONTROLLO LOCALE, NON INVIARE IL RISULTATO
   Righe di LogTransazioniTotem in cui la colonna PAN contiene 16 o più
   cifre consecutive (possibile PAN in chiaro). In Q14 sono 2 righe:
   forma "***9999999999999999" e forma "AAA): 9999...".
   --------------------------------------------------------------------- */
SELECT id, data, idpost, MName, tipo, PAN
FROM dbo.LogTransazioniTotem
WHERE PAN LIKE '%[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]%';
GO
