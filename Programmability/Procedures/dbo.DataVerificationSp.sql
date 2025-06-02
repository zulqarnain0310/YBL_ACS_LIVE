SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[DataVerificationSp]

AS
BEGIN 
  BEGIN  TRY


SELECT 
DISTINCT 

A.AccountBranchCode
,B.BranchCode
,CASE WHEN A.AccountBranchCode<>B.BranchCode THEN 'TRUE' ELSE 'FALSE' END AccountBranchCodeDiff

,A.FCR_CustomerID
,B.RefCustomerID
,CASE WHEN A.FCR_CustomerID<>B.RefCustomerID THEN 'TRUE' ELSE 'FALSE' END FCR_CustomerIDDiff

,A.SourceSystemCustomerID
,B.SourceSystemCustomerID
,CASE WHEN A.SourceSystemCustomerID<>B.SourceSystemCustomerID THEN 'TRUE' ELSE 'FALSE' END SourceSystemCustomerIDDiff

,A.AccountID
,B.CustomerAcID
,CASE WHEN A.AccountID<>B.CustomerAcID THEN 'TRUE' ELSE 'FALSE' END AccountIDDiff

,A.ContractRefNo
,NULL AS ContractRefNo
,CASE WHEN A.ContractRefNo<>'' THEN 'TRUE' ELSE 'FALSE' END ContractRefNoDiff

,A.AccountOpenDate
,B.AcOpenDt
,CASE WHEN A.AccountOpenDate<>B.AcOpenDt THEN 'TRUE' ELSE 'FALSE' END AccountOpenDateDiff

,A.FacilityCodeLineCode
,LineCode AS FacilityCodeLineCode
,CASE WHEN A.FacilityCodeLineCode<>B.LineCode THEN 'TRUE' ELSE 'FALSE' END FacilityCodeLineCodeDiff

,A.FacilityLine
,NULL AS FacilityLine
,CASE WHEN A.FacilityLine<>'' THEN 'TRUE' ELSE 'FALSE' END FacilityLineDiff

,A.ProductCode
,C.ProductCode
,CASE WHEN A.ProductCode<>C.ProductCode THEN 'TRUE' ELSE 'FALSE' END ProductCodeDiff

,A.SectorCode
,NULL AS SectorCode
,CASE WHEN A.SectorCode<>'' THEN 'TRUE' ELSE 'FALSE' END SectorCodeDiff

,A.AccountSegmentCode
,B.ActSegmentCode
,CASE WHEN A.AccountSegmentCode<>B.ActSegmentCode THEN 'TRUE' ELSE 'FALSE' END AccountSegmentCodeDiff

,A.CurrentLimit
,B.CurrentLimit
,CASE WHEN A.CurrentLimit<>B.CurrentLimit THEN 'TRUE' ELSE 'FALSE' END CurrentLimitDiff

,A.DisbAmount
,B.DisbAmount
,CASE WHEN A.DisbAmount<>B.DisbAmount THEN 'TRUE' ELSE 'FALSE' END DisbAmountDiff

,A.CurrentLimitDate
,B.CurrentLimitDt
,CASE WHEN A.CurrentLimitDate<>B.CurrentLimitDt THEN 'TRUE' ELSE 'FALSE' END CurrentLimitDateDiff

,A.CurrencyCode
,D.CurrencyCode
,CASE WHEN A.CurrencyCode<>D.CurrencyCode THEN 'TRUE' ELSE 'FALSE' END CurrencyCodeDiff

,A.DrawingPower
,B.DrawingPower
,CASE WHEN A.DrawingPower<>B.DrawingPower THEN 'TRUE' ELSE 'FALSE' END DrawingPowerDiff

,A.TotalBalanceOutstandingINR
,B.Balance
,CASE WHEN A.TotalBalanceOutstandingINR<>B.Balance THEN 'TRUE' ELSE 'FALSE' END TotalBalanceOutstandingINRDiff

,A.BalanceInCurrency
,B.BalanceInCrncy
,CASE WHEN A.BalanceInCurrency<>B.BalanceInCrncy THEN 'TRUE' ELSE 'FALSE' END BalanceInCurrencyDiff

,A.PrincipalOutstanding
,B.PrincOutStd
,CASE WHEN A.PrincipalOutstanding<>B.PrincOutStd THEN 'TRUE' ELSE 'FALSE' END PrincipalOutstandingDiff

,A.MaxDPD
,B.DPD_Max
,CASE WHEN A.MaxDPD<>B.DPD_Max THEN 'TRUE' ELSE 'FALSE' END MaxDPDDiff

,A.TotalOverdueAmount 
,B.OverdueAmt
,CASE WHEN A.TotalOverdueAmount<>B.OverdueAmt THEN 'TRUE' ELSE 'FALSE' END TotalOverdueAmountDiff

,A.OverdueSinceDate
,B.OtherOverdueSinceDt
,CASE WHEN A.OverdueSinceDate<>B.OtherOverdueSinceDt THEN 'TRUE' ELSE 'FALSE' END OverdueSinceDateDiff

,A.PrincipalOverdue
,B.PrincOverdue
,CASE WHEN A.PrincipalOverdue<>B.PrincOverdue THEN 'TRUE' ELSE 'FALSE' END PrincipalOverdueDiff

,A.PrincipalOverdueSinceDate
,B.PrincOverdueSinceDt
,CASE WHEN A.PrincipalOverdueSinceDate<>B.PrincOverdueSinceDt THEN 'TRUE' ELSE 'FALSE' END PrincipalOverdueSinceDateDiff

,A.PrincipalOverdueDPD
,B.DPD_PrincOverdue
,CASE WHEN A.PrincipalOverdueDPD<>B.DPD_PrincOverdue THEN 'TRUE' ELSE 'FALSE' END PrincipalOverdueDPDDiff

,A.InterestOverdue
,B.IntOverdue
,CASE WHEN A.InterestOverdue<>B.IntOverdue THEN 'TRUE' ELSE 'FALSE' END InterestOverdueDiff

,A.InterestOverdueSinceDate
,B.IntOverdueSinceDt
,CASE WHEN A.InterestOverdueSinceDate<>B.IntOverdueSinceDt THEN 'TRUE' ELSE 'FALSE' END InterestOverdueSinceDateDiff

,A.InterestOverdueSinceDPD
,B.DPD_IntOverdueSince
,CASE WHEN A.InterestOverdueSinceDPD<>B.DPD_IntOverdueSince THEN 'TRUE' ELSE 'FALSE' END InterestOverdueSinceDPDDiff

,A.OtherOverdue
,B.OtherOverdue
,CASE WHEN A.OtherOverdue<>B.OtherOverdue THEN 'TRUE' ELSE 'FALSE' END OtherOverdueDiff

,A.OtherOverdueSinceDate
,B.OtherOverdueSinceDt
,CASE WHEN A.OtherOverdueSinceDate<>B.OtherOverdueSinceDt THEN 'TRUE' ELSE 'FALSE' END OtherOverdueSinceDateDiff

,A.OtherOverdueSinceDPD
,B.DPD_OtherOverdueSince
,CASE WHEN A.OtherOverdueSinceDPD<>B.DPD_OtherOverdueSince THEN 'TRUE' ELSE 'FALSE' END OtherOverdueSinceDPDDiff

,A.SbaCaaTodDate
,B.DebitSinceDt
,CASE WHEN A.SbaCaaTodDate<>B.DebitSinceDt THEN 'TRUE' ELSE 'FALSE' END SbaCaaTodDateDiff

,A.LastCreditDate
,B.LastCrDate
,CASE WHEN A.LastCreditDate<>B.LastCrDate THEN 'TRUE' ELSE 'FALSE' END LastCreditDateDiff

,A.ContinuousExcessSinceDate
,B.ContiExcessDt
,CASE WHEN A.ContinuousExcessSinceDate<>B.ContiExcessDt THEN 'TRUE' ELSE 'FALSE' END ContinuousExcessSinceDateDiff

,A.DPD_CCOD
,B.DPD_Overdrawn
,CASE WHEN A.DPD_CCOD<>B.DPD_Overdrawn THEN 'TRUE' ELSE 'FALSE' END DPD_CCODDiff

,A.FirstDtOfDisb
,B.FirstDtOfDisb
,CASE WHEN A.FirstDtOfDisb<>B.FirstDtOfDisb THEN 'TRUE' ELSE 'FALSE' END FirstDtOfDisbDiff

,A.InterestRate
,B.InttRate
,CASE WHEN A.InterestRate<>B.InttRate THEN 'TRUE' ELSE 'FALSE' END InterestRateDiff

,A.StockStatementDate
,B.StockStDt
,CASE WHEN A.StockStatementDate<>B.StockStDt THEN 'TRUE' ELSE 'FALSE' END StockStatementDateDiff

,A.GovernmentGuaranteeAmount 
,B.GovtGtyAmt
,CASE WHEN A.GovernmentGuaranteeAmount<>B.GovtGtyAmt THEN 'TRUE' ELSE 'FALSE' END GovernmentGuaranteeAmountDiff

,A.WriteOffAmount
,B.WriteOffAmount
,CASE WHEN A.WriteOffAmount<>B.WriteOffAmount THEN 'TRUE' ELSE 'FALSE' END WriteOffAmountDiff

,A.UnAdjustSubSidy
,B.UnAdjSubSidy
,CASE WHEN A.UnAdjustSubSidy<>B.UnAdjSubSidy THEN 'TRUE' ELSE 'FALSE' END UnAdjustSubSidyDiff

,A.AssetClass
,B.BankAssetClass
,CASE WHEN A.AssetClass<>B.BankAssetClass THEN 'TRUE' ELSE 'FALSE' END AssetClassDiff

,A.NPADate
,B.InitialNpaDt
,CASE WHEN A.NPADate<>B.InitialNpaDt THEN 'TRUE' ELSE 'FALSE' END NPADateDiff

,A.SourceSystemName
,E.SourceName
,CASE WHEN A.SourceSystemName<>E.SourceName THEN 'TRUE' ELSE 'FALSE' END SourceSystemNameDiff


,A.RelationshipNumber
,B.RelationshipNumber
,CASE WHEN A.RelationshipNumber<>B.RelationshipNumber THEN 'TRUE' ELSE 'FALSE' END RelationshipNumberDiff

,A.AccountFlag
,B.AccountFlag
,CASE WHEN A.AccountFlag<>B.AccountFlag THEN 'TRUE' ELSE 'FALSE' END AccountFlagDiff

,A.CommercialFlag
,B.CommercialFlag_AltKey
,CASE WHEN A.CommercialFlag<>F.CommercialFlagCode THEN 'TRUE' ELSE 'FALSE' END CommercialFlagDiff

,A.Liability
,B.Liability
,CASE WHEN A.Liability<>B.Liability THEN 'TRUE' ELSE 'FALSE' END LiabilityDiff


,A.CD
,B.CD
,CASE WHEN A.CD<>B.CD THEN 'TRUE' ELSE 'FALSE' END CDDiff

,A.Accountstatus
,B.Accountstatus
,CASE WHEN A.Accountstatus<>B.Accountstatus THEN 'TRUE' ELSE 'FALSE' END AccountstatusDiff

,A.AccountBlkCode1
,B.AccountBlkCode1
,CASE WHEN A.AccountBlkCode1<>B.AccountBlkCode1 THEN 'TRUE' ELSE 'FALSE' END AccountBlkCode1Diff

,A.AccountBlkCode2
,B.AccountBlkCode2
,CASE WHEN A.AccountBlkCode2<>B.AccountBlkCode2 THEN 'TRUE' ELSE 'FALSE' END AccountBlkCode2Diff



FROM YBL_ACS_MIS.DBO.AccountData A INNER JOIN PRO.AccountCal B ON A.AccountID=B.CustomerAcID
  LEFT OUTER JOIN DIMPRODUCT C ON A.PRODUCTCODE=C.PRODUCTCODE 	    AND (C.EffectiveFromTimeKey<=49999 AND C.EffectiveToTimeKey >=49999)
  LEFT OUTER JOIN DimCurrency D ON A.CurrencyCode=D.CurrencyCode 	AND (D.EffectiveFromTimeKey<=49999 AND D.EffectiveToTimeKey >=49999)
  LEFT OUTER JOIN DimSourceDB E ON A.SourceSystemName=E.SourceName 	AND (E.EffectiveFromTimeKey<=49999 AND E.EffectiveToTimeKey >=49999)
  LEFT OUTER JOIN DimCommercialFlag F ON A.CommercialFlag=F.CommercialFlagCode 	AND (E.EffectiveFromTimeKey<=49999 AND E.EffectiveToTimeKey >=49999)

----	IF OBJECT_ID('TEMPDB..#UCID') IS NOT NULL
----    DROP TABLE #UCID
----	IF OBJECT_ID('TEMPDB..#CUID') IS NOT NULL
----    DROP TABLE #CUID
----	IF OBJECT_ID('TEMPDB..#SUID') IS NOT NULL
----    DROP TABLE #SUID

----SELECT UcifEntityID,SysAssetClassAlt_Key
----INTO #UCID
----FROM PRO.CustomerCal WHERE UcifEntityID IS NOT NULL

----SELECT CustomerEntityID ,SysAssetClassAlt_Key

----INTO #CUID FROM PRO.CustomerCal WHERE RefCustomerID IS NOT NULL

----SELECT CustomerEntityID,SysAssetClassAlt_Key  INTO #SUID 
----FROM PRO.CustomerCal WHERE SourceSystemCustomerID IS NOT NULL


----select * from #UCID  A INNER JOIN PRO.CustomerCal B ON A.UcifEntityID=B.UcifEntityID 
----WHERE A.SysAssetClassAlt_Key<>B.SysAssetClassAlt_Key

----select * from #CUID  A INNER JOIN PRO.CustomerCal B ON A.CustomerEntityID=B.CustomerEntityID 
----WHERE A.SysAssetClassAlt_Key<>B.SysAssetClassAlt_Key

----select * from #SUID  A INNER JOIN PRO.CustomerCal B ON A.CustomerEntityID=B.CustomerEntityID 
----WHERE A.SysAssetClassAlt_Key<>B.SysAssetClassAlt_Key



----select * from #UCID  A INNER JOIN PRO.AccountCal B ON A.UcifEntityID=B.UcifEntityID 
----WHERE A.SysAssetClassAlt_Key<>B.FinalAssetClassAlt_Key

----select * from #CUID  A INNER JOIN PRO.AccountCal B ON A.CustomerEntityID=B.CustomerEntityID 
----WHERE A.SysAssetClassAlt_Key<>B.FinalAssetClassAlt_Key

----select * from #SUID  A INNER JOIN PRO.AccountCal B ON A.CustomerEntityID=B.CustomerEntityID 
----WHERE A.SysAssetClassAlt_Key<>B.FinalAssetClassAlt_Key
	

	


	

	

	

END TRY

BEGIN  CATCH
  SELECT 'ERROR MESSAGE :'+ERROR_MESSAGE()+'ERROR PROCEDURE :'+ERROR_PROCEDURE();
END CATCH
END




















GO