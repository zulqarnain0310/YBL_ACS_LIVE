SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
Create PROCEDURE [pro].[AdvSecurityDetailUcifLevel_Insert]
AS
BEGIN
DECLARE @TIMEKEY INT=(SELECT TimeKey FROM PRO.EXTDATE_MISDB WHERE Flg='Y')
DECLARE @TIMEKEYPDay INT=(SELECT TimeKey-1 FROM PRO.EXTDATE_MISDB WHERE Flg='Y')
DECLARE @TIMEKEYPPDay INT=(SELECT TimeKey-2 FROM PRO.EXTDATE_MISDB WHERE Flg='Y')


IF OBJECT_ID('TEMPDB..##Temptd_lien_mast_noE') is not  null 
		 DROP TABLE ##Temptd_lien_mast_noE

select COD_ACCT_NO, max(cast(COD_DEP_NO as int ))  COD_DEP_NO 
INTO ##Temptd_lien_mast_noE
from YBL_ACS_MIS.dbo.td_lien_mast A

where FLG_LIEN_TYPE='E'  
group by a.COD_ACCT_NO
order by a.COD_ACCT_NO

IF OBJECT_ID('TEMPDB..##TD_LIEN_MAST_COD_DEP_NO_Mx') IS NOT NULL
    DROP TABLE ##TD_LIEN_MAST_COD_DEP_NO_Mx
SELECT COD_ACCT_NO,max(COD_DEP_NO)COD_DEP_NO_Mx into ##TD_LIEN_MAST_COD_DEP_NO_Mx FROM YBL_ACS_MIS.dbo.td_lien_mast A WHERE FLG_LIEN_TYPE='E'  GROUP BY COD_ACCT_NO

--select * FROM ##TD_LIEN_MAST_COD_DEP_NO_Mx A 
--select * FROM ##TD_LIEN_MAST_ODFD_LAFD
IF OBJECT_ID('tempdb..##TD_LIEN_MAST_ODFD_LAFD') IS NOT NULL
    DROP TABLE ##TD_LIEN_MAST_ODFD_LAFD
SELECT a.*, cast('' as Varchar (50))Derived_UCIF_ID ,cast(NULL as Varchar (130))TXT_LIEN_DESCClean INTO ##TD_LIEN_MAST_ODFD_LAFD
FROM YBL_ACS_MIS.DBO.TD_LIEN_MAST A 
INNER JOIN ##TD_LIEN_MAST_COD_DEP_NO_Mx B
ON a.COD_ACCT_NO=b.COD_ACCT_NO and a.COD_DEP_NO=b.COD_DEP_NO_Mx
WHERE FLG_LIEN_TYPE='E'
AND 
(
	RIGHT(TXT_LIEN_DESC,5) LIKE '%_ODFD%'
OR 
	RIGHT(TXT_LIEN_DESC,5) LIKE '%_LAFD%'
)
AND RIGHT(TXT_LIEN_DESC,10) NOT LIKE '%_ODFD/LAFD'
AND RIGHT(TXT_LIEN_DESC,10) NOT LIKE '%_LAFD/ODFD'

AND 
  (
  ISNUMERIC(REPLACE(TXT_LIEN_DESC,RIGHT(TXT_LIEN_DESC,5),''))=1
  --OR 
  --ISNUMERIC(REPLACE(TXT_LIEN_DESC,RIGHT(TXT_LIEN_DESC,10),''))=1
  )
   
 
 update ##TD_LIEN_MAST_ODFD_LAFD set TXT_LIEN_DESCClean=SUBSTRING(TXT_LIEN_DESC,1,LEN(TXT_LIEN_DESC)-5)


 
 UPDATE A SET Derived_UCIF_ID=B.UCIC_ID
FROM ##TD_LIEN_MAST_ODFD_LAFD A
INNER JOIN YBL_ACS_MIS.DBO.CustomerData B
ON A.TXT_LIEN_DESCClean=B.SourceSystemCustomerID 
WHERE A.Derived_UCIF_ID IS NULL


 UPDATE A SET Derived_UCIF_ID=B.UCIC_ID
FROM ##TD_LIEN_MAST_ODFD_LAFD A
INNER JOIN YBL_ACS_MIS.DBO.CustomerData B
ON A.TXT_LIEN_DESCClean=B.SourceSystemCustomerID 
WHERE A.Derived_UCIF_ID =''

UPDATE A SET Derived_UCIF_ID=B.UCIC_ID
FROM ##TD_LIEN_MAST_ODFD_LAFD A
INNER JOIN YBL_ACS_MIS.DBO.CustomerData B
ON A.TXT_LIEN_DESCClean=B.FCR_CustomerID 
WHERE A.Derived_UCIF_ID IS NULL

UPDATE A SET Derived_UCIF_ID=B.UCIC_ID
FROM ##TD_LIEN_MAST_ODFD_LAFD A
INNER JOIN YBL_ACS_MIS.DBO.CustomerData B
ON A.TXT_LIEN_DESCClean=B.FCR_CustomerID 
WHERE A.Derived_UCIF_ID =''

UPDATE A SET Derived_UCIF_ID=B.UCIC_ID
FROM ##TD_LIEN_MAST_ODFD_LAFD A
INNER JOIN YBL_ACS_MIS.DBO.CustomerData B
ON A.TXT_LIEN_DESCClean=B.UCIC_ID 
WHERE A.Derived_UCIF_ID IS NULL

UPDATE A SET Derived_UCIF_ID=B.UCIC_ID
FROM ##TD_LIEN_MAST_ODFD_LAFD A
INNER JOIN YBL_ACS_MIS.DBO.CustomerData B
ON A.TXT_LIEN_DESCClean=B.UCIC_ID 
WHERE A.Derived_UCIF_ID =''

IF OBJECT_ID('tempdb..##TD_LIEN_MAST_FD_EXCLE') IS NOT NULL
    DROP TABLE ##TD_LIEN_MAST_FD_EXCLE
SELECT a.*, cast('' as Varchar (50))Derived_UCIF_ID ,cast(NULL as Varchar (130))TXT_LIEN_DESCClean INTO ##TD_LIEN_MAST_FD_EXCLE
FROM YBL_ACS_MIS.DBO.TD_LIEN_MAST A 
INNER JOIN ##TD_LIEN_MAST_COD_DEP_NO_Mx B
ON a.COD_ACCT_NO=b.COD_ACCT_NO and a.COD_DEP_NO=b.COD_DEP_NO_Mx
WHERE FLG_LIEN_TYPE='E'
AND (RIGHT(TXT_LIEN_DESC,9) LIKE '%_FD-EXCLE%')
AND ( ISNUMERIC(REPLACE(TXT_LIEN_DESC,RIGHT(TXT_LIEN_DESC,9),''))=1 )
   
update ##TD_LIEN_MAST_FD_EXCLE set TXT_LIEN_DESCClean=SUBSTRING(TXT_LIEN_DESC,1,LEN(TXT_LIEN_DESC)-9)



UPDATE A SET Derived_UCIF_ID=B.UCIC_ID
FROM ##TD_LIEN_MAST_FD_EXCLE A
INNER JOIN YBL_ACS_MIS.DBO.CustomerData B
ON A.TXT_LIEN_DESCClean=B.UCIC_ID 
WHERE A.Derived_UCIF_ID IS NULL

UPDATE A SET Derived_UCIF_ID=B.UCIC_ID
FROM ##TD_LIEN_MAST_FD_EXCLE A
INNER JOIN YBL_ACS_MIS.DBO.CustomerData B
ON A.TXT_LIEN_DESCClean=B.UCIC_ID 
WHERE A.Derived_UCIF_ID =''




UPDATE A SET Derived_UCIF_ID=B.UCIC_ID
FROM ##TD_LIEN_MAST_FD_EXCLE A
INNER JOIN YBL_ACS_MIS.DBO.CustomerData B
ON A.TXT_LIEN_DESCClean=B.FCR_CustomerID 
WHERE A.Derived_UCIF_ID IS NULL

UPDATE A SET Derived_UCIF_ID=B.UCIC_ID
FROM ##TD_LIEN_MAST_FD_EXCLE A
INNER JOIN YBL_ACS_MIS.DBO.CustomerData B
ON A.TXT_LIEN_DESCClean=B.FCR_CustomerID 
WHERE A.Derived_UCIF_ID =''


 UPDATE A SET Derived_UCIF_ID=B.UCIC_ID
FROM ##TD_LIEN_MAST_FD_EXCLE A
INNER JOIN YBL_ACS_MIS.DBO.CustomerData B
ON A.TXT_LIEN_DESCClean=B.SourceSystemCustomerID 
WHERE A.Derived_UCIF_ID IS NULL


 UPDATE A SET Derived_UCIF_ID=B.UCIC_ID
FROM ##TD_LIEN_MAST_FD_EXCLE A
INNER JOIN YBL_ACS_MIS.DBO.CustomerData B
ON A.TXT_LIEN_DESCClean=B.SourceSystemCustomerID 
WHERE A.Derived_UCIF_ID =''









DELETE FROM CURDAT.AdvSecurityDetailUcifLevel WHERE EffectiveFromTimeKey=@TIMEKEY

INSERT INTO CURDAT.AdvSecurityDetailUcifLevel
 (
[UCIF_ID] ,
[Security_RefNo],  
[CollateralID],  
[SecurityParticular] ,
[ValuationDate] ,
[ValueAtSanctionTime] ,
[ValuationExpiryDate] ,
[CurrentValue] ,
[EffectiveFromTimeKey] ,
[EffectiveToTimeKey] ,
[CreatedBy],
[DateCreated],
[OrgCurrentValueInCurrency]
)

SELECT    
Derived_UCIF_ID ,
a.COD_DEP_NO   AS [Security_RefNo] ,
A.COD_ACCT_NO AS CollateralID,
TXT_LIEN_DESC AS [SecurityParticular] ,
DAT_LIEN AS [ValuationDate] ,
AMT_LIEN AS [ValueAtSanctionTime] ,
DAT_EXP_LIEN AS [ValuationExpiryDate] ,
AMT_LIEN AS [CurrentValue] ,
@TIMEKEY AS [EffectiveFromTimeKey] ,
@TIMEKEY AS [EffectiveToTimeKey] ,
'SSIS' AS [CreatedBy],
GETDATE(),
AMT_LIEN AS OrgCurrentValueInCurrency
FROM   ##TD_LIEN_MAST_ODFD_LAFD A
INNER JOIN ##Temptd_lien_mast_noE B
ON A.COD_ACCT_NO =B.COD_ACCT_NO
AND A.COD_DEP_NO=B.COD_DEP_NO
where A.[Derived_UCIF_ID] is not null
Union
SELECT    
Derived_UCIF_ID ,
a.COD_DEP_NO   AS [Security_RefNo] ,
A.COD_ACCT_NO AS CollateralID,
TXT_LIEN_DESC AS [SecurityParticular] ,
DAT_LIEN AS [ValuationDate] ,
AMT_LIEN AS [ValueAtSanctionTime] ,
DAT_EXP_LIEN AS [ValuationExpiryDate] ,
AMT_LIEN AS [CurrentValue] ,
@TIMEKEY AS [EffectiveFromTimeKey] ,
@TIMEKEY AS [EffectiveToTimeKey] ,
'SSIS' AS [CreatedBy],
GETDATE(),
AMT_LIEN AS OrgCurrentValueInCurrency
FROM   ##TD_LIEN_MAST_FD_EXCLE A
INNER JOIN ##Temptd_lien_mast_noE B
ON A.COD_ACCT_NO =B.COD_ACCT_NO
AND A.COD_DEP_NO=B.COD_DEP_NO
where A.[Derived_UCIF_ID] is not null


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
from CURDAT.AdvSecurityDetailUcifLevel a
inner join ##TempCurrencyCurrentDay b
on a.CollateralID=b.COD_ACCT_NO
where a.EffectiveFromTimeKey=@TIMEKEY
AND A.Currencycode IS NULL

UPDATE A SET CurrentValueInCurrency=CurrentValue*ConvRate
 FROM CURDAT.AdvSecurityDetailUcifLevel A
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
from CURDAT.AdvSecurityDetailUcifLevel a
inner join ##TempCurrencyCurrentPDay b
on a.CollateralID=b.COD_ACCT_NO
where a.EffectiveFromTimeKey=@TIMEKEY
AND A.Currencycode IS NULL

UPDATE A SET CurrentValueInCurrency=CurrentValue*ConvRate
 FROM CURDAT.AdvSecurityDetailUcifLevel A
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
from CURDAT.AdvSecurityDetailUcifLevel a
inner join ##TempCurrencyCurrentPPDay b
on a.CollateralID=b.COD_ACCT_NO
where a.EffectiveFromTimeKey=@TIMEKEY
AND A.Currencycode IS NULL

UPDATE A SET CurrentValueInCurrency=CurrentValue*ConvRate
 FROM CURDAT.AdvSecurityDetailUcifLevel A
INNER JOIN DimCurCovRate B
ON A.CurrencyAlt_Key=B.CurrencyAlt_Key
WHERE a.EffectiveFromTimeKey=@TIMEKEY
 AND (B.EFFECTIVEFROMTIMEKEY<=@TIMEKEYPPDay  AND B.EFFECTIVETOTIMEKEY>=@TIMEKEYPPDay )
AND CurrentValueInCurrency IS NULL

UPDATE  A SET CurrentValueInCurrency=CurrentValueInCurrency/100
FROM CURDAT.AdvSecurityDetailUcifLevel A
WHERE CurrencyAlt_Key=169 AND a.EffectiveFromTimeKey=@TIMEKEY
and ISNULL(CurrentValueInCurrency,0)>0

UPDATE A SET CurrentValue=CurrentValueInCurrency
FROM CURDAT.AdvSecurityDetailUcifLevel A
WHERE  a.EffectiveFromTimeKey=@TIMEKEY AND ISNULL(CurrentValueInCurrency,0)>0



IF OBJECT_ID('TEMPDB..##TD_LIEN_MAST_COD_DEP_NO_Mx') IS NOT NULL
    DROP TABLE ##TD_LIEN_MAST_COD_DEP_NO_Mx

IF OBJECT_ID('TEMPDB..##Temptd_lien_mast_noE') IS NOT NULL
    DROP TABLE ##Temptd_lien_mast_noE

IF OBJECT_ID('TEMPDB..##TempCurrencyCurrentDay') IS NOT NULL
    DROP TABLE ##TempCurrencyCurrentDay

IF OBJECT_ID('TEMPDB..##TempCurrencyCurrentPDay') IS NOT NULL
    DROP TABLE ##TempCurrencyCurrentPDay

IF OBJECT_ID('TEMPDB..##TempCurrencyCurrentPPDay') IS NOT NULL
    DROP TABLE ##TempCurrencyCurrentPPDay



END
GO