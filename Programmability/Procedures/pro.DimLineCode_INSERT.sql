SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


/*==============================================
 AUTHER : TRILOKI KHANNA 
 CREATE DATE : 28-11-2018
 MODIFY DATE : 28-11-2018
 DESCRIPTION : INSERT DATA FOR MnemonicCode
 --EXEC PRO.DimLineCode_INSERT
 ================================================*/

CREATE PROCEDURE [pro].[DimLineCode_INSERT]
AS
BEGIN
DECLARE @TIMEKEY INT = (SELECT TIMEKEY FROM PRO.EXTDATE_MISDB WHERE FLG = 'Y')
DECLARE @SETID INT =(SELECT ISNULL(MAX(ISNULL(SETID,0)),0)+1 FROM [PRO].[PROCESSMONITOR] WHERE TIMEKEY=@TIMEKEY)

INSERT INTO PRO.PROCESSMONITOR(USERID,DESCRIPTION,MODE,STARTTIME,ENDTIME,TIMEKEY,SETID)
SELECT ORIGINAL_LOGIN(),'Work for DimLineCode_Insert','RUNNING',GETDATE(),NULL,@TIMEKEY,@SETID


IF OBJECT_ID('TEMPDB..#NEWLineCode') IS NOT NULL
   DROP TABLE #NEWLineCode


   SELECT LINE_CODE LineCode INTO #NEWLineCode  FROM YBL_ACS_MIS.dbo.ODS_FCC_GETM_TEMPLE
   EXCEPT
   SELECT LineCode FROM DimLineCode


 
   INSERT INTO DimLineCode
   (
LineCode
,LineCodeName
,LineCodeShortName
,LineCodeShortNameEnum
,LineCodeGroup
,LineCodeSubGroup
,LineCodeSegment
,LineCodeValidCode
,SrcSysLineCodeCode
,SrcSysLineCodeName
,DestSysLineCodeCode
,AssetNorm
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

LineCode=A.LineCode
,LineCodeName=B.DESCRIPTION
,LineCodeShortName=NULL
,LineCodeShortNameEnum=NULL
,LineCodeGroup=NULL
,LineCodeSubGroup=NULL
,LineCodeSegment=NULL
,LineCodeValidCode=NULL
,SrcSysLineCodeCode=NULL
,SrcSysLineCodeName=NULL
,DestSysLineCodeCode=NULL
,AssetNorm='NORMAL'
,AuthorisationStatus=NULL
,EffectiveFromTimeKey=(SELECT TimeKey FROM PRO.EXTDATE_MISDB WHERE Flg='Y')
,EffectiveToTimeKey=49999
,CreatedBy='SSIS'
,DateCreated=GETDATE()
,ModifiedBy=NULL
,DateModified=NULL
,ApprovedBy=NULL
,DateApproved=NULL

FROM #NEWLineCode A INNER JOIN 
YBL_ACS_MIS.dbo.ODS_FCC_GETM_TEMPLE B ON A.LineCode=B.LINE_CODE
ORDER BY A.LineCode


UPDATE DimLineCode SET AssetNorm='ALWYS_STD' WHERE LineCode IN('100DBCNO1','100DBCNOC','100DBGNO1','100DBGNO2','100DBGNOC','100DLCNOC','100SLCNOC') AND  AssetNorm<>'ALWYS_STD'

DROP TABLE #NEWLineCode

UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE IDENTITYKEY = (SELECT IDENT_CURRENT('PRO.PROCESSMONITOR')) AND  TIMEKEY=@TIMEKEY AND DESCRIPTION='Work for DimLineCode_Insert'

END







GO