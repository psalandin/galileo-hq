CREATE   PROCEDURE dbo.sp_redeem_cancel 
 @DbName VARCHAR(6), @Codice VARCHAR(15), @ErrKey VARCHAR(50) OUTPUT 
 AS BEGIN SET NOCOUNT ON; SET @ErrKey=NULL; 
 DECLARE @Id BIGINT, @UsedAt DATETIME; 
 SELECT TOP 1 @Id=Id, @UsedAt=UsedAt FROM dbo.RedeemCodes WITH (UPDLOCK, ROWLOCK) WHERE DbName=@DbName AND Codice=@Codice; 
 IF @Id IS NULL BEGIN SET @ErrKey='redeem_not_found'; RETURN; END 
 IF @UsedAt IS NOT NULL BEGIN SET @ErrKey='redeem_already_used'; RETURN; END 
 UPDATE dbo.RedeemCodes SET ReservedBy=NULL, ReservedAt=NULL, ReservedOnPost=NULL, ReservedOnDevice=NULL, ReservationExpiresAt=NULL WHERE Id=@Id; 
 END
