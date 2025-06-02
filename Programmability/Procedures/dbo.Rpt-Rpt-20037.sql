SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO





 CREATE PROCEDURE [dbo].[Rpt-Rpt-20037]
   @TimeKey AS INT,
-- @Source   VARCHAR(200),
   @RangeFrom DECIMAL(30,2),
   @RangeTo   DECIMAL(30,2),
   @Cost      AS FLOAT
AS 

--DECLARE 
--      @TimeKey AS INT =27195,
--      ----@Source   VARCHAR(200)='1',
--	  @RangeFrom DECIMAL(30,2)=NULL,
--	  @RangeTo   DECIMAL(30,2)=NULL,
--	  @Cost      AS FLOAT=1


BEGIN


--IF OBJECT_ID('TEMPDB..##SecurityFDOD') IS NOT NULL     
-- DROP TABLE ##SecurityFDOD     
         
      
-- SELECT SUM(ISNULL(L.CurrentValue,0)) as CurrentValue ,l.UCIF_ID      
-- into ##SecurityFDOD     
-- FROM curdat.AdvSecurityDetailUcifLevel L     
-- where EffectiveFromTimeKey  >= @Timekey and EffectiveFROMTimeKey <=@Timekey     
-- group by l.UCIF_ID  



IF OBJECT_ID('TEMPDB.dbo.#CUSTOMERCAL20037') IS NOT NULL             
DROP TABLE #CUSTOMERCAL20037              
             
select PANNO,CustSegmentCode,CustomerPartnerSegment,Customername,CurntQtrRv,UCIF_ID,SourceSystemCustomerID,RefCustomerID,
EffectiveFromTimeKey,EffectiveToTimeKey 
into #CUSTOMERCAL20037 
FROM PRO.Customercal_hist L where L.EFFECTIVEFROMTIMEKEY=@TimeKey AND L.EFFECTIVETOTIMEKEY=@TimeKey  

IF OBJECT_ID('TEMPDB.dbo.#accountcal20037') IS NOT NULL             
DROP TABLE #accountcal20037             
             
select BranchCode,UCIF_ID,ActSegmentCode,RefCustomerID,Productcode,CustomerAcID,FinalAssetClassAlt_Key,FinalNpaDt
,LineCode,Balance,PrincOutStd,CreditAmt,DebitAmt,SourceSystemCustomerID,ProductAlt_Key,AccountEntityID,
DPD_IntService,UnserviedInt,Asset_Norm,SecurityValue,CurrentLimit,OverdueAmt,EffectiveFromTimeKey,EffectiveToTimeKey,
SourceAlt_Key,BANKASSETCLASS,AccountBlkCode1,AccountBlkCode2
into #accountcal20037 FROM PRO.accountcal_hist L where L.EFFECTIVEFROMTIMEKEY=@TimeKey AND L.EFFECTIVETOTIMEKEY=@TimeKey 

 IF OBJECT_ID('TEMPDB..#CorporateSecurity') IS NOT NULL
   DROP TABLE #CorporateSecurity
   

SELECT SUM(ISNULL(L.CurntQtrRv,0)) as CurrentValue ,l.UCIF_ID 
into #CorporateSecurity
--FROM PRO.Customercal_hist L
from #CUSTOMERCAL20037 L
where L.EFFECTIVEFROMTIMEKEY=@TimeKey AND L.EFFECTIVETOTIMEKEY=@TimeKey
AND L.CurntQtrRv>0
group by l.UCIF_ID


CREATE NONCLUSTERED INDEX IX_UCIF_ID    ON #CorporateSecurity   (UCIF_ID)  
   INCLUDE (CurrentValue)  


select							
A.BranchCode as [BRANCH CODE],							
B.PANNO as PAN,							
A.UCIF_ID as [UCIC ID],							
B.CustSegmentCode as [Segment],							
A.ActSegmentCode as [ActSegmentCode],							
B.CustomerPartnerSegment as [CustomerPartnerSegment],							
A.RefCustomerID as [CUST ID],							
B.Customername as [CUSTOMER NAME],							
A.Productcode as [PRODUCT CODE],							
C.ProductName as [PRODUCT NAME],							
A.CustomerAcID as [ACCOUNT NO],							
case when A.FinalAssetClassAlt_Key=1 then 'STD'							
when A.FinalAssetClassAlt_Key=2 then 'SUB'							
when A.FinalAssetClassAlt_Key=3 then 'DB1'							
when A.FinalAssetClassAlt_Key=4 then 'DB2'							
when A.FinalAssetClassAlt_Key=5 then 'DB3'							
when A.FinalAssetClassAlt_Key=6 then 'LOS' END AS [ENPA ASSET CLASS],							
--A.FinalNpaDt AS [ENPA NPA DATE],	
CONVERT(VARCHAR(10),A.FinalNpaDt,103) AS [ENPA NPA DATE],
A.LineCode AS [Code Line Number],							
ACCVAR.InternalFDFlag AS [Internal Collateral],							
CASE WHEN A.ProductCode in('660','661','889','237') THEN 'Demand Recovery 90'							
WHEN A.ProductCode in('681','682','693','694','695','696','715','716','717','718',							
'755','756','758','763','764','765','766','787','788','789','795','796',							
'797','798','799','220','740','235') THEN 'Demand Recovery 365'	-----Removed ProductCode 778 Confirmed by Pankaj Mailed							
ELSE 'Lookback - 90' END AS [Account Logic],							
A.DPD_IntService AS [DPD IntService],							
isnull(A.Balance,0)/@cost  AS [O/S AMT],							
isnull(A.PrincOutStd,0)/@cost  AS [POS],
--'NA' AS [60DaysCreditAmount],
isnull(A.CreditAmt,0)/@cost  AS [90DaysCreditAmount],							
isnull(A.DebitAmt,0)/@cost  AS [90DaysDebitAmount],							
case when A.DPD_IntService > 0 and  isnull(A.UnserviedInt,0) >0 then isnull(A.UnserviedInt,0)/@cost
     when A.DPD_IntService > 0 and  isnull(A.UnserviedInt,0)=0  then isnull(A.OverdueAmt,0) /@cost
 ELSE 0 END AS  [Overdue Amount],															
case when A.FinalAssetClassAlt_Key=1 then 'STD'							
when A.FinalAssetClassAlt_Key=2 then 'NPA'							
when A.FinalAssetClassAlt_Key=3 then 'NPA'							
when A.FinalAssetClassAlt_Key=4 then 'NPA'							
when A.FinalAssetClassAlt_Key=5 then 'NPA'							
when A.FinalAssetClassAlt_Key=6 then 'NPA' END  AS [Account Stage],
--'NA' AS [Sum of Credit balance accounts],
--'NA' AS [RM_Code],
--'NA' AS [RM_NAME],
--'NA' AS [TL_Code],
--'NA' AS [TL_NAME]
ACCVAR.DaysCount AS [Count],
A.Asset_Norm as [Asset_Norm],
isnull(A.SecurityValue,0)/@cost AS [SecurityAmount],
--B.CurntQtrRv as [UCIFSecurityAmount],
ISNULL(CS.CurrentValue,0)/@Cost           AS [UCIFSecurityAmount] ,
--NULL AS [UCIFSecurityAmountFDOD],
case when ( a.LineCode like'%294ODAGFD%'  OR a.LineCode like'%ODAG-FCNR%' OR a.LineCode like'%IBUODAGFD%' 
	
 OR a.LineCode like'%226TLAGFD%' OR a.LineCode like'%FCYAG-DEP%' OR a.LineCode like'%LDAG-FCNR%' OR  LineCode  like'%FD-EXCLE%'   
  ) --then ISNULL(FD.CurrentValue,0)/@cost else null END AS [UCIFSecurityAmountFDOD],
  then ISNULL(ACCVAR.FD_UCIF_Security,0)/@cost else null END AS [UCIFSecurityAmountFDOD],
isnull(A.CurrentLimit,0)/@cost  as [CurrentLimit],
ACCVAR.AccountMarking as [Marking]
			
FROM #CUSTOMERCAL20037 B
INNER JOIN #accountcal20037 A  ON B.SourceSystemCustomerID=A.SourceSystemCustomerID
                                              AND B.EffectiveFromTimeKey=@TimeKey
                                              AND B.EffectiveToTimeKey=@TimeKey
                                              AND A.EffectiveFromTimeKey=@TimeKey
                                              AND A.EffectiveToTimeKey=@TimeKey							
left join DimProduct C on C.ProductAlt_Key=A.ProductAlt_Key
                                              AND C.EffectiveFromTimeKey<= @TimeKey
                                              AND C.EffectiveToTimeKey>=@TimeKey
Inner Join PRO.AccountWiseMiscDetailCal_Hist ACCVAR ON A.AccountEntityID=ACCVAR.AccountEntityID
											  AND ACCVAR.EffectiveFromTimeKey=@TimeKey
											  AND ACCVAR.EffectiveToTimeKey=@TimeKey
--LEFT JOIN ##SecurityFDOD FD                   ON a.UCIF_ID=FD.UCIF_ID 
LEFT JOIN #CorporateSecurity CS               ON A.UCIF_ID=CS.UCIF_ID

where A.SourceAlt_Key=1 --AND A.FinalAssetClassAlt_Key<>1						
	  AND ((ISNULL(A.Balance,0) BETWEEN @RangeFrom AND @rangeto AND @RangeFrom IS NOT NULL AND @RangeTo IS NOT NULL) OR
	  (ISNULL(A.Balance,0)<=@RangeTo AND @rangefrom IS NULL AND @RangeTo IS NOT NULL) OR
	  (ISNULL(A.Balance,0)>=@RangeFrom AND @RangeFrom IS NOT NULL AND @RangeTo IS NULL)OR
	  (@RangeFrom IS NULL AND @RangeTo IS NULL)) 
          AND ISNULL(A.BANKASSETCLASS,'N')<>'WRITEOFF'
		  AND  ISNULL(A.AccountBlkCode1,'N')<>'W' AND  ISNULL(A.AccountBlkCode2,'N')<>'W'
		  and ISNULL(A.Balance,0) > 0  AND ISNULL(A.ProductCode,'') not in ('NSLI' )

Order by B.UCIF_ID,B.RefCustomerID
Drop table #CUSTOMERCAL20037,#accountcal20037,#CorporateSecurity

END
GO