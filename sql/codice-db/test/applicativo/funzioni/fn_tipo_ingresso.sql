CREATE FUNCTION [dbo].[fn_tipo_ingresso]
( @CodMac AS varchar(15) ,
  @NrIngresso AS int
)
RETURNS smallmoney
AS
BEGIN

  RETURN (
	select 
		case when @NrIngresso = 1 then TipoIn1 else 0 end +
		case when @NrIngresso = 2 then TipoIn2 else 0 end +
		case when @NrIngresso = 3 then TipoIn3 else 0 end +
		case when @NrIngresso = 4 then TipoIn4 else 0 end +
		case when @NrIngresso = 5 then TipoIn5 else 0 end +
		case when @NrIngresso = 6 then TipoIn6 else 0 end +
		case when @NrIngresso = 7 then TipoIn7 else 0 end +
		case when @NrIngresso = 8 then TipoIn8 else 0 end +
		case when @NrIngresso = 9 then TipoIn9 else 0 end +
		case when @NrIngresso = 10 then TipoIn10 else 0 end +
		case when @NrIngresso = 11 then TipoIn11 else 0 end +
		case when @NrIngresso = 12 then TipoIn12 else 0 end +
		case when @NrIngresso = 13 then TipoIn13 else 0 end +
		case when @NrIngresso = 14 then TipoIn14 else 0 end +
		case when @NrIngresso = 15 then TipoIn15 else 0 end 
	from EcsMacchine where CodMac = @CodMac

 )
END
;
