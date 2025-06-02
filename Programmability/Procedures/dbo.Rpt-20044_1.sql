SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[Rpt-20044_1]
@TimeKey AS int,
@Cost      AS FLOAT,
@FrequencyType AS CHAR(1)
AS

-- DECLARE  
-- @TimeKey as int=26848
--,@Cost    AS FLOAT=1
--,@FrequencyType AS CHAR(1)='M'

 
  
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

--select @Date,@PrevTimekey


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
			  ,FinalAssetClassAlt_Key
			  ,CustomerAcID
			  ,FinalNpaDt
			  ,DPD_MAX
			  ,Balance
			  ,CustomerEntityID
			  ,CurrencyAlt_Key
			  ,ProductAlt_Key
			  ,SourceAlt_Key
			  --,UpgDate
			  ,ProductCode
			  ,ActSegmentCode
			  ,NPA_Reason
			  ,IntOverdue
			 ,BalanceInCrncy  
			 ,PrincOutStd     
			 ,ExposureType    
			 ,DPD_IntService  
			 ,DPD_Overdrawn   
			 ,DPD_Renewal     
			 ,DPD_Overdue     
			 ,DPD_StockStmt   
			 ,FlgDeg
			 ,ACCOUNTSTATUSDebitFreeze  
			 , FlgRestructure            
			 ,SplCatg1Alt_Key
			 ,SplCatg2Alt_Key
			 ,SplCatg3Alt_Key
			 ,SplCatg4Alt_Key
			 ,EffectiveFromTimeKey
			 ,InitialAssetClassAlt_Key
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
  --,''  FinalNpaDt
  ,ach.FinalNpaDt
  ,ACH.EffectiveFromTimeKey
  ,'Q1' FLAG	 			
	into #DATA_Prev		
		 
	   from #AccountCal_hist_prev							                   ACH

	   INNER JOIN #Customercal_hist_prev CCH                                 ON  ACH.CustomerEntityID=CCH.CustomerEntityID
	                                                                         and  ACH.FinalAssetClassAlt_Key=1 
                                              --                                 AND ACH.EffectiveFromTimeKey <= @PrevTimekey 
											                                   --AND ACH.EffectiveToTimeKey   >= @PrevTimekey
                                              --                                 AND CCH.EffectiveFromTimeKey <= @PrevTimekey 
											                                   --AND CCH.EffectiveToTimeKey   >= @PrevTimekey
																			   

  		INNER JOIN DimAssetClass DA                                        ON DA.AssetClassAlt_Key= ACH.FinalAssetClassAlt_Key    
														                       AND DA.EffectiveFromTimeKey <= @PrevTimekey
														                       AND DA.EffectiveToTimeKey   >= @PrevTimekey


	--where ACH.FinalAssetClassAlt_Key=1   
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
		--select *  
	   from #AccountCal_hist_curr							                   ACH
	   inner join #DATA_Prev prev                     on  ACH.CustomerAcID=prev.CustomerAcID
	  and ACH.FinalAssetClassAlt_Key<>1 

	   INNER JOIN #Customercal_curr CCH                                 ON  ACH.CustomerEntityID=CCH.CustomerEntityID
                                              --                                 AND ACH.EffectiveFromTimeKey >= @PrevTimekey 
											                                   --AND ACH.EffectiveToTimeKey   <= @TimeKey
                                              --                                 AND CCH.EffectiveFromTimeKey >= @PrevTimekey 
											                                   --AND CCH.EffectiveToTimeKey   <= @TimeKey
																			   

  		INNER JOIN DimAssetClass DA                                        ON DA.AssetClassAlt_Key= ACH.FinalAssetClassAlt_Key    
														                       AND DA.EffectiveFromTimeKey <= @PrevTimekey
														                       AND DA.EffectiveToTimeKey   >= @TimeKey


	--where ACH.FinalAssetClassAlt_Key<>1   
	Option(recompile)

IF(OBJECT_ID('tempdb..#timekey') is not null)
DROP TABLE #timekey


----select * from #DATA_Curr where CustomerAcID = 'NBD2903211746247488862seletc z'
select 	CustomerAcID
		,min(EffectiveFromTimeKey) EffectiveFromTimeKey
		into #timekey
		from #DATA_Curr ----where CustomerAcID = 'NBD2903211746247488862' 
		group by 
			CustomerAcID	

IF(OBJECT_ID('tempdb..#DATA_Curr_final') is not null)
DROP TABLE #DATA_Curr_final
	
	select A. * into  #DATA_Curr_final from #DATA_Curr A inner join #timekey B on A.CustomerAcID = B.CustomerAcID and A.EffectiveFromTimeKey = B.EffectiveFromTimeKey
	--where A.CustomerAcID = 'NBD2903211746247488862' 	

IF(OBJECT_ID('tempdb..#DATA') is not null)
DROP TABLE #DATA


	select * into #DATA from(
select * from #DATA_Curr_final
union all
select * from #DATA_Prev	
)a


--select * from #DATA where CustomerAcID = 'NBD2903211746247488862'

IF(OBJECT_ID('tempdb..#FinalData') is not null)
DROP TABLE #FinalData

select 
      	
     UCIF_ID       	
	  ,d.RefCustomerid    
	  ,CustomerName     
	  ,d.CustomerAcID  
	  --,AssetClassShortName  
	  ,AssetName_Q1
	  ,AssetName_Q2 
	  ,FinalNpaDt
	  --,FLAG
	  ,EffectiveFromTimeKey
	  into #FinalData
from #DATA D




INNER JOIN(
SELECT  CustomerAcID,([Q1]) AssetName_Q1,([Q2]) AssetName_Q2
				FROM 
				(		SELECT CustomerAcID ,AssetClassShortName ,FLAG 
						FROM #DATA
				) Pvt
				PIVOT       
				(
				MAX(AssetClassShortName) FOR FLAG IN ([Q1],[Q2])
				) P
       WHERE (([Q1]) ='STD' and ([Q2]) <>'STD')

	   ) ASSET1 ON ASSET1.CustomerAcID=D.CustomerAcID 
--order by ASSET1.REF_ACHCT_NO

--select * from #FinalData where customeracid='079IL2000025'


IF(OBJECT_ID('tempdb..#maindata') is not null)
DROP TABLE #maindata

select distinct 	 RefCustomerid	
                    ,CustomerName	
					,CustomerAcID	
					,AssetName_Q1	
					,AssetName_Q2	
					,MIN(FinalNpaDt)FinalNpaDt
					,MIN(EffectiveFromTimeKey)EffectiveFromTimeKey
 into #maindata 
from #FinalData where  AssetName_Q1='STD'  and AssetName_Q2 not in('STD' ,'') 

group  by            RefCustomerid	
                    ,CustomerName	
					,CustomerAcID	
					,AssetName_Q1	
					,AssetName_Q2
					--,FinalNpaDt
----select * from #maindata WHERE customeracid='079IL2000025'

select distinct 
     ach.UCIF_ID       	
   ,a.RefCustomerid    
   ,a.CustomerName     
   ,a.CustomerAcID  
   ,a.AssetName_Q2  
   ,DA.AssetClassShortName  currentassetClass
   --,a.AssetName_Q1
   --,a.AssetName_Q2 
   --,a.FLAG
  ,DS.sourcename                                        AS                         SOURCESYSTEM   
  ,CCH.PANNO                                            AS                         PAN_Number        
  ,CCH.RefCustomerid								    AS                         Source_System_Customer_ID
  ,ACH.ProductCode                                      AS                         Product_Code       
  ,DP.ProductName                                       AS                         PRODUCT_DESCRIP       
  ,ACH.ActSegmentCode                                   AS                         Product_segment------        
  ,DimAssetClass.AssetClassShortName                    AS                         SOURCE_SYSTEM_ASSET_CLASS     
  ,CONVERT(VARCHAR(20),a.FinalNpaDt,103)              AS                         ENPA_NPA_DATE       
  ,ACH.NPA_Reason                                       AS                         ENPA_NPA_REASON  
  ,ACH.DPD_MAX                                          AS                         Max_DPD_AS_PER_OVERDUE_REPORT     
  ,DCR.CurrencyCode                                     AS                         CONTRACT_CCY--------   
  ,ACH.IntOverdue                                       AS                        OS_INTEREST_AMT  
  ,ACH.Balance                                          AS                         OS_AMT_FCY       
  ,ACH.BalanceInCrncy                                   AS                         OS_AMT_LCY---      
  ,ACH.PrincOutStd                                      AS                         POS      
  ,ACH.ExposureType                                     AS                         ExposureType       
  ,ACH.DPD_IntService                                   AS                         DPD_IntService       
  ,ACH.DPD_Overdrawn                                    AS                         DPD_Overdrawn      
  ,ACH.DPD_Renewal                                      AS                         DPD_Renewal       
  ,ACH.DPD_Overdue                                      AS                         DPD_Overdue      
  ,ACH.DPD_StockStmt                                    AS                         DPD_StockStmt     
  ,CASE WHEN ACH.FlgDeg ='Y' then 'Fresh Slippage'                                      else 'NULL' 
  END                                                   AS                         Npa_Mark       
  ,ACH.ACCOUNTSTATUSDebitFreeze                         AS                         Account_Freeze_Status       
  ,ACH.FlgRestructure                                   AS                         FlgRestructure        
  ,CASE WHEN ISNULL(ACH.SplCatg1Alt_Key,0)=870         
  OR ISNULL(ACH.SplCatg2Alt_Key,0)=870        
  OR ISNULL(ACH.SplCatg3Alt_Key,0)=870   
  OR ISNULL(ACH.SplCatg4Alt_Key,0)=870       
  THEN 'Y'    ELSE 'N'    END                           AS                         FlgFraud 
  ,@FrequencyType  FrequencyType
from  #maindata  A

inner join   #AccountCal_hist_curr		 ACH                           on A.customeracid=ach.customeracid
                                              --                          AND ACH.EffectiveFromTimeKey <= @TimeKey 
											                                   --AND ACH.EffectiveToTimeKey   >= @TimeKey

	   INNER JOIN #Customercal_curr CCH                                 ON  ACH.CustomerEntityID=CCH.CustomerEntityID
                                                                             
                                              --                                 AND CCH.EffectiveFromTimeKey <= @TimeKey 
											                                   --AND CCH.EffectiveToTimeKey   >= @TimeKey

     INNER JOIN DimAssetClass DA                                         ON DA.AssetClassAlt_Key= ACH.FinalAssetClassAlt_Key    
														                       AND DA.EffectiveFromTimeKey <= @TimeKey
														                       AND DA.EffectiveToTimeKey   >= @TimeKey
                                                                           
														
       INNER JOIN DimAssetClass                                            ON  DimAssetClass.AssetClassAlt_Key= ACH.InitialAssetClassAlt_Key
														                       AND DimAssetClass.EffectiveFromTimeKey<=@Timekey
														                       AND DimAssetClass.EffectiveToTimeKey>=@Timekey
											                               								   
	LEFT JOIN DimCurrency  DCR				                               ON  DCR.CurrencyAlt_Key=ACH.CurrencyAlt_Key
											                               	   AND DCR.EffectiveFromTimeKey <= @TimeKey
											                               	   AND DCR.EffectiveToTimeKey   >= @TimeKey
											                               
	LEFT JOIN DimProduct DP					                               	ON  DP.ProductAlt_Key=ACH.ProductAlt_Key
											                                 	AND DP.EffectiveFromTimeKey <= @TimeKey
											                               	    AND DP.EffectiveToTimeKey	>= @TimeKey
											                               
  	LEFT JOIN DimSourceDB DS				                               	ON DS.SourceAlt_Key=ACH.SourceAlt_Key
											                                   AND DS.EffectiveFromTimeKey <= @TimeKey
											                               	   AND DS.EffectiveToTimeKey   >= @TimeKey


--where A.customeracid='NBD2903211746247488862'
option (recompile)
GO