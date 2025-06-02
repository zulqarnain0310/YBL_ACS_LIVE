SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Rpt-Year]

AS

SELECT Distinct YEAR(DATE) YearName
FROM   SysDayMatrix Where Date<=GetDate()
Order by YearName DESC

GO