SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CoinlessDati] (
  [device] varchar(10)   NULL,
  [cmd] varchar(300)   NULL,
  [cnt] bigint  NULL,
  [logdate] datetime2(7) DEFAULT getdate() NOT NULL,
  [id] bigint  IDENTITY(1,1) NOT NULL,
  [hmac] varchar(64)   NOT NULL,
  [FlagOpDaVerificare] int  NULL,
  CONSTRAINT [PK__Coinless__497F6CB44C180CAC] PRIMARY KEY CLUSTERED ([id])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
)  
ON [PRIMARY]
GO

ALTER TABLE [dbo].[CoinlessDati] SET (LOCK_ESCALATION = TABLE)
GO

CREATE UNIQUE NONCLUSTERED INDEX [idx1]
ON [dbo].[CoinlessDati] (
  [device] ASC,
  [cmd] ASC,
  [cnt] ASC,
  [hmac] ASC
)
GO

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
GO
ALTER TABLE [dbo].[CoinlessDati] ENABLE TRIGGER [decodifica_flusso]
GO
