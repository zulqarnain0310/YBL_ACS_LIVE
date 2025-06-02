SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/*=========================================
 AUTHER : SANJEEV KUMAR SHARMA
 CREATE DATE : 18-11-2017
 MODIFY DATE : 18-11-2017
 DESCRIPTION : UPDATE AssetClass
 ---EXEC [Pro].[Update_AssetClass] @TIMEKEY=25140 
=============================================*/

CREATE PROCEDURE [pro].[Update_AssetClass]
@TIMEKEY INT
AS
BEGIN
    SET NOCOUNT ON
  BEGIN TRY
     
--DECLARE @Timekey int = 27479
DECLARE @SUB_Days INT =(SELECT RefValue FROM PRO.refperiod WHERE BusinessRule='SUB_Days' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
DECLARE @DB1_Days INT =(SELECT RefValue FROM PRO.refperiod WHERE BusinessRule='DB1_Days' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
DECLARE @DB2_Days INT =(SELECT RefValue FROM PRO.refperiod WHERE BusinessRule='DB2_Days' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
DECLARE @MoveToDB1 DECIMAL(5,2) =(SELECT cast(RefValue/100.00 as decimal(5,2))FROM PRO.refperiod where BusinessRule='MoveToDB1' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
DECLARE @MoveToLoss DECIMAL(5,2)=(SELECT cast(RefValue/100.00 as decimal(5,2)) FROM PRO.refperiod where BusinessRule='MoveToLoss' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)

DECLARE @PROCESSDATE DATE =(SELECT DATE FROM SysDayMatrix WHERE TimeKey=@TIMEKEY)

IF OBJECT_ID('TEMPDB..#CTE_CustomerWiseBalance') IS NOT NULL
   DROP TABLE #CTE_CustomerWiseBalance


SELECT A.refcustomerid,SUM(ISNULL(A.BALANCE,0)) Balance 
INTO #CTE_CustomerWiseBalance FROM PRO.ACCOUNTCAL A INNER JOIN PRO.CUSTOMERCAL B ON A.refcustomerid=B.refcustomerid
WHERE   ISNULL(B.FlgProcessing,'N')='N' 
-- AND ISNULL(A.FACILITYTYPE,'N')NOT IN('INV','LC','BG') AND A.SecApp='S'
and B.refcustomerid<>'0' 
GROUP BY A.refcustomerid



CREATE CLUSTERED INDEX I1 ON #CTE_CustomerWiseBalance(refcustomerid)

/*-----INTIAL LEVEL SysAssetClassAlt_Key DbtDt,C DegDate----------- */

UPDATE B SET B.DbtDt=NULL,B.LossDt=NULL,B.DegDate=NULL
FROM  #CTE_CustomerWiseBalance a   INNER JOIN PRO.CustomerCal B ON A.REFCUSTOMERID=B.REFCUSTOMERID
WHERE (ISNULL(B.FlgDeg,'N')='Y'  AND ISNULL(B.FlgProcessing,'N')='N' )


/*---CALCULATE SysAssetClassAlt_Key ,DbtDt,DegDate-----------------------*/

UPDATE B SET B.SysAssetClassAlt_Key= (--CASE WHEN    B.CurntQtrRv< (A.BALANCE *@MoveToLoss) THEN   (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='LOS' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
                                        CASE  WHEN  DATEADD(DAY,@SUB_Days,B.SysNPA_Dt)>@PROCESSDATE   THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='SUB' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
										  WHEN  DATEADD(DAY,@SUB_Days,B.SysNPA_Dt)<=@PROCESSDATE AND  DATEADD(DAY,@SUB_Days+@DB1_Days,B.SysNPA_Dt)>@PROCESSDATE   THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='DB1' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
									      WHEN  DATEADD(DAY,@SUB_Days+@DB1_Days,B.SysNPA_Dt)<=@PROCESSDATE AND  DATEADD(DAY,@SUB_Days+@DB1_Days+@DB2_Days,B.SysNPA_Dt)>@PROCESSDATE THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='DB2' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
									       WHEN  DATEADD(DAY,(@DB1_Days+@SUB_Days+@DB2_Days),B.SysNPA_Dt)<=@PROCESSDATE  THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='DB3' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
									   END)
          ,B.DBTDT= (CASE 
									       WHEN  DATEADD(DAY,@SUB_Days,B.SysNPA_Dt)<=@PROCESSDATE AND  DATEADD(DAY,@SUB_Days+@DB1_Days,B.SysNPA_Dt)>@PROCESSDATE  THEN DATEADD(DAY,@SUB_Days,B.SysNPA_Dt)
									       WHEN  DATEADD(DAY,@SUB_Days+@DB1_Days,B.SysNPA_Dt)<=@PROCESSDATE AND  DATEADD(DAY,@SUB_Days+@DB1_Days+@DB2_Days,B.SysNPA_Dt)>@PROCESSDATE   THEN DATEADD(DAY,@SUB_Days,B.SysNPA_Dt)
									       WHEN  DATEADD(DAY,(@DB1_Days+@SUB_Days+@DB2_Days),B.SysNPA_Dt)<=@PROCESSDATE THEN DATEADD(DAY,(@SUB_Days),B.SysNPA_Dt)
										   ELSE DBTDT 
									   END)

		--,B.LossDt= (CASE  WHEN     B.CurntQtrRv< (A.BALANCE *@MoveToLoss)   THEN @PROCESSDATE ELSE LossDt END)
		,B.DegDate=@PROCESSDATE

FROM  #CTE_CustomerWiseBalance A   INNER JOIN PRO.CustomerCal B ON A.REFCUSTOMERID=B.REFCUSTOMERID
WHERE (ISNULL(B.FlgDeg,'N')='Y'    AND B.FlgProcessing='N' )


UPDATE B SET B.SysAssetClassAlt_Key= 
                                       (CASE  WHEN  DATEADD(DAY,@SUB_Days,B.SysNPA_Dt)>@PROCESSDATE   THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='SUB' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
										  WHEN  DATEADD(DAY,@SUB_Days,B.SysNPA_Dt)<=@PROCESSDATE AND  DATEADD(DAY,@SUB_Days+@DB1_Days,B.SysNPA_Dt)>@PROCESSDATE   THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='DB1' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
									      WHEN  DATEADD(DAY,@SUB_Days+@DB1_Days,B.SysNPA_Dt)<=@PROCESSDATE AND  DATEADD(DAY,@SUB_Days+@DB1_Days+@DB2_Days,B.SysNPA_Dt)>@PROCESSDATE THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='DB2' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
									       WHEN  DATEADD(DAY,(@DB1_Days+@SUB_Days+@DB2_Days),B.SysNPA_Dt)<=@PROCESSDATE  THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='DB3' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
									   END)
          ,B.DBTDT= (CASE 
									       WHEN  DATEADD(DAY,@SUB_Days,B.SysNPA_Dt)<=@PROCESSDATE AND  DATEADD(DAY,@SUB_Days+@DB1_Days,B.SysNPA_Dt)>@PROCESSDATE  THEN DATEADD(DAY,@SUB_Days,B.SysNPA_Dt)
									       WHEN  DATEADD(DAY,@SUB_Days+@DB1_Days,B.SysNPA_Dt)<=@PROCESSDATE AND  DATEADD(DAY,@SUB_Days+@DB1_Days+@DB2_Days,B.SysNPA_Dt)>@PROCESSDATE   THEN DATEADD(DAY,@SUB_Days,B.SysNPA_Dt)
									       WHEN  DATEADD(DAY,(@DB1_Days+@SUB_Days+@DB2_Days),B.SysNPA_Dt)<=@PROCESSDATE THEN DATEADD(DAY,(@SUB_Days),B.SysNPA_Dt)
										   ELSE DBTDT 
									   END)

		 
		,B.DegDate=@PROCESSDATE

FROM     PRO.CustomerCal B  
WHERE ISNULL(B.FlgDeg,'N')='Y'  
--and B.REFCUSTOMERID is null 
and b.SourceSystemCustomerID is not null


/*-------------MARKING OF FRAUD-----------------------*/
UPDATE  A SET A.SysAssetClassAlt_Key= 
(SELECT  TOP 1 AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='LOS' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
FROM PRO.CustomerCal A 
WHERE (
   ISNULL(A.SplCatg1Alt_Key,0) =870 
OR ISNULL(A.SplCatg2Alt_Key,0) =870 
OR ISNULL(A.SplCatg3Alt_Key,0)=870 
OR ISNULL(A.SplCatg4Alt_Key,0)=870
)
AND ISNULL(A.FlgDeg,'N')='Y' 



/*-------- UPDATE DBT DATE NULL FOR LOS CUSTOMERS------------------- */
UPDATE B SET DbtDt=NULL
FROM  #CTE_CustomerWiseBalance A   INNER JOIN PRO.CustomerCal B ON A.REFCUSTOMERID=B.REFCUSTOMERID
WHERE (ISNULL(B.FlgDeg,'N')='Y'  AND ISNULL(B.FlgProcessing,'N')='N' ) AND SysAssetClassAlt_Key IN(SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='LOS' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)

/*----UPDATE FINALASSETALT_KEY IN ACCOUNT LEVEL FROM CUSTOMER--------------------*/

UPDATE A SET A.FinalAssetClassAlt_Key=B.SysAssetClassAlt_Key
FROM PRO.AccountCal  A INNER JOIN PRO.CustomerCal B ON A.REFCUSTOMERID=B.REFCUSTOMERID
WHERE (ISNULL(B.FlgDeg,'N')='Y'  AND ISNULL(B.FlgProcessing,'N')='N' ) AND 
(ISNULL(A.Asset_Norm,'NORMAL')='NORMAL' AND ISNULL(A.FlgDeg,'N')='Y')

UPDATE A SET A.FinalAssetClassAlt_Key=B.SysAssetClassAlt_Key
FROM PRO.AccountCal  A INNER JOIN PRO.CustomerCal B ON A.SourceSystemCustomerID=B.SourceSystemCustomerID
WHERE (ISNULL(B.FlgDeg,'N')='Y'  AND ISNULL(B.FlgProcessing,'N')='N' ) AND 
(ISNULL(A.Asset_Norm,'NORMAL')='NORMAL' AND ISNULL(A.FlgDeg,'N')='Y')

 
 /*DCCO CR ADDED BY ZAIN ON 20250321 ON LOCAL*/
 
UPDATE A SET A.ASSET_NORM='ALWYS_NPA'
             ,A.FINALASSETCLASSALT_KEY=CASE WHEN FinalAssetClassAlt_Key=1 THEN 2 ELSE A.FinalAssetClassAlt_Key END 
			 ,A.DEGREASON=' DEGRADE BY DCCO FOR UCIC/FCR_CUSTOMERID ' + D.SourceName+' '+A.RefCustomerID
			,A.FlgDeg=(CASE WHEN ISNULL(A.FlgDeg,'N')='N' AND A.FinalAssetClassAlt_Key=1 THEN 'Y' ELSE A.FlgDeg END)
			,A.FINALNPADT=(CASE WHEN FINALNPADT IS NULL AND B.Final_DCCO > @PROCESSDATE THEN @PROCESSDATE --ADDED BY BALA ON 20250416
			                    WHEN FINALNPADT IS NULL AND B.FINAL_DCCO < @PROCESSDATE THEN B.FINAL_DCCO --ADDED BY BALA ON 20250416
						   ELSE FINALNPADT END)
			,A.DPD_DCCO=(DATEDIFF(DAY,B.Final_DCCO,@PROCESSDATE)+1)
			,A.FIN_DCCO_DATE=B.Final_DCCO
			,A.Utilisation=B.Utilisation
	FROM PRO.ACCOUNTCAL A INNER JOIN YBL_ACS..DCCO_MAIN B 
		ON A.RefCustomerID=B.Cust_ID AND (B.EFFECTIVEFROMTIMEKEY<=@timekey AND B.EFFECTIVETOTIMEKEY>=@timekey)
	INNER JOIN DimSourceDB D ON A.SourceAlt_Key=D.SourceAlt_Key
			AND (D.EFFECTIVEFROMTIMEKEY<=@timekey AND D.EFFECTIVETOTIMEKEY>=@timekey)
AND (DATEDIFF(DAY,B.Final_DCCO,@PROCESSDATE)+1)>0
AND B.Utilisation>0


 UPDATE A SET 	A.ASSET_NORM='ALWYS_NPA'
            	,A.DEGREASON=' DEGRADE BY DCCO FOR UCIC/FCR_CUSTOMERID ' + D.SourceName+' '+A.RefCustomerID
				,FlgDeg=(CASE WHEN ISNULL(FlgDeg,'N')='N' AND A.SysAssetClassAlt_Key=1 THEN 'Y' ELSE FlgDeg END)
				,DegDate=(CASE WHEN DegDate IS NULL THEN @PROCESSDATE
				               WHEN B.Final_DCCO < @PROCESSDATE THEN B.Final_DCCO --ADDED BY BALA ON 20250416
				               WHEN B.Final_DCCO > @PROCESSDATE THEN @PROCESSDATE --ADDED BY BALA ON 20250416
						       ELSE DegDate END)
		,A.SYSASSETCLASSALT_KEY=CASE WHEN SYSASSETCLASSALT_KEY=1 THEN 2 ELSE A.SYSASSETCLASSALT_KEY END --2  If Already Npa Customer resturcture marking done than asset class change based on updated Npa date
     		,A.SYSNPA_DT=(CASE WHEN SYSNPA_DT IS NULL AND B.Final_DCCO > @PROCESSDATE THEN @PROCESSDATE --ADDED BY BALA ON 20250416
			                   WHEN SYSNPA_DT IS NULL AND B.FINAL_DCCO < @PROCESSDATE THEN B.FINAL_DCCO --ADDED BY BALA ON 20250416
						   ELSE SYSNPA_DT END)
FROM PRO.CUSTOMERCAL A INNER JOIN YBL_ACS..DCCO_MAIN B 
		ON A.REFCUSTOMERID=B.Cust_ID AND (B.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND B.EFFECTIVETOTIMEKEY>=@TIMEKEY)
	INNER JOIN DimSourceDB D ON A.SourceAlt_Key=D.SourceAlt_Key
			AND (D.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND D.EFFECTIVETOTIMEKEY>=@TIMEKEY)
AND (DATEDIFF(DAY,B.Final_DCCO,@PROCESSDATE)+1)>0
AND B.Utilisation>0
/*DCCO CR ADDED BY ZAIN ON 20250321 ON LOCAL*/

 --UPDATE A
 -- SET  A.FinalAssetClassAlt_Key =CASE WHEN A.FlgDeg='Y' AND Asset_Norm='CONDI_STD' THEN FinalAssetClassAlt_Key ELSE  1 END
 --  FROM PRO.AccountCal  A
 --WHERE ISNULL(A.Asset_Norm,'NORMAL')='CONDI_STD' and isnull(InitialAssetClassAlt_Key,1)=1


 --/*------to handle upgrade of advance agianst  cash security IF CUSTOMER IS NPA BUT ISLAD ACCOUNT IS REGULAR------------------------------------*/
 
 --UPDATE A
 -- SET  A.FinalAssetClassAlt_Key =  case when b.ContinousExcessSecDt is not null  then FinalAssetClassAlt_Key else 1 end
 --  FROM PRO.AccountCal  A left outer join CurDat.AdvAcOtherDetail  b on a.AccountEntityID=b.AccountEntityId and (b.EffectiveFromTimeKey<=@TIMEKEY
 --  and b.EffectiveToTimeKey>=@TIMEKEY)
 --WHERE ISNULL(A.Asset_Norm,'NORMAL')='CONDI_STD' and isnull(a.InitialAssetClassAlt_Key,1)<>1

 DROP TABLE #CTE_CustomerWiseBalance

UPDATE PRO.ACLRUNNINGPROCESSSTATUS 
	SET COMPLETED='Y',ERRORDATE=NULL,ERRORDESCRIPTION=NULL,COUNT=ISNULL(COUNT,0)+1
	WHERE RUNNINGPROCESSNAME='Update_AssetClass'


END TRY
BEGIN  CATCH

	UPDATE PRO.ACLRUNNINGPROCESSSTATUS 
	SET COMPLETED='N',ERRORDATE=GETDATE(),ERRORDESCRIPTION=ERROR_MESSAGE(),COUNT=ISNULL(COUNT,0)+1
	WHERE RUNNINGPROCESSNAME='Update_AssetClass'
END CATCH

SET NOCOUNT OFF
END











GO