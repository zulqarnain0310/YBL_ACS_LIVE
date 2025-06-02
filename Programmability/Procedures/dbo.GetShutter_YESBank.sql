SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROC [dbo].[GetShutter_YESBank] 
@MenuId int=0,
@BaseColumnValue int=0,
@TimeKey		INT = 49999
AS 


--DECLARE   
--@MenuId int=616,
--@BaseColumnValue int=1,
--@TimeKey		INT = 25141

BEGIN
		DECLARE 
		@BranchCode						VARCHAR(10),
		@CustomerId					    VARCHAR(30),
		@CustomerName				    VARCHAR(200),
		@SourceTableName				VARCHAR(100),
		@SQL							VARCHAR(MAX),
		@TableBaseColumnName			VARCHAR(100)
				
				
		IF @MenuID IN (602, 620, 621, 622, 607, 616, 641) 
			BEGIN
					
					SELECT DISTINCT @SourceTableName = SourceTable from MetaDynamicScreenField 
									WHERE MenuID=@MenuId AND SourceTable IS NOT NULL

					SELECT @TableBaseColumnName = ControlName from MetaDynamicScreenField 
									WHERE MenuID=@MenuId AND BaseColumnType='BASE'

					PRINT @SourceTableName + ' is Source Table'
					PRINT @TableBaseColumnName + ' is Base Column'

					IF OBJECT_ID('tempdb..#tempCust') IS NOT NULL
					DROP TABLE #tempCust

					CREATE TABLE #tempCust
					(CustomerId  Varchar(30))

					SET @SQL = 'SELECT  CustomerId from DataUpload.' + @SourceTableName + '_Mod WHERE '+ @TableBaseColumnName + ' = ' + CAST(@BaseColumnValue AS VARCHAR(100))+ ' AND EffectiveFromTimeKey <=' + CAST(@Timekey AS VARCHAR(10)) +' AND EffectiveToTimeKey >= ' + CAST(@Timekey AS VARCHAR(10))
					
					INSERT INTO #tempCust
					EXEC (@SQL)

					SELECT @CustomerId=CustomerId from #tempCust

					SELECT @BranchCode=BranchCode, @CustomerName=CustomerName FROM PRO.CustomerCal WHERE RefCustomerID=@CustomerId
			END



-----------------------------------------------------------------------------------------------------------------------------------
		  BEGIN

			   SELECT 
			   @BranchCode AS branchcode
			   ,@CustomerId AS customerid
			   ,@CustomerName AS customername

		  END


		----------------
		PRINT 9																				  
																							  
END																												  
GO