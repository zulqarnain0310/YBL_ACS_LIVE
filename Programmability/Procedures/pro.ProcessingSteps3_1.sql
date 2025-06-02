SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



CREATE PROCEDURE [pro].[ProcessingSteps3_1]
@UserLoginID VARCHAR(50)='DM585'
AS
BEGIN
  DECLARE @TIMEKEY INT = (SELECT TIMEKEY FROM PRO.EXTDATE_MISDB WHERE FLG = 'Y')
  DECLARE @ProcessingDateAudit DATE=(SELECT StartDate FROM PRO.EXTDATE_MISDB WHERE FLG = 'Y')

  DELETE FROM PACKAGE_AUDIT WHERE IdentityKey=3

INSERT INTO PACKAGE_AUDIT(IdentityKey,UserID,Execution_date,PackageName,TableName,ExecutionStartTime,ExecutionStatus,ProcessingDate)    SELECT 3,@UserLoginID, GETDATE(),'Dmd', 'Daily Interest servicing',GETDATE(),'P',@ProcessingDateAudit

----EXEC PRO.ACDAILYTXNDETAILDAILY_INSERT  
------EXEC [dbo].[DemandTableBackup] 
----EXEC [Pro].[DynamicSegmentCreation]
----EXEC DmdRecoSetOffLogicCC_Seg01 
----EXEC DemandDataInsertIntoCurnt_Old

--			EXEC PRO.ACDAILYTXNDETAILDAILY_INSERT 
--------EXEC [dbo].[DemandTableBackup] 
--			EXEC [Pro].[DynamicSegmentCreation]
--			EXEC DmdRecoSetOffLogicCC_Seg01
--			EXEC PRO.ACDAILYTXNDETAILDAILY_INSERT_FITL  
--			EXEC [Pro].[DynamicSegmentCreation_FITL]
--			EXEC [dbo].[DmdRecoSetOffLogicCC_Seg_FITL01] 
--			EXEC DemandDataInsertIntoCurnt_Old



		EXEC PRO.ACDAILYTXNDETAILDAILY_INSERT 
		EXEC [Pro].[DynamicSegmentCreation]
		EXEC DmdRecoSetOffLogicCC_Seg01
		EXEC DemandDataInsertIntoCurnt_Old

		EXEC PRO.ACDAILYTXNDETAILDAILY_INSERT_FITL  
		EXEC [Pro].[DynamicSegmentCreation_FITL]
		EXEC [dbo].[DmdRecoSetOffLogicCC_Seg_FITL01] 
		EXEC DemandDataInsertIntoCurnt_Old_fitl

	-----New Condition Added on 19/11/2021 as per Phase iv Requirement Triloki Khanna Accounts wise Demand Calcualtion -----
	----Condition comment only Cred Avenue Integration 09/03/2022
	----EXEC CCOD_InttDemandService @DATE=@ProcessingDateAudit

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