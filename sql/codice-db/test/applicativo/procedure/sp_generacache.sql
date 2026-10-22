CREATE PROCEDURE [dbo].[sp_generacache]
(
      @DataDal     date        = NULL
    , @DataAl      date        = NULL
    , @CodMac      varchar(15) = NULL
    , @FiltraTipo  int         = 0
    , @ValGett     money       = NULL
    , @ValTick     money       = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @LockResult        int;
    DECLARE @CodMacFiltro      varchar(15);
    DECLARE @DataDalEffettiva  date;
    DECLARE @DataAlEffettiva   date;
    DECLARE @Oggi              date;
    DECLARE @UltimaDataCache   date;
    DECLARE @ErrMsg            nvarchar(4000);

    DECLARE @StartAt           datetime;
    DECLARE @EndAt             datetime;
    DECLARE @DeletedRows       int;
    DECLARE @InsertedRows      int;

    SET @Oggi = CAST(GETDATE() AS date);
    SET @StartAt = GETDATE();
    SET @DeletedRows = 0;
    SET @InsertedRows = 0;

    BEGIN TRY
        EXEC @LockResult = sp_getapplock
              @Resource    = 'dbo.sp_generacache'
            , @LockMode    = 'Exclusive'
            , @LockOwner   = 'Session'
            , @LockTimeout = 60000;

        IF @LockResult < 0
        BEGIN
            RAISERROR('Impossibile acquisire il lock esclusivo su dbo.sp_generacache.', 16, 1);
            RETURN;
        END

        IF OBJECT_ID('dbo.cache_dati_grafico_giornaliero', 'U') IS NULL
        BEGIN
            CREATE TABLE [dbo].[cache_dati_grafico_giornaliero]
            (
                [CodMac]            varchar(15)   NULL,
                [tipo]              int           NULL,
                [DataRil]           date          NULL,
                [EUIncassiMonete]   money         NULL,
                [EUIncassiGettoni]  money         NULL,
                [EUPremiPagati]     money         NULL,
                [EUTicketsPagati]   money         NULL,
                [NrMonete]          bigint        NULL,
                [NrGettoni]         bigint        NULL,
                [NrPremi]           bigint        NULL,
                [NrTickets]         bigint        NULL,
                [NrGettoniOut]      bigint        NULL,
                [NrMoneteOut]       money         NULL,
                [NPartite]          numeric(10,1) NULL
            );

            ALTER TABLE [dbo].[cache_dati_grafico_giornaliero]
            SET (LOCK_ESCALATION = TABLE);
        END

        IF NOT EXISTS
        (
            SELECT 1
            FROM sys.indexes
            WHERE object_id = OBJECT_ID('dbo.cache_dati_grafico_giornaliero')
              AND name = 'IX_cache_dati_grafico_giornaliero_DataRil_CodMac_Tipo'
        )
        BEGIN
            CREATE NONCLUSTERED INDEX IX_cache_dati_grafico_giornaliero_DataRil_CodMac_Tipo
            ON dbo.cache_dati_grafico_giornaliero (DataRil, CodMac, tipo);
        END

        SET @CodMacFiltro = LTRIM(RTRIM(ISNULL(@CodMac, '')));
        IF @CodMacFiltro = '' SET @CodMacFiltro = '%';

        IF @ValGett IS NULL OR @ValTick IS NULL
        BEGIN
            SELECT
                  @ValGett = ISNULL(@ValGett, ValGett)
                , @ValTick = ISNULL(@ValTick, ValTick)
            FROM dbo.Setup
            WHERE IDPost = '101';
        END

        SET @ValGett = ISNULL(@ValGett, 1);
        SET @ValTick = ISNULL(@ValTick, 1);

        IF @DataDal IS NULL AND @DataAl IS NULL
        BEGIN
            SELECT
                @UltimaDataCache = MAX(DataRil)
            FROM dbo.cache_dati_grafico_giornaliero
            WHERE CodMac LIKE @CodMacFiltro
              AND (@FiltraTipo = 0 OR tipo = @FiltraTipo);

            IF @UltimaDataCache IS NULL
                SET @DataDalEffettiva = @Oggi;
            ELSE
                SET @DataDalEffettiva = DATEADD(DAY, -1, @UltimaDataCache);

            SET @DataAlEffettiva = @Oggi;
        END
        ELSE
        BEGIN
            SET @DataDalEffettiva = ISNULL(@DataDal, @DataAl);
            SET @DataAlEffettiva  = ISNULL(@DataAl,  @DataDal);
        END

        IF @DataDalEffettiva IS NULL OR @DataAlEffettiva IS NULL
        BEGIN
            RAISERROR('Intervallo date non valido.', 16, 1);
            RETURN;
        END

        IF @DataDalEffettiva > @DataAlEffettiva
        BEGIN
            RAISERROR('La DataDal non può essere maggiore della DataAl.', 16, 1);
            RETURN;
        END

        BEGIN TRANSACTION;

        DELETE C
        FROM dbo.cache_dati_grafico_giornaliero AS C
        WHERE C.DataRil >= @DataDalEffettiva
          AND C.DataRil <= @DataAlEffettiva
          AND C.CodMac LIKE @CodMacFiltro
          AND (@FiltraTipo = 0 OR C.tipo = @FiltraTipo);

        SET @DeletedRows = @@ROWCOUNT;

        INSERT INTO dbo.cache_dati_grafico_giornaliero
        (
              CodMac
            , tipo
            , DataRil
            , EUIncassiMonete
            , EUIncassiGettoni
            , EUPremiPagati
            , EUTicketsPagati
            , NrMonete
            , NrGettoni
            , NrPremi
            , NrTickets
            , NrGettoniOut
            , NrMoneteOut
            , NPartite
        )
        SELECT
              F.CodMac
            , F.tipo
            , F.DataRil
            , F.EUIncassiMonete
            , F.EUIncassiGettoni
            , F.EUPremiPagati
            , F.EUTicketsPagati
            , F.NrMonete
            , F.NrGettoni
            , F.NrPremi
            , F.NrTickets
            , F.NrGettoniOut
            , F.NrMoneteOut
            , F.NPartite
        FROM dbo.fn_dati_grafico_giornaliero
        (
              @CodMacFiltro
            , CAST(@DataDalEffettiva AS datetime)
            , DATEADD(DAY, 1, CAST(@DataAlEffettiva AS datetime))
            , @FiltraTipo
            , @ValGett
            , @ValTick
        ) AS F;

        SET @InsertedRows = @@ROWCOUNT;

        COMMIT TRANSACTION;

        EXEC sp_releaseapplock
              @Resource  = 'dbo.sp_generacache'
            , @LockOwner = 'Session';

        SET @EndAt = GETDATE();

        SELECT
              @DataDalEffettiva                          AS DataDalEffettiva
            , @DataAlEffettiva                           AS DataAlEffettiva
            , @CodMacFiltro                              AS CodMacFiltro
            , @FiltraTipo                                AS FiltraTipo
            , @ValGett                                   AS ValGettUsato
            , @ValTick                                   AS ValTickUsato
            , @DeletedRows                               AS RigheCancellate
            , @InsertedRows                              AS RigheInserite
            , @StartAt                                   AS InizioElaborazione
            , @EndAt                                     AS FineElaborazione
            , DATEDIFF(MILLISECOND, @StartAt, @EndAt)   AS DurataMs;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        BEGIN TRY
            EXEC sp_releaseapplock
                  @Resource  = 'dbo.sp_generacache'
                , @LockOwner = 'Session';
        END TRY
        BEGIN CATCH
        END CATCH;

        SET @ErrMsg =
              'Errore in dbo.sp_generacache. Nr=' + CAST(ERROR_NUMBER() AS nvarchar(20))
            + ', Riga=' + CAST(ERROR_LINE() AS nvarchar(20))
            + ', Msg=' + ERROR_MESSAGE();

        RAISERROR(@ErrMsg, 16, 1);
        RETURN;
    END CATCH
END
