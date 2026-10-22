CREATE   PROCEDURE dbo.FinalizeUidCodbar
    @CodBar varchar(50),
    @ReservedBy varchar(64)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.UID_Ammessi set DataEmissione = getdate()
    WHERE CodBar = @CodBar
    DELETE FROM dbo.uid_reservations
    WHERE CodBar = @CodBar
      AND ReservedBy = @ReservedBy;
END
