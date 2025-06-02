SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


/*==============================================
 AUTHER : TRILOKI SHANKER KHANNA
 CREATE DATE : 24-10-2018
 MODIFY DATE : 24-10-2018
 DESCRIPTION : INSERT DATA PRO.LcBgAccountCal
 --EXEC PRO.LcBgAccountCalData

 ================================================*/

CREATE PROCEDURE [pro].[LcBgAccountCalData]
AS
BEGIN


DECLARE @TIMEKEY INT = (SELECT TIMEKEY FROM PRO.EXTDATE_MISDB WHERE FLG = 'Y')	
DECLARE @PROCESSINGDATE DATE=(SELECT DATE FROM SYSDAYMATRIX WHERE TIMEKEY=@TIMEKEY)	
DECLARE @SETID INT =(SELECT ISNULL(MAX(ISNULL(SETID,0)),0)+1 FROM [PRO].[PROCESSMONITOR] WHERE TIMEKEY=@TIMEKEY)
INSERT INTO PRO.PROCESSMONITOR(USERID,DESCRIPTION,MODE,STARTTIME,ENDTIME,TIMEKEY,SETID)
SELECT ORIGINAL_LOGIN(),'Work for LcBgAccountCalData','RUNNING',GETDATE(),NULL,@TIMEKEY,@SETID


IF OBJECT_ID('TEMPDB..#NEWLcBgAccountCal') IS NOT NULL
   DROP TABLE #NEWLcBgAccountCal


   SELECT AccountID CustomerAcID INTO #NEWLcBgAccountCal  FROM  YBL_ACS_MIS.. AccountData 
	WHERE  --PRODUCTCODE IN ('BM18','BM06','BM08','BM17','SLC5','SLC6','GM06')  ---AND ISNULL(MAXDPD,0)>0	
	---'BM18','BM06' removed as per confrimation mail from Pramod dt.08-Mar-2019 1:59 PM
	PRODUCTCODE IN ('BM08','BM17','SLC5','SLC6','GM06')  ---AND ISNULL(MAXDPD,0)>0	
      EXCEPT
   SELECT CustomerAcID FROM Pro.LcBgAccountCal where Effectivetotimekey=49999


 
   INSERT INTO Pro.LcBgAccountCal
   (
	CustomerAcID
	,SourceSystemCustomerID
	,AccountOpenDate
	,AccountStatus
	,CustStatus
	,EffectiveFromTimeKey
	,EffectiveToTimeKey
   )

SELECT 
	CustomerAcID
	,SourceSystemCustomerID
	,B.AccountOpenDate
	,'Live' AS AccountStatus
	,'Live' AS CustStatus
,EffectiveFromTimeKey=(SELECT TimeKey FROM PRO.EXTDATE_MISDB WHERE Flg='Y')
,EffectiveToTimeKey=49999
FROM #NEWLcBgAccountCal A INNER JOIN 
YBL_ACS_MIS.. AccountData  B ON A.CustomerAcID=B.AccountID

------overdue since date logic-----------------
IF OBJECT_ID('TEMPDB..#TEMPTABLELcBgAccountopenmin') IS NOT NULL
      DROP TABLE #TEMPTABLELcBgAccountopenmin

select min(AccountOpenDate)AccountOpenDate ,SourceSystemCustomerID  into #TEMPTABLELcBgAccountopenmin
from pro.LcBgAccountCal WHERE CustStatus='Live'
group by SourceSystemCustomerID

UPDATE A SET A.OverDueSinceDt=b.AccountOpenDate
FROM PRO.LcBgAccountCal A INNER JOIN #TEMPTABLELcBgAccountopenmin B ON A.SourceSystemCustomerID=B.SourceSystemCustomerID
and A.OverDueSinceDt is null
------------------------------

/*------EXPIRE DATA FOR ---------------------*/
UPDATE A SET A.EffectiveToTimekey=@TimeKey-1,AccountStatus='Closed'
FROM Pro.LcBgAccountCal A LEFT OUTER JOIN  
(
select b.AccountID  CustomerAcID  from PRO.LcBgAccountCal a inner join YBL_ACS_MIS..AccountData b
 on a.CustomerAcID=b.AccountID and b.AccountID is not null
) C 
ON A.CustomerAcID=C.CustomerAcID
WHERE C.CustomerAcID IS NULL AND A.EffectiveToTimekey=49999


IF OBJECT_ID('TEMPDB..#TEMPTABLELcBgAccountCal') IS NOT NULL
      DROP TABLE #TEMPTABLELcBgAccountCal

SELECT A.SourceSystemCustomerID,TOTALCOUNT  INTO #TEMPTABLELcBgAccountCal FROM 
(
SELECT A.SourceSystemCustomerID,COUNT(1) TOTALCOUNT FROM PRO.LcBgAccountCal A
GROUP BY A.SourceSystemCustomerID
)
A INNER JOIN 
(
SELECT A.SourceSystemCustomerID,COUNT(1) TOTAL_MAXCOUNT FROM PRO.LcBgAccountCal A 
WHERE  ISNULL(A.AccountStatus,'N')='Closed' 
GROUP BY A.SourceSystemCustomerID
) B ON A.SourceSystemCustomerID=B.SourceSystemCustomerID
 AND A.TOTALCOUNT=B.TOTAL_MAXCOUNT
 

  /*------ CLOSED CUSTOMER-----------*/
  
UPDATE A SET A.CustStatus='Closed'
FROM PRO.LcBgAccountCal A INNER JOIN #TEMPTABLELcBgAccountCal B ON A.SourceSystemCustomerID=B.SourceSystemCustomerID


UPDATE A SET AccountCloseDate=B.DATE
    FROM PRO.LcBgAccountCal  A 
   inner join sysdaymatrix B on A.EffectiveToTimeKey=B.TimeKey
   where AccountStatus='Closed' and A.AccountCloseDate is null

   IF OBJECT_ID('TEMPDB..#MaxCustStatus') IS NOT NULL
	DROP TABLE #MaxCustStatus
  
		SELECT SourceSystemCustomerID, MIN(EffectiveToTimeKey) AS EffectiveToTimeKey   INTO #MaxCustStatus 
		FROM Pro.LcBgAccountCal WHERE  CustStatus='Closed'
		AND CustomerCloseDate IS NULL
		GROUP BY  SourceSystemCustomerID

   UPDATE B SET CustomerCloseDate=C.DATE
    FROM #MaxCustStatus A
	INNER JOIN Pro.LcBgAccountCal B ON A.SourceSystemCustomerID=B.SourceSystemCustomerID
	inner join sysdaymatrix C on A.EffectiveToTimeKey=C.TimeKey
   where B.CustStatus='Closed' and B.CustomerCloseDate is null

    DROP TABLE #NEWLcBgAccountCal
	DROP TABLE #TEMPTABLELcBgAccountopenmin
	DROP TABLE #TEMPTABLELcBgAccountCal 
	DROP TABLE #MaxCustStatus

UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE IDENTITYKEY = (SELECT IDENT_CURRENT('PRO.PROCESSMONITOR')) AND  TIMEKEY=@TIMEKEY AND DESCRIPTION='Work for LcBgAccountCalData'

END











GO