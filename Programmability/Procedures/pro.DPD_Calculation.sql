SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/*=========================================
 AUTHER : TRILOKI KHANNA
 CREATE DATE : 18-11-2017
 MODIFY DATE : 22-07-2022
 DESCRIPTION : CALCULATION OF DPD
 --Exec  [Pro].[DPD_Calculation]  @timekey=25140
=============================================*/
CREATE PROCEDURE [pro].[DPD_Calculation]
@TIMEKEY INT
with recompile
AS
BEGIN
  SET NOCOUNT ON
     BEGIN TRY

DECLARE @PROCESSDATE DATE =(SELECT Date FROM SysDayMatrix where TimeKey=@TIMEKEY)

UPDATE PRO.AccountCal SET IntNotServicedDt  = NULL   WHERE (IntNotServicedDt='1900-01-01' OR IntNotServicedDt='01/01/1900') 
UPDATE PRO.AccountCal SET LastCrDate        = NULL   WHERE (LastCrDate='1900-01-01' OR LastCrDate='01/01/1900') 
UPDATE PRO.AccountCal SET ContiExcessDt     = NULL   WHERE (ContiExcessDt='1900-01-01' OR ContiExcessDt='01/01/1900') 
UPDATE PRO.AccountCal SET OverDueSinceDt    = NULL   WHERE (OverDueSinceDt='1900-01-01' OR OverDueSinceDt='01/01/1900') 
UPDATE PRO.AccountCal SET ReviewDueDt       = NULL   WHERE (ReviewDueDt='1900-01-01' OR ReviewDueDt='01/01/1900') 
UPDATE PRO.AccountCal SET StockStDt         = NULL   WHERE (StockStDt='1900-01-01' OR StockStDt='01/01/1900') 
UPDATE PRO.AccountCal SET OTS_Settlement_Date         = NULL   WHERE (OTS_Settlement_Date='1900-01-01' OR OTS_Settlement_Date='01/01/1900') /*FOR OTS CR ADDED BY ZAIN  ON LOCAL 20250213*/


/*------------------INITIAL ALL DPD 0 FOR RE-PROCESSING------------------------------- */

UPDATE A SET A.DPD_IntService=0,A.DPD_NoCredit=0,A.DPD_Overdrawn=0,A.DPD_Overdue=0,A.DPD_Renewal=0,
             A.DPD_StockStmt=0,A.DPD_OTS=0/*FOR OTS CR ADDED BY ZAIN  ON LOCAL 20250213*/
FROM PRO.AccountCal A
-- INNER JOIN PRO.CustomerCal B ON A.RefCustomerID =B.RefCustomerID
---WHERE (B.FlgProcessing='N') 


/*---------- CALCULATED ALL DPD---------------------------------------------------------*/

UPDATE A SET  
          --A.DPD_IntService =(CASE WHEN  A.IntNotServicedDt IS NOT NULL THEN DATEDIFF(DAY,A.IntNotServicedDt,@PROCESSDATE)  ELSE 0 end)
             A.DPD_IntService = (CASE WHEN  A.IntNotServicedDt IS NOT NULL THEN DATEDIFF(DAY,A.IntNotServicedDt,@ProcessDate) + 1 ELSE 0 END)--  As per Bank Mail Dated 21/07/2022 condition modify By Triloki Add 1 Day
             ,A.DPD_NoCredit =  (CASE WHEN  A.LastCrDate IS NOT NULL      THEN DATEDIFF(DAY,A.LastCrDate,  @PROCESSDATE)       ELSE 0 END)
	     ,A.DPD_Overdrawn= (CASE WHEN   A.ContiExcessDt IS NOT NULL    THEN DATEDIFF(DAY,A.ContiExcessDt,  @PROCESSDATE) + 1  ELSE 0 END)     --  1.01 BDTS_Business_Case_ENPA_DPD_Correction condition modify By Triloki Add 1 Day
	     ,A.DPD_Overdue =   (CASE WHEN  A.OverDueSinceDt IS NOT NULL   THEN  DATEDIFF(DAY,A.OverDueSinceDt,  @PROCESSDATE) + 1 ELSE 0 END)    -- 1.01 BDTS_Business_Case_ENPA_DPD_Correction condition modify By Triloki Add 1 Day
	     ,A.DPD_Renewal =   (CASE WHEN  A.ReviewDueDt IS NOT NULL      THEN DATEDIFF(DAY,A.ReviewDueDt, @PROCESSDATE)  + 1     ELSE 0 END)    -- 1.01 BDTS_Business_Case_ENPA_DPD_Correction condition modify By Triloki Add 1 Day
	    ,A.DPD_StockStmt= (CASE WHEN  A.StockStDt IS NOT NULL         THEN   DATEDIFF(DAY,A.StockStDt,@PROCESSDATE)  + 1      ELSE 0 END)      --  1.01 BDTS_Business_Case_ENPA_DPD_Correction modify By Triloki Add 1 Day
FROM PRO.AccountCal A where SourceAlt_Key not in (3,4,10,11) --FOR SFIN AccountData_FinSmart 15102023
--INNER JOIN PRO.CustomerCal B ON A.RefCustomerID =B.RefCustomerID
--WHERE isnull(B.FlgProcessing,'N')='N'  
--and isnull(A.AccountStatus,'N')<>'Z' 


UPDATE A SET  
          --A.DPD_IntService =(CASE WHEN  A.IntNotServicedDt IS NOT NULL THEN DATEDIFF(DAY,A.IntNotServicedDt,@PROCESSDATE)  ELSE 0 end)
             A.DPD_IntService = (CASE WHEN  A.IntNotServicedDt IS NOT NULL THEN DATEDIFF(DAY,A.IntNotServicedDt,@ProcessDate) ELSE 0 END)--  As per Bank Mail Dated 21/07/2022 condition modify By Triloki Add 1 Day
             ,A.DPD_NoCredit =  (CASE WHEN  A.LastCrDate IS NOT NULL      THEN DATEDIFF(DAY,A.LastCrDate,  @PROCESSDATE)       ELSE 0 END)
	     ,A.DPD_Overdrawn= (CASE WHEN   A.ContiExcessDt IS NOT NULL    THEN DATEDIFF(DAY,A.ContiExcessDt,  @PROCESSDATE)  ELSE 0 END)     --  1.01 BDTS_Business_Case_ENPA_DPD_Correction condition modify By Triloki Add 1 Day
	     ,A.DPD_Overdue =   (CASE WHEN  A.OverDueSinceDt IS NOT NULL   THEN  DATEDIFF(DAY,A.OverDueSinceDt,  @PROCESSDATE)  ELSE 0 END)    -- 1.01 BDTS_Business_Case_ENPA_DPD_Correction condition modify By Triloki Add 1 Day
	     ,A.DPD_Renewal =   (CASE WHEN  A.ReviewDueDt IS NOT NULL      THEN DATEDIFF(DAY,A.ReviewDueDt, @PROCESSDATE)      ELSE 0 END)    -- 1.01 BDTS_Business_Case_ENPA_DPD_Correction condition modify By Triloki Add 1 Day
	    ,A.DPD_StockStmt= (CASE WHEN  A.StockStDt IS NOT NULL         THEN   DATEDIFF(DAY,A.StockStDt,@PROCESSDATE)       ELSE 0 END)      --  1.01 BDTS_Business_Case_ENPA_DPD_Correction modify By Triloki Add 1 Day
FROM PRO.AccountCal A where SourceAlt_Key  in (3,4,10,11)--FOR SFIN AccountData_FinSmart 15102023


/*FOR OTS CR ADDED BY ZAIN  ON LOCAL 20250213*/
		UPDATE A SET A.DPD_OTS=(CASE WHEN  A.OTS_Settlement_Flag ='Y' THEN DATEDIFF(DAY,A.OTS_Settlement_Date,@PROCESSDATE) + 1 ELSE 0 END)
			FROM PRO.AccountCal A 
		where SourceAlt_Key  in (3,4)
			AND A.OTS_Settlement_Flag ='Y'
			AND A.EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
/*FOR OTS CR ADDED BY ZAIN  ON LOCAL 20250213 END*/

/*FOR DCCO CR ADDED BY ZAIN  ON LOCAL 20250303*/
		UPDATE A SET A.DPD_DCCO=(CASE WHEN (DATEDIFF(DAY,A.FIN_DCCO_DATE,@PROCESSDATE)+1)>0 THEN DATEDIFF(DAY,A.FIN_DCCO_DATE,@PROCESSDATE)+1 ELSE 0 END)
			FROM PRO.AccountCal A 
		where A.FIN_DCCO_DATE IS NOT NULL
			AND A.EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
			
/*FOR DCCO CR ADDED BY ZAIN  ON LOCAL 20250303 END*/

UPDATE A SET DPD_Overdue= isnull((CASE WHEN  A.DebitSinceDt IS NOT NULL   THEN  DATEDIFF(DAY,A.DebitSinceDt,  @PROCESSDATE)+1 ELSE 0 END),0)
FROM PRO.AccountCal A
INNER JOIN DimProduct B ON  A.ProductAlt_Key=B.ProductAlt_Key AND (B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey)
WHERE DebitSinceDt IS NOT NULL AND ISNULL(SrcSysProductCode,'N')='SAVING'

--UPDATE A SET DPD_Overdrawn= isnull((CASE WHEN  A.ContiExcessDt IS NOT NULL   THEN  DATEDIFF(DAY,A.ContiExcessDt,  @PROCESSDATE) ELSE 0 END),0)+1
--FROM PRO.AccountCal A
--WHERE ContiExcessDt IS NOT NULL 
-------------------ECBF DPD increase by 1 day as per user observation Ashish Pathak 21-05-2019-------------
UPDATE A SET DPD_Overdue= isnull((CASE WHEN  A.OverDueSinceDt IS NOT NULL   THEN  DATEDIFF(DAY,A.OverDueSinceDt,  @PROCESSDATE) ELSE 0 END),0)+1 --1 AS PER BANK MAIL CONDITION CHANGED 23/03/2022
FROM PRO.AccountCal A
WHERE OverDueSinceDt IS NOT NULL and SourceAlt_Key = 5

/*--------------IF ANY DPD IS NEGATIVE THEN ZERO---------------------------------*/

 UPDATE PRO.AccountCal SET DPD_IntService=0 WHERE isnull(DPD_IntService,0)<0
 UPDATE PRO.AccountCal SET DPD_NoCredit=0 WHERE isnull(DPD_NoCredit,0)<0
 UPDATE PRO.AccountCal SET DPD_Overdrawn=0 WHERE isnull(DPD_Overdrawn,0)<0
 UPDATE PRO.AccountCal SET DPD_Overdue=0 WHERE isnull(DPD_Overdue,0)<0
 UPDATE PRO.AccountCal SET DPD_Renewal=0 WHERE isnull(DPD_Renewal,0)<0
 UPDATE PRO.AccountCal SET DPD_StockStmt=0 WHERE isnull(DPD_StockStmt,0)<0
 UPDATE PRO.AccountCal SET DPD_OTS=0 WHERE isnull(DPD_OTS,0)<0 /*FOR OTS CR ADDED BY ZAIN  ON LOCAL 20250213 END*/
 UPDATE PRO.AccountCal SET DPD_DCCO=0 WHERE isnull(DPD_DCCO,0)<0 /*FOR DCCO CR ADDED BY ZAIN  ON LOCAL 20250303 END*/

/*------------DPD IS ZERO FOR ALL CC ACCOUNT DUE TO LASTCRDATE ------------------------------------*/

UPDATE A SET DPD_NoCredit=0
FROM PRO.AccountCal A INNER JOIN PRO.CustomerCal B ON A.RefCustomerID =B.RefCustomerID
WHERE isnull(B.FlgProcessing,'N')='N' 


/*------------DPD IS ZERO FOR  PRODUCT CODE 605 AND 869 EXCLUDE ONLY FOR OUT OF ORDER  ------------------------------------*/

UPDATE A SET DPD_IntService=0,IntNotServicedDt=NULL   FROM PRO.ACCOUNTCAL  A  INNER JOIN DIMPRODUCT B ON A.PRODUCTALT_KEY=B.PRODUCTALT_KEY
  AND (B.EffectiveFromTimeKey<=@TIMEKEY AND B.EffectiveToTimeKey >=@TIMEKEY)  WHERE B.PRODUCTCODE IN ('605','869')

/*------------DPD IS ZERO FOR  LINE CODE 2940D EXCLUDE ONLY FOR OUT OF ORDER  ------------------------------------*/
--UPDATE A SET DPD_IntService=0,IntNotServicedDt=NULL   FROM PRO.ACCOUNTCAL  A WHERE SUBSTRING(LineCode,1,5)='294OD'

 /*------------DPD IS ZERO FOR  BACKED BY FD ACCOUNT  EXCLUDE ONLY FOR OUT OF ORDER  ------------------------------------*/
--UPDATE A SET DPD_IntService=0,IntNotServicedDt=NULL   FROM PRO.ACCOUNTCAL  A INNER JOIN YBL_ACS_MIS..ODS_FCR_CH_OD_LIMIT B
-- ON A.CustomerAcID=B.Cod_acct_no  WHERE B.flg_internal_fd='Y'
 

 ---As per Bank Mail New Condition 13/05/2022 Commit below condition ---
 ----UPDATE  A SET OverDueSinceDt=@PROCESSDATE,DPD_Overdue=1,FlgDirtyRow='Y'
	----	 from pro.accountcal A where sourcealt_key=4
	----	 AND (ACCOUNTBLKCODE1 ='A' 	AND CD IN (2,3,4) AND ISNULL(ACCOUNTSTATUS,'N')<>'Z')
	----	AND InitialAssetClassAlt_Key>1	AND ISNULL(DPD_Overdue,0)=0



--------------Covid-19 Implementation on 03July2020-----------------------------


----		IF OBJECT_ID('TEMPDB..#COVID19BaseDataSourceENpaSTD') IS NOT NULL
----      DROP TABLE #COVID19BaseDataSourceENpaSTD
----select CustomerEntityId,FinalAssetClassAlt_Key as Cust_AssetClassAlt_Key,FinalNpaDt as NPADt,RefCustomerID,EffectiveFromTimeKey,EffectiveToTimeKey,DegReason as NPA_Reason,SourceSystemCustomerID
----,'Y' AS Exclusion
----INTO #COVID19BaseDataSourceENpaSTD
---- from  pro.ACCOUNTCAL
---- where FinalAssetClassAlt_Key=1
----order by CustomerEntityId





----IF OBJECT_ID('TEMPDB..#ProductCodeExclusion') IS NOT NULL
----      DROP TABLE #ProductCodeExclusion

----select 
----AccountEntityID,UcifEntityID,	CustomerEntityID	,CustomerAcID	,RefCustomerID	,SourceSystemCustomerID	,
----UCIF_ID	,BranchCode ,DPD_Max, InitialNpaDt,	FinalNpaDt ,InitialAssetClassAlt_Key,	FinalAssetClassAlt_Key ,ProductCode,SourceAlt_Key,'N' AS Exclusion
----INTO #ProductCodeExclusion
----from  pro.accountcal 
----where  Productcode in ('BM08','BM17','SLC5','SLC6','GM06')


----UPDATE A SET Exclusion=B.Exclusion
----FROM #COVID19BaseDataSourceENpaSTD A
----INNER JOIN #ProductCodeExclusion B
----ON A.SourceSystemCustomerID=B.SourceSystemCustomerID


----IF OBJECT_ID('TEMPDB..#BranchCodeExclusion') IS NOT NULL
----      DROP TABLE #BranchCodeExclusion

----select 
----AccountEntityID,UcifEntityID,	CustomerEntityID	,CustomerAcID	,RefCustomerID	,SourceSystemCustomerID	,
----UCIF_ID	,BranchCode ,DPD_Max, InitialNpaDt,	FinalNpaDt ,InitialAssetClassAlt_Key,	FinalAssetClassAlt_Key ,ProductCode,A.SourceAlt_Key,'N' AS Exclusion
----INTO #BranchCodeExclusion
----from  pro.accountcal  A
----INNER JOIN DimSourceDB B
----ON A.SourceAlt_Key=B.SourceAlt_Key
----where  BranchCode='801'  AND A.SourceAlt_Key=2


----UPDATE A SET Exclusion=B.Exclusion
----FROM #COVID19BaseDataSourceENpaSTD A
----INNER JOIN #BranchCodeExclusion B
----ON A.SourceSystemCustomerID=B.SourceSystemCustomerID



----IF OBJECT_ID('TEMPDB..#MurexExclusion') IS NOT NULL
----      DROP TABLE #MurexExclusion

----select 
----AccountEntityID,UcifEntityID,	CustomerEntityID	,CustomerAcID	,RefCustomerID	,SourceSystemCustomerID	,
----UCIF_ID	,BranchCode ,DPD_Max, InitialNpaDt,	FinalNpaDt ,InitialAssetClassAlt_Key,	FinalAssetClassAlt_Key ,ProductCode,A.SourceAlt_Key,'N' AS Exclusion
----INTO #MurexExclusion
----from  pro.accountcal  A
----INNER JOIN DimSourceDB B ON A.SourceAlt_Key=B.SourceAlt_Key
----where A.SourceAlt_Key=7


----UPDATE A SET Exclusion=B.Exclusion
----FROM #COVID19BaseDataSourceENpaSTD A
----INNER JOIN #MurexExclusion B
----ON A.SourceSystemCustomerID=B.SourceSystemCustomerID




----IF OBJECT_ID('TEMPDB..#TreasuryProductCodeExclusion') IS NOT NULL
----      DROP TABLE #TreasuryProductCodeExclusion

----select 
----AccountEntityID,UcifEntityID,	CustomerEntityID	,CustomerAcID	,RefCustomerID	,SourceSystemCustomerID	,
----UCIF_ID	,BranchCode ,DPD_Max, InitialNpaDt,	FinalNpaDt ,InitialAssetClassAlt_Key,	FinalAssetClassAlt_Key ,ProductCode,SourceAlt_Key,'N' AS Exclusion
----INTO #TreasuryProductCodeExclusion
----from  pro.accountcal 
----where  Productcode in ('NSLR','NSLI','NSLB','TREC' )


----UPDATE A SET Exclusion=B.Exclusion
----FROM #COVID19BaseDataSourceENpaSTD A
----INNER JOIN #TreasuryProductCodeExclusion B
----ON A.SourceSystemCustomerID=B.SourceSystemCustomerID





----IF OBJECT_ID('TEMPDB..#StockStatementExclusion') IS NOT NULL
----      DROP TABLE #StockStatementExclusion

----select 
----AccountEntityID,UcifEntityID,	CustomerEntityID	,A.CustomerAcID	,a.RefCustomerID	,SourceSystemCustomerID	,
----UCIF_ID	,BranchCode ,DPD_Max, InitialNpaDt,	FinalNpaDt ,InitialAssetClassAlt_Key,	FinalAssetClassAlt_Key ,ProductCode,A.SourceAlt_Key,'N' AS Exclusion
----INTO #StockStatementExclusion
----from  pro.accountcal  A 
----inner join [DATAUPLOAD].[STOCKSTATEMENTDATAUPLOAD]  c 
----on a.REFCUSTOMERID=c.CustomerID
----INNER JOIN DimSourceDB B ON A.SourceAlt_Key=B.SourceAlt_Key
----where c.EffectiveToTimeKey=49999
----AND A.STOCKSTDT IS NOT NULL-- AND FINALASSETCLASSALT_KEY>1


----UPDATE A SET Exclusion=B.Exclusion
----FROM #COVID19BaseDataSourceENpaSTD A
----INNER JOIN #StockStatementExclusion B
----ON A.SourceSystemCustomerID=B.SourceSystemCustomerID




----IF OBJECT_ID('TEMPDB..#REVIEWExclusion') IS NOT NULL
----      DROP TABLE #REVIEWExclusion

----select 
----AccountEntityID,UcifEntityID,	CustomerEntityID	,a.CustomerAcID	,a.RefCustomerID	,SourceSystemCustomerID	,
----UCIF_ID	,BranchCode ,DPD_Max, InitialNpaDt,	FinalNpaDt ,InitialAssetClassAlt_Key,	FinalAssetClassAlt_Key ,ProductCode,A.SourceAlt_Key,'N' AS Exclusion
----INTO #REVIEWExclusion
----from  pro.accountcal  A 
----inner join [DATAUPLOAD].[REVIEWRENEWALDATAUPLOAD]  c 
----on a.REFCUSTOMERID=c.CustomerID
----INNER JOIN DimSourceDB B ON A.SourceAlt_Key=B.SourceAlt_Key
----where c.EffectiveToTimeKey=49999
----and a.REVIEWDUEDT is not null --and FinalAssetClassAlt_Key>1


----UPDATE A SET Exclusion=B.Exclusion
----FROM #COVID19BaseDataSourceENpaSTD A
----INNER JOIN #REVIEWExclusion B
----ON A.SourceSystemCustomerID=B.SourceSystemCustomerID


----IF OBJECT_ID('TEMPDB..#WriteOffBANKASSETCLASSCodeExclusion') IS NOT NULL
----      DROP TABLE #WriteOffBANKASSETCLASSCodeExclusion

----select 
----AccountEntityID,UcifEntityID,	CustomerEntityID	,CustomerAcID	,RefCustomerID	,SourceSystemCustomerID	,
----UCIF_ID	,BranchCode ,DPD_Max, InitialNpaDt,	FinalNpaDt ,InitialAssetClassAlt_Key,	FinalAssetClassAlt_Key ,ProductCode,SourceAlt_Key,'N' AS Exclusion
----INTO #WriteOffBANKASSETCLASSCodeExclusion
----from  pro.accountcal 
----where  BANKASSETCLASS='WRITEOFF' 


----UPDATE A SET Exclusion=B.Exclusion
----FROM #COVID19BaseDataSourceENpaSTD A
----INNER JOIN #WriteOffBANKASSETCLASSCodeExclusion B
----ON A.SourceSystemCustomerID=B.SourceSystemCustomerID


----IF OBJECT_ID('TEMPDB..#MOCCUSTOMERExclusion') IS NOT NULL
----      DROP TABLE #MOCCUSTOMERExclusion

----select 
----AccountEntityID,UcifEntityID,	CustomerEntityID	,A.CustomerAcID	,a.RefCustomerID	,A.SourceSystemCustomerID	,
----UCIF_ID	,BranchCode ,DPD_Max, InitialNpaDt,	FinalNpaDt ,InitialAssetClassAlt_Key,	FinalAssetClassAlt_Key ,ProductCode,A.SourceAlt_Key,'N' AS Exclusion
----INTO #MOCCUSTOMERExclusion
----from  pro.accountcal A 
----inner join [DATAUPLOAD].MOCCUSTOMERDATAUPLOAD  c 
----on a.REFCUSTOMERID=c.CustomerID
----where c.EffectiveToTimeKey=49999
----AND C.DateCreated>'2020-07-01'

----UPDATE A SET Exclusion=B.Exclusion
----FROM #MOCCUSTOMERExclusion A
----INNER JOIN #WriteOffBANKASSETCLASSCodeExclusion B
----ON A.SourceSystemCustomerID=B.SourceSystemCustomerID



----update A  SET FinalAssetClassAlt_Key=1,SplCatg3Alt_Key=127,FinalNpaDt=NULL,DegReason='NOT DEGERADE DUE TO COVID',Asset_Norm='ALWYS_STD'
----from pro.AccountCal a 
----inner join #COVID19BaseDataSourceENpaSTD b on a.SourceSystemCustomerID =b.SourceSystemCustomerID
----where b.Exclusion='Y'


----UPDATE B SET FinalAssetClassAlt_Key=2,SplCatg3Alt_Key=0,DegReason=NULL,Asset_Norm='NORMAL',FinalNpaDt=A.FinalNpaDt   ----Add FinalNpaDt on 16-July-2020
----FROM #WriteOffBANKASSETCLASSCodeExclusion A
----INNER JOIN pro.AccountCal B
----ON A.REFCUSTOMERID=B.REFCUSTOMERID
----WHERE B.SplCatg3Alt_Key=127

----UPDATE B SET SysAssetClassAlt_Key=2,SplCatg3Alt_Key=0,DegReason=NULL,Asset_Norm='NORMAL',SysNPA_Dt=A.FinalNpaDt   ----Add SysNPA_Dt on 16-July-2020
----FROM #WriteOffBANKASSETCLASSCodeExclusion A
----INNER JOIN pro.CUSTOMERCAL B
----ON A.REFCUSTOMERID=B.REFCUSTOMERID
----WHERE B.SplCatg3Alt_Key=127



--------------End Covid-19 Implementation on 03July2020-----------------------------

		 /*------------DPD IS ZERO And Final Asset class is NPA then mark account as ALWAYS NPA TO AVOID UPGRADE AS PER BANK MAIL 12-06-2020------------------------------------*/
/* Start >> Murex account upgrade issue >> changes by Triloki/Vishal >> 14/07/2021 */ 
/*
 UPDATE A SET Asset_Norm='ALWYS_NPA'
from pro.AccountCal A
where InitialAssetClassAlt_Key>1
 and ( isnull(DPD_IntService,0)<=REFPERIODINTSERVICEUPG
       AND isnull(DPD_NoCredit,0)<=REFPERIODNOCREDITUPG
	   AND isnull(DPD_Overdrawn,0)<=REFPERIODOVERDRAWNUPG
	   AND isnull(DPD_Overdue,0)<=REFPERIODOVERDUEUPG
	   AND isnull(DPD_Renewal,0)<=	REFPERIODREVIEWUPG
	   AND isnull(DPD_StockStmt,0)<=REFPERIODSTKSTATEMENTUPG
	 ) 
	 and isnull(BankAssetClass,'') <> 'WRITEOFF' and isnull(Asset_Norm,'') <>'ALWYS_NPA'
*/	 
/* End >> Murex account upgrade issue >> changes by Triloki/Vishal >> 14/07/2021 */	 

-----Covid Phase-II----

----As per mail Below Condition Comment Triloki Khanna ---21072022----
------UPDATE A SET 
------ADJUSTED_DPD_CONTIEXCESSDT=DPD_OVERDRAWN
------,ADJUSTED_DPD_STOCKSTDT=DPD_STOCKSTMT
------,ADJUSTED_DPD_REVIEWDUEDT=DPD_RENEWAL
------,ADJUSTED_DPD_INTNOTSERVICEDDT=DPD_INTSERVICE
------,ADJUSTED_DPD_OVERDUESINCEDT=DPD_OVERDUE
------FROM YBL_ACS.DBO.DPD_MORATORIUM_ADJUSTED A
------INNER JOIN PRO.ACCOUNTCAL B
------ON A.ACCOUNTENTITYID=B.ACCOUNTENTITYID

----As per mail Below Condition Comment Triloki Khanna ---21072022----

----delete from  DPD_Moratorium_Adjusted_Hist where TimeKey=@TimeKey

----insert into DPD_Moratorium_Adjusted_Hist

----(
---- BranchCode
----,UCIF_ID
----,UcifEntityID
----,RefCustomerID
----,SourceSystemCustomerID
----,CustomerAcID
----,AccountEntityID
----,SourceAlt_Key
----,FacilityType
----,Frozen_ContiExcessDt
----,Actual_ContiExcessDt
----,Adjusted_ContiExcessDt
----,Frozen_DPD_ContiExcessDt
----,Actual_DPD_ContiExcessDt
----,Adjusted_DPD_ContiExcessDt
----,Frozen_StockStDt
----,Actual_StockStDt
----,Adjusted_StockStDt
----,Frozen_DPD_StockStDt
----,Actual_DPD_StockStDt
----,Adjusted_DPD_StockStDt
----,Frozen_ReviewDueDt
----,Actual_ReviewDueDt
----,Adjusted_ReviewDueDt
----,Frozen_DPD_ReviewDueDt
----,Actual_DPD_ReviewDueDt
----,Adjusted_DPD_ReviewDueDt
----,Frozen_IntNotServicedDt
----,Actual_IntNotServicedDt
----,Adjusted_IntNotServicedDt
----,Frozen_DPD_IntNotServicedDt
----,Actual_DPD_IntNotServicedDt
----,Adjusted_DPD_IntNotServicedDt
----,Frozen_OverDueSinceDt
----,Actual_OverDueSinceDt
----,Adjusted_OverDueSinceDt
----,Frozen_DPD_OverDueSinceDt
----,Actual_DPD_OverDueSinceDt
----,Adjusted_DPD_OverDueSinceDt
----,Exclusion
----,TimeKey
----,FinalAssetClassAlt_Key
----)

----SELECT 
----BranchCode
----,UCIF_ID
----,UcifEntityID
----,RefCustomerID
----,SourceSystemCustomerID
----,CustomerAcID
----,AccountEntityID
----,SourceAlt_Key
----,FacilityType
----,Frozen_ContiExcessDt
----,Actual_ContiExcessDt
----,Adjusted_ContiExcessDt
----,Frozen_DPD_ContiExcessDt
----,Actual_DPD_ContiExcessDt
----,Adjusted_DPD_ContiExcessDt
----,Frozen_StockStDt
----,Actual_StockStDt
----,Adjusted_StockStDt
----,Frozen_DPD_StockStDt
----,Actual_DPD_StockStDt
----,Adjusted_DPD_StockStDt
----,Frozen_ReviewDueDt
----,Actual_ReviewDueDt
----,Adjusted_ReviewDueDt
----,Frozen_DPD_ReviewDueDt
----,Actual_DPD_ReviewDueDt
----,Adjusted_DPD_ReviewDueDt
----,Frozen_IntNotServicedDt
----,Actual_IntNotServicedDt
----,Adjusted_IntNotServicedDt
----,Frozen_DPD_IntNotServicedDt
----,Actual_DPD_IntNotServicedDt
----,Adjusted_DPD_IntNotServicedDt
----,Frozen_OverDueSinceDt
----,Actual_OverDueSinceDt
----,Adjusted_OverDueSinceDt
----,Frozen_DPD_OverDueSinceDt
----,Actual_DPD_OverDueSinceDt
----,Adjusted_DPD_OverDueSinceDt
----,Exclusion
----,TimeKey
----,FinalAssetClassAlt_Key
---- FROM DPD_Moratorium_Adjusted

------Covid Phase II end---------


UPDATE PRO.ACLRUNNINGPROCESSSTATUS 
	SET COMPLETED='Y',ERRORDATE=NULL,ERRORDESCRIPTION=NULL,COUNT=ISNULL(COUNT,0)+1
	WHERE RUNNINGPROCESSNAME='DPD_Calculation'

 
END TRY
BEGIN  CATCH
	
	UPDATE PRO.ACLRUNNINGPROCESSSTATUS 
	SET COMPLETED='N',ERRORDATE=GETDATE(),ERRORDESCRIPTION=ERROR_MESSAGE(),COUNT=ISNULL(COUNT,0)+1
	WHERE RUNNINGPROCESSNAME='DPD_Calculation'
END CATCH
  SET NOCOUNT OFF
END













GO