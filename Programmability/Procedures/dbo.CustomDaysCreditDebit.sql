SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

create procedure [dbo].[CustomDaysCreditDebit]
 @StartDt date
,@EndDt date
with recompile
as

--declare 
--@StartDt date='01/jan/2024'
--,@EndDt date='31/jan/2024'


begin
set nocount on
	begin try

	declare @TimeKey int=(select TimeKey from SysDayMatrix where date=@EndDt)

	if object_id('tempdb..#AcDailyTxnDetail_Cal')is not null
		drop table #AcDailyTxnDetail_Cal

	select AccountEntityID
	,ProductCode
	,a.CustomerAcID
	,TxnAmount
	,TxnType
	,TxnSubType
	,TxnValueDate
	,SourceAlt_Key
	,'Y' as TrueCredit
	,MNEMONICCODE
	,PARTICULAR
	into #AcDailyTxnDetail_Cal
	from dbo.AcDailyTxnDetail A
	inner join PRO.AccountCal_Hist B ON A.CustomerAcID=B.CustomerAcID
	and B.EffectiveFromTimeKey<=@TimeKey and B.EffectiveToTimeKey>=@TimeKey
	where TxnType in ('CREDIT','DEBIT')
	and TxnSubType in ('RECOVERY','INTEREST') 
	--AND TxnValueDate BETWEEN DATEADD(DD,-34,@StartDt) AND @EndDt /*19072023 - AMAR ADDED FOR OPTIMISATION */

	--14062024 Removed -34 condition as per discussion With Amar sir
	and TxnValueDate between @StartDt and @EndDt

	and isnull(TxnAmount,0)>0 
	and B.SourceAlt_Key=1
	and B.ProductCode not in('660','661','889','681','682','693','694','695','696','715','716','717','718',
					 '755','756','758','763','764','765','766','787','788','789','795','796',
					 '797','798','799','220','237','869','219','819','891','703','704','705','209','605','740','235') -----Removed ProductCode 778 Confirmed by Pankaj Mailed	

/*------------------------DISBURSEMENTS (FCC & FCR)----------------------------------------*/

if object_id('TEMPDB..#COD_TXN_MNEMONIC') IS NOT NULL
   drop table #COD_TXN_MNEMONIC

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


UPDATE A SET A.TRUECREDIT='N' FROM #AcDailyTxnDetail_Cal A 
		INNER JOIN #COD_TXN_MNEMONIC B
			ON A.CustomerAcID=B.COD_ACCT_NO
			AND A.MNEMONICCODE =B.Cod_txn_mnemonic
			AND TXT_TXN_NARRATIVE NOT LIKE '%ADJ-ENT%'
		WHERE   TXNTYPE='CREDIT'  AND TXNSUBTYPE='RECOVERY'
				--AND EXTDATE=@PROCESSDATE
		
DELETE FROM #AcDailyTxnDetail_Cal WHERE TrueCredit='N'
			
/*****above code is commented for optimization****directly deleting the ***TrueCredit ='N'*Records****2023-07-19**Pranay*****/

DELETE FROM #AcDailyTxnDetail_Cal 
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

if object_id('tempdb..#CustomDaysCreditDebit')is not null
	drop table #CustomDaysCreditDebit

select 
	AccountEntityID
--,MAX(CASE WHEN TxnType='CREDIT' AND TxnSubType='RECOVERY' THEN TxnValueDate ELSE NULL END)LastCreditDate
,SUM(CASE WHEN TxnType='CREDIT' AND TxnSubType='RECOVERY' THEN TxnAmount ELSE 0 END) CreditAmount
,SUM(CASE WHEN TxnType='DEBIT' AND TxnSubType='INTEREST' THEN TxnAmount  ELSE 0  END) DebitAmount
into #CustomDaysCreditDebit
FROM #AcDailyTxnDetail_Cal
	WHERE TxnValueDate BETWEEN @StartDt AND @EndDt /*19072023 - AMAR ADDED FOR OPTIMISATION */
group by AccountEntityID


update #CustomDaysCreditDebit set CreditAmount=0  where CreditAmount IS NULL --and SourceAlt_Key=1
update #CustomDaysCreditDebit set DebitAmount=0  where DebitAmount IS NULL --and SourceAlt_Key=1

select * from #CustomDaysCreditDebit

end try

begin catch
	select 'Proc Name: ' + ISNULL(ERROR_PROCEDURE(),'') + ' ErrorMsg: ' + ISNULL(ERROR_MESSAGE(),'')
end catch
end

GO