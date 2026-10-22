CREATE   PROCEDURE dbo.PrizeHub_MoveToSlot
    @HubId         int,
    @SlotCode      nvarchar(10),
    @SourceCodice  nvarchar(50),
    @Qty           int
AS
BEGIN
    SET NOCOUNT ON;

    IF @Qty IS NULL OR @Qty <= 0
    BEGIN
        RAISERROR('Quantità non valida.', 16, 1);
        RETURN;
    END

    -- Normalizza slot
    SET @SlotCode = UPPER(REPLACE(LTRIM(RTRIM(@SlotCode)), ' ', ''));

    DECLARE @Type nvarchar(20);
    SET @Type =
        CASE
            WHEN @SlotCode LIKE 'A%' THEN N'CAPSULE'
            WHEN @SlotCode LIKE 'B%' THEN N'SPINDLE'
            WHEN @SlotCode LIKE 'C%' THEN N'LOCKER'
            ELSE NULL
        END;

    IF @Type IS NULL
    BEGIN
        RAISERROR('Slot non valido: deve iniziare per A/B/C.', 16, 1);
        RETURN;
    END

    DECLARE @TargetCodice nvarchar(100) = CONCAT(@SlotCode, '_', @Type, '_PH', @HubId);

    BEGIN TRY
        BEGIN TRAN;

        -- 1) Verifica esistenza articolo sorgente
        IF NOT EXISTS (SELECT 1 FROM dbo.Premi WITH (UPDLOCK, HOLDLOCK) WHERE Codice = @SourceCodice)
        BEGIN
            RAISERROR('Codice sorgente non trovato in Premi.', 16, 1);
        END

        -- 2) Se non esiste il target (slot virtuale), inseriscilo con valori base
        IF NOT EXISTS (SELECT 1 FROM dbo.Premi WITH (UPDLOCK, HOLDLOCK) WHERE Codice = @TargetCodice)
        BEGIN
            INSERT INTO dbo.Premi (Codice, Descrizione, Quantita, PDis1, QDis1,costo,n_tickets,fornitore,riserva,CodOr)
            VALUES (
                @TargetCodice,
                CONCAT(LOWER(@Type), ' posizione ', @SlotCode, ' prizehub ', @HubId),
                0,
                @SlotCode,
                0,
				0.1,
				100,
				'ELMAC',
				0,
				@TargetCodice
            );
        END

        /* 3) Movimenti di magazzino
           Adatta i nomi delle colonne se nel tuo schema sono diversi:
           - DataMov (datetime), Causale (nvarchar), Codice (nvarchar), Qta (int),
             Note (nvarchar), Riferimento (nvarchar), HubId (int), Slot (nvarchar)
        */
        INSERT INTO dbo.MOVOUT (Data, motivo, Codice, quantita, Note, Nbolla, Nordine, T0)
        VALUES (GETDATE(), N'PRIZEHUB', @SourceCodice, @Qty,
                CONCAT(N'Trasferimento verso ', @TargetCodice), CONCAT(N'MANU_',@SlotCode), '', @TargetCodice);

        INSERT INTO dbo.MOVMAG (Data, motivo, Codice, quantita, Note, Nbolla, Nordine, T0)
        VALUES (GETDATE(), N'PRIZEHUB', @TargetCodice, @Qty,
                CONCAT(N'Carico da ', @SourceCodice), CONCAT(N'MANU_',@SlotCode), '', @SourceCodice);

        -- 4) Aggiornamento quantità (sorgente - , target +)
        UPDATE dbo.Premi
        SET Quantita = ISNULL(Quantita, 0) - @Qty
        WHERE Codice = @SourceCodice;

        UPDATE dbo.Premi
        SET Quantita = ISNULL(Quantita, 0) + @Qty,
            PDis1    = @SlotCode,                -- slot assegnato
            QDis1    = ISNULL(QDis1, 0) + @Qty   -- somma quantità distribuite nello slot
        WHERE Codice = @TargetCodice;

        COMMIT TRAN;

        -- (facoltativo) ritorna un riepilogo
        SELECT
            SourceCodice = @SourceCodice,
            TargetCodice = @TargetCodice,
            HubId = @HubId,
            Slot = @SlotCode,
            Qty = @Qty;

    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRAN;
        DECLARE @ErrMsg nvarchar(4000) = ERROR_MESSAGE(),
                @ErrNum int = ERROR_NUMBER(),
                @ErrSev int = ERROR_SEVERITY(),
                @ErrState int = ERROR_STATE();
        RAISERROR(@ErrMsg, @ErrSev, @ErrState);
        RETURN;
    END CATCH
END
