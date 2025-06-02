SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



 /*
 CREATED BY     : BAIJAYANTI
 CREATED DATE   : 06/05/2019
 REPORT NAME    : Status of facility wise Potential NPAs on (Month end Date) outstanding as on
 */

 create PROC [dbo].[Rpt-20003]
 @TimeKey AS INT,
 @Source AS VARCHAR(200),
 @RangeFrom AS DECIMAL(20,2),
 @RangeTo AS DECIMAL(20,2),
 @Cost AS FLOAT
 AS 

 --DECLARE 

 --@TimeKey AS INT=25141,
 --@Source AS VARCHAR(200)='1,2,3',
 --@RangeFrom AS DECIMAL(30,2),
 --@RangeTo AS DECIMAL(30,2),
 --@Cost AS FLOAT=1


 IF (OBJECT_ID('tempdb..#Balance') IS NOT NULL)
					DROP TABLE #Balance

SELECT 
SourceSystemCustomerID,
SUM(ISNULL(Balance,0))/@Cost   AS Customer_Exposure

INTO #Balance
FROM PRO.ACCOUNTCAL_HIST  
WHERE  EffectiveFromTimeKey<= @TimeKey
        AND EffectiveToTimeKey>=@TimeKey 

GROUP BY
SourceSystemCustomerID

 SELECT 
 
 SourceName,
 CCH.PANNO,
 CCH.UCIF_ID,
 CCH.RefCustomerID                                 AS CUST_ID,
 CCH.CustomerName                                  AS CUST_NAME,
 ACH.CustomerAcID,
 DP.ProductName,
 ACH.ActSegmentCode,
 DC.CurrencyCode,
 CCH.CustSegmentCode,
 ACH.DPD_Max,
 ACH.PRINCOVERDUE,
 (ISNULL(ACH.DerecognisedInterest1,0)+ISNULL(ACH.DerecognisedInterest2,0))/@Cost  AS Unserviced_Interest,
 CONVERT(VARCHAR(20),ACH.PNPA_DATE,103)                                           AS PNPA_DATE,
 PNPA_Reason                                                                      AS PNPA_Reason,
 ISNULL(BalanceInCrncy,0)/@Cost                                                   AS OS_AMT_FCY,
 ISNULL(Balance,0)/@Cost                                                          AS OS_AMT_INR,
 ISNULL(Customer_Exposure,0)                                                      AS Customer_Exposure

FROM PRO.CUSTOMERCAL_HIST CCH
INNER JOIN PRO.ACCOUNTCAL_HIST   ACH        ON CCH.SourceSystemCustomerID=ACH.SourceSystemCustomerID
                                               AND CCH.EffectiveFromTimeKey<= @TimeKey
											   AND CCH.EffectiveToTimeKey>=@TimeKey  
                                               AND ACH.EffectiveFromTimeKey<= @TimeKey
											   AND ACH.EffectiveToTimeKey>=@TimeKey  

LEFT JOIN DimProduct DP                     ON DP.ProductAlt_Key=ACH.ProductAlt_Key
                                               AND DP.EffectiveFromTimeKey<= @TimeKey
											   AND DP.EffectiveToTimeKey>=@TimeKey  
											   
LEFT JOIN DimCurrency DC  		            ON DC.CurrencyAlt_Key=ACH.CurrencyAlt_Key
                                               AND DC.EffectiveFromTimeKey<= @TimeKey
											   AND DC.EffectiveToTimeKey>=@TimeKey 

INNER JOIN DimSourceDB DSDB                 ON DSDB.SourceAlt_Key=ACH.SourceAlt_Key
                                               AND DSDB.EffectiveFromTimeKey<= @TimeKey
											   AND DSDB.EffectiveToTimeKey>=@TimeKey 
											   
INNER JOIN #Balance BL  		            ON BL.SourceSystemCustomerID=ACH.SourceSystemCustomerID									    										            										   
											   								               
WHERE ACH.FlgPNPA='Y' AND (DSDB.SourceAlt_Key IN (SELECT * FROM DBO.SPLIT(@Source,',')) OR @Source='0')
 AND  ((ISNULL(Balance,0) BETWEEN @RangeFrom AND @RangeTo) OR (@RangeFrom IS NULL AND @RangeTo IS NULL)
				  OR (@RangeFrom IS NULL AND ISNULL(Balance,0)<= @RangeTo)
				  or (@RangeTo IS NULL AND ISNULL(Balance,0)>= @RangeFrom)
				  )  AND ISNULL(ACH.AccountStatus,'N')<>'Z'

OPTION(RECOMPILE)
GO