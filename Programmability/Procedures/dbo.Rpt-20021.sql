SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Rpt-20021]
   @TimeKey AS INT,
   @Source   VARCHAR(200),
   @RangeFrom DECIMAL(30,2),
   @RangeTo   DECIMAL(30,2),
   @Cost      AS FLOAT
AS 
--DECLARE 
--    @TimeKey AS INT =25383,
--    @Source   VARCHAR(200)='0',
--	  @RangeFrom DECIMAL(30,2)=NULL,
--	  @RangeTo   DECIMAL(30,2)=NULL,
--	  @Cost      AS FLOAT=1

SELECT  

DB.sourcename,
CH.PANNO,
CH.UCIF_ID,
AH.RefCustomerID,
AH.SourceSystemCustomerID,  
CH.CustomerName,
AH.CustomerAcID,
DimProduct.ProductCode,   
DimProduct.ProductName,
AH.ActSegmentCode,
CONVERT(VARCHAR(20),AH.InitialNpaDt,103)                                           AS InitialNpaDt,
CONVERT(VARCHAR(20),CH.SysNPA_Dt,103)                                              AS SysNPA_Dt,
AH.DegReason,
AH.DPD_Max,
DimCurrency.currencycode,
(CASE WHEN DB.SourceDBName='FCR' then ISNULL(AH.IntOverdue,0) else 0 end)/@cost	  AS [O/S INTEREST AMT],
ISNULl(AH.BalanceInCrncy,0)/@cost                                                 AS BalanceInCrncy,
ISNULL(AH.Balance,0)/@cost                                                        AS Balance,
case when DimProduct.ProductCode ='NSLI' then 0 else ISNULL(AH.PrincOutStd,0) end/@cost  AS POS,               
AH.ExposureType																      AS ExposureType, 
AH.CD																			  AS CD,           
DPD_IntService																	  AS DPD_IntService,  
DPD_Overdrawn																	  AS DPD_Overdrawn,   
'N' AS [Linked NPA account (Y/N)],
NULL AS [Date of write off],
NULL AS [Asset class on date of write off]

FROM PRO.CUSTOMERCAL_HIST CH
              
INNER JOIN PRO.ACCOUNTCAL_HIST  AH                     ON CH.SourceSystemCustomerID=AH.SourceSystemCustomerID AND
														  AH.EffectiveFromTimeKey<=@Timekey AND
														  AH.EffectiveToTimeKey>=@Timekey AND
														  CH.EffectiveFromTimeKey<=@Timekey AND
		                                                  CH.EffectiveToTimeKey>=@Timekey

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

WHERE (DB.SourceAlt_Key IN (SELECT * FROM[Split](@Source,',')) OR @Source='0') AND
	  ((ISNULL(AH.Balance,0) BETWEEN @RangeFrom AND @rangeto AND @RangeFrom IS NOT NULL AND @RangeTo IS NOT NULL) OR
	  (ISNULL(AH.Balance,0)<=@RangeTo AND @rangefrom IS NULL AND @RangeTo IS NOT NULL) OR
	  (ISNULL(AH.Balance,0)>=@RangeFrom AND @RangeFrom IS NOT NULL AND @RangeTo IS NULL)OR
	  (@RangeFrom IS NULL AND @RangeTo IS NULL)) 
	   --AND ISNULL(DA.AssetClassShortName,'')<>'STD' AND   (ISNULL(AH.Balance,0)>0 OR ISNULL(AH.PrincOutStd,0)>0 or (ISNULL(AH.Balance,0)=0 and ISNULL(AH.PrincOutStd,0)=0 and SourceDBName='FCC')) 
	   AND ISNULL(AH.BANKASSETCLASS,'N')='Writeoff'
	   
ORDER BY CH.RefCustomerID,DB.SourceAlt_Key
GO