SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



/*===========================================
AUTHER : TRILOKI KHANNA
CREATE DATE : 19-09-2022
MODIFY DATE : 19-09-2022
DESCRIPTION : CALCULATE CURRENT 90 Days CREDIT AND INT
--EXEC [PRO].[UpdateCADCADURefBalRecovery] 25490
===================================================*/
Create PROCEDURE [pro].[UpdateCADCADURefBalRecovery]
@TimeKey INT
with recompile
AS
BEGIN
	SET NOCOUNT ON
         BEGIN TRY

Declare @LookBackPeriod int
SELECT @LookBackPeriod=RefValue FROM pro.RefPeriod  WHERE BusinessRule = 'LookBackPeriod'   
AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY	

Update pro.AccountCal set CreditAmt=0	,DebitAmt=0 where SourceAlt_Key=1

Declare  @QtrDefinition Varchar(5),@Refdate Date

SELECT @Refdate=Date FROM SysDayMatrix
WHERE TimeKey=@TimeKey


Declare          @StartDt DATE
		,@EndDt DATE
SELECT  @StartDt=DATEADD(day,-@LookBackPeriod,DATE)+1,
            @EndDt=Date
	      	FROM SysDayMAtrix
		      WHERE TimeKEy=@TimeKey




----IF OBJECT_ID('Tempdb..#AcDailyTxnDetail') IS NOT NULL
----DROP TABLE #AcDailyTxnDetail

----SELECT A.*
----INTO #AcDailyTxnDetail 
----FROM dbo.AcDailyTxnDetail A
----INNER JOIN PRO.AccountCal B ON A.CustomerAcID=B.CustomerAcID 
----WHERE TxnType IN ('CREDIT','DEBIT')
----AND TxnSubType IN ('RECOVERY','INTEREST') 
----AND TxnValueDate BETWEEN @StartDt AND @EndDt
----AND ISNULL(TxnAmount,0)>0 
----and B.SourceAlt_Key=1
----and B.ProductCode not in('660','661','889','681','682','693','694','695','696','715','716','717','718',
----			     '755','756','758','763','764','765','766','787','788','789','795','796',
----			     '797','798','799','220','237','869','219','819','891','703','704','705','209','605','740','778','235')


----Update  #AcDailyTxnDetail set TrueCredit='Y' --where MNEMONICCODE not in('1408')

----Update  #AcDailyTxnDetail set TrueCredit='Y' where MNEMONICCODE in('1408') AND CUSTOMERACID=RIGHT(PARTICULAR,15) and TrueCredit='N'






TRUNCATE TABLE Pro.[AcDailyTxnDetail_Cal]

	INSERT INTO Pro.[AcDailyTxnDetail_Cal]
           (
			    [AccountEntityID]
			   ,[ProductCode]
			   ,[CustomerAcID]
			   ,[TxnAmount]
			   ,[TxnType]
			   ,[TxnSubType]
			   ,[TxnValueDate]
			   ,[SourceAlt_Key]
			   ,[TrueCredit]
			   ,[MNEMONICCODE]
			   ,[PARTICULAR]
			)

		SELECT AccountEntityID
				,ProductCode
				,a.CustomerAcID
				,TxnAmount
				,TxnType
				,TxnSubType
				,TxnValueDate
				,SourceAlt_Key
				,'Y' AS TrueCredit
				,MNEMONICCODE
				,PARTICULAR
 
FROM dbo.AcDailyTxnDetail A
INNER JOIN PRO.AccountCal B ON A.CustomerAcID=B.CustomerAcID 
WHERE TxnType IN ('CREDIT','DEBIT')
AND TxnSubType IN ('RECOVERY','INTEREST') 
/*AND TxnValueDate BETWEEN @StartDt AND @EndDt 19072023 - AMAR COMMENTED FOR OPTIMISATION */
AND TxnValueDate BETWEEN DATEADD(DD,-34,@StartDt) AND @EndDt /*19072023 - AMAR ADDED FOR OPTIMISATION */
AND ISNULL(TxnAmount,0)>0 
AND B.SourceAlt_Key=1
AND B.ProductCode not in('660','661','889','681','682','693','694','695','696','715','716','717','718',
			     '755','756','758','763','764','765','766','787','788','789','795','796',
			     '797','798','799','220','237','869','219','819','891','703','704','705','209','605','740','235') -----Removed ProductCode 778 Confirmed by Pankaj Mailed	


/*------INWARDCHEQUE RETURNS(9101)/OUTWARD CHEQUE RETURNS(9501)------------------------------*/

----UPDATE A SET A.TRUECREDIT='N' FROM #AcDailyTxnDetail A 
----WHERE A.MNEMONICCODE  IN('9101','9501','1418')  
----AND TXNTYPE='CREDIT'  AND TXNSUBTYPE='RECOVERY'


/*------------------------DISBURSEMENTS (FCC & FCR)----------------------------------------*/

IF OBJECT_ID('TEMPDB..#COD_TXN_MNEMONIC') IS NOT NULL
   DROP TABLE #COD_TXN_MNEMONIC


SELECT A.COD_TXN_MNEMONIC,TXT_TXN_NARRATIVE, C.COD_ACCT_NO
	INTO #COD_TXN_MNEMONIC
FROM YBL_ACS_MIS.DBO.ODS_FCR_CH_NOBOOK_CURR A 
	 INNER JOIN YBL_ACS_MIS.DBO.ODS_FCR_FFI_STAN_XREF_MMDD C
					ON A.COD_ACCT_NO = C.COD_ACCT_NO
					AND A.CTR_BATCH_NO = C.CTR_BATCH_NO
					AND A.REF_SYS_TR_AUD_NO = C.STAN_NO_FC
					AND A.DAT_VALUE = C.DAT_VALUE       
					AND C.COD_FCC_MODULE = 'CL'
					AND C.COD_TXN_MNEMONIC in('12012')
		WHERE A.COD_TXN_MNEMONIC in( '12012')


----UPDATE A SET A.TRUECREDIT='N' FROM #AcDailyTxnDetail A 
----		INNER JOIN #COD_TXN_MNEMONIC B
----			ON A.CustomerAcID=B.COD_ACCT_NO
----			AND A.MNEMONICCODE =B.Cod_txn_mnemonic
----			AND TXT_TXN_NARRATIVE NOT LIKE '%ADJ-ENT%'
----		WHERE   TXNTYPE='CREDIT'  AND TXNSUBTYPE='RECOVERY'
----				--AND EXTDATE=@PROCESSDATE


UPDATE A SET A.TRUECREDIT='N' FROM Pro.[AcDailyTxnDetail_Cal] A 
		INNER JOIN #COD_TXN_MNEMONIC B
			ON A.CustomerAcID=B.COD_ACCT_NO
			AND A.MNEMONICCODE =B.Cod_txn_mnemonic
			AND TXT_TXN_NARRATIVE NOT LIKE '%ADJ-ENT%'
		WHERE   TXNTYPE='CREDIT'  AND TXNSUBTYPE='RECOVERY'
				--AND EXTDATE=@PROCESSDATE
		
DELETE FROM Pro.[AcDailyTxnDetail_Cal] WHERE TrueCredit='N'
			

/*-------------NEFT RETURN(2557)/RTGS RETURN(2555)/RTGS Flex@Corp FUNDS TRANSFER CR(6931)------------------------------*/

------UPDATE A SET A.TRUECREDIT='N'  FROM #AcDailyTxnDetail A 
------WHERE A.MNEMONICCODE  IN('2557','2555','6909','6931')  AND PARTICULAR LIKE '%RETURN%'
------ AND TXNTYPE='CREDIT'  AND TXNSUBTYPE='RECOVERY'


 /*--------------DD LIQUIDATED/CANCELLED-------------------------------------------------------------------------------------*/

----UPDATE A SET A.TRUECREDIT='N' FROM #AcDailyTxnDetail A 
----WHERE A.MNEMONICCODE  IN('8312','8310','6504','7793','8311') 
---- AND TXNTYPE='CREDIT'  AND TXNSUBTYPE='RECOVERY'


---- UPDATE A SET A.TRUECREDIT='N'  FROM #AcDailyTxnDetail A 
----WHERE A.MNEMONICCODE  IN('6926')  AND PARTICULAR LIKE '%REVERSAL%'
----AND   TXNTYPE='CREDIT'  AND TXNSUBTYPE='RECOVERY'


--Update A set TrueCredit ='N'
--from  #AcDailyTxnDetail A   inner join ybl_acs_mis.dbo.accountdata  B on
--A.CustomerAcID=b.AccountID
--where TxnType ='CREDIT' and B.ProductCode in ('869','219','819','891','703','704','705','209','605')


/*****above code is commented for optimization****directly deleting the ***TrueCredit ='N'*Records****2023-07-19**Pranay*****/

DELETE FROM Pro.[AcDailyTxnDetail_Cal] 
WHERE 
		(

			MNEMONICCODE  IN('9101','9501','1418')  
			AND TXNTYPE='CREDIT'  AND TXNSUBTYPE='RECOVERY'
		)
		OR
	   (
			MNEMONICCODE  IN('2557','2555','6909','6931')  AND PARTICULAR LIKE '%RETURN%'
			AND TXNTYPE='CREDIT'  AND TXNSUBTYPE='RECOVERY'
	   )
	   Or
	  (	
			MNEMONICCODE  IN('8312','8310','6504','7793','8311') 
			AND TXNTYPE='CREDIT'  AND TXNSUBTYPE='RECOVERY'
	  )
	  OR
	  (
			MNEMONICCODE  IN('6926')  AND PARTICULAR LIKE '%REVERSAL%'
			AND   TXNTYPE='CREDIT'  AND TXNSUBTYPE='RECOVERY'
	  )
	  OR
	  (
		TxnType ='CREDIT' and ProductCode in ('869','219','819','891','703','704','705','209','605')
	  )


	  ; WITH _CTE_90DaysCreditDebitLastCreditDate
	  AS
	  (
		SELECT 
		 AccountEntityID
		,MAX(CASE WHEN TxnType='CREDIT' AND TxnSubType='RECOVERY' THEN TxnValueDate ELSE NULL END)LastCreditDate
		,SUM(CASE WHEN TxnType='CREDIT' AND TxnSubType='RECOVERY' THEN TxnAmount ELSE 0 END) CreditAmount
		,SUM(CASE WHEN TxnType='DEBIT' AND TxnSubType='INTEREST' THEN TxnAmount  ELSE 0  END) DebitAmount
		FROM Pro.[AcDailyTxnDetail_Cal]
			WHERE TxnValueDate BETWEEN @StartDt AND @EndDt /*19072023 - AMAR ADDED FOR OPTIMISATION */
		group by AccountEntityID
	  )

UPDATE FCC 
SET LastCrDate= PQC.LastCreditDate
	,CreditAmt=PQC.CreditAmount
	,DebitAmt = PQC.DebitAmount
FROM PRO.AccountCal FCC 
INNER JOIN _CTE_90DaysCreditDebitLastCreditDate PQC
ON FCC.AccountEntityID=PQC.AccountEntityID



/*
 IF OBJECT_ID('Tempdb..#LastCreditDate') IS NOT NULL
	DROP TABLE #LastCreditDate

select max(TxnValueDate)TxnValueDate,A.CustomerAcID into #LastCreditDate 
	from #AcDailyTxnDetail A INNER JOIN PRO.AccountCal B ON A.CustomerAcID=B.CustomerAcID 
		INNER JOIN DimProduct C  ON B.ProductAlt_Key=C.ProductAlt_Key 
		and C.EffectiveFromTimeKey<=@timekey AND C.EffectiveToTimeKey>=@timekey 
		WHERE  TxnType='CREDIT' AND TxnSubType='RECOVERY' 
			AND TxnValueDate BETWEEN @StartDt AND @EndDt
--AND (ISNULL(C.PRODUCTGROUP,'N') <>'KCC')
--AND ((isnull(LineCode,'NA') NOT LIKE '%CROP_OD_F%' and isnull(LineCode,'NA')  NOT LIKE '%CROP_DLOD%' and isnull(LineCode,'NA')  Not LIKE '%CROP_TL_F%'))
--AND ACCOUNTSTATUS NOT LIKE '%CROP LOAN (OTHER THAN PL%' AND ACCOUNTSTATUS NOT LIKE '%CROP LOAN (PLANT N HORTI%' AND ACCOUNTSTATUS Not LIKE '%PRE AND POST-HARVEST ACT%'
--AND ACCOUNTSTATUS NOT LIKE '%FARMERS AGAINST HYPOTHEC%' AND ACCOUNTSTATUS NOT LIKE '%FARMERS AGAINST PLEDGE O%' AND ACCOUNTSTATUS NOT LIKE '%PLANTATION/HORTICULTURE%'
-- AND ACCOUNTSTATUS NOT LIKE '%365_CROP LOAN_OTR THAN PL%'
-- AND ACCOUNTSTATUS NOT LIKE '%365_CROP LOAN_PLANT/HORTI%'
-- AND ACCOUNTSTATUS NOT LIKE '%365_DEVELOPMENTAL ACTIVI%'
-- AND ACCOUNTSTATUS NOT LIKE '%365_LAND DEVELOPMENT%'
-- AND ACCOUNTSTATUS NOT LIKE '%365_PLANTATION/HORTI%'
and B.ProductCode not in('660','661','889','681','682','693','694','695','696','715','716','717','718',
			     '755','756','758','763','764','765','766','787','788','789','795','796',
			     '797','798','799','220','237','869','219','819','891','703','704','705','209','605','740','778','235')
 and b.SourceAlt_Key=1
 group by A.CustomerAcID 

 UPDATE FCC 
SET LastCrDate= PQC.TxnValueDate
FROM PRO.AccountCal FCC 
INNER JOIN #LastCreditDate PQC
ON FCC.CustomerAcID=PQC.CustomerAcID where FCC.SourceAlt_Key=1


--***********************
--  90 DAYS Credit
--***********************


 

 IF OBJECT_ID('Tempdb..#Credit') IS NOT NULL
	DROP TABLE #Credit

		SELECT SUM(ISNULL(TxnAmount,0)) as CreditAmount ,A.CustomerAcID
		INTO #Credit 
		FROM #AcDailyTxnDetail A 
		INNER JOIN PRO.AccountCal B ON A.CustomerAcID=B.CustomerAcID 
		INNER JOIN DimProduct C  ON B.ProductAlt_Key=C.ProductAlt_Key 
		and C.EffectiveFromTimeKey<=@timekey AND C.EffectiveToTimeKey>=@timekey 
		WHERE  TxnType='CREDIT' AND TxnSubType='RECOVERY' 
			AND TxnValueDate BETWEEN @StartDt AND @EndDt
--AND (ISNULL(C.PRODUCTGROUP,'N') <>'KCC')
--AND ((isnull(LineCode,'NA') NOT LIKE '%CROP_OD_F%' and isnull(LineCode,'NA')  NOT LIKE '%CROP_DLOD%' and isnull(LineCode,'NA')  Not LIKE '%CROP_TL_F%'))
--AND ACCOUNTSTATUS NOT LIKE '%CROP LOAN (OTHER THAN PL%' AND ACCOUNTSTATUS NOT LIKE '%CROP LOAN (PLANT N HORTI%' AND ACCOUNTSTATUS Not LIKE '%PRE AND POST-HARVEST ACT%'
--AND ACCOUNTSTATUS NOT LIKE '%FARMERS AGAINST HYPOTHEC%' AND ACCOUNTSTATUS NOT LIKE '%FARMERS AGAINST PLEDGE O%' AND ACCOUNTSTATUS NOT LIKE '%PLANTATION/HORTICULTURE%'
-- AND ACCOUNTSTATUS NOT LIKE '%365_CROP LOAN_OTR THAN PL%'
-- AND ACCOUNTSTATUS NOT LIKE '%365_CROP LOAN_PLANT/HORTI%'
-- AND ACCOUNTSTATUS NOT LIKE '%365_DEVELOPMENTAL ACTIVI%'
-- AND ACCOUNTSTATUS NOT LIKE '%365_LAND DEVELOPMENT%'
-- AND ACCOUNTSTATUS NOT LIKE '%365_PLANTATION/HORTI%'
and B.ProductCode not in('660','661','889','681','682','693','694','695','696','715','716','717','718',
			     '755','756','758','763','764','765','766','787','788','789','795','796',
			     '797','798','799','220','237','869','219','819','891','703','704','705','209','605','740','778','235')
 and B.SourceAlt_Key=1
GROUP BY A.CustomerAcID

UPDATE FCC 
SET CreditAmt= PQC.CreditAmount
FROM PRO.AccountCal FCC 
INNER JOIN #Credit PQC
ON FCC.CustomerAcID=PQC.CustomerAcID 





--***********************
-- 90 DAYS Interest
--***********************

	IF OBJECT_ID('Tempdb..#Debit') IS NOT NULL
	DROP TABLE #Debit

SELECT SUM(ISNULL(TxnAmount,0)) as DebitAmount, A.CustomerAcID 
INTO #Debit 
		FROM #AcDailyTxnDetail A
		INNER JOIN PRO.AccountCal B ON A.CustomerAcID=B.CustomerAcID
		INNER JOIN DimProduct C  ON B.ProductAlt_Key=C.ProductAlt_Key 
		and C.EffectiveFromTimeKey<=@timekey AND C.EffectiveToTimeKey>=@timekey 
		WHERE  TxnType='DEBIT' AND TxnSubType='INTEREST' 
		AND TxnValueDate BETWEEN @StartDt AND @EndDt
--AND (ISNULL(C.PRODUCTGROUP,'N') <>'KCC')
--AND ((isnull(LineCode,'NA') NOT LIKE '%CROP_OD_F%' and isnull(LineCode,'NA')  NOT LIKE '%CROP_DLOD%' and isnull(LineCode,'NA')  Not LIKE '%CROP_TL_F%'))
--AND ACCOUNTSTATUS NOT LIKE '%CROP LOAN (OTHER THAN PL%' AND ACCOUNTSTATUS NOT LIKE '%CROP LOAN (PLANT N HORTI%' AND ACCOUNTSTATUS Not LIKE '%PRE AND POST-HARVEST ACT%'
--AND ACCOUNTSTATUS NOT LIKE '%FARMERS AGAINST HYPOTHEC%' AND ACCOUNTSTATUS NOT LIKE '%FARMERS AGAINST PLEDGE O%' AND ACCOUNTSTATUS NOT LIKE '%PLANTATION/HORTICULTURE%'
-- AND ACCOUNTSTATUS NOT LIKE '%365_CROP LOAN_OTR THAN PL%'
-- AND ACCOUNTSTATUS NOT LIKE '%365_CROP LOAN_PLANT/HORTI%'
-- AND ACCOUNTSTATUS NOT LIKE '%365_DEVELOPMENTAL ACTIVI%'
-- AND ACCOUNTSTATUS NOT LIKE '%365_LAND DEVELOPMENT%'
-- AND ACCOUNTSTATUS NOT LIKE '%365_PLANTATION/HORTI%'
and B.ProductCode not in('660','661','889','681','682','693','694','695','696','715','716','717','718',
			     '755','756','758','763','764','765','766','787','788','789','795','796',
			     '797','798','799','220','237','869','219','819','891','703','704','705','209','605','740','778','235')
 and B.SourceAlt_Key=1
		GROUP BY A.CustomerAcID
	
	UPDATE FCC 
SET DebitAmt= PQC.DebitAmount
FROM PRO.AccountCal FCC 
INNER JOIN #Debit PQC ON FCC.CustomerAcID=PQC.CustomerAcID
*/

/***************************/


UPDATE PRO.ACCOUNTCAL SET CreditAmt=0   WHERE CreditAmt IS NULL and SourceAlt_Key=1
UPDATE PRO.ACCOUNTCAL SET DebitAmt=0    WHERE DebitAmt IS NULL and SourceAlt_Key=1



	END TRY

	BEGIN CATCH
					SELECT 'Proc Name: ' + ISNULL(ERROR_PROCEDURE(),'') + ' ErrorMsg: ' + ISNULL(ERROR_MESSAGE(),'')
	END CATCH


	END

GO