SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION dbo.fn_DecodeCardTrans
(
    @device              varchar(16),
    @comando             varchar(255),
    @logdate             datetime2,        -- per coerenza colla SP
    @FlagOpDaVerificare  int
)
RETURNS @out TABLE
(
    device               varchar(16),
    CodMac               varchar(64),
    cardid               varchar(8),
    DataMovimento        datetime2(0),
		StatoAcquisizione 	 varchar(10),
    TipoMovimento        nvarchar(20),
    SaldoCard            bigint,
    CostoPartita         bigint,
    LivelloCard          int,
    N0                   int,
    Bonus                bigint,
    FlagOpDaVerificare   int
)
AS
BEGIN
    -- Scompongo la stringa una sola volta
    DECLARE @cmdtable TABLE (row bigint, item varchar(100));
    INSERT INTO @cmdtable SELECT * FROM dbo.split(@comando, ';');

    ;WITH cmd AS (
        SELECT
          MAX(CASE WHEN row=1  THEN item END) AS b1,
          MAX(CASE WHEN row=2  THEN item END) AS b2,
          MAX(CASE WHEN row=3  THEN item END) AS b3,
          MAX(CASE WHEN row=4  THEN item END) AS b4,
          MAX(CASE WHEN row=5  THEN item END) AS b5,
          MAX(CASE WHEN row=6  THEN item END) AS b6,
          MAX(CASE WHEN row=7  THEN item END) AS b7,
          MAX(CASE WHEN row=8  THEN item END) AS b8,
          MAX(CASE WHEN row=13 THEN item END) AS b13,
          MAX(CASE WHEN row=14 THEN item END) AS b14,
          MAX(CASE WHEN row=15 THEN item END) AS b15,
          MAX(CASE WHEN row=16 THEN item END) AS b16,
          MAX(CASE WHEN row=17 THEN item END) AS b17,
          MAX(CASE WHEN row=18 THEN item END) AS b18,
          MAX(CASE WHEN row=19 THEN item END) AS b19,
          MAX(CASE WHEN row=20 THEN item END) AS b20,
          MAX(CASE WHEN row=21 THEN item END) AS b21,
          MAX(CASE WHEN row=22 THEN item END) AS b22,
          MAX(CASE WHEN row=23 THEN item END) AS b23,
          MAX(CASE WHEN row=24 THEN item END) AS b24,
          MAX(CASE WHEN row=25 THEN item END) AS b25,
          MAX(CASE WHEN row=26 THEN item END) AS b26,
          MAX(CASE WHEN row=27 THEN item END) AS b27,
          MAX(CASE WHEN row=28 THEN item END) AS b28,
          MAX(CASE WHEN row=29 THEN item END) AS b29,
          MAX(CASE WHEN row=30 THEN item END) AS b30,
          MAX(CASE WHEN row=31 THEN item END) AS b31,
          MAX(CASE WHEN row=32 THEN item END) AS b32,
          MAX(CASE WHEN row=33 THEN item END) AS b33,
          MAX(CASE WHEN row=34 THEN item END) AS b34,
          MAX(CASE WHEN row=35 THEN item END) AS b35,
          MAX(CASE WHEN row=37 THEN item END) AS b37,
          MAX(CASE WHEN row=38 THEN item END) AS b38
        FROM @cmdtable
    )
    , base AS (
        SELECT
            -- tiporecord da b3
            CONVERT(int, CONVERT(VARBINARY, CASE WHEN LEN(LTRIM(RTRIM(b3))) % 2 = 0
                                                 THEN '0x' ELSE '0x0' END + LTRIM(RTRIM(b3)), 1)) AS tiporecord,
            -- progressivo N0 = 8..5 (little endian)
            CONVERT(int, CONVERT(VARBINARY, '0x'
                + RIGHT('00'+b8,2)+RIGHT('00'+b7,2)+RIGHT('00'+b6,2)+RIGHT('00'+b5,2), 1)) AS N0,
            -- idcard per i due rami
            RIGHT('00'+b21,2)+RIGHT('00'+b22,2)+RIGHT('00'+b23,2)+RIGHT('00'+b24,2) AS idcard_8_13,
            RIGHT('00'+b17,2)+RIGHT('00'+b18,2)+RIGHT('00'+b19,2)+RIGHT('00'+b20,2) AS idcard_19_23,
            -- saldi/costi/bonus per i due rami
            CONVERT(bigint, CONVERT(VARBINARY, '0x'
                + RIGHT('00'+b20,2)+RIGHT('00'+b19,2)+RIGHT('00'+b18,2)+RIGHT('00'+b17,2), 1)) AS saldo_8_13,
            CONVERT(bigint, CONVERT(VARBINARY, '0x'+RIGHT('0000'+b29,4), 1)) AS costo_8_13,
            CONVERT(int,   CONVERT(VARBINARY, '0x'+RIGHT('0000'+b30,4), 1)) AS livello_8_13,

            CONVERT(bigint, CONVERT(VARBINARY, '0x'
                + RIGHT('00'+b16,2)+RIGHT('00'+b15,2)+RIGHT('00'+b14,2)+RIGHT('00'+b13,2), 1)) AS saldo_19_23,
            CONVERT(bigint, CONVERT(VARBINARY, '0x'
                + RIGHT('00'+b26,2)+RIGHT('00'+b25,2), 1)) AS costo_19_23,
            CONVERT(int,   CONVERT(VARBINARY, '0x'+RIGHT('0000'+b27,4), 1)) AS livello_19_23,
            CONVERT(bigint, CONVERT(VARBINARY, '0x'
                + RIGHT('00'+b38,2)+RIGHT('00'+b37,2), 1)) AS bonus_19_23,
            -- data dalla BE per 19..23: YYYY (32..31), MM (30), DD (29), hh (33), mm(34), ss(35)
            CONVERT(int, CONVERT(VARBINARY, '0x'+RIGHT('00'+b32,2)+RIGHT('00'+b31,2), 1)) AS year_be,
            b29 AS d_be, b30 AS m_be, b33 AS hh_be, b34 AS mm_be, b35 AS ss_be
        FROM cmd
    )
    INSERT @out
    SELECT
        @device                                                        AS device,
        ISNULL((SELECT codmac FROM WinMtSqlDB.dbo.EcsMacchine WHERE device = @device),'') AS CodMac,
        -- cardid + campi dipendenti dal tipo record
        CASE WHEN b.tiporecord IN (8,13) THEN UPPER(b.idcard_8_13)
             WHEN b.tiporecord IN (19,20,22,23) THEN UPPER(b.idcard_19_23)
        END                                                            AS cardid,
        -- DataMovimento:
        CASE 
          WHEN b.tiporecord IN (8,13) 
            THEN @logdate  -- come nella SP: per device collegati usiamo il timestamp di log/sp
          WHEN b.tiporecord IN (19,20,22,23) AND b.year_be > 2020 THEN
            TRY_CONVERT(datetime2(0),
              CONCAT(
                CONVERT(varchar(4), b.year_be), N'-',
                CONVERT(varchar(2), CONVERT(int, CONVERT(VARBINARY, '0x'+RIGHT('00'+b.m_be,2), 1))), N'-',
                CONVERT(varchar(2), CONVERT(int, CONVERT(VARBINARY, '0x'+RIGHT('00'+b.d_be,2), 1))), N'T',
                CONVERT(varchar(2), CONVERT(int, CONVERT(VARBINARY, '0x'+RIGHT('00'+b.hh_be,2),1))), N':',
                CONVERT(varchar(2), CONVERT(int, CONVERT(VARBINARY, '0x'+RIGHT('00'+b.mm_be,2),1))), N':',
                CONVERT(varchar(2), CONVERT(int, CONVERT(VARBINARY, '0x'+RIGHT('00'+b.ss_be,2),1)))
              ), 126)
          ELSE
            -- fallback SP: DataMovimento = DATEADD(ms, N0, TransCard.data) dell'ultima <= N0
            (
              SELECT TOP 1 TRY_CONVERT(datetime2(0), DATEADD(millisecond, tc.N0, tc.data))
              FROM  WinMtSqlDB.dbo.TransCard tc
              INNER JOIN WinMtSqlDB.dbo.Clienti cl
                ON tc.IdCli = CONVERT(varchar(30), dbo.fn_idcliente(cl.IdContatto, cl.idlong))
              WHERE cl.t0 = (
                       CASE WHEN b.tiporecord IN (8,13) THEN UPPER(b.idcard_8_13)
                            ELSE UPPER(b.idcard_19_23) END
                     ) + '00000000'
                AND tc.N0 <= b.N0
              ORDER BY tc.N0 DESC
            )
        END                                                            AS DataMovimento,
				CASE WHEN b.tiporecord IN (20,23) THEN 'offline' ELSE 'normal' END     AS StatoAcquisizione,
        N'Scarico'                                                     AS TipoMovimento,
        CASE WHEN b.tiporecord IN (8,13) THEN b.saldo_8_13 ELSE b.saldo_19_23 END AS SaldoCard,
        CASE WHEN b.tiporecord IN (8,13) THEN b.costo_8_13 ELSE b.costo_19_23 END AS CostoPartita,
        CASE WHEN b.tiporecord IN (8,13) THEN b.livello_8_13 ELSE b.livello_19_23 END AS LivelloCard,
        b.N0                                                           AS N0,
        CASE WHEN b.tiporecord IN (19,20,22,23) THEN b.bonus_19_23 ELSE 0 END     AS Bonus,
        @FlagOpDaVerificare                                            AS FlagOpDaVerificare
    FROM base b
    WHERE b.tiporecord IN (8,13,19,20,22,23);  -- solo transazioni con card

    RETURN;
END
GO