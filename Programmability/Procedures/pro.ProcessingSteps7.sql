SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO








CREATE PROCEDURE [pro].[ProcessingSteps7]
@UserLoginID VARCHAR(50)='DM585'
AS
BEGIN
BEGIN  TRY
  
DELETE FROM pro.ProcessingStepStatus WHERE ErrorDate=CAST(GETDATE() AS DATE) and ProcessingStepName='ProcessingSteps7'
  DECLARE @TIMEKEY INT = (SELECT TIMEKEY FROM PRO.EXTDATE_MISDB WHERE FLG = 'Y')
  DECLARE @ProcessingDateAudit DATE=(SELECT StartDate FROM PRO.EXTDATE_MISDB WHERE FLG = 'Y')
  DELETE FROM PACKAGE_AUDIT WHERE IdentityKey=7

INSERT INTO PACKAGE_AUDIT(IdentityKey,UserID,Execution_date,PackageName,TableName,ExecutionStartTime,ExecutionStatus,ProcessingDate)  
                   SELECT 7,@UserLoginID, GETDATE(),'Validation', 'Validation Control Scripts',GETDATE(),'P',@ProcessingDateAudit
  

EXEC dbo.ValidationControlScripts ---03/June -2021 for data insert into control table 

EXEC [PRO].[AccountWiseMiscDetailCal_Insert]	---- Add by Pranay 20230620

UPDATE PACKAGE_AUDIT SET ExecutionEndTime=GETDATE()  WHERE IdentityKey = 7 AND  Execution_date=CAST(GETDATE() AS DATE) AND TableName='Validation Control Scripts'
UPDATE PACKAGE_AUDIT SET ExecutionStatus='Y' WHERE IdentityKey = 7


SELECT 7 AS StepNo, 'Result' AS TableName

DELETE  FROM  PACKAGE_AUDITHIST WHERE TIMEKEY=@TIMEKEY 

INSERT INTO PACKAGE_AUDITHIST( IDENTITYKEY,USERID,EXECUTION_DATE,PACKAGENAME,TABLENAME,EXECUTIONSTARTTIME,EXECUTIONENDTIME,TIMEDURATION_MIN ,EXECUTIONSTATUS,PROCESSINGDATE,TIMEKEY)
SELECT 
IDENTITYKEY,USERID,EXECUTION_DATE,PACKAGENAME,TABLENAME,EXECUTIONSTARTTIME,EXECUTIONENDTIME,TIMEDURATION_MIN,EXECUTIONSTATUS,PROCESSINGDATE,@TIMEKEY FROM PACKAGE_AUDIT

UPDATE A SET UserID=B.UserID FROM PRO.ProcessMonitor A  INNER JOIN PACKAGE_AUDITHIST B  ON A.TimeKey=B.TimeKey
INNER JOIN  PRO.EXTDATE_MISDB C on A.TimeKey=C.TimeKey
 WHERE B.IdentityKey = 7 
 AND C.FLG = 'Y'



 EXEC dbo.SuspendUsersByDormancy_DailyActivity  -- Dormancy_suspendActivity

 END TRY


BEGIN  CATCH
		
		INSERT INTO PRO.ProcessingStepStatus(ProcessingStepName,Completed,ErrorDescription,ErrorDate)
		values('ProcessingSteps7','N',ERROR_MESSAGE(),GETDATE())
		UPDATE PACKAGE_AUDIT SET ExecutionStatus='E' WHERE IdentityKey = 7


END CATCH


END


GO