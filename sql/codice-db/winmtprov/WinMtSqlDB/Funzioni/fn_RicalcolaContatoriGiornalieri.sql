SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION dbo.fn_RicalcolaContatoriGiornalieri (
		@CodMac AS varchar(15) = '%',
    @StartDate DATETIME,
    @EndDate DATETIME
)
RETURNS TABLE
AS
RETURN
( -- Ver 1.1
    WITH RankedData AS (
        SELECT 
            CodMac,
            CONVERT(DATE, DataRil) AS DataRil,
            In1, In2, In3, In4, In5, In6, In7, In8, In9, In10, In11, In12, In13, In14, In15, In16,
            ROW_NUMBER() OVER (PARTITION BY CodMac, CONVERT(DATE, DataRil) ORDER BY DataRil) AS RN_ASC,
            ROW_NUMBER() OVER (PARTITION BY CodMac, CONVERT(DATE, DataRil) ORDER BY DataRil DESC) AS RN_DESC
        FROM ecsdati
        WHERE DataRil >= @StartDate AND DataRil <= @EndDate and codmac like @CodMac
    )
    SELECT 
				CodMac,
				DataRil,
				MAX(In1) - MIN(In1) AS In1,
				MAX(In2) - MIN(In2) AS In2,
				MAX(In3) - MIN(In3) AS In3,
				MAX(In4) - MIN(In4) AS In4,
				MAX(In5) - MIN(In5) AS In5,
				MAX(In6) - MIN(In6) AS In6,
				MAX(In7) - MIN(In7) AS In7,
				MAX(In8) - MIN(In8) AS In8,
				MAX(In9) - MIN(In9) AS In9,
				MAX(In10) - MIN(In10) AS In10,
				MAX(In11) - MIN(In11) AS In11,
				MAX(In12) - MIN(In12) AS In12,
				MAX(In13) - MIN(In13) AS In13,
				MAX(In14) - MIN(In14) AS In14,
				MAX(In15) - MIN(In15) AS In15,
				MAX(In16) - MIN(In16) AS In16
    FROM RankedData
    WHERE RN_ASC = 1 OR RN_DESC = 1
    GROUP BY CodMac, DataRil
    
);
GO
