SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROCEDURE [pro].[AdvSecurityDetailCollateralTag_Insert_Data]
AS
BEGIN



DECLARE @TIMEKEY INT=(SELECT TimeKey FROM PRO.EXTDATE_MISDB WHERE Flg='Y')

 
DELETE FROM CURDAT.AdvSecurityDetailCollateralTag WHERE EffectiveFromTimeKey=@TIMEKEY

IF OBJECT_ID('TEMPDB..#TempMaxcod_limit_no') is not  null 
		 DROP TABLE #TempMaxcod_limit_no

select COD_ACCT_NO,max(cast(cod_limit_no as int ))  cod_limit_no 
into #TempMaxcod_limit_no
 from YBL_ACS_MIS.dbo.ch_od_limit  A
where FLG_INTERNAL_FD='Y'  
group by A.COD_ACCT_NO
order by A.COD_ACCT_NO

IF OBJECT_ID('TEMPDB..#Temptd_lien_mast_no') is not  null 
		 DROP TABLE #Temptd_lien_mast_no

select COD_ACCT_NO,COD_ACCT_NO_BENEF, max(cast(COD_DEP_NO as int ))  COD_DEP_NO 
INTO #Temptd_lien_mast_no
from YBL_ACS_MIS.dbo.td_lien_mast A

where FLG_LIEN_TYPE='O'  
group by A.COD_ACCT_NO_BENEF,a.COD_ACCT_NO
order by A.COD_ACCT_NO_BENEF,a.COD_ACCT_NO


IF OBJECT_ID('tempdb..#FDBackedUCIFMarkingDESCInternal') IS NOT NULL
	DROP TABLE #FDBackedUCIFMarkingDESCInternal
select * into #FDBackedUCIFMarkingDESCInternal
from YBL_ACS_MIS.dbo.td_lien_mast A
where TXT_LIEN_DESC is not null
 and (RIGHT(TXT_LIEN_DESC,5) LIKE '%_ODFD%')
 and TXT_LIEN_DESC not in('100%  LIEN FOR ODFD','110%  LIEN for  FOR ODFD','105%  LIEN  FOR ODFD','100%  LIEN for  FOR ODFD',
'100%  LIEN  FOR ODFD','100%  LIEN for  ODFD','100%Â  LIEN FOR ODFD','105%  LIEN for  FOR ODFD',
'105%  LIEN FOR ODFD','105%Â  LIEN FOR ODFD','105%Â  LIEN forÂ  FOR ODFD','110%  LIEN  FOR ODFD','110%  LIEN FOR ODFD','100% LIEN FOR ODFD','LIEN FOR WB - ODFD','LIEN FOR WB â€“ ODFD','100% Lien against ODFD','FD Lien mark against ODFD',
'LIEN FOR ODFD','Lien marked against ODFD','Lien against ODFD','placed as security for availing ODFD','Lien against our exposure for ODFD','FD margin against ODFD','favour Of Credit Admin for availing ODFD','LIEN IN FAVOUR OF CAD for ODFD'
,'CAD Lien  BB CAD   ODFD','Fvg. BB-CAD for ODFD Fvg. BB-CAD for ODFD','DSRA TWDS ODFD','Lien fvg BB Cad against ODFD','FD Margin for OD CAD Lien ODFD','Fvg BB-CAD for ODFD','Fvg. BB-CAD for ODFD','110% LIEN FOR ODFD','Margin for LAFD','CAD Lien  Quant Broking Pvt Ltd ODFD','CAD Lien-Quant Broking Pvt Ltd ODFD','Lien marke against ODFD','Fvg. BB-CAD for ODFDFvg. BB-CAD for ODFD','Fvg BB-CAD as security for ODFD','Security margin CAD Lien ODFD')
 
 ALTER TABLE #FDBackedUCIFMarkingDESCInternal ADD TXT_LIEN_DESCClean Varchar (130)
 ALTER TABLE #FDBackedUCIFMarkingDESCInternal ADD UCIF_ID Varchar (130)
 
 update #FDBackedUCIFMarkingDESCInternal set TXT_LIEN_DESCClean=SUBSTRING(TXT_LIEN_DESC,1,LEN(TXT_LIEN_DESC)-5)

 UPDATE A SET UCIF_ID=B.UCIC_ID
FROM #FDBackedUCIFMarkingDESCInternal A
INNER JOIN YBL_ACS_MIS.DBO.CustomerData B
ON A.TXT_LIEN_DESCClean=B.SourceSystemCustomerID 
WHERE A.UCIF_ID IS NULL

UPDATE A SET UCIF_ID=B.UCIC_ID
FROM #FDBackedUCIFMarkingDESCInternal A
INNER JOIN YBL_ACS_MIS.DBO.CustomerData B
ON A.TXT_LIEN_DESCClean=B.FCR_CustomerID 
WHERE A.UCIF_ID IS NULL

UPDATE A SET UCIF_ID=B.UCIC_ID
FROM #FDBackedUCIFMarkingDESCInternal A
INNER JOIN YBL_ACS_MIS.DBO.CustomerData B
ON A.TXT_LIEN_DESCClean=B.UCIC_ID 
WHERE A.UCIF_ID IS NULL

INSERT INTO CURDAT.AdvSecurityDetailCollateralTag
 (
 [CustomerAcID] ,
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
C.[CustomerAcID] ,
A.COD_DEP_NO  AS [Security_RefNo] ,
B.COD_ACCT_NO AS CollateralID,
TXT_LIEN_DESC AS [SecurityParticular] ,
DAT_LIEN AS [ValuationDate] ,
AMT_PRINC_LIEN AS [ValueAtSanctionTime] ,
DAT_EXP_LIEN AS [ValuationExpiryDate] ,
AMT_LIEN AS [CurrentValue] ,
'A' AS [AuthorisationStatus],
@TIMEKEY  AS [EffectiveFromTimeKey] ,
@TIMEKEY  AS [EffectiveToTimeKey] ,
'SSIS' AS [CreatedBy]
FROM  #Temptd_lien_mast_no a
inner join YBL_ACS_MIS.dbo.td_lien_mast  b
on a.COD_ACCT_NO=b.COD_ACCT_NO
and a.COD_ACCT_NO_BENEF=b.COD_ACCT_NO_BENEF
and a.COD_DEP_NO=b.COD_DEP_NO and b.FLG_LIEN_TYPE='O'
INNER JOIN PRO.AccountCal C ON A.COD_ACCT_NO_BENEF=C.CUSTOMERACID

union all

 select
C.[CustomerAcID] ,
b.COD_DEP_NO  AS [Security_RefNo] ,
B.COD_ACCT_NO AS CollateralID,
TXT_LIEN_DESC AS [SecurityParticular] ,
DAT_LIEN AS [ValuationDate] ,
AMT_PRINC_LIEN AS [ValueAtSanctionTime] ,
DAT_EXP_LIEN AS [ValuationExpiryDate] ,
AMT_LIEN AS [CurrentValue] ,
'A' AS [AuthorisationStatus],
@TIMEKEY  AS [EffectiveFromTimeKey] ,
@TIMEKEY AS [EffectiveToTimeKey] ,
'SSISO' AS [CreatedBy]

 from #TempMaxcod_limit_no a		
		
 INNER JOIN PRO.AccountCal C ON A.COD_ACCT_NO=C.CUSTOMERACID		
 inner join #FDBackedUCIFMarkingDESCInternal b  on b.UCIF_ID=c.UCIF_ID		


DROP TABLE #TempMaxcod_limit_no
DROP TABLE #Temptd_lien_mast_no
DROP TABLE #FDBackedUCIFMarkingDESCInternal

END



GO