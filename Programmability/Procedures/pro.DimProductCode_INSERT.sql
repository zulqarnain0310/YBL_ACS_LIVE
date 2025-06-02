SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/*==============================================
 AUTHER : TRILOKI KHANNA
 CREATE DATE : 24-10-2018
 MODIFY DATE : 19-01-2022
 DESCRIPTION : INSERT DATA FOR ProductCode
 --EXEC PRO.DimProductCode_INSERT
 
 ================================================*/

Create PROCEDURE [pro].[DimProductCode_INSERT]
AS
BEGIN

DECLARE @TIMEKEY INT = (SELECT TIMEKEY FROM PRO.EXTDATE_MISDB WHERE FLG = 'Y')
DECLARE @SETID INT =(SELECT ISNULL(MAX(ISNULL(SETID,0)),0)+1 FROM [PRO].[PROCESSMONITOR] WHERE TIMEKEY=@TIMEKEY)


INSERT INTO PRO.PROCESSMONITOR(USERID,DESCRIPTION,MODE,STARTTIME,ENDTIME,TIMEKEY,SETID)
SELECT ORIGINAL_LOGIN(),'Work for DimProductCode_Insert','RUNNING',GETDATE(),NULL,@TIMEKEY,@SETID

IF OBJECT_ID('TEMPDB..#NEWProductFCR1') IS NOT NULL
   DROP TABLE #NEWProductFCR1


   SELECT Cod_prod ProductCode INTO #NEWProductFCR1  FROM YBL_ACS_MIS.dbo.ODS_FCR_CH_PROD_MAST
   EXCEPT
   SELECT ProductCode FROM DimProduct where SrcSysProductName='FCR'


 
   INSERT INTO DimProduct
   (
ProductCode
,ProductName
,ProductShortName
,ProductShortNameEnum
,ProductGroup
,ProductSubGroup
,ProductSegment
,ProductValidCode
,SrcSysProductCode
,SrcSysProductName
,DestSysProductCode
,AuthorisationStatus
,EffectiveFromTimeKey
,EffectiveToTimeKey
,CreatedBy
,DateCreated
,ModifiedBy
,DateModified
,ApprovedBy
,DateApproved
,DepositType
,FacilityType
,CodPrefId
   )

SELECT 
 ProductCode=A.ProductCode
,ProductName=B.Nam_product
,ProductShortName=NULL
,ProductShortNameEnum=NULL
,ProductGroup=NULL
,ProductSubGroup=NULL
,ProductSegment=NULL
,ProductValidCode=NULL
,SrcSysProductCode=NULL
,SrcSysProductName='FCR'
,DestSysProductCode=NULL
,AuthorisationStatus=NULL
,EffectiveFromTimeKey=(SELECT TimeKey FROM PRO.EXTDATE_MISDB WHERE Flg='Y')
,EffectiveToTimeKey=49999
,CreatedBy='SSIS'
,DateCreated=GETDATE()
,ModifyBy=NULL
,DateModified=NULL
,ApprovedBy=NULL
,DateApproved=NULL
,DepositType=COD_TYP_PROD
,FacilityType=NULL
,cod_ac_pref_id
FROM #NEWProductFCR1 A INNER JOIN 
YBL_ACS_MIS.dbo.ODS_FCR_CH_PROD_MAST B ON A.ProductCode=B.Cod_prod
ORDER BY A.ProductCode

--ADDED NEW CODE 727 AND 729 AS PER MAIL TO EXCLUDE ACCOUNTS FROM PNPA REPORTS  TRILOKI08092019--
--ADDED NEW CODE 768 AND 769 AS PER MAIL TO EXCLUDE ACCOUNTS FROM NPA/PNPA REPORTS  Kuldeep Razoria 11-Dec-2019--
--ADDED NEW CODE 714,736,738,739,741,772  AS PER MAIL TO EXCLUDE ACCOUNTS FROM NPA/PNPA REPORTS  Sapna K on 03-Jan-2020
--ADDED NEW CODE 'TPPV','TPVR','TPAY' as per mail dated 29-01-2020 from  Vrushali Sanzgiri (FMO) 
---ADDED NEW CODE '782','783' as per mail dated 28-07-2021 from  Vishal Patil

UPDATE DimProduct SET AssetNorm='ALWYS_STD'
WHERE ProductCode IN ('604','609','612','627','636','638','643','654','664','665','688','690','707','714','727','729','736','738','739','741','768','769'
,'772','890','891','898','899','963','964','TPPV','TPVR','TPAY','782','783') and AssetNorm<>'ALWYS_STD'
and  SrcSysProductName in ('FCR','FCC')

----605-Exclude only for Out of order  ,'605','869','889','660','661'
----869-Exclude only for Out of order
----889-Exclude only for Out of order
----660-Exclude only for Out of order
----661-Exclude only for Out of order

update dimproduct set CodPrefIdDec=NAM_PREFERENCE
 from dimproduct inner join YBL_ACS_MIS.dbo.ODS_FCR_ac_preferences
			on dimproduct.CodPrefId=COD_PREF_ID
where COD_PREF_ID in(100,101,103) and CodPrefIdDec is null


-----Added 203 in COD_PREF_ID ,based on mail from Sapna 26-May-2020

--UPDATE dimproduct SET ProductGroup='KCC' ,ProductSubGroup='AGRI366'
--from dimproduct inner join YBL_ACS_MIS.dbo.ODS_FCR_ac_preferences ON  dimproduct.CodPrefId=COD_PREF_ID
--where COD_PREF_ID in(103) and ProductGroup is null


---AssetNorm is maintained by CDAG only Pankaj 72424
--UPDATE dimproduct SET ProductGroup='KCC' ,ProductSubGroup='AGRI366'
--from dimproduct inner join YBL_ACS_MIS.dbo.ODS_FCR_ac_preferences ON  dimproduct.CodPrefId=COD_PREF_ID
---where COD_PREF_ID in(103,203) and ProductGroup is null
---AssetNorm is maintained by CDAG only Pankaj 72424

--UPDATE D SET  ProductGroup='KCC'
--from  YBL_ACS_MIS.dbo.ODS_FCR_CH_PROD_MAST A

--INNER JOIN  YBL_ACS_MIS.dbo.ODS_FCR_BA_PROD_PRODTYPE_XREF B ON A.Cod_prod=B.Cod_prod
--INNER JOIN  YBL_ACS_MIS.dbo.ODS_FCR_ac_preferences C ON A.cod_ac_pref_id=C.COD_PREF_ID
--inner join  dimproduct D ON D.ProductCode=A.Cod_prod
--INNER JOIN  YBL_ACS_MIS.dbo.ODS_FCR_ac_plan_mast E ON A.COD_CLASSIF_PLAN_CODE=E.COD_PLAN

--WHERE E.NAM_PLAN='KCC Classification'


--/*--------------------------------- FCR product code in two master tables---------------------------------*/   

--/*---------------------------------INSERT DATA FOR FCR ---------------------------------*/

--IF OBJECT_ID('TEMPDB..#NEWProductCodeFCR2') IS NOT NULL
--   DROP TABLE #NEWProductCodeFCR2


--   SELECT  cast(COD_PROD as varchar(20)) as   ProductCode INTO #NEWProductCodeFCR2  FROM YBL_ACS_MIS..ODS_FCR_BA_PROD_PRODTYPE_XREF
--   EXCEPT
--   SELECT ProductCode FROM DimProduct


   
 
--   INSERT INTO DimProduct
--   (
--ProductCode
--,ProductName
--,ProductShortName
--,ProductShortNameEnum
--,ProductGroup
--,ProductSubGroup
--,ProductSegment
--,ProductValidCode
--,SrcSysProductCode
--,SrcSysProductName
--,DestSysProductCode
--,AuthorisationStatus
--,EffectiveFromTimeKey
--,EffectiveToTimeKey
--,CreatedBy
--,DateCreated
--,ModifiedBy
--,DateModified
--,ApprovedBy
--,DateApproved
--,DepositType
--,FacilityType
--   )

--SELECT 
-- ProductCode=A.ProductCode
--,ProductName=B.COD_PROD_DESC
--,ProductShortName=NULL
--,ProductShortNameEnum=NULL
--,ProductGroup=NULL
--,ProductSubGroup=NULL
--,ProductSegment=NULL
--,ProductValidCode=NULL
--,SrcSysProductCode=NULL
--,SrcSysProductName='FCR'
--,DestSysProductCode=NULL
--,AuthorisationStatus=NULL
--,EffectiveFromTimeKey=(SELECT TimeKey FROM PRO.EXTDATE_MISDB WHERE Flg='Y')
--,EffectiveToTimeKey=49999
--,CreatedBy='SSIS'
--,DateCreated=GETDATE()
--,ModifyBy=NULL
--,DateModified=NULL
--,ApprovedBy=NULL
--,DateApproved=NULL
--,DepositType=NULL
--,FacilityType=NULL
--FROM #NEWProductCodeFCR2 A INNER JOIN 
--YBL_ACS_MIS..ODS_FCR_BA_PROD_PRODTYPE_XREF  B ON A.ProductCode=B.COD_PROD
--ORDER BY A.ProductCode

/*-------INSERT DATA FOR GANSEVA---------------------------------*/

IF OBJECT_ID('TEMPDB..#NEWProductCodeGENSEVA') IS NOT NULL
   DROP TABLE #NEWProductCodeGENSEVA


   SELECT  ProductCode INTO #NEWProductCodeGENSEVA  FROM YBL_ACS_MIS..ODS_GS_RCDSLoanProductMaster
   EXCEPT
   SELECT ProductCode FROM DimProduct where SrcSysProductName='GANASEVA'


   
 
   INSERT INTO DimProduct
   (
ProductCode
,ProductName
,ProductShortName
,ProductShortNameEnum
,ProductGroup
,ProductSubGroup
,ProductSegment
,ProductValidCode
,SrcSysProductCode
,SrcSysProductName
,DestSysProductCode
,AuthorisationStatus
,EffectiveFromTimeKey
,EffectiveToTimeKey
,CreatedBy
,DateCreated
,ModifiedBy
,DateModified
,ApprovedBy
,DateApproved
,DepositType
,FacilityType
   )

SELECT 
 ProductCode=A.ProductCode
,ProductName=B.Name
,ProductShortName=NULL
,ProductShortNameEnum=NULL
,ProductGroup=NULL
,ProductSubGroup=NULL
,ProductSegment=NULL
,ProductValidCode=NULL
,SrcSysProductCode=NULL
,SrcSysProductName='GANASEVA'
,DestSysProductCode=NULL
,AuthorisationStatus=NULL
,EffectiveFromTimeKey=(SELECT TimeKey FROM PRO.EXTDATE_MISDB WHERE Flg='Y')
,EffectiveToTimeKey=49999
,CreatedBy='SSIS'
,DateCreated=GETDATE()
,ModifyBy=NULL
,DateModified=NULL
,ApprovedBy=NULL
,DateApproved=NULL
,DepositType=NULL
,FacilityType=NULL
FROM #NEWProductCodeGENSEVA A INNER JOIN 
YBL_ACS_MIS..ODS_GS_RCDSLoanProductMaster  B ON A.ProductCode=B.ProductCode
ORDER BY A.ProductCode




/*-------INSERT DATA FOR FINNONE---------------------------------*/

IF OBJECT_ID('TEMPDB..#NEWProductCodeFINNONE') IS NOT NULL
   DROP TABLE #NEWProductCodeFINNONE


   SELECT  CODE ProductCode INTO #NEWProductCodeFINNONE  FROM YBL_ACS_MIS..ODS_RA_NBFC_PRODUCT_M
   EXCEPT
   SELECT ProductCode FROM DimProduct where SrcSysProductName='FINNONE'


   
 
   INSERT INTO DimProduct
   (
ProductCode
,ProductName
,ProductShortName
,ProductShortNameEnum
,ProductGroup
,ProductSubGroup
,ProductSegment
,ProductValidCode
,SrcSysProductCode
,SrcSysProductName
,DestSysProductCode
,AuthorisationStatus
,EffectiveFromTimeKey
,EffectiveToTimeKey
,CreatedBy
,DateCreated
,ModifiedBy
,DateModified
,ApprovedBy
,DateApproved
,DepositType
,FacilityType
   )

SELECT 
 ProductCode=A.ProductCode
,ProductName=B.Description
,ProductShortName=NULL
,ProductShortNameEnum=NULL
,ProductGroup=NULL
,ProductSubGroup=NULL
,ProductSegment=NULL
,ProductValidCode=NULL
,SrcSysProductCode=NULL
,SrcSysProductName='FINNONE'
,DestSysProductCode=NULL
,AuthorisationStatus=NULL
,EffectiveFromTimeKey=(SELECT TimeKey FROM PRO.EXTDATE_MISDB WHERE Flg='Y')
,EffectiveToTimeKey=49999
,CreatedBy='SSIS'
,DateCreated=GETDATE()
,ModifyBy=NULL
,DateModified=NULL
,ApprovedBy=NULL
,DateApproved=NULL
,DepositType=NULL
,FacilityType=NULL
FROM #NEWProductCodeFINNONE A INNER JOIN 
YBL_ACS_MIS..ODS_RA_NBFC_PRODUCT_M  B ON A.ProductCode=B.CODE

ORDER BY A.ProductCode

update DimProduct set ProductGroup='PROPERTY BACKED' where ProductCode in('AFHL','BHL','BSL','DLN','CVDODP','DOD','HLN','LAP','LRD','MOR','PSS') and ProductGroup is null
update DimProduct set ProductGroup='UNSECURED' where ProductCode in('BLN','ELN','FLN','PLN','SPL','PSU') and ProductGroup is null
update DimProduct set ProductGroup='NON PROPERTY BACKED' where ProductCode in('HIN','ALN','CEL','CVDODV','CVL','GLN','MEN','MER','MET','PEN','THWL','TWL','UCE','UCL','UCV','ZAP','INF') and ProductGroup is null
update DimProduct set ProductGroup='PERSONAL LOAN' where ProductCode in('201','AMCPA','APAL','FFL','FMA','FMC','GSS','INEQ','KCC','LCBC','MEFSOD','MEFSTL','MEFUOD','MEFUTL','MIL','ODG','PLOD','RPEN','UTL','YDA','YLL','YML','YNIR') and ProductGroup is null



/*-------INSERT DATA FOR EIFS---------------------------------*/

IF OBJECT_ID('TEMPDB..#NEWProductCodeEIFS') IS NOT NULL
   DROP TABLE #NEWProductCodeEIFS


   SELECT  cast(PRODUCTCATEGORYID as varchar(20)) as  ProductCode INTO #NEWProductCodeEIFS  FROM YBL_ACS_MIS..ODS_EIFS_PRODUCTCATEGORYMST
   EXCEPT
   SELECT ProductCode FROM DimProduct  where SrcSysProductName='EIFS'


   
 
   INSERT INTO DimProduct
   (
ProductCode
,ProductName
,ProductShortName
,ProductShortNameEnum
,ProductGroup
,ProductSubGroup
,ProductSegment
,ProductValidCode
,SrcSysProductCode
,SrcSysProductName
,DestSysProductCode
,AuthorisationStatus
,EffectiveFromTimeKey
,EffectiveToTimeKey
,CreatedBy
,DateCreated
,ModifiedBy
,DateModified
,ApprovedBy
,DateApproved
,DepositType
,FacilityType
   )
  
SELECT 
 ProductCode=A.ProductCode
,ProductName=B.PRODUCTCATEGORYNAME
,ProductShortName=NULL
,ProductShortNameEnum=NULL
,ProductGroup=NULL
,ProductSubGroup=NULL
,ProductSegment=NULL
,ProductValidCode=NULL
,SrcSysProductCode=NULL
,SrcSysProductName='EIFS'
,DestSysProductCode=NULL
,AuthorisationStatus=NULL
,EffectiveFromTimeKey=(SELECT TimeKey FROM PRO.EXTDATE_MISDB WHERE Flg='Y')
,EffectiveToTimeKey=49999
,CreatedBy='SSIS'
,DateCreated=GETDATE()
,ModifyBy=NULL
,DateModified=NULL
,ApprovedBy=NULL
,DateApproved=NULL
,DepositType=NULL
,FacilityType=NULL
FROM #NEWProductCodeEIFS A INNER JOIN 
YBL_ACS_MIS..ODS_EIFS_PRODUCTCATEGORYMST  B ON A.ProductCode=B.PRODUCTCATEGORYID
ORDER BY A.ProductCode


/*-------INSERT DATA FOR ECFS---------------------------------*/

IF OBJECT_ID('TEMPDB..#NEWProductCodeECFS') IS NOT NULL
   DROP TABLE #NEWProductCodeECFS


   SELECT  cast(PROGRAMSEGMENTid as varchar(20)) as  ProductCode INTO #NEWProductCodeECFS  FROM YBL_ACS_MIS..ods_ECFS_PROGRAMSEGMENTMST
   EXCEPT
   SELECT ProductCode FROM DimProduct  where SrcSysProductName='ECFS'


   
 
   INSERT INTO DimProduct
   (
ProductCode
,ProductName
,ProductShortName
,ProductShortNameEnum
,ProductGroup
,ProductSubGroup
,ProductSegment
,ProductValidCode
,SrcSysProductCode
,SrcSysProductName
,DestSysProductCode
,AuthorisationStatus
,EffectiveFromTimeKey
,EffectiveToTimeKey
,CreatedBy
,DateCreated
,ModifiedBy
,DateModified
,ApprovedBy
,DateApproved
,DepositType
,FacilityType
   )
  
SELECT 
 ProductCode=A.ProductCode
,ProductName=B.programsegmentname
,ProductShortName=NULL
,ProductShortNameEnum=NULL
,ProductGroup=NULL
,ProductSubGroup=NULL
,ProductSegment=NULL
,ProductValidCode=NULL
,SrcSysProductCode=NULL
,SrcSysProductName='ECFS'
,DestSysProductCode=NULL
,AuthorisationStatus=NULL
,EffectiveFromTimeKey=(SELECT TimeKey FROM PRO.EXTDATE_MISDB WHERE Flg='Y')
,EffectiveToTimeKey=49999
,CreatedBy='SSIS'
,DateCreated=GETDATE()
,ModifyBy=NULL
,DateModified=NULL
,ApprovedBy=NULL
,DateApproved=NULL
,DepositType=NULL
,FacilityType=NULL
FROM #NEWProductCodeECFS A INNER JOIN 
YBL_ACS_MIS..ods_ECFS_PROGRAMSEGMENTMST  B ON A.ProductCode=B.PROGRAMSEGMENTid
ORDER BY A.ProductCode



   

/*-------INSERT DATA FOR FCC---------------------------------*/

IF OBJECT_ID('TEMPDB..#NEWProductCodeFCC') IS NOT NULL
   DROP TABLE #NEWProductCodeFCC


   SELECT  PRODUCT_CODE ProductCode INTO #NEWProductCodeFCC  FROM YBL_ACS_MIS..ODS_FCC_cstm_product
   EXCEPT
   SELECT ProductCode FROM DimProduct where  SrcSysProductName='FCC'


   
 
   INSERT INTO DimProduct
   (
ProductCode
,ProductName
,ProductShortName
,ProductShortNameEnum
,ProductGroup
,ProductSubGroup
,ProductSegment
,ProductValidCode
,SrcSysProductCode
,SrcSysProductName
,DestSysProductCode
,AuthorisationStatus
,EffectiveFromTimeKey
,EffectiveToTimeKey
,CreatedBy
,DateCreated
,ModifiedBy
,DateModified
,ApprovedBy
,DateApproved
,DepositType
,FacilityType
   )

SELECT 
 ProductCode=A.ProductCode
,ProductName=B.PRODUCT_DESCRIPTION
,ProductShortName=NULL
,ProductShortNameEnum=NULL
,ProductGroup=NULL
,ProductSubGroup=NULL
,ProductSegment=NULL
,ProductValidCode=NULL
,SrcSysProductCode=NULL
,SrcSysProductName='FCC'
,DestSysProductCode=NULL
,AuthorisationStatus=NULL
,EffectiveFromTimeKey=(SELECT TimeKey FROM PRO.EXTDATE_MISDB WHERE Flg='Y')
,EffectiveToTimeKey=49999
,CreatedBy='SSIS'
,DateCreated=GETDATE()
,ModifyBy=NULL
,DateModified=NULL
,ApprovedBy=NULL
,DateApproved=NULL
,DepositType=NULL
,CASE WHEN MODULE='LD' THEN 'TL'
	 WHEN MODULE='LC' THEN 'LC'
	 WHEN MODULE='BC' THEN 'BP'
	 WHEN MODULE='FT' THEN 'TL' END AS FacilityType
FROM #NEWProductCodeFCC A INNER JOIN 
YBL_ACS_MIS..ODS_FCC_cstm_product  B ON A.ProductCode=B.PRODUCT_CODE
ORDER BY A.ProductCode




/*-------INSERT DATA FOR CRED AVENUE---------------------------------*/

IF OBJECT_ID('TEMPDB..#NEWProductCodeCRED') IS NOT NULL
   DROP TABLE #NEWProductCodeCRED


   SELECT  ProductCode INTO #NEWProductCodeCRED  FROM YBL_ACS_MIS..ODS_CA_RCDSLoanProductMaster
   EXCEPT
   SELECT ProductCode FROM DimProduct where SrcSysProductName='CREDAVENUE_DA'


   
 
   INSERT INTO DimProduct
   (
ProductCode
,ProductName
,ProductShortName
,ProductShortNameEnum
,ProductGroup
,ProductSubGroup
,ProductSegment
,ProductValidCode
,SrcSysProductCode
,SrcSysProductName
,DestSysProductCode
,AuthorisationStatus
,EffectiveFromTimeKey
,EffectiveToTimeKey
,CreatedBy
,DateCreated
,ModifiedBy
,DateModified
,ApprovedBy
,DateApproved
,DepositType
,FacilityType
   )

SELECT 
 ProductCode=A.ProductCode
,ProductName=B.Name
,ProductShortName=NULL
,ProductShortNameEnum=NULL
,ProductGroup=NULL
,ProductSubGroup=NULL
,ProductSegment=NULL
,ProductValidCode=NULL
,SrcSysProductCode=NULL
,SrcSysProductName='CREDAVENUE_DA'
,DestSysProductCode=NULL
,AuthorisationStatus=NULL
,EffectiveFromTimeKey=(SELECT TimeKey FROM PRO.EXTDATE_MISDB WHERE Flg='Y')
,EffectiveToTimeKey=49999
,CreatedBy='SSIS'
,DateCreated=GETDATE()
,ModifyBy=NULL
,DateModified=NULL
,ApprovedBy=NULL
,DateApproved=NULL
,DepositType=NULL
,FacilityType=NULL
FROM #NEWProductCodeCRED A INNER JOIN 
YBL_ACS_MIS..ODS_CA_RCDSLoanProductMaster  B ON A.ProductCode=B.ProductCode
ORDER BY A.ProductCode



/*-------INSERT DATA FOR VisionPLUS---------------------------------*/

IF OBJECT_ID('TEMPDB..#NEWProductCodeVisionPLUS') IS NOT NULL
   DROP TABLE #NEWProductCodeVisionPLUS


   SELECT  distinct ProductCode  INTO #NEWProductCodeVisionPLUS  FROM  YBL_ACS_MIS.dbo.AccountData
	where SourceSystemName='visionplus'  and ProductCode is not null 
   EXCEPT
   SELECT ProductCode FROM DimProduct where SrcSysProductName='VisionPLUS'


   
 
   INSERT INTO DimProduct
   (
ProductCode
,ProductName
,ProductShortName
,ProductShortNameEnum
,ProductGroup
,ProductSubGroup
,ProductSegment
,ProductValidCode
,SrcSysProductCode
,SrcSysProductName
,DestSysProductCode
,AuthorisationStatus
,EffectiveFromTimeKey
,EffectiveToTimeKey
,CreatedBy
,DateCreated
,ModifiedBy
,DateModified
,ApprovedBy
,DateApproved
,DepositType
,FacilityType
   )

SELECT 
 ProductCode=A.ProductCode
,ProductName=NULL
,ProductShortName=NULL
,ProductShortNameEnum=NULL
,ProductGroup=NULL
,ProductSubGroup=NULL
,ProductSegment=NULL
,ProductValidCode=NULL
,SrcSysProductCode=NULL
,SrcSysProductName='VisionPLUS'
,DestSysProductCode=NULL
,AuthorisationStatus=NULL
,EffectiveFromTimeKey=(SELECT TimeKey FROM PRO.EXTDATE_MISDB WHERE Flg='Y')
,EffectiveToTimeKey=49999
,CreatedBy='SSIS'
,DateCreated=GETDATE()
,ModifyBy=NULL
,DateModified=NULL
,ApprovedBy=NULL
,DateApproved=NULL
,DepositType=NULL
,FacilityType=NULL
FROM #NEWProductCodeVisionPLUS A



/*-------INSERT DATA FOR SFIN 15102023---------------------------------*/

IF OBJECT_ID('TEMPDB..#NEWProductCodeSFIN') IS NOT NULL
   DROP TABLE #NEWProductCodeSFIN


   SELECT  distinct ProductCode  INTO #NEWProductCodeSFIN  FROM  YBL_ACS_MIS.[dbo].[AccountData_FinSmart]
	where SourceSystemName='SFIN'  and ProductCode is not null 
   EXCEPT
   SELECT ProductCode FROM DimProduct where SrcSysProductName='SFIN'

   INSERT INTO DimProduct
   (
ProductCode
,ProductName
,ProductShortName
,ProductShortNameEnum
,ProductGroup
,ProductSubGroup
,ProductSegment
,ProductValidCode
,SrcSysProductCode
,SrcSysProductName
,DestSysProductCode
,AuthorisationStatus
,EffectiveFromTimeKey
,EffectiveToTimeKey
,CreatedBy
,DateCreated
,ModifiedBy
,DateModified
,ApprovedBy
,DateApproved
,DepositType
,FacilityType
   )

SELECT 
 ProductCode=A.ProductCode
,ProductName=NULL
,ProductShortName=NULL
,ProductShortNameEnum=NULL
,ProductGroup=NULL
,ProductSubGroup=NULL
,ProductSegment=NULL
,ProductValidCode=NULL
,SrcSysProductCode=NULL
,SrcSysProductName='SFIN'
,DestSysProductCode=NULL
,AuthorisationStatus=NULL
,EffectiveFromTimeKey=(SELECT TimeKey FROM PRO.EXTDATE_MISDB WHERE Flg='Y')
,EffectiveToTimeKey=49999
,CreatedBy='SSIS'
,DateCreated=GETDATE()
,ModifyBy=NULL
,DateModified=NULL
,ApprovedBy=NULL
,DateApproved=NULL
,DepositType=NULL
,FacilityType=NULL
FROM #NEWProductCodeSFIN A

/*-------INSERT DATA FOR SFIN 15102023---------------------------------*/

UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='501'  AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='502'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='507'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='508'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='509'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='510'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='511'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='512'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='513'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='514'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='515'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='516'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='517'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='518'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='519'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='528'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='600'  AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='604'  AND SrcSysProductCode<>'CURRENT' 
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='605'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='606'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='607'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='608'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='609'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='610'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='612'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='614'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='615'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='616'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='617'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='618'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='619'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='620'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='621'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='622'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='624'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='626'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='627'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='628'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='629'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='631'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='632'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='633'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='634'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='635'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='636'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='637'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='638'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='643'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='644'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='645'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='646'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='647'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='648'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='649'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='650'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='651'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='652'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='653'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='654'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='655'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='656'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='657'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='658'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='659'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='662'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='663'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='664'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='665'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='666'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='667'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='668'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='675'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='676'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='677'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='679'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='680'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='681'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='682'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='683'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='684'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='685'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='686'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='687'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='688'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='689'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='690'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='691'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='692'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='693'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='694'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='695'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='696'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='697'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='698'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='699'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='700'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='703'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='704'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='705'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='706'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='707'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='713'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='714'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='715'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='716'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='717'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='718'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='719'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='720'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='721'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='722'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='723'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='724'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='725'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='727'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='729'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='730'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='731'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='732'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='733'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='734'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='735'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='736'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='740'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='801'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='802'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='803'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='804'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='805'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='806'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='807'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='813'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='814'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='815'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='816'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='817'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='818'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='819'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='820'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='821'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='822'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='823'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='824'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='825'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='826'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='827'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='828'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='829'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='830'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='831'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='833'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='834'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='835'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='836'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='837'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='838'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='839'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='840'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='841'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='844'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='846'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='847'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='849'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='852'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='853'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='854'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='857'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='858'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='861'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='862'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='863'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='864'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='865'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='866'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='867'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='869'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='870'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='871'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='872'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='873'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='874'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='877'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='880'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='881'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='882'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='886'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='887'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='888'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='891'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='892'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='893'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='894'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='895'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='897'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='898'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='CURRENT'	WHERE ProductCode='899'	 AND SrcSysProductCode<>'CURRENT'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='901'  AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='902'  AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='903'  AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='904'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='905'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='907'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='908'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='909'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='910'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='911'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='912'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='913'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='914'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='915'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='916'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='917'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='918'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='919'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='920'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='921'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='922'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='930'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='931'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='932'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='933'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='934'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='935'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='936'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='937'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='938'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='940'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='941'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='943'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='944'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='945'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='946'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='947'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='948'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='949'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='950'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='951'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='954'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='955'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='956'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='957'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='958'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='959'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='960'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='961'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='962'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='963'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='964'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='965'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='967'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='968'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='969'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='970'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='971'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='972'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='973'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='974'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='975'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='976'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='977'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='978'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='979'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='980'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='981'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='982'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='983'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='984'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='985'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='986'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='987'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='988'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='989'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='990'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='991'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='992'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='993'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='994'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='995'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='996'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='997'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='998'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET SrcSysProductCode='SAVING'	WHERE ProductCode='999'	 AND SrcSysProductCode<>'SAVING'
UPDATE DIMPRODUCT SET NpaNorm='N'

IF OBJECT_ID('TEMPDB..#NpaNormFCC') IS NOT NULL
   DROP TABLE #NpaNormFCC  

SELECT A.ProductCode  INTO #NpaNormFCC FROM 
   (
	SELECT DISTINCT PRODUCT ProductCode FROM YBL_ACS_MIS..ODS_FCC_CSTM_PRODUCT_STATUS_COMPS WHERE STATUS IN('NPA','NPA1') 
	UNION 
	SELECT DISTINCT PRODUCT_CODE AS ProductCode  FROM YBL_ACS_MIS..ODS_FCC_CLTM_PRODUCT_STATUS 
	WHERE FROM_STATUS IN('NPA','NPA1') OR TO_STATUS IN('NPA','NPA1') 
) A

UPDATE A SET NpaNorm='Y'
 FROM DimProduct A
INNER JOIN #NpaNormFCC B ON A.ProductCode=B.ProductCode
WHERE A.SrcSysProductName='FCC'

UPDATE DIMPRODUCT SET FACILITYTYPE='CC' FROM DIMPRODUCT WHERE  SRCSYSPRODUCTNAME='FCR' AND FACILITYTYPE IS NULL

   DROP TABLE #NEWProductFCR1
   DROP TABLE #NEWProductCodeGENSEVA
   DROP TABLE #NEWProductCodeFINNONE
   DROP TABLE #NEWProductCodeEIFS
   DROP TABLE #NEWProductCodeECFS
   DROP TABLE #NEWProductCodeFCC
   DROP TABLE #NpaNormFCC 

   
UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE IDENTITYKEY = (SELECT IDENT_CURRENT('PRO.PROCESSMONITOR')) AND  TIMEKEY=@TIMEKEY AND DESCRIPTION='Work for DimProductCode_Insert'


END















GO