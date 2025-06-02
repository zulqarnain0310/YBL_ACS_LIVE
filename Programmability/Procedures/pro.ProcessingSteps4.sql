SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROCEDURE [pro].[ProcessingSteps4]
@UserLoginID VARCHAR(50)='DM585'
AS
BEGIN
  DECLARE @TIMEKEY INT = (SELECT TIMEKEY FROM PRO.EXTDATE_MISDB WHERE FLG = 'Y')
  DECLARE @ProcessingDateAudit DATE=(SELECT StartDate FROM PRO.EXTDATE_MISDB WHERE FLG = 'Y')

  DELETE FROM PACKAGE_AUDIT WHERE IdentityKey=4

INSERT INTO PACKAGE_AUDIT(IdentityKey,UserID,Execution_date,PackageName,TableName,ExecutionStartTime,ExecutionStatus,ProcessingDate)    SELECT 4,@UserLoginID, GETDATE(),'DataPre', 'Daily Data Preparation',GETDATE(),'P',@ProcessingDateAudit

EXEC PRO.INSERTDATAFORASSETCLASSFICATIONYES 

IF (select ErrorDescription from PRO.ACLRUNNINGPROCESSSTATUS		--- Condtion added to check the status of  processing step 4, if it is completed then only it will update the status in package audit -- Added by Pranay mail dated --2023-05-09
	WHERE RUNNINGPROCESSNAME='INSERTDATAFORASSETCLASSFICATIONYES') IS NOT  NULL 
	BEGIN
		UPDATE PACKAGE_AUDIT SET ExecutionStatus='E'   WHERE IdentityKey = 4 AND  Execution_date=CAST(GETDATE() AS DATE) AND TableName='Daily Data Preparation'
	END


IF ((select ErrorDescription from PRO.ACLRUNNINGPROCESSSTATUS		--- Condtion added to check the status of  processing step 4, if it is completed then only it will update the status in package audit -- Added by Pranay mail dated --2023-05-09
	WHERE RUNNINGPROCESSNAME='INSERTDATAFORASSETCLASSFICATIONYES') IS NULL 
	AND (SELECT Completed from PRO.ACLRUNNINGPROCESSSTATUS WHERE RUNNINGPROCESSNAME='INSERTDATAFORASSETCLASSFICATIONYES')='Y')
BEGIN
PRINT 1
UPDATE PACKAGE_AUDIT SET ExecutionEndTime=GETDATE()  WHERE IdentityKey = 4 AND  Execution_date=CAST(GETDATE() AS DATE) AND TableName='Daily Data Preparation'
UPDATE PACKAGE_AUDIT SET ExecutionStatus='Y' WHERE IdentityKey = 4
SELECT 4 AS StepNo, 'Result' AS TableName
END
PRINT 2
END
GO