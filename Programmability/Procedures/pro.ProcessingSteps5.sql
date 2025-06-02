SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO







CREATE PROCEDURE [pro].[ProcessingSteps5]
@UserLoginID VARCHAR(50)='DM585'
AS
BEGIN
  DECLARE @TIMEKEY INT = (SELECT TIMEKEY FROM PRO.EXTDATE_MISDB WHERE FLG = 'Y')
  DECLARE @ProcessingDateAudit DATE=(SELECT StartDate FROM PRO.EXTDATE_MISDB WHERE FLG = 'Y')
  DELETE FROM PACKAGE_AUDIT WHERE IdentityKey=5

  INSERT INTO PACKAGE_AUDIT(IdentityKey,UserID,Execution_date,PackageName,TableName,ExecutionStartTime,ExecutionStatus,ProcessingDate)    SELECT 5,@UserLoginID, GETDATE(),'Data Pro', 'Data Processing',GETDATE(),'P',@ProcessingDateAudit

EXEC PRO.MAINPROECESSFORASSETCLASSFICATION  
--EXEC PRO.DATATOCLIENTDEGRADE
--EXEC PRO.DATATOCLIENTDEGRADENPA
--EXEC PRO.DATATOCLIENTDEGRADEPNPA
--EXEC PRO.DATATOCLIENTUPGRADE

-------New Processing Steps 6 and 7 Created  27/12/2021 Triloki Khanna-------

------EXEC PRO.REVERSEFEED_ENPA
------EXEC [PRO].[REVERSEFEED_ENPA_VISIONPLUS]

------EXEC [PRO].[Inserdataintooverduedata_component]

------EXEC [Pro].[Insertdataforoutoforder] ---20-April-2021 for Interest bucket table

------EXEC dbo.ValidationControlScripts ---03/June -2021 for data insert into control table 


UPDATE PACKAGE_AUDIT SET ExecutionEndTime=GETDATE()  WHERE IdentityKey = 5 AND  Execution_date=CAST(GETDATE() AS DATE) AND TableName='Data Processing'
UPDATE PACKAGE_AUDIT SET ExecutionStatus='Y' WHERE IdentityKey = 5

--UPDATE PACKAGE_AUDIT SET ExecutionStatus='N'											--***********LINE TO BE COMMENTED***********
--UPDATE PACKAGE_AUDIT SET ExecutionStartTime=NULL, ExecutionEndTime=NULL               --***********LINE TO BE COMMENTED***********

-----Shifited to Processing Step Number 7 27/12/2021 Triloki Khanna-------

--DELETE  FROM  PACKAGE_AUDITHIST WHERE TIMEKEY=@TIMEKEY 

--INSERT INTO PACKAGE_AUDITHIST( IDENTITYKEY,USERID,EXECUTION_DATE,PACKAGENAME,TABLENAME,EXECUTIONSTARTTIME,EXECUTIONENDTIME,TIMEDURATION_MIN ,EXECUTIONSTATUS,PROCESSINGDATE,TIMEKEY)
--SELECT 
--IDENTITYKEY,USERID,EXECUTION_DATE,PACKAGENAME,TABLENAME,EXECUTIONSTARTTIME,EXECUTIONENDTIME,TIMEDURATION_MIN,EXECUTIONSTATUS,PROCESSINGDATE,@TIMEKEY FROM PACKAGE_AUDIT

--UPDATE A SET UserID=B.UserID FROM PRO.ProcessMonitor A  INNER JOIN PACKAGE_AUDITHIST B  ON A.TimeKey=B.TimeKey
--INNER JOIN  PRO.EXTDATE_MISDB C on A.TimeKey=C.TimeKey
-- WHERE B.IdentityKey = 5 
-- AND C.FLG = 'Y'
IF (select top 1 ErrorDescription from PRO.ACLRUNNINGPROCESSSTATUS		--- Condtion added to check the status of  processing step 5, if it is completed then only it will update the status in package audit -- Added by Pranay mail dated --2023-05-09
	WHERE RUNNINGPROCESSNAME!='INSERTDATAFORASSETCLASSFICATIONYES' AND ErrorDescription IS NOT NULL) IS NOT  NULL 
	BEGIN
		UPDATE PACKAGE_AUDIT SET ExecutionStatus='E'   WHERE IdentityKey = 5 AND  Execution_date=CAST(GETDATE() AS DATE) AND TableName='Data Processing'
	END

SELECT 5 AS StepNo, 'Result' AS TableName

END


GO