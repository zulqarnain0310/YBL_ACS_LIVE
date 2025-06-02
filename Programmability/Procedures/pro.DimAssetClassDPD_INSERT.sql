SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


/*==============================================
 AUTHER : TRILOKI KHANNA 
 CREATE DATE : 28-11-2018
 MODIFY DATE : 28-11-2018
 DESCRIPTION : INSERT DATA FOR MnemonicCode
 --EXEC PRO.DimAssetClassDPD_INSERT
 ================================================*/

CREATE PROCEDURE [pro].[DimAssetClassDPD_INSERT]
AS
BEGIN

DECLARE @TIMEKEY INT = (SELECT TIMEKEY FROM PRO.EXTDATE_MISDB WHERE FLG = 'Y')
DECLARE @SETID INT =(SELECT ISNULL(MAX(ISNULL(SETID,0)),0)+1 FROM [PRO].[PROCESSMONITOR] WHERE TIMEKEY=@TIMEKEY)

INSERT INTO PRO.PROCESSMONITOR(USERID,DESCRIPTION,MODE,STARTTIME,ENDTIME,TIMEKEY,SETID)
SELECT ORIGINAL_LOGIN(),'Work for DimAssetClassDPD_Insert','RUNNING',GETDATE(),NULL,@TIMEKEY,@SETID


IF OBJECT_ID('TEMPDB..#DimAssetClassDPD') IS NOT NULL
   DROP TABLE #DimAssetClassDPD


   SELECT COD_PLAN DpdPLAN, NAM_PLAN DpdNamePlan, COD_CLASSIF_CRITERIA DpdClassCriteria ,CASE   WHEN COD_CLASSIF_CRITERIA='A' THEN 'NORMAL'
		WHEN COD_CLASSIF_CRITERIA='T' THEN 'TOD' END AS DpdClassCriteriaDesc, COD_CLASSIF_VALUES DpdClassValues, CTR_SRL_NO  DpdSrlNO,  CTR_MVMNT_VALUE DpdValue,
    COD_MVMT_UNIT DpdMonth ,  COD_CRR DpdCRR INTO #DimAssetClassDPD  FROM YBL_ACS_MIS.dbo.ODS_FCR_ac_plan_mast --where COD_PLAN in(1,2) and COD_CLASSIF_CRITERIA  in('A','T')
   EXCEPT
   SELECT DpdPlan,DpdNamePlan,DpdClassCriteria,	DpdClassCriteriaDesc,DpdClassValues,DpdSrlNO,DpdValue,DpdMonth,DpdCRR FROM DimAssetClassDPD


 
   INSERT INTO DimAssetClassDPD
   (
 DpdPLAN
,DpdNamePlan
,DpdClassCriteria
,DpdClassCriteriaDesc
,DpdClassValues
,DpdSrlNO
,DpdValue
,DpdMonth
,DpdCRR
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

DpdPLAN AS  DpdPLAN
,DpdNamePlan AS DpdNamePlan
,DpdClassCriteria AS DpdClassCriteria
,DpdClassCriteriaDesc AS DpdClassCriteriaDesc
,DpdClassValues AS DpdClassValues
,DpdSrlNO AS DpdSrlNO
,DpdValue AS DpdValue
, DpdMonth AS DpdMonth
, DpdCRR AS DpdCRR
,AuthorisationStatus=NULL
,EffectiveFromTimeKey=(SELECT TimeKey FROM PRO.EXTDATE_MISDB WHERE Flg='Y')
,EffectiveToTimeKey=49999
,CreatedBy='SSIS'
,DateCreated=GETDATE()
,ModifiedBy=NULL
,DateModified=NULL
,ApprovedBy=NULL
,DateApproved=NULL

from #DimAssetClassDPD

DROP TABLE #DimAssetClassDPD

UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE IDENTITYKEY = (SELECT IDENT_CURRENT('PRO.PROCESSMONITOR')) AND  TIMEKEY=@TIMEKEY AND DESCRIPTION='Work for DimAssetClassDPD_Insert'

END








GO