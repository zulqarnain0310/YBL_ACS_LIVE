SET QUOTED_IDENTIFIER OFF

SET ANSI_NULLS ON
GO
CREATE Proc [dbo].[Rpt-20033]
 @TimeKey AS INT 
AS

----DECLARE
----@TimeKey AS  INT = 49999


--IF (OBJECT_ID('tempdb..#DATA') IS NOT NULL)
--					DROP TABLE #DATA

----SELECT * INTO #DATA FROM(
----SELECT 
----DISTINCT 
----CASE WHEN BusinessRule IN('RefPeriodOverdue','RefPeriodOverDrawn','RefPeriodIntService','RefPeriodStkStatement','RefPeriodReview','FINNONE91')
----      THEN 'Regular'
----	  WHEN BusinessRule IN('RefPeriodAgr366','FINNONE366')
----	  THEN 'Crop Loan'
----	  END [Type]
----,BusinessRule
----,RefValue

----FROM Pro.RefPeriod
----WHERE EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey
----      AND BusinessRule IN('RefPeriodOverdue','RefPeriodOverDrawn','RefPeriodIntService','RefPeriodStkStatement','RefPeriodReview','RefPeriodAgr366','FINNONE366','FINNONE91'
----	 ,'RefPeriodOverdueUpg',
----'RefPeriodIntServiceUpg',
----'RefPeriodOverDrawnUpg',
----'RefPeriodReviewUpg',
----'RefPeriodStkStatementUpg',
----'RefPeriodNoCreditUpg' 
----	  )

----)

----A PIVOT( MAX(RefValue)    FOR BusinessRule IN ([RefPeriodOverdue],[RefPeriodOverDrawn],[RefPeriodIntService],[RefPeriodStkStatement],[RefPeriodReview],[RefPeriodAgr366],[FINNONE366],[FINNONE91]))  AS B
	
-----Upgraded parameter include on Report 27-01-2023	
--SELECT * INTO #DATA FROM(

--SELECT 
--DISTINCT  
--CASE WHEN BusinessRule IN('RefPeriodOverdue','RefPeriodOverDrawn','RefPeriodIntService','RefPeriodStkStatement','RefPeriodReview','FINNONE91',  'RefPeriodOverdueUpg',
--'RefPeriodIntServiceUpg',
--'RefPeriodOverDrawnUpg',
--'RefPeriodReviewUpg',
--'RefPeriodStkStatementUpg' )
--      THEN 'Regular'
--	  WHEN BusinessRule IN('RefPeriodAgr366','FINNONE366')
--	  THEN 'Crop Loan'
--	  END [Type]
--,BusinessRule
--,RefValue

--FROM Pro.RefPeriod
--WHERE EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey
--      AND BusinessRule IN('RefPeriodOverdue','RefPeriodOverDrawn','RefPeriodIntService','RefPeriodStkStatement','RefPeriodReview','RefPeriodAgr366','FINNONE366','FINNONE91',
--	  'RefPeriodOverdueUpg',
--'RefPeriodIntServiceUpg',
--'RefPeriodOverDrawnUpg',
--'RefPeriodReviewUpg',
--'RefPeriodStkStatementUpg' ))A PIVOT( MAX(RefValue)    FOR BusinessRule IN ([RefPeriodOverdue],[RefPeriodOverDrawn],[RefPeriodIntService],[RefPeriodStkStatement],[RefPeriodReview],[RefPeriodAgr366],[FINNONE366],[FINNONE91],
--[RefPeriodOverdueUpg],
--[RefPeriodIntServiceUpg],
--[RefPeriodOverDrawnUpg],
--[RefPeriodReviewUpg],
--[RefPeriodStkStatementUpg]
-- ))  AS B												
--OPTION(RECOMPILE)

----update #DATA set RefPeriodIntService=91 where Type='Regular'

--DECLARE @Agr_RefPeriodStkStatement VARCHAR(1000)=(SELECT [RefPeriodStkStatement]  FROM #DATA WHERE [Type]='Regular')
--DECLARE @Agr_RefPeriodReview VARCHAR(1000)=(SELECT [RefPeriodReview]  FROM #DATA WHERE [Type]='Regular')
--DECLARE @Agr_RefPeriodOverdue VARCHAR(1000)=(SELECT [RefPeriodAgr366] FROM #DATA WHERE [Type]='Crop Loan')

--DECLARE @Agr_RefPeriodStkStatementUPG VARCHAR(1000)=(SELECT [RefPeriodStkStatementUpg]  FROM #DATA WHERE [Type]='Regular')
--DECLARE @Agr_RefPeriodReviewUPG VARCHAR(1000)=(SELECT [RefPeriodReviewUPG]  FROM #DATA WHERE [Type]='Regular')
--DECLARE @Agr_RefPeriodOverdueUPG VARCHAR(1000)=(SELECT [RefPeriodOverdueUPG] FROM #DATA WHERE [Type]='Regular')
--DECLARE @Agr_RefPeriodIntServiceUpg VARCHAR(1000)=(SELECT [RefPeriodIntServiceUpg]  FROM #DATA WHERE [Type]='Regular')
--DECLARE @Agr_RefPeriodOverDrawnUpg VARCHAR(1000)=(SELECT [RefPeriodOverDrawnUpg] FROM #DATA WHERE [Type]='Regular')
----select * from #DATA
--SELECT
-- 1                   SourceAlt_Key	
--,'FCR'               [Source System] 
--,[Type]
--,CASE WHEN [Type]='Regular' 
--      THEN [RefPeriodOverdue] 
--	  WHEN [Type]='Crop Loan' 
--      THEN [RefPeriodAgr366]
--	  END                          [Principal Overdue days]	
--,CASE WHEN [Type]='Regular' 
--      THEN [RefPeriodOverDrawn]
--	  WHEN [Type]='Crop Loan' 
--      THEN [RefPeriodAgr366]
--	  END                          [Principal Overdrawn days]	
--,CASE WHEN [Type]='Regular' 
--      THEN [RefPeriodIntService]
--	  WHEN [Type]='Crop Loan' 
--      THEN @Agr_RefPeriodOverdue
--	  END                          [Interest Overdue days]	
--,CASE WHEN [Type]='Regular'
--      THEN [RefPeriodStkStatement]
--      WHEN [Type] ='Crop Loan'
--      THEN @Agr_RefPeriodStkStatement
--	  END                          [Stock statement overdue days]	
--,CASE WHEN [Type]='Regular'
--      THEN [RefPeriodReview]
--      WHEN [Type] ='Crop Loan'
--      THEN @Agr_RefPeriodReview
--	  END                          [Review overdue days]	

--,CASE WHEN [Type]='Regular' 
--      THEN [RefPeriodOverdueupg] 
--	  WHEN [Type]='Crop Loan' 
--      THEN @Agr_RefPeriodOverdueUPG
--	  END                          [UPG_Principal Overdue days]	
--,CASE WHEN [Type]='Regular' 
--      THEN [RefPeriodOverDrawnUpg]
--	  WHEN [Type]='Crop Loan' 
--      THEN @Agr_RefPeriodOverDrawnUpg
--	  END                          [UPG_Principal Overdrawn days]	
--,CASE WHEN [Type]='Regular' 
--      THEN [RefPeriodIntServiceupg]
--	  WHEN [Type]='Crop Loan' 
--      THEN @Agr_RefPeriodIntServiceUpg
--	  END                          [UPG_Interest Overdue days]	
--,CASE WHEN [Type]='Regular'
--      THEN [RefPeriodStkStatementupg]
--      WHEN [Type] ='Crop Loan'
--      THEN @Agr_RefPeriodStkStatementupg
--	  END                          [UPG_Stock statement overdue days]	
--,CASE WHEN [Type]='Regular'
--      THEN [RefPeriodReviewUpg]
--      WHEN [Type] ='Crop Loan'
--      THEN @Agr_RefPeriodReviewUPG
--	  END                          [UPG_Review overdue days]	

-- FROM #DATA


--UNION ALL

--SELECT
-- 2                   SourceAlt_Key	
--,'FCC'               [Source System] 
--,[Type]
--,CASE WHEN [Type]='Regular' 
--      THEN [RefPeriodOverdue] 
--	  WHEN [Type]='Crop Loan' 
--      THEN [RefPeriodAgr366]
--	  END                          [Principal Overdue days]	
--,CASE WHEN [Type]='Regular' 
--      THEN [RefPeriodOverDrawn]
--	  WHEN [Type]='Crop Loan' 
--      THEN [RefPeriodAgr366]
--	  END                          [Principal Overdrawn days]	
--,CASE WHEN [Type]='Regular' 
--      THEN [RefPeriodIntService]
--	  WHEN [Type]='Crop Loan' 
--      THEN @Agr_RefPeriodOverdue
--	  END                          [Interest Overdue days]	
--,CASE WHEN [Type]='Regular'
--      THEN [RefPeriodStkStatement]
--      WHEN [Type] ='Crop Loan'
--      THEN @Agr_RefPeriodStkStatement
--	  END                          [Stock statement overdue days]	
--,CASE WHEN [Type]='Regular'
--      THEN [RefPeriodReview]
--      WHEN [Type] ='Crop Loan'
--      THEN @Agr_RefPeriodReview
--	  END                          [Review overdue days]	
--,CASE WHEN [Type]='Regular' 
--      THEN [RefPeriodOverdueupg] 
--	  WHEN [Type]='Crop Loan' 
--      THEN @Agr_RefPeriodOverdueUPG
--	  END                          [UPG_Principal Overdue days]	
--,CASE WHEN [Type]='Regular' 
--      THEN [RefPeriodOverDrawnUpg]
--	  WHEN [Type]='Crop Loan' 
--      THEN @Agr_RefPeriodOverDrawnUpg
--	  END                          [UPG_Principal Overdrawn days]	
--,CASE WHEN [Type]='Regular' 
--      THEN [RefPeriodIntServiceupg]
--	  WHEN [Type]='Crop Loan' 
--      THEN @Agr_RefPeriodIntServiceUpg
--	  END                          [UPG_Interest Overdue days]	
--,CASE WHEN [Type]='Regular'
--      THEN [RefPeriodStkStatementupg]
--      WHEN [Type] ='Crop Loan'
--      THEN @Agr_RefPeriodStkStatementupg
--	  END                          [UPG_Stock statement overdue days]	
--,CASE WHEN [Type]='Regular'
--      THEN [RefPeriodReviewUpg]
--      WHEN [Type] ='Crop Loan'
--      THEN @Agr_RefPeriodReviewUPG
--	  END                          [UPG_Review overdue days]	



--FROM #DATA

--UNION ALL

--SELECT
-- 3                       SourceAlt_Key	
--,'FINNONE'               [Source System] 
--,[Type]
--,CASE WHEN [Type]='Regular' 
--      THEN [FINNONE91] 
--	  WHEN [Type]='Crop Loan' 
--      THEN [FINNONE366]
--	  END                      [Principal Overdue days]	
--,'NA'                          [Principal Overdrawn days]	
--,'NA'                          [Interest Overdue days]	
--,'NA'                          [Stock statement overdue days]	
--,'NA'                          [Review overdue days]
--,CASE WHEN [Type]='Regular' 
--      THEN [RefPeriodOverdueUpg]
--	  ELSE @Agr_RefPeriodOverdueUPG
--	  END    as [UPG_Principal Overdue days]
--, 'NA' as [UPG_Principal Overdrawn days]
--, 'NA' as [UPG_Interest Overdue days]	
--, 'NA' as [UPG_Stock statement overdue days]	
--, 'NA' as [UPG_Review overdue days]	

--FROM #DATA

--UNION ALL

--SELECT
-- 4                        SourceAlt_Key	
--,'GANASEVA'               [Source System] 
--,[Type]
--,CASE WHEN [Type]='Regular' 
--      THEN [FINNONE91] 
--	  WHEN [Type]='Crop Loan' 
--      THEN [FINNONE366]
--	  END                      [Principal Overdue days]	
--,'NA'                          [Principal Overdrawn days]	
--,'NA'                          [Interest Overdue days]	
--,'NA'                          [Stock statement overdue days]	
--,'NA'                          [Review overdue days]
--,CASE WHEN [Type]='Regular' 
--      THEN [RefPeriodOverdueUpg]
--	  ELSE @Agr_RefPeriodOverdueUPG
--	  END    as [UPG_Principal Overdue days]	
--, 'NA' as [UPG_Principal Overdrawn days]
--, 'NA' as [UPG_Interest Overdue days]	
--, 'NA' as [UPG_Stock statement overdue days]	
--, 'NA' as [UPG_Review overdue days]		

--FROM #DATA

--UNION ALL

--SELECT
-- 5                   SourceAlt_Key	
--,'VISIONPLUS'        [Source System] 
--,[Type]
--,CASE WHEN [Type]='Regular' 
--      THEN [FINNONE91] 
--	  ELSE 'NA'
--	  END                          [Principal Overdue days]	
--,'NA'                          [Principal Overdrawn days]	
--,'NA'                          [Interest Overdue days]	
--,'NA'                          [Stock statement overdue days]	
--,'NA'                          [Review overdue days]
--,CASE WHEN [Type]='Regular' 
--      THEN [RefPeriodOverdueUpg]
--	  ELSE 'NA'
--	  END    as [UPG_Principal Overdue days]	
--, 'NA' as [UPG_Principal Overdrawn days]
--, 'NA' as [UPG_Interest Overdue days]	
--, 'NA' as [UPG_Stock statement overdue days]	
--, 'NA' as [UPG_Review overdue days]		

--FROM #DATA

--UNION ALL

--SELECT
-- 6                    SourceAlt_Key	
--,'ECBF'               [Source System] 
--,[Type]
--,CASE WHEN [Type]='Regular' 
--      THEN [RefPeriodOverdue] 
--	  WHEN [Type]='Crop Loan' 
--      THEN [RefPeriodAgr366]
--	  END                      [Principal Overdue days]                        	
--,'NA'                          [Principal Overdrawn days]	
--,'NA'                          [Interest Overdue days]	
--,CASE WHEN [Type]='Regular'
--      THEN [RefPeriodStkStatement]
--      WHEN [Type] ='Crop Loan'
--      THEN @Agr_RefPeriodStkStatement
--	  END                      [Stock statement overdue days]	
--,CASE WHEN [Type]='Regular'
--      THEN [RefPeriodReview]
--      WHEN [Type] ='Crop Loan'
--      THEN @Agr_RefPeriodReview
--	  END             [Review overdue days]	
--,CASE WHEN [Type]='Regular' 
--      THEN [RefPeriodOverdueupg] 
--	  WHEN [Type]='Crop Loan' 
--      THEN @Agr_RefPeriodOverdueUPG
--	  END                          [UPG_Principal Overdue days]	
--, 'NA' as [UPG_Principal Overdrawn days]
--, 'NA' as [UPG_Interest Overdue days]	
--,CASE WHEN [Type]='Regular'
--      THEN [RefPeriodStkStatementupg]
--      WHEN [Type] ='Crop Loan'
--      THEN @Agr_RefPeriodStkStatementupg
--	  END                          [UPG_Stock statement overdue days]	
--,CASE WHEN [Type]='Regular'
--      THEN [RefPeriodReviewUpg]
--      WHEN [Type] ='Crop Loan'
--      THEN @Agr_RefPeriodReviewUPG
--	  END                          [UPG_Review overdue days]	


--FROM #DATA

--UNION ALL

--SELECT
-- 7                   SourceAlt_Key	
--,'EIFS'               [Source System] 
--,[Type]
--,CASE WHEN [Type]='Regular' 
--      THEN [RefPeriodOverdue] 
--	  ELSE 'NA'
--	  END                          [Principal Overdue days]	
--,'NA'                              [Principal Overdrawn days]	
--,'NA'                              [Interest Overdue days]	
--,CASE WHEN [Type]='Regular'
--      THEN [RefPeriodStkStatement]
--	  ELSE 'NA'
--	  END                          [Stock statement overdue days]	
--,CASE WHEN [Type]='Regular'
--      THEN [RefPeriodReview]
--	  ELSE 'NA'
--	  END                          [Review overdue days]
-- ,CASE WHEN [Type]='Regular' 
--      THEN [RefPeriodOverdueUpg]
--	  ELSE 'NA'
--	  END    as [UPG_Principal Overdue days]
--, 'NA' as [UPG_Principal Overdrawn days]
--, 'NA' as [UPG_Interest Overdue days]	
--,CASE WHEN [Type]='Regular'
--      THEN [RefPeriodStkStatementUpg]
--	  ELSE 'NA'
--	  END  as [UPG_Stock statement overdue days]	
--, CASE WHEN [Type]='Regular'
--      THEN [RefPeriodReviewupg]
--	  ELSE 'NA'
--	  END   as [UPG_Review overdue days]		

--FROM #DATA

--UNION ALL

--SELECT
-- 8                    SourceAlt_Key	
--,'ECFS'               [Source System] 
--,[Type]
--,CASE WHEN [Type]='Regular' 
--      THEN [RefPeriodOverdue] 
--	  ELSE 'NA'
--	  END                          [Principal Overdue days]	
--,'NA'                              [Principal Overdrawn days]	
--,'NA'                              [Interest Overdue days]	
--,CASE WHEN [Type]='Regular'
--      THEN [RefPeriodStkStatement]
--	  ELSE 'NA'
--	  END                          [Stock statement overdue days]	
--,CASE WHEN [Type]='Regular'
--      THEN [RefPeriodReview]
--	  ELSE 'NA'
--	  END                          [Review overdue days]
--,CASE WHEN [Type]='Regular' 
--      THEN [RefPeriodOverdueUpg]
--	  ELSE 'NA'
--	  END    as [UPG_Principal Overdue days]
--, 'NA' as [UPG_Principal Overdrawn days]
--, 'NA' as [UPG_Interest Overdue days]	
--,CASE WHEN [Type]='Regular'
--      THEN [RefPeriodStkStatementUpg]
--	  ELSE 'NA'
--	  END  as [UPG_Stock statement overdue days]	
--, CASE WHEN [Type]='Regular'
--      THEN [RefPeriodReviewupg]
--	  ELSE 'NA'
--	  END   as [UPG_Review overdue days]		

--FROM #DATA

--UNION ALL


--SELECT
-- 9                      SourceAlt_Key	
--,'CREDAVENUE_DA'        [Source System] 
--,[Type]
----,CASE WHEN [Type]='Regular' 
----      THEN [RefPeriodOverdue] 
----	  ELSE 'NA'
----	  END                          [Principal Overdue days]	

----AMar 20240517 add Kcc in Cred
--,CASE WHEN [Type]='Regular' 
--      THEN [RefPeriodOverdue] 
--	  WHEN [Type]='Crop Loan' 
--      THEN [RefPeriodAgr366]
--	  END                          [Principal Overdue days]	
--,'NA'                          [Principal Overdrawn days]	
--,'NA'                          [Interest Overdue days]	
--,'NA'                          [Stock statement overdue days]	
--,'NA'                          [Review overdue days]

-----AMAR 2024-05-17 added KCC
----,CASE WHEN [Type]='Regular' 
----      THEN [RefPeriodOverdueUpg]
----	  ELSE 'NA'
----	  END    as [UPG_Principal Overdue days]
	  
--	  ,CASE WHEN [Type]='Regular' 
--      THEN [RefPeriodOverdueupg] 
--	  WHEN [Type]='Crop Loan' 
--      THEN @Agr_RefPeriodOverdueUPG
--	  END                          [UPG_Principal Overdue days]	
	  	
--, 'NA' as [UPG_Principal Overdrawn days]
--, 'NA' as [UPG_Interest Overdue days]	
--, 'NA' as [UPG_Stock statement overdue days]	
--, 'NA' as [UPG_Review overdue days]		

--FROM #DATA

--UNION ALL

--SELECT
-- 10                    SourceAlt_Key	
--,'GOLD'               [Source System] 
--,[Type]
--,'NA'                              [Principal Overdue days]	
--,'NA'                              [Principal Overdrawn days]	
--,'NA'                              [Interest Overdue days]	
--,'NA'                         [Stock statement overdue days]	
--,CASE WHEN [Type]='Regular'
--      THEN [RefPeriodReview]
--	  ELSE 'NA'
--	  END                          [Review overdue days]
--,'NA'as [UPG_Principal Overdue days]	
--, 'NA' as [UPG_Principal Overdrawn days]
--, 'NA' as [UPG_Interest Overdue days]	
--, 'NA' as [UPG_Stock statement overdue days]	
--, CASE WHEN [Type]='Regular'
--      THEN [RefPeriodReviewUPG]
--	  ELSE 'NA'
--	  END    as [UPG_Review overdue days]		

--FROM #DATA

--UNION ALL

--SELECT
-- 11                   SourceAlt_Key	
--,'MUREX'               [Source System] 
--,[Type]
--,'NA'                              [Principal Overdue days]	
--,'NA'                              [Principal Overdrawn days]	
--,'NA'                              [Interest Overdue days]	
--,'NA'                         [Stock statement overdue days]	
--,CASE WHEN [Type]='Regular'
--      THEN [RefPeriodReview]
--	  ELSE 'NA'
--	  END                          [Review overdue days]
--,'NA'as [UPG_Principal Overdue days]	
--, 'NA' as [UPG_Principal Overdrawn days]
--, 'NA' as [UPG_Interest Overdue days]	
--, 'NA' as [UPG_Stock statement overdue days]	
--, CASE WHEN [Type]='Regular'
--      THEN [RefPeriodReviewUPG]
--	  ELSE 'NA'
--	  END    as [UPG_Review overdue days]  	

--FROM #DATA

----------12/*'SFIN' SmartFin  15102023*/---------------------------------
--UNION ALL

--SELECT
-- 12                    SourceAlt_Key	
--,'SFIN'               [Source System] 
--,[Type]
--,CASE WHEN [Type]='Regular' 
--      THEN [RefPeriodOverdue] 
--	  ELSE 'NA'
--	  END                          [Principal Overdue days]	
--,'NA'                              [Principal Overdrawn days]	
--,'NA'                              [Interest Overdue days]	
--,CASE WHEN [Type]='Regular'
--      THEN [RefPeriodStkStatement]
--	  ELSE 'NA'
--	  END                          [Stock statement overdue days]	
--,CASE WHEN [Type]='Regular'
--      THEN [RefPeriodReview]
--	  ELSE 'NA'
--	  END                          [Review overdue days]
--,CASE WHEN [Type]='Regular' 
--      THEN [RefPeriodOverdueUpg]
--	  ELSE 'NA'
--	  END    as [UPG_Principal Overdue days]
--, 'NA' as [UPG_Principal Overdrawn days]
--, 'NA' as [UPG_Interest Overdue days]	
--,CASE WHEN [Type]='Regular'
--      THEN [RefPeriodStkStatementUpg]
--	  ELSE 'NA'
--	  END  as [UPG_Stock statement overdue days]	
--, CASE WHEN [Type]='Regular'
--      THEN [RefPeriodReviewupg]
--	  ELSE 'NA'
--	  END   as [UPG_Review overdue days]		

--FROM #DATA

----------12/*'SFIN' SmartFin  15102023*/---------------------------------

--ORDER BY SourceAlt_Key,[Type] DESC





IF (OBJECT_ID('tempdb..#DATA') IS NOT NULL)
					DROP TABLE #DATA


---Upgraded parameter include on Report 27-01-2023	
SELECT * INTO #DATA FROM(

SELECT 
DISTINCT  
CASE WHEN BusinessRule IN('RefPeriodOverdue','RefPeriodOverDrawn','RefPeriodIntService','RefPeriodStkStatement','RefPeriodReview','FINNONE91',  'RefPeriodOverdueUpg',
'RefPeriodIntServiceUpg',
'RefPeriodOverDrawnUpg',
'RefPeriodReviewUpg',
'RefPeriodStkStatementUpg' )
      THEN 'Regular'
	  WHEN BusinessRule IN('RefPeriodAgr366','FINNONE366')
	  THEN 'Crop Loan'
	  END [Type]
,BusinessRule
,RefValue

FROM Pro.RefPeriod
WHERE EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey
      AND BusinessRule IN('RefPeriodOverdue','RefPeriodOverDrawn','RefPeriodIntService','RefPeriodStkStatement','RefPeriodReview','RefPeriodAgr366','FINNONE366','FINNONE91',
	  'RefPeriodOverdueUpg',
'RefPeriodIntServiceUpg',
'RefPeriodOverDrawnUpg',
'RefPeriodReviewUpg',
'RefPeriodStkStatementUpg' ))A PIVOT( MAX(RefValue)    FOR BusinessRule IN ([RefPeriodOverdue],[RefPeriodOverDrawn],[RefPeriodIntService],[RefPeriodStkStatement],[RefPeriodReview],[RefPeriodAgr366],[FINNONE366],[FINNONE91],
[RefPeriodOverdueUpg],
[RefPeriodIntServiceUpg],
[RefPeriodOverDrawnUpg],
[RefPeriodReviewUpg],
[RefPeriodStkStatementUpg]
 ))  AS B												
OPTION(RECOMPILE)

--update #DATA set RefPeriodIntService=91 where Type='Regular'

DECLARE @Agr_RefPeriodStkStatement VARCHAR(1000)=(SELECT [RefPeriodStkStatement]  FROM #DATA WHERE [Type]='Regular')
DECLARE @Agr_RefPeriodReview VARCHAR(1000)=(SELECT [RefPeriodReview]  FROM #DATA WHERE [Type]='Regular')
DECLARE @Agr_RefPeriodOverdue VARCHAR(1000)=(SELECT [RefPeriodAgr366] FROM #DATA WHERE [Type]='Crop Loan')

DECLARE @Agr_RefPeriodStkStatementUPG VARCHAR(1000)=(SELECT [RefPeriodStkStatementUpg]  FROM #DATA WHERE [Type]='Regular')
DECLARE @Agr_RefPeriodReviewUPG VARCHAR(1000)=(SELECT [RefPeriodReviewUPG]  FROM #DATA WHERE [Type]='Regular')
DECLARE @Agr_RefPeriodOverdueUPG VARCHAR(1000)=(SELECT [RefPeriodOverdueUPG] FROM #DATA WHERE [Type]='Regular')
DECLARE @Agr_RefPeriodIntServiceUpg VARCHAR(1000)=(SELECT [RefPeriodIntServiceUpg]  FROM #DATA WHERE [Type]='Regular')
DECLARE @Agr_RefPeriodOverDrawnUpg VARCHAR(1000)=(SELECT [RefPeriodOverDrawnUpg] FROM #DATA WHERE [Type]='Regular')
--select * from #DATA
SELECT
 1                   SourceAlt_Key	
,'FCR'               [Source System] 
,[Type]
,CASE WHEN [Type]='Regular' 
      THEN [RefPeriodOverdue] 
	  WHEN [Type]='Crop Loan' 
      THEN [RefPeriodAgr366]
	  END                          [Principal Overdue days]	
,CASE WHEN [Type]='Regular' 
      THEN [RefPeriodOverDrawn]
	  WHEN [Type]='Crop Loan' 
      THEN [RefPeriodAgr366]
	  END                          [Principal Overdrawn days]	
,CASE WHEN [Type]='Regular' 
      THEN [RefPeriodIntService]
	  WHEN [Type]='Crop Loan' 
      THEN @Agr_RefPeriodOverdue
	  END                          [Interest Overdue days]	
,CASE WHEN [Type]='Regular'
      THEN [RefPeriodStkStatement]
      WHEN [Type] ='Crop Loan'
      THEN @Agr_RefPeriodStkStatement
	  END                          [Stock statement overdue days]	
,CASE WHEN [Type]='Regular'
      THEN [RefPeriodReview]
      WHEN [Type] ='Crop Loan'
      THEN @Agr_RefPeriodReview
	  END                          [Review overdue days]	

,CASE WHEN [Type]='Regular' 
      THEN [RefPeriodOverdueupg] 
	  WHEN [Type]='Crop Loan' 
      THEN @Agr_RefPeriodOverdueUPG
	  END                          [UPG_Principal Overdue days]	
,CASE WHEN [Type]='Regular' 
      THEN [RefPeriodOverDrawnUpg]
	  WHEN [Type]='Crop Loan' 
      THEN @Agr_RefPeriodOverDrawnUpg
	  END                          [UPG_Principal Overdrawn days]	
,CASE WHEN [Type]='Regular' 
      THEN [RefPeriodIntServiceupg]
	  WHEN [Type]='Crop Loan' 
      THEN @Agr_RefPeriodIntServiceUpg
	  END                          [UPG_Interest Overdue days]	
,CASE WHEN [Type]='Regular'
      THEN [RefPeriodStkStatementupg]
      WHEN [Type] ='Crop Loan'
      THEN @Agr_RefPeriodStkStatementupg
	  END                          [UPG_Stock statement overdue days]	
,CASE WHEN [Type]='Regular'
      THEN [RefPeriodReviewUpg]
      WHEN [Type] ='Crop Loan'
      THEN @Agr_RefPeriodReviewUPG
	  END                          [UPG_Review overdue days]	

 FROM #DATA


UNION ALL

SELECT
 2                   SourceAlt_Key	
,'FCC'               [Source System] 
,[Type]
,CASE WHEN [Type]='Regular' 
      THEN [RefPeriodOverdue] 
	  WHEN [Type]='Crop Loan' 
      THEN [RefPeriodAgr366]
	  END                          [Principal Overdue days]	
,CASE WHEN [Type]='Regular' 
     THEN 'NA' -- [RefPeriodOverDrawn]
	 WHEN [Type]='Crop Loan' 
     THEN 'NA' -- [RefPeriodAgr366]
 
	  END                          [Principal Overdrawn days]	
,CASE WHEN [Type]='Regular' 
      THEN [RefPeriodIntService]
	  WHEN [Type]='Crop Loan' 
      THEN @Agr_RefPeriodOverdue
	  END                          [Interest Overdue days]	
,CASE WHEN [Type]='Regular'
      THEN [RefPeriodStkStatement]
      WHEN [Type] ='Crop Loan'
      THEN @Agr_RefPeriodStkStatement
	  END                          [Stock statement overdue days]	
,CASE WHEN [Type]='Regular'
      THEN [RefPeriodReview]
      WHEN [Type] ='Crop Loan'
      THEN @Agr_RefPeriodReview
	  END                          [Review overdue days]	
,CASE WHEN [Type]='Regular' 
      THEN [RefPeriodOverdueupg] 
	  WHEN [Type]='Crop Loan' 
      THEN @Agr_RefPeriodOverdueUPG
	  END                          [UPG_Principal Overdue days]	
,CASE WHEN [Type]='Regular' 
      THEN  'NA' --[RefPeriodOverDrawnUpg]
	  WHEN [Type]='Crop Loan' 
      THEN 'NA' --@Agr_RefPeriodOverDrawnUpg
	    
	  END                          [UPG_Principal Overdrawn days]	
,CASE WHEN [Type]='Regular' 
      THEN [RefPeriodIntServiceupg]
	  WHEN [Type]='Crop Loan' 
      THEN @Agr_RefPeriodIntServiceUpg
	  END                          [UPG_Interest Overdue days]	
,CASE WHEN [Type]='Regular'
      THEN [RefPeriodStkStatementupg]
      WHEN [Type] ='Crop Loan'
      THEN @Agr_RefPeriodStkStatementupg
	  END                          [UPG_Stock statement overdue days]	
,CASE WHEN [Type]='Regular'
      THEN [RefPeriodReviewUpg]
      WHEN [Type] ='Crop Loan'
      THEN @Agr_RefPeriodReviewUPG
	  END                          [UPG_Review overdue days]	



FROM #DATA

UNION ALL

SELECT
 3                       SourceAlt_Key	
,'FINNONE'               [Source System] 
,[Type]
,CASE WHEN [Type]='Regular' 
      THEN [FINNONE91] 
	  WHEN [Type]='Crop Loan' 
      THEN [FINNONE366]
	  END                      [Principal Overdue days]	
,'NA'                          [Principal Overdrawn days]	
--,'NA'                          [Interest Overdue days]	
,CASE WHEN [Type]='Regular' 
      THEN [FINNONE91] 
	  WHEN [Type]='Crop Loan' 
      THEN [FINNONE366]
	  END                           [Interest Overdue days]	

,'NA'                          [Stock statement overdue days]	
,'NA'                          [Review overdue days]
,CASE WHEN [Type]='Regular' 
      THEN [RefPeriodOverdueUpg]
	  ELSE @Agr_RefPeriodOverdueUPG
	  END    as [UPG_Principal Overdue days]
, 'NA' as [UPG_Principal Overdrawn days]
--, 'NA' as [UPG_Interest Overdue days]
, CASE WHEN [Type]='Regular' 
      THEN [RefPeriodOverdueUpg]
	  ELSE @Agr_RefPeriodOverdueUPG
	  END    as [UPG_Interest Overdue days]	
, 'NA' as [UPG_Stock statement overdue days]	
, 'NA' as [UPG_Review overdue days]	

FROM #DATA

UNION ALL

SELECT
 4                        SourceAlt_Key	
,'GANASEVA'               [Source System] 
,[Type]
,CASE WHEN [Type]='Regular' 
      THEN [FINNONE91] 
	  WHEN [Type]='Crop Loan' 
      THEN [FINNONE366]
	  END                      [Principal Overdue days]	
,'NA'                          [Principal Overdrawn days]	
--,'NA'                          [Interest Overdue days]	
,CASE WHEN [Type]='Regular' 
      THEN [FINNONE91] 
	  WHEN [Type]='Crop Loan' 
      THEN [FINNONE366]
	  END                       [Interest Overdue days]	
,'NA'                          [Stock statement overdue days]	
,'NA'                          [Review overdue days]
,CASE WHEN [Type]='Regular' 
      THEN [RefPeriodOverdueUpg]
	  ELSE @Agr_RefPeriodOverdueUPG
	  END    as [UPG_Principal Overdue days]	
, 'NA' as [UPG_Principal Overdrawn days]
--, 'NA' as [UPG_Interest Overdue days]
,CASE WHEN [Type]='Regular' 
      THEN [RefPeriodOverdueUpg]
	  ELSE @Agr_RefPeriodOverdueUPG
	  END    as [UPG_Interest Overdue days]	
, 'NA' as [UPG_Stock statement overdue days]	
, 'NA' as [UPG_Review overdue days]		

FROM #DATA

UNION ALL

SELECT
 5                   SourceAlt_Key	
,'VISIONPLUS'        [Source System] 
,[Type]
,CASE WHEN [Type]='Regular' 
      THEN [FINNONE91] 
	  ELSE 'NA'
	  END                          [Principal Overdue days]	
,'NA'                          [Principal Overdrawn days]	
--,'NA'                          [Interest Overdue days]	
,CASE WHEN [Type]='Regular' 
      THEN [FINNONE91] 
	  ELSE 'NA'
	  END                            [Interest Overdue days]	
,'NA'                          [Stock statement overdue days]	
,'NA'                          [Review overdue days]
,CASE WHEN [Type]='Regular' 
      THEN [RefPeriodOverdueUpg]
	  ELSE 'NA'
	  END    as [UPG_Principal Overdue days]	
, 'NA' as [UPG_Principal Overdrawn days]
--, 'NA' as [UPG_Interest Overdue days]	
,CASE WHEN [Type]='Regular' 
      THEN [RefPeriodOverdueUpg]
	  ELSE 'NA'
	  END    as [UPG_Interest Overdue days]	
, 'NA' as [UPG_Stock statement overdue days]	
, 'NA' as [UPG_Review overdue days]		

FROM #DATA

UNION ALL

SELECT
 6                    SourceAlt_Key	
,'ECBF'               [Source System] 
,[Type]
,CASE WHEN [Type]='Regular' 
      THEN [RefPeriodOverdue] 
	  WHEN [Type]='Crop Loan' 
      THEN [RefPeriodAgr366]
	  END                      [Principal Overdue days]                        	
,'NA'                          [Principal Overdrawn days]	
--,'NA'                          [Interest Overdue days]
,CASE WHEN [Type]='Regular' 
      THEN [RefPeriodOverdue] 
	  WHEN [Type]='Crop Loan' 
      THEN [RefPeriodAgr366]
	  END                      [Interest Overdue days]	
,CASE WHEN [Type]='Regular'
      THEN [RefPeriodStkStatement]
      WHEN [Type] ='Crop Loan'
      THEN @Agr_RefPeriodStkStatement
	  END                      [Stock statement overdue days]	
,CASE WHEN [Type]='Regular'
      THEN [RefPeriodReview]
      WHEN [Type] ='Crop Loan'
      THEN @Agr_RefPeriodReview
	  END             [Review overdue days]	
,CASE WHEN [Type]='Regular' 
      THEN [RefPeriodOverdueupg] 
	  WHEN [Type]='Crop Loan' 
      THEN @Agr_RefPeriodOverdueUPG
	  END                          [UPG_Principal Overdue days]	
, 'NA' as [UPG_Principal Overdrawn days]

--, 'NA' as [UPG_Interest Overdue days]
,CASE WHEN [Type]='Regular' 
      THEN [RefPeriodOverdueupg] 
	  WHEN [Type]='Crop Loan' 
      THEN @Agr_RefPeriodOverdueUPG
	  END                         [UPG_Interest Overdue days]
,CASE WHEN [Type]='Regular'
      THEN [RefPeriodStkStatementupg]
      WHEN [Type] ='Crop Loan'
      THEN @Agr_RefPeriodStkStatementupg
	  END                          [UPG_Stock statement overdue days]	
,CASE WHEN [Type]='Regular'
      THEN [RefPeriodReviewUpg]
      WHEN [Type] ='Crop Loan'
      THEN @Agr_RefPeriodReviewUPG
	  END                          [UPG_Review overdue days]	


FROM #DATA

UNION ALL

SELECT
 7                   SourceAlt_Key	
,'EIFS'               [Source System] 
,[Type]
,CASE WHEN [Type]='Regular' 
      THEN [RefPeriodOverdue] 
	  ELSE 'NA'
	  END                          [Principal Overdue days]	
,'NA'                              [Principal Overdrawn days]	
--,'NA'                              [Interest Overdue days]	
,CASE WHEN [Type]='Regular' 
      THEN [RefPeriodOverdue] 
	  ELSE 'NA'
	  END                         [Interest Overdue days]	
,CASE WHEN [Type]='Regular'
      THEN [RefPeriodStkStatement]
	  ELSE 'NA'
	  END                          [Stock statement overdue days]	
,CASE WHEN [Type]='Regular'
      THEN [RefPeriodReview]
	  ELSE 'NA'
	  END                          [Review overdue days]
 ,CASE WHEN [Type]='Regular' 
      THEN [RefPeriodOverdueUpg]
	  ELSE 'NA'
	  END    as [UPG_Principal Overdue days]
, 'NA' as [UPG_Principal Overdrawn days]

--, 'NA' as [UPG_Interest Overdue days]
 ,CASE WHEN [Type]='Regular' 
      THEN [RefPeriodOverdueUpg]
	  ELSE 'NA'
	  END    as [UPG_Interest Overdue days]
,CASE WHEN [Type]='Regular'
      THEN [RefPeriodStkStatementUpg]
	  ELSE 'NA'
	  END  as [UPG_Stock statement overdue days]	
, CASE WHEN [Type]='Regular'
      THEN [RefPeriodReviewupg]
	  ELSE 'NA'
	  END   as [UPG_Review overdue days]		

FROM #DATA

UNION ALL

SELECT
 8                    SourceAlt_Key	
,'ECFS'               [Source System] 
,[Type]
,CASE WHEN [Type]='Regular' 
      THEN [RefPeriodOverdue] 
	  ELSE 'NA'
	  END                          [Principal Overdue days]	
,'NA'                              [Principal Overdrawn days]	
--,'NA'                              [Interest Overdue days]
,CASE WHEN [Type]='Regular' 
      THEN [RefPeriodOverdue] 
	  ELSE 'NA'
	  END                        [Interest Overdue days]	
,CASE WHEN [Type]='Regular'
      THEN [RefPeriodStkStatement]
	  ELSE 'NA'
	  END                          [Stock statement overdue days]	
,CASE WHEN [Type]='Regular'
      THEN [RefPeriodReview]
	  ELSE 'NA'
	  END                          [Review overdue days]
,CASE WHEN [Type]='Regular' 
      THEN [RefPeriodOverdueUpg]
	  ELSE 'NA'
	  END    as [UPG_Principal Overdue days]
, 'NA' as [UPG_Principal Overdrawn days]
--, 'NA' as [UPG_Interest Overdue days]
,CASE WHEN [Type]='Regular' 
      THEN [RefPeriodOverdueUpg]
	  ELSE 'NA'
	  END  	[UPG_Interest Overdue days]
,CASE WHEN [Type]='Regular'
      THEN [RefPeriodStkStatementUpg]
	  ELSE 'NA'
	  END  as [UPG_Stock statement overdue days]	
, CASE WHEN [Type]='Regular'
      THEN [RefPeriodReviewupg]
	  ELSE 'NA'
	  END   as [UPG_Review overdue days]		

FROM #DATA

UNION ALL


SELECT
 9                      SourceAlt_Key	
,'CREDAVENUE_DA'        [Source System] 
,[Type]
--,CASE WHEN [Type]='Regular' 
--      THEN [RefPeriodOverdue] 
--	  ELSE 'NA'
--	  END                          [Principal Overdue days]	

--AMar 20240517 add Kcc in Cred
,CASE WHEN [Type]='Regular' 
      THEN [RefPeriodOverdue] 
	  WHEN [Type]='Crop Loan' 
      THEN [RefPeriodAgr366]
	  END                          [Principal Overdue days]	
,'NA'                          [Principal Overdrawn days]	
--,'NA'                          [Interest Overdue days]
,CASE WHEN [Type]='Regular' 
      THEN [RefPeriodOverdue] 
	  WHEN [Type]='Crop Loan' 
      THEN [RefPeriodAgr366]
	  END 	 [Interest Overdue days]
,'NA'                          [Stock statement overdue days]	
,'NA'                          [Review overdue days]

---AMAR 2024-05-17 added KCC
--,CASE WHEN [Type]='Regular' 
--      THEN [RefPeriodOverdueUpg]
--	  ELSE 'NA'
--	  END    as [UPG_Principal Overdue days]
	  
	  ,CASE WHEN [Type]='Regular' 
      THEN [RefPeriodOverdueupg] 
	  WHEN [Type]='Crop Loan' 
      THEN @Agr_RefPeriodOverdueUPG
	  END                          [UPG_Principal Overdue days]	
	  	
, 'NA' as [UPG_Principal Overdrawn days]
--, 'NA' as [UPG_Interest Overdue days]
  ,CASE WHEN [Type]='Regular' 
      THEN [RefPeriodOverdueupg] 
	  WHEN [Type]='Crop Loan' 
      THEN @Agr_RefPeriodOverdueUPG
	  END    [UPG_Interest Overdue days]	
, 'NA' as [UPG_Stock statement overdue days]	
, 'NA' as [UPG_Review overdue days]		

FROM #DATA

UNION ALL

SELECT
 10                    SourceAlt_Key	
,'GOLD'               [Source System] 
,[Type]
,'NA'                              [Principal Overdue days]	
,'NA'                              [Principal Overdrawn days]	
,'NA'                              [Interest Overdue days]	
,'NA'                         [Stock statement overdue days]	
,CASE WHEN [Type]='Regular'
      THEN [RefPeriodReview]
	  ELSE 'NA'
	  END                          [Review overdue days]
,'NA'as [UPG_Principal Overdue days]	
, 'NA' as [UPG_Principal Overdrawn days]
, 'NA' as [UPG_Interest Overdue days]	
, 'NA' as [UPG_Stock statement overdue days]	
, CASE WHEN [Type]='Regular'
      THEN [RefPeriodReviewUPG]
	  ELSE 'NA'
	  END    as [UPG_Review overdue days]		

FROM #DATA

UNION ALL

SELECT
 11                   SourceAlt_Key	
,'MUREX'               [Source System] 
,[Type]
,'NA'                              [Principal Overdue days]	
,'NA'                              [Principal Overdrawn days]	
,'NA'                              [Interest Overdue days]	
,'NA'                         [Stock statement overdue days]	
,CASE WHEN [Type]='Regular'
      THEN [RefPeriodReview]
	  ELSE 'NA'
	  END                          [Review overdue days]
,'NA'as [UPG_Principal Overdue days]	
, 'NA' as [UPG_Principal Overdrawn days]
, 'NA' as [UPG_Interest Overdue days]	
, 'NA' as [UPG_Stock statement overdue days]	
, CASE WHEN [Type]='Regular'
      THEN [RefPeriodReviewUPG]
	  ELSE 'NA'
	  END    as [UPG_Review overdue days]  	

FROM #DATA

--------12/*'SFIN' SmartFin  15102023*/---------------------------------
UNION ALL

SELECT
 12                    SourceAlt_Key	
,'SFIN'               [Source System] 
,[Type]
,CASE WHEN [Type]='Regular' 
      THEN [RefPeriodOverdue] 
	  ELSE 'NA'
	  END                          [Principal Overdue days]	
,'NA'                              [Principal Overdrawn days]	
--,'NA'                              [Interest Overdue days]
,CASE WHEN [Type]='Regular' 
      THEN [RefPeriodOverdue] 
	  ELSE 'NA'
	  END  	[Interest Overdue days]
,CASE WHEN [Type]='Regular'
      THEN [RefPeriodStkStatement]
	  ELSE 'NA'
	  END                          [Stock statement overdue days]	
,CASE WHEN [Type]='Regular'
      THEN [RefPeriodReview]
	  ELSE 'NA'
	  END                          [Review overdue days]
,CASE WHEN [Type]='Regular' 
      THEN [RefPeriodOverdueUpg]
	  ELSE 'NA'
	  END    as [UPG_Principal Overdue days]
, 'NA' as [UPG_Principal Overdrawn days]
--, 'NA' as [UPG_Interest Overdue days]
,CASE WHEN [Type]='Regular' 
      THEN [RefPeriodOverdueUpg]
	  ELSE 'NA'
	  END    as [UPG_Interest Overdue days]	
,CASE WHEN [Type]='Regular'
      THEN [RefPeriodStkStatementUpg]
	  ELSE 'NA'
	  END  as [UPG_Stock statement overdue days]	
, CASE WHEN [Type]='Regular'
      THEN [RefPeriodReviewupg]
	  ELSE 'NA'
	  END   as [UPG_Review overdue days]		

FROM #DATA

--------12/*'SFIN' SmartFin  15102023*/---------------------------------

ORDER BY SourceAlt_Key,[Type] DESC


OPTION(RECOMPILE)

--DROP TABLE #DATA




GO