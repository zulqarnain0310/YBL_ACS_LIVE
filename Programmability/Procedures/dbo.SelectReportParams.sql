SET QUOTED_IDENTIFIER OFF

SET ANSI_NULLS ON
GO
    
---SelectReportParams 92405,3652    
Create PROCEDURE [dbo].[SelectReportParams]     
    @ReportID int = 92405,    
    @TimeKey int      
AS    
SELECT DimReportColAlt_Key     
   , ISNULL(ReportMenuId,0) ReportMenuId     
   , DisplayOrder     
   , Label     
   , ControlType     
   , DataType     
   , Placeholder    
   , Col_lg ColumnWidth     
   , Col_md     
   , Col_sm    
   , ISNULL(IsDBPull,0) as 'IsDBPull'    
   , ISNULL(ReferenceTable,'NA') ReferenceTable     
   , ISNULL(ReferenceColumn,'NA') ReferenceColumn     
   , MasterTableValidCode    
   , ControlName    
   , RefColumnValue    
   , ReferenceTableCond    
   , RoutineNo    
   , RoutineArgument    
   , OnFormLoad    
   , OnFormLoadParameter    
   ,isnull(SkipColumnInQuery,'Y') as SkipColumnInQuery    
   ,isnull(IsVisible,0) as IsVisible    
   ,ISNULL(IsMandatory,0) as IsMandatory    
   ,DisplayRowOrder    
FROM [dbo].[DimReportParameter]    
WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) and ReportMenuId is not null AND ReportMenuId = @ReportID    
ORDER BY DisplayOrder    
    
    
    
exec GetReportEffectiveFromTimeKey @Menuid=@ReportID    
    
Declare @query as varchar(max)    
Set @query=(select 'select '+cast(DimReportColAlt_Key as varchar)+' as [TableKey],'+ReferenceColumn+' as [Description],'+RefColumnValue+' as [Code] from '+ReferenceTable+' '+    
   case when ReferenceTableCond is not null then ' where '+ReferenceTableCond else '' end +';'  FROM [dbo].[DimReportParameter]    
   WHERE ReferenceTable is not null and ReferenceColumn is not null AND ReportMenuId = @ReportID    
   for xml path('')    
       
   )    
    
print @query    
exec(@query) 
GO