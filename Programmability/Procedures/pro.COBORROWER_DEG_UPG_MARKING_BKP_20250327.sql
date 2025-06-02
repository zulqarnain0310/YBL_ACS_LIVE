SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



--/*=========================================
-- AUTHER : AMAR YADAV
-- CREATE DATE : 23-10-2023
-- MODIFY DATE : 
-- DESCRIPTION :MARKING COBORROWER AS NPA
-- =============================================*/



 

CREATE PROCEDURE [pro].[COBORROWER_DEG_UPG_MARKING_BKP_20250327]--26886,'U'
	@TimeKey INT=49999,
	@FLG_UPG_DEG CHAR(1)='U' --------D -- FOR NPA MARKING, u FOR UPGRADE
	WITH RECOMPILE
	AS



BEGIN
DECLARE @PROCESSDATE DATE =(SELECT DATE FROM SysDayMatrix WHERE TimeKey=@TimeKey)
 
IF @FLG_UPG_DEG='D'
	BEGIN
	 


	/* PREPARING CO-BORROWER DATA FOR MARKING UPGRADE */---insert MainBorrower and CoBorrower data into temp table
		IF OBJECT_ID('TEMPDB..#CUST_SELF_NPA') IS NOT NULL
			DROP TABLE #CUST_SELF_NPA
			SELECT B.RefCustomerID,a.SourceSystemCustomerID, a.CO_APPLICANT_UCIC as UCIF_ID,PANNO
				INTO #CUST_SELF_NPA
			FROM pro.CoBorrowerDetails  A   
				INNER JOIN PRO.ACCOUNTCAL B 
				ON A.CoBorrowerID =B.RefCustomerID
				WHERE (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
					AND  ISNULL(FinalAssetClassAlt_Key,1)<>1
					AND	(ISNULL(B.DPD_INTSERVICE,0)>=B.REFPERIODINTSERVICE
							OR ISNULL(B.DPD_OVERDRAWN,0)>=B.REFPERIODOVERDRAWN  
							OR ISNULL(B.DPD_NOCREDIT,0)>=B.REFPERIODNOCREDIT
							OR ISNULL(B.DPD_OVERDUE,0) >=B.REFPERIODOVERDUE 
							OR ISNULL(B.DPD_STOCKSTMT,0)>=B.REFPERIODSTKSTATEMENT
							OR ISNULL(B.DPD_RENEWAL,0)>=B.REFPERIODREVIEW 
							OR ISNULL(ASSET_NORM,'NORMAL')='ALWYS_NPA'  -- ADDED BY AMAR ON 16052024 - FOR ADD ALWAYS NPA ACCOUNT IN DEG CONDITION
							OR ISNULL(B.DPD_OTS,0)>0 -- ADDED BY ZAIN ON 20250228 - FOR ADD OTS ACCOUNT IN DEG CONDITION
						)
					AND ISNULL(ASSET_NORM,'NORMAL')<>'ALWYS_STD'  -- ADDED BY AMAR ON 16052024 - FOR EXCLUDE ALWAYS STD ACCOUNT DOE DEGRDAE
									GROUP BY B.RefCustomerID,a.SourceSystemCustomerID, a.CO_APPLICANT_UCIC,PANNO
/* ADDED BY ZAIN ON 20250228 - FOR ADD OTS ACCOUNT IN UPG CONDITION*/
	;WITH CTE_OTS AS(
				SELECT APPLICANT_UCIC FROM PRO.COBORROWERDETAILS A 
						WHERE APPLICANT_UCIC NOT IN (SELECT RefCustomerID FROM #CUST_SELF_NPA B) 
								AND FlgDeg='Y' AND DegDate IS NOT NULL
				)UPDATE A SET A.FlgDeg=NULL,A.DegDate=NULL,A.UpgDate=@PROCESSDATE,A.FlgUpg='Y'
				FROM PRO.COBORROWERDETAILS A INNER JOIN CTE_OTS B ON A.APPLICANT_UCIC=B.APPLICANT_UCIC
/* ADDED BY ZAIN ON 20250228 - FOR ADD OTS ACCOUNT IN UPG CONDITION*/

	/*07022024 - REPEADTED ABOVE CODE FOR FINDING THE SELF CUSTOMER NAP AT UCUC LEVEL*/	
			insert into #CUST_SELF_NPA 
 			SELECT B.RefCustomerID,a.SourceSystemCustomerID, a.CO_APPLICANT_UCIC as UCIF_ID,PANNO
			FROM pro.CoBorrowerDetails    A   
			INNER JOIN  pro.accountcal  B 
		ON A.CO_APPLICANT_UCIC =B.UCIF_ID
		WHERE (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
		AND  ISNULL(FinalAssetClassAlt_Key,1)<>1
		AND	(ISNULL(B.DPD_INTSERVICE,0)>=B.REFPERIODINTSERVICE
				OR ISNULL(B.DPD_OVERDRAWN,0)>=B.REFPERIODOVERDRAWN  
				OR ISNULL(B.DPD_NOCREDIT,0)>=B.REFPERIODNOCREDIT
				OR ISNULL(B.DPD_OVERDUE,0) >=B.REFPERIODOVERDUE 
				OR ISNULL(B.DPD_STOCKSTMT,0)>=B.REFPERIODSTKSTATEMENT
				OR ISNULL(B.DPD_RENEWAL,0)>=B.REFPERIODREVIEW 
				OR ISNULL(ASSET_NORM,'NORMAL')='ALWYS_NPA'  -- ADDED BY AMAR ON 16052024 - FOR ADD ALWAYS NPA ACCOUNT IN DEG CONDITION
			)
			AND ISNULL(ASSET_NORM,'NORMAL')<>'ALWYS_STD'  --- -- ADDED BY AMAR ON 16052024 - FOR EXCLUDE ALWAYS STD ACCOUNT DOE DEGRDAE
		and ISNULL(b.UCIF_ID,'') not in  (select ISNULL(UCIF_ID,'') from #CUST_SELF_NPA)
	GROUP BY B.RefCustomerID,a.SourceSystemCustomerID, a.CO_APPLICANT_UCIC,PANNO


	/*07022024 - FINDING PRIMARY BORRROWER - ALRE BREACHED NPA CRITERIA TO UPGRADE DEGDATE AND DEGFLG*/	
	insert into #CUST_SELF_NPA 
 			SELECT B.RefCustomerID,a.SourceSystemCustomerID, a.UCIF_ID,PANNO
			FROM pro.CoBorrowerDetails    A   
			INNER JOIN  pro.accountcal  B 
		ON A.APPLICANT_UCIC =B.UCIF_ID
		WHERE (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
		AND  ISNULL(FinalAssetClassAlt_Key,1)<>1
		AND	(ISNULL(B.DPD_INTSERVICE,0)>=B.REFPERIODINTSERVICE
				OR ISNULL(B.DPD_OVERDRAWN,0)>=B.REFPERIODOVERDRAWN  
				OR ISNULL(B.DPD_NOCREDIT,0)>=B.REFPERIODNOCREDIT
				OR ISNULL(B.DPD_OVERDUE,0) >=B.REFPERIODOVERDUE 
				OR ISNULL(B.DPD_STOCKSTMT,0)>=B.REFPERIODSTKSTATEMENT
				OR ISNULL(B.DPD_RENEWAL,0)>=B.REFPERIODREVIEW 
				OR ISNULL(ASSET_NORM,'NORMAL')='ALWYS_NPA'  -- ADDED BY AMAR ON 16052024 - FOR ADD ALWAYS NPA ACCOUNT IN DEG CONDITION
			)
			AND ISNULL(ASSET_NORM,'NORMAL')<>'ALWYS_STD'  --- -- ADDED BY AMAR ON 16052024 - FOR EXCLUDE ALWAYS STD ACCOUNT DOE DEGRDAE		and ISNULL(b.UCIF_ID,'') not in  (select ISNULL(UCIF_ID,'') from #CUST_SELF_NPA)
	GROUP BY B.RefCustomerID,a.SourceSystemCustomerID, a.UCIF_ID,PANNO



			

			/*UPDATE DEG DATE AND FLAG FOR THE CUSTOMERS UNDER NPA CRITERIA*/
				UPDATE A
					 SET     A.DegDate=@PROCESSDATE
						,A.FlgDeg='Y'
						,FlgUpg='N'
						,UpgDate =null
                         			,A.Co_Assetclassalt_key=2
						,A.Co_NPADate=@PROCESSDATE
				FROM Pro.CoBorrowerDetails A 
					INNER JOIN #CUST_SELF_NPA B
						ON A.RefCustomerID=B.RefCustomerID
						AND (A.EffectiveFromTimeKey<=@TimeKey and a.EffectiveToTimeKey>=@TimeKey)
					INNER JOIN pro.CustomerCal c
						on a.RefCustomerID=c.RefCustomerID
						and isnull(c.TotOsCust,0)>0
					WHERE isnull(A.FlgDeg,'N')='N'
			/*DEG COBORROWER WHERE COBORROWER AND PRIMARY BORROWER HAVE A VICE VERSA RELATION BY ZAIN 0N 20241226*/
			
		IF OBJECT_ID('TEMPDB..#COBO_VICEVERSA_RELATION1') IS NOT NULL
			DROP TABLE #COBO_VICEVERSA_RELATION1
			
			SELECT DISTINCT CO_APPLICANT_UCIC,APPLICANT_UCIC 
				INTO #COBO_VICEVERSA_RELATION1 
			FROM #CUST_SELF_NPA A INNER JOIN PRO.CoBorrowerDetails B 
			ON A.UCIF_ID=B.APPLICANT_UCIC
			WHERE B.EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY

		IF OBJECT_ID('TEMPDB..#COBO_VICEVERSA_RELATION') IS NOT NULL
			DROP TABLE #COBO_VICEVERSA_RELATION
			
			SELECT DISTINCT B.APPLICANT_UCIC INTO #COBO_VICEVERSA_RELATION FROM #COBO_VICEVERSA_RELATION1 A
			INNER JOIN PRO.CoBorrowerDetails B  
			ON A.CO_APPLICANT_UCIC=B.APPLICANT_UCIC
				AND A.APPLICANT_UCIC=B.CO_APPLICANT_UCIC
				WHERE B.EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
				AND isnull(B.FlgDeg,'N')='N' 


				UPDATE A
					 SET     A.DegDate=@PROCESSDATE--'2024-11-18'
						,A.FlgDeg='Y'
						,FlgUpg='N'
						,UpgDate =null
                         			,A.Co_Assetclassalt_key=2
						,A.Co_NPADate=@PROCESSDATE--'2024-11-18'
				FROM PRO.CoBorrowerDetails A INNER JOIN #COBO_VICEVERSA_RELATION B
				ON A.APPLICANT_UCIC=B.APPLICANT_UCIC
					WHERE isnull(A.FlgDeg,'N')='N'
					AND A.EffectiveFromTimeKey<=@TIMEKEY AND A.EffectiveToTimeKey>=@TIMEKEY

				/*DEG COBORROWER WHERE COBORROWER AND PRIMARY BORROWER HAVE A VICE VERSA RELATION BY ZAIN 0N 20241226 END*/

				/*UPDATE DEG DATE AND FLAG FOR THE SOURCESYSTEMCUSTOMERID UNDER NPA CRITERIA*/
				UPDATE A
					 SET A.DegDate=@PROCESSDATE
						,A.FlgDeg='Y'
						,FlgUpg='N'
						,UpgDate =null
                        			,A.Co_Assetclassalt_key=2
						,A.Co_NPADate=@PROCESSDATE
				FROM Pro.CoBorrowerDetails A 
					INNER JOIN #CUST_SELF_NPA B
						ON A.RefCustomerID=B.RefCustomerID
						AND (A.EffectiveFromTimeKey<=@TimeKey and a.EffectiveToTimeKey>=@TimeKey)
					INNER JOIN pro.CustomerCal c
						on A.SourceSystemCustomerID=C.SourceSystemCustomerID
						and isnull(c.TotOsCust,0)>0
					WHERE isnull(A.FlgDeg,'N')='N' and a.SourceSystemCustomerID is not null

				/*UPDATE DEG DATE AND FLAG FOR THE UCIF ID UNDER NPA CRITERIA*/
				UPDATE A
					 SET    A.DegDate=@PROCESSDATE
						,A.FlgDeg='Y'
						,FlgUpg='N'
						,UpgDate =null
                        			,A.Co_Assetclassalt_key=2
						,A.Co_NPADate=@PROCESSDATE
				FROM Pro.CoBorrowerDetails A 
					INNER JOIN #CUST_SELF_NPA B
						ON A.RefCustomerID=B.RefCustomerID
						AND (A.EffectiveFromTimeKey<=@TimeKey and a.EffectiveToTimeKey>=@TimeKey)
					INNER JOIN pro.CustomerCal c
						ON A.UCIF_ID=C.UCIF_ID
						--AND isnull(c.TotOsCust,0)>0
					WHERE ISNULL(A.FlgDeg,'N')='N' AND A.UCIF_ID IS NOT NULL

	
				/*UPDATE DEG DATE AND FLAG FOR THE PANNO UNDER NPA CRITERIA*/
				UPDATE A
					 SET    A.DegDate=@PROCESSDATE
						,A.FlgDeg='Y'
						,FlgUpg='N'
						,UpgDate =null
                        			,A.Co_Assetclassalt_key=2
						,A.Co_NPADate=@PROCESSDATE   
				FROM Pro.CoBorrowerDetails A 
					INNER JOIN #CUST_SELF_NPA B
						ON A.RefCustomerID=B.RefCustomerID
						AND (A.EffectiveFromTimeKey<=@TimeKey and a.EffectiveToTimeKey>=@TimeKey)
					INNER JOIN pro.CustomerCal c
						ON A.PANNO=C.PANNO
						AND isnull(c.TotOsCust,0)>0
					WHERE ISNULL(A.FlgDeg,'N')='N' AND A.PANNO IS NOT NULL


				/*AMAR -04122023 CALCULATE DEGRADE DATE - SAme AS NPA DATE CALCULATION LOGIC */
					IF OBJECT_ID('TEMPDB..#TEMPTABLEDPD_COBO') IS NOT NULL
							DROP TABLE #TEMPTABLEDPD_COBO

						 SELECT A.CustomerAcID
								,CASE WHEN  isnull(A.DPD_IntService,0)>=isnull(A.RefPeriodIntService,0)		THEN A.DPD_IntService  ELSE 0   END DPD_IntService,  
								 CASE WHEN  isnull(A.DPD_NoCredit,0)>=isnull(A.RefPeriodNoCredit,0)			THEN A.DPD_NoCredit    ELSE 0   END DPD_NoCredit,  
								 CASE WHEN  isnull(A.DPD_Overdrawn,0)>=isnull(A.RefPeriodOverDrawn	,0)	    THEN A.DPD_Overdrawn   ELSE 0   END DPD_Overdrawn,  
								 CASE WHEN  isnull(A.DPD_Overdue,0)>=isnull(A.RefPeriodOverdue	,0)		    THEN A.DPD_Overdue     ELSE 0   END DPD_Overdue , 
								 CASE WHEN  isnull(A.DPD_Renewal,0)>=isnull(A.RefPeriodReview	,0)			THEN A.DPD_Renewal     ELSE 0   END  DPD_Renewal ,
								 CASE WHEN  isnull(A.DPD_StockStmt,0)>=isnull(A.RefPeriodStkStatement,0)       THEN A.DPD_StockStmt   ELSE 0   END DPD_StockStmt  
								 INTO #TEMPTABLEDPD_COBO
								  FROM PRO.ACCOUNTCAL A 
									INNER JOIN Pro.CoBorrowerDetails B
										ON (B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey)
										AND A.CustomerAcID=B.AGREEMENTNO
									INNER JOIN Pro.CoBorrowerDetails c --filtered only co-borrower data
										ON (c.EffectiveFromTimeKey<=@TimeKey AND c.EffectiveToTimeKey>=@TimeKey)
										AND c.RefCustomerID=B.CoBorrowerID

										
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

						SELECT A.CustomerAcID ,CASE  WHEN (isnull(A.DPD_IntService,0)>=isnull(A.DPD_NoCredit,0) AND isnull(A.DPD_IntService,0)>=isnull(A.DPD_Overdrawn,0) AND isnull(A.DPD_IntService,0)>=isnull(A.DPD_Overdue,0) AND isnull(A.DPD_IntService,0)>=isnull(A.DPD_Renewal,0) AND isnull(A.DPD_IntService,0)>=isnull(A.DPD_StockStmt,0)) 
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

						INTO #TEMPTABLENPA    FROM #TEMPTABLEDPD_COBO A 	 INNER JOIN  PRO.ACCOUNTCAL B   ON A.CustomerAcID=B.CustomerAcID  

						UPDATE  A  SET DegDate= DATEADD(DAY,ISNULL(REFPERIODNPA,0),DATEADD(DAY,-ISNULL(REFPERIODNPA,0),@ProcessDate))
						FROM PRO.CoBorrowerDetails A INNER JOIN #TEMPTABLENPA B ON A.AGREEMENTNO=B.CustomerAcID and
						 (A.EffectiveFromTimeKey<=@TimeKey and A.EffectiveToTimeKey>=@TimeKey)
						WHERE  ISNULL(A.FLGDEG,'N')='Y' AND DEGDATE IS NULL

						UPDATE   A SET  A.DegDate=@ProcessDate  
						FROM PRO.CoBorrowerDetails A 
						WHERE ISNULL(a.FLGDEG,'N')='Y'  
						AND DEGDATE IS NULL 
						and (A.EffectiveFromTimeKey<=@TimeKey and A.EffectiveToTimeKey>=@TimeKey)


		/* 07022024 -  UPADTING DEG FLAG AND OTHER COLUMNS IN COBORROWER DETAIL TABLE  IF ACCOUNT DEGRADE MARKED FRESH IN ACCOUNTCAL */						
		UPDATE B SET 
		 B.FlgDeg =A.FlgDeg 
		,B.DegDate=A.FinalNpaDt
		,B.FlgUpg =A.FlgUpg 
		,B.UpgDate=A.UpgDate
		,B.Pri_Assetclassalt_key = A.FinalAssetClassAlt_Key
		,B.Pri_NPADate			 = A.FinalNpaDt
		,B.Co_Assetclassalt_key	 = A.FinalAssetClassAlt_Key
		,B.Co_NPADate			 = A.FinalNpaDt
		FROM PRO.accountcal  a
		INNER JOIN PRO.CoBorrowerDetails  b 
		ON B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
		AND A.flgdeg='Y' AND A.CustomerAcID=B.AGREEMENTNO 


		UPDATE B SET 
		 B.FlgDeg ='Y' 
		,B.DegDate=A.FinalNpaDt
		,B.FlgUpg =A.FlgUpg 
		,B.UpgDate=A.UpgDate
		,B.Pri_Assetclassalt_key = A.FinalAssetClassAlt_Key
		,B.Pri_NPADate			 = A.FinalNpaDt
		,B.Co_Assetclassalt_key	 = A.FinalAssetClassAlt_Key
		,B.Co_NPADate			 = A.FinalNpaDt
	   FROM PRO.accountcal  a
		INNER JOIN PRO.CoBorrowerDetails  b 
		ON  A.BankAssetClass='WRITEOFF' AND A.CustomerAcID=B.AGREEMENTNO 
		where isnull(b.FlgDeg ,'N')='N'

		/* AMAR - 16052024 -- update flgdeg and degdate for MOC customer marked as NPA*/
UPDATE A
	SET A.FlgDeg='Y'
		,A.DegDate= B.SysNPA_Dt	
		,A.FlgUpg=NULL	--ADDED BY ZAIN TO PASS NULL WHERE CUSTOMER IS MARKED AS DEGRADED IN MOC ON 20241225
		,A.UpgDate=NULL	--ADDED BY ZAIN TO PASS NULL WHERE CUSTOMER IS MARKED AS DEGRADED IN MOC ON 20241225
FROM PRO.CoBorrowerDetails A
INNER JOIN PRO.customercal B
ON A.APPLICANT_FCR_CUST_ID=B.RefCustomerID
AND B.SysAssetClassAlt_Key>1 AND 
(B.FlgMoc='Y' or b.Asset_Norm='Alwys_NPA')

UPDATE A SET A.FlgDeg='Y'
		,A.DegDate= B.FinalNpaDt
		,A.FlgUpg=NULL	--ADDED BY ZAIN TO PASS NULL WHERE CUSTOMER IS MARKED AS DEGRADED IN MOC ON 20241225
		,A.UpgDate=NULL	--ADDED BY ZAIN TO PASS NULL WHERE CUSTOMER IS MARKED AS DEGRADED IN MOC ON 20241225
FROM PRO.CoBorrowerDetails A
INNER JOIN PRO.AccountCal B
ON A.AGREEMENTNO = B.CustomerAcID
AND B.FinalAssetClassAlt_Key>1 and 
(B.Asset_Norm='Alwys_NPA' or B.FlgMoc='Y' )





		/* 07022024 -  UPDATING PRIMARY NPA DATE AND ASSETCLASS FROM CO-BORROWER FOR FLGDEG =Y */						
		update pro.CoBorrowerDetails set Pri_NPADate=Co_NPADate,Pri_Assetclassalt_key=Co_Assetclassalt_key
		where  FlgDeg='y' and Pri_Assetclassalt_key is null  and EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey  --New Condition Added Amar 01 Feb 2024


/* FIND PRIMARY BORROWER'S CUSTOMERID,PANNO AND UCIFID */
			IF OBJECT_ID('TEMPDB..#CO_MARK_TO_BO_NPA') IS NOT NULL
				DROP TABLE #CO_MARK_TO_BO_NPA
				 
			SELECT B.REFCUSTOMERID, A.PANNO,A.UCIF_ID
				INTO #CO_MARK_TO_BO_NPA
			FROM Pro.CustomerCal A 
				INNER JOIN Pro.CoBorrowerDetails b
				on (B.EffectiveFromTimeKey<=@TimeKey and b.EffectiveToTimeKey>=@TimeKey)
				AND B.REFCUSTOMERID=A.RefCustomerID

			/* MARKING CO-BORROWER AS NPA - WPRIMARY BORROWER DEGDATE WILL BE NPA DATE FOR COBORROWER AND ASSET CLASS WILL BE SUB */
			




			
			
			UPDATE A SET A.SysAssetClassAlt_Key=b.Pri_Assetclassalt_key
				,A.SysNPA_Dt=B.DegDate
				
				,DegReason='Percolation by Finnone Primary Borrower PAN_' + Isnull(C.PANNO,'') + '/FCR Cust ID '+ isnull(C.RefCustomerID,'') + '/UCIC '+ isnull(C.UCIF_ID,'')
			FROM Pro.CustomerCal A 
			INNER JOIN Pro.CoBorrowerDetails b
				on (B.EffectiveFromTimeKey<=@TimeKey and b.EffectiveToTimeKey>=@TimeKey)
				AND B.CoBorrowerID=A.RefCustomerID
				--AND ISNULL(A.TotOsCust,0)>0
				AND A.ASSET_NORM<>'ALWYS_STD'
			INNER JOIN #CO_MARK_TO_BO_NPA C
				ON C.REFCUSTOMERID=B.REFCUSTOMERID
			WHERE A.SysAssetClassAlt_Key=1
				AND B.DegDate IS NOT NULL

				


				UPDATE A SET A.SysAssetClassAlt_Key=b.Pri_Assetclassalt_key
				,A.SysNPA_Dt=B.DegDate
				
				,DegReason='Percolation by Finnone Primary Borrower PAN_' + Isnull(C.PANNO,'') + '/FCR Cust ID '+ isnull(C.RefCustomerID,'') + '/UCIC '+ isnull(C.UCIF_ID,'')
			FROM Pro.CustomerCal A 
			INNER JOIN Pro.CoBorrowerDetails b
				on (B.EffectiveFromTimeKey<=@TimeKey and b.EffectiveToTimeKey>=@TimeKey)
				AND B.CO_APPLICANT_UCIC=A.UCIF_ID
				--AND ISNULL(A.TotOsCust,0)>0
				AND A.ASSET_NORM<>'ALWYS_STD'
			INNER JOIN #CO_MARK_TO_BO_NPA C
				ON C.REFCUSTOMERID=B.REFCUSTOMERID
			WHERE A.SysAssetClassAlt_Key=1
				AND B.DegDate IS NOT NULL

			UPDATE A SET 
				A.FinalAssetClassAlt_Key=b.Pri_Assetclassalt_key
				,A.FinalNpaDt=B.DegDate	
				,A.NPA_Reason='PERCOLATION DUE TO PRIMARY BORROWER NPA_'+ B.RefCustomerID + '_'+ A.UCIF_ID 
				,DegReason='Percolation by Finnone Primary Borrower PAN_' + Isnull(B.PANNO,'') + '/FCR Cust ID '+ isnull(C.RefCustomerID,'') + '/UCIC '+ isnull(C.UCIF_ID,'')
			FROM Pro.accountcal A 
			INNER JOIN Pro.CoBorrowerDetails b
				on (B.EffectiveFromTimeKey<=@TimeKey and b.EffectiveToTimeKey>=@TimeKey)
				AND B.CoBorrowerID=A.RefCustomerID
				--AND ISNULL(A.Balance,0)>0
				AND A.ASSET_NORM<>'ALWYS_STD'
			INNER JOIN #CO_MARK_TO_BO_NPA C
				ON C.REFCUSTOMERID=B.REFCUSTOMERID
				
			WHERE A.FinalAssetClassAlt_Key=1
				AND B.DegDate IS NOT NULL		

	UPDATE A SET 
				A.FinalAssetClassAlt_Key=b.Pri_Assetclassalt_key
				,A.FinalNpaDt=B.DegDate	
				,A.NPA_Reason='PERCOLATION DUE TO PRIMARY BORROWER NPA_'+ B.RefCustomerID + '_'+ A.UCIF_ID 
				,DegReason='Percolation by Finnone Primary Borrower PAN_' + Isnull(B.PANNO,'') + '/FCR Cust ID '+ isnull(C.RefCustomerID,'') + '/UCIC '+ isnull(C.UCIF_ID,'')
			FROM Pro.accountcal A 
			INNER JOIN Pro.CoBorrowerDetails b
				on (B.EffectiveFromTimeKey<=@TimeKey and b.EffectiveToTimeKey>=@TimeKey)
				AND B.CO_APPLICANT_UCIC=A.UCIF_ID
				--AND ISNULL(A.Balance,0)>0
				AND A.ASSET_NORM<>'ALWYS_STD'
			INNER JOIN #CO_MARK_TO_BO_NPA C
				ON C.REFCUSTOMERID=B.REFCUSTOMERID
				
			WHERE A.FinalAssetClassAlt_Key=1
				AND B.DegDate IS NOT NULL	
		
				
				
			IF OBJECT_ID('TEMPDB..##TempWriteOffReason') IS NOT NULL
		DROP TABLE ##TempWriteOffReason

		select distinct RefCustomerID, UCIF_ID
		into ##TempWriteOffReason
		from Pro.accountcal
		where DegReason like '%write%'

		update a set DegReason=a.DegReason  + '  ' + ' & W/O '
		  FROM Pro.accountcal A INNER   JOIN Pro.CoBorrowerDetails B 
			ON  A.RefCustomerID=B.CoBorrowerID  and (B.EffectiveFromTimeKey<=@TimeKey and b.EffectiveToTimeKey>=@TimeKey)
			INNER JOIN Pro.CustomerCal C ON C.SourceSystemCustomerID=A.SourceSystemCustomerId
			inner join ##TempWriteOffReason d on d.RefCustomerID=b.RefCustomerID
		 where a.DegReason like '%PRIMARY BORROWER%'

		 --select * from Pro.CoBorrowerDetails

		 update a set DegReason=a.DegReason  + '  ' + ' & W/O '
				  FROM Pro.accountcal A INNER   JOIN Pro.CoBorrowerDetails B 
			ON  A.RefCustomerID=B.CoBorrowerID  and (B.EffectiveFromTimeKey<=@TimeKey and b.EffectiveToTimeKey>=@TimeKey)
			INNER JOIN Pro.CustomerCal C ON C.SourceSystemCustomerID=A.SourceSystemCustomerId
			inner join ##TempWriteOffReason d on d.UCIF_ID =b.applicant_UCIC
		where a.DegReason like '%PRIMARY BORROWER%' and  a.DegReason not like '%W/O%'


		update c set DegReason=c.DegReason  + '  ' + ' & W/O '
		  FROM Pro.accountcal A INNER   JOIN Pro.CoBorrowerDetails B 
			ON  A.RefCustomerID=B.CoBorrowerID  and (B.EffectiveFromTimeKey<=@TimeKey and b.EffectiveToTimeKey>=@TimeKey)
			INNER JOIN Pro.CustomerCal C ON C.SourceSystemCustomerID=A.SourceSystemCustomerId
			inner join ##TempWriteOffReason d on d.RefCustomerID=b.RefCustomerID
		where c.DegReason like '%PRIMARY BORROWERn%'

		update c set DegReason=c.DegReason  + '  ' + ' & W/O '
				  FROM Pro.accountcal A INNER   JOIN Pro.CoBorrowerDetails B 
			ON  A.RefCustomerID=B.CoBorrowerID  and (B.EffectiveFromTimeKey<=@TimeKey and b.EffectiveToTimeKey>=@TimeKey)
			INNER JOIN Pro.CustomerCal C ON C.SourceSystemCustomerID=A.SourceSystemCustomerId
			inner join ##TempWriteOffReason d on d.UCIF_ID =b.applicant_UCIC
		where c.DegReason like '%PRIMARY BORROWER%'and  c.DegReason not like '%W/O%' 


			/* FIND PRIMARY BORROWER'S CUSTOMERID,PANNO AND UCIFID */
			
			/* EXECUTING AGING PROCESS TO UPDATED ASSET CLASS AS PER NPA DATE*/
			DECLARE @SUB_Months INT =(SELECT RefValue FROM PRO.refperiod WHERE BusinessRule='SUB_Months' AND  EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
			DECLARE @DB1_Months INT =(SELECT RefValue FROM PRO.refperiod WHERE BusinessRule='DB1_Months' AND  EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
			DECLARE @DB2_Months INT =(SELECT RefValue FROM PRO.refperiod WHERE BusinessRule='DB2_Months' AND  EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)


			--UPDATE A SET A.SysAssetClassAlt_Key= (
			--										CASE  WHEN  DATEADD(MONTH,@SUB_Months,A.SysNPA_Dt)>@PROCESSDATE AND b.AssetClassShortName not in ('DB1','DB2','DB3')  THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='SUB' AND EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
			--										  WHEN  DATEADD(MONTH,@SUB_Months,A.SysNPA_Dt)<=@PROCESSDATE AND  DATEADD(MONTH,@DB1_Months+@SUB_Months,A.SysNPA_Dt)>@PROCESSDATE AND b.AssetClassShortName not in ('DB2','DB3') THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='DB1' AND EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
			--										  WHEN  DATEADD(MONTH,@DB1_Months,A.DbtDt)<=@PROCESSDATE AND  DATEADD(MONTH,@DB1_Months+@DB2_Months,A.DbtDt)>@PROCESSDATE AND b.AssetClassShortName not in ('DB3') THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='DB2' AND EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
			--										   WHEN  DATEADD(MONTH,@DB1_Months+@DB2_Months,A.DbtDt)<=@PROCESSDATE THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='DB3'AND EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
			--											ELSE A.SysAssetClassAlt_Key
			--									   END)
			--		  ,A.DBTDT= (CASE 
			--										   WHEN   DATEADD(MONTH,@SUB_Months,A.SysNPA_Dt)<=@PROCESSDATE AND  DATEADD(MONTH,@DB1_Months+@SUB_Months,A.SysNPA_Dt)>@PROCESSDATE  THEN DATEADD(MONTH,@SUB_Months,A.SysNPA_Dt)
			--										   WHEN  DATEADD(MONTH,@DB1_Months,A.DbtDt)<=@PROCESSDATE AND  DATEADD(MONTH,@DB1_Months+@DB2_Months,A.DbtDt)>@PROCESSDATE   THEN DATEADD(MONTH,@SUB_Months,A.SysNPA_Dt)
			--										   WHEN DATEADD(MONTH,@DB1_Months+@DB2_Months,A.DbtDt)<=@PROCESSDATE THEN DATEADD(MONTH,(@SUB_Months),A.SysNPA_Dt)
			--										   ELSE DBTDT 
			--									   END)

			--FROM PRO.CustomerCal A INNER JOIN DimAssetClass B  ON A.SysAssetClassAlt_Key =B.AssetClassAlt_Key AND  B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
			--WHERE B.AssetClassShortName NOT IN('STD','LOS') AND ISNULL(A.FlgDeg,'N')<>'Y'  AND (ISNULL(A.FlgProcessing,'N')='N') and DbtDt is not null

			----UPDATE YBL_ACS.PRO.CustomerCal  SET SysAssetClassAlt_Key=SrcAssetClassAlt_Key WHERE SysAssetClassAlt_Key IS NULL

			----Added after FinalAssetClassAlt_Key Null Issue  30/06/2022
			--UPDATE A SET A.SysAssetClassAlt_Key= (
			--										CASE  WHEN  DATEADD(MONTH,@SUB_Months,A.SysNPA_Dt)>@PROCESSDATE   THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='SUB' AND EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
			--										  WHEN  DATEADD(MONTH,@SUB_Months,A.SysNPA_Dt)<=@PROCESSDATE AND  DATEADD(MONTH,@SUB_Months+@DB1_Months,A.SysNPA_Dt)>@PROCESSDATE   THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='DB1' AND EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
			--										  WHEN  DATEADD(MONTH,@SUB_Months+@DB1_Months,A.SysNPA_Dt)<=@PROCESSDATE AND  DATEADD(MONTH,@SUB_Months+@DB1_Months+@DB2_Months,A.SysNPA_Dt)>@PROCESSDATE THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='DB2' AND EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
			--										   WHEN  DATEADD(MONTH,(@DB1_Months+@SUB_Months+@DB2_Months),A.SysNPA_Dt)<=@PROCESSDATE  THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='DB3' AND EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
			--									   END)
			--		  ,A.DBTDT= (CASE 
			--										   WHEN  DATEADD(MONTH,@SUB_Months,A.SysNPA_Dt)<=@PROCESSDATE AND  DATEADD(MONTH,@SUB_Months+@DB1_Months,A.SysNPA_Dt)>@PROCESSDATE  THEN DATEADD(MONTH,@SUB_Months,A.SysNPA_Dt)
			--										   WHEN  DATEADD(MONTH,@SUB_Months+@DB1_Months,A.SysNPA_Dt)<=@PROCESSDATE AND  DATEADD(MONTH,@SUB_Months+@DB1_Months+@DB2_Months,A.SysNPA_Dt)>@PROCESSDATE   THEN DATEADD(MONTH,@SUB_Months,A.SysNPA_Dt)
			--										   WHEN  DATEADD(MONTH,(@DB1_Months+@SUB_Months+@DB2_Months),A.SysNPA_Dt)<=@PROCESSDATE THEN DATEADD(MONTH,(@SUB_Months),A.SysNPA_Dt)
			--										   ELSE DBTDT 
			--									   END)

			--FROM PRO.CustomerCal A INNER JOIN DimAssetClass B  ON A.SysAssetClassAlt_Key =B.AssetClassAlt_Key AND  B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
			--WHERE B.AssetClassShortName NOT IN('STD','LOS') AND ISNULL(A.FlgDeg,'N')<>'Y'  AND (ISNULL(A.FlgProcessing,'N')='N') and DbtDt is null --AND (ISNULL(A.FlgErosion,'N')='Y') 
  

  --UPDATE A SET   A.DBTDT= (CASE 
		--											   WHEN  DATEADD(MONTH,@SUB_Months,A.SysNPA_Dt)<=@PROCESSDATE AND  DATEADD(MONTH,@SUB_Months+@DB1_Months,A.SysNPA_Dt)>@PROCESSDATE  THEN DATEADD(MONTH,@SUB_Months,A.SysNPA_Dt)
		--											   WHEN  DATEADD(MONTH,@SUB_Months+@DB1_Months,A.SysNPA_Dt)<=@PROCESSDATE AND  DATEADD(MONTH,@SUB_Months+@DB1_Months+@DB2_Months,A.SysNPA_Dt)>@PROCESSDATE   THEN DATEADD(MONTH,@SUB_Months,A.SysNPA_Dt)
		--											   WHEN  DATEADD(MONTH,(@DB1_Months+@SUB_Months+@DB2_Months),A.SysNPA_Dt)<=@PROCESSDATE THEN DATEADD(MONTH,(@SUB_Months),A.SysNPA_Dt)
		--											   ELSE DBTDT 
		--										   END)

		--	FROM PRO.CustomerCal A INNER JOIN DimAssetClass B  ON A.SysAssetClassAlt_Key =B.AssetClassAlt_Key AND  B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
		--	WHERE B.AssetClassShortName NOT IN('STD','LOS') AND ISNULL(A.FlgDeg,'N')<>'Y'  AND (ISNULL(A.FlgProcessing,'N')='N') and DbtDt is null 
		--				and A.SysAssetClassAlt_Key in(3,4,5)

			/* PERCOLATION AT SIOURCESYSTEMCUSTOERID LEVEL*/
			IF OBJECT_ID('TEMPDB..#TempAssetClassSourceSysCustID') IS NOT NULL
				DROP TABLE #TempAssetClassSourceSysCustID

				SELECT SourceSystemCustomerID
					,MAX(ISNULL(SYSASSETCLASSALT_KEY,1)) SYSASSETCLASSALT_KEY
					,MIN(SYSNPA_DT) SYSNPA_DT 
					,MIN(DbtDt) DbtDt
				INTO #TempAssetClassSourceSysCustID
				FROM(
						SELECT  A.SourceSystemCustomerID,ISNULL(A.SYSASSETCLASSALT_KEY,1) as SYSASSETCLASSALT_KEY
							,A.SYSNPA_DT as SYSNPA_DT 
							,A.DbtDt as DbtDt
						FROM PRO.CUSTOMERCAL A
							INNER JOIN Pro.CoBorrowerDetails B 
								ON B.CoBorrowerID=A.RefCustomerID
								AND (B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey)
							WHERE A.SourceSystemCustomerID IS NOT NULL and A.SourceSystemCustomerID<>'0' 
								AND ISNULL(A.TotOsCust,0)>0
								AND A.Asset_Norm<>'ALWYS_STD' 
								AND SYSASSETCLASSALT_KEY >1 ---amar 16052024 added NPA Condition
					) A
				GROUP BY A.SourceSystemCustomerID

			UPDATE A SET A.SysAssetClassAlt_Key=B.SYSASSETCLASSALT_KEY
				,A.SysNPA_Dt=B.SYSNPA_DT  
				,A.DbtDt=B.DbtDt
			 FROM PRO.CustomerCal A 
				INNER JOIN #TempAssetClassSourceSysCustID B 
					ON A.SourceSystemCustomerID=B.SourceSystemCustomerID
			WHERE A.Asset_Norm<>'ALWYS_STD' 

 
			/* PERCOLATION AT UCIC_ID LEVEL*/
	 		IF OBJECT_ID('TEMPDB..#TempAssetClassUCIF_ID') IS NOT NULL
			DROP TABLE #TempAssetClassUCIF_ID

			SELECT UCIF_ID
				,MAX(ISNULL(SYSASSETCLASSALT_KEY,1)) SYSASSETCLASSALT_KEY
				,MIN(SYSNPA_DT) SYSNPA_DT 
				,MIN(DbtDt) DbtDt
			INTO #TempAssetClassUCIF_ID
			FROM(
					SELECT  A.UCIF_ID,ISNULL(A.SYSASSETCLASSALT_KEY,1) as SYSASSETCLASSALT_KEY
						,A.SYSNPA_DT as SYSNPA_DT 
						,A.DbtDt as DbtDt
					FROM PRO.CUSTOMERCAL A
						INNER JOIN Pro.CoBorrowerDetails B 
							ON B.CoBorrowerID=A.RefCustomerID
							AND (B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey)
						WHERE A.UCIF_ID IS NOT NULL and A.UCIF_ID<>'0' 
							AND ISNULL(A.TotOsCust,0)>0
							AND A.Asset_Norm<>'ALWYS_STD'
							AND SYSASSETCLASSALT_KEY >1 ---amar 16052024 added NPA Condition
				) A
			GROUP BY A.UCIF_ID

			UPDATE A SET A.SysAssetClassAlt_Key=B.SYSASSETCLASSALT_KEY
				,A.SysNPA_Dt=B.SYSNPA_DT  
				,A.DbtDt=B.DbtDt
			 FROM PRO.CustomerCal A INNER JOIN #TempAssetClassUCIF_ID B ON A.UCIF_ID=B.UCIF_ID
			WHERE A.Asset_Norm<>'ALWYS_STD' 


			/* PERCOLATION AT PAN LEVEL*/
	 		IF OBJECT_ID('TEMPDB..#TempAssetClassPAN') IS NOT NULL
			DROP TABLE #TempAssetClassPAN

			SELECT PANNO
				,MAX(ISNULL(SYSASSETCLASSALT_KEY,1)) SYSASSETCLASSALT_KEY
				,MIN(SYSNPA_DT) SYSNPA_DT 
				,MIN(DbtDt) DbtDt
			INTO #TempAssetClassPAN
			FROM(
					SELECT  A.PANNO,ISNULL(A.SYSASSETCLASSALT_KEY,1) as SYSASSETCLASSALT_KEY
						,A.SYSNPA_DT as SYSNPA_DT 
						,A.DbtDt as DbtDt
					FROM PRO.CUSTOMERCAL A
						INNER JOIN Pro.CoBorrowerDetails B 
							ON B.CoBorrowerID=A.RefCustomerID
							AND (B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey)
						WHERE A.PANNO IS NOT NULL and A.PANNO<>'0' 
							AND ISNULL(A.TotOsCust,0)>0
							AND A.Asset_Norm<>'ALWYS_STD'
							AND SYSASSETCLASSALT_KEY >1 ---amar 16052024 added NPA Condition
				) A
			GROUP BY A.PANNO
		
			/* UPDATE SYSASSETCLASSALT_KEY AT CUSTSOMKJER LEVEL */
			UPDATE A SET A.SysAssetClassAlt_Key=B.SYSASSETCLASSALT_KEY
				,A.SysNPA_Dt=B.SYSNPA_DT  
				,A.DbtDt=B.DbtDt
			 FROM PRO.CustomerCal A INNER JOIN #TempAssetClassPAN B ON A.PANNO=B.PANNO
			WHERE A.Asset_Norm<>'ALWYS_STD' 

			/*UPDATE FINALASSETCLASS AT ACCOUNT LEVEL */
			UPDATE B SET b.FinalAssetClassAlt_Key=A.SYSASSETCLASSALT_KEY
				,b.FinalNpaDt=A.SYSNPA_DT  
				--,B.NPA_Reason=A.DegReason
			 FROM PRO.CustomerCal A INNER JOIN PRO.AccountCal B ON A.RefCustomerID=B.RefCustomerID
			WHERE b.Asset_Norm<>'ALWYS_STD' 
			AND SYSASSETCLASSALT_KEY >1 ---amar 16052024 added NPA Condition


		/* 0722024 -- PREPARING DATA AND UPDATEING COLUMN DEGDATE,PRI_ASSETcLASS AND pRInpa DATE TO KEEP DATA AS SYNCHRONISE AT UCIC LEVEL FOR CUSTOMER MARKED DEGD DATE*/
	
		IF OBJECT_ID('TEMPDB..#PrimaryDegData1') IS NOT NULL
		      DROP TABLE #PrimaryDegData1
		 select APPLICANT_UCIC,DegDate,Pri_Assetclassalt_key,Pri_NPADate,Co_Assetclassalt_key,Co_NPADate into #PrimaryDegData1
		  from PRo.CoBorrowerDetails where DegDate is not null 
		  --and EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey/*ADDED BY ZAIN ON 20250219 TO HANDLE COBOOROWER LOOP OBSERVATION END*/
		  group by APPLICANT_UCIC,DegDate,Pri_Assetclassalt_key,Pri_NPADate,Co_Assetclassalt_key,Co_NPADate

			/*ADDED BY ZAIN ON 20250219 TO HANDLE COBOOROWER LOOP OBSERVATION*/
				UPDATE A SET A.DEGDATE=B.DEGDATE
								,A.SysAssetClassAlt_Key=C.Co_Assetclassalt_key
								,A.FlgDeg='Y'
								,A.SysNPA_Dt=B.Co_NPADate
								--,A.DegReason='NPA DUE TO PRIMARY BORROWER '+C.CO_APPLICANT_UCIC
					FROM PRO.CUSTOMERCAL A 
						INNER JOIN #PrimaryDegData1 B ON A.RefCustomerID=B.APPLICANT_UCIC
						INNER JOIN PRO.CoBorrowerDetails C ON C.APPLICANT_UCIC=B.APPLICANT_UCIC
					WHERE A.FlgDeg<>'Y' AND A.SysNPA_Dt IS NULL
							AND A.FlgMoc<>'Y'
							AND A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey

				UPDATE A SET A.DegReason='NPA DUE TO PRIMARY BORROWER APPLICANT_FCR_CUST_ID '+C.CO_APPLICANT_UCIC
					 FROM PRO.CUSTOMERCAL A 
						INNER JOIN #PrimaryDegData1 B ON A.RefCustomerID=B.APPLICANT_UCIC
						INNER JOIN PRO.CoBorrowerDetails C ON C.APPLICANT_UCIC=B.APPLICANT_UCIC
					WHERE A.DegReason IS NULL 
						AND A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey


				UPDATE A SET A.FinalAssetClassAlt_Key=C.Co_Assetclassalt_key
								,A.FlgDeg='Y'
								,A.FinalNpaDt=B.Co_NPADate
								--,A.DegReason='NPA DUE TO PRIMARY BORROWER '+C.CO_APPLICANT_UCIC
					FROM PRO.AccountCal A 
						INNER JOIN #PrimaryDegData1 B ON A.RefCustomerID=B.APPLICANT_UCIC
						INNER JOIN PRO.CoBorrowerDetails C ON C.APPLICANT_UCIC=B.APPLICANT_UCIC
					WHERE A.FlgDeg<>'Y' AND A.FinalNpaDt IS NULL
							AND ISNULL(A.FlgMoc,'')<>'Y'
							AND A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey

				UPDATE A SET A.DegReason='NPA DUE TO PRIMARY BORROWER APPLICANT_FCR_CUST_ID '+C.CO_APPLICANT_UCIC
					 FROM PRO.AccountCal A 
						INNER JOIN #PrimaryDegData1 B ON A.RefCustomerID=B.APPLICANT_UCIC
						INNER JOIN PRO.CoBorrowerDetails C ON C.APPLICANT_UCIC=B.APPLICANT_UCIC
					WHERE A.DegReason IS NULL 
						AND A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey

			/*ADDED BY ZAIN ON 20250219 TO HANDLE COBOOROWER LOOP OBSERVATION END*/ 

		  update b set b.DegDate=a.DegDate,b.FlgDeg='Y',
		 B.Pri_Assetclassalt_key = A.Pri_Assetclassalt_key
		,B.Pri_NPADate			 = A.Pri_NPADate
		,B.Co_Assetclassalt_key	 = A.Co_Assetclassalt_key
		,B.Co_NPADate			 = A.Co_NPADate
		 from #PrimaryDegData1 a
		  inner join PRo.CoBorrowerDetails b
		  on a.APPLICANT_UCIC=b.APPLICANT_UCIC
		  where --(B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey) and /*ADDED BY ZAIN ON 20250219 TO HANDLE COBOOROWER LOOP OBSERVATION*/
		   b.DegDate is null

		/*07022024 - FOR ABOVE UCIC UPDATING FLGUPG=N AND UPGDATE AS NULL BECASUE THESE UCIC ARE AMRKED AS DEGDATE AND FLAG */
		update b set b.upgDate=null,b.Flgupg='N'
		from #PrimaryDegData1 a
		  inner join PRo.CoBorrowerDetails b
		  on a.APPLICANT_UCIC=b.APPLICANT_UCIC
		  --where (B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey)/*ADDED BY ZAIN ON 20250219 TO HANDLE COBOOROWER LOOP OBSERVATION*/

		  /*ADDED BY ZAIN ON 20241225 TO HANDLE COBOOROWER LOOP OBSERVATION*/
		  UPDATE PRO.COBORROWERDETAILS 
						SET upgDate=null
							,Flgupg='N'
			WHERE APPLICANT_UCIC IN (SELECT CO_APPLICANT_UCIC FROM PRO.COBORROWERDETAILS WHERE FlgDeg='Y')
		  AND (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey)
		  /*ADDED BY ZAIN ON 20241225 TO HANDLE COBOOROWER LOOP OBSERVATION END*/



	END
IF @FLG_UPG_DEG='U'
	BEGIN


	--UPDATE B SET FlgDeg='N',DegDate=NULL
	--FROM PRO.CUSTOMERCAL A
	--INNER JOIN PRO.CoBorrowerDetails B
	--ON A.UCIF_ID=B.UCIF_ID
	--WHERE A.FlgUpg='U'

		/*UPDATE FINALASSETCLASS AT ACCOUNT LEVEL */
		IF OBJECT_ID('TEMPDB..#TEMPTABLE_COBO') IS NOT NULL
		  DROP TABLE #TEMPTABLE_COBO
		
		
		CREATE TABLE #TEMPTABLE_COBO (RefCustomerID VARCHAR(30))--,TOTALCOUNT INT)
		--INSERT INTO #TEMPTABLE_COBO
		--SELECT A.RefCustomerID--,TOTALCOUNT -- INTO #TEMPTABLE
		--FROM 
		--	(
		--		SELECT A.RefCustomerID,COUNT(1) TOTALCOUNT FROM PRO.CUSTOMERCAL A INNER JOIN PRO.ACCOUNTCAL B ON A.UCIF_ID=B.UCIF_ID 
		--		WHERE (A.FlgProcessing='N' ) AND A.UCIF_ID IS NOT NULL
		--		--AND A.UCIF_ID<>'0'
		--		GROUP BY A.RefCustomerID
		--	) A
		--	 INNER JOIN 
		--		(
		--			SELECT A.RefCustomerID,COUNT(1) TOTALDPD_MAXCOUNT FROM PRO.CUSTOMERCAL A INNER JOIN PRO.ACCOUNTCAL B ON A.UCIF_ID=B.UCIF_ID
		--			WHERE (B.DPD_INTSERVICE<=B.REFPERIODINTSERVICEUPG
		--					and B.DPD_OVERDRAWN <=B.REFPERIODOVERDRAWNUPG
		--					and B.DPD_OVERDUE<=B.REFPERIODOVERDUEUPG
		--					and B.DPD_RENEWAL<=B.REFPERIODREVIEWUPG
		--					and B.DPD_STOCKSTMT <=B.REFPERIODSTKSTATEMENTUPG)
		--					and B.FinalAssetClassAlt_Key NOT IN(1)
		--				AND (A.FlgProcessing='N')
		--				AND B.Asset_Norm NOT IN ('ALWYS_NPA','ALWYS_STD')
		--				AND  ISNULL(A.MocStatusMark,'N')='N' 
		--				AND  ISNULL(B.AccountStatus,'N')<>'Z' 
		--				AND ISNULL(B.BankAssetClasS,'N')<>'WRITEOFF'
		--				AND A.UCIF_ID IS NOT NULL
		--				--AND A.UCIF_ID<>'0'
		--			GROUP BY A.RefCustomerID
		--		) B ON A.RefCustomerID=B.RefCustomerID 
		--		AND A.TOTALCOUNT=B.TOTALDPD_MAXCOUNT
				 
	--/*26102023--FIND THE CUSTOMER FOR UPGRADE- WHOSE EITHER NOT BREACHED THE NPA CRITERIA OR AFTER NPA CAME OUT IN UPGRADE CONDITIONs */

		IF OBJECT_ID('TEMPDB..#TEMPCOTABLE1') IS NOT NULL
		  DROP TABLE #TEMPCOTABLE1

			SELECT A.UCIF_ID   INTO #TEMPCOTABLE1 FROM 
			(
			SELECT A.UCIF_ID,COUNT(1) TOTALCOUNT FROM PRO.CUSTOMERCAL A INNER JOIN PRO.ACCOUNTCAL B ON A.UCIF_ID=B.UCIF_ID 
			WHERE (A.FlgProcessing='N' ) AND A.UCIF_ID IS NOT NULL
			 --Condition changed  By Triloki Khanna  08/04/2021 One Account 'ALWYS_STD' and DPD of All other accounts Zero , so condition of  ALWYS_STD Added
			AND B.Asset_Norm NOT IN ('ALWYS_STD')
			/*ADDED BY ZAIN ON 20250219 FOR COBORROWER LOOP SCENARIO*/
			AND A.UCIF_ID NOT IN (SELECT CO_APPLICANT_UCIC FROM PRO.CoBorrowerDetails WHERE FlgDeg='Y')
			/*ADDED BY ZAIN ON 20250219 FOR COBORROWER LOOP SCENARIO*/
			--AND A.UCIF_ID<>'0'
			GROUP BY A.UCIF_ID
			)
			A INNER JOIN 
			(
			SELECT A.UCIF_ID,COUNT(1) TOTALDPD_MAXCOUNT FROM PRO.CUSTOMERCAL A INNER JOIN PRO.ACCOUNTCAL B ON A.UCIF_ID=B.UCIF_ID
			WHERE (B.DPD_INTSERVICE<=B.REFPERIODINTSERVICEUPG
			  -- and B.DPD_NOCREDIT <=B.REFPERIODNOCREDITUPG
			   and B.DPD_OVERDRAWN <=B.REFPERIODOVERDRAWNUPG
			   and B.DPD_OVERDUE<=B.REFPERIODOVERDUEUPG
			   and B.DPD_RENEWAL<=B.REFPERIODREVIEWUPG
			   and B.DPD_STOCKSTMT <=B.REFPERIODSTKSTATEMENTUPG)
			   and B.FinalAssetClassAlt_Key not in(1)
			AND (A.FlgProcessing='N')
			AND B.Asset_Norm NOT IN ('ALWYS_NPA','ALWYS_STD')
			AND  ISNULL(A.MocStatusMark,'N')='N' 
			AND  ISNULL(B.AccountStatus,'N')<>'Z' 
			AND ISNULL(B.BankAssetClasS,'N')<>'WRITEOFF'
			AND A.UCIF_ID IS NOT NULL
			--AND A.UCIF_ID<>'0'
			GROUP BY A.UCIF_ID
			) B ON A.UCIF_ID=B.UCIF_ID AND A.TOTALCOUNT=B.TOTALDPD_MAXCOUNT



					IF OBJECT_ID('TEMPDB..#TEMPCOTABLE2') IS NOT NULL
					  DROP TABLE #TEMPCOTABLE2

			SELECT A.RefCustomerID  INTO #TEMPCOTABLE2 FROM 
			(
			SELECT A.RefCustomerID,COUNT(1) TOTALCOUNT FROM PRO.CUSTOMERCAL A INNER JOIN PRO.ACCOUNTCAL B ON A.RefCustomerID=B.RefCustomerID 
			WHERE (A.FlgProcessing='N' ) AND A.UCIF_ID IS  NULL 
			 and A.RefCustomerID is not null
			--AND A.UCIF_ID<>'0'
			 --Condition changed  By Triloki Khanna  08/04/2021 One Account 'ALWYS_STD' and DPD of All other accounts Zero , so condition of  ALWYS_STD Added
			AND B.Asset_Norm NOT IN ('ALWYS_STD')
			GROUP BY A.RefCustomerID
			)
			A INNER JOIN 
			(
			SELECT A.RefCustomerID,COUNT(1) TOTALDPD_MAXCOUNT FROM PRO.CUSTOMERCAL A INNER JOIN PRO.ACCOUNTCAL B ON A.RefCustomerID=B.RefCustomerID
			WHERE (B.DPD_INTSERVICE<=B.REFPERIODINTSERVICEUPG
			  -- and B.DPD_NOCREDIT <=B.REFPERIODNOCREDITUPG
			   and B.DPD_OVERDRAWN <=B.REFPERIODOVERDRAWNUPG
			   and B.DPD_OVERDUE<=B.REFPERIODOVERDUEUPG
			   and B.DPD_RENEWAL<=B.REFPERIODREVIEWUPG
			   and B.DPD_STOCKSTMT <=B.REFPERIODSTKSTATEMENTUPG)
			   and B.FinalAssetClassAlt_Key not in(1)
			AND (A.FlgProcessing='N')
			AND B.Asset_Norm NOT IN ('ALWYS_NPA','ALWYS_STD')
			AND  ISNULL(A.MocStatusMark,'N')='N' 
			AND  ISNULL(B.AccountStatus,'N')<>'Z' 
			AND ISNULL(B.BankAssetClasS,'N')<>'WRITEOFF'
			AND A.UCIF_ID IS  NULL 
			--AND A.UCIF_ID<>'0'
			AND A.RefCustomerID is not null
			GROUP BY A.RefCustomerID

			) B ON A.RefCustomerID=B.RefCustomerID AND A.TOTALCOUNT=B.TOTALDPD_MAXCOUNT


					IF OBJECT_ID('TEMPDB..#TEMPCOTABLE3') IS NOT NULL
					  DROP TABLE #TEMPCOTABLE3

			SELECT A.SourceSystemCustomerID  INTO #TEMPCOTABLE3 FROM 
			(
			SELECT A.SourceSystemCustomerID,COUNT(1) TOTALCOUNT FROM PRO.CUSTOMERCAL A INNER JOIN PRO.ACCOUNTCAL B ON A.SourceSystemCustomerID=B.SourceSystemCustomerID 
			WHERE (A.FlgProcessing='N' ) AND A.UCIF_ID IS  NULL AND A.RefCustomerID IS  NULL
			 and A.SourceSystemCustomerID is not null
			--AND A.UCIF_ID<>'0'
			GROUP BY A.SourceSystemCustomerID
			)
			A INNER JOIN 
			(
			SELECT A.SourceSystemCustomerID,COUNT(1) TOTALDPD_MAXCOUNT FROM PRO.CUSTOMERCAL A INNER JOIN PRO.ACCOUNTCAL B ON A.SourceSystemCustomerID=B.SourceSystemCustomerID
			WHERE (B.DPD_INTSERVICE<=B.REFPERIODINTSERVICEUPG
			  -- and B.DPD_NOCREDIT <=B.REFPERIODNOCREDITUPG
			   and B.DPD_OVERDRAWN <=B.REFPERIODOVERDRAWNUPG
			   and B.DPD_OVERDUE<=B.REFPERIODOVERDUEUPG
			   and B.DPD_RENEWAL<=B.REFPERIODREVIEWUPG
			   and B.DPD_STOCKSTMT <=B.REFPERIODSTKSTATEMENTUPG)
			   and B.FinalAssetClassAlt_Key not in(1)
			AND (A.FlgProcessing='N')
			AND B.Asset_Norm NOT IN ('ALWYS_NPA','ALWYS_STD')
			AND  ISNULL(A.MocStatusMark,'N')='N' 
			AND  ISNULL(B.AccountStatus,'N')<>'Z' 
			AND ISNULL(B.BankAssetClasS,'N')<>'WRITEOFF'
			AND A.UCIF_ID IS  NULL 
			AND A.RefCustomerID IS  NULL 
			AND A.SourceSystemCustomerID is not null
			--AND A.UCIF_ID<>'0'
			GROUP BY A.SourceSystemCustomerID

			) B ON A.SourceSystemCustomerID=B.SourceSystemCustomerID AND A.TOTALCOUNT=B.TOTALDPD_MAXCOUNT


			insert into #TEMPTABLE_COBO
			select a.RefCustomerID 
			from pro.CustomerCal a
				inner join #TEMPCOTABLE1 b on a.UCIF_ID=b.UCIF_ID
			union 
			select a.RefCustomerID from pro.CustomerCal a
				inner join #TEMPCOTABLE2 b on a.RefCustomerID=b.RefCustomerID
			union 
			select a.RefCustomerID from pro.CustomerCal a
				inner join #TEMPCOTABLE3 b on a.SourceSystemCustomerID=b.SourceSystemCustomerID

			Union
			SELECT A.RefCustomerID ----,A.*
			FROM PRO.CoBorrowerDetails a
				INNER JOIN PRO.CUSTOMERCAL B
					ON  (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
					AND A.CoBorrowerID=b.RefCustomerID
					AND b.SysAssetClassAlt_Key>1 AND A.DegDate IS NULL
			UNION
			SELECT A.CoBorrowerID RefCustomerID ----,A.*
			from PRO.CoBorrowerDetails a
				INNER JOIN PRO.CUSTOMERCAL B
					ON  (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
					AND A.RefCustomerID=b.RefCustomerID
					AND b.SysAssetClassAlt_Key>1 AND A.DegDate IS NULL
            UNION
			  SELECT B.RefCustomerID ----,A.*
			FROM PRO.CoBorrowerDetails a
				INNER JOIN PRO.CUSTOMERCAL B
					ON  (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
					AND A.APPLICANT_UCIC=b.UCIF_ID
					AND b.SysAssetClassAlt_Key>1 AND A.DegDate IS NULL
					--and a.APPLICANT_UCIC='8900573'
					group by b.RefCustomerID


			
			/*07022024 - FINDING CUSTOMERID ARE NOT ELLIGBLE FOR UPGRADE - BREACHING NPA CREITERIA */
			IF OBJECT_ID('TEMPDB..#WrongUpg_coboflg') IS NOT NULL
				 DROP TABLE #WrongUpg_coboflg
			SELECT RefCustomerID
			into #WrongUpg_coboflg
			FROM PRO.AccountCal B
			WHERE (ISNULL(B.DPD_INTSERVICE,0)>=B.REFPERIODINTSERVICE
				OR ISNULL(B.DPD_OVERDRAWN,0)>=B.REFPERIODOVERDRAWN  
				OR ISNULL(B.DPD_NOCREDIT,0)>=B.REFPERIODNOCREDIT
				OR ISNULL(B.DPD_OVERDUE,0) >=B.REFPERIODOVERDUE 
				OR ISNULL(B.DPD_STOCKSTMT,0)>=B.REFPERIODSTKSTATEMENT
				OR ISNULL(B.DPD_RENEWAL,0)>=B.REFPERIODREVIEW 
				)
			AND B.Asset_Norm='NORMAL'
			/*ADDED TO HANDLE COBORROWER RESTRUCTURE CONDITION BY ZAIN ON UAT 2024-12-12*/
			UNION
			SELECT RefCustomerID
			FROM PRO.AccountCal 
			where Asset_Norm='ALWYS_NPA'
			/*ADDED TO HANDLE COBORROWER RESTRUCTURE CONDITION BY ZAIN ON UAT 2024-12-12 END*/


			/*07022024 - DELETING RECORED FOR EXCLUSION TO UPGADE FLGUPG IN CO-BORROWER DETAIL */
			 DELETE A from #TEMPTABLE_COBO  A
				INNER JOIN #WrongUpg_coboflg B
					ON A.RefCustomerID=B.RefCustomerID

			


					/*26102023--UPDATE UPGRADE FLAG FOR PRIMARY BORROWER - IF MEET THE UPGRDE CONDITION*/
			
			UPDATE A SET A.FlgUpg='U'
						,A.UpgDate=@PROCESSDATE
						,A.FLGDEG='N'
						,A.DegDate=NULL
		----select a.RefCustomerID
			 FROM PRO.CoBorrowerDetails a
				INNER JOIN #TEMPTABLE_COBO  b
					ON (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
					AND A.RefCustomerID=b.RefCustomerID
				left join PRO.CoBorrowerDetails C
					ON (C.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey)
					AND c.CoBorrowerID=a.RefCustomerID
				Inner join PRO.Customercal d
					on d.RefCustomerID=a.RefCustomerID
					and d.FlgUpg='U'
				WHERE  A.FlgDeg='Y'  ---Change by amar on 28022024 - for customer should be update degdate as null if dpd under upgrade criteria and should be eligible for upgrade --c.RefCustomerId is null AND A.FlgDeg='Y'


		/*26102023--UPDATE UPGRADE FLAG AT CUSTOMER LEVEL FROM   */
			/*26102023--UPDATE UPGRADE FLAG FOR CO-BORROWER FOE ORIMRY CUSTOMER UPGRADED  */
	
		UPDATE A SET A.FlgUpg='U'
						,A.UpgDate=@PROCESSDATE
						,A.FLGDEG='N'
						,A.DegDate=NULL
			-- select *
			 FROM PRO.CoBorrowerDetails a
				INNER JOIN #TEMPTABLE_COBO  b
					ON (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
					AND A.RefCustomerID=b.RefCustomerID
					Inner join PRO.CoBorrowerDetails C
					ON (C.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey)
					and a.CoBorrowerID=c.RefCustomerID
					Inner join PRO.Customercal d
					on d.RefCustomerID=C.RefCustomerID---Changed by 29JAN2024  c.RefCustomerID /a.RefCustomerID
					and d.FlgUpg='U'

				WHERE ISNULL(A.FlgUpg,'N')='N' 


      			 update e set	e.FlgUpg='U'
						,e.UpgDate=@PROCESSDATE
						,e.FLGDEG='N'
						,e.DegDate=NULL
				--select a.RefCustomerID,a.UCIF_ID ,e.RefCustomerID
				from  #TEMPTABLE_COBO  b inner join Pro.customercal a
                    ON A.RefCustomerID=b.RefCustomerID 
					inner join PRO.CoBorrowerDetails c
						on c.CO_APPLICANT_UCIC=a.UCIF_ID and (C.EffectiveFromTimeKey<=@TimeKey AND c.EffectiveToTimeKey>=@TimeKey)
					inner join Pro.customercal D on c.RefCustomerID=D.RefCustomerID
					and D.FlgUpg='U' and C.FlgUpg='U'
				    inner join PRO.CoBorrowerDetails e
					on a.RefCustomerID= e.RefCustomerID and (e.EffectiveFromTimeKey<=@TimeKey AND e.EffectiveToTimeKey>=@TimeKey)


		    
		    IF OBJECT_ID('TEMPDB..#TEMPCOTABLE4') IS NOT NULL
					  DROP TABLE #TEMPCOTABLE4 

		/*07022024 - FINDING CUSTOMERS ARE MARKED FLGUPG=U IN CUSTOMERCAL(ELLIGIBLE FOR UPGRADE) AND FLGUPG =N AMRKED IN CO-BORROWER DETAIL */
                      select distinct a.RefCustomerID
				into #TEMPCOTABLE4
			 FROM PRO.CoBorrowerDetails a
				INNER JOIN #TEMPTABLE_COBO  b
					ON (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
					AND A.RefCustomerID=b.RefCustomerID
				  Inner join PRO.customercAL d
					on d.RefCustomerID=a.RefCustomerID
					and d.FlgUpg='U'
					and a.FlgUpg='N'
				 
		/*07022024 - UPDATING UPG FLAG=U IN CoBorrowerDetails FOR (COBORROWER) WHER PRIMARY  BORROWER IS UPGRADED */
			update	D SET            D.FlgUpg='U'
						,D.UpgDate=@PROCESSDATE
						,D.FLGDEG='N'
						,D.DegDate=NULL

			-- SELECT DISTINCT  a.RefCustomerID,b.coborrowerid,c.RefCustomerID,b.RefCustomerID
				  FROM #TEMPCOTABLE4 A
				 INNER JOIN PRO.CoBorrowerDetails B
				 ON A.RefCustomerID=B.coborrowerid
				 inner join PRO.customercal c
				 on c.RefCustomerID=b.RefCustomerID
				 and (c.FlgUpg='U' or c.sysassetclassalt_key=1)  
                         INNER JOIN PRO.CoBorrowerDetails D ON A.RefCustomerID=D.RefCustomerID

	
		UPDATE C	
			SET C.FlgUpg='N',c.UpgDate=null
		 --select Distinct c.RefCustomerID
		  from PRO.CoBorrowerDetails a
			inner join PRO.CUSTOMERCAL b
				on  (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
				AND A.RefCustomerID=B.RefCustomerID
				AND B.FlgUpg='N'
			INNER JOIN PRO.CoBorrowerDetails C
				ON A.RefCustomerID=C.RefCustomerID /*07022024-- UPDATING FLAG UPG=N  IN COBORROWER TABLE WHERE CUSTOMER CAL UPG FLG='N' AND IN CO-BORROWER TABLE FLGUPG=U ON CUSTOMERID BASES*/ --ON A.CoBorrowerID=C.RefCustomerID 01 FEB 2024
				AND ISNULL(C.FlgUpg,'N')='U' --and C.RefCustomerID='12243096'
				and (C.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey)


	UPDATE C	
			SET C.FlgUpg='N',c.UpgDate=null
		 --select Distinct c.RefCustomerID
		  from PRO.CoBorrowerDetails a
			inner join PRO.CUSTOMERCAL b
				on  (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
				AND A.APPLICANT_UCIC=B.UCIF_ID
				AND B.FlgUpg='N'
			INNER JOIN PRO.CoBorrowerDetails C
				ON A.APPLICANT_UCIC=C.APPLICANT_UCIC   /*07022024-- UPDATING FLAG UPG=N  IN COBORROWER TABLE WHERE CUSTOMER CAL UPG FLG='N' AND IN CO-BORROWER TABLE FLGUPG=U ON CUSTOMERID BASES*/ --ON A.CoBorrowerID=C.RefCustomerID 01 FEB 2024
				AND ISNULL(C.FlgUpg,'N')='U' --and C.RefCustomerID='12243096'
				and (C.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey)



				UPDATE A
			SET A.FlgUpg='N',A.UpgDate=null

                 from  PRO.CoBorrowerDetails a
                   inner join PRO.CUSTOMERCAL b
				on  (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
				AND Co_APPLICANT_UCIC=b.UCIF_ID
				AND B.FlgUpg='U'
                  inner join PRO.CoBorrowerDetails  c
	         on (c.EffectiveFromTimeKey<=@TimeKey AND c.EffectiveToTimeKey>=@TimeKey)
	--and A.Co_APPLICANT_UCIC=C.APPLICANT_UCIC
	            and A.APPLICANT_UCIC=C.APPLICANT_UCIC
	--and B.UCIF_ID=C.APPLICANT_UCIC
	              AND  c.FlgUpg='N'

		
			/* UPDATE UPGRADE FLAG AT CUSTOMER LEVEL FRO CO-BORROWER DATA*/
			UPDATE B SET b.FlgUpg='U'
			FROM PRO.CoBorrowerDetails a
				INNER JOIN PRO.CustomerCal  B
					ON (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
					AND A.CO_APPLICANT_FCR_CUST_ID=b.RefCustomerID /*07022024 - CHANGED CODE TO UPDATE FLGUPG IN CUSTOMERCAL FOR CO-BORROWER WHERE FLGUPG=U IN COBORROWER TABLE AND N IN CUSTOMER TABLE  */ --A.RefCustomerID AMAR CHANGED 31 JAN 2023
					INNER JOIN PRO.ACCOUNTCAL C ON B.RefCustomerID=C.RefCustomerID

				WHERE ISNULL(B.FlgUpg,'N')='N' AND A.FlgUpg='U'
				AND (B.FlgProcessing='N')
			AND C.Asset_Norm NOT IN ('ALWYS_NPA','ALWYS_STD')
			AND  ISNULL(B.MocStatusMark,'N')='N' 
			AND  ISNULL(C.AccountStatus,'N')<>'Z' 
			AND ISNULL(C.BankAssetClasS,'N')<>'WRITEOFF'



			     /*16052024 AMAR - ADDED CODE FOR UPGRADE THE CUSTOMER -- MARKED UPGRADE IN MAIN PROCESS(CUSTOMERCAL) 
                    AND DELG DATE IS NULL AND NO PRIMARY BORROWER AVAILABE IN COBO DATA*/
            UPDATE A
                SET A.FLGUPG='U'
                    ,A.UPGDATE=@PROCESSDATE
            FROM PRO.CoBorrowerDetails A
                INNER JOIN PRO.CUSTOMERCAL B
                    ON A.APPLICANT_FCR_CUST_ID=b.RefCustomerID
                    AND B.Asset_Norm NOT IN ('ALWYS_NPA')
                    AND B.FlgUpg='U' AND B.SYSASSETCLASSALT_KEY>1
                LEFT JOIN PRO.CoBorrowerDetails C
                    ON A.APPLICANT_UCIC=C.CO_APPLICANT_UCIC
                WHERE C.CO_APPLICANT_FCR_CUST_ID IS NULL
                     AND A.DEGDATE IS NULL
				/*ADDED FOR OTS BY ZAIN ON 20250311*/
					 AND A.APPLICANT_UCIC NOT IN (SELECT REFCUSTOMERID FROM PRO.ACCOUNTCAL WHERE DPD_OTS>0 
													AND EFFECTIVEFROMTIMEKEY<=@TIMEKEY
													AND EFFECTIVETOTIMEKEY>=@TIMEKEY)
				/*ADDED FOR OTS BY ZAIN ON 20250311*/



			

--IF OBJECT_ID('TEMPDB..#APPLICANTUPG') IS NOT NULL
	--		DROP TABLE #APPLICANTUPG

--select distinct CO_APPLICANT_FCR_CUST_ID,CO_APPLICANT_UCIC 
--into #APPLICANTUPG 
--FROM PRO.CoBorrowerDetails b  where b.FlgUpg='U'
--and (b.EffectiveFromTimeKey<=@TimeKey AND b.EffectiveToTimeKey>=@TimeKey)


--IF OBJECT_ID('TEMPDB..#CoBorrowerDetailsUPG') IS NOT NULL
--			DROP TABLE #CoBorrowerDetailsUPG

--select * into #CoBorrowerDetailsUPG 
--from PRO.CoBorrowerDetails D where APPLICANT_UCIC in (select CO_APPLICANT_FCR_CUST_ID from #APPLICANTUPG) and  
--ISNULL(D.FlgUpg,'N')='N'  and ISNULL(D.FlgDeg,'N')='N'
-- and (D.EffectiveFromTimeKey<=@TimeKey AND D.EffectiveToTimeKey>=@TimeKey)

--Update B SET b.FlgUpg='U'
--FROM  #CoBorrowerDetailsUPG a
--INNER JOIN PRO.CustomerCal  B
--ON (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
--AND A.APPLICANT_UCIC=b.UCIF_ID
--INNER JOIN PRO.ACCOUNTCAL C ON B.UCIF_ID=C.UCIF_ID
--WHERE ISNULL(B.FlgUpg,'N')='N' AND ISNULL(A.FlgUpg,'N')='N'
    --        AND (B.FlgProcessing='N')  
     --       AND C.Asset_Norm NOT IN ('ALWYS_NPA','ALWYS_STD')
      --      AND  ISNULL(B.MocStatusMark,'N')='N' 
      --      AND  ISNULL(C.AccountStatus,'N')<>'Z' 
       --     AND ISNULL(C.BankAssetClasS,'N')<>'WRITEOFF'

		/* COBORROWER UPGRADE REVERT IN CASE OF PRIMRY BORROWER BREACHED NP CONFITION */
			;WITH CTE_COBO
			AS(
			select CO_APPLICANT_UCIC from pro.CoBorrowerDetails where DegDate is NOT NULL AND CO_APPLICANT_UCIC IS NOT NULL
			INTERSECT
			select UCIF_ID from pro.CoBorrowerDetails 
			)
			UPDATE A
				SET A.FlgUpg='N'
			FROM PRO.customercal A
				INNER JOIN CTE_COBO B
					ON A.UCIF_ID=B.CO_APPLICANT_UCIC
				WHERE A.FlgUpg='U'

		/* COBORROWER UPGRADE IN CASE OF NPA ND PRIMRY BORROWER ELLIGIBLE FOR UPGRDE WITH SELF*/

			IF OBJECT_ID('TEMPDB..##COBORROWER_DATATablewriteoff') IS NOT NULL
			      DROP TABLE ##COBORROWER_DATATablewriteoff
			SELECT distinct A.UCIF_ID 
			into ##COBORROWER_DATATablewriteoff
			 FROM PRO.customercal A INNER JOIN PRO.accountcal B ON A.UCIF_ID=B.UCIF_ID
			WHERE  B.FINALAssetClassAlt_Key not in(1)
			AND B.Asset_Norm IN ('ALWYS_NPA' )
			AND  ISNULL(B.AccountStatus,'N')='Z' 
			AND ISNULL(B.BankAssetClasS,'N')='WRITEOFF'


		/* 0722024 -- PREPARING DATA AND UPDATEING COLUMN DEGDATE,PRI_ASSETcLASS AND pRInpa DATE TO KEEP DATA AS SYNCHRONISE AT UCIC LEVEL FOR CUSTOMER MARKED DEGD DATE*/
	
		IF OBJECT_ID('TEMPDB..#PrimaryDegData11') IS NOT NULL
		      DROP TABLE #PrimaryDegData11
		 select APPLICANT_UCIC,DegDate,Pri_Assetclassalt_key,Pri_NPADate,Co_Assetclassalt_key,Co_NPADate into #PrimaryDegData11
		  from PRo.CoBorrowerDetails where DegDate is not null and EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey
		  group by APPLICANT_UCIC,DegDate,Pri_Assetclassalt_key,Pri_NPADate,Co_Assetclassalt_key,Co_NPADate

 
		  update b set b.DegDate=a.DegDate,b.FlgDeg='Y',
			 B.Pri_Assetclassalt_key = A.Pri_Assetclassalt_key
			,B.Pri_NPADate			 = A.Pri_NPADate
			,B.Co_Assetclassalt_key	 = A.Co_Assetclassalt_key
			,B.Co_NPADate			 = A.Co_NPADate
		 from #PrimaryDegData11 a
		  inner join PRo.CoBorrowerDetails b
		  on a.APPLICANT_UCIC=b.APPLICANT_UCIC
		  where (B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey)
		  and b.DegDate is null

		/*07022024 - FOR ABOVE UCIC UPDATING FLGUPG=N AND UPGDATE AS NULL BECASUE THESE UCIC ARE AMRKED AS DEGDATE AND FLAG */
		update b set b.upgDate=null,b.Flgupg='N'
		from #PrimaryDegData11 a
		  inner join PRo.CoBorrowerDetails b
		  on a.APPLICANT_UCIC=b.APPLICANT_UCIC
		  where (B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey)


		IF OBJECT_ID('TEMPDB.dbo.#CTE_COBO2') IS NOT NULL
			  DROP TABLE #CTE_COBO2 
		/*07022024 -  FINDING CO-BORROWER UCIC FOR DEGRADE DATE IS IS NOT NULL AND  CO_APPLICANT_UCIC IS NOT NULL OF PRIMARY BORROWER*/
			select CO_APPLICANT_UCIC INTO #CTE_COBO2 from pro.CoBorrowerDetails where DegDate is NOT NULL AND CO_APPLICANT_UCIC IS NOT NULL
			
		IF OBJECT_ID('TEMPDB.dbo.#CTE_COBO1 ') IS NOT NULL
		  DROP TABLE #CTE_COBO1 
			
			/* 07022024 - FINDING COBORROWER UCIC  THOSE ARE AVAILABLE AS PROMARY BORROWER AND DEGDATE IS NULL - AND PRIMARY BORROWER'S ALSO DEGDATE IS NULL AND CO-APP UCIC IS AVAILABLE  */	
			select CO_APPLICANT_UCIC INTO #CTE_COBO1 from pro.CoBorrowerDetails where DegDate is NULL AND CO_APPLICANT_UCIC IS NOT NULL
		                   INTERSECT
			select UCIF_ID from pro.CoBorrowerDetails where DegDate is NULL


/*07022024  - DELETING MATCHING RECORDS - THOSE ARE NOT ELLIGIBLE FOR UPGRADE IN TABLE LIKE WRITEOFF/ ACCOUNT STSTUS Z */
			delete a
		    from #CTE_COBO1  a
		 inner join ##COBORROWER_DATATablewriteoff b
		  on a.CO_APPLICANT_UCIC  =b.UCIF_ID 

 /*07022024  - DELETING MATCHING RECORDS- BECAUSE IF ANY ONE RECORTD OF CO-BORROWER HAVING DEG DATE IS NOT NULL SHOULD OF OUT OF UPGRADE  */
		 delete a
		    from #CTE_COBO1  a
		 inner join #CTE_COBO2 b
		  on a.CO_APPLICANT_UCIC  =b.CO_APPLICANT_UCIC 
			 

	/* 02072024 - MARKING FLG UPG AT CUSTOMER LEVELE(CO-BORROWER) IN CUSTOMERCAL FOR ELLIGIOBLE CUSTOMER*/
		UPDATE A
			SET A.FlgUpg='U'
		FROM PRO.customercal A
			INNER JOIN #CTE_COBO1 B
				ON A.UCIF_ID=B.CO_APPLICANT_UCIC
			WHERE A.FlgUpg='N' and SysAssetClassAlt_Key>1
			AND   A.Asset_Norm NOT IN ('ALWYS_NPA','ALWYS_STD')

	/* 02072024 - MARKING FLG UPG AT CUSTOMER LEVELE(CO-BORROWER) IN CO-BORROWER TABLE FOR ELLIGIOBLE CUSTOMER*/
			UPDATE A
				SET A.FlgUpg='U', UpgDate=@PROCESSDATE,FlgDeg='N',DegDate=NULL
			FROM pro.CoBorrowerDetails A
				INNER JOIN #CTE_COBO1 B
					ON A.UCIF_ID=B.CO_APPLICANT_UCIC
				WHERE ISNULL(A.FlgUpg,'N')='N'

	
		/* 02072024 - DUE TO CROSS CO-BORROWER LINKAGE -RESTRUCT WROMG UPGRADE  IN CUSTMERCAL  - IF PRIMARY BOROWER DEGDATE IS NOT NULL*/
			UPDATE C
				SET C.FlgUpg='N'
			FROM pro.CoBorrowerDetails A
				INNER JOIN pro.CoBorrowerDetails  B
					ON A.CO_APPLICANT_UCIC=B.UCIF_ID
				INNER JOIN PRO.customercal C
					ON C.UCIF_ID=B.UCIF_ID
				WHERE A.DEGDATE IS NOT NULL AND C.FlgUpg='U'

		IF OBJECT_ID('TEMPDB..#CO_BORROWER_UPG_DIFFfLAG') IS NOT NULL
			DROP TABLE #CO_BORROWER_UPG_DIFFfLAG
	
	/* 02072024 - FINDING UCIC ID FROM COBORROWER TABLE WHERE AT UCIC LEVEL BOTH FLAGS ARE MARKED u AND N IN FLGUPG - FOR MARKING FLGUPG IN CO-BORROWER  */

	         select  distinct UCIF_ID 
				INTO #CO_BORROWER_UPG_DIFFfLAG
			from PRO.CoBorrowerDetails 
			 WHERE FlgUpg='U'  
			INTERSECT
		     select  distinct ISNULL(UCIF_ID,'') from PRO.CoBorrowerDetails 
			WHERE ISNULL(FlgUpg,'N')='N'  

	/* 02072024 - DELETING RECORD FROM #CO_BORROWER_UPG_DIFFfLAG WHERE UCIC MATCHING WITH CO-BOROWER DATA FILTERED  */
			delete a
		        from #CO_BORROWER_UPG_DIFFfLAG a
		     inner join ##COBORROWER_DATATablewriteoff b
		      on a.UCIF_ID=b.UCIF_ID 	

		/* 02072024 - maRKING FLGUPG IN CO-BORROWER DETAIL TABLE FOR ABOVE FILTERED RECORDS */
			UPDATE A
				SET A.FlgUpg='U', UpgDate=@PROCESSDATE,FlgDeg='N',DegDate=NULL
			FROM PRO.CoBorrowerDetails A
				INNER JOIN #CO_BORROWER_UPG_DIFFfLAG B
					ON A.UCIF_ID=B.UCIF_ID
				WHERE ISNULL(A.FlgUpg,'N')='N'









			/* FIND THE CUSTOMERS - UPGRADE D IN NORMAL PROCESS BUT NOT IN CO-BORROWER DATA */
			IF OBJECT_ID('TEMPDB..#CO_BORROWER_UPG_REVERT') IS NOT NULL
				DROP TABLE #CO_BORROWER_UPG_REVERT

			 SELECT  b.RefCustomerID,b.UcifEntityID,b.PANNO,b.SourceSystemCustomerID
				into #CO_BORROWER_UPG_REVERT
			 FROM PRO.CoBorrowerDetails a
				INNER JOIN PRO.CustomerCal  B
					ON (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
					AND A.RefCustomerID=b.RefCustomerID
				WHERE ISNULL(B.FlgUpg,'N')='U' AND ISNULL(A.FlgUpg,'N')='N' --AND A.FlgDeg='Y'

				union 
				 SELECT  b.RefCustomerID,b.UcifEntityID,b.PANNO,b.SourceSystemCustomerID
				
			 FROM PRO.CoBorrowerDetails a
				INNER JOIN PRO.CustomerCal  B
					ON (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
					AND A.APPLICANT_UCIC=b.UCIF_ID
				WHERE ISNULL(B.FlgUpg,'N')='U' AND ISNULL(A.FlgUpg,'N')='N' --AND A.FlgDeg='Y'
				---
			
	

				/* REVERT UPGRADE FLAG FOR SOURCESYSTEMCUSTOMERID */
				UPDATE B
					SET B.FlgUpg='N'
				FROM #CO_BORROWER_UPG_REVERT A
					INNER JOIN PRO.CUSTOMERCAL B
						ON A.SourceSystemCustomerID=B.SourceSystemCustomerID
					WHERE 	B.FlgUpg='U'	


				/* REVERT UPGRADE FLAG FOR UCIF ENTITYID */
				UPDATE B
					SET B.FlgUpg='N'
				FROM #CO_BORROWER_UPG_REVERT A
					INNER JOIN PRO.CUSTOMERCAL B
						ON A.UcifEntityID=B.UcifEntityID
					WHERE 	B.FlgUpg='U'	and b.UCIF_ID is not null

				/* REVERT UPGRADE FLAG FOR PAN */
				UPDATE B
					SET B.FlgUpg='N'
				FROM #CO_BORROWER_UPG_REVERT A
					INNER JOIN PRO.CUSTOMERCAL B
						ON A.PANNO=B.PANNO
					WHERE 	B.FlgUpg='U' and b.PANNO is not null	

			/*FOR PRIMARY BORROWER CLOSED ACCOUNTS GETTING COBORROWER DATA "CO_APPLICANT_UCIC"  OBSERVARTION REPORTED ON 20240819
			MAIL REFERENCE SUBJECT LINE "Internal | Production observation | Co-borrower production observation " CHANGED BY ZAIN ON 20240829*/
			
	
			/*MANUAL CHANGES ON UAT AFTER DATA IMPACT CHECK 20240930 BY ZAIN & TUSHAR*/
			;WITH CTE_A AS(
			SELECT A.CO_APPLICANT_UCIC,B.APPLICANT_UCIC FROM PRO.COBORROWERDETAILSHIST  A 
			LEFT JOIN PRO.COBORROWERDETAILS B 
			ON A.APPLICANT_UCIC=B.APPLICANT_UCIC
			WHERE B.APPLICANT_UCIC is null
			and A.APPLICANT_UCIC is not null
			AND (A.EFFECTIVEFROMTIMEKEY<=@TimeKey-1 AND A.EFFECTIVETOTIMEKEY>=@TimeKey-1)
			and a.FLAG='C'
			GROUP BY a.APPLICANT_UCIC,A.CO_APPLICANT_UCIC,B.APPLICANT_UCIC
			),
			CTE_B
			as(
			/*FINDING PRIMARY BORROWER(LINKED AS A COBORROWER ON PREVIOUS DATE) DEGRADE DATE IS NULL OR NOT*/
			SELECT B.APPLICANT_UCIC,B.DegDate,B.FlgDeg 
			FROM CTE_A A 
			INNER JOIN 
			PRO.COBORROWERDETAILSHIST B ON
			A.CO_APPLICANT_UCIC=B.APPLICANT_UCIC
			AND (B.EFFECTIVEFROMTIMEKEY<=@TimeKey-1 AND B.EFFECTIVETOTIMEKEY>=@TimeKey-1)
			AND B.DegDate IS NULL 
			)
			/*UPDATING PRIMARY BORROWER FLAG AS 'U' IF ALL THE UPGRADATION CONDITION IS SATISFYING SO THAT IT WILL BE UPGRADED*/
			UPDATE B SET b.FlgUpg='U'
			FROM CTE_B a
				INNER JOIN PRO.CustomerCal  B
					ON 
					 A.APPLICANT_UCIC=B.UCIF_ID
					INNER JOIN PRO.ACCOUNTCAL C ON B.UCIF_ID=C.UCIF_ID
			WHERE (B.FlgProcessing='N')
					AND C.Asset_Norm NOT IN ('ALWYS_NPA','ALWYS_STD')
					AND  ISNULL(B.MocStatusMark,'N')='N' 
					AND  ISNULL(C.AccountStatus,'N')<>'Z' 
					AND ISNULL(C.BankAssetClasS,'N')<>'WRITEOFF'
					and B.FlgUpg<>'U'
					and B.SrcAssetClassAlt_Key>1
			/*MANUAL CHANGES ON UAT AFTER DATA IMPACT CHECK 20240930 BY ZAIN & TUSHAR ON UCIF LEVEL END*/

;WITH CTE_A AS(
			SELECT A.CO_APPLICANT_FCR_CUST_ID,B.APPLICANT_FCR_CUST_ID FROM PRO.COBORROWERDETAILSHIST  A 
			LEFT JOIN PRO.COBORROWERDETAILS B 
			ON A.APPLICANT_FCR_CUST_ID=B.APPLICANT_FCR_CUST_ID
			WHERE B.APPLICANT_FCR_CUST_ID is null
			and A.APPLICANT_UCIC is null 
			and a.APPLICANT_FCR_CUST_ID is not null
			AND (A.EFFECTIVEFROMTIMEKEY<=@timekey-1 AND A.EFFECTIVETOTIMEKEY>=@timekey-1)
			and a.FLAG='C'
			GROUP BY a.APPLICANT_FCR_CUST_ID,A.CO_APPLICANT_FCR_CUST_ID,B.APPLICANT_FCR_CUST_ID
			),
			CTE_B
			as(
			/*FINDING PRIMARY BORROWER(LINKED AS A COBORROWER ON PREVIOUS DATE) DEGRADE DATE IS NULL OR NOT*/
			SELECT B.APPLICANT_UCIC,b.APPLICANT_FCR_CUST_ID,B.DegDate,B.FlgDeg 
			FROM CTE_A A 
			INNER JOIN 
			PRO.COBORROWERDETAILSHIST B ON
			A.CO_APPLICANT_FCR_CUST_ID=B.APPLICANT_FCR_CUST_ID
			AND (B.EFFECTIVEFROMTIMEKEY<=@TimeKey-1 AND B.EFFECTIVETOTIMEKEY>=@TimeKey-1)
			AND B.DegDate IS NULL 
			)
			/*UPDATING PRIMARY BORROWER FLAG AS 'U' IF ALL THE UPGRADATION CONDITION IS SATISFYING SO THAT IT WILL BE UPGRADED*/
			UPDATE B SET b.FlgUpg='U'
			FROM CTE_B a
				INNER JOIN PRO.CustomerCal  B
					ON 
					 A.APPLICANT_FCR_CUST_ID=B.RefCustomerID
					INNER JOIN PRO.ACCOUNTCAL C ON B.RefCustomerID=C.RefCustomerID
			WHERE (B.FlgProcessing='N')
					AND C.Asset_Norm NOT IN ('ALWYS_NPA','ALWYS_STD')
					AND  ISNULL(B.MocStatusMark,'N')='N' 
					AND  ISNULL(C.AccountStatus,'N')<>'Z' 
					AND ISNULL(C.BankAssetClasS,'N')<>'WRITEOFF'
					and B.FlgUpg<>'U'
					and B.SrcAssetClassAlt_Key>1

			/*MANUAL CHANGES ON UAT AFTER DATA IMPACT CHECK 20240930 BY ZAIN & TUSHAR ON CUSTOMER LEVEL END*/

			/*FOR CUSTOMER HAVING ONLY ALWAYS STANDARD ACCOUNT AS ON DATE AND PREVIOULSY NPA OR WRITE OF ACCOUNTS ARE CLOSED 
				THEN CUSTOMER UPGRADE FLAG SHOLUD BE 'Y' IN CUSTOMER CAL FLG SHOULD BE UPGRADE 'U'.ADDED BY ZAIN ON 20240902 ON LOCAL*/

				IF OBJECT_ID('TEMPDB..#ACCOUNT_ALWAYS_STD') IS NOT NULL
				DROP TABLE #ACCOUNT_ALWAYS_STD
			
				SELECT  UCIF_ID,RefCustomerID,COUNT(1) COUNT_STD
					INTO #ACCOUNT_ALWAYS_STD 
				FROM PRO.AccountCal
					WHERE Asset_Norm='ALWYS_STD'
	--				AND UCIF_ID='162810'
					GROUP BY UCIF_ID,RefCustomerID


				IF OBJECT_ID('TEMPDB..#CUST_ALWAYS_STD') IS NOT NULL
				DROP TABLE #ACCOUNT_ALL
		
				SELECT  A.UCIF_ID,A.RefCustomerID,COUNT(1) COUNT_ALL
					INTO #ACCOUNT_ALL 
				FROM PRO.AccountCal A 
					INNER JOIN #ACCOUNT_ALWAYS_STD B 
					ON A.UCIF_ID=B.UCIF_ID
				GROUP BY A.UCIF_ID,A.RefCustomerID


				;WITH CTE_STD AS(
							SELECT A.UCIF_ID FROM 
							#ACCOUNT_ALWAYS_STD A
							INNER JOIN #ACCOUNT_ALL B
							ON A.UCIF_ID=B.UCIF_ID
							AND A.COUNT_STD=B.COUNT_ALL
							)
						UPDATE B SET B.FlgUpg='U'
									,B.FlgDeg=NULL
									,B.DegDate=NULL
									,B.DegReason=NULL
							--SELECT A.*,B.FlgDeg,B.DegDate,B.DegReason,B.FlgUpg,B.* 
							FROM CTE_STD a
							INNER JOIN PRO.CustomerCal B
						ON 
						 A.UCIF_ID=B.UCIF_ID
						 AND ISNULL(B.FlgDeg,'N')='Y'--ADDED BY ZAIN AND BALA ON LOCAL AS PER OBSERVATION RAISED BY PRAVIN ON 20250321

/*ADDED BY ZAIN AND BALA ON LOCAL AS PER OBSERVATION RAISED BY PRAVIN ON 20250321*/
				UPDATE C SET C.SysAssetClassAlt_Key=1
							,C.SysNPA_Dt=null
							,C.FlgUpg='U'
							,C.FlgDeg=NULL
							,C.DegDate=NULL
							,C.DegReason=NULL
				FROM #ACCOUNT_ALL A INNER JOIN #ACCOUNT_ALWAYS_STD B ON A.RefCustomerID=B.RefCustomerID
				INNER JOIN PRO.CUSTOMERCAL C ON A.RefCustomerID=C.RefCustomerID
				WHERE A.COUNT_ALL=B.COUNT_STD
				AND C.SysAssetClassAlt_Key IS NULL
/*ADDED BY ZAIN AND BALA ON LOCAL AS PER OBSERVATION RAISED BY PRAVIN ON 20250321 END*/
			/*FOR CUSTOMER HAVING ONLY ALWAYS STANDARD ACCOUNT AS ON DATE AND PREVIOULSY NPA OR WRITE OF ACCOUNTS ARE CLOSED 
				THEN CUSTOMER UPGRADE FLAG SHOLUD BE 'Y' IN CUSTOMER CAL CLASSIFICATION SHOULD BE 
													END											*/

		
	END
			
END 
GO