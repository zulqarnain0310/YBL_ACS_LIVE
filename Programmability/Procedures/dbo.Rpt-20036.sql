﻿SET QUOTED_IDENTIFIER OFF

SET ANSI_NULLS ON
GO
--USE [YBL_ACS]
--GO
--/****** Object:  StoredProcedure [dbo].[Rpt-20036]    Script Date: 05/08/2024 10:50:05 ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO
--/*
--CREATE BY		:	Baijayanti
--CREATE DATE	    :	06-10-2022
--DISCRIPTION		:   Security Erosion Report
--*/

Create PROC [dbo].[Rpt-20036]  
  @TimeKey AS INT
,@Cost    AS FLOAT
AS 

--select * from SysDayMatrix where date='2024-07-27'

--DECLARE 
--@TimeKey AS INT=27237
--,@Cost    AS FLOAT=1
--, @TimeKey1 AS INT
--set @TimeKey1 = (@TimeKey-1)

SET NOCOUNT ON ;  

Declare @PROCESSDATE DATE =(SELECT DATE FROM SysDayMatrix WHERE TimeKey=@TimeKey)

Declare @TimeKey_D AS Varchar(20)=@TimeKey
DECLARE @DataBase varchar(10)='YBL_ACS_'
DECLARE @Year varchar(10) = (SELECT year(date) FROM SysDayMatrix WHERE TimeKey=@TIMEKEY) 
DECLARE @TableName varchar(50)='.dbo.CustomerCal_Main_' 
DECLARE @TableName1 varchar(50)='.dbo.AccountCal_Main_' 
DECLARE @Month varchar(10) = (SELECT LEFT(datename(MM,Date),3) FROM SysDayMatrix a WHERE TimeKey=@TIMEKEY)
--select @Month
DECLARE @DerivedTable VARCHAR(100) =@DataBase+''+@Year+''+''+@TableName+''+@Year+'_'+@Month 
DECLARE @DerivedTable1 VARCHAR(100) =@DataBase+''+@Year+''+''+@TableName1+''+@Year+'_'+@Month 
--SELECT @DerivedTable
--SELECT @DerivedTable1
Declare @SelectSQL Varchar(Max)

IF OBJECT_ID('TEMPDB..##CTE_CustomerWiseBalanceUCIF') IS NOT NULL
   DROP TABLE ##CTE_CustomerWiseBalanceUCIF

 SET @SelectSQL= 'SELECT A.UCIF_ID,SUM(ISNULL(A.PrincOutStd,0)) PrincOutStd ,
SUM(ISNULL(A.SecurityValue,0)) SecurityValue	

INTO ##CTE_CustomerWiseBalanceUCIF FROM '+@DerivedTable1+ ' A
 INNER JOIN '+@DerivedTable+ ' B ON A.SourceSystemCustomerID=B.SourceSystemCustomerID
              and A.UCIF_ID=B.UCIF_ID
WHERE   ( b.SysAssetClassAlt_Key NOT IN (select AssetClassAlt_Key from DimAssetClass where AssetClassShortName ='+'''STD'''+' AND EffectiveFromTimeKey<='+@TimeKey_D+' AND EffectiveToTimeKey>='+@TimeKey_D+' )
 AND ISNULL(B.FlgDeg,'+'''N'''+')<>'+'''Y'''+') AND (ISNULL(B.FlgProcessing,'+'''N'''+')='+'''N'''+') 
AND B.RefCustomerID<>'+'''0'''+'and( A.UCIF_ID IS NOT NULL AND A.UCIF_ID<>'+'''0'''+' )
 and ISNULL(A.PrincOutStd,0)>0 
 and A.SourceAlt_Key in(1,2) AND a.FinalAssetClassAlt_Key > 1
  AND ISNULL(A.BANKASSETCLASS,'+'''N'''+')<>'+'''WRITEOFF'''+'
  AND ISNULL(A.ProductCode,'+''''''+') not in ('+'''NSLI'''+','+'''NSLB'''+', '+'''NSLR'''+','+'''TRGC'+''','+'''TREC'''+')
   AND a.EffectiveFromTimeKey='+@TimeKey_D+' 
AND a.EffectiveToTimeKey='+@TimeKey_D+'
 AND b.EffectiveFromTimeKey='+@TimeKey_D+' 
AND b.EffectiveToTimeKey='+@TimeKey_D+'

GROUP BY A.UCIF_ID'

EXEC (@SelectSQL)

--IF OBJECT_ID('TEMPDB..#CTE_CustomerWiseBalanceUCIF') IS NOT NULL
--   DROP TABLE #CTE_CustomerWiseBalanceUCIF

--SELECT A.UCIF_ID,SUM(ISNULL(A.PrincOutStd,0)) PrincOutStd ,
--SUM(ISNULL(A.SecurityValue,0)) SecurityValue	

--INTO #CTE_CustomerWiseBalanceUCIF FROM PRO.ACCOUNTCAL_hist A
-- INNER JOIN PRO.CUSTOMERCAL_hist B ON A.SourceSystemCustomerID=B.SourceSystemCustomerID
--              and A.UCIF_ID=B.UCIF_ID
--WHERE   ( b.SysAssetClassAlt_Key NOT IN (select AssetClassAlt_Key from DimAssetClass where AssetClassShortName ='STD' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY )
-- AND ISNULL(B.FlgDeg,'N')<>'Y') AND (ISNULL(B.FlgProcessing,'N')='N') 
--AND B.RefCustomerID<>'0'and( A.UCIF_ID IS NOT NULL AND A.UCIF_ID<>'0' )
-- and ISNULL(A.PrincOutStd,0)>0 
-- and A.SourceAlt_Key in(1,2) AND a.FinalAssetClassAlt_Key > 1
--  AND ISNULL(A.BANKASSETCLASS,'N')<>'WRITEOFF'
--  AND ISNULL(A.ProductCode,'') not in ('NSLI','NSLB', 'NSLR','TRGC','TREC')
--   AND a.EffectiveFromTimeKey=@TimeKey 
--AND a.EffectiveToTimeKey=@TimeKey
-- AND b.EffectiveFromTimeKey=@TimeKey 
--AND b.EffectiveToTimeKey=@TimeKey

--GROUP BY A.UCIF_ID










--select * from #CTE_CustomerWiseBalanceUCIF where UCIF_ID='10457157'


---------------------------------------------Final Selection---------------------------
SELECT 
CCH.UCIF_ID,
CCH.refCustomerID																							  AS CustomerID,
CCH.CustomerName,
CCH.PANNO,
CONVERT(VARCHAR(20),CCH.SysNPA_Dt,103)																			      AS [NPA Date],
CASE WHEN (	 (MONTH(@PROCESSDATE) IN(3,12) AND DAY(@PROCESSDATE)=31)
	  OR (MONTH(@PROCESSDATE) IN(6,9)  AND DAY(@PROCESSDATE)=30)
	) and CCH.FlgErosion='Y' THEN PAC.AssetClassName																			   
	     ELSE FAC.AssetClassName  
	     END																										  AS [Prv Asset Class],
FAC.AssetClassName																								      AS [Current Asset Class],

ISNULL((SELECT SUM(ISNULL(PrvQtrRV,0)) FROM PRO.CUSTOMERCAL_hist L where  L.UCIF_ID= CCH.UCIF_ID 
AND L.EFFECTIVEFROMTIMEKEY=@TIMEKEY AND L.EFFECTIVETOTIMEKEY=@TIMEKEY),0)											  AS [Per Security Value],
	
ISNULL((SELECT SUM(ISNULL(CurntQtrRv,0)) 	 FROM PRO.CUSTOMERCAL_hist L  
where L.UCIF_ID= CCH.UCIF_ID  
AND L.EFFECTIVEFROMTIMEKEY=@TIMEKEY AND L.EFFECTIVETOTIMEKEY=@TIMEKEY),0) 	 + ISNULL(RS.SecurityValue,0)									AS [Security Value] ,

--ISNULL((SELECT SUM(ISNULL(CurntQtrRv,0)) FROM PRO.CUSTOMERCAL_hist L where L.UCIF_ID= CCH.UCIF_ID 
--AND L.EFFECTIVEFROMTIMEKEY=@TIMEKEY AND L.EFFECTIVETOTIMEKEY=@TIMEKEY),0)										  AS [Security Value],	
			    
CAST( ISNULL(RS.PrincOutStd,0) /@Cost  AS DECIMAL(30,2))																				  AS [Current Balance Outstanding],


--ISNULL((SELECT   CAST(SUM(CASE WHEN AC1.SourceAlt_Key in (1,2)  and ISNULL(AC1.PrincOutStd,0) >0
--         THEN ISNULL(AC1.PrincOutStd,0)
--	     ELSE 0
--	     END)/@Cost  AS DECIMAL(30,2))		 FROM PRO.AccountCAL_hist AC1  
--where AC1.UCIF_ID= CCH.UCIF_ID  
--AND AC1.EFFECTIVEFROMTIMEKEY=@TIMEKEY AND AC1.EFFECTIVETOTIMEKEY=@TIMEKEY),0) AS [Current Balance Outstanding1] ,	



--(ISNULL((SELECT SUM(ISNULL(CurntQtrRv,0)) FROM PRO.CUSTOMERCAL_hist L where L.UCIF_ID= CCH.UCIF_ID 
--AND L.EFFECTIVEFROMTIMEKEY=@TIMEKEY AND L.EFFECTIVETOTIMEKEY=@TIMEKEY),0)
--/CAST(NULLIF(SUM(CASE WHEN ACH.SourceAlt_Key in (1,2)
--         THEN ISNULL(ACH.PrincOutStd,0)
--	     ELSE 0
--	     END)/@Cost,0)  AS DECIMAL(30,2)))*100																		  AS [Security Erosion (%)],


((ISNULL((SELECT SUM(ISNULL(CurntQtrRv,0)) FROM PRO.CUSTOMERCAL_hist L where L.UCIF_ID= CCH.UCIF_ID 
AND L.EFFECTIVEFROMTIMEKEY=@TIMEKEY AND L.EFFECTIVETOTIMEKEY=@TIMEKEY),0) + ISNULL(RS.SecurityValue,0))
/CAST(NULLIF( ISNULL(RS.PrincOutStd,0) /@Cost,0)  AS DECIMAL(30,2)))*100																		  AS [Security Erosion (%)],




CASE WHEN CCH.FlgErosion='Y' THEN 'Yes' ELSE 'No' END FlgErosion

FROM PRO.CustomerCal_Hist CCH   
LEFT JOIN PRO.AccountCal_Hist ACH       ON ACH.SourceSystemCustomerID=CCH.SourceSystemCustomerID
                                              AND ACH.EffectiveFromTimeKey=@TimeKey 
										      AND ACH.EffectiveToTimeKey=@TimeKey
LEFT JOIN ##CTE_CustomerWiseBalanceUCIF RS on CCH.UCIF_ID=Rs.UCIF_ID
LEFT join Curdat.AdvCustNPAdetail ACN      ON CCH.SourceSystemCustomerID=ACN.SourceSystemCustomerID
										      AND ACN.EffectiveToTimeKey=@TimeKey-1
LEFT JOIN DimAssetClass PAC              ON ACN.Cust_AssetClassAlt_Key=PAC.AssetClassAlt_Key
                                             AND PAC.EffectiveFromTimeKey<=@TimeKey 
											 AND PAC.EffectiveToTimeKey>=@TimeKey
INNER JOIN DimAssetClass FAC              ON CCH.SysAssetClassAlt_Key=FAC.AssetClassAlt_Key
                                             AND FAC.EffectiveFromTimeKey<=@TimeKey 
											 AND FAC.EffectiveToTimeKey>=@TimeKey

LEFT  JOIN DimProduct                                  ON DimProduct.ProductAlt_Key=ACH.ProductAlt_Key AND
                                                           DimProduct.EffectiveFromTimeKey<=@Timekey AND
                                                                                                               DimProduct.EffectiveToTimeKey>=@Timekey

WHERE  ACH.FinalAssetClassAlt_Key>1 and ACH.SourceAlt_Key in (1,2)
 AND ISNULL(ACH.BANKASSETCLASS,'N')<>'WRITEOFF'
 AND ISNULL(ACH.ProductCode,'') not in ('NSLI','NSLB', 'NSLR','TRGC','TREC')
 AND ISNULL(ACH.balance,0)>0
AND CCH.EffectiveFromTimeKey=@TimeKey 
AND CCH.EffectiveToTimeKey=@TimeKey --and ACH.UCIF_ID='10051544'

GROUP BY
CCH.UCIF_ID,
--ACH.UCIF_ID,
CCH.refCustomerID,
CCH.CustomerName,
CCH.PANNO,
CCH.SysNPA_Dt,
PAC.AssetClassName,
FAC.AssetClassName
,CCH.FlgErosion
,RS.SecurityValue
,ISNULL(RS.PrincOutStd,0)
order by CCH.UCIF_ID,CCH.refCustomerID

OPTION(RECOMPILE)


GO