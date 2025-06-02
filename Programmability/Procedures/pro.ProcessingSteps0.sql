SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROCEDURE [pro].[ProcessingSteps0]
@UserLoginID VARCHAR(50)='DM585'
AS
BEGIN
  DECLARE @TIMEKEY INT = (SELECT TIMEKEY FROM PRO.EXTDATE_MISDB WHERE FLG = 'Y')


  SELECT 'ProcessingSteps' AS TableName, A.PackageAlt_Key AS SRNO,	A.PackageName	,A.PackageDescriptionName, B.ExecutionStartTime,	B.ExecutionEndTime,	B.TimeDuration_Min,	ISNULL(B.ExecutionStatus,'N') AS ExecutionStatus
       FROM DimPackageAudit A LEFT OUTER JOIN [PACKAGE_AUDIT] B ON A.PackageDescriptionName=B.TableName --***********LINE TO BE MODIFIED***********


END


GO