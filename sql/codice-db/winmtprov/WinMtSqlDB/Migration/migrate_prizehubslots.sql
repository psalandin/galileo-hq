SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET NOCOUNT ON;
GO

-- ============================================================
-- Migration: Premi (PDis/QDis) → PrizeHubSlots (v2, con unit)
-- ============================================================
-- Legge le assegnazioni slot legacy da dbo.Premi (colonne PDis1-PDis8 /
-- QDis1-QDis8) e popola dbo.PrizeHubSlots (tabella v2 Flutter).
--
-- Prerequisiti:
--   - PrizeHubSlots.sql (con colonna unit) già eseguito su questo DB.
--   - SQL Server 2016+ (STRING_SPLIT).
--
-- Logica tipo slot (coerente con SlotToType in DBwinmt.bas):
--   A* → CAPSULE   B* → SPINDLE   C* → LOCKER
--
-- Distribuzione quantità:
--   QDis{N} è la quantità totale del hub; viene divisa equamente
--   tra gli slot dell'articolo; il resto (+1) va al primo slot
--   (ordine alfabetico). LOCKER: capped a 1 per definizione.
--
-- Dati legacy (PDis1-8):
--   Tutta la giacenza legacy appartiene a unit=1 (non esisteva
--   il concetto di multi-unit nei dati storici).
--
-- Premio fittizio SPINDLE: codice = SPINDLE{unit}-{slot}
--   es. SPINDLE1-B3 (unit 1)  SPINDLE2-B3 (unit 2)
--   Marcati con Attivo=0 in dbo.Premi.
--
-- Esclusi da Step 2:
--   - Premi con Codice LIKE 'SPINDLE[0-9]-%'  (fittizi, già gestiti in Step 3)
--   - Premi con CodOr = '?_?_PH?'             (magazzino virtuale legacy)
--   - Slot non validi (non corrispondono a [ABC][0-9]%)
--
-- Idempotente: usa MERGE su (hubId, tipo, unit, slot, codArticolo).
-- ============================================================

DECLARE @rowsSlot   INT = 0;
DECLARE @rowsFit    INT = 0;
DECLARE @rowsRenam  INT = 0;
DECLARE @rowsFix    INT = 0;
DECLARE @msg        NVARCHAR(2000);

BEGIN TRY

    BEGIN TRANSACTION;

    -- -------------------------------------------------------
    -- Step 0: rinomina premi fittizi SPINDLE-{slot} → SPINDLE1-{slot}
    --         (idempotente: WHERE esclude già migrati)
    -- -------------------------------------------------------
    UPDATE dbo.Premi
    SET Codice = REPLACE(Codice, 'SPINDLE-', 'SPINDLE1-'),
        CodOr  = REPLACE(CodOr,  'SPINDLE-', 'SPINDLE1-')
    WHERE Codice LIKE 'SPINDLE-[A-Z][0-9]%';

    SET @rowsRenam = @@ROWCOUNT;
    PRINT 'Step 0 OK: ' + CAST(@rowsRenam AS NVARCHAR(10)) + ' premi fittizi rinominati SPINDLE- → SPINDLE1-.';

    -- -------------------------------------------------------
    -- Step 1: imposta Attivo=0 su tutti i premi fittizi SPINDLE
    -- -------------------------------------------------------
    UPDATE dbo.Premi SET Attivo = 0
    WHERE Codice LIKE 'SPINDLE[0-9]-%';

    SET @rowsFix = @@ROWCOUNT;
    PRINT 'Step 1 OK: ' + CAST(@rowsFix AS NVARCHAR(10)) + ' premi fittizi impostati Attivo=0.';

    -- -------------------------------------------------------
    -- Step 2: popola PrizeHubSlots da PDis1-8 / QDis1-8
    --         Tutto il dato legacy ha unit=1
    -- -------------------------------------------------------
    ;WITH AllHubs AS (

        SELECT 1 AS hubId, 1 AS unit, p.Codice, p.QDis1 AS qtaTotale, ISNULL(CAST(p.N_Tickets AS INT), 0) AS N_Tickets,
               UPPER(LTRIM(RTRIM(s.value))) AS slot
        FROM dbo.Premi p
        CROSS APPLY STRING_SPLIT(REPLACE(ISNULL(p.PDis1, ''), ' ', ''), ',') s
        WHERE ISNULL(p.PDis1, '') <> ''
          AND p.Codice NOT LIKE 'SPINDLE[0-9]-%'
          AND p.CodOr <> '?_?_PH?'
          AND UPPER(LTRIM(RTRIM(s.value))) LIKE '[ABC][0-9]%'

        UNION ALL

        SELECT 2, 1, p.Codice, p.QDis2, ISNULL(CAST(p.N_Tickets AS INT), 0),
               UPPER(LTRIM(RTRIM(s.value)))
        FROM dbo.Premi p
        CROSS APPLY STRING_SPLIT(REPLACE(ISNULL(p.PDis2, ''), ' ', ''), ',') s
        WHERE ISNULL(p.PDis2, '') <> ''
          AND p.Codice NOT LIKE 'SPINDLE[0-9]-%'
          AND p.CodOr <> '?_?_PH?'
          AND UPPER(LTRIM(RTRIM(s.value))) LIKE '[ABC][0-9]%'

        UNION ALL

        SELECT 3, 1, p.Codice, p.QDis3, ISNULL(CAST(p.N_Tickets AS INT), 0),
               UPPER(LTRIM(RTRIM(s.value)))
        FROM dbo.Premi p
        CROSS APPLY STRING_SPLIT(REPLACE(ISNULL(p.PDis3, ''), ' ', ''), ',') s
        WHERE ISNULL(p.PDis3, '') <> ''
          AND p.Codice NOT LIKE 'SPINDLE[0-9]-%'
          AND p.CodOr <> '?_?_PH?'
          AND UPPER(LTRIM(RTRIM(s.value))) LIKE '[ABC][0-9]%'

        UNION ALL

        SELECT 4, 1, p.Codice, p.QDis4, ISNULL(CAST(p.N_Tickets AS INT), 0),
               UPPER(LTRIM(RTRIM(s.value)))
        FROM dbo.Premi p
        CROSS APPLY STRING_SPLIT(REPLACE(ISNULL(p.PDis4, ''), ' ', ''), ',') s
        WHERE ISNULL(p.PDis4, '') <> ''
          AND p.Codice NOT LIKE 'SPINDLE[0-9]-%'
          AND p.CodOr <> '?_?_PH?'
          AND UPPER(LTRIM(RTRIM(s.value))) LIKE '[ABC][0-9]%'

        UNION ALL

        SELECT 5, 1, p.Codice, p.QDis5, ISNULL(CAST(p.N_Tickets AS INT), 0),
               UPPER(LTRIM(RTRIM(s.value)))
        FROM dbo.Premi p
        CROSS APPLY STRING_SPLIT(REPLACE(ISNULL(p.PDis5, ''), ' ', ''), ',') s
        WHERE ISNULL(p.PDis5, '') <> ''
          AND p.Codice NOT LIKE 'SPINDLE[0-9]-%'
          AND p.CodOr <> '?_?_PH?'
          AND UPPER(LTRIM(RTRIM(s.value))) LIKE '[ABC][0-9]%'

        UNION ALL

        SELECT 6, 1, p.Codice, p.QDis6, ISNULL(CAST(p.N_Tickets AS INT), 0),
               UPPER(LTRIM(RTRIM(s.value)))
        FROM dbo.Premi p
        CROSS APPLY STRING_SPLIT(REPLACE(ISNULL(p.PDis6, ''), ' ', ''), ',') s
        WHERE ISNULL(p.PDis6, '') <> ''
          AND p.Codice NOT LIKE 'SPINDLE[0-9]-%'
          AND p.CodOr <> '?_?_PH?'
          AND UPPER(LTRIM(RTRIM(s.value))) LIKE '[ABC][0-9]%'

        UNION ALL

        SELECT 7, 1, p.Codice, p.QDis7, ISNULL(CAST(p.N_Tickets AS INT), 0),
               UPPER(LTRIM(RTRIM(s.value)))
        FROM dbo.Premi p
        CROSS APPLY STRING_SPLIT(REPLACE(ISNULL(p.PDis7, ''), ' ', ''), ',') s
        WHERE ISNULL(p.PDis7, '') <> ''
          AND p.Codice NOT LIKE 'SPINDLE[0-9]-%'
          AND p.CodOr <> '?_?_PH?'
          AND UPPER(LTRIM(RTRIM(s.value))) LIKE '[ABC][0-9]%'

        UNION ALL

        SELECT 8, 1, p.Codice, p.QDis8, ISNULL(CAST(p.N_Tickets AS INT), 0),
               UPPER(LTRIM(RTRIM(s.value)))
        FROM dbo.Premi p
        CROSS APPLY STRING_SPLIT(REPLACE(ISNULL(p.PDis8, ''), ' ', ''), ',') s
        WHERE ISNULL(p.PDis8, '') <> ''
          AND p.Codice NOT LIKE 'SPINDLE[0-9]-%'
          AND p.CodOr <> '?_?_PH?'
          AND UPPER(LTRIM(RTRIM(s.value))) LIKE '[ABC][0-9]%'

    ),
    Ranked AS (
        SELECT
            hubId,
            unit,
            Codice          AS codArticolo,
            slot,
            qtaTotale,
            N_Tickets,
            tipo            = CASE LEFT(slot, 1)
                                  WHEN 'A' THEN 'CAPSULE'
                                  WHEN 'B' THEN 'SPINDLE'
                                  WHEN 'C' THEN 'LOCKER'
                                  ELSE          'CAPSULE'
                              END,
            nSlots          = COUNT(*) OVER (PARTITION BY hubId, unit, Codice),
            slotRank        = ROW_NUMBER() OVER (PARTITION BY hubId, unit, Codice ORDER BY slot)
        FROM AllHubs
    ),
    WithQty AS (
        SELECT
            hubId,
            unit,
            codArticolo,
            slot,
            tipo,
            qtaDisp         = CASE tipo
                                  WHEN 'LOCKER'
                                      THEN CASE WHEN qtaTotale > 0 THEN 1 ELSE 0 END
                                  ELSE
                                      ISNULL(qtaTotale / NULLIF(nSlots, 0), 0)
                                      + CASE slotRank
                                            WHEN 1 THEN ISNULL(qtaTotale % NULLIF(nSlots, 0), 0)
                                            ELSE 0
                                        END
                              END,
            ticketsMedi     = CASE tipo WHEN 'SPINDLE' THEN N_Tickets ELSE NULL END
        FROM Ranked
    )
    MERGE dbo.PrizeHubSlots AS tgt
    USING WithQty AS src
       ON  tgt.hubId       = src.hubId
      AND  tgt.unit        = src.unit
      AND  tgt.slot        = src.slot
      AND  tgt.tipo        = src.tipo
      AND  tgt.codArticolo = src.codArticolo
    WHEN MATCHED THEN
        UPDATE SET
            qtaDisp     = src.qtaDisp,
            ticketsMedi = src.ticketsMedi,
            updatedAt   = GETDATE(),
            updatedBy   = N'MIGRATION_V2'
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (hubId, unit, slot, tipo, codArticolo, qtaDisp, ticketsMedi, updatedAt, updatedBy)
        VALUES (src.hubId, src.unit, src.slot, src.tipo, src.codArticolo,
                src.qtaDisp, src.ticketsMedi, GETDATE(), N'MIGRATION_V2');

    SET @rowsSlot = @@ROWCOUNT;
    PRINT 'Step 2 OK: ' + CAST(@rowsSlot AS NVARCHAR(10)) + ' righe MERGE in PrizeHubSlots.';

    -- -------------------------------------------------------
    -- Step 3: crea premi fittizi SPINDLE{unit}-{slot} mancanti
    -- -------------------------------------------------------
    -- Per ogni (unit, slot) SPINDLE in PrizeHubSlots che non ha ancora
    -- un record 'SPINDLE{unit}-{slot}' in Premi, crea il premio fittizio.
    -- Prende Descrizione e Foto dall'articolo con qtaDisp maggiore.
    -- Coerente con HubAggiornaPremioFittizio in DBwinmt.bas.
    -- -------------------------------------------------------
    ;WITH BestArticle AS (
        SELECT
            phs.unit,
            phs.slot,
            phs.ticketsMedi,
            phs.codArticolo,
            rn = ROW_NUMBER() OVER (
                     PARTITION BY phs.unit, phs.slot
                     ORDER BY phs.qtaDisp DESC, phs.codArticolo
                 )
        FROM dbo.PrizeHubSlots phs
        WHERE phs.tipo   = 'SPINDLE'
          AND phs.attivo = 1
          AND phs.qtaDisp > 0
    )
    INSERT INTO dbo.Premi
        (Codice, CodOr, Descrizione, N_Tickets, Quantita, Costo, Fornitore, Foto, Attivo,
         QDis1,QDis2,QDis3,QDis4,QDis5,QDis6,QDis7,QDis8, Locked, Prenotabile, F0, F1)
    SELECT
        CONCAT('SPINDLE', ba.unit, '-', ba.slot),
        CONCAT('SPINDLE', ba.unit, '-', ba.slot),
        N'SPINDLE' + CAST(ba.unit AS NVARCHAR(2)) + N' ' + ba.slot + N' - ' + ISNULL(p.Descrizione, ba.codArticolo),
        COALESCE(ba.ticketsMedi, CAST(p.N_Tickets AS INT), 0),
        0, 0, N'ELMAC',
        p.Foto,
        0,  -- Attivo=0 → premio fittizio
        0,0,0,0,0,0,0,0, 0, 0, 0, 0  -- Prenotabile=0 → fittizio
    FROM BestArticle ba
    LEFT JOIN dbo.Premi p ON p.Codice = ba.codArticolo
    WHERE ba.rn = 1
      AND NOT EXISTS (
              SELECT 1 FROM dbo.Premi
              WHERE Codice = CONCAT('SPINDLE', ba.unit, '-', ba.slot)
          );

    SET @rowsFit = @@ROWCOUNT;
    PRINT 'Step 3 OK: ' + CAST(@rowsFit AS NVARCHAR(10)) + ' premi fittizi SPINDLE{unit}-{slot} creati.';

    COMMIT TRANSACTION;
    PRINT '=== Migrazione PrizeHubSlots completata.'
          + '  Slot: '      + CAST(@rowsSlot  AS NVARCHAR(10))
          + '  Rinominati: '+ CAST(@rowsRenam AS NVARCHAR(10))
          + '  Fittizi: '   + CAST(@rowsFit   AS NVARCHAR(10)) + ' ===';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    SET @msg = ERROR_MESSAGE();
    PRINT 'ERRORE — rollback eseguito: ' + @msg;
    RAISERROR (@msg, 16, 1);
END CATCH
GO
