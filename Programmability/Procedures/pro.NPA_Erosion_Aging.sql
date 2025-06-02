SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO




/*=========================================
 AUTHER : SANJEEV KUMAR SHARMA
 CREATE DATE : 18-11-2017
 MODIFY DATE : 02-11-2017
 DESCRIPTION : UPDATE  SysAssetClassAlt_Key  NPA Erosion Aging
 --EXEC [PRO].[NPA_Erosion_Aging] @TIMEKEY=27419
=============================================*/

CREATE PROCEDURE [pro].[NPA_Erosion_Aging]
@TIMEKEY INT
with recompile
AS
BEGIN
  SET NOCOUNT ON
   BEGIN TRY


DECLARE @PROCESSDATE DATE =(SELECT DATE FROM SysDayMatrix WHERE TimeKey=@TIMEKEY)
DECLARE @MoveToDB1 DECIMAL(5,2) =(SELECT cast(RefValue/100.00 as decimal(5,2))FROM PRO.refperiod where BusinessRule='MoveToDB1' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
DECLARE @MoveToLoss DECIMAL(5,2)=(SELECT cast(RefValue/100.00 as decimal(5,2)) FROM PRO.refperiod where BusinessRule='MoveToLoss' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
DECLARE @LastQtrDateKey INT=(select LastQtrDateKey from sysdaymatrix where timekey=@TIMEKEY)
DECLARE @LastFinYearKey INT=(select LastFinYearKey from sysdaymatrix where timekey=@TIMEKEY)

IF OBJECT_ID('TEMPDB..#CTE_CustomerWiseBalance') IS NOT NULL
   DROP TABLE #CTE_CustomerWiseBalance

    --change by 11-01-2022
--SELECT A.UCIF_ID,SUM(ISNULL(A.BALANCE,0)) BALANCE INTO #CTE_CustomerWiseBalance FROM PRO.ACCOUNTCAL A
-- INNER JOIN PRO.CUSTOMERCAL B ON A.RefCustomerID=B.RefCustomerID
--              and A.UCIF_ID=B.UCIF_ID
--WHERE   ( b.SysAssetClassAlt_Key NOT IN (select AssetClassAlt_Key from DimAssetClass where AssetClassShortName ='STD' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY )
-- AND ISNULL(B.FlgDeg,'N')<>'Y')
-- AND (ISNULL(B.FlgProcessing,'N')='N') 
-- --AND ISNULL(A.FACILITYTYPE,'N')NOT IN('INV','LC','BG')  AND A.SecApp='S'
-- AND B.RefCustomerID<>'0'
-- and( A.UCIF_ID IS NOT NULL AND A.UCIF_ID<>'0' )
-- and A.SecApp='S'
--GROUP BY A.UCIF_ID

SELECT A.UCIF_ID,SUM(ISNULL(A.PrincOutStd,0)) PrincOutStd ,cast(0.00 as decimal(18,2)) AS PrvQtrRV ,cast(0.00 as decimal(18,2)) AS CurntQtrRv,
SUM(ISNULL(A.SecurityValue,0)) SecurityValue	--- Retail Security added on Erosion logic

INTO #CTE_CustomerWiseBalance FROM PRO.ACCOUNTCAL A
 INNER JOIN PRO.CUSTOMERCAL B ON A.SourceSystemCustomerID=B.SourceSystemCustomerID
              and A.UCIF_ID=B.UCIF_ID
WHERE   ( b.SysAssetClassAlt_Key NOT IN (select AssetClassAlt_Key from DimAssetClass where AssetClassShortName ='STD' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY ))
 --AND ISNULL(B.FlgDeg,'N')<>'Y')  CHANGE AS PER BANK REQUEST ON 20250205 ADDED BY ZAIN RAISED BY PRIYA MEENA
 AND (ISNULL(B.FlgProcessing,'N')='N') 
 --AND ISNULL(A.FACILITYTYPE,'N')NOT IN('INV','LC','BG')  AND A.SecApp='S'
 AND B.RefCustomerID<>'0'
 and( A.UCIF_ID IS NOT NULL AND A.UCIF_ID<>'0' )
 --and A.SecApp='S' 
 and ISNULL(A.PrincOutStd,0)>0 
 and A.SourceAlt_Key in(1,2)
 ---as disccused with Promodsir excluding below cases from Erosion balance logic 16022023
 AND a.FinalAssetClassAlt_Key > 1
  AND ISNULL(A.BANKASSETCLASS,'N')<>'WRITEOFF'
  AND ISNULL(A.ProductCode,'') not in ('NSLI','NSLB', 'NSLR','TRGC','TREC')
GROUP BY A.UCIF_ID


IF OBJECT_ID('TEMPDB..#CTE_PrvQtrRV') IS NOT NULL
   DROP TABLE #CTE_PrvQtrRV

SELECT UCIF_ID,SUM(ISNULL(A.PrvQtrRV,0)) PrvQtrRV
INTO #CTE_PrvQtrRV
 FROM PRO.CUSTOMERCAL A
WHERE ISNULL(A.PrvQtrRV,0)>0 AND ( A.UCIF_ID IS NOT NULL AND A.UCIF_ID<>'0' ) 
and SourceAlt_Key in(1,2)
GROUP BY A.UCIF_ID



IF OBJECT_ID('TEMPDB..#CTE_CurntQtrRv') IS NOT NULL
   DROP TABLE #CTE_CurntQtrRv

SELECT UCIF_ID,SUM(ISNULL(A.CurntQtrRv,0)) CurntQtrRv
INTO #CTE_CurntQtrRv
 FROM PRO.CUSTOMERCAL A
WHERE --ISNULL(A.CurntQtrRv,0)>0 AND   -- Retail Security added on Erosion logic
( A.UCIF_ID IS NOT NULL AND A.UCIF_ID<>'0' )
and SourceAlt_Key in(1,2) 
GROUP BY A.UCIF_ID

UPDATE A SET PrvQtrRV=B.PrvQtrRV
FROM #CTE_CustomerWiseBalance A
INNER JOIN #CTE_PrvQtrRV B
ON A.UCIF_ID=B.UCIF_ID


UPDATE A SET CurntQtrRv=B.CurntQtrRv +a.SecurityValue
FROM #CTE_CustomerWiseBalance A
INNER JOIN #CTE_CurntQtrRv B
ON A.UCIF_ID=B.UCIF_ID

/*----INTIAL LEVEL LossDt FlgErosion,ErosionDt NULL ------*/

--B.LossDt=NULL,B.FlgErosion='N',B.ErosionDt=NULL
--changed by 11-01-2022
--UPDATE B SET B.FlgErosion='N',B.ErosionDt=NULL
--FROM  PRO.AccountCal A INNER JOIN PRO.CustomerCal B ON A.RefCustomerID=B.RefCustomerID
--                                      AND A.UCIF_ID=B.UCIF_ID
--INNER JOIN #CTE_CustomerWiseBalance C ON C.UCIF_ID=B.RefCustomerID
--INNER JOIN DimAssetClass D ON D.AssetClassAlt_Key=B.SysAssetClassAlt_Key AND (D.EffectiveFromTimeKey<=@TIMEKEY AND D.EffectiveToTimeKey>=@TIMEKEY)
--WHERE ISNULL(A.Balance,0)>=0  AND D.AssetClassShortName<>'STD' AND (ISNULL(B.FlgProcessing,'N')='N')

UPDATE B SET B.FlgErosion='N',B.ErosionDt=NULL FROM  PRO.CustomerCal B 


--IF ( @PROCESSDATE=EOMONTH(@PROCESSDATE) 
IF ( CAST(DAY(@PROCESSDATE) AS INT )=25 
	)

BEGIN

UPDATE  B SET B.FlgErosion=  CASE WHEN  ISNULL(C.CurntQtrRv,0)< (ISNULL(C.PrincOutStd,0) *@MoveToLoss) AND D.AssetClassShortName<>'LOS' THEN  'Y'
					       WHEN    ISNULL(C.CurntQtrRv,0) <(ISNULL(C.PrincOutStd,0) *@MoveToDB1) 
						   --AND (ISNULL(C.PrincOutStd,0)>= ISNULL(C.CurntQtrRv,0)) 
						    AND  D.AssetClassShortName IN('SUB')  THEN  'Y'
						   ELSE 'N'
					   END
					
				,B.ErosionDt=CASE WHEN  ISNULL(C.CurntQtrRv,0)< (ISNULL(C.PrincOutStd,0) *@MoveToLoss) AND D.AssetClassShortName<>'LOS' THEN  @PROCESSDATE
					
					                 WHEN  ISNULL(C.CurntQtrRv,0) <(ISNULL(C.PrincOutStd,0) *@MoveToDB1) 
									 --AND (ISNULL(C.PrincOutStd,0)>= ISNULL(C.CurntQtrRv,0)) 
									  AND  D.AssetClassShortName IN('SUB')  THEN  @PROCESSDATE
						   ELSE B.ErosionDt
					   END
					
					
					
					
FROM  PRO.AccountCal A INNER JOIN PRO.CustomerCal B ON a.SourceSystemCustomerID=b.SourceSystemCustomerID
                               AND  A.UCIF_ID=B.UCIF_ID
INNER JOIN #CTE_CustomerWiseBalance C ON C.UCIF_ID=B.UCIF_ID     
INNER JOIN DimAssetClass D ON D.AssetClassAlt_Key=B.SysAssetClassAlt_Key AND (D.EffectiveFromTimeKey<=@TIMEKEY AND D.EffectiveToTimeKey>=@TIMEKEY)
WHERE ISNULL(A.PrincOutStd,0)>=0  AND D.AssetClassShortName<>'STD'  AND (ISNULL(B.FlgProcessing,'N')='N')
--AND  ISNULL(C.CurntQtrRv,0)>0

 ----Previous QTR value not checking for Erosion logic confirm by ashitosh 1908
--(
--(ISNULL(C.PrvQtrRV,0)>0  and ISNULL(C.CurntQtrRv,0)>0)
--OR
--(ISNULL(C.PrvQtrRV,0)=0  and ISNULL(C.CurntQtrRv,0)>0)
--OR
--(ISNULL(C.PrvQtrRV,0)>0  and ISNULL(C.CurntQtrRv,0)=0)
--)

END


IF (	 (MONTH(@PROCESSDATE) IN(3,12) AND DAY(@PROCESSDATE)=31)
	  OR (MONTH(@PROCESSDATE) IN(6,9)  AND DAY(@PROCESSDATE)=30)
	)
BEGIN


--As per Bank Mail (17/03/2022) Comment Security  EROSION Condition TRILOKI KHANNA 19/03/2022---
--As per Bank Mail (23/09/2022) Security EROSION Condition Started
----/*---UPDATING ASSET CLASS ON DUE TO EROSION OF SECURITY AND DBTDT AND LOSS DT DUE TO EROSION */

UPDATE  B SET B.SysAssetClassAlt_Key=
					
					  (CASE WHEN  ISNULL(C.CurntQtrRv,0)< (ISNULL(C.PrincOutStd,0) *@MoveToLoss) AND D.AssetClassShortName<>'LOS' THEN   (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='LOS' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
					       WHEN  ISNULL(C.CurntQtrRv,0) <(ISNULL(C.PrincOutStd,0) *@MoveToDB1) 
						  -- AND (ISNULL(C.PrincOutStd,0)>= ISNULL(C.CurntQtrRv,0) )
						    AND  D.AssetClassShortName IN('SUB')  THEN   (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='DB1' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY) 
						   ELSE B.SysAssetClassAlt_Key
					   END)
					
				,B.LossDt=CASE WHEN  ISNULL(C.CurntQtrRv,0)< (ISNULL(C.PrincOutStd,0) *@MoveToLoss) AND D.AssetClassShortName<>'LOS' THEN @PROCESSDATE
					        ELSE LossDt  END
					
				,B.DbtDt= CASE  WHEN  ISNULL(C.CurntQtrRv,0) <(ISNULL(C.PrincOutStd,0) *@MoveToDB1)
				-- AND (ISNULL(C.PrincOutStd,0)>= ISNULL(C.CurntQtrRv,0))
				 AND  D.AssetClassShortName IN('SUB')   THEN @PROCESSDATE ELSE DbtDt END -- Change 08/06/2018

				,B.FlgErosion=  CASE WHEN  ISNULL(C.CurntQtrRv,0)< (ISNULL(C.PrincOutStd,0) *@MoveToLoss) AND D.AssetClassShortName<>'LOS' THEN  'Y'
					       WHEN    ISNULL(C.CurntQtrRv,0) <(ISNULL(C.PrincOutStd,0) *@MoveToDB1)
						   -- AND (ISNULL(C.PrincOutStd,0)>= ISNULL(C.CurntQtrRv,0)) 
						    AND  D.AssetClassShortName IN('SUB')  THEN  'Y'
						   ELSE 'N'
					   END
					
				,B.ErosionDt=CASE WHEN  ISNULL(C.CurntQtrRv,0)< (ISNULL(C.PrincOutStd,0) *@MoveToLoss) AND D.AssetClassShortName<>'LOS' THEN  @PROCESSDATE
					
					                 WHEN  ISNULL(C.CurntQtrRv,0) <(ISNULL(C.PrincOutStd,0) *@MoveToDB1) 
									 ---AND (ISNULL(C.PrincOutStd,0)>= ISNULL(C.CurntQtrRv,0)) 
									      AND  D.AssetClassShortName IN('SUB')  THEN  @PROCESSDATE
						   ELSE B.ErosionDt
					   END
					
					
					
					
FROM  PRO.AccountCal A INNER JOIN PRO.CustomerCal B ON a.SourceSystemCustomerID=b.SourceSystemCustomerID
--- A.RefCustomerID=B.RefCustomerID change by 11-01-2022
                        AND  A.UCIF_ID=B.UCIF_ID
INNER JOIN #CTE_CustomerWiseBalance C ON C.UCIF_ID=B.UCIF_ID
                            
INNER JOIN DimAssetClass D ON D.AssetClassAlt_Key=B.SysAssetClassAlt_Key AND (D.EffectiveFromTimeKey<=@TIMEKEY AND D.EffectiveToTimeKey>=@TIMEKEY)
WHERE ISNULL(A.PrincOutStd,0)>=0  AND D.AssetClassShortName<>'STD'
  AND (ISNULL(B.FlgProcessing,'N')='N')

--AND  ISNULL(C.CurntQtrRv,0)>0

 ----Previous QTR value not checking for Erosion logic confirm by ashitosh 1908
--(
--(ISNULL(C.PrvQtrRV,0)>0  and ISNULL(C.CurntQtrRv,0)>0)
--OR
--(ISNULL(C.PrvQtrRV,0)=0  and ISNULL(C.CurntQtrRv,0)>0)
--OR
--(ISNULL(C.PrvQtrRV,0)>0  and ISNULL(C.CurntQtrRv,0)=0)
--)
 End 

--------As PER BRD_BDTS_ENPA_Finnone_Security Erosion Added 13/03/2023--------


--IF OBJECT_ID('TEMPDB..#CTE_CustomerWiseBalanceFinnOne') IS NOT NULL
--   DROP TABLE #CTE_CustomerWiseBalanceFinnOne
   
--SELECT A.CustomerAcID,ISNULL(A.PrincOutStd,0) PrincOutStd,cast(0.00 as decimal(18,2)) AS PrvQtrRV ,cast(0.00 as decimal(18,2)) AS CurntQtrRv 
--INTO #CTE_CustomerWiseBalanceFinnOne 
--FROM PRO.ACCOUNTCAL A
--INNER JOIN dimproduct b on a.ProductAlt_Key=b.ProductAlt_Key
--INNER JOIN DimSourceDB c on a.SourceAlt_Key=c.SourceAlt_Key
-- and a.ProductCode in('MEFSTL','AFHL','BHL','HLN','LAP','LRD','MOR','MICROMOR','SHL')
-- and b.SrcSysProductName='FINNONE'
--AND (b.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND b.EFFECTIVETOTIMEKEY>=@TIMEKEY)
--AND (C.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND C.EFFECTIVETOTIMEKEY>=@TIMEKEY)
--and c.SourceDBName='FinnOne'
--WHERE    a.FinalAssetClassAlt_Key NOT IN (select AssetClassAlt_Key from DimAssetClass where AssetClassShortName ='STD' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY )
-- and ISNULL(A.PrincOutStd,0)>0 
--  AND a.RefCustomerID<>'0' and ( A.UCIF_ID IS NOT NULL AND A.UCIF_ID<>'0' )
-- and isnull(SecurityValue,0)>0


/*SECURITY EROSION CR FSD RECEIVED ON  2024-08-21 12:36 BY TEJAS HALKATTI ON LOCAL 20240827 BY ZAIN
;WITH CTE AS(
SELECT A.AccountEntityID FROM PRO.AccountCal A 
                                                INNER JOIN
                                                                CURDAT.AdvSecurityDetail Advsec ON A.AccountEntityID=ADVSEC.AccountEntityId                                
                                                INNER JOIN 
                                                                CURDAT.AdvSecurityValueDetail Sec ON 
                                                 (SEC.EffectiveFromTimeKey < = @TimeKey AND SEC.EffectiveToTimeKey >= @TimeKey)
                                                                                                                                                                                AND Advsec.EffectiveFromTimeKey < = @Timekey
                                                                                                                                                                                AND Advsec.EffectiveToTimeKey > = @Timekey
                                                                                                                                                                                AND Advsec.SecurityEntityID=Sec.SecurityEntityID
                                                INNER JOIN
                                                                DIMPRODUCT D ON A.ProductAlt_Key=D.ProductAlt_Key
                                                                                                                                AND D.EffectiveFromTimeKey < = @Timekey
                                                                                                                                AND D.EffectiveToTimeKey > = @Timekey
                                                                                                                                AND D.ProductErosion='Y'
                                                WHERE EntryType='Retail' AND ISNULL(CurrentValue,0)>0 and           
                                                DATEADD(YY,3,(CASE WHEN isnull(A.FirstDtOfDisb,'1900-01-01') > isnull(SEC.VALUATIONDATE ,'1900-01-01')
                                                THEN A.FirstDtOfDisb ELSE SEC.VALUATIONDATE END))<@PROCESSDATE
)
UPDATE A SET A.SecurityValue=0,SecApp='U'
FROM PRO.AccountCal A INNER JOIN CTE B ON A.AccountEntityID=B.AccountEntityID */
/*SECURITY EROSION CR END*/


;WITH CTE AS(
SELECT A.AccountEntityID FROM PRO.AccountCal A 
                                                INNER JOIN
                                                                CURDAT.AdvSecurityDetail Advsec ON A.AccountEntityID=ADVSEC.AccountEntityId                                
                                                INNER JOIN 
                                                                CURDAT.AdvSecurityValueDetail Sec ON 
                                                 (SEC.EffectiveFromTimeKey < = @TimeKey AND SEC.EffectiveToTimeKey >= @TimeKey)
                                                                                                                                                                                AND Advsec.EffectiveFromTimeKey < = @Timekey
                                                                                                                                                                                AND Advsec.EffectiveToTimeKey > = @Timekey
                                                                                                                                                                                AND Advsec.SecurityEntityID=Sec.SecurityEntityID
                                                INNER JOIN
                                                                DIMPRODUCT D ON A.ProductAlt_Key=D.ProductAlt_Key
                                                                                                                                AND D.EffectiveFromTimeKey < = @Timekey
                                                                                                                                AND D.EffectiveToTimeKey > = @Timekey
                                                                                                                                AND D.ProductErosion='Y'
																																AND D.SrcSysProductName='FINNONE' --added Source system
                                                WHERE EntryType='Retail' AND ISNULL(CurrentValue,0)>0 and           
                                                DATEADD(YY,3,(CASE WHEN isnull(A.FirstDtOfDisb,'1900-01-01') > isnull(SEC.VALUATIONDATE ,'1900-01-01')
                                                THEN A.FirstDtOfDisb ELSE SEC.VALUATIONDATE END))<@PROCESSDATE
)
UPDATE A SET A.SecurityValue=0,SecApp='U'
FROM PRO.AccountCal A INNER JOIN CTE B ON A.AccountEntityID=B.AccountEntityID




;WITH CTE1 AS(
SELECT A.AccountEntityID FROM PRO.AccountCal A 
                                                INNER JOIN
                                                                CURDAT.AdvSecurityDetail Advsec ON A.AccountEntityID=ADVSEC.AccountEntityId                                
                                                INNER JOIN 
                                                                CURDAT.AdvSecurityValueDetail Sec ON 
                                                 (SEC.EffectiveFromTimeKey < = @TimeKey AND SEC.EffectiveToTimeKey >= @TimeKey)
                                                                                                                                                                                AND Advsec.EffectiveFromTimeKey < = @Timekey
                                                                                                                                                                                AND Advsec.EffectiveToTimeKey > = @Timekey
                                                                                                                                                                                AND Advsec.SecurityEntityID=Sec.SecurityEntityID
                                                INNER JOIN
                                                                DIMPRODUCT D ON A.ProductAlt_Key=D.ProductAlt_Key
                                                                                                                                AND D.EffectiveFromTimeKey < = @Timekey
                                                                                                                                AND D.EffectiveToTimeKey > = @Timekey
                                                                                                                                AND D.ProductErosion='Y'
																																AND D.SrcSysProductName='FCR'
                                                WHERE EntryType='Retail' AND ISNULL(CurrentValue,0)>0   
                                                and isnull(SEC.VALUATIONDATE ,'1900-01-01') <@PROCESSDATE
												

)
UPDATE A SET A.SecurityValue=0,SecApp='U' 
FROM PRO.AccountCal A INNER JOIN CTE1 B ON A.AccountEntityID=B.AccountEntityID




IF OBJECT_ID('TEMPDB..#CTE_CustomerWiseBalanceFinnOne') IS NOT NULL
   DROP TABLE #CTE_CustomerWiseBalanceFinnOne
   
SELECT A.CustomerAcID,ISNULL(A.PrincOutStd,0) PrincOutStd,cast(0.00 as decimal(18,2)) AS PrvQtrRV ,cast(0.00 as decimal(18,2)) AS CurntQtrRv 
INTO #CTE_CustomerWiseBalanceFinnOne 
FROM PRO.ACCOUNTCAL A
INNER JOIN dimproduct b on a.ProductAlt_Key=b.ProductAlt_Key
INNER JOIN DimSourceDB c on a.SourceAlt_Key=c.SourceAlt_Key
  
AND (b.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND b.EFFECTIVETOTIMEKEY>=@TIMEKEY)
AND (C.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND C.EFFECTIVETOTIMEKEY>=@TIMEKEY)
WHERE    a.FinalAssetClassAlt_Key NOT IN (select AssetClassAlt_Key from DimAssetClass where AssetClassShortName ='STD' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY )
 and ISNULL(A.PrincOutStd,0)>=0 
 AND a.RefCustomerID<>'0' and ( A.UCIF_ID IS NOT NULL AND A.UCIF_ID<>'0' )
 and isnull(SecurityValue,0)>=0 and b.ProductErosion='Y' and a.SecApp='S' ---added a.SecApp='S'


IF OBJECT_ID('TEMPDB..#CTE_PrvQtrRV1') IS NOT NULL
   DROP TABLE #CTE_PrvQtrRV1

SELECT CustomerAcID,SUM(ISNULL(A.SecurityValue,0)) PrvQtrRV
INTO #CTE_PrvQtrRV1
 FROM PRO.AccountCal_Hist A
INNER JOIN dimproduct b on a.ProductAlt_Key=b.ProductAlt_Key
INNER JOIN DimSourceDB c on a.SourceAlt_Key=c.SourceAlt_Key
 
WHERE ISNULL(A.SecurityValue,0)>=0  
and A.EffectiveFromTimeKey=@LastQtrDateKey and A.EffectiveToTimeKey=@LastQtrDateKey
AND (b.EFFECTIVEFROMTIMEKEY<=@LastQtrDateKey AND b.EFFECTIVETOTIMEKEY>=@LastQtrDateKey)
AND (C.EFFECTIVEFROMTIMEKEY<=@LastQtrDateKey AND C.EFFECTIVETOTIMEKEY>=@LastQtrDateKey)
and b.ProductErosion='Y'
GROUP BY A.CustomerAcID



IF OBJECT_ID('TEMPDB..#CTE_CurntQtrRv1') IS NOT NULL
   DROP TABLE #CTE_CurntQtrRv1

SELECT CustomerAcID,SUM(ISNULL(A.SecurityValue,0)) CurntQtrRv
INTO #CTE_CurntQtrRv1
 FROM PRO.ACCOUNTCAL A
INNER JOIN dimproduct b on a.ProductAlt_Key=b.ProductAlt_Key
INNER JOIN DimSourceDB c on a.SourceAlt_Key=c.SourceAlt_Key
 
WHERE ISNULL(A.SecurityValue,0)>=0  
AND (b.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND b.EFFECTIVETOTIMEKEY>=@TIMEKEY)
AND (C.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND C.EFFECTIVETOTIMEKEY>=@TIMEKEY)
and b.ProductErosion='Y'
GROUP BY A.CustomerAcID

UPDATE A SET PrvQtrRV=B.PrvQtrRV
FROM #CTE_CustomerWiseBalanceFinnOne A
INNER JOIN #CTE_PrvQtrRV1 B
ON A.CustomerAcID=B.CustomerAcID


UPDATE A SET CurntQtrRv=B.CurntQtrRv
FROM #CTE_CustomerWiseBalanceFinnOne A
INNER JOIN #CTE_CurntQtrRv1 B
ON A.CustomerAcID=B.CustomerAcID


 

IF ( CAST(DAY(@PROCESSDATE) AS INT )=25 
	)

BEGIN

UPDATE  B SET B.FlgErosion=  CASE WHEN  ISNULL(C.CurntQtrRv,0)< (ISNULL(C.PrincOutStd,0) *@MoveToLoss) AND D.AssetClassShortName<>'LOS' THEN  'Y'
					       WHEN    ISNULL(C.CurntQtrRv,0) <(ISNULL(C.PrincOutStd,0) *@MoveToDB1) 
						   
						    AND  D.AssetClassShortName IN('SUB')  THEN  'Y'
						   ELSE 'N'
					   END
					
				,B.ErosionDt=CASE WHEN  ISNULL(C.CurntQtrRv,0)< (ISNULL(C.PrincOutStd,0) *@MoveToLoss) AND D.AssetClassShortName<>'LOS' THEN  @PROCESSDATE
					
					                 WHEN  ISNULL(C.CurntQtrRv,0) <(ISNULL(C.PrincOutStd,0) *@MoveToDB1) 
									 
									  AND  D.AssetClassShortName IN('SUB')  THEN  @PROCESSDATE
						   ELSE B.ErosionDt
					   END
					
			--select * from PRo.accountcal		
					
					
FROM  PRO.AccountCal A INNER JOIN PRO.CustomerCal B ON a.SourceSystemCustomerID=b.SourceSystemCustomerID
                               
INNER JOIN #CTE_CustomerWiseBalanceFinnOne C ON C.CustomerAcID=a.CustomerAcID     
INNER JOIN DimAssetClass D ON D.AssetClassAlt_Key=B.SysAssetClassAlt_Key AND (D.EffectiveFromTimeKey<=@TIMEKEY AND D.EffectiveToTimeKey>=@TIMEKEY)
WHERE ISNULL(A.PrincOutStd,0)>=0  AND D.AssetClassShortName<>'STD'  AND (ISNULL(B.FlgProcessing,'N')='N')
AND ISNULL(C.CurntQtrRv,0)>0

 --Previous QTR value not checking for Erosion logic confirm by ashitosh 1908

 
--(
--(ISNULL(C.PrvQtrRV,0)>0  and ISNULL(C.CurntQtrRv,0)>0)
--OR
--(ISNULL(C.PrvQtrRV,0)=0  and ISNULL(C.CurntQtrRv,0)>0)
--OR
--(ISNULL(C.PrvQtrRV,0)>0  and ISNULL(C.CurntQtrRv,0)=0)
--)

END


IF (	 (MONTH(@PROCESSDATE) IN(3,12) AND DAY(@PROCESSDATE)=31)
	  OR (MONTH(@PROCESSDATE) IN(6,9)  AND DAY(@PROCESSDATE)=30)
	)
BEGIN



UPDATE  B SET B.SysAssetClassAlt_Key=
					
					  (CASE WHEN  ISNULL(C.CurntQtrRv,0)< (ISNULL(C.PrincOutStd,0) *@MoveToLoss) AND D.AssetClassShortName<>'LOS' THEN   (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='LOS' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
					       WHEN  ISNULL(C.CurntQtrRv,0) <(ISNULL(C.PrincOutStd,0) *@MoveToDB1) 
						
						    AND  D.AssetClassShortName IN('SUB')  THEN   (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='DB1' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY) 
						   ELSE B.SysAssetClassAlt_Key
					   END)
					
				,B.LossDt=CASE WHEN  ISNULL(C.CurntQtrRv,0)< (ISNULL(C.PrincOutStd,0) *@MoveToLoss) AND D.AssetClassShortName<>'LOS' THEN @PROCESSDATE
					        ELSE LossDt  END
					
				,B.DbtDt= CASE  WHEN  ISNULL(C.CurntQtrRv,0) <(ISNULL(C.PrincOutStd,0) *@MoveToDB1)
				
				 AND  D.AssetClassShortName IN('SUB')   THEN @PROCESSDATE ELSE DbtDt END 

				,B.FlgErosion=  CASE WHEN  ISNULL(C.CurntQtrRv,0)< (ISNULL(C.PrincOutStd,0) *@MoveToLoss) AND D.AssetClassShortName<>'LOS' THEN  'Y'
					       WHEN    ISNULL(C.CurntQtrRv,0) <(ISNULL(C.PrincOutStd,0) *@MoveToDB1)
						   						    AND  D.AssetClassShortName IN('SUB')  THEN  'Y'
						   ELSE 'N'
					   END
					
				,B.ErosionDt=CASE WHEN  ISNULL(C.CurntQtrRv,0)< (ISNULL(C.PrincOutStd,0) *@MoveToLoss) AND D.AssetClassShortName<>'LOS' THEN  @PROCESSDATE
					
					                 WHEN  ISNULL(C.CurntQtrRv,0) <(ISNULL(C.PrincOutStd,0) *@MoveToDB1) 
																		      AND  D.AssetClassShortName IN('SUB')  THEN  @PROCESSDATE
						   ELSE B.ErosionDt
					   END
					
					
					
					
FROM  PRO.AccountCal A INNER JOIN PRO.CustomerCal B ON a.SourceSystemCustomerID=b.SourceSystemCustomerID
                        
INNER JOIN #CTE_CustomerWiseBalanceFinnOne C ON C.CustomerAcID=a.CustomerAcID
                            
INNER JOIN DimAssetClass D ON D.AssetClassAlt_Key=B.SysAssetClassAlt_Key AND (D.EffectiveFromTimeKey<=@TIMEKEY AND D.EffectiveToTimeKey>=@TIMEKEY)
WHERE ISNULL(A.PrincOutStd,0)>=0  AND D.AssetClassShortName<>'STD'
  AND (ISNULL(B.FlgProcessing,'N')='N')
--AND ISNULL(C.CurntQtrRv,0)>0

 ----Previous QTR value not checking for Erosion logic confirm by ashitosh 1908
--(
--(ISNULL(C.PrvQtrRV,0)>0  and ISNULL(C.CurntQtrRv,0)>0)
--OR
--(ISNULL(C.PrvQtrRV,0)=0  and ISNULL(C.CurntQtrRv,0)>0)
--OR
--(ISNULL(C.PrvQtrRV,0)>0  and ISNULL(C.CurntQtrRv,0)=0)
--)
 End 
/*-------------------UPDATING ASSET CLASS DUE TO AGING--------*/






---Leep Year Changed on 27-04-2022

--DECLARE @SUB_Days INT =(SELECT RefValue FROM PRO.refperiod WHERE BusinessRule='SUB_Days')
--DECLARE @DB1_Days INT =(SELECT RefValue FROM PRO.refperiod WHERE BusinessRule='DB1_Days')
--DECLARE @DB2_Days INT =(SELECT RefValue FROM PRO.refperiod WHERE BusinessRule='DB2_Days')

DECLARE @SUB_Months INT =(SELECT RefValue FROM PRO.refperiod WHERE BusinessRule='SUB_Months' AND  EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
DECLARE @DB1_Months INT =(SELECT RefValue FROM PRO.refperiod WHERE BusinessRule='DB1_Months' AND  EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
DECLARE @DB2_Months INT =(SELECT RefValue FROM PRO.refperiod WHERE BusinessRule='DB2_Months' AND  EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)



/*------INTIAL LEVEL  DBTDT IS SET TO NULL------*/

/*---CALCULATE SysAssetClassAlt_Key,DbtDt ------------------ */

--UPDATE  A SET A.SysAssetClassAlt_Key= 
--   /*------VERSION 2 COMMENT TRILOKI 04/02/2019 DBT ASSET CLASS NOT UPDATE CORRECT  -----*/
--      CASE WHEN B.AssetClassShortName ='SUB' AND DATEADD(DAY,@SUB_Days,A.SysNPA_Dt)<=@PROCESSDATE THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='DB1' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
--       WHEN B.AssetClassShortName ='DB1' AND DATEADD(DAY,@DB1_Days, CASE WHEN A.DbtDt IS NOT NULL  THEN A.DbtDt
--	                                                                     ELSE DATEADD(DAY,@SUB_Days,A.SysNPA_Dt) END
	   
--	   )<=@PROCESSDATE      THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='DB2' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
--	   WHEN B.AssetClassShortName ='DB2' AND DATEADD(DAY,@DB1_Days+@DB2_Days,
--	                                          CASE WHEN A.DbtDt IS NOT NULL  THEN A.DbtDt
--											   ELSE DATEADD(DAY,@SUB_Days,A.SysNPA_Dt) END
--	   )<=@PROCESSDATE  THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='DB3' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
--  ELSE   A.SysAssetClassAlt_Key END ,

  
-- A.DbtDt= CASE WHEN B.AssetClassShortName ='SUB' AND DATEADD(DAY,@SUB_Days,A.SysNPA_Dt)<=@PROCESSDATE THEN DATEADD(DAY,@SUB_Days,A.SysNPA_Dt)
--  ELSE   A.DbtDt END

---Leep Year Changed on 27-04-2022

--UPDATE A SET A.SysAssetClassAlt_Key= (
--                                        CASE  WHEN  DATEADD(DAY,@SUB_Days,A.SysNPA_Dt)>@PROCESSDATE   THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='SUB' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
--										  WHEN  DATEADD(DAY,@SUB_Days,A.SysNPA_Dt)<=@PROCESSDATE AND  DATEADD(DAY,@SUB_Days+@DB1_Days,A.SysNPA_Dt)>@PROCESSDATE   THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='DB1' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
--									      WHEN  DATEADD(DAY,@SUB_Days+@DB1_Days,A.SysNPA_Dt)<=@PROCESSDATE AND  DATEADD(DAY,@SUB_Days+@DB1_Days+@DB2_Days,A.SysNPA_Dt)>@PROCESSDATE THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='DB2' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
--									       WHEN  DATEADD(DAY,(@DB1_Days+@SUB_Days+@DB2_Days),A.SysNPA_Dt)<=@PROCESSDATE  THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='DB3' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
--									   END)
--          ,A.DBTDT= (CASE 
--									       WHEN  DATEADD(DAY,@SUB_Days,A.SysNPA_Dt)<=@PROCESSDATE AND  DATEADD(DAY,@SUB_Days+@DB1_Days,A.SysNPA_Dt)>@PROCESSDATE  THEN DATEADD(DAY,@SUB_Days,A.SysNPA_Dt)
--									       WHEN  DATEADD(DAY,@SUB_Days+@DB1_Days,A.SysNPA_Dt)<=@PROCESSDATE AND  DATEADD(DAY,@SUB_Days+@DB1_Days+@DB2_Days,A.SysNPA_Dt)>@PROCESSDATE   THEN DATEADD(DAY,@SUB_Days,A.SysNPA_Dt)
--									       WHEN  DATEADD(DAY,(@DB1_Days+@SUB_Days+@DB2_Days),A.SysNPA_Dt)<=@PROCESSDATE THEN DATEADD(DAY,(@SUB_Days),A.SysNPA_Dt)
--										   ELSE DBTDT 
--									   END)

--FROM PRO.CustomerCal A INNER JOIN DimAssetClass B  ON A.SysAssetClassAlt_Key =B.AssetClassAlt_Key AND  B.EffectiveFromTimeKey<=@TIMEKEY AND B.EffectiveToTimeKey>=@TIMEKEY
--WHERE B.AssetClassShortName NOT IN('STD','LOS') AND ISNULL(A.FlgDeg,'N')<>'Y'  AND (ISNULL(A.FlgProcessing,'N')='N')
  
UPDATE A SET A.SysAssetClassAlt_Key= (
                                        CASE  WHEN  DATEADD(MONTH,@SUB_Months,A.SysNPA_Dt)>@PROCESSDATE AND b.AssetClassShortName not in ('DB1','DB2','DB3')  THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='SUB' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
										  --WHEN  DATEADD(MONTH,@SUB_Months,A.SysNPA_Dt)<=@PROCESSDATE AND  DATEADD(MONTH,@DB1_Months+@SUB_Months,A.SysNPA_Dt)>@PROCESSDATE AND b.AssetClassShortName not in ('DB2','DB3') THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='DB1' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
									       
										   WHEN  A.DbtDt <=@PROCESSDATE AND  DATEADD(MONTH,@DB1_Months,A.DbtDt)>@PROCESSDATE AND b.AssetClassShortName not in ('DB2','DB3') THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='DB1' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
									       WHEN  DATEADD(MONTH,@DB1_Months,A.DbtDt)<=@PROCESSDATE AND  DATEADD(MONTH,@DB1_Months+@DB2_Months,A.DbtDt)>@PROCESSDATE AND b.AssetClassShortName not in ('DB3') THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='DB2' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
									       WHEN  DATEADD(MONTH,@DB1_Months+@DB2_Months,A.DbtDt)<=@PROCESSDATE THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='DB3'AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
											ELSE A.SysAssetClassAlt_Key
									   END)
          --,A.DBTDT= (CASE 
									 --      WHEN   DATEADD(MONTH,@SUB_Months,A.SysNPA_Dt)<=@PROCESSDATE AND  DATEADD(MONTH,@DB1_Months+@SUB_Months,A.SysNPA_Dt)>@PROCESSDATE  THEN DATEADD(MONTH,@SUB_Months,A.SysNPA_Dt)
									 --      WHEN  DATEADD(MONTH,@DB1_Months,A.DbtDt)<=@PROCESSDATE AND  DATEADD(MONTH,@DB1_Months+@DB2_Months,A.DbtDt)>@PROCESSDATE   THEN DATEADD(MONTH,@SUB_Months,A.SysNPA_Dt)
									 --      WHEN DATEADD(MONTH,@DB1_Months+@DB2_Months,A.DbtDt)<=@PROCESSDATE THEN DATEADD(MONTH,(@SUB_Months),A.SysNPA_Dt)
										--   ELSE DBTDT 
									 --  END)

FROM PRO.CustomerCal A INNER JOIN DimAssetClass B  ON A.SysAssetClassAlt_Key =B.AssetClassAlt_Key AND  B.EffectiveFromTimeKey<=@TIMEKEY AND B.EffectiveToTimeKey>=@TIMEKEY
WHERE B.AssetClassShortName NOT IN('STD','LOS') AND ISNULL(A.FlgDeg,'N')<>'Y'  AND (ISNULL(A.FlgProcessing,'N')='N') and DbtDt is not null

--UPDATE YBL_ACS.PRO.CustomerCal  SET SysAssetClassAlt_Key=SrcAssetClassAlt_Key WHERE SysAssetClassAlt_Key IS NULL

--Added after FinalAssetClassAlt_Key Null Issue  30/06/2022
UPDATE A SET A.SysAssetClassAlt_Key= (
                                        CASE  WHEN  DATEADD(MONTH,@SUB_Months,A.SysNPA_Dt)>@PROCESSDATE   THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='SUB' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
										  WHEN  DATEADD(MONTH,@SUB_Months,A.SysNPA_Dt)<=@PROCESSDATE AND  DATEADD(MONTH,@SUB_Months+@DB1_Months,A.SysNPA_Dt)>@PROCESSDATE   THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='DB1' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
									      WHEN  DATEADD(MONTH,@SUB_Months+@DB1_Months,A.SysNPA_Dt)<=@PROCESSDATE AND  DATEADD(MONTH,@SUB_Months+@DB1_Months+@DB2_Months,A.SysNPA_Dt)>@PROCESSDATE THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='DB2' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
									       WHEN  DATEADD(MONTH,(@DB1_Months+@SUB_Months+@DB2_Months),A.SysNPA_Dt)<=@PROCESSDATE  THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='DB3' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
									   END)
          ,A.DBTDT= (CASE 
									       WHEN  DATEADD(MONTH,@SUB_Months,A.SysNPA_Dt)<=@PROCESSDATE AND  DATEADD(MONTH,@SUB_Months+@DB1_Months,A.SysNPA_Dt)>@PROCESSDATE  THEN DATEADD(MONTH,@SUB_Months,A.SysNPA_Dt)
									       WHEN  DATEADD(MONTH,@SUB_Months+@DB1_Months,A.SysNPA_Dt)<=@PROCESSDATE AND  DATEADD(MONTH,@SUB_Months+@DB1_Months+@DB2_Months,A.SysNPA_Dt)>@PROCESSDATE   THEN DATEADD(MONTH,@SUB_Months,A.SysNPA_Dt)
									       WHEN  DATEADD(MONTH,(@DB1_Months+@SUB_Months+@DB2_Months),A.SysNPA_Dt)<=@PROCESSDATE THEN DATEADD(MONTH,(@SUB_Months),A.SysNPA_Dt)
										   ELSE DBTDT 
									   END)

FROM PRO.CustomerCal A INNER JOIN DimAssetClass B  ON A.SysAssetClassAlt_Key =B.AssetClassAlt_Key AND  B.EffectiveFromTimeKey<=@TIMEKEY AND B.EffectiveToTimeKey>=@TIMEKEY
WHERE B.AssetClassShortName NOT IN('STD','LOS') AND ISNULL(A.FlgDeg,'N')<>'Y'  AND (ISNULL(A.FlgProcessing,'N')='N') and DbtDt is null --AND (ISNULL(A.FlgErosion,'N')='Y') 


--Issue in case of Erosion customers where customer present in different source system

IF OBJECT_ID('TEMPDB..#TEMPTABLE_FlgErosion') IS NOT NULL
DROP TABLE #TEMPTABLE_FlgErosion

SELECT UCIF_ID,MAX(ISNULL(SYSASSETCLASSALT_KEY,1)) SYSASSETCLASSALT_KEY
,MIN(SYSNPA_DT) SYSNPA_DT
,RefCustomerID
,SourceSystemCustomerID  
INTO #TEMPTABLE_FlgErosion FROM PRO.CUSTOMERCAL A
WHERE  a.FlgErosion='Y'and a.SYSASSETCLASSALT_KEY=6
GROUP BY  UCIF_ID ,RefCustomerID,SourceSystemCustomerID

UPDATE A SET A.SysAssetClassAlt_Key=B.SYSASSETCLASSALT_KEY
,A.SysNPA_Dt=B.SYSNPA_DT  
FROM PRO.CustomerCal A INNER JOIN #TEMPTABLE_FlgErosion B ON A.UCIF_ID=B.UCIF_ID
where A.Asset_Norm<>'ALWYS_STD'

UPDATE A SET A.SysAssetClassAlt_Key=B.SYSASSETCLASSALT_KEY
,A.SysNPA_Dt=B.SYSNPA_DT  
FROM PRO.CustomerCal A INNER JOIN #TEMPTABLE_FlgErosion B ON A.RefCustomerID=B.RefCustomerID
where A.Asset_Norm<>'ALWYS_STD'

UPDATE A SET A.SysAssetClassAlt_Key=B.SYSASSETCLASSALT_KEY
,A.SysNPA_Dt=B.SYSNPA_DT  
FROM PRO.CustomerCal A INNER JOIN #TEMPTABLE_FlgErosion B ON A.SourceSystemCustomerID=B.SourceSystemCustomerID
where A.Asset_Norm<>'ALWYS_STD'

UPDATE PRO.ACLRUNNINGPROCESSSTATUS 
	SET COMPLETED='Y',ERRORDATE=NULL,ERRORDESCRIPTION=NULL,COUNT=ISNULL(COUNT,0)+1
	WHERE RUNNINGPROCESSNAME='NPA_Erosion_Aging'

	DROP TABLE #CTE_CustomerWiseBalance
	DROP TABLE #CTE_PrvQtrRV
	DROP TABLE #CTE_CurntQtrRv
	DROP TABLE #CTE_PrvQtrRV1
	DROP TABLE #CTE_CurntQtrRv1
	DROP TABLE #CTE_CustomerWiseBalanceFinnOne

END TRY
BEGIN  CATCH

	UPDATE PRO.ACLRUNNINGPROCESSSTATUS 
	SET COMPLETED='N',ERRORDATE=GETDATE(),ERRORDESCRIPTION=ERROR_MESSAGE(),COUNT=ISNULL(COUNT,0)+1
	WHERE RUNNINGPROCESSNAME='NPA_Erosion_Aging'
END CATCH


SET NOCOUNT OFF
END
GO