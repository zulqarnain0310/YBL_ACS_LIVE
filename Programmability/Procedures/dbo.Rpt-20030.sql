SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


  
CREATE PROC [dbo].[Rpt-20030]      
 @Timekey INT,  
 @Source   VARCHAR(500),  
 @Cost FLOAT  
AS  
  
--DECLARE @Timekey INT=(select TimeKey from SysDayMatrix where date='2022-11-29'),   
--      @Source   VARCHAR(500)='1,2,3,4,5,6,7,8,9,10,11',  
--       @Cost FLOAT=1  
  
  
IF OBJECT_ID('TEMPDB..#CorporateSecurity') IS NOT NULL
IF OBJECT_ID('TEMPDB..#Data') IS NOT NULL
IF OBJECT_ID('TEMPDB..#result') IS NOT NULL
   DROP TABLE #CorporateSecurity,#result,#data  
     
  
SELECT SUM(ISNULL(L.CurntQtrRv,0)) as CurrentValue ,l.UCIF_ID   
into #CorporateSecurity  
FROM VWCUSTOMERCAL_HIST L  
where L.EFFECTIVEFROMTIMEKEY=@TIMEKEY AND L.EFFECTIVETOTIMEKEY=@TIMEKEY  
AND L.CurntQtrRv>0  
group by l.UCIF_ID  
  
OPTION(RECOMPILE)  
 
declare @TimekeyDate date = (Select Date From SysDayMatrix Where TimeKey = @TimeKey)

 IF OBJECT_ID('TEMPDB..#AbsoluteProvisionMOCAmount') IS NOT NULL
			DROP TABLE #AbsoluteProvisionMOCAmount
 
		Select distinct
		  CustomerACID
		 ,Sum(ISNULL(AdditionalProvision,0)) as AdditionalProvision
		 		into #AbsoluteProvisionMOCAmount
		From [YBL_ACS].DataUpload.AbsoluteBackdatedMOC 
		Where EffectiveToTimeKey = 49999
		AND MOC_Date=@TimekeyDate
		Group by CustomerACID  
 
  IF OBJECT_ID('TEMPDB..#ReportData') IS NOT NULL
			DROP TABLE #ReportData


SELECT   
   SDB.SourceShortName                                     AS SystemName  
      ,Account.UCIF_ID  
   ,CUST.RefCustomerID  
   ,Account.SourceSystemCustomerID  
   ,CUST.CustomerName  
   ,Account.CustomerAcID  
   ,DPC.ProductCode  
   ,DPC.ProductName  
   ,Account.ActSegmentCode  
      ,DAI.AssetClassName                                      AS InitialAssetClass  
   ,DAF.AssetClassName                                      AS FinalAssetClass   
   ,Account.DegReason  
   ,Account.DPD_Max  
   ,DC.CurrencyCode  
  
   
  
   ,cast ((CASE When  SDB.SourceDBName='VisionPlus' then ISNULL(Account.IntOverdue,0) else  
ISNULL(Account.IntOverdue,0)+ISNULL(Account.OtherOverdue,0) end) /@cost as decimal(18,2)  )            AS IntOverdue,-- [O/S INTEREST AMT],  
  
cast (case when ISNULL(Account.BalanceInCrncy,0)<0 then 0 else ISNULL (Account.BalanceInCrncy,0)end /@cost as decimal(18,2))     AS BalanceInCrncy,--Mail dated by bank 23/05/2020  
cast (case when ISNULL(Account.Balance,0)<0 then 0 else  ISNULL(Account.Balance,0)end/@cost as decimal(18,2))    AS Balance,--Mail dated by bank 23/05/2020  
cast (case when DPC.ProductCode ='NSLI' then 0      when ISNULL(Account.PrincOutStd,0)<0 then 0   
  
else ISNULL(Account.PrincOutStd,0) end/@cost as decimal(18,2)) AS PrincOutStd  -- AS POS,  
  
   ,Account.CD    
   ,cast (ISNULL(CUST.CurntQtrRv,0)/@Cost as decimal(18,2))                         AS CurntQtrRv   
   , cast (case when (account.SourceAlt_Key in (1,2,7) ) then   
     case when ISNULL(Account.securityvalue,0)=0 then ISNULL(CS.CurrentValue,0) else 0 end     
     else 0 end as decimal(18,2))  AS TotalSecurityValue  
   ,cast (ISNULL(Account.securityvalue,0)/@Cost as decimal(18,2))                  AS SecurityValue  
   ,cast (ISNULL(Account.UsedRV,0)/@Cost        as decimal(18,2))                  AS UsedRV   
   ,cast (ISNULL(Account.ApprRV,0)/@Cost        as decimal(18,2))                  AS ApprRV   
   ,cast (ISNULL(Account.SecuredAmt,0)/@Cost    as decimal(18,2))                  AS SecuredAmt  
   ,cast (ISNULL(Account.UnSecuredAmt,0)/@Cost  as decimal(18,2))                  AS UnSecuredAmt  
   ,cast (ISNULL(Account.BankProvsecured,0)/@Cost  as decimal(18,2))               AS BankProvsecured  
   ,cast (ISNULL(Account.bankprovunsecured,0)/@Cost as decimal(18,2))               AS bankprovunsecured  
   ,cast (ISNULL(Account.BankTotalProvision,0)/@Cost as decimal(18,2))             AS BankTotalProvision  
   ,cast (ISNULL(Account.RBIProvsecured,0)/@Cost   as decimal(18,2))               AS RBIProvsecured  
   ,cast (ISNULL(Account.RBIProvUnsecured,0)/@Cost as decimal(18,2))               AS RBIProvUnsecured  
   ,cast (ISNULL(Account.RBITotalProvision,0)/@Cost as decimal(18,2))               AS RBITotalProvision  
   ,cast (ISNULL(Account.Provsecured,0)/@Cost      as decimal(18,2))               AS Provsecured  
   ,cast (ISNULL(Account.ProvUnsecured,0)/@Cost    as decimal(18,2))               AS ProvUnsecured  
   ,cast (ISNULL(Account.TotalProvision,0)/@Cost   as decimal(18,2))               AS TotalProvision  
   ----------------added by lipsa on 14-06-24 to sync with Prod
,cast (ISNULL(APM.AdditionalProvision,0)/@Cost 	 as decimal(18,2)) 			   AS Absolute_Provision
,cast (ISNULL(APM.AdditionalProvision,0)+ISNULL(Account.TotalProvision,0)  as decimal(18,2))  AS FINAL_Provision
   ,DP.ProvisionName   
   ,DP.ProvisionRule  
   ,cast (isnull( DP.ProvisionSecured,0)       as decimal (30,2)) as ProvisionSecured_per  
   ,cast (isnull(DP.ProvisionUnSecured,0)      as decimal (30,2)) as ProvisionUnSecured_per  
   ,cast (isnull(DP.RBIProvisionSecured,0)     as decimal (30,2)) as RBIProvisionSecured_per  
   ,cast (isnull( DP.RBIProvisionUnSecured,0)  as decimal (30,2)) as RBIProvisionUnSecured_per  
           ,Account.DPD_Overdrawn  
,Account.DPD_IntService  
,Account.DPD_Renewal  
,Account.DPD_Overdue  
,Account.DPD_StockStmt  
,ISNULL(Account.FlgRestructure,'N') AS FlgRestructure  
,CASE WHEN ISNULL(Account.SplCatg1Alt_Key,0)=870 OR ISNULL(Account.SplCatg2Alt_Key,0)=870  
               OR ISNULL(Account.SplCatg3Alt_Key,0)=870 OR ISNULL(Account.SplCatg4Alt_Key,0)=870  
          THEN 'Y'  
      ELSE 'N'  
          END AS FlgFraud  


,ROW_NUMBER()over(order by SDB.SourceShortName)as RN
into #ReportData
FROM VWAccountCal_Hist   Account  
INNER JOIN VWCustomerCal_Hist     Cust                    ON Account.SourceSystemCustomerID=Cust.SourceSystemCustomerID  
                                                          AND Account.EffectiveFromTimeKey=@Timekey  
                                                          AND Account.EffectiveToTimeKey=@Timekey  
                                                          AND CUST.EffectiveFromTimeKey=@Timekey  
                                                          AND CUST.EffectiveToTimeKey=@Timekey  
  
LEFT JOIN #CorporateSecurity CS                           ON Account.UCIF_ID=CS.UCIF_ID  
  
INNER JOIN DimSourcedb      SDB                           ON Account.SourceAlt_key=SDB.SourceAlt_key  
                                                          AND SDB.EffectiveFromTimeKey<=@Timekey  
                                                          AND SDB.EffectiveToTimeKey>=@Timekey      
  
INNER JOIN DimAssetclass   DAI                            ON Account.InitialAssetClassAlt_key=DAI.AssetClassAlt_Key  
                                                          AND SDB.EffectiveFromTimeKey<=@Timekey  
                                                          AND SDB.EffectiveToTimeKey>=@Timekey  
  
INNER JOIN DimAssetclass   DAF                            ON Account.finalAssetClassAlt_key=DAF.AssetClassAlt_Key  
                                                          AND SDB.EffectiveFromTimeKey<=@Timekey  
                                                          AND SDB.EffectiveToTimeKey>=@Timekey  
  
--LEFT JOIN DimProvision_SEG   DP                           ON DP.ProvisionAlt_Key=Account.ProvisionAlt_Key   
--                                                          AND DP.EffectiveFromTimeKey<=@Timekey  
--                                                          AND DP.EffectiveToTimeKey>=@Timekey  
 LEFT JOIN DimProvision_SEG   DP                   ON DP.ProvisionAlt_Key=Account.ProvisionAlt_Key	
                                                     AND DP.EffectiveFromTimeKey<=@Timekey
							                         AND DP.EffectiveToTimeKey>=@Timekey

  
LEFT JOIN DimProduct   DPC                                ON DPC.ProductAlt_Key=Account.ProductAlt_Key   
                                                          AND DPC.EffectiveFromTimeKey<=@Timekey  
                                                          AND DPC.EffectiveToTimeKey>=@Timekey  
                
LEFT JOIN DimCurrency DC                                  ON DC.CurrencyAlt_Key=Account.CurrencyAlt_Key   
                                                          AND DC.EffectiveFromTimeKey<=@Timekey  
                                                          AND DC.EffectiveToTimeKey>=@Timekey  

left join #AbsoluteProvisionMOCAmount APM                 ON APM.Customeracid=Account.Customeracid
                
WHERE SDB.SourceAlt_Key IN (SELECT * FROM[Split](@Source,','))   
AND Account.FinalAssetClassAlt_Key>1   
AND ISNULL(Account.BankAssetClass,'N') <> 'WRITEOFF'  
--AND ISNULL(Account.AccountBlkCode1,'N')<>'W' AND  ISNULL(Account.AccountBlkCode2,'N')<>'W'    
AND ISNULL(Account.Balance,0) > 0 AND ISNULL(DPC.ProductCode,'') not in ('NSLI')                                             
ORDER BY Cust.RefCustomerID,SDB.SourceAlt_Key  
  
OPTION(RECOMPILE)   

;with x as(
select 0 as Mark,* from #ReportData
union all
select
1 as Mark
,null as SystemName
,null as  UCIF_ID
,null as RefCustomerID
,null as SourceSystemCustomerID
,null as CustomerName
,null as CustomerAcID
,null as ProductCode
,null as ProductName
,null as ActSegmentCode
,null as InitialAssetClass
,null as FinalAssetClass
,null as DegReason
,null as DPD_Max
,'Grand Total' as CurrencyCode
--,sum(IntOverdue) as IntOverdue
,SUM(CONVERT(numeric(18,2), CAST(IntOverdue AS FLOAT))) IntOverdue
,sum(BalanceInCrncy) as BalanceInCrncy
,sum(Balance) as Balance
,sum(PrincOutStd) as PrincOutStd
,null as CD
,sum(CurntQtrRv) as CurntQtrRv
,sum(TotalSecurityValue) as TotalSecurityValue
,sum(SecurityValue) as SecurityValue
,sum(UsedRV) as UsedRV
,sum(ApprRV) as ApprRV
,sum(SecuredAmt) as SecuredAmt
,sum(UnSecuredAmt) as UnSecuredAmt
,sum(BankProvsecured) as BankProvsecured
,sum(bankprovunsecured) as bankprovunsecured
,sum(BankTotalProvision) as BankTotalProvision
,sum(RBIProvsecured) as RBIProvsecured
,sum(RBIProvUnsecured) as RBIProvUnsecured
,sum(RBITotalProvision) as RBITotalProvision
,sum(Provsecured) as Provsecured
,sum(ProvUnsecured) as ProvUnsecured
,sum(TotalProvision) as TotalProvision
,sum(Absolute_Provision) as Absolute_Provision
,sum(FINAL_Provision) as FINAL_Provision
,null as ProvisionName
,null as ProvisionRule
,null as ProvisionSecured_per
,null as ProvisionUnSecured_per
,null as RBIProvisionSecured_per
,null as RBIProvisionUnSecured_per
,null as DPD_Overdrawn
,null as DPD_IntService
,null as DPD_Renewal
,null as DPD_Overdue
,null as DPD_StockStmt
,null as FlgRestructure
,null as FlgFraud
,max(RN)+1 as RN
from #ReportData
)
select * into #data from x order by RN asc


select 

Mark
,SystemName
,
	CASE 
		WHEN replace(UCIF_ID,' ','') LIKE '%[^a-zA-Z0-9]%' 
		THEN Replace(REPLACE( cast (replace(UCIF_ID,' ','') as varchar(38)), SUBSTRING( cast (replace(UCIF_ID,' ','') as varchar(38)), PATINDEX('%[~,@,#,$,%,&,*,^,&,%,*,(,),'''',]%', cast (replace(UCIF_ID,' ','') as varchar(38))), 1 ),''),'-',' ')
		ELSE replace(UCIF_ID,' ','')
	END
UCIF_ID
,
	CASE 
		WHEN replace(RefCustomerID,' ','') LIKE '%[^a-zA-Z0-9]%' 
		THEN Replace(REPLACE( cast (replace(RefCustomerID,' ','') as varchar(38)), SUBSTRING( cast (replace(RefCustomerID,' ','') as varchar(38)), PATINDEX('%[~,@,#,$,%,&,*,^,&,%,*,(,),'''',]%', cast (replace(RefCustomerID,' ','') as varchar(38))), 1 ),''),'-',' ')
		ELSE replace(RefCustomerID,' ','')
	END
RefCustomerID
,
	CASE 
		WHEN replace(SourceSystemCustomerID,' ','') LIKE '%[^a-zA-Z0-9]%' 
		THEN Replace(REPLACE( cast (replace(SourceSystemCustomerID,' ','') as varchar(38)), SUBSTRING( cast (replace(SourceSystemCustomerID,' ','') as varchar(38)), PATINDEX('%[~,@,#,$,%,&,*,^,&,%,*,(,),'''',]%', cast (replace(SourceSystemCustomerID,' ','') as varchar(38))), 1 ),''),'-',' ')
		ELSE replace(SourceSystemCustomerID,' ','')
	END
SourceSystemCustomerID
,CustomerName
,
	CASE 
		WHEN replace(CustomerAcID,' ','') LIKE '%[^a-zA-Z0-9]%' 
		THEN Replace(REPLACE( cast (replace(CustomerAcID,' ','') as varchar(38)), SUBSTRING( cast (replace(CustomerAcID,' ','') as varchar(38)), PATINDEX('%[~,@,#,$,%,&,*,^,&,%,*,(,),'''',]%', cast (replace(CustomerAcID,' ','') as varchar(38))), 1 ),''),'-',' ')
		ELSE replace(CustomerAcID,' ','')
	END
CustomerAcID
,ProductCode
,ProductName
,ActSegmentCode
,InitialAssetClass
,FinalAssetClass
,DegReason
,DPD_Max
,CurrencyCode
,
	CASE 
		WHEN replace(IntOverdue,' ','') LIKE '%[^a-zA-Z0-9]%' 
		THEN Replace(REPLACE( cast (replace(IntOverdue,' ','') as varchar(38)), SUBSTRING( cast (replace(IntOverdue,' ','') as varchar(38)), PATINDEX('%[~,@,#,$,%,&,*,^,&,%,*,(,),'''',]%', cast (replace(IntOverdue,' ','') as varchar(38))), 1 ),''),'-',' ')
		ELSE replace(IntOverdue,' ','')
	END
IntOverdue
,
	CASE 
		WHEN replace(BalanceInCrncy,' ','') LIKE '%[^a-zA-Z0-9]%' 
		THEN Replace(REPLACE( cast (replace(BalanceInCrncy,' ','') as varchar(38)), SUBSTRING( cast (replace(BalanceInCrncy,' ','') as varchar(38)), PATINDEX('%[~,@,#,$,%,&,*,^,&,%,*,(,),'''',]%', cast (replace(BalanceInCrncy,' ','') as varchar(38))), 1 ),''),'-',' ')
		ELSE replace(BalanceInCrncy,' ','')
	END
BalanceInCrncy
,
	CASE 
		WHEN replace(Balance,' ','') LIKE '%[^a-zA-Z0-9]%' 
		THEN Replace(REPLACE( cast (replace(Balance,' ','') as varchar(38)), SUBSTRING( cast (replace(Balance,' ','') as varchar(38)), PATINDEX('%[~,@,#,$,%,&,*,^,&,%,*,(,),'''',]%', cast (replace(Balance,' ','') as varchar(38))), 1 ),''),'-',' ')
		ELSE replace(Balance,' ','')
	END
Balance
,
	CASE 
		WHEN replace(PrincOutStd,' ','') LIKE '%[^a-zA-Z0-9]%' 
		THEN Replace(REPLACE( cast (replace(PrincOutStd,' ','') as varchar(38)), SUBSTRING( cast (replace(PrincOutStd,' ','') as varchar(38)), PATINDEX('%[~,@,#,$,%,&,*,^,&,%,*,(,),'''',]%', cast (replace(PrincOutStd,' ','') as varchar(38))), 1 ),''),'-',' ')
		ELSE replace(PrincOutStd,' ','')
	END
PrincOutStd
,CD
,CurntQtrRv
,
	CASE 
		WHEN replace(TotalSecurityValue,' ','') LIKE '%[^a-zA-Z0-9]%' 
		THEN Replace(REPLACE( cast (replace(TotalSecurityValue,' ','') as varchar(38)), SUBSTRING( cast (replace(TotalSecurityValue,' ','') as varchar(38)), PATINDEX('%[~,@,#,$,%,&,*,^,&,%,*,(,),'''',]%', cast (replace(TotalSecurityValue,' ','') as varchar(38))), 1 ),''),'-',' ')
		ELSE replace(TotalSecurityValue,' ','')
	END
TotalSecurityValue
,
	CASE 
		WHEN replace(SecurityValue,' ','') LIKE '%[^a-zA-Z0-9]%' 
		THEN Replace(REPLACE( cast (replace(SecurityValue,' ','') as varchar(38)), SUBSTRING( cast (replace(SecurityValue,' ','') as varchar(38)), PATINDEX('%[~,@,#,$,%,&,*,^,&,%,*,(,),'''',]%', cast (replace(SecurityValue,' ','') as varchar(38))), 1 ),''),'-',' ')
		ELSE replace(SecurityValue,' ','')
	END
SecurityValue
,UsedRV
,ApprRV
,
	CASE 
		WHEN replace(SecuredAmt,' ','') LIKE '%[^a-zA-Z0-9]%' 
		THEN Replace(REPLACE( cast (replace(SecuredAmt,' ','') as varchar(38)), SUBSTRING( cast (replace(SecuredAmt,' ','') as varchar(38)), PATINDEX('%[~,@,#,$,%,&,*,^,&,%,*,(,),'''',]%', cast (replace(SecuredAmt,' ','') as varchar(38))), 1 ),''),'-',' ')
		ELSE replace(SecuredAmt,' ','')
	END
SecuredAmt
,
	CASE 
		WHEN replace(UnSecuredAmt,' ','') LIKE '%[^a-zA-Z0-9]%' 
		THEN Replace(REPLACE( cast (replace(UnSecuredAmt,' ','') as varchar(38)), SUBSTRING( cast (replace(UnSecuredAmt,' ','') as varchar(38)), PATINDEX('%[~,@,#,$,%,&,*,^,&,%,*,(,),'''',]%', cast (replace(UnSecuredAmt,' ','') as varchar(38))), 1 ),''),'-',' ')
		ELSE replace(UnSecuredAmt,' ','')
	END

UnSecuredAmt
,
	CASE 
		WHEN replace(BankProvsecured,' ','') LIKE '%[^a-zA-Z0-9]%' 
		THEN Replace(REPLACE( cast (replace(BankProvsecured,' ','') as varchar(38)), SUBSTRING( cast (replace(BankProvsecured,' ','') as varchar(38)), PATINDEX('%[~,@,#,$,%,&,*,^,&,%,*,(,),'''',]%', cast (replace(BankProvsecured,' ','') as varchar(38))), 1 ),''),'-',' ')
		ELSE replace(BankProvsecured,' ','')
	END

BankProvsecured
,
	CASE 
		WHEN replace(bankprovunsecured,' ','') LIKE '%[^a-zA-Z0-9]%' 
		THEN Replace(REPLACE( cast (replace(bankprovunsecured,' ','') as varchar(38)), SUBSTRING( cast (replace(bankprovunsecured,' ','') as varchar(38)), PATINDEX('%[~,@,#,$,%,&,*,^,&,%,*,(,),'''',]%', cast (replace(bankprovunsecured,' ','') as varchar(38))), 1 ),''),'-',' ')
		ELSE replace(bankprovunsecured,' ','')
	END
	
bankprovunsecured
,
	CASE 
		WHEN replace(BankTotalProvision,' ','') LIKE '%[^a-zA-Z0-9]%' 
		THEN Replace(REPLACE( cast (replace(BankTotalProvision,' ','') as varchar(38)), SUBSTRING( cast (replace(BankTotalProvision,' ','') as varchar(38)), PATINDEX('%[~,@,#,$,%,&,*,^,&,%,*,(,),'''',]%', cast (replace(BankTotalProvision,' ','') as varchar(38))), 1 ),''),'-',' ')
		ELSE replace(BankTotalProvision,' ','')
	END
BankTotalProvision
,
	CASE 
		WHEN replace(RBIProvsecured,' ','') LIKE '%[^a-zA-Z0-9]%' 
		THEN Replace(REPLACE( cast (replace(RBIProvsecured,' ','') as varchar(38)), SUBSTRING( cast (replace(RBIProvsecured,' ','') as varchar(38)), PATINDEX('%[~,@,#,$,%,&,*,^,&,%,*,(,),'''',]%', cast (replace(RBIProvsecured,' ','') as varchar(38))), 1 ),''),'-',' ')
		ELSE replace(RBIProvsecured,' ','')
	END
RBIProvsecured
,
	CASE 
		WHEN replace(RBIProvUnsecured,' ','') LIKE '%[^a-zA-Z0-9]%' 
		THEN Replace(REPLACE( cast (replace(RBIProvUnsecured,' ','') as varchar(38)), SUBSTRING( cast (replace(RBIProvUnsecured,' ','') as varchar(38)), PATINDEX('%[~,@,#,$,%,&,*,^,&,%,*,(,),'''',]%', cast (replace(RBIProvUnsecured,' ','') as varchar(38))), 1 ),''),'-',' ')
		ELSE replace(RBIProvUnsecured,' ','')
	END
	RBIProvUnsecured
,
	CASE 
		WHEN replace(RBITotalProvision,' ','') LIKE '%[^a-zA-Z0-9]%' 
		THEN Replace(REPLACE( cast (replace(RBITotalProvision,' ','') as varchar(38)), SUBSTRING( cast (replace(RBITotalProvision,' ','') as varchar(38)), PATINDEX('%[~,@,#,$,%,&,*,^,&,%,*,(,),'''',]%', cast (replace(RBITotalProvision,' ','') as varchar(38))), 1 ),''),'-',' ')
		ELSE replace(RBITotalProvision,' ','')
	END 
RBITotalProvision
,
	CASE 
		WHEN replace(Provsecured,' ','') LIKE '%[^a-zA-Z0-9]%' 
		THEN Replace(REPLACE( cast (replace(Provsecured,' ','') as varchar(38)), SUBSTRING( cast (replace(Provsecured,' ','') as varchar(38)), PATINDEX('%[~,@,#,$,%,&,*,^,&,%,*,(,),'''',]%', cast (replace(Provsecured,' ','') as varchar(38))), 1 ),''),'-',' ')
		ELSE replace(Provsecured,' ','')
	END
Provsecured
,
	CASE 
		WHEN replace(ProvUnsecured,' ','') LIKE '%[^a-zA-Z0-9]%' 
		THEN Replace(REPLACE( cast (replace(ProvUnsecured,' ','') as varchar(38)), SUBSTRING( cast (replace(ProvUnsecured,' ','') as varchar(38)), PATINDEX('%[~,@,#,$,%,&,*,^,&,%,*,(,),'''',]%', cast (replace(ProvUnsecured,' ','') as varchar(38))), 1 ),''),'-',' ')
		ELSE replace(ProvUnsecured,' ','')
	END
ProvUnsecured
,
	CASE 
		WHEN replace(TotalProvision,' ','') LIKE '%[^a-zA-Z0-9]%' 
		THEN Replace(REPLACE( cast (replace(TotalProvision,' ','') as varchar(38)), SUBSTRING( cast (replace(TotalProvision,' ','') as varchar(38)), PATINDEX('%[~,@,#,$,%,&,*,^,&,%,*,(,),'''',]%', cast (replace(TotalProvision,' ','') as varchar(38))), 1 ),''),'-',' ')
		ELSE replace(TotalProvision,' ','')
	END
TotalProvision
,
	CASE 
		WHEN replace(Absolute_Provision,' ','') LIKE '%[^a-zA-Z0-9]%' 
		THEN Replace(REPLACE( cast (replace(Absolute_Provision,' ','') as varchar(38)), SUBSTRING( cast (replace(Absolute_Provision,' ','') as varchar(38)), PATINDEX('%[~,@,#,$,%,&,*,^,&,%,*,(,),'''',]%', cast (replace(Absolute_Provision,' ','') as varchar(38))), 1 ),''),'-',' ')
		ELSE replace(Absolute_Provision,' ','')
	END
Absolute_Provision
,
	CASE 
		WHEN replace(FINAL_Provision,' ','') LIKE '%[^a-zA-Z0-9]%' 
		THEN Replace(REPLACE( cast (replace(FINAL_Provision,' ','') as varchar(38)), SUBSTRING( cast (replace(FINAL_Provision,' ','') as varchar(38)), PATINDEX('%[~,@,#,$,%,&,*,^,&,%,*,(,),'''',]%', cast (replace(FINAL_Provision,' ','') as varchar(38))), 1 ),''),'-',' ')
		ELSE replace(FINAL_Provision,' ','')
	END
FINAL_Provision
,ProvisionName
,ProvisionRule
,ProvisionSecured_per
,ProvisionUnSecured_per
,RBIProvisionSecured_per
,RBIProvisionUnSecured_per
,DPD_Overdrawn
,DPD_IntService
,DPD_Renewal
,DPD_Overdue
,DPD_StockStmt
,FlgRestructure
,FlgFraud
,RN

into #result
from #data



select 

Mark
,SystemName
,UCIF_ID
,RefCustomerID
,SourceSystemCustomerID
,CustomerName
,CustomerAcID
,ProductCode
,ProductName
,ActSegmentCode
,InitialAssetClass
,FinalAssetClass
,DegReason
,DPD_Max
,CurrencyCode
,CONVERT(numeric(16,0), CAST(IntOverdue AS FLOAT)) IntOverdue
,CONVERT(numeric(16,0), CAST(BalanceInCrncy AS FLOAT))  BalanceInCrncy
,CONVERT(numeric(16,0), CAST(Balance AS FLOAT))Balance
,CONVERT(numeric(16,0), CAST(PrincOutStd AS FLOAT)) PrincOutStd
,CD
,CurntQtrRv
,CONVERT(numeric(16,0), CAST(TotalSecurityValue AS FLOAT))TotalSecurityValue
,CONVERT(numeric(16,0), CAST(SecurityValue AS FLOAT)) SecurityValue
,UsedRV
,ApprRV
,CONVERT(numeric(16,0), CAST(SecuredAmt AS FLOAT)) SecuredAmt
,CONVERT(numeric(16,0), CAST(UnSecuredAmt AS FLOAT)) UnSecuredAmt
,CONVERT(numeric(16,0), CAST(BankProvsecured AS FLOAT))BankProvsecured
,CONVERT(numeric(16,0), CAST(bankprovunsecured AS FLOAT))bankprovunsecured
,CONVERT(numeric(16,0), CAST(BankTotalProvision AS FLOAT)) BankTotalProvision
,CONVERT(numeric(16,0), CAST(RBIProvsecured AS FLOAT)) RBIProvsecured
,CONVERT(numeric(16,0), CAST(RBIProvUnsecured AS FLOAT))RBIProvUnsecured
,CONVERT(numeric(16,0), CAST(RBITotalProvision AS FLOAT)) RBITotalProvision
,CONVERT(numeric(16,0), CAST(Provsecured AS FLOAT)) Provsecured
,CONVERT(numeric(16,0), CAST(ProvUnsecured AS FLOAT)) ProvUnsecured
,CONVERT(numeric(16,0), CAST(TotalProvision AS FLOAT)) TotalProvision
,CONVERT(numeric(16,0), CAST(Absolute_Provision AS FLOAT)) Absolute_Provision
,CONVERT(numeric(16,0), CAST(FINAL_Provision AS FLOAT))FINAL_Provision
,ProvisionName
,ProvisionRule
,ProvisionSecured_per
,ProvisionUnSecured_per
,RBIProvisionSecured_per
,RBIProvisionUnSecured_per
,DPD_Overdrawn
,DPD_IntService
,DPD_Renewal
,DPD_Overdue
,DPD_StockStmt
,FlgRestructure
,FlgFraud
,RN


from #result



order by Mark asc
GO