SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



/*=========================================
 AUTHER : SANJEEV KUMAR SHARMA
 CREATE DATE : 18-11-2017
 MODIFY DATE : 18-11-2017
 DESCRIPTION : MARKING OF FLGDEG AND DEG REASON 
 --EXEC [PRO].[Marking_NPA_Reason_NPAAccount]  @TIMEKEY=25140
=============================================*/
CREATE PROCEDURE [pro].[Marking_NPA_Reason_NPAAccount]
@TIMEKEY INT
with recompile
AS
BEGIN
    SET NOCOUNT ON 
  BEGIN TRY

DECLARE @PROCESSDATE DATE =(SELECT DATE FROM SYSDAYMATRIX WHERE TIMEKEY=@TIMEKEY)

UPDATE PRO.ACCOUNTCAL SET NPA_REASON=NULL

----UPDATE A SET a.NPA_Reason='Account Restructured after 01-04-2015'
----FROM PRO.AccountCal A INNER JOIN Curdat.AdvAcRestructureDetail B ON A.AccountEntityID=B.AccountEntityId
----AND (B.EffectiveFromTimeKey<=@TIMEKEY AND B.EffectiveToTimeKey>=@TIMEKEY)
----INNER JOIN PRO.CustomerCal C ON C.CustomerEntityID=A.CustomerEntityID
----WHERE B.RestructureDt IS NOT NULL AND RestructureDt >'2015-04-01'  AND ISNULL(FinalAssetClassAlt_Key,1)<>1 


/*----REVERSING DEGRADED ACCOUNT THROUGH NORMAL  PROCESS--------------*/
----UPDATE B SET 

---- b.NPA_Reason=(CASE WHEN ISNULL(SDR_INVOKED,'N')='Y' AND   SDR_REFER_DATE >DATEADD(MONTH,-18,@PROCESSDATE) THEN null
----ELSE B.NPA_Reason end)

----FROM  Curdat.AdvAcRestructureDetail A INNER JOIN PRO.AccountCal
---- B ON A.AccountEntityId=B.AccountEntityID
---- AND A.EffectiveFromTimeKey<=@TIMEKEY AND A.EffectiveToTimeKey>=@TIMEKEY
---- INNER JOIN PRO.CustomerCal C ON C.CustomerEntityID=B.CustomerEntityID
---- WHERE  C.CustomerEntityID  NOT IN(SELECT CustomerEntityID FROM AdvAcProjectDetail WHERE EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
---- AND  A.SDR_REFER_DATE IS NOT NULL   AND ISNULL(FinalAssetClassAlt_Key,1)<>1 


----UPDATE B SET 
---- b.NPA_Reason=(CASE WHEN ISNULL(S4A_IMPLEMENTAION_FLG,'N')='Y' AND   S4A_REFERENCE_DATE >DATEADD(DAY,-180,@PROCESSDATE) THEN null
----    ELSE b.NPA_Reason
---- END)
----FROM   PRO.AccountCaL B
----INNER JOIN AdvAcProjectDetail C ON C.RefAccountEntityId=B.AccountEntityID
----AND  C.EffectiveFromTimeKey<=@TIMEKEY AND C.EffectiveToTimeKey>=@TIMEKEY
----INNER JOIN PRO.CustomerCal D ON D.CustomerEntityID=B.CustomerEntityID
----WHERE   S4A_REFERENCE_DATE IS NOT NULL AND  ISNULL(FinalAssetClassAlt_Key,1)<>1 


----UPDATE C SET 
----c.NPA_Reason =( CASE WHEN  ISNULL(SDR_INVOKED,'N')='N'  AND ISNULL(S4A_IMPLEMENTAION_FLG,'N')='N' 
----AND  RevisedCompletionDt>@PROCESSDATE THEN null ELSE c.NPA_Reason  END )

---- FROM Curdat.AdvAcRestructureDetail A INNER JOIN AdvAcProjectDetail B ON A.AccountEntityId=B.RefAccountEntityId
---- AND (A.EffectiveFromTimeKey<=@TIMEKEY AND A.EffectiveToTimeKey>=@TIMEKEY)
---- AND (B.EffectiveFromTimeKey<=@TIMEKEY AND B.EffectiveToTimeKey>=@TIMEKEY)
---- INNER JOIN PRO.AccountCal C ON  C.AccountEntityID=A.AccountEntityId
---- INNER JOIN PRO.CustomerCal D ON D.CustomerEntityID=C.CustomerEntityID
---- WHERE   B.RevisedCompletionDt IS NOT NULL AND  ISNULL(FinalAssetClassAlt_Key,1)<>1 
 

UPDATE   A SET  A.NPA_Reason=isnull(A.NPA_Reason,'')+' Degarde Account due to ALWYS_NPA and balance >0'  
FROM PRO.ACCOUNTCAL A  INNER JOIN PRO.CUSTOMERCAL B ON A.CUSTOMERENTITYID =B.CUSTOMERENTITYID
WHERE A.ASSET_NORM='ALWYS_NPA' AND isnull(FinalAssetClassAlt_Key,1)<>1 AND  (B.FLGPROCESSING='N') 

UPDATE A SET A.NPA_Reason= ISNULL(A.NPA_Reason,'')+' DEGRADE BY INT NOT SERVICED'  
FROM PRO.AccountCal A INNER JOIN PRO.CustomerCal B ON A.CustomerEntityID =B.CustomerEntityID
WHERE (B.FlgProcessing='N')  AND ( isnull(FinalAssetClassAlt_Key,1)<>1 AND (A.DPD_INTSERVICE>0))
 
UPDATE A SET A.NPA_Reason= ISNULL(A.NPA_Reason,'')+', DEGRADE BY CONTI EXCESS'
FROM PRO.AccountCal A INNER JOIN PRO.CustomerCal B ON A.CustomerEntityID =B.CustomerEntityID
WHERE (B.FlgProcessing='N')  AND ( isnull(FinalAssetClassAlt_Key,1)<>1 AND A.DPD_OVERDRAWN>0)  

UPDATE A SET NPA_Reason= ISNULL(A.NPA_Reason,'')+', DEGRADE BY NO CREDIT'      
FROM PRO.AccountCal A INNER JOIN PRO.CustomerCal B ON A.CustomerEntityID =B.CustomerEntityID
WHERE (B.FlgProcessing='N')  AND ( isnull(FinalAssetClassAlt_Key,1)<>1 AND A.DPD_NOCREDIT>0 ) 

UPDATE A SET A.NPA_Reason= ISNULL(A.NPA_Reason,'')+', DEGRADE BY OVERDUE'            
FROM PRO.AccountCal A INNER JOIN PRO.CustomerCal B ON A.CustomerEntityID =B.CustomerEntityID
WHERE (B.FlgProcessing='N')  AND ( isnull(FinalAssetClassAlt_Key,1)<>1 AND A.DPD_OVERDUE >0)  

UPDATE A SET A.NPA_Reason= ISNULL(A.NPA_Reason,'')+', DEGRADE BY DEBIT BALANCE '            
FROM PRO.AccountCal A INNER JOIN PRO.CustomerCal B ON A.CustomerEntityID =B.CustomerEntityID
INNER JOIN DimProduct C ON  A.ProductAlt_Key=C.ProductAlt_Key AND (C.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey)
WHERE (B.FlgProcessing='N')  AND ( isnull(FinalAssetClassAlt_Key,1)<>1 AND A.DPD_OVERDUE >0)  
AND A.DebitSinceDt IS NOT NULL AND ISNULL(C.SrcSysProductCode,'N')='SAVING'

UPDATE A SET NPA_Reason= ISNULL(A.NPA_Reason,'')+', DEGRADE BY STOCK STATEMENT'    
FROM PRO.AccountCal A INNER JOIN PRO.CustomerCal B ON A.CustomerEntityID =B.CustomerEntityID
WHERE (B.FlgProcessing='N')  AND ( isnull(FinalAssetClassAlt_Key,1)<>1 AND A.DPD_STOCKSTMT>0)  

UPDATE A SET A.NPA_Reason= ISNULL(A.NPA_Reason,'')+', DEGRADE BY REVIEW DUE DATE'    
FROM PRO.AccountCal A INNER JOIN PRO.CustomerCal B ON A.CustomerEntityID =B.CustomerEntityID
WHERE (B.FlgProcessing='N')  AND ( isnull(FinalAssetClassAlt_Key,1)<>1AND A.DPD_RENEWAL>0)  


UPDATE A SET A.NPA_REASON=ISNULL(A.NPA_REASON,'')+'DEGARDE BY MOC'
FROM   PRO.ACCOUNTCAL A INNER JOIN  pro.ChangedMocAclStatus B ON A.CUSTOMERENTITYID=B.CUSTOMERENTITYID
AND (B.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND B.EFFECTIVETOTIMEKEY>=@TIMEKEY)
and a.Asset_Norm='NORMAL'

/*FOR OTS CR ADDED BY ZAIN  ON LOCAL 20250213*/
UPDATE A SET A.NPA_Reason= ISNULL(A.NPA_Reason,'')+', DEGRADE BY OTS'    
FROM PRO.AccountCal A INNER JOIN PRO.CustomerCal B ON A.CustomerEntityID =B.CustomerEntityID
WHERE (B.FlgProcessing='N')  AND A.OTS_Settlement_Flag='Y'
/*FOR OTS CR ADDED BY ZAIN  ON LOCAL 20250213*/

/*FOR DCCO CR ADDED BY ZAIN  ON LOCAL 20250303*/
UPDATE A SET A.NPA_Reason= ISNULL(A.NPA_Reason,'')+', DEGRADE BY DCCO'    
FROM PRO.AccountCal A INNER JOIN PRO.CustomerCal B ON A.CustomerEntityID =B.CustomerEntityID
WHERE (B.FlgProcessing='N')  AND ((DATEDIFF(DAY,A.FIN_DCCO_DATE,@PROCESSDATE)+1)>0 AND A.Utilisation>0)
/*FOR DCCO CR ADDED BY ZAIN  ON LOCAL 20250303*/

--Changed by Triloki 28-01-22 /30-11-2022 for Quarter End
IF (	 (MONTH(@PROCESSDATE) IN(3,12) AND DAY(@PROCESSDATE)=31)
	  OR (MONTH(@PROCESSDATE) IN(6,9)  AND DAY(@PROCESSDATE)=30)
	)
BEGIN

UPDATE A SET A.NPA_Reason= ISNULL(A.NPA_Reason,'')+', DEGRADE BY EROSION'    
FROM PRO.AccountCal A INNER JOIN PRO.CustomerCal B ON A.CustomerEntityID =B.CustomerEntityID
WHERE b.FlgErosion='Y' and A.NPA_Reason not like '%EROSION%'

End

UPDATE PRO.ACLRUNNINGPROCESSSTATUS 
SET COMPLETED='Y',ERRORDATE=NULL,ERRORDESCRIPTION=NULL,COUNT=ISNULL(COUNT,0)+1
WHERE RUNNINGPROCESSNAME='Marking_NPA_Reason_NPAAccount'


END TRY
BEGIN  CATCH

UPDATE PRO.ACLRUNNINGPROCESSSTATUS 
SET COMPLETED='N',ERRORDATE=GETDATE(),ERRORDESCRIPTION=ERROR_MESSAGE(),COUNT=ISNULL(COUNT,0)+1
WHERE RUNNINGPROCESSNAME='Marking_NPA_Reason_NPAAccount'
END CATCH
SET NOCOUNT OFF
END




GO