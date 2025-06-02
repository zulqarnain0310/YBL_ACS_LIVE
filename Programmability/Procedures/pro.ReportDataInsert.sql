SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



/*=========================================
AUTHER : TRILOKI KHANNA
CREATE DATE : 25-10-2022
MODIFY DATE :
DESCRIPTION : PRO.ReportDataInsert  Insert data as per condition
--EXEC [PRO].[ReportDataInsert]
============================================*/

CREATE PROCEDURE [pro].[ReportDataInsert]
AS
BEGIN
  DECLARE @TIMEKEY INT = (SELECT TIMEKEY FROM PRO.EXTDATE_MISDB WHERE FLG = 'Y')

    DELETE  FROM  PRO.ReportData WHERE EffectiveFromTimeKey=@TIMEKEY 

INSERT INTO  PRO.ReportData

(
DateOfData
,BranchCode
,UCIF_ID
,RefCustomerID
,SourceSystemCustomerID
,CustomerName
,PANNO
,AadharCardNO
,SrcAssetClassAlt_Key
,SysAssetClassAlt_Key
,PrvQtrRV
,CurntQtrRv
,SrcNPA_Dt
,SysNPA_Dt
,DbtDt
,LossDt
,ErosionDt
,CustomerAcID
,FacilityType
,AcOpenDt
,FirstDtOfDisb
,ProductAlt_Key
,ActSegmentCode
,ProductCode
,SourceAlt_Key
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
,FlgDeg
,FlgInMonth
,FlgSMA
,FlgPNPA
,FlgUpg
,FlgFITL
,FlgAbinitio
,UsedRV
,NPA_Reason
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
,SecApp
,BorrowerTypeID
,LineCode
,ProvPerSecured
,ProvPerUnSecured
,EffectiveFromTimeKey
,EffectiveToTimeKey
)


SELECT 

 B.ProcessingDt AS DateOfData
,B.BranchCode
,B.UCIF_ID
,B.RefCustomerID
,B.SourceSystemCustomerID
,B.CustomerName
,B.PANNO
,B.AadharCardNO
,B.SrcAssetClassAlt_Key
,B.SysAssetClassAlt_Key
,B.PrvQtrRV
,B.CurntQtrRv
,B.SrcNPA_Dt
,B.SysNPA_Dt
,B.DbtDt
,B.LossDt
,B.ErosionDt
,CustomerAcID
,A.FacilityType
,A.AcOpenDt
,A.FirstDtOfDisb
,A.ProductAlt_Key
,A.ActSegmentCode
,A.ProductCode
,A.SourceAlt_Key
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
,A.FlgDeg
,A.FlgInMonth
,A.FlgSMA
,A.FlgPNPA
,A.FlgUpg
,A.FlgFITL
,A.FlgAbinitio
,A.UsedRV
,A.NPA_Reason
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
,A.SecApp
,A.BorrowerTypeID
,A.LineCode
,A.ProvPerSecured
,A.ProvPerUnSecured
,A.EffectiveFromTimeKey
,A.EffectiveToTimeKey
FROM PRO.ACCOUNTCAL A INNER JOIN PRO.CUSTOMERCAL  B ON A.CustomerEntityID=B.CustomerEntityID
--LEFT JOIN DIMASSETCLASS D ON D.ASSETCLASSALT_KEY=A.FINALASSETCLASSALT_KEY AND D.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND D.EFFECTIVETOTIMEKEY>=@TIMEKEY
--LEFT JOIN DIMPRODUCT DP ON  A.PRODUCTALT_KEY=DP.PRODUCTALT_KEY AND DP.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND DP.EFFECTIVETOTIMEKEY>=@TIMEKEY
--LEFT JOIN DimCommercialFlag DC ON  A.CommercialFlag_AltKey=DC.CommercialFlagAlt_Key AND DC.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND DC.EFFECTIVETOTIMEKEY>=@TIMEKEY
--LEFT JOIN DimSourceDB DSB ON  A.SourceAlt_Key=DSB.SourceAlt_Key AND DSB.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND DSB.EFFECTIVETOTIMEKEY>=@TIMEKEY

WHERE  
( 
	FinalAssetClassAlt_Key>1
OR isnull(OverdueAmt,0)>0
OR A.flgupg='U'
OR A.flgDEG='Y'
OR A.flgSMA='Y'
OR A.flgPNPA='Y'
)

ORDER BY BranchCode DESC


END


GO