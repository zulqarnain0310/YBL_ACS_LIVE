SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROCEDURE [pro].[ProcessingSteps2]
@UserLoginID VARCHAR(50)='DM585'
AS
BEGIN
BEGIN  TRY
  
DELETE FROM pro.ProcessingStepStatus WHERE ErrorDate=CAST(GETDATE() AS DATE) and ProcessingStepName='ProcessingSteps2'

  DECLARE @TIMEKEY INT = (SELECT TIMEKEY FROM PRO.EXTDATE_MISDB WHERE FLG = 'Y')
  DECLARE @ProcessingDateAudit DATE=(SELECT StartDate FROM PRO.EXTDATE_MISDB WHERE FLG = 'Y')

DELETE FROM PACKAGE_AUDIT WHERE IdentityKey=2

INSERT INTO PACKAGE_AUDIT(IdentityKey,UserID,Execution_date,PackageName,TableName,ExecutionStartTime,ExecutionStatus,ProcessingDate)    SELECT 2,@UserLoginID, GETDATE(),'TrnData', 'Daily Transaction Data Processing',GETDATE(),'P',@ProcessingDateAudit

EXEC PRO.CURDATACDAILYTXNDETAIL_INSERT 

UPDATE PACKAGE_AUDIT SET ExecutionEndTime=GETDATE()  WHERE IdentityKey = 2 AND  Execution_date=CAST(GETDATE() AS DATE) AND TableName='Daily Transaction Data Processing'

IF (
		SELECT COUNT(1)cnt FROM PRO.ProcessingStepStatus 
		WHERE ErrorDate= CAST (GETDATE() AS DATE) 
		and ProcessingStepName='ProcessingSteps2'
 ) <> 0
 
	 BEGIN
		UPDATE dbo.PACKAGE_AUDIT SET ExecutionStatus='E' WHERE IdentityKey = 2
	 END
	 ELSE
		UPDATE PACKAGE_AUDIT SET ExecutionStatus='Y' WHERE IdentityKey = 2

SELECT 2 AS StepNo, 'Result' AS TableName

END TRY


BEGIN  CATCH
		
		INSERT INTO PRO.ProcessingStepStatus(ProcessingStepName,Completed,ErrorDescription,ErrorDate)
		values('ProcessingSteps2','N',ERROR_MESSAGE(),GETDATE())
		UPDATE PACKAGE_AUDIT SET ExecutionStatus='E' WHERE IdentityKey = 2


END CATCH

END

GO