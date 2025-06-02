SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [pro].[ProcessingSteps3BackupBeforeNewImplement]
@UserLoginID VARCHAR(50)='DM585'
AS
BEGIN
  DECLARE @TIMEKEY INT = (SELECT TIMEKEY FROM PRO.EXTDATE_MISDB WHERE FLG = 'Y')
  DECLARE @ProcessingDateAudit DATE=(SELECT StartDate FROM PRO.EXTDATE_MISDB WHERE FLG = 'Y')

  DELETE FROM PACKAGE_AUDIT WHERE IdentityKey=3

INSERT INTO PACKAGE_AUDIT(IdentityKey,UserID,Execution_date,PackageName,TableName,ExecutionStartTime,ExecutionStatus,ProcessingDate)    SELECT 3,@UserLoginID, GETDATE(),'Dmd', 'Daily Interest servicing',GETDATE(),'P',@ProcessingDateAudit

EXEC PRO.ACDAILYTXNDETAILDAILY_INSERT  
--EXEC [dbo].[DemandTableBackup] 
EXEC [Pro].[DynamicSegmentCreation]
EXEC DmdRecoSetOffLogicCC_Seg01 
EXEC DemandDataInsertIntoCurnt_Old

IF  EXISTS (SELECT 1 FROM [dbo].[InttServiceControlTbl] where ProcessingDate=@ProcessingDateAudit and Tallied='N')
		BEGIN
			SELECT 'Error in Demand Recovery Set of procecss for Date : '+CONVERT(NVARCHAR, @ProcessingDateAudit ,105)
			RETURN 
		END

UPDATE PACKAGE_AUDIT SET ExecutionEndTime=GETDATE()  WHERE IdentityKey = 3 AND  Execution_date=CAST(GETDATE() AS DATE) AND TableName='Daily Interest servicing'
UPDATE PACKAGE_AUDIT SET ExecutionStatus='Y' WHERE IdentityKey = 3
SELECT 3 AS StepNo, 'Result' AS TableName

END


GO