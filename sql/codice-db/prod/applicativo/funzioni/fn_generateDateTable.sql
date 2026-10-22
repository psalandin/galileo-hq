CREATE FUNCTION [dbo].[fn_generateDateTable] 
(  
  @start_date datetime
  , @end_date datetime
  , @datepart varchar(20) = 'day'
  , @step int = 1
)
returns table 
as
return (
  with getdates (date)
    as (

  select 
    @start_date as date

  union all

  select 
    case 
      when @datepart in ('year', 'yy', 'yyyy') then dateadd(yy, @step, date)
      when @datepart in ('quarter', 'qq', 'q') then dateadd(qq, @step, date)
      when @datepart in ('month', 'mm', 'm') then dateadd(mm, @step, date) 
      when @datepart in ('dayofyear', 'dy', 'y') then dateadd(dy, @step, date) 
      when @datepart in ('day', 'dd', 'd') then dateadd(dd, @step, date) 
      when @datepart in ('week', 'wk', 'ww') then dateadd(ww, @step, date) 
      when @datepart in ('hour', 'hh') then dateadd(hh, @step, date) 
      when @datepart in ('minute', 'mi', 'n') then dateadd(n, @step, date) 
      when @datepart in ('second', 'ss', 's') then dateadd(s, @step, date) 
      when @datepart in ('millisecond', 'ms') then dateadd(ms, @step, date) 
      else dateadd(dd, @step, date)
    end as date
  from 
    getdates
  where 
    (case 
      when @datepart in ('year', 'yy', 'yyyy') then dateadd(yy, @step, date)
      when @datepart in ('quarter', 'qq', 'q') then dateadd(qq, @step, date)
      when @datepart in ('month', 'mm', 'm') then dateadd(mm, @step, date) 
      when @datepart in ('dayofyear', 'dy', 'y') then dateadd(dy, @step, date) 
      when @datepart in ('day', 'dd', 'd') then dateadd(dd, @step, date) 
      when @datepart in ('week', 'wk', 'ww') then dateadd(ww, @step, date) 
      when @datepart in ('hour', 'hh') then dateadd(hh, @step, date) 
      when @datepart in ('minute', 'mi', 'n') then dateadd(n, @step, date) 
      when @datepart in ('second', 'ss', 's') then dateadd(s, @step, date) 
      when @datepart in ('millisecond', 'ms') then dateadd(ms, @step, date) 
      else dateadd(dd, @step, date)
    end) <= @end_date
  )

  select
    date
  from 
    getdates
)
;
