SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROCEDURE [pro].[CustomerSecurityValueRetail_Insert_Data]
AS
BEGIN



DECLARE @TIMEKEY INT=(SELECT TimeKey FROM PRO.EXTDATE_MISDB WHERE Flg='Y')

DECLARE @SecurityMaxId AS INT SET @SecurityMaxId=(SELECT  ISNULL(Max(SecurityEntityID),0)  FROM CURDAT.AdvSecurityValueDetail)
  


  
IF OBJECT_ID('TEMPDB..#AdvSecurityDetail') IS NOT NULL
   DROP TABLE #AdvSecurityDetail

CREATE TABLE [#AdvSecurityDetail](
	[EntityKey] [bigint] NULL,
	[AccountEntityId] [int] NULL,
	[CustomerEntityId] [int] NULL,
	[SecurityEntityID] [int] NOT NULL,
	[Security_RefNo] [varchar](20) NULL,
	[UCICID][varchar](50)  NULL,
	[RefCustomerId] [varchar](50)  NULL,
	[RefSystemAcId][varchar](50)  NULL,
	[CurrentValue] [decimal](16, 2) NULL,
    [EntryType][varchar](20) NULL,
	Appraisal_date	date NULL, ------NEW COLUMN FOR DATA OF VALUATION
	disbursaldate	VARCHAR(25) NULL, ------NEW COLUMN FOR DATA OF DISBURSMENT
	[EffectiveFromTimeKey] [int] NOT NULL,
	[EffectiveToTimeKey] [int] NOT NULL,
	[SecurityType] [char](1) NULL,
	[SecurityAlt_Key] [smallint] NULL,
) ON [PRIMARY]


IF OBJECT_ID('TEMPDB..#NOTNULL_ACC_NO') IS NOT NULL
   DROP TABLE #NOTNULL_ACC_NO
	SELECT * INTO #NOTNULL_ACC_NO FROM YBL_ACS_MIS.DBO.CFPM_ENPA_COLLATERAL A
	WHERE A.ACCOUNT_NUMBER IS NOT NULL

IF OBJECT_ID('TEMPDB..#NULL_ACC_NO') IS NOT NULL
   DROP TABLE #NULL_ACC_NO
	SELECT * INTO #NULL_ACC_NO FROM YBL_ACS_MIS.DBO.CFPM_ENPA_COLLATERAL A
	WHERE A.ACCOUNT_NUMBER IS NULL


INSERT INTO #AdvSecurityDetail (
 AccountEntityId
,CustomerEntityId
,SecurityEntityID
,UCICID
,RefCustomerId
,RefSystemAcId
,CurrentValue
,EntryType
,APPRAISAL_DATE   /*NEW COLUMN FOR DATA OF VALUATION BY ZAIN 20240831 FOR SECURITY EROSION CR GREATER THAN 3 YEARS AS ZERO*/
,DISBURSALDATE   /*NEW COLUMN FOR DATA OF DISBURSMENT BY ZAIN 20240831 FOR SECURITY EROSION CR GREATER THAN 3 YEARS AS ZERO*/
,EffectiveFromTimeKey
,EffectiveToTimeKey
,SecurityType
,SecurityAlt_Key

)


/* FCR SECURITY EROSION CR FOR RETAIL PRODUCTCODE IN ('889','661','729','727','697','699','759','760','761','762') ADDED BY ZAIN ON 20250113 AND COMMENTED NOT LIVE YET*/

	/*IF PRODUCT CODE IN ('889','661','729','727','697','699','759','760','761','762')
				,ACCOUNT NUMBER IS  NULL AND SOURCE SYSTEM IS 'FCR' THEN GET DATA FROM YBL_ACS_MIS.DBO.CFPM_ENPA_COLLATERAL*/
		SELECT 
		 0 AS ACCOUNTENTITYID	
		,0  AS CUSTOMERENTITYID
		,0 AS SECURITYENTITYID
		,NULL AS UCICID
		,NULL AS REFCUSTOMERID
		,B.SourceSystemCustomerID AS REFSYSTEMACID
		,SUM(ISNULL(A.ALLOCATED_AMOUNT,0)) AS CURRENTVALUE
		,'RETAIL' AS ENTRYTYPE
		,NULL APPRAISAL_DATE   /*NEW COLUMN FOR DATA OF VALUATION BY ZAIN 20240831 FOR SECURITY EROSION CR GREATER THAN 3 YEARS AS ZERO*/
        ,NULL DISBURSALDATE   /*NEW COLUMN FOR DATA OF DISBURSMENT BY ZAIN 20240831 FOR SECURITY EROSION CR GREATER THAN 3 YEARS AS ZERO*/
		,@TIMEKEY EFFECTIVEFROMTIMEKEY
		,49999 AS EFFECTIVETOTIMEKEY
		,'C' AS SECURITYTYPE
		, 0 AS SECURITYALT_KEY
		 FROM YBL_ACS_MIS.DBO.CFPM_ENPA_COLLATERAL A
				INNER JOIN YBL_ACS_MIS..ACCOUNTDATA B ON cast(A.CUSTOMER_ID as varchar(50))=cast(B.SourceSystemCustomerID as varchar(50))
				INNER JOIN DIMPRODUCT D ON B.PRODUCTCODE=D.PRODUCTCODE
			WHERE A.CUSTOMER_ID IN (SELECT CUSTOMER_ID FROM #NOTNULL_ACC_NO)
					AND A.SOURCE_SYSTEM LIKE '%FCR%'
					AND D.PRODUCTEROSION ='Y'
					group by SourceSystemCustomerID 
					union 
	/*IF PRODUCT CODE IN ('889','661','729','727','697','699','759','760','761','762')
				,ACCOUNT NUMBER IS  NULL AND SOURCE SYSTEM IS 'FCR' THEN GET DATA FROM YBL_ACS_MIS.DBO.CFPM_ENPA_COLLATERAL END*/


	/*IF PRODUCT CODE IN ('889','661','729','727','697','699','759','760','761','762')
				,ACCOUNT NUMBER IS NOT NULL AND SOURCE SYSTEM IS 'FCR' THEN GET DATA FROM YBL_ACS_MIS.DBO.GLD_ELCM_CONSOL_DTL_COLLATERAL*/		

		SELECT 
		 0 AS ACCOUNTENTITYID	
		,0  AS CUSTOMERENTITYID
		,0 AS SECURITYENTITYID
		,NULL AS UCICID
		,NULL AS REFCUSTOMERID
		,CAST(B.SourceSystemCustomerID AS varchar(50)) AS REFSYSTEMACID
		,SUM(ISNULL(CAST(A.COLLATERAL_VALUE AS DECIMAL(18,4)),0)) AS CURRENTVALUE
		,'RETAIL' AS ENTRYTYPE
		,APPRAISAL_DATE   /*NEW COLUMN FOR DATA OF VALUATION BY ZAIN 20240831 FOR SECURITY EROSION CR GREATER THAN 3 YEARS AS ZERO*/
        ,DISBURSALDATE   /*NEW COLUMN FOR DATA OF DISBURSMENT BY ZAIN 20240831 FOR SECURITY EROSION CR GREATER THAN 3 YEARS AS ZERO*/
		,@TIMEKEY EFFECTIVEFROMTIMEKEY
		,49999 AS EFFECTIVETOTIMEKEY
		,'C' AS SECURITYTYPE
		, 0 AS SECURITYALT_KEY
		 FROM YBL_ACS_MIS.DBO.GLD_ELCM_CONSOL_DTL_COLLATERAL A
				INNER JOIN YBL_ACS_MIS..ACCOUNTDATA B ON A.CUST_ID=B.FCR_CUSTOMERID																		
				INNER JOIN DIMPRODUCT D ON B.PRODUCTCODE=D.PRODUCTCODE
			WHERE A.cust_id IN (SELECT CUSTOMER_ID FROM #NULL_ACC_NO)
					AND A.SOURCE_SYSTEM = 'FCR'
					AND D.PRODUCTEROSION ='Y'
					group by SourceSystemCustomerID ,APPRAISAL_DATE,DISBURSALDATE
					union

	/*IF PRODUCT CODE IN ('889','661','729','727','697','699','759','760','761','762')
				,ACCOUNT NUMBER IS NOT NULL AND SOURCE SYSTEM IS 'FCR' THEN GET DATA FROM YBL_ACS_MIS.DBO.GLD_ELCM_CONSOL_DTL_COLLATERAL END*/		

/* FCR SECURITY EROSION CR FOR RETAIL PRODUCTCODE IN ('889','661','729','727','697','699','759','760','761','762') END*/

/* FCR SECURITY EROSION CR FOR RETAIL PRODUCTCODE IN ('889','661','729','727','697','699','759','760','761','762') ADDED BY ZAIN ON 20250113 AND COMMENTED NOT LIVE YET END*/


SELECT	
 0 AS AccountEntityId	
,0  AS CustomerEntityId
,0 AS SecurityEntityID
,NULL AS UCICID
,NULL AS RefCustomerId
,CAST(source_system_reference AS VARCHAR(50)) AS RefSystemAcId
,sum(isnull(collateral_value,0)) AS CurrentValue
,'Retail' as EntryType
,APPRAISAL_DATE   /*NEW COLUMN FOR DATA OF VALUATION BY ZAIN 20240831 FOR SECURITY EROSION CR GREATER THAN 3 YEARS AS ZERO*/
,DISBURSALDATE   /*NEW COLUMN FOR DATA OF DISBURSMENT BY ZAIN 20240831 FOR SECURITY EROSION CR GREATER THAN 3 YEARS AS ZERO*/
,@TIMEKEY EffectiveFromTimeKey
,49999 AS EffectiveToTimeKey
,'C' AS SecurityType
, 0 AS SecurityAlt_Key
FROM  YBL_ACS_MIS.DBO.[gld_elcm_consol_dtl_collateral]
where isnull(collateral_value,0)>0
and  source_system  in('CREDIT_CARD','FCC','FINONE','CREDAVENUE_DA')---"FCR" COMMENTED FOR SECURITY EROSION FCR ON 20250127
group by  source_system_reference,APPRAISAL_DATE,DISBURSALDATE /*ADDED COLUMNS IN GROUP BY CLAUSE APPRAISAL_DATE,DISBURSALDATE BY ZAIN 20240831 FOR SECURITY EROSION CR GREATER THAN 3 YEARS AS ZERO*/
Union 							  
/* ECBF consider  Account Number from FCR based on same customerID and product code 605 */
SELECT	
 0 AS AccountEntityId	
,0  AS CustomerEntityId
,0 AS SecurityEntityID
,NULL AS UCICID
,NULL AS RefCustomerId
,cast(a.AccountID as varchar(50))AS RefSystemAcId
,sum(isnull(collateral_value,0)) AS CurrentValue
,'Retail' as EntryType
,APPRAISAL_DATE  /*NEW COLUMN FOR DATA OF VALUATION BY ZAIN 20240831 FOR SECURITY EROSION CR GREATER THAN 3 YEARS AS ZERO*/
,DISBURSALDATE  /*NEW COLUMN FOR DATA OF DISBURSMENT BY ZAIN 20240831 FOR SECURITY EROSION CR GREATER THAN 3 YEARS AS ZERO*/
,@TIMEKEY EffectiveFromTimeKey
,49999 AS EffectiveToTimeKey
,'C' AS SecurityType
, 0 AS SecurityAlt_Key
FROM  YBL_ACS_MIS.DBO.[gld_elcm_consol_dtl_collateral] b
inner join YBL_ACS_MIS..AccountData a on b.cust_id=a.FCR_CustomerID and a.ProductCode='605'
where isnull(collateral_value,0)>0
and  source_system  in('ECBF')
group by  a.AccountID,APPRAISAL_DATE,DISBURSALDATE /*ADDED COLUMNS IN GROUP BY CLAUSE APPRAISAL_DATE,DISBURSALDATE BY ZAIN 20240831 FOR SECURITY EROSION CR GREATER THAN 3 YEARS AS ZERO*/


/*  Update Entity ID Update  */

/*---"FCR" COMMENTED FOR SECURITY EROSION FCR ON 20250127*/
UPDATE TEMP 
SET TEMP.ACCOUNTENTITYID=MAIN.ACCOUNTENTITYID,TEMP.CUSTOMERENTITYID=MAIN.CUSTOMERENTITYID,
TEMP.UCICID=MAIN.UCIF_ID,TEMP.REFCUSTOMERID=MAIN.REFCUSTOMERID
FROM  #ADVSECURITYDETAIL  TEMP
INNER JOIN [PRO].ACCOUNTCAL(NOLOCK) MAIN ON TEMP.REFSYSTEMACID LIKE MAIN.RefCustomerID
INNER JOIN YBL_ACS_MIS.DBO.CFPM_ENPA_COLLATERAL A on a.CUSTOMER_ID LIKE TEMP.REFSYSTEMACID
INNER JOIN DIMPRODUCT D ON MAIN.PRODUCTCODE=D.PRODUCTCODE
where A.ACCOUNT_NUMBER IS NOT NULL
					AND A.SOURCE_SYSTEM ='FCR'
					AND D.PRODUCTEROSION ='Y'
/*---"FCR" COMMENTED FOR SECURITY EROSION FCR ON 20250127 END*/

UPDATE TEMP 
SET TEMP.AccountEntityId=MAIN.AccountEntityId
,TEMP.CustomerEntityId=MAIN.CustomerEntityId
,TEMP.UCICID=MAIN.UCIF_ID
,TEMP.RefCustomerId=MAIN.RefCustomerId
FROM  #AdvSecurityDetail  TEMP
INNER JOIN [pro].AccountCal(nolock) MAIN ON TEMP.RefSystemAcId=MAIN.CustomerAcID
INNER JOIN YBL_ACS_MIS.DBO.[gld_elcm_consol_dtl_collateral] coll on coll.cust_id=MAIN.RefCustomerId
and cast(coll.source_system_reference as varchar(50))=MAIN.CustomerAcID

--- ECBF
UPDATE TEMP 
SET TEMP.AccountEntityId=MAIN.AccountEntityId,TEMP.CustomerEntityId=MAIN.CustomerEntityId,
TEMP.UCICID=MAIN.UCIF_ID,TEMP.RefCustomerId=MAIN.RefCustomerId
FROM  #AdvSecurityDetail  TEMP
INNER JOIN [pro].AccountCal(nolock) MAIN ON TEMP.RefSystemAcId=MAIN.CustomerAcID
where  MAIN.SourceAlt_Key=5




DELETE  from #AdvSecurityDetail WHERE  AccountEntityId=0
--update #AdvSecurityDetail set EffectiveToTimeKey=null where    CurrentValue=940000.00-----

/*  Update SecurityEntityID Entity ID Update  */
UPDATE TEMP 
SET TEMP.SecurityEntityID=MAIN.SecurityEntityID
FROM  #AdvSecurityDetail  TEMP
INNER JOIN CURDAT.AdvSecurityDetail MAIN ON TEMP.RefSystemAcId=MAIN.RefSystemAcId and MAIN.EntryType='Retail'
inner join CURDAT.AdvSecurityValueDetail sec on main.SecurityEntityID=sec.SecurityEntityID
and MAIN.EffectiveToTimeKey=49999
and sec.EffectiveToTimeKey=49999
and sec.CurrentValue=TEMP.CurrentValue

/*********************************************************************************************************/
--GO
/*  New SecurityEntityID Entity ID Update  */


DECLARE @SecurityEntityID INT=0 
SELECT @SecurityEntityID=MAX(SecurityEntityID) FROM  dbo.AdvSecurityValueDetail
--SELECT @SecurityEntityID
IF @SecurityEntityID IS NULL  
BEGIN
SET @SecurityEntityID=0
END

UPDATE TEMP 
SET TEMP.SecurityEntityID=ACCT.SecurityEntityID
 FROM  #AdvSecurityDetail TEMP
INNER JOIN (SELECT RefSystemAcId,(@SecurityEntityID + ROW_NUMBER()OVER(ORDER BY (SELECT 1))) SecurityEntityID
			FROM #AdvSecurityDetail
			WHERE SecurityEntityID=0)ACCT ON TEMP.RefSystemAcId=ACCT.RefSystemAcId

			

 
DECLARE @VEFFECTIVETO INT SET @VEFFECTIVETO=(SELECT TIMEKEY-1 FROM PRO.EXTDATE_MISDB WHERE Flg='Y')



MERGE CURDAT.AdvSecurityDetail AS O
USING #AdvSecurityDetail AS T
ON O.SecurityEntityID=T.SecurityEntityID
and O.EffectiveToTimeKey=49999
AND T.EffectiveToTimeKey=49999
and O.EntryType='Retail'
 WHEN MATCHED AND 
(  
   ISNULL(O.SecurityType,0) <> ISNULL(T.SecurityType,0)
OR ISNULL(O.SecurityEntityID,0)<> ISNULL(T.SecurityEntityID,0)
OR ISNULL(O.EntryType,0)<> ISNULL(T.EntryType,0)
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
and AA.EntryType='Retail'
AND NOT EXISTS (SELECT 1 FROM DBO.#AdvSecurityDetail BB
    WHERE AA.SecurityEntityID=BB.SecurityEntityID
	     AND BB.EffectiveToTimeKey =49999
    )


/***************************************************************************************************************/

/* Merging Data From  To MainDB For Those Accounts Which Ones Are Not Present In MainDB */

Merge Curdat.AdvSecurityDetail ACBD
USING DBO.#AdvSecurityDetail T_ACBD
ON ACBD.SecurityEntityID=T_ACBD.SecurityEntityID
AND ACBD.EffectiveToTimeKey = 49999
AND T_ACBD.EffectiveToTimeKey = 49999

WHEN NOT MATCHED
THEN
INSERT
(
AccountEntityId
,CustomerEntityId
,SecurityType 
,SecurityAlt_Key
,SecurityEntityID
,EntryType
,UCICID
,RefCustomerId
,RefSystemAcId
,EffectiveFromTimeKey
,EffectiveToTimeKey
)
Values
( 
 
 T_ACBD.AccountEntityId
,T_ACBD.CustomerEntityId
,T_ACBD.SecurityType 
,T_ACBD.SecurityAlt_Key
,T_ACBD.SecurityEntityID
,T_ACBD.EntryType
,T_ACBD.UCICID
,T_ACBD.RefCustomerId
,T_ACBD.RefSystemAcId
,T_ACBD.EffectiveFromTimeKey
,T_ACBD.EffectiveToTimeKey); 

MERGE CURDAT.AdvSecurityValueDetail AS O
USING #AdvSecurityDetail AS T
ON O.SecurityEntityID=T.SecurityEntityID
and O.EffectiveToTimeKey=49999
AND T.EffectiveToTimeKey=49999

 WHEN MATCHED AND 
(  
   ISNULL(O.SecurityEntityID,0) <> ISNULL(T.SecurityEntityID,0)
OR ISNULL(O.CurrentValue,0)<> ISNULL(T.CurrentValue,0)
OR ISNULL(O.ValuationDate,'')<>ISNULL(T.Appraisal_date,'')
OR ISNULL(O.DISBURSALDATE,'')<>ISNULL(T.DISBURSALDATE,'')
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
and CC.EntryType='Retail'
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
,ValuationDate	 /*NEW COLUMN FOR DATA OF VALUATION BY ZAIN 20240831 FOR SECURITY EROSION CR GREATER THAN 3 YEARS AS ZERO*/
,DISBURSALDATE	/*NEW COLUMN FOR DATA OF DISBURSMENT BY ZAIN 20240831 FOR SECURITY EROSION CR GREATER THAN 3 YEARS AS ZERO*/
,EffectiveFromTimeKey
,EffectiveToTimeKey
)
Values
( 
 T_ACBD.SecurityEntityID
,T_ACBD.CurrentValue
,T_ACBD.Appraisal_date	 /*NEW COLUMN FOR DATA OF VALUATION BY ZAIN 20240831 FOR SECURITY EROSION CR GREATER THAN 3 YEARS AS ZERO*/
,T_ACBD.DISBURSALDATE	/*NEW COLUMN FOR DATA OF DISBURSMENT BY ZAIN 20240831 FOR SECURITY EROSION CR GREATER THAN 3 YEARS AS ZERO*/
,T_ACBD.EffectiveFromTimeKey
,T_ACBD.EffectiveToTimeKey); 

select * from #AdvSecurityDetail

--IF OBJECT_ID('TEMPDB..#RetailCustomerSecurity') IS NOT NULL
--   DROP TABLE #RetailCustomerSecurity

--SELECT   UCICID,SUM(ISNULL(CurrentValue,0)) AS CurrentValue
--INTO #RetailCustomerSecurity
--FROM 	 AdvSecurityDetail Advsec 
--INNER JOIN AdvSecurityValueDetail Sec ON (SEC.EffectiveFromTimeKey < = @TimeKey AND SEC.EffectiveToTimeKey >= @TimeKey)
																
--										AND Advsec.SecurityEntityID=Sec.SecurityEntityID
--										AND Advsec.EffectiveFromTimeKey < = @Timekey
--				AND Advsec.EffectiveToTimeKey > = @Timekey
--WHERE UCICID<>''
--GROUP  BY UCICID


--ALTER TABLE  #RetailCustomerSecurity ADD  UCICIDIDTOTALCOUNT INT 
--ALTER TABLE  #RetailCustomerSecurity ADD  UCICIDIDSECURITYVALUE DECIMAL (18,2) 

--IF OBJECT_ID('TEMPDB..#UCICIDIDTOTALCOUNT') IS NOT NULL
--  DROP TABLE #UCICIDIDTOTALCOUNT

--SELECT COUNT(*) AS NUMBER , UCIF_ID 
--INTO #UCICIDIDTOTALCOUNT
--FROM PRO.CUSTOMERCAL WHERE UCIF_ID IS NOT NULL
--GROUP BY UCIF_ID



--UPDATE A SET UCICIDIDTOTALCOUNT= NUMBER 
--FROM #RetailCustomerSecurity A
--INNER JOIN #UCICIDIDTOTALCOUNT B ON A.UCICID=B.UCIF_ID

--UPDATE #RetailCustomerSecurity SET UCICIDIDSECURITYVALUE=(ISNULL(CurrentValue,0)/UCICIDIDTOTALCOUNT)
--WHERE UCICIDIDTOTALCOUNT>=1

--update b set CurntQtrRv=a.UCICIDIDSECURITYVALUE
--from #RetailCustomerSecurity a
--inner join pro.customercal b
--on a.UCICID=b.UCIF_ID

 

END

GO