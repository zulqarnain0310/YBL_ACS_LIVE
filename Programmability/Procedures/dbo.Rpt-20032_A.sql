SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


/*
 Created by   : KALIK DEV
 Created date : 15/02/2022
 Report Name  : Borrower Not in outstanding data As On 
*/

CREATE Proc [dbo].[Rpt-20032_A]
 @TimeKey AS INT ,
 @SelectReport AS INT
AS


--DECLARE
--@TimeKey AS  INT = 25705, 
--@SelectReport AS INT = 1


DECLARE @DATE AS DATE =(SELECT DATE FROM SysDayMatrix WHERE TimeKey = @TimeKey)


SELECT 
	
SourceName													AS SourceSys,
A.RefCustomerID												AS CUST_ID,
C.CustomerName												AS CustomerName,
A.ActSegmentCode                                            AS BS,
C.CustomerPartnerSegment                                    AS PS, 
A.BranchCode											AS Branch,
--DB.BranchName												AS Branch,
CONVERT(VARCHAR(20),A.ReviewDueDt,103)						AS ExpiryDt,
CONVERT(VARCHAR(20),DATEDIFF(DD,A.ReviewDueDt,@DATE))		AS DPD_day

FROM PRO.AccountCal_Hist	A

INNER JOIN PRO.CustomerCal_Hist		C						ON A.UcifEntityID = C.UcifEntityID
															AND  A.EffectiveFromTimeKey<=@Timekey
															AND	 A.EffectiveToTimeKey>=@Timekey
															AND  C.EffectiveFromTimeKey<=@TimeKey
															AND  C.EffectiveToTimeKey>=@TimeKey

INNER JOIN DimSourceDB			DS							ON A.SourceAlt_Key = DS.SourceAlt_Key
															AND  DS.EffectiveFromTimeKey<=@Timekey
															AND	 DS.EffectiveToTimeKey>=@Timekey                                                    
															
LEFT JOIN DimBranch			DB							ON C.BranchCode = DB.BranchCode
															AND  DB.EffectiveFromTimeKey<=@Timekey
															AND	 DB.EffectiveToTimeKey>=@Timekey

WHERE (ISNULL(A.BALANCE,0) = 0	AND A.ReviewDueDt<=DATEADD(DD,-180,@DATE) AND @SelectReport=1)
      OR (ISNULL(A.BALANCE,0) = 0	AND A.ReviewDueDt<=DATEADD(DD,-180,@DATE) AND @SelectReport=3)
OPTION(RECOMPILE)
GO