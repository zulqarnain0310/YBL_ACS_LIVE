SET QUOTED_IDENTIFIER OFF

SET ANSI_NULLS ON
GO

CREATE PROC[dbo].[Rpt-20030_NewUpdate]    
	@Timekey INT,
	@Source   VARCHAR(500),
	@Cost FLOAT
AS

--DECLARE @Timekey INT=26732,
--        @Source   VARCHAR(500)='1,2,3,4,5,6,7,8,9,10,11',
--        @Cost FLOAT=1


SELECT 
B.sourcename														         AS SystemName,																	
A.UCIF_ID,
A.RefCustomerID,
A.SourceSystemCustomerID,  -----New Added
g.CustomerName,
A.CustomerAcID,
DimProduct.ProductCode,   -----New Added
DimProduct.ProductName,
A.ActSegmentCode,
DimAssetClass.AssetClassShortName                                             AS  InitialAssetClassName,
F.AssetClassShortName                                                         AS FinalAssetClassName,
A.DegReason,
A.DPD_Max,
DimCurrency.currencycode,

(CASE When B.SourceDBName='VisionPlus' then ISNULL(A.IntOverdue,0) 
else ISNULL(A.IntOverdue,0)+ISNULL(A.OtherOverdue,0) end) /@cost              AS [O/S INTEREST AMT],
case when ISNULL(A.BalanceInCrncy,0)<0 then 0 
else ISNULL (A.BalanceInCrncy,0)end /@cost									  AS BalanceInCrncy,--Mail dated by bank 23/05/2020
case when ISNULL(A.Balance,0)<0 then 0 
else  ISNULL(A.Balance,0)end/@cost											  AS Balance,--Mail dated by bank 23/05/2020
case when DimProduct.ProductCode ='NSLI' then 0      
when ISNULL(A.PrincOutStd,0)<0 then 0
else ISNULL(A.PrincOutStd,0) end/@cost										  AS PrincOutStd, --AS POS

A.CD
,ISNULL(g.CurntQtrRv,0)/@Cost 												  AS CurntQtrRv
,Case when (A.SourceAlt_Key in (1,2,7) ) then 
case when ISNULL(A.securityvalue,0)=0 then
ISNULL((SELECT SUM(ISNULL(L.CurntQtrRv,0)) FROM VWCUSTOMERCAL_HIST L
where L.UCIF_ID= A.UCIF_ID 
AND L.EFFECTIVEFROMTIMEKEY=@TIMEKEY AND L.EFFECTIVETOTIMEKEY=@TIMEKEY),0) END
Else 0 END																	  AS TotalSecurityValue
,ISNULL(A.securityvalue,0)/@Cost											  AS SecurityValue
,ISNULL(A.UsedRV,0)/@Cost													  AS UsedRV	
,ISNULL(A.ApprRV,0)/@Cost													  AS ApprRV 
,ISNULL(A.SecuredAmt,0)/@Cost												  AS SecuredAmt
,ISNULL(A.UnSecuredAmt,0)/@Cost												  AS UnSecuredAmt
,ISNULL(A.BankProvsecured,0)/@Cost											  AS BankProvsecured
,ISNULL(A.bankprovunsecured,0)/@Cost										  AS bankprovunsecured
,ISNULL(A.BankTotalProvision,0)/@Cost										  AS BankTotalProvision
,ISNULL(A.RBIProvsecured,0)/@Cost											  AS RBIProvsecured
,ISNULL(A.RBIProvUnsecured,0)/@Cost											  AS RBIProvUnsecured
,ISNULL(A.RBITotalProvision,0)/@Cost										  AS RBITotalProvision
,ISNULL(A.Provsecured,0)/@Cost												  AS Provsecured
,ISNULL(A.ProvUnsecured,0)/@Cost											  AS ProvUnsecured
,ISNULL(A.TotalProvision,0)/@Cost											  AS TotalProvision 
,ProvisionRule
,ProvisionName
,cast (isnull(ProvisionSecured,0)       as decimal (30,2))					  AS ProvisionSecured_per
,cast (isnull(ProvisionUnSecured,0)     as decimal (30,2))					  AS ProvisionUnSecured_per
,cast (isnull(RBIProvisionSecured,0)    as decimal (30,2))					  AS RBIProvisionSecured_per
,cast (isnull(RBIProvisionUnSecured,0)  as decimal (30,2))					  AS RBIProvisionUnSecured_per

FROM VWACCOUNTCAL_HIST A 
INNER JOIN VWCUSTOMERCAL_HIST g					 ON A.SourceSystemCustomerID=g.SourceSystemCustomerID
                                                     AND A.EffectiveFromTimeKey=@Timekey
							                         AND A.EffectiveToTimeKey=@Timekey
							                         AND g.EffectiveFromTimeKey=@Timekey
							                         AND g.EffectiveToTimeKey=@Timekey
INNER JOIN DBO.DIMSOURCEDB B						 ON A.SOURCEALT_KEY=B.SOURCEALT_KEY
                                                     AND B.EffectiveFromTimeKey<=@Timekey
							                         AND B.EffectiveToTimeKey>=@Timekey 
INNER JOIN DimAssetClass                             ON  DimAssetClass.AssetClassAlt_Key= A.InitialAssetClassAlt_Key
													 AND DimAssetClass.EffectiveFromTimeKey<=@Timekey 
													 AND DimAssetClass.EffectiveToTimeKey>=@Timekey													  
INNER JOIN DBO.DimAssetClass f						 ON f.AssetClassAlt_Key=a.FinalAssetClassAlt_Key
                                                     AND f.EffectiveFromTimeKey<=@Timekey
							                         AND f.EffectiveToTimeKey>=@Timekey 
LEFT JOIN DimProvision_Seg c						 ON A.ProvisionAlt_Key =c.ProvisionAlt_Key
                                                     AND c.EffectiveFromTimeKey<=@Timekey
							                         AND c.EffectiveToTimeKey>=@Timekey
LEFT  JOIN DimProduct                                ON DimProduct.ProductAlt_Key=A.ProductAlt_Key  
                                                     AND DimProduct.EffectiveFromTimeKey<=@Timekey 
													 AND DimProduct.EffectiveToTimeKey>=@Timekey
LEFT JOIN DimCurrency                                ON  DimCurrency.CurrencyAlt_Key= A.CurrencyAlt_Key	
			                                         AND DimCurrency.EffectiveFromTimeKey<=@Timekey 
													 AND DimCurrency.EffectiveToTimeKey>=@Timekey
WHERE B.SourceAlt_Key IN (SELECT * FROM[Split](@Source,','))	
AND A.FinalAssetClassAlt_Key>1 
AND ISNULL(A.BankAssetClass,'N') <> 'WRITEOFF'	
AND ISNULL(A.AccountBlkCode1,'N')<>'W' AND  ISNULL(A.AccountBlkCode2,'N')<>'W'	
AND ISNULL(A.Balance,0) > 0 AND ISNULL(DimProduct.ProductCode,'') not in ('NSLI')

ORDER BY g.RefCustomerID,B.SourceAlt_Key

OPTION(RECOMPILE)


GO