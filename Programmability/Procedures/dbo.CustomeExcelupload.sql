SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create Procedure [dbo].[CustomeExcelupload]
(
@UserLoginId varchar(20),
@filepath varchar(600)

)
As
Begin

IF OBJECT_ID('TEMPDB..#Customer') IS NOT NULL
				DROP TABLE #Customer

		--SELECT 
		--ROW_NUMBER()OVER(ORDER BY (SELECT  (1))) RowNum
		 
		--,C.value('./CUSTOMERID			[1]','VARCHAR(50)')CUSTOMERID  
		--,C.value('./ASSETCLASSIFICATION	[1]','VARCHAR(30)')AssetClassification
		--,C.value('./NPADATE				[1]','VARCHAR(30)')NPADate
		--,C.value('./SECURITYVALUE		[1]','VARCHAR(30)')SecurityValue
		--,CASE WHEN C.value('./ADDITIONALPROVISION	[1]','VARCHAR(30)')= '' THEN NULL ELSE C.value('./ADDITIONALPROVISION	[1]','DECIMAL(18,2)') END AdditionalProvision 
		--,C.value('./MOCTYPE			[1]','VARCHAR(15)')MOCTYPE
		--,C.value('./MOCREASON			[1]','VARCHAR(500)')MOCReason
		--,CAST(NULL AS VARCHAR(MAX))ERROR
		--,CASE WHEN C.value('./DOUBTFULDATE [1]','VARCHAR(30)')='' THEN NULL ELSE C.value('./DOUBTFULDATE [1]','VARCHAR(30)') END DOUBTFULDATE
		--INTO #Customer
		--FROM @XMLDocument.nodes('/DataSet/Gridrow') AS t(c)

		SELECT 
			ROW_NUMBER()OVER(ORDER BY (SELECT  (1))) RowNum,
			CUSTOMERID,
			AssetClassification,
			NPADate,
			SecurityValue,
			cast(nullif(AdditionalProvision,'') as decimal(18,2)) AdditionalProvision,
			MOCTYPE,
			MOCReason,
			CAST(NULL AS VARCHAR(MAX)) ERROR,
			DOUBTFULDATE
			into #Customer
	        from
		    dbo.CustomerDataUpload



		--SELECT * FROM #Customer
		/****************************************************************************************************************
					
											FOR CHECKING A CUSTOMER ID 

		****************************************************************************************************************/
		
		UPDATE A
		SET ERROR = CASE	WHEN ISNULL(A.CUSTOMERID,'')=''		THEN 'Customer Id should not be Empty'
							WHEN ISNULL(C.RefCustomerID,'')=''	THEN 'Invalid Customer Id'
							ELSE ERROR
					END
		FROM #Customer A
		LEFT OUTER JOIN PRO.CustomerCal C
			ON  A.CUSTOMERID = C.RefCustomerID --C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey		AND A.CUSTOMERID = C.RefCustomerID


		/****************************************************************************************************************
					
											FOR CHECKING A Asset Classification

		****************************************************************************************************************/
		
		UPDATE #Customer
		SET ERROR = CASE	WHEN ISNULL(ERROR,'')='' AND ISNULL(AssetClassification,'') ='' THEN 'AssetClassification should not be Empty'
							WHEN ISNULL(ERROR,'')<>'' AND ISNULL(AssetClassification,'') ='' THEN ISNULL(ERROR,'')+','+SPACE(1)+'AssetClassification should not be Empty'

							WHEN ISNULL(ERROR,'')='' 
							AND ISNULL(AssetClassification,'') NOT IN ('STD','SUB','DB1','DB2', 'DB3', 'LOS') 
								THEN 'AssetClassification should  be STD ,SUB ,DB1 ,DB2 ,DB3 ,LOS'

							WHEN ISNULL(ERROR,'')<>'' 
							AND ISNULL(AssetClassification,'') NOT IN ('STD','SUB','DB1','DB2', 'DB3', 'LOS') 
								THEN ERROR+','+SPACE(1)+'AssetClassification should  be STD ,SUB ,DB1 ,DB2 ,DB3 ,LOS'

							ELSE ERROR
					END

		/****************************************************************************************************************
					
											FOR CHECKING A NPA DATE

		****************************************************************************************************************/


		UPDATE A
				SET ERROR = CASE	
									WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.NPADate,'')<>'' AND ISNULL(B.correct,0)<>1	THEN ISNULL(ERROR,'')+','+'Invalid NPA Date'
									WHEN ISNULL(ERROR,'')='' AND ISNULL(A.NPADate,'')<>''  AND ISNULL(B.correct,0)<>1	THEN 'Invalid NPA Date'

									WHEN ISNULL(ERROR,'')='' 
									AND AssetClassification IN ('SUB','DB1','DB2', 'DB3', 'LOS') 
									AND ISNULL(A.NPADate,'')=''		
									THEN 'NPA Date cannot be empty'
						
									WHEN ISNULL(ERROR,'')<>''
									AND AssetClassification IN ('SUB','DB1','DB2', 'DB3', 'LOS') 
									AND ISNULL(A.NPADate,'')=''		
									THEN ISNULL(ERROR,'')+','+SPACE(1)+ 'NPA Date cannot be empty'

								ELSE ERROR
							END
				
				 FROM #Customer A
				LEFT OUTER JOIN 
			(
			--SELECT 1
				SELECT RowNum ,1 correct FROM #Customer
				WHERE ISDATE(NPADate)=1
				AND (CASE	WHEN SUBSTRING(RTRIM(LTRIM(NPADate)),3,1)='-' 
								AND (LEN(RTRIM(LTRIM(NPADate)))=9 OR LEN(RTRIM(LTRIM(NPADate)))=11 )
								AND ISNUMERIC(SUBSTRING(RTRIM(LTRIM(NPADate)),4,3))=0 
								AND  SUBSTRING(RTRIM(LTRIM(NPADate)),7,1)='-' 
							THEN 1

							WHEN SUBSTRING(RTRIM(LTRIM(NPADate)),3,1)='/'
							AND (LEN(RTRIM(LTRIM(NPADate)))=8 OR LEN(RTRIM(LTRIM(NPADate)))=10 )
							 AND  SUBSTRING(RTRIM(LTRIM(NPADate)),6,1)='/' THEN 1
					END)=1
			)B 
			ON A.RowNum = B.RowNum
			WHERE ISNULL(B.RowNum,'')='' 
			--AND ISNULL(NPADate,'')<>''

	
			--SP

		UPDATE A
						SET ERROR = CASE	
											WHEN ISNULL(ERROR,'')='' AND 
											AssetClassification IN ('STD') AND (ISNULL(A.NPADate,'')<>'' )		
											THEN 'NPA Date should be null when AssetClassification is STD'

											WHEN ISNULL(ERROR,'')='' AND 
											AssetClassification IN ('STD') AND (ISNULL(A.DOUBTFULDATE,'')<>'')
										
											THEN 'Doubtful Date should be null when AssetClassification is STD'

											WHEN ISNULL(ERROR,'')='' AND 
											AssetClassification IN ('LOS') 
											AND (ISNULL(A.DOUBTFULDATE,'')<>'')	
											THEN 'Doubtful Date should be null when AssetClassification is LOS'

                 
											ELSE ERROR
									END
				
						 FROM #Customer A

		--SP
		/****************************************************************************************************************
					
											FOR CHECKING A DOUBTFULDATE 

		****************************************************************************************************************/
		
		UPDATE A
				SET ERROR = CASE	WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.DOUBTFULDATE,'')<>''	AND ISNULL(B.correct,0)<>1 THEN ISNULL(ERROR,'')+','+'Invalid DOUBTFUL DATE'
									WHEN ISNULL(ERROR,'')='' AND ISNULL(A.DOUBTFULDATE,'')<>''	AND ISNULL(B.correct,0)<>1 THEN 'Invalid DOUBTFUL DATE'

									WHEN ISNULL(ERROR,'')='' 
									AND AssetClassification IN ('DB1','DB2', 'DB3') 
									AND ISNULL(A.DOUBTFULDATE,'')=''		
									THEN 'DOUBTFUL DATE cannot be empty'

									WHEN ISNULL(ERROR,'')<>''
									AND AssetClassification IN ('DB1','DB2', 'DB3') 
									AND ISNULL(A.DOUBTFULDATE,'')=''		
									THEN ISNULL(ERROR,'')+','+SPACE(1)+ 'DOUBTFUL DATE cannot be empty'

								ELSE ERROR
							END
				
				 FROM #Customer A
				LEFT OUTER JOIN 
			(
			--SELECT 1
				SELECT RowNum ,1 correct FROM #Customer
				WHERE ISDATE(DOUBTFULDATE)=1
				AND (CASE	WHEN SUBSTRING(RTRIM(LTRIM(DOUBTFULDATE)),3,1)='-' 
								AND (LEN(RTRIM(LTRIM(DOUBTFULDATE)))=9 OR LEN(RTRIM(LTRIM(DOUBTFULDATE)))=11 )
								AND ISNUMERIC(SUBSTRING(RTRIM(LTRIM(DOUBTFULDATE)),4,3))=0 
								AND  SUBSTRING(RTRIM(LTRIM(DOUBTFULDATE)),7,1)='-' 
							THEN 1

							WHEN SUBSTRING(RTRIM(LTRIM(DOUBTFULDATE)),3,1)='/'
							AND (LEN(RTRIM(LTRIM(DOUBTFULDATE)))=8 OR LEN(RTRIM(LTRIM(DOUBTFULDATE)))=10 )
							 AND  SUBSTRING(RTRIM(LTRIM(DOUBTFULDATE)),6,1)='/' THEN 1
					END)=1
			)B 
			ON A.RowNum = B.RowNum
			WHERE ISNULL(B.RowNum,'')='' 
			--AND ISNULL(DOUBTFULDATE,'')<>''


	

	--sp

		/****************************************************************************************************************
					
											FOR CHECKING A Security Value

		****************************************************************************************************************/

		UPDATE #Customer
		SET ERROR = CASE	WHEN ISNUMERIC(SecurityValue)= 0 AND  ISNULL(ERROR,'')=''	THEN 'Incorrect Security Value' 
							WHEN ISNUMERIC(SecurityValue)= 0 AND  ISNULL(ERROR,'')<>''	THEN ISNULL(ERROR,'')+','+SPACE(1)+'Incorrect Security Value' 
							WHEN LEN(SecurityValue)>19  AND ISNULL(ERROR,'')=''		THEN 'Lengh is Security value should be less then 20'
							WHEN LEN(SecurityValue)>19  AND ISNULL(ERROR,'')<>''		THEN 'Lengh is Security value should be less then 20'
							ELSE ERROR
					END
		WHERE ISNULL(SecurityValue,'')<>'' 


		/****************************************************************************************************************
					
											FOR CHECKING A Additional Provision

		****************************************************************************************************************/

		UPDATE #Customer
		SET ERROR = CASE	WHEN ISNUMERIC(AdditionalProvision)= 0 AND  ISNULL(ERROR,'')=''	THEN 'Incorrect Additional Provision' 
							WHEN ISNUMERIC(AdditionalProvision)= 0 AND  ISNULL(ERROR,'')<>''	THEN ISNULL(ERROR,'')+','+SPACE(1)+'Incorrect Additional Provision' 
							WHEN (ISNULL(AdditionalProvision,0) NOT BETWEEN 0 AND 100)  AND ISNULL(ERROR,'')=''		THEN 'Additional Provision Percentage Should be between 0 to 100'
							WHEN (ISNULL(AdditionalProvision,0) NOT BETWEEN 0 AND 100)  AND ISNULL(ERROR,'')<>''	THEN ERROR+','+SPACE(1)+ 'Additional Provision Percentage Should be between 0 to 100'
							ELSE ERROR
					END
		WHERE ISNULL(AdditionalProvision,0)<>0


		/****************************************************************************************************************
					
											FOR CHECKING A Moc Reason

		****************************************************************************************************************/

		UPDATE #Customer
		SET ERROR = CASE	WHEN ISNULL(ERROR,'')=''	THEN 'MOC Reason Length should not be  greater then 500 Chararter'
							WHEN ISNULL(ERROR,'')<>''	THEN ISNULL(ERROR,'')+','+SPACE(1)+ 'MOC Reason Length should not be  greater then 500 Chararter'
							ELSE ERROR
					END
		WHERE LEN(MOCReason)>500

		UPDATE #Customer
		SET ERROR = CASE	WHEN ISNULL(ERROR,'')=''	THEN 'MOC TYPE should not be  greater then 15 Chararter'
							WHEN ISNULL(ERROR,'')<>''	THEN ISNULL(ERROR,'')+','+SPACE(1)+ 'MOC TYPE should not be  greater then 15 Chararter'
							ELSE ERROR
					END
		WHERE LEN(MOCTYPE) >15

		UPDATE #Customer
		SET ERROR = CASE	WHEN ISNULL(ERROR,'')=''	THEN 'MOC TYPE can not be other than AUTO and MANUAL. Please check and upload again'
							WHEN ISNULL(ERROR,'')<>''	THEN ISNULL(ERROR,'')+','+SPACE(1)+ 'MOC TYPE can not be other than AUTO and MANUAL. Please check and upload again'
							ELSE ERROR
					END
		WHERE ISNULL(MOCTYPE,'') NOT IN('AUTO','MANUAL') 

		
		-- Added By Sourangshu 20241105

		DECLARE @FilePathUpdated_Cust VARCHAR(500)
	    SELECT @FilePathUpdated_Cust=@UserLoginId+'_'+@filepath

		Delete from  dbo.CustomerDataUploadFinal where FILENAME=@FilePathUpdated_Cust

		--Added By Sourangshu 

		Declare	@Fraentid int= (Select IDENT_CURRENT('dbo.CustomerDataUpload'))
	
		IF EXISTS(SELECT 1 FROM #Customer WHERE ISNULL(ERROR,'')<>'')
		BEGIN
			SELECT	  RowNum
					,CUSTOMERID  
					,ASSETCLASSIFICATION
					,NPADATE
					,SECURITYVALUE
					,ADDITIONALPROVISION 
					,MOCTYPE
					,MOCREASON
					,ERROR
					,'ErrorData' TableName
					,DOUBTFULDATE
			FROM #Customer WHERE ISNULL(ERROR,'')<>''
		END
		ELSE
		BEGIN	
			
			SELECT  RowNum
					,CUSTOMERID  
					,ASSETCLASSIFICATION
					,CASE WHEN ISNULL(NPADate,'')='' THEN NULL ELSE CONVERT(VARCHAR(10),CAST(NPADate AS DATE),103) END NPADATE 
					,SECURITYVALUE
					,ADDITIONALPROVISION 
					,MOCTYPE
					,MOCREASON
					,'CustomerData' TableName
					,CASE WHEN ISNULL(DOUBTFULDATE,'')='' THEN NULL ELSE CONVERT(VARCHAR(10),CAST(DOUBTFULDATE AS DATE),103) END DOUBTFULDATE 
			FROM #Customer WHERE ISNULL(ERROR,'')=''

			insert into dbo.CustomerDataUploadFinal
				( 
				CUSTOMERID,
				AssetClassification,
				NPADate,
				SecurityValue,
				AdditionalProvision,
				MOCTYPE,
				MOCReason,
				DOUBTFULDATE,
				MocCustomerDataEntityId
				)
				select
				CUSTOMERID,
				AssetClassification,
				NPADate,
				SecurityValue,
				AdditionalProvision,
				MOCTYPE,
				MOCReason,
				DOUBTFULDATE,
				@Fraentid+(ROW_NUMBER() over(order by CUSTOMERID))
				from
				#Customer


		END

		DROP TABLE #Customer



End
GO