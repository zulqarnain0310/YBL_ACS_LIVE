SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

Create PROCEDURE [pro].[AccountWiseMiscDetailCal_Insert] 
AS
BEGIN


 DECLARE @TIMEKEY INT = (SELECT TimeKey FROM PRO.EXTDATE_MISDB WHERE Flg='Y')--StartDate='2023-06-05')     
 DECLARE @PROCESSDATE DATE= (SELECT DATE FROM SYSDAYMATRIX WHERE TIMEKEY=@TIMEKEY)     
 DECLARE @LastMonthDate DATE= (SELECT LastMonthDate FROM SYSDAYMATRIX WHERE TIMEKEY=@TIMEKEY)     
 DECLARE @NPAPROCESSDATE DATE  =(SELECT EOMONTH(DATE) FROM SYSDAYMATRIX WHERE CAST(DATE AS DATE) =@PROCESSDATE)     
 DECLARE @NPA_DAYS INT =DATEDIFF(DAY,@PROCESSDATE,@NPAPROCESSDATE)  
 
 DECLARE @SETID INT =(SELECT ISNULL(MAX(ISNULL(SETID,0)),0)+1 FROM [PRO].[PROCESSMONITOR] WHERE TIMEKEY=@TIMEKEY)

 INSERT INTO PRO.PROCESSMONITOR(USERID,DESCRIPTION,MODE,STARTTIME,ENDTIME,TIMEKEY,SETID)
SELECT ORIGINAL_LOGIN(),'Work for AccountWiseMiscDetailCal_Insert','RUNNING',GETDATE(),NULL,@TIMEKEY,@SETID    
      
 Declare @day1  int=90-@NPA_DAYS     
 Declare @day2  int=@day1-1     
      
      
      
 Declare          @StartDt111 DATE     
 ,@EndDt111 DATE     
 SELECT  @StartDt111=DATEADD(day,-90,DATE)+1,     
 @EndDt111=Date     
 FROM SysDayMAtrix     
 WHERE TimeKEy=@TimeKey     
      
     
      
      
 Declare          @StartDt DATE     
 ,@EndDt DATE     
 SELECT  @StartDt=DATEADD(day,-@day1,DATE)+1,     
 @EndDt=Date     
 FROM SysDayMAtrix     
 WHERE TimeKEy=@TimeKey     
 Select   @StartDt,   @EndDt

 Declare @StartDt1 DATE     
 SELECT  @StartDt1=DATEADD(day,-@day2,DATE) FROM SysDayMAtrix     
 WHERE TimeKEy=@TimeKey     
 Declare  @Timekey1 int     
 select  @Timekey1=timekey from SysDayMatrix where Date =@StartDt1     
      
    IF OBJECT_ID('Tempdb..##DebitCreditVarday') IS NOT NULL     
 DROP TABLE ##DebitCreditVarday
 SELECT 
 A.AccountEntityID  
 ,SUM(CASE WHEN TxnType='CREDIT' AND TxnSubType='RECOVERY' THEN TxnAmount ELSE 0 END)  CreditAmount
 ,SUM(CASE WHEN TxnType='DEBIT' AND TxnSubType='INTEREST' THEN TxnAmount  ELSE 0  END) DebitAmount
 Into ##DebitCreditVarday
 FROM Pro.[AcDailyTxnDetail_Cal] A     
  WHERE TxnValueDate BETWEEN @StartDt AND @EndDt     
 GROUP BY A.AccountEntityID  


  if OBJECT_ID('TEMPDB..##AccountCalMarking') IS NOT NULL
 DROP TABLE ##AccountCalMarking
select * into ##AccountCalMarking FROM PRO.ACCOUNTCAL WHERE SourceAlt_Key=1
 ALTER TABLE ##AccountCalMarking add AccountMarking varchar(100),DaysCount int ,InternalFDFlag CHAR(1),VariableDebitAmt DECIMAL (22,4),VariableCreditAmt DECIMAL (22,4)
 ,FD_UCIF_Security DECIMAL (22,4)

 -------------Update UCIC Data in Table added 06-07-2023------------
update A set UCIF_ID=b.UCIF_ID from ##AccountCalMarking A
inner join pro.accountcal B on A.AccountEntityID=B.AccountEntityID

UPDATE A SET AccountMarking='Internal Flag Y'
FROM ##AccountCalMarking A INNER JOIN YBL_ACS_MIS..ODS_FCR_CH_OD_LIMIT B
ON A.CustomerAcID=B.Cod_acct_no  
WHERE B.flg_internal_fd='Y' AND AccountMarking IS NULL

UPDATE A set AccountMarking='FD OD'
FROM ##AccountCalMarking A
 where( LineCode like'%294ODAGFD%'  OR LineCode like'%ODAG-FCNR%' OR LineCode like'%IBUODAGFD%' 
	
 OR LineCode like'%226TLAGFD%' OR LineCode like'%FCYAG-DEP%' OR LineCode like'%LDAG-FCNR%'
)

							  AND AccountMarking IS NULL AND Asset_Norm IN('ALWYS_STD','CONDI_STD')

UPDATE b set AccountMarking ='FCNR And Third Party'
 FROM curdat.AdvSecurityDetailAccountLevel a 
 inner join    ##AccountCalMarking b
 on a.CustomerAcID=b.CustomerAcID
 and a.EffectiveFromTimeKey  >= @Timekey and a.EffectiveFROMTimeKey <=@Timekey     
  AND CREATEDBY='TP' AND AccountMarking IS NULL


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
  ---------------------------------FDOD UCIF Security Added 06-07-2023----------------
  IF OBJECT_ID('TEMPDB..##SecurityAmtFDOD')IS NOT NULL
DROP TABLE ##SecurityAmtFDOD

SELECT SUM(ISNULL(A.CurrentValue,0)) as CurrentValue , A.UCIF_ID
 INTO ##SecurityAmtFDOD
 FROM curdat.AdvSecurityDetailUcifLevel A
 where EffectiveFromTimeKey>=@TIMEKEY and EffectiveToTimeKey<=@TIMEKEY
 group by A.UCIF_ID

update A set FD_UCIF_Security=CurrentValue from ##AccountCalMarking A
inner join ##SecurityAmtFDOD B on A.UCIF_ID=B.UCIF_ID
Where A.AccountMarking='FD OD'



IF OBJECT_ID('TEMPDB..#last90DebitBalance') IS NOT NULL
   DROP TABLE #last90DebitBalance

		
select CustomerAcID,count(1) DaysCount into #last90DebitBalance from YBL_ACS.pro.AcDebitDetail_Cal
where  EffectiveFromTimeKey  >= @Timekey1 and EffectiveFROMTimeKey <=@Timekey  
group by CustomerAcID


 UPDATE B SET DaysCount= A.DaysCount
 FROM
 #last90DebitBalance a INNER JOIN ##AccountCalMarking b
 ON a.CustomerAcID=b.CustomerAcID


  UPDATE A SET InternalFDFlag='Y'
FROM ##AccountCalMarking A INNER JOIN YBL_ACS_MIS..ODS_FCR_CH_OD_LIMIT B
ON A.CustomerAcID=B.Cod_acct_no  WHERE B.flg_internal_fd='Y'


 UPDATE A SET VariableCreditAmt=B.CreditAmount, VariableDebitAmt=DebitAmount
 FROM ##AccountCalMarking A 
 INNER JOIN  ##DebitCreditVarday B
 ON A.AccountEntityID=B.AccountEntityID


Truncate table PRO.AccountWiseMiscDetailCal

INSERT INTO PRO.AccountWiseMiscDetailCal
(

 AccountEntityID
,VariableCreditAmt
,VariableDebitAmt
,DaysCount
,InternalFDFlag
,AccountMarking
,EffectiveFromTimeKey
,EffectiveToTimeKey
,UCIF_ID                 --Newly Added 06-07-2023
,FD_UCIF_Security		   --Newly Added 06-07-2023
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
,UCIF_ID                 --Newly Added 06-07-2023
,FD_UCIF_Security		   --Newly Added 06-07-2023

FROM ##AccountCalMarking

DELETE FROM PRO.AccountWiseMiscDetailCal_Hist WHERE EffectiveFromTimeKey=@TIMEKEY

INSERT INTO PRO.AccountWiseMiscDetailCal_Hist
(

 AccountEntityID
,VariableCreditAmt
,VariableDebitAmt
,DaysCount
,InternalFDFlag
,AccountMarking
,EffectiveFromTimeKey
,EffectiveToTimeKey
,UCIF_ID                 --Newly Added 06-07-2023
,FD_UCIF_Security		   --Newly Added 06-07-2023
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
,UCIF_ID                 --Newly Added 06-07-2023
,FD_UCIF_Security		   --Newly Added 06-07-2023
FROM
PRO.AccountWiseMiscDetailCal

UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE IDENTITYKEY = (SELECT IDENT_CURRENT('PRO.PROCESSMONITOR')) AND 
 TIMEKEY=@TIMEKEY AND DESCRIPTION='Work for AccountWiseMiscDetailCal_Insert'

 END
GO