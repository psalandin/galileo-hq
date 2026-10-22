CREATE   PROCEDURE dbo.sp_redeem_create 
 @DbName VARCHAR(6), @Azione VARCHAR(20), @Valore MONEY=NULL, @Bonus MONEY=NULL, @Tickets INT=NULL, @CardLevel INT=NULL, 
 @IdPromozione BIGINT=NULL, @IdCompleanno BIGINT=NULL, @IdContatto BIGINT=NULL, @MailDestinatario VARCHAR(255)=NULL, 
 @ValidFrom DATETIME=NULL, @ValidTo DATETIME=NULL, @CreatedBy BIGINT, 
 @OutCodice VARCHAR(15) OUTPUT, @OutPin VARCHAR(4) OUTPUT, @ErrKey VARCHAR(50) OUTPUT 
 AS BEGIN SET NOCOUNT ON; SET @ErrKey=NULL; SET @OutCodice=NULL; SET @OutPin=NULL; DECLARE @Try INT=0; 
 WHILE @Try < 20 BEGIN SET @Try=@Try+1; 
  DECLARE @C VARCHAR(15); DECLARE @P VARCHAR(4); 
  SET @C = 'RD' + RIGHT(REPLACE(CONVERT(VARCHAR(36), NEWID()), '-', '' ), 13); 
  SET @P = RIGHT('0000' + CONVERT(VARCHAR(10), ABS(CHECKSUM(NEWID())) % 10000), 4); 
  BEGIN TRY 
   INSERT INTO dbo.RedeemCodes (DbName,Codice,Azione,Valore,Bonus,Tickets,IdPromozione,IdCompleanno,IdContatto,MailDestinatario,CardLevel,Pin,ValidFrom,ValidTo,CreatedBy,CreatedAt) 
   VALUES (@DbName,@C,@Azione,@Valore,@Bonus,@Tickets,@IdPromozione,@IdCompleanno,@IdContatto,@MailDestinatario,@CardLevel,@P,@ValidFrom,@ValidTo,@CreatedBy,GETDATE()); 
   SET @OutCodice=@C; SET @OutPin=@P; RETURN; 
  END TRY BEGIN CATCH 
    IF ERROR_NUMBER() IN (2601,2627) CONTINUE; 
    SET @ErrKey='redeem_internal_error'; RETURN; 
  END CATCH 
 END 
 SET @ErrKey='redeem_internal_error'; 
 END
