SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fn_CambiaBase]  
    (  
        @value AS BIGINT,  
        @base AS INT  
    ) RETURNS VARCHAR(MAX) AS BEGIN  
 -- Ver 1.1     

        DECLARE @characters CHAR(36),  
                @result VARCHAR(MAX);  
      

        SELECT @characters = '0123456789abcdefghijklmnopqrstuvwxyz',  
               @result = '';  
      

        IF @value < 0 OR @base < 2 OR @base > 36 RETURN NULL;  
      

        WHILE @value > 0  
            SELECT @result = SUBSTRING(@characters, @value % @base + 1, 1) + @result,  
                   @value = @value / @base;  

        RETURN @result;  
      
    END  

GO
