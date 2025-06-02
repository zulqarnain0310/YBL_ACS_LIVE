SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO





CREATE PROCEDURE [pro].[ProcessingSteps6]
@UserLoginID VARCHAR(50)='DM585'
AS
BEGIN
BEGIN  TRY
  
DELETE FROM pro.ProcessingStepStatus WHERE ErrorDate=CAST(GETDATE() AS DATE) and ProcessingStepName='ProcessingSteps6'

  DECLARE @TIMEKEY INT = (SELECT TIMEKEY FROM PRO.EXTDATE_MISDB WHERE FLG = 'Y')
  DECLARE @ProcessingDateAudit DATE=(SELECT StartDate FROM PRO.EXTDATE_MISDB WHERE FLG = 'Y')
  DELETE FROM PACKAGE_AUDIT WHERE IdentityKey=6

INSERT INTO PACKAGE_AUDIT(IdentityKey,UserID,Execution_date,PackageName,TableName,ExecutionStartTime,ExecutionStatus,ProcessingDate)  
                   SELECT 6,@UserLoginID, GETDATE(),'Reverse', 'Reverse Feed Data',GETDATE(),'P',@ProcessingDateAudit
  
EXEC PRO.REVERSEFEED_ENPA
EXEC [PRO].[REVERSEFEED_ENPA_VISIONPLUS]
EXEC [PRO].[Inserdataintooverduedata_component]
EXEC [Pro].[Insertdataforoutoforder] ---20-April-2021 for Interest bucket table

UPDATE PACKAGE_AUDIT SET ExecutionEndTime=GETDATE()  WHERE IdentityKey = 6 AND  Execution_date=CAST(GETDATE() AS DATE) AND TableName='Reverse Feed Data'
UPDATE PACKAGE_AUDIT SET ExecutionStatus='Y' WHERE IdentityKey = 6


SELECT 6 AS StepNo, 'Result' AS TableName
END TRY


BEGIN  CATCH
		
		INSERT INTO PRO.ProcessingStepStatus(ProcessingStepName,Completed,ErrorDescription,ErrorDate)
		values('ProcessingSteps6','N',ERROR_MESSAGE(),GETDATE())
		UPDATE PACKAGE_AUDIT SET ExecutionStatus='E' WHERE IdentityKey = 6


END CATCH



END


GO