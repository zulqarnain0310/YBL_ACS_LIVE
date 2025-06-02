SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/*
CREATE BY		:	Baijayanti
CREATE DATE	    :	06-10-2022
DISCRIPTION		:   Security Erosion Report
*/

Create PROC [dbo].[Rpt-20036_Erosion]  
  @TimeKey AS INT
 ,@Cost    AS FLOAT
AS 

--DECLARE 
--@TimeKey AS INT=26627
--,@Cost    AS FLOAT=1
--, @TimeKey1 AS INT
--set @TimeKey1 = (@TimeKey-1)

SET NOCOUNT ON ;  

Declare @PROCESSDATE DATE =(SELECT DATE FROM SysDayMatrix WHERE TimeKey=@TimeKey)
---------------------------------------------Final Selection---------------------------
SELECT 
CCH.UCIF_ID,
CCH.SourceSystemCustomerID																							  AS CustomerID,
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

ISNULL((SELECT SUM(ISNULL(CurntQtrRv,0)) FROM PRO.CUSTOMERCAL_hist L where L.UCIF_ID= CCH.UCIF_ID 
AND L.EFFECTIVEFROMTIMEKEY=@TIMEKEY AND L.EFFECTIVETOTIMEKEY=@TIMEKEY),0)											  AS [Security Value],	
			    
CAST(SUM(CASE WHEN ACH.SourceAlt_Key in (1,2,7)
         THEN ISNULL(ACH.PrincOutStd,0)
	     ELSE 0
	     END)/@Cost  AS DECIMAL(30,2))																				  AS [Current Balance Outstanding],

(ISNULL((SELECT SUM(ISNULL(CurntQtrRv,0)) FROM PRO.CUSTOMERCAL_hist L where L.UCIF_ID= CCH.UCIF_ID 
AND L.EFFECTIVEFROMTIMEKEY=@TIMEKEY AND L.EFFECTIVETOTIMEKEY=@TIMEKEY),0)
/CAST(NULLIF(SUM(CASE WHEN ACH.SourceAlt_Key in (1,2,7)
         THEN ISNULL(ACH.PrincOutStd,0)
	     ELSE 0
	     END)/@Cost,0)  AS DECIMAL(30,2)))*100																		  AS [Security Erosion (%)]

,CASE WHEN CCH.FlgErosion='Y' THEN 'Yes' ELSE 'No' END FlgErosion

FROM PRO.CustomerCal_Hist CCH   
LEFT JOIN PRO.AccountCal_Hist ACH       ON ACH.SourceSystemCustomerID=CCH.SourceSystemCustomerID
                                              AND ACH.EffectiveFromTimeKey=@TimeKey 
										      AND ACH.EffectiveToTimeKey=@TimeKey
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

WHERE  CCH.sysassetclassalt_key>1 and CCH.SourceAlt_Key in (1,2,7)
 AND ISNULL(CCH.BANKASSETCLASS,'N')<>'WRITEOFF'
 AND ISNULL(ACH.ProductCode,'') not in ('NSLI' )
AND CCH.EffectiveFromTimeKey=@TimeKey 
AND CCH.EffectiveToTimeKey=@TimeKey
GROUP BY
CCH.UCIF_ID,
CCH.SourceSystemCustomerID,
CCH.CustomerName,
CCH.PANNO,
CCH.SysNPA_Dt,
PAC.AssetClassName,
FAC.AssetClassName
,CCH.FlgErosion
order by CCH.UCIF_ID,CCH.SourceSystemCustomerID

OPTION(RECOMPILE)


GO