-- Adattata per B4X/JDBC (nessun supporto a parametri OUTPUT): stessa logica/locking
-- dell'originale VB6/ADODB, ErrKey restituito come riga di risultato.
CREATE   PROCEDURE dbo.sp_redeem_confirm
    @DbName VARCHAR(6), @Codice VARCHAR(15), @UsedBy BIGINT = 0, @UsedOnPost INT = NULL, @UsedOnDevice VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Now DATETIME = GETDATE();
    DECLARE @Id BIGINT, @UsedAt DATETIME, @ReservedAt DATETIME, @ReservationExpiresAt DATETIME,
            @ReservedOnDevice VARCHAR(50), @ErrKey VARCHAR(50) = NULL;

    SELECT TOP 1 @Id=Id, @UsedAt=UsedAt, @ReservedAt=ReservedAt, @ReservationExpiresAt=ReservationExpiresAt, @ReservedOnDevice=ReservedOnDevice
    FROM dbo.RedeemCodes WITH (UPDLOCK, ROWLOCK) WHERE DbName=@DbName AND Codice=@Codice;

    IF @Id IS NULL SET @ErrKey = 'redeem_not_found';
    ELSE IF @UsedAt IS NOT NULL SET @ErrKey = 'redeem_already_used';
    ELSE IF @ReservedAt IS NULL OR (@ReservationExpiresAt IS NOT NULL AND @ReservationExpiresAt < @Now) SET @ErrKey = 'redeem_no_reservation';
    ELSE IF ISNULL(@UsedOnDevice,'') <> '' AND ISNULL(@ReservedOnDevice,'') <> '' AND @ReservedOnDevice <> @UsedOnDevice SET @ErrKey = 'redeem_no_reservation';

    IF @ErrKey IS NULL
    BEGIN
        UPDATE dbo.RedeemCodes SET UsedAt=@Now, UsedBy=IIF(@UsedBy<=0, NULL, @UsedBy), UsedOnPost=@UsedOnPost, UsedOnDevice=@UsedOnDevice,
            ReservedBy=NULL, ReservedAt=NULL, ReservedOnPost=NULL, ReservedOnDevice=NULL, ReservationExpiresAt=NULL
        WHERE Id=@Id;
    END

    SELECT @ErrKey AS ErrKey;
END
