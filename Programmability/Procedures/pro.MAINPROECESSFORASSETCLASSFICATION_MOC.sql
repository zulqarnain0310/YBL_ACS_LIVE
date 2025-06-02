SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [pro].[MAINPROECESSFORASSETCLASSFICATION_MOC]
@TIMEKEY INT,--moc time key
@ISMoc CHAR(1)= 'Y'
AS
BEGIN

DECLARE @SetID INT=1
declare @TIMEKEY1 int 
SET @TIMEKEY1= (SELECT LASTQTRDATEKEY FROM SYSDAYMATRIX WHERE TIMEKEY=@TIMEKEY)
--/*------------------MocAssetClassTable------------------*/
--INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
--SELECT ORIGINAL_LOGIN(),'MocAssetClassTable','RUNNING',GETDATE(),NULL,@TIMEKEY,@SetID

--EXEC [Pro].[MocAssetClassTable] @TIMEKEY1

--UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE TIMEKEY=@TIMEKEY AND DESCRIPTION='MocAssetClassTable'
--/*------------------MOC_ForAssetClassification------------------*/
--INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
--SELECT ORIGINAL_LOGIN(),'MOC_ForAssetClassification','RUNNING',GETDATE(),NULL,@TIMEKEY,@SetID

--EXEC [Pro].[MOC_ForAssetClassification] @TIMEKEY1

--UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE TIMEKEY=@TIMEKEY AND DESCRIPTION='MOC_ForAssetClassification'
/*------------------InsertDataforAssetClassficationYes_MOC------------------*/
INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'InsertDataforAssetClassficationYes_MOC','RUNNING',GETDATE(),NULL,@TIMEKEY1,@SetID

EXEC [PRO].[InsertDataforAssetClassficationYes_MOC] @TIMEKEY

UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE TIMEKEY=@TIMEKEY1 AND DESCRIPTION='InsertDataforAssetClassficationYes_MOC'

--/*------------------Final_AssetClass_Npadate------------------*/
--INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
--SELECT ORIGINAL_LOGIN(),'Final_AssetClass_Npadate_MOC','RUNNING',GETDATE(),NULL,@TIMEKEY,@SetID

--EXEC PRO.Final_AssetClass_Npadate @TIMEKEY=@TIMEKEY1

--UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE TIMEKEY=@TIMEKEY AND DESCRIPTION='Final_AssetClass_Npadate_MOC'

	
/*------------------Update PnpaAssetClassAlt_key------------------*/ 

--IF (@PROCESSMONTH = EOMONTH(@PROCESSMONTH))
--BEGIN
--UPDATE PRO.ACCOUNTCAL SET PnpaAssetClassAlt_key = FINALASSETCLASSALT_KEY

--UPDATE PRO.customercal SET PNPA_CLASS_KEY = SysAssetClassAlt_Key
--END

/*------------------End PnpaAssetClassAlt_key------------------*/ 

INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'UpdateProvisionKey_AccountWise_MOC','RUNNING',GETDATE(),NULL,@TIMEKEY1,@SetID

EXEC PRO.UpdateProvisionKey_AccountWise @TIMEKEY=@TIMEKEY1

UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE TIMEKEY=@TIMEKEY1 AND DESCRIPTION='UpdateProvisionKey_AccountWise_MOC'



/*------------------UpdateNetBalance_AccountWise------------------*/
INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'UpdateNetBalance_AccountWise_MOC','RUNNING',GETDATE(),NULL,@TIMEKEY1,@SetID

EXEC  PRO.UpdateNetBalance_AccountWise @TIMEKEY=@TIMEKEY1

UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE TIMEKEY=@TIMEKEY1 AND DESCRIPTION='UpdateNetBalance_AccountWise_MOC'

/*------------------GovtGuarAppropriation------------------*/
INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'GovtGuarAppropriation_MOC','RUNNING',GETDATE(),NULL,@TIMEKEY1,@SetID

EXEC  PRO.[GovtGuarAppropriation] @TIMEKEY=@TIMEKEY1

UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE TIMEKEY=@TIMEKEY1 AND DESCRIPTION='GovtGuarAppropriation_MOC'

/*------------------SecurityAppropriation------------------*/
INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'SecurityAppropriation_MOC','RUNNING',GETDATE(),NULL,@TIMEKEY1,@SetID

EXEC  PRO.[SecurityAppropriation] @TIMEKEY=@TIMEKEY1

UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE TIMEKEY=@TIMEKEY1 AND DESCRIPTION='SecurityAppropriation_MOC'

/*------------------UpdateUsedRV_MOC------------------*/
INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'UpdateUsedRV_MOC','RUNNING',GETDATE(),NULL,@TIMEKEY1,@SetID

EXEC  PRO.[UpdateUsedRV] @TIMEKEY=@TIMEKEY1

UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE TIMEKEY=@TIMEKEY1 AND DESCRIPTION='UpdateUsedRV_MOC'

/*------------------ProvisionComputationSecured------------------*/
INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'ProvisionComputationSecured_MOC','RUNNING',GETDATE(),NULL,@TIMEKEY1,@SetID

EXEC  PRO.[ProvisionComputationSecured] @TIMEKEY=@TIMEKEY1

UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE TIMEKEY=@TIMEKEY1 AND DESCRIPTION='ProvisionComputationSecured_MOC'

/*------------------GovtGurCoverAmount------------------*/
INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'GovtGurCoverAmount_MOC','RUNNING',GETDATE(),NULL,@TIMEKEY1,@SetID


EXEC  PRO.GovtGurCoverAmount @TIMEKEY=@TIMEKEY1

UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE TIMEKEY=@TIMEKEY1 AND DESCRIPTION='GovtGurCoverAmount_MOC'

/*------------------UpdationProvisionComputationUnSecured------------------*/
INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'UpdationProvisionComputationUnSecured_MOC','RUNNING',GETDATE(),NULL,@TIMEKEY1,@SetID

EXEC  PRO.UpdationProvisionComputationUnSecured @TIMEKEY=@TIMEKEY1

UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE TIMEKEY=@TIMEKEY1 AND DESCRIPTION='UpdationProvisionComputationUnSecured_MOC'

/*------------------UpdationTotalProvision------------------*/
INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'UpdationTotalProvision_MOC','RUNNING',GETDATE(),NULL,@TIMEKEY1,@SetID

EXEC PRO.UpdationTotalProvision  @TIMEKEY=@TIMEKEY1

UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE TIMEKEY=@TIMEKEY1 AND DESCRIPTION='UpdationTotalProvision_MOC'

/*------------------DataShiftingintoArchiveandPremocTable_MOC------------------*/
INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'DataShiftingintoArchiveandPremocTable_MOC','RUNNING',GETDATE(),NULL,@TIMEKEY1,@SetID


EXEC [Pro].[DataShiftingintoArchiveandPremocTable] @TIMEKEY1

UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE TIMEKEY=@TIMEKEY1 AND DESCRIPTION='DataShiftingintoArchiveandPremocTable_MOC'

/*------------------PRO.UpdateDataInHistTable------------------*/
INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'UpdateDataInHistTable','RUNNING',GETDATE(),NULL,@TIMEKEY1,@SetID


EXEC PRO.UpdateDataInHistTable @TIMEKEY=@TIMEKEY1 

UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE TIMEKEY=@TIMEKEY1 AND DESCRIPTION='UpdateDataInHistTable'

--/*------------------UpdateDataIntoMainTables------------------*/
--INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
--SELECT ORIGINAL_LOGIN(),'UpdateDataIntoMainTables_MOC','RUNNING',GETDATE(),NULL,@TIMEKEY,@SetID

--EXEC [PRO].[UpdateDataIntoMainTables] @TIMEKEY=@TIMEKEY1, @BranchCode='0',@EditMode='N',@ISMoc='Y'

--UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE TIMEKEY=5021 AND DESCRIPTION='UpdateDataIntoMainTables_MOC'

END









GO