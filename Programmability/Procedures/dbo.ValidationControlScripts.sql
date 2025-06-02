SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO






Create PROCEDURE [dbo].[ValidationControlScripts]
  
AS 

BEGIN
  

DECLARE @TIMEKEY INT = (SELECT TIMEKEY FROM PRO.EXTDATE_MISDB WHERE FLG = 'Y')
DECLARE @PROCESSINGDATE DATE=(SELECT DATE FROM SYSDAYMATRIX WHERE TIMEKEY=@TIMEKEY) 
Declare @Cost   AS FLOAT=1
DECLARE @SUB_Days INT =(SELECT RefValue FROM PRO.refperiod WHERE BusinessRule='SUB_Days')
DECLARE @DB1_Days INT =(SELECT RefValue FROM PRO.refperiod WHERE BusinessRule='DB1_Days')
DECLARE @DB2_Days INT =(SELECT RefValue FROM PRO.refperiod WHERE BusinessRule='DB2_Days')
DECLARE @MoveToDB1 DECIMAL(5,2) =(SELECT cast(RefValue/100.00 as decimal(5,2))FROM PRO.refperiod where BusinessRule='MoveToDB1' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
DECLARE @MoveToLoss DECIMAL(5,2)=(SELECT cast(RefValue/100.00 as decimal(5,2)) FROM PRO.refperiod where BusinessRule='MoveToLoss' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
DECLARE @SETID INT =(SELECT ISNULL(MAX(ISNULL(SETID,0)),0)+1 FROM [PRO].[PROCESSMONITOR] WHERE TIMEKEY=@TIMEKEY)

INSERT INTO PRO.PROCESSMONITOR(USERID,DESCRIPTION,MODE,STARTTIME,ENDTIME,TIMEKEY,SETID)
SELECT ORIGINAL_LOGIN(),'INSERT DATA FOR ValidationControlScripts','RUNNING',GETDATE(),NULL,@TIMEKEY,@SETID

--------------------1. Completeness of the data flowing in the ENPA system--------------------
DELETE FROM YBL_ACS_MIS.DBO.BI_DATASUMMARY WHERE DATA_DATE IN (SELECT  max(DATA_DATE)   FROM YBL_ACS_MIS.DBO.CUSTOMERDATA)
INSERT INTO YBL_ACS_MIS.DBO.BI_DATASUMMARY
SELECT DISTINCT DATA_DATE,ETL_DATE,SOURCESYSTEMNAME,'CUSTOMER' DATA_TYPE,COUNT(1) ROW_COUNT,GETDATE() INSERT_TIME FROM YBL_ACS_MIS.DBO.CUSTOMERDATA                                                                                       
GROUP BY DATA_DATE,ETL_DATE,SOURCESYSTEMNAME                                                                                                                                                                                                         
UNION
SELECT DISTINCT DATA_DATE,ETL_DATE,SOURCESYSTEMNAME,'ACCOUNT' DATA_TYPE,COUNT(1) ROW_COUNT,GETDATE() INSERT_TIME FROM YBL_ACS_MIS.DBO.ACCOUNTDATA                                                                                                     
GROUP BY DATA_DATE,ETL_DATE,SOURCESYSTEMNAME
UNION
SELECT DISTINCT DateOfData,DateOfData,
SourceShortName,'CustCal' DATA_TYPE,COUNT(1) ROW_COUNT,
GETDATE() INSERT_TIME 
FROM pro.CustomerCal  a
inner join  dbo.DimSourceDB b
on a.SourceAlt_Key=b.SourceAlt_Key                                                                                  
GROUP BY DateOfData,DateOfData,SourceShortName
UNION
SELECT DISTINCT DateOfData,DateOfData,
SourceShortName,'AccCal' DATA_TYPE,COUNT(1) ROW_COUNT,
GETDATE() INSERT_TIME 
FROM pro.AccountCal  a
inner join  dbo.DimSourceDB b
on a.SourceAlt_Key=b.SourceAlt_Key                                                                                  
GROUP BY DateOfData,DateOfData,SourceShortName

--------------------1. Completeness of the data flowing in the ENPA system--------------------


--------------------2. Exceptional Standard Facilities 90--------------------

Delete from ControlScripts where ExceptionCode=2 and 
 ExceptionDescription='Exceptional Standard Facilities 90'  and EffectiveFromTimeKey=(select timekey from SysDataMatrix where CurrentStatus='C')

Insert into ControlScripts
(
UCIF_ID
,PANNO
,CustomerAcID
,RefCustomerID
,SourceSystemCustomerID
,CustomerName
,SourceName
,DPD_Max
,POS
,BalanceInCrncy
,Balance
,SysNPA_Dt
,FinalAssetClassName
,ExceptionCode
,ExceptionDescription
,EffectiveFromTimeKey
,EffectiveToTimeKey
)

SELECT  
CH.UCIF_ID
,CH.PanNO
,AH.CustomerAcID
,AH.RefCustomerID
,AH.SourceSystemCustomerID
,CH.CustomerName
,DB.SourceName
,AH.DPD_Max
,case when DimProduct.ProductCode ='NSLI' then 0      when ISNULL(AH.PrincOutStd,0)<0 then 0 else ISNULL(AH.PrincOutStd,0) end/1  AS POS
,case when ISNULL(AH.BalanceInCrncy,0)<0 then 0 else ISNULL (AH.BalanceInCrncy,0)end /1     AS BalanceInCrncy
,case when ISNULL(AH.Balance,0)<0 then 0 else  ISNULL(AH.Balance,0)end/1     AS Balance
,CONVERT(VARCHAR(20),CH.SysNPA_Dt,103)                AS SysNPA_Dt
,DA.AssetClassShortName                          AS FinalAssetClassName
,2 AS ExceptionCode
,'Exceptional Standard Facilities 90'  AS ExceptionDescription
,AH.EffectiveFromTimeKey
,AH.EffectiveToTimeKey

FROM PRO.CUSTOMERCAL CH
              
INNER JOIN PRO.ACCOUNTCAL      AH                  ON CH.SourceSystemCustomerID=AH.SourceSystemCustomerID AND
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
where DPD_Max>90
AND Ah.FinalAssetClassAlt_Key=1
and Ah.Asset_Norm<>'ALWYS_STD'
AND ISNULL(DimProduct.PRODUCTGROUP,'N')<>'KCC'
AND ((isnull(LineCode,'NA') NOT LIKE '%CROP_OD_F%' and isnull(LineCode,'NA')  NOT LIKE '%CROP_DLOD%' and isnull(LineCode,'NA')  Not LIKE '%CROP_TL_F%'))
--OR( (ACCOUNTSTATUS LIKE '%CROP LOAN (OTHER THAN PL%' OR ACCOUNTSTATUS LIKE '%CROP LOAN (PLANT N HORTI%' OR ACCOUNTSTATUS LIKE '%PRE AND POST-HARVEST ACT%'
-- OR ACCOUNTSTATUS LIKE ,'%FARMERS AGAINST HYPOTHEC%' OR ACCOUNTSTATUS LIKE '%FARMERS AGAINST PLEDGE O%' OR ACCOUNTSTATUS LIKE '%PLANTATION/HORTICULTURE%'
-- OR ACCOUNTSTATUS LIKE '%365_CROP LOAN_OTR THAN PL%'
-- OR ACCOUNTSTATUS LIKE '%365_CROP LOAN_PLANT/HORTI%'
-- OR ACCOUNTSTATUS LIKE '%365_DEVELOPMENTAL ACTIVI%'
-- OR ACCOUNTSTATUS LIKE '%365_LAND DEVELOPMENT%'
-- OR ACCOUNTSTATUS LIKE '%365_PLANTATION/HORTI%'
-- ))
--) 

and ( 
			          isnull(DPD_IntService,0)>=isnull(RefPeriodIntService,0)
                   OR isnull(DPD_NoCredit,0)>=isnull(RefPeriodNoCredit,0)
				   OR isnull(DPD_Overdrawn,0)>=isnull(RefPeriodOverDrawn,0)
				   OR isnull(DPD_Overdue,0)>=isnull(RefPeriodOverdue,0)
				   OR isnull(DPD_Renewal,0)>=isnull(RefPeriodReview,0)
                   OR isnull(DPD_StockStmt,0)>=isnull(RefPeriodStkStatement,0)
			      ) 

and ISNULL(AH.Balance,0)>0

--------------------2. Exceptional Standard Facilities 90--------------------

--------------------2. Exceptional Standard Facilities 365--------------------

update ControlScripts set ExceptionCode=15 where ExceptionDescription='Exceptional Standard Facilities 365'
and ExceptionCode=2

Delete from ControlScripts
where ExceptionCode=15 and ExceptionDescription='Exceptional Standard Facilities 365' 
and EffectiveFromTimeKey=(select timekey from SysDataMatrix where CurrentStatus='C')

Insert into ControlScripts
(
UCIF_ID
,PANNO
,CustomerAcID
,RefCustomerID
,SourceSystemCustomerID
,CustomerName
,SourceName
,DPD_Max
,POS
,BalanceInCrncy
,Balance
,SysNPA_Dt
,FinalAssetClassName
,ExceptionCode
,ExceptionDescription
,EffectiveFromTimeKey
,EffectiveToTimeKey
)

SELECT  
CH.UCIF_ID
,CH.PanNO
,AH.CustomerAcID
,AH.RefCustomerID
,AH.SourceSystemCustomerID
,CH.CustomerName
,DB.SourceName
,AH.DPD_Max
,case when DimProduct.ProductCode ='NSLI' then 0      when ISNULL(AH.PrincOutStd,0)<0 then 0 else ISNULL(AH.PrincOutStd,0) end/@cost  AS POS
,case when ISNULL(AH.BalanceInCrncy,0)<0 then 0 else ISNULL (AH.BalanceInCrncy,0)end /@cost     AS BalanceInCrncy
,case when ISNULL(AH.Balance,0)<0 then 0 else  ISNULL(AH.Balance,0)end/@cost     AS Balance
,CONVERT(VARCHAR(20),CH.SysNPA_Dt,103)                AS SysNPA_Dt
,DA.AssetClassShortName                          AS FinalAssetClassName
,15 AS ExceptionCode
,'Exceptional Standard Facilities 365'  AS ExceptionDescription
,AH.EffectiveFromTimeKey
,AH.EffectiveToTimeKey
FROM PRO.CUSTOMERCAL CH
              
INNER JOIN PRO.ACCOUNTCAL      AH                  ON CH.SourceSystemCustomerID=AH.SourceSystemCustomerID AND
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
where DPD_Max>365
AND Ah.FinalAssetClassAlt_Key=1
and Ah.Asset_Norm<>'ALWYS_STD'
AND (ISNULL(DimProduct.PRODUCTGROUP,'N')='KCC'
OR ((LineCode LIKE '%CROP_OD_F%' or LineCode LIKE '%CROP_DLOD%' or LineCode LIKE '%CROP_TL_F%'))
OR( (ACCOUNTSTATUS LIKE '%CROP LOAN (OTHER THAN PL%' OR ACCOUNTSTATUS LIKE '%CROP LOAN (PLANT N HORTI%' OR ACCOUNTSTATUS LIKE '%PRE AND POST-HARVEST ACT%'
 OR ACCOUNTSTATUS LIKE '%FARMERS AGAINST HYPOTHEC%' OR ACCOUNTSTATUS LIKE '%FARMERS AGAINST PLEDGE O%' OR ACCOUNTSTATUS LIKE '%PLANTATION/HORTICULTURE%'
 OR ACCOUNTSTATUS LIKE '%365_CROP LOAN_OTR THAN PL%'
 OR ACCOUNTSTATUS LIKE '%365_CROP LOAN_PLANT/HORTI%'
 OR ACCOUNTSTATUS LIKE '%365_DEVELOPMENTAL ACTIVI%'
 OR ACCOUNTSTATUS LIKE '%365_LAND DEVELOPMENT%'
 OR ACCOUNTSTATUS LIKE '%365_PLANTATION/HORTI%'
 ))
) 
and ISNULL(AH.Balance,0)>0
--------------------2. Exceptional Standard Facilities 365--------------------



--------------------2. Exceptional Standard Facilities 90--------------------

Delete from ControlScripts where ExceptionCode=16 and 
 ExceptionDescription='Exceptional Standard Facilities DPD More Than 90 and Balance Zero'  and EffectiveFromTimeKey=(select timekey from SysDataMatrix where CurrentStatus='C')

Insert into ControlScripts
(
UCIF_ID
,PANNO
,CustomerAcID
,RefCustomerID
,SourceSystemCustomerID
,CustomerName
,SourceName
,DPD_Max
,POS
,BalanceInCrncy
,Balance
,SysNPA_Dt
,FinalAssetClassName
,ExceptionCode
,ExceptionDescription
,EffectiveFromTimeKey
,EffectiveToTimeKey
)

SELECT  
CH.UCIF_ID
,CH.PanNO
,AH.CustomerAcID
,AH.RefCustomerID
,AH.SourceSystemCustomerID
,CH.CustomerName
,DB.SourceName
,AH.DPD_Max
,case when DimProduct.ProductCode ='NSLI' then 0      when ISNULL(AH.PrincOutStd,0)<0 then 0 else ISNULL(AH.PrincOutStd,0) end/1  AS POS
,case when ISNULL(AH.BalanceInCrncy,0)<0 then 0 else ISNULL (AH.BalanceInCrncy,0)end /1     AS BalanceInCrncy
,case when ISNULL(AH.Balance,0)<0 then 0 else  ISNULL(AH.Balance,0)end/1     AS Balance
,CONVERT(VARCHAR(20),CH.SysNPA_Dt,103)                AS SysNPA_Dt
,DA.AssetClassShortName                          AS FinalAssetClassName
,16 AS ExceptionCode
,'Exceptional Standard Facilities DPD More Than 90 and Balance Zero'  AS ExceptionDescription
,AH.EffectiveFromTimeKey
,AH.EffectiveToTimeKey

FROM PRO.CUSTOMERCAL CH
              
INNER JOIN PRO.ACCOUNTCAL      AH                  ON CH.SourceSystemCustomerID=AH.SourceSystemCustomerID AND
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
where DPD_Max>90
AND Ah.FinalAssetClassAlt_Key=1
and Ah.Asset_Norm<>'ALWYS_STD'
AND ISNULL(DimProduct.PRODUCTGROUP,'N')<>'KCC'
AND ((isnull(LineCode,'NA') NOT LIKE '%CROP_OD_F%' and isnull(LineCode,'NA')  NOT LIKE '%CROP_DLOD%' and isnull(LineCode,'NA')  Not LIKE '%CROP_TL_F%'))
and ( 
			          isnull(DPD_IntService,0)>=isnull(RefPeriodIntService,0)
                   OR isnull(DPD_NoCredit,0)>=isnull(RefPeriodNoCredit,0)
				   OR isnull(DPD_Overdrawn,0)>=isnull(RefPeriodOverDrawn,0)
				   OR isnull(DPD_Overdue,0)>=isnull(RefPeriodOverdue,0)
				   OR isnull(DPD_Renewal,0)>=isnull(RefPeriodReview,0)
                   OR isnull(DPD_StockStmt,0)>=isnull(RefPeriodStkStatement,0)
			      ) 

and ISNULL(AH.Balance,0)<=0

--------------------2. Exceptional Standard Facilities 90--------------------

------------------3. Exceptional NPA Facilities------------------


Delete from ControlScripts
where ExceptionCode=3 
and EffectiveFromTimeKey=(select timekey from SysDataMatrix where CurrentStatus='C')

IF OBJECT_ID('TEMPDB..#TempZeroDpd') IS NOT NULL
  DROP TABLE #TempZeroDpd

select UCIF_ID,sum(DPD_Max)  as DPD_Max, 'Normal' as Status
into #TempZeroDpd
 from pro.AccountCal
where UCIF_ID is not null
and FinalAssetClassAlt_Key>1
group by UCIF_ID
having sum(DPD_Max)=0

Delete from a from #TempZeroDpd a inner join   pro.AccountCal b on a.UCIF_ID=b.UCIF_ID and b.SPLCATG1ALT_KEY=870
Delete from a from #TempZeroDpd a inner join   pro.AccountCal b on a.UCIF_ID=b.UCIF_ID and b.Asset_Norm='ALWYS_NPA'
Delete from a from #TempZeroDpd a inner join   pro.AccountCal b on a.UCIF_ID=b.UCIF_ID and b.Asset_Norm='WRITEOFF'
Delete from a from #TempZeroDpd a inner join   pro.AccountCal b on a.UCIF_ID=b.UCIF_ID and b.AccountBlkCode1='W'
Delete from a from #TempZeroDpd a inner join   pro.AccountCal b on a.UCIF_ID=b.UCIF_ID and b.AccountBlkCode2='W'
 


Insert into ControlScripts
(
UCIF_ID
,PANNO
,CustomerAcID
,RefCustomerID
,SourceSystemCustomerID
,CustomerName
,SourceName
,DPD_Max
,POS
,BalanceInCrncy
,Balance
,SysNPA_Dt
,FinalAssetClassName
,ExceptionCode
,ExceptionDescription
,EffectiveFromTimeKey
,EffectiveToTimeKey

)

SELECT  
CH.UCIF_ID
,CH.PanNO
,AH.CustomerAcID
,AH.RefCustomerID
,AH.SourceSystemCustomerID
,CH.CustomerName
,DB.SourceName
,AH.DPD_Max
,case when DimProduct.ProductCode ='NSLI' then 0      when ISNULL(AH.PrincOutStd,0)<0 then 0 else ISNULL(AH.PrincOutStd,0) end/@cost  AS POS
,case when ISNULL(AH.BalanceInCrncy,0)<0 then 0 else ISNULL (AH.BalanceInCrncy,0)end /@cost     AS BalanceInCrncy
,case when ISNULL(AH.Balance,0)<0 then 0 else  ISNULL(AH.Balance,0)end/@cost     AS Balance
,CONVERT(VARCHAR(20),CH.SysNPA_Dt,103)                AS SysNPA_Dt
,DA.AssetClassShortName                          AS FinalAssetClassName
,3 AS ExceptionCode
,'Exceptional NPA Facilities'  AS ExceptionDescription
,AH.EffectiveFromTimeKey
,AH.EffectiveToTimeKey

FROM PRO.CUSTOMERCAL CH
              
INNER JOIN PRO.ACCOUNTCAL      AH                  ON CH.SourceSystemCustomerID=AH.SourceSystemCustomerID AND
														  AH.EffectiveFromTimeKey=@Timekey AND
														  AH.EffectiveToTimeKey=@Timekey AND
														  CH.EffectiveFromTimeKey=@Timekey AND
		                                                  CH.EffectiveToTimeKey=@Timekey

INNER JOIN #TempZeroDpd ZeroDpd ON ZeroDpd.UCIF_ID=CH.UCIF_ID
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
--where DPD_Max<=90
--AND Ah.FinalAssetClassAlt_Key>1
--and Ah.Asset_Norm<>'ALWYS_NPA' and AH.DegReason NOT LIKE '%Percolation%'

WHERE Ah.SPLCATG1ALT_KEY<>870
AND  ISNULL(Ah.FlgRestructure,'N')<>'Y'
AND  Ah.Asset_Norm<>'ALWYS_NPA'
and ISNULL(AH.Balance,0)>0
AND ISNULL(Ah.BANKASSETCLASS,'N')<>'WRITEOFF'
AND  ISNULL(Ah.AccountBlkCode1,'N')<>'W' AND  ISNULL(Ah.AccountBlkCode2,'N')<>'W'
AND Ah.DegReason<>'ALWYS_NPA DUE TO RESTRUCTURE'

------------------3. Exceptional NPA Facilities------------------



------------------4. Fresh Slippages Not tagged as Sub Standard------------------ 


Delete from ControlScripts
where ExceptionCode=4 
and EffectiveFromTimeKey=(select timekey from SysDataMatrix where CurrentStatus='C')

Insert into ControlScripts
(
UCIF_ID
,PANNO
,CustomerAcID
,RefCustomerID
,SourceSystemCustomerID
,CustomerName
,SourceName
,DPD_Max
,POS
,BalanceInCrncy
,Balance
,SysNPA_Dt
,FinalAssetClassName
,ExceptionCode
,ExceptionDescription
,EffectiveFromTimeKey
,EffectiveToTimeKey

)

SELECT  
CH.UCIF_ID
,CH.PanNO
,AH.CustomerAcID
,AH.RefCustomerID
,AH.SourceSystemCustomerID
,CH.CustomerName
,DB.SourceName
,AH.DPD_Max
,case when DimProduct.ProductCode ='NSLI' then 0      when ISNULL(AH.PrincOutStd,0)<0 then 0 else ISNULL(AH.PrincOutStd,0) end/@cost  AS POS
,case when ISNULL(AH.BalanceInCrncy,0)<0 then 0 else ISNULL (AH.BalanceInCrncy,0)end /@cost     AS BalanceInCrncy
,case when ISNULL(AH.Balance,0)<0 then 0 else  ISNULL(AH.Balance,0)end/@cost     AS Balance
,CONVERT(VARCHAR(20),CH.SysNPA_Dt,103)                AS SysNPA_Dt
,DA.AssetClassShortName                          AS FinalAssetClassName
,4 AS ExceptionCode
,'Fresh Slippages Not tagged as Sub Standard'  AS ExceptionDescription
,AH.EffectiveFromTimeKey
,AH.EffectiveToTimeKey
FROM PRO.CUSTOMERCAL CH
              
INNER JOIN PRO.ACCOUNTCAL      AH                  ON CH.SourceSystemCustomerID=AH.SourceSystemCustomerID AND
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
where CH.FlgDeg='Y'
AND AH.FinalAssetClassAlt_Key  IN (3,4,5,6)

------------------4. Fresh Slippages Not tagged as Sub Standard------------------ 

------------------5. Exceptional aging of NPA facilities------------------


Delete from ControlScripts
where ExceptionCode=5 
and EffectiveFromTimeKey=(select timekey from SysDataMatrix where CurrentStatus='C')


Insert into ControlScripts
(
UCIF_ID
,PANNO
,CustomerAcID
,RefCustomerID
,SourceSystemCustomerID
,CustomerName
,SourceName
,DPD_Max
,POS
,BalanceInCrncy
,Balance
,SysNPA_Dt
,FinalAssetClassName
,ExceptionCode
,ExceptionDescription
,EffectiveFromTimeKey
,EffectiveToTimeKey

)


SELECT  
CH.UCIF_ID
,CH.PanNO
,AH.CustomerAcID
,AH.RefCustomerID
,AH.SourceSystemCustomerID
,CH.CustomerName
,DB.SourceName
,AH.DPD_Max
,case when DimProduct.ProductCode ='NSLI' then 0      when ISNULL(AH.PrincOutStd,0)<0 then 0 else ISNULL(AH.PrincOutStd,0) end/@cost  AS POS
,case when ISNULL(AH.BalanceInCrncy,0)<0 then 0 else ISNULL (AH.BalanceInCrncy,0)end /@cost     AS BalanceInCrncy
,case when ISNULL(AH.Balance,0)<0 then 0 else  ISNULL(AH.Balance,0)end/@cost     AS Balance
,CONVERT(VARCHAR(20),CH.SysNPA_Dt,103)                AS SysNPA_Dt
,DA.AssetClassShortName                          AS FinalAssetClassName
,5 AS ExceptionCode
,'Exceptional aging of NPA facilities'  AS ExceptionDescription
,AH.EffectiveFromTimeKey
,AH.EffectiveToTimeKey
FROM PRO.CUSTOMERCAL CH
              
INNER JOIN PRO.ACCOUNTCAL      AH                  ON CH.SourceSystemCustomerID=AH.SourceSystemCustomerID AND
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
where  AH.FinalAssetClassAlt_Key  IN (2,3,4,5)
and ( 
SysAssetClassAlt_Key=2 and DATEDIFF(DAY,SysNPA_Dt,ProcessingDt)>365 
or(SysAssetClassAlt_Key=3 and DATEDIFF(DAY,SysNPA_Dt,ProcessingDt)<365 ) 
or(SysAssetClassAlt_Key=4 and DATEDIFF(DAY,SysNPA_Dt,ProcessingDt)<730 ) 
or(SysAssetClassAlt_Key=5 and DATEDIFF(DAY,SysNPA_Dt,ProcessingDt)<1460 ) 
)
and isnull(AH.FlgMoc,'N')<>'Y' and isnull(CH.FlgMoc,'N')<>'Y'AND CH.DegReason NOT LIKE '%MOC%'
and isnull(ah.balance,0)>0 and CH.DegReason NOT LIKE '%EROSION%'
------------------5. Exceptional aging of NPA facilities------------------




------------------6. Customers having Multiple NPA date in different facilities across Customer ID & PAN------------------


Delete from ControlScripts
where ExceptionCode=6
and EffectiveFromTimeKey=(select timekey from SysDataMatrix where CurrentStatus='C')

IF OBJECT_ID('TEMPDB..#TempTableNpaCustomers') IS NOT NULL
  DROP TABLE #TempTableNpaCustomers

	SELECT UCIF_ID,RefCustomerID,SourceSystemCustomerID,PANNO,SysAssetClassAlt_Key,SysNPA_Dt
	 INTO #TempTableNpaCustomers FROM PRO.CUSTOMERCAL A
	  INNER JOIN DIMSOURCEDB  B ON B.SOURCEALT_KEY=A.SOURCEALT_KEY 
	  AND	A.EFFECTIVEFROMTIMEKEY=@TIMEKEY AND A.EFFECTIVETOTIMEKEY=@TIMEKEY
	   AND B.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND B.EFFECTIVETOTIMEKEY>=@TIMEKEY
	  WHERE  ISNULL(SYSASSETCLASSALT_KEY,1)<>1
	 GROUP BY  UCIF_ID,RefCustomerID,SourceSystemCustomerID,PANNO,SysAssetClassAlt_Key,SysNPA_Dt

IF OBJECT_ID('TEMPDB..#DuplicateNpaDt') IS NOT NULL
  DROP TABLE #DuplicateNpaDt

	 
select A.SourceSystemCustomerID 
Into #DuplicateNpaDt
from #TempTableNpaCustomers A
INNER JOIN #TempTableNpaCustomers B
ON A.SourceSystemCustomerID=B.SourceSystemCustomerID
AND A.SysNPA_Dt<>B.SysNPA_Dt
UNION
select A.SourceSystemCustomerID  from #TempTableNpaCustomers A
INNER JOIN #TempTableNpaCustomers B
ON A.PANNO=B.PANNO
AND A.SysNPA_Dt<>B.SysNPA_Dt
WHERE A.PANNO IS NOT NULL AND B.PANNO IS NOT NULL


Insert into ControlScripts
(
UCIF_ID
,PANNO
,CustomerAcID
,RefCustomerID
,SourceSystemCustomerID
,CustomerName
,SourceName
,DPD_Max
,POS
,BalanceInCrncy
,Balance
,SysNPA_Dt
,FinalAssetClassName
,ExceptionCode
,ExceptionDescription
,EffectiveFromTimeKey
,EffectiveToTimeKey

)


SELECT  
CH.UCIF_ID
,CH.PanNO
,AH.CustomerAcID
,AH.RefCustomerID
,AH.SourceSystemCustomerID
,CH.CustomerName
,DB.SourceName
,AH.DPD_Max
,case when DimProduct.ProductCode ='NSLI' then 0      when ISNULL(AH.PrincOutStd,0)<0 then 0 else ISNULL(AH.PrincOutStd,0) end/@cost  AS POS
,case when ISNULL(AH.BalanceInCrncy,0)<0 then 0 else ISNULL (AH.BalanceInCrncy,0)end /@cost     AS BalanceInCrncy
,case when ISNULL(AH.Balance,0)<0 then 0 else  ISNULL(AH.Balance,0)end/@cost     AS Balance
,CONVERT(VARCHAR(20),CH.SysNPA_Dt,103)                AS SysNPA_Dt
,DA.AssetClassShortName                          AS FinalAssetClassName
,6 AS ExceptionCode
,'Customers having Multiple NPA date in different facilities across Customer ID & PAN'  AS ExceptionDescription
,AH.EffectiveFromTimeKey
,AH.EffectiveToTimeKey
FROM PRO.CUSTOMERCAL CH
              
INNER JOIN PRO.ACCOUNTCAL      AH                  ON CH.SourceSystemCustomerID=AH.SourceSystemCustomerID AND
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

inner join  #DuplicateNpaDt on #DuplicateNpaDt.SourceSystemCustomerID=CH.SourceSystemCustomerID 

LEFT  JOIN DimProduct                                  ON DimProduct.ProductAlt_Key=AH.ProductAlt_Key AND 
                                                           DimProduct.EffectiveFromTimeKey<=@Timekey AND
													       DimProduct.EffectiveToTimeKey>=@Timekey

LEFT JOIN DimCurrency                                  ON  DimCurrency.CurrencyAlt_Key= AH.CurrencyAlt_Key	AND
			                                               DimCurrency.EffectiveFromTimeKey<=@Timekey AND
														   DimCurrency.EffectiveToTimeKey>=@Timekey
where  AH.FinalAssetClassAlt_Key  IN (2,3,4,5,6)

------------------6. Customers having Multiple NPA date in different facilities across Customer ID & PAN------------------

------------------7. Customers having different asset class in different facilities across Customer ID & PAN------------------ 


Delete from ControlScripts
where ExceptionCode=7 
and EffectiveFromTimeKey=(select timekey from SysDataMatrix where CurrentStatus='C')

IF OBJECT_ID('TEMPDB..#TempTableCustomersAsset') IS NOT NULL
  DROP TABLE #TempTableCustomersAsset

	SELECT A.UCIF_ID,A.RefCustomerID,A.SourceSystemCustomerID,A.PANNO,A.SysAssetClassAlt_Key,A.SysNPA_Dt
	 INTO #TempTableCustomersAsset FROM PRO.CUSTOMERCAL A
	  INNER JOIN DIMSOURCEDB  B ON B.SOURCEALT_KEY=A.SOURCEALT_KEY 
	  AND A.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND A.EFFECTIVETOTIMEKEY>=@TIMEKEY
	   AND	B.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND B.EFFECTIVETOTIMEKEY>=@TIMEKEY
	inner join pro.accountcal c on a.SourceSystemCustomerID=c.SourceSystemCustomerID
	 -- WHERE  ISNULL(SYSASSETCLASSALT_KEY,1)<>1
	 GROUP BY  A.UCIF_ID,A.RefCustomerID,A.SourceSystemCustomerID,A.PANNO,A.SysAssetClassAlt_Key,A.SysNPA_Dt

IF OBJECT_ID('TEMPDB..#DuplicateAssetClass') IS NOT NULL
  DROP TABLE #DuplicateAssetClass

select A.SourceSystemCustomerID 
Into #DuplicateAssetClass from #TempTableCustomersAsset A
INNER JOIN #TempTableCustomersAsset B
ON A.SourceSystemCustomerID=B.SourceSystemCustomerID
AND A.SysAssetClassAlt_Key<>B.SysAssetClassAlt_Key
union
select A.SourceSystemCustomerID from #TempTableCustomersAsset A
INNER JOIN #TempTableCustomersAsset B
ON A.PANNO=B.PANNO
AND A.SysAssetClassAlt_Key<>B.SysAssetClassAlt_Key
WHERE A.PANNO IS NOT NULL AND B.PANNO IS NOT NULL 

Insert into ControlScripts
(
UCIF_ID
,PANNO
,CustomerAcID
,RefCustomerID
,SourceSystemCustomerID
,CustomerName
,SourceName
,DPD_Max
,POS
,BalanceInCrncy
,Balance
,SysNPA_Dt
,FinalAssetClassName
,ExceptionCode
,ExceptionDescription
,EffectiveFromTimeKey
,EffectiveToTimeKey

)


SELECT  
CH.UCIF_ID
,CH.PanNO
,AH.CustomerAcID
,AH.RefCustomerID
,AH.SourceSystemCustomerID
,CH.CustomerName
,DB.SourceName
,AH.DPD_Max
,case when DimProduct.ProductCode ='NSLI' then 0      when ISNULL(AH.PrincOutStd,0)<0 then 0 else ISNULL(AH.PrincOutStd,0) end/@cost  AS POS
,case when ISNULL(AH.BalanceInCrncy,0)<0 then 0 else ISNULL (AH.BalanceInCrncy,0)end /@cost     AS BalanceInCrncy
,case when ISNULL(AH.Balance,0)<0 then 0 else  ISNULL(AH.Balance,0)end/@cost     AS Balance
,CONVERT(VARCHAR(20),CH.SysNPA_Dt,103)                AS SysNPA_Dt
,DA.AssetClassShortName                          AS FinalAssetClassName
,7 AS ExceptionCode
,'Customers having different asset class in different facilities across Customer ID & PAN'  AS ExceptionDescription
,AH.EffectiveFromTimeKey
,AH.EffectiveToTimeKey
FROM PRO.CUSTOMERCAL CH
              
INNER JOIN PRO.ACCOUNTCAL     AH                  ON CH.SourceSystemCustomerID=AH.SourceSystemCustomerID AND
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
inner join  #DuplicateAssetClass on #DuplicateAssetClass.SourceSystemCustomerID=CH.SourceSystemCustomerID 

LEFT  JOIN DimProduct                                  ON DimProduct.ProductAlt_Key=AH.ProductAlt_Key AND 
                                                           DimProduct.EffectiveFromTimeKey<=@Timekey AND
													       DimProduct.EffectiveToTimeKey>=@Timekey

LEFT JOIN DimCurrency                                  ON  DimCurrency.CurrencyAlt_Key= AH.CurrencyAlt_Key	AND
			                                               DimCurrency.EffectiveFromTimeKey<=@Timekey AND
														   DimCurrency.EffectiveToTimeKey>=@Timekey
--where  AH.FinalAssetClassAlt_Key  IN (2)
WHERE AH.ASSET_NORM<>'ALWYS_STD' and ISNULL(AH.Balance,0)>0
and CH.ASSET_NORM<>'ALWYS_STD' 
and isnull(AH.FlgMoc,'N')<>'Y' and isnull(CH.FlgMoc,'N')<>'Y'AND CH.DegReason NOT LIKE '%MOC%'
and CH.DegReason NOT LIKE '%EROSION%'
------------------7. Customers having different asset class in different facilities across Customer ID & PAN------------------ 


------------------8. Customers appearing in slippage & upgradation on same date------------------

Delete from ControlScripts
where ExceptionCode=8 
and EffectiveFromTimeKey=(select timekey from SysDataMatrix where CurrentStatus='C')

IF OBJECT_ID('TEMPDB..#TempTableFreshSillapge') IS NOT NULL
  DROP TABLE #TempTableFreshSillapge

	SELECT UCIF_ID,RefCustomerID,SourceSystemCustomerID,CustomerAcID
	 INTO #TempTableFreshSillapge FROM PRO.AccountCal Ah
	  INNER JOIN DIMSOURCEDB  B ON B.SOURCEALT_KEY=Ah.SOURCEALT_KEY 
	  AND Ah.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND Ah.EFFECTIVETOTIMEKEY>=@TIMEKEY
	  AND B.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND B.EFFECTIVETOTIMEKEY>=@TIMEKEY
	  WHERE  Ah.FlgDeg='Y'
	 
	 IF OBJECT_ID('TEMPDB..#TempTableUpgrade') IS NOT NULL
		DROP TABLE #TempTableUpgrade

	SELECT UCIF_ID,RefCustomerID,SourceSystemCustomerID,CustomerAcID
	 INTO #TempTableUpgrade FROM PRO.AccountCal Ah
	  INNER JOIN DIMSOURCEDB  B ON B.SOURCEALT_KEY=Ah.SOURCEALT_KEY 
	  AND Ah.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND Ah.EFFECTIVETOTIMEKEY>=@TIMEKEY
	  AND B.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND B.EFFECTIVETOTIMEKEY>=@TIMEKEY
	  WHERE  Ah.FlgUpg='U'

	  IF OBJECT_ID('TEMPDB..#TempTableFreshSillapgeUpgrade') IS NOT NULL
		DROP TABLE #TempTableFreshSillapgeUpgrade

	  SELECT A.CustomerAcID INTO #TempTableFreshSillapgeUpgrade
	   FROM #TempTableFreshSillapge A
	  INNER JOIN #TempTableUpgrade B
	  ON A.CustomerAcID=B.CustomerAcID

	  
Insert into ControlScripts
(
UCIF_ID
,PANNO
,CustomerAcID
,RefCustomerID
,SourceSystemCustomerID
,CustomerName
,SourceName
,DPD_Max
,POS
,BalanceInCrncy
,Balance
,SysNPA_Dt
,FinalAssetClassName
,ExceptionCode
,ExceptionDescription
,EffectiveFromTimeKey
,EffectiveToTimeKey

)

SELECT  
CH.UCIF_ID
,CH.PanNO
,AH.CustomerAcID
,AH.RefCustomerID
,AH.SourceSystemCustomerID
,CH.CustomerName
,DB.SourceName
,AH.DPD_Max
,case when DimProduct.ProductCode ='NSLI' then 0      when ISNULL(AH.PrincOutStd,0)<0 then 0 else ISNULL(AH.PrincOutStd,0) end/@cost  AS POS
,case when ISNULL(AH.BalanceInCrncy,0)<0 then 0 else ISNULL (AH.BalanceInCrncy,0)end /@cost     AS BalanceInCrncy
,case when ISNULL(AH.Balance,0)<0 then 0 else  ISNULL(AH.Balance,0)end/@cost     AS Balance
,CONVERT(VARCHAR(20),CH.SysNPA_Dt,103)                AS SysNPA_Dt
,DA.AssetClassShortName                          AS FinalAssetClassName
,8 AS ExceptionCode
,'Customers appearing in slippage & upgradation on same date'  AS ExceptionDescription
,AH.EffectiveFromTimeKey
,AH.EffectiveToTimeKey
FROM PRO.CUSTOMERCAL CH
              
INNER JOIN PRO.ACCOUNTCAL     AH                  ON CH.SourceSystemCustomerID=AH.SourceSystemCustomerID AND
														  AH.EffectiveFromTimeKey=@Timekey AND
														  AH.EffectiveToTimeKey=@Timekey AND
														  CH.EffectiveFromTimeKey=@Timekey AND
		                                                  CH.EffectiveToTimeKey=@Timekey

INNER JOIN #TempTableFreshSillapgeUpgrade SU ON SU.CustomerAcID=AH.CustomerAcID

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

------------------8. Customers appearing in slippage & upgradation on same date------------------

------------------9. Customers slipped to NPA without having Debit Freeze Flag------------------


Delete from ControlScripts
where ExceptionCode=9 
and EffectiveFromTimeKey=(select timekey from SysDataMatrix where CurrentStatus='C')

Insert into ControlScripts
(
UCIF_ID
,PANNO
,CustomerAcID
,RefCustomerID
,SourceSystemCustomerID
,CustomerName
,SourceName
,DPD_Max
,POS
,BalanceInCrncy
,Balance
,SysNPA_Dt
,FinalAssetClassName
,ExceptionCode
,ExceptionDescription
,EffectiveFromTimeKey
,EffectiveToTimeKey

)

SELECT  
CH.UCIF_ID
,CH.PanNO
,AH.CustomerAcID
,AH.RefCustomerID
,AH.SourceSystemCustomerID
,CH.CustomerName
,DB.SourceName
,AH.DPD_Max
,case when DimProduct.ProductCode ='NSLI' then 0      when ISNULL(AH.PrincOutStd,0)<0 then 0 else ISNULL(AH.PrincOutStd,0) end/@cost  AS POS
,case when ISNULL(AH.BalanceInCrncy,0)<0 then 0 else ISNULL (AH.BalanceInCrncy,0)end /@cost     AS BalanceInCrncy
,case when ISNULL(AH.Balance,0)<0 then 0 else  ISNULL(AH.Balance,0)end/@cost     AS Balance
,CONVERT(VARCHAR(20),CH.SysNPA_Dt,103)                AS SysNPA_Dt
,DA.AssetClassShortName                          AS FinalAssetClassName
,9 AS ExceptionCode
,'Customers slipped to NPA without having Debit Freeze Flag.'  AS ExceptionDescription
,AH.EffectiveFromTimeKey
,AH.EffectiveToTimeKey
FROM PRO.CUSTOMERCAL CH
              
INNER JOIN PRO.ACCOUNTCAL      AH                  ON CH.SourceSystemCustomerID=AH.SourceSystemCustomerID AND
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
--where CH.FlgDeg='Y'
--AND AH.FinalAssetClassAlt_Key  IN (2,3,4,5,6)
--and AH.DebitSinceDt IS NULL

where  AH.FinalAssetClassAlt_Key  IN (2,3,4,5,6)
AND AH.DebitSinceDt IS NULL
AND ah.Asset_Norm<>'writeoff'
 AND DATEDIFF(DAY,CH.SysNPA_Dt,CH.ProcessingDt)>2
AND CH.SysNPA_Dt<>CH.ProcessingDt  
 AND ah.SourceAlt_Key=1
 AND ah.ACCOUNTSTATUSDebitFreeze='ACCOUNT OPEN REGULAR'
  
------------------9. Customers slipped to NPA without having Debit Freeze Flag------------------

------------------10. Customers having different asset class in source system and CrisMac System------------------



Delete from ControlScripts
where ExceptionCode=10 
and EffectiveFromTimeKey=(select timekey from SysDataMatrix where CurrentStatus='C')


Insert into ControlScripts
(
UCIF_ID
,PANNO
,CustomerAcID
,RefCustomerID
,SourceSystemCustomerID
,CustomerName
,SourceName
,DPD_Max
,POS
,BalanceInCrncy
,Balance
,SysNPA_Dt
,FinalAssetClassName
,ExceptionCode
,ExceptionDescription
,EffectiveFromTimeKey
,EffectiveToTimeKey

)

SELECT  
CH.UCIF_ID
,CH.PanNO
,AH.CustomerAcID
,AH.RefCustomerID
,AH.SourceSystemCustomerID
,CH.CustomerName
,DB.SourceName
,AH.DPD_Max
,case when DimProduct.ProductCode ='NSLI' then 0      when ISNULL(AH.PrincOutStd,0)<0 then 0 else ISNULL(AH.PrincOutStd,0) end/@cost  AS POS
,case when ISNULL(AH.BalanceInCrncy,0)<0 then 0 else ISNULL (AH.BalanceInCrncy,0)end /@cost     AS BalanceInCrncy
,case when ISNULL(AH.Balance,0)<0 then 0 else  ISNULL(AH.Balance,0)end/@cost     AS Balance
,CONVERT(VARCHAR(20),CH.SysNPA_Dt,103)                AS SysNPA_Dt
,DA.AssetClassShortName                          AS FinalAssetClassName
,10 AS ExceptionCode
,'Customers having different asset class in source system and CrisMac System'  AS ExceptionDescription
,AH.EffectiveFromTimeKey
,AH.EffectiveToTimeKey
FROM PRO.CUSTOMERCAL CH
              
INNER JOIN PRO.ACCOUNTCAL      AH                  ON CH.SourceSystemCustomerID=AH.SourceSystemCustomerID AND
														  AH.EffectiveFromTimeKey=@Timekey AND
														  AH.EffectiveToTimeKey>@Timekey AND
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
where (
AH.InitialAssetClassAlt_Key in(1) and AH.FinalAssetClassAlt_Key in(2,3,4,5,6)
or
AH.InitialAssetClassAlt_Key in(2,3,4,5,6) and AH.FinalAssetClassAlt_Key in(1)

)

------------------10. Customers having different asset class in source system and CrisMac System------------------

------------------11. Exceptional variation in DPD reported from source system------------------


Delete from ControlScripts
where ExceptionCode=11
and EffectiveFromTimeKey=(select timekey from SysDataMatrix where CurrentStatus='C')

IF OBJECT_ID('TEMPDB..#TempTablePreviousDayDpdData') IS NOT NULL
  DROP TABLE #TempTablePreviousDayDpdData

	SELECT UCIF_ID,RefCustomerID,SourceSystemCustomerID,CustomerAcID,DPD_Max,Ah.SOURCEALT_KEY,AH.ProductCode,ah.DPD_IntService
	 INTO #TempTablePreviousDayDpdData FROM PRO.AccountCal_Hist Ah
	  INNER JOIN DIMSOURCEDB  B ON B.SOURCEALT_KEY=Ah.SOURCEALT_KEY 
	  AND Ah.EFFECTIVEFROMTIMEKEY=@TIMEKEY-1 AND Ah.EFFECTIVETOTIMEKEY=@TIMEKEY-1
	  AND B.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND B.EFFECTIVETOTIMEKEY>=@TIMEKEY
	  --WHERE  Ah.DPD_Max>0
	 
	 IF OBJECT_ID('TEMPDB..#TempTableCurrentDpdData') IS NOT NULL
		DROP TABLE #TempTableCurrentDpdData

	SELECT UCIF_ID,RefCustomerID,SourceSystemCustomerID,CustomerAcID,DPD_Max,Ah.SOURCEALT_KEY,AH.ProductCode,ah.DPD_IntService
	 INTO #TempTableCurrentDpdData FROM PRO.AccountCal Ah
	  INNER JOIN DIMSOURCEDB  B ON B.SOURCEALT_KEY=Ah.SOURCEALT_KEY 
	  AND Ah.EFFECTIVEFROMTIMEKEY=@TIMEKEY AND Ah.EFFECTIVETOTIMEKEY=@TIMEKEY
	  AND B.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND B.EFFECTIVETOTIMEKEY>=@TIMEKEY
	  --WHERE  Ah.DPD_Max>0

 DELETE    FROM #TempTableCurrentDpdData WHERE  SourceAlt_Key=1 AND   ProductCode not in('660','661','889','681','682','693','694','695','696','715','716','717','718',
			     '755','756','758','763','764','765','766','787','788','789','795','796',
			     '797','798','799','220','237','869','219','819','891','703','704','705','209','605','740','778','235') 
				and DPD_IntService=91 and DPD_Max=91

---Exclude only int serviced accounts---

	 IF OBJECT_ID('TEMPDB..#TempTableDpdData') IS NOT NULL
		DROP TABLE #TempTableDpdData

	  SELECT A.CustomerAcID,A.DPD_Max AS DPD_MaxP ,B.DPD_Max  AS DPD_MaxC,b.SOURCEALT_KEY
	  INTO #TempTableDpdData
	   FROM #TempTablePreviousDayDpdData  A
	  INNER JOIN #TempTableCurrentDpdData B
	  ON A.CustomerAcID=B.CustomerAcID

	
	  DELETE from #TempTableDpdData WHERE  SourceAlt_Key=4 AND DPD_MaxP=999 and DPD_MaxC=999
 
Insert into ControlScripts
(
UCIF_ID
,PANNO
,CustomerAcID
,RefCustomerID
,SourceSystemCustomerID
,CustomerName
,SourceName
,DPD_Max
,POS
,BalanceInCrncy
,Balance
,SysNPA_Dt
,FinalAssetClassName
,ExceptionCode
,ExceptionDescription
,DPDPreviousDay
,DPDCurrentDay
,EffectiveFromTimeKey
,EffectiveToTimeKey

)

SELECT  
CH.UCIF_ID
,CH.PanNO
,AH.CustomerAcID
,AH.RefCustomerID
,AH.SourceSystemCustomerID
,CH.CustomerName
,DB.SourceName
,AH.DPD_Max
,case when DimProduct.ProductCode ='NSLI' then 0      when ISNULL(AH.PrincOutStd,0)<0 then 0 else ISNULL(AH.PrincOutStd,0) end/@cost  AS POS
,case when ISNULL(AH.BalanceInCrncy,0)<0 then 0 else ISNULL (AH.BalanceInCrncy,0)end /@cost     AS BalanceInCrncy
,case when ISNULL(AH.Balance,0)<0 then 0 else  ISNULL(AH.Balance,0)end/@cost     AS Balance
,CONVERT(VARCHAR(20),CH.SysNPA_Dt,103)                AS SysNPA_Dt
,DA.AssetClassShortName                          AS FinalAssetClassName
,11 AS ExceptionCode
,'Exceptional variation in DPD reported from source system'  AS ExceptionDescription
,SU.DPD_MaxP
,SU.DPD_MaxC
,AH.EffectiveFromTimeKey
,AH.EffectiveToTimeKey
FROM PRO.CUSTOMERCAL CH
              
INNER JOIN PRO.ACCOUNTCAL     AH                  ON CH.SourceSystemCustomerID=AH.SourceSystemCustomerID AND
														  AH.EffectiveFromTimeKey=@Timekey AND
														  AH.EffectiveToTimeKey=@Timekey AND
														  CH.EffectiveFromTimeKey=@Timekey AND
		                                                  CH.EffectiveToTimeKey=@Timekey

INNER JOIN #TempTableDpdData SU ON SU.CustomerAcID=AH.CustomerAcID

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
where (
     (isnull(SU.DPD_MaxC,0)-isnull(SU.DPD_Maxp,0)>1)
or (isnull(SU.DPD_MaxC,0)>0 and isnull(SU.DPD_Maxp,0)>0 and isnull(SU.DPD_MaxC,0)-isnull(SU.DPD_Maxp,0)=0)
or (isnull(SU.DPD_Maxp,0)=0 and isnull(SU.DPD_MaxC,0)>1) 
) 
--and isnull(SU.DPD_Maxp,0)>0

------------------11. Exceptional variation in DPD reported from source system------------------


------------------12. No Upward Movement in NPA categories------------------


Delete from ControlScripts
where ExceptionCode=12 
and EffectiveFromTimeKey=(select timekey from SysDataMatrix where CurrentStatus='C')


Insert into ControlScripts
(
UCIF_ID
,PANNO
,CustomerAcID
,RefCustomerID
,SourceSystemCustomerID
,CustomerName
,SourceName
,DPD_Max
,POS
,BalanceInCrncy
,Balance
,SysNPA_Dt
,FinalAssetClassName
,ExceptionCode
,ExceptionDescription
,EffectiveFromTimeKey
,EffectiveToTimeKey

)

SELECT  
CH.UCIF_ID
,CH.PanNO
,AH.CustomerAcID
,AH.RefCustomerID
,AH.SourceSystemCustomerID
,CH.CustomerName
,DB.SourceName
,AH.DPD_Max
,case when DimProduct.ProductCode ='NSLI' then 0      when ISNULL(AH.PrincOutStd,0)<0 then 0 else ISNULL(AH.PrincOutStd,0) end/@cost  AS POS
,case when ISNULL(AH.BalanceInCrncy,0)<0 then 0 else ISNULL (AH.BalanceInCrncy,0)end /@cost     AS BalanceInCrncy
,case when ISNULL(AH.Balance,0)<0 then 0 else  ISNULL(AH.Balance,0)end/@cost     AS Balance
,CONVERT(VARCHAR(20),CH.SysNPA_Dt,103)                AS SysNPA_Dt
,DA.AssetClassShortName                          AS FinalAssetClassName
,12 AS ExceptionCode
,'No Upward Movement in NPA categories'  AS ExceptionDescription
,AH.EffectiveFromTimeKey
,AH.EffectiveToTimeKey
FROM PRO.CUSTOMERCAL CH
              
INNER JOIN PRO.ACCOUNTCAL      AH                  ON CH.SourceSystemCustomerID=AH.SourceSystemCustomerID AND
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
where  ( AH.InitialAssetClassAlt_Key  IN (3,4,5,6) AND AH.FinalAssetClassAlt_Key  IN (2)
OR
AH.InitialAssetClassAlt_Key  IN (4,5,6) AND AH.FinalAssetClassAlt_Key  IN (2,3)
OR
AH.InitialAssetClassAlt_Key  IN (5,6) AND AH.FinalAssetClassAlt_Key  IN (2,3,4)
)

------------------12. No Upward Movement in NPA categories------------------

------------------14. Same UCICFCR customer id but having different PAN number------------------


Delete from ControlScripts
where ExceptionCode=14 
and EffectiveFromTimeKey=(select timekey from SysDataMatrix where CurrentStatus='C')

IF OBJECT_ID('TEMPDB..#TempTableAllCustomers') IS NOT NULL
  DROP TABLE #TempTableAllCustomers

	SELECT A.UCIF_ID,A.RefCustomerID,A.SourceSystemCustomerID,A.PANNO
	 INTO #TempTableAllCustomers FROM PRO.CUSTOMERCAL A
	  INNER JOIN DIMSOURCEDB  B ON B.SOURCEALT_KEY=A.SOURCEALT_KEY 
	  AND A.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND A.EFFECTIVETOTIMEKEY>=@TIMEKEY
	  AND B.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND B.EFFECTIVETOTIMEKEY>=@TIMEKEY
	inner join pro.accountcal c on a.SourceSystemCustomerID=c.SourceSystemCustomerID
	  where a.PANNO<>'' and ISNULL(c.Balance,0)>0
	  GROUP BY  A.UCIF_ID,A.RefCustomerID,A.SourceSystemCustomerID,A.PANNO

IF OBJECT_ID('TEMPDB..#DuplicatePan') IS NOT NULL
  DROP TABLE #DuplicatePan

select A.SourceSystemCustomerID  
Into #DuplicatePan
from #TempTableAllCustomers A
INNER JOIN #TempTableAllCustomers B
ON A.SourceSystemCustomerID=B.SourceSystemCustomerID
AND A.PANNO<>B.PANNO
union
select A.SourceSystemCustomerID  from #TempTableAllCustomers A
INNER JOIN #TempTableAllCustomers B
ON A.UCIF_ID=B.UCIF_ID
AND A.PANNO<>B.PANNO



Insert into ControlScripts
(
UCIF_ID
,PANNO
,CustomerAcID
,RefCustomerID
,SourceSystemCustomerID
,CustomerName
,SourceName
,DPD_Max
,POS
,BalanceInCrncy
,Balance
,SysNPA_Dt
,FinalAssetClassName
,ExceptionCode
,ExceptionDescription
,EffectiveFromTimeKey
,EffectiveToTimeKey

)


SELECT  
CH.UCIF_ID
,CH.PanNO
,AH.CustomerAcID
,AH.RefCustomerID
,AH.SourceSystemCustomerID
,CH.CustomerName
,DB.SourceName
,AH.DPD_Max
,case when DimProduct.ProductCode ='NSLI' then 0      when ISNULL(AH.PrincOutStd,0)<0 then 0 else ISNULL(AH.PrincOutStd,0) end/@cost  AS POS
,case when ISNULL(AH.BalanceInCrncy,0)<0 then 0 else ISNULL (AH.BalanceInCrncy,0)end /@cost     AS BalanceInCrncy
,case when ISNULL(AH.Balance,0)<0 then 0 else  ISNULL(AH.Balance,0)end/@cost     AS Balance
,CONVERT(VARCHAR(20),CH.SysNPA_Dt,103)                AS SysNPA_Dt
,DA.AssetClassShortName                          AS FinalAssetClassName
,14 AS ExceptionCode
,'Same UCIC/FCR customer id but having different PAN number'  AS ExceptionDescription
,AH.EffectiveFromTimeKey
,AH.EffectiveToTimeKey

FROM PRO.CUSTOMERCAL CH
              
INNER JOIN PRO.ACCOUNTCAL      AH                  ON CH.SourceSystemCustomerID=AH.SourceSystemCustomerID AND
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

inner join  #DuplicatePan on #DuplicatePan.SourceSystemCustomerID=CH.SourceSystemCustomerID

INNER JOIN DimAssetClass                               ON  DimAssetClass.AssetClassAlt_Key= AH.InitialAssetClassAlt_Key AND 
                                                            DimAssetClass.EffectiveFromTimeKey<=@Timekey AND
													        DimAssetClass.EffectiveToTimeKey>=@Timekey

LEFT  JOIN DimProduct                                  ON DimProduct.ProductAlt_Key=AH.ProductAlt_Key AND 
                                                           DimProduct.EffectiveFromTimeKey<=@Timekey AND
													       DimProduct.EffectiveToTimeKey>=@Timekey

LEFT JOIN DimCurrency                                  ON  DimCurrency.CurrencyAlt_Key= AH.CurrencyAlt_Key	AND
			                                               DimCurrency.EffectiveFromTimeKey<=@Timekey AND
														   DimCurrency.EffectiveToTimeKey>=@Timekey
--where  AH.FinalAssetClassAlt_Key  IN (2)
where  ISNULL(AH.Balance,0)>0

------------------14. Same UCICFCR customer id but having different PAN number------------------



------------------17. Borrower having different UCIC under one PAN number------------------

Delete from ControlScripts
where ExceptionCode=17 
and EffectiveFromTimeKey=(select timekey from SysDataMatrix where CurrentStatus='C')

IF OBJECT_ID('TEMPDB..#TempTableAllCustomersPan') IS NOT NULL
  DROP TABLE #TempTableAllCustomersPan

	SELECT A.UCIF_ID,A.RefCustomerID,A.SourceSystemCustomerID,A.PANNO
	 INTO #TempTableAllCustomersPan FROM PRO.CUSTOMERCAL A
	  INNER JOIN DIMSOURCEDB  B ON B.SOURCEALT_KEY=A.SOURCEALT_KEY 
	  AND A.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND A.EFFECTIVETOTIMEKEY>=@TIMEKEY
	  AND B.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND B.EFFECTIVETOTIMEKEY>=@TIMEKEY
	inner join pro.accountcal c on a.SourceSystemCustomerID=c.SourceSystemCustomerID
	  where a.PANNO<>'' and ISNULL(c.Balance,0)>0 and A.UCIF_ID IS NOT NULL
	  GROUP BY  A.UCIF_ID,A.RefCustomerID,A.SourceSystemCustomerID,A.PANNO

delete from #TempTableAllCustomersPan where PANNO is null

IF OBJECT_ID('TEMPDB..#DuplicatePanV') IS NOT NULL
  DROP TABLE #DuplicatePanV

select A.PANNO  
Into #DuplicatePanV
from #TempTableAllCustomersPan A
INNER JOIN #TempTableAllCustomersPan B
ON A.PANNO=B.PANNO
AND A.UCIF_ID<>B.UCIF_ID
union
select A.PANNO  from #TempTableAllCustomersPan A
INNER JOIN #TempTableAllCustomersPan B
ON A.PANNO=B.PANNO
AND A.UCIF_ID<>B.UCIF_ID



Insert into ControlScripts
(
UCIF_ID
,PANNO
,CustomerAcID
,RefCustomerID
,SourceSystemCustomerID
,CustomerName
,SourceName
,DPD_Max
,POS
,BalanceInCrncy
,Balance
,SysNPA_Dt
,FinalAssetClassName
,ExceptionCode
,ExceptionDescription
,EffectiveFromTimeKey
,EffectiveToTimeKey

)


SELECT  
CH.UCIF_ID
,CH.PanNO
,AH.CustomerAcID
,AH.RefCustomerID
,AH.SourceSystemCustomerID
,CH.CustomerName
,DB.SourceName
,AH.DPD_Max
,case when DimProduct.ProductCode ='NSLI' then 0      when ISNULL(AH.PrincOutStd,0)<0 then 0 else ISNULL(AH.PrincOutStd,0) end/@cost  AS POS
,case when ISNULL(AH.BalanceInCrncy,0)<0 then 0 else ISNULL (AH.BalanceInCrncy,0)end /@cost     AS BalanceInCrncy
,case when ISNULL(AH.Balance,0)<0 then 0 else  ISNULL(AH.Balance,0)end/@cost     AS Balance
,CONVERT(VARCHAR(20),CH.SysNPA_Dt,103)                AS SysNPA_Dt
,DA.AssetClassShortName                          AS FinalAssetClassName
,17 AS ExceptionCode
,'Borrower having different UCIC under one PAN number'  AS ExceptionDescription
,AH.EffectiveFromTimeKey
,AH.EffectiveToTimeKey

FROM PRO.CUSTOMERCAL CH
              
INNER JOIN PRO.ACCOUNTCAL      AH                  ON CH.SourceSystemCustomerID=AH.SourceSystemCustomerID AND
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

inner join  #DuplicatePanV on #DuplicatePanV.PanNO=CH.PanNO

INNER JOIN DimAssetClass                               ON  DimAssetClass.AssetClassAlt_Key= AH.InitialAssetClassAlt_Key AND 
                                                            DimAssetClass.EffectiveFromTimeKey<=@Timekey AND
													        DimAssetClass.EffectiveToTimeKey>=@Timekey

LEFT  JOIN DimProduct                                  ON DimProduct.ProductAlt_Key=AH.ProductAlt_Key AND 
                                                           DimProduct.EffectiveFromTimeKey<=@Timekey AND
													       DimProduct.EffectiveToTimeKey>=@Timekey

LEFT JOIN DimCurrency                                  ON  DimCurrency.CurrencyAlt_Key= AH.CurrencyAlt_Key	AND
			                                               DimCurrency.EffectiveFromTimeKey<=@Timekey AND
														   DimCurrency.EffectiveToTimeKey>=@Timekey
 
where  ISNULL(AH.Balance,0)>0
order by ch.PanNO

UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' 
WHERE IDENTITYKEY = (SELECT IDENT_CURRENT('PRO.PROCESSMONITOR'))
 AND  TIMEKEY=@TIMEKEY AND DESCRIPTION='INSERT DATA FOR ValidationControlScripts'
 END


GO