CREATE FUNCTION [dbo].[fn_valore_ingresso]
( @CodMac AS varchar(15) ,
  @NrIngresso AS decimal(4,1) 
)
RETURNS smallmoney
AS
BEGIN
  RETURN (
	select 
		case when @NrIngresso = 1 then ValIn1 else 0 end +
		case when @NrIngresso = 2 then ValIn2 else 0 end +
		case when @NrIngresso = 3 then ValIn3 else 0 end +
		case when @NrIngresso = 4 then ValIn4 else 0 end +
		case when @NrIngresso = 5 then ValIn5 else 0 end +
		case when @NrIngresso = 6 then ValIn6 else 0 end +
		case when @NrIngresso = 7 then ValIn7 else 0 end +
		case when @NrIngresso = 8 then ValIn8 else 0 end +
		case when @NrIngresso = 9 then ValIn9 else 0 end +
		case when @NrIngresso = 10 then ValIn10 else 0 end +
		case when @NrIngresso = 11 then ValIn11 else 0 end +
		case when @NrIngresso = 12 then ValIn12 else 0 end +
		case when @NrIngresso = 13 then ValIn13 else 0 end +
		case when @NrIngresso = 14 then ValIn14 else 0 end +
		case when @NrIngresso = 15 then ValIn15 else 0 end 
	from EcsMacchine where CodMac = @CodMac

 )
END;
