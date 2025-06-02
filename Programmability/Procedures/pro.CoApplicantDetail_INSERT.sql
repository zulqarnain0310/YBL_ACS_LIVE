SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/*====================================
AUTHER : SANJEEV KUMAR SHARMA
CREATE DATE : 24-10-2018
MODIFY DATE : 24-10-2018
DESCRIPTION : CO-APPLICATION DATA INSERT
--EXEC PRO.CoApplicantDetail_INSERT
========================================*/
CREATE PROCEDURE [pro].[CoApplicantDetail_INSERT]
with recompile
AS
BEGIN
  BEGIN TRY
    DECLARE @TIMEKEY  INT =(SELECT TimeKey FROM PRO.EXTDATE_MISDB WHERE Flg='Y')
	DECLARE @SETID INT =(SELECT ISNULL(MAX(ISNULL(SETID,0)),0)+1 FROM [PRO].[PROCESSMONITOR] WHERE TIMEKEY=@TIMEKEY)

INSERT INTO PRO.PROCESSMONITOR(USERID,DESCRIPTION,MODE,STARTTIME,ENDTIME,TIMEKEY,SETID)
SELECT ORIGINAL_LOGIN(),'Work for CoApplicantDetail_Insert','RUNNING',GETDATE(),NULL,@TIMEKEY,@SETID

	--DELETE FROM PRO.COAPPLICANTDETAIL WHERE EFFECTIVEFROMTIMEKEY=@TIMEKEY AND EFFECTIVETOTIMEKEY=@TIMEKEY

	--INSERT INTO Pro.CoApplicantDetail
	--(
	--RefCustomerID ,
	--CustomerAcid ,
	--JointBorFlg  ,
	--EffectiveFromTimekey,
	--EffectiveToTimekey 
	--)
	--SELECT cod_cust,account_number, cod_acct_cust_rel,@TIMEKEY,@TIMEKEY FROM 
	--YBL_ACS_MIS.dbo.ODS_FCR_ch_acct_cust_xref 
	--where  cod_acct_cust_rel in('JAO','JOO')

	
IF OBJECT_ID('TEMPDB..#CoApplicantDetail') IS NOT NULL
   DROP TABLE #CoApplicantDetail


   SELECT account_number CustomerAcID INTO #CoApplicantDetail FROM  YBL_ACS_MIS.dbo.ODS_FCR_ch_acct_cust_xref 
	where  cod_acct_cust_rel in('JAO','JOO')
      EXCEPT
   SELECT CustomerAcID FROM Pro.CoApplicantDetail where Effectivetotimekey=49999

   INSERT INTO Pro.CoApplicantDetail
	(
	RefCustomerID ,
	CustomerAcid ,
	JointBorFlg  ,
	EffectiveFromTimekey,
	EffectiveToTimekey 
	)

SELECT 
	B.cod_cust AS RefCustomerID ,
	A.CustomerAcid  AS CustomerAcid ,
	B.cod_acct_cust_rel AS JointBorFlg  ,
	EffectiveFromTimeKey=(SELECT TimeKey FROM PRO.EXTDATE_MISDB WHERE Flg='Y'),
	EffectiveToTimeKey=49999
FROM #CoApplicantDetail A INNER JOIN 
YBL_ACS_MIS.dbo.ODS_FCR_ch_acct_cust_xref  B ON A.CustomerAcid=B.account_number
where  B.cod_acct_cust_rel in('JAO','JOO')

 DROP TABLE #CoApplicantDetail

 UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE IDENTITYKEY = (SELECT IDENT_CURRENT('PRO.PROCESSMONITOR')) AND  TIMEKEY=@TIMEKEY AND DESCRIPTION='Work for CoApplicantDetail_Insert'

  END TRY
  BEGIN CATCH
    SELECT 'ERROR PROCEDURE :'+ERROR_PROCEDURE()+'ERROR MESSAGE :'+ERROR_MESSAGE();
  END CATCH
END


GO