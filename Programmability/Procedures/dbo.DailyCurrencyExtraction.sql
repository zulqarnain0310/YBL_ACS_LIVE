SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/*=========================================
 AUTHER :  TRILOKI SHANKER KHANNA
 CREATE DATE : 25-02-2019
 MODIFY DATE : 25-02-2019
 DESCRIPTION : Daily Currency Extraction
 EXEC [dbo].[DailyCurrencyExtraction]
=============================================*/


CREATE PROC [dbo].[DailyCurrencyExtraction]
AS
BEGIN

Declare @TimeKey int
Select @TimeKey=TimeKey from dbo.SysDayMatrix where Cast([Date] as date)=Cast(Getdate() as Date)
-------------------------------added for process monitor-----------------------------	
Declare @TimeKey1 int
Select @TimeKey1=(SELECT TIMEKEY FROM PRO.EXTDATE_MISDB WHERE FLG = 'Y')
----------------------------------------------------------------------------------------
DECLARE @ExTimeKey int=(select timekey from SysDayMatrix where Cast([Date] as date)=Cast(Getdate() as Date))
DECLARE @SETID INT =(SELECT ISNULL(MAX(ISNULL(SETID,0)),0)+1 FROM [PRO].[PROCESSMONITOR] WHERE TIMEKEY=@TIMEKEY1)
DECLARE @TIMEKEYSAT INT = (SELECT B.TimeKey FROM SysDayMatrix A  INNER JOIN PRO.EXTDATE_MISDB B 
ON A.TimeKey=B.TimeKey AND A.DateName LIKE '%SATURDAY%'  AND B.FLG = 'Y')
 
 DECLARE @TIMEKEYSUN INT = (SELECT B.TimeKey FROM SysDayMatrix A  INNER JOIN PRO.EXTDATE_MISDB B 
ON A.TimeKey=B.TimeKey AND A.DateName LIKE '%SUNDAY%'  AND B.FLG = 'Y')

DECLARE @TIMEKEYDEL INT = (SELECT TIMEKEY FROM PRO.EXTDATE_MISDB WHERE FLG = 'Y')

DELETE FROM DimCurCovRate WHERE EffectiveFromTimeKey=@TIMEKEYDEL AND CurrencyAlt_Key<>62

INSERT INTO PRO.PROCESSMONITOR(USERID,DESCRIPTION,MODE,STARTTIME,ENDTIME,TIMEKEY,SETID)
SELECT ORIGINAL_LOGIN(),'Work for DailyCurrencyExtraction','RUNNING',GETDATE(),NULL,@TIMEKEY1,@SETID


UPDATE A  SET SrcSysCurrencyCode=NAM_CCY_SHORT,SrcSysCurrencyName=NAM_CURRENCY
from DIMCURRENCY A
INNER JOIN YBL_ACS_MIS.. ODS_FCR_BA_ccy_code B
ON A.CurrencyCode=B.NAM_CCY_SHORT

IF OBJECT_ID ('TEMPDB..#DimCurCovRate') IS NOT NULL
DROP TABLE #DimCurCovRate

CREATE TABLE [#DimCurCovRate](
	[CurrencyAlt_Key] [smallint] NOT NULL,
	[CurrencyCode] [varchar](10) NULL,
	[CurrencyName] [varchar](50) NULL,
	[ConvRate] [decimal](18, 4) NULL,
	[ConvDate] [date] NULL,
	[AuthorisationStatus] [varchar](2) NULL,
	[EffectiveFromTimeKey] [int] NULL,
	[EffectiveToTimeKey] [int] NULL,
	[CreatedBy] [varchar](20) NULL,
	[DateCreated] [smalldatetime] NULL,
	[ModifiedBy] [varchar](20) NULL,
	[DateModified] [smalldatetime] NULL,
	[ApprovedBy] [varchar](20) NULL,
	[DateApproved] [smalldatetime] NULL,
	[D2Ktimestamp] [timestamp] NOT NULL
) ON [PRIMARY]




INSERT INTO #DimCurCovRate

(
 CurrencyAlt_Key
,CurrencyCode
,CurrencyName
,ConvRate
,ConvDate
,AuthorisationStatus
,EffectiveFromTimeKey
,EffectiveToTimeKey
,CreatedBy
,DateCreated
,ModifiedBy
,DateModified
,ApprovedBy
,DateApproved

)

SELECT 
 C.CurrencyAlt_Key
,C.CurrencyCode
,C.CurrencyName
,CAST(CAST(A.RAT_CCY_BOOK AS float) AS  DECIMAL (18,8))
,A.DAT_TIM_RATE_EFF AS ConvDate
,NULL AS AuthorisationStatus
,SysDayMatrix.TIMEKEY AS EffectiveFromTimeKey
,SysDayMatrix.TIMEKEY AS EffectiveToTimeKey
,NULL AS CreatedBy
,NULL AS DateCreated
,NULL AS ModifiedBy
,NULL AS DateModified
,NULL AS ApprovedBy
,NULL AS DateApproved

FROM YBL_ACS_MIS.. ODS_FCR_BA_ccy_rate A 
INNER JOIN YBL_ACS_MIS.. ODS_FCR_BA_ccy_code B ON A.COD_CCY=B.COD_CCY
INNER JOIN DIMCURRENCY C ON C.CurrencyCode=B.NAM_CCY_SHORT
inner join SysDayMatrix on cast(DAT_TIM_RATE_EFF as Date)= cast(SysDayMatrix.date as date)
WHERE (C.EffectiveFromTimeKey<=@TIMEKEY AND C.EffectiveToTimeKey>=@TIMEKEY)
Order by A.DAT_TIM_RATE_EFF



MERGE DimCurCovRate  AS T
USING #DimCurCovRate AS S

 ON     LTRIM(RTRIM(T.CurrencyCode))=LTRIM(RTRIM(S.CurrencyCode))
	--AND	LTRIM(RTRIM(T.ConvRate))=LTRIM(RTRIM(S.ConvRate))
      AND LTRIM(RTRIM(T.EffectiveFromTimeKey))=LTRIM(RTRIM(S.EffectiveFromTimeKey))  							
WHEN NOT MATCHED THEN 

INSERT 
(
CurrencyAlt_Key
,CurrencyCode
,CurrencyName
,ConvRate
,ConvDate
,AuthorisationStatus
,EffectiveFromTimeKey
,EffectiveToTimeKey
,CreatedBy
,DateCreated
,ModifiedBy
,DateModified
,ApprovedBy
,DateApproved


)
VALUES
(

CurrencyAlt_Key
,CurrencyCode
,CurrencyName
,ConvRate
,ConvDate
,AuthorisationStatus
,EffectiveFromTimeKey
,EffectiveToTimeKey
,CreatedBy
,DateCreated
,ModifiedBy
,DateModified
,ApprovedBy
,DateApproved


);



 INSERT INTO DimCurCovRate
 (
CurrencyAlt_Key
,CurrencyCode
,CurrencyName
,ConvRate
,ConvDate
,AuthorisationStatus
,EffectiveFromTimeKey
,EffectiveToTimeKey
,CreatedBy
,DateCreated
,ModifiedBy
,DateModified
,ApprovedBy
,DateApproved
)

 SELECT 
 CurrencyAlt_Key
,CurrencyCode
,CurrencyName
,ConvRate
,DATEADD(DAY,1,ConvDate) ConvDate
,AuthorisationStatus
,@TIMEKEYSAT EffectiveFromTimeKey
,@TIMEKEYSAT EffectiveToTimeKey
,CreatedBy
,DateCreated
,ModifiedBy
,DateModified
,ApprovedBy
,DateApproved

FROM  DimCurCovRate
 WHERE EffectiveFromTimeKey=@TIMEKEYSAT-1 AND CurrencyAlt_Key<>62

 INSERT INTO DimCurCovRate
 (
CurrencyAlt_Key
,CurrencyCode
,CurrencyName
,ConvRate
,ConvDate
,AuthorisationStatus
,EffectiveFromTimeKey
,EffectiveToTimeKey
,CreatedBy
,DateCreated
,ModifiedBy
,DateModified
,ApprovedBy
,DateApproved
)

 SELECT 
 CurrencyAlt_Key
,CurrencyCode
,CurrencyName
,ConvRate
,DATEADD(DAY,2,ConvDate) ConvDate
,AuthorisationStatus
,@TIMEKEYSUN EffectiveFromTimeKey
,@TIMEKEYSUN EffectiveToTimeKey
,CreatedBy
,DateCreated
,ModifiedBy
,DateModified
,ApprovedBy
,DateApproved

FROM  DimCurCovRate
 WHERE EffectiveFromTimeKey=@TIMEKEYSUN-2 AND CurrencyAlt_Key<>62


 DROP TABLE #DimCurCovRate
UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE IDENTITYKEY = (SELECT IDENT_CURRENT('PRO.PROCESSMONITOR')) AND  TIMEKEY=@TIMEKEY1 AND DESCRIPTION='Work for DailyCurrencyExtraction'

END



GO