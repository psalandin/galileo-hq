/* =====================================================================
   Galileo HQ — Kit di query 03 su [WinMtSqlDB] (copia locale)
   ---------------------------------------------------------------------
   Q18 e Q19 restituiscono solo forme e conteggi: si possono inviare.
   Q20 è SOLO PER CONTROLLO LOCALE: mostra due righe con un possibile PAN
   in chiaro. Il risultato NON va inviato: serve a te per verificare.
   ===================================================================== */

USE [WinMtSqlDB];
SET NOCOUNT ON;
GO

/* ---------------------------------------------------------------------
   Q18 — Forma degli identificativi di card e cliente
   Le cifre diventano 9 e le lettere A. Serve a capire perché
   TransCard.IdCli non corrisponde a nessuna colonna candidata:
   formato diverso (esadecimale, decimale, ordine dei byte)?
   --------------------------------------------------------------------- */
WITH v AS (
              SELECT 'TransCard.IdCli' AS campo, CONVERT(varchar(50), IdCli) AS x FROM dbo.TransCard
    UNION ALL SELECT 'CoinlessCards.cardid', CONVERT(varchar(50), cardid) FROM dbo.CoinlessCards
    UNION ALL SELECT 'CoinlessTransazioniCards.cardid', CONVERT(varchar(50), cardid) FROM dbo.CoinlessTransazioniCards
    UNION ALL SELECT 'UID_Ammessi.UID', CONVERT(varchar(50), UID) FROM dbo.UID_Ammessi
    UNION ALL SELECT 'Clienti.T0', CONVERT(varchar(50), T0) FROM dbo.Clienti
    UNION ALL SELECT 'Clienti.CodBar', CONVERT(varchar(50), CodBar) FROM dbo.Clienti
    UNION ALL SELECT 'Clienti.IdContatto', CONVERT(varchar(50), IdContatto) FROM dbo.Clienti
    UNION ALL SELECT 'Clienti.IdLong', CONVERT(varchar(50), IdLong) FROM dbo.Clienti
)
SELECT TOP (60) campo,
       TRANSLATE(UPPER(x), '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ', '9999999999AAAAAAAAAAAAAAAAAAAAAAAAAA') AS forma,
       LEN(x) AS lunghezza,
       COUNT_BIG(*) AS righe
FROM v
WHERE x IS NOT NULL
GROUP BY campo, TRANSLATE(UPPER(x), '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ', '9999999999AAAAAAAAAAAAAAAAAAAAAAAAAA'), LEN(x)
ORDER BY campo, righe DESC;
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
