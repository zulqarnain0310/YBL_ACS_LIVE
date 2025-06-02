SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
 
CREATE PROCEDURE [dbo].[LineCodeValidation]  
 @xmlDocument XML=''  
,@Timekey INT = 49999  
,@ScreenFlag VARCHAR(20)='LineCode'   
AS  
SET DATEFORMAT DMY  
 
--declare @todaydate date = (select StartDate from pro.EXTDATE_MISDB where TimeKey=@Timekey)  
  
IF @ScreenFlag = 'LineCode'  
BEGIN  
  IF OBJECT_ID('TEMPDB..##LineCodeData') IS NOT NULL  
    DROP TABLE ##LineCodeData  
  
SELECT   
ROW_NUMBER()OVER(ORDER BY (SELECT  (1))) RowNum  
,C.value('./SlNo [1]','VARCHAR(30)') SlNo  
,C.value('./SourceSystem [1]','VARCHAR(30)') SourceSystem   
,C.value('./CodeValue [1]','VARCHAR(50)') CodeValue       
,C.value('./CodeType [1]','VARCHAR(200)') CodeType  
,C.value('./CodeDescription [1]','VARCHAR(100)') CodeDescription  
--,C.value('./ROWNO [1]','VARCHAR(100)') ROWNO1  
,CAST(NULL AS VARCHAR(MAX))ERROR  
INTO ##LineCodeData  
FROM @XMLDocument.nodes('/DataSet/Gridrow') AS t(c)  
  
  --select '##LineCodeData',* from ##LineCodeData
  
Declare @Date Date  
  
SET @Date =(Select CAST(B.Date as Date)Date1 from SysDataMatrix A  
Inner Join SysDayMatrix B ON A.TimeKey=B.TimeKey  
 where A.CurrentStatus='C')  
 
 SET DATEFORMAT DMY  
  
  
   /*validations on SrNo*/
  
 Declare @DuplicateCnt int=0
   UPDATE V
	SET  
        ERROR=CASE WHEN ISNULL(ERROR,'')='' THEN 'SrNo cannot be blank . Please check the values and upload again'     
						ELSE ERROR+','+SPACE(1)+'SrNo cannot be blank . Please check the values and upload again'     END
		--,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END   
		--,Srnooferroneousrows=V.SrNo
								
   
   FROM ##LineCodeData V  
 WHERE ISNULL(v.SlNo,'')='' --or ISNULL(v.SrNo,0)< 0)
  


  UPDATE V
	SET  
        ERROR=CASE WHEN ISNULL(ERROR,'')='' THEN 'SrNo cannot be greater than 16 character . Please check the values and upload again'     
						ELSE ERROR+','+SPACE(1)+'SrNo cannot be greater than 16 character . Please check the values and upload again'     END
		--,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END   
		--,Srnooferroneousrows=V.SrNo
								
   
   FROM ##LineCodeData V  
 WHERE Len(SlNo)>16

  UPDATE V
	SET  
        ERROR=CASE WHEN ISNULL(ERROR,'')='' THEN 'Invalid Sl. No., kindly check and upload again'     
						ELSE ERROR+','+SPACE(1)+'Invalid Sl. No., kindly check and upload again'     END
		--,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END   
		--,Srnooferroneousrows=V.SrNo
								
   
   FROM ##LineCodeData V  
  WHERE --(ISNUMERIC(SrNo)=0 AND ISNULL(SrNo,'')<>'') OR 
 ISNUMERIC(SlNo) LIKE '%^[0-9]%'

 UPDATE V
	SET  
        ERROR=CASE WHEN ISNULL(ERROR,'')='' THEN 'Special characters not allowed, kindly remove and upload again'     
						ELSE ERROR+','+SPACE(1)+'Special characters not allowed, kindly remove and upload again'   END
		--,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END   
		--,Srnooferroneousrows=V.SrNo
								
   
   FROM ##LineCodeData V  
  -- WHERE ISNULL(SrNo,'') LIKE '%[,!@#$%^&*()_-+=/]%'
  WHERE ISNULL(SlNo,'') LIKE '%[^0-9a-zA-Z]%'
   --LIKE'%[,!@#$%^&*()_-+=/]%- \ / _%'
   --
  SELECT @DuplicateCnt=Count(1)
FROM ##LineCodeData
GROUP BY  SlNo
HAVING COUNT(SlNo) >1;

IF (@DuplicateCnt>0)

 UPDATE V
	SET  
        ERROR=CASE WHEN ISNULL(ERROR,'')='' THEN 'Duplicate Sl. No., kindly check and upload again'     
						ELSE ERROR+','+SPACE(1)+'Duplicate Sl. No., kindly check and upload again'     END
		--,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END   
		--,Srnooferroneousrows=V.SrNo
								
   
   FROM ##LineCodeData V  
   Where ISNULL(SlNo,'') In(  
   SELECT SlNo
	FROM ##LineCodeData
	GROUP BY  SlNo
	HAVING COUNT(SlNo) >1

)

  
/****************************************************************************************************************  
       
           FOR CHECKING A SOURCESYSTEM  
  
****************************************************************************************************************/  
    
  UPDATE A  
  SET ERROR = CASE WHEN ISNULL(ERROR,'')='' THEN 'SourceSystem should not be Empty. Please check the values and upload again'     
						ELSE ERROR+','+SPACE(1)+'SourceSystem should not be Empty. 
						Please check the values and upload again'     END 
	 --select *  
  FROM ##LineCodeData A  
  where isnull(A.SOURCESYSTEM,'')=''  
  
 
  UPDATE A  
  SET ERROR = CASE WHEN ISNULL(ERROR,'')='' THEN 'Invalid Source System. Please check the values and upload again'     
						ELSE ERROR+','+SPACE(1)+'Invalid Source System. Please check the values and upload again'     END 
						 
  
  FROM ##LineCodeData A  
  where isnull(A.SOURCESYSTEM,'') NOT IN  ('FCC','FCR','VisionPlus')  

  /****************************************************************************************************************  
         FOR CHECKING Source System & Code Type   
 ****************************************************************************************************************/  
  
  UPDATE A  
  
	 SET ERROR = CASE WHEN ISNULL(ERROR,'')='' THEN 'Code Type should not be Empty. Please check the values and upload again'     
						ELSE ERROR+','+SPACE(1)+'Code Type should not be Empty. 
						Please check the values and upload again'     END  
  FROM ##LineCodeData A  
   where isnull(A.SOURCESYSTEM,'') IN( 'FCC')  AND ISNULL(A.CODETYPE,'') NOT IN('CAM Renewal Code','Stock Statement Code')
  

  UPDATE A  
  
	 SET ERROR = CASE WHEN ISNULL(ERROR,'')='' THEN 'Code Type should not be Empty. Please check the values and upload again'     
						ELSE ERROR+','+SPACE(1)+'Code Type should not be Empty. 
						Please check the values and upload again'     END  
  FROM ##LineCodeData A  
   where isnull(A.SOURCESYSTEM,'') IN( 'FCR')  AND ISNULL(A.CODETYPE,'') NOT IN('CAM Renewal Code','Stock Statement Code','Product Code') 
  
  UPDATE A  
   
	 SET ERROR = CASE WHEN ISNULL(ERROR,'')='' THEN 'Invalid Code Type. Please check the values and upload again'     
						ELSE ERROR+','+SPACE(1)+'Invalid Code Type. 
						Please check the values and upload again'     END   
  
  FROM ##LineCodeData A  
  where isnull(A.SOURCESYSTEM,'') IN( 'VisionPlus') AND ISNULL(A.CODETYPE,'') NOT IN  ('Product Code') 
    
/****************************************************************************************************************  
         FOR CHECKING Code Type   
 ****************************************************************************************************************/  
  
  UPDATE A  
  
	 SET ERROR = CASE WHEN ISNULL(ERROR,'')='' THEN 'Code Type should not be Empty. Please check the values and upload again'     
						ELSE ERROR+','+SPACE(1)+'Code Type should not be Empty. 
						Please check the values and upload again'     END  
  FROM ##LineCodeData A  
  where isnull(A.CODETYPE,'')=''  
  
  
  UPDATE A  
   
	 SET ERROR = CASE WHEN ISNULL(ERROR,'')='' THEN 'Invalid Code Type. Please check the values and upload again'     
						ELSE ERROR+','+SPACE(1)+'Invalid Code Type. 
						Please check the values and upload again'     END   
  
  FROM ##LineCodeData A  
  where ISNULL(A.CODETYPE,'') NOT IN  ('CAM Renewal Code','Stock Statement Code','Product Code')  
  
/****************************************************************************************************************  
            FOR CHECKING Code value  
 ****************************************************************************************************************/  
   UPDATE A  

	 SET ERROR = CASE WHEN ISNULL(ERROR,'')='' THEN 'Code value should not be Empty. Please check the values and upload again'     
						ELSE ERROR+','+SPACE(1)+'Code value should not be Empty. 
						Please check the values and upload again'     END   
  FROM ##LineCodeData A  
  where ISNULL(A.CODEVALUE,'')=''  
   
  UPDATE A  
 
	 SET ERROR = CASE WHEN ISNULL(ERROR,'')='' THEN 'Code value Length should not be  greater then 20 Chararter. Please check the values and upload again'     
						ELSE ERROR+','+SPACE(1)+'Code value Length should not be  greater then 20 Chararter. 
						Please check the values and upload again'     END   
         FROM ##LineCodeData A  
  WHERE LEN(ISNULL(CODEVALUE,''))>20   
  
  
   UPDATE V
	SET  
        ERROR=CASE WHEN ISNULL(ERROR,'')='' THEN  'Invalid CODEVALUE. Please check the values and upload again'     
						ELSE ERROR+','+SPACE(1)+ 'Invalid CODEVALUE. Please check the values and upload again'     END
		  

 FROM ##LineCodeData V  
 WHERE ISNULL(CODEVALUE,'') LIKE'%[,!@#$%^&*()+=]%' 
 
  ----duplicate ReviewLineCode
  UPDATE V
	SET  
        ERROR=CASE WHEN ISNULL(ERROR,'')='' THEN  'CODEVALUE AlReady Exists. Please check the values and upload again'     
						ELSE ERROR+','+SPACE(1)+ 'CODEVALUE AlReady Exists. Please check the values and upload again'     END
		  

 FROM ##LineCodeData V  
 WHERE ISNULL(CODEVALUE,'')<>''
 and ISNULL(CODEVALUE,'') IN ( select ReviewLineCode from DimLineCodeReview
                              where EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey)

UPDATE V
	SET  
        ERROR=CASE WHEN ISNULL(ERROR,'')='' THEN  'Record for Code Value  is pending for authorization in ‘Upload ID’ '+ Convert(Varchar(10),B.UploadId) +' kindly remove the record and upload again'     
						ELSE ERROR+','+SPACE(1)+ 'Record for Code Value  is pending for authorization in ‘Upload ID’ '+ Convert(Varchar(10),B.UploadId) +' kindly remove the record and upload again '     END
		  

 FROM ##LineCodeData V  
 Left Join DimLineCodeReview_Mod B ON V.CodeValue=B.ReviewLineCode
 WHERE ISNULL(CODEVALUE,'')<>''
 AND 	B.AuthorisationStatus In('NP','MP','FM','RM','1A') 
 and (V.CodeValue is not NULL or B.ReviewLineCode is not NULL)
 
 

----DimLinecodeStockStatement_Mod
  UPDATE V
	SET  
        ERROR=CASE WHEN ISNULL(ERROR,'')='' THEN  'CODEVALUE AlReady Exists. Please check the values and upload again'     
						ELSE ERROR+','+SPACE(1)+ 'CODEVALUE AlReady Exists. Please check the values and upload again'     END
		  

 FROM ##LineCodeData V  
 WHERE ISNULL(CODEVALUE,'')<>''
 and ISNULL(CODEVALUE,'') IN ( select StockLineCode from DimLinecodeStockStatement
                              where EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey)


UPDATE V
	SET  
        ERROR=CASE WHEN ISNULL(ERROR,'')='' THEN  'Record for Code Value  is pending for authorization in ‘Upload ID’ '+ Convert(Varchar(10),B.UploadId) +' kindly remove the record and upload again'     
						ELSE ERROR+','+SPACE(1)+ 'Record for Code Value  is pending for authorization in ‘Upload ID’ '+ Convert(Varchar(10),B.UploadId) +' kindly remove the record and upload again '     END
		  

 FROM ##LineCodeData V  
 Left Join DimLinecodeStockStatement_Mod B ON V.CodeValue=B.StockLineCode
 WHERE ISNULL(CODEVALUE,'')<>''
 AND 	B.AuthorisationStatus In('NP','MP','FM','RM','1A') 
 and (V.CodeValue is not NULL or B.StockLineCode is not NULL)
 

----duplicate DimLineProductCodeReview							  
 UPDATE V
	SET  
        ERROR=CASE WHEN ISNULL(ERROR,'')='' THEN  'CODEVALUE AlReady Exists. Please check the values and upload again'     
						ELSE ERROR+','+SPACE(1)+ 'CODEVALUE AlReady Exists. Please check the values and upload again'     END
		  

 FROM ##LineCodeData V  
 WHERE ISNULL(CODEVALUE,'')<>''
 and ISNULL(CODEVALUE,'') IN ( select ReviewLineProductCode from DimLineProductCodeReview
                              where EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey)
							  
UPDATE V
	SET  
        ERROR=CASE WHEN ISNULL(ERROR,'')='' THEN  'Record for Code Value  is pending for authorization in ‘Upload ID’ '+ Convert(Varchar(10),B.UploadId) +' kindly remove the record and upload again'     
						ELSE ERROR+','+SPACE(1)+ 'Record for Code Value  is pending for authorization in ‘Upload ID’ '+ Convert(Varchar(10),B.UploadId) +' kindly remove the record and upload again '     END
		  

 FROM ##LineCodeData V  
 Left Join DimLineProductCodeReview_Mod B ON V.CodeValue=B.ReviewLineProductCode
 WHERE ISNULL(CODEVALUE,'')<>''
 AND 	B.AuthorisationStatus In('NP','MP','FM','RM','1A') 
 and (V.CodeValue is not NULL or B.ReviewLineProductCode is not NULL)
/*************************************************************************  
                          FOR Code Description   
***************************************************************************/    
  
  UPDATE A  
   
	 SET ERROR = CASE WHEN ISNULL(ERROR,'')='' THEN 'Code Descripton should not be Empty. Please check the values and upload again'     
						ELSE ERROR+','+SPACE(1)+'Code Descripton should not be Empty. 
						Please check the values and upload again'     END  
  FROM ##LineCodeData A  
  where ISNULL(A.CODEDESCRIPTION,'')=''  
  
  
  UPDATE A  
 
	 SET ERROR = CASE WHEN ISNULL(ERROR,'')='' THEN 'Code Descripton Length should not be  greater then 100 Chararter. Please check the values and upload again'     
						ELSE ERROR+','+SPACE(1)+'Code Descripton Length should not be  greater then 100 Chararter. 
						Please check the values and upload again'     END   
         FROM ##LineCodeData A  
  WHERE LEN(ISNULL(CODEDESCRIPTION,''))>100    

  
   UPDATE V
	SET  
        ERROR=CASE WHEN ISNULL(ERROR,'')='' THEN  'Invalid Code Descripton Please check the values and upload again'     
						ELSE ERROR+','+SPACE(1)+ 'Invalid Code Descripton. Please check the values and upload again'     END
		  

 FROM ##LineCodeData V  
 WHERE ISNULL(CODEDESCRIPTION,'') LIKE'%[,!@#$%^&*()+=]%' 
 
  
/**************************************************************************************************************  
            FOR OUTPUT  
  
****************************************************************************************************************/  
  
IF EXISTS(SELECT 1 FROM ##LineCodeData WHERE ISNULL(ERROR,'')<>'')  
 BEGIN  
  SELECT RowNum  
           ,SLNO  
     ,SOURCESYSTEM   
     ,CODETYPE  
     ,CODEVALUE  
     ,CODEDESCRIPTION  
     ,ERROR  
     ,'ErrorData' TableName  
  FROM ##LineCodeData  WHERE ISNULL(ERROR,'')<>''  
 END  
ELSE  
  BEGIN  
    SELECT RowNum  
    ,SLNO  
    ,SOURCESYSTEM   
    ,CODETYPE  
    ,CODEVALUE  
    ,CODEDESCRIPTION  
    ,'LinecodeData' TableName  
    ,Error  
    FROM ##LineCodeData   
  END  
  DROP TABLE ##LineCodeData  
 END  
  
GO