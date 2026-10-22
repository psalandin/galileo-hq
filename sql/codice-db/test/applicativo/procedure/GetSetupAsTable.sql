CREATE PROCEDURE GetSetupAsTable
	@IdPost as int
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @cols NVARCHAR(MAX), @query NVARCHAR(MAX);

    -- Creiamo dinamicamente le colonne in base ai valori disponibili in Chiave
    SELECT @cols = STRING_AGG(QUOTENAME(Chiave), ', ') 
    FROM (SELECT DISTINCT Chiave FROM setup2) AS Cols;

    -- Creiamo la query dinamica
    SET @query = 'SELECT * FROM ( 
                    SELECT IdPost, Chiave, Valore FROM setup2 WHERE IdPost = ' + (select convert(nvarchar,@IdPost)) +'
                  ) AS SourceTable
                  PIVOT (
                      MAX(Valore) FOR Chiave IN (' + @cols + ')
                  ) AS PivotTable';

    -- Eseguiamo la query dinamica
    EXEC sp_executesql @query;
END;
