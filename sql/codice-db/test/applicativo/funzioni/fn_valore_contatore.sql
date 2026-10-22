CREATE FUNCTION [dbo].[fn_valore_contatore]
( @CodMac AS varchar(15) ,
  @NrContatore AS int 
)
RETURNS smallmoney
AS
BEGIN

  RETURN (
	select 
		case when @NrContatore = 1 then CntrVal1 else 0 end +
		case when @NrContatore = 2 then CntrVal2 else 0 end +
		case when @NrContatore = 3 then CntrVal3 else 0 end +
		case when @NrContatore = 4 then CntrVal4 else 0 end +
		case when @NrContatore = 5 then CntrVal5 else 0 end +
		case when @NrContatore = 6 then CntrVal6 else 0 end +
		case when @NrContatore = 7 then CntrVal7 else 0 end +
		case when @NrContatore = 8 then CntrVal8 else 0 end +
		case when @NrContatore = 9 then CntrVal9 else 0 end +
		case when @NrContatore = 10 then CntrVal10 else 0 end +
		case when @NrContatore = 11 then CntrVal11 else 0 end +
		case when @NrContatore = 12 then CntrVal12 else 0 end +
		case when @NrContatore = 13 then CntrVal13 else 0 end +
		case when @NrContatore = 14 then CntrVal14 else 0 end +
		case when @NrContatore = 15 then CntrVal15 else 0 end 
	from EcsMacchine where CodMac = @CodMac

 )
END;
