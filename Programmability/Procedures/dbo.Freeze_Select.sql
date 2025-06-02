SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
	CREATE PROC [dbo].[Freeze_Select]
				 @UserLoginId VARCHAR(20)
				,@TimeKey INT
				,@LastQtrDateKey INT = 24837
	AS
	DECLARE @PrevLastQtrDateKey INT , @CurrQtrDate DATE
	SET @PrevLastQtrDateKey =(SELECT  MAX(Prev_Qtr_key)FROM SysDataMatrix WHERE Prev_Qtr_key < @LastQtrDateKey)

	SELECT @CurrQtrDate= Date FROM SysDayMatrix WHERE TImekey =
	(SELECT MAX(Qtr_key) FROM  SysDataMatrix WHERE Prev_Qtr_key = @PrevLastQtrDateKey)
	PRINT @PrevLastQtrDateKey
	PRINT @CurrQtrDate


	SELECT  MOC_Initialised
	        ,QTR_Initialised
			,QTR_Frozen
			,PRV_QTR_Frozen
			,MOC_Frozen
			,CONVERT(VARCHAR(10),@CurrQtrDate,103) CurrQtrDate
			,PrevQtrTimeKey
			, TableName
			FROM 
	(
	SELECT   CASE WHEN ISNULL(MOC_Initialised,'N')='Y'	THEN 'Y' ELSE 'N' END 'MOC_Initialised'  
			,CASE WHEN ISNULL(QTR_Initialised,'N')='Y'	THEN 'Y' ELSE 'N' END 'QTR_Initialised'
			,CASE WHEN ISNULL(QTR_Frozen,'N') ='Y'		THEN 'Y' ELSE 'N' END 'QTR_Frozen' 
			,CASE WHEN ISNULL(MOC_Frozen,'N') ='Y'		THEN 'Y' ELSE 'N' END 'MOC_Frozen' 
			, (
					SELECT CASE WHEN ISNULL(QTR_Frozen,'')='' THEN 'N' ELSE 'Y' END 
				FROM SysDataMatrix WHERE TImekey = (
				SELECT MAX(TImekey) FROM SysDataMatrix WHERE  Prev_Qtr_key = @PrevLastQtrDateKey)
				) AS
			'PRV_QTR_Frozen'
			,Prev_Qtr_key AS PrevQtrTimeKey
			,'FreezeData' AS 'TableName'
	FROM SysDataMatrix 
	WHERE Prev_Qtr_key = @PrevLastQtrDateKey -- AND QTR_Initialised ='Y'
	)A
	GROUP BY  MOC_Initialised
			,MOC_Frozen
	        ,QTR_Initialised
			,QTR_Frozen
			,PRV_QTR_Frozen
			,PrevQtrTimeKey
			, TableName


--------------------  New ---------------------
		
		DECLARE @LastQtrDateKey1 INT
					

			SELECT @LastQtrDateKey1= MIN(Prev_Qtr_key) FROM SysDataMatrix WHERE Prev_Qtr_key >  
						(select MAX(Prev_Qtr_key) from SysDataMatrix where Prev_Qtr_key=

							(SELECT MAX (Prev_Qtr_key) FROM SysDataMatrix where  QTR_Initialised ='Y' AND QTR_Frozen ='Y'))

		print @LastQtrDateKey1
		DECLARE @PrevLastQtrDateKey1 INT , @CurrQtrDate1 DATE
		SET @PrevLastQtrDateKey1 =(SELECT  MAX(Prev_Qtr_key)FROM SysDataMatrix WHERE Prev_Qtr_key < @LastQtrDateKey1)
		print @PrevLastQtrDateKey1
		SELECT @CurrQtrDate1= Date FROM SysDayMatrix WHERE TImekey =
				(SELECT MAX(Qtr_key) FROM  SysDataMatrix WHERE Prev_Qtr_key = @LastQtrDateKey1)
	
	DECLARE @LastDayTimeKeyOfQtr INT
	
			SELECT  @LastDayTimeKeyOfQtr=MAX(TimeKey) FROM SysDataMatrix 
					WHERE Prev_Qtr_key=(SELECT MAX(TimeKey) FROM SysDataMatrix 
					WHERE ISNULL(QTR_Initialised,'N') ='Y' AND ISNULL(QTR_Frozen,'N')='Y')
		
	

	SELECT  MOC_Initialised
	        ,QTR_Initialised
			,QTR_Frozen
			,PRV_QTR_Frozen
			,MOC_Frozen
			,CONVERT(VARCHAR(10),@CurrQtrDate1,103) CurrQtrDate
			,PrevQtrTimeKey
			, TableName
			FROM 
	(
	SELECT   CASE WHEN ISNULL(MOC_Initialised,'N')='Y'	THEN 'Y' ELSE 'N' END 'MOC_Initialised'  
			,CASE WHEN ISNULL(QTR_Initialised,'N')='Y'	THEN 'Y' ELSE 'N' END 'QTR_Initialised'
			,CASE WHEN ISNULL(QTR_Frozen,'N') ='Y'		THEN 'Y' ELSE 'N' END 'QTR_Frozen' 
			,CASE WHEN ISNULL(MOC_Frozen,'N') ='Y'		THEN 'Y' ELSE 'N' END 'MOC_Frozen' 
			, (
					SELECT CASE WHEN ISNULL(QTR_Frozen,'N')='N' THEN 'N' ELSE 'Y' END 
				FROM SysDataMatrix WHERE TImekey = (
				SELECT MAX(TImekey) FROM SysDataMatrix WHERE  Prev_Qtr_key = @PrevLastQtrDateKey1)
				) AS
			'PRV_QTR_Frozen'
			,Prev_Qtr_key AS PrevQtrTimeKey
			,'FreezeData1' AS 'TableName'
	FROM SysDataMatrix 
	WHERE Prev_Qtr_key = @LastQtrDateKey1 -- AND QTR_Initialised ='Y'
	)A
	GROUP BY  MOC_Initialised
			,MOC_Frozen
	        ,QTR_Initialised
			,QTR_Frozen
			,PRV_QTR_Frozen
			,PrevQtrTimeKey
			, TableName



GO