SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--USE YES_MISDB  
--exec CollateralDetail_DownloadData @TimeKey=25994,@UserLoginId=N'mischecker',@ExcelUploadId=N'12',@UploadType=N'Colletral Detail Upload'  
--go  
  
  
  
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  
  
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  
  
  
CREATE PROCEDURE [dbo].[CollateralDetail_DownloadData]  
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
  
IF (@UploadType='Colletral Detail Upload')  
  
BEGIN  
    
  --SELECT * FROM(  
  SELECT 'Details' as TableName, 
  UploadID, 
  SrNo as [Sr. No.],
  	CASE WHEN [ACTION] in('M') Then CollateralIDModification Else CollateralID END as [Collateral ID],
   Action,
LiabID  as [Liab ID],
  UCIC, 
    CustName as [Cust Name],  
   AssetID as [Asset ID],
   Segment,
    CRE,  
	CollateralSubType as [Sub Type of Collateral],
    NameSecuPv as [Name of the security Provider],
  SeniorityCharge as [Seniority of Charge],
   SecurityStatus as [Security Status],
   FDNO  as [Fd no.],
   ISINNo_FolioNumber as [ISIN No./Folio Number], 
    QtyShares_MutualFunds_Bonds as [Quantity of shares/Mutual Funds/Bonds],
  Line_No as [Line No.],
   CrossCollateral_LiabID as [Cross Collateral (Liab ID)], 
  PropertyAdd as [Property Address],   
  PIN as [PIN Code],
    DtStockAudit as [Date of stock Audit],
    SBLCIssuingBank as [SBLC Issuing bank],
      SBLCNumber as [SBLC Number],
   CurSBLCissued as [Currency in which SBLC issued],
   SBLCFCY as [SBLC in FCY],  
  DtexpirySBLC as [Date of expiry for SBLC],
   DtexpiryLIC as [Date of expiry for  LIC],
  ModeOperation as [Mode of operation],
   ExceApproval as [Exceptional approval], 
  ValSource_ExpBusinessRule as [ValuationSource/Expiry Business Rule],
   DtofValuation as [Date of valuation],
    ValueConsidered as [Value to be considered],
   SecondDtofValuation as [Second Valuation Date],
  SecondValuation as [Second Valuation Amount],
  Expirydate as [Expiry date]
   FROM CollateralDetailUpload_Mod  
  WHERE UploadId=@ExcelUploadId  
  AND EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey    
  
  
    
  
 
  
    
  
   
  
END  
  
  
  
END  
  

GO