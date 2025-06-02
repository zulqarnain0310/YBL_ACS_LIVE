SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/*
CREATED BY       : LIPSA
DATE             : 19-12-2023
*/
Create procedure  [dbo].[Rpt-Date_FrequencyWise]
    @FrequencyType   char(1)
	As

--DECLARE @FrequencyType AS CHAR(1)='D'


--SELECT DISTINCT
--		CONVERT(VARCHAR(10),D.Date,103) AS Description
--		,D.TimeKey                                     AS Code
		
		
--FROM	SysDayMatrix D
--		INNER JOIN SysDataMatrix	DA	ON	D.TimeKey=DA.TimeKey
--											AND DA.CurrentStatus IN ('C','U')
--WHERE 
--		DA.DataEffectiveFromTimeKey IS NOT NULL 
--		AND DataEffectiveToDate IS NOT NULL
--		AND EOMONTH(GETDATE())>=DataEffectiveToDate
--		AND @FrequencyType='M'

--UNION ALL

SELECT DISTINCT CONVERT(VARCHAR(10),D.DATE,103)		                  AS  Description ,
				D.TIMEKEY							                      AS  Code
				
FROM	SysDayMatrix D


WHERE @FrequencyType IN('D','M')  AND date<=cast(getdate() as date)


AND DATEADD(YEAR,-5,cast(getdate() as date))<=DATE




ORDER BY Code DESC
GO