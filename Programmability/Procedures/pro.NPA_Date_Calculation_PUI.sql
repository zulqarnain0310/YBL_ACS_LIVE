SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


/*=========================================
 AUTHER : TRILOKI KKANNA
 CREATE DATE : 18-11-2017
 MODIFY DATE : 13-05-2022
 DESCRIPTION : CALCULATED NPA DATE 
 --EXEC [PRO].[NPA_DATE_CALCULATION]  @TIMEKEY=25140
=============================================*/
 CREATE PROCEDURE [pro].[NPA_Date_Calculation_PUI]
 @TIMEKEY INT
 with recompile
 AS
 BEGIN
    SET NOCOUNT ON
   BEGIN TRY


DECLARE @INTTSERNORM VARCHAR(50)=(SELECT REFVALUE FROM PRO.REFPERIOD WHERE BUSINESSRULE='RECOVERYADJUSTMENT' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)  --'PROGRESSIVE'
DECLARE @ProcessDate DATE=(SELECT DATE FROM SysDayMatrix WHERE TimeKey=@TIMEKEY)

UPDATE   PRO.AccountCal SET InitialNpaDt=NULL WHERE (InitialNpaDt='1900-01-01'  OR InitialNpaDt='01/01/1900')
UPDATE   PRO.AccountCal SET FinalNpaDt=NULL   WHERE FinalNpaDt='1900-01-01'  OR FinalNpaDt='01/01/1900'

UPDATE   PRO.AccountCal SET InitialNpaDt=NULL,FinalNpaDt=NULL 
FROM PRO.ACCOUNTCAL A INNER JOIN PRO.CustomerCal B ON A.REFCUSTOMERID=B.REFCUSTOMERID
WHERE (ISNULL(B.FlgProcessing,'N')='N' AND ISNULL(A.FLGDEG,'N')='Y')

---New Condition---
UPDATE   PRO.AccountCal SET InitialNpaDt=NULL,FinalNpaDt=NULL 
FROM PRO.ACCOUNTCAL A INNER JOIN PRO.CustomerCal B ON A.SourceSystemCustomerID=B.SourceSystemCustomerID
WHERE (ISNULL(B.FlgProcessing,'N')='N' AND ISNULL(A.FLGDEG,'N')='Y')

---As per Bank Mail New Condition 13/05/2022---

/*------------CALCULATE NpaDt -------------------------------------*/

IF OBJECT_ID('TEMPDB..#TEMPTABLEDPD') IS NOT NULL
	    DROP TABLE #TEMPTABLEDPD

	 SELECT A.CustomerAcID
			,CASE WHEN  isnull(A.DPD_IntService,0)>=isnull(A.RefPeriodIntService,0)		THEN A.DPD_IntService  ELSE 0   END DPD_IntService,  
			 CASE WHEN  isnull(A.DPD_NoCredit,0)>=isnull(A.RefPeriodNoCredit,0)			THEN A.DPD_NoCredit    ELSE 0   END DPD_NoCredit,  
			 CASE WHEN  isnull(A.DPD_Overdrawn,0)>=isnull(A.RefPeriodOverDrawn	,0)	    THEN A.DPD_Overdrawn   ELSE 0   END DPD_Overdrawn,  
			 CASE WHEN  isnull(A.DPD_Overdue,0)>=isnull(A.RefPeriodOverdue	,0)		    THEN A.DPD_Overdue     ELSE 0   END DPD_Overdue , 
			 CASE WHEN  isnull(A.DPD_Renewal,0)>=isnull(A.RefPeriodReview	,0)			THEN A.DPD_Renewal     ELSE 0   END  DPD_Renewal ,
			 CASE WHEN  isnull(A.DPD_StockStmt,0)>=isnull(A.RefPeriodStkStatement,0)       THEN A.DPD_StockStmt   ELSE 0   END DPD_StockStmt  
			 INTO #TEMPTABLEDPD
			  FROM PRO.ACCOUNTCAL A 
			 WHERE ( 
			          isnull(DPD_IntService,0)>=isnull(RefPeriodIntService,0)
                   OR isnull(DPD_NoCredit,0)>=isnull(RefPeriodNoCredit,0)
				   OR isnull(DPD_Overdrawn,0)>=isnull(RefPeriodOverDrawn,0)
				   OR isnull(DPD_Overdue,0)>=isnull(RefPeriodOverdue,0)
				   OR isnull(DPD_Renewal,0)>=isnull(RefPeriodReview,0)
                   OR isnull(DPD_StockStmt,0)>=isnull(RefPeriodStkStatement,0)
			      ) 
	
					  
IF OBJECT_ID('TEMPDB..#TEMPTABLENPA') IS NOT NULL
DROP TABLE #TEMPTABLENPA

select A.CustomerAcID 
	   ,CASE  WHEN (isnull(A.DPD_IntService,0)>=isnull(A.DPD_NoCredit,0) AND isnull(A.DPD_IntService,0)>=isnull(A.DPD_Overdrawn,0) AND isnull(A.DPD_IntService,0)>=isnull(A.DPD_Overdue,0) AND isnull(A.DPD_IntService,0)>=isnull(A.DPD_Renewal,0) AND isnull(A.DPD_IntService,0)>=isnull(A.DPD_StockStmt,0)) 
				THEN isnull(a.DPD_IntService,0)
				
		WHEN (isnull(A.DPD_NoCredit,0)>=isnull(A.DPD_IntService,0) AND isnull(A.DPD_NoCredit,0)>=isnull(A.DPD_Overdrawn,0) AND isnull(A.DPD_NoCredit,0)>=isnull(A.DPD_Overdue,0) AND isnull(A.DPD_NoCredit,0)>=isnull(A.DPD_Renewal,0) AND isnull(A.DPD_NoCredit,0)>=isnull(A.DPD_StockStmt,0)) 
			THEN isnull(a.DPD_NoCredit,0)
				
		WHEN (isnull(A.DPD_Overdrawn,0)>=isnull(A.DPD_NoCredit,0)  AND isnull(A.DPD_Overdrawn,0)>= isnull(A.DPD_IntService,0) AND  isnull(A.DPD_Overdrawn,0)>=isnull(A.DPD_Overdue,0) AND isnull(A.DPD_Overdrawn,0)>=isnull(A.DPD_Renewal,0) AND isnull(A.DPD_Overdrawn,0)>=isnull(A.DPD_StockStmt,0))
			THEN isnull(a.DPD_Overdrawn,0)
				
		WHEN (isnull(A.DPD_Renewal,0)>=isnull(A.DPD_NoCredit ,0) AND isnull(A.DPD_Renewal,0)>= isnull(A.DPD_IntService ,0) AND  isnull(A.DPD_Renewal,0)>=isnull(A.DPD_Overdrawn,0)  AND   isnull(A.DPD_Renewal,0)>=isnull(A.DPD_Overdue,0)  AND isnull(A.DPD_Renewal,0) >=isnull(A.DPD_StockStmt ,0)) 
			THEN isnull(a.DPD_Renewal,0)
				
		WHEN (isnull(A.DPD_Overdue,0)>=isnull(A.DPD_NoCredit ,0) AND isnull(A.DPD_Overdue,0)>= isnull(A.DPD_IntService ,0) AND  isnull(A.DPD_Overdue,0)>=isnull(A.DPD_Overdrawn,0)  AND   isnull(A.DPD_Overdue,0)>=isnull(A.DPD_Renewal,0)  AND isnull(A.DPD_Overdue,0) >=isnull(A.DPD_StockStmt,0) )
			THEN isnull(a.DPD_Overdue,0)
				
		ELSE isnull(a.DPD_StockStmt,0)
				
	END AS REFPERIODNPA

	INTO #TEMPTABLENPA    
FROM #TEMPTABLEDPD A 	 INNER JOIN  PRO.ACCOUNTCAL B   ON A.CustomerAcID=B.CustomerAcID  



UPDATE  A  SET FinalNpaDt= DATEADD(DAY,ISNULL(REFPERIODMAX,0),DATEADD(DAY,-ISNULL(REFPERIODNPA,0),@ProcessDate))
FROM PRO.ACCOUNTCAL A INNER JOIN #TEMPTABLENPA B ON A.CustomerAcID=B.CustomerAcID
WHERE  ISNULL(A.FLGDEG,'N')='Y'

----UPDATE  A  SET FinalNpaDt= DATEADD(DAY,ISNULL(REFPERIODMAX,0),DATEADD(DAY,-ISNULL(DPD_MAX,0),@ProcessDate))
----FROM PRO.ACCOUNTCAL A INNER JOIN PRO.CustomerCal B ON A.REFCUSTOMERID=B.REFCUSTOMERID
----WHERE (ISNULL(B.FlgProcessing,'N')='N' AND ISNULL(A.FLGDEG,'N')='Y')



UPDATE   A SET  A.FINALNPADT=@ProcessDate  
FROM PRO.ACCOUNTCAL A  INNER JOIN PRO.CUSTOMERCAL B ON A.REFCUSTOMERID =B.REFCUSTOMERID
WHERE A.ASSET_NORM='ALWYS_NPA' AND  isnull(a.FLGDEG,'N')='Y' 


EXEC  [PRO].[PUI_Process] 'N' -- CALCULATE npa DATE FOR PUI DATA

 

/*------MIN NPA DATE CUSTOMER LEVEL ---------------------*/

UPDATE A SET A.SysNPA_Dt=C.FinalNpaDt,
             A.FlgDeg='Y'
 FROM PRO.CustomerCal A INNER JOIN
(
	SELECT A.REFCUSTOMERID,MIN(A.FinalNpaDt) FinalNpaDt  FROM PRO.AccountCal  A 
	INNER JOIN PRO.CustomerCal B ON A.REFCUSTOMERID=B.REFCUSTOMERID
	WHERE ISNULL(A.FlgDeg,'N')='Y' AND ISNULL(B.FlgProcessing,'N')='N' 
	GROUP BY A.REFCUSTOMERID

) C ON A.REFCUSTOMERID=C.REFCUSTOMERID
 AND (ISNULL(A.FlgProcessing,'N')='N')

---New Condition---

UPDATE A SET A.SysNPA_Dt=C.FinalNpaDt,
             A.FlgDeg='Y'
 FROM PRO.CustomerCal A INNER JOIN
(
	SELECT A.SourceSystemCustomerID,MIN(A.FinalNpaDt) FinalNpaDt  FROM PRO.AccountCal  A 
	INNER JOIN PRO.CustomerCal B ON A.SourceSystemCustomerID=B.SourceSystemCustomerID
	WHERE ISNULL(A.FlgDeg,'N')='Y' AND ISNULL(B.FlgProcessing,'N')='N' 
	GROUP BY A.SourceSystemCustomerID

) C ON A.SourceSystemCustomerID=C.SourceSystemCustomerID
 AND (ISNULL(A.FlgProcessing,'N')='N')

/*-----UPDATE Initial LEVEL InitialNpaDt IS SET NULL FOR Fresh Npa Accounts---------*/

UPDATE A SET A.FINALNPADT=B.SysNPA_Dt
FROM  PRO.ACCOUNTCAL A INNER JOIN  PRO.CustomerCal  B ON A.REFCUSTOMERID=B.REFCUSTOMERID
WHERE ISNULL(A.ASSET_NORM,'NORMAL')<>'ALWYS_STD' AND ISNULL(A.FlgDeg,'N')='Y' AND ISNULL(B.FlgProcessing,'N')='N'
 
---New Condition---

UPDATE A SET A.FINALNPADT=B.SysNPA_Dt
FROM  PRO.ACCOUNTCAL A INNER JOIN  PRO.CustomerCal  B ON A.SourceSystemCustomerID=B.SourceSystemCustomerID
WHERE ISNULL(A.ASSET_NORM,'NORMAL')<>'ALWYS_STD' AND ISNULL(A.FlgDeg,'N')='Y' AND ISNULL(B.FlgProcessing,'N')='N'

		UPDATE PRO.ACLRUNNINGPROCESSSTATUS 
		SET COMPLETED='Y',ERRORDATE=NULL,ERRORDESCRIPTION=NULL,COUNT=ISNULL(COUNT,0)+1
		WHERE RUNNINGPROCESSNAME='NPA_Date_Calculation'
END TRY
BEGIN  CATCH
	   UPDATE PRO.ACLRUNNINGPROCESSSTATUS 
	   SET COMPLETED='N',ERRORDATE=GETDATE(),ERRORDESCRIPTION=ERROR_MESSAGE(),COUNT=ISNULL(COUNT,0)+1
	   WHERE RUNNINGPROCESSNAME='NPA_Date_Calculation'
END CATCH
SET NOCOUNT OFF
END
GO