SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Rpt-Date] 
@Year INT,
@Month Varchar(20)

AS
BEGIN
DECLARE @date date
SELECT @date=StartDate FROM   PRO.EXTDATE_MISDB  WHERE Flg='Y'
    SELECT Convert(Varchar(20),DATE,103) DateLabel
	       ,TimeKey DateValue
    FROM SysDayMatrix DDM
    WHERE --DDM.Date<=GETDATE()
	DDM.Date<=@date
	      AND YEAR(DDM.DATE)=@Year
		  AND DATENAME(MM,DDM.DATE)=@Month

Order by DDM.Date DESC 
END

GO