SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



CREATE PROC [dbo].[Rpt-SysReportVersion]      

 @ReportName AS VARCHAR(MAX),
 @TimeKey AS INT  
  as

declare @reptitle AS VARCHAR(MAX)      
declare @value AS INT      
SET @reptitle =RIGHT(@reportname,charindex('-',reverse(@reportname))-1)       
SET @value=(SELECT CASE WHEN (SELECT top(1) ReportRdlName FROM SysReportDirectory
                                                   WHERE EffectiveFromTimeKey<=@timekey and EffectiveToTimeKey >=@timekey 
												         AND ReportRdlName=@reptitle)=@reptitle      
                        THEN 1 ELSE 2 END)      


IF @value =1      
 BEGIN      
  SELECT top(1) ('Version No. : '+VersionNo)  AS versionno,('Report ID : '+ExportReportId) as reportid        
  , Frequency_Period        
        
  ,CASE WHEN ReportType = 1    
        THEN 'Summary'   
        WHEN  ReportType = 2 THEN 'Details'   
        WHEN  ReportType = 3 THEN 'SummaryDetails'  
		WHEN  ReportType = 7   
        THEN 'Summary'   
        WHEN  ReportType = 8 THEN 'Details' 
        WHEN  ReportType = 9 THEN 'SummaryDetails' 
        END AS ReportTypeLabel
      
  ,ReportType AS ReportTypeValue     
        
  FROM SysReportDirectory SRD
  WHERE     
  SRD.EffectiveFromTimeKey<=@timekey and SRD.EffectiveToTimeKey >=@timekey 
  AND  SRD.ReportRdlName=@reptitle      
  END  
  
      
IF @value =2      
 BEGIN      
  SELECT top(1) ('Version No. : '+VersionNo)  AS versionno,('Report ID : '+ReportID) as reportid       
        
  ,CASE WHEN ReportType = 1    
        THEN 'Summary' ELSE 'Details' END AS ReportTypeLabel    
      
      
  ,CASE WHEN ReportType = 1    
        THEN '1' ELSE '2' END AS ReportTypeValue      
        
   FROM SysValidationReport  WHERE      
  EffectiveFromTimeKey<=@timekey and EffectiveToTimeKey >=@timekey  and  ReportRdlName=@reptitle      
 END      
 ELSE      
 BEGIN      
 SELECT '' AS versionno      
 END 



GO