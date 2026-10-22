CREATE   PROCEDURE dbo.sp_redeem_confirm 
 @DbName VARCHAR(6), @Codice VARCHAR(15), @UsedBy BIGINT=NULL, @UsedOnPost INT=NULL, @UsedOnDevice VARCHAR(50)=NULL, @ErrKey VARCHAR(50) OUTPUT 
 AS BEGIN SET NOCOUNT ON; SET @ErrKey=NULL; DECLARE @Now DATETIME=GETDATE(); 
 DECLARE @Id BIGINT, @UsedAt DATETIME, @ReservedAt DATETIME, @ReservationExpiresAt DATETIME, @ReservedOnDevice VARCHAR(50); 
 SELECT TOP 1 @Id=Id, @UsedAt=UsedAt, @ReservedAt=ReservedAt, @ReservationExpiresAt=ReservationExpiresAt, @ReservedOnDevice=ReservedOnDevice 
 FROM dbo.RedeemCodes WITH (UPDLOCK, ROWLOCK) WHERE DbName=@DbName AND Codice=@Codice; 
 IF @Id IS NULL BEGIN SET @ErrKey='redeem_not_found'; RETURN; END 
 IF @UsedAt IS NOT NULL BEGIN SET @ErrKey='redeem_already_used'; RETURN; END 
 IF @ReservedAt IS NULL OR (@ReservationExpiresAt IS NOT NULL AND @ReservationExpiresAt < @Now) BEGIN SET @ErrKey='redeem_no_reservation'; RETURN; END 
 IF ISNULL(@UsedOnDevice,'') <> '' AND ISNULL(@ReservedOnDevice,'') <> '' AND @ReservedOnDevice <> @UsedOnDevice BEGIN SET @ErrKey='redeem_no_reservation'; RETURN; END 
 UPDATE dbo.RedeemCodes SET UsedAt=@Now, UsedBy=@UsedBy, UsedOnPost=@UsedOnPost, UsedOnDevice=@UsedOnDevice, 
   ReservedBy=NULL, ReservedAt=NULL, ReservedOnPost=NULL, ReservedOnDevice=NULL, ReservationExpiresAt=NULL 
 WHERE Id=@Id; 
 END
