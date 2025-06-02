SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--USE [YBL_ACS]
--GO
--/****** Object:  StoredProcedure [dbo].[Rpt-Monthly_Dates]    Script Date: 21-Mar-25 10:35:44 AM ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO


CREATE PROCEDURE [dbo].[Rpt-Monthly_Dates]
@Year INT
AS

--DECLARE
--@Year INT=2025

BEGIN

    SELECT CONVERT(VARCHAR(20),DATE,103) DateLabel
	       ,TimeKey DateValue
    FROM SysDayMatrix SDM   
    WHERE (DAY(SDM.DATE)=25 OR (EOMONTH(SDM.DATE)=DATE AND MONTH(EOMONTH(SDM.DATE)) IN(3,6,9,12))) AND  
	      (SDM.DATE)<=GETDATE() 
		 ------CAST((SDM.DATE) AS DATE) <= CAST(DATEADD(month, 1, getdate()) AS DATE)
	      
		  AND YEAR(DATE)=@Year

Order by SDM.TimeKey DESC 
END
GO