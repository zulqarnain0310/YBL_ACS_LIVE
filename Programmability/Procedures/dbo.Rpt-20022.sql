SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


 CREATE PROCEDURE [dbo].[Rpt-20022]
   @TimeKey AS INT,
   @Source   VARCHAR(200),
   @RangeFrom DECIMAL(30,2),
   @RangeTo   DECIMAL(30,2),
   @Cost      AS FLOAT
AS 

--DECLARE 
--      @TimeKey AS INT =25383,
--      @Source   VARCHAR(200)='1',
--	  @RangeFrom DECIMAL(30,2)=NULL,
--	  @RangeTo   DECIMAL(30,2)=NULL,
--	  @Cost      AS FLOAT=1

IF @TimeKey > = 26043

BEGIN


SELECT
PANNO                                       AS PAN_NUMBER,
UCIF_ID                                    AS UCIC,
RefCustomerID                              AS FCR_CustomerID,
CustomerName                               AS Customer_NAME,
SourceSystemCustomerID                      AS SourceSystemCustomerID,
CustomerAcID                               AS ACCOUNT_ID,
CustSegmentCode                            AS BS,
ProductCode                                 AS ProductCode ,
ProductName                                  AS PRODUCT_CLASS,
ISNULL([Balance] ,0)/@cost                     AS OS,
DPD_IntService                             AS DPD_IntService,
GRTR_THAN_90                                        AS GRTR_THAN_90,
DAYS_61_TO_90                                       AS DAYS_61_TO_90,
DAYS_31_TO_60                                       AS DAYS_31_TO_60,
UPTO_30                                      AS UPTO_30,
ISNULL(OverdueAmt,0)/@Cost                  AS TOTAL_OVERDUE,
BranchCode                                 AS Brn,
BranchName                                      AS Branch_Name,
rpt.SourceName                                AS SourceName

from PRO.Rptoutoforderdata rpt
INNER JOIN DimSourceDB DSDB                ON rpt.SourceName=DSDB.SourceName
                                              AND DSDB.EffectiveFromTimeKey<= @TimeKey
                                              AND DSDB.EffectiveToTimeKey>=@TimeKey

WHERE TIMEKEY= @TimeKey
      AND ((ISNULL(OverdueAmt,0) BETWEEN @RangeFrom AND @RangeTo) OR (@RangeFrom IS NULL AND @RangeTo IS NULL)
      OR (@RangeFrom IS NULL AND ISNULL(OverdueAmt,0)<= @RangeTo)
      OR (@RangeTo IS NULL AND ISNULL(OverdueAmt,0)>= @RangeFrom)) 
      --AND ISNULL(ACH.BANKASSETCLASS,'N')<>'WRITEOFF'
      AND DSDB.SourceName IN ('FCR') AND (DSDB.SourceAlt_Key IN (SELECT * FROM[Split](@Source,',')) OR @Source='0') 

END
else
BEGIN

SELECT
CCH.PANNO                                       AS PAN_NUMBER,
CCH.UCIF_ID                                     AS UCIC,
CCH.RefCustomerID                               AS FCR_CustomerID,
CCH.CustomerName                                AS Customer_NAME,
CCH.SourceSystemCustomerID                      AS SourceSystemCustomerID,
ACH.CustomerAcID                                AS ACCOUNT_ID,
CCH.CustSegmentCode                             AS BS,
ACH.ProductCode                                 AS ProductCode ,
DP.ProductName                                  AS PRODUCT_CLASS,
ISNULL(ACH.Balance,0)/@cost                     AS OS,
ACH.DPD_IntService                              AS DPD_IntService,
CASE WHEN  ACH.DPD_IntService> 90 
     THEN ISNULL(ACH.OverdueAmt,0)/@Cost 
	 ELSE 0 
	 END                                        AS GRTR_THAN_90,
CASE WHEN  ACH.DPD_IntService> 60 AND ACH.DPD_IntService<= 90 
     THEN ISNULL(ACH.OverdueAmt,0)/@Cost 
	 ELSE 0 
	 END                                        AS DAYS_61_TO_90,
CASE WHEN  ACH.DPD_IntService> 30 AND ACH.DPD_IntService<= 60 
     THEN ISNULL(ACH.OverdueAmt,0)/@Cost 
	 ELSE 0 
	 END                                        AS DAYS_31_TO_60,
CASE WHEN  ACH.DPD_IntService<= 30 
     THEN ISNULL(ACH.OverdueAmt,0)/@Cost 
	 ELSE 0 
	 END                                        AS UPTO_30,
ISNULL(ACH.OverdueAmt,0)/@Cost                  AS TOTAL_OVERDUE,
ACH.BranchCode                                  AS Brn,
BranchName                                      AS Branch_Name,
DSDB.SourceName                                 AS SourceName

FROM VWCUSTOMERCAL_hist CCH
INNER JOIN VWACCOUNTCAL_hist ACH         ON CCH.SourceSystemCustomerID=ACH.SourceSystemCustomerID
                                              AND CCH.EffectiveFromTimeKey<= @TimeKey
                                              AND CCH.EffectiveToTimeKey>=@TimeKey
                                              AND ACH.EffectiveFromTimeKey<= @TimeKey
                                              AND ACH.EffectiveToTimeKey>=@TimeKey

LEFT JOIN DimBranch DB                     ON DB.BranchCode=ACH.BranchCode
                                              AND DB.EffectiveFromTimeKey<= @TimeKey
                                              AND DB.EffectiveToTimeKey>=@TimeKey

LEFT JOIN DimProduct DP                    ON DP.ProductAlt_Key=ACH.ProductAlt_Key
                                              AND DP.EffectiveFromTimeKey<= @TimeKey
                                              AND DP.EffectiveToTimeKey>=@TimeKey


INNER JOIN DimSourceDB DSDB                ON DSDB.SourceAlt_Key=ACH.SourceAlt_Key
                                              AND DSDB.EffectiveFromTimeKey<= @TimeKey
                                              AND DSDB.EffectiveToTimeKey>=@TimeKey


WHERE ISNULL(DPD_IntService,0) >=1
      AND ((ISNULL(OverdueAmt,0) BETWEEN @RangeFrom AND @RangeTo) OR (@RangeFrom IS NULL AND @RangeTo IS NULL)
      OR (@RangeFrom IS NULL AND ISNULL(OverdueAmt,0)<= @RangeTo)
      OR (@RangeTo IS NULL AND ISNULL(OverdueAmt,0)>= @RangeFrom)) 
      AND ISNULL(ACH.BANKASSETCLASS,'N')<>'WRITEOFF'
      AND DSDB.SourceName IN ('FCR') AND (DSDB.SourceAlt_Key IN (SELECT * FROM[Split](@Source,',')) OR @Source='0') 

END


GO