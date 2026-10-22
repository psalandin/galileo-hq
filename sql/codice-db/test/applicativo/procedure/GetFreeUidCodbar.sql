CREATE   PROCEDURE dbo.GetFreeUidCodbar
    @ReservedBy varchar(64),
    @TtlSeconds int = 120,
    @CodBar varchar(50) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @tries int = 0;

    WHILE (@tries < 20)
    BEGIN
        SET @tries += 1;
        SET @CodBar = NULL;

        BEGIN TRAN;

        -- 1) cleanup scaduti
        DELETE FROM dbo.uid_reservations
        WHERE ExpiresAt <= SYSDATETIME();

        -- 2) scegli un candidato NON presente in clienti e NON già prenotato
        SELECT TOP (1) @CodBar = UA.CodBar
        FROM dbo.UID_Ammessi UA WITH (READPAST)
        LEFT JOIN dbo.clienti cli WITH (READCOMMITTEDLOCK)
            ON cli.CodBar = UA.CodBar
        LEFT JOIN dbo.uid_reservations r WITH (READCOMMITTEDLOCK)
            ON r.CodBar = UA.CodBar
        WHERE cli.IdContatto IS NULL
          AND UA.DataEmissione is null
          AND UA.CodBar = UA.UID
          AND r.CodBar IS NULL
        ORDER BY UA.CodBar;

        IF @CodBar IS NULL
        BEGIN
            ROLLBACK;
            RETURN 1; -- nessun UID disponibile
        END

        BEGIN TRY
            INSERT INTO dbo.uid_reservations (CodBar, ReservedBy, ExpiresAt)
            VALUES (@CodBar, @ReservedBy, DATEADD(SECOND, @TtlSeconds, SYSDATETIME()));

            COMMIT;
            RETURN 0; -- prenotato con successo
        END TRY
        BEGIN CATCH
            -- 2627/2601: PK/Unique violation => un altro ha prenotato lo stesso CodBar
            IF ERROR_NUMBER() IN (2627, 2601)
            BEGIN
                ROLLBACK;
                CONTINUE; -- riprova
            END

            IF XACT_STATE() <> 0 ROLLBACK;
            THROW;
        END CATCH
    END

    RETURN 2; -- troppa contesa / troppi retry
END
