SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[DYNAMIC_GLOBALTABLE_CREATE_SP_OUTPUT](
    @ProcedureName  nvarchar(128),
    @TableName      nvarchar(128),
    @SQL            nvarchar(max) OUTPUT
)
AS
SET @SQL = 'CREATE TABLE ' + @TableName + ' ('

SELECT @SQL = @SQL + '['+name +'] '+ system_type_name +''  + ','
        FROM sys.dm_exec_describe_first_result_set_for_object
        (
          OBJECT_ID(@ProcedureName), 
          NULL
        );

--Remove trailing comma
SET @SQL = SUBSTRING(@SQL,0,LEN(@SQL))    
SET @SQL =  @SQL +')'
select @SQL
Exec sp_executesql @SQL
GO