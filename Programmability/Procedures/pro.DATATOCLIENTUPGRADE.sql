SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



/*=========================================
AUTHER : TRILOKI KHANNA
CREATE DATE : 09-01-2019
MODIFY DATE : 09-01-2019
DESCRIPTION : DATATOCLIENT_UPGRADE
--EXEC [PRO].[DATATOCLIENTUPGRADE]
============================================*/

CREATE PROCEDURE [pro].[DATATOCLIENTUPGRADE]
AS
BEGIN
  DECLARE @TIMEKEY INT = (SELECT TIMEKEY FROM PRO.EXTDATE_MISDB WHERE FLG = 'Y')

 DELETE  FROM  PRO.DATATOCLIENT_UPGRADE WHERE TIMEKEY=@TIMEKEY 

INSERT INTO  [PRO].DATATOCLIENT_UPGRADE

(
DateOfData
,BranchCode
,UCIF_ID
,FCRCustomerId
,CustomerName
,SrcSystemCustomerID
,PANNO
,AadharCardNO
,SrcAssetClassCust
,SrcAssetClassCustDesc
,ENPA_AssetClassCust
,SrcNPA_DtCust
,ENPA_NPA_DtCust
,[CustomerAcID/Contact Ref. No]
,SrcSystemName
,FacilityType
,LineCode
,ProductCode
,ProductDescription
,CurrentLimit
,ContiExcessDt
,StockStDt
,IntNotServicedDt
,ReviewDueDt
,OverDueSinceDt
,DPD_Overdrawn
,DPD_StockStmt
,DPD_IntService
,DPD_Renewal
,DPD_Overdue
,DPD_Max
,RefPeriodOverDrawn
,RefPeriodStkStatement
,RefPeriodIntService
,RefPeriodReview
,RefPeriodOverdue
,DegReason
,PNPA_Reason
,SMA_Class
,SMA_Reason
,FLGDEG
,FLGUPG
,FlgPNPA
,FlgSMA
,Balance
,Overdue
,SrcAssetClassAccount
,SrcAssetClassAccountDesc
,ENPA_AssetClassAccount
,SrcNpaDtAccount
,ENPA_NpaDtAccount
,TotalProv
,CommercialFlag
,AccountFlag
,Liability
,CD
,AccountStatus
,Timekey
,ExposureType
,SecurityAmount
,DebitSinceDt
,POS
)


SELECT 

 B.ProcessingDt AS DateOfData
 ,A.BranchCode AS BranchCode
,B.UCIF_ID AS UCIF_ID
,A.RefCustomerID AS FCRCustomerId
,B.CustomerName AS CustomerName
,A.SourceSystemCustomerID AS SrcSystemCustomerID
,B.PANNO AS PANNO
,B.AadharCardNO AS AadharCardNO
,B.BankAssetClass AS SrcAssetClassCust
,CASE WHEN B.SrcAssetClassAlt_Key =1 THEN 'STD'
	  WHEN B.SrcAssetClassAlt_Key =2 THEN 'SUB'
	  WHEN B.SrcAssetClassAlt_Key =3 THEN 'DB1'
	  WHEN B.SrcAssetClassAlt_Key =4 THEN 'DB2'
	  WHEN B.SrcAssetClassAlt_Key =5 THEN 'DB3'
	  WHEN B.SrcAssetClassAlt_Key =6 THEN 'LOS' END AS    SrcAssetClassCustDesc

,CASE WHEN B.SysAssetClassAlt_Key =1 THEN 'STD'
	  WHEN B.SysAssetClassAlt_Key =2 THEN 'SUB'
	  WHEN B.SysAssetClassAlt_Key =3 THEN 'DB1'
	  WHEN B.SysAssetClassAlt_Key =4 THEN 'DB2'
	  WHEN B.SysAssetClassAlt_Key =5 THEN 'DB3'
	  WHEN B.SysAssetClassAlt_Key =6 THEN 'LOS' END AS  ENPA_AssetClassCust

,B.SrcNPA_Dt AS SrcNPA_DtCust
,B.SysNPA_Dt AS ENPA_NPA_DtCust
,A.CustomerAcID AS  [CustomerAcID/Contact Ref. No]
,DSB.SourceDBName AS SrcSystemName
,A.FacilityType AS FacilityType
,A.LineCode AS LineCode
,DP.PRODUCTCODE AS ProductCode
,DP.PRODUCTNAME AS ProductDescription
,A.CurrentLimit AS CurrentLimit
,A.ContiExcessDt AS ContiExcessDt
,A.StockStDt AS StockStDt
,A.IntNotServicedDt AS IntNotServicedDt
,A.ReviewDueDt AS ReviewDueDt
,A.OverDueSinceDt As OverDueSinceDt
,CASE WHEN A.DPD_Overdrawn=32677 THEN NULL ELSE DPD_Overdrawn END AS DPD_Overdrawn
,CASE WHEN A.DPD_StockStmt=32677 THEN NULL ELSE DPD_StockStmt END AS DPD_StockStmt
,CASE WHEN A.DPD_IntService=32677 THEN NULL ELSE DPD_IntService END AS DPD_IntService
,CASE WHEN A.DPD_Renewal=32677 THEN NULL ELSE DPD_Renewal END AS DPD_Renewal
,CASE WHEN A.DPD_Overdue=32677 THEN NULL ELSE DPD_Overdue END AS DPD_Overdue
,A.DPD_Max AS DPD_Max
,CASE WHEN A.RefPeriodOverDrawn =32677 THEN NULL ELSE RefPeriodOverDrawn END AS RefPeriodOverDrawn
,CASE WHEN A.RefPeriodStkStatement =32677 THEN NULL ELSE  RefPeriodStkStatement END AS RefPeriodStkStatement
,CASE WHEN A.RefPeriodIntService =32677 THEN NULL ELSE RefPeriodIntService END  AS RefPeriodIntService 
,CASE WHEN A.RefPeriodReview =32677 THEN NULL ELSE RefPeriodReview END AS RefPeriodReview
,CASE WHEN A.RefPeriodOverdue =32677 THEN NULL ELSE RefPeriodOverdue END AS RefPeriodOverdue
,A.DegReason AS DegReason
,A.PNPA_Reason AS PNPA_Reason
,A.SMA_Class AS SMA_Class
,A.SMA_Reason AS SMA_Reason
,A.FLGDEG AS FLGDEG
,A.FLGUPG AS FLGUPG
,A.FlgPNPA AS FlgPNPA
,A.FlgSMA AS FlgSMA
,ISNULL(A.Balance,0) AS Balance
,ISNULL(A.OverdueAmt,0) AS Overdue
,A.BankAssetClass AS SrcAssetClassAccount
,CASE WHEN A.InitialAssetClassAlt_Key =1 THEN 'STD'
	  WHEN A.InitialAssetClassAlt_Key =2 THEN 'SUB'
	  WHEN A.InitialAssetClassAlt_Key =3 THEN 'DB1'
	  WHEN A.InitialAssetClassAlt_Key =4 THEN 'DB2'
	  WHEN A.InitialAssetClassAlt_Key =5 THEN 'DB3'
	  WHEN A.InitialAssetClassAlt_Key =6 THEN 'LOS' END AS    SrcAssetClassAccountDesc

,CASE WHEN A.FinalAssetClassAlt_Key =1 THEN 'STD'
	  WHEN A.FinalAssetClassAlt_Key =2 THEN 'SUB'
	  WHEN A.FinalAssetClassAlt_Key =3 THEN 'DB1'
	  WHEN A.FinalAssetClassAlt_Key =4 THEN 'DB2'
	  WHEN A.FinalAssetClassAlt_Key =5 THEN 'DB3'
	  WHEN A.FinalAssetClassAlt_Key =6 THEN 'LOS' END AS  ENPA_AssetClassAccount

,A.InitialNpaDt AS SrcNpaDtAccount
,A.FinalNpaDt AS ENPA_NpaDtAccount
,A.TotalProvision AS TotalProv
,DC.CommercialFlagCode AS CommercialFlag
,A.AccountFlag AS AccountFlag
,A.Liability AS Liability
,A.CD AS CD 
,A.AccountStatus AS AccountStatus
,@TIMEKEY AS TIMEKEY
,A.ExposureType
,B.CurntQtrRv
,A.DebitSinceDt
,A.PrincOutStd
 
FROM PRO.ACCOUNTCAL A INNER JOIN PRO.CUSTOMERCAL  B ON A.CustomerEntityID=B.CustomerEntityID
 
LEFT JOIN DIMASSETCLASS D ON D.ASSETCLASSALT_KEY=A.FINALASSETCLASSALT_KEY AND D.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND D.EFFECTIVETOTIMEKEY>=@TIMEKEY

LEFT JOIN DIMPRODUCT DP ON  A.PRODUCTALT_KEY=DP.PRODUCTALT_KEY AND DP.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND DP.EFFECTIVETOTIMEKEY>=@TIMEKEY

LEFT JOIN DimCommercialFlag DC ON  A.CommercialFlag_AltKey=DC.CommercialFlagAlt_Key AND DC.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND DC.EFFECTIVETOTIMEKEY>=@TIMEKEY

LEFT JOIN DimSourceDB DSB ON  A.SourceAlt_Key=DSB.SourceAlt_Key AND DSB.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND DSB.EFFECTIVETOTIMEKEY>=@TIMEKEY


WHERE  A.FLGUPG='U'   AND (ISNULL(A.Balance,0)>0 OR ISNULL(A.PrincOutStd,0)>0)

ORDER BY BranchCode DESC

END





GO