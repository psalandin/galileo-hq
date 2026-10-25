
CREATE FUNCTION [dbo].[fn_decode_mt_bitmask] (@value AS BIGINT, @lingua as int) 
RETURNS VARCHAR(MAX) AS 
BEGIN 
DECLARE @characters CHAR(36), 
@result VARCHAR(MAX), 
@base int, 
@k int 
declare @maschera as table 
( BitId  int, valore  varchar(1)) 
SELECT @characters = '0123456789abcdefghijklmnopqrstuvwxyz', 
@result = '', 
@base = 2, 
@k = 0 
WHILE @value > 0 
BEGIN 
if (SELECT SUBSTRING(@characters, @value % @base + 1, 1)) > '0' 
BEGIN 
INSERT INTO @maschera 
select @k,
(SELECT SUBSTRING(@characters, @value % @base + 1, 1) ) End  
SELECT @value = @value / @base SELECT @k = @k +1 End 
declare @decodifiche as table 
(BitId  int,IT  varchar(50),EN  varchar(50)) 
insert into @decodifiche 
select 0 as BitId , convert(varchar(50),'Mangiatickets Galileo') as IT,convert(varchar(50),'Galileo Ticket Eater') as EN 
UNION 
select 1 as BitId , convert(varchar(50),'Esterno') as IT,convert(varchar(50),'External') as EN 
UNION 
select 2 as BitId , convert(varchar(50),'Manuale') as IT,convert(varchar(50),'Manual') as EN 
UNION select 3 as BitId , convert(varchar(50),'Reso') as IT,convert(varchar(50),'Return') as EN 
UNION select 4 as BitId , convert(varchar(50),'Somma') as IT,convert(varchar(50),'Sum') as EN 
UNION select 5 as BitId , convert(varchar(50),'Resto') as IT,convert(varchar(50),'Change') as EN 
UNION select 6 as BitId , convert(varchar(50),'Bonus') as IT,convert(varchar(50),'Bonus') as EN 
UNION select 7 as BitId , convert(varchar(50),'Sommato') as IT,convert(varchar(50),'Added') as EN 
UNION select 8 as BitId , convert(varchar(50),'Caricato sulla Card') as IT,convert(varchar(50),'Loaded on Card') as EN 
UNION select 9 as BitId , convert(varchar(50),'Passato ad altra Card') as IT,convert(varchar(50),'Passed to another Card') as EN 
UNION select 10 as BitId ,convert(varchar(50),'Acquisito da altra Card') as IT,convert(varchar(50),'Acquired by another Card') as EN 
UNION select 11 as BitId ,convert(varchar(50),'Prenotazione cancellata') as IT,convert(varchar(50),'Pre-Order deleted') as EN 
UNION select 12 as BitId ,convert(varchar(50),'Cancellato da Operatore') as IT,convert(varchar(50),'Deleted by Operator') as EN 
UNION select 13 as BitId ,convert(varchar(50),'Punti da App') as IT,convert(varchar(50),'Points from App') as EN 
UNION select 14 as BitId ,convert(varchar(50),'Silver in Gold') as IT,convert(varchar(50),'Silver to Gold') as EN 
select @result = STUFF(CAST((SELECT [text()] = ', ' + case @lingua when 0 then md.IT when 1 then md.EN end 
FROM @decodifiche md 
WHERE md.BitId in (select m.bitid from  @maschera m inner join @decodifiche d on m.BitId = d.BitId ) FOR XML PATH(''), TYPE) 
AS VARCHAR(100)), 1, 2, '') 
RETURN @result; 
End
