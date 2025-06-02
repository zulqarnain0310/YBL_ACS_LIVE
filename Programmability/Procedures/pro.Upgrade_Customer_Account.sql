SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO







/*=========================================
 AUTHER : SANJEEV KUMAR SHARMA
 CREATE DATE : 18-11-2017
 MODIFY DATE : 08-04-2021
 DESCRIPTION : FIRST UPGRADE TO CUSTOMER LEVEL  AFTER THAT ACCOUNT LEVEL
=============================================*/
CREATE PROCEDURE [pro].[Upgrade_Customer_Account]
@TIMEKEY INT
WITH RECOMPILE
AS
BEGIN
  SET NOCOUNT ON
   BEGIN TRY --444560
   
/*check the customer when all account to cutomer dpdmax must be 0*/
--declare @timekey int =27482
DECLARE @PROCESSDATE DATE=(SELECT Date FROM SysDayMatrix WHERE TimeKey=@TIMEKEY)

IF OBJECT_ID('TEMPDB.dbo.#CUSTOMERCALWrong') IS NOT NULL
  DROP TABLE #CUSTOMERCALWrong

select * into #CUSTOMERCALWrong FROM PRO.Customercal  

IF OBJECT_ID('TEMPDB.dbo.#accountcalWrong') IS NOT NULL
  DROP TABLE #accountcalWrong

select * into #accountcalWrong FROM PRO.accountcal


UPDATE PRO.ACCOUNTCAL SET FLGUPG='N'
UPDATE PRO.CUSTOMERCAL SET FLGUPG='N'


--/*--------MOC CUSTOMER NOT UPGRADED ACCOUNT---------*/
--UPDATE A SET A.MocStatusMark='Y' FROM   PRO.CustomerCal A inner join  PreMoc.CustomerCal B  ON A.CustomerEntityID=B.CustomerEntityID
--WHERE  B.EffectiveFromTimeKey<=@TIMEKEY AND B.EffectiveToTimeKey>=@TIMEKEY
--AND B.MocStatusMark='Y'



--IF OBJECT_ID('TEMPDB..#TEMPTABLE') IS NOT NULL
--      DROP TABLE #TEMPTABLE

--SELECT A.RefCustomerID,TOTALCOUNT  INTO #TEMPTABLE FROM 
--(
--SELECT A.RefCustomerID,COUNT(1) TOTALCOUNT FROM PRO.CUSTOMERCAL A INNER JOIN PRO.ACCOUNTCAL B ON A.RefCustomerID=B.RefCustomerID 
--WHERE (A.FlgProcessing='N' )
--GROUP BY A.RefCustomerID
--)
--A INNER JOIN 
--(
--SELECT A.RefCustomerID,COUNT(1) TOTALDPD_MAXCOUNT FROM PRO.CUSTOMERCAL A INNER JOIN PRO.ACCOUNTCAL B ON A.RefCustomerID=B.RefCustomerID
--WHERE (B.DPD_INTSERVICE<=B.REFPERIODINTSERVICEUPG
--   and B.DPD_NOCREDIT <=B.REFPERIODNOCREDITUPG
--   and B.DPD_OVERDRAWN <=B.REFPERIODOVERDRAWNUPG
--   and B.DPD_OVERDUE<=B.REFPERIODOVERDUEUPG
--   and B.DPD_RENEWAL<=B.REFPERIODREVIEWUPG
--   and B.DPD_STOCKSTMT <=B.REFPERIODSTKSTATEMENTUPG)
--   and B.InitialAssetClassAlt_Key not in(1)
--AND (A.FlgProcessing='N')
--AND B.Asset_Norm NOT IN ('ALWYS_NPA','ALWYS_STD')
--AND  ISNULL(A.MocStatusMark,'N')='N' 
--AND  ISNULL(B.AccountStatus,'N')<>'Z' 

----AND A.RefCustomerID NOT IN  /*----FOR AdvCustStressedAssetDetail ACCOUNT------ */
----(
----SELECT CustomerEntityID FROM  AdvCustStressedAssetDetail
----WHERE EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
----)
----AND A.CustomerEntityID NOT IN  /*---FOR RESTRUCTURE ACCOUNT ----*/
----(
----SELECT CustomerEntityID FROM  CurDat.AdvAcRestructureDetail A INNER JOIN PRO.AccountCal B ON A.AccountEntityId=B.AccountEntityID
----WHERE  DATEADD(YEAR,1,A.RestructureDt)>@PROCESSDATE  
---- AND B.InitialAssetClassAlt_Key<>1
----)
--GROUP BY A.RefCustomerID

--) B ON A.RefCustomerID=B.RefCustomerID AND A.TOTALCOUNT=B.TOTALDPD_MAXCOUNT





--  /*------ UPGRADING CUSTOMER-----------*/


--UPDATE A SET A.FlgUpg='U'
--FROM PRO.CUSTOMERCAL A INNER JOIN #TEMPTABLE B ON A.RefCustomerID=B.RefCustomerID
-- INNER JOIN DIMASSETCLASS C ON C.AssetClassAlt_Key=A.SYSASSETCLASSALT_KEY AND (C.EffectiveFromTimeKey<=@TIMEKEY AND C.EffectiveToTimeKey>=@TIMEKEY)
--WHERE  (not(isnull(A.ASSET_NORM,'NORMAL')='ALWYS_NPA' ) AND  C.ASSETCLASSGROUP ='NPA' AND not(ISNULL(A.FLGDEG,'N')='Y')) AND (ISNULL(A.FlgProcessing,'N')='N')



--UPDATE   PRO.CustomerCal SET SysNPA_Dt=NULL,
--							 DbtDt=NULL,
--							 LossDt=NULL,
--							 ErosionDt=NULL,
--							 FlgErosion='N',
--							 SysAssetClassAlt_Key=1
--							 ,FlgDeg='N'
--WHERE FlgUpg='U'


--/*--------MARKING UPGRADED ACCOUNT --------------*/

--UPDATE B SET  B.UpgDate=@PROCESSDATE
--             ,B.DegReason=NULL
--			 ,B.FinalAssetClassAlt_Key=1
--			 ,B.FlgDeg='N'
--			 ,B.FinalNpaDt=null
--             ,b.FlgUpg='U'

--FROM PRO.CUSTOMERCAL A INNER JOIN PRO.ACCOUNTCAL B ON A.RefCustomerID=B.RefCustomerID
--WHERE  ISNULL(A.FlgUpg,'U')='U' AND (ISNULL(A.FlgProcessing,'N')='N')

IF OBJECT_ID('TEMPDB..#TEMPTABLE') IS NOT NULL
      DROP TABLE #TEMPTABLE

SELECT A.UCIF_ID,TOTALCOUNT  INTO #TEMPTABLE FROM 
(
SELECT A.UCIF_ID,COUNT(1) TOTALCOUNT FROM PRO.CUSTOMERCAL A INNER JOIN PRO.ACCOUNTCAL B ON A.UCIF_ID=B.UCIF_ID 
WHERE (A.FlgProcessing='N' ) AND A.UCIF_ID IS NOT NULL
--AND A.UCIF_ID<>'0'
GROUP BY A.UCIF_ID
)
A INNER JOIN 
(
SELECT A.UCIF_ID,COUNT(1) TOTALDPD_MAXCOUNT FROM PRO.CUSTOMERCAL A INNER JOIN PRO.ACCOUNTCAL B ON A.UCIF_ID=B.UCIF_ID
WHERE (B.DPD_INTSERVICE<=B.REFPERIODINTSERVICEUPG
 --  AND B.DPD_NOCREDIT <=B.REFPERIODNOCREDITUPG
   AND B.DPD_OVERDRAWN <=B.REFPERIODOVERDRAWNUPG
   AND B.DPD_OVERDUE<=B.REFPERIODOVERDUEUPG
   AND B.DPD_RENEWAL<=B.REFPERIODREVIEWUPG
   AND B.DPD_STOCKSTMT <=B.REFPERIODSTKSTATEMENTUPG)
   AND ISNULL(B.OTS_SETTLEMENT_FLAG,'N') ='N'/*FOR OTS CR ADDED BY ZAIN  ON LOCAL 20250213 END*/
   AND (DATEDIFF(DAY,ISNULL(B.FIN_DCCO_DATE,'2099-12-31'),@PROCESSDATE)<=0 AND ISNULL(CAST(B.UTILISATION AS DECIMAL(18,2)),0)<=0)/*FOR DCCO CR ADDED BY ZAIN  ON LOCAL 20250303 END*/
   AND B.INITIALASSETCLASSALT_KEY NOT IN(1)
AND (A.FlgProcessing='N')
AND B.Asset_Norm NOT IN ('ALWYS_NPA','ALWYS_STD')
AND  ISNULL(A.MocStatusMark,'N')='N' 
AND  ISNULL(B.AccountStatus,'N')<>'Z' 
AND ISNULL(B.BankAssetClasS,'N')<>'WRITEOFF'
AND A.UCIF_ID IS NOT NULL
--AND A.UCIF_ID<>'0'
GROUP BY A.UCIF_ID

) B ON A.UCIF_ID=B.UCIF_ID AND A.TOTALCOUNT=B.TOTALDPD_MAXCOUNT





  /*------ UPGRADING CUSTOMER-----------*/


UPDATE A SET A.FlgUpg='U'
FROM PRO.CUSTOMERCAL A INNER JOIN #TEMPTABLE B ON A.UCIF_ID=B.UCIF_ID
 INNER JOIN DIMASSETCLASS C ON C.AssetClassAlt_Key=A.SYSASSETCLASSALT_KEY AND (C.EffectiveFromTimeKey<=@TIMEKEY AND C.EffectiveToTimeKey>=@TIMEKEY)
WHERE  (not(isnull(A.ASSET_NORM,'NORMAL')='ALWYS_NPA' ) AND  C.ASSETCLASSGROUP ='NPA' AND not(ISNULL(A.FLGDEG,'N')='Y')) AND (ISNULL(A.FlgProcessing,'N')='N')



IF OBJECT_ID('TEMPDB..#TEMPTABLE1') IS NOT NULL
      DROP TABLE #TEMPTABLE1

SELECT A.UCIF_ID,TOTALCOUNT  INTO #TEMPTABLE1 FROM 
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



/*UPGRADING CUSTOMER FOR DCCO*/

			UPDATE C SET C.FlgUpg='U'
			FROM YBL_ACS.DBO.DCCO_MAIN A INNER JOIN YBL_ACS_MIS.DBO.DCCO_STG B ON A.UCIC=B.UCIC
				INNER JOIN PRO.CUSTOMERCAL C ON A.UCIC=B.UCIC
				WHERE (ISNULL(A.Final_DCCO,'')<>ISNULL(B.Final_DCCO,'')
						)
						AND B.Final_DCCO>@PROCESSDATE--'2025-06-04'--@PROCESSDATE
						AND A.Final_DCCO<@PROCESSDATE--'2025-06-04'
						AND A.EFFECTIVEFROMTIMEKEY=@TIMEKEY-1--27480-1
						AND A.EFFECTIVETOTIMEKEY=49999--27480-1
						AND ISNULL(C.FlgDeg,'')<>'Y'
/*UPGRADING CUSTOMER FOR DCCO END*/

  /*------ UPGRADING CUSTOMER-----------*/


UPDATE A SET A.FlgUpg='U'
FROM PRO.CUSTOMERCAL A INNER JOIN #TEMPTABLE1 B ON A.UCIF_ID=B.UCIF_ID
 INNER JOIN DIMASSETCLASS C ON C.AssetClassAlt_Key=A.SYSASSETCLASSALT_KEY AND (C.EffectiveFromTimeKey<=@TIMEKEY AND C.EffectiveToTimeKey>=@TIMEKEY)
WHERE  (not(isnull(A.ASSET_NORM,'NORMAL')='ALWYS_NPA' ) AND  C.ASSETCLASSGROUP ='NPA' AND not(ISNULL(A.FLGDEG,'N')='Y')) AND (ISNULL(A.FlgProcessing,'N')='N')



IF OBJECT_ID('TEMPDB..#TEMPTABLERefCustomerID') IS NOT NULL
      DROP TABLE #TEMPTABLERefCustomerID

SELECT A.RefCustomerID,TOTALCOUNT  INTO #TEMPTABLERefCustomerID FROM 
(
SELECT A.RefCustomerID,COUNT(1) TOTALCOUNT FROM PRO.CUSTOMERCAL A INNER JOIN PRO.ACCOUNTCAL B ON A.RefCustomerID=B.RefCustomerID 
WHERE (A.FlgProcessing='N' ) AND A.UCIF_ID IS  NULL 
 and A.RefCustomerID is not null
--AND A.UCIF_ID<>'0'
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
   and B.InitialAssetClassAlt_Key not in(1)
AND (A.FlgProcessing='N')
AND B.Asset_Norm NOT IN ('ALWYS_NPA','ALWYS_STD')
AND  ISNULL(A.MocStatusMark,'N')='N' 
AND  ISNULL(B.AccountStatus,'N')<>'Z' 
AND ISNULL(B.BankAssetClasS,'N')<>'WRITEOFF'
AND A.UCIF_ID IS  NULL 
AND A.RefCustomerID is not null
--AND A.UCIF_ID<>'0'
GROUP BY A.RefCustomerID

) B ON A.RefCustomerID=B.RefCustomerID AND A.TOTALCOUNT=B.TOTALDPD_MAXCOUNT



  /*-----------UPGRADING CUSTOMER----------*/


UPDATE A SET A.FlgUpg='U'
FROM PRO.CUSTOMERCAL A INNER JOIN #TEMPTABLERefCustomerID B ON A.RefCustomerID=B.RefCustomerID
 INNER JOIN DIMASSETCLASS C ON C.AssetClassAlt_Key=A.SYSASSETCLASSALT_KEY AND (C.EffectiveFromTimeKey<=@TIMEKEY AND C.EffectiveToTimeKey>=@TIMEKEY)
WHERE  (not(isnull(A.ASSET_NORM,'NORMAL')='ALWYS_NPA' ) AND  C.ASSETCLASSGROUP ='NPA' AND not(ISNULL(A.FLGDEG,'N')='Y')) AND (ISNULL(A.FlgProcessing,'N')='N')


/*-----------UPGRADING CUSTOMER added 18/11/2019 where final asset class npa but dpd zero-----------*/

IF OBJECT_ID('TEMPDB..#TEMPTABLERefCustomerIDNew') IS NOT NULL
      DROP TABLE #TEMPTABLERefCustomerIDNew

SELECT A.RefCustomerID,TOTALCOUNT  INTO #TEMPTABLERefCustomerIDNew FROM 
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


/*-----------UPGRADING CUSTOMER added 18/11/2019 where final asset class npa but dpd zero-----------*/


UPDATE A SET A.FlgUpg='U'
FROM PRO.CUSTOMERCAL A INNER JOIN #TEMPTABLERefCustomerIDNew B ON A.RefCustomerID=B.RefCustomerID
 INNER JOIN DIMASSETCLASS C ON C.AssetClassAlt_Key=A.SYSASSETCLASSALT_KEY AND (C.EffectiveFromTimeKey<=@TIMEKEY AND C.EffectiveToTimeKey>=@TIMEKEY)
WHERE  (not(isnull(A.ASSET_NORM,'NORMAL')='ALWYS_NPA' ) AND  C.ASSETCLASSGROUP ='NPA' AND not(ISNULL(A.FLGDEG,'N')='Y')) AND (ISNULL(A.FlgProcessing,'N')='N')


-----As per mail dated 07/02/2022 Modification done Triloki Khanna-----

IF OBJECT_ID('TEMPDB..#TEMPTABLESourceSystemCustomerID') IS NOT NULL
      DROP TABLE #TEMPTABLESourceSystemCustomerID

SELECT A.SourceSystemCustomerID,TOTALCOUNT  INTO #TEMPTABLESourceSystemCustomerID FROM 
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
   and B.InitialAssetClassAlt_Key not in(1)
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

/*-----------UPGRADING CUSTOMER----------*/

UPDATE A SET A.FlgUpg='U'
FROM PRO.CUSTOMERCAL A INNER JOIN #TEMPTABLESourceSystemCustomerID B ON A.SourceSystemCustomerID=B.SourceSystemCustomerID
 INNER JOIN DIMASSETCLASS C ON C.AssetClassAlt_Key=A.SYSASSETCLASSALT_KEY AND (C.EffectiveFromTimeKey<=@TIMEKEY AND C.EffectiveToTimeKey>=@TIMEKEY)
WHERE  (not(isnull(A.ASSET_NORM,'NORMAL')='ALWYS_NPA' ) AND  C.ASSETCLASSGROUP ='NPA' AND not(ISNULL(A.FLGDEG,'N')='Y')) AND (ISNULL(A.FlgProcessing,'N')='N')

IF OBJECT_ID('TEMPDB..#TEMPTABLESourceSystemCustomerIDNew') IS NOT NULL
      DROP TABLE #TEMPTABLESourceSystemCustomerIDNew

SELECT A.SourceSystemCustomerID,TOTALCOUNT  INTO #TEMPTABLESourceSystemCustomerIDNew FROM 
(
SELECT A.SourceSystemCustomerID,COUNT(1) TOTALCOUNT FROM PRO.CUSTOMERCAL A INNER JOIN PRO.ACCOUNTCAL B ON A.RefCustomerID=B.RefCustomerID 
WHERE (A.FlgProcessing='N' )  AND A.UCIF_ID IS  NULL AND A.RefCustomerID IS  NULL
 and A.SourceSystemCustomerID is not null
--AND A.UCIF_ID<>'0'
 --Condition changed  By Triloki Khanna  08/04/2021 One Account 'ALWYS_STD' and DPD of All other accounts Zero , so condition of  ALWYS_STD Added
AND B.Asset_Norm NOT IN ('ALWYS_STD')
GROUP BY A.SourceSystemCustomerID
)
A INNER JOIN 
(
SELECT A.SourceSystemCustomerID,COUNT(1) TOTALDPD_MAXCOUNT FROM PRO.CUSTOMERCAL A INNER JOIN PRO.ACCOUNTCAL B ON A.RefCustomerID=B.RefCustomerID
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
AND A.UCIF_ID IS  NULL AND A.RefCustomerID IS  NULL
 and A.SourceSystemCustomerID is not null
GROUP BY A.SourceSystemCustomerID

) B ON A.SourceSystemCustomerID=B.SourceSystemCustomerID AND A.TOTALCOUNT=B.TOTALDPD_MAXCOUNT



/*-----------UPGRADING CUSTOMER added 18/11/2019 where final asset class npa but dpd zero-----------*/


UPDATE A SET A.FlgUpg='U'
FROM PRO.CUSTOMERCAL A INNER JOIN #TEMPTABLESourceSystemCustomerIDNew B ON A.SourceSystemCustomerID=B.SourceSystemCustomerID
 INNER JOIN DIMASSETCLASS C ON C.AssetClassAlt_Key=A.SYSASSETCLASSALT_KEY AND (C.EffectiveFromTimeKey<=@TIMEKEY AND C.EffectiveToTimeKey>=@TIMEKEY)
WHERE  (not(isnull(A.ASSET_NORM,'NORMAL')='ALWYS_NPA' ) AND  C.ASSETCLASSGROUP ='NPA' AND not(ISNULL(A.FLGDEG,'N')='Y')) AND (ISNULL(A.FlgProcessing,'N')='N')


/*-----------UPGRADING CUSTOMER added 18/11/2019 where final asset class npa but dpd zero-----------*/




---Changes done by Triloki 12-06-2020 in case of Same Pan Number One Customer Upgrade and One Npa To handle that Issue ---

----IF OBJECT_ID('TEMPDB..#PANUPDATEUPGRADE') IS NOT NULL
----DROP TABLE #PANUPDATEUPGRADE

----SELECT A.PANNO,A.TotalCountMAX,B.TotalCount
----INTO #PANUPDATEUPGRADE
----FROM

----(

----SELECT Count(1) TotalCountMAX,PANNO FROM PRO.CUSTOMERCAL WHERE PANNO IS NOT NULL

----GROUP BY PANNO

----) A

----INNER JOIN

----(

----SELECT Count(1) TotalCount,PANNO FROM PRO.CUSTOMERCAL WHERE PANNO IS NOT NULL AND FLGUPG='U'

----GROUP BY PANNO

----) B ON A.PANNO=B.PANNO AND A.TotalCountMAX <> B.TotalCount


---Changes done by Triloki 12-06-2020 in case of Same Pan Number One Customer Upgrade and One Npa To handle that Issue ---

---As per observation above condition modified 31/03/2023 ( in customerdata for single PAN 3 rows but in account 1 customer is not present)

IF OBJECT_ID('TEMPDB.DBO.#RemoveExtraCustomer') IS NOT NULL
DROP TABLE #RemoveExtraCustomer

select distinct b.CustomerEntityID
into #RemoveExtraCustomer
from pro.CustomerCal a
inner join pro.AccountCal b
on a.CustomerEntityID=b.CustomerEntityID


IF OBJECT_ID('TEMPDB..#PANUPDATEUPGRADE') IS NOT NULL
DROP TABLE #PANUPDATEUPGRADE

SELECT A.PANNO,A.TotalCountMAX,B.TotalCount
INTO #PANUPDATEUPGRADE
FROM

(

SELECT Count(1) TotalCountMAX,PANNO FROM PRO.CUSTOMERCAL A inner join #RemoveExtraCustomer B
on a.CustomerEntityID=b.CustomerEntityID
WHERE a.PANNO IS NOT NULL GROUP BY PANNO
) A
INNER JOIN
(SELECT Count(1) TotalCount,PANNO FROM PRO.CUSTOMERCAL a inner join #RemoveExtraCustomer B
on a.CustomerEntityID=b.CustomerEntityID WHERE PANNO IS NOT NULL AND FLGUPG='U'
GROUP BY PANNO
) B ON A.PANNO=B.PANNO AND A.TotalCountMAX <> B.TotalCount 

UPDATE B SET FLGUPG='N' from #PANUPDATEUPGRADE A
INNER JOIN PRO.CustomerCal B
ON A.PANNO=B.PANNO
WHERE B.FLGUPG='U'

-----Customer is upgraded who accounts is not preseent and asset class as NPA
IF OBJECT_ID('TEMPDB.DBO.#UCICExtraCustomer') IS NOT NULL
DROP TABLE #UCICExtraCustomer

select distinct UcifEntityID into #UCICExtraCustomer from Pro.customercal a where sysassetclassalt_key >1 and a.UCIf_ID is not null
except
select UcifEntityID from  Pro.Accountcal b where  b.UCIf_ID is not null

--select * from Pro.customercal where UcifEntityID in (select UcifEntityID from #UCICExtraCustomer)


UPDATE A SET A.FlgUpg='U'
FROM Pro.customercal A INNER JOIN #UCICExtraCustomer B ON A.UcifEntityID=B.UcifEntityID

IF OBJECT_ID('TEMPDB.DBO.#ReferenceExtraCustomer') IS NOT NULL
DROP TABLE #ReferenceExtraCustomer

select distinct CustomerEntityID into #ReferenceExtraCustomer from Pro.customercal a where sysassetclassalt_key >1 and ucif_id is null
and a.refcustomerID is not null
except
select CustomerEntityID from  Pro.Accountcal b where ucif_id is null and b.refcustomerID is not null

UPDATE A SET A.FlgUpg='U'
FROM Pro.customercal A INNER JOIN #ReferenceExtraCustomer B ON A.CustomerEntityID=B.CustomerEntityID


IF OBJECT_ID('TEMPDB.DBO.#SourceSystemExtraCustomer') IS NOT NULL
DROP TABLE #SourceSystemExtraCustomer

select distinct CustomerEntityID into #SourceSystemExtraCustomer from Pro.customercal a where sysassetclassalt_key >1 and ucif_id is null
and a.refcustomerID is  null   and SourceSystemCustomerID is not null
except
select CustomerEntityID from  Pro.Accountcal b where ucif_id is null and b.refcustomerID is  null and SourceSystemCustomerID is not null

UPDATE A SET A.FlgUpg='U'
FROM Pro.customercal A INNER JOIN #SourceSystemExtraCustomer B ON A.CustomerEntityID=B.CustomerEntityID


EXEC [PRO].[COBORROWER_DEG_UPG_MARKING] @TIMEKEY, 'U' /* CO-BORROWER UPGARDE MARKING*/  --Added on 2023-11-14  as Per Coborrowers Patch by AMAR SIR/Shubham


UPDATE   PRO.CustomerCal SET SysNPA_Dt=NULL,
							 DbtDt=NULL,
							 LossDt=NULL,
							 ErosionDt=NULL,
							 FlgErosion='N',
							 SysAssetClassAlt_Key=1
							 ,FlgDeg='N'
WHERE FlgUpg='U'


/*--------MARKING UPGRADED ACCOUNT --------------*/

UPDATE B SET  B.UpgDate=@PROCESSDATE
             ,B.DegReason=NULL
			 ,B.FinalAssetClassAlt_Key=1
			 ,B.FlgDeg='N'
			 ,B.FinalNpaDt=null
             ,B.FlgUpg='U'
			 FROM PRO.CUSTOMERCAL A INNER JOIN PRO.ACCOUNTCAL B ON A.UCIF_ID=B.UCIF_ID
WHERE  ISNULL(A.FlgUpg,'U')='U' AND (ISNULL(A.FlgProcessing,'N')='N')


UPDATE B SET  B.UpgDate=@PROCESSDATE
             ,B.DegReason=NULL
			 ,B.FinalAssetClassAlt_Key=1
			 ,B.FlgDeg='N'
			 ,B.FinalNpaDt=null
             ,B.FlgUpg='U'
			 FROM PRO.CUSTOMERCAL A INNER JOIN PRO.ACCOUNTCAL B ON A.RefCustomerID=B.RefCustomerID
WHERE  ISNULL(A.FlgUpg,'U')='U' AND (ISNULL(A.FlgProcessing,'N')='N')

-----As per mail dated 07/02/2022 Modification done Triloki Khanna-----
UPDATE B SET  B.UpgDate=@PROCESSDATE
             ,B.DegReason=NULL
			 ,B.FinalAssetClassAlt_Key=1
			 ,B.FlgDeg='N'
			 ,B.FinalNpaDt=null
             ,B.FlgUpg='U'
			 FROM PRO.CUSTOMERCAL A INNER JOIN PRO.ACCOUNTCAL B ON A.SourceSystemCustomerID=B.SourceSystemCustomerID
WHERE  ISNULL(A.FlgUpg,'U')='U' AND (ISNULL(A.FlgProcessing,'N')='N')

UPDATE A SET OVERDUESINCEDT=NULL,DPD_OVERDUE=0,DPD_MAX=0 FROM PRO.ACCOUNTCAL A WHERE  FLGDIRTYROW='Y'

UPDATE A set DegReason=NULL FROM PRO.CustomerCal A where SysAssetClassAlt_Key=1 and DegReason is not null


EXEC [pro].[CoBorrowerDetails_Insert] 'M'  -- DATA MERGER INTO HIST TABLE

--UPDATE A SET SysAssetClassAlt_Key=2
--from pro.CustomerCal  a
--inner join pro.accountcal b
--on a.CustomerEntityID=b.CustomerEntityID
--and a.SysNPA_Dt=B.FinalNpaDt
--and b.Asset_Norm='NORMAL'
--AND A.Asset_Norm='NORMAL'
--AND A.SysAssetClassAlt_Key=1

--UPDATE B SET FinalAssetClassAlt_Key=2
--from pro.CustomerCal  a
--inner join pro.accountcal b
--on a.CustomerEntityID=b.CustomerEntityID
--and a.SysNPA_Dt=B.FinalNpaDt
--and b.Asset_Norm='NORMAL'
--AND A.Asset_Norm='NORMAL'
--AND A.SysAssetClassAlt_Key>1
--AND B.FinalAssetClassAlt_Key=1


--IF OBJECT_ID('TEMPDB..#WrongUpg') IS NOT NULL
--	 DROP TABLE #WrongUpg
--SELECT CustomerEntityID,CustomerAcID,RefCustomerID,UCIF_ID,DegReason,NPA_Reason
--into #WrongUpg
--FROM PRO.AccountCal B
--WHERE (ISNULL(B.DPD_INTSERVICE,0)>=B.REFPERIODINTSERVICE
--OR ISNULL(B.DPD_OVERDRAWN,0)>=B.REFPERIODOVERDRAWN  
--OR ISNULL(B.DPD_NOCREDIT,0)>=B.REFPERIODNOCREDIT
--OR ISNULL(B.DPD_OVERDUE,0) >=B.REFPERIODOVERDUE 
--OR ISNULL(B.DPD_STOCKSTMT,0)>=B.REFPERIODSTKSTATEMENT
--OR ISNULL(B.DPD_RENEWAL,0)>=B.REFPERIODREVIEW 
--)
--AND B.FlgUpg='U' 
--AND B.Asset_Norm='NORMAL'

--UPDATE C SET SysAssetClassAlt_Key=A.SysAssetClassAlt_Key,FlgUpg=A.FlgUpg,SysNPA_Dt=A.SysNPA_Dt,DegReason=A.DegReason,FlgDeg=A.FlgDeg
--FROM #CUSTOMERCALWrong A
--INNER JOIN #WrongUpg B
--ON A.CustomerEntityID=B.CustomerEntityID
--INNER JOIN PRO.Customercal C
--ON A.CustomerEntityID=C.CustomerEntityID
--and C.Asset_Norm='NORMAL'

--UPDATE C SET FinalAssetClassAlt_Key=A.FinalAssetClassAlt_Key,FlgUpg=A.FlgUpg,FinalNpaDt=A.FinalNpaDt,DegReason=A.DegReason,NPA_Reason=A.NPA_Reason
--,UpgDate=A.UpgDate,FlgDeg=A.FlgDeg
-- FROM #accountcalWrong A
--INNER JOIN #WrongUpg B
--ON A.CustomerEntityID=B.CustomerEntityID
--INNER JOIN PRO.accountcal C
--ON A.CustomerEntityID=C.CustomerEntityID
--and A.AccountEntityID=C.AccountEntityID
--and C.Asset_Norm='NORMAL'



--IF OBJECT_ID('TEMPDB..#WrongUpgUCIF_ID') IS NOT NULL
--	 DROP TABLE #WrongUpgUCIF_ID
--select distinct UCIF_ID 
--into #WrongUpgUCIF_ID
--from pro.AccountCal where FlgUpg='U' AND Asset_Norm='NORMAL' AND FinalAssetClassAlt_Key=1

--IF OBJECT_ID('TEMPDB..#NPAUCIF_ID') IS NOT NULL
--	 DROP TABLE #NPAUCIF_ID
--SELECT distinct UCIF_ID 
--into #NPAUCIF_ID
--from pro.AccountCal
--WHERE FinalAssetClassAlt_Key>1 AND Asset_Norm='NORMAL'


--UPDATE D SET SysAssetClassAlt_Key=C.SysAssetClassAlt_Key,FlgUpg=C.FlgUpg,SysNPA_Dt=C.SysNPA_Dt,DegReason=C.DegReason,FlgDeg=C.FlgDeg 
--FROM #NPAUCIF_ID A
--INNER JOIN #WrongUpgUCIF_ID B
--ON A.UCIF_ID=B.UCIF_ID
--INNER JOIN #CUSTOMERCALWrong  C
--ON A.UCIF_ID=C.UCIF_ID
--INNER JOIN PRO.Customercal D
--ON D.UCIF_ID=C.UCIF_ID
--WHERE D.Asset_Norm='NORMAL'
--AND D.FlgUpg='U' and C.SysAssetClassAlt_Key>1


--UPDATE D SET FinalAssetClassAlt_Key=C.FinalAssetClassAlt_Key,FlgUpg=C.FlgUpg,FinalNpaDt=C.FinalNpaDt,DegReason=C.DegReason,NPA_Reason=C.NPA_Reason
--,UpgDate=C.UpgDate,FlgDeg=C.FlgDeg
--FROM #NPAUCIF_ID A
--INNER JOIN #WrongUpgUCIF_ID B
--ON A.UCIF_ID=B.UCIF_ID
--INNER JOIN #accountcalWrong  C
--ON A.UCIF_ID=C.UCIF_ID
--INNER JOIN PRO.accountcal D
--ON D.UCIF_ID=C.UCIF_ID
--and D.AccountEntityID=C.AccountEntityID
--WHERE D.Asset_Norm='NORMAL'
--AND D.FlgUpg='U' and C.FinalAssetClassAlt_Key>1

UPDATE C SET FinalAssetClassAlt_Key=A.FinalAssetClassAlt_Key,FlgUpg=A.FlgUpg,FinalNpaDt=A.FinalNpaDt,DegReason=A.DegReason,NPA_Reason=A.NPA_Reason
,UpgDate=A.UpgDate,FlgDeg=A.FlgDeg

 FROM #accountcalWrong A
INNER JOIN PRO.accountcal C
ON A.CustomerEntityID=C.CustomerEntityID
and A.AccountEntityID=C.AccountEntityID
and C.Asset_Norm='ALWYS_NPA'
and c.FinalAssetClassAlt_Key=1


IF OBJECT_ID('TEMPDB..#CustomerEntityIDAll') IS NOT NULL     
DROP TABLE #CustomerEntityIDAll     
select count(*) as ToatlAll,CustomerEntityID 
into #CustomerEntityIDAll
from pro.AccountCal
where CustomerEntityID>0
group by CustomerEntityID
order by CustomerEntityID


IF OBJECT_ID('TEMPDB..#CustomerEntityIDAllStd') IS NOT NULL     
DROP TABLE #CustomerEntityIDAllStd     

select count(*) as ToatlAllStd ,CustomerEntityID 
into #CustomerEntityIDAllStd
from pro.AccountCal
where CustomerEntityID>0 and Asset_Norm='ALWYS_STD'
and DPD_Max=0
group by CustomerEntityID
order by CustomerEntityID

UPDATE C SET SysAssetClassAlt_Key=1,SysNPA_Dt=NULL,DegReason=NULL
FROM #CustomerEntityIDAll A
INNER JOIN  #CustomerEntityIDAllStd B
ON A.CustomerEntityID=B.CustomerEntityID
AND A.ToatlAll=B.ToatlAllStd 
INNER JOIN PRO.CustomerCal C  ON A.CustomerEntityID=C.CustomerEntityID
INNER JOIN PRO.AccountCal D  ON A.CustomerEntityID=D.CustomerEntityID
WHERE C.SysAssetClassAlt_Key>1 and C.Asset_Norm='NORMAL'
 


        DROP TABLE #TEMPTABLE
	DROP TABLE #TEMPTABLE1
	DROP TABLE #TEMPTABLERefCustomerID
	DROP TABLE #PANUPDATEUPGRADE

UPDATE PRO.ACLRUNNINGPROCESSSTATUS 
	SET COMPLETED='Y',ERRORDATE=NULL,ERRORDESCRIPTION=NULL,COUNT=ISNULL(COUNT,0)+1
	WHERE RUNNINGPROCESSNAME='Upgrade_Customer_Account'

 
END TRY
BEGIN  CATCH

	UPDATE PRO.ACLRUNNINGPROCESSSTATUS 
	SET COMPLETED='N',ERRORDATE=GETDATE(),ERRORDESCRIPTION=ERROR_MESSAGE(),COUNT=ISNULL(COUNT,0)+1
	WHERE RUNNINGPROCESSNAME='Upgrade_Customer_Account'
END CATCH

SET NOCOUNT OFF
END
GO