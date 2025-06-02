SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO




Create PROC [dbo].[CCOD_InttDemandService]
 @date DATE
AS


SET NOCOUNT ON;


DECLARE @TimeKey AS INT =(SELECT TimeKey FROM SysDayMatrix WHERE DATE=@DATE)

/* CHECK ALREADY PROCESSED FOR THE DATE */	
IF EXISTS(SELECT 1 FROM curdat.AdvAcDemandDetail where (DemandDate =@Date or RecDate =@Date)  and ACTYPE='CCOD')
		BEGIN
		SELECT 'INTEREST SERVICE ALREADY PROCECSSED FOR THE DATE '+convert(nvarchar, @date ,104)
		RETURN 1
	END


	
/* PREPARE TXNDATA*/
	
		
IF OBJECT_ID('tempdb..#AcDailyTxnDetail') IS NOT NULL
	DROP TABLE #AcDailyTxnDetail

	SELECT 
		A.Entitykey,A.CustomerID,A.CustomerAcID,A.TxnDate,A.TxnType,A.TxnSubType,A.TxnTime,A.CurrencyAlt_Key
		,A.CurrencyConvRate,A.TxnAmount,A.TxnAmountInCurrency,A.ExtDate,A.TxnRefNo,A.TxnValueDate
		,A.MnemonicCode,A.Particular,A.AuthorisationStatus,A.CreatedBy,A.DateCreated,A.ModifiedBy
		,A.DateModified,A.ApprovedBy,A.DateApproved,A.Remark,A.TrueCredit
		,A.IsProcessed,A.CtrBatchNo,A.RefSysTraNo,A.UCIF_ID,A.REF_CHQ_NO,A.TxnValueDate_Source
        ,CASE WHEN B.SOURCESYSTEMNAME ='FCR' THEN ISNULL(B.TOTALBALANCEOUTSTANDINGINR,0.00) * -1 ELSE ISNULL(B.TOTALBALANCEOUTSTANDINGINR,0.00) END AS Balance
		INTO #AcDailyTxnDetail 
	FROM dbo.AcDailyTxnDetail A
       INNER  JOIN YBL_ACS_MIS..ACCOUNTDATA B ON A.CUSTOMERACID=B.ACCOUNTID
           INNER JOIN DIMSOURCEDB C ON C.SOURCENAME=b.SOURCESYSTEMNAME
		AND (C.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND C.EFFECTIVETOTIMEKEY>=@TIMEKEY)
       where B.ProductCode in('660','661','889','681','682','693','694','695','696','715','716','717','718',
			     '755','756','758','763','764','765','766','787','788','789','795','796',
			     '797','798','799','220','237','740','235') ----Removed ProductCode 778 Confirmed by Pankaj Mailed	
             AND TxnValueDate=@date
		AND ISNULL(A.TxnAmount,0)>0
     --- AND CASE WHEN B.SOURCESYSTEMNAME ='FCR' THEN ISNULL(B.TOTALBALANCEOUTSTANDINGINR,0.00) * -1 ELSE ISNULL(B.TOTALBALANCEOUTSTANDINGINR,0.00) END >0
           

	update #AcDailyTxnDetail set TxnAmount=0 where isnull(TxnAmount,0)<=0

Update  #AcDailyTxnDetail set TrueCredit='Y' --where MNEMONICCODE not in('1408')

Update  #AcDailyTxnDetail set TrueCredit='Y' where MNEMONICCODE in('1408') AND CUSTOMERACID=RIGHT(PARTICULAR,15) and TrueCredit='N'

/*------INWARDCHEQUE RETURNS(9101)/OUTWARD CHEQUE RETURNS(9501)------------------------------*/

UPDATE A SET A.TRUECREDIT='N' FROM #AcDailyTxnDetail A 
WHERE A.MNEMONICCODE  IN('9101','9501','1418')  
AND TXNTYPE='CREDIT'  AND TXNSUBTYPE='RECOVERY'


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


UPDATE A SET A.TRUECREDIT='N' FROM #AcDailyTxnDetail A 
		INNER JOIN #COD_TXN_MNEMONIC B
			ON A.CustomerAcID=B.COD_ACCT_NO
			AND A.MNEMONICCODE =B.Cod_txn_mnemonic
			AND TXT_TXN_NARRATIVE NOT LIKE '%ADJ-ENT%'
		WHERE   TXNTYPE='CREDIT'  AND TXNSUBTYPE='RECOVERY'
				--AND EXTDATE=@PROCESSDATE
			
			

/*-------------NEFT RETURN(2557)/RTGS RETURN(2555)/RTGS Flex@Corp FUNDS TRANSFER CR(6931)------------------------------*/

UPDATE A SET A.TRUECREDIT='N'  FROM #AcDailyTxnDetail A 
WHERE A.MNEMONICCODE  IN('2557','2555','6909','6931')  AND PARTICULAR LIKE '%RETURN%'
 AND TXNTYPE='CREDIT'  AND TXNSUBTYPE='RECOVERY'


 /*--------------DD LIQUIDATED/CANCELLED-------------------------------------------------------------------------------------*/

UPDATE A SET A.TRUECREDIT='N' FROM #AcDailyTxnDetail A 
WHERE A.MNEMONICCODE  IN('8312','8310','6504','7793','8311') 
 AND TXNTYPE='CREDIT'  AND TXNSUBTYPE='RECOVERY'


 UPDATE A SET A.TRUECREDIT='N'  FROM #AcDailyTxnDetail A 
WHERE A.MNEMONICCODE  IN('6926')  AND PARTICULAR LIKE '%REVERSAL%'
AND   TXNTYPE='CREDIT'  AND TXNSUBTYPE='RECOVERY'


Update A set TrueCredit ='N'
from  #AcDailyTxnDetail A   inner join ybl_acs_mis.dbo.accountdata  B on
A.CustomerAcID=b.AccountID
where TxnType ='CREDIT' and B.ProductCode in ('869','219','819','891','703','704','705','209','605')

	

/* PREPARE DEMAND DATA FOR CURRENT DATE*/
	
	IF OBJECT_ID('tempdb..#DEMAND_DATA') IS NOT NULL
	DROP TABLE #DEMAND_DATA

		SELECT 
			    A.TxnSubType [DemandType]
			   ,A.[TxnValueDate] DemandDate
			   ,A.[TxnValueDate] [DemandOverDueDate]
			 -- ,SUM(A.TxnAmount) [DemandAmt]
			 , CASE WHEN (SUM(A.TxnAmount))>Balance THEN Balance ELSE SUM(A.TxnAmount)END AS   DemandAmt
			   ,CAST(0 AS DECIMAL(16,2)) [RecAmount]
			  -- ,SUM(A.TxnAmount)  [BalanceDemand] 
			 , CASE WHEN (SUM(A.TxnAmount))>Balance THEN Balance ELSE SUM(A.TxnAmount)END AS   BalanceDemand
			   ,A.CustomerAcID [CUSTOMERACID]
			   ,'CCOD' [AcType]
			   ,@TimeKey [EffectiveFromTimeKey]
			   ,49999 [EffectiveToTimeKey]
			   ,'SSIS'  [CreatedBy]
			   ,GETDATE() [DateCreated]
 			INTO #DEMAND_DATA
		FROM #AcDailyTxnDetail A
			WHERE TxnValueDate=@Date
			AND TxnSubType IN('INTEREST')
			AND TxnType='DEBIT'
			AND ISNULL(TxnValueDate,'1900-01-01')<>'2020-09-01' AND ISNULL(MnemonicCode,'')<>'8001'
   			 AND ISNULL(A.Balance,0)>0 
			GROUP BY  A.TxnSubType 
			   ,A.[TxnValueDate] 
			   ,A.CustomerAcID 
			   ,A.Balance






/* INSERT PREVIOUS BALANCE DEMAND DATA */
	INSERT INTO #DEMAND_DATA
			   ([DemandType]
			   ,[DemandDate]
			   ,[DemandOverDueDate]
			   ,[DemandAmt]
			   ,[RecAmount]
			   ,[BalanceDemand]
			   ,[CUSTOMERACID]
			   ,[AcType]
			   ,[EffectiveFromTimeKey]
			   ,[EffectiveToTimeKey]
			   ,[CreatedBy]
			   ,[DateCreated])
	SELECT
			    [DemandType]
			   ,[DemandDate]
			   ,[DemandOverDueDate]
			   ,[DemandAmt]
			   ,CAST(0 AS DECIMAL(16,2)) [RecAmount]
			   ,[BalanceDemand]
			   ,[CUSTOMERACID]
			   ,[AcType]
			   ,[EffectiveFromTimeKey]
			   ,[EffectiveToTimeKey]
			   ,[CreatedBy]
			   ,GETDATE()[DateCreated]
			FROM [CURDAT].[AdvAcDemandDetail] A
				WHERE  AcType='CCOD' AND BalanceDemand>0 
				AND (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)


IF OBJECT_ID('tempdb..#CHQ_RETURN') IS NOT NULL
	DROP TABLE #CHQ_RETURN

select A.ENTITYKEY
INTO #CHQ_RETURN
from #AcDailyTxnDetail a
	
	inner join #AcDailyTxnDetail b
		on a.customeracid=b.customeracid
		and a.TxnValueDate=b.TxnValueDate
		and a.TxnAmount=b.TxnAmount
		and a.MnemonicCode=6501
		and b.MnemonicCode=9501
		and a.REF_CHQ_NO =b.REF_CHQ_NO    



	
/* PREPARING RECOVERY DATA */

		ALTER TABLE #DEMAND_DATA ADD ENTITYKEY INT IDENTITY(1,1)

			

	IF OBJECT_ID('tempdb..#RECOVERY_DATA') IS NOT NULL
	DROP TABLE #RECOVERY_DATA

		;WITH CTE_DMD
		AS(SELECT CUSTOMERACID FROM #DEMAND_DATA GROUP BY CUSTOMERACID)

		SELECT A.CUSTOMERACID,SUM(TxnAmount)  RecAmount 
				INTO #RECOVERY_DATA
			FROM #AcDailyTxnDetail A
				INNER JOIN CTE_DMD B
					ON A.CUSTOMERACID=B.CUSTOMERACID
					LEFT JOIN #CHQ_RETURN c
		ON A.ENTITYKEY=C.ENTITYKEY
		WHERE TxnValueDate=@Date
			and TXNTYPE='CREDIT' AND  TxnSubType='RECOVERY' AND TRUECREDIT='Y'
			AND C.ENTITYKEY IS NULL
			AND ISNULL(MnemonicCode,'')<>'8000'
			GROUP BY A.CUSTOMERACID


/* ADJUSTING INTEREST DEMAND  WITH RECOOVERY */
		
		IF OBJECT_ID('tempdb..#DMD_REC_DATA') IS NOT NULL
	DROP TABLE #DMD_REC_DATA

		select A.* --a.AccountEntityId,DemandDate
			--,a.BalanceDemand, B.RecAmount--,-- 
			,SUM(A.BalanceDemand) OVER (PARTITION BY a.CUSTOMERACID ORDER BY a.CUSTOMERACID,DEMANDDATE,ENTITYKEY) DmdRunTotal
			,b.RecAmount GrossRec
			,CAST(0  AS DECIMAL(18,2)) RecCalc
			,CAST(0  AS DECIMAL(18,2))RecAdjusted
			,@Date RecDAte
			,@Date RecAdjDAte
			,ROW_NUMBER() over (order by A.CUSTOMERACID,A.demanddate) RID
			INTO #DMD_REC_DATA
		FROM #DEMAND_DATA  a
			left JOIN #RECOVERY_DATA b
				ON A.CUSTOMERACID=b.CUSTOMERACID
		ORDER BY CUSTOMERACID,DemandDate

		/* CALCULATING BALANCE DEMAND AND ADJUSTED RECOVERY */
		
		UPDATE #DMD_REC_DATA SET RecCalc=GrossRec where GrossRec=DmdRunTotal
		UPDATE #DMD_REC_DATA SET RecCalc=GrossRec-DmdRunTotal where RecCalc=0
		UPDATE #DMD_REC_DATA SET RecAdjusted =BalanceDemand  WHERE RecCalc>0


		;WITH CTE_AC
		AS
		(SELECT CUSTOMERACID,MIN(RID) RID FROM #DMD_REC_DATA WHERE RecCalc<0 GROUP BY CUSTOMERACID)
		
		UPDATE A
			SET A.RecAdjusted=BalanceDemand -(RecCalc*-1)
		FROM #DMD_REC_DATA A
			INNER JOIN CTE_AC B
				ON A.CUSTOMERACID=B.CUSTOMERACID
				AND A.RID=B.RID
	
		UPDATE #DMD_REC_DATA SET BalanceDemand=BalanceDemand-ISNULL(RecAdjusted,0)
					,RecAmount=ISNULL(RecAdjusted,0)
				WHERE ISNULL(RecAdjusted,0)>0
		
		/* UPDATEING REC DATE AND RECADJ DATE  */
		UPDATE #DMD_REC_DATA SET RECDATE=NULL WHERE ISNULL(RecAdjusted,0)=0

		UPDATE #DMD_REC_DATA SET RECADJDATE=NULL WHERE ISNULL(BalanceDemand,0)>0
	
		UPDATE #DMD_REC_DATA SET RECADJDATE=RECDATE WHERE ISNULL(BalanceDemand,0)=0

		
	  /* CHANGE EFFECTIVEFFROMTIMEKEY FOR PREVIOUS DATE DEMAND SERVICED DATA */
		UPDATE  #DMD_REC_DATA SET EffectiveFromTimeKey=@TimeKey WHERE EffectiveFromTimeKey <@TimeKey AND ISNULL(RecAdjusted,0)>0

		/* DELETE PREVISOU DATES UNSERVE DEMAND DATA - NOT REQUIRED ANY CHANGE IN MAIN TABLE*/
		DELETE #DMD_REC_DATA WHERE EffectiveFromTimeKey <@TimeKey AND ISNULL(RecAdjusted,0)=0


/*MERGE DEMAND INTO MAIN  TABLE */
	
	UPDATE O
		SET O.EffectiveToTimeKey=@TimeKey-1
	FROM CURDAT.AdvAcDemandDetail O
		INNER JOIN #DMD_REC_DATA T
	ON  O.CUSTOMERACID=T.CUSTOMERACID
		AND O.DemandType=T.DemandType
		AND O.DemandDate=T.DemandDate
		AND ISNULL(O.[DemandAmt],0)	=ISNULL(T.[DemandAmt],0)
		AND O.EffectiveToTimeKey=49999
		AND O.BalanceDemand <>T.BalanceDemand	
	
---------------------------------------------------------------------------------------------------------------
/* INSERT DATA INTO MAIN TABLE */
INSERT INTO CURDAT.AdvAcDemandDetail
           (
            [DemandType]
           ,[DemandDate]
           ,[DemandOverDueDate]
           ,[DemandAmt]
           ,[RecDate]
           ,[RecAdjDate]
           ,[RecAmount]
           ,[BalanceDemand]
           ,[CUSTOMERACID]
           ,[AcType]
           ,[EffectiveFromTimeKey]
           ,[EffectiveToTimeKey]
           ,[CreatedBy]
           ,[DateCreated]
		   )
 SELECT
            T.[DemandType]
           ,T.[DemandDate]
           ,T.[DemandOverDueDate]
           ,T.[DemandAmt]
           ,T.[RecDate]
           ,T.[RecAdjDate]
           ,T.[RecAmount]
           ,T.[BalanceDemand]
           ,T.[CUSTOMERACID]
           ,T.[AcType]
           ,T.[EffectiveFromTimeKey]
           ,T.[EffectiveToTimeKey]
           ,T.[CreatedBy]
           ,T.[DateCreated]
	FROM #DMD_REC_DATA T
		WHERE EffectiveToTimeKey=49999
		 AND EffectiveFromTimeKey=@TimeKey


/* INSERT RECOVERY DATA */
INSERT INTO  AdvAcRecoveryDetail
	(
			CashRecDate
			,AcType
			,CreatedBy
			,RecAmt
			,RecDate
			,DemandDate
			,CUSTOMERACID
			,DateCreated
	)
SELECT 
			 RECDATE CashRecDate
			,AcType
			,'SSIS' CreatedBy
			,RecAmount RecAmt
			,RecDate
			,DemandDate
			,CUSTOMERACID
			,GETDATE() DateCreated
FROM #DMD_REC_DATA
WHERE ISNULL(RecAmount,0)>0
 

update a set RecAmount=BalanceDemand,BalanceDemand=0,CreatedBy='M'
from CURDAT.AdvAcDemandDetail a
inner join #AcDailyTxnDetail b
on a.customeracid=b.customeracid
WHERE BalanceDemand>0 AND (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
AND ISNULL(b.BALANCE,0)=0

update a set RecAmount=BalanceDemand,BalanceDemand=0,CreatedBy='M'
from CURDAT.AdvAcDemandDetail a
inner join #AcDailyTxnDetail b
on a.customeracid=b.customeracid
WHERE BalanceDemand>0 AND (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
AND ISNULL(b.BALANCE,0)<0
 
GO