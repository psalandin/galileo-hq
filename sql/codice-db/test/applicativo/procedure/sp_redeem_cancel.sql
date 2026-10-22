-- Adattata per B4X/JDBC (nessun supporto a parametri OUTPUT): stessa logica/locking
-- dell'originale VB6/ADODB, ErrKey restituito come riga di risultato.
CREATE   PROCEDURE dbo.sp_redeem_cancel
    @DbName VARCHAR(6), @Codice VARCHAR(15)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Id BIGINT, @UsedAt DATETIME, @ErrKey VARCHAR(50) = NULL;

    SELECT TOP 1 @Id=Id, @UsedAt=UsedAt FROM dbo.RedeemCodes WITH (UPDLOCK, ROWLOCK) WHERE DbName=@DbName AND Codice=@Codice;

    IF @Id IS NULL SET @ErrKey = 'redeem_not_found';
    ELSE IF @UsedAt IS NOT NULL SET @ErrKey = 'redeem_already_used';

    IF @ErrKey IS NULL
        UPDATE dbo.RedeemCodes SET ReservedBy=NULL, ReservedAt=NULL, ReservedOnPost=NULL, ReservedOnDevice=NULL, ReservationExpiresAt=NULL WHERE Id=@Id;

    SELECT @ErrKey AS ErrKey;
END
