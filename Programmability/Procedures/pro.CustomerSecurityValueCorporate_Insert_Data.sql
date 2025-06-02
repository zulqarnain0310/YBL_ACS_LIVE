SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROCEDURE [pro].[CustomerSecurityValueCorporate_Insert_Data]
AS
BEGIN



DECLARE @TIMEKEY INT=(SELECT TimeKey FROM PRO.EXTDATE_MISDB WHERE Flg='Y')

DECLARE @SecurityMaxId AS INT SET @SecurityMaxId=(SELECT  ISNULL(Max(SecurityEntityID),0)  FROM dbo.AdvSecurityValueDetail)
DECLARE @SecurityEntityID INT=0 
SELECT @SecurityEntityID=MAX(SecurityEntityID) FROM  curdat.AdvSecurityValueDetail
IF @SecurityEntityID IS NULL  
BEGIN
SET @SecurityEntityID=0
END 

  DELETE FROM B
		FROM curdat.AdvSecurityDetail A
			INNER JOIN  curdat.AdvSecurityValueDetail B
			ON A.SecurityEntityID=B.SecurityEntityID
 WHERE A.EffectiveFromTimeKey<=@TIMEKEY AND A.EffectiveToTimeKey>=@TIMEKEY
		AND B.EffectiveFromTimeKey<=@TIMEKEY AND B.EffectiveToTimeKey>=@TIMEKEY
		AND A.EntryType='CorporateE'

   DELETE FROM curdat.AdvSecurityDetail  
			WHERE EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY 
		  AND EntryType='CorporateE'
   
IF OBJECT_ID('TEMPDB..#AdvSecurityDetail') IS NOT NULL
   DROP TABLE #AdvSecurityDetail

CREATE TABLE [#AdvSecurityDetail](
[ENTITYKEY] [bigint] NULL,
[CustomerEntityId] [int] NULL,
[SecurityEntityID] [int] NOT NULL,
[LiabID] [varchar](100) NULL,
[Line_No] [varchar](300) NULL,
[RefCustomerId] [varchar](50) NULL,
[UCICID] [varchar](16) NULL,
[CrossCollateral_LiabID] [varchar](500) NULL,
[CollateralID] [varchar](30) NULL,
[CollateralType] [varchar](30) NULL,
[CollateralSubTypeDescription] [varchar](500) NULL,
[ValueAtSanctionTime] [decimal](16, 2) NULL,
[ValuationExpiryDate] [datetime] NULL,
[CurrentValue] [decimal](16, 2) NULL,
[EntryType][varchar](20) NULL,
[EffectiveFromTimeKey] [int] NOT NULL,
[EffectiveToTimeKey] [int] NOT NULL,
[SecurityType] [char](1) NULL,
[SecurityAlt_Key] [smallint] NULL,
[SecurityStatus]  [varchar](25) NULL
) ON [PRIMARY]


INSERT INTO #AdvSecurityDetail (
CustomerEntityId,
SecurityEntityID,
LiabID,
Line_No,
RefCustomerId,
UCICID,
CrossCollateral_LiabID,
CollateralID,
CollateralType,
CollateralSubTypeDescription,
ValueAtSanctionTime,
ValuationExpiryDate,
CurrentValue,
EntryType,
EffectiveFromTimeKey,
EffectiveToTimeKey,
SecurityType,
SecurityAlt_Key,
SecurityStatus

)

SELECT	

0 AS  CustomerEntityId
,@SecurityEntityID + ROW_NUMBER()OVER(ORDER BY (SELECT 1))  AS SecurityEntityID
,LIABILITY_ID AS LiabID
,FACILITY_ID AS Line_No
,CUSTOMER_ID AS RefCustomerId
,UCIC_ID AS UCICID
,THIRDPARTY_ID AS CrossCollateral_LiabID
,COLLATERAL_ID AS CollateralID
,COLLATERAL_TYPE AS CollateralType
,COLLATERAL_SUBCATEGORY AS CollateralSubTypeDescription
,ISNULL(COLLATERAL_VALUE,0) AS  ValueAtSanctionTime
,TRY_CAST(VALUATION_EXPIRY AS datetime) AS ValuationExpiryDate
,ISNULL(ALLOCATED_AMOUNT,0) AS CurrentValue
,'CorporateE' as EntryType
,@TIMEKEY EffectiveFromTimeKey
,@TIMEKEY AS EffectiveToTimeKey
,'C' AS SecurityType
,DimCollateralSecurityMapping.SecurityAlt_Key AS SecurityAlt_Key
,DimCollateralSecurityMapping.SecurityType as SecurityStatus
 FROM  YBL_ACS_MIS.DBO.CFPM_ENPA_COLLATERAL 
inner join DimCollateralSecurityMapping 
on YBL_ACS_MIS.DBO.CFPM_ENPA_COLLATERAL.COLLATERAL_SUBCATEGORY=DimCollateralSecurityMapping.SecurityName
and DimCollateralSecurityMapping.EffectiveFromTimeKey<=@TIMEKEY and DimCollateralSecurityMapping.EffectivetoTimeKey>=@TIMEKEY



/*  Update Entity ID Update  */


UPDATE TEMP 
SET TEMP.CustomerEntityId=MAIN.CustomerEntityId,
TEMP.UCICID=MAIN.UCIF_ID,TEMP.RefCustomerId=MAIN.RefCustomerId
FROM  #AdvSecurityDetail  TEMP
INNER JOIN [pro].CustomerCal MAIN ON TEMP.UCICID=MAIN.UCIF_ID
INNER JOIN YBL_ACS_MIS.DBO.CFPM_ENPA_COLLATERAL coll on coll.UCIC_ID=MAIN.UCIF_ID


--DELETE  from #AdvSecurityDetail WHERE  UCICID=0
--DELETE  from #AdvSecurityDetail WHERE  UCICID IS NULL
--DELETE  from #AdvSecurityDetail WHERE  UCICID =''
 
DECLARE @VEFFECTIVETO INT SET @VEFFECTIVETO=(SELECT TIMEKEY-1 FROM PRO.EXTDATE_MISDB WHERE Flg='Y')

MERGE CURDAT.AdvSecurityDetail AS O
USING #AdvSecurityDetail AS T
ON O.SecurityEntityID=T.SecurityEntityID
and O.EffectiveToTimeKey=49999
AND T.EffectiveToTimeKey=49999
and O.EntryType='CorporateE'
 WHEN MATCHED AND 
(  
   ISNULL(O.SecurityType,0) <> ISNULL(T.SecurityType,0)
OR ISNULL(O.SecurityEntityID,0)<> ISNULL(T.SecurityEntityID,0)
OR ISNULL(O.EntryType,0)<> ISNULL(T.EntryType,0)
OR ISNULL(O.SecurityAlt_Key,0)<> ISNULL(T.SecurityAlt_Key,0)
)
THEN
UPDATE SET 
 O.EffectiveToTimeKey=@vEffectiveto,
 O.DateModified=CONVERT(DATE,GETDATE(),103),
 O.ModifiedBy='SSISUSER';

---------------------------------------------------------------------------------------------------------------
UPDATE AA
SET 
 EffectiveToTimeKey = @vEffectiveto,
 DateModified=CONVERT(DATE,GETDATE(),103),
 ModifiedBy='SSISUSER' 
FROM CURDAT.AdvSecurityDetail AA
WHERE AA.EffectiveToTimeKey = 49999
and AA.EntryType='CorporateE'
AND NOT EXISTS (SELECT 1 FROM DBO.#AdvSecurityDetail BB
    WHERE AA.SecurityEntityID=BB.SecurityEntityID
	     AND BB.EffectiveToTimeKey =49999
    )


/***************************************************************************************************************/

/* Merging Data From  To MainDB For Those  Which Ones Are Not Present In MainDB */

Merge Curdat.AdvSecurityDetail ACBD
USING DBO.#AdvSecurityDetail T_ACBD
ON ACBD.SecurityEntityID=T_ACBD.SecurityEntityID
 AND ACBD.Line_No=T_ACBD.Line_No
AND ACBD.EffectiveToTimeKey = 49999
AND T_ACBD.EffectiveToTimeKey = 49999

WHEN NOT MATCHED
THEN
INSERT
(
CustomerEntityId,
SecurityEntityID,
LiabID,
Line_No,
RefCustomerId,
UCICID,
CrossCollateral_LiabID,
CollateralID,
CollateralType,
CollateralSubTypeDescription,
ValueAtSanctionTime,
EntryType,
EffectiveFromTimeKey,
EffectiveToTimeKey,
SecurityType,
SecurityAlt_Key,
SecurityStatus
)
Values
( 
T_ACBD.CustomerEntityId,
T_ACBD.SecurityEntityID,
T_ACBD.LiabID,
T_ACBD.Line_No,
T_ACBD.RefCustomerId,
T_ACBD.UCICID,
T_ACBD.CrossCollateral_LiabID,
T_ACBD.CollateralID,
T_ACBD.CollateralType,
T_ACBD.CollateralSubTypeDescription,
T_ACBD.ValueAtSanctionTime,
T_ACBD.EntryType,
T_ACBD.EffectiveFromTimeKey,
T_ACBD.EffectiveToTimeKey,
T_ACBD.SecurityType,
T_ACBD.SecurityAlt_Key,
T_ACBD.SecurityStatus); 



 

MERGE CURDAT.AdvSecurityValueDetail AS O
USING #AdvSecurityDetail AS T
ON O.SecurityEntityID=T.SecurityEntityID
and O.EffectiveToTimeKey=49999
AND T.EffectiveToTimeKey=49999

 WHEN MATCHED AND 
(  
   ISNULL(O.SecurityEntityID,0) <> ISNULL(T.SecurityEntityID,0)
OR ISNULL(O.CurrentValue,0)<> ISNULL(T.CurrentValue,0)
OR ISNULL(O.ValuationExpiryDate,0)<> ISNULL(T.ValuationExpiryDate,0)
)
THEN
UPDATE SET 
 O.EffectiveToTimeKey=@vEffectiveto,
 O.DateModified=CONVERT(DATE,GETDATE(),103),
 O.ModifiedBy='SSISUSER';

---------------------------------------------------------------------------------------------------------------
UPDATE AA
SET 
 EffectiveToTimeKey = @vEffectiveto,
 DateModified=CONVERT(DATE,GETDATE(),103),
 ModifiedBy='SSISUSER' 
FROM CURDAT.AdvSecurityValueDetail AA
inner join CURDAT.ADVSECURITYDETAIL CC
ON CC.SecurityEntityID=AA.SecurityEntityID
WHERE AA.EffectiveToTimeKey = 49999
AND CC.EffectiveToTimeKey = 49999
and CC.EntryType='CorporateE'
AND NOT EXISTS (SELECT 1 FROM DBO.#AdvSecurityDetail BB
    WHERE AA.SecurityEntityID=BB.SecurityEntityID
    AND BB.EffectiveToTimeKey =49999
    )


/***************************************************************************************************************/

/* Merging Data From  To MainDB For Those Accounts Which Ones Are Not Present In MainDB */

Merge Curdat.AdvSecurityValueDetail ACBD
USING DBO.#AdvSecurityDetail T_ACBD
ON ACBD.SecurityEntityID=T_ACBD.SecurityEntityID
AND ACBD.EffectiveToTimeKey = 49999
AND T_ACBD.EffectiveToTimeKey = 49999

WHEN NOT MATCHED
THEN
INSERT
(
SecurityEntityID
,CurrentValue
,ValuationExpiryDate
,EffectiveFromTimeKey
,EffectiveToTimeKey
,CollateralID

)
Values
( 
 T_ACBD.SecurityEntityID
,T_ACBD.CurrentValue
,T_ACBD.ValuationExpiryDate
,T_ACBD.EffectiveFromTimeKey
,T_ACBD.EffectiveToTimeKey
,T_ACBD.CollateralID); 

END




GO