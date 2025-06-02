SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/*
 Created by   : Rakesh
 Created date : 7/5/2019
 Report Name  : Status Of Facility Wise Upgradations Outstanding As On
*/

CREATE Proc [dbo].[Rpt-20006]
        @TimeKey  INT,
        @Source   VARCHAR(200),
		@RangeFrom DECIMAL(30,2),
		@RangeTo   DECIMAL(30,2),
		@Cost      FLOAT
AS

--DECLARE 
--        @TimeKey INT =25302,
--        @Source  VARCHAR(200)='1,2,3',
--		@RangeFrom DECIMAL(30,2)=null,
--		@RangeTo   DECIMAL(30,2)=null,
--		@Cost      FLOAT=1


SELECT  
       DB.sourcename,
	   CUSTOMERCAL_HIST.UCIF_ID,
	   CUSTOMERCAL_HIST.CustomerName,
	   ACCOUNTCAL_HIST.CustomerAcID,
	   DimProduct.ProductName,
	   ACCOUNTCAL_HIST.ActSegmentCode,
	   DA.AssetClassShortName                                      AS FinalAssetClassName,
	   ACCOUNTCAL_HIST.DPD_Max,
	   DimCurrency.Currencycode,
	   CONVERT(VARCHAR(20),ACCOUNTCAL_HIST.UpgDate,103)            AS UpgDate,
	   ISNULl(ACCOUNTCAL_HIST.BalanceInCrncy,0)/@Cost              AS BalanceInCrncy,
	   ISNULL(ACCOUNTCAL_HIST.Balance,0)/@Cost                     AS Balance

 FROM PRO.CUSTOMERCAL_HIST
              
INNER JOIN PRO.ACCOUNTCAL_HIST                          ON CUSTOMERCAL_HIST.sourcesystemcustomerid=ACCOUNTCAL_HIST.sourcesystemcustomerid AND
														   ACCOUNTCAL_HIST.EffectiveFromTimeKey<=@Timekey AND
														   ACCOUNTCAL_HIST.EffectiveToTimeKey>=@Timekey AND
														   CUSTOMERCAL_HIST.EffectiveFromTimeKey<=@Timekey AND
		                                                   CUSTOMERCAL_HIST.EffectiveToTimeKey>=@Timekey
             
 INNER JOIN DimsourceDB  DB                             ON DB.SourceAlt_Key=ACCOUNTCAL_HIST.SourceAlt_Key AND
			                                               DB.EffectiveFromTimeKey<=@Timekey AND
														   DB.EffectiveToTimeKey>=@Timekey
             
LEFT JOIN DimAssetClass DA                              ON  DA.AssetClassAlt_Key= ACCOUNTCAL_HIST.FinalAssetClassAlt_Key AND  
			                                                DA.EffectiveFromTimeKey<=@Timekey AND
															DA.EffectiveToTimeKey>=@Timekey

LEFT  JOIN DimProduct                                   ON DimProduct.ProductAlt_Key=ACCOUNTCAL_HIST.ProductAlt_Key AND 
			                                               DimProduct.EffectiveFromTimeKey<=@Timekey AND
														   DimProduct.EffectiveToTimeKey>=@Timekey
			
LEFT JOIN DimCurrency                                   ON  DimCurrency.CurrencyAlt_Key= ACCOUNTCAL_HIST.CurrencyAlt_Key	AND
			                                                DimCurrency.EffectiveFromTimeKey<=@Timekey AND
															DimCurrency.EffectiveToTimeKey>=@Timekey

WHERE (DB.SourceAlt_Key IN (SELECT * FROM [Split](@Source,',')) OR @Source='0') AND
	  ((ISNULL(ACCOUNTCAL_HIST.Balance,0) BETWEEN @RangeFrom AND @RangeTo AND @RangeFrom IS NOT NULL AND @RangeTo IS NOT NULL) OR
	  (ISNULL(ACCOUNTCAL_HIST.Balance,0)<=@RangeTo AND @RangeFrom IS NULL AND @RangeTo IS NOT NULL) OR
	  (ISNULL(ACCOUNTCAL_HIST.Balance,0)>=@RangeFrom AND @RangeFrom IS NOT NULL AND @RangeTo IS NULL)OR
	   (@RangeFrom IS NULL AND @RangeTo IS NULL)				) AND
		ACCOUNTCAL_HIST.FLGUPG='U' 
        AND ISNULL(ACCOUNTCAL_HIST.AccountStatus,'N')<>'Z'

ORDER BY customercal_hist.UCIF_ID, DB.SourceAlt_Key

OPTION(RECOMPILE)


  
GO