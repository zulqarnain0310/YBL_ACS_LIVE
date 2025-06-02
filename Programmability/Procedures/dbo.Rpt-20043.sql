SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


/*
Created By    :Lipsa
Date          :03/06/2024
Desc          :Daily/Monthly Upgradation report
*/

Create PROCEDURE [dbo].[Rpt-20043]
@TimeKey AS int,
@Cost      AS FLOAT,
@FrequencyType AS CHAR(1)
AS
		


---- DECLARE  
---- @TimeKey as int=25688
----,@Cost    AS FLOAT=1
----,@FrequencyType AS CHAR(1)='m'

 
--Declare @MonthStartTimeKey as int=(Select (LastMonthDateKey+1) from SysDayMatrix where Timekey=@TimeKey)
--Declare @MonthStartDt as Date=(Select Date from Sysdaymatrix where TimeKey=@MonthstartTimeKey)
--Declare @MonthendTimeKey as int=(Select (CurrentMonthDateKey) from SysDayMatrix where Timekey=@TimeKey)
--Declare @MonthendDt as Date=(Select Date from Sysdaymatrix where TimeKey=@MonthendTimeKey)

declare @PrevTimekey   as int =(select(case when @FrequencyType='M'
                                            then LastMonthDateKey 
											when @FrequencyType='D'
											then (@TimeKey-1)
											end )from SysDayMatrix where Timekey=@TimeKey)

declare @PrevDate   as Date =(select(case when @FrequencyType='M'
                                            then LastMonthDate 
											when @FrequencyType='D'
											then dateadd(dd,-1,date)
											end )from SysDayMatrix where Timekey=@TimeKey)

Declare @Date   date=(select date from SysDayMatrix   where TimeKey=@TimeKey)

--select @PrevTimekey,@PrevDate,@Date
IF(OBJECT_ID('tempdb..#DATA_Curr') is not null)
DROP TABLE #DATA_Curr

IF(OBJECT_ID('tempdb..#DATA_Prev') is not null)
DROP TABLE #DATA_Prev

	   SELECT distinct 
	    
	   
  ACH.UCIF_ID			                                                 AS	              UCIFID	
 ,ACH.RefCustomerID		                                             AS	              CustID            
,ACH.CustomerAcID			                                             AS               AccountID
,DC.AssetClassName	                                                 AS	              AssetClass    
  ,ACH.FinalAssetClassAlt_Key
				  ,'Q2' FLAG	 			
	into #DATA_Curr		
			
	   from pro.AccountCal_hist							                   ACH

	   INNER JOIN PRO.customercal_hist CCH                                 ON  ACH.CustomerEntityID=CCH.CustomerEntityID
                                                                               AND ACH.EffectiveFromTimeKey <= @TimeKey 
											                                   AND ACH.EffectiveToTimeKey   >= @TimeKey
                                                                               AND CCH.EffectiveFromTimeKey <= @TimeKey 
											                                   AND CCH.EffectiveToTimeKey   >= @TimeKey

  									                               		   										
      LEFT JOIN DimAssetClass DC	                                       ON  DC.AssetClassAlt_Key=ACH.FinalAssetClassAlt_Key
                                                                               AND DC.EffectiveFromTimeKey <= @TimeKey
											                                   AND DC.EffectiveToTimeKey   >= @TimeKey
											                               								   
	

	where ACH.FinalAssetClassAlt_Key=1
	Option(recompile)

--select * from #DATA_Curr	


	   SELECT distinct 
	    
  ACH.UCIF_ID			                                                 AS	              UCIFID	
 ,ACH.RefCustomerID		                                             AS	              CustID            
,ACH.CustomerAcID			                                             AS               AccountID
,DC.AssetClassName	                                                 AS	              AssetClass      
  ,ACH.FinalAssetClassAlt_Key
				  ,'Q1' FLAG	 			
	into #DATA_Prev		
			
	   from pro.AccountCal_hist							                   ACH
	   inner join #DATA_Curr B on ACH.CustomerAcID=b.AccountID

	  

	   INNER JOIN PRO.customercal_hist CCH                                 ON  ACH.CustomerEntityID=CCH.CustomerEntityID
                                                                               AND ACH.EffectiveFromTimeKey <= @PrevTimekey 
											                                   AND ACH.EffectiveToTimeKey   >= @PrevTimekey
                                                                               AND CCH.EffectiveFromTimeKey <= @PrevTimekey 
											                                   AND CCH.EffectiveToTimeKey   >= @PrevTimekey

  									                               		   										
      LEFT JOIN DimAssetClass DC	                                       ON  DC.AssetClassAlt_Key=ACH.FinalAssetClassAlt_Key
                                                                               AND DC.EffectiveFromTimeKey <= @PrevTimekey
											                                   AND DC.EffectiveToTimeKey   >= @PrevTimekey
											                               								   
	LEFT JOIN DimCurrency  DCR				                               ON  DCR.CurrencyAlt_Key=ACH.CurrencyAlt_Key
											                               	   AND DCR.EffectiveFromTimeKey <= @PrevTimekey
											                               	   AND DCR.EffectiveToTimeKey   >= @PrevTimekey
											                              

	where ACH.FinalAssetClassAlt_Key<>1
	Option(recompile)


IF(OBJECT_ID('tempdb..#DATA') is not null)
DROP TABLE #DATA


	select * into #DATA from(
select * from #DATA_Curr
union all
select * from #DATA_Prev	
)a

--select * from #DATA
IF(OBJECT_ID('tempdb..#FinalData') is not null)
DROP TABLE #FinalData
--select * from #DATA  order by  CustID
select 
UCIFID	
,d.CustID	
,d.AccountID	
,AssetClass	
,FinalAssetClassAlt_Key	
,FLAG
,AssetName_Q1
,AssetName_Q2  
	  into #FinalData
from #DATA D
INNER JOIN(
SELECT  AccountID,ISNULL([Q1],'') AssetName_Q1,ISNULL([Q2],'') AssetName_Q2
				FROM 
				(		SELECT AccountID ,AssetClass ,FLAG 
						FROM #DATA
				) Pvt
				PIVOT       
				(
				MAX(AssetClass) FOR FLAG IN ([Q1],[Q2])
				) P
       WHERE (ISNULL([Q1],'')<>'STANDARD' and ISNULL([Q2],'') ='STANDARD')

	   ) ASSET1 ON ASSET1.AccountID=D.AccountID 
order by CustID
	  

IF(OBJECT_ID('tempdb..#maindata') is not null)
DROP TABLE #maindata

select * into #maindata from #FinalData where   AssetName_Q1 not in('','STANDARD') and AssetName_Q2='STANDARD'

--SELECT * FROM  #maindata
select distinct 
                 a. UCIFID	
,a.CustID	
,A.AccountID	
,AssetName_Q2 AssetClass
   ,DS.SOURCENAME                                                        AS               Sourcename
				  ,CCH.PANNO				                                             AS	              PANNumber
				  ,CCH.CustomerName		                                                 AS	              CustomerName
				  ,DP.ProductName		                                                 AS               ProductName
				  ,ACH.DPD_MAX	                                                         AS	              DPDMax
				 
				  ,CONVERT(VARCHAR(20),ACH.UpgDate ,103)		                         AS	              UpgradeDate
				  ,DCR.CurrencyCode		                                                 AS	              CurrencyCode
				  ,(ABS(ACH.Balance))/@Cost			                                     AS	              Balance
				
				  --,DA.assetclassname  AssetClass
from  #maindata  A
inner join   pro.AccountCal_hist		 ACH                           on A.AccountID=ach.customeracid
                                                                        AND ACH.EffectiveFromTimeKey <= @TimeKey 
											                                   AND ACH.EffectiveToTimeKey   >= @TimeKey

	   INNER JOIN PRO.customercal_hist CCH                                 ON  ACH.CustomerEntityID=CCH.CustomerEntityID
                                                                             
                                                                               AND CCH.EffectiveFromTimeKey <= @TimeKey 
											                                   AND CCH.EffectiveToTimeKey   >= @TimeKey

     --INNER JOIN DimAssetClass DA                                         ON DA.AssetClassAlt_Key= ACH.FinalAssetClassAlt_Key    
					--									                       AND DA.EffectiveFromTimeKey <= @TimeKey
					--									                       AND DA.EffectiveToTimeKey   >= @TimeKey
											                               								   
	LEFT JOIN DimCurrency  DCR				                               ON  DCR.CurrencyAlt_Key=ACH.CurrencyAlt_Key
											                               	   AND DCR.EffectiveFromTimeKey <= @TimeKey
											                               	   AND DCR.EffectiveToTimeKey   >= @TimeKey
											                               
	LEFT JOIN DimProduct DP					                               	ON  DP.ProductAlt_Key=ACH.ProductAlt_Key
											                                 	AND DP.EffectiveFromTimeKey <= @TimeKey
											                               	    AND DP.EffectiveToTimeKey	>= @TimeKey
											                               
  	LEFT JOIN DimSourceDB DS				                               	ON DS.SourceAlt_Key=ACH.SourceAlt_Key
											                                   AND DS.EffectiveFromTimeKey <= @TimeKey
											                               	   AND DS.EffectiveToTimeKey   >= @TimeKey


option (recompile)

	  
GO