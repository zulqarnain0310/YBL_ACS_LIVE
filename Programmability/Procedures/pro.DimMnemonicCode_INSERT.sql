SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/*==============================================
 AUTHER : sanjeev kumar sharma
 CREATE DATE : 24-10-2018
 MODIFY DATE : 24-10-2018
 DESCRIPTION : INSERT DATA FOR MnemonicCode
 --EXEC PRO.DimMnemonicCode_INSERT

 ================================================*/

CREATE PROCEDURE [pro].[DimMnemonicCode_INSERT]
AS
BEGIN

DECLARE @TIMEKEY INT = (SELECT TIMEKEY FROM PRO.EXTDATE_MISDB WHERE FLG = 'Y')
DECLARE @SETID INT =(SELECT ISNULL(MAX(ISNULL(SETID,0)),0)+1 FROM [PRO].[PROCESSMONITOR] WHERE TIMEKEY=@TIMEKEY)

INSERT INTO PRO.PROCESSMONITOR(USERID,DESCRIPTION,MODE,STARTTIME,ENDTIME,TIMEKEY,SETID)
SELECT ORIGINAL_LOGIN(),'Work for DimMnemonicCode_Insert','RUNNING',GETDATE(),NULL,@TIMEKEY,@SETID

IF OBJECT_ID('TEMPDB..#NEWMnemonicCode') IS NOT NULL
   DROP TABLE #NEWMnemonicCode

 
   SELECT Cod_txn_mnemonic MnemonicValidCode INTO #NEWMnemonicCode  FROM YBL_ACS_mis.dbo.ODS_FCR_BA_TXN_MNEMONIC
   EXCEPT
   SELECT MnemonicCode FROM DimMnemonicCode

   INSERT INTO DimMnemonicCode
   (
MnemonicCode
,MnemonicName
,MnemonicShortName
,MnemonicShortNameEnum
,MnemonicGroup
,MnemonicSubGroup
,MnemonicSegment
,SrcSysMnemonicCode
,SrcSysMnemonicName
,DestSysMnemonicCode
,AuthorisationStatus
,EffectiveFromTimeKey
,EffectiveToTimeKey
,CreatedBy
,DateCreated
,ModifyBy
,DateModified
,ApprovedBy
,DateApproved
,IsInterest

   )

SELECT 
MnemonicCode=A.MnemonicValidCode
,MnemonicName=ISNULL(B.Txt_txn_desc,'NA')
,MnemonicShortName=NULL
,MnemonicShortNameEnum=NULL
,MnemonicGroup=NULL
,MnemonicSubGroup=NULL
,MnemonicSegment=NULL
,SrcSysMnemonicCode=NULL
,SrcSysMnemonicName=NULL
,DestSysMnemonicCode=NULL
,AuthorisationStatus=NULL
,EffectiveFromTimeKey=(SELECT TimeKey FROM PRO.EXTDATE_MISDB WHERE Flg='Y')
,EffectiveToTimeKey=49999
,CreatedBy='SSIS'
,DateCreated=GETDATE()
,ModifyBy=NULL
,DateModified=NULL
,ApprovedBy=NULL
,DateApproved=NULL
,typ_arrear
 
FROM #NEWMnemonicCode A INNER JOIN 
YBL_ACS_mis.dbo.ODS_FCR_BA_TXN_MNEMONIC B ON A.MnemonicValidCode=B.Cod_txn_mnemonic

update a set A.SrcSysMnemonicName=b.FLG_DORM_POST
from DimMnemonicCode a
INNER JOIN 
YBL_ACS_mis.dbo.ODS_FCR_BA_TXN_MNEMONIC B ON A.MnemonicCode=B.Cod_txn_mnemonic


--update a set A.MnemonicName=B.Txt_txn_desc
--from DimMnemonicCode a
--INNER JOIN 
--YBL_ACS_mis.dbo.ODS_FCR_BA_TXN_MNEMONIC B ON A.MnemonicCode=B.Cod_txn_mnemonic
--WHERE B.Txt_txn_desc IS NOT NULL


DROP TABLE #NEWMnemonicCode
UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE IDENTITYKEY = (SELECT IDENT_CURRENT('PRO.PROCESSMONITOR')) AND  TIMEKEY=@TIMEKEY AND DESCRIPTION='Work for DimMnemonicCode_Insert'

END





GO