SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


/*
 Created by   : Baijayanti
 Created date : 17/11/2021
 Report Name  : Collateral CDAG
*/

CREATE PROC [dbo].[Rpt-20029B]
    @TimeKey AS INT,
	@Cost   AS FLOAT, 
	@SelectReport AS INT
AS

--DECLARE   @TimeKey AS INT =26237,
--          @Cost   AS FLOAT=1,
--		  @SelectReport AS INT=4


DECLARE @CurDate AS DATE=(SELECT [DATE] FROM SysDayMatrix WHERE TimeKey=@TimeKey)

-----------------------------------------------------------------
																													

SELECT 

UCICID                                               AS [UCIC], 
UCICID                                               AS [Customer ID],
CustomerName                                         AS [Customer Name], 
--SegmentName                                          AS [Segment],
SegmentShortName                                     AS [Segment Type],
CollateralSubTypeDescription                         AS [Type of Collateral],
SUM(ISNULL(CurrentValue,0))/@Cost                    AS [Value of Security],
SUM(CASE WHEN CAST(ValuationDate  AS DATE)<=DATEADD(DD,-90,@CurDate)
         THEN ISNULL(CurrentValue,0)
	     ELSE 0
	     END)/@Cost                                       AS [Total Security Immediate earlier quarter] , 
SUM(CASE WHEN CAST(ValuationDate  AS DATE)<=DATEADD(DD,-180,@CurDate)
         THEN ISNULL(CurrentValue,0)
	     ELSE 0
	     END)/@Cost                                       AS [Total Security Quarter earlier to Immediate earlier qaurter] ,	       
SUM(ISNULL(TotalSecurityMarOfPreviousFY,0))/@Cost         AS [Total Security Mar of Previous FY]


FROM AdvSecurityDetail  ASD
INNER JOIN AdvSecurityValueDetail  ASVD      ON  ASD.CollateralID=ASVD.CollateralID              
                                                 AND  ASD.EffectiveFromTimeKey<=@TimeKey AND  ASD.EffectiveToTimeKey>=@TimeKey
												 AND  ASVD.EffectiveFromTimeKey<=@TimeKey AND  ASVD.EffectiveToTimeKey>=@TimeKey 

INNER JOIN DimSegment   DS                   ON ISNULL(ASD.Segment,'0')=CAST(DS.SegmentAlt_Key AS VARCHAR(20))
                                                AND  DS.EffectiveFromTimeKey<=@TimeKey AND  DS.EffectiveToTimeKey>=@TimeKey

WHERE @SelectReport=4

GROUP BY

UCICID, 
CustomerName, 
SegmentName,
SegmentShortName,
CollateralSubTypeDescription

OPTION(RECOMPILE)
  

 	




GO