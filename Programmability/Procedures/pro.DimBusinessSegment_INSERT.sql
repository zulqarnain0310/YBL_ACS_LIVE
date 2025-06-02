SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/*==============================================
 AUTHER : sanjeev kumar sharma
 CREATE DATE : 24-10-2018
 MODIFY DATE : 24-10-2018
 DESCRIPTION : INSERT DATA FOR Business Segment
 --EXEC PRO.DimBusinessSegment_INSERT
 ================================================*/

CREATE PROCEDURE [pro].[DimBusinessSegment_INSERT]
AS
BEGIN

DECLARE @TIMEKEY INT = (SELECT TIMEKEY FROM PRO.EXTDATE_MISDB WHERE FLG = 'Y')
DECLARE @SETID INT =(SELECT ISNULL(MAX(ISNULL(SETID,0)),0)+1 FROM [PRO].[PROCESSMONITOR] WHERE TIMEKEY=@TIMEKEY)

INSERT INTO PRO.PROCESSMONITOR(USERID,DESCRIPTION,MODE,STARTTIME,ENDTIME,TIMEKEY,SETID)
SELECT ORIGINAL_LOGIN(),'Work for DimBusinessSegment_Insert','RUNNING',GETDATE(),NULL,@TIMEKEY,@SETID

IF OBJECT_ID('TEMPDB..#BusinessSegmentsCode') IS NOT NULL
   DROP TABLE #BusinessSegmentsCode


   SELECT Mis_code BusinessSegmentsCode INTO #BusinessSegmentsCode  FROM YBL_ACS_MIS.dbo.ODS_FCR_BA_MIS_CLASS_CODE_XREF where Mis_class='SEGMENT_P'
   EXCEPT
   SELECT BusinessSegmentsCode FROM DimBusinessSegment



   INSERT INTO DimBusinessSegment
   (
BusinessSegmentsCode
,BusinessSegmentsName
,BusinessSegmentsShortName
,BusinessSegmentsShortNameEnum
,BusinessSegmentsGroup
,BusinessSegmentsSubGroup
,BusinessSegmentsSegment
,SrcSysBusinessSegmentsCode
,SrcSysBusinessSegmentsName
,DestSysBusinessSegmentsCode
,AuthorisationStatus
,EffectiveFromTimeKey
,EffectiveToTimeKey
,CreatedBy
,DateCreated
,ModifiedBy
,DateModifie
,ApprovedBy
,DateApproved


   )

SELECT 
BusinessSegmentsCode=a.BusinessSegmentsCode
,BusinessSegmentsName=b.Code_desc
,BusinessSegmentsShortName=null
,BusinessSegmentsShortNameEnum=null
,BusinessSegmentsGroup=B.Mis_class
,BusinessSegmentsSubGroup=null
,BusinessSegmentsSegment=null
,SrcSysBusinessSegmentsCode=null
,SrcSysBusinessSegmentsName=null
,DestSysBusinessSegmentsCode=null
,AuthorisationStatus=NULL
,EffectiveFromTimeKey=(SELECT TimeKey FROM PRO.EXTDATE_MISDB WHERE Flg='Y')
,EffectiveToTimeKey=49999
,CreatedBy='SSIS'
,DateCreated=GETDATE()
,ModifyBy=NULL
,DateModified=NULL
,ApprovedBy=NULL
,DateApproved=NULL
 
FROM #BusinessSegmentsCode A INNER JOIN 
YBL_ACS_MIS.dbo.ODS_FCR_BA_MIS_CLASS_CODE_XREF B ON A.BusinessSegmentsCode=B.Mis_code
where b.Mis_class='SEGMENT_P'


-----Added Triloki 28112018 segment code from ECBF----


IF OBJECT_ID('TEMPDB..#BusinessSegmentsCodeECBF') IS NOT NULL
   DROP TABLE #BusinessSegmentsCodeECBF


   SELECT SEGMENTCODE BusinessSegmentsCode INTO #BusinessSegmentsCodeECBF  FROM YBL_ACS_MIS.dbo.ODS_ECBF_segmentmst
   EXCEPT
   SELECT BusinessSegmentsCode FROM DimBusinessSegment



   
   INSERT INTO DimBusinessSegment
   (
BusinessSegmentsCode
,BusinessSegmentsName
,BusinessSegmentsShortName
,BusinessSegmentsShortNameEnum
,BusinessSegmentsGroup
,BusinessSegmentsSubGroup
,BusinessSegmentsSegment
,SrcSysBusinessSegmentsCode
,SrcSysBusinessSegmentsName
,DestSysBusinessSegmentsCode
,AuthorisationStatus
,EffectiveFromTimeKey
,EffectiveToTimeKey
,CreatedBy
,DateCreated
,ModifiedBy
,DateModifie
,ApprovedBy
,DateApproved


   )

SELECT 
BusinessSegmentsCode=a.BusinessSegmentsCode
,BusinessSegmentsName=b.SEGMENTNAME
,BusinessSegmentsShortName=null
,BusinessSegmentsShortNameEnum=null
,BusinessSegmentsGroup=NULL
,BusinessSegmentsSubGroup=null
,BusinessSegmentsSegment=null
,SrcSysBusinessSegmentsCode=null
,SrcSysBusinessSegmentsName=null
,DestSysBusinessSegmentsCode=null
,AuthorisationStatus=NULL
,EffectiveFromTimeKey=(SELECT TimeKey FROM PRO.EXTDATE_MISDB WHERE Flg='Y')
,EffectiveToTimeKey=49999
,CreatedBy='SSIS'
,DateCreated=GETDATE()
,ModifyBy=NULL
,DateModified=NULL
,ApprovedBy=NULL
,DateApproved=NULL
 
FROM #BusinessSegmentsCodeECBF A INNER JOIN 
YBL_ACS_MIS.dbo.ODS_ECBF_segmentmst B ON A.BusinessSegmentsCode=B.SEGMENTCODE







IF OBJECT_ID('TEMPDB..#ACCOUNTSEGMENTCODE') IS NOT NULL
   DROP TABLE #ACCOUNTSEGMENTCODE

select AccountSegmentCode INTO #ACCOUNTSEGMENTCODE from YBL_ACS_MIS..AccountData
where AccountSegmentCode is not null
group by AccountSegmentCode
EXCEPT
SELECT BusinessSegmentsCode FROM DimBusinessACSegment

INSERT INTO DimBusinessACSegment
(
BusinessSegmentsCode
,BusinessSegmentsName
,BusinessSegmentsShortName
,BusinessSegmentsShortNameEnum
,BusinessSegmentsGroup
,BusinessSegmentsSubGroup
,BusinessSegmentsSegment
,SrcSysBusinessSegmentsCode
,SrcSysBusinessSegmentsName
,DestSysBusinessSegmentsCode
,AuthorisationStatus
,EffectiveFromTimeKey
,EffectiveToTimeKey
,CreatedBy
,DateCreated
,ModifiedBy
,DateModifie
,ApprovedBy
,DateApproved


)
SELECT 
 BusinessSegmentsCode=AccountSegmentCode
,BusinessSegmentsName=AccountSegmentCode
,BusinessSegmentsShortName=AccountSegmentCode
,BusinessSegmentsShortNameEnum=AccountSegmentCode
,BusinessSegmentsGroup=NULL
,BusinessSegmentsSubGroup=NULL
,BusinessSegmentsSegment=NULL
,SrcSysBusinessSegmentsCode=NULL
,SrcSysBusinessSegmentsName=NULL
,DestSysBusinessSegmentsCode=NULL
,AuthorisationStatus=NULL
,EffectiveFromTimeKey=(SELECT TimeKey FROM PRO.EXTDATE_MISDB WHERE Flg='Y')
,EffectiveToTimeKey=49999
,CreatedBy='SSIS'
,DateCreated=GETDATE()
,ModifiedBy=NULL
,DateModifie=NULL
,ApprovedBy=NULL
,DateApproved=NULL
FROM #ACCOUNTSEGMENTCODE
order by 1


UPDATE A SET A.BUSINESSSEGMENTSNAME=B.BUSINESSSEGMENTSNAME 
FROM DIMBUSINESSACSEGMENT A INNER JOIN DIMBUSINESSSEGMENT B 
ON A.BUSINESSSEGMENTSCODE=B.BUSINESSSEGMENTSCODE
inner join #ACCOUNTSEGMENTCODE c on c.AccountSegmentCode=b.BusinessSegmentsCode



    DROP TABLE #BusinessSegmentsCode
	DROP TABLE #BusinessSegmentsCodeECBF
	DROP TABLE #ACCOUNTSEGMENTCODE
	
UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE IDENTITYKEY = (SELECT IDENT_CURRENT('PRO.PROCESSMONITOR')) AND  TIMEKEY=@TIMEKEY AND DESCRIPTION='Work for DimBusinessSegment_Insert'

END





GO