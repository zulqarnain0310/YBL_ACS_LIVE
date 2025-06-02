SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO




CREATE PROCEDURE [dbo].[Rpt-20024] 
   @TimeKey   AS INT,
   @CustomerID  AS VARCHAR(MAX),
   @ExposureBucket AS VARCHAR(500),
   @RP_Plan AS VARCHAR(100),
   @Yes_Bank_Exposure AS VARCHAR(5)
AS

--DECLARE 
--   @TimeKey   AS INT=25781,
--   @CustomerID  AS VARCHAR(MAX)='0',
--   @ExposureBucket AS VARCHAR(500)='0',
--   @RP_Plan AS VARCHAR(100)='ALL',
--   @Yes_Bank_Exposure AS VARCHAR(5)='Y'

DECLARE @CurDate AS DATE=(SELECT DATE FROM SysDayMatrix WHERE TimeKey=@TimeKey)

SELECT [PAN_No]
      ,[UCIC_ID]
      ,RPPD.[CustomerID]
      ,[CustomerName]
      ,DBRP.BankName
      ,BA.ArrangementDescription
      ,BRP.BankName                                              AS LeadBank
      ,CONVERT(VARCHAR(20),InDefaultDate,103)                    AS [DefaultDate]
      ,DP.ParameterName                                          AS [RP_Status]
      ,EB.BucketName                                             AS Bucketvalue
	  ,CONVERT(VARCHAR(20),ReferenceDate,103)                    AS [ReferenceDate]
      ,CONVERT(VARCHAR(20),ReviewExpiryDate,103)                 AS [ReviewExpiryDate]
      ,CONVERT(VARCHAR(20),RP_ApprovalDate,103)                  AS [RP_ApprovalDate]
      ,DPN.ParameterName                                         AS [RP_Nature]
      ,[If_Other]
      ,CASE WHEN DATEDIFF(DD,ReviewExpiryDate,@CurDate)<0
	        THEN ''
			ELSE DATEDIFF(DD,ReviewExpiryDate,@CurDate)
			END                                                  AS [DaysPassedReviewPeriodDate]
      ,CONVERT(VARCHAR(20),RPPD.RP_ExpiryDate,103)               AS [ResolutionPlanImplementationDate]
      ,DPI.ParameterName                                         AS [ImplStatus]
      ,CONVERT(VARCHAR(20),Actual_Impl_Date,103)                 AS [Actual_Impl_Date]
      ,CASE WHEN DATEDIFF(DD,RPPD.RP_ExpiryDate,@CurDate)<0
	        THEN ''
			ELSE DATEDIFF(DD,RPPD.RP_ExpiryDate,@CurDate)
			END                                                  AS [DaysPassedResolutionImplementationDate]
	  ,CONVERT(VARCHAR(20),RP_OutOfDateAllBanksDeadline,103)     AS [OutOfDefaultDate]
      ,CONVERT(VARCHAR(20),Revised_RP_Expiry_Date,103)           AS [Revised_RP_Expiry_Date]
      ,CASE WHEN IsBankExposure='Y'
	        THEN 'YES'
			WHEN IsBankExposure='N'
	        THEN 'NO'
			END                                                  AS [IsBankExposure]
      ,AC.AssetClassName
      --,[ActSegmentCode]
      --,[RM_Name]
      --,[TL_Name]
      ,CONVERT(VARCHAR(20),RiskReviewExpiryDate,103)             AS [RiskReviewExpiryDate]


  FROM RP_Portfolio_Details RPPD
  INNER JOIN RP_Lender_Details RPLD                ON RPPD.CustomerID=RPLD.CustomerID
                                                      AND RPPD.EffectiveFromTimeKey<=@TimeKey 
												      AND RPPD.EffectiveToTimeKey>=@TimeKey
													  AND RPLD.EffectiveFromTimeKey<=@TimeKey 
												      AND RPLD.EffectiveToTimeKey>=@TimeKey

  INNER JOIN DimExposureBucket EB                 ON RPPD.ExposureBucketAlt_Key=EB.ExposureBucketAlt_Key
                                                      AND EB.EffectiveFromTimeKey<=@TimeKey 
												      AND EB.EffectiveToTimeKey>=@TimeKey
											       
  LEFT JOIN DimBankingArrangement BA              ON BA.BankingArrangementAlt_Key=RPPD.BankingArrangementAlt_Key
                                                      AND BA.EffectiveFromTimeKey<=@TimeKey 
												      AND BA.EffectiveToTimeKey>=@TimeKey
											       
  INNER JOIN DimParameter DP                      ON RPPD.DefaultStatusAlt_Key=DP.ParameterAlt_Key
                                                      AND DP.EffectiveFromTimeKey<=@TimeKey 
												      AND DP.EffectiveToTimeKey>=@TimeKey
												      AND DP.DimParameterName='BorrowerDefaultStatus'   
													  
  LEFT JOIN DimParameter  DPN	                  ON RPPD.RPNatureAlt_Key=DPN.ParameterAlt_Key
                                                      AND DPN.EffectiveFromTimeKey<=@TimeKey 
												      AND DPN.EffectiveToTimeKey>=@TimeKey
												      AND DPN.DimParameterName='DimNatureResolutionPlan'  
													  
													  												   
  INNER JOIN DimParameter DPI                     ON RPPD.RP_ImplStatusAlt_Key=DPI.ParameterAlt_Key
                                                      AND DPI.EffectiveFromTimeKey<=@TimeKey 
												      AND DPI.EffectiveToTimeKey>=@TimeKey
													  AND DPI.DimParameterName='ImplementationStatus'
													  											       
  INNER JOIN DimBankRP BRP                         ON BRP.BankRPAlt_Key=RPPD.LeadBankAlt_Key
                                                      AND BRP.EffectiveFromTimeKey<=@TimeKey 
												      AND BRP.EffectiveToTimeKey>=@TimeKey

  INNER JOIN DimBankRP DBRP                         ON DBRP.BankRPAlt_Key=RPLD.ReportingLenderAlt_Key
                                                      AND DBRP.EffectiveFromTimeKey<=@TimeKey 
												      AND DBRP.EffectiveToTimeKey>=@TimeKey
											       
  INNER JOIN DimAssetClass AC                      ON AC.AssetClassAlt_Key=RPPD.AssetClassAlt_Key
                                                      AND AC.EffectiveFromTimeKey<=@TimeKey 
												      AND AC.EffectiveToTimeKey>=@TimeKey
											       

 WHERE (RPPD.CustomerID IN (SELECT * FROM[Split](@CustomerID,',')) OR @CustomerID='0')
       AND (EB.ExposureBucketAlt_Key IN (SELECT * FROM[Split](@ExposureBucket,',')) OR @ExposureBucket='0')
	   AND @Yes_Bank_Exposure=[IsBankExposure]
	   AND (@RP_Plan=(CASE WHEN (DP.ParameterName='In Default' AND DPI.ParameterName='In Progress') OR  DPI.ParameterName='Extended'
	                      THEN 'Active'
						  WHEN (DP.ParameterName='Out of Default' AND DPI.ParameterName='Implemented') OR  (DP.ParameterName='Out of Default' AND DPI.ParameterName='Implemented with Extension')
	                      THEN 'Expired'
						  END) OR @RP_Plan='ALL')

ORDER BY RPPD.[CustomerID]

  OPTION(RECOMPILE)
GO