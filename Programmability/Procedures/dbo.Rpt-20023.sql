SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



/* In Selection Form Please Add Date Range Form and to filter condition Also*/
/* Account Wise Review Date Data */

CREATE PROCEDURE [dbo].[Rpt-20023]
   @TimeKey AS INT,
   @Source   VARCHAR(200),
   @RangeFrom DECIMAL(30,2),
   @RangeTo   DECIMAL(30,2),
   @Cost      AS FLOAT,
   @DateRangeFrom DATE,
   @DateRangeTo   DATE
    
AS 

--DECLARE 
--      @TimeKey AS INT =25383,
--      @Source   VARCHAR(200)='1',
--	  @RangeFrom DECIMAL(30,2)=NULL,
--	  @RangeTo   DECIMAL(30,2)=NULL,
--	  @Cost      AS FLOAT=1,
--      @DateRangeFrom date ='2017-01-01',
--      @DateRangeTo date  ='2020-06-30'


DECLARE @date DATE,@dateFrom1 DATE,@dateto1 DATE
	  select @date =date from SysDayMatrix where TimeKey=@TimeKey
	  select @dateFrom1 =cast(@DateRangeFrom as date)
	  select @dateto1 =cast(@DateRangeTo as date)

SELECT  
DB.SourceName,
CH.PanNO,
CH.UCIF_ID,
AH.RefCustomerID,
AH.SourceSystemCustomerID,  
CH.CustomerName,
AH.CustomerAcID,
DimProduct.ProductCode,   
DimProduct.ProductName,
AH.ActSegmentCode,
DimAssetClass.AssetClassShortName                                                  AS  InitialAssetClassName,
CONVERT(VARCHAR(20),AH.InitialNpaDt,103)                                           AS InitialNpaDt,
DA.AssetClassShortName                                                             AS FinalAssetClassName,
CONVERT(VARCHAR(20),CH.SysNPA_Dt,103)                                              AS SysNPA_Dt,
AH.DegReason,
--AH.DPD_Max,
DimCurrency.Currencycode,
case when ISNULL(AH.BalanceInCrncy,0)<0 then 0 else ISNULL (AH.BalanceInCrncy,0)end /@cost     AS BalanceInCrncy,
case when ISNULL(AH.Balance,0)<0 then 0 else  ISNULL(AH.Balance,0)end/@cost     AS Balance,
case when DimProduct.ProductCode ='NSLI' then 0      when ISNULL(AH.PrincOutStd,0)<0 then 0 else ISNULL(AH.PrincOutStd,0) end/@cost  AS POS, 
AH.ReviewDueDt AS ReviewDt

FROM PRO.CUSTOMERCAL_HIST CH
              
INNER JOIN PRO.ACCOUNTCAL_HIST      AH                  ON CH.SourceSystemCustomerID=AH.SourceSystemCustomerID AND
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
	   AND AH.ReviewDueDt IS NOT NULL
	    AND ((ReviewDueDt  BETWEEN @dateFrom1 AND @dateto1) OR (case when @dateFrom1 IS NULL AND @dateto1 IS NULL then ReviewDueDt end )<=@date
      OR (@dateFrom1 IS NULL AND ReviewDueDt<= @dateto1)
      OR (@dateto1 IS NULL AND ReviewDueDt>= @dateFrom1)) 
	 
ORDER BY CH.RefCustomerID,DB.SourceAlt_Key

OPTION(RECOMPILE)

GO