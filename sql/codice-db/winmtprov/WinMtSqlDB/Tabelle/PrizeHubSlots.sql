SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- Giacenze fisiche per slot di ogni PrizeHub.
-- Una riga per (hubId, tipo, unit, slot, codArticolo).
-- CAPSULE/LOCKER: in genere una riga per slot; unit=1 se c'è un solo container.
-- SPINDLE: N righe per slot per unit (una per articolo caricato).
--          Due SPINDLE fisici → unit=1 e unit=2 con gli stessi slot B1-B14.
--
-- Premio fittizio SPINDLE: Codice = SPINDLE{unit}-{slot}  (es. SPINDLE1-B3, SPINDLE2-B3)
-- I premi fittizi sono marcati con Attivo=0 in dbo.Premi.
--
-- ============================================================
-- Upgrade (se la tabella esiste già senza la colonna [unit]):
--
--   ALTER TABLE dbo.PrizeHubSlots
--       ADD [unit] INT NOT NULL CONSTRAINT DF_PrizeHubSlots_unit DEFAULT 1;
--
--   ALTER TABLE dbo.PrizeHubSlots DROP CONSTRAINT uq_hub_slot_art;
--   ALTER TABLE dbo.PrizeHubSlots ADD CONSTRAINT uq_hub_slot_art
--       UNIQUE (hubId, tipo, unit, slot, codArticolo);
--
--   DROP INDEX IF EXISTS IX_PrizeHubSlots_hub_slot ON dbo.PrizeHubSlots;
--   DROP INDEX IF EXISTS IX_PrizeHubSlots_hub_cod  ON dbo.PrizeHubSlots;
--   (ricreare gli indici con lo script sottostante)
-- ============================================================

CREATE TABLE [dbo].[PrizeHubSlots] (
    [id]                  INT           IDENTITY(1,1)   NOT NULL,
    [hubId]               INT           NOT NULL,
    [tipo]                NVARCHAR(20)  NOT NULL,        -- CAPSULE | SPINDLE | LOCKER
    [unit]                INT           NOT NULL  DEFAULT 1,  -- numero container (1 o 2)
    [slot]                NVARCHAR(10)  NOT NULL,        -- es. 'A3', 'B7', 'C2'
    [codArticolo]         NVARCHAR(50)  NOT NULL,        -- FK logica verso dbo.Premi.Codice
    [qtaDisp]             INT           NOT NULL  DEFAULT 0,
    [ticketsMedi]         INT           NULL,            -- media ponderata (solo SPINDLE)
    [ticketsMediaForzata] BIT           NOT NULL  DEFAULT 0,
    [attivo]              BIT           NOT NULL  DEFAULT 1,
    [updatedAt]           DATETIME2     NULL,
    [updatedBy]           NVARCHAR(50)  NULL,
    CONSTRAINT [PK_PrizeHubSlots] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [uq_hub_slot_art]  UNIQUE ([hubId], [tipo], [unit], [slot], [codArticolo])
)
GO

-- Indice per le query più frequenti (per hubId + unit + slot)
CREATE NONCLUSTERED INDEX [IX_PrizeHubSlots_hub_slot]
    ON [dbo].[PrizeHubSlots] ([hubId] ASC, [unit] ASC, [slot] ASC)
    INCLUDE ([tipo], [codArticolo], [qtaDisp], [attivo])
GO

-- Indice per la ricerca per articolo (usato in getPrizesForHub CAPSULE/LOCKER)
CREATE NONCLUSTERED INDEX [IX_PrizeHubSlots_hub_cod]
    ON [dbo].[PrizeHubSlots] ([hubId] ASC, [unit] ASC, [codArticolo] ASC)
    INCLUDE ([slot], [tipo], [qtaDisp], [attivo])
GO
