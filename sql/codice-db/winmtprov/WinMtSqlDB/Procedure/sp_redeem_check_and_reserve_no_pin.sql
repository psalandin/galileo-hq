SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create or ALTER PROCEDURE dbo.sp_redeem_check_and_reserve_no_pin  @DbName VARCHAR(6), @Codice VARCHAR(15), @IsLogged BIT, @IdContatto BIGINT = NULL,  @PostId INT = NULL, @DeviceId VARCHAR(50) = NULL, @MinutesToExpire INT = 5, @ErrKey VARCHAR(50) OUTPUT  AS 
 BEGIN 
 SET NOCOUNT ON; SET @ErrKey = NULL; 
 DECLARE @Now DATETIME = GETDATE(); DECLARE @Exp DATETIME = DATEADD(MINUTE, @MinutesToExpire, @Now); 
 DECLARE @Id BIGINT, @Azione VARCHAR(20), @UsedAt DATETIME, @ValidFrom DATETIME, @ValidTo DATETIME, @ReservedAt DATETIME, @ReservationExpiresAt DATETIME; 
 SELECT TOP 1 @Id=Id, @Azione=Azione, @UsedAt=UsedAt, @ValidFrom=ValidFrom, @ValidTo=ValidTo, @ReservedAt=ReservedAt, @ReservationExpiresAt=ReservationExpiresAt 
 FROM dbo.RedeemCodes WITH (UPDLOCK, ROWLOCK) WHERE DbName=@DbName AND Codice=@Codice; 
 IF @Id IS NULL BEGIN SET @ErrKey = 'redeem_not_found'; RETURN; END 
 IF @UsedAt IS NOT NULL BEGIN SET @ErrKey = 'redeem_already_used'; RETURN; END 
 IF (@ValidFrom IS NOT NULL AND @ValidFrom > @Now) OR (@ValidTo IS NOT NULL AND @ValidTo < @Now) BEGIN SET @ErrKey = 'redeem_code_expired'; RETURN; END 
 IF @ReservedAt IS NOT NULL AND (@ReservationExpiresAt IS NULL OR @ReservationExpiresAt >= @Now) BEGIN SET @ErrKey = 'redeem_code_reserved'; RETURN; END 
 IF @IsLogged = 1 BEGIN 
   IF ISNULL(@IdContatto,0) <= 0 BEGIN SET @ErrKey = 'redeem_requires_login'; RETURN; END 
   IF @Azione <> 'recharge' BEGIN SET @ErrKey = 'redeem_requires_login'; RETURN; END 
 END ELSE BEGIN 
   IF @Azione <> 'new' BEGIN SET @ErrKey = 'redeem_requires_login'; RETURN; END 
 END 
 UPDATE dbo.RedeemCodes SET 
   ReservedBy = CASE WHEN @IsLogged=1 THEN @IdContatto ELSE NULL END, 
   ReservedAt=@Now, ReservedOnPost=@PostId, ReservedOnDevice=@DeviceId, ReservationExpiresAt=@Exp 
 WHERE Id=@Id; 
 SELECT TOP 1 * FROM dbo.RedeemCodes WITH (NOLOCK) WHERE Id=@Id; 
 END
 GO