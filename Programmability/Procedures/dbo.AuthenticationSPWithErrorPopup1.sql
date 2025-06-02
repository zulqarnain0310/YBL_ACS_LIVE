SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


create Procedure [dbo].[AuthenticationSPWithErrorPopup1]
AS

SET NOCOUNT ON;
Declare @I Int,@Count Int
Declare @ModTableName Varchar(100),@MenuId INT,@CountRow INT
Declare @strsql nvarchar(500)

IF OBJECT_ID('Tempdb..#temp') IS NOT NULL
DROP TABLE #temp

IF OBJECT_ID('Tempdb..##temp1') IS NOT NULL
DROP TABLE #temp1

IF OBJECT_ID('Tempdb..##temp2') IS NOT NULL
DROP TABLE #temp2

Create Table #temp
(
MenuId Int,
ModTableName Varchar(100)
)

Create Table #temp2
(
Rowreturn Int,

)

SELECT ROW_NUMBER() Over(ORDER BY MenuId ) AS RowNumber,MenuId,ModTableName INTO #temp1 from [MenuModTableMapping]

SET @I=1
Select  @Count=Count(*) from #temp1
SET @CountRow=0
WHILE(@I<=@Count)
BEGIN
		Select @ModTableName=ModTableName,@MenuId=MenuId from #temp1 Where RowNumber=@I
		SET @CountRow=0
		Truncate Table #temp2
		--Select  @CountRow =COUNT(*) from SolutionGlobalParameter_Mod Where AuthorisationStatus in('NP','MP'
	SET @strsql='INSERT Into #temp2 Select Count(*) from '+ @ModTableName+ ' Where AuthorisationStatus in(''NP'',''MP'')'

		PRINT @strsql
		
          EXEC SP_EXECUTESQL @strsql
		 Select @CountRow=Rowreturn from #temp2
		
		SET @I=@I+1
		IF (@CountRow>0)
		BEGIN
			INSERT INTO #temp(MenuId,ModTableName) Values(@MenuId,@ModTableName)
		END

END

--Select * from #temp

Select  ROW_NUMBER() Over(ORDER BY A.MenuId ) AS SrNo,B.MenuCaption As ListofPendingInterfaceScreen,'ErrorPopUp1' As TableName from #temp A
INNER JOIN SysCRisMacMenu B ON A.MenuId=B.MenuId






GO