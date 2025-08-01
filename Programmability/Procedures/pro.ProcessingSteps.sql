﻿SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO






CREATE PROCEDURE [pro].[ProcessingSteps]
AS
BEGIN



UPDATE PRO.EXTDATE_MISDB SET LAST_EXTDATE = (SELECT MAX(PROCESSINGDATE)  FROM PACKAGE_AUDITHIST) WHERE Flg='Y'--Extration date

UPDATE PRO.EXTDATE_MISDB SET Flg='U' WHERE   Flg='Y'

UPDATE DBO.SysDataMatrix SET CurrentStatus='U' WHERE   CurrentStatus='C'

UPDATE PRO.EXTDATE_MISDB  SET Flg='Y'  WHERE TimeKey in (select max(TimeKey) + 1  from PACKAGE_AUDITHIST WHERE IdentityKey = 5)

UPDATE SysDataMatrix SET CurrentStatus='C'  WHERE TimeKey in (select max(TimeKey) + 1  from PACKAGE_AUDITHIST WHERE IdentityKey = 5)

SELECT 'Checksum' AS TableName, COUNT(TABLE_NAME ) AS Count, CAST(ETL_DATE AS DATE) AS ETL_DATE FROM YBL_ACS_MIS.DBO.EXTRACTION_STATUS
WHERE ETL_DATE in (select startdate from pro.EXTDATE_MISDB where flg='Y')    --*******UNCOMMENT THIS LINE***********
GROUP BY ETL_DATE
HAVING COUNT(TABLE_NAME)=3 --***********TO BE SET TO 3***********

SELECT  'ExtractionStatus' AS TableName, Table_Name AS 'LoadedTables', ETL_Date AS 'ETLDate' FROM YBL_ACS_MIS.DBO.EXTRACTION_STATUS --***********LINE TO BE ADDED***********

SELECT PARAMETERNAME  AS TableName , ParameterValue AS TimePeriod FROM SYSSOLUTIONPARAMETER WHERE  PARAMETERNAME='REFRESHPERIOD'
 

SELECT 'ProcessingStatus' AS TableName FROM PACKAGE_AUDIT WHERE  IDENTITYKEY='5'  AND EXECUTIONSTATUS='Y' AND ProcessingDate = (select startdate from pro.EXTDATE_MISDB where flg='Y')--***********LINE TO BE ADDED***********

DELETE FROM PACKAGE_AUDIT WHERE ProcessingDate IN (select max(ProcessingDate)  from PACKAGE_AUDITHIST WHERE IdentityKey = 5) --***********LINE TO BE ADDED***********


DECLARE @TIMEKEY INT = (SELECT TIMEKEY FROM PRO.EXTDATE_MISDB WHERE FLG = 'Y')
  
DECLARE @ProcessingDateAudit DATE=(SELECT StartDate FROM PRO.EXTDATE_MISDB WHERE FLG = 'Y')

SELECT 'ProcessingDate' AS TableName, MonthLastDate AS PROCESSINGDATE FROM SYSDATAMATRIX WHERE  CURRENTSTATUS='C' --***********LINE TO BE MODIFIED***********


END






GO