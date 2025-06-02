SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/*=========================================================
 AUTHER : SANJEEV KUMAR SHARMA
 CREATE DATE : 18-11-2017
 MODIFY DATE : 02-11-2018
 DESCRIPTION : CALCULATED MAX DPD AND REGARD OF REFERENCE PERIOD ON  MAX DPD
 --EXEC [Pro].[MaxDPD_ReferencePeriod_Calculation] 25140
==============================================================*/
CREATE PROCEDURE [pro].[MaxDPD_ReferencePeriod_Calculation]
@TIMEKEY INT
with recompile
AS
BEGIN
     SET NOCOUNT ON;
     BEGIN TRY

/*FOR OTS CR ADDED BY ZAIN  ON LOCAL 20250213*/
DECLARE @PROCESSDATE DATE =(SELECT Date FROM SysDayMatrix where TimeKey=@TIMEKEY)
/*FOR OTS CR ADDED BY ZAIN  ON LOCAL 20250213 END*/

	 IF OBJECT_ID('TEMPDB..#TEMPTABLE') IS NOT NULL
	    DROP TABLE #TEMPTABLE

	 SELECT A.CustomerAcID
			,CASE WHEN  isnull(A.DPD_IntService,0)>=isnull(A.RefPeriodIntService,0)		THEN A.DPD_IntService  ELSE 0   END DPD_IntService,  
			 CASE WHEN  isnull(A.DPD_NoCredit,0)>=isnull(A.RefPeriodNoCredit,0)			THEN A.DPD_NoCredit    ELSE 0   END DPD_NoCredit,  
			 CASE WHEN  isnull(A.DPD_Overdrawn,0)>=isnull(A.RefPeriodOverDrawn	,0)	    THEN A.DPD_Overdrawn   ELSE 0   END DPD_Overdrawn,  
			 CASE WHEN  isnull(A.DPD_Overdue,0)>=isnull(A.RefPeriodOverdue	,0)		    THEN A.DPD_Overdue     ELSE 0   END DPD_Overdue , 
			 CASE WHEN  isnull(A.DPD_Renewal,0)>=isnull(A.RefPeriodReview	,0)			THEN A.DPD_Renewal     ELSE 0   END  DPD_Renewal ,
			 CASE WHEN  isnull(A.DPD_StockStmt,0)>=isnull(A.RefPeriodStkStatement,0)       THEN A.DPD_StockStmt   ELSE 0   END DPD_StockStmt  
			 INTO #TEMPTABLE
			 --FROM PRO.ACCOUNTCAL A inner join pro.CustomerCal B on a.RefCustomerID=b.RefCustomerID
			 FROM PRO.ACCOUNTCAL A inner join pro.CustomerCal B on A.SourceSystemCustomerID=B.SourceSystemCustomerID
			 WHERE ( 
			          isnull(DPD_IntService,0)>=isnull(RefPeriodIntService,0)
                   OR isnull(DPD_NoCredit,0)>=isnull(RefPeriodNoCredit,0)
				   OR isnull(DPD_Overdrawn,0)>=isnull(RefPeriodOverDrawn,0)
				   OR isnull(DPD_Overdue,0)>=isnull(RefPeriodOverdue,0)
				   OR isnull(DPD_Renewal,0)>=isnull(RefPeriodReview,0)
                   OR isnull(DPD_StockStmt,0)>=isnull(RefPeriodStkStatement,0)
			      ) AND (isnull(B.FlgProcessing,'N')='N' 
	
			      )

			    
				--and A.RefCustomerID<>'0'

/*--------------INTIAL MAX DPD 0 FOR RE PROCESSING DATA-------------------------*/

UPDATE A SET A.DPD_Max=0
 FROM PRO.ACCOUNTCAL A 
 --inner join PRO.CUSTOMERCAL B on A.RefCustomerID=B.RefCustomerID
 --WHERE  isnull(B.FlgProcessing,'N')='N'  


/*----------------FIND MAX DPD---------------------------------------*/

UPDATE   A SET A.DPD_Max= (CASE    WHEN (isnull(A.DPD_IntService,0)>=isnull(A.DPD_NoCredit,0) AND isnull(A.DPD_IntService,0)>=isnull(A.DPD_Overdrawn,0) AND    isnull(A.DPD_IntService,0)>=isnull(A.DPD_Overdue,0) AND  isnull(A.DPD_IntService,0)>=isnull(A.DPD_Renewal,0) AND isnull(A.DPD_IntService,0)>=isnull(A.DPD_StockStmt,0)) THEN isnull(A.DPD_IntService,0)
                                   WHEN (isnull(A.DPD_NoCredit,0)>=isnull(A.DPD_IntService,0) AND isnull(A.DPD_NoCredit,0)>=  isnull(A.DPD_Overdrawn,0) AND    isnull(A.DPD_NoCredit,0)>=isnull(A.DPD_Overdue,0) AND    isnull(A.DPD_NoCredit,0)>=  isnull(A.DPD_Renewal,0) AND isnull(A.DPD_NoCredit,0)>=isnull(A.DPD_StockStmt,0)) THEN   isnull(A.DPD_NoCredit ,0)
								   WHEN (isnull(A.DPD_Overdrawn,0)>=isnull(A.DPD_NoCredit,0)  AND isnull(A.DPD_Overdrawn,0)>= isnull(A.DPD_IntService,0)  AND  isnull(A.DPD_Overdrawn,0)>=isnull(A.DPD_Overdue,0) AND   isnull(A.DPD_Overdrawn,0)>= isnull(A.DPD_Renewal,0) AND isnull(A.DPD_Overdrawn,0)>=isnull(A.DPD_StockStmt,0)) THEN  isnull(A.DPD_Overdrawn,0)
								   WHEN (isnull(A.DPD_Renewal,0)>=isnull(A.DPD_NoCredit,0)    AND isnull(A.DPD_Renewal,0)>=   isnull(A.DPD_IntService,0)  AND  isnull(A.DPD_Renewal,0)>=isnull(A.DPD_Overdrawn,0)  AND  isnull(A.DPD_Renewal,0)>=   isnull(A.DPD_Overdue,0)  AND isnull(A.DPD_Renewal,0) >=isnull(A.DPD_StockStmt ,0)) THEN isnull(A.DPD_Renewal,0)
	                               WHEN (isnull(A.DPD_Overdue,0)>=isnull(A.DPD_NoCredit,0)    AND isnull(A.DPD_Overdue,0)>=   isnull(A.DPD_IntService,0)  AND  isnull(A.DPD_Overdue,0)>=isnull(A.DPD_Overdrawn,0)  AND  isnull(A.DPD_Overdue,0)>=   isnull(A.DPD_Renewal,0)  AND isnull(A.DPD_Overdue ,0)>=isnull(A.DPD_StockStmt ,0))  THEN   isnull(A.DPD_Overdue,0)
								   ELSE isnull(A.DPD_StockStmt,0) END) 
			 
FROM  PRO.AccountCal a 
--INNER JOIN PRO.CUSTOMERCAL C ON C.RefCustomerID=a.RefCustomerID
INNER JOIN PRO.CUSTOMERCAL C ON C.SourceSystemCustomerID=a.SourceSystemCustomerID
WHERE  (isnull(C.FlgProcessing,'N')='N') 
AND 
(isnull(A.DPD_IntService,0)>0   OR isnull(A.DPD_Overdrawn,0)>0   OR  Isnull(A.DPD_Overdue,0)>0	 OR isnull(A.DPD_Renewal,0) >0 OR
isnull(A.DPD_StockStmt,0)>0 OR isnull(DPD_NoCredit,0)>0)

/*FOR OTS CR ADDED BY ZAIN  ON LOCAL 20250213*/
		UPDATE A SET A.DPD_MAX=CASE 
								WHEN A.DPD_MAX>A.DPD_OTS
										THEN A.DPD_MAX 
								ELSE A.DPD_OTS END
			 FROM PRO.ACCOUNTCAL A
			 INNER JOIN PRO.CUSTOMERCAL C ON C.SourceSystemCustomerID=a.SourceSystemCustomerID
			 WHERE  A.OTS_SETTLEMENT_FLAG='Y'
					AND A.SOURCEALT_KEY IN (3,4)
					AND (isnull(C.FlgProcessing,'N')='N') 
					AND (isnull(A.DPD_OTS,0)>0)
/*FOR OTS CR ADDED BY ZAIN  ON LOCAL 20250213 END*/

/*FOR DCCO CR ADDED BY ZAIN  ON LOCAL 20250303*/
		UPDATE A SET A.DPD_MAX=CASE 
								WHEN A.DPD_MAX>A.DPD_DCCO
										THEN A.DPD_MAX 
								ELSE A.DPD_DCCO END
			 FROM PRO.ACCOUNTCAL A
			 INNER JOIN PRO.CUSTOMERCAL C ON C.SourceSystemCustomerID=a.SourceSystemCustomerID
			 WHERE  A.FIN_DCCO_DATE IS NOT NULL
					AND (isnull(C.FlgProcessing,'N')='N') 
					AND (isnull(A.DPD_DCCO,0)>0)
/*FOR DCCO CR ADDED BY ZAIN  ON LOCAL 20250303 END*/

/*----------------DPD_FinMaxType ---------------------------------------*/

UPDATE   a SET a.DPD_FinMaxType= (CASE   WHEN (isnull(A.DPD_IntService,0)>= isnull(A.DPD_NoCredit,0)   AND isnull(A.DPD_IntService,0)>= isnull(A.DPD_Overdrawn,0)   AND  isnull(A.DPD_IntService,0)>= isnull(A.DPD_Overdue,0)	 AND isnull(A.DPD_IntService,0)>= isnull(A.DPD_Renewal,0) AND isnull(A.DPD_IntService,0)>=isnull(A.DPD_StockStmt,0)) THEN 'RefPeriodIntService'
										 WHEN (isnull(A.DPD_NoCredit,0)>=   isnull(A.DPD_IntService,0) AND isnull(A.DPD_NoCredit,0)>=   isnull(A.DPD_Overdrawn,0)   AND  isnull(A.DPD_NoCredit,0)>=   isnull(A.DPD_Overdue,0)	 AND isnull(A.DPD_NoCredit,0)>=  isnull(A.DPD_Renewal,0) AND  isnull(A.DPD_NoCredit,0)>=isnull(A.DPD_StockStmt,0)) THEN 'RefPeriodNoCredit'
										 WHEN (isnull(A.DPD_Overdrawn,0)>=  isnull(A.DPD_NoCredit,0)   AND isnull(A.DPD_Overdrawn,0)>=  isnull(A.DPD_IntService,0)  AND  isnull(A.DPD_Overdrawn,0)>=  isnull(A.DPD_Overdue,0)	 AND isnull(A.DPD_Overdrawn,0)>= isnull(A.DPD_Renewal,0) AND  isnull(A.DPD_Overdrawn,0)>=isnull(A.DPD_StockStmt,0)) THEN 'RefPeriodOverDrawn'
										 WHEN (isnull(A.DPD_Renewal,0)>=    isnull(A.DPD_NoCredit,0)   AND isnull(A.DPD_Renewal,0)>=    isnull(A.DPD_IntService,0)  AND  isnull(A.DPD_Renewal,0)>=    isnull(A.DPD_Overdrawn,0)  AND isnull(A.DPD_Renewal,0)>= isnull(A.DPD_Overdue,0)  AND   isnull(A.DPD_Renewal,0) >=isnull(A.DPD_StockStmt ,0)) THEN 'RefPeriodReview'
										 WHEN (isnull(A.DPD_Overdue,0)>=    isnull(A.DPD_NoCredit,0)   AND isnull(A.DPD_Overdue,0)>=    isnull(A.DPD_IntService,0)  AND  isnull(A.DPD_Overdue,0)>=    isnull(A.DPD_Overdrawn,0)  AND isnull(A.DPD_Overdue,0)>=isnull(A.DPD_Renewal,0)  AND    isnull(A.DPD_Overdue,0) >=isnull(A.DPD_StockStmt,0) )  THEN 'RefPeriodOverdue'
								   ELSE 'RefPeriodStkStatement' END) 
			 
FROM  PRO.AccountCal a 
--INNER JOIN PRO.CUSTOMERCAL C ON C.RefCustomerID=a.RefCustomerID
INNER JOIN PRO.CUSTOMERCAL C ON C.SourceSystemCustomerID=a.SourceSystemCustomerID
WHERE  ( isnull(C.FlgProcessing,'N')='N') 
AND 
( 
    ISNULL(A.DPD_INTSERVICE,0)>0   
 OR ISNULL(A.DPD_OVERDRAWN,0)>0   
 OR ISNULL(A.DPD_OVERDUE,0)>0	 
 OR ISNULL(A.DPD_RENEWAL,0) >0 
 OR ISNULL(A.DPD_STOCKSTMT,0)>0 
 OR ISNULL(DPD_NOCREDIT,0)>0
)

	
	
/*-------Update REFPeriodMax---------------------------*/


IF OBJECT_ID('TEMPDB..#TEMPTABLE2') IS NOT NULL
   DROP TABLE #TEMPTABLE2

select A.CustomerAcID ,CASE  WHEN (isnull(A.DPD_IntService,0)>=isnull(A.DPD_NoCredit,0) AND isnull(A.DPD_IntService,0)>=isnull(A.DPD_Overdrawn,0) AND isnull(A.DPD_IntService,0)>=isnull(A.DPD_Overdue,0) AND isnull(A.DPD_IntService,0)>=isnull(A.DPD_Renewal,0) AND isnull(A.DPD_IntService,0)>=isnull(A.DPD_StockStmt,0)) 
                  THEN isnull(RefPeriodIntService,0)
				
				WHEN (isnull(A.DPD_NoCredit,0)>=isnull(A.DPD_IntService,0) AND isnull(A.DPD_NoCredit,0)>=isnull(A.DPD_Overdrawn,0) AND isnull(A.DPD_NoCredit,0)>=isnull(A.DPD_Overdue,0) AND isnull(A.DPD_NoCredit,0)>=isnull(A.DPD_Renewal,0) AND isnull(A.DPD_NoCredit,0)>=isnull(A.DPD_StockStmt,0)) 
				   THEN isnull(RefPeriodNoCredit,0)
				
				WHEN (isnull(A.DPD_Overdrawn,0)>=isnull(A.DPD_NoCredit,0)  AND isnull(A.DPD_Overdrawn,0)>= isnull(A.DPD_IntService,0) AND  isnull(A.DPD_Overdrawn,0)>=isnull(A.DPD_Overdue,0) AND isnull(A.DPD_Overdrawn,0)>=isnull(A.DPD_Renewal,0) AND isnull(A.DPD_Overdrawn,0)>=isnull(A.DPD_StockStmt,0))
				   THEN isnull(RefPeriodOverDrawn,0)
				
				WHEN (isnull(A.DPD_Renewal,0)>=isnull(A.DPD_NoCredit ,0) AND isnull(A.DPD_Renewal,0)>= isnull(A.DPD_IntService ,0) AND  isnull(A.DPD_Renewal,0)>=isnull(A.DPD_Overdrawn,0)  AND   isnull(A.DPD_Renewal,0)>=isnull(A.DPD_Overdue,0)  AND isnull(A.DPD_Renewal,0) >=isnull(A.DPD_StockStmt ,0)) 
				   THEN isnull(RefPeriodReview,0)
				
				WHEN (isnull(A.DPD_Overdue,0)>=isnull(A.DPD_NoCredit ,0) AND isnull(A.DPD_Overdue,0)>= isnull(A.DPD_IntService ,0) AND  isnull(A.DPD_Overdue,0)>=isnull(A.DPD_Overdrawn,0)  AND   isnull(A.DPD_Overdue,0)>=isnull(A.DPD_Renewal,0)  AND isnull(A.DPD_Overdue,0) >=isnull(A.DPD_StockStmt,0) )
			        THEN isnull(RefPeriodOverdue,0)
				
				ELSE isnull(RefPeriodStkStatement,0)
				
				END AS REFPERIOD

INTO #TEMPTABLE2    FROM #TEMPTABLE A 	 INNER JOIN  PRO.ACCOUNTCAL B   ON A.CustomerAcID=B.CustomerAcID  
--INNER JOIN PRO.CUSTOMERCAL C ON C.RefCustomerID=B.RefCustomerID
INNER JOIN PRO.CUSTOMERCAL C ON C.SourceSystemCustomerID=B.SourceSystemCustomerID
WHERE (isnull(C.FLGPROCESSING,'N')='N') 


/*------- INTIAL REFPERIODMAX 0 FOR RE-PROCESSING----- */

UPDATE  B SET  B.REFPERIODMAX=0
FROM #TEMPTABLE2 A INNER JOIN PRO.ACCOUNTCAL B ON A.CustomerAcID=B.CustomerAcID
--INNER JOIN PRO.CUSTOMERCAL C ON C.RefCustomerID=B.RefCustomerID
INNER JOIN PRO.CUSTOMERCAL C ON C.SourceSystemCustomerID=B.SourceSystemCustomerID
WHERE (isnull(C.FLGPROCESSING,'N')='N') 



/*----CALCULATE REFPERIODMAX  REGARDING MAX DPD--------------*/

UPDATE  B SET  B.REFPERIODMAX=A.REFPERIOD
FROM #TEMPTABLE2 A INNER JOIN PRO.ACCOUNTCAL B ON A.CustomerAcID=B.CustomerAcID
--INNER JOIN PRO.CUSTOMERCAL C ON C.RefCustomerID=B.RefCustomerID
INNER JOIN PRO.CUSTOMERCAL C ON C.SourceSystemCustomerID=B.SourceSystemCustomerID
WHERE (isnull(C.FLGPROCESSING,'N')='N') 
--AND B.Balance>0
/*---FOR HANDING NULL REFERENCE PERIOD ----------------------*/

UPDATE A SET A.REFPeriodMax=isnull(A.RefPeriodOverdue,0) 
 FROM PRO.AccountCal A 
WHERE isnull(FlgDeg,'N')='Y' AND ISNULL(InitialAssetClassAlt_Key,1)=1 AND Balance>0   AND ISNULL(REFPeriodMax,0)=0 
AND ISNULL(DPD_Max,0)<ISNULL(RefPeriodOverdue,0) AND FacilityType IN('TL','DL','BP','BD','PC')

UPDATE A SET A.REFPeriodMax=isnull(A.RefPeriodIntService,0)
 FROM PRO.AccountCal A 
WHERE isnull(FlgDeg,'N')='Y' AND ISNULL(InitialAssetClassAlt_Key,1)=1 AND Balance>0 
AND ISNULL(DPD_Max,0)<ISNULL(RefPeriodIntService,0) AND FacilityType IN('CC','OD') AND  ISNULL(REFPeriodMax,0)=0 


UPDATE PRO.ACLRUNNINGPROCESSSTATUS 
	SET COMPLETED='Y',ERRORDATE=NULL,ERRORDESCRIPTION=NULL,COUNT=ISNULL(COUNT,0)+1
	WHERE RUNNINGPROCESSNAME='MaxDPD_ReferencePeriod_Calculation'


	 DROP TABLE #TEMPTABLE
	 DROP TABLE #TEMPTABLE2


END TRY
BEGIN  CATCH

	UPDATE PRO.ACLRUNNINGPROCESSSTATUS 
	SET COMPLETED='N',ERRORDATE=GETDATE(),ERRORDESCRIPTION=ERROR_MESSAGE(),COUNT=ISNULL(COUNT,0)+1
	WHERE RUNNINGPROCESSNAME='MaxDPD_ReferencePeriod_Calculation'
END CATCH

 SET NOCOUNT OFF;

END








GO