-- Riscritta da zero: il file di migrazione originale conteneva per errore una copia di
-- sp_redeem_create (bug individuato durante il porting - la vera logica di VerifyPin non era
-- presente in nessun file disponibile). Dedotta dall'uso in cls_RedeemManager.VerifyPin (VB6) e
-- dalle stored procedure sorelle: valida il PIN sul codice gia' prenotato, senza consumarlo.
-- Adattata per B4X/JDBC (nessun supporto a parametri OUTPUT): ErrKey come riga di risultato.
CREATE   PROCEDURE dbo.sp_redeem_verify_pin
    @DbName VARCHAR(6), @Codice VARCHAR(15), @Pin VARCHAR(4)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Now DATETIME = GETDATE();
    DECLARE @Id BIGINT, @UsedAt DATETIME, @ReservedAt DATETIME, @ReservationExpiresAt DATETIME,
            @StoredPin VARCHAR(4), @ErrKey VARCHAR(50) = NULL;

    SELECT TOP 1 @Id=Id, @UsedAt=UsedAt, @ReservedAt=ReservedAt, @ReservationExpiresAt=ReservationExpiresAt, @StoredPin=Pin
    FROM dbo.RedeemCodes WITH (NOLOCK) WHERE DbName=@DbName AND Codice=@Codice;

    IF @Id IS NULL SET @ErrKey = 'redeem_not_found';
    ELSE IF @UsedAt IS NOT NULL SET @ErrKey = 'redeem_already_used';
    ELSE IF @ReservedAt IS NULL OR (@ReservationExpiresAt IS NOT NULL AND @ReservationExpiresAt < @Now) SET @ErrKey = 'redeem_no_reservation';
    ELSE IF @StoredPin <> @Pin SET @ErrKey = 'redeem_pin_wrong';

    SELECT @ErrKey AS ErrKey;
END
