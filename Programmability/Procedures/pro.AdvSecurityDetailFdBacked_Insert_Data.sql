SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROCEDURE [pro].[AdvSecurityDetailFdBacked_Insert_Data]
AS
BEGIN



DECLARE @TIMEKEY INT=(SELECT TimeKey FROM PRO.EXTDATE_MISDB WHERE Flg='Y')



IF OBJECT_ID('TEMPDB..#Temptd_lien_mast_noE') is not  null 
		 DROP TABLE #Temptd_lien_mast_noE

select COD_ACCT_NO, max(cast(COD_DEP_NO as int ))  COD_DEP_NO 
INTO #Temptd_lien_mast_noE
from YBL_ACS_MIS.dbo.td_lien_mast A

where FLG_LIEN_TYPE='E'  
group by a.COD_ACCT_NO
order by a.COD_ACCT_NO

 

IF OBJECT_ID('tempdb..#FDBackedUCIFMarkingDESC') IS NOT NULL
	DROP TABLE #FDBackedUCIFMarkingDESC
select * into #FDBackedUCIFMarkingDESC
from YBL_ACS_MIS.dbo.td_lien_mast A
where TXT_LIEN_DESC is not null
 and (RIGHT(TXT_LIEN_DESC,5) LIKE '%_ODFD%'
  or RIGHT(TXT_LIEN_DESC,5) LIKE '%_LAFD%')
 and TXT_LIEN_DESC not in('100%  LIEN FOR ODFD','110%  LIEN for  FOR ODFD','105%  LIEN  FOR ODFD','100%  LIEN for  FOR ODFD',
'100%  LIEN  FOR ODFD','100%  LIEN for  ODFD','100%Â  LIEN FOR ODFD','105%  LIEN for  FOR ODFD',
'105%  LIEN FOR ODFD','105%Â  LIEN FOR ODFD','105%Â  LIEN forÂ  FOR ODFD','110%  LIEN  FOR ODFD','110%  LIEN FOR ODFD','100% LIEN FOR ODFD','LIEN FOR WB - ODFD','LIEN FOR WB â€“ ODFD','100% Lien against ODFD','FD Lien mark against ODFD',
'LIEN FOR ODFD','Lien marked against ODFD','Lien against ODFD','placed as security for availing ODFD','Lien against our exposure for ODFD','FD margin against ODFD','favour Of Credit Admin for availing ODFD','LIEN IN FAVOUR OF CAD for ODFD'
,'CAD Lien  BB CAD   ODFD','Fvg. BB-CAD for ODFD Fvg. BB-CAD for ODFD','DSRA TWDS ODFD','Lien fvg BB Cad against ODFD','FD Margin for OD CAD Lien ODFD','Fvg BB-CAD for ODFD','Fvg. BB-CAD for ODFD','110% LIEN FOR ODFD','Margin for LAFD','CAD Lien  Quant Broking Pvt Ltd ODFD','CAD Lien-Quant Broking Pvt Ltd ODFD','Lien marke against ODFD','Fvg. BB-CAD for ODFDFvg. BB-CAD for ODFD','Fvg BB-CAD as security for ODFD','Security margin CAD Lien ODFD')
 
 ALTER TABLE #FDBackedUCIFMarkingDESC ADD TXT_LIEN_DESCClean Varchar (130)
 ALTER TABLE #FDBackedUCIFMarkingDESC ADD UCIF_ID Varchar (130)
 
 update #FDBackedUCIFMarkingDESC set TXT_LIEN_DESCClean=SUBSTRING(TXT_LIEN_DESC,1,LEN(TXT_LIEN_DESC)-5)

 UPDATE A SET UCIF_ID=B.UCIC_ID
FROM #FDBackedUCIFMarkingDESC A
INNER JOIN YBL_ACS_MIS.DBO.CustomerData B
ON A.TXT_LIEN_DESCClean=B.SourceSystemCustomerID 
WHERE A.UCIF_ID IS NULL

UPDATE A SET UCIF_ID=B.UCIC_ID
FROM #FDBackedUCIFMarkingDESC A
INNER JOIN YBL_ACS_MIS.DBO.CustomerData B
ON A.TXT_LIEN_DESCClean=B.FCR_CustomerID 
WHERE A.UCIF_ID IS NULL

UPDATE A SET UCIF_ID=B.UCIC_ID
FROM #FDBackedUCIFMarkingDESC A
INNER JOIN YBL_ACS_MIS.DBO.CustomerData B
ON A.TXT_LIEN_DESCClean=B.UCIC_ID 
WHERE A.UCIF_ID IS NULL
 
DELETE FROM CURDAT.AdvSecurityDetailFdBacked WHERE EffectiveFromTimeKey=@TIMEKEY

INSERT INTO CURDAT.AdvSecurityDetailFdBacked
 (
[UCIF_ID] ,
[Security_RefNo],  
[CollateralID],  
[SecurityParticular] ,
[ValuationDate] ,
[ValueAtSanctionTime] ,
[ValuationExpiryDate] ,
[CurrentValue] ,
[AuthorisationStatus],
[EffectiveFromTimeKey] ,
[EffectiveToTimeKey] ,
[CreatedBy]

)

SELECT	
A.[UCIF_ID] ,
A.COD_DEP_NO  AS [Security_RefNo] ,
A.COD_ACCT_NO AS CollateralID,
TXT_LIEN_DESC AS [SecurityParticular] ,
DAT_LIEN AS [ValuationDate] ,
AMT_LIEN AS [ValueAtSanctionTime] ,
DAT_EXP_LIEN AS [ValuationExpiryDate] ,
AMT_LIEN AS [CurrentValue] ,
'A' AS [AuthorisationStatus],
@TIMEKEY AS [EffectiveFromTimeKey] ,
@TIMEKEY AS [EffectiveToTimeKey] ,
'SSIS' AS [CreatedBy]
FROM   #FDBackedUCIFMarkingDESC A
INNER JOIN #Temptd_lien_mast_noE B
ON A.COD_ACCT_NO =B.COD_ACCT_NO
AND A.COD_DEP_NO=B.COD_DEP_NO
where A.[UCIF_ID] is not null

drop table #FDBackedUCIFMarkingDESC


END



GO