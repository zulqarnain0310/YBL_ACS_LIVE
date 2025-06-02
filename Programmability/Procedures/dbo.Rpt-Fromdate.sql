SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

 
 CREATE PROCEDURE [dbo].[Rpt-Fromdate]
 as
 SELECT Convert(Varchar(20),DATE,103) DateLabel
	       ,TimeKey DateValue
    FROM SysDayMatrix DDM
    WHERE DDM.Date<=GETDATE()
	   --   AND YEAR(DDM.DATE)=@Year
		  --AND DATENAME(MM,DDM.DATE)=@Month

Order by DDM.Date DESC 
GO