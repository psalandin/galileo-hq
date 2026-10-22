CREATE PROCEDURE [dbo].[decodifica_record]
  @device               VARCHAR(16),
  @comando              VARCHAR(255),
  @logdate              DATETIME2,
  @FlagOpDaVerificare   INT
AS
BEGIN
  SET NOCOUNT ON;
  SET XACT_ABORT ON;

  -- Transazione con supporto a transazioni annidate (savepoint)
  DECLARE @sp_tran_started BIT = 0;
  IF @@TRANCOUNT = 0
  BEGIN
      BEGIN TRAN;
      SET @sp_tran_started = 1;
  END
  ELSE
  BEGIN
      SAVE TRAN decodifica_record_sp;
  END

  BEGIN TRY
      -----------------------------------------------------------------------
      -- 0) Inizializzazioni
      -----------------------------------------------------------------------
      DECLARE @multilocale                 INT  = 0; -- compatibilità
      DECLARE @verificaDoppioneProgressivo INT  = 0;

      -- Soglia anti-frode "RFID non scrivibile" (vedi Migration/AntifrodeCardRfidNonScrivibile.sql):
      -- configurabile da setup2, fallback a 3 se la chiave manca o non e' un numero valido.
      DECLARE @maxTentativiNonConfermati INT;
      SELECT @maxTentativiNonConfermati = TRY_CONVERT(INT, Valore)
      FROM dbo.setup2
      WHERE IdPost = 101 AND Chiave = N'MaxTentativiNonConfermati';
      SET @maxTentativiNonConfermati = ISNULL(@maxTentativiNonConfermati, 3);

      -----------------------------------------------------------------------
      -- 1) Split inline del payload in @cmdtable (compatibile, senza UDF)
      -----------------------------------------------------------------------
      DECLARE @cmdtable TABLE (row BIGINT NOT NULL, item VARCHAR(100) NULL);
      DECLARE @xml XML;

      -- sostituisco solo & per sicurezza XML basilare
      SET @xml = CONVERT(XML, N'<r><v>' +
                REPLACE(REPLACE(LTRIM(RTRIM(@comando)),'&','&amp;'),';','</v><v>')
              + N'</v></r>');

      INSERT INTO @cmdtable(row, item)
      SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 1)),
             LTRIM(RTRIM(T.c.value('.','varchar(100)')))
      FROM   @xml.nodes('/r/v') AS T(c);

      -----------------------------------------------------------------------
      -- 2) Tipo record
      -----------------------------------------------------------------------
      DECLARE @tiporecord INT;

      SELECT @tiporecord =
             CONVERT(INT,
               CONVERT(VARBINARY,
                 CASE WHEN LEN(LTRIM(RTRIM(item))) % 2 = 0 THEN '0x' ELSE '0x0' END + LTRIM(RTRIM(item)), 1)
             )
      FROM @cmdtable
      WHERE row = 3;

      -----------------------------------------------------------------------
      -- 3) Tipo 7: telemetria/snapshot -> CoinlessDecodedData
      -----------------------------------------------------------------------
      IF @tiporecord = 7
      BEGIN
          INSERT INTO CoinlessDecodedData
          ( device, datastore, [Header], risposta, cmd_inviato, numbyte, dataril,
            partite, tickets, cnt3, cnt4, cnt5, cnt6, cnt7, cnt8, gettoni, tipocard, datarec )
          SELECT
            @device, GETDATE(),
            (SELECT CONVERT(INT, CONVERT(VARBINARY, CASE WHEN LEN(LTRIM(RTRIM(item)))%2=0 THEN '0x' ELSE '0x0' END + LTRIM(RTRIM(item)),1)) FROM @cmdtable WHERE row=1),
            (SELECT CONVERT(INT, CONVERT(VARBINARY, CASE WHEN LEN(LTRIM(RTRIM(item)))%2=0 THEN '0x' ELSE '0x0' END + LTRIM(RTRIM(item)),1)) FROM @cmdtable WHERE row=2),
            (SELECT CONVERT(INT, CONVERT(VARBINARY, CASE WHEN LEN(LTRIM(RTRIM(item)))%2=0 THEN '0x' ELSE '0x0' END + LTRIM(RTRIM(item)),1)) FROM @cmdtable WHERE row=3),
            (SELECT CONVERT(INT, CONVERT(VARBINARY, CASE WHEN LEN(LTRIM(RTRIM(item)))%2=0 THEN '0x' ELSE '0x0' END + LTRIM(RTRIM(item)),1)) FROM @cmdtable WHERE row=4),
            GETDATE(),

            -- partite: 48..45
            CONVERT(VARCHAR(10), CONVERT(BIGINT,
                CONVERT(VARBINARY,'0x' + (SELECT RIGHT('00'+item,2) FROM @cmdtable WHERE row=48)
                                       + (SELECT RIGHT('00'+item,2) FROM @cmdtable WHERE row=47),1)
              + CONVERT(VARBINARY,'0x' + (SELECT RIGHT('00'+item,2) FROM @cmdtable WHERE row=46)
                                       + (SELECT RIGHT('00'+item,2) FROM @cmdtable WHERE row=45),1)
            )),

            -- tickets: 20..17
            CONVERT(VARCHAR(10), CONVERT(BIGINT,
              CONVERT(VARBINARY,'0x' + (SELECT RIGHT('00'+item,2) FROM @cmdtable WHERE row=20)
                                     + (SELECT RIGHT('00'+item,2) FROM @cmdtable WHERE row=19)
                                     + (SELECT RIGHT('00'+item,2) FROM @cmdtable WHERE row=18)
                                     + (SELECT RIGHT('00'+item,2) FROM @cmdtable WHERE row=17),1)
            )),

            -- cnt3..cnt8
            CONVERT(VARCHAR(10), CONVERT(BIGINT, CONVERT(VARBINARY,'0x' + (SELECT RIGHT('00'+item,2) FROM @cmdtable WHERE row=24)
                                                                        + (SELECT RIGHT('00'+item,2) FROM @cmdtable WHERE row=23)
                                                                        + (SELECT RIGHT('00'+item,2) FROM @cmdtable WHERE row=22)
                                                                        + (SELECT RIGHT('00'+item,2) FROM @cmdtable WHERE row=21),1))),
            CONVERT(VARCHAR(10), CONVERT(BIGINT, CONVERT(VARBINARY,'0x' + (SELECT RIGHT('00'+item,2) FROM @cmdtable WHERE row=28)
                                                                        + (SELECT RIGHT('00'+item,2) FROM @cmdtable WHERE row=27)
                                                                        + (SELECT RIGHT('00'+item,2) FROM @cmdtable WHERE row=26)
                                                                        + (SELECT RIGHT('00'+item,2) FROM @cmdtable WHERE row=25),1))),
            CONVERT(VARCHAR(10), CONVERT(BIGINT, CONVERT(VARBINARY,'0x' + (SELECT RIGHT('00'+item,2) FROM @cmdtable WHERE row=32)
                                                                        + (SELECT RIGHT('00'+item,2) FROM @cmdtable WHERE row=31)
                                                                        + (SELECT RIGHT('00'+item,2) FROM @cmdtable WHERE row=30)
                                                                        + (SELECT RIGHT('00'+item,2) FROM @cmdtable WHERE row=29),1))),
            CONVERT(VARCHAR(10), CONVERT(BIGINT, CONVERT(VARBINARY,'0x' + (SELECT RIGHT('00'+item,2) FROM @cmdtable WHERE row=36)
                                                                        + (SELECT RIGHT('00'+item,2) FROM @cmdtable WHERE row=35)
                                                                        + (SELECT RIGHT('00'+item,2) FROM @cmdtable WHERE row=34)
                                                                        + (SELECT RIGHT('00'+item,2) FROM @cmdtable WHERE row=33),1))),
            CONVERT(VARCHAR(10), CONVERT(BIGINT, CONVERT(VARBINARY,'0x' + (SELECT RIGHT('00'+item,2) FROM @cmdtable WHERE row=40)
                                                                        + (SELECT RIGHT('00'+item,2) FROM @cmdtable WHERE row=39)
                                                                        + (SELECT RIGHT('00'+item,2) FROM @cmdtable WHERE row=38)
                                                                        + (SELECT RIGHT('00'+item,2) FROM @cmdtable WHERE row=37),1))),
            CONVERT(VARCHAR(10), CONVERT(BIGINT, CONVERT(VARBINARY,'0x' + (SELECT RIGHT('00'+item,2) FROM @cmdtable WHERE row=44)
                                                                        + (SELECT RIGHT('00'+item,2) FROM @cmdtable WHERE row=43)
                                                                        + (SELECT RIGHT('00'+item,2) FROM @cmdtable WHERE row=42)
                                                                        + (SELECT RIGHT('00'+item,2) FROM @cmdtable WHERE row=41),1))),

            -- crediti: 16..13
            CONVERT(VARCHAR(10), CONVERT(BIGINT, CONVERT(VARBINARY,'0x' + (SELECT RIGHT('00'+item,2) FROM @cmdtable WHERE row=16)
                                                                        + (SELECT RIGHT('00'+item,2) FROM @cmdtable WHERE row=15)
                                                                        + (SELECT RIGHT('00'+item,2) FROM @cmdtable WHERE row=14)
                                                                        + (SELECT RIGHT('00'+item,2) FROM @cmdtable WHERE row=13),1))),

            -- tipo_card: 49
            CONVERT(VARCHAR(10), CONVERT(BIGINT,
              CONVERT(VARBINARY,'0x' + (SELECT RIGHT('0000'+item,4) FROM @cmdtable WHERE row=49),1)
            )),
            @logdate
          ;
      END
      ELSE IF @tiporecord IN (8,13,19,20,22,23)
      BEGIN
          -------------------------------------------------------------------
          -- Variabili per transazioni con card
          -------------------------------------------------------------------
          DECLARE
              @idcard                  VARCHAR(8),
              @valoreUltimoSaldo       BIGINT,
              @valoreNuovoSaldo        BIGINT,
              @valoreNuovoCostoPartita BIGINT,
              @valoreNuovoBonus        BIGINT,
              @n0                      BIGINT,
              @dt                      DATETIME,
              @progressivo             INT,
              @moltiplicatore          MONEY,
              @puntiocrediti           INT,
              @idcontatto              BIGINT,
              @progressivogiausato     BIGINT,
              @lsMotivo                VARCHAR(512),
              @lsLogDebug              VARCHAR(512),
              @livellocard             INT,
              @datatransazione         DATETIME,
              @hadProvisional          INT = 0,
              @yy INT, @mm INT, @dd INT, @hh INT, @mi INT, @ss INT;

          SET @moltiplicatore = (SELECT dbo.CreditToCurrency(1));

          -- progressivo N0: 8..5
          SET @progressivo = CONVERT(INT,
                              CONVERT(VARBINARY,'0x' +
                                 (SELECT RIGHT('00'+item,2) FROM @cmdtable WHERE row=8) +
                                 (SELECT RIGHT('00'+item,2) FROM @cmdtable WHERE row=7) +
                                 (SELECT RIGHT('00'+item,2) FROM @cmdtable WHERE row=6) +
                                 (SELECT RIGHT('00'+item,2) FROM @cmdtable WHERE row=5),1)
                            );

          -------------------------------------------------------------------
          -- Branch 8/13 (device collegati via cavo)
          -------------------------------------------------------------------
          IF @tiporecord IN (8,13)
          BEGIN
              -- card id: 21..24
              SET @idcard = (SELECT ISNULL(RIGHT('00'+item,2),'00') FROM @cmdtable WHERE row=21)
                          + (SELECT ISNULL(RIGHT('00'+item,2),'00') FROM @cmdtable WHERE row=22)
                          + (SELECT ISNULL(RIGHT('00'+item,2),'00') FROM @cmdtable WHERE row=23)
                          + (SELECT ISNULL(RIGHT('00'+item,2),'00') FROM @cmdtable WHERE row=24);

              SET @idcontatto = (
                  SELECT TOP (1) dbo.fn_idcliente(c.IdContatto, c.idlong)
                  FROM Clienti AS c
                  WHERE c.t0 = @idcard + '00000000'
              );

              -- saldo nuovo: 20..17
              SET @valoreNuovoSaldo = CONVERT(BIGINT,
                CONVERT(VARBINARY,'0x' +
                  (SELECT RIGHT('00'+item,2) FROM @cmdtable WHERE row=20) +
                  (SELECT RIGHT('00'+item,2) FROM @cmdtable WHERE row=19) +
                  (SELECT RIGHT('00'+item,2) FROM @cmdtable WHERE row=18) +
                  (SELECT RIGHT('00'+item,2) FROM @cmdtable WHERE row=17),1)
              );

              -- costo partita: 29
              SET @valoreNuovoCostoPartita = CONVERT(BIGINT,
                CONVERT(VARBINARY,'0x' + (SELECT RIGHT('0000'+item,4) FROM @cmdtable WHERE row=29),1)
              );

              -- duplicati
              SET @progressivogiausato = (SELECT COUNT(*) FROM transcard WHERE idcli=@idcontatto AND N0=@progressivo);

              -- puntiocrediti: 31
              SET @puntiocrediti = CONVERT(INT,
                  CONVERT(VARBINARY,'0x' + (SELECT RIGHT('00'+item,2) FROM @cmdtable WHERE row=31),1)
              );

              -- ultimo saldo noto
              SELECT TOP (1)
                     @n0                = tc.N0,
                     @valoreUltimoSaldo = tc.ValoreFinale / @moltiplicatore,
                     @dt                = DATEADD(MILLISECOND, tc.N0, tc.data)
              FROM TransCard AS tc
              INNER JOIN Clienti AS c
                      ON tc.IdCli = CONVERT(VARCHAR(30), dbo.fn_idcliente(c.IdContatto, c.idlong))
              WHERE c.t0 = @idcard + '00000000'
                AND tc.N0 <= @progressivo
				AND isnull(tc.nimp,-1) not in(12)
              ORDER BY tc.N0 DESC;

              -- CoinlessCards upsert minimale
              IF NOT EXISTS (SELECT 1 FROM dbo.CoinlessCards WHERE cardid=@idcard)
              BEGIN
                  INSERT INTO dbo.CoinlessCards (cardid, IdContatto, SaldoUltimaRicarica, SaldoUltimaPresentazione)
                  VALUES (@idcard, ISNULL(@idcontatto,0), @valoreUltimoSaldo, @valoreUltimoSaldo);
              END

              SET @datatransazione = GETDATE();
              SET @livellocard = CONVERT(INT,
                CONVERT(VARBINARY,'0x' + (SELECT RIGHT('0000'+item,4) FROM @cmdtable WHERE row=30),1)
              );
          END
          ELSE
          -------------------------------------------------------------------
          -- Branch 19/20/22/23 (giochi/BE; )
          -------------------------------------------------------------------
          BEGIN
              -- card id: 17..20
              SET @idcard = (SELECT ISNULL(RIGHT('00'+item,2),'00') FROM @cmdtable WHERE row=17)
                          + (SELECT ISNULL(RIGHT('00'+item,2),'00') FROM @cmdtable WHERE row=18)
                          + (SELECT ISNULL(RIGHT('00'+item,2),'00') FROM @cmdtable WHERE row=19)
                          + (SELECT ISNULL(RIGHT('00'+item,2),'00') FROM @cmdtable WHERE row=20);

              SET @idcontatto = (
                  SELECT TOP (1) dbo.fn_idcliente(c.IdContatto, c.idlong)
                  FROM Clienti AS c
                  WHERE c.t0 = @idcard + '00000000'
              );

              -- saldo nuovo: 16..13
              SET @valoreNuovoSaldo = CONVERT(BIGINT,
                CONVERT(VARBINARY,'0x' +
                  (SELECT RIGHT('00'+item,2) FROM @cmdtable WHERE row=16) +
                  (SELECT RIGHT('00'+item,2) FROM @cmdtable WHERE row=15) +
                  (SELECT RIGHT('00'+item,2) FROM @cmdtable WHERE row=14) +
                  (SELECT RIGHT('00'+item,2) FROM @cmdtable WHERE row=13),1)
              );

              -- costo partita: 26..25
              SET @valoreNuovoCostoPartita = CONVERT(BIGINT,
                CONVERT(VARBINARY,'0x' +
                  (SELECT RIGHT('00'+item,2) FROM @cmdtable WHERE row=26) +
                  (SELECT RIGHT('00'+item,2) FROM @cmdtable WHERE row=25),1)
              );

              -- bonus: 38..37
              SET @valoreNuovoBonus = CONVERT(BIGINT,
                CONVERT(VARBINARY,'0x' +
                  (SELECT RIGHT('00'+item,2) FROM @cmdtable WHERE row=38) +
                  (SELECT RIGHT('00'+item,2) FROM @cmdtable WHERE row=37),1)
              );

              -- verifico se esisteva una provvisoria (da verificare)
              SET @hadProvisional = (
                  SELECT COUNT(*)
                  FROM transcard
                  WHERE idcli = @idcontatto
                    AND N0    = @progressivo
                    AND FlagOpDaVerificare = 1
              );

              -- elimino provvisorie duplicate
              DELETE FROM transcard
              WHERE idcli = @idcontatto
                AND N0    = @progressivo
                AND FlagOpDaVerificare = 1;

              -- duplicati esatti presenti
              SET @progressivogiausato = (SELECT COUNT(*) FROM transcard WHERE idcli=@idcontatto AND N0=@progressivo);

              -- doppione "perfetto" per tipo 23
              IF @progressivogiausato > 0 AND @tiporecord = 23
              BEGIN
                  SET @verificaDoppioneProgressivo = (
                      SELECT COUNT(*)
                      FROM transcard
                      WHERE idcli = @idcontatto
                        AND N0    = @progressivo
                        AND ValoreFinale = @valoreNuovoSaldo * @moltiplicatore
                        AND ValoreBonus  = @valoreNuovoBonus * @moltiplicatore
                  );
              END

              -- puntiocrediti: 28
              SET @puntiocrediti = CONVERT(INT,
                  CONVERT(VARBINARY,'0x' + (SELECT RIGHT('00'+item,2) FROM @cmdtable WHERE row=28),1)
              );

              -- ultimo saldo noto
              SELECT TOP (1)
                     @n0                = tc.N0,
                     @valoreUltimoSaldo = tc.ValoreFinale / @moltiplicatore,
                     @dt                = DATEADD(MILLISECOND, tc.N0, tc.data)
              FROM TransCard AS tc
              INNER JOIN Clienti AS c
                      ON tc.IdCli = CONVERT(VARCHAR(30), dbo.fn_idcliente(c.IdContatto, c.idlong))
              WHERE c.t0 = @idcard + '00000000'
                AND tc.N0 <= @progressivo
				AND isnull(tc.nimp,-1) not in(12)
              ORDER BY tc.N0 DESC;


              -- CoinlessCards upsert minimale
              IF NOT EXISTS (SELECT 1 FROM dbo.CoinlessCards WHERE cardid=@idcard)
              BEGIN
                  INSERT INTO dbo.CoinlessCards (cardid, IdContatto, SaldoUltimaRicarica, SaldoUltimaPresentazione)
                  VALUES (@idcard, ISNULL(@idcontatto,0), @valoreUltimoSaldo, @valoreUltimoSaldo);
              END

              -----------------------------------------------------------------------------------
              -- Anti-frode "RFID non scrivibile" (emergenza 2026-10-07): una card manomessa in
              -- modo che il device non riesca mai a scrivere l'esito ripresenta all'infinito la
              -- stessa giocata come "non confermata" (FlagOpDaVerificare=1, stesso progressivo).
              -- Senza questo contatore decodifica_record la riaccetta ogni volta come un retry
              -- legittimo (vedi @hadProvisional sotto) e rilancia scriviTicketsAutomatici ad ogni
              -- ripresentazione. Qui si conta quante volte CONSECUTIVE accade per la stessa card
              -- sullo stesso progressivo e, raggiunta @maxTentativiNonConfermati (setup2 IdPost=101
              -- Chiave='MaxTentativiNonConfermati', fallback 3), si marca BlackList=1 (colonna esistente,
              -- gia' letta da DBwinmt.getBlackList/verificaBlackList per il push MQTT alle BE:
              -- quella chiamata avviene comunque ad ogni "send_client", quindi basta aspettare la
              -- prossima transazione di questa stessa card per vederla bloccata lato scheda).
              --
              -- Si azzera quando arriva la vera conferma di quel progressivo (Flag=0) o quando il
              -- progressivo e' avanzato oltre quello che si stava contando (vuol dire che la
              -- scrittura RFID e' riuscita per davvero).
              UPDATE dbo.CoinlessCards
                 SET TentativiNonConfermati = 0,
                     UltimoN0NonConfermato  = NULL
               WHERE cardid = @idcard
                 AND UltimoN0NonConfermato IS NOT NULL
                 AND ( (@FlagOpDaVerificare = 0 AND UltimoN0NonConfermato = @progressivo)
                    OR (@progressivo > UltimoN0NonConfermato) );

              IF @FlagOpDaVerificare = 1
              BEGIN
                  UPDATE dbo.CoinlessCards
                     SET TentativiNonConfermati =
                           CASE WHEN UltimoN0NonConfermato = @progressivo THEN TentativiNonConfermati + 1 ELSE 1 END,
                         UltimoN0NonConfermato = @progressivo
                   WHERE cardid = @idcard;

                  UPDATE dbo.CoinlessCards
                     SET BlackList = 1
                   WHERE cardid = @idcard AND TentativiNonConfermati >= @maxTentativiNonConfermati AND ISNULL(BlackList,0) = 0;

                  IF EXISTS (SELECT 1 FROM dbo.CoinlessCards WHERE cardid = @idcard AND TentativiNonConfermati = @maxTentativiNonConfermati)
                      INSERT INTO CoinlessLogEventiBlacklist (testo, cardid)
                      VALUES ('Auto-blacklist: ' + CONVERT(VARCHAR(10),@maxTentativiNonConfermati) +
                               ' presentazioni consecutive non confermate (N0=' +
                               ISNULL(CONVERT(VARCHAR(20),@progressivo),'') + ', device=' + ISNULL(@device,'') + ')',
                              UPPER(@idcard));
              END
              -----------------------------------------------------------------------------------

              -- decodifica data (componenti)
              SET @yy = CONVERT(INT, CONVERT(VARBINARY,'0x' + (SELECT RIGHT('00'+item,2) FROM @cmdtable WHERE row=32)
                                                       + (SELECT RIGHT('00'+item,2) FROM @cmdtable WHERE row=31),1));
              SET @mm = CONVERT(INT, CONVERT(VARBINARY,'0x' + (SELECT RIGHT('00'+item,2) FROM @cmdtable WHERE row=30),1));
              SET @dd = CONVERT(INT, CONVERT(VARBINARY,'0x' + (SELECT RIGHT('00'+item,2) FROM @cmdtable WHERE row=29),1));
              SET @hh = CONVERT(INT, CONVERT(VARBINARY,'0x' + (SELECT RIGHT('00'+item,2) FROM @cmdtable WHERE row=33),1));
              SET @mi = CONVERT(INT, CONVERT(VARBINARY,'0x' + (SELECT RIGHT('00'+item,2) FROM @cmdtable WHERE row=34),1));
              SET @ss = CONVERT(INT, CONVERT(VARBINARY,'0x' + (SELECT RIGHT('00'+item,2) FROM @cmdtable WHERE row=35),1));

              IF @yy > 2020
              BEGIN
                  SET @datatransazione =
                      CONVERT(DATETIME,
                          RIGHT('0000' + CONVERT(VARCHAR(4),@yy),4) + '-' +
                          RIGHT('00'   + CONVERT(VARCHAR(2),@mm),2) + '-' +
                          RIGHT('00'   + CONVERT(VARCHAR(2),@dd),2) + ' ' +
                          RIGHT('00'   + CONVERT(VARCHAR(2),@hh),2) + ':' +
                          RIGHT('00'   + CONVERT(VARCHAR(2),@mi),2) + ':' +
                          RIGHT('00'   + CONVERT(VARCHAR(2),@ss),2)
                      , 120);
              END
              ELSE
              BEGIN
                  SET @datatransazione = CONVERT(DATETIME, @dt);
              END

              -- livello card: 27
              SET @livellocard = CONVERT(INT,
                CONVERT(VARBINARY,'0x' + (SELECT RIGHT('0000'+item,4) FROM @cmdtable WHERE row=27),1)
              );

              -- Il 23 è conferma definitiva: non "da verificare"
              
          END

          -------------------------------------------------------------------
          -- Validazione e scritture
          -------------------------------------------------------------------
          IF (ISNULL(@valoreUltimoSaldo,0) >= @valoreNuovoSaldo OR (ISNULL(@n0,0) < @progressivo) )
             
             AND (@progressivogiausato = 0)
             AND (ISNULL(@idcontatto,0) > 0)
          BEGIN
              UPDATE Clienti
              SET credito = @valoreNuovoSaldo
              WHERE T0 = UPPER(@idcard) + '00000000';

              INSERT INTO CoinlessTransazioniCards
              ( device, CodMac, cardid, DataMovimento, TipoMovimento,
                SaldoCard, CostoPartita, LivelloCard, N0, Bonus, FlagOpDaVerificare )
              SELECT
                @device,
                ISNULL((SELECT codmac FROM EcsMacchine WHERE device=@device), ''),
                UPPER(@idcard),
                @datatransazione,
                'Scarico',
                @valoreNuovoSaldo,
                @valoreNuovoCostoPartita,
                @livellocard,
                @progressivo,
                @valoreNuovoBonus,
                @FlagOpDaVerificare;

              EXEC scriviTicketsAutomatici @idcard, @device;

							IF @tiporecord IN (19,20) -- transazione con card da device senza BI devo emulare la registrazione in ecsdati
							BEGIN
									-- Prelevo l'ultimo snapshot per il device (se esiste) e calcolo i campi da reinserire
									DECLARE
											@ins_header   INT,
											@ins_risposta INT,
											@ins_cmd      INT,
											@ins_numbyte  INT,
											@ins_crediti  BIGINT,
											@ins_tickets  BIGINT,
											@ins_tipocard INT,
											@ins_partite  INT;

									SELECT TOP (1)
											@ins_header   = Header,
											@ins_risposta = risposta,
											@ins_cmd      = cmd_inviato,
											@ins_numbyte  = numbyte,
											@ins_crediti  = crediti,
											@ins_tickets  = tickets,
											@ins_tipocard = tipocard,
											@ins_partite  = partite + 1
									FROM dbo.CoinlessDecodedData
									WHERE device = @device
									ORDER BY dataril DESC;

									-- Se non esiste nessun record precedente, imposto i default 
									IF @ins_partite IS NULL
									BEGIN
											SET @ins_header   = 3;
											SET @ins_risposta = 0;
											SET @ins_cmd      = 7;
											SET @ins_numbyte  = 48;
											SET @ins_crediti  = NULL;
											SET @ins_tickets  = 0;
											SET @ins_tipocard = 0;
											SET @ins_partite  = 1;
									END

									-- Inserisco il "record di servizio" allineando il datario con la transazione
									INSERT INTO CoinlessDecodedData
									(
											device, datastore, Header, risposta, cmd_inviato, numbyte, dataril,
											crediti, tickets, cnt3, cnt4, cnt5, cnt6, cnt7, cnt8, gettoni,
											tipocard, datarec, partite, carduid, saldocard
									)
									VALUES
									(
											@device, @datatransazione, @ins_header, @ins_risposta, @ins_cmd, @ins_numbyte, @datatransazione,
											@ins_crediti, @ins_tickets, 0,0,0,0,0,0,0,
											@ins_tipocard, GETDATE(), @ins_partite, NULL, NULL
									);
							END

          END
          ELSE
          BEGIN
              SET @lsMotivo = '';

              IF ISNULL(@valoreUltimoSaldo,0) < @valoreNuovoSaldo
                 SET @lsMotivo = @lsMotivo +
                   'Saldo nuovo (' + ISNULL(CONVERT(VARCHAR(50),@valoreNuovoSaldo),'NULL') +
                   ') maggiore dell''ultimo saldo memorizzato (' + ISNULL(CONVERT(VARCHAR(50),@valoreUltimoSaldo),'NULL') + '). ';

              IF ISNULL(@n0,0) = @progressivo
                 SET @lsMotivo = @lsMotivo +
                   'Progressivo non valido (uguale all''ultimo N0: ' + ISNULL(CONVERT(VARCHAR(50),@progressivo),'') + '). ';

              IF @progressivogiausato > 0
                 SET @lsMotivo = @lsMotivo +
                   'Progressivo duplicato (' + ISNULL(CONVERT(VARCHAR(50),@progressivo),'') + '). ';

              -- Se è un 23 e prima c'era una provvisoria, NON blacklisto
              IF NOT (@tiporecord = 23 AND @hadProvisional > 0)
              BEGIN
                  IF ISNULL(@verificaDoppioneProgressivo,0) = 0
                  BEGIN
                      IF ISNULL(@idcontatto,0) = 0
                         SET @lsMotivo = @lsMotivo + 'Card [' + UPPER(@idcard) + '] non associata a un cliente. ';

                      SET @lsLogDebug =
                          'T0=' + @idcard + '00000000' +
                          ' UltimoSaldo=' + ISNULL(CONVERT(VARCHAR(50),@valoreUltimoSaldo),'NULL') +
                          ' NuovoSaldo=' + ISNULL(CONVERT(VARCHAR(50),@valoreNuovoSaldo),'NULL') +
                          ' Costo=' + ISNULL(CONVERT(VARCHAR(50),@valoreNuovoCostoPartita),'NULL') +
                          ' N0=' + ISNULL(CONVERT(VARCHAR(50),@progressivo),'NULL') +
                          ' Punti=' + ISNULL(CONVERT(VARCHAR(50),@puntiocrediti),'NULL') +
                          ' ProgUsato=' + ISNULL(CONVERT(VARCHAR(10),@progressivogiausato),'NULL');

                      INSERT INTO CoinlessLogEventiBlacklist (testo) VALUES (@lsLogDebug);
                      INSERT INTO CoinlessLogEventiBlacklist (testo, cardid) VALUES (@lsMotivo, UPPER(@idcard));

                      INSERT INTO CoinlessClonedCards
                      ( device, CodMac, cardid, DataMovimento, TipoMovimento,
                        SaldoCard, CostoPartita, LivelloCard, N0 )
                      SELECT
                        @device,
                        ISNULL((SELECT codmac FROM EcsMacchine WHERE device=@device),''),
                        UPPER(@idcard),
                        GETDATE(),
                        'Scarico',
                        @valoreNuovoSaldo,
                        @valoreNuovoCostoPartita,
                        @livellocard,
                        @progressivo;
                  END
              END
          END
      END

      -- Commit
      IF @sp_tran_started = 1
          COMMIT TRAN;
  END TRY
  BEGIN CATCH
      DECLARE @errnum INT        = ERROR_NUMBER(),
              @errmsg NVARCHAR(4000) = ERROR_MESSAGE(),
              @errline INT       = ERROR_LINE(),
              @errproc SYSNAME   = ISNULL(ERROR_PROCEDURE(), 'decodifica_record');

      IF XACT_STATE() <> 0
      BEGIN
          IF @sp_tran_started = 1
              ROLLBACK TRAN;
          ELSE
              ROLLBACK TRAN decodifica_record_sp;
      END

      RAISERROR('decodifica_record failed (%d) in %s at line %d: %s',
                16, 1, @errnum, @errproc, @errline, @errmsg);
      RETURN;
  END CATCH
END
