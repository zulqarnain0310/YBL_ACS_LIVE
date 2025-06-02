SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--USE YES_MISDB  
--exec CollateralDetail_DownloadData @TimeKey=25994,@UserLoginId=N'mischecker',@ExcelUploadId=N'12',@UploadType=N'Colletral Detail Upload'  
--go  
  
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  
  
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  
  
  
CREATE PROCEDURE [dbo].[LineCode_DownloadData]  
 @Timekey INT  
 ,@UserLoginId VARCHAR(100)  
 ,@ExcelUploadId INT  
 ,@UploadType VARCHAR(50)  
 --,@Page SMALLINT =1       
 --   ,@perPage INT = 30000     
AS  
  
----DECLARE @Timekey INT=49999  
---- ,@UserLoginId VARCHAR(100)='FNASUPERADMIN'  
---- ,@ExcelUploadId INT=4  
---- ,@UploadType VARCHAR(50)='Interest reversal'  
  
BEGIN  
  SET NOCOUNT ON;  
  
  Select @Timekey=Max(Timekey) from dbo.SysDayMatrix    
    where  Date=cast(getdate() as Date)  
        PRINT @Timekey    
  
  --DECLARE @PageFrom INT, @PageTo INT     
    
  --SET @PageFrom = (@perPage*@Page)-(@perPage) +1    
  --SET @PageTo = @perPage*@Page    
  
IF (@UploadType='LineCode Upload')  
  
BEGIN  
    
  --SELECT * FROM(  
  SELECT 'CAMRenewalCode' as TableName, 
  UploadID, 
  ROW_NUMBER() Over(order by(select 1))  as [Sl. No.],
  ReviewLineCodeGroup as [Source System],
  ReviewLineCode as [Code Value],
  CodeType as [Code Type],
  ReviewLineCodeName as [Code Description]
  
   FROM DimLineCodeReview_Mod  
  WHERE UploadId=@ExcelUploadId  
  AND EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey    
  
  UNION ALL

   SELECT 'CAMRenewalCode' as TableName, 
  UploadID, 
  ROW_NUMBER() Over(order by(select 1))  as [Sr. No.],
  StockLineCodeGroup as [Source System],
  StockLineCode as [Code Value],
  CodeType as [Code Type],
  StockLineCodeName as [Code Description]
   
   FROM DimLinecodeStockStatement_Mod  
  WHERE UploadId=@ExcelUploadId  
  AND EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey    

  UNION ALL

   SELECT 'CAMRenewalCode' as TableName, 
  UploadID, 
  ROW_NUMBER() Over(order by(select 1))  as [Sr. No.],
  ReviewLineProductCodeGroup as [Source System],
  ReviewLineProductCode as [Code Value],
  CodeType as [Code Type],
  ReviewLineProductCodeName as [Code Description]  
   FROM DimLineProductCodeReview_Mod  
  WHERE UploadId=@ExcelUploadId  
  AND EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey   


    
  
 
  
    
  
   
  
END  
  
  
  
END  
  

GO