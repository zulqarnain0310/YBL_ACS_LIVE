SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



CREATE PROC [dbo].[SysCurrentTimeKey] 
      
AS 
SET DATEFORMAT DMY      
BEGIN        

	DECLARE @TIMEKEY INT
	--SET @TIMEKEY=(SELECT TimeKey FROM SysDayMatrix WHERE CAST(Date AS DATE)=CAST(GETDATE() AS DATE))
	SELECT @TimeKey=TimeKey FROM   PRO.EXTDATE_MISDB  WHERE Flg='Y'--TIMEKEY=25141
	
	Declare @PrevQtrTimeKey INT
	Select @PrevQtrTimeKey=LastQtrDateKey from SysDayMatrix where TimeKey=@TIMEKEY

	DECLARE @date date =(SELECT MonthLastDate FROM  SysDataMatrix WHERE  CurrentStatus = 'C')   
	DECLARE @HfYrStDate DATE
	
	SELECT @HfYrStDate
			= CASE WHEN MONTH(@date)<=3 
				THEN CAST(DATEPART(YEAR,@date)-1 AS VARCHAR(4))+'-10-01' 
				
				WHEN MONTH(@date) BETWEEN 9 AND 12
				THEN  CAST(DATEPART(YEAR,@date) AS VARCHAR(4))+'-10-01' 

			ELSE CAST(DATEPART(YEAR, @date) AS VARCHAR(4))+'-04-01' 
			END
PRINT 'A'
	DECLARE @HalfYrStTimekey INT = ( SELECT TimeKey FROM SysDayMatrix WHERE DAte =  @HfYrStDate)
	
	SELECT         
		CONVERT(Char,DataEffectiveFromDate ,103) AS MonthFirstDate        
		,CONVERT(Char,DataEffectiveToDate,103) AS MonthLastDate        
		,CONVERT(Char,'01/01/1950',103) AS StartDate        
		,@TIMEKEY AS TimeKey       
		,MONTHNAME        
		,CASE WHEN
			 MONTH(DataEffectiveToDate)<=9 THEN 
			 '0'+CAST(MONTH(DataEffectiveToDate) AS VARCHAR)
			 ELSE
			 CAST(MONTH(DataEffectiveToDate) AS VARCHAR)
			 END+CAST(YEAR(DataEffectiveToDate) AS VARCHAR)  AS MonthYear    
		,[Year]        
		,Prev_Month_Key AS PrvTimeKey  
		,CurrentStatus      
		,@TIMEKEY  AS EffectiveFromTimeKey
		,'49999' AS EffectiveToTimeKey
		,DataEffectiveToDate
		,CONVERT(varchar(11),GETDATE(),103) AS CurrentDate
		--,Prev_Qtr_key PrevQtrTimeKey
		,@PrevQtrTimeKey PrevQtrTimeKey
		   , DY.LastFinYearKey+1	StartYearTimeKey
			, DY.CurFinYearKey		EndYearTimeKey
			, @HalfYrStTimekey		StartHalfYearTimeKey
			, Fiscal_HalfYear_key	EndHalfYearTimeKey
			, DY.LastQtrDateKey+1	StartQuarterTimeKey
			, DY.CurQtrDate			ENdQuarterDate
			, DY.CurQtrDateKey		EndQuarterTimeKey
			, Prev_Month_Key+1      StartMonthTimeKey
			, Month_Key				EndMonthTimeKey 
			, WeekDateKey -6		StartWeekTimeKey
			, WeekDateKey			EndWeekTimeKey
			, CONVERT(VARCHAR(10), DATEADD(DAY,1,LastQtrDate),103)         CurrentQuarterStDate
	FROM SysDataMatrix    DTS     
		 INNER JOIN SysDayMatrix DY
			ON DTS.CurrentStatus = 'C'
			AND DY.TimeKey= DTS.TimeKey
	
	
	 
     
END






GO