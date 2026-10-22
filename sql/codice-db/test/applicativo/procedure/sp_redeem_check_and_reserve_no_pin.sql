-- Adattata per B4X/JDBC (nessun supporto a parametri OUTPUT in questo progetto - vedi
-- ecs2mqtt/DBwinmt.CheckAndReserveRedeem): stessa logica/locking dell'originale VB6/ADODB,
-- ma ErrKey e i dati del codice sono restituiti come riga di risultato anziche' come OUTPUT.
create   PROCEDURE dbo.sp_redeem_check_and_reserve_no_pin
    @DbName VARCHAR(6), @Codice VARCHAR(15), @IsLogged BIT, @IdContatto BIGINT = 0,
    @PostId INT = NULL, @DeviceId VARCHAR(50) = NULL, @MinutesToExpire INT = 5
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Now DATETIME = GETDATE();
    DECLARE @Exp DATETIME = DATEADD(MINUTE, @MinutesToExpire, @Now);
    DECLARE @Id BIGINT, @Azione VARCHAR(20), @UsedAt DATETIME, @ValidFrom DATETIME, @ValidTo DATETIME,
            @ReservedAt DATETIME, @ReservationExpiresAt DATETIME, @Valore MONEY, @Bonus MONEY,
            @Tickets INT, @CardLevel INT, @IdCompleanno BIGINT, @ErrKey VARCHAR(50) = NULL;

    SELECT TOP 1 @Id=Id, @Azione=Azione, @UsedAt=UsedAt, @ValidFrom=ValidFrom, @ValidTo=ValidTo,
           @ReservedAt=ReservedAt, @ReservationExpiresAt=ReservationExpiresAt, @Valore=Valore,
           @Bonus=Bonus, @Tickets=Tickets, @CardLevel=CardLevel, @IdCompleanno=IdCompleanno
    FROM dbo.RedeemCodes WITH (UPDLOCK, ROWLOCK) WHERE DbName=@DbName AND Codice=@Codice;

    IF @Id IS NULL SET @ErrKey = 'redeem_not_found';
    ELSE IF @UsedAt IS NOT NULL SET @ErrKey = 'redeem_already_used';
    ELSE IF (@ValidFrom IS NOT NULL AND @ValidFrom > @Now) OR (@ValidTo IS NOT NULL AND @ValidTo < @Now) SET @ErrKey = 'redeem_code_expired';
    ELSE IF @ReservedAt IS NOT NULL AND (@ReservationExpiresAt IS NULL OR @ReservationExpiresAt >= @Now) SET @ErrKey = 'redeem_code_reserved';
    ELSE IF @IsLogged = 1 AND (ISNULL(@IdContatto,0) <= 0 OR @Azione <> 'recharge') SET @ErrKey = 'redeem_requires_login';
    ELSE IF @IsLogged = 0 AND @Azione <> 'new' SET @ErrKey = 'redeem_requires_login';

    IF @ErrKey IS NULL
    BEGIN
        UPDATE dbo.RedeemCodes SET
            ReservedBy = CASE WHEN @IsLogged=1 THEN @IdContatto ELSE NULL END,
            ReservedAt=@Now, ReservedOnPost=@PostId, ReservedOnDevice=@DeviceId, ReservationExpiresAt=@Exp
        WHERE Id=@Id;
        SET @ReservationExpiresAt = @Exp;
    END

    -- ISNULL difensivo: i campi valore/bonus/tickets/cardlevel/idcompleanno sono nullable su
    -- RedeemCodes, il chiamante B4X (DBwinmt.CheckAndReserveRedeem) non gestisce NULL su questi
    SELECT @ErrKey AS ErrKey, @Codice AS Codice, ISNULL(@Azione,'') AS Azione, ISNULL(@Valore,0) AS Valore,
           ISNULL(@Bonus,0) AS Bonus, ISNULL(@Tickets,0) AS Tickets, ISNULL(@CardLevel,0) AS CardLevel,
           ISNULL(@IdCompleanno,0) AS IdCompleanno, @ReservationExpiresAt AS ReservationExpiresAt;
END
