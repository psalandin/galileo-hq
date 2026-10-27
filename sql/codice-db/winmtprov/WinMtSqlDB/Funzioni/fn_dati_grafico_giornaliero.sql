SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE FUNCTION [dbo].[fn_dati_grafico_giornaliero]
( @CodMac AS Varchar(15) ,
  @DallaData AS datetime ,
  @AllaData AS datetime ,
	@FiltraTipo as int ,
	@valgettone money = 0,
	@valticket money = 0
)
RETURNS @myReturn TABLE
(
      CodMac            varchar(15)   NULL
    , tipo              int           NULL
    , DataRil           date          NULL
    , EUIncassiMonete   money         NULL
    , EUIncassiGettoni  money         NULL
    , EUPremiPagati     money         NULL
    , EUTicketsPagati   money         NULL
    , NrMonete          bigint        NULL
    , NrGettoni         bigint        NULL
    , NrPremi           bigint        NULL
    , NrTickets         bigint        NULL
    , NrGettoniOut      bigint        NULL
    , NrMoneteOut       money         NULL
    , NPartite          numeric(10,1) NULL
)
AS
BEGIN
    DECLARE @DataDalDate date;
    DECLARE @DataAlDate  date;

    SET @DataDalDate = CONVERT(date, @DallaData);
    SET @DataAlDate  = CONVERT(date, @AllaData);

    --------------------------------------------------------------------------
    -- Valori di setup fallback
    --------------------------------------------------------------------------
    SELECT @valgettone =
        CASE
            WHEN ISNULL(@valgettone, 0) = 0
                THEN ISNULL((SELECT ValGett FROM dbo.Setup WHERE IDPost = '101'), 1)
            ELSE @valgettone
        END;

    SELECT @valticket =
        CASE
            WHEN ISNULL(@valticket, 0) = 0
                THEN ISNULL((SELECT ValTick FROM dbo.Setup WHERE IDPost = '101'), 1)
            ELSE @valticket
        END;

    --------------------------------------------------------------------------
    -- Periodo completo macchina/giorno per garantire righe anche senza movimenti
    -- Versione NON ricorsiva: niente fn_generateDateTable, niente MAXRECURSION
    --------------------------------------------------------------------------
    DECLARE @Periodo TABLE
    (
          CodMac varchar(15) NULL
        , giorno date        NULL
    );

    ;WITH N AS
    (
        SELECT TOP (DATEDIFF(DAY, @DataDalDate, @DataAlDate) + 1)
               ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS n
        FROM sys.all_objects A
        CROSS JOIN sys.all_objects B
    )
    INSERT INTO @Periodo (CodMac, giorno)
    SELECT
          M.CodMac
        , DATEADD(DAY, N.n, @DataDalDate) AS giorno
    FROM N
    CROSS JOIN dbo.EcsMacchine AS M
    WHERE M.CodMac LIKE @CodMac
      AND (M.DataDis IS NULL OR M.DataDis > @DallaData)
      AND M.Tipo > @FiltraTipo;

    --------------------------------------------------------------------------
    -- Base dati giornalieri già espansa e normalizzata
    --------------------------------------------------------------------------
    ;WITH Base AS
    (
        SELECT
              P.CodMac
            , CONVERT(date, P.DataRil) AS DataRil
            , M.TipoIn
            , M.Tipo
            , M.Ingresso
            , CONVERT(money, ISNULL(M.ValIn, 0))  AS ValIn
            , CONVERT(money, ISNULL(M.ValCnt, 0)) AS ValCnt
            , CONVERT(money, ISNULL(M.ValPar, 0)) AS ValPar
            , CONVERT(money,
                CASE M.Ingresso
                    WHEN 1  THEN ISNULL(P.In1, 0)
                    WHEN 2  THEN ISNULL(P.In2, 0)
                    WHEN 3  THEN ISNULL(P.In3, 0)
                    WHEN 4  THEN ISNULL(P.In4, 0)
                    WHEN 5  THEN ISNULL(P.In5, 0)
                    WHEN 6  THEN ISNULL(P.In6, 0)
                    WHEN 7  THEN ISNULL(P.In7, 0)
                    WHEN 8  THEN ISNULL(P.In8, 0)
                    WHEN 9  THEN ISNULL(P.In9, 0)
                    WHEN 10 THEN ISNULL(P.In10, 0)
                    WHEN 11 THEN ISNULL(P.In11, 0)
                    WHEN 12 THEN ISNULL(P.In12, 0)
                    WHEN 13 THEN ISNULL(P.In13, 0)
                    WHEN 14 THEN ISNULL(P.In14, 0)
                    WHEN 15 THEN ISNULL(P.In15, 0)
                    ELSE 0
                END
              ) AS QtaIngresso
            , ISNULL(P.In9, 0) AS NPartiteEcoin
        FROM dbo.fn_EcsDatiGiornalieri(@CodMac, @DallaData, @AllaData) AS P
        INNER JOIN dbo.vs_macchine AS M
            ON  M.CodMac = P.CodMac
            AND (M.DataDis IS NULL OR M.DataDis > @DallaData)
            AND M.Tipo > CASE WHEN @FiltraTipo = 0 THEN 0 ELSE (@FiltraTipo - 1) END
    ),
    Calc AS
    (
        SELECT
              B.CodMac
            , B.DataRil
            , B.Tipo

            , CASE WHEN B.TipoIn = 0 THEN B.QtaIngresso * B.ValIn END               AS EUIncassiMonete
            , CASE WHEN B.TipoIn = 1 THEN B.QtaIngresso * @valgettone * B.ValIn END AS EUIncassiGettoni
            , CASE WHEN B.TipoIn = 2 THEN B.QtaIngresso * B.ValIn END               AS EUPremiPagati
            , CASE WHEN B.TipoIn = 3 THEN B.QtaIngresso * @valticket * B.ValIn END  AS EUTicketsPagati

            , CASE WHEN B.TipoIn = 0 THEN CONVERT(bigint, B.QtaIngresso ) END AS MoneteContate
            , CASE WHEN B.TipoIn = 1 THEN CONVERT(bigint, B.QtaIngresso ) END AS GettoniContati
            , CASE WHEN B.TipoIn = 2 THEN CONVERT(bigint, B.QtaIngresso ) END AS PremiContati
            , CASE WHEN B.TipoIn = 3 THEN CONVERT(bigint, B.QtaIngresso * B.ValIn) END AS TicketsContati
            , CASE WHEN B.TipoIn = 5 THEN CONVERT(bigint, B.QtaIngresso ) END AS NrGettoniOut
            , CASE WHEN B.TipoIn = 4 THEN CONVERT(bigint,  B.QtaIngresso ) END AS NrMoneteOut

            , CASE
                WHEN B.Ingresso <> 9
                 AND B.TipoIn IN (0,1)
                 AND ISNULL(B.ValCnt, 0) <> 0
                 AND ISNULL(B.ValPar, 0) <> 0
                    THEN (B.QtaIngresso * B.ValIn) / B.ValPar
                ELSE 0
              END AS NPartite

            , B.NPartiteEcoin
        FROM Base AS B
    )
    INSERT INTO @myReturn
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
          ISNULL(C.CodMac, P.CodMac)                   AS CodMac
        , ISNULL(C.Tipo, 0)                            AS tipo
        , ISNULL(C.DataRil, P.giorno)                  AS DataRil
        , ISNULL(SUM(C.EUIncassiMonete), 0)            AS EUIncassiMonete
        , ISNULL(SUM(C.EUIncassiGettoni), 0)           AS EUIncassiGettoni
        , ISNULL(SUM(C.EUPremiPagati), 0)              AS EUPremiPagati
        , ISNULL(SUM(C.EUTicketsPagati), 0)            AS EUTicketsPagati
        , ISNULL(SUM(C.MoneteContate), 0)              AS NrMonete
        , ISNULL(SUM(C.GettoniContati), 0)             AS NrGettoni
        , ISNULL(SUM(C.PremiContati), 0)               AS NrPremi
        , ISNULL(SUM(C.TicketsContati), 0)             AS NrTickets
        , ISNULL(SUM(C.NrGettoniOut), 0)               AS NrGettoniOut
        , ISNULL(SUM(C.NrMoneteOut), 0)                AS NrMoneteOut
        , ISNULL(SUM(ISNULL(C.NPartite, 0)), 0)
          + ISNULL(MAX(ISNULL(C.NPartiteEcoin, 0)), 0) AS NPartite
    FROM @Periodo AS P
    FULL JOIN Calc AS C
        ON  C.CodMac  = P.CodMac
        AND C.DataRil = P.giorno
    WHERE ISNULL(C.Tipo, 0) > CASE WHEN @FiltraTipo = 0 THEN 0 ELSE (@FiltraTipo - 1) END
      AND ISNULL(C.Tipo, 0) < CASE WHEN @FiltraTipo = 0 THEN 99 ELSE (@FiltraTipo + 1) END
    GROUP BY
          ISNULL(C.CodMac, P.CodMac)
        , ISNULL(C.Tipo, 0)
        , ISNULL(C.DataRil, P.giorno)
    ORDER BY
          ISNULL(C.CodMac, P.CodMac)
        , ISNULL(C.Tipo, 0);

    RETURN;
END
GO


