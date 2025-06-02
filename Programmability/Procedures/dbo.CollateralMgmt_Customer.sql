SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


  
  
  
  
  
CREATE Proc [dbo].[CollateralMgmt_Customer]  --- Script Date: 3/26/2021 2:00:55 PM *****(Farahnaaz)  
 @SearchType Int,  
 @Cust_Ucic_Acid varchar(20)='',  
 @Result     INT    =0 OUTPUT  
  
As  
BEGIN  
    --IF OBJECT_ID('TempDB..#temp') IS NOT NULL  
    --             DROP TABLE  #temp;  
 Declare @RowsRetrurn Int  
 Declare @TimeKey as Int  
 Declare @LatestColletralSum Decimal(18,2),@LatestColletralCount Int  
  
 SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')  
  
  
 IF (@SearchType=4)  
 BEGIN  
 print 'aaa'  
    
IF OBJECT_ID('TempDB..#tmp2') IS NOT NULL Drop Table #tmp2   
    
 IF NOT EXISTS ( Select  M.UCIF_ID,  
             'UCICDetails' TableName,M.CustomerName,M.Customerid  
    
     FROM (  
     Select A.UCIF_ID ,A.CustomerName,A.RefCustomerId as Customerid  
    from PRO.CustomerCal A  
   ) As M  
      WHERE M.UCIF_ID=@Cust_Ucic_Acid)  
  
      BEGIN  
  
      Select 'NULL' as UCIC_ID,'UCICDetails' TableName,'' CustomerName  
  
      END  
      Else  
      BEgin  
      Select  M.UCIF_ID,  
       'UCICDetails' TableName ,M.CustomerName,M.Customerid  
    
         FROM (  
     Select A.UCIF_ID ,A.CustomerName,A.RefCustomerId as Customerid  
    from pro.CustomerCal  A  
   ) As M  
      WHERE M.UCIF_ID=@Cust_Ucic_Acid  
  
      END  
  
        
  
Select CollateralID into #tmp2 from Curdat.AdvSecurityDetail where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey And UCICID=@Cust_Ucic_Acid  
  
    Select @LatestColletralSum =SUM(TotalCollateralvalueatcustomerlevel)  from(  
    Select (ISNULL(CurrentValue,0)) as TotalCollateralvalueatcustomerlevel  
          from Curdat.AdvSecurityValueDetail A  
          INNER JOIN Curdat.AdvSecurityDetail  B ON A.CollateralID=B.CollateralID Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey   
          And A.CollateralID in (Select CollateralID from #tmp2)  
          AND B.UCICID=@Cust_Ucic_Acid  
     )X    
       
     Select @LatestColletralCount=Count(*) from #tmp2  
  
  
     Select @LatestColletralSum as LatestColletralSum,@LatestColletralCount as LatestColletralCount,'ColletralDetails2' as TableName  
  
     SET @RowsRetrurn=@@ROWCOUNT  
  
     if (@RowsRetrurn<=0)  
         BEGIN  
        
       SET @Result=-4  
       --RETURN @Result;  
         END  
      --Select @Result As result  
 END  
  
   
  
        
END       
 
GO