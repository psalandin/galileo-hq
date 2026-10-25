
CREATE PROCEDURE [dbo].[sp_last_trans]
( @locale AS varchar(10),
  @IdContatto AS bigint,
	@aggiorna as int = 0, @tickets as bigint)
AS
BEGIN
	declare @sSQL nvarchar(500)
	DECLARE @ParmDefinition nvarchar(500)
	declare @intervallo int
	declare @intervallo_verificato int
	declare @risultato int 
	set @sSQL = 'select @retvalOUT = n0 from DB'+@locale+'.dbo.setup where idpost=101'
	SET @ParmDefinition = N'@retvalOUT int OUTPUT'
	EXEC sp_executesql @sSQL, @ParmDefinition, @retvalOUT=@intervallo OUTPUT
	select @intervallo_verificato = isnull( (SELECT	datediff(SECOND, d0, getdate()) from clienti where idlong = @IdContatto and n0 != @locale ) ,@intervallo)
	if @intervallo_verificato >= @intervallo
		BEGIN
			set @risultato = 1
			if @aggiorna >0 
				BEGIN
					update clienti set n0 = @locale, d0 = getdate(), dataultvis = getdate(), tickets = @tickets where idlong = @IdContatto
				END 
		END
	else 
		BEGIN
			set @risultato = 0
		END 
  select @risultato
END
