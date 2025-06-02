SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



--/*=========================================
-- AUTHER : AMAR YADAV
-- CREATE DATE : 23-10-2023
-- MODIFY DATE : 
-- DESCRIPTION :MARKING COBORROWER AS NPA
-- =============================================*/
 

CREATE PROCEDURE [pro].[COBORROWER_DEG_UPG_MARKINGfinalbackup]
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
			SELECT B.RefCustomerID,a.SourceSystemCustomerID, a.UCIF_ID,PANNO
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
						)
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
				,DegReason='Percolation by Finnone Primary Borrower PAN_' + Isnull(B.PANNO,'') + '/FCR Cust ID '+ isnull(B.RefCustomerID,'') + '/UCIC '+ isnull(A.UCIF_ID,'')
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
				,DegReason='Percolation by Finnone Primary Borrower PAN_' + Isnull(B.PANNO,'') + '/FCR Cust ID '+ isnull(B.RefCustomerID,'') + '/UCIC '+ isnull(A.UCIF_ID,'')
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
			--DECLARE @SUB_Months INT =(SELECT RefValue FROM PRO.refperiod WHERE BusinessRule='SUB_Months' AND  EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
			--DECLARE @DB1_Months INT =(SELECT RefValue FROM PRO.refperiod WHERE BusinessRule='DB1_Months' AND  EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
			--DECLARE @DB2_Months INT =(SELECT RefValue FROM PRO.refperiod WHERE BusinessRule='DB2_Months' AND  EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)


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
				,B.NPA_Reason=A.DegReason
			 FROM PRO.CustomerCal A INNER JOIN PRO.AccountCal B ON A.RefCustomerID=B.RefCustomerID
			WHERE b.Asset_Norm<>'ALWYS_STD' 

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

	END
IF @FLG_UPG_DEG='U'
	BEGIN
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
				WHERE  c.RefCustomerId is null AND A.FlgDeg='Y'


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
					on d.RefCustomerID=C.RefCustomerID
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


		
		UPDATE C	
			SET C.FlgUpg='N',c.UpgDate=null
		 --select Distinct c.RefCustomerID
		  from PRO.CoBorrowerDetails a
			inner join PRO.CUSTOMERCAL b
				on  (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
				AND A.RefCustomerID=B.RefCustomerID
				AND B.FlgUpg='N'
			INNER JOIN PRO.CoBorrowerDetails C
				ON A.CoBorrowerID=C.RefCustomerID
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
				ON A.Co_APPLICANT_UCIC=C.APPLICANT_UCIC
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
					AND A.RefCustomerID=b.RefCustomerID
					INNER JOIN PRO.ACCOUNTCAL C ON B.RefCustomerID=C.RefCustomerID

				WHERE ISNULL(B.FlgUpg,'N')='N' AND A.FlgUpg='U'
				AND (B.FlgProcessing='N')
			AND C.Asset_Norm NOT IN ('ALWYS_NPA','ALWYS_STD')
			AND  ISNULL(B.MocStatusMark,'N')='N' 
			AND  ISNULL(C.AccountStatus,'N')<>'Z' 
			AND ISNULL(C.BankAssetClasS,'N')<>'WRITEOFF'

			
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

				
		
	END
			
END 
GO