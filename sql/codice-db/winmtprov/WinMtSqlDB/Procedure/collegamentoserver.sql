EXEC sp_addlinkedserver   
   @server = N'elmaccloud',  
   @srvproduct=N'SQLServer',  
   @provider=N'SQLNCLI',  
   @datasrc=N'winmt.elmaccloud.com';
GO

EXEC sp_addlinkedsrvlogin
   @rmtsrvname = N'elmaccloud',
   @useself = N'False',
   @rmtuser = N'sa',
   @rmtpassword = '<PASSWORD RIMOSSA>';
GO
EXEC sp_serveroption 
	@server = N'elmaccloud',
	@optname = N'rpc',
	@optvalue = N'true';
GO
EXEC sp_serveroption 
	@server = N'elmaccloud',
	@optname = N'rpc out',
	@optvalue = N'true';
GO
