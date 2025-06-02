SET QUOTED_IDENTIFIER OFF

SET ANSI_NULLS ON
GO


  
create Procedure [dbo].[GetReportEffectiveFromTimeKey]   
 @Menuid int  
As  
BEGIN  
  
Declare @EffectiveFromTimeKey int=0  
Declare @EffectiveToTimeKey int=0  
  
  
--Select * from DimReportFrequency  
Select Distinct DimReportFrequency.ReportFrequency_Name,Min(SysReportDirectory.EffectiveFromTimeKey) as EffectiveFromTimeKey,Max(SysReportDirectory.EffectiveToTimeKey) as EffectiveToTimeKey,ReportID,DimReportFrequency.ReportFrequencyAlt_Key from SysReportDirectory   
LEFT JOIN DimReportFrequency on DimReportFrequency.ReportFrequencyAlt_Key=SysReportDirectory.ReportFrequency_Key  
where ReportMenuId=@Menuid --ReportID='Axis-001'  
Group By DimReportFrequency.ReportFrequency_Name,ReportId,DimReportFrequency.ReportFrequencyAlt_Key  
order by EffectiveFromTimeKey desc  
  
Select   DimReportFrequency.ReportFrequency_Name as Frequency,TblReportDirectory.* from SysReportDirectory TblReportDirectory  
LEFT JOIN DimReportFrequency on DimReportFrequency.ReportFrequencyAlt_Key=TblReportDirectory.ReportFrequency_Key  
--AND DimReportFrequency.ReportFrequencyShortNameEnum IN ('W-FRI','M-LD','FORT-NG','Q-LD')  
  where ReportMenuId=@MenuId  
order by Reportid  
  
  
  
END  
  
GO