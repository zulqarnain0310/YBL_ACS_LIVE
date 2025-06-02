SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create proc [pro].[AccountWiseVariableCrDrAmtCal_Insert] --AccountWiseMiscDetailCal_Insert --new table name
AS




 DECLARE @TIMEKEY INT = (SELECT TimeKey FROM PRO.EXTDATE_MISDB WHERE Flg='Y')--StartDate='2023-06-05')     
 DECLARE @PROCESSDATE DATE= (SELECT DATE FROM SYSDAYMATRIX WHERE TIMEKEY=@TIMEKEY)     
 DECLARE @LastMonthDate DATE= (SELECT LastMonthDate FROM SYSDAYMATRIX WHERE TIMEKEY=@TIMEKEY)     
 DECLARE @NPAPROCESSDATE DATE  =(SELECT EOMONTH(DATE) FROM SYSDAYMATRIX WHERE CAST(DATE AS DATE) =@PROCESSDATE)     
 DECLARE @NPA_DAYS INT =DATEDIFF(DAY,@PROCESSDATE,@NPAPROCESSDATE)      
 DECLARE @LastTIMEKEY INT= (SELECT LastMonthDateKey FROM SYSDAYMATRIX WHERE TIMEKEY=@TIMEKEY)     
 DECLARE @LastTIMEKEY1 INT= (SELECT LastMonthDateKey FROM SYSDAYMATRIX WHERE TIMEKEY=@LastTIMEKEY)     
 DECLARE @LastTIMEKEY2 INT= (SELECT LastMonthDateKey FROM SYSDAYMATRIX WHERE TIMEKEY=@LastTIMEKEY1)     
 DECLARE @LastMonthDate2 DATE= (SELECT DATE FROM SYSDAYMATRIX WHERE TIMEKEY=@LastTIMEKEY2)     
      
      
 Declare @day1  int=90-@NPA_DAYS     
 Declare @day2  int=@day1-1     
      
      
 Declare  @QtrDefinition1 Varchar(5),@Refdate1 Date     
      
 SELECT @Refdate1=Date FROM SysDayMatrix     
 WHERE TimeKey=@TimeKey     
      
      
 Declare          @StartDt111 DATE     
 ,@EndDt111 DATE     
 SELECT  @StartDt111=DATEADD(day,-90,DATE)+1,     
 @EndDt111=Date     
 FROM SysDayMAtrix     
 WHERE TimeKEy=@TimeKey     
      
      
      
 Declare  @QtrDefinition Varchar(5),@Refdate Date     
      
 SELECT @Refdate=Date FROM SysDayMatrix     
 WHERE TimeKey=@TimeKey     
      
      
 Declare          @StartDt DATE     
 ,@EndDt DATE     
 SELECT  @StartDt=DATEADD(day,-@day1,DATE)+1,     
 @EndDt=Date     
 FROM SysDayMAtrix     
 WHERE TimeKEy=@TimeKey     
      
 Declare @StartDt1 DATE     
 SELECT  @StartDt1=DATEADD(day,-@day2,DATE) FROM SysDayMAtrix     
 WHERE TimeKEy=@TimeKey     
 Declare  @Timekey1 int     
 select  @Timekey1=timekey from SysDayMatrix where Date =@StartDt1     
      
       
      
 IF OBJECT_ID('Tempdb..##AcDailyTxnDetail') IS NOT NULL     
 DROP TABLE ##AcDailyTxnDetail     
 SELECT A.*     
 INTO ##AcDailyTxnDetail      
 FROM dbo.AcDailyTxnDetail A     
 INNER JOIN PRO.AccountCal B  with(nolock) ON A.CustomerAcID=B.CustomerAcID      
 WHERE TxnType IN ('CREDIT','DEBIT')     
 AND TxnSubType IN ('RECOVERY','INTEREST')           
 AND TxnValueDate BETWEEN @StartDt AND @EndDt     
 AND ISNULL(TxnAmount,0)>0      
 and B.SourceAlt_Key=1     
 and B.ProductCode not in('660','661','889','681','682','693','694','695','696','715','716','717','718',     
 '755','756','758','763','764','765','766','787','788','789','795','796',     
 '797','798','799','220','237','869','219','819','891','703','704','705','209','605','740','778','235')     
      
      
 Update  ##AcDailyTxnDetail set TrueCredit='Y'     
      
 /*------INWARDCHEQUE RETURNS(9101)/OUTWARD CHEQUE RETURNS(9501)------------------------------*/     
      
 UPDATE A SET A.TRUECREDIT='N' FROM ##AcDailyTxnDetail A      
 WHERE A.MNEMONICCODE  IN('9101','9501','1418')       
 AND TXNTYPE='CREDIT'  AND TXNSUBTYPE='RECOVERY'     
      
 /*------------------------DISBURSEMENTS (FCC & FCR)----------------------------------------*/     
      
 IF OBJECT_ID('TEMPDB..##COD_TXN_MNEMONIC') IS NOT NULL     
 DROP TABLE ##COD_TXN_MNEMONIC     
      
      
 SELECT A.COD_TXN_MNEMONIC,TXT_TXN_NARRATIVE, C.COD_ACCT_NO     
 INTO ##COD_TXN_MNEMONIC     
 FROM YBL_ACS_MIS.DBO.ODS_FCR_CH_NOBOOK_CURR A      
 INNER JOIN YBL_ACS_MIS.DBO.ODS_FCR_FFI_STAN_XREF_MMDD C     
 ON A.COD_ACCT_NO = C.COD_ACCT_NO     
 AND A.CTR_BATCH_NO = C.CTR_BATCH_NO     
 AND A.REF_SYS_TR_AUD_NO = C.STAN_NO_FC     
 AND A.DAT_VALUE = C.DAT_VALUE            
 AND C.COD_FCC_MODULE = 'CL'     
 AND C.COD_TXN_MNEMONIC in('12012')     
 WHERE A.COD_TXN_MNEMONIC in( '12012')     
      
      
 UPDATE A SET A.TRUECREDIT='N' FROM ##AcDailyTxnDetail A      
 INNER JOIN ##COD_TXN_MNEMONIC B     
 ON A.CustomerAcID=B.COD_ACCT_NO     
 AND A.MNEMONICCODE =B.Cod_txn_mnemonic     
 AND TXT_TXN_NARRATIVE NOT LIKE '%ADJ-ENT%'     
 WHERE   TXNTYPE='CREDIT'  AND TXNSUBTYPE='RECOVERY'       
      
      
 /*-------------NEFT RETURN(2557)/RTGS RETURN(2555)/RTGS Flex@Corp FUNDS TRANSFER CR(6931)------------------------------*/     
      
 UPDATE A SET A.TRUECREDIT='N'  FROM ##AcDailyTxnDetail A      
 WHERE A.MNEMONICCODE  IN('2557','2555','6909','6931')  AND PARTICULAR LIKE '%RETURN%'     
 AND TXNTYPE='CREDIT'  AND TXNSUBTYPE='RECOVERY'     
      
      
 /*--------------DD LIQUIDATED/CANCELLED-------------------------------------------------------------------------------------*/     
      
 UPDATE A SET A.TRUECREDIT='N' FROM ##AcDailyTxnDetail A      
 WHERE A.MNEMONICCODE  IN('8312','8310','6504','7793','8311')      
 AND TXNTYPE='CREDIT'  AND TXNSUBTYPE='RECOVERY'     
      
      
 UPDATE A SET A.TRUECREDIT='N'  FROM ##AcDailyTxnDetail A      
 WHERE A.MNEMONICCODE  IN('6926')  AND PARTICULAR LIKE '%REVERSAL%'     
 AND   TXNTYPE='CREDIT'  AND TXNSUBTYPE='RECOVERY'     
      
      
      
 DELETE FROM ##AcDailyTxnDetail WHERE TrueCredit='N'     
      
 IF OBJECT_ID('Tempdb..##CreditVarday') IS NOT NULL     
 DROP TABLE ##CreditVarday     
      
 SELECT SUM(ISNULL(TxnAmount,0)) as VariableCreditAmt ,A.CustomerAcID     
 INTO ##CreditVarday       
 FROM ##AcDailyTxnDetail A      
 WHERE  TxnType='CREDIT' AND TxnSubType='RECOVERY'      
 GROUP BY A.CustomerAcID     
      
      
 IF OBJECT_ID('Tempdb..##DebitVarday') IS NOT NULL     
 DROP TABLE ##DebitVarday     
      
 SELECT SUM(ISNULL(TxnAmount,0)) as VariableDebitAmt, A.CustomerAcID      
 INTO ##DebitVarday     
 FROM ##AcDailyTxnDetail A     
 WHERE  TxnType='DEBIT' AND TxnSubType='INTEREST'      
 GROUP BY A.CustomerAcID  


 -- IF OBJECT_ID('TEMPDB..##last90DebitBalance') IS NOT NULL     
 --DROP TABLE ##last90DebitBalance     
      
      
 --select CustomerAcID,count(1) cnt into ##last90DebitBalance from [Pro].[AccountCAL_hist]     
 --where  EffectiveFromTimeKey  >= @Timekey1 and EffectiveFROMTimeKey <=@Timekey and SourceAlt_Key=1     
 --and Balance >0 group by CustomerAcID   


  if OBJECT_ID('TEMPDB..##AccountCalMarking') IS NOT NULL
 DROP TABLE ##AccountCalMarking
select * into ##AccountCalMarking FROM PRO.ACCOUNTCAL WHERE SourceAlt_Key=1
 ALTER TABLE ##AccountCalMarking add AccountMarking varchar(100),DaysCount int ,InternalFDFlag CHAR(1),VariableDebitAmt DECIMAL (22,4),VariableCreditAmt DECIMAL (22,4)


 --case when A.DEG_RELAX_MSME='Y' THEN 'Y' ELSE 'N' END  AS [Internal Collateral],

UPDATE A 
 
 SET AccountMarking=
 
 CASE 
	
	WHEN DEG_RELAX_MSME='Y' AND AccountMarking IS NULL AND Asset_Norm IN('ALWYS_STD','CONDI_STD')		THEN 'Internal Flag Y' 
	
	WHEN  (	
				LineCode like'%294OD%'  OR LineCode like'%LDAG%' OR LineCode like'%FCYAG%' 
				OR LineCode like'%226TLA%' OR LineCode like'%IBUOD%'	OR LineCode like'%ODAG%'
		  )		AND AccountMarking IS NULL AND Asset_Norm IN('ALWYS_STD','CONDI_STD')					THEN  'FD OD'

	--WHEN AccountMarking IS NULL AND Asset_Norm IN('ALWYS_STD','CONDI_STD')								THEN 'FCNR And Third Party'

	END



 FROM ##AccountCalMarking A

UPDATE b set AccountMarking ='FCNR And Third Party'
 FROM curdat.AdvSecurityDetailAccountLevel a 
 inner join    ##AccountCalMarking b
 on a.CustomerAcID=b.CustomerAcID
 and a.EffectiveFromTimeKey  >= @Timekey and a.EffectiveFROMTimeKey <=@Timekey     
  AND CREATEDBY='TP'


UPDATE A SET AccountMarking='Product Code'
FROM ##AccountCalMarking A INNER JOIN DIMPRODUCT B ON A.PRODUCTALT_KEY=B.PRODUCTALT_KEY
 AND B.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND B.EFFECTIVETOTIMEKEY>=@TIMEKEY
WHERE B.ASSETNORM='ALWYS_STD'
 AND AccountMarking IS NULL AND Asset_Norm IN('ALWYS_STD','CONDI_STD')


IF OBJECT_ID('TEMPDB..##TRIMLINECODE') IS NOT NULL
  DROP TABLE ##TRIMLINECODE

SELECT ACCOUNTENTITYID,LINECODE INTO ##TRIMLINECODE  FROM ##AccountCalMarking WHERE  LINECODE IS NOT NULL

UPDATE ##TRIMLINECODE SET LINECODE=SUBSTRING(LINECODE,1,LEN(LINECODE)-1) FROM ##TRIMLINECODE WHERE RIGHT(LINECODE,1) LIKE '%[0-9]%'
UPDATE ##TRIMLINECODE SET LINECODE=SUBSTRING(LINECODE,1,LEN(LINECODE)-1) FROM ##TRIMLINECODE WHERE RIGHT(LINECODE,1) LIKE '%[0-9]%'
UPDATE ##TRIMLINECODE SET LINECODE=SUBSTRING(LINECODE,1,LEN(LINECODE)-1) FROM ##TRIMLINECODE WHERE RIGHT(LINECODE,1) LIKE '%[0-9]%'
UPDATE ##TRIMLINECODE SET LINECODE=SUBSTRING(LINECODE,1,LEN(LINECODE)-1) FROM ##TRIMLINECODE WHERE RIGHT(LINECODE,1) LIKE '%[0-9]%'
UPDATE ##TRIMLINECODE SET LINECODE=SUBSTRING(LINECODE,1,LEN(LINECODE)-1) FROM ##TRIMLINECODE WHERE RIGHT(LINECODE,1) LIKE '%[0-9]%'

UPDATE C SET AccountMarking='Line code'
FROM ##TRIMLINECODE A  INNER JOIN DIMLINECODE  B ON A.LINECODE=B.LINECODE
INNER JOIN ##AccountCalMarking C ON A.ACCOUNTENTITYID=C.ACCOUNTENTITYID 
AND B.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND B.EFFECTIVETOTIMEKEY>=@TIMEKEY
WHERE B.ASSETNORM='ALWYS_STD'
 AND AccountMarking IS NULL AND Asset_Norm IN('ALWYS_STD','CONDI_STD')

 UPDATE A SET AccountMarking='MOC' 
 FROM ##AccountCalMarking A 
INNER JOIN DATAUPLOAD.MOCCUSTOMERDATAUPLOAD B ON A.REFCUSTOMERID=B.CUSTOMERID 
  INNER JOIN DIMASSETCLASS DA       ON  DA.ASSETCLASSSHORTNAME= B.ASSETCLASSIFICATION AND 
                           DA.ASSETCLASSSHORTNAME='STD'  
WHERE B.MOCTYPE='MANUAL' AND B.EFFECTIVETOTIMEKEY=49999 
  AND AccountMarking IS NULL AND Asset_Norm IN('ALWYS_STD','CONDI_STD')

UPDATE A SET AccountMarking='MOC'
 FROM ##AccountCalMarking A 
INNER JOIN DATAUPLOAD.MOCCUSTOMERDATAUPLOAD B ON A.UcifEntityID=B.UcifEntityID 
  INNER JOIN DIMASSETCLASS DA       ON  DA.ASSETCLASSSHORTNAME= B.ASSETCLASSIFICATION AND 
                           DA.ASSETCLASSSHORTNAME='STD'  
WHERE B.MOCTYPE='MANUAL' AND B.EFFECTIVETOTIMEKEY=49999 
 
  AND AccountMarking IS NULL AND Asset_Norm IN('ALWYS_STD','CONDI_STD')   
      
 --IF OBJECT_ID('TEMPDB..##last90DebitBalance') IS NOT NULL     
 --DROP TABLE ##last90DebitBalance     
    
;WITH last90DebitBalance_CTE
AS
(
 SELECT CustomerAcID,COUNT(1) DaysCount 
 FROM [Pro].[AccountCAL_hist]     
 where  EffectiveFromTimeKey  >= @Timekey1 and EffectiveFROMTimeKey <=@Timekey and SourceAlt_Key=1  and   
  Balance >0 group by CustomerAcID   
 )

 UPDATE B SET DaysCount= B.DaysCount
 FROM
 last90DebitBalance_CTE a INNER JOIN ##AccountCalMarking b
 ON a.CustomerAcID=b.CustomerAcID

 --UPDATE A SET InternalFDFlag='Y'
 --FROM ##AccountCalMarking A WHERE DEG_RELAX_MSME='Y'

  UPDATE A SET InternalFDFlag='Y'
FROM ##AccountCalMarking A INNER JOIN YBL_ACS_MIS..ODS_FCR_CH_OD_LIMIT B
ON A.CustomerAcID=B.Cod_acct_no  WHERE B.flg_internal_fd='Y'


 UPDATE A SET VariableDebitAmt=B.VariableDebitAmt
 FROM ##AccountCalMarking A 
 INNER JOIN  ##DebitVarday B
 ON A.CustomerAcID=B.CustomerAcID

  UPDATE A SET VariableCreditAmt=B.VariableCreditAmt
 FROM ##AccountCalMarking A 
 INNER JOIN  ##CreditVarday B
 ON A.CustomerAcID=B.CustomerAcID


 DELETE FROM PRO.AccountWiseVariableCrDrAmtCal WHERE EffectiveFromTimeKey=@TIMEKEY



INSERT INTO PRO.AccountWiseVariableCrDrAmtCal
(

 AccountEntityID
,VariableCreditAmt
,VariableDebitAmt
,DaysCount
,InternalFDFlag
,AccountMarking
,EffectiveFromTimeKey
,EffectiveToTimeKey
)

SELECT 
AccountEntityID
,VariableCreditAmt
,VariableDebitAmt
,DaysCount
,InternalFDFlag
,AccountMarking
,EffectiveFromTimeKey
,EffectiveToTimeKey

FROM ##AccountCalMarking

DELETE FROM PRO.AccountWiseVariableCrDrAmtCal_Hist WHERE EffectiveFromTimeKey=@TIMEKEY

INSERT INTO PRO.AccountWiseVariableCrDrAmtCal_Hist
(

 AccountEntityID
,VariableCreditAmt
,VariableDebitAmt
,DaysCount
,InternalFDFlag
,AccountMarking
,EffectiveFromTimeKey
,EffectiveToTimeKey
)

SELECT 
AccountEntityID
,VariableCreditAmt
,VariableDebitAmt
,DaysCount
,InternalFDFlag
,AccountMarking
,EffectiveFromTimeKey
,EffectiveToTimeKey
FROM
PRO.AccountWiseVariableCrDrAmtCal

GO