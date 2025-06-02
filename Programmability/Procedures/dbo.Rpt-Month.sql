SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Rpt-Month]
@Year Varchar(20)
AS

DECLARE @date date
SELECT @date=StartDate FROM   PRO.EXTDATE_MISDB  WHERE Flg='Y'
SELECT Distinct DATENAME(MM,DATE) MonthName,DATEPART(MM,DATE) orderby
FROM   SysDayMatrix 
WHERE --Date<=GetDate()
Date <=@date
      AND Year(Date)=@Year
ORDER BY orderby DESC

GO