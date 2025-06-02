SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO





/*=========================================
 AUTHER : SANJEEV KUMAR SHARMA
 CREATE DATE : 18-11-2017
 MODIFY DATE : 02-11-2018
 DESCRIPTION : MARKING OF FLGDEG AND DEG REASON 
 --EXEC [Pro].[Marking_FlgDeg_Degreason] @TIMEKEY=25140
=============================================*/
CREATE PROCEDURE [pro].[Marking_FlgDeg_Degreason]
@TIMEKEY INT
AS
BEGIN
  SET NOCOUNT ON 
   BEGIN TRY
DECLARE @PROCESSDATE DATE=(SELECT DATE FROM SYSDAYMATRIX WHERE TimeKey=@TIMEKEY)

/*---------------INTIAL LEVEL FLG DEG SET N------------------------------------------*/

UPDATE A SET A.FLGDEG='N'
FROM PRO.AccountCal A INNER JOIN PRO.CustomerCal B ON A.RefCustomerID =B.RefCustomerID
WHERE (isnull(B.FlgProcessing,'N')='N')

/*---------------UPDATE DEG FLAG AT CUSTOMER LEVEL------------------------------------*/

UPDATE B SET B.FlgDeg='N' FROM PRO.ACCOUNTCAL A INNER JOIN  PRO.CustomerCal B 
ON A.RefCustomerID=B.RefCustomerID
WHERE  (isnull(B.FlgProcessing,'N')='N')

/*---------------UPDATE DEG FLAG AT ACCOUNT LEVEL-----------------------------------------*/
UPDATE A SET A.FLGDEG  =(CASE WHEN  ISNULL(A.DPD_INTSERVICE,0)>=A.REFPERIODINTSERVICE  THEN 'Y' 
							WHEN   ISNULL(A.DPD_OVERDRAWN,0)>=A.REFPERIODOVERDRAWN    THEN 'Y' 
							WHEN   ISNULL(A.DPD_NOCREDIT,0)>=A.REFPERIODNOCREDIT      THEN 'Y'
                            WHEN   ISNULL(A.DPD_OVERDUE,0) >=A.REFPERIODOVERDUE       THEN 'Y' 
                            WHEN   ISNULL(A.DPD_STOCKSTMT,0)>=A.REFPERIODSTKSTATEMENT THEN 'Y' 
							WHEN   ISNULL(A.DPD_RENEWAL,0)>=A.REFPERIODREVIEW         THEN 'Y'
						ELSE 'N'  END)
FROM PRO.ACCOUNTCAL A   INNER JOIN PRO.CustomerCal B ON A.RefCustomerID =B.RefCustomerID
WHERE  (a.FinalAssetClassAlt_Key IN(SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortNameEnum IN('STD') and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY))
AND (ISNULL(A.Asset_Norm,'NORMAL')<>'ALWYS_STD') 
AND (B.FlgProcessing='N')
AND ISNULL(InMonthMark,'N')='Y'
AND ISNULL(B.FlgMoc,'N')='N' AND ISNULL(A.Balance,0)>0

---New Condition---
UPDATE A SET A.FLGDEG  =(CASE WHEN  ISNULL(A.DPD_INTSERVICE,0)>=A.REFPERIODINTSERVICE  THEN 'Y' 
							WHEN   ISNULL(A.DPD_OVERDRAWN,0)>=A.REFPERIODOVERDRAWN    THEN 'Y' 
							WHEN   ISNULL(A.DPD_NOCREDIT,0)>=A.REFPERIODNOCREDIT      THEN 'Y'
                            WHEN   ISNULL(A.DPD_OVERDUE,0) >=A.REFPERIODOVERDUE       THEN 'Y' 
                            WHEN   ISNULL(A.DPD_STOCKSTMT,0)>=A.REFPERIODSTKSTATEMENT THEN 'Y' 
							WHEN   ISNULL(A.DPD_RENEWAL,0)>=A.REFPERIODREVIEW         THEN 'Y'
						ELSE 'N'  END)
FROM PRO.ACCOUNTCAL A   INNER JOIN PRO.CustomerCal B ON A.SourceSystemCustomerID =B.SourceSystemCustomerID
WHERE  (a.FinalAssetClassAlt_Key IN(SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortNameEnum IN('STD') and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY))
AND (ISNULL(A.Asset_Norm,'NORMAL')<>'ALWYS_STD') 
AND (B.FlgProcessing='N')
AND ISNULL(InMonthMark,'N')='Y'
AND ISNULL(B.FlgMoc,'N')='N' AND ISNULL(A.Balance,0)>0


/*---------------EXCLUDE VISION PLUS ACCOUNT FROM FRESH SILLAPGE WHERE BALANCE LESS THEN EQUAL TO 200 THROUGH SELF PROCESSING------------------------*/


---As per Bank Mail New Condition 13/05/2022 commit Below Condition---
----UPDATE A SET  FLGDEG='N'
----FROM PRO.ACCOUNTCAL A   INNER JOIN PRO.CustomerCal B ON A.SourceSystemCustomerID =B.SourceSystemCustomerID
---- INNER JOIN DimSourceDB C ON A.SourceAlt_Key=C.SourceAlt_Key
----  AND (C.EffectiveFromTimeKey<=@TIMEKEY AND C.EffectiveToTimeKey >=@TIMEKEY)
----WHERE  (A.FinalAssetClassAlt_Key IN(SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortNameEnum IN('STD') and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY))
----AND (ISNULL(A.Asset_Norm,'NORMAL')<>'ALWYS_STD') 
----AND (B.FlgProcessing='N')
----AND ISNULL(InMonthMark,'N')='Y'
----AND ISNULL(B.FlgMoc,'N')='N'
----AND C.SOURCENAME='VISIONPLUS' AND A.FINALASSETCLASSALT_KEY=1  AND ( ISNULL(A.BALANCE,0)<=200 OR  ISNULL(A.CD,0)<5 )

UPDATE A SET  FLGDEG='N'
FROM PRO.ACCOUNTCAL A   INNER JOIN PRO.CustomerCal B ON A.SourceSystemCustomerID =B.SourceSystemCustomerID
 INNER JOIN DimSourceDB C ON A.SourceAlt_Key=C.SourceAlt_Key
  AND (C.EffectiveFromTimeKey<=@TIMEKEY AND C.EffectiveToTimeKey >=@TIMEKEY)
WHERE  (A.FinalAssetClassAlt_Key IN(SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortNameEnum IN('STD') and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY))
AND (ISNULL(A.Asset_Norm,'NORMAL')<>'ALWYS_STD') 
AND (B.FlgProcessing='N')
AND ISNULL(InMonthMark,'N')='Y'
AND ISNULL(B.FlgMoc,'N')='N'
AND C.SOURCENAME='VISIONPLUS' and A.FLGDEG='Y'

UPDATE A SET A.FLGDEG  = (CASE WHEN  ISNULL(A.DPD_INTSERVICE,0)>=A.REFPERIODINTSERVICE  THEN 'Y' 
							WHEN   ISNULL(A.DPD_OVERDRAWN,0)>=A.REFPERIODOVERDRAWN    THEN 'Y' 
							WHEN   ISNULL(A.DPD_NOCREDIT,0)>=A.REFPERIODNOCREDIT      THEN 'Y'
                            WHEN   ISNULL(A.DPD_OVERDUE,0) >=A.REFPERIODOVERDUE       THEN 'Y' 
                            WHEN   ISNULL(A.DPD_STOCKSTMT,0)>=A.REFPERIODSTKSTATEMENT THEN 'Y' 
							WHEN   ISNULL(A.DPD_RENEWAL,0)>=A.REFPERIODREVIEW         THEN 'Y'
						ELSE 'N'  END)
FROM PRO.ACCOUNTCAL A   INNER JOIN PRO.CustomerCal B ON A.SourceSystemCustomerID =B.SourceSystemCustomerID
 INNER JOIN DimSourceDB C ON A.SourceAlt_Key=C.SourceAlt_Key
  AND (C.EffectiveFromTimeKey<=@TIMEKEY AND C.EffectiveToTimeKey >=@TIMEKEY)
WHERE  (A.FinalAssetClassAlt_Key IN(SELECT AssetClassAlt_Key 
FROM DimAssetClass WHERE AssetClassShortNameEnum IN('STD')
 and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY))
AND (ISNULL(A.Asset_Norm,'NORMAL')<>'ALWYS_STD') 
AND (B.FlgProcessing='N')
AND ISNULL(InMonthMark,'N')='Y'
AND ISNULL(B.FlgMoc,'N')='N'
AND C.SOURCENAME='VISIONPLUS' --and ISNULL(A.DPD_Max,0)>=91
AND A.AccountStatus IN('A','D')

/*FOR OTS CR ADDED BY ZAIN  ON LOCAL 20250213*/

UPDATE A SET A.FLGDEG  ='Y',A.DegReason=CASE WHEN DATEDIFF(MONTH,A.OTS_Settlement_Date,@PROCESSDATE)<3 
												THEN A.DegReason + ' DEGRADED BY OTS FOR ACCOUNT' +' '+C.SourceName+' '+A.CustomerAcID
												ELSE A.DegReason + ' DEGRADED BY OTS_R FOR ACCOUNT' +' '+C.SourceName+' '+A.CustomerAcID
											END
							,A.OTS_STATUS=CASE WHEN DATEDIFF(MONTH,A.OTS_Settlement_Date,@PROCESSDATE)<3 
												THEN 'NULL'
												ELSE 'Y'
											END
FROM PRO.ACCOUNTCAL A   INNER JOIN PRO.CustomerCal B ON A.RefCustomerID =B.RefCustomerID
						INNER JOIN DimSourceDB C ON A.SourceAlt_Key=C.SourceAlt_Key
WHERE  (a.FinalAssetClassAlt_Key IN(SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortNameEnum IN('STD') and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY))
AND (ISNULL(A.Asset_Norm,'NORMAL')<>'ALWYS_STD') 
AND (B.FlgProcessing='N')
AND ISNULL(InMonthMark,'N')='Y'
AND ISNULL(B.FlgMoc,'N')='N' 
--AND ISNULL(A.Balance,0)>0
AND B.SourceAlt_Key IN (3,4)
AND A.OTS_Settlement_Flag='Y'
AND A.EFFECTIVEFROMTIMEKEY<=@TIMEKEY
AND A.EFFECTIVETOTIMEKEY>=@TIMEKEY

/*FOR OTS CR ADDED BY ZAIN  ON LOCAL 20250213 END*/




/*---------------EXCLUDE WRITE OF PRODUCT IN CASE OF FCC SOURCE  FROM FRESH SILLAPGE MAIL DATED 29/01/2019 BY Pramod Shetty OSD------------------------*/

UPDATE A SET  FLGDEG='N'
FROM PRO.ACCOUNTCAL A   INNER JOIN PRO.CustomerCal B ON A.SourceSystemCustomerID =B.SourceSystemCustomerID
 INNER JOIN DimSourceDB C ON A.SourceAlt_Key=C.SourceAlt_Key  AND (C.EffectiveFromTimeKey<=49999 AND C.EffectiveToTimeKey >=49999)
 INNER JOIN DimProduct D ON D.ProductAlt_Key=A.ProductAlt_Key  AND (D.EffectiveFromTimeKey<=49999 AND D.EffectiveToTimeKey >=49999)
 WHERE  (A.FinalAssetClassAlt_Key IN(SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortNameEnum IN('STD') and EffectiveFromTimeKey<=49999 AND EffectiveToTimeKey>=49999))
AND (ISNULL(A.Asset_Norm,'NORMAL')<>'ALWYS_STD') 
AND (B.FlgProcessing='N')
AND ISNULL(InMonthMark,'N')='Y'
AND ISNULL(B.FlgMoc,'N')='N'
AND C.SourceName='FCC' AND A.FinalAssetClassAlt_Key=1 
 AND D.SrcSysProductName='FCC' and D.ProductName like '%write%'

 /*---------------EXCLUDE CA - NPV SUBV HL and CA - NPV SUBV AFHL OF PRODUCT IN CASE OF FCR SOURCE  FROM FRESH SILLAPGE -----------------------*/

UPDATE A SET  FLGDEG='N'
FROM PRO.ACCOUNTCAL A   INNER JOIN PRO.CustomerCal B ON A.SourceSystemCustomerID =B.SourceSystemCustomerID
 INNER JOIN DimSourceDB C ON A.SourceAlt_Key=C.SourceAlt_Key  AND (C.EffectiveFromTimeKey<=49999 AND C.EffectiveToTimeKey >=49999)
 INNER JOIN DimProduct D ON D.ProductAlt_Key=A.ProductAlt_Key  AND (D.EffectiveFromTimeKey<=49999 AND D.EffectiveToTimeKey >=49999)
 WHERE  (A.FinalAssetClassAlt_Key IN(SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortNameEnum IN('STD') and EffectiveFromTimeKey<=49999 AND EffectiveToTimeKey>=49999))
AND (ISNULL(A.Asset_Norm,'NORMAL')<>'ALWYS_STD') 
AND (B.FlgProcessing='N')
AND ISNULL(InMonthMark,'N')='Y'
AND ISNULL(B.FlgMoc,'N')='N'
AND C.SourceName='FCR' AND A.FinalAssetClassAlt_Key=1 
 AND D.SrcSysProductName='FCR' and  D.ProductCode in ('729','727')


 /* ------------------------UPDATE DEG FLAG AT CUSTOMER LEVEL----------------------------------*/

UPDATE B SET B.FlgDeg='Y' FROM PRO.ACCOUNTCAL A INNER JOIN  PRO.CustomerCal B 
ON A.RefCustomerID=B.RefCustomerID
WHERE A.FlgDeg='Y' AND (B.FlgProcessing='N')

---New Condition---
UPDATE B SET B.FlgDeg='Y' FROM PRO.ACCOUNTCAL A INNER JOIN  PRO.CustomerCal B 
ON A.SourceSystemCustomerID=B.SourceSystemCustomerID
WHERE A.FlgDeg='Y' AND (B.FlgProcessing='N')

--------------Covid-19 Implementation on 03July2020-----------------------------


----IF OBJECT_ID('TEMPDB..#COVID19BaseDataSourceENpaUCIF_ID') IS NOT NULL
----      DROP TABLE #COVID19BaseDataSourceENpaUCIF_ID
----select DISTINCT UCIF_ID
----INTO #COVID19BaseDataSourceENpaUCIF_ID
---- from  pro.ACCOUNTCAL
---- where FLGDEG='Y' AND UCIF_ID IS NOT NULL


 
---- UPDATE A SET SplCatg3Alt_Key=0,asset_norm='NORMAL',DegReason=NULL  FROM pro.ACCOUNTCAL A
---- INNER JOIN #COVID19BaseDataSourceENpaUCIF_ID B ON A.UCIF_ID=B.UCIF_ID
---- WHERE  A.SplCatg3Alt_Key=127 AND asset_norm='ALWYS_STD'


----IF OBJECT_ID('TEMPDB..#COVID19BaseDataSourceENpaRefCustomerID') IS NOT NULL
----      DROP TABLE #COVID19BaseDataSourceENpaRefCustomerID
----select DISTINCT RefCustomerID 
----INTO #COVID19BaseDataSourceENpaRefCustomerID
---- from  pro.ACCOUNTCAL
---- where FLGDEG='Y' AND RefCustomerID Is NOT NULL


 
---- UPDATE A SET SplCatg3Alt_Key=0,asset_norm='NORMAL',DegReason=NULL   FROM pro.ACCOUNTCAL A
---- INNER JOIN #COVID19BaseDataSourceENpaRefCustomerID B ON A.RefCustomerID=B.RefCustomerID 
---- WHERE  A.SplCatg3Alt_Key=127 AND asset_norm='ALWYS_STD'



----IF OBJECT_ID('TEMPDB..#COVID19BaseDataSourceENpaSourceSystemCustomerID') IS NOT NULL
----      DROP TABLE #COVID19BaseDataSourceENpaSourceSystemCustomerID
----select DISTINCT SourceSystemCustomerId 
----INTO #COVID19BaseDataSourceENpaSourceSystemCustomerID
---- from  pro.ACCOUNTCAL
---- where FLGDEG='Y' AND SourceSystemCustomerID Is NOT NULL


 
---- UPDATE A SET SplCatg3Alt_Key=0,asset_norm='NORMAL',DegReason=NULL  FROM pro.ACCOUNTCAL A
---- INNER JOIN #COVID19BaseDataSourceENpaSourceSystemCustomerID B ON A.SourceSystemCustomerID=B.SourceSystemCustomerID 
---- WHERE  A.SplCatg3Alt_Key=127 AND asset_norm='ALWYS_STD'




---- IF OBJECT_ID('TEMPDB..#COVID19BaseDataSourceENpaUCIF_IDPan') IS NOT NULL
----      DROP TABLE #COVID19BaseDataSourceENpaUCIF_IDPan
----select DISTINCT UCIF_ID
----INTO #COVID19BaseDataSourceENpaUCIF_IDPan
---- from  pro.customercal
---- where FLGDEG='Y' AND UCIF_ID IS NOT NULL and PANNO is NOT  null

 
---- UPDATE A SET SplCatg3Alt_Key=0,asset_norm='NORMAL',DegReason=NULL   FROM pro.ACCOUNTCAL A
---- INNER JOIN #COVID19BaseDataSourceENpaUCIF_IDPan B ON A.UCIF_ID=B.UCIF_ID
---- WHERE  A.SplCatg3Alt_Key=127 AND asset_norm='ALWYS_STD'



---- IF OBJECT_ID('TEMPDB..#COVID19BaseDataSourceENpasOURCESYSTEM_IDPan') IS NOT NULL
----      DROP TABLE #COVID19BaseDataSourceENpasOURCESYSTEM_IDPan
----select DISTINCT SourceSystemCustomerID
----INTO #COVID19BaseDataSourceENpasOURCESYSTEM_IDPan
---- from  pro.customercal
---- where FLGDEG='Y' AND SourceSystemCustomerID IS NOT NULL and PANNO is NOT  null

 
---- UPDATE A SET SplCatg3Alt_Key=0,asset_norm='NORMAL',DegReason=NULL   FROM pro.ACCOUNTCAL A
---- INNER JOIN #COVID19BaseDataSourceENpasOURCESYSTEM_IDPan B ON A.SourceSystemCustomerID=B.SourceSystemCustomerID
---- WHERE  A.SplCatg3Alt_Key=127 AND asset_norm='ALWYS_STD'


----  IF OBJECT_ID('TEMPDB..#COVID19BaseDataSourceENpaRefCustomerIDPan') IS NOT NULL
----      DROP TABLE #COVID19BaseDataSourceENpaRefCustomerIDPan
----select DISTINCT RefCustomerID
----INTO #COVID19BaseDataSourceENpaRefCustomerIDPan
---- from  pro.customercal
---- where FLGDEG='Y' AND RefCustomerID IS NOT NULL and PANNO is NOT  null

 
---- UPDATE A SET SplCatg3Alt_Key=0,asset_norm='NORMAL',DegReason=NULL   FROM pro.ACCOUNTCAL A
---- INNER JOIN #COVID19BaseDataSourceENpaRefCustomerIDPan B ON A.RefCustomerID=B.RefCustomerID
---- WHERE  A.SplCatg3Alt_Key=127 AND asset_norm='ALWYS_STD'

---- IF OBJECT_ID('TEMPDB..#COVID19BaseDataSourceENpaUCIF_IDbankassetcalss') IS NOT NULL
----      DROP TABLE #COVID19BaseDataSourceENpaUCIF_IDbankassetcalss
----select DISTINCT UCIF_ID
----INTO #COVID19BaseDataSourceENpaUCIF_IDbankassetcalss
---- from  pro.customercal
---- where FLGDEG='Y' AND UCIF_ID IS NOT NULL and BANKASSETCLASS='WRITEOFF'

 
---- UPDATE A SET SplCatg3Alt_Key=0,asset_norm='NORMAL',DegReason=NULL   FROM pro.ACCOUNTCAL A
---- INNER JOIN #COVID19BaseDataSourceENpaUCIF_IDbankassetcalss B ON A.UCIF_ID=B.UCIF_ID
---- WHERE  A.SplCatg3Alt_Key=127 AND asset_norm='ALWYS_STD'



---- IF OBJECT_ID('TEMPDB..#COVID19BaseDataSourceENpasOURCESYSTEM_IDbankassetcalss') IS NOT NULL
----      DROP TABLE #COVID19BaseDataSourceENpasOURCESYSTEM_IDbankassetcalss
----select DISTINCT SourceSystemCustomerID
----INTO #COVID19BaseDataSourceENpasOURCESYSTEM_IDbankassetcalss
---- from  pro.customercal
---- where FLGDEG='Y' AND SourceSystemCustomerID IS NOT NULL and BANKASSETCLASS='WRITEOFF'

 
---- UPDATE A SET SplCatg3Alt_Key=0,asset_norm='NORMAL',DegReason=NULL   FROM pro.ACCOUNTCAL A
---- INNER JOIN #COVID19BaseDataSourceENpasOURCESYSTEM_IDbankassetcalss B ON A.SourceSystemCustomerID=B.SourceSystemCustomerID
---- WHERE  A.SplCatg3Alt_Key=127 AND asset_norm='ALWYS_STD'


----  IF OBJECT_ID('TEMPDB..#COVID19BaseDataSourceENpaRefCustomerIDbankassetcalss') IS NOT NULL
----      DROP TABLE #COVID19BaseDataSourceENpaRefCustomerIDbankassetcalss
----select DISTINCT RefCustomerID
----INTO #COVID19BaseDataSourceENpaRefCustomerIDbankassetcalss
---- from  pro.customercal
---- where FLGDEG='Y' AND RefCustomerID IS NOT NULL and BANKASSETCLASS='WRITEOFF'

 
---- UPDATE A SET SplCatg3Alt_Key=0,asset_norm='NORMAL',DegReason=NULL   FROM pro.ACCOUNTCAL A
---- INNER JOIN #COVID19BaseDataSourceENpaRefCustomerIDbankassetcalss B ON A.RefCustomerID=B.RefCustomerID
---- WHERE  A.SplCatg3Alt_Key=127 AND asset_norm='ALWYS_STD'



 --------------End Covid-19 Implementation on 03July2020-----------------------------

 /*---------------------ASSIGNE NPA REASON------------------------------------------------------*/
--UPDATE  A SET A.DEGREASON=NULL 
--FROM PRO.AccountCal A INNER JOIN PRO.CustomerCal B ON A.RefCustomerID =B.RefCustomerID
--WHERE (B.FlgProcessing='N')


UPDATE A SET A.DEGREASON= ISNULL(A.DEGREASON,'')+'DEGRADE BY INT NOT SERVICED'  
FROM PRO.AccountCal A INNER JOIN PRO.CustomerCal B ON A.RefCustomerID =B.RefCustomerID
WHERE (B.FlgProcessing='N')  AND (A.FLGDEG='Y' AND (A.DPD_INTSERVICE>=A.REFPERIODINTSERVICE))
 
UPDATE A SET A.DEGREASON= ISNULL(A.DEGREASON,'')+', DEGRADE BY CONTI EXCESS'
FROM PRO.AccountCal A INNER JOIN PRO.CustomerCal B ON A.RefCustomerID =B.RefCustomerID
WHERE (B.FlgProcessing='N')  AND (A.FLGDEG='Y' AND A.DPD_OVERDRAWN>=A.REFPERIODOVERDRAWN) 

UPDATE A SET DEGREASON= ISNULL(A.DEGREASON,'')+', DEGRADE BY NO CREDIT'      
FROM PRO.AccountCal A INNER JOIN PRO.CustomerCal B ON A.RefCustomerID =B.RefCustomerID
WHERE (B.FlgProcessing='N')  AND (A.FLGDEG='Y' AND A.DPD_NOCREDIT>=A.REFPERIODNOCREDIT ) 

UPDATE A SET DEGREASON= ISNULL(A.DEGREASON,'')+', DEGRADE BY STOCK STATEMENT'    
FROM PRO.AccountCal A INNER JOIN PRO.CustomerCal B ON A.RefCustomerID =B.RefCustomerID
WHERE (B.FlgProcessing='N')  AND (A.FLGDEG='Y' AND A.DPD_STOCKSTMT>=A.REFPERIODSTKSTATEMENT) 

UPDATE A SET A.DEGREASON= ISNULL(A.DEGREASON,'')+', DEGRADE BY REVIEW DUE DATE'    
FROM PRO.AccountCal A INNER JOIN PRO.CustomerCal B ON A.RefCustomerID =B.RefCustomerID
WHERE (B.FlgProcessing='N')  AND (A.FLGDEG='Y' AND A.DPD_RENEWAL>=A.REFPERIODREVIEW) 

UPDATE A SET A.DEGREASON= ISNULL(A.DEGREASON,'')+', DEGRADE BY OVERDUE'            
FROM PRO.AccountCal A INNER JOIN PRO.CustomerCal B ON A.RefCustomerID =B.RefCustomerID
WHERE (B.FlgProcessing='N')  AND (A.FLGDEG='Y' AND A.DPD_OVERDUE >=A.REFPERIODOVERDUE)

---New Condition---

UPDATE A SET A.DEGREASON= ISNULL(A.DEGREASON,'')+'DEGRADE BY INT NOT SERVICED'  
FROM PRO.AccountCal A INNER JOIN PRO.CustomerCal B ON A.SourceSystemCustomerID =B.SourceSystemCustomerID
WHERE (B.FlgProcessing='N')  AND (A.FLGDEG='Y' AND (A.DPD_INTSERVICE>=A.REFPERIODINTSERVICE))
 and A.DEGREASON is null
 
UPDATE A SET A.DEGREASON= ISNULL(A.DEGREASON,'')+', DEGRADE BY CONTI EXCESS'
FROM PRO.AccountCal A INNER JOIN PRO.CustomerCal B ON A.SourceSystemCustomerID =B.SourceSystemCustomerID
WHERE (B.FlgProcessing='N')  AND (A.FLGDEG='Y' AND A.DPD_OVERDRAWN>=A.REFPERIODOVERDRAWN) 
and A.DEGREASON is null
UPDATE A SET DEGREASON= ISNULL(A.DEGREASON,'')+', DEGRADE BY NO CREDIT'      
FROM PRO.AccountCal A INNER JOIN PRO.CustomerCal B ON A.SourceSystemCustomerID =B.SourceSystemCustomerID
WHERE (B.FlgProcessing='N')  AND (A.FLGDEG='Y' AND A.DPD_NOCREDIT>=A.REFPERIODNOCREDIT ) 
and A.DEGREASON is null
UPDATE A SET DEGREASON= ISNULL(A.DEGREASON,'')+', DEGRADE BY STOCK STATEMENT'    
FROM PRO.AccountCal A INNER JOIN PRO.CustomerCal B ON A.SourceSystemCustomerID =B.SourceSystemCustomerID
WHERE (B.FlgProcessing='N')  AND (A.FLGDEG='Y' AND A.DPD_STOCKSTMT>=A.REFPERIODSTKSTATEMENT) 
and A.DEGREASON is null
UPDATE A SET A.DEGREASON= ISNULL(A.DEGREASON,'')+', DEGRADE BY REVIEW DUE DATE'    
FROM PRO.AccountCal A INNER JOIN PRO.CustomerCal B ON A.SourceSystemCustomerID =B.SourceSystemCustomerID
WHERE (B.FlgProcessing='N')  AND (A.FLGDEG='Y' AND A.DPD_RENEWAL>=A.REFPERIODREVIEW) 
and A.DEGREASON is null
UPDATE A SET A.DEGREASON= ISNULL(A.DEGREASON,'')+', DEGRADE BY OVERDUE'            
FROM PRO.AccountCal A INNER JOIN PRO.CustomerCal B ON A.SourceSystemCustomerID =B.SourceSystemCustomerID
WHERE (B.FlgProcessing='N')  AND (A.FLGDEG='Y' AND A.DPD_OVERDUE >=A.REFPERIODOVERDUE)
and A.DEGREASON is null


UPDATE A SET A.DEGREASON= ISNULL(A.DEGREASON,'')+', DEGRADE BY LCBG ACCOUNT'            
FROM PRO.AccountCal A INNER JOIN PRO.CustomerCal B ON A.RefCustomerID =B.RefCustomerID
WHERE (B.FlgProcessing='N')  AND (A.FLGDEG='Y' AND A.FLGLCBG='Y' AND A.DPD_OVERDUE >=A.REFPERIODOVERDUE)

UPDATE A SET A.DEGREASON= 'DEGRADE BY DEBIT BALANCE'            
FROM PRO.AccountCal A INNER JOIN PRO.CustomerCal B ON A.RefCustomerID =B.RefCustomerID
INNER JOIN DimProduct C ON  A.ProductAlt_Key=C.ProductAlt_Key AND (C.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey)
WHERE (B.FlgProcessing='N')  AND (A.FLGDEG='Y' AND A.DPD_OVERDUE >=A.REFPERIODOVERDUE)
AND A.DebitSinceDt IS NOT NULL AND ISNULL(C.SrcSysProductCode,'N')='SAVING'

/* ADDED FOR OTS ON 20250213 BY ZAIN*/
UPDATE A SET A.DEGREASON= A.DEGREASON + ' DEGRADE BY OTS FOR ACCOUNT' + D.SourceName +' '+A.CustomerAcID
FROM PRO.AccountCal A INNER JOIN PRO.CustomerCal B ON A.RefCustomerID =B.RefCustomerID
INNER JOIN DimProduct C ON  A.ProductAlt_Key=C.ProductAlt_Key AND (C.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey)
INNER JOIN DimSourceDB D ON A.SourceAlt_Key=D.SourceAlt_Key AND (D.EffectiveFromTimeKey<=@TimeKey AND D.EffectiveToTimeKey>=@TimeKey)
WHERE (B.FlgProcessing='N')  AND (A.FLGDEG='Y' AND A.OTS_Settlement_Flag='Y')
AND A.SourceAlt_Key IN (3,4)
/* ADDED FOR OTS ON 20250213 BY ZAIN END*/


 UPDATE A SET DEGREASON=B.DEGREASON
 FROM PRO.AccountCal A INNER JOIN PRO.CustomerCal B ON A.SourceSystemCustomerID =B.SourceSystemCustomerID
WHERE (B.FlgProcessing='N')  AND (A.FLGDEG='N')AND B.DegReason IS NOT NULL AND A.FinalAssetClassAlt_Key>1 AND A.DegReason IS NULL

--Changed by Triloki 28-01-22 /30-11-2022 for Quarter End
  
IF (	 (MONTH(@PROCESSDATE) IN(3,12) AND DAY(@PROCESSDATE)=31)
	  OR (MONTH(@PROCESSDATE) IN(6,9)  AND DAY(@PROCESSDATE)=30)
	)
BEGIN

UPDATE A SET A.DEGREASON= ISNULL(A.DEGREASON,'')+', DEGRADE BY EROSION'            
FROM PRO.AccountCal A INNER JOIN PRO.CustomerCal B ON A.CustomerEntityID =B.CustomerEntityID
WHERE b.FlgErosion='Y' and A.DEGREASON not like '%EROSION%'


UPDATE B SET B.DEGREASON= ISNULL(B.DEGREASON,'')+', DEGRADE BY EROSION'            
FROM PRO.AccountCal A INNER JOIN PRO.CustomerCal B ON A.CustomerEntityID =B.CustomerEntityID
WHERE b.FlgErosion='Y'  and B.DEGREASON not like '%EROSION%'

End

	UPDATE PRO.ACLRUNNINGPROCESSSTATUS 
	SET COMPLETED='Y',ERRORDATE=NULL,ERRORDESCRIPTION=NULL,COUNT=ISNULL(COUNT,0)+1
	WHERE RUNNINGPROCESSNAME='Marking_FlgDeg_Degreason'

END TRY
BEGIN  CATCH

	UPDATE PRO.ACLRUNNINGPROCESSSTATUS 
	SET COMPLETED='N',ERRORDATE=GETDATE(),ERRORDESCRIPTION=ERROR_MESSAGE(),COUNT=ISNULL(COUNT,0)+1
	WHERE RUNNINGPROCESSNAME='Marking_FlgDeg_Degreason'

END CATCH
SET NOCOUNT OFF
END








GO