SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


/*
 Created by   : Baijayanti
 Created date : 12/09/2022
 Report Name  : Asset Classification Master Report As On
*/

CREATE Proc [dbo].[Rpt-20034]
 @TimeKey AS INT 
AS

--DECLARE
--@TimeKey AS  INT = 25705


SELECT 
DISTINCT 	
 CASE WHEN BusinessRule IN('SUB_Months','DB1_Months','DB2_Months')
      THEN 'Asset Classification'
	  WHEN BusinessRule IN('MoveToDB1','MoveToLoss')
	  THEN 'Security Erosion'
	  END                                                               AS [Type]	
,CASE WHEN BusinessRule='SUB_Months'
      THEN 'Sub standard'
	  WHEN BusinessRule='DB1_Months'
	  THEN 'Doubtful 1'
	  WHEN BusinessRule='DB2_Months'
	  THEN 'Doubtful 2'
	  WHEN BusinessRule IN('MoveToDB1','MoveToLoss')
	  THEN 'Sub standard'
	  END                                                               AS [From]	
,CASE WHEN BusinessRule='SUB_Months'
      THEN 'Doubtful 1'
	  WHEN BusinessRule='DB1_Months'
	  THEN 'Doubtful 2'
	  WHEN BusinessRule='DB2_Months'
	  THEN 'Doubtful 3'
	  WHEN BusinessRule='MoveToDB1'
	  THEN 'Move To DB1'
	  WHEN BusinessRule='MoveToLoss'
	  THEN 'Move To Loss'
	  END                                                               AS [To]	
,RefValue                                                               AS [Value]	
,CASE WHEN BusinessRule IN('SUB_Months','DB1_Months','DB2_Months')
      THEN 'Month'
	  WHEN BusinessRule IN('MoveToDB1','MoveToLoss')
	  THEN 'Percent'
	  END                                                               AS [Unit]	

FROM Pro.RefPeriod
WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
      AND BusinessRule IN('SUB_Months','DB1_Months','DB2_Months','MoveToDB1','MoveToLoss')

  Order by Type,[To] asc	
  														
OPTION(RECOMPILE)
GO