SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[scriviTicketsDaCoinless]
  @cardid AS  varchar(20),
	@NumTickets as int
AS
BEGIN
	declare @IdContatto varchar(30) 
	set @IdContatto = ( select IdContatto from WinMtSqlDB.dbo.clienti where t0 = @cardid )
	declare @seriale  varchar(15) 

	IF @IdContatto is not null 
	BEGIN 
		
		declare @SCO bigint 
		select @SCO = (convert(bigint,substring(convert( varchar(4),year(getdate())),4,1) + '00000001' )+DATEDIFF(second, convert(varchar(4),year(getdate()))+'-01-01 00:00:00', getdate()) )

		insert into WinMtSqlDB.dbo.Tickets (IdContatto,NumTickets,Data,MangiaT,NumTrans,TPagati,DataOut,Oper,OperOut,NonCont,Id,Aux,NRep,NImp,F0,T0,N0,D0,F1,T1,N1,D1 ) 
						values( @IdContatto,@NumTickets,Getdate(),@SCO ,0,0,Null,0,0,0,'1',0,0,0,0,null,null,null,0,null,null,null )
		
		update WinMtSqlDB.dbo.clienti set tickets = tickets+ @NumTickets where t0 = @cardid

	END 

END
GO

