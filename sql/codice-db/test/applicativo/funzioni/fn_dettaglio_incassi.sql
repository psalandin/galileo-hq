CREATE FUNCTION [dbo].[fn_dettaglio_incassi]
( 
    @dalla_data     AS datetime,
    @alla_data      AS datetime,
    @codiceMac      AS varchar(15) = NULL,
    @valoregettone  AS smallmoney = NULL,
    @valoreticket   AS smallmoney = NULL
)
RETURNS @MyReturn TABLE
( 
      CodMac                 varchar(15)
    , DataRil                date
    , ScattiMonete           smallmoney
    , ValoreMonete           smallmoney
    , ScattiGettoni          smallmoney
    , ValoreGettoni          smallmoney
    , ScattiPremi            smallmoney
    , ValorePremi            smallmoney
    , ScattiTickets          smallmoney
    , ValoreTickets          smallmoney
    , ValoreEcoin            smallmoney
    , ValoreOperazioneEcoin  smallmoney
    , ValoreBonusEcoin       smallmoney
)
AS
BEGIN
    DECLARE @CodMac varchar(15);
    DECLARE @valgettone smallmoney;
    DECLARE @valticket smallmoney;

    SET @CodMac = ISNULL(@codiceMac, '%');

    SELECT @valgettone = ISNULL(@valoregettone, ValGett)
    FROM dbo.Setup
    WHERE IDPost = '101';

    SELECT @valticket = ISNULL(@valoreticket, ValTick)
    FROM dbo.Setup
    WHERE IDPost = '101';

    SET @valgettone = ISNULL(@valgettone, 0);
    SET @valticket  = ISNULL(@valticket, 0);

    ;WITH Base AS
    (
        SELECT
              I.CodMac
            , CONVERT(date, I.DataRil) AS DataRil
            , M.TipoIn
            , M.ValCnt
            , M.ValIn
            , M.Ingresso

            , CASE
                WHEN M.TipoIn = 6 AND ISNULL(I.In9, 0) > 0 THEN I.ValoreEcoin
                ELSE 0
              END AS ValoreEcoin

            , CASE
                WHEN M.TipoIn = 6 AND ISNULL(I.In9, 0) > 0 THEN I.ValoreOperazioneEcoin
                ELSE 0
              END AS ValoreOperazioneEcoin

            , CASE
                WHEN M.TipoIn = 6 AND ISNULL(I.In9, 0) > 0 THEN I.ValoreBonusEcoin
                ELSE 0
              END AS ValoreBonusEcoin

            , CONVERT(money,
                CASE M.Ingresso
                    WHEN 1  THEN ISNULL(I.In1, 0)
                    WHEN 2  THEN ISNULL(I.In2, 0)
                    WHEN 3  THEN ISNULL(I.In3, 0)
                    WHEN 4  THEN ISNULL(I.In4, 0)
                    WHEN 5  THEN ISNULL(I.In5, 0)
                    WHEN 6  THEN ISNULL(I.In6, 0)
                    WHEN 7  THEN ISNULL(I.In7, 0)
                    WHEN 8  THEN ISNULL(I.In8, 0)
                    WHEN 9  THEN ISNULL(I.In9, 0)
                    WHEN 10 THEN ISNULL(I.In10, 0)
                    WHEN 11 THEN ISNULL(I.In11, 0)
                    WHEN 12 THEN ISNULL(I.In12, 0)
                    WHEN 13 THEN ISNULL(I.In13, 0)
                    WHEN 14 THEN ISNULL(I.In14, 0)
                    WHEN 15 THEN ISNULL(I.In15, 0)
                    ELSE 0
                END
              ) AS QuantitaIngresso
        FROM dbo.fn_EcsDatiGiornalieri(@CodMac, @dalla_data, @alla_data) AS I
        LEFT JOIN dbo.vs_macchine AS M
               ON I.CodMac = M.CodMac
              AND M.DataDis IS NULL
              AND M.Tipo > 1
    ),
    Calc AS
    (
        SELECT
              B.CodMac
            , B.DataRil
            , B.TipoIn
            , B.ValoreEcoin
            , B.ValoreOperazioneEcoin
            , B.ValoreBonusEcoin

            , CONVERT(money,
                ISNULL(
                    (B.QuantitaIngresso * ISNULL(B.ValIn, 0)) / NULLIF(B.ValCnt, 0)
                , 0)
              ) AS Scatti

            , CONVERT(money,
                CASE B.TipoIn
                    WHEN 0 THEN 0
                    WHEN 2 THEN 0
                    ELSE B.QuantitaIngresso * ISNULL(B.ValIn, 0)
                END
              ) AS GettoniContati

            , CONVERT(money,
                B.QuantitaIngresso
                * CASE B.TipoIn
                    WHEN 1 THEN @valgettone
                    WHEN 3 THEN @valticket
                    ELSE 1.00
                  END
                * ISNULL(B.ValIn, 0)
              ) AS Valore
        FROM Base AS B
    )
    INSERT INTO @MyReturn
    (
          CodMac
        , DataRil
        , ScattiMonete
        , ValoreMonete
        , ScattiGettoni
        , ValoreGettoni
        , ScattiPremi
        , ValorePremi
        , ScattiTickets
        , ValoreTickets
        , ValoreEcoin
        , ValoreOperazioneEcoin
        , ValoreBonusEcoin
    )
    SELECT
          C.CodMac
        , C.DataRil
        , CONVERT(smallmoney, SUM(CASE WHEN C.TipoIn = 0 THEN C.Scatti         ELSE 0.0 END)) AS ScattiMonete
        , CONVERT(smallmoney, SUM(CASE WHEN C.TipoIn = 0 THEN C.Valore         ELSE 0.0 END)) AS ValoreMonete
        , CONVERT(smallmoney, SUM(CASE WHEN C.TipoIn = 1 THEN C.GettoniContati ELSE 0.0 END)) AS ScattiGettoni
        , CONVERT(smallmoney, SUM(CASE WHEN C.TipoIn = 1 THEN C.Valore         ELSE 0.0 END)) AS ValoreGettoni
        , CONVERT(smallmoney, SUM(CASE WHEN C.TipoIn = 2 THEN C.Scatti         ELSE 0.0 END)) AS ScattiPremi
        , CONVERT(smallmoney, SUM(CASE WHEN C.TipoIn = 2 THEN C.Valore         ELSE 0.0 END)) AS ValorePremi
        , CONVERT(smallmoney, SUM(CASE WHEN C.TipoIn = 3 THEN C.Scatti         ELSE 0.0 END)) AS ScattiTickets
        , CONVERT(smallmoney, SUM(CASE WHEN C.TipoIn = 3 THEN C.Valore         ELSE 0.0 END)) AS ValoreTickets
        , CONVERT(smallmoney, SUM(ISNULL(C.ValoreEcoin, 0)))                   AS ValoreEcoin
        , CONVERT(smallmoney, SUM(ISNULL(C.ValoreOperazioneEcoin, 0)))         AS ValoreOperazioneEcoin
        , CONVERT(smallmoney, SUM(ISNULL(C.ValoreBonusEcoin, 0)))              AS ValoreBonusEcoin
    FROM Calc AS C
    GROUP BY
          C.CodMac
        , C.DataRil
    ORDER BY
          C.CodMac
        , C.DataRil;

    RETURN;
END;
