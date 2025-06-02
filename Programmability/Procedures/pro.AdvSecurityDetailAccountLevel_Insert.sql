SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROCEDURE [pro].[AdvSecurityDetailAccountLevel_Insert]ASBEGIN
DECLARE @TIMEKEY INT=(SELECT TimeKey FROM PRO.EXTDATE_MISDB WHERE Flg='Y')
DECLARE @TIMEKEYPDay INT=(SELECT TimeKey-1 FROM PRO.EXTDATE_MISDB WHERE Flg='Y')
DECLARE @TIMEKEYPPDay INT=(SELECT TimeKey-2 FROM PRO.EXTDATE_MISDB WHERE Flg='Y')

DELETE FROM CURDAT.AdvSecurityDetailAccountLevel WHERE EffectiveFromTimeKey=@TIMEKEY

	IF OBJECT_ID('TEMPDB..##TD_LIEN_MAST_MAIN') IS NOT  NULL 
         DROP TABLE ##TD_LIEN_MAST_MAIN
		 SELECT * INTO ##TD_LIEN_MAST_MAIN FROM YBL_ACS_MIS.dbo.td_lien_mast

		UPDATE A 
		SET COD_ACCT_NO_BENEF= 
						CASE WHEN RIGHT(TXT_LIEN_DESC,7) LIKE '%TP_ODFD%'  THEN REPLACE(TXT_LIEN_DESC,'_TP_ODFD','')
							 WHEN RIGHT(TXT_LIEN_DESC,7) LIKE '%TP_LAFD%'  THEN REPLACE(TXT_LIEN_DESC,'_TP_LAFD','')
							 WHEN RIGHT(TXT_LIEN_DESC,9) LIKE '%FCNR_ODFD%' THEN REPLACE(TXT_LIEN_DESC,'_FCNR_ODFD','') 
							 WHEN RIGHT(TXT_LIEN_DESC,9) LIKE '%FCNR_LAFD%' THEN REPLACE(TXT_LIEN_DESC,'_FCNR_LAFD','')
						END

		FROM ##TD_LIEN_MAST_MAIN A
		 WHERE 
		 FLG_LIEN_TYPE='E' 
			AND (
						RIGHT(TXT_LIEN_DESC,7) LIKE '%TP_ODFD%' 
					OR  
						RIGHT(TXT_LIEN_DESC,9) LIKE '%FCNR_ODFD%'
					OR
						RIGHT(TXT_LIEN_DESC,7) LIKE '%TP_LAFD%' 
					OR  
						RIGHT(TXT_LIEN_DESC,9) LIKE '%FCNR_LAFD%'
				)


	IF OBJECT_ID('TEMPDB..##TD_LIEN_MAST_COD_ACCT_NO_BENEF') IS NOT  NULL 
         DROP TABLE ##TD_LIEN_MAST_COD_ACCT_NO_BENEF
SELECT COD_ACCT_NO, COD_ACCT_NO_BENEF ,COD_DEP_NO, FLG_LIEN_TYPE
INTO ##TD_LIEN_MAST_COD_ACCT_NO_BENEF
FROM ##TD_LIEN_MAST_MAIN A
WHERE FLG_LIEN_TYPE='O'  
	OR
	(
			FLG_LIEN_TYPE='E' 
		AND (
				RIGHT(TXT_LIEN_DESC,7) LIKE '%TP_ODFD%' 
			OR  
				RIGHT(TXT_LIEN_DESC,9) LIKE '%FCNR_ODFD%'
			OR
				RIGHT(TXT_LIEN_DESC,7) LIKE '%TP_LAFD%' 
			OR  
				RIGHT(TXT_LIEN_DESC,9) LIKE '%FCNR_LAFD%'
			)

	)

IF OBJECT_ID('TEMPDB..##TD_LIEN_MAST_COD_DEP_NO_MAX') IS NOT  NULL 
         DROP TABLE ##TD_LIEN_MAST_COD_DEP_NO_MAX
select COD_ACCT_NO,COD_ACCT_NO_BENEF, max(cast(COD_DEP_NO as int ))  COD_DEP_NO_MX 
INTO ##TD_LIEN_MAST_COD_DEP_NO_MAX
from ##TD_LIEN_MAST_COD_ACCT_NO_BENEF A 
group by A.COD_ACCT_NO_BENEF,a.COD_ACCT_NO


--IF OBJECT_ID('TEMPDB..##TD_LIEN_MAST_COD_DEP_NO_MAX') IS NOT  NULL 
--         DROP TABLE ##TD_LIEN_MAST_COD_DEP_NO_MAX
--select COD_ACCT_NO,COD_ACCT_NO_BENEF, max(cast(COD_DEP_NO as int ))  COD_DEP_NO_MX 
--INTO ##TD_LIEN_MAST_COD_DEP_NO_MAX
--from ##TD_LIEN_MAST_MAIN A
--where FLG_LIEN_TYPE='O'  
--group by A.COD_ACCT_NO_BENEF,a.COD_ACCT_NO

--select * from ##TD_LIEN_MAST_COD_DEP_NO_MAX

IF OBJECT_ID('TEMPDB..##MAX_CH_OD_LIMIT_COD_LIMIT_NO') IS NOT  NULL 
         DROP TABLE ##MAX_CH_OD_LIMIT_COD_LIMIT_NO
SELECT COD_ACCT_NO,MAX(CAST(COD_LIMIT_NO AS INT ))  COD_LIMIT_NO_MX 
INTO ##MAX_CH_OD_LIMIT_COD_LIMIT_NO
 FROM YBL_ACS_MIS.DBO.CH_OD_LIMIT  A
WHERE FLG_INTERNAL_FD='Y'  
GROUP BY A.COD_ACCT_NO

--select * from ##MAX_CH_OD_LIMIT_COD_LIMIT_NO where COD_ACCT_NO in( '111690400002861','115590400000188','078751400013022','078751000002856')
--select * from ##TD_LIEN_MAST_COD_DEP_NO_MAX a
--inner join ##MAX_CH_OD_LIMIT_COD_LIMIT_NO b
--on a.COD_ACCT_NO_BENEF=b.COD_ACCT_NO

IF OBJECT_ID('TEMPDB..##Temptd_lien_mast_noEE') is not  null 
		 DROP TABLE ##Temptd_lien_mast_noEE

select COD_ACCT_NO, max(cast(COD_DEP_NO as int ))  COD_DEP_NO 
INTO ##Temptd_lien_mast_noEE
from YBL_ACS_MIS.dbo.td_lien_mast A

where FLG_LIEN_TYPE='E'  
group by a.COD_ACCT_NO
order by a.COD_ACCT_NO 



IF OBJECT_ID('tempdb..##TD_LIEN_MAST_ODFD') IS NOT NULL
	DROP TABLE ##TD_LIEN_MAST_ODFD
select a.*, cast(NULL as Varchar (130))UCIF_ID, cast(NULL as Varchar (130))TXT_LIEN_DESCClean into ##TD_LIEN_MAST_ODFD
from YBL_ACS_MIS.dbo.td_lien_mast A
where TXT_LIEN_DESC is not null
 and (RIGHT(TXT_LIEN_DESC,5) LIKE '%_ODFD%')
 and TXT_LIEN_DESC not in('100%  LIEN FOR ODFD','110%  LIEN for  FOR ODFD','105%  LIEN  FOR ODFD','100%  LIEN for  FOR ODFD',
'100%  LIEN  FOR ODFD','100%  LIEN for  ODFD','100%  LIEN FOR ODFD','105%  LIEN for  FOR ODFD',
'105%  LIEN FOR ODFD','105%  LIEN FOR ODFD','105%  LIEN for  FOR ODFD','110%  LIEN  FOR ODFD','110%  LIEN FOR ODFD','100% LIEN FOR ODFD','LIEN FOR WB - ODFD','LIEN FOR WB – ODFD','100% Lien against ODFD','FD Lien mark against ODFD',
'LIEN FOR ODFD','Lien marked against ODFD','Lien against ODFD','placed as security for availing ODFD','Lien against our exposure for ODFD','FD margin against ODFD','favour Of Credit Admin for availing ODFD','LIEN IN FAVOUR OF CAD for ODFD'
,'CAD Lien  BB CAD   ODFD','Fvg. BB-CAD for ODFD Fvg. BB-CAD for ODFD','DSRA TWDS ODFD','Lien fvg BB Cad against ODFD','FD Margin for OD CAD Lien ODFD','Fvg BB-CAD for ODFD','Fvg. BB-CAD for ODFD','110% LIEN FOR ODFD','Margin for LAFD','CAD Lien  Quant Broking Pvt Ltd ODFD','CAD Lien-Quant Broking Pvt Ltd ODFD','Lien marke against ODFD','Fvg. BB-CAD for ODFDFvg. BB-CAD for ODFD','Fvg BB-CAD as security for ODFD','Security margin CAD Lien ODFD')
 

 update ##TD_LIEN_MAST_ODFD  set TXT_LIEN_DESCClean=SUBSTRING(TXT_LIEN_DESC,1,LEN(TXT_LIEN_DESC)-5)

 UPDATE A SET UCIF_ID=B.UCIC_ID
FROM ##TD_LIEN_MAST_ODFD A
INNER JOIN YBL_ACS_MIS.DBO.CustomerData B
ON A.TXT_LIEN_DESCClean=B.SourceSystemCustomerID 
WHERE A.UCIF_ID IS NULL

UPDATE A SET UCIF_ID=B.UCIC_ID
FROM ##TD_LIEN_MAST_ODFD A
INNER JOIN YBL_ACS_MIS.DBO.CustomerData B
ON A.TXT_LIEN_DESCClean=B.FCR_CustomerID 
WHERE A.UCIF_ID IS NULL

UPDATE A SET UCIF_ID=B.UCIC_ID
FROM ##TD_LIEN_MAST_ODFD A
INNER JOIN YBL_ACS_MIS.DBO.CustomerData B
ON A.TXT_LIEN_DESCClean=B.UCIC_ID 
WHERE A.UCIF_ID IS NULL

INSERT INTO CURDAT.AdvSecurityDetailAccountLevel ([CustomerAcID] ,[RefCustomerID],[Security_RefNo],[CollateralID],[SecurityDesc] ,[ValuationDate] ,[ValueAtSanctionTime] ,[ValuationExpiryDate] ,[CurrentValue] ,[EffectiveFromTimeKey] ,[EffectiveToTimeKey] ,[CreatedBy],DateCreated,
[OrgCurrentValueInCurrency])

SELECT    
C.[CustomerAcID] ,
C.[RefCustomerID] ,
A.COD_DEP_NO_MX  AS [Security_RefNo] ,
B.COD_ACCT_NO AS CollateralID,-- Account number of the deposit on which the lien is placed.
TXT_LIEN_DESC AS [SecurityDesc] ,-- lien description. this is a free text field to store the description for the lien that is maintained on the time deposit.
DAT_LIEN AS [ValuationDate] , --Date of marking of the lien.
AMT_PRINC_LIEN AS [ValueAtSanctionTime] , --principal lien amount. this is the portion of the lien on the deposit, that is taken from the principal balance of the account.
DAT_EXP_LIEN AS [ValuationExpiryDate] , --expiry date of the lien that has been placed on the time deposit.
AMT_LIEN AS [CurrentValue] , --- Security Amt
@TIMEKEY  AS [EffectiveFromTimeKey] ,
@TIMEKEY  AS [EffectiveToTimeKey] ,
'SSIS' AS [CreatedBy],
GETDATE() as DateCreated,
AMT_LIEN AS [OrgCurrentValueInCurrency]  --- Security Amt
FROM  ##TD_LIEN_MAST_COD_DEP_NO_MAX a
INNER JOIN YBL_ACS_MIS.dbo.TD_LIEN_MAST  b
ON A.COD_ACCT_NO=B.COD_ACCT_NO
AND A.COD_ACCT_NO_BENEF=B.COD_ACCT_NO_BENEF
AND A.COD_DEP_NO_MX=B.COD_DEP_NO AND B.FLG_LIEN_TYPE='O'
INNER JOIN ##MAX_CH_OD_LIMIT_COD_LIMIT_NO D
ON A.COD_ACCT_NO_BENEF=D.COD_ACCT_NO
INNER JOIN PRO.AccountCal C 
ON A.COD_ACCT_NO_BENEF=C.CUSTOMERACID

union all

 select 
C.[CustomerAcID] ,
C.[RefCustomerID] ,
b.COD_DEP_NO  AS [Security_RefNo] ,
B.COD_ACCT_NO AS CollateralID,
TXT_LIEN_DESC AS SecurityDesc ,
DAT_LIEN AS [ValuationDate] ,
AMT_PRINC_LIEN AS [ValueAtSanctionTime] ,
DAT_EXP_LIEN AS [ValuationExpiryDate] ,
AMT_LIEN AS [CurrentValue] ,
@TIMEKEY  AS [EffectiveFromTimeKey] ,
@TIMEKEY AS [EffectiveToTimeKey] ,
'SSISO' AS [CreatedBy],
GETDATE() as DateCreated,
AMT_LIEN AS [OrgCurrentValueInCurrency]  --- Security Amt
 from ##MAX_CH_OD_LIMIT_COD_LIMIT_NO a		
		
 INNER JOIN PRO.AccountCal C ON A.COD_ACCT_NO=C.CUSTOMERACID		
 inner join ##TD_LIEN_MAST_ODFD b  on b.UCIF_ID=c.UCIF_ID
INNER JOIN ##Temptd_lien_mast_noEE E ON E.COD_ACCT_NO=B.COD_ACCT_NO  AND E.COD_DEP_NO=B.COD_DEP_NO

union all

select 
C.[CustomerAcID] ,
C.[RefCustomerID] ,
b.COD_DEP_NO  AS [Security_RefNo] ,
B.COD_ACCT_NO AS CollateralID,
TXT_LIEN_DESC AS SecurityDesc ,
DAT_LIEN AS [ValuationDate] ,
AMT_PRINC_LIEN AS [ValueAtSanctionTime] ,
DAT_EXP_LIEN AS [ValuationExpiryDate] ,
AMT_LIEN AS [CurrentValue] ,
@TIMEKEY  AS [EffectiveFromTimeKey] ,
@TIMEKEY AS [EffectiveToTimeKey] ,
'TP' AS [CreatedBy],
GETDATE() as DateCreated,
AMT_LIEN AS [OrgCurrentValueInCurrency]  --- Security Amt


FROM  ##TD_LIEN_MAST_COD_DEP_NO_MAX a
INNER JOIN ##TD_LIEN_MAST_MAIN  b
ON A.COD_ACCT_NO=B.COD_ACCT_NO
AND A.COD_ACCT_NO_BENEF=B.COD_ACCT_NO_BENEF
AND A.COD_DEP_NO_MX=B.COD_DEP_NO AND B.FLG_LIEN_TYPE='E'
--INNER JOIN ##MAX_CH_OD_LIMIT_COD_LIMIT_NO D
--ON A.COD_ACCT_NO_BENEF=D.COD_ACCT_NO
INNER JOIN PRO.AccountCal C 
ON A.COD_ACCT_NO_BENEF=C.CUSTOMERACID



IF OBJECT_ID('TEMPDB..##TempCurrencyCurrentDay') is not  null 
	  DROP TABLE ##TempCurrencyCurrentDay

select COD_ACCT_NO,a.COD_CCY,CurrencyAlt_Key
into ##TempCurrencyCurrentDay
from  YBL_ACS_MIS.dbo.TD_ACCT_MAST a
INNER JOIN YBL_ACS_MIS.. ODS_FCR_BA_ccy_code B ON A.COD_CCY=B.COD_CCY
INNER JOIN DIMCURRENCY C ON C.CurrencyCode=B.NAM_CCY_SHORT
WHERE (C.EffectiveFromTimeKey<=@TIMEKEY AND C.EffectiveToTimeKey>=@TIMEKEY)
order by a.COD_CCY 

update a set Currencycode=b.COD_CCY,CurrencyAlt_Key=b.CurrencyAlt_Key
from CURDAT.AdvSecurityDetailAccountLevel a
inner join ##TempCurrencyCurrentDay b
on a.CollateralID=b.COD_ACCT_NO
where a.EffectiveFromTimeKey=@TIMEKEY
AND A.Currencycode IS NULL

UPDATE A SET CurrentValueInCurrency=CurrentValue*ConvRate
 FROM CURDAT.AdvSecurityDetailAccountLevel A
INNER JOIN DimCurCovRate B
ON A.CurrencyAlt_Key=B.CurrencyAlt_Key
WHERE a.EffectiveFromTimeKey=@TIMEKEY
 AND (B.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND B.EFFECTIVETOTIMEKEY>=@TIMEKEY)
AND CurrentValueInCurrency IS NULL

IF OBJECT_ID('TEMPDB..##TempCurrencyCurrentPDay') is not  null 
	  DROP TABLE ##TempCurrencyCurrentPDay

select COD_ACCT_NO,a.COD_CCY,CurrencyAlt_Key
into ##TempCurrencyCurrentPDay
from  YBL_ACS_MIS.dbo.TD_ACCT_MAST a
INNER JOIN YBL_ACS_MIS.. ODS_FCR_BA_ccy_code B ON A.COD_CCY=B.COD_CCY
INNER JOIN DIMCURRENCY C ON C.CurrencyCode=B.NAM_CCY_SHORT
WHERE (C.EffectiveFromTimeKey<=@TIMEKEYPDay AND C.EffectiveToTimeKey>=@TIMEKEYPDay)
order by a.COD_CCY 

update a set Currencycode=b.COD_CCY,CurrencyAlt_Key=b.CurrencyAlt_Key
from CURDAT.AdvSecurityDetailAccountLevel a
inner join ##TempCurrencyCurrentPDay b
on a.CollateralID=b.COD_ACCT_NO
where a.EffectiveFromTimeKey=@TIMEKEY
AND A.Currencycode IS NULL

UPDATE A SET CurrentValueInCurrency=CurrentValue*ConvRate
 FROM CURDAT.AdvSecurityDetailAccountLevel A
INNER JOIN DimCurCovRate B
ON A.CurrencyAlt_Key=B.CurrencyAlt_Key
WHERE a.EffectiveFromTimeKey=@TIMEKEY
 AND (B.EFFECTIVEFROMTIMEKEY<=@TIMEKEYPDay AND B.EFFECTIVETOTIMEKEY>=@TIMEKEYPDay)
AND CurrentValueInCurrency IS NULL


IF OBJECT_ID('TEMPDB..##TempCurrencyCurrentPPDay') is not  null 
	  DROP TABLE ##TempCurrencyCurrentPPDay

select COD_ACCT_NO,a.COD_CCY,CurrencyAlt_Key
into ##TempCurrencyCurrentPPDay
from  YBL_ACS_MIS.dbo.TD_ACCT_MAST a
INNER JOIN YBL_ACS_MIS.. ODS_FCR_BA_ccy_code B ON A.COD_CCY=B.COD_CCY
INNER JOIN DIMCURRENCY C ON C.CurrencyCode=B.NAM_CCY_SHORT
WHERE (C.EffectiveFromTimeKey<=@TIMEKEYPPDay  AND C.EffectiveToTimeKey>=@TIMEKEYPPDay )
order by a.COD_CCY 

update a set Currencycode=b.COD_CCY,CurrencyAlt_Key=b.CurrencyAlt_Key
from CURDAT.AdvSecurityDetailAccountLevel a
inner join ##TempCurrencyCurrentPPDay b
on a.CollateralID=b.COD_ACCT_NO
where a.EffectiveFromTimeKey=@TIMEKEY
AND A.Currencycode IS NULL

UPDATE A SET CurrentValueInCurrency=CurrentValue*ConvRate
 FROM CURDAT.AdvSecurityDetailAccountLevel A
INNER JOIN DimCurCovRate B
ON A.CurrencyAlt_Key=B.CurrencyAlt_Key
WHERE a.EffectiveFromTimeKey=@TIMEKEY
 AND (B.EFFECTIVEFROMTIMEKEY<=@TIMEKEYPPDay  AND B.EFFECTIVETOTIMEKEY>=@TIMEKEYPPDay )
AND CurrentValueInCurrency IS NULL

UPDATE  A SET CurrentValueInCurrency=CurrentValueInCurrency/100
FROM CURDAT.AdvSecurityDetailAccountLevel A
WHERE CurrencyAlt_Key=169 AND a.EffectiveFromTimeKey=@TIMEKEY
and ISNULL(CurrentValueInCurrency,0)>0

UPDATE A SET CurrentValue=CurrentValueInCurrency
FROM CURDAT.AdvSecurityDetailAccountLevel A
WHERE  a.EffectiveFromTimeKey=@TIMEKEY AND ISNULL(CurrentValueInCurrency,0)>0
--UPDATE A SET CurrentValue = CurrentValue * CASE WHEN A.CurrencyAlt_Key<>62 THEN ConvRate ELSE 1 END  --FROM CURDAT.AdvSecurityDetailAccountLevel A--LEFT JOIN  YES_MISDB.dbo.DimCurCovRate B--ON A.EffectiveFromTimeKey<=@TIMEKEY AND A.EffectiveToTimeKey>=@TIMEKEY--AND B.EffectiveFromTimeKey<=@TIMEKEY AND B.EffectiveToTimeKey>=@TIMEKEY--AND a.CurrencyAlt_Key=b.CurrencyAlt_KeyIF OBJECT_ID('TEMPDB..##TD_LIEN_MAST_COD_DEP_NO_MAX') IS NOT  NULL          DROP TABLE ##TD_LIEN_MAST_COD_DEP_NO_MAXIF OBJECT_ID('TEMPDB..##MAX_CH_OD_LIMIT_COD_LIMIT_NO') IS NOT  NULL          DROP TABLE ##MAX_CH_OD_LIMIT_COD_LIMIT_NO

IF OBJECT_ID('TEMPDB..##Temptd_lien_mast_noEE') IS NOT  NULL 
         DROP TABLE ##Temptd_lien_mast_noEE

IF OBJECT_ID('TEMPDB..##TempCurrencyCurrentDay') IS NOT  NULL 
         DROP TABLE ##TempCurrencyCurrentDay

IF OBJECT_ID('TEMPDB..##TempCurrencyCurrentPDay') IS NOT  NULL 
         DROP TABLE ##TempCurrencyCurrentPDay

IF OBJECT_ID('TEMPDB..##TempCurrencyCurrentPPDay') IS NOT  NULL 
         DROP TABLE ##TempCurrencyCurrentPPDay

 IF OBJECT_ID('TEMPDB..##TD_LIEN_MAST_ODFD') IS NOT  NULL 
         DROP TABLE ##TD_LIEN_MAST_ODFD

 

END
GO