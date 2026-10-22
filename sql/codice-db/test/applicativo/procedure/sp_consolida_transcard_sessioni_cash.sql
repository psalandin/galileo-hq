CREATE   PROCEDURE dbo.sp_consolida_transcard_sessioni_cash
(
    @DataFine datetime = NULL,
    @DataInizio datetime = NULL,
    @DryRun bit = 1
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @RunId int;
    DECLARE @RangeStart datetime;
    DECLARE @RangeEnd datetime;

    DECLARE @SessioniAnalizzate int = 0;
    DECLARE @SessioniConsolidate int = 0;
    DECLARE @SessioniScartate int = 0;

    DECLARE @TotaleRicarichePrima money = 0;
    DECLARE @TotaleRicaricheDopo money = 0;

    BEGIN TRY
        BEGIN TRAN;

        /* =========================================================
           1. Calcolo range
           ========================================================= */
        IF @DataFine IS NULL
            SET @DataFine = GETDATE();

        IF @DataInizio IS NOT NULL
            SET @RangeStart = @DataInizio;
        ELSE
        BEGIN
            SELECT @RangeStart = MAX(DataMaxRange)
            FROM dbo.TransCard_Consolidamento_Log
            WHERE Status = 'COMPLETED';

            IF @RangeStart IS NULL
                SET @RangeStart = '20000101';
        END;

        SET @RangeEnd = @DataFine;

        INSERT INTO dbo.TransCard_Consolidamento_Log
        (
            DataMinRange, DataMaxRange, DryRun, Status, Note
        )
        VALUES
        (
            @RangeStart, @RangeEnd, @DryRun, 'RUNNING',
            'Consolidamento sessioni cash con residui'
        );

        SET @RunId = SCOPE_IDENTITY();

        /* =========================================================
           2. Estrazione movimenti nel range
           ========================================================= */
        IF OBJECT_ID('tempdb..#Mov') IS NOT NULL DROP TABLE #Mov;

        SELECT
            t.IdCli,
            t.NImp,
            t.CodMac,
            t.[Data],
            t.ValoreOperazione,
            t.ValoreFinale,
            t.ValoreBonus,
            t.F0,
            t.T0,
            t.N0,
            t.D0,
            t.Operatore,
            t.ValoreCassa,
            t.WinMt,
            t.IDOperazione,
            t.FlagOpDaVerificare
        INTO #Mov
        FROM dbo.TransCard t
        WHERE t.IdCli IS NOT NULL
          AND t.[Data] > @RangeStart
          AND t.[Data] <= @RangeEnd;

        /* totale ricariche prima del consolidamento */
        SELECT
            @TotaleRicarichePrima =
                ISNULL(SUM(CASE WHEN NImp IN (0,1,2,13,14,6) THEN ISNULL(ValoreOperazione,0) ELSE 0 END), 0)
        FROM #Mov;

        /* =========================================================
           3. Ordinamento logico per IdCli su N0
           ========================================================= */
        IF OBJECT_ID('tempdb..#Ord') IS NOT NULL DROP TABLE #Ord;

        ;WITH X AS
        (
            SELECT
                m.*,
                rn = ROW_NUMBER() OVER
                (
                    PARTITION BY m.IdCli
                    ORDER BY ISNULL(m.N0,0), m.[Data], m.IDOperazione
                )
            FROM #Mov m
        )
        SELECT *
        INTO #Ord
        FROM X;

        /* =========================================================
           4. Inizio sessione:
              ricarica crediti cash, eventualmente anticipata dal bonus 6
           ========================================================= */
        IF OBJECT_ID('tempdb..#StartRecharge') IS NOT NULL DROP TABLE #StartRecharge;

        SELECT
            c.IdCli,
            StartRn = ISNULL(b.rn, c.rn),
            StartIDOperazione = ISNULL(b.IDOperazione, c.IDOperazione),
            StartData = ISNULL(b.[Data], c.[Data]),
            StartN0 = ISNULL(b.N0, c.N0),
            RechargeRn = c.rn,
            RechargeIDOperazione = c.IDOperazione,
            RechargeData = c.[Data],
            RechargeN0 = c.N0
        INTO #StartRecharge
        FROM #Ord c
        LEFT JOIN #Ord b
            ON b.IdCli = c.IdCli
           AND ISNULL(b.N0,-1) = ISNULL(c.N0,-1) - 1
           AND b.NImp = 6
        WHERE c.NImp IN (0,1,2,13,14)
          AND ISNULL(c.ValoreCassa,0) > 0;

        /* =========================================================
           5. Sessioni candidate: fino alla ricarica cash successiva
           ========================================================= */
        IF OBJECT_ID('tempdb..#Sessioni') IS NOT NULL DROP TABLE #Sessioni;

        ;WITH S AS
        (
            SELECT
                s.IdCli,
                s.StartRn,
                s.StartIDOperazione,
                s.StartData,
                s.StartN0,
                s.RechargeRn,
                s.RechargeIDOperazione,
                s.RechargeData,
                s.RechargeN0,
                NextStartRn =
                    LEAD(s.StartRn) OVER
                    (
                        PARTITION BY s.IdCli
                        ORDER BY s.StartRn
                    )
            FROM #StartRecharge s
        )
        SELECT
            SessionId = IDENTITY(int,1,1),
            IdCli,
            StartRn,
            EndRn = ISNULL(NextStartRn - 1, 2147483647),
            StartIDOperazione,
            StartData,
            StartN0,
            RechargeRn,
            RechargeIDOperazione,
            RechargeData,
            RechargeN0
        INTO #Sessioni
        FROM S;

        SELECT @SessioniAnalizzate = COUNT(*) FROM #Sessioni;

        /* =========================================================
           6. Righe della sessione
           ========================================================= */
        IF OBJECT_ID('tempdb..#SessionRows') IS NOT NULL DROP TABLE #SessionRows;

        SELECT
            s.SessionId,
            s.IdCli,
            s.StartRn,
            s.EndRn,
            s.RechargeRn,
            s.RechargeIDOperazione,
            o.rn,
            o.NImp,
            o.CodMac,
            o.[Data],
            o.ValoreOperazione,
            o.ValoreFinale,
            o.ValoreBonus,
            o.F0,
            o.T0,
            o.N0,
            o.D0,
            o.Operatore,
            o.ValoreCassa,
            o.WinMt,
            o.IDOperazione,
            o.FlagOpDaVerificare
        INTO #SessionRows
        FROM #Sessioni s
        JOIN #Ord o
          ON o.IdCli = s.IdCli
         AND o.rn BETWEEN s.StartRn AND s.EndRn;

        /* =========================================================
           7. Ultima riga sessione
           ========================================================= */
        IF OBJECT_ID('tempdb..#LastRowSession') IS NOT NULL DROP TABLE #LastRowSession;

        ;WITH L AS
        (
            SELECT
                sr.*,
                rn_desc = ROW_NUMBER() OVER
                (
                    PARTITION BY sr.SessionId
                    ORDER BY ISNULL(sr.N0,0) DESC, sr.[Data] DESC, sr.IDOperazione DESC
                )
            FROM #SessionRows sr
        )
        SELECT *
        INTO #LastRowSession
        FROM L
        WHERE rn_desc = 1;

        /* =========================================================
           8. Righe prima dell'ultima
           ========================================================= */
        IF OBJECT_ID('tempdb..#SessionRowsBeforeLast') IS NOT NULL DROP TABLE #SessionRowsBeforeLast;

        SELECT sr.*
        INTO #SessionRowsBeforeLast
        FROM #SessionRows sr
        JOIN #LastRowSession lr
          ON lr.SessionId = sr.SessionId
        WHERE sr.rn < lr.rn;

        /* =========================================================
           9. Classificazione e calcoli sessione
           ========================================================= */
        IF OBJECT_ID('tempdb..#SessionSummary') IS NOT NULL DROP TABLE #SessionSummary;

        SELECT
            s.SessionId,
            s.IdCli,
            s.RechargeIDOperazione,

            RechargeNImp =
                MAX(CASE WHEN sr.IDOperazione = s.RechargeIDOperazione THEN sr.NImp END),

            RechargeData =
                MAX(CASE WHEN sr.IDOperazione = s.RechargeIDOperazione THEN sr.[Data] END),

            RechargeN0 =
                MAX(CASE WHEN sr.IDOperazione = s.RechargeIDOperazione THEN sr.N0 END),

            RechargeF0 =
								MAX(CASE WHEN sr.IDOperazione = s.RechargeIDOperazione THEN CAST(sr.F0 AS int) END),

            RechargeT0 =
                MAX(CASE WHEN sr.IDOperazione = s.RechargeIDOperazione THEN sr.T0 END),

            RechargeD0 =
                MAX(CASE WHEN sr.IDOperazione = s.RechargeIDOperazione THEN sr.D0 END),

            RechargeOperatore =
                MAX(CASE WHEN sr.IDOperazione = s.RechargeIDOperazione THEN sr.Operatore END),

						RechargeWinMt =
								MAX(CASE WHEN sr.IDOperazione = s.RechargeIDOperazione THEN CAST(sr.WinMt AS int) END),

            RechargeFlagOpDaVerificare =
                MAX(CASE WHEN sr.IDOperazione = s.RechargeIDOperazione THEN sr.FlagOpDaVerificare END),

            BonusStartID =
                MAX(CASE WHEN sr.NImp = 6 AND ISNULL(sr.N0,-1) = ISNULL(s.RechargeN0,-1) - 1 THEN sr.IDOperazione END),

            BonusStartData =
                MAX(CASE WHEN sr.NImp = 6 AND ISNULL(sr.N0,-1) = ISNULL(s.RechargeN0,-1) - 1 THEN sr.[Data] END),

            BonusStartN0 =
                MAX(CASE WHEN sr.NImp = 6 AND ISNULL(sr.N0,-1) = ISNULL(s.RechargeN0,-1) - 1 THEN sr.N0 END),

						BonusStartF0 =
								MAX(CASE WHEN sr.NImp = 6 AND ISNULL(sr.N0,-1) = ISNULL(s.RechargeN0,-1) - 1 THEN CAST(sr.F0 AS int) END),

            BonusStartT0 =
                MAX(CASE WHEN sr.NImp = 6 AND ISNULL(sr.N0,-1) = ISNULL(s.RechargeN0,-1) - 1 THEN sr.T0 END),

            BonusStartD0 =
                MAX(CASE WHEN sr.NImp = 6 AND ISNULL(sr.N0,-1) = ISNULL(s.RechargeN0,-1) - 1 THEN sr.D0 END),

            BonusStartOperatore =
                MAX(CASE WHEN sr.NImp = 6 AND ISNULL(sr.N0,-1) = ISNULL(s.RechargeN0,-1) - 1 THEN sr.Operatore END),

						BonusStartWinMt =
								MAX(CASE WHEN sr.NImp = 6 AND ISNULL(sr.N0,-1) = ISNULL(s.RechargeN0,-1) - 1 THEN CAST(sr.WinMt AS int) END),

            BonusStartFlagOpDaVerificare =
                MAX(CASE WHEN sr.NImp = 6 AND ISNULL(sr.N0,-1) = ISNULL(s.RechargeN0,-1) - 1 THEN sr.FlagOpDaVerificare END),

            BonusCaricati =
                SUM(CASE WHEN sr.NImp = 6 THEN ISNULL(sr.ValoreOperazione,0) ELSE 0 END),

            CreditiCaricati =
                SUM(CASE WHEN sr.IDOperazione = s.RechargeIDOperazione THEN ISNULL(sr.ValoreOperazione,0) ELSE 0 END),

            BonusConsumatiPrimaDellUltimo =
                SUM(CASE WHEN b.NImp IS NULL THEN ISNULL(b.ValoreBonus,0) ELSE 0 END),

            CreditiConsumatiPrimaDellUltimo =
                SUM(CASE WHEN b.NImp IS NULL THEN ISNULL(b.ValoreOperazione,0) ELSE 0 END),

            NumeroBonusStart =
                SUM(CASE WHEN sr.NImp = 6 THEN 1 ELSE 0 END),

            NumeroRecharge =
                SUM(CASE WHEN sr.NImp IN (0,1,2,13,14) THEN 1 ELSE 0 END),

            NumeroPartite =
                SUM(CASE WHEN sr.NImp IS NULL THEN 1 ELSE 0 END),

            BadRows =
                SUM(CASE
                        WHEN sr.NImp IN (10,11,15,16,18,19,20) THEN 1
                        WHEN sr.NImp NOT IN (0,1,2,6,13,14) AND sr.NImp IS NOT NULL THEN 1
                        ELSE 0
                    END)

        INTO #SessionSummary
        FROM #Sessioni s
        JOIN #SessionRows sr
          ON sr.SessionId = s.SessionId
        LEFT JOIN #SessionRowsBeforeLast b
          ON b.SessionId = s.SessionId
         AND b.IDOperazione = sr.IDOperazione
        GROUP BY
            s.SessionId,
            s.IdCli,
            s.RechargeIDOperazione,
            s.RechargeN0;

        /* =========================================================
           10. Candidati consolidabili
           ========================================================= */
        IF OBJECT_ID('tempdb..#Candidate') IS NOT NULL DROP TABLE #Candidate;

        SELECT
            ss.SessionId,
            ss.IdCli,
            ss.RechargeNImp,
            ss.RechargeData,
            ss.RechargeN0,
            ss.RechargeF0,
            ss.RechargeT0,
            ss.RechargeD0,
            ss.RechargeOperatore,
            ss.RechargeWinMt,
            ss.RechargeFlagOpDaVerificare,

            ss.BonusStartID,
            ss.BonusStartData,
            ss.BonusStartN0,
            ss.BonusStartF0,
            ss.BonusStartT0,
            ss.BonusStartD0,
            ss.BonusStartOperatore,
            ss.BonusStartWinMt,
            ss.BonusStartFlagOpDaVerificare,

            ss.BonusCaricati,
            ss.CreditiCaricati,
            ss.BonusConsumatiPrimaDellUltimo,
            ss.CreditiConsumatiPrimaDellUltimo,

            BonusResidui = ss.BonusCaricati - ss.BonusConsumatiPrimaDellUltimo,
            CreditiResidui = ss.CreditiCaricati - ss.CreditiConsumatiPrimaDellUltimo,

            lr.NImp AS LastNImp,
            lr.[Data] AS LastData,
            lr.N0 AS LastN0,
            lr.D0 AS LastD0,
            lr.ValoreFinale AS LastValoreFinale,
            lr.ValoreOperazione AS LastValoreOperazione,
            lr.ValoreBonus AS LastValoreBonus,
            lr.F0 AS LastF0,
            lr.T0 AS LastT0,
            lr.Operatore AS LastOperatore,
            lr.WinMt AS LastWinMt,
            lr.FlagOpDaVerificare AS LastFlagOpDaVerificare,
            lr.CodMac AS LastCodMac,
            lr.ValoreCassa AS LastValoreCassa,
            lr.IDOperazione AS LastIDOperazione,

            SaldoPreSessione =
                CASE
                    WHEN ss.BonusStartID IS NOT NULL THEN
                        (
                            SELECT TOP (1)
                                ISNULL(x.ValoreFinale,0) - ISNULL(x.ValoreOperazione,0)
                            FROM #SessionRows x
                            WHERE x.SessionId = ss.SessionId
                              AND x.IDOperazione = ss.BonusStartID
                        )
                    ELSE
                        (
                            SELECT TOP (1)
                                ISNULL(x.ValoreFinale,0) - ISNULL(x.ValoreOperazione,0)
                            FROM #SessionRows x
                            WHERE x.SessionId = ss.SessionId
                              AND x.IDOperazione = ss.RechargeIDOperazione
                        )
                END
        INTO #Candidate
        FROM #SessionSummary ss
        JOIN #LastRowSession lr
          ON lr.SessionId = ss.SessionId
        WHERE ss.NumeroRecharge = 1
          AND ss.BadRows = 0
          AND lr.NImp IS NULL
          AND ss.CreditiCaricati > 0
          AND EXISTS
          (
              SELECT 1
              FROM #SessionRows r
              WHERE r.SessionId = ss.SessionId
                AND r.IDOperazione = ss.RechargeIDOperazione
                AND ISNULL(r.ValoreCassa,0) > 0
          );

        /* filtro più stretto:
           prima dell'ultima solo bonus 6, ricarica iniziale e partite */
        DELETE c
        FROM #Candidate c
        WHERE EXISTS
        (
            SELECT 1
            FROM #SessionRows sr
            WHERE sr.SessionId = c.SessionId
              AND sr.IDOperazione <> c.LastIDOperazione
              AND NOT
              (
                    sr.NImp = 6
                 OR sr.IDOperazione = (SELECT RechargeIDOperazione FROM #Sessioni s WHERE s.SessionId = c.SessionId)
                 OR sr.NImp IS NULL
              )
        );

        SELECT @SessioniConsolidate = COUNT(*) FROM #Candidate;
        SET @SessioniScartate = @SessioniAnalizzate - @SessioniConsolidate;

        /* =========================================================
           11. Backup record originali
           ========================================================= */
        INSERT INTO dbo.TransCard_Consolidamento_Backup
        (
            IdRun, BackupAt, BackupReason, CategoriaSessione, SessionId,
            IdCli, NImp, CodMac, [Data], ValoreOperazione, ValoreFinale,
            ValoreBonus, F0, T0, N0, D0, Operatore, ValoreCassa, WinMt,
            IDOperazione, FlagOpDaVerificare
        )
        SELECT
            @RunId,
            GETDATE(),
            'BACKUP sessione cash con residui',
            'SESSIONE_CASH',
            sr.SessionId,
            sr.IdCli, sr.NImp, sr.CodMac, sr.[Data], sr.ValoreOperazione, sr.ValoreFinale,
            sr.ValoreBonus, sr.F0, sr.T0, sr.N0, sr.D0, sr.Operatore, sr.ValoreCassa, sr.WinMt,
            sr.IDOperazione, sr.FlagOpDaVerificare
        FROM #SessionRows sr
        JOIN #Candidate c
          ON c.SessionId = sr.SessionId;

        INSERT INTO dbo.TransCard_Consolidamento_Map
        (
            IdRun, SessionId, IdCli, CategoriaSessione, ActionType, OldIDOperazione, NewIDOperazione, Note
        )
        SELECT
            @RunId,
            sr.SessionId,
            sr.IdCli,
            'SESSIONE_CASH',
            'BACKUP',
            sr.IDOperazione,
            NULL,
            'Record originale salvato'
        FROM #SessionRows sr
        JOIN #Candidate c
          ON c.SessionId = sr.SessionId;

        /* =========================================================
           12. Delete record originali della sessione
           ========================================================= */
        DELETE tc
        FROM dbo.TransCard tc
        JOIN #SessionRows sr
          ON sr.IDOperazione = tc.IDOperazione
        JOIN #Candidate c
          ON c.SessionId = sr.SessionId;

        /* =========================================================
           13. Insert record sintetici
           ========================================================= */
        IF OBJECT_ID('tempdb..#Inserted') IS NOT NULL DROP TABLE #Inserted;
        CREATE TABLE #Inserted
        (
            SessionId int,
            IdCli varchar(16),
            NewIDOperazione uniqueidentifier,
            ActionNote varchar(50)
        );

        /* 13A bonus sintetico solo se residuo > 0 */
        IF OBJECT_ID('tempdb..#InsBonus6') IS NOT NULL DROP TABLE #InsBonus6;

        SELECT
            c.SessionId,
            c.IdCli,
            NewIDOperazione = NEWID(),
            NImp = 6,
            CodMac = 'CASSA1',
            [Data] = c.BonusStartData,
            ValoreOperazione = c.BonusResidui,
            ValoreFinale = c.SaldoPreSessione + c.BonusResidui,
            ValoreBonus = CAST(0 AS money),
            F0 = c.BonusStartF0,
            T0 = c.BonusStartT0,
            N0 = c.BonusStartN0,
            D0 = c.BonusStartD0,
            Operatore = c.BonusStartOperatore,
            ValoreCassa = CAST(0 AS money),
            WinMt = c.BonusStartWinMt,
            FlagOpDaVerificare = c.BonusStartFlagOpDaVerificare
        INTO #InsBonus6
        FROM #Candidate c
        WHERE c.BonusStartID IS NOT NULL
          AND ISNULL(c.BonusResidui,0) > 0;

        INSERT INTO dbo.TransCard
        (
            IdCli, NImp, CodMac, [Data], ValoreOperazione, ValoreFinale,
            ValoreBonus, F0, T0, N0, D0, Operatore, ValoreCassa, WinMt,
            IDOperazione, FlagOpDaVerificare
        )
        SELECT
            IdCli, NImp, CodMac, [Data], ValoreOperazione, ValoreFinale,
            ValoreBonus, F0, T0, N0, D0, Operatore, ValoreCassa, WinMt,
            NewIDOperazione, FlagOpDaVerificare
        FROM #InsBonus6;

        INSERT INTO #Inserted (SessionId, IdCli, NewIDOperazione, ActionNote)
        SELECT SessionId, IdCli, NewIDOperazione, 'INSERT_BONUS6'
        FROM #InsBonus6;

        /* 13B ricarica sintetica solo se residuo > 0 */
        IF OBJECT_ID('tempdb..#InsCash') IS NOT NULL DROP TABLE #InsCash;

        SELECT
            c.SessionId,
            c.IdCli,
            NewIDOperazione = NEWID(),
            NImp = c.RechargeNImp,
            CodMac = 'CASSA1',
            [Data] = c.RechargeData,
            ValoreOperazione = c.CreditiResidui,
            ValoreFinale =
                c.SaldoPreSessione
                + CASE WHEN ISNULL(c.BonusResidui,0) > 0 THEN c.BonusResidui ELSE 0 END
                + c.CreditiResidui,
            ValoreBonus = CAST(0 AS money),
            F0 = c.RechargeF0,
            T0 = c.RechargeT0,
            N0 = c.RechargeN0,
            D0 = c.RechargeD0,
            Operatore = c.RechargeOperatore,
            ValoreCassa = c.CreditiResidui,
            WinMt = c.RechargeWinMt,
            FlagOpDaVerificare = c.RechargeFlagOpDaVerificare
        INTO #InsCash
        FROM #Candidate c
        WHERE ISNULL(c.CreditiResidui,0) > 0;

        INSERT INTO dbo.TransCard
        (
            IdCli, NImp, CodMac, [Data], ValoreOperazione, ValoreFinale,
            ValoreBonus, F0, T0, N0, D0, Operatore, ValoreCassa, WinMt,
            IDOperazione, FlagOpDaVerificare
        )
        SELECT
            IdCli, NImp, CodMac, [Data], ValoreOperazione, ValoreFinale,
            ValoreBonus, F0, T0, N0, D0, Operatore, ValoreCassa, WinMt,
            NewIDOperazione, FlagOpDaVerificare
        FROM #InsCash;

        INSERT INTO #Inserted (SessionId, IdCli, NewIDOperazione, ActionNote)
        SELECT SessionId, IdCli, NewIDOperazione, 'INSERT_CASH'
        FROM #InsCash;

        /* 13C ultima partita invariata */
        IF OBJECT_ID('tempdb..#InsLast') IS NOT NULL DROP TABLE #InsLast;

        SELECT
            c.SessionId,
            c.IdCli,
            NewIDOperazione = NEWID(),
            NImp = CAST(NULL AS int),
            CodMac = c.LastCodMac,
            [Data] = c.LastData,
            ValoreOperazione = c.LastValoreOperazione,
            ValoreFinale = c.LastValoreFinale,
            ValoreBonus = c.LastValoreBonus,
            F0 = c.LastF0,
            T0 = c.LastT0,
            N0 = c.LastN0,
            D0 = c.LastD0,
            Operatore = c.LastOperatore,
            ValoreCassa = c.LastValoreCassa,
            WinMt = c.LastWinMt,
            FlagOpDaVerificare = c.LastFlagOpDaVerificare
        INTO #InsLast
        FROM #Candidate c;

        INSERT INTO dbo.TransCard
        (
            IdCli, NImp, CodMac, [Data], ValoreOperazione, ValoreFinale,
            ValoreBonus, F0, T0, N0, D0, Operatore, ValoreCassa, WinMt,
            IDOperazione, FlagOpDaVerificare
        )
        SELECT
            IdCli, NImp, CodMac, [Data], ValoreOperazione, ValoreFinale,
            ValoreBonus, F0, T0, N0, D0, Operatore, ValoreCassa, WinMt,
            NewIDOperazione, FlagOpDaVerificare
        FROM #InsLast;

        INSERT INTO #Inserted (SessionId, IdCli, NewIDOperazione, ActionNote)
        SELECT SessionId, IdCli, NewIDOperazione, 'INSERT_LAST'
        FROM #InsLast;

        INSERT INTO dbo.TransCard_Consolidamento_Map
        (
            IdRun, SessionId, IdCli, CategoriaSessione, ActionType, OldIDOperazione, NewIDOperazione, Note
        )
        SELECT
            @RunId,
            i.SessionId,
            i.IdCli,
            'SESSIONE_CASH',
            'INSERT',
            NULL,
            i.NewIDOperazione,
            i.ActionNote
        FROM #Inserted i;

        /* totale ricariche dopo il consolidamento:
           sintetici scritti dalla procedura nel range */
				DECLARE @TotaleRicaricheSinteticheGenerate money = 0;
				DECLARE @TotaleRicaricheOriginaliNonToccate money = 0;

				SELECT
						@TotaleRicaricheSinteticheGenerate =
								ISNULL((SELECT SUM(ISNULL(ValoreOperazione,0)) FROM #InsBonus6), 0)
								+
								ISNULL((SELECT SUM(ISNULL(ValoreOperazione,0)) FROM #InsCash), 0);

				SELECT
						@TotaleRicaricheOriginaliNonToccate =
								ISNULL(SUM(CASE WHEN m.NImp IN (0,1,2,13,14,6) THEN ISNULL(m.ValoreOperazione,0) ELSE 0 END), 0)
				FROM #Mov m
				WHERE NOT EXISTS
				(
						SELECT 1
						FROM #SessionRows sr
						JOIN #Candidate c
							ON c.SessionId = sr.SessionId
						WHERE sr.IDOperazione = m.IDOperazione
				);

				SET @TotaleRicaricheDopo =
						ISNULL(@TotaleRicaricheOriginaliNonToccate,0)
						+ ISNULL(@TotaleRicaricheSinteticheGenerate,0);

        /* =========================================================
           14. Audit finale
           ========================================================= */
        /* =========================================================
           14. Audit finale
           ========================================================= */

				/* A) Riepilogo delle sole sessioni consolidate */
				SELECT
						CategoriaSessione = 'SESSIONE_CASH',
						COUNT(*) AS NumeroSessioni,
						SUM(ISNULL(c.CreditiCaricati,0) + ISNULL(c.BonusCaricati,0)) AS TotaleRicarichePrimaCandidate,
						SUM(
								CASE WHEN ISNULL(c.BonusResidui,0) > 0 THEN c.BonusResidui ELSE 0 END
								+
								CASE WHEN ISNULL(c.CreditiResidui,0) > 0 THEN c.CreditiResidui ELSE 0 END
						) AS TotaleRicaricheDopoCandidate,
						SUM(
								(
										CASE WHEN ISNULL(c.BonusResidui,0) > 0 THEN c.BonusResidui ELSE 0 END
										+
										CASE WHEN ISNULL(c.CreditiResidui,0) > 0 THEN c.CreditiResidui ELSE 0 END
								)
								-
								(ISNULL(c.CreditiCaricati,0) + ISNULL(c.BonusCaricati,0))
						) AS DeltaRicaricheCandidate,
						SUM(ISNULL(c.LastValoreFinale,0)) AS TotaleValoreFinaleUltimaPartita
				FROM #Candidate c;

				/* B) Riepilogo complessivo del range prima/dopo corretto */
				SELECT
						@RunId AS IdRun,
						@RangeStart AS DataInizio,
						@RangeEnd AS DataFine,
						@SessioniAnalizzate AS SessioniAnalizzate,
						@SessioniConsolidate AS SessioniConsolidate,
						@SessioniScartate AS SessioniScartate,
						@TotaleRicarichePrima AS TotaleRicarichePrimaNelRange,
						@TotaleRicaricheOriginaliNonToccate AS TotaleRicaricheOriginaliNonToccateNelRange,
						@TotaleRicaricheSinteticheGenerate AS TotaleRicaricheSinteticheGenerate,
						@TotaleRicaricheDopo AS TotaleRicaricheDopoNelRange,
						@TotaleRicaricheDopo - @TotaleRicarichePrima AS DeltaRicaricheNelRange,
						@DryRun AS DryRun;

        UPDATE dbo.TransCard_Consolidamento_Log
        SET
            EndedAt = GETDATE(),
            Status = CASE WHEN @DryRun = 1 THEN 'DRYRUN' ELSE 'COMPLETED' END,
            SessioniAnalizzate = @SessioniAnalizzate,
            SessioniConsolidate = @SessioniConsolidate,
            SessioniScartate = @SessioniScartate,
						Note =
								CONCAT(
										'RicarichePrimaNelRange=', CONVERT(varchar(50), @TotaleRicarichePrima),
										'; OriginaliNonToccate=', CONVERT(varchar(50), @TotaleRicaricheOriginaliNonToccate),
										'; SinteticheGenerate=', CONVERT(varchar(50), @TotaleRicaricheSinteticheGenerate),
										'; RicaricheDopoNelRange=', CONVERT(varchar(50), @TotaleRicaricheDopo)
								)
        WHERE IdRun = @RunId;

        IF @DryRun = 1
            ROLLBACK TRAN;
        ELSE
            COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN;

        IF @RunId IS NOT NULL
        BEGIN
            UPDATE dbo.TransCard_Consolidamento_Log
            SET
                EndedAt = GETDATE(),
                Status = 'ERROR',
                Note = ERROR_MESSAGE()
            WHERE IdRun = @RunId;
        END;

        THROW;
    END CATCH
END;
