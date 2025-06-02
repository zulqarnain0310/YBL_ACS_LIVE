SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROC [dbo].[GetTimeKeyByMenuID] 
	  @MenuId int = 506
AS 
--Declare @MenuId int = 516
BEGIN        

	
	Declare @FreqType char = 'D'
	Declare @DayLimit INT = 0
	Declare @CarryForwordFlag Char = 'Y'

	Declare @HalfYrDateStartKey INT = 0
	Declare @HalfYrDateEndKey INT = 0
	Declare @HalfYrDate		 Varchar(10)

	Select @FreqType=ScreenFrequency,@DayLimit=ISNULL(FreqEndPeriod,0),@CarryForwordFlag=ISNULL(CarryForwordFlag,'Y') from SysCRisMacMenu Where MenuId=@MenuId

	IF NULLIF(@FreqType,'') is null
	BEGIN
		SET @FreqType = 'D'
		SET @DayLimit = 0
		SET @CarryForwordFlag = 'Y'
	END


	Declare @Date Date = (select GetDate())
	
	SELECT	@HalfYrDateStartKey= PrevHalfYrDateKey +1			
			,@HalfYrDateEndKey=HalfYrDateKey		
			,@HalfYrDate=DATEADD(DAY, 1,PrevHalfYrDate)				
	FROM SysDayMatrix
	WHERE DATE = @Date
	Declare @FreqEndDate date
	Declare @FreqDate date
	Select @FreqDate=
				Case 
					when @FreqType='D' THEN
						 DATEADD(day, -@DayLimit, [Date])
					when @FreqType='W' THEN
						LastWkDate
					when @FreqType='M' THEN
						LastMonthDate
					when @FreqType='Q' THEN
						LastQtrDate 
					When @FreqType='Y' THEN
						LastFinYear
					When @FreqType='H' THEN
						DATEADD(DAY, 1,PrevHalfYrDate)	
				END 
	FROM SysDayMatrix WHERE  Date=@Date
	SET @FreqEndDate = DATEADD(day, @DayLimit, @FreqDate)

	

	If cast(@FreqEndDate as date)>=cast(@Date as date)
		SET @DATE=@FreqDate

	--Select @DATE DATE, @FreqEndDate FreqEndDate,@FreqDate FreqDate
	--else 
	--	select @DATE

		--Select LastQtrDate,CurQtrDateKey, * from SysDayMatrix WHERE  TimeKey=25019
		----CAST(Date AS DATE)=CAST(GETDATE() AS DATE)

	Declare @EffectiveFromTimeKey INT,@EffectiveToTimeKey INT

	Declare @EffectiveFromTimeKey_FREEZE INT,@EffectiveToTimeKey_FREEZE INT
	print @FreqType
	print @CarryForwordFlag
	Select	@EffectiveFromTimeKey = Case 
					when @FreqType='D' THEN
						 TimeKey
					when @FreqType='W' THEN
						LastWkDateKey + 1
					when @FreqType='M' THEN
						LastMonthDateKey + 1
					when @FreqType='Q' THEN
						LastQtrDateKey + 1
					When @FreqType='Y' THEN
						LastFinYearKey + 1
					When @FreqType='H' THEN
						@HalfYrDateStartKey
					END,
				--END  EffectiveFromTimeKey,
			@EffectiveToTimeKey=Case 
				When @CarryForwordFlag = 'N'
				 THEN 
					CASE	when @FreqType='D' THEN
								 TimeKey
							when @FreqType='W' THEN
								WeekDateKey
							when @FreqType='M' THEN
								(Select TimeKey from SysDayMatrix where [Date]=EOMONTH(@DATE))
							when @FreqType='Q' THEN
								CurQtrDateKey
							When @FreqType='Y' THEN
								CurFinYearKey
							When @FreqType='H' THEN
								@HalfYrDateEndKey
					END
				ELSE 
				
			
					49999
				END
				--EffectiveToTimeKey
				
	from SysDayMatrix WHERE  CAST(Date AS DATE)=@DATE

	
	IF(@FreqType='F' and (@MenuId=506 or @MenuId=505))
		BEGIN
		SELECT @EffectiveFromTimeKey_FREEZE= (SELECT  MAX(TimeKey) FROM SysDataMatrix 
					WHERE Prev_Qtr_key=(SELECT MAX(TimeKey) FROM SysDataMatrix 
					WHERE ISNULL(QTR_Initialised,'N') ='Y' AND ISNULL(QTR_Frozen,'N')='Y'))


		 
		 --if(@MenuId=505)
			SELECT @EffectiveToTimeKey_FREEZE=@EffectiveFromTimeKey_FREEZE
		--else
			--SELECT @EffectiveToTimeKey_FREEZE=49999
		 SELECT @EffectiveFromTimeKey_FREEZE EffectiveFromTimeKey,@EffectiveToTimeKey_FREEZE EffectiveToTimeKey,@DATE Date,'TimeKey' TableName
		END
	ELSE IF(@FreqType='F')
		BEGIN
		SELECT @EffectiveFromTimeKey_FREEZE=TimeKey
			FROM SysDayMatrix  
			WHERE DATE =
					(select MIN(MonthFirstDate) FROM SysDataMatrix where ISNULL(QTR_Initialised,'N')='Y' AND  ISNULL(QTR_Frozen,'N') = 'N' )
		 

		 SELECT @EffectiveToTimeKey_FREEZE=49999

		 SELECT @EffectiveFromTimeKey_FREEZE EffectiveFromTimeKey,@EffectiveToTimeKey_FREEZE EffectiveToTimeKey,@DATE Date,'TimeKey' TableName
		END

	ELSE IF (@MenuId=643)
		BEGIN


				DECLARE  @YrStTimekey INT, @YrStartdate DATE, @YrEndTimekey INT, @YrEndDate DATE

			--	SELECT @YrEndTimekey	=  MIN(Timekey) FROM ModluleFreezeStatus WHERE  ModuleName = 'FactTarget' AND						  ISNULL(Frozen,'N')='N'
				SELECT @YrEndDate		= (SELECT DATE FROM SysDayMatrix WHERE TimeKey = @YrEndTimekey)
				SELECT @YrStartdate		= DATEADD( DAY, 1, DATEADD(YEAR , -1, @YrEndDate))
				SELECT @YrStTimekey		= (SELECT TimeKey FROM SysDayMatrix WHERE DATE = @YrStartdate)

				SELECT @YrStTimekey EffectiveFromTimeKey,49999 EffectiveToTimeKey,@DATE Date,'TimeKey' TableName
		END
	ELSE
		BEGIN
			SELECT @EffectiveFromTimeKey EffectiveFromTimeKey,@EffectiveToTimeKey EffectiveToTimeKey,@DATE Date,'TimeKey' TableName
		END

	
END



GO