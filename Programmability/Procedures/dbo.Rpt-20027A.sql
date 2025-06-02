SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



CREATE PROC [dbo].[Rpt-20027A]
      @TimeKey AS INT,
	  @ExceptionCode AS VARCHAR(500)
AS


--DECLARE 
--      @TimeKey AS INT =26852,
--	  @ExceptionCode AS VARCHAR(500)='1'

DECLARE @DATE AS DATE=(SELECT [DATE] FROM SysDayMatrix WHERE TimeKey=@TimeKey)

SELECT 
convert (VARCHAR(20),Data_Date,103)                         as Data_Date,
SourceSystemName,
Data_type                                                    AS Data_Type,
row_count                                                    AS Row_Count,
--convert (VARCHAR (20),insert_time,113)                       AS Insert_Time,
FORMAT (insert_time,'dd/MM/yyyy hh:mm:ss')                   AS Insert_Time,
1                                                            AS ExceptionCode,
'Completeness of the data flowing in the ENPA system'        AS ExceptionDescription

FROM YBL_ACS_MIS.dbo.BI_DataSummary
              
WHERE Data_Date=@DATE AND @ExceptionCode='1'




OPTION(RECOMPILE)
  




GO