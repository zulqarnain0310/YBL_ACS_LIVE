SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO




create PROCEDURE [pro].[UpdateDataInHistTable]
@TIMEKEY int
with recompile
as
begin


update B SET
				 B.BranchCode							=A.BranchCode
				,B.UCIF_ID							=A.UCIF_ID
				,B.UcifEntityID							=A.UcifEntityID
				,B.CustomerEntityID						=A.CustomerEntityID
				,B.ParentCustomerID						=A.ParentCustomerID
				,B.RefCustomerID						=A.RefCustomerID
				,B.SourceSystemCustomerID				         =A.SourceSystemCustomerID
				,B.CustomerName							=A.CustomerName
				,B.CustSegmentCode						=A.CustSegmentCode
				,B.ConstitutionAlt_Key					         =A.ConstitutionAlt_Key
				,B.PANNO						 	=A.PANNO
				,B.AadharCardNO							=A.AadharCardNO
				,B.SrcAssetClassAlt_Key					        =A.SrcAssetClassAlt_Key
				,B.SysAssetClassAlt_Key					        =A.SysAssetClassAlt_Key
				,B.SplCatg1Alt_Key						=A.SplCatg1Alt_Key
				,B.SplCatg2Alt_Key						=A.SplCatg2Alt_Key
				,B.SplCatg3Alt_Key						=A.SplCatg3Alt_Key
				,B.SplCatg4Alt_Key						=A.SplCatg4Alt_Key
				,B.SMA_Class_Key						=A.SMA_Class_Key
				,B.PNPA_Class_Key						=A.PNPA_Class_Key
				,B.PrvQtrRV							=A.PrvQtrRV
				,B.CurntQtrRv							=A.CurntQtrRv
				,B.TotProvision							=A.TotProvision
				,B.RBITotProvision						=A.RBITotProvision
				,B.BankTotProvision						=A.BankTotProvision
				,B.SrcNPA_Dt							=A.SrcNPA_Dt
				,B.SysNPA_Dt							=A.SysNPA_Dt
				,B.DbtDt							=A.DbtDt
				,B.DbtDt2							=A.DbtDt2
				,B.DbtDt3							=A.DbtDt3
				,B.LossDt							=A.LossDt
				,B.MOC_Dt							=A.MOC_Dt
				,B.ErosionDt				          		=A.ErosionDt
				,B.SMA_Dt							=A.SMA_Dt
				,B.PNPA_Dt							=A.PNPA_Dt
				,B.ProcessingDt							=A.ProcessingDt
				,B.Asset_Norm							=A.Asset_Norm
				,B.FlgDeg							=A.FlgDeg
				,B.FlgUpg							=A.FlgUpg
				,B.FlgMoc							=A.FlgMoc
				,B.FlgSMA							=A.FlgSMA
				,B.FlgProcessing						=A.FlgProcessing
				,B.FlgErosion							=A.FlgErosion
				,B.FlgPNPA							=A.FlgPNPA
				,B.FlgPercolation						=A.FlgPercolation
				,B.FlgInMonth							=A.FlgInMonth
				,B.FlgDirtyRow							=A.FlgDirtyRow
				,B.DegDate							=A.DegDate
				,B.EffectiveFromTimeKey					        =A.EffectiveFromTimeKey
				,B.EffectiveToTimeKey					        =A.EffectiveToTimeKey
				,B.CommonMocTypeAlt_Key					        =A.CommonMocTypeAlt_Key
				,B.InMonthMark							=A.InMonthMark
				,B.MocStatusMark						=A.MocStatusMark
				,B.SourceAlt_Key						=A.SourceAlt_Key
				,B.BankAssetClass						=A.BankAssetClass
				,B.Cust_Expo							=A.Cust_Expo
				,B.MOCReason						        =A.MOCReason
				,B.AddlProvisionPer						=A.AddlProvisionPer
				,B.FraudDt						        =A.FraudDt
				,B.FraudAmount							=A.FraudAmount
				,B.DegReason							=A.DegReason
				,B.IMAXID_CCube							=A.IMAXID_CCube
				,B.CustMoveDescription					        =A.CustMoveDescription
				,B.TotOsCust							=A.TotOsCust
				,B.MOCTYPE					                =A.MOCTYPE
                                ,B.CustomerPartnerSegment                                       =A.CustomerPartnerSegment
				FROM PRO.CustomerCal  A
INNER JOIN pro.CustomerCal_HIST B
ON b.EffectiveFromTimeKey=@TIMEKEY and b.EffectiveToTimeKey=@TIMEKEY
AND a.CustomerEntityID=b.CustomerEntityID


	UPDATE B SET
			    B.AccountEntityID						=A.AccountEntityID
				,B.UcifEntityID							=A.UcifEntityID
				,B.CustomerEntityID						=A.CustomerEntityID
				,B.CustomerAcID							=A.CustomerAcID
				,B.RefCustomerID							=A.RefCustomerID
				,B.SourceSystemCustomerID				=A.SourceSystemCustomerID
				,B.UCIF_ID								=A.UCIF_ID
				,B.BranchCode							=A.BranchCode
				,B.FacilityType							=A.FacilityType
				,B.AcOpenDt								=A.AcOpenDt
				,B.FirstDtOfDisb							=A.FirstDtOfDisb
				,B.ProductAlt_Key						=A.ProductAlt_Key
				,B.SchemeAlt_key							=A.SchemeAlt_key
				,B.SubSectorAlt_Key						=A.SubSectorAlt_Key
				,B.SplCatg1Alt_Key						=A.SplCatg1Alt_Key
				,B.SplCatg2Alt_Key						=A.SplCatg2Alt_Key
				,B.SplCatg3Alt_Key						=A.SplCatg3Alt_Key
				,B.SplCatg4Alt_Key						=A.SplCatg4Alt_Key
				,B.SourceAlt_Key							=A.SourceAlt_Key
				,B.ActSegmentCode						=A.ActSegmentCode
				,B.InttRate								=A.InttRate
				,B.Balance								=A.Balance
				,B.BalanceInCrncy						=A.BalanceInCrncy
				,B.CurrencyAlt_Key						=A.CurrencyAlt_Key
				,B.DrawingPower							=A.DrawingPower
				,B.CurrentLimit							=A.CurrentLimit
				,B.CurrentLimitDt						=A.CurrentLimitDt
				,B.ContiExcessDt							=A.ContiExcessDt
				,B.StockStDt								=A.StockStDt
				,B.DebitSinceDt							=A.DebitSinceDt
				,B.LastCrDate							=A.LastCrDate
				,B.IntNotServicedDt						=A.IntNotServicedDt
				,B.OverdueAmt							=A.OverdueAmt
				,B.OverDueSinceDt						=A.OverDueSinceDt
				,B.ReviewDueDt							=A.ReviewDueDt
				,B.SecurityValue							=A.SecurityValue
				,B.DFVAmt								=A.DFVAmt
				,B.GovtGtyAmt							=A.GovtGtyAmt
				,B.CoverGovGur							=A.CoverGovGur
				,B.WriteOffAmount						=A.WriteOffAmount
				,B.UnAdjSubSidy							=A.UnAdjSubSidy
				,B.CreditsinceDt							=A.CreditsinceDt
				,B.NetBalance							=A.NetBalance
				,B.ApprRV								=A.ApprRV
				,B.SecuredAmt							=A.SecuredAmt
				,B.UnSecuredAmt							=A.UnSecuredAmt
				,B.ProvDFV								=A.ProvDFV
				,B.Provsecured							=A.Provsecured
				,B.ProvUnsecured							=A.ProvUnsecured
				,B.ProvCoverGovGur						=A.ProvCoverGovGur
				,B.AddlProvision							=A.AddlProvision
				,B.TotalProvision						=A.TotalProvision
				,B.BankProvsecured						=A.BankProvsecured
				,B.BankProvUnsecured						=A.BankProvUnsecured
				,B.BankTotalProvision					=A.BankTotalProvision
				,B.RBIProvsecured						=A.RBIProvsecured
				,B.RBIProvUnsecured						=A.RBIProvUnsecured
				,B.RBITotalProvision						=A.RBITotalProvision
				,B.InitialNpaDt							=A.InitialNpaDt
				,B.FinalNpaDt							=A.FinalNpaDt
				,B.SMA_Dt								=A.SMA_Dt
				,B.UpgDate								=A.UpgDate
				,B.InitialAssetClassAlt_Key				=A.InitialAssetClassAlt_Key
				,B.FinalAssetClassAlt_Key				=A.FinalAssetClassAlt_Key
				,B.ProvisionAlt_Key						=A.ProvisionAlt_Key
				,B.PNPA_Reason							=A.PNPA_Reason
				,B.SMA_Class								=A.SMA_Class
				,B.SMA_Reason							=A.SMA_Reason
				,B.FlgMoc								=A.FlgMoc
				,B.MOC_Dt								=A.MOC_Dt
				,B.CommonMocTypeAlt_Key					=A.CommonMocTypeAlt_Key
				,B.DPD_SMA								=A.DPD_SMA
				,B.FlgDeg								=A.FlgDeg
				,B.FlgDirtyRow							=A.FlgDirtyRow
				,B.FlgInMonth							=A.FlgInMonth
				,B.FlgSMA								=A.FlgSMA
				,B.FlgPNPA								=A.FlgPNPA
				,B.FlgUpg								=A.FlgUpg
				,B.FlgFITL								=A.FlgFITL
				,B.FlgAbinitio							=A.FlgAbinitio
				,B.NPA_Days								=A.NPA_Days
				,B.EffectiveFromTimeKey					=A.EffectiveFromTimeKey
				,B.EffectiveToTimeKey					=A.EffectiveToTimeKey
				,B.AppGovGur								=A.AppGovGur
				,B.UsedRV								=A.UsedRV
				,B.ComputedClaim							=A.ComputedClaim
				,B.PNPA_DATE								=A.PNPA_DATE
				,B.NPA_Reason							=A.NPA_Reason
				,B.PnpaAssetClassAlt_key					=A.PnpaAssetClassAlt_key
				,B.DisbAmount							=A.DisbAmount
				,B.PrincOutStd							=A.PrincOutStd
				,B.PrincOverdue							=A.PrincOverdue
				,B.PrincOverdueSinceDt					=A.PrincOverdueSinceDt
				,B.DPD_PrincOverdue						=A.DPD_PrincOverdue
				,B.IntOverdue							=A.IntOverdue
				,B.IntOverdueSinceDt						=A.IntOverdueSinceDt
				,B.DPD_IntOverdueSince					=A.DPD_IntOverdueSince
				,B.OtherOverdue							=A.OtherOverdue
				,B.OtherOverdueSinceDt					=A.OtherOverdueSinceDt
				,B.DPD_OtherOverdueSince					=A.DPD_OtherOverdueSince
				,B.RelationshipNumber					=A.RelationshipNumber
				,B.AccountFlag							=A.AccountFlag
				,B.CommercialFlag_AltKey					=A.CommercialFlag_AltKey
				,B.Liability								=A.Liability
				,B.CD									=A.CD
				,B.AccountStatus							=A.AccountStatus
				,B.AccountBlkCode1						=A.AccountBlkCode1
				,B.AccountBlkCode2						=A.AccountBlkCode2
				,B.ExposureType							=A.ExposureType
				,B.Mtm_Value								=A.Mtm_Value
				,B.BankAssetClass						=A.BankAssetClass
				,B.NpaType								=A.NpaType
				,B.SecApp								=A.SecApp
				,B.BorrowerTypeID						=A.BorrowerTypeID
				,B.LineCode								=A.LineCode
				,B.ProvPerSecured						=A.ProvPerSecured
				,B.ProvPerUnSecured						=A.ProvPerUnSecured
				,B.MOCReason							=A.MOCReason
				,B.AddlProvisionPer								=A.AddlProvisionPer
				,B.FlgINFRA								=A.FlgINFRA
				,B.RepossessionDate						=A.RepossessionDate
				,B.DerecognisedInterest1			=A.DerecognisedInterest1
				,B.DerecognisedInterest2			=A.DerecognisedInterest2
				,B.ProductCode				=A.ProductCode
				,B.FlgLCBG=					A.FlgLCBG
				,B.ACCOUNTSTATUSDebitFreeze          =A.ACCOUNTSTATUSDebitFreeze
				,B.FlgRestructure                 =A.FlgRestructure
				,B.Buyout_Code                  =A.Buyout_Code
				,B.CreditAmt                  =A.Buyout_Code
				,B.DebitAmt               =A.DebitAmt
				,B.UnserviedInt           =A.UnserviedInt
from pro.AccountCal A
	INNER JOIN pro.AccountCal_Hist B
		ON b.EffectiveFromTimeKey=@TIMEKEY and b.EffectiveToTimeKey=@TIMEKEY
		AND a.AccountEntityID=b.AccountEntityID
end



GO