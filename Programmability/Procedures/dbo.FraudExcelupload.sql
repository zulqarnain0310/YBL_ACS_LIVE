SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE Procedure [dbo].[FraudExcelupload]
(
@UserLoginId varchar(20),
@filepath varchar(600)
)
As
Begin

print 'A'

IF OBJECT_ID('TEMPDB..#Fraud') IS NOT NULL
				DROP TABLE #Fraud

		--SELECT 
		--ROW_NUMBER()OVER(ORDER BY (SELECT  (1))) RowNum
		
		--,C.value('./UCICID				[1]','VARCHAR(30)') UCICID  
		--,C.value('./CUSTOMERID			[1]','VARCHAR(50)') CUSTOMERID  
		--,C.value('./CUSTOMERNAME		[1]','VARCHAR(225)') CUSTOMERNAME  
		--,C.value('./ACCOUNTID			[1]','VARCHAR(30)') CustomerAcID
		--,C.value('./DATEOFFRAUD			[1]','VARCHAR(30)') FraudDate
		--,CASE WHEN C.value('./AMOUNTOFFRAUD		[1]','VARCHAR(30)')='' THEN NULL ELSE C.value('./AMOUNTOFFRAUD		[1]','DECIMAL(18,2)') END FraudAmt
		--,CAST(NULL AS VARCHAR(MAX))ERROR
		--,C.value('./EFFECTIVENPADATE			[1]','VARCHAR(30)') EffectiveNPADate
		--INTO #Fraud
		--FROM @XMLDocument.nodes('/DataSet/Gridrow') AS t(c)

				-- Changes BY Sourangshu 20241105

				select
				ROW_NUMBER()OVER(ORDER BY (SELECT  (1))) RowNum,
				UCICID,
				CUSTOMERID ,
				CUSTOMERNAME ,
				ACCOUNTID CustomerAcID ,
				DATEOFFRAUD FraudDate ,
				cast(nullif(AMOUNTOFFRAUD,'') as decimal(18,2)) FraudAmt ,
				CAST(NULL AS VARCHAR(MAX)) ERROR ,
				EffectiveNPADate
				into #Fraud
				from
				dbo.FraudDataupload

		
		
		/****************************************************************************************************************
					
											FOR CHECKING A UCIF ID 

		****************************************************************************************************************/
		UPDATE F
		SET ERROR = CASE	WHEN ISNULL(C.UCIF_ID,'')=''AND ISNULL(ERROR,'')='' THEN 'Invalid UCICID Id'
							WHEN ISNULL(C.UCIF_ID,'')=''AND ISNULL(ERROR,'')<>'' THEN ERROR+','+SPACE(1)+ 'Invalid UCICID Id'
							ELSE ERROR
					END
		FROM 
		#Fraud F
		LEFT OUTER  JOIN PRO.CUSTOMERCAL  C
			ON C.UCIF_ID = F.UCICID --C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey	AND C.UCIF_ID = F.UCICID
		WHERE ISNULL(UCICID,'')<>''



		UPDATE F
		SET ERROR = CASE	WHEN  ISNULL(C.UCIF_ID,'')='' AND ISNULL(ERROR,'')=''	THEN 'UCIC ID  Not Belong to that Customer Id'

							WHEN ISNULL(C.UCIF_ID,'')='' AND ISNULL(ERROR,'')<>''	THEN  ISNULL(ERROR,'')+','+SPACE(1)+'UCIC ID  Not Belong to that Customer Id'
							ELSE ERROR
					END
		
		FROM #Fraud F
		LEFT OUTER JOIN PRO.CustomerCal C
			ON F.CUSTOMERID = C.RefCustomerID		AND F.UCICID = C.UCIF_ID --C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey		AND F.CUSTOMERID = C.RefCustomerID		AND F.UCICID = C.UCIF_ID
		WHERE  ISNULL(F.UCICID,'')<>''

		
		/****************************************************************************************************************
					
											FOR CHECKING A CUSTOMER ID 

		****************************************************************************************************************/
		UPDATE F
		SET ERROR = CASE	WHEN ISNULL(F.CUSTOMERID,'')='' AND ISNULL(ERROR,'')=''		THEN 'Customer Id should not be Empty'
							WHEN ISNULL(F.CUSTOMERID,'')='' AND ISNULL(ERROR,'')<>''	THEN ERROR+','+SPACE(1) +'Customer Id should not be Empty'
							WHEN ISNULL(C.RefCustomerID,'')='' AND ISNULL(ERROR,'')=''	THEN 'Invalid Customer Id'
							WHEN ISNULL(C.RefCustomerID,'')='' AND ISNULL(ERROR,'')<>''	THEN ERROR+','+SPACE(1) +'Invalid Customer Id'
						ELSE ERROR
					END
		FROM #Fraud F
		LEFT OUTER JOIN PRO.CustomerCal C
			ON C.RefCustomerID = F.CUSTOMERID-- C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey		AND C.RefCustomerID = F.CUSTOMERID


		

		/****************************************************************************************************************
					
											FOR CHECKING A ACCOUNT  ID 

		****************************************************************************************************************/

		UPDATE A
		SET ERROR = CASE	WHEN ISNULL(C.CustomerAcID,'')='' AND ISNULL(ERROR,'')=''	THEN 'Invalid Account Id'
							WHEN ISNULL(C.CustomerAcID,'')='' AND ISNULL(ERROR,'')<>'' THEN ERROR+','+SPACE(1)+'Invalid Account Id'
							ELSE ERROR
					END
		FROM #Fraud A
		LEFT OUTER JOIN PRO.AccountCal C
			ON C.CustomerAcID = A.CustomerAcID --C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey AND C.CustomerAcID = A.CustomerAcID
		WHERE ISNULL(A.CustomerAcID,'')<>''

		
		UPDATE F
		SET ERROR = CASE	WHEN  ISNULL(C.CustomerAcID,'')='' AND ISNULL(ERROR,'')=''	THEN 'Account Id Not Belong to that Customer Id'

							WHEN ISNULL(C.CustomerAcID,'')='' AND ISNULL(ERROR,'')<>''	THEN  ISNULL(ERROR,'')+','+SPACE(1)+'Account Id Not Belong to that Customer Id'
							ELSE ERROR
					END
		
		FROM #Fraud F
		LEFT OUTER JOIN PRO.AccountCal C
			ON F.CUSTOMERID = C.RefCustomerID	AND F.CustomerAcID = C.CustomerAcID-- C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey	AND F.CUSTOMERID = C.RefCustomerID	AND F.CustomerAcID = C.CustomerAcID
		WHERE  ISNULL(F.CustomerAcID,'')<>''
		
		/****************************************************************************************************************
					
											FOR CHECKING A FRAUD DATE


		****************************************************************************************************************/

				
				UPDATE A
				SET ERROR = 
							--CASE	WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.FraudDate,'')<>''THEN ERROR+','+'Invalid Fraud Date'
							--		WHEN ISNULL(ERROR,'')='' AND ISNULL(A.FraudDate,'')<>''	THEN 'Invalid Fraud Date'
							--		WHEN ISNULL(ERROR,'')='' AND ISNULL(A.FraudDate,'')=''	THEN 'Fraud Date cannot be empty'
							--		WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.FraudDate,'')=''	THEN ERROR+','+'Fraud Date cannot be empty'

							--	ELSE ERROR
							--END
								CASE	WHEN ISNULL(ERROR,'')=''  AND ISNULL(A.FraudDate,'')<>'' AND ISNULL(B.correct,0)<>1 
											THEN 'Invalid Fraud Date'

										WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.FraudDate,'')<>'' AND ISNULL(B.correct,0)<>1 
													THEN ISNULL(ERROR,'')+','+SPACE(1)+ 'Invalid Fraud Date'

										WHEN ISNULL(ERROR,'')=''  AND ISNULL(A.FraudDate,'')='' 
													THEN 'Fraud Date cannot be empty'

										WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.FraudDate,'')='' THEN 
													ISNULL(ERROR,'')+','+SPACE(1)+ 'Fraud Date cannot be empty'

									ELSE ERROR
								END
				
				 FROM #Fraud A
				LEFT OUTER JOIN 
			(
			--SELECT 1
				SELECT RowNum ,1 correct FROM #Fraud
				WHERE ISDATE(FraudDate)=1
				AND (CASE	WHEN SUBSTRING(RTRIM(LTRIM(FraudDate)),3,1)='-' 
								AND (LEN(RTRIM(LTRIM(FraudDate)))=9 OR LEN(RTRIM(LTRIM(FraudDate)))=11 )
								AND ISNUMERIC(SUBSTRING(RTRIM(LTRIM(FraudDate)),4,3))=0 
								AND  SUBSTRING(RTRIM(LTRIM(FraudDate)),7,1)='-' 
							THEN 1

							WHEN SUBSTRING(RTRIM(LTRIM(FraudDate)),3,1)='/'
							AND (LEN(RTRIM(LTRIM(FraudDate)))=8 OR LEN(RTRIM(LTRIM(FraudDate)))=10 )
							 AND  SUBSTRING(RTRIM(LTRIM(FraudDate)),6,1)='/' THEN 1
					END)=1
			)B 
			ON A.RowNum = B.RowNum
			WHERE --ISNULL(A.FraudDate,'')<>''  and 
			ISNULL(B.RowNum,'')='' 

		/****************************************************************************************************************
					
											FOR CHECKING A EffectiveNPADate


		****************************************************************************************************************/

				
				UPDATE A
				SET ERROR = 
								CASE	WHEN ISNULL(ERROR,'')=''  AND ISNULL(A.EffectiveNPADate,'')<>'' AND ISNULL(B.correct,0)<>1 
											THEN 'Invalid Effective Date of NPA'

										WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.EffectiveNPADate,'')<>'' AND ISNULL(B.correct,0)<>1 
													THEN ISNULL(ERROR,'')+','+SPACE(1)+ 'Invalid Effective Date of NPA'

										WHEN ISNULL(ERROR,'')=''  AND ISNULL(A.EffectiveNPADate,'')='' 
													THEN 'Effective Date of NPA cannot be empty'

										WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.EffectiveNPADate,'')='' THEN 
													ISNULL(ERROR,'')+','+SPACE(1)+ 'Effective Date of NPA cannot be empty'

									ELSE ERROR
								END
				
				 FROM #Fraud A
				LEFT OUTER JOIN 
			(
				SELECT RowNum ,1 correct FROM #Fraud
				WHERE ISDATE(EffectiveNPADate)=1
				AND (CASE	WHEN SUBSTRING(RTRIM(LTRIM(EffectiveNPADate)),3,1)='-' 
								AND (LEN(RTRIM(LTRIM(EffectiveNPADate)))=9 OR LEN(RTRIM(LTRIM(EffectiveNPADate)))=11 )
								AND ISNUMERIC(SUBSTRING(RTRIM(LTRIM(EffectiveNPADate)),4,3))=0 
								AND  SUBSTRING(RTRIM(LTRIM(EffectiveNPADate)),7,1)='-' 
							THEN 1

							WHEN SUBSTRING(RTRIM(LTRIM(EffectiveNPADate)),3,1)='/'
							AND (LEN(RTRIM(LTRIM(EffectiveNPADate)))=8 OR LEN(RTRIM(LTRIM(EffectiveNPADate)))=10 )
							 AND  SUBSTRING(RTRIM(LTRIM(EffectiveNPADate)),6,1)='/' THEN 1
					END)=1
			)B 
			ON A.RowNum = B.RowNum
			WHERE --ISNULL(A.EffectiveNPADate,'')<>''  and 
			ISNULL(B.RowNum,'')='' 
		
		
		/****************************************************************************************************************
					
											FOR CHECKING A FRAUD AMOUNT


		****************************************************************************************************************/


		UPDATE #Fraud
		SET ERROR = CASE	WHEN  ISNULL(ERROR,'')='' AND ISNUMERIC(FraudAmt)=0  THEN 'Incorrect Fraud Amount'
							WHEN ISNULL(ERROR,'')<>'' AND ISNUMERIC(FraudAmt)=0 THEN ERROR+','+SPACE(1)+'Incorrect Fraud Amount'

							WHEN ISNULL(ERROR,'')=''	AND LEN(CAST(FraudAmt AS DECIMAL(18,2)))>20 THEN 'Length of Fraud Amount should be less then 20'
							WHEN ISNULL(ERROR,'')<>''	AND LEN(CAST(FraudAmt AS DECIMAL(18,2)))>20 THEN ERROR+','+SPACE(1)+ 'Length of Fraud Amount should be less then 20'
							
						ELSE ERROR
					END
		WHERE ISNULL(FraudAmt,0)<>0 

		
		/****************************************************************************************************************
					
											FOR RETRIEVING A OUTPUT


		****************************************************************************************************************/

		-- Added By Sourangshu 20241105

		DECLARE @FilePathUpdated_Fraud VARCHAR(500)
	    SELECT @FilePathUpdated_Fraud=@UserLoginId+'_'+@filepath

		Delete from  dbo.FraudDatauploadFinal where FILENAME=@FilePathUpdated_Fraud

		--Added By Sourangshu 

		Declare	@Fraentid int= (Select IDENT_CURRENT('dbo.SecurityDataUpload'))

		IF EXISTS(SELECT 1 FROM #Fraud WHERE ISNULL(ERROR,'')<>'')
		BEGIN
			SELECT RowNum
					,UCICID
					,CUSTOMERID 
					,CUSTOMERNAME
					,CUSTOMERACID
					,FRAUDDATE
					,FRAUDAMT
					,ERROR
					,EFFECTIVENPADATE
					,'ErrorData' TableName
			FROM #Fraud WHERE ISNULL(ERROR,'')<>''

		END
		ELSE 
		BEGIN
			SELECT RowNum
					,UCICID
					,CUSTOMERID 
					,CUSTOMERNAME
					,CUSTOMERACID
					,CASE WHEN ISNULL(FraudDate,'')<>'' THEN CONVERT(VARCHAR(10),CAST(FraudDate AS DATE),103) ELSE NULL END FRAUDDATE
					,FRAUDAMT
					, CASE WHEN ISNULL(EffectiveNPADate,'')<>'' THEN CONVERT(VARCHAR(10),CAST(EffectiveNPADate AS DATE),103) ELSE NULL END EFFECTIVENPADATE
					,'FraudData' TableName
			FROM #Fraud WHERE ISNULL(ERROR,'')=''

			insert into dbo.FraudDatauploadFinal
			    (     
				UCICID ,
				CUSTOMERID ,
				CUSTOMERNAME ,
				CUSTOMERACID ,
				FRAUDDATE ,
				FRAUDAMT ,
				FraudAccountDataEntityId ,
				EFFECTIVENPADATE 
				)
				select
				UCICID
			   ,CUSTOMERID 
			   ,CUSTOMERNAME
			   ,CUSTOMERACID
			   ,nullif(FraudDate,'') FRAUDDATE
			   ,FraudAmt
			   ,@Fraentid+(ROW_NUMBER() over(order by CUSTOMERACID))
			   ,nullif(EFFECTIVENPADATE,'') EFFECTIVENPADATE 
				from
				#Fraud

		END
		DROP TABLE #Fraud
END	



GO