SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


---SelectReportParams 92405,3652
CREATE PROCEDURE [dbo].[SelectReportData] 
    @ReportID int = 1040
   
AS

BEGIN 

Select   DimReportFrequency.ReportFrequency_Name as Frequency,TblReportDirectory.* 
FROM SysReportDirectory TblReportDirectory
		LEFT JOIN DimReportFrequency 
		ON DimReportFrequency.ReportFrequencyAlt_Key=TblReportDirectory.ReportFrequency_Key
		where ReportMenuId=@ReportID
		order by Reportid


End



GO