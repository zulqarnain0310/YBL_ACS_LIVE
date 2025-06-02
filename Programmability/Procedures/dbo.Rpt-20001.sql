SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


--/*
-- Created by   : Rakesh
-- Created date : 7/5/2019
-- Report Name  : Status Of Facility Wise NPAs Outstanding As On 
--*/

CREATE PROC [dbo].[Rpt-20001]
@TimeKey AS INT ,
@Source   VARCHAR(200),
@RangeFrom DECIMAL(30,2),
@RangeTo   DECIMAL(30,2),
@Cost      AS FLOAT
AS

----select * from SysDayMatrix where date='2022-11-29'

--DECLARE 
--      @TimeKey AS INT =27452,   --'26549',
--      @Source   VARCHAR(200)='0',
--	  @RangeFrom DECIMAL(30,2)=NULL,
--	  @RangeTo   DECIMAL(30,2)=NULL,
--	  @Cost      AS FLOAT=1

    
IF(OBJECT_ID('tempdb..#VWCustomerCal_Hist200')IS NOT NULL)
IF(OBJECT_ID('tempdb..#VWAccountCal_Hist200')IS NOT NULL) 
IF(OBJECT_ID('tempdb..#Final')IS NOT NULL) 
DROP TABLE #VWCustomerCal_Hist200,#VWAccountCal_Hist200,#Final
     
	 
select CustomerEntityID,Branchcode,PANNO,UCIF_ID,CustomerName,SysNPA_Dt,SourceSystemCustomerID,RefCustomerID
into #VWCustomerCal_Hist200 
FROM VWCustomercal_hist L with (nolock)
where L.EFFECTIVEFROMTIMEKEY=@TIMEKEY AND L.EFFECTIVETOTIMEKEY=@TIMEKEY
option (recompile)


CREATE NONCLUSTERED INDEX INX_UCIF_ID ON #VWCustomerCal_Hist200(Branchcode)INCLUDE(SourceSystemCustomerID,CustomerEntityID)

--IF OBJECT_ID('TEMPDB.dbo.#VWAccountCal_Hist200') IS NOT NULL
--  DROP TABLE #VWAccountCal_Hist200

SELECT 
Branchcode,CustomerEntityID,AccountEntityID,
RefCustomerID,ActSegmentCode,SourceSystemCustomerID,FlgRestructure,SplCatg3Alt_Key,InitialNpaDt,DegReason,DPD_Max,OtherOverdue,IntOverdue,BalanceInCrncy,Balance,
PrincOutStd,ExposureType,ACCOUNTSTATUSDebitFreeze ,FlgDeg, DPD_Renewal,FinalAssetClassAlt_Key,SourceAlt_Key,InitialAssetClassAlt_Key ,ProductAlt_Key,CurrencyAlt_Key 
,BANKASSETCLASS,AccountBlkCode1,AccountBlkCode2, ProductCode,DPD_Overdue,SplCatg2Alt_Key,SplCatg1Alt_Key,SplCatg4Alt_Key,DPD_StockStmt,CD,DPD_IntService,DPD_Overdrawn,
CustomerAcID,OTS_Settlement_Date,OTS_Settlement_Flag,OTS_STATUS
 
into   #VWAccountCal_Hist200 FROM VWAccountCal_Hist AH with (nolock) 


where AH.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND AH.EFFECTIVETOTIMEKEY>=@TIMEKEY
	AND	((ISNULL(AH.Balance,0) BETWEEN @RangeFrom AND @rangeto AND @RangeFrom IS NOT NULL AND @RangeTo IS NOT NULL) OR
	  (ISNULL(AH.Balance,0)<=@RangeTo AND @rangefrom IS NULL AND @RangeTo IS NOT NULL) OR
	  (ISNULL(AH.Balance,0)>=@RangeFrom AND @RangeFrom IS NOT NULL AND @RangeTo IS NULL)OR
	  (@RangeFrom IS NULL AND @RangeTo IS NULL)) 
	

	   
	  -- AND    (ISNULL(AH.Balance,0)>0 OR ISNULL(AH.PrincOutStd,0)>0 or (ISNULL(AH.Balance,0)=0 and ISNULL(AH.PrincOutStd,0)=0 and SourceDBName='FCC')) AND
		--ISNULL(AH.AccountStatus,'N')<>'Z' AND  ISNULL(AH.AccountBlkCode2,'N')<>'F'
          AND ISNULL(AH.BANKASSETCLASS,'N')<>'WRITEOFF'--- EXCLUDE WRITE OFF ACCOUNT FROM NPA LIST 17/02/2020 TRILOKI KHANNA AS PER BANK POINT
		  AND  ISNULL(AH.AccountBlkCode1,'N')<>'W' AND  ISNULL(AH.AccountBlkCode2,'N')<>'W' --- Exclude Card Settlement Account Treatment from NPA LIST 24/11/2021 TRILOKI KHANNA AS PER BANK POINT 14/12/2021
-- Exclude less than Zero account from ENPA Reports 30-May-22
		  and ISNULL(AH.Balance,0) > 0  AND ISNULL(AH.ProductCode,'') not in ('NSLI' )

		  option (recompile)

CREATE NONCLUSTERED INDEX INX_RefCustomerID ON #VWAccountCal_Hist200(Branchcode)
INCLUDE(SourceSystemCustomerID,customerentityid)



SELECT  
DISTINCT

DB.sourcename,
CH.PANNO,
CH.UCIF_ID,
AH.RefCustomerID,
AH.SourceSystemCustomerID,  -----New Added
CH.CustomerName,
--case when TRY_CAST(AH.CustomerAcID AS INT) IS NOT NULL  AND CHARINDEX ('.',AH.CustomerAcID) = 0 THEN CAST(AH.CustomerAcID AS INT)
--ELSE AH.CustomerAcID END		AS CustomerAcID, 

--CASE WHEN ISNUMERIC(AH.CustomerAcID) = 1 AND CAST (AH.CustomerAcID AS FLOAT)=CAST(CAST(AH.CustomerAcID AS FLOAT)AS INT)THEN CAST(AH.CustomerAcID AS INT)	
--ELSE AH.CustomerAcID END AS CustomerAcID,

--CASE WHEN TRY_CAST(AH.CustomerAcID AS INT) IS NOT NULL AND TRY_CAST(AH.CustomerAcID AS INT)=CAST(AH.CustomerAcID AS FLOAT)  
--THEN CAST(AH.CustomerAcID AS INT)	ELSE AH.CustomerAcID END		AS CustomerAcID,

 --CAST (AH.CustomerAcID AS char(30)) AS CustomerAcID,
AH.CustomerAcID ,
DimProduct.ProductCode,   -----New Added
DimProduct.ProductName,
AH.ActSegmentCode,
DimAssetClass.AssetClassShortName                                                  AS  InitialAssetClassName,
CONVERT(VARCHAR(20),AH.InitialNpaDt,103)                                           AS InitialNpaDt,
DA.AssetClassShortName                                                             AS FinalAssetClassName,
CONVERT(VARCHAR(20),CH.SysNPA_Dt,103)                                              AS SysNPA_Dt,
AH.DegReason,
AH.DPD_Max,
DimCurrency.currencycode,
--(CASE WHEN DB.SourceDBName='FCR' THEN ISNULL(AH.IntOverdue,0) 
--      WHEN DB.SourceDBName='ECFS'THEN ISNULL(AH.IntOverdue,0) 
--	  WHEN DB.SourceDBName='ECBF' THEN ISNULL(AH.IntOverdue,0) 
--      WHEN DB.SourceDBName='EIFS'THEN ISNULL(AH.IntOverdue,0)                       
--	  When  DB.SourceDBName='VisionPlus' THEN ISNULL(AH.IntOverdue,0)
--      ELSE 0 
--	  END)/@cost	  AS [O/S INTEREST AMT],
(CASE When  DB.SourceDBName='VisionPlus' then ISNULL(AH.IntOverdue,0) 
When  DB.SourceDBName='Finnone' then ISNULL(AH.IntOverdue,0)
else ISNULL(AH.IntOverdue,0)+ISNULL(AH.OtherOverdue,0) end) /@cost               AS [O/S INTEREST AMT],-----added after mail by bank----
--ISNULL(AH.BalanceInCrncy,0)/@cost    AS BalanceInCrncy,
case when ISNULL(AH.BalanceInCrncy,0)<0 then 0 else ISNULL (AH.BalanceInCrncy,0)end /@cost     AS BalanceInCrncy,--Mail dated by bank 23/05/2020
--ISNULL(AH.Balance,0)/@cost           AS Balance,
case when ISNULL(AH.Balance,0)<0 then 0 else  ISNULL(AH.Balance,0)end/@cost     AS Balance,--Mail dated by bank 23/05/2020
--case when DimProduct.ProductCode ='NSLI' then 0 else ISNULL(AH.PrincOutStd,0) end/@cost  AS POS,               -----New Added
case when DimProduct.ProductCode ='NSLI' then 0      when ISNULL(AH.PrincOutStd,0)<0 then 0 
--WHEN DB.SourceDBName='EIFS'THEN ISNULL(AH.PrincOutStd,0)-ISNULL(AH.IntOverdue,0)
else ISNULL(AH.PrincOutStd,0) end/@cost  AS POS,

--ISNULL(AH.PrincOverdue,0)/@Cost                                                   AS PrincOverdue,   ---Not required
--ISNULL(AH.IntOverdue,0)/@Cost                                                     AS IntOverdue,     ---Not required
AH.ExposureType																      AS ExposureType, -----New Added
AH.CD																			  AS CD,           -----New Added
AH.DPD_IntService																	  AS DPD_IntService,  -----New Added
AH.DPD_Overdrawn																	  AS DPD_Overdrawn,   -----New Added
CASE WHEN AH.FlgDeg ='Y' then 'Fresh Slippage' else 'NULL' END					  AS [NpaMark]   -----New Added
,AH.ACCOUNTSTATUSDebitFreeze AS DebitFreezeStatus


,AH.DPD_Renewal
,AH.DPD_Overdue
,AH.DPD_StockStmt
,ISNULL(AH.FlgRestructure,'N') AS FlgRestructure
,CASE WHEN ISNULL(AH.SplCatg1Alt_Key,0)=870 OR ISNULL(AH.SplCatg2Alt_Key,0)=870
	       OR ISNULL(AH.SplCatg3Alt_Key,0)=870 OR ISNULL(AH.SplCatg4Alt_Key,0)=870 
	  THEN 'Y' 
      ELSE 'N' 
	  END           AS FlgFraud 

,CASE WHEN AH.SOURCEALT_KEY= 3 THEN (AH.OtherOverdue) else 0.00 end  AS Penal_charges

,AH.OTS_Settlement_Flag  AS [OTS flag]
----,AH.OTS_Settlement_Date  AS [OTS Date]

,CONVERT(VARCHAR(20),AH.OTS_Settlement_Date,103)  AS [OTS Date]
,AH.OTS_STATUS           AS [OTS_R]

INTO #FINAL
FROM #VWCustomerCal_Hist200 CH
              
INNER JOIN #VWAccountCal_Hist200  AH                     ON CH.SourceSystemCustomerID=AH.SourceSystemCustomerID  
														  --AH.EffectiveFromTimeKey=@Timekey AND
														  --AH.EffectiveToTimeKey=@Timekey AND
														  --CH.EffectiveFromTimeKey=@Timekey AND
		              --                                    CH.EffectiveToTimeKey=@Timekey
														  

INNER JOIN DimsourceDB  DB                             ON DB.SourceAlt_Key=AH.SourceAlt_Key AND
                                                           DB.EffectiveFromTimeKey<=@Timekey AND
													       DB.EffectiveToTimeKey>=@Timekey

INNER JOIN DimAssetClass DA                            ON  DA.AssetClassAlt_Key= AH.FinalAssetClassAlt_Key AND 
                                                           DA.EffectiveFromTimeKey<=@Timekey AND
													       DA.EffectiveToTimeKey>=@Timekey
														    AND ISNULL(DA.AssetClassShortName,'') <>'STD'

INNER JOIN DimAssetClass                               ON  DimAssetClass.AssetClassAlt_Key= AH.InitialAssetClassAlt_Key AND 
                                                            DimAssetClass.EffectiveFromTimeKey<=@Timekey AND
													        DimAssetClass.EffectiveToTimeKey>=@Timekey

LEFT  JOIN DimProduct                                  ON DimProduct.ProductAlt_Key=AH.ProductAlt_Key AND 
                                                           DimProduct.EffectiveFromTimeKey<=@Timekey AND
													       DimProduct.EffectiveToTimeKey>=@Timekey

LEFT JOIN DimCurrency                                  ON  DimCurrency.CurrencyAlt_Key= AH.CurrencyAlt_Key	AND
			                                               DimCurrency.EffectiveFromTimeKey<=@Timekey AND
														   DimCurrency.EffectiveToTimeKey>=@Timekey

WHERE (DB.SourceAlt_Key IN (SELECT * FROM[Split](@Source,',')) OR @Source='0')
  AND ISNULL(DA.AssetClassShortName,'') <>'STD'


  SELECT * FROM #FINAL ORDER BY RefCustomerID,SourceName



GO