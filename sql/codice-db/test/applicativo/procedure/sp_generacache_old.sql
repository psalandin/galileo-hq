    CREATE PROCEDURE [dbo].[sp_generacache] 
    AS
    BEGIN
        -- se non esiste creo il file della cache
        IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'cache_dati_grafico_giornaliero')
        BEGIN
            -- Se la tabella non esiste, la creiamo
            CREATE TABLE [dbo].[cache_dati_grafico_giornaliero] (
                [CodMac] varchar(15) NULL,
                [tipo] int  NULL,
                [DataRil] date  NULL,
                [EUIncassiMonete] money  NULL,
                [EUIncassiGettoni] money  NULL,
                [EUPremiPagati] money  NULL,
                [EUTicketsPagati] money  NULL,
                [NrMonete] bigint  NULL,
                [NrGettoni] bigint  NULL,
                [NrPremi] bigint  NULL,
                [NrTickets] bigint  NULL,
                [NrGettoniOut] bigint  NULL,
                [NrMoneteOut] money  NULL,
                [NPartite] numeric(10,1)  NULL
            )  
            ON [PRIMARY];

            ALTER TABLE [dbo].[cache_dati_grafico_giornaliero] SET (LOCK_ESCALATION = TABLE);
        END

        DECLARE @primo DATE = (
            SELECT ISNULL(MAX(DataRil), CONVERT(DATE, '01/01/2018', 101)) 
            FROM cache_dati_grafico_giornaliero
        );

        DECLARE @ultimo DATE = (
            SELECT ISNULL(MAX(DataRil), CONVERT(DATE, GETDATE(), 101)) 
            FROM cache_dati_grafico_giornaliero
        );

        DECLARE @valtick NUMERIC(5,3);
        DECLARE @valgett NUMERIC(5,3);
        DECLARE @currentDate DATE = @primo;
        DECLARE @oggi DATE =( SELECT GETDATE());

        -- Valori di setup
        SELECT @valtick = valtick, @valgett = valgett 
        FROM setup 
        WHERE idpost = '101';

        -- Cancella il record della ultima data inserita, se presente
        DELETE FROM cache_dati_grafico_giornaliero 
        WHERE dataril = @ultimo;

        -- Loop per ogni giorno tra @primo e @ultimo
        WHILE @currentDate <= @oggi
        BEGIN
            -- Inserisci i dati per il giorno corrente
            INSERT INTO cache_dati_grafico_giornaliero 
            SELECT * 
            FROM fn_dati_grafico_giornaliero (
                '%', 
                CONVERT(DATETIME, @currentDate, 101), 
                DATEADD(SECOND, 86399, CONVERT(DATETIME, @currentDate, 101)), -- Fine del giorno
                0, 
                @valgett, 
                @valtick
            );

            -- Incrementa la data corrente di 1 giorno
            SET @currentDate = DATEADD(DAY, 1, @currentDate);
        END;
    END
