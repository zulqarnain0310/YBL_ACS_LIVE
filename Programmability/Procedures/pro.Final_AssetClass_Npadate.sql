SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO




/*=========================================
 AUTHER : SANJEEV KUMAR SHARMA
 CREATE DATE : 18-11-2017
 MODIFY DATE : 18-11-2017
 DESCRIPTION :UPDATE FINAL ASSET CLASS AND MIN NPA DATE UPDATE CUSTOMER LEVEL AT ACCOUNT LEVEL
 EXEC [PRO].[Final_AssetClass_Npadate] 26203
=============================================*/
CREATE PROCEDURE [pro].[Final_AssetClass_Npadate]
@TIMEKEY INT with recompile
AS
BEGIN
      SET NOCOUNT ON
  BEGIN TRY
 




DECLARE @PanCardFlag char(1)=(select RefValue from pro.RefPeriod where BusinessRule='PanCardNO' and EffectiveFromTimeKey<=@TIMEKEY and EffectiveToTimeKey>=@TIMEKEY)
DECLARE @AadharCardFlag char(1)=(select RefValue from pro.RefPeriod where BusinessRule='AadharCard' and EffectiveFromTimeKey<=@TIMEKEY and EffectiveToTimeKey>=@TIMEKEY)
DECLARE @JointAccountFlag char(1)=(select RefValue from pro.RefPeriod where BusinessRule='Joint Account' and EffectiveFromTimeKey<=@TIMEKEY and EffectiveToTimeKey>=@TIMEKEY)
DECLARE @UCFICFlag char(1)=(select RefValue from pro.RefPeriod where BusinessRule='UCFIC' and EffectiveFromTimeKey<=@TIMEKEY and EffectiveToTimeKey>=@TIMEKEY)
DECLARE @PROCESSDATE DATE =(SELECT DATE FROM SysDayMatrix WHERE TimeKey=@TIMEKEY)

UPDATE  B SET B.finalAssetClassAlt_Key=1
FROM PRO.CustomerCal  A INNER JOIN PRO.AccountCal B ON A.SourceSystemCustomerID=B.SourceSystemCustomerID AND (A.FlgProcessing='N')
 WHERE A.Asset_Norm='ALWYS_STD'
/*---update FINALAssetClassAlt_Key  of those account which are not synk customer asset class key---------------------*/

UPDATE B SET B.finalAssetClassAlt_Key=  CASE WHEN A.Asset_Norm<>'ALWYS_STD' THEN A.SysAssetClassAlt_Key 
ELSE (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='STD' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY) END
FROM PRO.CustomerCal  A INNER JOIN PRO.AccountCal B ON A.RefCustomerID=B.RefCustomerID AND (ISNULL(A.FlgProcessing,'N')='N')
--AND A.RefCustomerID<>'0'
AND A.RefCustomerID IS NOT  NULL

UPDATE B SET B.finalAssetClassAlt_Key=  CASE WHEN A.Asset_Norm<>'ALWYS_STD' THEN A.SysAssetClassAlt_Key 
ELSE (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='STD' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY) END
FROM PRO.CustomerCal  A INNER JOIN PRO.AccountCal B ON A.SourceSystemCustomerID=B.SourceSystemCustomerID AND (ISNULL(A.FlgProcessing,'N')='N')
where A.SysAssetClassAlt_Key<>B.FinalAssetClassAlt_Key AND B.RefCustomerID is null 



/*---------------NPA DATE UPDATE CUSTOMER TO ACCOUNT LEVEL----------------------------------*/



UPDATE B SET B.FinalNpaDt=A.SYSNPA_DT FROM PRO.CUSTOMERCAL A INNER JOIN PRO.ACCOUNTCAL B  ON A.SourceSystemCustomerID=B.SourceSystemCustomerID
WHERE ISNULL(B.ASSET_NORM,'NORMAL')<>'ALWYS_STD' AND (ISNULL(A.FlgProcessing,'N')='N') 
and  isnull(A.SysNPA_Dt,'')<>isnull(b.FinalNpaDt,'') 
AND ISNULL(A.FlgDeg,'N')='Y'
AND A.RefCustomerID<>'0'



UPDATE A SET A.FINALASSETCLASSALT_KEY=1,FINALNPADT=NULL FROM PRO.ACCOUNTCAL  A WHERE ASSET_NORM='ALWYS_STD' AND FINALASSETCLASSALT_KEY>1
UPDATE A SET FinalAssetClassAlt_Key=1,FinalNpaDt=NULL, DEGREASON=NULL
 FROM PRO.AccountCal A WHERE A.ASSET_NORM ='ALWYS_STD'



/*------UPDATING DEG REASON  FOR ACCOUNT WHERE  NO DEFAULT IS THERE------ */

UPDATE B SET  B.DEGREASON=NULL FROM PRO.CUSTOMERCAL A INNER JOIN PRO.ACCOUNTCAL  B ON A.SourceSystemCustomerID=B.SourceSystemCustomerID
WHERE A.FLGDEG='Y' AND B.DEGREASON IS NULL AND B.ASSET_NORM <>'ALWYS_STD' AND (ISNULL(A.FlgProcessing,'N')='N')

IF OBJECT_ID('TEMPDB..#TempNewPERCOLATION') IS NOT NULL
    DROP TABLE #TempNewPERCOLATION

	SELECT SourceSystemCustomerID,CustomerAcID,MAX(ISNULL(DPD_Max,1)) DPD_Max
	,B.SourceDBName
	 INTO #TempNewPERCOLATION FROM PRO.ACCOUNTCAL A
	  INNER JOIN DIMSOURCEDB  B ON B.SourceAlt_Key=A.SourceAlt_Key 
	  AND B.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND B.EFFECTIVETOTIMEKEY>=@TIMEKEY
	  	WHERE FlgDeg='Y'
	GROUP BY SourceSystemCustomerID, CustomerAcID,B.SourceDBName

UPDATE B SET  B.DEGREASON='PERCOLATION BY OTHER ACCOUNT' FROM PRO.CUSTOMERCAL A INNER JOIN PRO.ACCOUNTCAL  B ON A.SourceSystemCustomerID=B.SourceSystemCustomerID
WHERE A.FLGDEG='Y' AND B.DEGREASON IS NULL AND B.ASSET_NORM <>'ALWYS_STD' AND (ISNULL(A.FlgProcessing,'N')='N')

 UPDATE A SET DegReason='PERCOLATION BY OTHER ACCOUNT' + '  ' + B.SourceDBName + '  ' + B.CustomerAcID 
	 FROM PRO.AccountCal A INNER JOIN #TempNewPERCOLATION B ON A.SourceSystemCustomerID=B.SourceSystemCustomerID
	 WHERE A.DEGREASON='PERCOLATION BY OTHER ACCOUNT'

	 
 UPDATE A SET DEGREASON=B.DEGREASON
  FROM PRO.ACCOUNTCAL A
INNER JOIN PRO.CUSTOMERCAL B
ON A.SOURCESYSTEMCUSTOMERID=B.SOURCESYSTEMCUSTOMERID
 WHERE A.DEGREASON='PERCOLATION BY OTHER ACCOUNT'

---------------------------------------------------------------------
--START OF MODIFICATION--HANDLING OF ACCOUNTS WITH FUTURE NPA DATE
---------------------------------------------------------------------

DECLARE @REF_DATE AS DATE = (SELECT EndDate FROM Pro.EXTDATE_MISDB WHERE Flg = 'Y')

UPDATE PRO.CustomerCal SET SysNPA_Dt = @REF_DATE WHERE ISNULL(SysNPA_Dt,'1900-01-01') > @REF_DATE

UPDATE PRO.AccountCal SET FinalNpaDt = @REF_DATE WHERE ISNULL(FinalNpaDt,'1900-01-01') > @REF_DATE

UPDATE PRO.CustomerCal SET SysNPA_Dt = @REF_DATE WHERE SysNPA_Dt IS NULL AND SysAssetClassAlt_Key>1
UPDATE PRO.AccountCal SET FinalNpaDt = @REF_DATE WHERE FinalNpaDt IS NULL AND FinalAssetClassAlt_Key>1

---------------------------------------------------------------------
--END OF MODIFICATION--


--/*------------------UPDATE SYSASSETCLASSALT_KEY|SYSNPA_DT BY PAN NO------------------*/
--IF ISNULL(@PanCardFlag,'N')='Y'
--BEGIN

--IF OBJECT_ID('TEMPDB..#TEMPTABLEPANCARD') IS NOT NULL
--    DROP TABLE #TEMPTABLEPANCARD

--	SELECT PANNO,MAX(ISNULL(SYSASSETCLASSALT_KEY,1)) SYSASSETCLASSALT_KEY
--	,MIN(SYSNPA_DT) SYSNPA_DT ,B.SourceDBName
--	 INTO #TEMPTABLEPANCARD FROM PRO.CUSTOMERCAL A
--	  INNER JOIN DIMSOURCEDB  B ON B.SourceAlt_Key=A.SourceAlt_Key AND B.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND B.EFFECTIVETOTIMEKEY>=@TIMEKEY
--	  	WHERE PANNO IS NOT NULL AND  ISNULL(SYSASSETCLASSALT_KEY,1)<>1
--	GROUP BY  PANNO,B.SourceDBName

--	UPDATE A SET A.SysAssetClassAlt_Key=B.SYSASSETCLASSALT_KEY
--	             ,A.SysNPA_Dt=B.SYSNPA_DT  
--	 FROM PRO.CustomerCal A INNER JOIN #TEMPTABLEPANCARD B ON A.PANNO=B.PANNO

	
--	 UPDATE A SET DegReason='PERCOLATION BY PAN CARD ' + 'SYSTEM  ' + B.SourceDBName + '  ' + B.PANNO 
--	  FROM PRO.CustomerCal A INNER JOIN #TEMPTABLEPANCARD B ON A.PANNO=B.PANNO
--	 WHERE A. SrcAssetClassAlt_Key=1 AND A.SysAssetClassAlt_Key>1
--	  AND A.DegReason IS NULL

	
--END	 

--/*------------------UPDATE SYSASSETCLASSALT_KEY|SYSNPA_DT BY AADHAR CARD NO------------------*/


--IF ISNULL(@AadharCardFlag,'N')='Y'
--BEGIN

--IF OBJECT_ID('TEMPDB..#TEMPTABLE_ADHARCARD') IS NOT NULL
--    DROP TABLE #TEMPTABLE_ADHARCARD

--	SELECT AadharCardNO,MAX(ISNULL(SYSASSETCLASSALT_KEY,1)) SYSASSETCLASSALT_KEY
--	,MIN(SYSNPA_DT) SYSNPA_DT 
--	 INTO #TEMPTABLE_ADHARCARD FROM PRO.CUSTOMERCAL
--	WHERE AadharCardNO IS NOT NULL AND  ISNULL(SYSASSETCLASSALT_KEY,1)<>1

--	GROUP BY  AadharCardNO

--	UPDATE A SET A.SysAssetClassAlt_Key=B.SYSASSETCLASSALT_KEY
--	             ,A.SysNPA_Dt=B.SYSNPA_DT  
--	 FROM PRO.CustomerCal A INNER JOIN #TEMPTABLE_ADHARCARD B ON A.AadharCardNO=B.AadharCardNO

--	  UPDATE A SET DegReason='PERCOLATION BY AADHAR CARD ' +' ' + B.AadharCardNO
--	 FROM PRO.CustomerCal A INNER JOIN #TEMPTABLE_ADHARCARD B ON A.AadharCardNO=B.AadharCardNO
--	 WHERE A. SrcAssetClassAlt_Key=1 AND A.SysAssetClassAlt_Key>1
--	  AND A.DegReason IS NULL
--END	 


--/*------------------UPDATE SYSASSETCLASSALT_KEY|SYSNPA_DT BY JointAccountFlag------------------*/

--IF ISNULL(@JointAccountFlag,'N')='Y'
--BEGIN

--IF OBJECT_ID('TEMPDB..#TEMPTABLE_JointAccountFlag') IS NOT NULL
--    DROP TABLE #TEMPTABLE_JointAccountFlag

--		SELECT A.RefCustomerID AS CoApplicantDetail,
--		       B.RefCustomerID AS PrimaryBrower,
--			   C.SysAssetClassAlt_Key,C.SysNPA_Dt
--		INTO #TEMPTABLE_JointAccountFlag
--	  FROM PRO.CoApplicantDetail A
--			INNER JOIN PRO.AccountCal  B  ON A.CustomerAcid=B.CustomerAcid
--			INNER JOIN PRO.CustomerCal C ON C.RefCustomerID=B.RefCustomerID
--			AND A.RefCustomerID<>B.RefCustomerID
--			INNER JOIN YBL_ACS_MIS..CustomerDatA D ON D.FCR_CustomerID=A.RefCustomerID
--			WHERE ISNULL(C.SysAssetClassAlt_Key,1)<>1 AND D.AssetClass=1
--			 and C.RefCustomerID<>'0'
--			ORDER BY B.RefCustomerID


--	UPDATE A SET A.SysAssetClassAlt_Key=B.SYSASSETCLASSALT_KEY
--	             ,A.SysNPA_Dt=B.SYSNPA_DT  
--	 FROM PRO.CustomerCal A INNER JOIN #TEMPTABLE_JointAccountFlag B ON B.CoApplicantDetail=A.RefCustomerID

--	 update A SET DegReason='PERCOLATION BY JOINT' + B.PrimaryBrower
--	 FROM PRO.CustomerCal A INNER JOIN #TEMPTABLE_JointAccountFlag B ON A.RefCustomerID=B.PrimaryBrower
--	 WHERE A. SrcAssetClassAlt_Key=1 AND A.SysAssetClassAlt_Key>1
--	  AND A.DegReason IS NULL
--	  --SELECT * FROM #TEMPTABLE_JointAccountFlag
--END	 



--/*------------------UPDATE SYSASSETCLASSALT_KEY|SYSNPA_DT BY REFCUSTOMERID------------------*/


--IF OBJECT_ID('TEMPDB..#TempTableRefCustomerID') IS NOT NULL
--    DROP TABLE #TempTableRefCustomerID
	
--	SELECT RefCustomerID,MAX(ISNULL(SYSASSETCLASSALT_KEY,1)) SYSASSETCLASSALT_KEY
--	,MIN(SYSNPA_DT) SYSNPA_DT 
--	 INTO #TempTableRefCustomerID FROM PRO.CUSTOMERCAL
--	WHERE (RefCustomerID IS NOT NULL and RefCustomerID<>'0')  AND  ISNULL(SYSASSETCLASSALT_KEY,1)<>1
--	GROUP BY  RefCustomerID

--	UPDATE A SET A.SysAssetClassAlt_Key=B.SYSASSETCLASSALT_KEY
--	             ,A.SysNPA_Dt=B.SYSNPA_DT  
--	 FROM PRO.CustomerCal A INNER JOIN #TempTableRefCustomerID B ON A.RefCustomerID=B.RefCustomerID

--	 update A SET DegReason='PERCOLATION BY CustomerID ' +' ' + B.RefCustomerID
--	 FROM PRO.CustomerCal A INNER JOIN #TempTableRefCustomerID B ON A.RefCustomerID=B.RefCustomerID
--	 WHERE A. SrcAssetClassAlt_Key=1 AND A.SysAssetClassAlt_Key>1
--	 AND A.DegReason IS NULL
	 


--/*------------------UPDATE SYSASSETCLASSALT_KEY|SYSNPA_DT BY UCFIC LEVEL------------------*/
--IF ISNULL(@UCFICFlag,'N')='Y'
--BEGIN

--IF OBJECT_ID('TEMPDB..#TEMPTABLE_UCFIC') IS NOT NULL
--    DROP TABLE #TEMPTABLE_UCFIC

--	SELECT UCIF_ID,MAX(ISNULL(SYSASSETCLASSALT_KEY,1)) SYSASSETCLASSALT_KEY
--	,MIN(SYSNPA_DT) SYSNPA_DT 
--	 INTO #TEMPTABLE_UCFIC FROM PRO.CUSTOMERCAL
--	WHERE ( UCIF_ID IS NOT NULL and UCIF_ID<>'0' ) AND  ISNULL(SYSASSETCLASSALT_KEY,1)<>1
--	GROUP BY  UCIF_ID

--	UPDATE A SET A.SysAssetClassAlt_Key=B.SYSASSETCLASSALT_KEY
--	             ,A.SysNPA_Dt=B.SYSNPA_DT  
--	 FROM PRO.CustomerCal A INNER JOIN #TEMPTABLE_UCFIC B ON A.UCIF_ID=B.UCIF_ID

--END	 


/*------------------------------UPDATE UNIFORM ASSET CLASSIFICATION--------------------------------*/

	UPDATE A SET DegReason='SELF' FROM PRO.CustomerCal A WHERE FlgDeg='Y' AND DegReason IS NULL

	IF OBJECT_ID('TEMPDB..#TEMPTABLE_UCFIC1') IS NOT NULL
    DROP TABLE #TEMPTABLE_UCFIC1

	SELECT UCIF_ID,MAX(ISNULL(SYSASSETCLASSALT_KEY,1)) SYSASSETCLASSALT_KEY
	,MIN(SYSNPA_DT) SYSNPA_DT ,B.SourceDBName
	 INTO #TEMPTABLE_UCFIC1 FROM PRO.CUSTOMERCAL A
	 INNER JOIN DIMSOURCEDB  B ON B.SourceAlt_Key=A.SourceAlt_Key AND B.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND B.EFFECTIVETOTIMEKEY>=@TIMEKEY

	WHERE ( UCIF_ID IS NOT NULL and UCIF_ID<>'0' ) AND  ISNULL(SYSASSETCLASSALT_KEY,1)<>1
	
	GROUP BY  UCIF_ID,B.SourceDBName

	UPDATE A SET A.SysAssetClassAlt_Key=B.SYSASSETCLASSALT_KEY
	             ,A.SysNPA_Dt=B.SYSNPA_DT  
	 FROM PRO.CustomerCal A INNER JOIN #TEMPTABLE_UCFIC1 B ON A.UCIF_ID=B.UCIF_ID

	/*START ---AMAR - 21052024 ADDED FOR PAN PERCOLATION AS				----------EMAIL BY TEJAUS (BA Team) ON 2105024 AT 03:30PM  */
		/*FINDING MAX ASSET CLASS AND MIN NPA DATE AT PAN LEVEL */
		
		IF OBJECT_ID('TEMPDB..#TEMPTABLEPANCARD') IS NOT NULL
    DROP TABLE #TEMPTABLEPANCARD
		
		SELECT PANNO
				,MAX(ISNULL(SYSASSETCLASSALT_KEY,1)) SYSASSETCLASSALT_KEY
				,MIN(SYSNPA_DT) SYSNPA_DT 
			INTO #TEMPTABLEPANCARD FROM PRO.CUSTOMERCAL A
				INNER JOIN DIMSOURCEDB  B ON B.SourceAlt_Key=A.SourceAlt_Key AND B.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND B.EFFECTIVETOTIMEKEY>=@TIMEKEY
		  	WHERE PANNO IS NOT NULL AND  ISNULL(SYSASSETCLASSALT_KEY,1)<>1
		GROUP BY  PANNO

		/*UPDATING PAN LEVEL ASSET CLASS AND NPA DATE*/
		UPDATE A SET A.SysAssetClassAlt_Key=B.SYSASSETCLASSALT_KEY
		             ,A.SysNPA_Dt=B.SYSNPA_DT  
		 FROM PRO.CustomerCal A INNER JOIN #TEMPTABLEPANCARD B ON A.PANNO=B.PANNO
			
		/*UPDATING DEG REASON- FOR THE CUSTOMER MARKED NPA AT PAN LEVEL*/
		 UPDATE A SET DegReason='PERCOLATION BY PAN CARD ' + ' ' + B.PANNO 
		  FROM PRO.CustomerCal A INNER JOIN #TEMPTABLEPANCARD B ON A.PANNO=B.PANNO
		 WHERE A. SrcAssetClassAlt_Key=1 AND A.SysAssetClassAlt_Key>1
				AND A.DegReason IS NULL
	/*END---AMAR - 21052024 ADDED FOR PAN PERCOLATION AS			----------EMAIL BY TEJAUS (BA Team) ON 2105024 AT 03:30PM */


	 UPDATE A SET 
	         A.FinalAssetClassAlt_Key=ISNULL(B.SysAssetClassAlt_Key,1)
		    ,A.FinalNpaDt=B.SysNPA_Dt
			FROM PRO.AccountCal A INNER   JOIN PRO.CustomerCal B 
			ON  A.RefCustomerID=B.RefCustomerID AND A.SourceSystemCustomerID=B.SourceSystemCustomerID 
			WHERE ISNULL(B.SysAssetClassAlt_Key,1)<>1 AND B.RefCustomerID<>'0'

	UPDATE A SET 
	         A.FinalAssetClassAlt_Key=ISNULL(B.SysAssetClassAlt_Key,1)
		    ,A.FinalNpaDt=B.SysNPA_Dt
			FROM PRO.AccountCal A INNER   JOIN PRO.CustomerCal B 
			ON  A.SourceSystemCustomerID=B.SourceSystemCustomerID 
			WHERE ISNULL(B.SysAssetClassAlt_Key,1)<>1

	---Triloki khanna as per mail  17-11-2021 npa date null issue 
	--UPDATE A SET 
	--         A.FinalAssetClassAlt_Key=ISNULL(B.SysAssetClassAlt_Key,1)
	--	    ,A.FinalNpaDt=B.SysNPA_Dt
	--		FROM PRO.AccountCal A INNER   JOIN PRO.CustomerCal B 
	--		ON  A.UcifEntityID=B.UcifEntityID 
	--		WHERE ISNULL(B.SysAssetClassAlt_Key,1)<>1

			
	UPDATE A SET 
	         A.FinalAssetClassAlt_Key=ISNULL(B.SysAssetClassAlt_Key,1)
		    ,A.FinalNpaDt=B.SysNPA_Dt
			FROM PRO.AccountCal A INNER   JOIN PRO.CustomerCal B 
			ON  A.UcifEntityID=B.UcifEntityID 
			and ( b.UCIF_ID IS NOT NULL and b.UCIF_ID<>'0' )---Triloki khanna as per mail  17-11-2021 npa date null issue 
			WHERE ISNULL(B.SysAssetClassAlt_Key,1)<>1

	 UPDATE A SET DegReason='PERCOLATION BY UCIFID ' + ' ' + B.SourceDBName + '  ' + B.UCIF_ID 
	 FROM PRO.CustomerCal A INNER JOIN #TEMPTABLE_UCFIC1 B ON A.UCIF_ID=B.UCIF_ID
	 WHERE A.SrcAssetClassAlt_Key=1 AND A.SysAssetClassAlt_Key>1
	 AND A.DegReason IS NULL

	 UPDATE A SET DegReason =NULL FROM PRO.CustomerCal A WHERE FlgDeg='Y' AND DegReason='SELF'

	 
	 UPDATE A SET DEGREASON=B.DEGREASON
 FROM PRO.AccountCal A INNER JOIN PRO.CustomerCal B ON A.SourceSystemCustomerID =B.SourceSystemCustomerID
WHERE (B.FlgProcessing='N')  AND (A.FLGDEG='N') AND B.DegReason IS NOT NULL AND A.FinalAssetClassAlt_Key>1 AND A.DegReason IS NULL

	IF OBJECT_ID('TEMPDB..#TEMPTABLE_UCFICDbtDt') IS NOT NULL
    DROP TABLE #TEMPTABLE_UCFICDbtDt

	SELECT UcifEntityID,DbtDt
	 INTO #TEMPTABLE_UCFICDbtDt FROM PRO.CUSTOMERCAL
	WHERE ( UCIF_ID IS NOT NULL and UCIF_ID<>'0' ) AND  ISNULL(SYSASSETCLASSALT_KEY,1) IN(3,4,5)
	 AND DbtDt IS NOT NULL 
	GROUP BY  UcifEntityID,DbtDt


	 UPDATE B SET DbtDt =A.DbtDt FROM #TEMPTABLE_UCFICDbtDt A
	INNER JOIN PRO.CUSTOMERCAL B ON A.UcifEntityID=B.UcifEntityID	 AND B.DbtDt IS NULL

	
IF OBJECT_ID('TEMPDB..#TempTableRefCustomerID') IS NOT NULL
    DROP TABLE #TempTableRefCustomerID
	
	SELECT RefCustomerID,MAX(ISNULL(SYSASSETCLASSALT_KEY,1)) SYSASSETCLASSALT_KEY
	,MIN(SYSNPA_DT) SYSNPA_DT , MIN(DbtDt) DbtDt ,B.SourceDBName
	 INTO #TempTableRefCustomerID FROM PRO.CUSTOMERCAL A
	 INNER JOIN DIMSOURCEDB  B ON B.SourceAlt_Key=A.SourceAlt_Key AND B.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND B.EFFECTIVETOTIMEKEY>=@TIMEKEY
	WHERE (A.RefCustomerID IS NOT NULL and RefCustomerID<>'0')  AND  ISNULL(A.SYSASSETCLASSALT_KEY,1)<>1
	GROUP BY  A.RefCustomerID,B.SourceDBName

	UPDATE A SET A.SysAssetClassAlt_Key=B.SYSASSETCLASSALT_KEY
	             ,A.SysNPA_Dt=B.SYSNPA_DT  
				 ,A.DbtDt=B.DbtDt
	 FROM PRO.CustomerCal A INNER JOIN #TempTableRefCustomerID B ON A.RefCustomerID=B.RefCustomerID
	 WHERE A.SysAssetClassAlt_Key<>B.SYSASSETCLASSALT_KEY


	  UPDATE A SET 
	         A.FinalAssetClassAlt_Key=ISNULL(B.SysAssetClassAlt_Key,1)
		    ,A.FinalNpaDt=B.SysNPA_Dt
			FROM PRO.AccountCal A INNER   JOIN #TempTableRefCustomerID B 
			ON  A.RefCustomerID=B.RefCustomerID  
			WHERE A.FinalAssetClassAlt_Key<>B.SYSASSETCLASSALT_KEY

	 UPDATE A SET DegReason='PERCOLATION BY FCR CustomerID' + ' ' + B.SourceDBName + '  ' + B.RefCustomerID 
	 FROM PRO.CustomerCal A INNER JOIN #TempTableRefCustomerID B ON A.RefCustomerID=B.RefCustomerID
	 WHERE  A.SrcAssetClassAlt_Key=1 AND A.SysAssetClassAlt_Key>1 
	 AND A.DegReason IS NULL



	EXEC [PRO].[CoBorrowerDetails_Insert]  -- Adde by Amar 04122023  -Shifted from [PRO].[InsertDataforAssetClassficationYes]

	EXEC PRO.COBORROWER_DEG_UPG_MARKING @TIMEKEY,'D' /*26102023 CO-BORROWER DEGRADE MARKING*/

	 UPDATE A SET DEGREASON=B.DEGREASON
	FROM PRO.AccountCal A INNER JOIN PRO.CustomerCal B ON A.SourceSystemCustomerID =B.SourceSystemCustomerID
	WHERE (B.FlgProcessing='N')  AND (A.FLGDEG='N') AND B.DegReason IS NOT NULL AND A.FinalAssetClassAlt_Key>1
	 AND A.DegReason IS NULL

UPDATE B SET B.FinalNpaDt=A.SYSNPA_DT FROM PRO.CUSTOMERCAL A INNER JOIN PRO.ACCOUNTCAL B  ON A.SourceSystemCustomerID=B.SourceSystemCustomerID
WHERE ISNULL(B.ASSET_NORM,'NORMAL')<>'ALWYS_STD' AND (ISNULL(A.FlgProcessing,'N')='N') 
and  isnull(A.SysNPA_Dt,'') <> isnull(b.FinalNpaDt,'') 
AND ISNULL(A.FlgDeg,'N')='N'
AND A.RefCustomerID<>'0'

/*---------------UPDATE ASSET CLASS STD WHERE ASSET NORM ALWAYS STD---------------*/


UPDATE A SET FinalAssetClassAlt_Key=1,FinalNpaDt=NULL, DEGREASON=NULL
 FROM PRO.AccountCal A WHERE A.ASSET_NORM ='ALWYS_STD'

 UPDATE A SET DEGREASON='SOURCE ' + ' ' + C.SOURCEDBNAME
 	 FROM PRO.AccountCal A 
	INNER JOIN DIMSOURCEDB  C ON C.SOURCEALT_KEY=A.SOURCEALT_KEY  AND C.EffectiveFromTimeKey<=@TIMEKEY AND C.EffectiveToTimeKey>=@TIMEKEY
	WHERE  (A.FLGDEG='N')  AND A.FinalAssetClassAlt_Key>1
	 AND A.DegReason IS NULL


	 
------PREPARE LIST OF ALL KCC ACCOUNT 17/02/2020 AS PER BANK POINT----

--IF OBJECT_ID('TEMPDB..#TEMPTABLEALLKCCAccounts') IS NOT NULL
--	    DROP TABLE #TEMPTABLEALLKCCAccounts


--select 
--SourceSystemCustomerID,'N' AS ExistingNpa
--into #TEMPTABLEALLKCCAccounts
--FROM PRO.ACCOUNTCAL A   

--INNER JOIN DimProduct C ON  A.ProductAlt_Key=C.ProductAlt_Key AND (C.EffectiveFromTimeKey<=@TIMEKEY AND C.EffectiveToTimeKey>=@TIMEKEY)
--WHERE (ISNULL(A.Asset_Norm,'NORMAL')<>'ALWYS_STD')
--AND ISNULL(A.FLGMOC,'N')<>'Y'
--AND (ISNULL(C.PRODUCTGROUP,'N')='KCC'
--OR ((LineCode LIKE '%CROP_OD_F%' or LineCode LIKE '%CROP_DLOD%' or LineCode LIKE '%CROP_TL_F%'))
--OR( (ACCOUNTSTATUS LIKE '%CROP LOAN (OTHER THAN PL%' OR ACCOUNTSTATUS LIKE '%CROP LOAN (PLANT N HORTI%' OR ACCOUNTSTATUS LIKE '%PRE AND POST-HARVEST ACT%'
-- OR ACCOUNTSTATUS LIKE '%FARMERS AGAINST HYPOTHEC%' OR ACCOUNTSTATUS LIKE '%FARMERS AGAINST PLEDGE O%' OR ACCOUNTSTATUS LIKE '%PLANTATION/HORTICULTURE%'
-- OR ACCOUNTSTATUS LIKE '%365_CROP LOAN_OTR THAN PL%'
-- OR ACCOUNTSTATUS LIKE '%365_CROP LOAN_PLANT/HORTI%'
-- OR ACCOUNTSTATUS LIKE '%365_DEVELOPMENTAL ACTIVI%'
-- OR ACCOUNTSTATUS LIKE '%365_LAND DEVELOPMENT%'
-- OR ACCOUNTSTATUS LIKE '%365_PLANTATION/HORTI%'
-- ))
--) AND A.FinalAssetClassAlt_Key>1


--  UPDATE A SET EXISTINGNPA='Y'
--  FROM #TEMPTABLEALLKCCACCOUNTS A
-- INNER JOIN CURDAT.ADVCUSTNPADETAIL B
--  ON A.SOURCESYSTEMCUSTOMERID=B.SOURCESYSTEMCUSTOMERID
--  WHERE (B.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND B.EFFECTIVETOTIMEKEY>=@TIMEKEY)

--  UPDATE B SET FINALASSETCLASSALT_KEY=1,FINALNPADT=NULL,DEGREASON=NULL
--	FROM #TEMPTABLEALLKCCACCOUNTS A
--   INNER JOIN PRO.ACCOUNTCAL B
--    ON A.SOURCESYSTEMCUSTOMERID=B.SOURCESYSTEMCUSTOMERID
--	WHERE A.EXISTINGNPA='N'	AND DPD_MAX >=0 AND DPD_MAX<=364---365 As per bank mail dated 05/04/2022 Degradation issue in kcc Product max dpd condition changed 
--	 AND  B.ASSET_NORM NOT IN ('ALWYS_NPA')

------PREPARE LIST OF ALL KCC ACCOUNT 17/02/2020 AS PER BANK POINT---- 

	 ---UPDATE  MULTIPLE   DegReason IN PRO.CUSTOMERCAL TABLE-------

	 IF object_id('TEMPDB..#Data') is NOT NULL
     DROP TABLE #Data

select distinct DegReason ,SourceSystemCustomerID  INTO #Data from PRO.AccountCal  WHERE DegReason IS NOT NULL AND FLGDEG='Y'
--and DegReason not like '%per%'

IF object_id('TEMPDB..#DD') is NOT NULL
DROP TABLE #DD

Select SourceSystemCustomerID ,DegReason ,ROW_NUMBER()OVER(PARTITION by SourceSystemCustomerID order by SourceSystemCustomerID) AS RN  INTO #DD  FROM #Data


IF object_id('TEMPDB..#NPADegReason') is NOT NULL
DROP TABLE #NPADegReason

SELECT SourceSystemCustomerID ,DegReason INTO #NPADegReason FROM
(
Select SourceSystemCustomerID,([1] +ISNULL(' ,'+[2],'') +ISNULL(' ,' + [3],'')   +ISNULL(' ,' + [4],'')  +ISNULL(' ,' + [5],'')  +ISNULL(' ,' + [6],'')
+ISNULL(' ,' + [7],'')  +ISNULL(' ,' + [8],'')  +ISNULL(' ,' + [9],'')  +ISNULL(' ,' + [10],'')  +ISNULL(' ,' + [11],'')  +ISNULL(' ,' + [12],'')
+ISNULL(' ,' + [13],'')  +ISNULL(' ,' + [14],'')  +ISNULL(' ,' + [15],'')  +ISNULL(' ,' + [16],'')  +ISNULL(' ,' + [17],'')) AS DegReason
FROM(
Select SourceSystemCustomerID, DegReason,  RN FROM #DD  )a 
PIVOT 
(
MAX(DegReason)  FOR RN IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17])
) S
) A


UPDATE A SET DegReason=B.DegReason  FROM PRO.CustomerCal A INNER JOIN #NPADegReason B  ON A.SourceSystemCustomerID=B.SourceSystemCustomerID
AND A.FlgDeg='Y'


--Changed by Triloki 28-01-22 /30-11-2022 for Quarter End

IF (	 (MONTH(@PROCESSDATE) IN(3,12) AND DAY(@PROCESSDATE)=31)
	  OR (MONTH(@PROCESSDATE) IN(6,9)  AND DAY(@PROCESSDATE)=30)
	)
BEGIN

UPDATE A SET A.DEGREASON= ISNULL(A.DEGREASON,'')+', DEGRADE BY EROSION'            
FROM PRO.AccountCal A INNER JOIN PRO.CustomerCal B ON A.CustomerEntityID =B.CustomerEntityID
WHERE b.FlgErosion='Y'  and A.DEGREASON not like '%EROSION%'


UPDATE B SET B.DEGREASON= ISNULL(B.DEGREASON,'')+', DEGRADE BY EROSION'            
FROM PRO.AccountCal A INNER JOIN PRO.CustomerCal B ON A.CustomerEntityID =B.CustomerEntityID
WHERE b.FlgErosion='Y'  and B.DEGREASON not like '%EROSION%'

End

UPDATE B SET B.FinalAssetClassAlt_Key=A.FinalAssetClassAlt_Key ---- UPDATE FINAL ASSET IN FRAUD TABLE after percolation 2022-12-06 -- Amar sir,Pranay
FROM PRO.ACCOUNTCAL A 
INNER JOIN FraudAccountsDetails B
ON A.CustomerAcID=B.CustomerAcID





UPDATE PRO.ACLRUNNINGPROCESSSTATUS 
	SET COMPLETED='Y',ERRORDATE=NULL,ERRORDESCRIPTION=NULL,COUNT=ISNULL(COUNT,0)+1
	WHERE RUNNINGPROCESSNAME='Final_AssetClass_Npadate'

   DROP TABLE #TempNewPERCOLATION
   DROP TABLE #TEMPTABLE_UCFIC1
   DROP TABLE #TEMPTABLE_UCFICDbtDt
   DROP TABLE #TempTableRefCustomerID
   DROP TABLE #Data
   DROP TABLE #DD
   DROP TABLE #NPADegReason

 
END TRY
BEGIN  CATCH
	
	UPDATE PRO.ACLRUNNINGPROCESSSTATUS 
	SET COMPLETED='N',ERRORDATE=GETDATE(),ERRORDESCRIPTION=ERROR_MESSAGE(),COUNT=ISNULL(COUNT,0)+1
	WHERE RUNNINGPROCESSNAME='Final_AssetClass_Npadate'
END CATCH
SET NOCOUNT OFF
END












GO