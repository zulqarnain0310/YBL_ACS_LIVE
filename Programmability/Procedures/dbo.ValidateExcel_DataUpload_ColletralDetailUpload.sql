SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO





Create PROCEDURE [dbo].[ValidateExcel_DataUpload_ColletralDetailUpload]
@MenuID INT=10,  
@UserLoginId  VARCHAR(20)='fnachecker',  
@Timekey INT=49999
,@filepath VARCHAR(MAX) ='IBPCUPLOAD.xlsx'  
WITH RECOMPILE  
AS  
  
  --fnasuperadmin_IBPCUPLOAD.xlsx

--DECLARE  
  
--@MenuID INT=1458,  
--@UserLoginId varchar(20)='FNASUPERADMIN',  
--@Timekey int=49999
--,@filepath varchar(500)='fnasuperadmin_IBPCUPLOAD.xlsx'  
  
BEGIN

BEGIN TRY  
--BEGIN TRAN  
  
--Declare @TimeKey int  
    --Update UploadStatus Set ValidationOfData='N' where FileNames=@filepath  
     
	 SET DATEFORMAT DMY

 --Select @Timekey=Max(Timekey) from dbo.SysProcessingCycle  
 -- where  ProcessType='Quarterly' ----and PreMOC_CycleFrozenDate IS NULL
 
 Select   @Timekey= (select CAST(B.timekey as int)from SysDataMatrix A
                    Inner Join SysDayMatrix B ON A.TimeKey=B.TimeKey
                       where A.CurrentStatus='C')

  PRINT @Timekey  
  
 --  DECLARE @DepartmentId SMALLINT ,@DepartmentCode varchar(100)  
 --SELECT  @DepartmentId= DepartmentId FROM dbo.DimUserInfo   
 --WHERE EffectiveFromTimeKey <= @Timekey AND EffectiveToTimeKey >= @Timekey  
 --AND UserLoginID = @UserLoginId  
 --PRINT @DepartmentId  
 --PRINT @DepartmentCode  
  
    
  
 --SELECT @DepartmentCode=DepartmentCode FROM AxisIntReversalDB.DimDepartment   
 --    WHERE EffectiveFromTimeKey <= @Timekey AND EffectiveToTimeKey >= @Timekey   
 --    --AND DepartmentCode IN ('BBOG','FNA')  
 --    AND DepartmentAlt_Key = @DepartmentId  
  
 --    print @DepartmentCode  
     --Select @DepartmentCode=REPLACE('',@DepartmentCode,'_')  
     
       
  
   
  
  DECLARE @FilePathUpload	VARCHAR(100)

			SET @FilePathUpload=@UserLoginId+'_'+@filepath
	PRINT '@FilePathUpload'
	PRINT @FilePathUpload

	IF EXISTS(SELECT 1 FROM dbo.MasterUploadData    where FileNames=@filepath )
	BEGIN
		Delete from dbo.MasterUploadData    where FileNames=@filepath  
		print @@rowcount
	END


IF (@MenuID=24702)	
BEGIN

	  -- IF OBJECT_ID('tempdb..UploadCollateralDetail') IS NOT NULL  
	  IF OBJECT_ID('UploadCollateralDetail') IS NOT NULL  
	  BEGIN  
	   DROP TABLE UploadCollateralDetail  
	   
	  END


	  IF OBJECT_ID('CollateralDetail_stg') IS NOT NULL  
	  BEGIN  
	   DROP TABLE CollateralDetail_stg  
	
	  END
	  

	  Select Entity_Key as Entity_Key , 
SrNo as SrNo ,
CollateralID as CollateralID,
[Action] as [Action],
LiabID as LiabID , 
UCIC as UCIC , 
CustName as CustName , 
AssetID as AssetID , 
Segment as Segment , 
CRE as CRE , 
SubTypeofCollateral as CollateralSubType , 
NameofthesecurityProvider as NameSecuPv , 
SeniorityofCharge as SeniorityCharge , 
SecurityStatus as SecurityStatus , 
Fdno as FDNO , 
ISINNoFolioNumber as ISINNo_FolioNumber , 
QuantityofsharesMutualFundsBonds as QtyShares_MutualFunds_Bonds , 
[LineNo] as Line_No , 
CrossCollateralLiabID as CrossCollateral_LiabID , 
PropertyAddress as PropertyAdd , 
PINCode as PIN , 
DateofstockAudit as DtStockAudit , 
SBLCIssuingbank as SBLCIssuingBank , 
SBLCNumber as SBLCNumber , 
CurrencyinwhichSBLCissued as CurSBLCissued , 
SBLCinFCY as SBLCFCY , 
DateofexpiryforSBLC as DtexpirySBLC , 
DateofexpiryforLIC as DtexpiryLIC , 
Modeofoperation as ModeOperation , 
Exceptionalapproval as ExceApproval , 
ValuationSourceExpiryBusinessRule as ValSource_ExpBusinessRule , 
Dateofvaluation as DtofValuation , 
Valuetobeconsidered as ValueConsidered , 
SecondValuationDate as SecondDtofValuation , 
SecondValuationAmount as SecondValuation , 
Expirydate as Expirydate,
filname as sheetname 
into CollateralDetail_stg 
from CollateralDetails_stg

  IF NOT (EXISTS (SELECT * FROM CollateralDetail_stg where sheetname=@FilePathUpload))

BEGIN
print 'NO DATA'
			Insert into dbo.MasterUploadData
			(SR_No,ColumnName,ErrorData,ErrorType,FileNames,Flag) 
			SELECT 0 SRNO , '' ColumnName,'No Record found' ErrorData,'No Record found' ErrorType,@filepath,'SUCCESS' 
			--SELECT 0 SRNO , '' ColumnName,'' ErrorData,'' ErrorType,@filepath,'SUCCESS' 

			goto errordata
    
END

ELSE
BEGIN
PRINT 'DATA PRESENT'
	   Select *,CAST('' AS varchar(MAX)) ErrorMessage,CAST('' AS varchar(MAX)) ErrorinColumn,CAST('' AS varchar(MAX)) Srnooferroneousrows
 	   into UploadCollateralDetail
	   from CollateralDetail_stg 
	   WHERE sheetname=@FilePathUpload

	  
END

  ------------------------------------------------------------------------------  
   
	--SrNo	Territory	ACID	InterestReversalAmount	filname
	
	UPDATE UploadCollateralDetail
	SET  
        ErrorMessage='There is no data in excel. Kindly check and upload again' 
		,ErrorinColumn='UCIC,CustomerName,AssetID,LiabID,Segment,CRE,Balances,CollateralSubType,Nmae Of Security Provider,Seniority Charge,Security Status'
		,Srnooferroneousrows=''
 FROM UploadCollateralDetail V  
 WHERE ISNULL(LiabID,'')=''
 AND ISNULL(UCIC,'')=''
AND ISNULL(CustName,'')=''
AND ISNULL(AssetID,'')=''

AND ISNULL(Segment,'')=''
AND ISNULL(CRE,'')=''
AND ISNULL(CollateralSubType,'')=''

AND ISNULL(NameSecuPv,'')=''
AND ISNULL(SeniorityCharge,'')=''
AND ISNULL(SecurityStatus,'')=''


AND ISNULL(FDNO,'')=''
AND ISNULL(ISINNo_FolioNumber,'')=''
AND ISNULL(QtyShares_MutualFunds_Bonds,'')=''


AND ISNULL(Line_No,'')=''
AND ISNULL(CrossCollateral_LiabID,'')=''
AND ISNULL(PropertyAdd,'')=''


AND ISNULL(PIN,'')=''
AND ISNULL(DtStockAudit,'')=''
AND ISNULL(SBLCIssuingBank,'')=''


AND ISNULL(SBLCNumber,'')=''
AND ISNULL(CurSBLCissued,'')=''
AND ISNULL(SBLCFCY,'')=''
  

  
AND ISNULL(DtexpirySBLC,'')=''
AND ISNULL(DtexpiryLIC,'')=''
AND ISNULL(ModeOperation,'')=''

  
AND ISNULL(ExceApproval,'')=''
AND ISNULL(ValSource_ExpBusinessRule,'')=''
AND ISNULL(DtofValuation,'')=''

  
AND ISNULL(ValueConsidered,'')=''
AND ISNULL(SecondDtofValuation,'')=''
AND ISNULL(SecondValuation,'')=''
  
--WHERE ISNULL(V.SrNo,'')=''
-- ----AND ISNULL(Territory,'')=''
-- AND ISNULL(AccountID,'')=''
-- AND ISNULL(PoolID,'')=''
-- AND ISNULL(filname,'')=''

  IF EXISTS(SELECT 1 FROM UploadCollateralDetail WHERE ISNULL(ErrorMessage,'')<>'')
  BEGIN
  PRINT 'NO DATA'
  GOTO ERRORDATA;
  END

      /*validations on Sl. No.*/
 ------------------------------------------------------------

  Declare @DuplicateCnt int=0
   UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'SrNo cannot be blank . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'SrNo cannot be blank . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadCollateralDetail V  
 WHERE ISNULL(SrNo,'')='' or ISNULL(SrNo,'0')='0'


  UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'SrNo cannot be greater than 16 character . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'SrNo cannot be greater than 16 character . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadCollateralDetail V  
 WHERE Len(SrNo)>16

  UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid Sl. No., kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid Sl. No., kindly check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadCollateralDetail V  
  WHERE (ISNUMERIC(SrNo)=0 AND ISNULL(SrNo,'')<>'') OR 
 ISNUMERIC(SrNo) LIKE '%^[0-9]%'

 UPDATE UploadCollateralDetail
	SET  
  ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Special characters not allowed, kindly remove and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Special characters not allowed, kindly remove and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadCollateralDetail V  
   WHERE ISNULL(SrNo,'') LIKE'%[,!@#$%^&*()_-+=/]%'

   --
  SELECT @DuplicateCnt=Count(1)
FROM UploadCollateralDetail
GROUP BY  SrNo
HAVING COUNT(SrNo) >1;

IF (@DuplicateCnt>0)

 UPDATE		UploadCollateralDetail
SET			ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Duplicate Sl. No., kindly check and upload again'     
						 ELSE ErrorMessage+','+SPACE(1)+'Duplicate Sl. No., kindly check and upload again'     END
			,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END   
			,Srnooferroneousrows=V.SrNo			
   FROM		UploadCollateralDetail V  
   Where	ISNULL(SrNo,'') In(  
								   SELECT SrNo
									FROM UploadCollateralDetail a
									GROUP BY  SrNo
									HAVING COUNT(SrNo) >1
							   )

							   
----------------------------------------------
  
  /*validations on LiabID*/
  
  UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Liab ID cannot be blank or greater than 100 Character. Please check the values and upload again.'     
						ELSE ErrorMessage+','+SPACE(1)+'Liab ID cannot be blank or greater than 100 Character. Please check the values and upload again.'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Liab ID' ELSE   ErrorinColumn +','+SPACE(1)+'Liab ID' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadCollateralDetail V  
 WHERE ISNULL(LiabID,'')='' Or  Len((LiabID))>100


  
  UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Only special characters - _  / are allowed, kindly remove and try again'     
						ELSE ErrorMessage+','+SPACE(1)+'Only special characters - _  / are allowed, kindly remove and try again'    END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Liab ID' ELSE   ErrorinColumn +','+SPACE(1)+'Liab ID' END       
		,Srnooferroneousrows=V.SrNo

   
   FROM UploadCollateralDetail V  
  WHERE ISNULL(LiabID,'')  like '%[,!@#$%^&*()+=]%'

		
 -------------------------------------------------------------------------


----------------------------------------------
  
  /*validations on UCIC*/
   Declare @Count Int,@I Int,@Entity_Key Int
   Declare @UCIC Varchar(100)=''
   Declare @UCIFFound Int=0
     Declare @CustomerName Varchar(250)=''
	  Declare @CustName Varchar(250)=''
	  Declare @CustomerNameFound Int=0


  UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'UCIC cannot be blank or grtater than 16 Character. Please check the values and upload again.'
     
						ELSE ErrorMessage+','+SPACE(1)+' UCIC cannot be blank or grtater than 16 Character. Please check the values and upload again.'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'UCIC' ELSE   ErrorinColumn +','+SPACE(1)+'UCIC' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadCollateralDetail V  
 WHERE ISNULL(UCIC,'')=''  Or  Len((UCIC))>16

 IF OBJECT_ID('TempDB..#tmp') IS NOT NULL DROP TABLE #tmp; 
  
  Select  ROW_NUMBER() OVER(ORDER BY  CONVERT(INT,Entity_Key) ) RecentRownumber,Entity_Key,UCIC,CustName  into #tmp from UploadCollateralDetail
                  
 Select @Count=Count(*) from #tmp
  
   SET @I=1
   SET @Entity_Key=0
     SET @UCIFFound =0
   SET @CustomerNameFound =0

   SET @UCIC=''
     While(@I<=@Count)
               BEGIN 
			     Select @UCIC =UCIC,@Entity_Key=Entity_Key,@CustName=CustName  from #tmp where RecentRownumber=@I 
							order By Entity_Key

					  Select      @UCIFFound=Count(1)
				from PRO.CustomerCal  A Where UCIF_ID=@UCIC

				  Select      @CustomerNameFound=Count(1)
				from PRO.CustomerCal  A Where UCIF_ID=@UCIC And CustomerName=@CustName

				IF @UCIFFound =0
				    Begin
				 Update UploadCollateralDetail
										   SET   ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN ' UCIC is invalid. Kindly check the entered UCIC'     
											 ELSE ErrorMessage+','+SPACE(1)+' UCIC is invalid. Kindly check the entered UCIC'      END
											 ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'UCIC' ELSE   ErrorinColumn +','+SPACE(1)+'UCIC' END   
										   Where Entity_Key=@Entity_Key
					END

					IF @CustomerNameFound=0
				    Begin
				 Update UploadCollateralDetail
										   SET   ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Customer Name is invalid for this UCIC. Kindly check the entered Customer Name'     
											 ELSE ErrorMessage+','+SPACE(1)+' Customer Name is invalid for this UCIC. Kindly check the entered Customer Name'      END
											 ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'UCIC' ELSE   ErrorinColumn +','+SPACE(1)+'UCIC' END   
										   Where Entity_Key=@Entity_Key
					END
					  SET @I=@I+1
					  SET @UCIC=''
								
								
			   END

UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Only special characters - _  / are allowed, kindly remove and try again'     
						ELSE ErrorMessage+','+SPACE(1)+'Only special characters - _  / are allowed, kindly remove and try again'    END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Liab ID' ELSE   ErrorinColumn +','+SPACE(1)+'Liab ID' END       
		,Srnooferroneousrows=V.SrNo

   
   FROM UploadCollateralDetail V  
  WHERE ISNULL(UCIC,'')  like '%[,!@#$%^&*()+=]%'

 -------------------------------------------------------------------------

 ----------------------------------------------
  
----------------------------------------------
  
  /*validations on Asset ID*/
    Declare @DuplicateAssetCnt int=0
  UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Asset ID cannot be blank or greater than 25 Character. Please check the values and upload again.'     
						ELSE ErrorMessage+','+SPACE(1)+'Asset ID cannot be blank or greater than 25 Character. Please check the values and upload again.'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Asset ID' ELSE   ErrorinColumn +','+SPACE(1)+'Asset ID' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadCollateralDetail V  
 WHERE ISNULL(AssetID,'')='' or LEN(ISNULL(AssetID,''))>25

 
  SELECT @DuplicateAssetCnt=Count(1)
FROM UploadCollateralDetail
GROUP BY  AssetID
HAVING COUNT(AssetID) >1;

IF (@DuplicateAssetCnt>0)
 BEGIN
  UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Duplicate Asset ID., kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Duplicate Asset ID., kindly check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Asset ID' ELSE   ErrorinColumn +','+SPACE(1)+'Asset ID' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadCollateralDetail V  
   Where ISNULL(AssetID,'') In(  
   SELECT AssetID
	FROM UploadCollateralDetail
	GROUP BY  AssetID
	HAVING COUNT(AssetID) >1)
END

	UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Record for Asset ID  is pending for authorization in ‘Upload ID’ '+ Convert(Varchar(10),C.UploadId) +' kindly remove the record and upload again '     
						ELSE ErrorMessage+','+SPACE(1)+'Record for Asset ID  is pending for authorization in ‘Upload ID’ '+ Convert(Varchar(10),C.UploadId) +' kindly remove the record and upload again '  END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Asset ID ' ELSE   ErrorinColumn +','+SPACE(1)+'Asset ID ' END       
		,Srnooferroneousrows=V.SrNo
    FROM UploadCollateralDetail V  
   LEFT Join AdvSecurityDetail_Mod B ON V.AssetID=B.AssetID
   LEFT Join CollateralDetailUpload_Mod C ON V.AssetID=C.AssetID
 WHERE	C.AuthorisationStatus In('NP','MP','FM','RM','1A') 
 and (B.AssetID is not NULL or C.AssetID is not NULL)


 	UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Record for Asset ID  is Already present for ‘CollateralID’ '+ Convert(Varchar(10),B.CollateralID) +' kindly remove the record and upload again '     
						ELSE ErrorMessage+','+SPACE(1)+'Record for Asset ID  is Already present for ‘CollateralID’ '+ Convert(Varchar(10),B.CollateralID) +' kindly remove the record and upload again  '  END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Asset ID ' ELSE   ErrorinColumn +','+SPACE(1)+'Asset ID ' END       
		,Srnooferroneousrows=V.SrNo
    FROM UploadCollateralDetail V  
   Inner Join  Curdat.AdvSecurityDetail B ON V.AssetID=B.AssetID
   
 WHERE	
  (B.AssetID is not NULL or V.AssetID is not NULL)
  AND V.Action='A'
 ---------------------------------------------------

  -------------------------------------------------------------------------
----------------------------------------------
 ----------------------------------------------
  
  /*validations on Segement*/
    Declare @DuplicateSegmentInt int=0

	

	IF OBJECT_ID('SegmentTypeData') IS NOT NULL  
	  BEGIN  
	   DROP TABLE SegmentTypeData 
	
	  END

	   SELECT * into SegmentTypeData  FROM(
 SELECT ROW_NUMBER() OVER(PARTITION BY Segment  ORDER BY  Segment ) 
 ROW ,Segment FROM UploadCollateralDetail
)X
 WHERE ROW=1

 
  SELECT  @DuplicateSegmentInt=COUNT(*) FROM UploadCollateralDetail A
 Left JOIN Dimsegment B
 ON  A.Segment=B.SegmentName
 Where B.SegmentName IS NULL

    IF @DuplicateSegmentInt>0

	BEGIN
	       UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in column ‘Segment’. Kindly enter the values as mentioned in the ‘Segment’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column



'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid value in column ‘Segment’. Kindly enter the values as mentioned in the ‘Segment’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'     END  
        ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Segment' ELSE   ErrorinColumn +','+SPACE(1)+'Segment' END     
		,Srnooferroneousrows=V.SrNo
		 FROM UploadCollateralDetail V  
 WHERE ISNULL(Segment,'')<>''
 AND  V.Segment IN(
				SELECT  A.Segment FROM UploadCollateralDetail A
						 Left JOIN Dimsegment B
						 ON  A.Segment=B.SegmentName
						 Where B.SegmentName IS NULL

				 )
	END





	 UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Segment cannot be blank or greater than 25 Character. Please check the values and upload again.'     
						ELSE ErrorMessage+','+SPACE(1)+'Segment cannot be blank or greater than 25 Character. Please check the values and upload again.'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Segment' ELSE   ErrorinColumn +','+SPACE(1)+'Segment' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadCollateralDetail V  
 WHERE ISNULL(Segment,'')='' or Len(ISNULL(Segment,''))>25




	

	 ---------------------------------------------------

	  ----------------------------------------------
  
  /*validations on CRE*/
    --Declare @DuplicateAssetCnt int=0

	 UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Segment cannot be blank or grtater than 3 Character. Please check the values and upload again.'     
						ELSE ErrorMessage+','+SPACE(1)+'Segment cannot be blank or grtater than 3 Character. Please check the values and upload again.'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'CRE' ELSE   ErrorinColumn +','+SPACE(1)+'CRE' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadCollateralDetail V  
 WHERE ISNULL(CRE,'')='' or Len(ISNULL(CRE,''))>25

  UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in column ‘CRE’. Kindly enter ‘Yes or No’ and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid value in column ‘CRE’. Kindly enter ‘Yes or No’ and upload again'    END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'CRE' ELSE   ErrorinColumn +','+SPACE(1)+'CRE' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadCollateralDetail V  
 WHERE ISNULL(CRE,'') NOT IN('Yes','No')


	

	 ---------------------------------------------------
	   ----------------------------------------------
  
  /*validations on CRE*/
    --Declare @DuplicateAssetCnt int=0

	 UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Action Colum Can not be Blank. Kindly enter A for Addition and M for Modification upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Action Colum Can not be Blank. Kindly enter A for Addition and M for Modification upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Action' ELSE   ErrorinColumn +','+SPACE(1)+'Action' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadCollateralDetail V  
 WHERE ltrim(rtrim(ISNULL(Action,''))) =''


 	 UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Collateral ID Column Can not be Blank.If Action is M. Kindly Check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Collateral ID Column Can not be Blank.If Action is M. Kindly Check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Action' ELSE   ErrorinColumn +','+SPACE(1)+'Action' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadCollateralDetail V  
 WHERE ltrim(rtrim(ISNULL(Action,''))) ='M' and ISNULL(CollateralID,'')=''

  UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Collateral ID Column must be Blank.If Action is A. Kindly Check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Collateral ID Column must be Blank.If Action is A. Kindly Check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Action' ELSE   ErrorinColumn +','+SPACE(1)+'Action' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadCollateralDetail V  
 WHERE ltrim(rtrim(ISNULL(Action,''))) ='A' and ISNULL(CollateralID,'')<>''

 
  UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'InValid Value,Kindly enter A for Addition and M for Modification. Kindly Check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'InValid Value,Kindly enter A for Addition and M for Modification. Kindly Check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Action' ELSE   ErrorinColumn +','+SPACE(1)+'Action' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadCollateralDetail V  
 WHERE ltrim(rtrim(ISNULL(Action,''))) NOT IN('A','M')

 ----------------------------------------------

	 
	  ----------------------------------------------
  
  /*validations on Sub Type of Collateral*/
    --Declare @DuplicateAssetCnt int=0

	Declare @CollateralSubTypeCnt int=0
 IF OBJECT_ID('CollateralSubTypeData') IS NOT NULL  
	 BEGIN  
	   DROP TABLE CollateralSubTypeData  
	
	  END

	  
 SELECT * into CollateralSubTypeData  FROM(
 SELECT ROW_NUMBER() OVER(PARTITION BY A.CollateralSubType  ORDER BY  A.CollateralSubType ) 
 ROW ,A.CollateralSubType,B.CollateralTypeAltKey FROM UploadCollateralDetail A
LEFT JOIN DimCollateralSubType B
 ON  A.CollateralSubType=B.CollateralSubTypeDescription
 )X
 WHERE ROW=1

 

  SELECT  @CollateralSubTypeCnt=COUNT(*) FROM CollateralSubTypeData A

 Where A.CollateralTypeAltKey IS NULL

 

UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Collateral Sub Type cannot be blank . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Collateral Sub Type cannot be blank . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Collateral Sub Type' ELSE   ErrorinColumn +','+SPACE(1)+'Collateral Sub Type' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadCollateralDetail V  
 WHERE ISNULL(CollateralSubType,'')=''

 --UPDATE UploadCollateralDetail
	--SET  
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Collateral Sub Type is Immovable Fixed assets and CRE must be Yes. Please check the values and upload again'     
	--					ELSE ErrorMessage+','+SPACE(1)+'Collateral Sub Type is Immovable Fixed assets and CRE must be Yes. Please check the values and upload again'     END
	--	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Collateral Sub Type' ELSE   ErrorinColumn +','+SPACE(1)+'Collateral Sub Type' END   
	--	,Srnooferroneousrows=V.SrNo
								
   
 --  FROM UploadCollateralDetail V  
 --WHERE ISNULL(CollateralSubType,'')='Immovable Fixed assets' AND ISNULL(CRE,'')<>'Yes'

  UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Collateral Sub Type is not Immovable Fixed assets and CRE must be No. Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Collateral Sub Type is not Immovable Fixed assets and CRE must be No. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Collateral Sub Type' ELSE   ErrorinColumn +','+SPACE(1)+'Collateral Sub Type' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadCollateralDetail V  
 WHERE ISNULL(CollateralSubType,'') NOT IN('Immovable Fixed assets') AND ISNULL(CRE,'')='Yes'


IF @CollateralSubTypeCnt>0

BEGIN
 
   UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in column ‘Collateral Sub Type’. Kindly enter the values as mentioned in the ‘Collateral Sub Type’ master and upload again. Click on ‘Download Master value’ to download the val

id values for the column'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid value in column ‘Collateral Sub Type’. Kindly enter the values as mentioned in the ‘Collateral Sub Type’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'  

END   
						--ELSE ErrorMessage+','+SPACE(1)+ 'Different PoolID of same combination of PoolName and PoolType is Available. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Collateral Sub Typ' ELSE   ErrorinColumn +','+SPACE(1)+'Collateral Sub Typ' END     
		,Srnooferroneousrows=V.SrNo
	--	STUFF((SELECT ','+SRNO 
	--							FROM #UploadNewAccount A
	--							WHERE A.SrNo IN(SELECT V.SrNo FROM #UploadNewAccount V  
 --WHERE ISNULL(ACID,'')<>'' AND ISNULL(TERRITORY,'')<>''
 ----AND SRNO IN(SELECT Srno FROM #DUB2))
 --AND ACID IN(SELECT ACID FROM #DUB2 GROUP BY ACID))

	--							FOR XML PATH ('')
	--							),1,1,'')   

 FROM UploadCollateralDetail V  
 WHERE ISNULL(CollateralSubType,'')<>''
 AND  V.CollateralSubType IN(
				  SELECT A.CollateralSubType FROM CollateralSubTypeData A
				  Where A.CollateralTypeAltKey IS NULL
 
				 )
 END 

	

	 ---------------------------------------------------

	 /*validations on Name of the Security Provider*/
    --Declare @DuplicateAssetCnt int=0

	-- UPDATE UploadCollateralDetail
	--SET  
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Name of the Security Provider cannot be blank or greater than 50 Character. Please check the values and upload again.'     
	--					ELSE ErrorMessage+','+SPACE(1)+'Name of the Security Provider cannot be blank or greater than 50 Character. Please check the values and upload again.'     END
	--	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Name of the Security Provider' ELSE   ErrorinColumn +','+SPACE(1)+'Name of the Security Provider' END   
	--	,Srnooferroneousrows=V.SrNo
								
   
 --  FROM UploadCollateralDetail V  
 --WHERE ISNULL(NameSecuPv,'')='' 

  UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Only special characters - _ / ; , are allowed, kindly remove and try again'     
						ELSE ErrorMessage+','+SPACE(1)+'Only special characters - _ / ; , are allowed, kindly remove and try again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Name of the Security Provider' ELSE   ErrorinColumn +','+SPACE(1)+'Name of the Security Provider' END 
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadCollateralDetail V  

   WHERE ISNULL(NameSecuPv,'')  like '%[!@#$%^&*()+=]%'


	

	 ---------------------------------------------------

	 	 ---------------------------------------------------

	 /*validations on Seniority of Charge*/
    --Declare @DuplicateAssetCnt int=0

	 UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Seniority of Charge cannot be blank . Please check the values and upload again.'     
						ELSE ErrorMessage+','+SPACE(1)+'Seniority of Charge cannot be blank . Please check the values and upload again.'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Seniority of Charge' ELSE   ErrorinColumn +','+SPACE(1)+'Seniority of Charge' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadCollateralDetail V  
 WHERE ISNULL(SeniorityCharge,'')='' 

  UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in column ‘Seniority of Charge’. Kindly enter the values as mentioned in the ‘Charge Nature’ master and upload again. Click on ‘Download Master value’ to download the valid val
u
es for the column'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid value in column ‘Seniority of Charge’. Kindly enter the values as mentioned in the ‘Charge Nature’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'     END


,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Seniority of Charge' ELSE   ErrorinColumn +','+SPACE(1)+'Seniority of Charge' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadCollateralDetail V  
 WHERE ISNULL(SeniorityCharge,'') NOT in('Exclusive Charge','First Charge','Second Charge','Residual Charge','First Pari Passu Charge','Second Pari Passu charge')



	

	 ---------------------------------------------------

	 
	 	 ---------------------------------------------------

	 /*validations on Security Status*/
    --Declare @DuplicateAssetCnt int=0

	 UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Security Status cannot be blank . Please check the values and upload again.'     
						ELSE ErrorMessage+','+SPACE(1)+'Security Status cannot be blank . Please check the values and upload again.'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Security Status' ELSE   ErrorinColumn +','+SPACE(1)+'Security Status' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadCollateralDetail V  
 WHERE ISNULL(SecurityStatus,'')='' 

  UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in column ‘Security Status’. Kindly enter ‘Secured, WIP, Partially Secured’ and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid value in column ‘Security Status’. Kindly enter ‘Secured, WIP, Partially Secured’ and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Security Status' ELSE   ErrorinColumn +','+SPACE(1)+'Security Status' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadCollateralDetail V  
 WHERE ISNULL(SecurityStatus,'') NOT in('Secured','WIP','Partially Secured')



	

	 ---------------------------------------------------




	 	 	 ---------------------------------------------------

	 	 	 	 ---------------------------------------------------

	 /*validations on FD No*/
    --Declare @DuplicateAssetCnt int=0

	 UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'FDNO cannot be greater Than 25 character . Please check the values and upload again.'     
						ELSE ErrorMessage+','+SPACE(1)+'FDNO cannot be greater Than 25 character . Please check the values and upload again.'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'FDNO' ELSE   ErrorinColumn +','+SPACE(1)+'FDNO' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadCollateralDetail V  
 WHERE  Len(ISNULL(FDNO,''))>25

  UPDATE UploadCollateralDetail
	SET  
     ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Column ‘FD No.’ cannot be blank when ‘Sub Type of Collateral is ‘Borrower FD or Third Party FD'     
						ELSE ErrorMessage+','+SPACE(1)+'Column ‘FD No.’ cannot be blank when ‘Sub Type of Collateral is ‘Borrower FD or Third Party FD'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'FDNO' ELSE   ErrorinColumn +','+SPACE(1)+'FDNO' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadCollateralDetail V  
 WHERE ISNULL(CollateralSubType,'')  in('Borrowers FD','Third Party FD') AND ISNULL(FDNO,'')='' 


 UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Column ‘FD No.’ must be blank when ‘Sub Type of Collateral is other than ‘Borrower FD or Third Party FD'     
						ELSE ErrorMessage+','+SPACE(1)+'Column ‘FD No.’ must be blank when ‘Sub Type of Collateral is other than ‘Borrower FD or Third Party FD'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'FDNO' ELSE   ErrorinColumn +','+SPACE(1)+'FDNO' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadCollateralDetail V  
 WHERE ISNULL(CollateralSubType,'') NOT in('Borrowers FD','Third Party FD') AND ISNULL(FDNO,'')<>''

 UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'FDNO can not contain decimal. Kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'FDNO can not contain decimal. Kindly check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'FDNO' ELSE   ErrorinColumn +','+SPACE(1)+'FDNO' END       
		,Srnooferroneousrows=V.SrNo

   
   FROM UploadCollateralDetail V  
  WHERE (CHARINDEX('.',FDNO))>0

	

	 ---------------------------------------------------

	  	 	 	 ---------------------------------------------------

	 /*validations on ISIN No./Folio No*/
    --Declare @DuplicateAssetCnt int=0

	-- UPDATE UploadCollateralDetail
	--SET  
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'ISIN No./Folio No cannot be blank . Please check the values and upload again.'     
	--					ELSE ErrorMessage+','+SPACE(1)+'ISIN No./Folio No cannot be blank . Please check the values and upload again.'     END
	--	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'ISIN No./Folio No' ELSE   ErrorinColumn +','+SPACE(1)+'ISIN No./Folio No' END   
	--	,Srnooferroneousrows=V.SrNo
								
   
 --  FROM UploadCollateralDetail V  
 --WHERE ISNULL(ISINNo_FolioNumber,'')='' 

  UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'ISIN No./Folio No. can not be greater than 25 character.. Kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'ISIN No./Folio No. can not be greater than 25 character.. Kindly check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'ISIN No./Folio No' ELSE   ErrorinColumn +','+SPACE(1)+'ISIN No./Folio No' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadCollateralDetail V  
 WHERE   Len(ISNULL(ISINNo_FolioNumber,''))>25

 UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Only special characters - _ / are allowed, kindly remove and try again'     
						ELSE ErrorMessage+','+SPACE(1)+'Only special characters - _ / are allowed, kindly remove and try again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'ISIN No./Folio No' ELSE   ErrorinColumn +','+SPACE(1)+'ISIN No./Folio No' END       
		,Srnooferroneousrows=V.SrNo

   
   FROM UploadCollateralDetail V  
   WHERE ISNULL(ISINNo_FolioNumber,'')  like '%[,!@#$%^&*()+=]%'
  


  
 UPDATE UploadCollateralDetail
	SET  
       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Column ‘ISIN No./Folio No.’ cannot be blank when ‘Sub Type of Collateral is either ‘Listed Shares, Unlisted Shares, Mutual Fund, Bond’'     
						ELSE ErrorMessage+','+SPACE(1)+'Column ‘ISIN No./Folio No.’ cannot be blank when ‘Sub Type of Collateral is either ‘Listed Shares, Unlisted Shares, Mutual Fund, Bond’'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'ISIN No./Folio No' ELSE   ErrorinColumn +','+SPACE(1)+'ISIN No./Folio No' END       
		,Srnooferroneousrows=V.SrNo

   
  FROM UploadCollateralDetail V  
 WHERE ISNULL(CollateralSubType,'')  in('Listed Shares', 'Unlisted Shares', 'Mutual Funds', 'Bond') AND ISNULL(ISINNo_FolioNumber,'')='' 
	
	UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Column ‘ISIN No./Folio No.’ must be blank when ‘Sub Type of Collateral is other than ‘Listed Shares, Unlisted Shares, Mutual Fund, Bond’'     
						ELSE ErrorMessage+','+SPACE(1)+'Column ‘ISIN No./Folio No.’ must be blank when ‘Sub Type of Collateral is other than ‘Listed Shares, Unlisted Shares, Mutual Fund, Bond’’'     END


		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'ISIN No./Folio No' ELSE   ErrorinColumn +','+SPACE(1)+'ISIN No./Folio No' END       
		,Srnooferroneousrows=V.SrNo

   
  FROM UploadCollateralDetail V  
 WHERE ISNULL(CollateralSubType,'')NOT  in('Listed Shares', 'Unlisted Shares', 'Mutual Funds', 'Bond') AND ISNULL(ISINNo_FolioNumber,'')<>''

	 ---------------------------------------------------

	   	 	 	 ---------------------------------------------------

	 /*validations on Quantity of Shares / Mutual Funds/ Bonds*/
    --Declare @DuplicateAssetCnt int=0

	-- UPDATE UploadCollateralDetail
	--SET  
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Quantity of Shares / Mutual Funds/ Bonds No cannot be blank . Please check the values and upload again.'     
	--					ELSE ErrorMessage+','+SPACE(1)+'Quantity of Shares / Mutual Funds/ Bonds cannot be blank . Please check the values and upload again.'     END
	--	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Quantity of Shares / Mutual Funds/ Bonds' ELSE   ErrorinColumn +','+SPACE(1)+'Quantity of Shares / Mutual Funds/ Bonds' END   
	--	,Srnooferroneousrows=V.SrNo
								
   
 --  FROM UploadCollateralDetail V  
 --WHERE ISNULL(QtyShares_MutualFunds_Bonds,'')='' 

  UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Quantity of Shares / Mutual Funds/ Bonds No cannot contain decimal or greater than 10 character . Please check the values and upload again.'     
						ELSE ErrorMessage+','+SPACE(1)+'Quantity of Shares / Mutual Funds/ Bonds No cannot contain decimal or greater than 10 character . Please check the values and upload again.n.'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Quantity of Shares / Mutual Funds/ Bonds' ELSE   ErrorinColumn +','+SPACE(1)+'Quantity of Shares / Mutual Funds/ Bonds' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadCollateralDetail V  
 WHERE Len(ISNULL(QtyShares_MutualFunds_Bonds,''))>10 AND (CHARINDEX('.',QtyShares_MutualFunds_Bonds))>0

 UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Column ‘Quantity of Shares / Mutual Funds/ Bonds’ cannot be blank when ‘Sub Type of Collateral is either ‘Listed Shares, Unlisted Shares, Mutual Fund, Bond'     
						ELSE ErrorMessage+','+SPACE(1)+'Column ‘Quantity of Shares / Mutual Funds/ Bonds’ cannot be blank when ‘Sub Type of Collateral is either ‘Listed Shares, Unlisted Shares, Mutual Fund, Bond' END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Quantity of Shares / Mutual Funds/ Bonds' ELSE   ErrorinColumn +','+SPACE(1)+'Quantity of Shares / Mutual Funds/ Bonds' END  
		,Srnooferroneousrows=V.SrNo

 
   FROM UploadCollateralDetail V  
 WHERE ISNULL(CollateralSubType,'')  in('Listed Shares', 'Unlisted Shares', 'Mutual Funds', 'Bond') AND ISNULL(QtyShares_MutualFunds_Bonds,'')=''

UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Column ‘Quantity of Shares / Mutual Funds/ Bonds’ must be blank when ‘Sub Type of Collateral is other than ‘Listed Shares, Unlisted Shares, Mutual Fund, Bond'     
						ELSE ErrorMessage+','+SPACE(1)+'Column ‘Quantity of Shares / Mutual Funds/ Bonds’ must be blank when ‘Sub Type of Collateral is other than ‘Listed Shares, Unlisted Shares, Mutual Fund, Bond'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Quantity of Shares / Mutual Funds/ Bonds' ELSE   ErrorinColumn +','+SPACE(1)+'Quantity of Shares / Mutual Funds/ Bonds' END       
		,Srnooferroneousrows=V.SrNo

   
   FROM UploadCollateralDetail V  
 WHERE ISNULL(CollateralSubType,'') NOT in('Listed Shares', 'Unlisted Shares', 'Mutual Funds', 'Bond') AND ISNULL(QtyShares_MutualFunds_Bonds,'')<>''


 UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Column ‘Quantity of Shares / Mutual Funds/ Bonds’ must be numeric. Kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Column ‘Quantity of Shares / Mutual Funds/ Bonds’ must be numeric. Kindly check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Quantity of Shares / Mutual Funds/ Bonds' ELSE   ErrorinColumn +','+SPACE(1)+'Quantity of Shares / Mutual Funds/ Bonds' END   
		,Srnooferroneousrows=V.SrNo

   FROM UploadCollateralDetail V  
  WHERE (ISNUMERIC(QtyShares_MutualFunds_Bonds)=0 AND ISNULL(QtyShares_MutualFunds_Bonds,'')<>'') OR 
 ISNUMERIC(QtyShares_MutualFunds_Bonds) LIKE '%^[0-9]%'
  

	


	 ---------------------------------------------------

	 	 	 	 ---------------------------------------------------

	 /*validations on Quantity of Line No.*/
    --Declare @DuplicateAssetCnt int=0

	 UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Line No cannot be blank . Please check the values and upload again.'     
						ELSE ErrorMessage+','+SPACE(1)+'Line No cannot be blank . Please check the values and upload again.'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Line No' ELSE   ErrorinColumn +','+SPACE(1)+'Line No' END   
		,Srnooferroneousrows=V.SrNo
								

   
   FROM UploadCollateralDetail V  
 WHERE ISNULL(Line_No,'')=''
 

 UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Line No  cannot be greater than 300 Character. Please check the values and upload again.'     
						ELSE ErrorMessage+','+SPACE(1)+'Line No  cannot be greater than 300 Character. Please check the values and upload again.'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Line No ' ELSE   ErrorinColumn +','+SPACE(1)+'Line No ' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadCollateralDetail V  
 WHERE Len(ISNULL(Line_No,''))>300

  UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Only special characters - _ / ; are allowed, kindly remove and try again.'     
						ELSE ErrorMessage+','+SPACE(1)+'Only special characters - _ / ; are allowed, kindly remove and try again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Line No' ELSE   ErrorinColumn +','+SPACE(1)+'Line No' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadCollateralDetail V  
 WHERE ISNULL(Line_No,'')  like '%[,!@#$%^&*()+=]%'

 

	 ---------------------------------------------------

	 
	 	 	 	 ---------------------------------------------------

	 /*validations on Quantity of Cross Collateral (Liab ID)*/
    --Declare @DuplicateAssetCnt int=0

	-- UPDATE UploadCollateralDetail
	--SET  
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Cross Collateral (Liab ID) cannot be blank . Please check the values and upload again.'     
	--					ELSE ErrorMessage+','+SPACE(1)+'Cross Collateral (Liab ID)cannot be blank . Please check the values and upload again.'     END
	--	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Cross Collateral (Liab ID)' ELSE   ErrorinColumn +','+SPACE(1)+'Cross Collateral (Liab ID)' END   
	--	,Srnooferroneousrows=V.SrNo
								
   
 --  FROM UploadCollateralDetail V  
 --WHERE ISNULL(CrossCollateral_LiabID,'')='' 

 	 UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Cross Collateral (Liab ID) cannot be greater than 100 Character. Please check the values and upload again.'     
						ELSE ErrorMessage+','+SPACE(1)+'Cross Collateral (Liab ID) cannot be gr
eater than 100 Character. Please check the values and upload again.'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Cross Collateral (Liab ID)' ELSE   ErrorinColumn +','+SPACE(1)+'Cross Collateral (Liab ID)' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadCollateralDetail V  
 WHERE Len(ISNULL(CrossCollateral_LiabID,''))>100



  UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Only special characters - _ / ; are allowed, kindly remove and try again.'     
						ELSE ErrorMessage+','+SPACE(1)+'Only special characters - _ / ; are allowed, kindly remove and try again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Line No' ELSE   ErrorinColumn +','+SPACE(1)+'Line No' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadCollateralDetail V  

 WHERE ISNULL(CrossCollateral_LiabID,'')  like '%[,!@#$%^&*()+=]%'

 

	 ---------------------------------------------------

	 	 	 	 ---------------------------------------------------

	 /*validations on  Property Address*/
    --Declare @DuplicateAssetCnt int=0

	
	-- UPDATE UploadCollateralDetail
	--SET  
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Property Address cannot be blank when ‘Sub Type of Collateral is ‘Immovable Fixed Asset'     
	--					ELSE ErrorMessage+','+SPACE(1)+'Property Address cannot be blank when ‘Sub Type of Collateral is ‘Immovable Fixed Asset'     END
	--	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Property Address' ELSE   ErrorinColumn +','+SPACE(1)+'Property Address' END   
	--	,Srnooferroneousrows=V.SrNo
								
   
 --  FROM UploadCollateralDetail V  
 --WHERE ISNULL(CollateralSubType,'')  in('Immovable Fixed assets') AND ISNULL(PropertyAdd,'') = ''

 /* 
  UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Only special characters - _ / ; are allowed, kindly remove and try again.'     
						ELSE ErrorMessage+','+SPACE(1)+'Only special characters - _ / ; are allowed, kindly remove and try again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Property Address' ELSE   ErrorinColumn +','+SPACE(1)+'Property Address' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadCollateralDetail V  


 WHERE ISNULL(PropertyAdd,'')  like '%[]%'
 */


 --UPDATE UploadCollateralDetail
	--SET  
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Column ‘Property Address’ cannot be blank when ‘Sub Type of Collateral is ‘Immovable Fixed Asset'     
	--					ELSE ErrorMessage+','+SPACE(1)+'Column ‘Property Address’ cannot be blank when ‘Sub Type of Collateral is ‘Immovable Fixed Asset’'     END
	--	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Property Addres' ELSE   ErrorinColumn +','+SPACE(1)+'Property Addreso' END       
	--	,Srnooferroneousrows=V.SrNo

 
 -- FROM UploadCollateralDetail V  
 --WHERE ISNULL(PropertyAdd,'')  in('Immovable Fixed Asset') AND ISNULL(PropertyAdd,'')='' 

	 ---------------------------------------------------

	 	 	 	 ---------------------------------------------------

	 /*validations on  PIN Code*/
    --Declare @DuplicateAssetCnt int=0

	 UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'PIN cannot be blank or greater than 6 Character. Please check the values and upload again.'     
						ELSE ErrorMessage+','+SPACE(1)+'PIN cannot be blank or greater than 6 Character. Please check the values and upload again.'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'PIN' ELSE   ErrorinColumn +','+SPACE(1)+'PIN' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadCollateralDetail V  
WHERE ISNULL(CollateralSubType,'')  in('Immovable Fixed assets')  AND (ISNULL(PIN,'')='' OR Len(ISNULL(PIN,''))>6)


	 /*validations on  Date of Stock Audit */
    --Declare @DuplicateAssetCnt int=0
/*	
	 UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Column ‘Date of Stock Audit’ can not  be blank when ‘Sub Type of Collateral is  ‘Current Asset’. Please check the values and upload again.'     
						ELSE ErrorMessage+','+SPACE(1)+'Column ‘Date of Stock Audit’ can not  be blank when ‘Sub Type of Collateral is  ‘Current Asset’.. Please check the values and upload again.'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Date of Stock Audit' ELSE   ErrorinColumn +','+SPACE(1)+'Date of Stock Audit' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadCollateralDetail V  
 WHERE ISNULL(CollateralSubType,'')  in('Current Assets') AND  ISNULL(DtStockAudit,'')=''   
*/
 Set DateFormat DMY

 UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Date of Stock Audit must be less than equal to Current Date. Kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Date of Stock Audit must be less than equal to Current Date. Kindly check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Date of Stock Audit' ELSE   ErrorinColumn +','+SPACE(1)+'Date of Stock Audit' END       
		,Srnooferroneousrows=V.SrNo

   
  FROM UploadCollateralDetail V  
 WHERE (Case When ISDATE(DtStockAudit)=0 Then 2
        When ISDATE(DtStockAudit)=1 AND Convert(date,DtStockAudit)<Convert(date,Getdate())     Then 1
       Else 0 END)=0



--WHERE (Case  When  Convert(Varchar(10),DtStockAudit,121)<=Convert(Varchar(10),Getdate(),121)      Then 1
--       Else 0 END)=1

 UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Date of Stock Audit must be in ddmmyyyy format. Kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Date of Stock Audit must be in ddmmyyyy format. Kindly check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Date of Stock Audit' ELSE   ErrorinColumn +','+SPACE(1)+'Date of Stock Audit' END       
		,Srnooferroneousrows=V.SrNo

   
  FROM UploadCollateralDetail V  
 WHERE ISDATE(DtStockAudit)=0 AND (ISNULL(DtStockAudit,'')<>''  AND ISNULL(DtStockAudit,'')<>'Not Applicable')


/*
  UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Column ‘Date of Stock Audit’ must be blank when ‘Sub Type of Collateral is other than ‘Current Asset’'     
						ELSE ErrorMessage+','+SPACE(1)+'Column ‘Date of Stock Audit’ must be blank when ‘Sub Type of Collateral is other than ‘Current Asset’'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Date of Stock Audit' ELSE   ErrorinColumn +','+SPACE(1)+'Date of Stock Audit' END       
		,Srnooferroneousrows=V.SrNo

   
  FROM UploadCollateralDetail V  
 WHERE ISNULL(CollateralSubType,'')NOT  in('Current Assets') AND  ISNULL(DtStockAudit,'')<>''   AND ISNULL(DtStockAudit,'')<>'Not Applicable'
 */
	 ---------------------------------------------------

	 
	 	 	 	 ---------------------------------------------------

	 /*validations on  SBLC Issuing Bank  */
    --Declare @DuplicateAssetCnt int=0
	Declare @SBLCIssueBank Int=0

	 IF OBJECT_ID('SBLCIssueBankTypeData') IS NOT NULL  
	  BEGIN  
	   DROP TABLE SBLCIssueBankTypeData  
	
	  END


	  SELECT * into SBLCIssueBankTypeData  FROM(
 SELECT ROW_NUMBER() OVER(PARTITION BY SBLCIssuingBank  ORDER BY  SBLCIssuingBank ) 
 ROW ,SBLCIssuingBank FROM UploadCollateralDetail
 )X
 WHERE ROW=1


 SELECT  @SBLCIssueBank=COUNT(*) FROM SBLCIssueBankTypeData A
 Left JOIN DimBank B
 ON  A.SBLCIssuingBank=B.BankName
 Where B.BankName IS NULL

 IF @SBLCIssueBank>0

  BEGIN
	       UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in column ‘SBLC Issuing Bank’. Kindly enter the values as mentioned in the ‘Bank’ master and upload again. Click on ‘Download Master value’ to download the valid values for the
 
column'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid value in column ‘SBLC Issuing Bank’. Kindly enter the values as mentioned in the ‘Bank’ master and upload again. Click on ‘Download Master value’ to download the valid values for the columnn'     END  
        ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SBLC Issuing Bank ' ELSE   ErrorinColumn +','+SPACE(1)+'SBLC Issuing Bank ' END     
		,Srnooferroneousrows=V.SrNo

 

 FROM UploadCollateralDetail V  
 WHERE ISNULL(SBLCIssuingBank,'')<>''
 AND  V.SBLCIssuingBank IN(
				 SELECT   A.SBLCIssuingBank FROM SBLCIssueBankTypeData A
					 Left JOIN DimBank B
					 ON  A.SBLCIssuingBank=B.BankName
					 Where B.BankName IS NULL
				 )

	 END

	-- UPDATE UploadCollateralDetail
	--SET  
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'SBLC Issuing Bank  cannot be blank or grtater than 6 Character. Please check the values and upload again.'     
	--					ELSE ErrorMessage+','+SPACE(1)+'SBLC Issuing Bank cannot be blank or grtater than 6 Character. Please check the values and upload again.'     END
	--	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SBLC Issuing Bank ' ELSE   ErrorinColumn +','+SPACE(1)+'SBLC Issuing Bank ' END   
	--	,Srnooferroneousrows=V.SrNo
								
   
 --  FROM UploadCollateralDetail V  
 --WHERE ISNULL(SBLCIssuingBank,'')=''

 
 UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Column ‘SBLC Issuing Bank’ cannot be blank when ‘Sub Type of Collateral is ‘SBLC/BG'     
						ELSE ErrorMessage+','+SPACE(1)+'Column ‘SBLC Issuing Bank’ cannot be blank when ‘Sub Type of Collateral is ‘SBLC'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SBLC Issuing Bank' ELSE   ErrorinColumn +','+SPACE(1)+'SBLC Issuing Bank' END       
		,Srnooferroneousrows=V.SrNo

   
  FROM UploadCollateralDetail V  
 WHERE ISNULL(SBLCIssuingBank,'')  in('SBLC/BG') AND  ISNULL(DtStockAudit,'')=''



 /*
 UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Column ‘SBLC Issuing Bank’ must be blank when ‘Sub Type of Collateral is other than ‘SBLC/BG’'     
						ELSE ErrorMessage+','+SPACE(1)+'Column ‘SBLC Issuing Bank’ must be blank when ‘Sub Type of Collateral is other than ‘SBLC'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SBLC Issuing Bank' ELSE   ErrorinColumn +','+SPACE(1)+'SBLC Issuing Bank' END       
		,Srnooferroneousrows=V.SrNo

   
  FROM UploadCollateralDetail V  
 WHERE ISNULL(SBLCIssuingBank,'') NOT in('SBLC/BG') AND  ISNULL(DtStockAudit,'')<>''
 */
	 ---------------------------------------------------

	 
	 	 	 	 ---------------------------------------------------

	 /*validations on  SBLC Number   */
    --Declare @DuplicateAssetCnt int=0

	 UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN ' greater than 25 Character. Please check the values and upload again.'     
						ELSE ErrorMessage+','+SPACE(1)+' greater than 25 Character. Please check the values and upload again.'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SBLC Number ' ELSE   ErrorinColumn +','+SPACE(1)+'SBLC Number ' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadCollateralDetail V  
 WHERE  Len(ISNULL(SBLCNumber,''))>25

 

UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Special characters - _ \ / are allowed, kindly remove and try again'     
						ELSE ErrorMessage+','+SPACE(1)+'Special characters - _ \ / are allowed, kindly remove and try again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SBLC Number' ELSE   ErrorinColumn +','+SPACE(1)+'SBLC Numbert' END       
		,Srnooferroneousrows=V.SrNo

   
  FROM UploadCollateralDetail V  
 
  WHERE ISNULL(SBLCNumber,'')  like '%[,!@#$%^&*()+=]%'



 UPDATE UploadCollateralDetail 
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Column ‘SBLC Number’ cannot be blank when ‘Sub Type of Collateral is ‘SBLC'     
						ELSE ErrorMessage+','+SPACE(1)+'Column ‘SBLC Number’ cannot be blank when ‘Sub Type of Collateral is ‘SBLC'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SBLC Numbe' ELSE   ErrorinColumn +','+SPACE(1)+'SBLC Numbe' END       
		,Srnooferroneousrows=V.SrNo

  
  FROM UploadCollateralDetail V  
 WHERE ISNULL(CollateralSubType,'')  in('SBLC/BG') AND  ISNULL(SBLCNumber,'')=''

   Select CollateralSubType,SBLCNumber,DtStockAudit,* from UploadCollateralDetail

 UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Column ‘SBLC Number’ must be blank when ‘Sub Type of Collateral is other than ‘SBLC'     
						ELSE ErrorMessage+','+SPACE(1)+'Column ‘SBLC Number’ must be blank when ‘Sub Type of Collateral is other than ‘SBLC'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SBLC Numbe' ELSE   ErrorinColumn +','+SPACE(1)+'SBLC Numbe' END       
		,Srnooferroneousrows=V.SrNo

  
  FROM UploadCollateralDetail V  
 WHERE ISNULL(CollateralSubType,'') NOT in('SBLC/BG') AND  ISNULL(SBLCNumber,'')<>''



	 ---------------------------------------------------

	 
	 
	 	 	 	 ---------------------------------------------------

	 /*validations on  Currency in Which SBLC Issued    */
    --Declare @DuplicateAssetCnt int=0
	Declare @SBLCCurIssued Int =0

	IF OBJECT_ID('CollateralCurIssuedData') IS NOT NULL  
	  BEGIN  
	   DROP TABLE CollateralCurIssuedData
	
	  END

	  
 SELECT * into CollateralCurIssuedData  FROM(
 SELECT ROW_NUMBER() OVER(PARTITION BY A.CurSBLCissued  ORDER BY  A.CurSBLCissued ) 
 ROW ,CurSBLCissued FROM UploadCollateralDetail A
)X
 WHERE ROW=1


  SELECT  @SBLCCurIssued=COUNT(*) FROM CollateralCurIssuedData A
 Left JOIN DimCurrency B
 ON  A.CurSBLCissued=B.CurrencyName
 Where B.CurrencyName IS NULL


	 

 
 IF @SBLCCurIssued>0
 BEGIN
	 UPDATE UploadCollateralDetail
		SET  
			ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in column ‘Currency in which SBLC issued’. Kindly enter the values as mentioned in the ‘Currency’ master and upload again. Click on ‘Download Master value’ to download the valid valu

es for the column'     
							ELSE ErrorMessage+','+SPACE(1)+'Invalid value in column ‘Currency in which SBLC issued’. Kindly enter the values as mentioned in the ‘Currency’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'  

 END
			,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Currency in Which SBLC Issued' ELSE   ErrorinColumn +','+SPACE(1)+'Currency in Which SBLC Issued' END       
			,Srnooferroneousrows=V.SrNo

   
	  FROM UploadCollateralDetail V  
	 WHERE ISNULL(CurSBLCissued,'')<>''
	 AND V.CurSBLCissued IN(SELECT  A.CurSBLCissued   FROM CollateralCurIssuedData A
	 Left JOIN DimCurrency B
	 ON  A.CurSBLCissued=B.CurrencyName
	 Where B.CurrencyName IS NULL)
 END

 --UPDATE UploadCollateralDetail
	--SET  
 -- ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Currency in Which SBLC Issued cannot be blank . Please check the values and upload again.'     
	--					ELSE ErrorMessage+','+SPACE(1)+'Currency in Which SBLC Issued cannot be blank . Please check the values and upload again.'     END
	--	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Currency in Which SBLC Issued ' ELSE   ErrorinColumn +','+SPACE(1)+'Currency in Which SBLC Issued ' END  
	--	,Srnooferroneousrows=V.SrNo
								
   
 --  FROM UploadCollateralDetail V  
 --WHERE ISNULL(CurSBLCissued,'')=''

 UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Column ‘SBLC Number’ cannot be blank when ‘Sub Type of Collateral is ‘SBLC/BG'     
						ELSE ErrorMessage+','+SPACE(1)+'Column ‘SBLC Number’ cannot be blank when ‘Sub Type of Collateral is ‘SBLC'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Currency in Which SBLC Issued' ELSE   ErrorinColumn +','+SPACE(1)+'SBLC Currency in Which SBLC Issued' END       
		,Srnooferroneousrows=V.SrNo

   --Select CollateralSubType,CurSBLCissued,* from UploadCollateralDetail
  FROM UploadCollateralDetail V  
 WHERE ISNULL(CollateralSubType,'')  in('SBLC/BG') AND  ISNULL(CurSBLCissued,'')=''

 UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Column ‘SBLC Number’ cannot be blank when ‘Sub Type of Collateral is ‘SBLC/BG'     
						ELSE ErrorMessage+','+SPACE(1)+'Column ‘SBLC Number’ cannot be blank when ‘Sub Type of Collateral is ‘SBLC'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Currency in Which SBLC Issued' ELSE   ErrorinColumn +','+SPACE(1)+'Currency in Which SBLC Issued' END       
		,Srnooferroneousrows=V.SrNo

   
  FROM UploadCollateralDetail V  
 WHERE ISNULL(CollateralSubType,'') NOT in('SBLC/BG') AND  ISNULL(CurSBLCissued,'')<>''

 

 UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Column ‘SBLC Number’ must be blank when ‘Sub Type of Collateral is other than ‘SBLC/BG'     
						ELSE ErrorMessage+','+SPACE(1)+'Column ‘SBLC Number’ must be blank when ‘Sub Type of Collateral is other than ‘SBLC'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Currency in Which SBLC Issued' ELSE   ErrorinColumn +','+SPACE(1)+'Currency in Which SBLC Issued' END       
		,Srnooferroneousrows=V.SrNo

   
  FROM UploadCollateralDetail V  
 WHERE ISNULL(CollateralSubType,'') NOT in('SBLC/BG') AND  ISNULL(SBLCNumber,'')<>''
 
 
	 ---------------------------------------------------
	 
	 	 	 	 ---------------------------------------------------

	 /*validations on  SBLC in FCY    */
    
	

	

	-- UPDATE UploadCollateralDetail
	--SET  
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'SBLC in FCY cannot be blank or grtater than 25 Character. Please check the values and upload again.'     
	--					ELSE ErrorMessage+','+SPACE(1)+'SBLC in FCY Issued cannot be blank or grtater than 25 Character. Please check the values and upload again.'     END
	--	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SBLC in FCY ' ELSE   ErrorinColumn +','+SPACE(1)+'SBLC in FCY ' END   
	--	,Srnooferroneousrows=V.SrNo
								
   
 --  FROM UploadCollateralDetail V  
 --WHERE ISNULL(SBLCFCY,'')=''

 
UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in column ‘SBLC in FCY’. Kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid value in column ‘SBLC in FCY’. Kindly check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SBLC in FCY' ELSE   ErrorinColumn +','+SPACE(1)+'SBLC in FCY' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadCollateralDetail V  
  WHERE (ISNUMERIC(SBLCFCY)=0 AND ISNULL(SBLCFCY,'')<>'') OR 
 ISNUMERIC(SBLCFCY) LIKE '%^[0-9]%'




 UPDATE UploadCollateralDetail
	SET  
ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Column ‘SBLC in FCY’ cannot be blank when ‘Sub Type of Collateral is ‘SBLC'     
						ELSE ErrorMessage+','+SPACE(1)+'Column ‘SBLC in FCY’ cannot be blank when ‘Sub Type of Collateral is ‘SBLC'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SBLC in FCY' ELSE   ErrorinColumn +','+SPACE(1)+'SBLC in FCY' END       
		,Srnooferroneousrows=V.SrNo

   
  FROM UploadCollateralDetail V  
 WHERE ISNULL(CollateralSubType,'')  in('SBLC/BG') AND  ISNULL(SBLCFCY,'')=''

 UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Column ‘SBLC Number’ cannot be blank when ‘Sub Type of Collateral is ‘SBLC'     
						ELSE ErrorMessage+','+SPACE(1)+'Column ‘SBLC Number’ cannot be blank when ‘Sub Type of Collateral is ‘SBLC'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SBLC in FCY' ELSE   ErrorinColumn +','+SPACE(1)+'SBLC in FCY' END       
		,Srnooferroneousrows=V.SrNo

   
  FROM UploadCollateralDetail V  
 WHERE ISNULL(CollateralSubType,'') NOT in('SBLC/BG') AND  ISNULL(SBLCFCY,'')<>''

 


 
 
	 ---------------------------------------------------

	  	 ---------------------------------------------------

	 /*validations on  Date of expiry for SBLC    */
    
	

	

	-- UPDATE UploadCollateralDetail
	--SET  
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Date of expiry for SBLC cannot be blank or grtater than 25 Character. Please check the values and upload again.'     
	--					ELSE ErrorMessage+','+SPACE(1)+'Date of expiry for SBLC Issued cannot be blank or grtater than 25 Character. Please check the values and upload again.'     END
	--	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Date of expiry for SBLC ' ELSE   ErrorinColumn +','+SPACE(1)+'Date of expiry for SBLC ' END   
	--	,Srnooferroneousrows=V.SrNo
								
   
 --  FROM UploadCollateralDetail V  
 --WHERE ISNULL(DtexpirySBLC,'')=''
  SET dateformat DMY
--UPDATE UploadCollateralDetail
--	SET  
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in column ‘Date of expiry for SBLC’. Kindly check and upload again'     
--						ELSE ErrorMessage+','+SPACE(1)+'Invalid value in column ‘Date of expiry for SBLC’. Kindly check and upload again'     END
--		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Date of expiry for SBLC' ELSE   ErrorinColumn +','+SPACE(1)+'Date of expiry for SBLC' END       
--		,Srnooferroneousrows=V.SrNo

   
--  FROM UploadCollateralDetail V  
--  WHERE (Case  When ISDATE(DtexpirySBLC)=0 Then 2
--  When ISDATE(DtexpirySBLC)=1 AND Convert(date,DtexpirySBLC)>Convert(date,Getdate())     Then 1
       --Else 0 END)=0
 
  --WHERE (Case  When  Convert(Varchar(10),DtexpirySBLC,121)<=Convert(Varchar(10),Getdate(),121)      Then 1
  --     Else 0 END)=1


 UPDATE UploadCollateralDetail 
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Date of expiry for SBLC’ must be in ddmmyyyy format. Kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Date of expiry for SBLC must be in ddmmyyyy format. Kindly check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Date of expiry for SBLC' ELSE   ErrorinColumn +','+SPACE(1)+'Date of expiry for SBLC' END       
		,Srnooferroneousrows=V.SrNo

   
  FROM UploadCollateralDetail V  
  WHERE ISDATE(DtexpirySBLC)=0 AND ISNULL(DtexpirySBLC,'')<>''

 

  UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Column ‘Date of expiry for SBLC’ cannot be blank when ‘Sub Type of Collateral is ‘SBLC/BG'     
						ELSE ErrorMessage+','+SPACE(1)+'Column ‘Date of expiry for SBLC’ cannot be blank when ‘Sub Type of Collateral is ‘SBLC'   END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Date of expiry for SBLC' ELSE   ErrorinColumn +','+SPACE(1)+'Date of expiry for SBLCt' END       
		,Srnooferroneousrows=V.SrNo

   
  FROM UploadCollateralDetail V  
 WHERE ISNULL(CollateralSubType,'')  in('SBLC/BG') AND  ISNULL(DtexpirySBLC,'')=''

 
  UPDATE UploadCollateralDetail
	SET  
   ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Column ‘Date of expiry for SBLC’ must be blank when ‘Sub Type of Collateral is other than ‘SBLC/BG'     
						ELSE ErrorMessage+','+SPACE(1)+'Column ‘Date of expiry for SBLC’ must be blank when ‘Sub Type of Collateral is other than ‘SBLC'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Date of expiry for SBLC' ELSE   ErrorinColumn +','+SPACE(1)+'Date of expiry for SBLCt' END       
		,Srnooferroneousrows=V.SrNo

   
  FROM UploadCollateralDetail V  
 WHERE ISNULL(CollateralSubType,'')NOT  in('SBLC/BG') AND  ISNULL(DtexpirySBLC,'')<>''

 


 
 
	 ---------------------------------------------------

	  ---------------------------------------------------

	 /*validations on Date of expiry for LIC	   */
    
	

	

	-- UPDATE UploadCollateralDetail
	--SET  
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Date of expiry for SBLC cannot be blank . Please check the values and upload again.'     
	--					ELSE ErrorMessage+','+SPACE(1)+'Date of expiry for SBLC Issued cannot be blank  Please check the values and upload again.'     END
	--	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Date of expiry for LIC	 ' ELSE   ErrorinColumn +','+SPACE(1)+'Date of expiry for LIC	 ' END   
	--	,Srnooferroneousrows=V.SrNo
								
   
 --  FROM UploadCollateralDetail V  
 --WHERE ISNULL(DtexpiryLIC,'')=''
  SET dateformat DMY
--UPDATE UploadCollateralDetail
--	SET  
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in column ‘Date of expiry for LIC’. Kindly check and upload again'     
--						ELSE ErrorMessage+','+SPACE(1)+'Invalid value in column ‘Date of expiry for LIC’. Kindly check and upload againn'     END
--		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Date of expiry for LIC' ELSE   ErrorinColumn +','+SPACE(1)+'Date of expiry for LIC' END       
--		,Srnooferroneousrows=V.SrNo

   
--  FROM UploadCollateralDetail V 
--   WHERE (Case  When ISDATE(DtexpiryLIC)=0 Then 2
--   When ISDATE(DtexpiryLIC)=1 AND Convert(date,DtexpiryLIC)>Convert(date,Getdate())     Then 1
--       Else 0 END)=0





 UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN '’Date of expiry for LIC’ must be in ddmmyyyy format. Kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'’Date of expiry for LIC’ must be in ddmmyyyy format. Kindly check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Date of expiry for LIC' ELSE   ErrorinColumn +','+SPACE(1)+'Date of expiry for LIC' END       
		,Srnooferroneousrows=V.SrNo

   
  FROM UploadCollateralDetail V  
 WHERE   ISDATE(DtexpiryLIC)=0 AND ISNULL(DtexpiryLIC,'')<>''

 

  UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Column ‘Date of expiry for LIC’ cannot be blank when ‘Sub Type of Collateral is ‘LIC'     
						ELSE ErrorMessage+','+SPACE(1)+'Column ‘Date of expiry for LIC’ cannot be blank when ‘Sub Type of Collateral is ‘LIC'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Date of expiry for LIC' ELSE   ErrorinColumn +','+SPACE(1)+'Date of expiry for LIC' END       
		,Srnooferroneousrows=V.SrNo

   
  FROM UploadCollateralDetail V  
 WHERE ISNULL(CollateralSubType,'')  in('LIC') AND  ISNULL(DtexpiryLIC,'')=''

 
  UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Column ‘Date of expiry for LIC’ must be blank when ‘Sub Type of Collateral is other than ‘LIC'     
						ELSE ErrorMessage+','+SPACE(1)+'Column ‘Date of expiry for LIC’ must be blank when ‘Sub Type of Collateral is other than ‘LIC'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Date of expiry for LIC' ELSE   ErrorinColumn +','+SPACE(1)+'Date of expiry for LIC' END  
		,Srnooferroneousrows=V.SrNo

   
  FROM UploadCollateralDetail V  
 WHERE ISNULL(CollateralSubType,'')NOT  in('LIC') AND  ISNULL(DtexpiryLIC,'')<>''

 


 

	 ---------------------------------------------------



	 
	  ---------------------------------------------------

	 /*validations on Mode of Operation	   */
   
	

	

	 UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Mode of Operation cannot be blank . Please check the values and upload again.'     
						ELSE ErrorMessage+','+SPACE(1)+'Mode of Operationd cannot be blank  Please check the values and upload again.'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Mode of Operation	 ' ELSE   ErrorinColumn +','+SPACE(1)+'Mode of Operation	 ' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadCollateralDetail V  
 WHERE ISNULL(ModeOperation,'')=''

UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in column ‘Mode of Operation’. Kindly enter ‘Release or Delete’ ‘ADD or MODIFY’ and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid value in column ‘Mode of Operation’. Kindly enter ‘Release or Delete’ ‘ADD or MODIFY’ and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Mode of Operation	' ELSE   ErrorinColumn +','+SPACE(1)+'Mode of Operation	' END       
		,Srnooferroneousrows=V.SrNo

   
  FROM UploadCollateralDetail V  
WHERE ISNULL(ModeOperation,'') NOT IN('Release','Delete','ADD','MODIFY')

 
	 ---------------------------------------------------

	 


	 
	  ---------------------------------------------------

	 /*validations on Exceptional Approval		   */
    
	
	UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Exceptional Approval cannot be blank . Please check the values and upload again.'     
						ELSE ErrorMessage+','+SPACE(1)+'Exceptional Approval cannot be blank  Please check the values and upload again.'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Exceptional Approval	 ' ELSE   ErrorinColumn +','+SPACE(1)+'Exceptional Approval	' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadCollateralDetail V  
 WHERE ISNULL(ExceApproval,'')=''
	

	 UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN ' Exceptional Approval can not  greater than 25 Character. Please check the values and upload again.'     
						ELSE ErrorMessage+','+SPACE(1)+'Exceptional Approval can not  greater than 25 Character. Please check the values and upload again.'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Exceptional Approval	 ' ELSE   ErrorinColumn +','+SPACE(1)+'Exceptional Approval	 ' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadCollateralDetail V  
 WHERE  Len(ISNULL(ExceApproval,''))>25


UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in column ‘Exceptional Approval’. Kindly enter ‘Yes’ or ‘No’ '     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid value in column ‘Exceptional Approval’. Kindly enter ‘Yes’ or ‘No’ '     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Exceptional Approval	' ELSE   ErrorinColumn +','+SPACE(1)+'Exceptional Approval	' END       
		,Srnooferroneousrows=V.SrNo

   
  FROM UploadCollateralDetail V  
WHERE ISNULL(ExceApproval,'') NOT IN('Yes','No')

 
	 ---------------------------------------------------

	 
	 
	  ---------------------------------------------------


 
  ---------------------------------------------------

	 /*validations on ValuationSource/Expiry Business Rule		   */

	 UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Expiry Business Rule cannot be blank . Please check the values and upload again.'     
						ELSE ErrorMessage+','+SPACE(1)+'Expiry Business Rule cannot be blank . Please check the values and upload again.'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Expiry Business Rule ' ELSE   ErrorinColumn +','+SPACE(1)+'Expiry Business Rule' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadCollateralDetail V  
 WHERE ISNULL(ValSource_ExpBusinessRule,'')=''


	 Declare @ValuationCnt Int=0
 IF OBJECT_ID('ValuationSourceData') IS NOT NULL  
	  BEGIN  
	   DROP TABLE ValuationSourceData  
	
	  END

	  
 SELECT * into ValuationSourceData  FROM(
 SELECT ROW_NUMBER() OVER(PARTITION BY A.ValSource_ExpBusinessRule  ORDER BY  A.ValSource_ExpBusinessRule ) 
 ROW ,A.ValSource_ExpBusinessRule,B.SecuritySubTypeAlt_Key,C.CollateralSubTypeDescription FROM UploadCollateralDetail A
 LEFT JOIN DimValueExpiration B ON A.ValSource_ExpBusinessRule=B.Documents
 LEFT  JOIN DimCollateralSubType C ON A.CollateralSubType= C.CollateralSubTypeDescription
 Where B.SecuritySubTypeAlt_Key=C.CollateralSubTypeAltKey
  
 
 )X
 WHERE ROW=1

 

  SELECT  @ValuationCnt=COUNT(*) FROM ValuationSourceData A
 
 --Where A.CollateralSubTypeDescription IS NULL

 PRINT '@ValuationCnt'
 PRINT @ValuationCnt

--UPDATE UploadCollateralDetail
--	SET  
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'ValuationSource/Expiry Business Rule cannot be blank . Please check the values and upload again'     
--						ELSE ErrorMessage+','+SPACE(1)+'ValuationSource/Expiry Business Rule cannot be blank . Please check the values and upload again'     END
--		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'ValuationSource/Expiry Business Rule' ELSE   ErrorinColumn +','+SPACE(1)+'ValuationSource/Expiry Business Rule' END   
--		,Srnooferroneousrows=V.SrNo
								
   
--   FROM UploadCollateralDetail V  
-- WHERE ISNULL(ValSource_ExpBusinessRule,'')=''


IF @ValuationCnt=0

BEGIN

 PRINT 'Sachin'
   UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Entered ‘Basis of Valuation Source’ is not applicable for the entered ‘Sub type of Collateral’. Kindly enter the values as mentioned in the ‘Valuation Source’ master & it’s ‘Sub Type of Coll





a
teral’ and upload again. Click on ‘Download Master value’ to download the valid values for the column'     
						ELSE ErrorMessage+','+SPACE(1)+'Entered ‘Basis of Valuation Source’ is not applicable for the entered ‘Sub type of Collateral’. Kindly enter the values as mentioned in the ‘Valuation Source’ master & it’s ‘Sub Type of Collateral’ and upload again. C




lick on ‘Download Master value’ to download the valid values for the column'  END   
						--ELSE ErrorMessage+','+SPACE(1)+ 'Different PoolID of same combination of PoolName and PoolType is Available. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'ValuationSource/Expiry Business Rule' ELSE   ErrorinColumn +','+SPACE(1)+'ValuationSource/Expiry Business Rule' END     
		,Srnooferroneousrows=V.SrNo
 

 FROM UploadCollateralDetail V  
 WHERE ISNULL(ValSource_ExpBusinessRule,'')<>''
 --AND  V.ValSource_ExpBusinessRule IN(
	--			SELECT  A.ValSource_ExpBusinessRule FROM ValuationSourceData A
				 
	--			 Where A.CollateralSubTypeDescription IS NULL
	--			 )
 END 

 ---------------------------------------------------

   ---------------------------------------------------

	 /*validations on Date of Valuation		   */
    
	Set DateFormat DMY
	 UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Date of Valuation must be in ddmmyyyy format. Kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Date of Valuation must be in ddmmyyyy format. Kindly check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Date of Valuation' ELSE   ErrorinColumn +','+SPACE(1)+'Date of Valuation' END       
		,Srnooferroneousrows=V.SrNo

   
  FROM UploadCollateralDetail V  
WHERE  
  ISDATE(DtofValuation)=0 AND ISNULL(DtofValuation,'')<>'' 
  --AND ISNULL(CollateralSubType,'') NOT in('Corporate Guarantee','Personal Guarantee')
	

	 UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Date of Valuation cannot be blank . Please check the values and upload again.'     
						ELSE ErrorMessage+','+SPACE(1)+'Date of Valuation cannot be blank . Please check the values and upload again.'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Date of Valuation ' ELSE   ErrorinColumn +','+SPACE(1)+'Date of Valuation		 ' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadCollateralDetail V  
 WHERE ISNULL(DtofValuation,'')='' 
 --AND ISNULL(CollateralSubType,'') NOT in('Corporate Guarantee','Personal Guarantee')


UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Valuation date must be less than equal to Current Date. Kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Valuation date must be less than equal to Current Date. Kindly check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Date of Valuation' ELSE   ErrorinColumn +','+SPACE(1)+'Date 
of Valuation	' END       
		,Srnooferroneousrows=V.SrNo


  FROM UploadCollateralDetail V  
WHERE (Case When ISDATE(DtofValuation)=0 Then 2
  When ISDATE(DtofValuation)=1 AND Convert(date,DtofValuation)<=Convert(date,Getdate())     Then 1
       Else 0 END)=0 
	   
	   --AND ISNULL(CollateralSubType,'') NOT in('Corporate Guarantee','Personal Guarantee')



	    ---------------------------------------------------


		---------------------------------------------------

	 /*validations on Value to be considered		   */
    
	

	

	 UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Value to be considered cannot be blank . Please check the values and upload again.'     
						ELSE ErrorMessage+','+SPACE(1)+'Value to be considered cannot be blank . Please check the values and upload again.'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Value to be considered ' ELSE   ErrorinColumn +','+SPACE(1)+'Value to be considered ' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadCollateralDetail V  
 WHERE ISNULL(ValueConsidered,'')='' 
 --AND ISNULL(CollateralSubType,'') NOT in('Corporate Guarantee','Personal Guarantee')


UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid values in ‘Value to be considered’. Kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid values in ‘Value to be considered’. Kindly check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Value to be considered' ELSE   ErrorinColumn +','+SPACE(1)+'Value to be considered	' END       
		,Srnooferroneousrows=V.SrNo

   
  FROM UploadCollateralDetail V  
 WHERE (ISNUMERIC(ValueConsidered)=0 AND ISNULL(ValueConsidered,'')<>'') OR 
 ISNUMERIC(ValueConsidered) LIKE '%^[0-9]%' 
 
 --AND ISNULL(CollateralSubType,'') NOT in('Corporate Guarantee','Personal Guarantee')


 UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Valuation Amount is 50 CR, Please enter second amount and Date. Kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Valuation Amount is 50 CR, Please enter second amount and Date. Kindly check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Date of Valuation' ELSE   ErrorinColumn +','+SPACE(1)+'Date of Valuation' END       
		,Srnooferroneousrows=V.SrNo

   
  FROM UploadCollateralDetail V  
WHERE  
(Case WHen ValueConsidered='' Then 0 ELSE  Convert(Decimal(16,2),ISNULL(ValueConsidered,'0')) END)>500000000 AND ISNULL(SecondDtofValuation,'')='' AND ISNULL(SecondValuation,'')=''
AND ISNULL(CollateralSubType,'')  in('Immovable Fixed assets')
	    ---------------------------------------------------

		---------------------------------------------------

	 /*validations on Second Valuation Date		   */
    
	

	

	-- UPDATE UploadCollateralDetail
	--SET  
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Second Valuation Date cannot be blank . Please check the values and upload again.'     
	--					ELSE ErrorMessage+','+SPACE(1)+'Second Valuation Date cannot be blank . Please check the values and upload again.'     END
	--	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Second Valuation Date ' ELSE   ErrorinColumn +','+SPACE(1)+'Second Valuation Date ' END   
	--	,Srnooferroneousrows=V.SrNo
								
   
 --  FROM UploadCollateralDetail V  
 --WHERE ISNULL(SecondDtofValuation,'')='' 

  SET dateformat DMY
 UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Second Valuation date must be in ddmmyyyy format. Kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Second Valuation date must be in ddmmyyyy format. Kindly check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Second Valuation Date' ELSE   ErrorinColumn +','+SPACE(1)+'Second Valuation Date' END       
		,Srnooferroneousrows=V.SrNo

   
  FROM UploadCollateralDetail V  
 WHERE ISDATE(SecondDtofValuation)=0 AND ISNULL(SecondDtofValuation,'')<>''

UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Second Valuation date must be less than equal to Current Date. Kindly check and upload again'   
						ELSE ErrorMessage+','+SPACE(1)+'Second Valuation date must be less than equal to Current Date. Kindly check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Second Valuation Date ' ELSE   ErrorinColumn +','+SPACE(1)+'Second Valuation Date 	' END       
		,Srnooferroneousrows=V.SrNo

   
  FROM UploadCollateralDetail V  
WHERE (Case When ISDATE(SecondDtofValuation)=0 Then 2
When ISDATE(SecondDtofValuation)=1 AND Convert(date,SecondDtofValuation)<=Convert(date,Getdate())     Then 1
       Else 0 END)=0

	

	   
	   UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Column ‘Second Valuation Date’ must be blank when ‘Sub Type of Collateral is other than ‘‘ImmovableFixedAssets'     
						ELSE ErrorMessage+','+SPACE(1)+'Column ‘Second Valuation Date’ must be blank when ‘Sub Type of Collateral is other than ‘‘ImmovableFixedAssets'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Second Valuation Date ' ELSE   ErrorinColumn +','+SPACE(1)+'Second Valuation Date 	' END       
		,Srnooferroneousrows=V.SrNo

   
  FROM UploadCollateralDetail V  
WHERE ISNULL(CollateralSubType,'') NOT in('Immovable Fixed assets') AND ISNULL(SecondDtofValuation,'')<>''

	    ---------------------------------------------------

		
		---------------------------------------------------

	 /*validations on Second Valuation Amount		   */
    
	

	

	-- UPDATE UploadCollateralDetail
	--SET  
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Second Valuation Amount cannot be blank . Please check the values and upload again.'     
	--					ELSE ErrorMessage+','+SPACE(1)+'Second Valuation Amount cannot be blank . Please check the values and upload again.'     END
	--	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Second Valuation Amount ' ELSE   ErrorinColumn +','+SPACE(1)+'Second Valuation Amounte ' END   
	--	,Srnooferroneousrows=V.SrNo
								
   
 --  FROM UploadCollateralDetail V  
 --WHERE ISNULL(SecondValuation,'')='' 


UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid values in ‘Second Valuation Amount’. Kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid values in ‘Second Valuation Amount’. Kindly check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Second Valuation Amount	 ' ELSE   ErrorinColumn +','+SPACE(1)+'Second Valuation Amount		' END       
		,Srnooferroneousrows=V.SrNo

   
  FROM UploadCollateralDetail V  
WHERE (ISNUMERIC(SecondValuation)=0 AND ISNULL(SecondValuation,'')<>'') OR 
 ISNUMERIC(SecondValuation) LIKE '%^[0-9]%'

	 

	   
	   UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Column ‘Second Valuation Amount’ must be blank when ‘Sub Type of Collateral is other than ‘‘ImmovableFixedAssets'     
						ELSE ErrorMessage+','+SPACE(1)+'Column ‘Second Valuation Amount’ must be blank when ‘Sub Type of Collateral is other than ‘‘ImmovableFixedAssets'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Second Valuation Date ' ELSE   ErrorinColumn +','+SPACE(1)+'Second Valuation Date 	' END       
		,Srnooferroneousrows=V.SrNo

   
  FROM UploadCollateralDetail V  
WHERE ISNULL(CollateralSubType,'') NOT in('Immovable Fixed assets') AND ISNULL(SecondValuation,'')<>''

	    ---------------------------------------------------
 ---------------------------------------------------
 Print '123'
 goto valid

  END
	
   ErrorData:  
   print 'no'  

		SELECT *,'Data'TableName
		FROM dbo.MasterUploadData WHERE FileNames=@filepath 
		return

   valid:
		IF NOT EXISTS(Select 1 from  CollateralDetail_stg WHERE sheetname=@FilePathUpload)
		BEGIN
		PRINT 'NO ERRORS'
			
			Insert into dbo.MasterUploadData
			(SR_No,ColumnName,ErrorData,ErrorType,FileNames,Flag) 
			SELECT '' SRNO , '' ColumnName,'' ErrorData,'' ErrorType,@filepath,'SUCCESS' 
			
		END
		ELSE
		BEGIN
			PRINT 'VALIDATION ERRORS'
			PRINT '@filepath'
			PRINT @filepath
			Insert into dbo.MasterUploadData
			(SR_No,ColumnName,ErrorData,ErrorType,FileNames,Srnooferroneousrows,Flag) 
			SELECT SrNo,ErrorinColumn,ErrorMessage,ErrorinColumn,@filepath,Srnooferroneousrows,'SUCCESS' 
			FROM UploadCollateralDetail 

			print 'Row Effected'

			print @@ROWCOUNT
			
		--	----SELECT * FROM UploadCollateralDetail 

		--	--ORDER BY ErrorMessage,UploadCollateralDetail.ErrorinColumn DESC
			goto final
		END

		

  IF EXISTS (SELECT 1 FROM  dbo.MasterUploadData   WHERE FileNames=@filepath AND  ISNULL(ERRORDATA,'')<>'') 
   -- added for delete Upload status while error while uploading data.  
   BEGIN  
   --SELECT * FROM #OAOLdbo.MasterUploadData
    delete from UploadStatus where FileNames=@filepath  
   END  
  --ELSE IF EXISTS (SELECT 1 FROM  UploadStatus where ISNULL(InsertionOfData,'')='' and FileNames=@filepath and UploadedBy=@UserLoginId)  -- added validated condition successfully, delete filename from Upload status  
  --  BEGIN  
  --  print 'RC'  
  --   delete from UploadStatus where FileNames=@filepath  
  --  END    --commented in [OAProvision].[GetStatusOfUpload] SP for checkin 'InsertionOfData' Flag  
  ELSE  
   BEGIN   
  
    Update UploadStatus Set ValidationOfData='Y',ValidationOfDataCompletedOn=GetDate()   
    where FileNames=@filepath  
  
   END  


  final:
IF EXISTS(SELECT 1 FROM dbo.MasterUploadData WHERE FileNames=@filepath AND ISNULL(ERRORDATA,'')<>''
		) 
	BEGIN
	PRINT 'ERROR'
		SELECT SR_No
				,ColumnName
				,ErrorData
				,ErrorType
				,FileNames
				,Flag
				,Srnooferroneousrows,'Validation'TableName
		FROM dbo.MasterUploadData
		WHERE FileNames=@filepath
		--(SELECT *,ROW_NUMBER() OVER(PARTITION BY ColumnName,ErrorData,ErrorType,FileNames ORDER BY ColumnName,ErrorData,ErrorType,FileNames )AS ROW 
		--FROM  dbo.MasterUploadData    )a 
		--WHERE A.ROW=1
		--AND FileNames=@filepath
		--AND ISNULL(ERRORDATA,'')<>''
	
		ORDER BY CONVERT(INT,SR_No)

		 IF EXISTS(SELECT 1 FROM CollateralDetail_stg WHERE sheetname=@FilePathUpload)
		 BEGIN
		 Print '1'
		 DELETE FROM CollateralDetail_stg
		 WHERE sheetname=@FilePathUpload

		 DELETE FROM CollateralDetails_stg
		 WHERE filname=@FilePathUpload

		 PRINT '2';

		 PRINT 'ROWS DELETED FROM DBO.CollateralDetail_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
		 END

	END
	ELSE
	BEGIN
	PRINT ' DATA NOT PRESENT'
		--SELECT *,'Data'TableName
		--FROM dbo.MasterUploadData WHERE FileNames=@filepath 
		--ORDER BY ErrorData DESC
		SELECT SR_No,ColumnName,ErrorData,ErrorType,FileNames,Flag,Srnooferroneousrows,'Data'TableName 
		FROM
		(
			SELECT *,ROW_NUMBER() OVER(PARTITION BY ColumnName,ErrorData,ErrorType,FileNames,Flag,Srnooferroneousrows
			ORDER BY ColumnName,ErrorData,ErrorType,FileNames,Flag,Srnooferroneousrows)AS ROW 
			FROM  dbo.MasterUploadData    
		)a 
		WHERE A.ROW=1
		AND FileNames=@filepath

	END

	----SELECT * FROM UploadCollateralDetail

	print 'p'
------to delete file if it has errors
		--if exists(Select  1 from dbo.MasterUploadData where FileNames=@filepath and ISNULL(ErrorData,'')<>'')
		--begin
		--print 'ppp'
		-- IF EXISTS(SELECT 1 FROM IBPCPoolDetail_stg WHERE filname=@FilePathUpload)
		-- BEGIN
		-- print '123'
		-- DELETE FROM IBPCPoolDetail_stg
		-- WHERE filname=@FilePathUpload

		-- PRINT 'ROWS DELETED FROM DBO.IBPCPoolDetail_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
		-- END
		-- END

   
END  TRY 
  
  BEGIN CATCH  
	

	INSERT INTO dbo.Error_Log
				SELECT ERROR_LINE() as ErrorLine,ERROR_MESSAGE()ErrorMessage,ERROR_NUMBER()ErrorNumber
				,ERROR_PROCEDURE()ErrorProcedure,ERROR_SEVERITY()ErrorSeverity,ERROR_STATE()ErrorState
				,GETDATE()

	--IF EXISTS(SELECT 1 FROM IBPCPoolDetail_stg WHERE filname=@FilePathUpload)
	--	 BEGIN
	--	 DELETE FROM IBPCPoolDetail_stg
	--	 WHERE filname=@FilePathUpload

	--	 PRINT 'ROWS DELETED FROM DBO.IBPCPoolDetail_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
	--	 END

END CATCH 

END


GO