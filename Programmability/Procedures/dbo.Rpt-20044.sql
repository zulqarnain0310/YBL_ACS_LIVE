SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[Rpt-20044]
@TimeKey AS int,
@Cost      AS FLOAT,
@FrequencyType AS CHAR(1)
AS


-- DECLARE  
-- @TimeKey as int=27188
--,@Cost    AS FLOAT=1
--,@FrequencyType AS CHAR(1)='D'

 

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




IF(OBJECT_ID('tempdb..#DATA_Curr') is not null)
DROP TABLE #DATA_Curr

IF(OBJECT_ID('tempdb..#DATA_Prev') is not null)
DROP TABLE #DATA_Prev

	   SELECT distinct 
	    
	   
        
   ACH.UCIF_ID                                          AS                         UCIF_ID       
  ,CCH.RefCustomerid                                    AS                         FCR_CustomerID             
  ,CCH.CustomerName                                     AS                         Customer_Name       
  ,ACH.CustomerAcID                                     AS                         REF_ACHCT_NO  
  ,DA.AssetClassShortName                               AS                         ENPA_ASSET_CLASS   ---------     
  ,ACH.FinalAssetClassAlt_Key
  ,'Q2' FLAG	 			
	into #DATA_Curr		
			
	   from pro.AccountCal_hist							                   ACH

	   INNER JOIN PRO.customercal_hist CCH                                 ON  ACH.CustomerEntityID=CCH.CustomerEntityID
                                                                               AND ACH.EffectiveFromTimeKey <= @TimeKey 
											                                   AND ACH.EffectiveToTimeKey   >= @TimeKey
                                                                               AND CCH.EffectiveFromTimeKey <= @TimeKey 
											                                   AND CCH.EffectiveToTimeKey   >= @TimeKey

       INNER JOIN DimAssetClass DA                                         ON DA.AssetClassAlt_Key= ACH.FinalAssetClassAlt_Key    
														                       AND DA.EffectiveFromTimeKey <= @TimeKey
														                       AND DA.EffectiveToTimeKey   >= @TimeKey
 
											                               								  

	where ACH.FinalAssetClassAlt_Key<>1
	Option(recompile)

--select * from #DATA_Curr	


	   SELECT distinct 
	    
	   
	                ACH.UCIF_ID                                          AS                         UCIF_ID       
  ,CCH.RefCustomerid                                    AS                         FCR_CustomerID             
  ,CCH.CustomerName                                     AS                         Customer_Name       
  ,ACH.CustomerAcID                                     AS                         REF_ACHCT_NO  
  ,DA.AssetClassShortName                               AS                         ENPA_ASSET_CLASS   ---------     
  ,ACH.FinalAssetClassAlt_Key
  ,'Q1' FLAG	 			
	into #DATA_Prev		
		 
	   from pro.AccountCal_hist							                   ACH

	   inner join #DATA_Curr B on ACH.CustomerAcID=b.REF_ACHCT_NO

	   INNER JOIN PRO.customercal_hist CCH                                 ON  ACH.CustomerEntityID=CCH.CustomerEntityID
                                                                               AND ACH.EffectiveFromTimeKey <= @PrevTimekey 
											                                   AND ACH.EffectiveToTimeKey   >= @PrevTimekey
                                                                               AND CCH.EffectiveFromTimeKey <= @PrevTimekey 
											                                   AND CCH.EffectiveToTimeKey   >= @PrevTimekey
																			   --AND CustomerEntityID=236523

  		INNER JOIN DimAssetClass DA                             ON DA.AssetClassAlt_Key= ACH.FinalAssetClassAlt_Key    
														AND DA.EffectiveFromTimeKey <= @PrevTimekey
														AND DA.EffectiveToTimeKey   >= @PrevTimekey


	where ACH.FinalAssetClassAlt_Key=1    --AND ACH.EffectiveFromTimeKey <= @PrevTimekey  AND ACH.EffectiveToTimeKey   >= @PrevTimekey
	--and CustomerAcID in ( select CustomerAcID from #DATA_Curr)
	Option(recompile)

	--select count(1) from #DATA_Prev



IF(OBJECT_ID('tempdb..#DATA') is not null)
DROP TABLE #DATA


	select * into #DATA from(
select * from #DATA_Curr
union all
select * from #DATA_Prev	
)a

--select * from #DATA  order by  FCR_CustomerID


IF(OBJECT_ID('tempdb..#FinalData') is not null)
DROP TABLE #FinalData

select 
      	
     UCIF_ID       	
	  ,d.FCR_CustomerID    
	  ,Customer_Name     
	  ,d.REF_ACHCT_NO  
	  ,ENPA_ASSET_CLASS  
	  ,AssetName_Q1
	  ,AssetName_Q2 
	  ,FLAG
	  into #FinalData
from #DATA D




INNER JOIN(
SELECT  REF_ACHCT_NO,([Q1]) AssetName_Q1,([Q2]) AssetName_Q2
				FROM 
				(		SELECT REF_ACHCT_NO ,ENPA_ASSET_CLASS ,FLAG 
						FROM #DATA
				) Pvt
				PIVOT       
				(
				MAX(ENPA_ASSET_CLASS) FOR FLAG IN ([Q1],[Q2])
				) P
       WHERE (([Q1]) ='STD' and ([Q2]) <>'STD')

	   ) ASSET1 ON ASSET1.REF_ACHCT_NO=D.REF_ACHCT_NO 
--order by ASSET1.REF_ACHCT_NO

--select * from #FinalData(nolock)


IF(OBJECT_ID('tempdb..#maindata') is not null)
DROP TABLE #maindata

select * into #maindata 
from #FinalData where  AssetName_Q1='STD'  and ENPA_ASSET_CLASS not in('STD' ,'')  



select distinct 
     a.UCIF_ID       	
   ,a.FCR_CustomerID    
   ,a.Customer_Name     
   ,a.REF_ACHCT_NO  
   ,a.ENPA_ASSET_CLASS  
   ,a.AssetName_Q1
   ,a.AssetName_Q2 
   ,a.FLAG
  ,DS.sourcename                                        AS                         SOURCESYSTEM   
  ,CCH.PANNO                                            AS                         PAN_Number        
  ,CCH.RefCustomerid								    AS                         Source_System_Customer_ID
  ,ACH.ProductCode                                      AS                         Product_Code       
  ,DP.ProductName                                       AS                         PRODUCT_DESCRIP       
  ,ACH.ActSegmentCode                                   AS                         Product_segment------        
  ,DimAssetClass.AssetClassShortName                     AS                         SOURCE_SYSTEM_ASSET_CLASS     
  ,CONVERT(VARCHAR(20),ACH.FinalNpaDt,103)              AS                         ENPA_NPA_DATE       
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
  ,@FrequencyType   FrequencyType
from  #maindata  A

inner join   pro.AccountCal_hist		 ACH                           on A.REF_ACHCT_NO=ach.customeracid
                                                                        AND ACH.EffectiveFromTimeKey <= @TimeKey 
											                                   AND ACH.EffectiveToTimeKey   >= @TimeKey

	   INNER JOIN PRO.customercal_hist CCH                                 ON  ACH.CustomerEntityID=CCH.CustomerEntityID
                                                                             
                                                                               AND CCH.EffectiveFromTimeKey <= @TimeKey 
											                                   AND CCH.EffectiveToTimeKey   >= @TimeKey

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

--select * from #FinalData where  REF_ACHCT_NO in(
--'PLN000501049655',
--'0001006150000065115',
--'0001001010003823826',
--'0001006160000017149')

option (recompile)
GO