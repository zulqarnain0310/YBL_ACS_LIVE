SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


/*
 Created by   : Baijayanti
 Created date : 11/10/2021
 Report Name  : Cases Nearing Expiry Report & Already Expired Cases
*/

CREATE PROC [dbo].[Rpt-20029]
    @TimeKey AS INT,
	@Cost   AS FLOAT, 
	@SelectReport AS INT
AS

--DECLARE   @TimeKey AS INT =26237,
--          @Cost   AS FLOAT=1,
--		  @SelectReport AS INT=2


DECLARE @CurDate AS DATE=(SELECT [DATE] FROM SysDayMatrix WHERE TimeKey=@TimeKey)

-----------------------------------------------------------------
																													

SELECT  
ASD.CollateralID                                     AS [Collateral ID],
ActionTakenRemark                                    AS [Action],
LiabID                                               AS [Liab ID], 
UCICID                                               AS [UCIC], 
CustomerName                                         AS [Customer Name], 
AssetID                                              AS [Asset ID],
SegmentName                                          AS [Segment],
CRE,
DCST.CollateralSubTypeDescription                    AS [Sub Type of Collateral],
NameSecuPvd                                          AS [Name of the security Provider],
SeniorityofCharge                                    AS [Seniority of Charge],
SecurityStatus                                       AS [Security Status],
FDNo                                                 AS [FD No.],
ISINNo                                               AS [ISIN No./Folio Number],
QtyShares_MutualFunds_Bonds                          AS [Quantity of shares/Mutual Funds/Bonds],
Line_No                                              AS [Line No.],
CrossCollateral_LiabID                               AS [Cross Collateral (Liab ID)],
PropertyAdd                                          AS [Property Address],
Pin                                                  AS [PIN Code],
CONVERT(VARCHAR(20),DtStockAudit,103)                AS [Date of stock Audit], 
SBLCIssuingBank                                      AS [SBLC Issuing Bank], 
SBLCNumber                                           AS [SBLC Number], 
CurSBLCissued                                        AS [Currency in which SBLC Issued], 
SBLCFCY                                              AS [SBLC in FCY], 
CONVERT(VARCHAR(20),DtExpirySBLC,103)                AS [Date of expiry for SBLC], 
CONVERT(VARCHAR(20),DtExpiryLIC, 103)                AS [Date of expiry for  LIC],
ModeOperation                                        AS [Mode of Operation], 
ExceApproval                                         AS [Exceptional Approval], 
CurrentValueSource                                   AS [ValuationSource/Expiry Business Rule], 
CONVERT(VARCHAR(20),ValuationDate,103)               AS [Date of Valuation] ,
ISNULL(CurrentValue,0)/@Cost                         AS [Value to be Considered] ,
CONVERT(VARCHAR(20),ValuationExpiryDate,103)         AS [Expiry Date]


FROM AdvSecurityDetail  ASD
INNER JOIN AdvSecurityValueDetail  ASVD      ON  ASD.CollateralID=ASVD.CollateralID              
                                                 AND  ASD.EffectiveFromTimeKey<=@TimeKey AND  ASD.EffectiveToTimeKey>=@TimeKey
												 AND  ASVD.EffectiveFromTimeKey<=@TimeKey AND  ASVD.EffectiveToTimeKey>=@TimeKey 

INNER JOIN DimSegment   DS                   ON ISNULL(ASD.Segment,'0')=CAST(DS.SegmentAlt_Key AS VARCHAR(20))
                                                AND  DS.EffectiveFromTimeKey<=@TimeKey AND  DS.EffectiveToTimeKey>=@TimeKey

LEFT JOIN DimCollateralSubType  DCST         ON ASD.CollateralSubTypeAlt_Key=DCST.CollateralSubTypeAltKey
                                                AND  DCST.EffectiveFromTimeKey<=@TimeKey AND  DCST.EffectiveToTimeKey>=@TimeKey 

WHERE (@SelectReport=1 AND CAST(ValuationExpiryDate AS DATE)=DATEADD(DD,-90,@CurDate)) 
       OR (@SelectReport=2 AND CAST(ValuationExpiryDate AS DATE)<@CurDate)

OPTION(RECOMPILE)
  




GO