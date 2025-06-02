SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


--===============================================================================================
-- Created by       : Amar
-- Created Date     : 30-Jul-2018
-- Description      : 
-- Form/Report Name :	For insert data in Promoc customer and account table for moc timekey 
--						(only once - if processe execute mnore than once then only first time 
--						will be insert data in premoc) 
--===============================================================================================

--===============================================================================================
--===============================  ALTER HISTORY ================================================
--===============================================================================================
--       Name             Date                    Reason                       Change
-- 1.  
-- 2.  
-- 3.  
--===============================================================================================
/*
  Hard Coded Fields Description: 
                                  Feild Name              Value             Significance
                               1. 
                               2. 
                               3. 


*/

-- 


create PROCEDURE [pro].[DataShiftingintoArchiveandPremocTable] 
	@TimeKey INT
AS
BEGIN
--print @TimeKey
      BEGIN TRY
INSERT INTO [PreMoc].[AccountCal] 
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
,ACCOUNTSTATUSDebitFreeze
,FlgRestructure	
,Buyout_Code
,CreditAmt
,DebitAmt
,UnserviedInt
)
SELECT      

 AcCal.AccountEntityID
,AcCal.UcifEntityID
,AcCal.CustomerEntityID
,AcCal.CustomerAcID
,AcCal.RefCustomerID
,AcCal.SourceSystemCustomerID
,AcCal.UCIF_ID
,AcCal.BranchCode
,AcCal.FacilityType
,AcCal.AcOpenDt
,AcCal.FirstDtOfDisb
,AcCal.ProductAlt_Key
,AcCal.SchemeAlt_key
,AcCal.SubSectorAlt_Key
,AcCal.SplCatg1Alt_Key
,AcCal.SplCatg2Alt_Key
,AcCal.SplCatg3Alt_Key
,AcCal.SplCatg4Alt_Key
,AcCal.SourceAlt_Key
,AcCal.ActSegmentCode
,AcCal.InttRate
,AcCal.Balance
,AcCal.BalanceInCrncy
,AcCal.CurrencyAlt_Key
,AcCal.DrawingPower
,AcCal.CurrentLimit
,AcCal.CurrentLimitDt
,AcCal.ContiExcessDt
,AcCal.StockStDt
,AcCal.DebitSinceDt
,AcCal.LastCrDate
,AcCal.InttServiced
,AcCal.IntNotServicedDt
,AcCal.OverdueAmt
,AcCal.OverDueSinceDt
,AcCal.ReviewDueDt
,AcCal.SecurityValue
,AcCal.DFVAmt
,AcCal.GovtGtyAmt
,AcCal.CoverGovGur
,AcCal.WriteOffAmount
,AcCal.UnAdjSubSidy
,AcCal.CreditsinceDt
,AcCal.DPD_IntService
,AcCal.DPD_NoCredit
,AcCal.DPD_Overdrawn
,AcCal.DPD_Overdue
,AcCal.DPD_Renewal
,AcCal.DPD_StockStmt
,AcCal.DPD_Max
,AcCal.DPD_FinMaxType
,AcCal.DegReason
,AcCal.Asset_Norm
,AcCal.REFPeriodMax
,AcCal.RefPeriodOverdue
,AcCal.RefPeriodOverDrawn
,AcCal.RefPeriodNoCredit
,AcCal.RefPeriodIntService
,AcCal.RefPeriodStkStatement
,AcCal.RefPeriodReview
,AcCal.NetBalance
,AcCal.ApprRV
,AcCal.SecuredAmt
,AcCal.UnSecuredAmt
,AcCal.ProvDFV
,AcCal.Provsecured
,AcCal.ProvUnsecured
,AcCal.ProvCoverGovGur
,AcCal.AddlProvision
,AcCal.TotalProvision
,AcCal.BankProvsecured
,AcCal.BankProvUnsecured
,AcCal.BankTotalProvision
,AcCal.RBIProvsecured
,AcCal.RBIProvUnsecured
,AcCal.RBITotalProvision
,AcCal.InitialNpaDt
,AcCal.FinalNpaDt
,AcCal.SMA_Dt
,AcCal.UpgDate
,AcCal.InitialAssetClassAlt_Key
,AcCal.FinalAssetClassAlt_Key
,AcCal.ProvisionAlt_Key
,AcCal.PNPA_Reason
,AcCal.SMA_Class
,AcCal.SMA_Reason
,AcCal.FlgMoc
,AcCal.MOC_Dt
,AcCal.CommonMocTypeAlt_Key
,AcCal.DPD_SMA
,AcCal.FlgDeg
,AcCal.FlgDirtyRow
,AcCal.FlgInMonth
,AcCal.FlgSMA
,AcCal.FlgPNPA
,AcCal.FlgUpg
,AcCal.FlgFITL
,AcCal.FlgAbinitio
,AcCal.NPA_Days
,AcCal.RefPeriodOverdueUPG
,AcCal.RefPeriodOverDrawnUPG
,AcCal.RefPeriodNoCreditUPG
,AcCal.RefPeriodIntServiceUPG
,AcCal.RefPeriodStkStatementUPG
,AcCal.RefPeriodReviewUPG
,AcCal.EffectiveFromTimeKey
,AcCal.EffectiveToTimeKey
,AcCal.AppGovGur
,AcCal.UsedRV
,AcCal.ComputedClaim
,AcCal.UPG_RELAX_MSME
,AcCal.DEG_RELAX_MSME
,AcCal.PNPA_DATE
,AcCal.NPA_Reason
,AcCal.PnpaAssetClassAlt_key
,AcCal.DisbAmount
,AcCal.PrincOutStd
,AcCal.PrincOverdue
,AcCal.PrincOverdueSinceDt
,AcCal.DPD_PrincOverdue
,AcCal.IntOverdue
,AcCal.IntOverdueSinceDt
,AcCal.DPD_IntOverdueSince
,AcCal.OtherOverdue
,AcCal.OtherOverdueSinceDt
,AcCal.DPD_OtherOverdueSince
,AcCal.RelationshipNumber
,AcCal.AccountFlag
,AcCal.CommercialFlag_AltKey
,AcCal.Liability
,AcCal.CD
,AcCal.AccountStatus
,AcCal.AccountBlkCode1
,AcCal.AccountBlkCode2
,AcCal.ExposureType
,AcCal.Mtm_Value
,AcCal.BankAssetClass
,AcCal.NpaType
,AcCal.SecApp
,AcCal.BorrowerTypeID
,AcCal.LineCode
,AcCal.ProvPerSecured
,AcCal.ProvPerUnSecured
,AcCal.MOCReason
,AcCal.AddlProvisionPer
,AcCal.FlgINFRA
,AcCal.RepossessionDate	
,AcCal.DATEOFDATA
,AcCal.DerecognisedInterest1
,AcCal.DerecognisedInterest2
,AcCal.ProductCode
,AcCal.FlgLCBG
,AcCal.ACCOUNTSTATUSDebitFreeze
,AcCal.FlgRestructure	
,AcCal.Buyout_Code
,AcCal.CreditAmt
,AcCal.DebitAmt
,AcCal.UnserviedInt
FROM    PRO.AccountCal_Hist AS AcCal INNER JOIN
		PRO.AccountCal AS AcCurnt ON AcCal.EffectiveFromTimeKey <= @TimeKey AND AcCal.EffectiveToTimeKey >= @TimeKey AND AcCal.AccountEntityID = AcCurnt.AccountEntityID
WHERE       NOT EXISTS
(SELECT        1 AS Expr1
FROM            PreMoc.Accountcal
WHERE        (AccountEntityID = AcCal.AccountEntityID) AND (EffectiveFromTimeKey <= @TimeKey) AND (EffectiveToTimeKey >= @TimeKey))

 					---=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=INSERT DATA IN PREMOC CUSTOMERCALCAL-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
INSERT INTO [PreMoc].[CustomerCal]
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
,CustomerPartnerSegment
	)
SELECT        
 CustCal.BranchCode
,CustCal.UCIF_ID
,CustCal.UcifEntityID
,CustCal.CustomerEntityID
,CustCal.ParentCustomerID
,CustCal.RefCustomerID
,CustCal.SourceSystemCustomerID
,CustCal.CustomerName
,CustCal.CustSegmentCode
,CustCal.ConstitutionAlt_Key
,CustCal.PANNO
,CustCal.AadharCardNO
,CustCal.SrcAssetClassAlt_Key
,CustCal.SysAssetClassAlt_Key
,CustCal.SplCatg1Alt_Key
,CustCal.SplCatg2Alt_Key
,CustCal.SplCatg3Alt_Key
,CustCal.SplCatg4Alt_Key
,CustCal.SMA_Class_Key
,CustCal.PNPA_Class_Key
,CustCal.PrvQtrRV
,CustCal.CurntQtrRv
,CustCal.TotProvision
,CustCal.RBITotProvision
,CustCal.BankTotProvision
,CustCal.SrcNPA_Dt
,CustCal.SysNPA_Dt
,CustCal.DbtDt
,CustCal.DbtDt2
,CustCal.DbtDt3
,CustCal.LossDt
,CustCal.MOC_Dt
,CustCal.ErosionDt
,CustCal.SMA_Dt
,CustCal.PNPA_Dt
,CustCal.ProcessingDt
,CustCal.Asset_Norm
,CustCal.FlgDeg
,CustCal.FlgUpg
,CustCal.FlgMoc
,CustCal.FlgSMA
,CustCal.FlgProcessing
,CustCal.FlgErosion
,CustCal.FlgPNPA
,CustCal.FlgPercolation
,CustCal.FlgInMonth
,CustCal.FlgDirtyRow
,CustCal.DegDate
,CustCal.EffectiveFromTimeKey
,CustCal.EffectiveToTimeKey
,CustCal.CommonMocTypeAlt_Key
,CustCal.InMonthMark
,CustCal.MocStatusMark
,CustCal.SourceAlt_Key
,CustCal.BankAssetClass
,CustCal.Cust_Expo
,CustCal.MOCReason
,CustCal.AddlProvisionPer
,CustCal.FraudDt
,CustCal.FraudAmount
,CustCal.DegReason
,CUSTCAL.IMAXID_CCube
,CUSTCAL.DATEOFDATA
,CUSTCAL.CustMoveDescription
,CUSTCAL.TotOsCust
,CUSTCAL.MOCTYPE
,CUSTCAL.CustomerPartnerSegment
FROM   PRO.CustomerCal_Hist AS CustCal INNER JOIN
PRO.CustomerCal AS CustCurnt ON CustCal.EffectiveFromTimeKey <= @TimeKey AND CustCal.EffectiveToTimeKey >= @TimeKey AND CustCal.CustomerEntityID = CustCurnt.CustomerEntityID
WHERE        NOT EXISTS
(SELECT        1 AS Expr1
FROM            PreMoc.CustomerCal
WHERE        (CustomerEntityID = CustCal.CustomerEntityID) AND (EffectiveFromTimeKey <= @TimeKey) AND (EffectiveToTimeKey >= @TimeKey))
	  END TRY

	  BEGIN CATCH
	                 SELECT 'Proc Name: ' + ISNULL(ERROR_PROCEDURE(),'') + ' ErrorMsg: ' + ISNULL(ERROR_MESSAGE(),'')
	  END CATCH
END




GO