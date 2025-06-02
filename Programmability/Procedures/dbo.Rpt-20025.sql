SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Rpt-20025] 
   @TimeKey   AS INT,
   @CustomerID  AS VARCHAR(MAX),
   @ProjectCategory AS VARCHAR(MAX),
   @ProjectDelayReason AS VARCHAR(MAX),
   @StandardRestructured AS VARCHAR(MAX)
AS


--DECLARE 
--   @TimeKey   AS INT=25999,
--   @CustomerID  AS VARCHAR(MAX)='9987801,9987888,9987802,9987889,9987803,9987883,161760505,9987800',
--   @ProjectCategory AS VARCHAR(MAX)='1,2,3',
--   @ProjectDelayReason AS VARCHAR(MAX)='0',
--   @StandardRestructured AS VARCHAR(MAX)='0'

   
DECLARE @Date AS DATE=(SELECT [DATE] FROM SysDayMatrix WHERE TimeKey=@TimeKey)

SELECT 
       ACPD.[CustomerID]
      ,ACPD.[CustomerName]
      ,ACPD.AccountID
      ,CONVERT(VARCHAR(20),ACPD.OriginalEnvisagCompletionDt,103)              AS [Original SCOD]
      ,CONVERT(VARCHAR(20),ACPD.RevisedCompletionDt,103)                      AS [Revised SCOD]	
      ,CONVERT(VARCHAR(20),ACPD.ActualCompletionDt,103)                       AS [Actual DCCO]
      ,DPPC.ParameterName                                                     AS [Project Category]
	  ,CASE WHEN DP.ParameterName='Beyond Control of Promoters'
	        THEN 'Yes'
			ELSE 'No'
			END                                                               AS [Beyond Control of Promoters]
      ,CASE WHEN DP.ParameterName='Court Case'
	        THEN 'Yes'
			ELSE 'No'
			END                                                               AS [Project Delay Reason]
      ,DPR.ParameterName                                                      AS [Standard Restructured]
	  ,CONVERT(VARCHAR(20),PNPA_DATE,103)                                     AS [PNPA Date]
      ,PNPA_Reason                                                            AS [PNPA Reason]

      ,CASE WHEN (DPPC.ParameterName IN('Infra','Non Infra','CRE') AND ACPD.OriginalEnvisagCompletionDt>@Date)
				 OR (DPPC.ParameterName IN('Infra','Non Infra','CRE') AND ACPD.OriginalEnvisagCompletionDt>@Date AND ACPD.RevisedCompletionDt>@Date)
				 OR (DPPC.ParameterName IN('Infra','Non Infra','CRE') AND ACPD.OriginalEnvisagCompletionDt<@Date AND ACPD.RevisedCompletionDt>@Date)
				 OR (DPPC.ParameterName IN('Infra','Non Infra','CRE') AND ACPD.OriginalEnvisagCompletionDt<@Date AND ACPD.RevisedCompletionDt<@Date AND ACPD.ActualCompletionDt<@Date)
				 OR (DPPC.ParameterName IN('Infra','Non Infra','CRE') AND ACPD.OriginalEnvisagCompletionDt<@Date AND ACPD.ActualCompletionDt<@Date)
				 OR (DPPC.ParameterName IN('Infra','Non Infra','CRE') AND ACPD.OriginalEnvisagCompletionDt<@Date AND ACPD.RevisedCompletionDt>@Date AND ACPD.ActualCompletionDt<@Date)
				 OR (DPPC.ParameterName IN('Infra','Non Infra','CRE') AND ACPD.OriginalEnvisagCompletionDt<@Date AND ACPD.RevisedCompletionDt>@Date AND ACPD.ActualCompletionDt<@Date AND DPR.ParameterShortName='Y')
				 OR (DPPC.ParameterName IN('Infra','Non Infra','CRE') AND ACPD.OriginalEnvisagCompletionDt<@Date AND ACPD.RevisedCompletionDt>@Date AND ACPD.ActualCompletionDt<@Date)
	        THEN 'No action from PUI perspective'  

			WHEN (DPPC.ParameterName IN('Infra','Non Infra','CRE') AND ACPD.OriginalEnvisagCompletionDt>@Date  AND DPR.ParameterShortName='Y')
			     OR (DPPC.ParameterName IN('Infra','Non Infra','CRE') AND ACPD.OriginalEnvisagCompletionDt>@Date AND ACPD.RevisedCompletionDt>@Date AND DPR.ParameterShortName='Y')
				 OR (DPPC.ParameterName IN('Infra','Non Infra','CRE') AND ACPD.OriginalEnvisagCompletionDt<@Date AND ACPD.RevisedCompletionDt>@Date AND DPR.ParameterShortName='Y')
				 OR (DPPC.ParameterName IN('Infra','Non Infra','CRE') AND ACPD.OriginalEnvisagCompletionDt<@Date AND ACPD.ActualCompletionDt<@Date AND DPR.ParameterShortName='Y')
				 OR (DPPC.ParameterName IN('Infra','Non Infra','CRE') AND ACPD.OriginalEnvisagCompletionDt<@Date AND ACPD.RevisedCompletionDt<@Date AND ACPD.ActualCompletionDt<@Date AND DPR.ParameterShortName='Y')				 
				 OR (DPPC.ParameterName IN('Infra','Non Infra','CRE') AND ACPD.OriginalEnvisagCompletionDt<@Date AND ACPD.RevisedCompletionDt<@Date 
			         AND DP.ParameterName='Court Case' AND ISNULL(DP.ParameterName,'')<>'Beyond Control of Promoters' AND DPR.ParameterShortName='Y')
                 OR (DPPC.ParameterName='Infra' AND ACPD.OriginalEnvisagCompletionDt<@Date AND ACPD.RevisedCompletionDt>@Date 
			         AND ISNULL(DP.ParameterName,'')<>'Court Case' AND DP.ParameterName='Beyond Control of Promoters' AND DPR.ParameterShortName='Y')
				 OR (DPPC.ParameterName='Infra' AND ACPD.OriginalEnvisagCompletionDt<@Date AND ACPD.RevisedCompletionDt>@Date 
			         AND DP.ParameterName='Court Case' AND ISNULL(DP.ParameterName,'')<>'Beyond Control of Promoters' AND DPR.ParameterShortName='Y')
				 OR (DPPC.ParameterName IN('Non Infra','CRE') AND ACPD.OriginalEnvisagCompletionDt<@Date AND ACPD.RevisedCompletionDt>@Date  
			         AND ISNULL(DP.ParameterName,'')<>'Court Case' AND DP.ParameterName='Beyond Control of Promoters' AND DPR.ParameterShortName='Y')
	        THEN 'No action from PUI perspective; Restructured from PUI perspective'  

			WHEN (DPPC.ParameterName='Infra' AND ACPD.OriginalEnvisagCompletionDt<@Date AND ACPD.RevisedCompletionDt>@Date AND InitialNpaDt>@Date AND DPR.ParameterShortName='Y')
			     OR (DPPC.ParameterName IN('Non Infra','CRE') AND ACPD.OriginalEnvisagCompletionDt<@Date AND ACPD.RevisedCompletionDt>@Date AND InitialNpaDt>@Date AND DPR.ParameterShortName='N')
			     OR (DPPC.ParameterName IN('Non Infra','CRE') AND ACPD.OriginalEnvisagCompletionDt<@Date AND ACPD.RevisedCompletionDt>@Date AND InitialNpaDt>@Date AND DPR.ParameterShortName='Y')
			THEN 'NPA from PUI perspective since SCOD exceeds the maximum permissible period'  

			WHEN DPPC.ParameterName IN('Non Infra','CRE') AND ACPD.OriginalEnvisagCompletionDt<@Date AND ACPD.RevisedCompletionDt>@Date AND InitialNpaDt<@Date AND DPR.ParameterShortName='Y'
			THEN 'NPA from PUI perspective; Restructured from PUI perspective'  

			WHEN (DPPC.ParameterName IN('Infra') AND ACPD.OriginalEnvisagCompletionDt<@Date AND ACPD.RevisedCompletionDt<@Date AND InitialNpaDt>@Date)
				 OR (DPPC.ParameterName IN('Infra') AND ACPD.OriginalEnvisagCompletionDt<@Date AND InitialNpaDt>@Date )
				 OR (DPPC.ParameterName IN('Non Infra','CRE') AND ACPD.OriginalEnvisagCompletionDt<@Date AND ACPD.RevisedCompletionDt<@Date AND InitialNpaDt>@Date)
				 OR (DPPC.ParameterName IN('Non Infra','CRE') AND ACPD.OriginalEnvisagCompletionDt<@Date AND InitialNpaDt>@Date)
			THEN 'SCOD is a passed date'  --done

			WHEN (DPPC.ParameterName IN('Infra','Non Infra','CRE') AND ACPD.OriginalEnvisagCompletionDt<@Date  AND  ACPD.RevisedCompletionDt IS NULL)
	             OR (DPPC.ParameterName IN('Infra','Non Infra','CRE') AND ACPD.OriginalEnvisagCompletionDt<@Date AND ACPD.RevisedCompletionDt<@Date AND ACPD.ActualCompletionDt IS NULL)
				 OR (DPPC.ParameterName IN('Infra','Non Infra','CRE') AND ACPD.OriginalEnvisagCompletionDt<@Date AND ACPD.RevisedCompletionDt>@Date AND ACPD.ActualCompletionDt IS NULL)
				 OR (DPPC.ParameterName='Infra' AND ACPD.RevisedCompletionDt>DATEADD(DD,2,ACPD.OriginalEnvisagCompletionDt) AND ACPD.RevisedCompletionDt>@Date AND DPR.ParameterShortName='N')
				 OR (DPPC.ParameterName='Infra' AND ACPD.RevisedCompletionDt>DATEADD(DD,3,ACPD.OriginalEnvisagCompletionDt) AND ACPD.RevisedCompletionDt>@Date AND DPR.ParameterShortName='N')
				 OR (DPPC.ParameterName='Infra' AND ACPD.RevisedCompletionDt>DATEADD(DD,4,ACPD.OriginalEnvisagCompletionDt) AND ACPD.RevisedCompletionDt>@Date AND DPR.ParameterShortName='N')
				 OR (DPPC.ParameterName IN('Non Infra','CRE') AND ACPD.RevisedCompletionDt>DATEADD(DD,2,ACPD.OriginalEnvisagCompletionDt) AND ACPD.RevisedCompletionDt>@Date and DPR.ParameterShortName='N')
				 OR (DPPC.ParameterName IN('Non Infra','CRE') AND ACPD.RevisedCompletionDt>DATEADD(DD,1,ACPD.OriginalEnvisagCompletionDt) AND ACPD.RevisedCompletionDt>@Date and DPR.ParameterShortName='N')
	        THEN 'PNPA from PUI Perspective' 

			WHEN (DPPC.ParameterName IN('Infra') AND ACPD.RevisedCompletionDt>DATEADD(DD,2,ACPD.OriginalEnvisagCompletionDt) AND ACPD.RevisedCompletionDt>@Date AND DPR.ParameterShortName='Y')
			     OR (DPPC.ParameterName IN('Infra') AND ACPD.RevisedCompletionDt>DATEADD(DD,3,ACPD.OriginalEnvisagCompletionDt) AND ACPD.RevisedCompletionDt>@Date AND DPR.ParameterShortName='Y')
                 OR (DPPC.ParameterName IN('Infra') AND ACPD.RevisedCompletionDt>DATEADD(DD,4,ACPD.OriginalEnvisagCompletionDt) AND ACPD.RevisedCompletionDt>@Date AND DPR.ParameterShortName='Y')
				 OR (DPPC.ParameterName IN('Non Infra','CRE') AND ACPD.RevisedCompletionDt>DATEADD(DD,1,ACPD.OriginalEnvisagCompletionDt) AND ACPD.RevisedCompletionDt>@Date AND DPR.ParameterShortName='Y')
				 OR (DPPC.ParameterName IN('Non Infra','CRE') AND ACPD.RevisedCompletionDt>DATEADD(DD,2,ACPD.OriginalEnvisagCompletionDt) AND ACPD.RevisedCompletionDt>@Date  AND DPR.ParameterShortName='n')
				 OR (DPPC.ParameterName IN('Non Infra','CRE') AND ACPD.RevisedCompletionDt>DATEADD(DD,2,ACPD.OriginalEnvisagCompletionDt) AND ACPD.RevisedCompletionDt>@Date AND DPR.ParameterShortName='Y')
	        THEN 'PNPA from PUI Perspective. Restructured from PUI perspective'
			END                                                               AS [PNPA Output]
      ,CONVERT(VARCHAR(20),ACPD.ActualCompletionDt,103)                       AS [PNPA Removal Date]


  FROM AdvAcProjectDetail ACPD

  INNER JOIN DimParameter DPPC                     ON ACPD.ProjectCatgAlt_Key=DPPC.ParameterAlt_Key
                                                      AND DPPC.EffectiveFromTimeKey<=@TimeKey 
												      AND DPPC.EffectiveToTimeKey>=@TimeKey												       
                                                      AND ACPD.EffectiveFromTimeKey<=@TimeKey 
												      AND ACPD.EffectiveToTimeKey>=@TimeKey
													  AND DPPC.DimParameterName='ProjectCategory'

  LEFT JOIN Pro.AccountCal_Hist  ACH              ON ACH.CustomerAcID=ACPD.AccountID
                                                     AND ACH.EffectiveFromTimeKey<=@TimeKey 
												     AND ACH.EffectiveToTimeKey>=@TimeKey	

  LEFT JOIN DimParameter DP                       ON ISNULL(ACPD.ProjectDelReason_AltKey,0)=DP.ParameterAlt_Key
                                                      AND DP.EffectiveFromTimeKey<=@TimeKey 
												      AND DP.EffectiveToTimeKey>=@TimeKey
												      AND DP.DimParameterName='ProdectDelReson'  
													  
													  
  LEFT JOIN DimParameter  DPR	                  ON ISNULL(ACPD.StandardRestruct_AltKey,0)=DPR.ParameterAlt_Key
                                                      AND DPR.EffectiveFromTimeKey<=@TimeKey 
												      AND DPR.EffectiveToTimeKey>=@TimeKey
												      AND DPR.DimParameterName='DimYesNo'
													  
 WHERE ACPD.CustomerID IN (SELECT * FROM[Split](@CustomerID,','))   
       AND DPPC.ParameterAlt_Key IN (SELECT * FROM[Split](@ProjectCategory,','))     
	   AND (ISNULL(ACPD.ProjectDelReason_AltKey,0) IN (SELECT * FROM[Split](@ProjectDelayReason,',')) OR @ProjectDelayReason='0') 
	   AND (ISNULL(ACPD.StandardRestruct_AltKey,0) IN (SELECT * FROM[Split](@StandardRestructured,',')) OR @StandardRestructured='0')
	      
  ORDER BY ACPD.[CustomerID]

 OPTION(RECOMPILE)

							
 
  
 
GO