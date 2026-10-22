CREATE FUNCTION [dbo].[fn_rapporto_contatore]
( @CodMac AS varchar(15) ,
  @Rapporto AS decimal(4,1) 
)
RETURNS smallmoney
AS
BEGIN

  RETURN (
	select 
		case when @Rapporto = 1 then RapCnt1 else 0 end +
		case when @Rapporto = 2 then RapCnt2 else 0 end +
		case when @Rapporto = 3 then RapCnt3 else 0 end +
		case when @Rapporto = 4 then RapCnt4 else 0 end +
		case when @Rapporto = 5 then RapCnt5 else 0 end +
		case when @Rapporto = 6 then RapCnt6 else 0 end +
		case when @Rapporto = 7 then RapCnt7 else 0 end +
		case when @Rapporto = 8 then RapCnt8 else 0 end +
		case when @Rapporto = 9 then RapCnt9 else 0 end +
		case when @Rapporto = 10 then RapCnt10 else 0 end +
		case when @Rapporto = 11 then RapCnt11 else 0 end +
		case when @Rapporto = 12 then RapCnt12 else 0 end +
		case when @Rapporto = 13 then RapCnt13 else 0 end +
		case when @Rapporto = 14 then RapCnt14 else 0 end +
		case when @Rapporto = 15 then RapCnt15 else 0 end 
	from EcsMacchine where CodMac = @CodMac

 )
END;
