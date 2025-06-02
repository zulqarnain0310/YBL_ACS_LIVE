SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO




/*
 Created by   : Baijayanti
 Created date : 25/10/2021
 Report Name  : Collateral Variance Report
*/

CREATE PROC [dbo].[Rpt-20029A]
    @TimeKey AS INT,
	@Cost   AS FLOAT, 
	@SelectReport AS INT
AS

--DECLARE   @TimeKey AS INT =26237,
--          @Cost   AS FLOAT=1,
--		  @SelectReport AS INT=3


DECLARE @CurDate AS DATE=(SELECT [DATE] FROM SysDayMatrix WHERE TimeKey=@TimeKey)
DECLARE @LastMDate AS DATE=(SELECT DATEADD(MM,-1,[DATE]) FROM SysDayMatrix WHERE TimeKey=@TimeKey)


-----------------------------------------------------------------
IF OBJECT_ID('tempdb..#DATA') IS NOT NULL 
	DROP TABLE #DATA																													

SELECT  
LiabID                                               AS [Liab ID], 
UCICID                                               AS [UCIC], 
CustomerName                                         AS [Customer Name],
SegmentName                                          AS [Segment], 

------------------------------Current Assets----------------------------

SUM(CASE WHEN CollateralSubTypeDescription  = 'Current Assets' 
               AND ValuationDate=@LastMDate
         THEN ISNULL(CurrentValue,0)
	     ELSE 0
	     END)/@Cost                                      AS PerM_CurrentAssets,

SUM(CASE WHEN CollateralSubTypeDescription  = 'Current Assets' 
              AND CAST(ValuationDate AS DATE)=@CurDate
         THEN ISNULL(CurrentValue,0)
	     ELSE 0
	     END)/@Cost                                       AS CurM_CurrentAssets, 

-------------------Movable Fixed Assets----------------

SUM(CASE WHEN CollateralSubTypeDescription  = 'Movable Fixed Assets' 
              AND ValuationDate=@LastMDate
         THEN ISNULL(CurrentValue,0)
	     ELSE 0
	     END)/@Cost                                       AS PerM_MovableFixedAssets,

SUM(CASE WHEN CollateralSubTypeDescription  = 'Movable Fixed Assets' 
              AND CAST(ValuationDate AS DATE)=@CurDate
         THEN ISNULL(CurrentValue,0)
	     ELSE 0
	     END)/@Cost                                       AS CurM_MovableFixedAssets,

------------------Immovable Fixed assets---------------------------

SUM(CASE WHEN CollateralSubTypeDescription  = 'Immovable Fixed assets' 
              AND ValuationDate=@LastMDate
         THEN ISNULL(CurrentValue,0)
	     ELSE 0
	     END)/@Cost                                       AS PerM_ImmovableFixedAssets,

SUM(CASE WHEN CollateralSubTypeDescription  = 'Immovable Fixed assets' 
              AND CAST(ValuationDate AS DATE)=@CurDate
         THEN ISNULL(CurrentValue,0)
	     ELSE 0
	     END)/@Cost                                       AS CurM_ImmovableFixedAssets,

------------------------Listed Shares---------------

SUM(CASE WHEN CollateralSubTypeDescription  = 'Listed Shares' 
              AND ValuationDate=@LastMDate
         THEN ISNULL(CurrentValue,0)
	     ELSE 0
	     END)/@Cost                                       AS PerM_ListedShares,

SUM(CASE WHEN CollateralSubTypeDescription  = 'Listed Shares' 
              AND CAST(ValuationDate AS DATE)=@CurDate
         THEN ISNULL(CurrentValue,0)
	     ELSE 0
	     END)/@Cost                                       AS CurM_ListedShares,

-----------------------------Unlisted Shares---------------

SUM(CASE WHEN CollateralSubTypeDescription  = 'Unlisted Shares' 
              AND ValuationDate=@LastMDate
         THEN ISNULL(CurrentValue,0)
	     ELSE 0
	     END)/@Cost                                       AS PerM_UnlistedShares,

SUM(CASE WHEN CollateralSubTypeDescription  = 'Unlisted Shares' 
              AND CAST(ValuationDate AS DATE)=@CurDate
         THEN ISNULL(CurrentValue,0)
	     ELSE 0
	     END)/@Cost                                       AS CurM_UnlistedShares,

-------------------Mutual Funds-------------------

SUM(CASE WHEN CollateralSubTypeDescription  = 'Mutual Funds' 
              AND ValuationDate=@LastMDate
         THEN ISNULL(CurrentValue,0)
	     ELSE 0
	     END)/@Cost                                       AS PerM_MutualFunds,

SUM(CASE WHEN CollateralSubTypeDescription  = 'Mutual Funds' 
              AND CAST(ValuationDate AS DATE)=@CurDate
         THEN ISNULL(CurrentValue,0)
	     ELSE 0
	     END)/@Cost                                       AS CurM_MutualFunds,

----------------------------Bond----------------------

SUM(CASE WHEN CollateralSubTypeDescription  = 'Bond' 
              AND ValuationDate=@LastMDate
         THEN ISNULL(CurrentValue,0)
	     ELSE 0
	     END)/@Cost                                       AS PerM_Bond,

SUM(CASE WHEN CollateralSubTypeDescription  = 'Bond' 
              AND CAST(ValuationDate AS DATE)=@CurDate
         THEN ISNULL(CurrentValue,0)
	     ELSE 0
	     END)/@Cost                                       AS CurM_Bond,


------------------------------Other Intangibles----------------------------

SUM(CASE WHEN CollateralSubTypeDescription  = 'Other Intangibles' 
              AND ValuationDate=@LastMDate
         THEN ISNULL(CurrentValue,0)
	     ELSE 0
	     END)/@Cost                                       AS PerM_OtherIntangibles,

SUM(CASE WHEN CollateralSubTypeDescription  = 'Other Intangibles' 
              AND CAST(ValuationDate AS DATE)=@CurDate
         THEN ISNULL(CurrentValue,0)
	     ELSE 0
	     END)/@Cost                                       AS CurM_OtherIntangibles, 

-------------------Object Finance----------------

SUM(CASE WHEN CollateralSubTypeDescription  = 'Object Finance' 
              AND ValuationDate=@LastMDate
         THEN ISNULL(CurrentValue,0)
	     ELSE 0
	     END)/@Cost                                       AS PerM_ObjectFinance,

SUM(CASE WHEN CollateralSubTypeDescription  = 'Object Finance' 
              AND CAST(ValuationDate AS DATE)=@CurDate
         THEN ISNULL(CurrentValue,0)
	     ELSE 0
	     END)/@Cost                                       AS CurM_ObjectFinance,

------------------SBLC/BG---------------------------

SUM(CASE WHEN CollateralSubTypeDescription  = 'SBLC/BG' 
              AND ValuationDate=@LastMDate
         THEN ISNULL(CurrentValue,0)
	     ELSE 0
	     END)/@Cost                                       AS [PerM_SBLC/BG],

SUM(CASE WHEN CollateralSubTypeDescription  = 'SBLC/BG' 
              AND CAST(ValuationDate AS DATE)=@CurDate
         THEN ISNULL(CurrentValue,0)
	     ELSE 0
	     END)/@Cost                                       AS [CurM_SBLC/BG],

------------------------LIC---------------

SUM(CASE WHEN CollateralSubTypeDescription  = 'LIC' 
              AND ValuationDate=@LastMDate
         THEN ISNULL(CurrentValue,0)
	     ELSE 0
	     END)/@Cost                                      AS PerM_LIC,

SUM(CASE WHEN CollateralSubTypeDescription  = 'LIC' 
              AND CAST(ValuationDate AS DATE)=@CurDate
         THEN ISNULL(CurrentValue,0)
	     ELSE 0
	     END)/@Cost                                       AS CurM_LIC,

-----------------------------Borrowers FD---------------

SUM(CASE WHEN CollateralSubTypeDescription  = 'Borrowers FD' 
              AND ValuationDate=@LastMDate
         THEN ISNULL(CurrentValue,0)
	     ELSE 0
	     END)/@Cost                                       AS PerM_BorrowersFD,

SUM(CASE WHEN CollateralSubTypeDescription  = 'Borrowers FD' 
              AND CAST(ValuationDate AS DATE)=@CurDate
         THEN ISNULL(CurrentValue,0)
	     ELSE 0
	     END)/@Cost                                       AS CurM_BorrowersFD,

-------------------Third Party FD-------------------

SUM(CASE WHEN CollateralSubTypeDescription  = 'Third Party FD' 
              AND ValuationDate=@LastMDate
         THEN ISNULL(CurrentValue,0)
	     ELSE 0
	     END)/@Cost                                       AS PerM_ThirdPartyFD,

SUM(CASE WHEN CollateralSubTypeDescription  = 'Third Party FD' 
              AND CAST(ValuationDate AS DATE)=@CurDate
         THEN ISNULL(CurrentValue,0)
	     ELSE 0
	     END)/@Cost                                       AS CurM_ThirdPartyFD,

----------------------------Government Guarantee----------------------

SUM(CASE WHEN CollateralSubTypeDescription  = 'Government Guarantee' 
              AND ValuationDate=@LastMDate
         THEN ISNULL(CurrentValue,0)
	     ELSE 0
	     END)/@Cost                                       AS PerM_GovernmentGuarantee,

SUM(CASE WHEN CollateralSubTypeDescription  = 'Government Guarantee' 
              AND CAST(ValuationDate AS DATE)=@CurDate
         THEN ISNULL(CurrentValue,0)
	     ELSE 0
	     END)/@Cost                                       AS CurM_GovernmentGuarantee,

-------------------Gold-------------------

SUM(CASE WHEN CollateralSubTypeDescription  = 'Gold' 
              AND ValuationDate=@LastMDate
         THEN ISNULL(CurrentValue,0)
	     ELSE 0
	     END)/@Cost                                       AS PerM_Gold,

SUM(CASE WHEN CollateralSubTypeDescription  = 'Gold' 
              AND CAST(ValuationDate AS DATE)=@CurDate
         THEN ISNULL(CurrentValue,0)
	     ELSE 0
	     END)/@Cost                                       AS CurM_Gold,

----------------------------Toll Receivables----------------------

SUM(CASE WHEN CollateralSubTypeDescription  = 'Toll Receivables' 
              AND ValuationDate=@LastMDate
         THEN ISNULL(CurrentValue,0)
	     ELSE 0
	     END)/@Cost                                      AS PerM_TollReceivables,

SUM(CASE WHEN CollateralSubTypeDescription  = 'Toll Receivables' 
              AND CAST(ValuationDate AS DATE)=@CurDate
         THEN ISNULL(CurrentValue,0)
	     ELSE 0
	     END)/@Cost                                       AS CurM_TollReceivables,

---------------------------Total-------------------
SUM(CASE WHEN CollateralSubTypeDescription IN('Current Assets','Movable Fixed Assets','Immovable Fixed assets','Listed Shares','Unlisted Shares','Mutual Funds',
                                              'Bond','Other Intangibles','Object Finance','SBLC/BG','LIC','Borrowers FD','Third Party FD','Government Guarantee',
											  'Gold','Toll Receivables')
              AND ValuationDate=@LastMDate
         THEN ISNULL(CurrentValue,0)
	     ELSE 0
	     END)/@Cost                                      AS PerM_TotalValue,

SUM(CASE WHEN CollateralSubTypeDescription  IN('Current Assets','Movable Fixed Assets','Immovable Fixed assets','Listed Shares','Unlisted Shares','Mutual Funds',
                                              'Bond','Other Intangibles','Object Finance','SBLC/BG','LIC','Borrowers FD','Third Party FD','Government Guarantee',
											  'Gold','Toll Receivables') 
              AND CAST(ValuationDate AS DATE)=@CurDate
         THEN ISNULL(CurrentValue,0)
	     ELSE 0
	     END)/@Cost                                       AS CurM_TotalValue

INTO #DATA

FROM AdvSecurityDetail  ASD
INNER JOIN AdvSecurityValueDetail  ASVD      ON  ASD.CollateralID=ASVD.CollateralID              
                                                 AND  ASD.EffectiveFromTimeKey<=@TimeKey AND  ASD.EffectiveToTimeKey>=@TimeKey
												 AND  ASVD.EffectiveFromTimeKey<=@TimeKey AND  ASVD.EffectiveToTimeKey>=@TimeKey 
												 
INNER JOIN DimSegment   DS                    ON ISNULL(ASD.Segment,'0')=CAST(DS.SegmentAlt_Key AS VARCHAR(20))
                                                AND  DS.EffectiveFromTimeKey<=@TimeKey AND  DS.EffectiveToTimeKey>=@TimeKey

WHERE @SelectReport=3

GROUP BY
LiabID,                                              
UCICID,                                              
CustomerName,                                        
SegmentName  

OPTION(RECOMPILE)
  

SELECT 
 [Liab ID]
,UCIC
,[Customer Name]
,Segment	
,ISNULL(PerM_CurrentAssets,0)                   AS PerM_CurrentAssets 	
,ISNULL(CurM_CurrentAssets,0)                   AS CurM_CurrentAssets
,ISNULL(((ISNULL(CurM_CurrentAssets,0)-ISNULL(PerM_CurrentAssets,0))/NULLIF(PerM_CurrentAssets,0))*100,0)  AS Variance_CurrentAssets
	
,ISNULL(PerM_MovableFixedAssets,0)              AS PerM_MovableFixedAssets	
,ISNULL(CurM_MovableFixedAssets,0)              AS CurM_MovableFixedAssets
,ISNULL(((ISNULL(CurM_MovableFixedAssets,0)-ISNULL(PerM_MovableFixedAssets,0))/NULLIF(PerM_MovableFixedAssets,0))*100,0)  AS Variance_MovableFixedAssets
	
,ISNULL(PerM_ImmovableFixedAssets,0)            AS PerM_ImmovableFixedAssets	
,ISNULL(CurM_ImmovableFixedAssets,0)            AS CurM_ImmovableFixedAssets
,ISNULL(((ISNULL(CurM_ImmovableFixedAssets,0)-ISNULL(PerM_ImmovableFixedAssets,0))/NULLIF(PerM_ImmovableFixedAssets,0))*100,0)  AS Variance_ImmovableFixedAssets
	
,ISNULL(PerM_ListedShares,0)                    AS PerM_ListedShares	
,ISNULL(CurM_ListedShares,0)                    AS CurM_ListedShares
,ISNULL(((ISNULL(CurM_ListedShares,0)-ISNULL(PerM_ListedShares,0))/NULLIF(PerM_ListedShares,0))*100,0)  AS Variance_ListedShares
	
,ISNULL(PerM_UnlistedShares,0)                  AS PerM_UnlistedShares	
,ISNULL(CurM_UnlistedShares,0)                  AS CurM_UnlistedShares
,ISNULL(((ISNULL(CurM_UnlistedShares,0)-ISNULL(PerM_UnlistedShares,0))/NULLIF(PerM_UnlistedShares,0))*100,0)  AS Variance_UnlistedShares
	
,ISNULL(PerM_MutualFunds,0)                     AS PerM_MutualFunds	
,ISNULL(CurM_MutualFunds,0)                     AS CurM_MutualFunds
,ISNULL(((ISNULL(CurM_MutualFunds,0)-ISNULL(PerM_MutualFunds,0))/NULLIF(PerM_MutualFunds,0))*100,0)  AS Variance_MutualFunds
	
,ISNULL(PerM_Bond,0)                            AS PerM_Bond	
,ISNULL(CurM_Bond,0)                            AS CurM_Bond
,ISNULL(((ISNULL(CurM_Bond,0)-ISNULL(PerM_Bond,0))/NULLIF(PerM_Bond,0))*100,0)  AS Variance_Bond
	
,ISNULL(PerM_OtherIntangibles,0)                AS PerM_OtherIntangibles	
,ISNULL(CurM_OtherIntangibles,0)                AS CurM_OtherIntangibles
,ISNULL(((ISNULL(CurM_OtherIntangibles,0)-ISNULL(PerM_OtherIntangibles,0))/NULLIF(PerM_OtherIntangibles,0))*100,0)  AS Variance_OtherIntangibles
	
,ISNULL(PerM_ObjectFinance,0)                   AS PerM_ObjectFinance                  	
,ISNULL(CurM_ObjectFinance,0)					AS CurM_ObjectFinance
,ISNULL(((ISNULL(CurM_ObjectFinance,0)-ISNULL(PerM_ObjectFinance,0))/NULLIF(PerM_ObjectFinance,0))*100,0)  AS Variance_ObjectFinance
	
,ISNULL([PerM_SBLC/BG],0)	                    AS [PerM_SBLC/BG]
,ISNULL([CurM_SBLC/BG],0)						AS [CurM_SBLC/BG]
,ISNULL(((ISNULL([CurM_SBLC/BG],0)-ISNULL([PerM_SBLC/BG],0))/NULLIF([PerM_SBLC/BG],0))*100,0)  AS Variance_SLBC_BG

,ISNULL(PerM_LIC,0)	                            AS PerM_LIC
,ISNULL(CurM_LIC,0)								AS CurM_LIC
,ISNULL(((ISNULL(CurM_LIC,0)-ISNULL(PerM_LIC,0))/NULLIF(PerM_LIC,0))*100,0)  AS Variance_LIC	

,ISNULL(PerM_BorrowersFD,0)	                    AS PerM_BorrowersFD
,ISNULL(CurM_BorrowersFD,0)						AS CurM_BorrowersFD
,ISNULL(((ISNULL(CurM_BorrowersFD,0)-ISNULL(PerM_BorrowersFD,0))/NULLIF(PerM_BorrowersFD,0))*100,0)  AS Variance_BorrowersFD	

,ISNULL(PerM_ThirdPartyFD,0)                    AS PerM_ThirdPartyFD	
,ISNULL(CurM_ThirdPartyFD,0)					AS CurM_ThirdPartyFD
,ISNULL(((ISNULL(CurM_ThirdPartyFD,0)-ISNULL(PerM_ThirdPartyFD,0))/NULLIF(PerM_ThirdPartyFD,0))*100,0)  AS Variance_ThirdPartyFD
	
,ISNULL(PerM_GovernmentGuarantee,0)	            AS PerM_GovernmentGuarantee
,ISNULL(CurM_GovernmentGuarantee,0)				AS CurM_GovernmentGuarantee
,ISNULL(((ISNULL(CurM_GovernmentGuarantee,0)-ISNULL(PerM_GovernmentGuarantee,0))/NULLIF(PerM_GovernmentGuarantee,0))*100,0)  AS Variance_GovernmentGuarantee

,ISNULL(PerM_Gold,0)                            AS PerM_Gold	
,ISNULL(CurM_Gold,0)							AS CurM_Gold
,ISNULL(((ISNULL(CurM_Gold,0)-ISNULL(PerM_Gold,0))/NULLIF(PerM_Gold,0))*100,0)  AS Variance_Gold
	
,ISNULL(PerM_TollReceivables,0)	                AS PerM_TollReceivables
,ISNULL(CurM_TollReceivables,0)					AS CurM_TollReceivables
,ISNULL(((ISNULL(CurM_TollReceivables,0)-ISNULL(PerM_TollReceivables,0))/NULLIF(PerM_TollReceivables,0))*100,0)  AS Variance_TollReceivables

,ISNULL(PerM_TotalValue,0)                      AS PerM_TotalValue
,ISNULL(CurM_TotalValue,0)                      AS CurM_TotalValue
,ISNULL(((ISNULL(CurM_TotalValue,0)-ISNULL(PerM_TotalValue,0))/NULLIF(PerM_TotalValue,0))*100,0)  AS Variance_TotalValue

FROM #DATA

OPTION(RECOMPILE)

DROP TABLE #DATA
GO