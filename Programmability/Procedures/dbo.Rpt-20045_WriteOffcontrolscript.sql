SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

Create Proc [dbo].[Rpt-20045_WriteOffcontrolscript]
@Timekey INT
AS

----select * from SysDayMatrix where date='2024-05-21'														
														
--Declare @Timekey as INT =25770														
														
SELECT  														
CH.UCIF_ID														
,CH.PanNO														
,AH.CustomerAcID														
,AH.RefCustomerID														
,AH.SourceSystemCustomerID														
,CH.CustomerName														
,DB.SourceName														
,AH.DPD_Max														
,isnull(DPD_IntService,0) DPD_IntService														
, isnull(DPD_NoCredit,0) DPD_NoCredit														
  , isnull(DPD_Overdrawn,0) DPD_Overdrawn														
, isnull(DPD_Overdue,0) DPD_Overdue														
,case when DimProduct.ProductCode ='NSLI' then 0      when ISNULL(AH.PrincOutStd,0)<0 then 0 else ISNULL(AH.PrincOutStd,0) end/1  AS POS														
,case when ISNULL(AH.BalanceInCrncy,0)<0 then 0 else ISNULL (AH.BalanceInCrncy,0)end /1     AS BalanceInCrncy														
,case when ISNULL(AH.Balance,0)<0 then 0 else  ISNULL(AH.Balance,0)end/1     AS Balance														
,CONVERT(VARCHAR(20),CH.SysNPA_Dt,103)                AS SysNPA_Dt														
,DA.AssetClassShortName                          AS FinalAssetClassName														
,18 AS ExceptionCode														
,'Exceptional NOT MARKED As WRITEOFF'  AS ExceptionDescription														
,AH.EffectiveFromTimeKey														
,AH.EffectiveToTimeKey 														
														
,AH.BankAssetClass														
,AH.ProductCode														
,CONVERT(VARCHAR(20),AH.DateOfData,103) DateOfData	
FROM pro.customercal_hist CH														
              														
INNER JOIN pro.accountcal_hist      AH                  ON CH.SourceSystemCustomerID=AH.SourceSystemCustomerID AND														
														  AH.EffectiveFromTimeKey=@Timekey AND
														  AH.EffectiveToTimeKey=@Timekey AND
														  CH.EffectiveFromTimeKey=@Timekey AND
		                                                  CH.EffectiveToTimeKey=@Timekey												
														
INNER JOIN DimsourceDB  DB                             ON DB.SourceAlt_Key=AH.SourceAlt_Key AND														
                                                           DB.EffectiveFromTimeKey<=@Timekey AND														
													       DB.EffectiveToTimeKey>=@Timekey	
														
INNER JOIN DimAssetClass DA                            ON  DA.AssetClassAlt_Key= AH.FinalAssetClassAlt_Key AND 														
                                                           DA.EffectiveFromTimeKey<=@Timekey AND														
													       DA.EffectiveToTimeKey>=@Timekey	
														
INNER JOIN DimAssetClass                               ON  DimAssetClass.AssetClassAlt_Key= AH.InitialAssetClassAlt_Key AND 														
                                                            DimAssetClass.EffectiveFromTimeKey<=@Timekey AND														
													        DimAssetClass.EffectiveToTimeKey>=@Timekey	
														
LEFT  JOIN DimProduct                                  ON DimProduct.ProductAlt_Key=AH.ProductAlt_Key AND 														
                                                           DimProduct.EffectiveFromTimeKey<=@Timekey AND														
													       DimProduct.EffectiveToTimeKey>=@Timekey	
														
LEFT JOIN DimCurrency                                  ON  DimCurrency.CurrencyAlt_Key= AH.CurrencyAlt_Key	AND													
			                                               DimCurrency.EffectiveFromTimeKey<=@Timekey AND											
														   DimCurrency.EffectiveToTimeKey>=@Timekey
where 	 Ah.Asset_Norm<>'ALWYS_STD'													



AND (

(DB.SourceDBName='VisionPlus' and (isnull(DPD_IntService,0)>=181 OR isnull(DPD_NoCredit,0)>=181 OR isnull(DPD_Overdrawn,0)>=181 OR isnull(DPD_Overdue,0)>=181)
)
OR
(DB.SourceDBName='FCR' 
and DimProduct.ProductCode in ('623','737','878','879','884','885','702','660')
and (isnull(DPD_IntService,0)>=181 OR isnull(DPD_NoCredit,0)>=181 OR isnull(DPD_Overdrawn,0)>=181 OR isnull(DPD_Overdue,0)>=181)
)
OR
(DB.SourceDBName='FCR' and DimProduct.ProductCode in ('889','661','727','688','690','729')
and (isnull(DPD_IntService,0)>=2281 OR isnull(DPD_NoCredit,0)>=2281 OR isnull(DPD_Overdrawn,0)>=2281 OR isnull(DPD_Overdue,0)>=2281)
)
OR
(DB.SourceDBName='FinnOne' and DimProduct.ProductCode in ('ALN',	'APAL',	'BLN',	'CEL',	'CVL',	'ELN',	'GLN',	'INEQ',	'LFPD',	'MEN',	'MER',	'PEN',	'PLN',	'RPEN',	'SPL',	'THWL',	'TWL',	'UCE',	'UCL',	'UCV',	'UTL',	'YNIR')
and (isnull(DPD_IntService,0)>=181 OR isnull(DPD_NoCredit,0)>=181 OR isnull(DPD_Overdrawn,0)>=181 OR isnull(DPD_Overdue,0)>=181)
)

OR
(DB.SourceDBName='FinnOne' and DimProduct.ProductCode in ('YDA')
and (isnull(DPD_IntService,0)>=455 OR isnull(DPD_NoCredit,0)>=455 OR isnull(DPD_Overdrawn,0)>=455 OR isnull(DPD_Overdue,0)>=455)
)
OR
(DB.SourceDBName='FinnOne' and DimProduct.ProductCode in ('MEFSTL')
and (isnull(DPD_IntService,0)>=1095 OR isnull(DPD_NoCredit,0)>=1095 OR isnull(DPD_Overdrawn,0)>=1095 OR isnull(DPD_Overdue,0)>=1095)
)

OR
(DB.SourceDBName='FinnOne' and DimProduct.ProductCode in ('FMA')
and (isnull(DPD_IntService,0)>=1825 OR isnull(DPD_NoCredit,0)>=1825 OR isnull(DPD_Overdrawn,0)>=1825 OR isnull(DPD_Overdue,0)>=1825)
)
OR
(DB.SourceDBName='FinnOne' and DimProduct.ProductCode in ('AFHL',	'BHL',	'HIN',	'HLN',	'INF',	'LAP',	'LRD',	'MICROMOR',	'MOR',	'SHL')

and (isnull(DPD_IntService,0)>=2281 OR isnull(DPD_NoCredit,0)>=2281 OR isnull(DPD_Overdrawn,0)>=2281 OR isnull(DPD_Overdue,0)>=2281)
)
 )														
and ISNULL(AH.Balance,0)>0														
AND ISNULL(Ah.BANKASSETCLASS,'N')<>'WRITEOFF'														
AND  ISNULL(Ah.AccountBlkCode1,'N')<>'W' AND  ISNULL(Ah.AccountBlkCode2,'N')<>'W'														
GO