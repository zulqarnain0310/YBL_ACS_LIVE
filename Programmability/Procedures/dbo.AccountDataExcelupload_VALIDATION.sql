SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create Procedure [dbo].[AccountDataExcelupload_VALIDATION]
(
@UserLoginId varchar(20),
@filepath varchar(600)
)
As
Begin


IF OBJECT_ID('TEMPDB..#Account') IS NOT NULL
				DROP TABLE #Account

		--SELECT 
		--ROW_NUMBER()OVER(ORDER BY (SELECT  (1))) RowNum
		--,C.value('./CUSTOMERID			[1]','VARCHAR(50)')CUSTOMERID  
		--,C.value('./ACCOUNTID			[1]','VARCHAR(30)')CUSTOMERAcID
		--,C.value('./BALANCE 			[1]','VARCHAR(100)')Balance 
		--,CASE WHEN C.value('./ADDITIONALPROVISION	[1]','VARCHAR(30)')= '' THEN NULL ELSE C.value('./ADDITIONALPROVISION	[1]','DECIMAL(18,2)') END AdditionalProvision
		--,CASE WHEN C.value('./ADDITIONALPROVISIONAMOUNT	[1]','VARCHAR(30)')= '' THEN NULL ELSE C.value('./ADDITIONALPROVISIONAMOUNT	[1]','DECIMAL(18,2)') END AdditionalProvisionAmount 
  --		,C.value('./APPROPRIATESECURITY [1]','VARCHAR(30)')AppropriateSecurity
		--,C.value('./FITL				[1]','VARCHAR(30)')FITL  
		--,CASE WHEN C.value('./DFVAMOUNT			[1]','VARCHAR(30)')='' THEN NULL ELSE C.value('./DFVAMOUNT			[1]','DECIMAL(18,2)') END DFVAmount  
		--,C.value('./INFRASTRUCTUREYN		[1]','VARCHAR(30)') InfrastructureYN  
		--,C.value('./REPOSSESSIONDATE	[1]','VARCHAR(30)') RepossessionDate  
		--,C.value('./RESTRUCTUREDATE		[1]','VARCHAR(30)') RestructureDate  
		--,C.value('./ORIGINALDCCODATE	[1]','VARCHAR(30)') OriginalDCCODate  
		--,C.value('./EXTENDEDDCCODATE	[1]','VARCHAR(30)') ExtendedDCCODate  
		--,C.value('./ACTUALDCCODATE		[1]','VARCHAR(30)') ActualDCCODate
		--,C.value('./MOCREASON			[1]','VARCHAR(500)') MocReason
		--,CAST(NULL AS VARCHAR(MAX))ERROR
		--INTO #Account
		--FROM @XMLDocument.nodes('/DataSet/Gridrow') AS t(c)


		select
		ROW_NUMBER()OVER(ORDER BY (SELECT  (1))) RowNum,
		CUSTOMERID,
		CUSTOMERAcID,
		Balance,
		AdditionalProvision,
		AdditionalProvisionAmount,
		AppropriateSecurity,
		FITL,
		DFVAmount,
		InfrastructureYN,
		RepossessionDate,
		RestructureDate,
		OriginalDCCODate,
		ExtendedDCCODate,
		ActualDCCODate,
		MocReason,
		CAST(NULL AS VARCHAR(MAX))ERROR
		into #Account
		from
		dbo.AccountDataUpload


			/****************************************************************************************************************
					
											FOR CHECKING A CUSTOMER ID 

		****************************************************************************************************************/
		
		UPDATE A
		SET ERROR = CASE	WHEN ISNULL(A.CUSTOMERID,'')=''		THEN 'Customer Id should not be Empty'
							WHEN ISNULL(C.RefCustomerID,'')=''	THEN 'Invalid Customer Id'
							ELSE ERROR
					END
		FROM #Account A
		LEFT OUTER JOIN PRO.CustomerCal C
			ON A.CUSTOMERID = C.RefCustomerID-- C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey		AND A.CUSTOMERID = C.RefCustomerID

		/****************************************************************************************************************
					
											FOR CHECKING A ACCOUNT  ID 

		****************************************************************************************************************/


		
	UPDATE A
		SET ERROR = CASE	WHEN ISNULL(C.CustomerAcID,'')='' AND ISNULL(ERROR,'')=''	THEN 'Invalid Account Id'
							WHEN ISNULL(C.CustomerAcID,'')='' AND ISNULL(ERROR,'')<>'' THEN ERROR+','+SPACE(1)+'Invalid Account Id'
							ELSE ERROR
					END
		FROM #Account A
		LEFT OUTER JOIN PRO.AccountCal C
			ON C.CustomerAcID = A.CustomerAcID-- C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey	AND C.CustomerAcID = A.CustomerAcID
		WHERE ISNULL(A.CustomerAcID,'')<>''




		UPDATE A
		SET ERROR = CASE	WHEN  ISNULL(C.CustomerAcID,'')='' AND ISNULL(ERROR,'')=''	THEN 'Account Id Not Belong to that Customer Id'

							WHEN ISNULL(C.CustomerAcID,'')='' AND ISNULL(ERROR,'')<>''	THEN  ISNULL(ERROR,'')+','+SPACE(1)+'Account Id Not Belong to that Customer Id'
							ELSE ERROR
					END
		
		FROM #Account A
		LEFT OUTER JOIN PRO.AccountCal C
			ON  A.CUSTOMERID = C.RefCustomerID	AND A.CustomerAcID = C.CustomerAcID --C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey	AND A.CUSTOMERID = C.RefCustomerID	AND A.CustomerAcID = C.CustomerAcID
		WHERE  ISNULL(A.CustomerAcID,'')<>''


		/****************************************************************************************************************
					
											FOR CHECKING A BALANCE

		****************************************************************************************************************/

		

		UPDATE #Account
		SET ERROR = CASE	WHEN ISNUMERIC(Balance)= 0 AND  ISNULL(ERROR,'')=''	THEN 'Incorrect Balance' 
							WHEN ISNUMERIC(Balance)= 0 AND  ISNULL(ERROR,'')<>''	THEN ERROR+','+SPACE(1)+'Incorrect Balance' 
							WHEN LEN(Balance)>19  AND ISNULL(ERROR,'')=''		THEN 'Lengh is Security value should be less then 20'
							WHEN LEN(Balance)>19  AND ISNULL(ERROR,'')<>''		THEN 'Lengh is Security value should be less then 20'
							ELSE ERROR
					END
		WHERE ISNULL(Balance,'')<>'' 

		/****************************************************************************************************************
					
											FOR CHECKING A Addtitonal Provision

		****************************************************************************************************************/
		
			UPDATE #Account
		SET ERROR = CASE	WHEN ISNUMERIC(AdditionalProvision)= 0 AND  ISNULL(ERROR,'')=''	THEN 'Incorrect Provision Percent' 
							WHEN ISNUMERIC(AdditionalProvision)= 0 AND  ISNULL(ERROR,'')<>''	THEN ERROR+','+SPACE(1)+'Incorrect Provision Percent' 
							WHEN (ISNULL(AdditionalProvision,0) NOT BETWEEN 0 AND 100)  AND ISNULL(ERROR,'')=''		THEN 'Provision Percentage Should be between 0 to 100'
							WHEN (ISNULL(AdditionalProvision,0) NOT BETWEEN 0 AND 100)  AND ISNULL(ERROR,'')<>''	THEN ERROR+','+SPACE(1)+ 'Provision Percentage Should be between 0 to 100'
							ELSE ERROR
					END
		WHERE ISNULL(AdditionalProvision,0)<>0

		

		
		/****************************************************************************************************************
					
											FOR CHECKING A STOCKVALUE

		****************************************************************************************************************/

		UPDATE #Account
		SET ERROR = CASE	WHEN ISNUMERIC(AdditionalProvisionAmount)= 0 AND  ISNULL(ERROR,'')=''	THEN 'Incorrect Additional Provision Amount' 
							WHEN ISNUMERIC(AdditionalProvisionAmount)= 0 AND  ISNULL(ERROR,'')<>''	THEN ISNULL(ERROR,'')+','+SPACE(1)+'Incorrect Additional Provision Amount' 
							WHEN LEN(AdditionalProvisionAmount)>19  AND ISNULL(ERROR,'')=''		THEN 'Length of Additional Provision Amount should be less then 20'
							WHEN LEN(AdditionalProvisionAmount)>19  AND ISNULL(ERROR,'')<>''		THEN  ISNULL(ERROR,'')+','+SPACE(1)+'Length of Additional Provision Amount should be less then 20'
							ELSE ERROR
					END
		WHERE ISNULL(AdditionalProvisionAmount,0)<>0  --AND ISNUMERIC(StockValue)= 0 



		
		/****************************************************************************************************************
					
											FOR CHECKING A Appropriate Security  

		****************************************************************************************************************/

		UPDATE #Account
		SET ERROR = CASE	WHEN ISNULL(AppropriateSecurity,'')<>'' AND AppropriateSecurity NOT IN('Y','N')  AND ISNULL(ERROR,'')='' THEN 'Appropriate Security Either Y OR N'
							WHEN ISNULL(AppropriateSecurity,'')<>'' AND AppropriateSecurity NOT IN('Y','N')  AND ISNULL(ERROR,'')<>'' THEN ERROR+','+SPACE(1)+'Appropriate Security Either Y OR N'
							ELSE ERROR
					END


		/****************************************************************************************************************
					
											FOR CHECKING A FITL  

		****************************************************************************************************************/

		UPDATE #Account
		SET ERROR = CASE	WHEN ISNULL(FITL,'')<>'' AND FITL NOT IN('Y','N')  AND ISNULL(ERROR,'')='' THEN 'FITL Flag Either Y OR N'
							WHEN ISNULL(FITL,'')<>'' AND FITL NOT IN('Y','N')  AND ISNULL(ERROR,'')<>'' THEN ERROR+','+SPACE(1)+'FITL Flag Either Y OR N'
							ELSE ERROR
					END
		


		/****************************************************************************************************************
					
											FOR CHECKING A DFV AMOUNT

		****************************************************************************************************************/

		UPDATE #Account
		SET ERROR = CASE	WHEN ISNUMERIC(DFVAmount)= 0 AND  ISNULL(ERROR,'')=''	THEN 'Incorrect DFVAmuont' 
							WHEN ISNUMERIC(DFVAmount)= 0 AND  ISNULL(ERROR,'')<>''	THEN ERROR+','+SPACE(1)+'Incorrect DFVAmuont' 
							WHEN LEN(DFVAmount)>19  AND ISNULL(ERROR,'')=''		THEN 'Length is DFVAmuont should be less then 20'
							WHEN LEN(DFVAmount)>19  AND ISNULL(ERROR,'')<>''		THEN 'Length is DFVAmuont should be less then 20'
							ELSE ERROR
					END
		WHERE ISNULL(DFVAmount,0)<>0 


		/****************************************************************************************************************
					
											FOR CHECKING A INFRASTRUCTUREYN 

		****************************************************************************************************************/
		UPDATE #Account
		SET ERROR = CASE	WHEN ISNULL(InfrastructureYN,'')<>'' AND InfrastructureYN NOT IN('Y','N')  AND ISNULL(ERROR,'')='' THEN 'Infrastructure Flag Either Y OR N'
							WHEN ISNULL(InfrastructureYN,'')<>'' AND InfrastructureYN NOT IN('Y','N')  AND ISNULL(ERROR,'')<>'' THEN ERROR+','+SPACE(1)+'Infrastructure Flag Either Y OR N'
							ELSE ERROR
					END
		


		/****************************************************************************************************************
					
											FOR CHECKING A Repossession Date

		****************************************************************************************************************/
			
			UPDATE A
				SET ERROR =
							-- CASE	WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.RepossessionDate,'')<>''THEN ERROR+','+'Invalid Repossession Date'
							--		WHEN ISNULL(ERROR,'')='' AND ISNULL(A.RepossessionDate,'')<>''	THEN 'Invalid Repossession Date'
							--		WHEN ISNULL(ERROR,'')='' AND ISNULL(A.RepossessionDate,'')=''	THEN 'Repossession Date should not be blank'
							--		WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.RepossessionDate,'')=''	THEN ERROR+','+ 'Repossession Date should not be blank'
							--	ELSE ERROR
							--END
							CASE	WHEN ISNULL(ERROR,'')=''  AND ISNULL(A.RepossessionDate,'')<>'' AND ISNULL(B.correct,0)<>1 
											THEN 'Invalid Repossession Date'

										WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.RepossessionDate,'')<>'' AND ISNULL(B.correct,0)<>1 
													THEN ISNULL(ERROR,'')+','+SPACE(1)+ 'Invalid Repossession Date'

										WHEN ISNULL(ERROR,'')=''  AND ISNULL(A.RepossessionDate,'')='' 
													THEN 'Repossession Date cannot be empty'

										WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.RepossessionDate,'')='' THEN 
													ISNULL(ERROR,'')+','+SPACE(1)+ 'Repossession Date cannot be empty'

									ELSE ERROR
								END
				 FROM #Account A
				LEFT OUTER JOIN 
			(
			
				SELECT RowNum ,1 correct FROM #Account
				WHERE ISDATE(RepossessionDate)=1
				AND (CASE	WHEN SUBSTRING(RTRIM(LTRIM(RepossessionDate)),3,1)='-' 
								AND (LEN(RTRIM(LTRIM(RepossessionDate)))=9 OR LEN(RTRIM(LTRIM(RepossessionDate)))=11 )
								AND ISNUMERIC(SUBSTRING(RTRIM(LTRIM(RepossessionDate)),4,3))=0 
								AND  SUBSTRING(RTRIM(LTRIM(RepossessionDate)),7,1)='-' 
							THEN 1

							WHEN SUBSTRING(RTRIM(LTRIM(RepossessionDate)),3,1)='/'
							AND (LEN(RTRIM(LTRIM(RepossessionDate)))=8 OR LEN(RTRIM(LTRIM(RepossessionDate)))=10 )
							 AND  SUBSTRING(RTRIM(LTRIM(RepossessionDate)),6,1)='/' THEN 1
					END)=1


			)B 
			ON A.RowNum = B.RowNum
			WHERE ISNULL(B.RowNum,'')=''  AND ISNULL(A.RepossessionDate,'')<>''

		/****************************************************************************************************************
					
											FOR CHECKING A RESTRUCTURED DATE

		****************************************************************************************************************/
		
				
				UPDATE A
				SET ERROR = 
							--CASE	WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.RestructureDate,'')<>''	THEN ERROR+','+'Invalid Restructure Date'
							--		WHEN ISNULL(ERROR,'')='' AND ISNULL(A.RestructureDate,'')<>''	THEN 'Invalid Restructure Date'
							--		WHEN ISNULL(ERROR,'')='' AND ISNULL(A.RestructureDate,'')=''	THEN 'Restructure Date cannot be empty'
							--		WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.RestructureDate,'')=''	THEN ERROR+','+'Restructure Date cannot be empty'

							--	ELSE ERROR
							--END
							CASE	WHEN ISNULL(ERROR,'')=''  AND ISNULL(A.RestructureDate,'')<>'' AND ISNULL(B.correct,0)<>1 
											THEN 'Invalid Restructure Date'

										WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.RestructureDate,'')<>'' AND ISNULL(B.correct,0)<>1 
													THEN ISNULL(ERROR,'')+','+SPACE(1)+ 'Invalid Restructure Date'

										WHEN ISNULL(ERROR,'')=''  AND ISNULL(A.RestructureDate,'')='' 
													THEN 'Restructure Date cannot be empty'

										WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.RestructureDate,'')='' THEN 
													ISNULL(ERROR,'')+','+SPACE(1)+ 'Restructure Date cannot be empty'

									ELSE ERROR
								END
				
				 FROM #Account A
				LEFT OUTER JOIN 
			(
			--SELECT 1
				SELECT RowNum ,1 correct FROM #Account
				WHERE ISDATE(RestructureDate)=1
				AND (CASE	WHEN SUBSTRING(RTRIM(LTRIM(RestructureDate)),3,1)='-' 
								AND (LEN(RTRIM(LTRIM(RestructureDate)))=9 OR LEN(RTRIM(LTRIM(RestructureDate)))=11 )
								AND ISNUMERIC(SUBSTRING(RTRIM(LTRIM(RestructureDate)),4,3))=0 
								AND  SUBSTRING(RTRIM(LTRIM(RestructureDate)),7,1)='-' 
							THEN 1

							WHEN SUBSTRING(RTRIM(LTRIM(RestructureDate)),3,1)='/'
							AND (LEN(RTRIM(LTRIM(RestructureDate)))=8 OR LEN(RTRIM(LTRIM(RestructureDate)))=10 )
							 AND  SUBSTRING(RTRIM(LTRIM(RestructureDate)),6,1)='/' THEN 1
					END)=1
			)B 
			ON A.RowNum = B.RowNum
			WHERE ISNULL(B.RowNum,'')='' 
			AND ISNULL(A.RestructureDate,'')<>''




			/****************************************************************************************************************
					
											FOR CHECKING A OriginalDCCODate DATE

		****************************************************************************************************************/
	
				
				UPDATE A
				SET ERROR = 
						--CASE	WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.OriginalDCCODate,'')<>''	THEN ERROR+','+'Invalid OriginalDCCO Date'
						--			WHEN ISNULL(ERROR,'')='' AND ISNULL(A.OriginalDCCODate,'')<>''	THEN 'Invalid OriginalDCCO Date'
						--			--WHEN ISNULL(ERROR,'')='' AND ISNULL(A.OriginalDCCODate,'')=''	THEN 'OriginalDCCO Date cannot be empty/ Invalid  Date'
						--			--WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.OriginalDCCODate,'')=''	THEN ERROR+','+'Restructure Date cannot be empty'

						--		ELSE ERROR
						--	END
						CASE	WHEN ISNULL(ERROR,'')=''  AND ISNULL(A.OriginalDCCODate,'')<>'' AND ISNULL(B.correct,0)<>1 
											THEN 'Invalid OriginalDCCO Date'

										WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.OriginalDCCODate,'')<>'' AND ISNULL(B.correct,0)<>1 
													THEN ISNULL(ERROR,'')+','+SPACE(1)+ 'Invalid OriginalDCCO Date'

										WHEN ISNULL(ERROR,'')=''  AND ISNULL(A.OriginalDCCODate,'')='' 
													THEN 'OriginalDCCO Date cannot be empty'

										WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.OriginalDCCODate,'')='' THEN 
													ISNULL(ERROR,'')+','+SPACE(1)+ 'OriginalDCCO Date cannot be empty'

									ELSE ERROR
								END
				
				 FROM #Account A
				LEFT OUTER JOIN 
			(
			--SELECT 1
				SELECT RowNum ,1 correct FROM #Account
				WHERE ISDATE(OriginalDCCODate)=1
				AND (CASE	WHEN SUBSTRING(RTRIM(LTRIM(OriginalDCCODate)),3,1)='-' 
								AND (LEN(RTRIM(LTRIM(OriginalDCCODate)))=9 OR LEN(RTRIM(LTRIM(OriginalDCCODate)))=11 )
								AND ISNUMERIC(SUBSTRING(RTRIM(LTRIM(OriginalDCCODate)),4,3))=0 
								AND  SUBSTRING(RTRIM(LTRIM(OriginalDCCODate)),7,1)='-' 
							THEN 1

							WHEN SUBSTRING(RTRIM(LTRIM(OriginalDCCODate)),3,1)='/'
							AND (LEN(RTRIM(LTRIM(OriginalDCCODate)))=8 OR LEN(RTRIM(LTRIM(OriginalDCCODate)))=10 )
							 AND  SUBSTRING(RTRIM(LTRIM(OriginalDCCODate)),6,1)='/' THEN 1
					END)=1
			)B 
			ON A.RowNum = B.RowNum
			WHERE ISNULL(A.OriginalDCCODate,'')<>'' AND ISNULL(B.RowNum,'')=''  
			
		
		/****************************************************************************************************************
					
											FOR CHECKING A ExtendedDCCODate DATE

		****************************************************************************************************************/

				
				UPDATE A
				SET ERROR = 
							--CASE	WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.ExtendedDCCODate,'')<>''	THEN ERROR+','+'Invalid OriginalDCCO Date'
							--		WHEN ISNULL(ERROR,'')='' AND ISNULL(A.ExtendedDCCODate,'')<>''	THEN 'Invalid OriginalDCCO Date'
							--		--WHEN ISNULL(ERROR,'')='' AND ISNULL(A.OriginalDCCODate,'')=''	THEN 'OriginalDCCO Date cannot be empty/ Invalid  Date'
							--		--WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.OriginalDCCODate,'')=''	THEN ERROR+','+'Restructure Date cannot be empty'

							--	ELSE ERROR
							--END
							CASE	WHEN ISNULL(ERROR,'')=''  AND ISNULL(A.ExtendedDCCODate,'')<>'' AND ISNULL(B.correct,0)<>1 
											THEN 'Invalid Extended DCCO Date'

										WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.ExtendedDCCODate,'')<>'' AND ISNULL(B.correct,0)<>1 
													THEN ISNULL(ERROR,'')+','+SPACE(1)+ 'Invalid Extended DCCO Date'

										WHEN ISNULL(ERROR,'')=''  AND ISNULL(A.ExtendedDCCODate,'')='' 
													THEN 'Extended DCCO Date cannot be empty'

										WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.ExtendedDCCODate,'')='' THEN 
													ISNULL(ERROR,'')+','+SPACE(1)+ 'Extended DCCO Date cannot be empty'

									ELSE ERROR
								END
				
				 FROM #Account A
				LEFT OUTER JOIN 
			(
			
				SELECT RowNum ,1 correct FROM #Account
				WHERE ISDATE(ExtendedDCCODate)=1
				AND (CASE	WHEN SUBSTRING(RTRIM(LTRIM(ExtendedDCCODate)),3,1)='-' 
								AND (LEN(RTRIM(LTRIM(ExtendedDCCODate)))=9 OR LEN(RTRIM(LTRIM(ExtendedDCCODate)))=11 )
								AND ISNUMERIC(SUBSTRING(RTRIM(LTRIM(ExtendedDCCODate)),4,3))=0 
								AND  SUBSTRING(RTRIM(LTRIM(ExtendedDCCODate)),7,1)='-' 
							THEN 1

							WHEN SUBSTRING(RTRIM(LTRIM(ExtendedDCCODate)),3,1)='/'
							AND (LEN(RTRIM(LTRIM(ExtendedDCCODate)))=8 OR LEN(RTRIM(LTRIM(ExtendedDCCODate)))=10 )
							 AND  SUBSTRING(RTRIM(LTRIM(ExtendedDCCODate)),6,1)='/' THEN 1
					END)=1
			)B 
			ON A.RowNum = B.RowNum
			WHERE ISNULL(A.ExtendedDCCODate,'')<>'' AND ISNULL(B.RowNum,'')=''  
			
	


		/****************************************************************************************************************
					
											FOR CHECKING A ActualDCCODate DATE

		****************************************************************************************************************/
	
				UPDATE A
				SET ERROR = 
							--CASE	WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.ActualDCCODate,'')<>''	THEN ERROR+','+'Invalid ActualDCCO Date'
							--		WHEN ISNULL(ERROR,'')='' AND ISNULL(A.ActualDCCODate,'')<>''	THEN 'Invalid ActualDCCO Date'
							--		--WHEN ISNULL(ERROR,'')='' AND ISNULL(A.OriginalDCCODate,'')=''	THEN 'OriginalDCCO Date cannot be empty/ Invalid  Date'
							--		--WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.OriginalDCCODate,'')=''	THEN ERROR+','+'Restructure Date cannot be empty'

							--	ELSE ERROR
							--END

							CASE	WHEN ISNULL(ERROR,'')=''  AND ISNULL(A.ActualDCCODate,'')<>'' AND ISNULL(B.correct,0)<>1 
											THEN 'Invalid Actual DCCO Date'

										WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.ActualDCCODate,'')<>'' AND ISNULL(B.correct,0)<>1 
													THEN ISNULL(ERROR,'')+','+SPACE(1)+ 'Invalid Actual DCCO Date'

										WHEN ISNULL(ERROR,'')=''  AND ISNULL(A.ActualDCCODate,'')='' 
													THEN 'Actual DCCO Date cannot be empty'

										WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.ActualDCCODate,'')='' THEN 
													ISNULL(ERROR,'')+','+SPACE(1)+ 'Actual DCCO Date cannot be empty'

									ELSE ERROR
								END
				
				 FROM #Account A
				LEFT OUTER JOIN 
			(
			--SELECT 1
				SELECT RowNum ,1 correct FROM #Account
				WHERE ISDATE(ActualDCCODate)=1
				AND (CASE	WHEN SUBSTRING(RTRIM(LTRIM(ActualDCCODate)),3,1)='-' 
								AND (LEN(RTRIM(LTRIM(ActualDCCODate)))=9 OR LEN(RTRIM(LTRIM(ActualDCCODate)))=11 )
								AND ISNUMERIC(SUBSTRING(RTRIM(LTRIM(ActualDCCODate)),4,3))=0 
								AND  SUBSTRING(RTRIM(LTRIM(ActualDCCODate)),7,1)='-' 
							THEN 1

							WHEN SUBSTRING(RTRIM(LTRIM(ActualDCCODate)),3,1)='/'
							AND (LEN(RTRIM(LTRIM(ActualDCCODate)))=8 OR LEN(RTRIM(LTRIM(ActualDCCODate)))=10 )
							 AND  SUBSTRING(RTRIM(LTRIM(ActualDCCODate)),6,1)='/' THEN 1
					END)=1
			)B 
			ON A.RowNum = B.RowNum
			WHERE ISNULL(A.ActualDCCODate,'')<>'' AND ISNULL(B.RowNum,'')=''  


		/****************************************************************************************************************
					
											FOR CHECKING A MOCReason

		****************************************************************************************************************/


		UPDATE #Account
		SET ERROR = CASE	WHEN ISNULL(ERROR,'')=''	THEN 'MOC Reason Length should not be  greater then 500 Chararter'
							WHEN ISNULL(ERROR,'')<>''	THEN ERror+','+SPACE(1)+ 'MOC Reason Length should not be  greater then 500 Chararter'
							ELSE ERROR
					END
		WHERE LEN(MOCReason)>500



		/****************************************************************************************************************
					
											FOR CHECKING A STOCK Valuation DATE

		****************************************************************************************************************/
			-- Added By Sourangshu 20241105

		DECLARE @FilePathUpdated_Account VARCHAR(500)
	    SELECT @FilePathUpdated_Account=@UserLoginId+'_'+@filepath

		Delete from  dbo.AccountDataUploadFinal where FILENAME=@FilePathUpdated_Account

		--Added By Sourangshu 

		Declare	@Fraentid int= (Select IDENT_CURRENT('dbo.AccountDataUpload'))



		IF EXISTS(SELECT 1 FROM #Account WHERE ISNULL(ERROR,'')<>'')
		BEGIN
			SELECT	  RowNum
					,CUSTOMERID  
					,CUSTOMERACID
					,BALANCE 
					,ADDITIONALPROVISION
					,ADDITIONALPROVISIONAMOUNT
					,APPROPRIATESECURITY
					,FITL  
					,DFVAMOUNT  
					,INFRASTRUCTUREYN  
					,REPOSSESSIONDATE  
					,RESTRUCTUREDATE  
					,ORIGINALDCCODATE  
					,EXTENDEDDCCODATE  
					,ACTUALDCCODATE
					,MOCREASON
					,ERROR
					,'ErrorData' TableName
			FROM #Account WHERE ISNULL(ERROR,'')<>''
		END
		ELSE
		BEGIN	
			
			SELECT  RowNum
					,CUSTOMERID  
					,CUSTOMERACID
					,BALANCE 
					,ADDITIONALPROVISION
					,ADDITIONALPROVISIONAMOUNT
					,APPROPRIATESECURITY
					,FITL  
					,DFVAMOUNT  
					,INFRASTRUCTUREYN  
					,CASE WHEN ISNULL(RepossessionDate,'')='' THEN NULL ELSE CONVERT(VARCHAR(10),CAST(RepossessionDate AS DATE),103) END REPOSSESSIONDATE
					,CASE WHEN ISNULL(RestructureDate,'')=''  THEN NULL ELSE CONVERT(VARCHAR(10),CAST(RestructureDate AS DATE),103)  END RESTRUCTUREDATE
					,CASE WHEN ISNULL(OriginalDCCODate,'')='' THEN NULL ELSE CONVERT(VARCHAR(10),CAST(OriginalDCCODate AS DATE),103) END ORIGINALDCCODATE
					,CASE WHEN ISNULL(ExtendedDCCODate,'')='' THEN NULL ELSE CONVERT(VARCHAR(10),CAST(ExtendedDCCODate AS DATE),103) END EXTENDEDDCCODATE
					,CASE WHEN ISNULL(ActualDCCODate,'')=''   THEN NULL ELSE CONVERT(VARCHAR(10),CAST(ActualDCCODate AS DATE),103)	 END ACTUALDCCODATE
					,MOCREASON
					,'AccountData' TableName
			FROM #Account WHERE ISNULL(ERROR,'')=''

			insert into dbo.AccountDataUploadFinal
			(
			CUSTOMERID,
			CUSTOMERAcID,
			Balance,
			AdditionalProvision,
			AdditionalProvisionAmount,
			AppropriateSecurity,
			FITL,
			DFVAmount,
			InfrastructureYN,
			RepossessionDate,
			RestructureDate,
			OriginalDCCODate,
			ExtendedDCCODate,
			ActualDCCODate,
			MocReason,
			MocAccountDataEntityId
		)
		select
		    CUSTOMERID,
			CUSTOMERAcID,
			Balance,
			AdditionalProvision,
			AdditionalProvisionAmount,
			AppropriateSecurity,
			FITL,
			DFVAmount,
			InfrastructureYN,
			RepossessionDate,
			RestructureDate,
			OriginalDCCODate,
			ExtendedDCCODate,
			ActualDCCODate,
			MocReason,
			@Fraentid+(ROW_NUMBER() over(order by CUSTOMERACID)) MocAccountDataEntityId
		from
		#Account


		END

		DROP TABLE #Account
END
GO