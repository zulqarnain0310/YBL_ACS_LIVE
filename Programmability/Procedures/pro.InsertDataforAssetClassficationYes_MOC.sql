SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROCEDURE [pro].[InsertDataforAssetClassficationYes_MOC]
@TIMEKEY INT
AS
BEGIN
  DECLARE @PROCESSINGDATE DATE=(SELECT DATE FROM SYSDAYMATRIX WHERE TIMEKEY=@TIMEKEY)

 DECLARE @SetID INT =(SELECT ISNULL(MAX(ISNULL(SETID,0)),0)+1 FROM [PRO].[ProcessMonitor] WHERE TimeKey=@TIMEKEY )

 SET @TIMEKEY= (SELECT LASTQTRDATEKEY FROM SYSDAYMATRIX WHERE TIMEKEY=@TIMEKEY)
 			


TRUNCATE TABLE PRO.CUSTOMERCAL

TRUNCATE TABLE PRO.ACCOUNTCAL


IF OBJECT_ID('Tempdb..#CustMocData') IS NOT NULL
	DROP TABLE #CustMocData

	SELECT DISTINCT SourceSystemCustomerID  INTO #CustMocData	FROM DataUpload.MocCustomerDataUpload WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
	
	
    INSERT INTO #CustMocData

	SELECT SourceSystemCustomerID FROM 
	(
	SELECT DISTINCT  SourceSystemCustomerID FROM DataUpload.MocAccountDataUpload where (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
	EXCEPT
	SELECT DISTINCT SourceSystemCustomerID  FROM #CustMocData
	) A
	

;WITH CTE_CUSTCAL
	AS
(	SELECT A.* 
 FROM PRO.CUSTOMERCAL_HIST A
	INNER JOIN #CustMocData B
		ON (A.EffectiveFromTimeKey=@TimeKey AND A.EffectiveToTimeKey=@TimeKey)
		AND A.SourceSystemCustomerID=B.SourceSystemCustomerID
 )


INSERT INTO PRO.CUSTOMERCAL
(
BranchCode
,UCIF_ID
,UcifEntityID
,CustomerEntityID
,ParentCustomerID
,RefCustomerID
,SourceSystemCustomerID
,CustomerName
,CustSegmentCode
,ConstitutionAlt_Key
,PANNO
,AadharCardNO
,SrcAssetClassAlt_Key
,SysAssetClassAlt_Key
,SplCatg1Alt_Key
,SplCatg2Alt_Key
,SplCatg3Alt_Key
,SplCatg4Alt_Key
,SMA_Class_Key
,PNPA_Class_Key
,PrvQtrRV
,CurntQtrRv
,TotProvision
,RBITotProvision
,BankTotProvision
,SrcNPA_Dt
,SysNPA_Dt
,DbtDt
,DbtDt2
,DbtDt3
,LossDt
,MOC_Dt
,ErosionDt
,SMA_Dt
,PNPA_Dt
,ProcessingDt
,Asset_Norm
,FlgDeg
,FlgUpg
,FlgMoc
,FlgSMA
,FlgProcessing
,FlgErosion
,FlgPNPA
,FlgPercolation
,FlgInMonth
,FlgDirtyRow
,DegDate
,EffectiveFromTimeKey
,EffectiveToTimeKey
,CommonMocTypeAlt_Key
,InMonthMark
,MocStatusMark
,SourceAlt_Key
,BankAssetClass
,Cust_Expo
,MOCReason
,AddlProvisionPer
,FraudDt
,FraudAmount
,DegReason
,IMAXID_CCube
,DATEOFDATA
,CustMoveDescription
,TotOsCust
,MOCTYPE
)
SELECT 

 A.BranchCode
,A.UCIF_ID
,A.UcifEntityID
,A.CustomerEntityID
,A.ParentCustomerID
,A.RefCustomerID
,A.SourceSystemCustomerID
,A.CustomerName
,A.CustSegmentCode
,A.ConstitutionAlt_Key
,A.PANNO
,A.AadharCardNO
,A.SrcAssetClassAlt_Key
,A.SysAssetClassAlt_Key
,A.SplCatg1Alt_Key
,A.SplCatg2Alt_Key
,A.SplCatg3Alt_Key
,A.SplCatg4Alt_Key
,A.SMA_Class_Key
,A.PNPA_Class_Key
,A.PrvQtrRV
,A.CurntQtrRv
,A.TotProvision
,A.RBITotProvision
,A.BankTotProvision
,A.SrcNPA_Dt
,A.SysNPA_Dt
,A.DbtDt
,A.DbtDt2
,A.DbtDt3
,A.LossDt
,A.MOC_Dt
,A.ErosionDt
,A.SMA_Dt
,A.PNPA_Dt
,A.ProcessingDt
,A.Asset_Norm
,A.FlgDeg
,A.FlgUpg
,A.FlgMoc
,A.FlgSMA
,A.FlgProcessing
,A.FlgErosion
,A.FlgPNPA
,A.FlgPercolation
,A.FlgInMonth
,A.FlgDirtyRow
,A.DegDate
,A.EffectiveFromTimeKey
,A.EffectiveToTimeKey
,A.CommonMocTypeAlt_Key
,A.InMonthMark
,A.MocStatusMark
,A.SourceAlt_Key
,A.BankAssetClass
,A.Cust_Expo
,A.MOCReason
,A.AddlProvisionPer
,A.FraudDt
,A.FraudAmount
,A.DegReason
,A.IMAXID_CCube
,A.DATEOFDATA
,A.CustMoveDescription
,A.TotOsCust
,A.MOCTYPE
FROM CTE_CUSTCAL A


;WITH CTE_ACCOUNTCAL
AS
	(SELECT A.* FROM PRO.AccountCal_Hist A
		INNER JOIN #CustMocData B
		ON (A.EffectiveFromTimeKey=@TimeKey AND A.EffectiveToTimeKey=@TimeKey)
		AND A.SourceSystemCustomerID=B.SourceSystemCustomerID
	)


INSERT INTO PRO.ACCOUNTCAL
(
 
AccountEntityID
,UcifEntityID
,CustomerEntityID
,CustomerAcID
,RefCustomerID
,SourceSystemCustomerID
,UCIF_ID
,BranchCode
,FacilityType
,AcOpenDt
,FirstDtOfDisb
,ProductAlt_Key
,SchemeAlt_key
,SubSectorAlt_Key
,SplCatg1Alt_Key
,SplCatg2Alt_Key
,SplCatg3Alt_Key
,SplCatg4Alt_Key
,SourceAlt_Key
,ActSegmentCode
,InttRate
,Balance
,BalanceInCrncy
,CurrencyAlt_Key
,DrawingPower
,CurrentLimit
,CurrentLimitDt
,ContiExcessDt
,StockStDt
,DebitSinceDt
,LastCrDate
,InttServiced
,IntNotServicedDt
,OverdueAmt
,OverDueSinceDt
,ReviewDueDt
,SecurityValue
,DFVAmt
,GovtGtyAmt
,CoverGovGur
,WriteOffAmount
,UnAdjSubSidy
,CreditsinceDt
,DPD_IntService
,DPD_NoCredit
,DPD_Overdrawn
,DPD_Overdue
,DPD_Renewal
,DPD_StockStmt
,DPD_Max
,DPD_FinMaxType
,DegReason
,Asset_Norm
,REFPeriodMax
,RefPeriodOverdue
,RefPeriodOverDrawn
,RefPeriodNoCredit
,RefPeriodIntService
,RefPeriodStkStatement
,RefPeriodReview
,NetBalance
,ApprRV
,SecuredAmt
,UnSecuredAmt
,ProvDFV
,Provsecured
,ProvUnsecured
,ProvCoverGovGur
,AddlProvision
,TotalProvision
,BankProvsecured
,BankProvUnsecured
,BankTotalProvision
,RBIProvsecured
,RBIProvUnsecured
,RBITotalProvision
,InitialNpaDt
,FinalNpaDt
,SMA_Dt
,UpgDate
,InitialAssetClassAlt_Key
,FinalAssetClassAlt_Key
,ProvisionAlt_Key
,PNPA_Reason
,SMA_Class
,SMA_Reason
,FlgMoc
,MOC_Dt
,CommonMocTypeAlt_Key
,DPD_SMA
,FlgDeg
,FlgDirtyRow
,FlgInMonth
,FlgSMA
,FlgPNPA
,FlgUpg
,FlgFITL
,FlgAbinitio
,NPA_Days
,RefPeriodOverdueUPG
,RefPeriodOverDrawnUPG
,RefPeriodNoCreditUPG
,RefPeriodIntServiceUPG
,RefPeriodStkStatementUPG
,RefPeriodReviewUPG
,EffectiveFromTimeKey
,EffectiveToTimeKey
,AppGovGur
,UsedRV
,ComputedClaim
,UPG_RELAX_MSME
,DEG_RELAX_MSME
,PNPA_DATE
,NPA_Reason
,PnpaAssetClassAlt_key
,DisbAmount
,PrincOutStd
,PrincOverdue
,PrincOverdueSinceDt
,DPD_PrincOverdue
,IntOverdue
,IntOverdueSinceDt
,DPD_IntOverdueSince
,OtherOverdue
,OtherOverdueSinceDt
,DPD_OtherOverdueSince
,RelationshipNumber
,AccountFlag
,CommercialFlag_AltKey
,Liability
,CD
,AccountStatus
,AccountBlkCode1
,AccountBlkCode2
,ExposureType
,Mtm_Value
,BankAssetClass
,NpaType
,SecApp
,BorrowerTypeID
,LineCode
,ProvPerSecured
,ProvPerUnSecured
,MOCReason
,AddlProvisionPer
,FlgINFRA
,RepossessionDate
,DATEOFDATA
,DerecognisedInterest1
,DerecognisedInterest2
,ProductCode
,FlgLCBG
)

SELECT 

 A.AccountEntityID
,A.UcifEntityID
,A.CustomerEntityID
,A.CustomerAcID
,A.RefCustomerID
,A.SourceSystemCustomerID
,A.UCIF_ID
,A.BranchCode
,A.FacilityType
,A.AcOpenDt
,A.FirstDtOfDisb
,A.ProductAlt_Key
,A.SchemeAlt_key
,A.SubSectorAlt_Key
,A.SplCatg1Alt_Key
,A.SplCatg2Alt_Key
,A.SplCatg3Alt_Key
,A.SplCatg4Alt_Key
,A.SourceAlt_Key
,A.ActSegmentCode
,A.InttRate
,A.Balance
,A.BalanceInCrncy
,A.CurrencyAlt_Key
,A.DrawingPower
,A.CurrentLimit
,A.CurrentLimitDt
,A.ContiExcessDt
,A.StockStDt
,A.DebitSinceDt
,A.LastCrDate
,A.InttServiced
,A.IntNotServicedDt
,A.OverdueAmt
,A.OverDueSinceDt
,A.ReviewDueDt
,A.SecurityValue
,A.DFVAmt
,A.GovtGtyAmt
,A.CoverGovGur
,A.WriteOffAmount
,A.UnAdjSubSidy
,A.CreditsinceDt
,A.DPD_IntService
,A.DPD_NoCredit
,A.DPD_Overdrawn
,A.DPD_Overdue
,A.DPD_Renewal
,A.DPD_StockStmt
,A.DPD_Max
,A.DPD_FinMaxType
,A.DegReason
,A.Asset_Norm
,A.REFPeriodMax
,A.RefPeriodOverdue
,A.RefPeriodOverDrawn
,A.RefPeriodNoCredit
,A.RefPeriodIntService
,A.RefPeriodStkStatement
,A.RefPeriodReview
,A.NetBalance
,A.ApprRV
,A.SecuredAmt
,A.UnSecuredAmt
,A.ProvDFV
,A.Provsecured
,A.ProvUnsecured
,A.ProvCoverGovGur
,A.AddlProvision
,A.TotalProvision
,A.BankProvsecured
,A.BankProvUnsecured
,A.BankTotalProvision
,A.RBIProvsecured
,A.RBIProvUnsecured
,A.RBITotalProvision
,A.InitialNpaDt
,A.FinalNpaDt
,A.SMA_Dt
,A.UpgDate
,A.InitialAssetClassAlt_Key
,A.FinalAssetClassAlt_Key
,A.ProvisionAlt_Key
,A.PNPA_Reason
,A.SMA_Class
,A.SMA_Reason
,A.FlgMoc
,A.MOC_Dt
,A.CommonMocTypeAlt_Key
,A.DPD_SMA
,A.FlgDeg
,A.FlgDirtyRow
,A.FlgInMonth
,A.FlgSMA
,A.FlgPNPA
,A.FlgUpg
,A.FlgFITL
,A.FlgAbinitio
,A.NPA_Days
,A.RefPeriodOverdueUPG
,A.RefPeriodOverDrawnUPG
,A.RefPeriodNoCreditUPG
,A.RefPeriodIntServiceUPG
,A.RefPeriodStkStatementUPG
,A.RefPeriodReviewUPG
,A.EffectiveFromTimeKey
,A.EffectiveToTimeKey
,A.AppGovGur
,A.UsedRV
,A.ComputedClaim
,A.UPG_RELAX_MSME
,A.DEG_RELAX_MSME
,A.PNPA_DATE
,A.NPA_Reason
,A.PnpaAssetClassAlt_key
,A.DisbAmount
,A.PrincOutStd
,A.PrincOverdue
,A.PrincOverdueSinceDt
,A.DPD_PrincOverdue
,A.IntOverdue
,A.IntOverdueSinceDt
,A.DPD_IntOverdueSince
,A.OtherOverdue
,A.OtherOverdueSinceDt
,A.DPD_OtherOverdueSince
,A.RelationshipNumber
,A.AccountFlag
,A.CommercialFlag_AltKey
,A.Liability
,A.CD
,A.AccountStatus
,A.AccountBlkCode1
,A.AccountBlkCode2
,A.ExposureType
,A.Mtm_Value
,A.BankAssetClass
,A.NpaType
,A.SecApp
,A.BorrowerTypeID
,A.LineCode
,A.ProvPerSecured
,A.ProvPerUnSecured
,A.MOCReason
,A.AddlProvisionPer
,A.FlgINFRA
,A.RepossessionDate
,A.DATEOFDATA
,A.DerecognisedInterest1
,A.DerecognisedInterest2
,A.ProductCode
,A.FlgLCBG
FROM CTE_ACCOUNTCAL A




UPDATE A SET A.SYSASSETCLASSALT_KEY=DA.ASSETCLASSALT_KEY,A.SYSNPA_DT=B.NPADATE,A.FLGMOC='Y',A.ASSET_NORM='ALWYS_NPA',A.MOCREASON=B.MOCREASON,DEGREASON='NPA DUE TO MOC',A.MOC_DT=B.DATECREATED,A.MOCTYPE=B.MOCTYPE
       FROM PRO.CUSTOMERCAL A
 INNER JOIN DATAUPLOAD.MOCCUSTOMERDATAUPLOAD B ON A.REFCUSTOMERID=B.CUSTOMERID
     INNER JOIN DIMASSETCLASS DA       ON  DA.ASSETCLASSSHORTNAME= B.ASSETCLASSIFICATION AND
                           DA.ASSETCLASSSHORTNAME<>'STD' AND  
                           DA.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND
                   DA.EFFECTIVETOTIMEKEY>=@TIMEKEY
WHERE B.MOCTYPE='MANUAL' AND B.EFFECTIVETOTIMEKEY=49999

UPDATE A SET A.SYSASSETCLASSALT_KEY=DA.ASSETCLASSALT_KEY,A.SYSNPA_DT=B.NPADATE,A.FLGMOC='Y',A.ASSET_NORM='NORMAL',A.MOCREASON=B.MOCREASON,DEGREASON='NPA DUE TO MOC',A.MOC_DT=B.DATECREATED,A.MOCTYPE=B.MOCTYPE
FROM PRO.CUSTOMERCAL A
INNER JOIN DATAUPLOAD.MOCCUSTOMERDATAUPLOAD B ON A.REFCUSTOMERID=B.CUSTOMERID
    INNER JOIN DIMASSETCLASS DA       ON  DA.ASSETCLASSSHORTNAME= B.ASSETCLASSIFICATION AND
                           DA.ASSETCLASSSHORTNAME<>'STD' AND  
                           DA.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND
                   DA.EFFECTIVETOTIMEKEY>=@TIMEKEY
WHERE B.MOCTYPE='AUTO' AND  B.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND  B.EFFECTIVETOTIMEKEY>=@TIMEKEY


UPDATE A SET A.SYSASSETCLASSALT_KEY=DA.ASSETCLASSALT_KEY,A.SYSNPA_DT=NULL,A.DBTDT =NULL,A.FLGMOC='Y',A.ASSET_NORM='ALWYS_STD',A.MOCREASON=B.MOCREASON,DEGREASON='STD DUE TO MOC',A.MOC_DT=B.DATECREATED,A.MOCTYPE=B.MOCTYPE
 FROM PRO.CUSTOMERCAL A
INNER JOIN DATAUPLOAD.MOCCUSTOMERDATAUPLOAD B ON A.REFCUSTOMERID=B.CUSTOMERID
  INNER JOIN DIMASSETCLASS DA       ON  DA.ASSETCLASSSHORTNAME= B.ASSETCLASSIFICATION AND
                           DA.ASSETCLASSSHORTNAME='STD' AND  
                           DA.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND
                   DA.EFFECTIVETOTIMEKEY>=@TIMEKEY
WHERE B.MOCTYPE='MANUAL' AND B.EFFECTIVETOTIMEKEY=49999

UPDATE A SET A.SYSASSETCLASSALT_KEY=DA.ASSETCLASSALT_KEY,A.SYSNPA_DT=NULL,A.DBTDT =NULL,A.FLGMOC='Y',A.ASSET_NORM='NORMAL',A.MOCREASON=B.MOCREASON,DEGREASON='STD DUE TO MOC',A.MOC_DT=B.DATECREATED,A.MOCTYPE=B.MOCTYPE
 FROM PRO.CUSTOMERCAL A
INNER JOIN DATAUPLOAD.MOCCUSTOMERDATAUPLOAD B ON A.REFCUSTOMERID=B.CUSTOMERID
 INNER JOIN DIMASSETCLASS DA       ON  DA.ASSETCLASSSHORTNAME= B.ASSETCLASSIFICATION AND
                           DA.ASSETCLASSSHORTNAME='STD' AND  
                           DA.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND
                   DA.EFFECTIVETOTIMEKEY>=@TIMEKEY
WHERE B.MOCTYPE='AUTO' AND  B.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND  B.EFFECTIVETOTIMEKEY>=@TIMEKEY


UPDATE A SET A.FinalAssetClassAlt_Key=DA.ASSETCLASSALT_KEY,A.FinalNpaDt=B.NPADATE,A.FlgMoc='Y',A.ASSET_NORM='ALWYS_NPA',A.MOCREASON=B.MOCREASON,DEGREASON='NPA DUE TO MOC',A.MOC_DT=B.DATECREATED
       FROM PRO.ACCOUNTCAL A
 INNER JOIN DATAUPLOAD.MOCCUSTOMERDATAUPLOAD B ON A.REFCUSTOMERID=B.CUSTOMERID
     INNER JOIN DIMASSETCLASS DA       ON  DA.ASSETCLASSSHORTNAME= B.ASSETCLASSIFICATION AND
                           DA.ASSETCLASSSHORTNAME<>'STD' AND  
                           DA.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND
                   DA.EFFECTIVETOTIMEKEY>=@TIMEKEY
WHERE B.MOCTYPE='MANUAL' AND B.EFFECTIVETOTIMEKEY=49999

UPDATE A SET A.FinalAssetClassAlt_Key=DA.ASSETCLASSALT_KEY,A.FinalNpaDt=B.NPADATE,A.FLGMOC='Y',A.ASSET_NORM='NORMAL',A.MOCREASON=B.MOCREASON,DEGREASON='NPA DUE TO MOC',A.MOC_DT=B.DATECREATED
FROM PRO.ACCOUNTCAL A
INNER JOIN DATAUPLOAD.MOCCUSTOMERDATAUPLOAD B ON A.REFCUSTOMERID=B.CUSTOMERID
    INNER JOIN DIMASSETCLASS DA       ON  DA.ASSETCLASSSHORTNAME= B.ASSETCLASSIFICATION AND
                           DA.ASSETCLASSSHORTNAME<>'STD' AND  
                           DA.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND
                   DA.EFFECTIVETOTIMEKEY>=@TIMEKEY
WHERE B.MOCTYPE='AUTO' AND  B.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND  B.EFFECTIVETOTIMEKEY>=@TIMEKEY


UPDATE A SET A.FinalAssetClassAlt_Key=DA.ASSETCLASSALT_KEY,A.FinalNpaDt=NULL,A.FLGMOC='Y',A.ASSET_NORM='ALWYS_STD',A.MOCREASON=B.MOCREASON,DEGREASON='STD DUE TO MOC',A.MOC_DT=B.DATECREATED
 FROM PRO.ACCOUNTCAL A
INNER JOIN DATAUPLOAD.MOCCUSTOMERDATAUPLOAD B ON A.REFCUSTOMERID=B.CUSTOMERID
  INNER JOIN DIMASSETCLASS DA       ON  DA.ASSETCLASSSHORTNAME= B.ASSETCLASSIFICATION AND
                           DA.ASSETCLASSSHORTNAME='STD' AND  
                           DA.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND
                   DA.EFFECTIVETOTIMEKEY>=@TIMEKEY
WHERE B.MOCTYPE='MANUAL' AND B.EFFECTIVETOTIMEKEY=49999

UPDATE A SET A.FinalAssetClassAlt_Key=DA.ASSETCLASSALT_KEY,A.FinalNpaDt=NULL,A.FLGMOC='Y',A.ASSET_NORM='NORMAL',A.MOCREASON=B.MOCREASON,DEGREASON='STD DUE TO MOC',A.MOC_DT=B.DATECREATED
 FROM PRO.ACCOUNTCAL A
INNER JOIN DATAUPLOAD.MOCCUSTOMERDATAUPLOAD B ON A.REFCUSTOMERID=B.CUSTOMERID
 INNER JOIN DIMASSETCLASS DA       ON  DA.ASSETCLASSSHORTNAME= B.ASSETCLASSIFICATION AND
                           DA.ASSETCLASSSHORTNAME='STD' AND  
                           DA.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND
                   DA.EFFECTIVETOTIMEKEY>=@TIMEKEY
WHERE B.MOCTYPE='AUTO' AND  B.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND  B.EFFECTIVETOTIMEKEY>=@TIMEKEY



UPDATE  A SET DBTDT=@PROCESSINGDATE FROM PRO.CUSTOMERCAL A  
INNER JOIN DIMASSETCLASS DA       ON  DA.ASSETCLASSALT_KEY= A.SYSASSETCLASSALT_KEY AND
                           DA.ASSETCLASSSHORTNAME IN ('DB1','DB2','DB3') AND  
                           DA.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND
                   DA.EFFECTIVETOTIMEKEY>=@TIMEKEY
WHERE DBTDT IS NULL

UPDATE DATAUPLOAD.MOCCUSTOMERDATAUPLOAD SET EFFECTIVETOTIMEKEY=EFFECTIVEFROMTIMEKEY WHERE MOCTYPE='AUTO'



DROP TABLE #CustMocData


END



GO