CREATE TRIGGER [dbo].[decodifica_flusso]
ON [dbo].[CoinlessDati]
WITH EXECUTE AS CALLER
FOR INSERT
AS
BEGIN
  -- type your statements here
DECLARE @NEWdevice VARCHAR (10)
DECLARE @NEWcmd varchar(255)
DECLARE @NEWlogdate datetime2 
DECLARE @NEWhmac varchar(64)
DECLARE @NEWcnt bigint
DECLARE @CHKHMAC varchar(64)
DECLARE @FlagDaVerificare int 

DECLARE my_Cursor CURSOR FAST_FORWARD FOR 
SELECT device,cmd,logdate,cnt,hmac, FlagOpDaVerificare FROM INSERTED
OPEN my_Cursor 
 FETCH NEXT FROM my_Cursor into @NEWdevice,@NEWcmd,@NEWlogdate,@NEWcnt,@NEWhmac,@FlagDaVerificare

 WHILE @@FETCH_STATUS = 0 
 BEGIN
	
	set @CHKHMAC = (SELECT dbo.fn_calcHMAC( @NEWdevice,@NEWcmd,convert(varchar(10),@NEWcnt) ) )	

	IF @CHKHMAC = @NEWhmac 
	BEGIN

		exec decodifica_record @NEWdevice,@NEWcmd,@NEWlogdate,@FlagDaVerificare
	END
	FETCH NEXT FROM my_Cursor into @NEWdevice,@NEWcmd,@NEWlogdate ,@NEWcnt,@NEWhmac,@FlagDaVerificare 
 END 
DEALLOCATE my_Cursor
END
