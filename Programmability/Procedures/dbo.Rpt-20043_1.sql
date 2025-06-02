SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO




/*
Created By    :Lipsa
Date          :03/06/2024
Desc          :Daily/Monthly Upgradation report
*/

CREATE PROCEDURE [dbo].[Rpt-20043_1]
@TimeKey AS int,
@Cost      AS FLOAT,
@FrequencyType AS CHAR(1)
AS
		


-- DECLARE  
-- @TimeKey as int=25688
--,@Cost    AS FLOAT=1
--,@FrequencyType AS CHAR(1)='m'



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

 IF OBJECT_ID('TEMPDB..#Customercal_hist_prev') IS NOT NULL
   DROP TABLE #Customercal_hist_prev
    select     RefCustomerid
	          ,Customername
	    --      ,EffectiveToTimeKey
			  --,EffectiveFromTimeKey
			  ,CustomerEntityID
			  ,PANNO

into #Customercal_hist_prev
from PRO.Customercal_hist L
where l.EffectiveFromTimeKey <= @PrevTimekey 
AND l.EffectiveToTimeKey   >= @PrevTimekey
option(recompile)

create clustered index idx_custid on #Customercal_hist_prev(RefCustomerID)

 IF OBJECT_ID('TEMPDB..#Customercal_curr') IS NOT NULL
   DROP TABLE #Customercal_curr
    select     RefCustomerid
	          ,Customername
	    --      ,EffectiveToTimeKey
			  --,EffectiveFromTimeKey
			  ,CustomerEntityID
			  ,PANNO

into #Customercal_curr
from PRO.Customercal_hist L
where l.EffectiveFromTimeKey <= @Timekey 
AND l.EffectiveToTimeKey   >= @TimeKey
option(recompile)

create clustered index idx_custid1 on #Customercal_curr(RefCustomerID)


 IF OBJECT_ID('TEMPDB..#AccountCal_hist_prev') IS NOT NULL
   DROP TABLE #AccountCal_hist_prev
    select     UCIF_ID
	          ,EffectiveFromTimeKey
			  ,EffectiveToTimeKey
			  ,FinalAssetClassAlt_Key
			  ,CustomerAcID
			  ,FinalNpaDt
			  ,DPD_MAX
			  ,Balance
			  ,CustomerEntityID
			  ,CurrencyAlt_Key
			  ,ProductAlt_Key
			  ,SourceAlt_Key
			  ,UpgDate
into #AccountCal_hist_prev
from PRO.AccountCal_hist L
where l.EffectiveFromTimeKey <= @PrevTimekey 
AND l.EffectiveToTimeKey   >= @PrevTimekey

option(recompile)

create clustered index idx_custacid on #AccountCal_hist_prev(CustomerAcID)

IF OBJECT_ID('TEMPDB..#AccountCal_hist_curr') IS NOT NULL
   DROP TABLE #AccountCal_hist_curr
    select     UCIF_ID
	          ,EffectiveFromTimeKey
			  ,EffectiveToTimeKey
			  ,FinalAssetClassAlt_Key
			  ,CustomerAcID
			  ,FinalNpaDt
			  ,DPD_MAX
			  ,Balance
			  ,CustomerEntityID
			  ,CurrencyAlt_Key
			  ,ProductAlt_Key
			  ,SourceAlt_Key
			  ,UpgDate
into #AccountCal_hist_curr
from PRO.AccountCal_hist L
where l.EffectiveFromTimeKey <= @TimeKey 
AND l.EffectiveToTimeKey   >= @Timekey

option(recompile)

create clustered index idx_custacid1 on #AccountCal_hist_curr(CustomerAcID)

IF(OBJECT_ID('tempdb..#DATA_Prev') is not null)
DROP TABLE #DATA_Prev
   SELECT distinct 
	    
	   
	ACH.UCIF_ID                                      
  ,CCH.RefCustomerid                                 
  ,CCH.CustomerName                                  
  ,ACH.CustomerAcID                                  
  ,DA.AssetClassShortName                               
  ,ACH.FinalAssetClassAlt_Key
  ,ach.FinalNpaDt
  ,ACH.EffectiveFromTimeKey
  ,'Q1' FLAG	 			
	into #DATA_Prev		
		 
	   from #AccountCal_hist_prev						                   ACH

	   INNER JOIN #Customercal_hist_prev CCH                                 ON  ACH.CustomerEntityID=CCH.CustomerEntityID
	                                                                          and ACH.FinalAssetClassAlt_Key<>1
                                              --                                 AND ACH.EffectiveFromTimeKey <= @PrevTimekey 
											                                   --AND ACH.EffectiveToTimeKey   >= @PrevTimekey
                                              --                                 AND CCH.EffectiveFromTimeKey <= @PrevTimekey 
											                                   --AND CCH.EffectiveToTimeKey   >= @PrevTimekey
																			   

  		INNER JOIN DimAssetClass DA                                        ON DA.AssetClassAlt_Key= ACH.FinalAssetClassAlt_Key    
														                       AND DA.EffectiveFromTimeKey <= @PrevTimekey
														                       AND DA.EffectiveToTimeKey   >= @PrevTimekey


	--where ACH.FinalAssetClassAlt_Key<>1   
	Option(recompile)

IF(OBJECT_ID('tempdb..#DATA_Curr') is not null)
DROP TABLE #DATA_Curr


   SELECT distinct 
	    
	   
	ACH.UCIF_ID                                      
  ,CCH.RefCustomerid                                 
  ,CCH.CustomerName                                  
  ,ACH.CustomerAcID                                  
  ,DA.AssetClassShortName                               
  ,ACH.FinalAssetClassAlt_Key
  ,ach.FinalNpaDt
  ,ACH.EffectiveFromTimeKey
  ,'Q2' FLAG	 			
	into #DATA_Curr		
	  
	   from #AccountCal_hist_curr						                   ACH
	   inner join #DATA_Prev prev                     on  ACH.CustomerAcID=prev.CustomerAcID
	                                                      and ACH.FinalAssetClassAlt_Key=1 
	   

	   INNER JOIN #Customercal_curr CCH                                 ON  ACH.CustomerEntityID=CCH.CustomerEntityID
                                              --                                 AND ACH.EffectiveFromTimeKey >= @PrevTimekey 
											                                   --AND ACH.EffectiveToTimeKey   <= @TimeKey
                                              --                                 AND CCH.EffectiveFromTimeKey >= @PrevTimekey 
											                                   --AND CCH.EffectiveToTimeKey   <= @TimeKey
																			   

  		INNER JOIN DimAssetClass DA                                        ON DA.AssetClassAlt_Key= ACH.FinalAssetClassAlt_Key    
														                       AND DA.EffectiveFromTimeKey <= @PrevTimekey
														                       AND DA.EffectiveToTimeKey   >= @TimeKey


	--where ACH.FinalAssetClassAlt_Key=1   
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
      d.RefCustomerid    
	  ,CustomerName     
	  ,d.CustomerAcID    
	  ,AssetName_Q1
	  ,AssetName_Q2 
	  ,EffectiveFromTimeKey
	  into #FinalData
from #DATA D
INNER JOIN(
SELECT  CustomerAcID,ISNULL([Q1],'') AssetName_Q1,ISNULL([Q2],'') AssetName_Q2
				FROM 
				(		SELECT CustomerAcID ,AssetClassShortName ,FLAG 
						FROM #DATA
				) Pvt
				PIVOT       
				(
				MAX(AssetClassShortName) FOR FLAG IN ([Q1],[Q2])
				) P
       WHERE (ISNULL([Q1],'')<>'STD' and ISNULL([Q2],'') ='STD')

	   ) ASSET1 ON ASSET1.CustomerAcID=D.CustomerAcID 
order by RefCustomerid
	  

IF(OBJECT_ID('tempdb..#maindata') is not null)
DROP TABLE #maindata

select 	             RefCustomerid	
                    ,CustomerName	
					,CustomerAcID	
					,AssetName_Q1	
					,AssetName_Q2
					,MIN(EffectiveFromTimeKey)EffectiveFromTimeKey
		into #maindata from #FinalData where   AssetName_Q1 not in('','STD') and AssetName_Q2='STD'

		group by  RefCustomerid	
                    ,CustomerName	
					,CustomerAcID	
					,AssetName_Q1	
					,AssetName_Q2
--SELECT * FROM  #maindata
select distinct 
  ACH.UCIF_ID	
,a.RefCustomerID	
,A.CustomerAcID	
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
inner join   #AccountCal_hist_curr		 ACH                           on A.CustomerAcID=ach.customeracid
                                              --                          AND ACH.EffectiveFromTimeKey <= @TimeKey 
											                                   --AND ACH.EffectiveToTimeKey   >= @TimeKey

	   INNER JOIN #Customercal_curr CCH                                 ON  ACH.CustomerEntityID=CCH.CustomerEntityID
                                                                             
                                              --                                 AND CCH.EffectiveFromTimeKey <= @TimeKey 
											                                   --AND CCH.EffectiveToTimeKey   >= @TimeKey
											                               								   
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