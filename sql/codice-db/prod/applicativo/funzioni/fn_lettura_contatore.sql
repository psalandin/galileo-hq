CREATE FUNCTION [dbo].[fn_lettura_contatore]
( @CodMac AS varchar(15) ,
  @NrContatore AS decimal(4,1) 
)
RETURNS int
AS
BEGIN
  RETURN (
	select 
		case when @NrContatore = 1 then CntrLet1 else 0 end +
		case when @NrContatore = 2 then CntrLet2 else 0 end +
		case when @NrContatore = 3 then CntrLet3 else 0 end +
		case when @NrContatore = 4 then CntrLet4 else 0 end +
		case when @NrContatore = 5 then CntrLet5 else 0 end +
		case when @NrContatore = 6 then CntrLet6 else 0 end +
		case when @NrContatore = 7 then CntrLet7 else 0 end +
		case when @NrContatore = 8 then CntrLet8 else 0 end +
		case when @NrContatore = 9 then CntrLet9 else 0 end +
		case when @NrContatore = 10 then CntrLet10 else 0 end +
		case when @NrContatore = 11 then CntrLet11 else 0 end +
		case when @NrContatore = 12 then CntrLet12 else 0 end +
		case when @NrContatore = 13 then CntrLet13 else 0 end +
		case when @NrContatore = 14 then CntrLet14 else 0 end +
		case when @NrContatore = 15 then CntrLet15 else 0 end 
	from EcsMacchine where CodMac = @CodMac

 )
END;
