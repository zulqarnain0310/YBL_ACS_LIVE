SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


create PROCEDURE [pro].[Insertdataforoutoforder]
  
AS 

BEGIN

DECLARE @TIMEKEY INT = (SELECT TIMEKEY FROM PRO.EXTDATE_MISDB WHERE FLG = 'Y')
DECLARE @PROCESSINGDATE DATE=(SELECT DATE FROM SYSDAYMATRIX WHERE TIMEKEY=@TIMEKEY) 
DECLARE @SETID INT =(SELECT ISNULL(MAX(ISNULL(SETID,0)),0)+1 FROM [PRO].[PROCESSMONITOR] WHERE TIMEKEY=@TIMEKEY)

INSERT INTO PRO.PROCESSMONITOR(USERID,DESCRIPTION,MODE,STARTTIME,ENDTIME,TIMEKEY,SETID)
SELECT ORIGINAL_LOGIN(),'INSERT DATA FOR Insertdataforoutoforder','RUNNING',GETDATE(),NULL,@TIMEKEY,@SETID

DELETE  FROM  PRO.Rptoutoforderdata WHERE TIMEKEY=@TIMEKEY 

INSERT INTO PRO.Rptoutoforderdata
(PANNO                                    ,
UCIF_ID                                    ,
RefCustomerID                                 ,
CustomerName                              ,
SourceSystemCustomerID                     ,
CustomerAcID                               ,
CustSegmentCode                           ,
ProductCode                                  ,
ProductName                                 ,
[Balance]             ,
DPD_IntService                             ,
GRTR_THAN_90 ,
DAYS_61_TO_90 ,
DAYS_31_TO_60 ,
UPTO_30 ,
OverdueAmt ,
BranchCode                                  ,
BranchName                             ,
SourceName                             ,
TIMEKEY
)

SELECT
CCH.PANNO                                       AS PAN_NUMBER,
CCH.UCIF_ID                                     AS UCIC,
CCH.RefCustomerID                               AS FCR_CustomerID,
CCH.CustomerName                                AS Customer_NAME,
CCH.SourceSystemCustomerID                      AS SourceSystemCustomerID,
ACH.CustomerAcID                                AS ACCOUNT_ID,
CCH.CustSegmentCode                             AS BS,
ACH.ProductCode                                 AS ProductCode ,
DP.ProductName                                  AS PRODUCT_CLASS,
ISNULL(ACH.Balance,0)                  AS OS,
ACH.DPD_IntService                              AS DPD_IntService,
0                                       AS GRTR_THAN_90,
0                                      AS DAYS_61_TO_90,
0                                       AS DAYS_31_TO_60,
0                                      AS UPTO_30,
ISNULL(ACH.OverdueAmt,0)                  AS TOTAL_OVERDUE,
ACH.BranchCode                                  AS Brn,
BranchName                                      AS Branch_Name,
DSDB.SourceName                                 AS SourceName,
ACH.EffectiveFromTimeKey

FROM PRO.CUSTOMERCAL CCH
INNER JOIN PRO.ACCOUNTCAL ACH         ON CCH.SourceSystemCustomerID=ACH.SourceSystemCustomerID
                                             

LEFT JOIN DimBranch DB                     ON DB.BranchCode=ACH.BranchCode
                                              AND DB.EffectiveFromTimeKey<= @TimeKey
                                              AND DB.EffectiveToTimeKey>=@TimeKey

LEFT JOIN DimProduct DP                    ON DP.ProductAlt_Key=ACH.ProductAlt_Key
                                              AND DP.EffectiveFromTimeKey<= @TimeKey
                                              AND DP.EffectiveToTimeKey>=@TimeKey


INNER JOIN DimSourceDB DSDB                ON DSDB.SourceAlt_Key=ACH.SourceAlt_Key
                                              AND DSDB.EffectiveFromTimeKey<= @TimeKey
                                              AND DSDB.EffectiveToTimeKey>=@TimeKey


WHERE ISNULL(DPD_IntService,0) >=1
      AND ISNULL(ACH.BANKASSETCLASS,'N')<>'WRITEOFF'
      AND DSDB.SourceName IN ('FCR') 


update A set GRTR_THAN_90 =DemandAmt From PRO.Rptoutoforderdata A inner join
( 
select sum(BalanceDemand) as DemandAmt,CUSTOMERACID from [CURDAT].[AdvAcDemandDetail]
where  datediff(day,DemandDate,@PROCESSINGDATE)+1 > 90 
and BalanceDemand>0 and EffectiveToTimeKey=49999
group by CUSTOMERACID
) B 
on A.CUSTOMERACID=b.CUSTOMERACID
where TIMEKEY=@TIMEKEY

----Bucket 61 to 90
update A set DAYS_61_TO_90 =DemandAmt From PRO.Rptoutoforderdata A inner join
( 
select sum(BalanceDemand) as DemandAmt,CUSTOMERACID from [CURDAT].[AdvAcDemandDetail] 
where datediff(day,DemandDate,@PROCESSINGDATE)+1 > 60 and datediff(day,DemandDate,@PROCESSINGDATE)+1 <=90
and BalanceDemand>0 and EffectiveToTimeKey=49999
group by CUSTOMERACID
) B 
on A.CUSTOMERACID=b.CUSTOMERACID
where TIMEKEY=@TIMEKEY

 ----Bucket 31 to 60
update A set DAYS_31_TO_60 =DemandAmt From PRO.Rptoutoforderdata A inner join
( 
select sum(BalanceDemand) as DemandAmt,CUSTOMERACID from [CURDAT].[AdvAcDemandDetail]
where  datediff(day,DemandDate,@PROCESSINGDATE)+1 > 30 and datediff(day,DemandDate,@PROCESSINGDATE)+1 <=60
and BalanceDemand>0 and EffectiveToTimeKey=49999
group by CUSTOMERACID
) B 
on A.CUSTOMERACID=b.CUSTOMERACID
where TIMEKEY=@TIMEKEY

 ----Bucket 1 to 30
update A set UPTO_30 =DemandAmt From PRO.Rptoutoforderdata A inner join
( 
select sum(BalanceDemand) as DemandAmt,CUSTOMERACID from [CURDAT].[AdvAcDemandDetail]
where datediff(day,DemandDate,@PROCESSINGDATE)+1 <=30
and BalanceDemand>0 and EffectiveToTimeKey=49999
group by CUSTOMERACID
) B 
on A.CUSTOMERACID=b.CUSTOMERACID
where TIMEKEY=@TIMEKEY

update PRO.Rptoutoforderdata set GRTR_THAN_90=OverdueAmt where DPD_IntService=91 and GRTR_THAN_90=0  and OverdueAmt>0
and TIMEKEY=@TIMEKEY

UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' 
WHERE IDENTITYKEY = (SELECT IDENT_CURRENT('PRO.PROCESSMONITOR'))
 AND  TIMEKEY=@TIMEKEY AND DESCRIPTION='INSERT DATA FOR Insertdataforoutoforder'
  
 END



GO