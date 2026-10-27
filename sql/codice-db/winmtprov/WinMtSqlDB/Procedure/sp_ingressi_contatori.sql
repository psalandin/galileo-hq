SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[sp_ingressi_contatori]
AS
BEGIN
-- Ver. 1.1

declare @sql nvarchar(max)
declare @CodMac nvarchar(30)
declare @Contatore nvarchar(30)
DECLARE @ParmDefinition nvarchar(500)

set @sql = N''
set @ParmDefinition = ''
DECLARE db_cursor CURSOR FOR
	select CodMac,convert(nvarchar(30),Contatore) from vs_contatori_per_macchina

OPEN db_cursor  
FETCH NEXT FROM db_cursor INTO @CodMac, @Contatore 

WHILE @@FETCH_STATUS = 0  
BEGIN  
	set @sql = @sql + N'SELECT CodMac,'''+@Contatore+''' as NrContatore,CntrVal'+@Contatore+' as CntVal,CntrLet'+@Contatore+ ' as  CntLett from EcsMacchine where codmac = '''+@CodMac+''' union '
	FETCH NEXT FROM db_cursor INTO @CodMac, @Contatore  
END  

CLOSE db_cursor  
DEALLOCATE db_cursor 

declare @myReturn TABLE (
			CodMac varchar(30) null,
			NrContatore int,
			CntrVal money null,
			CntLett int null
       )

if @sql <> ''
BEGIN 
	set @sql = left(@sql,(len(@sql)-5))
	--set @sql = 'insert into @myReturn (CodMac,CntrVal,CntLett) select * from a (' +@sql +') a'
	--exec( @sql )
	insert into @myReturn (CodMac,NrContatore,CntrVal,CntLett) exec( @sql )

	select tb1.CodMac,tb1.NrContatore,tb1.CntrVal,tb1.CntLett,vs_valore_ingressi_per_macchina.ingresso,vs_valore_ingressi_per_macchina.valoreIngresso 
	from @myReturn as tb1 
	INNER JOIN vs_valore_ingressi_per_macchina on vs_valore_ingressi_per_macchina.codmac = tb1.CodMac 
	INNER JOIN vs_ingressi_contatori on vs_ingressi_contatori.codmac = tb1.CodMac and vs_valore_ingressi_per_macchina.ingresso = vs_ingressi_contatori.ingresso and vs_ingressi_contatori.contatore = tb1.NrContatore
	where vs_valore_ingressi_per_macchina.valoreIngresso > 0

END
END;
GO


