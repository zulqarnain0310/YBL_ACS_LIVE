SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO





 Create PROCEDURE [dbo].[Rpt-20039]
   @TimeKey AS INT,
   @RangeFrom DECIMAL(30,2),
   @RangeTo   DECIMAL(30,2),
   @Cost      AS FLOAT
AS 

--DECLARE 
--      @TimeKey AS INT =26844,
--	  @RangeFrom DECIMAL(30,2)=NULL,
--	  @RangeTo   DECIMAL(30,2)=NULL,
--	  @Cost      AS FLOAT=1


------BEGIN

SET NOCOUNT ON

BEGIN


 IF OBJECT_ID('TEMPDB..#CorporateSecurity') IS NOT NULL
   DROP TABLE #CorporateSecurity
   

SELECT SUM(ISNULL(L.CurntQtrRv,0)) as CurrentValue ,l.UCIF_ID 
into #CorporateSecurity
FROM PRO.Customercal_hist L
where L.EFFECTIVEFROMTIMEKEY=@TIMEKEY AND L.EFFECTIVETOTIMEKEY=@TIMEKEY
AND L.CurntQtrRv>0
group by l.UCIF_ID


CREATE NONCLUSTERED INDEX IX_UCIF_ID    ON #CorporateSecurity   (UCIF_ID)
   INCLUDE (CurrentValue)

------------ADDED ON 13092023 by Pradeep-----------------

IF OBJECT_ID('TEMPDB.dbo.#CUSTOMERCAL20039') IS NOT NULL											
DROP TABLE #CUSTOMERCAL20039 											
											
select * into #CUSTOMERCAL20039 FROM PRO.Customercal_hist L where L.EFFECTIVEFROMTIMEKEY=@TIMEKEY AND L.EFFECTIVETOTIMEKEY=@TIMEKEY											
											
IF OBJECT_ID('TEMPDB.dbo.#accountcal20039') IS NOT NULL											
DROP TABLE #accountcal20039											
											
select * into #accountcal20039 FROM PRO.accountcal_hist L where L.EFFECTIVEFROMTIMEKEY=@TIMEKEY AND L.EFFECTIVETOTIMEKEY=@TIMEKEY											
											
											
IF OBJECT_ID('TEMPDB..#AccountAdd') IS NOT NULL											
DROP TABLE #AccountAdd											
											
select distinct CustomerAcID,'N' AS Match 											
into #AccountAdd											
from curdat.AdvSecurityDetailAccountLevel a											
where a.EFFECTIVEFROMTIMEKEY=@TIMEKEY AND a.EFFECTIVETOTIMEKEY=@TIMEKEY  and CreatedBy='tp'											
 											
											
update a set Match='y'											
from #AccountAdd a											
inner join #accountcal20039 b											
on a.CustomerAcID=b.CustomerAcID											
where SourceAlt_Key=1											
											
delete from #AccountAdd where Match='N'											

IF OBJECT_ID('TEMPDB..#AccountCountCheck') IS NOT NULL
   DROP TABLE #AccountCountCheck

select CustomerAcID,UCIF_ID,isnull(Balance,0) as Balance,LineCode,DEG_RELAX_MSME,Productcode,SourceSystemCustomerID,AccountEntityID,SourceAlt_Key
into  #AccountCountCheck  
FROM pro.ACCOUNTCAL_HIST   A WHERE (                        					
LineCode like'%294ODAGFD%'  OR LineCode like'%ODAG-FCNR%' OR LineCode like'%IBUODAGFD%' 
	
 OR LineCode like'%226TLAGFD%' OR LineCode like'%FCYAG-DEP%' OR LineCode like'%LDAG-FCNR%'  or LineCode like'%FD-EXCLE%' ---Added on 20240524
or DEG_RELAX_MSME='Y'
or 
productcode in (		
'904','909','933','944','981','983','985','986' )        
      					
)       
and a.EFFECTIVEFROMTIMEKEY=@TIMEKEY AND a.EFFECTIVETOTIMEKEY=@TIMEKEY  
UNION 											
select B.CustomerAcID,UCIF_ID,isnull(Balance,0) as Balance,LineCode,DEG_RELAX_MSME,Productcode,SourceSystemCustomerID,AccountEntityID,SourceAlt_Key											
FROM #AccountAdd A											
INNER JOIN #accountcal20039 B											
ON A.CustomerAcID=B.CustomerAcID											

option(recompile)

CREATE NONCLUSTERED INDEX IX_acc_ID_    ON #AccountCountCheck   (UCIF_ID)
   INCLUDE (CustomerAcID,LineCode,Balance,DEG_RELAX_MSME,Productcode,SourceSystemCustomerID,AccountEntityID,SourceAlt_Key)

 IF OBJECT_ID('TEMPDB..#balnce') IS NOT NULL
   DROP TABLE #balnce

select UCIF_ID,sum(Balance) Balance into #balnce
FROM  #AccountCountCheck  A WHERE (                        					
LineCode like'%294ODAGFD%'  OR LineCode like'%ODAG-FCNR%' OR LineCode like'%IBUODAGFD%' 
	
 OR LineCode like'%226TLAGFD%' OR LineCode like'%FCYAG-DEP%' OR LineCode like'%LDAG-FCNR%'  or LineCode like'%FD-EXCLE%' ---Added on 20240524            					
)                           					
group by UCIF_ID                          					
order by UCIF_ID


CREATE NONCLUSTERED INDEX IX_UCIF_ID_1    ON #balnce   (UCIF_ID)
   INCLUDE (Balance)

IF OBJECT_ID('TEMPDB..#FD_UCIf_Security') IS NOT NULL
   DROP TABLE #FD_UCIf_Security

select UCIF_ID,sum(isnull(CurrentValue,0)) CurrentValue into #FD_UCIf_Security
FROM  CURDAT.AdvSecurityDetailUcifLevel  A
WHERE   a.EFFECTIVEFROMTIMEKEY=@TIMEKEY AND a.EFFECTIVETOTIMEKEY=@TIMEKEY                           					
group by UCIF_ID                          					
order by UCIF_ID
option(recompile)
CREATE NONCLUSTERED INDEX IX_UCIF_ID_2    ON #FD_UCIf_Security   (UCIF_ID)
   INCLUDE (CurrentValue)
------------==============-----------------
IF OBJECT_ID('TEMPDB..#Data') IS NOT NULL
   DROP TABLE #Data
select * into #Data from
(


select							
A.BranchCode as [BRANCH CODE],							
B.PANNO as PAN,							
A.UCIF_ID as [UCIC ID],							
B.CustSegmentCode as [Cust Segment],							
A.ActSegmentCode as [Acc Segment],							
B.CustomerPartnerSegment as [Customer Segment],							
A.RefCustomerID as [CUST ID],							
B.Customername as [CUSTOMER NAME],							
A.Productcode as [PRODUCT CODE],							
C.ProductName as [PRODUCT DISCR],							
A.CustomerAcID as [ACCOUNT NO],	
A.FacilityType as [FacilityType],
isnull(A.Balance,0)/@cost  AS [Balance],
--isnull(A.CurrentLimit,0)/@cost  AS [CurrentLimit],
case when A.DPD_IntService > 0 and  isnull(A.UnserviedInt,0) >0 then isnull(A.UnserviedInt,0)/@cost
     when A.DPD_IntService > 0 and  isnull(A.UnserviedInt,0)=0  then isnull(A.OverdueAmt,0) /@cost
 ELSE 0 END AS  [Overdue Amount],
isnull(A.SecurityValue,0)/@cost AS [SecurityAmount],
case when ( a.LineCode like'%294ODAGFD%'  OR a.LineCode like'%ODAG-FCNR%' OR a.LineCode like'%IBUODAGFD%' 
	
 OR a.LineCode like'%226TLAGFD%' OR a.LineCode like'%FCYAG-DEP%' OR a.LineCode like'%LDAG-FCNR%'    or a.LineCode like'%FD-EXCLE%' ---Added on 20240524  
  ) then isnull(bal.Balance,0)/@cost else null end as [UcifLevelBalance],
case when A.FinalAssetClassAlt_Key=1 then 'STD'							
when A.FinalAssetClassAlt_Key=2 then 'SUB'							
when A.FinalAssetClassAlt_Key=3 then 'DB1'							
when A.FinalAssetClassAlt_Key=4 then 'DB2'							
when A.FinalAssetClassAlt_Key=5 then 'DB3'							
when A.FinalAssetClassAlt_Key=6 then 'LOS' END AS [ENPA ASSET CLASS],							
CONVERT(VARCHAR(10),A.FinalNpaDt,103) AS [ENPA NPA DATE],
A.LineCode AS [Code Line Number],							
ACCVAR.InternalFDFlag AS [Internal Collateral],							
----CASE WHEN A.ProductCode in('660','661','889','237') THEN 'Demand Recovery 90'							
----WHEN A.ProductCode in('681','682','693','694','695','696','715','716','717','718',							
----'755','756','758','763','764','765','766','787','788','789','795','796',							
----'797','798','799','220','740','778','235') THEN 'Demand Recovery 365'							
----ELSE 'Lookback - 90' END AS [Account Logic],							
A.DPD_IntService AS [DPD IntService],							
----isnull(A.Balance,0)/@cost  AS [O/S AMT],							
isnull(A.PrincOutStd,0)/@cost  AS [POS],
--'NA' AS [60DaysCreditAmount],
isnull(A.CreditAmt,0)/@cost  AS [90DaysCreditAmount],							
isnull(A.DebitAmt,0)/@cost  AS [90DaysDebitAmount],							
														
----case when A.FinalAssetClassAlt_Key=1 then 'STD'							
----when A.FinalAssetClassAlt_Key=2 then 'NPA'							
----when A.FinalAssetClassAlt_Key=3 then 'NPA'							
----when A.FinalAssetClassAlt_Key=4 then 'NPA'							
----when A.FinalAssetClassAlt_Key=5 then 'NPA'							
----when A.FinalAssetClassAlt_Key=6 then 'NPA' END  AS [Account Stage],
--'NA' AS [Sum of Credit balance accounts],
--'NA' AS [RM_Code],
--'NA' AS [RM_NAME],
--'NA' AS [TL_Code],
--'NA' AS [TL_NAME]
----ACCVAR.DaysCount AS [Count],
A.Asset_Norm as [Asset_Norm],
ISNULL(cs.CurrentValue,0)/@Cost           AS [UCIFSecurityAmount] ,
case when ( a.LineCode like'%294ODAGFD%'  OR a.LineCode like'%ODAG-FCNR%' OR a.LineCode like'%IBUODAGFD%' 
	
 OR a.LineCode like'%226TLAGFD%' OR a.LineCode like'%FCYAG-DEP%' OR a.LineCode like'%LDAG-FCNR%'  or a.LineCode like'%FD-EXCLE%' ---Added on 20240524    
  )  
  then ISNULL(#FD_UCIf_Security.CurrentValue,0)/@cost else null END AS [UCIFSecurityAmountFDOD],
isnull(A.CurrentLimit,0)/@cost  as [CurrentLimit],
case when ( a.LineCode like'%294ODAGFD%'  OR a.LineCode like'%ODAG-FCNR%' OR a.LineCode like'%IBUODAGFD%' 
	
 OR a.LineCode like'%226TLAGFD%' OR a.LineCode like'%FCYAG-DEP%' OR a.LineCode like'%LDAG-FCNR%'    or a.LineCode like'%FD-EXCLE%' ---Added on 20240524  
  ) then 'FD OD' else ACCVAR.AccountMarking end  as [Marking]
--------ADDED ON 05082023--------
,isnull(A.DPD_Max,0) DPD_Max
--,isnull(A.DPD_IntService,0)  DPD_IntService
,isnull(A.DPD_NoCredit,0) DPD_NoCredit
,isnull(A.DPD_Overdrawn,0) DPD_Overdrawn
,isnull(A.DPD_Overdue,0)  DPD_Overdue
,isnull(A.DPD_StockStmt,0) DPD_StockStmt
,isnull(A.DPD_Renewal,0)DPD_Renewal
,isnull(A.IntOverdue,0)/@cost  IntOverdue

------------ADDED ON 13092023 by Pradeep-----------------

,case when (a.LineCode like'%294ODAGFD%'  OR a.LineCode like'%ODAG-FCNR%' OR a.LineCode like'%IBUODAGFD%' 
	
 OR a.LineCode like'%226TLAGFD%' OR a.LineCode like'%FCYAG-DEP%' OR a.LineCode like'%LDAG-FCNR%'   or a.LineCode like'%FD-EXCLE%' ---Added on 20240524    
  ) 
  then ISNULL(#FD_UCIf_Security.CurrentValue,0)/@cost else null END as FixedDeposit

  ------------==============-----------------

----,ACCVAR.InternalFDFlag	
,case when (a.LineCode like'%294ODAGFD%'  OR a.LineCode like'%ODAG-FCNR%' OR a.LineCode like'%IBUODAGFD%' 
	
 OR a.LineCode like'%226TLAGFD%' OR a.LineCode like'%FCYAG-DEP%' OR a.LineCode like'%LDAG-FCNR%'     or a.LineCode like'%FD-EXCLE%' ---Added on 20240524   
  ) then 'FD OD' else ACCVAR.AccountMarking end as AccountMarking
FROM PRO.CUSTOMERCAL_hist B
INNER JOIN PRO.ACCOUNTCAL_hist A  ON B.SourceSystemCustomerID=A.SourceSystemCustomerID
                                              AND B.EffectiveFromTimeKey=@TimeKey
                                              AND B.EffectiveToTimeKey  =@TimeKey
                                              AND A.EffectiveFromTimeKey=@TimeKey
                                              AND A.EffectiveToTimeKey  =@TimeKey
											    AND ISNULL(A.BANKASSETCLASS,'N')<>'WRITEOFF'
		                                      AND  ISNULL(A.AccountBlkCode1,'N')<>'W' AND  ISNULL(A.AccountBlkCode2,'N')<>'W'
		                                      AND ISNULL(A.Balance,0) > 0  AND ISNULL(A.ProductCode,'') not in ('NSLI' )

INNER JOIN #AccountCountCheck d                        on d.CustomerAcID=a.CustomerAcID						

left join DimProduct C on C.ProductAlt_Key=A.ProductAlt_Key
                                              AND C.EffectiveFromTimeKey<= @TimeKey
                                              AND C.EffectiveToTimeKey>=@TimeKey

left Join PRO.AccountWiseMiscDetailCal_Hist ACCVAR ON A.AccountEntityID=ACCVAR.AccountEntityID
											  AND ACCVAR.EffectiveFromTimeKey=@TimeKey
											  AND ACCVAR.EffectiveToTimeKey  =@TimeKey
											   


LEFT JOIN #CorporateSecurity CS               ON A.UCIF_ID=CS.UCIF_ID
LEFT JOIN #FD_UCIf_Security #FD_UCIf_Security        ON A.UCIF_ID=#FD_UCIf_Security.UCIF_ID
------------==============-----------------

LEFT JOIN #balnce bal               ON A.UCIF_ID=bal.UCIF_ID
------------==============-----------------


where ((ISNULL(A.Balance,0) BETWEEN @RangeFrom AND @rangeto AND @RangeFrom IS NOT NULL AND @RangeTo IS NOT NULL) OR
	  (ISNULL(A.Balance,0)<=@RangeTo AND @rangefrom IS NULL AND @RangeTo IS NOT NULL) OR
	  (ISNULL(A.Balance,0)>=@RangeFrom AND @RangeFrom IS NOT NULL AND @RangeTo IS NULL)OR
	  (@RangeFrom IS NULL AND @RangeTo IS NULL)) 
    --      AND ISNULL(A.BANKASSETCLASS,'N')<>'WRITEOFF'
		  --AND  ISNULL(A.AccountBlkCode1,'N')<>'W' AND  ISNULL(A.AccountBlkCode2,'N')<>'W'
		  --and ISNULL(A.Balance,0) > 0  AND ISNULL(A.ProductCode,'') not in ('NSLI' )
		 
----Order by B.UCIF_ID,B.RefCustomerID

)a
Order by [UCIC ID],[CUST ID]
option(recompile)
END
CREATE NONCLUSTERED INDEX IX_UCIF_ID_2    ON #Data   ([UCIC ID])
INCLUDE ([BRANCH CODE],PAN,[Cust Segment],[Acc Segment],[Customer Segment],[CUST ID],[CUSTOMER NAME],[PRODUCT CODE],
[PRODUCT DISCR],[ACCOUNT NO],	[FacilityType],	[Balance],[Overdue Amount],	[SecurityAmount],	
UcifLevelBalance,[ENPA ASSET CLASS],[ENPA NPA DATE],[Code Line Number],[Internal Collateral],	
[DPD IntService],POS,[90DaysCreditAmount],[90DaysDebitAmount],Asset_Norm,UCIFSecurityAmount,UCIFSecurityAmountFDOD
,CurrentLimit,DPD_Max,DPD_NoCredit	,DPD_Overdrawn	,DPD_Overdue	,DPD_StockStmt	,DPD_Renewal,	IntOverdue	
,FixedDeposit)

SELECT * FROM #Data
option(recompile)
GO