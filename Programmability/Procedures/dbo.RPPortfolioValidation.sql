SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[RPPortfolioValidation]

@xmlDocument XML=''
,@Timekey	INT = 49999
,@ScreenFlag VARCHAR(20)='Automation' 
AS
SET DATEFORMAT DMY

--declare @todaydate date = (select StartDate from pro.EXTDATE_MISDB where TimeKey=@Timekey)

IF @ScreenFlag = 'Automation'
BEGIN
		IF OBJECT_ID('TEMPDB..#RPPortfoilioData') IS NOT NULL
				DROP TABLE #RPPortfoilioData

SELECT 
ROW_NUMBER()OVER(ORDER BY (SELECT  (1))) RowNum
,C.value('./CustomerEntityID[1]','VARCHAR(30)') CustomerEntityID
,C.value('./UCICID[1]','VARCHAR(30)') UCIC_ID
,C.value('./CustomerID [1]','VARCHAR(30)') CustomerID 
,C.value('./BorrowerPAN [1]','VARCHAR(20)') PAN_No     
--,C.value('./BorrowerName [1]','VARCHAR(255)') CustomerName
,C.value('./BankIDBankCode [1]','VARCHAR(20)') BankCode
--,CASE WHEN C.value('./BorrowerDefaultDate	[1]','VARCHAR(20)')='' THEN NULL ELSE C.value('./BorrowerDefaultDate[1]','VARCHAR(20)') END AS BorrowerDefaultDate
,C.value('./Exposurebucketing [1]','VARCHAR(100)') ExposureBucketName
,C.value('./Bankingarrangement [1]','VARCHAR(100)') BankingArrangementName
,C.value('./Nameofleadbank [1]','VARCHAR(100)') LeadBankName
,C.value('./BorrowerDefaultStatus [1]','VARCHAR(100)') DefaultStatus
,CASE WHEN C.value('./ApproveddateofnatureofResolutionPlan	[1]','VARCHAR(20)')='' THEN NULL ELSE C.value('./ApproveddateofnatureofResolutionPlan[1]','VARCHAR(20)') END AS RP_ApprovalDate
,C.value('./NatureofresolutionPlan [1]','VARCHAR(100)') RPNatureName
,C.value('./IncaseofOtherpleaseadvisenatureofresolutionplan [1]','VARCHAR(500)') If_Other
,C.value('./ImplementationStatus [1]','VARCHAR(100)') ImplementationStatus
,CASE WHEN C.value('./ActualResolutionPlanImplementationDate	[1]','VARCHAR(20)')='' THEN NULL ELSE C.value('./ActualResolutionPlanImplementationDate[1]','VARCHAR(20)') END AS Actual_Impl_Date
,CASE WHEN C.value('./OutofdefaultdatebyallbankspostinitialRPdeadline	[1]','VARCHAR(20)')='' THEN NULL ELSE C.value('./OutofdefaultdatebyallbankspostinitialRPdeadline[1]','VARCHAR(20)') END AS RP_OutOfDateAllBanksDeadline
,CAST(NULL AS VARCHAR(MAX))ERROR
INTO #RPPortfoilioData
FROM @XMLDocument.nodes('/DataSet/Gridrow') AS t(c)

--select * into test1 from #RPPortfoilioData
Declare @Date Date

SET @Date =(Select CAST(B.Date as Date)Date1 from SysDataMatrix A
Inner Join SysDayMatrix B ON A.TimeKey=B.TimeKey
 where A.CurrentStatus='C')


--select * from #RPPortfoilioData


/****************************************************************************************************************
					
											FOR CHECKING A UCIC ID 

****************************************************************************************************************/
		
		UPDATE A
		SET ERROR = CASE	WHEN ISNULL(A.ERROR,'')=''		THEN 'UCIC Id should not be Empty. Please check the values and upload again'
							Else A.ERROR+','+SPACE(1)+'UCIC Id should not be Empty. Please check the values and upload again' END
							
					
		FROM #RPPortfoilioData A
		Where ISNULL(A.UCIC_ID,'')=''
		--LEFT OUTER JOIN PRO.CustomerCal C
		--	ON A.UCIC_ID = C.UCIF_ID --C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey	AND A.UCIC_ID = C.UCIF_ID


		UPDATE A
		SET ERROR = CASE	WHEN ISNULL(A.ERROR,'')=''		THEN 'Invalid UCIC ID,  Please check the values and upload again'
							Else A.ERROR+','+SPACE(1)+'Invalid UCIC ID,  Please check the values and upload again' END
							
					
		FROM #RPPortfoilioData A
		Where ISNULL(A.UCIC_ID,'')<>''
		And Not exists (Select 1 from PRO.CustomerCal C where C.UCIF_ID=A.UCIC_ID)

		
/****************************************************************************************************************
					
											FOR CHECKING A CUSTOMER  ID 

****************************************************************************************************************/

		UPDATE A
		SET ERROR = CASE	WHEN ISNULL(A.ERROR,'')=''		THEN 'Customer ID should not be Empty. Please check the values and upload again'
							Else A.ERROR+','+SPACE(1)+'Customer ID should not be Empty. Please check the values and upload again' END

		FROM #RPPortfoilioData A
		WHere ISNULL(A.CustomerID,'')=''	
		--LEFT OUTER JOIN PRO.CustomerCal C
		--	ON A.CustomerID = C.RefCustomerID --C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey	AND A.CUSTOMERID = C.RefCustomerID
		

		UPDATE A
		SET ERROR = CASE	WHEN ISNULL(A.ERROR,'')=''		THEN 'Invalid Customer ID,  Please check the values and upload again'
							Else A.ERROR+','+SPACE(1)+'Invalid Customer ID,  Please check the values and upload again' END
							
					
		FROM #RPPortfoilioData A
		Where ISNULL(A.CustomerID,'')<>''
		AND Not exists (Select 1 from PRO.CustomerCal C where C.RefCustomerID=A.CustomerID)


		/****************************************************************************************************************
					
											FOR CHECKING A PAN_No

		****************************************************************************************************************/
			
			
		UPDATE A
		SET ERROR = CASE	WHEN ISNULL(A.ERROR,'')=''		THEN 'PAN NO should not be Empty. Please check the values and upload again'
							Else A.ERROR+','+SPACE(1)+'PAN NO should not be Empty. Please check the values and upload again' END

		FROM 
		#RPPortfoilioData A
		--LEFT OUTER  JOIN PRO.CUSTOMERCAL  C
		--	ON C.PANNO = A.PAN_No --C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey	AND C.PANNO = A.PAN_No
		WHERE ISNULL(A.PAN_No,'')=''


		UPDATE A
		SET ERROR = CASE	WHEN ISNULL(A.ERROR,'')=''		THEN 'Invalid PAN NO,  Please check the values and upload again'
							Else A.ERROR+','+SPACE(1)+'Invalid PAN NO,  Please check the values and upload again' END

		FROM 
		#RPPortfoilioData A
		--LEFT OUTER  JOIN PRO.CUSTOMERCAL  C
		--	ON C.PANNO = A.PAN_No --C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey	AND C.PANNO = A.PAN_No
		WHERE ISNULL(PAN_No,'')<>''
		AND Not exists (Select 1 from PRO.CustomerCal C where C.RefCustomerID=A.CustomerID ANd C.PANNO=A.PAN_No)



		--UPDATE A
		--SET ERROR = CASE	WHEN  ISNULL(C.PANNO,'')='' AND ISNULL(ERROR,'')=''	THEN 'PAN No Not Belong to that Customer Id'

		--					WHEN ISNULL(C.PANNO,'')='' AND ISNULL(ERROR,'')<>''	THEN  ISNULL(ERROR,'')+','+SPACE(1)+'PAN NO Not Belong to that Customer Id'
		--					ELSE ERROR
		--			END
		
		--FROM #RPPortfoilioData A
		--LEFT OUTER JOIN PRO.CustomerCal C
		--	ON A.CustomerID = C.RefCustomerID	AND A.UCIC_ID = C.UCIF_ID --C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey		AND A.CustomerID = C.RefCustomerID		AND A.UCICID = C.UCIF_ID
		--WHERE  ISNULL(A.UCIC_ID,'')<>''
				
		
		
		
		
/****************************************************************************************************************
					
											FOR CHECKING A CustomerName

****************************************************************************************************************

				UPDATE A
		SET ERROR = CASE	WHEN ISNULL(A.CustomerName,'')=''		THEN 'CustomerName should not be Empty'
							--WHEN ISNULL(C.CustomerName,'')=''	THEN 'Invalid Customer Name'
							ELSE ERROR
					END
		FROM #RPPortfoilioData A
		--LEFT OUTER JOIN PRO.CustomerCal C
			--ON A.CustomerName = C.CustomerName --C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey	AND A.CUSTOMERID = C.RefCustomerID */





/****************************************************************************************************************
					
											FOR CHECKING BankCode

****************************************************************************************************************/


		UPDATE A
		SET ERROR = CASE	WHEN ISNULL(A.ERROR,'')=''		THEN 'Bank Code should not be Empty. Please check the values and upload again'
							Else A.ERROR+','+SPACE(1)+'Bank Code should not be Empty. Please check the values and upload again' END

		FROM #RPPortfoilioData A
		--Left Outer Join DimBankRP B
		--ON A.BankCode=B.BankCode
		Where ISNULL(A.BankCode,'')=''


		UPDATE A
		SET ERROR = CASE	WHEN ISNULL(A.ERROR,'')=''		THEN 'Invalid Bank Code. Please check the values and upload again'
							Else A.ERROR+','+SPACE(1)+'Invalid Bank Code. Please check the values and upload again' END

		FROM #RPPortfoilioData A
		--Left Outer Join DimBankRP B
		--ON A.BankCode=B.BankCode
		Where ISNULL(A.BankCode,'')<>''
		And not exists (Select 1 from DimBankRP B where A.BankCode=B.BankCode And B.EffectiveToTimeKey=49999)

/****************************************************************************************************************
					
											FOR CHECKING A BorrowerDefaultDate

****************************************************************************************************************/
			
		
				
			--	UPDATE A
			--	SET ERROR = 
			--					CASE	WHEN ISNULL(ERROR,'')=''  AND ISNULL(A.BorrowerDefaultDate,'')<>'' AND ISNULL(B.correct,0)<>1 
			--								THEN 'Invalid BorrowerDefaultDate'

			--							WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.BorrowerDefaultDate,'')<>'' AND ISNULL(B.correct,0)<>1 
			--										THEN ISNULL(ERROR,'')+','+SPACE(1)+ 'Invalid BorrowerDefaultDate'

			--							WHEN ISNULL(ERROR,'')=''  AND ISNULL(A.BorrowerDefaultDate,'')='' 
			--										THEN 'BorrowerDefaultDate cannot be empty'

			--							WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.BorrowerDefaultDate,'')='' THEN 
			--										ISNULL(ERROR,'')+','+SPACE(1)+ 'BorrowerDefaultDate cannot be empty'

			--						ELSE ERROR
			--					END
			--	 FROM #RPPortfoilioData A
			--	LEFT OUTER JOIN 
			--(
			----SELECT 1
			--	SELECT RowNum ,1 correct FROM #RPPortfoilioData
			--	WHERE ISDATE(BorrowerDefaultDate)=1
			--	AND (CASE	WHEN SUBSTRING(RTRIM(LTRIM(BorrowerDefaultDate)),3,1)='-' 
			--					AND (LEN(RTRIM(LTRIM(BorrowerDefaultDate)))=9 OR LEN(RTRIM(LTRIM(BorrowerDefaultDate)))=11 )
			--					AND ISNUMERIC(SUBSTRING(RTRIM(LTRIM(BorrowerDefaultDate)),4,3))=0 
			--					AND  SUBSTRING(RTRIM(LTRIM(BorrowerDefaultDate)),7,1)='-' 
			--				THEN 1

			--				WHEN SUBSTRING(RTRIM(LTRIM(BorrowerDefaultDate)),3,1)='/'
			--				AND (LEN(RTRIM(LTRIM(BorrowerDefaultDate)))=8 OR LEN(RTRIM(LTRIM(BorrowerDefaultDate)))=10 )
			--				 AND  SUBSTRING(RTRIM(LTRIM(BorrowerDefaultDate)),6,1)='/' THEN 1
			--		END)=1
			--)B 
			--ON A.RowNum = B.RowNum
			--WHERE ISNULL(B.RowNum,'')='' 




/****************************************************************************************************************
					
											FOR CHECKING ExposureBucketName

****************************************************************************************************************/


		UPDATE A
		SET ERROR = CASE	WHEN ISNULL(A.ERROR,'')=''		THEN 'ExposureBucketName should not be Empty. Please check the values and upload again'
							Else A.ERROR+','+SPACE(1)+'ExposureBucketName should not be Empty. Please check the values and upload again' END

		FROM #RPPortfoilioData A
		--LEFT OUTER JOIN DimExposureBucket B
		--ON A. ExposureBucketName=B.BucketName
		Where ISNULL(A.ExposureBucketName,'')=''


		UPDATE A
		SET ERROR = CASE	WHEN ISNULL(A.ERROR,'')=''		THEN ' Invalid ExposureBucketName. Please check the values and upload again'
							Else A.ERROR+','+SPACE(1)+'Invalid ExposureBucketName. Please check the values and upload again' END

		FROM #RPPortfoilioData A
		--LEFT OUTER JOIN DimExposureBucket B
		--ON A. ExposureBucketName=B.BucketName
		Where ISNULL(A.ExposureBucketName,'')<>''
		And Not exists(Select 1 from DimExposureBucket B where A.ExposureBucketName=B.BucketName And B.EffectiveToTimeKey=49999)


/****************************************************************************************************************
					
											FOR CHECKING BankingArrangementName

****************************************************************************************************************/


		UPDATE A
		SET ERROR = CASE	WHEN ISNULL(A.ERROR,'')=''		THEN 'BankingArrangementName should not be Empty. Please check the values and upload again'
							Else A.ERROR+','+SPACE(1)+'BankingArrangementName should not be Empty. Please check the values and upload again' END

		FROM #RPPortfoilioData A
		--LEFT OUTER JOIN DimBankingArrangement B
		--ON A.BankingArrangementName=B.ArrangementDescription
		Where ISNULL(A.BankingArrangementName,'')=''

		
		UPDATE A
		SET ERROR = CASE	WHEN ISNULL(A.ERROR,'')=''		THEN 'Invalid BankingArrangementName. Please check the values and upload again'
							Else A.ERROR+','+SPACE(1)+'Invalid BankingArrangementName. Please check the values and upload again' END

		FROM #RPPortfoilioData A
		--LEFT OUTER JOIN DimBankingArrangement B
		--ON A.BankingArrangementName=B.ArrangementDescription
		Where ISNULL(A.BankingArrangementName,'')<>''
		ANd Not exists (Select 1 from DimBankingArrangement B where A.BankingArrangementName=B.ArrangementDescription And B.EffectiveToTimeKey=49999)


/****************************************************************************************************************
					
											FOR CHECKING LeadBankName

****************************************************************************************************************/


		UPDATE A
		SET ERROR =  CASE	WHEN ISNULL(A.ERROR,'')=''		THEN 'LeadBankName should not be Empty. Please check the values and upload again'
							Else A.ERROR+','+SPACE(1)+'LeadBankName should not be Empty. Please check the values and upload again' END

		FROM #RPPortfoilioData A
		--LEFT OUTER JOIN DimBankRP B
		--ON A.LeadBankName=B.BankName
		Where ISNULL(A.LeadBankName,'')=''
		And  exists(Select 1 from DimBankingArrangement B where A.BankingArrangementName=B.ArrangementDescription 
		--And B.EffectiveToTimeKey=49999 and B.ArrangementDescription='Sole')
		And B.EffectiveToTimeKey=49999 and B.ArrangementDescription='Consortium')

		--select * from DimBankingArrangement

		UPDATE A
		SET ERROR =  CASE	WHEN ISNULL(A.ERROR,'')=''		THEN 'Invalid LeadBankName. Please check the values and upload again'
							Else A.ERROR+','+SPACE(1)+'Invalid LeadBankName. Please check the values and upload again' END

		FROM #RPPortfoilioData A
		--LEFT OUTER JOIN DimBankRP B
		--ON A.LeadBankName=B.BankName
		Where ISNULL(A.LeadBankName,'')<>''
		And not exists (Select 1 from DimBankRP B where A.LeadBankName=B.BankName and B.EffectiveToTimeKey=49999)

	


/****************************************************************************************************************
					
											FOR CHECKING DefaultStatus

****************************************************************************************************************/


		UPDATE A
		SET ERROR =  CASE	WHEN ISNULL(A.ERROR,'')=''		THEN 'DefaultStatus should not be Empty. Please check the values and upload again'
							Else A.ERROR+','+SPACE(1)+'DefaultStatus should not be Empty. Please check the values and upload again' END

		FROM #RPPortfoilioData A
		Where ISNULL(A.DefaultStatus,'')=''

		UPDATE A
		SET ERROR =  CASE	WHEN ISNULL(A.ERROR,'')=''		THEN 'DefaultStatus values should be ''In Default'' or ''Out Default'' . Please check the values and upload again'
							Else A.ERROR+','+SPACE(1)+'DefaultStatus values should be  ''In Default'' ,or ''Out Default'' . Please check the values and upload again' END

		FROM #RPPortfoilioData A
		Where ISNULL(A.DefaultStatus,'')<>'' and ISNULL(A.DefaultStatus,'') not in ('In Default','Out Default')

/****************************************************************************************************************
					
											FOR CHECKING RP_ApprovalDate

****************************************************************************************************************/
 

			--			UPDATE A
			--	SET ERROR = 
			--					CASE	WHEN ISNULL(ERROR,'')=''  AND ISNULL(A.RP_ApprovalDate,'')<>'' AND ISNULL(B.correct,0)<>1 
			--								THEN 'Invalid RP_ApprovalDate'

			--							WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.RP_ApprovalDate,'')<>'' AND ISNULL(B.correct,0)<>1 
			--										THEN ISNULL(ERROR,'')+','+SPACE(1)+ 'Invalid RP_ApprovalDate'

			--							WHEN ISNULL(ERROR,'')=''  AND ISNULL(A.RP_ApprovalDate,'')='' 
			--										THEN 'RP_ApprovalDate cannot be empty'

			--							WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.RP_ApprovalDate,'')='' THEN 
			--										ISNULL(ERROR,'')+','+SPACE(1)+ 'RP_ApprovalDate cannot be empty'

			--							--WHEN    CONVERT(date,A.RP_ApprovalDate,101)> CONVERT(date,@Date,101) THEN 
			--							--			ISNULL(ERROR,'')+','+SPACE(1)+ 'Date Cannot be future Date'

			--						ELSE ERROR
			--					END
			--	 FROM #RPPortfoilioData A
			--	LEFT OUTER JOIN 
			--(
			----SELECT 1
			--	SELECT RowNum ,1 correct FROM #RPPortfoilioData
			--	WHERE ISDATE(RP_ApprovalDate)=1
			--	AND (CASE	WHEN SUBSTRING(RTRIM(LTRIM(RP_ApprovalDate)),3,1)='-' 
			--					AND (LEN(RTRIM(LTRIM(RP_ApprovalDate)))=9 OR LEN(RTRIM(LTRIM(RP_ApprovalDate)))=11 )
			--					AND ISNUMERIC(SUBSTRING(RTRIM(LTRIM(RP_ApprovalDate)),4,3))=0 
			--					AND  SUBSTRING(RTRIM(LTRIM(RP_ApprovalDate)),7,1)='-' 
			--				THEN 1

			--				WHEN SUBSTRING(RTRIM(LTRIM(RP_ApprovalDate)),3,1)='/'
			--				AND (LEN(RTRIM(LTRIM(RP_ApprovalDate)))=8 OR LEN(RTRIM(LTRIM(RP_ApprovalDate)))=10 )
			--				 AND  SUBSTRING(RTRIM(LTRIM(RP_ApprovalDate)),6,1)='/' THEN 1
			--		END)=1
			--)B 
			--ON A.RowNum = B.RowNum
			--WHERE ISNULL(B.RowNum,'')='' 


			---not Mandatery   ''

			UPDATE A
		SET ERROR =  CASE	WHEN ISNULL(A.ERROR,'')=''		THEN 'RP_ApprovalDate should not be Empty. Please check the values and upload again'
							Else A.ERROR+','+SPACE(1)+'RP_ApprovalDate should not be Empty. Please check the values and upload again' END

		FROM #RPPortfoilioData A
		Where ISNULL(A.RP_ApprovalDate,'')=''

		UPDATE A
		SET ERROR =  CASE	WHEN ISNULL(A.ERROR,'')=''		THEN 'Invalid RP_ApprovalDate. Please check the values and upload again'
							Else A.ERROR+','+SPACE(1)+'Invalid RP_ApprovalDate. Please check the values and upload again' END

		FROM #RPPortfoilioData A
		Where ISNULL(A.RP_ApprovalDate,'')<>''
		AND ISDATE(A.RP_ApprovalDate)=0



		 
			UPDATE A
				SET ERROR = 
								CASE	WHEN   ISNULL(ERROR,'')=''  THEN 'RP_ApprovalDate Date Cannot be future Date'
													ELSE ISNULL(ERROR,'')+','+SPACE(1)+ 'RP_ApprovalDate Date Cannot be future Date'
								END

				 FROM #RPPortfoilioData A
				 Where  ISDATE(A.RP_ApprovalDate)<>0
				 --And CONVERT(date,A.RP_ApprovalDate,103)> CONVERT(date,@Date,103)
				 --and  RP_ApprovalDate= case when ISDATE(A.RP_ApprovalDate)=1 
				 and  (Case When ISDATE(RP_ApprovalDate)=1 Then Case When Cast(RP_ApprovalDate as date)>Cast(@Date as Date) Then 1 Else 0 END END)=1
             

/****************************************************************************************************************
					
											FOR CHECKING RPNatureName

****************************************************************************************************************/


		--UPDATE A
		--SET ERROR = CASE	WHEN ISNULL(A.ERROR,'')=''		THEN 'RPNatureName should not be Empty. Please check the values and upload again'
		--					Else A.ERROR+','+SPACE(1)+'RPNatureName should not be Empty. Please check the values and upload again' END

		--FROM #RPPortfoilioData A
		----LEFT OUTER JOIN DimResolutionPlanNature B
		----ON A.RPNatureName=B.RPDescription
		--Where ISNULL(A.RPNatureName,'')=''


		UPDATE A
		SET ERROR = CASE	WHEN ISNULL(A.ERROR,'')=''		THEN 'Invalid RPNatureName. Please check the values and upload again'
							Else A.ERROR+','+SPACE(1)+'Invalid RPNatureName. Please check the values and upload again' END

		FROM #RPPortfoilioData A
		--LEFT OUTER JOIN DimResolutionPlanNature B
		--ON A.RPNatureName=B.RPDescription
		Where ISNULL(A.RPNatureName,'')<>''
		And Not exists (Select 1 from DimResolutionPlanNature B where A.RPNatureName=B.RPDescription And B.EffectiveToTimeKey=49999)
		                                --and B.RPDescription='Rectification')
--select * from DimResolutionPlanNature
/****************************************************************************************************************
					
											FOR CHECKING If_Other   ---not Mandatory

****************************************************************************************************************/
/*

		UPDATE A
		SET ERROR = CASE	WHEN ISNULL(A.ERROR,'')=''		THEN 'If_Other should not be Empty. Please check the values and upload again'
							Else A.ERROR+','+SPACE(1)+'If_Other should not be Empty. Please check the values and upload again' END

		FROM #RPPortfoilioData A
		--Inner JOIN DimResolutionPlanNature B
		--ON A.RPNatureName=B.RPDescription
		--where B.RPDescription='Other'
		Where ISNULL(A.If_Other,'')=''
		And  exists (Select 1 from DimResolutionPlanNature B where A.RPNatureName=B.RPDescription And B.EffectiveToTimeKey=49999 And B.RPDescription='Other') 

*/

/****************************************************************************************************************
					
											FOR CHECKING ImplementationStatus  ---not mandatory

****************************************************************************************************************/
/*

		UPDATE A
		SET ERROR = CASE	WHEN ISNULL(A.ERROR,'')=''		THEN 'ImplementationStatus should not be Empty. Please check the values and upload again'
							Else A.ERROR+','+SPACE(1)+'ImplementationStatus should not be Empty. Please check the values and upload again' END

		FROM #RPPortfoilioData A
		where ISNULL(A.ImplementationStatus,'')=''
*/

/****************************************************************************************************************
					
											FOR CHECKING Actual_Impl_Date

****************************************************************************************************************/


			--					UPDATE A
			--	SET ERROR = 
			--					CASE	WHEN ISNULL(ERROR,'')=''  AND ISNULL(A.Actual_Impl_Date,'')<>'' AND ISNULL(B.correct,0)<>1 
			--								THEN 'Invalid Actual_Impl_Date'

			--							WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.Actual_Impl_Date,'')<>'' AND ISNULL(B.correct,0)<>1 
			--										THEN ISNULL(ERROR,'')+','+SPACE(1)+ 'Invalid Actual_Impl_Date'

			--							WHEN ISNULL(ERROR,'')=''  AND ISNULL(A.Actual_Impl_Date,'')='' 
			--										THEN 'Actual_Impl_Date cannot be empty'

			--							WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.Actual_Impl_Date,'')='' THEN 
			--										ISNULL(ERROR,'')+','+SPACE(1)+ 'Actual_Impl_Date cannot be empty'
			--							--WHEN ISNULL(ERROR,'')<>'' AND (Convert(date,A.Actual_Impl_Date,103)>convert(date,@Date,103)) THEN 
			--							--			ISNULL(ERROR,'')+','+SPACE(1)+ 'Date Cannot be future Date'

			--						ELSE ERROR
			--					END
			--	 FROM #RPPortfoilioData A
			--	LEFT OUTER JOIN 
			--(
			----SELECT 1
			--	SELECT RowNum ,1 correct FROM #RPPortfoilioData
			--	WHERE ISDATE(Actual_Impl_Date)=1
			--	AND (CASE	WHEN SUBSTRING(RTRIM(LTRIM(Actual_Impl_Date)),3,1)='-' 
			--					AND (LEN(RTRIM(LTRIM(Actual_Impl_Date)))=9 OR LEN(RTRIM(LTRIM(Actual_Impl_Date)))=11 )
			--					AND ISNUMERIC(SUBSTRING(RTRIM(LTRIM(Actual_Impl_Date)),4,3))=0 
			--					AND  SUBSTRING(RTRIM(LTRIM(Actual_Impl_Date)),7,1)='-' 
			--				THEN 1

			--				WHEN SUBSTRING(RTRIM(LTRIM(Actual_Impl_Date)),3,1)='/'
			--				AND (LEN(RTRIM(LTRIM(Actual_Impl_Date)))=8 OR LEN(RTRIM(LTRIM(Actual_Impl_Date)))=10 )
			--				 AND  SUBSTRING(RTRIM(LTRIM(Actual_Impl_Date)),6,1)='/' THEN 1
			--		END)=1
			--)B 
			--ON A.RowNum = B.RowNum
			--WHERE ISNULL(B.RowNum,'')='' 

			----not mandatory
		--	UPDATE A
		--SET ERROR =  CASE	WHEN ISNULL(A.ERROR,'')=''		THEN 'Actual_Impl_Date should not be Empty. Please check the values and upload again'
		--					Else A.ERROR+','+SPACE(1)+'Actual_Impl_Date should not be Empty. Please check the values and upload again' END

		--FROM #RPPortfoilioData A
		--Where ISNULL(A.Actual_Impl_Date,'')=''

		UPDATE A
		SET ERROR =  CASE	WHEN ISNULL(A.ERROR,'')=''		THEN 'Invalid Actual_Impl_Date. Please check the values and upload again'
							Else A.ERROR+','+SPACE(1)+'Invalid Actual_Impl_Date. Please check the values and upload again' END

		FROM #RPPortfoilioData A
		Where ISNULL(A.Actual_Impl_Date,'')<>''
		AND ISDATE(A.Actual_Impl_Date)=0





			----------------Added on 22-01-2021

			UPDATE A
				SET ERROR = 
								CASE	WHEN   ISNULL(ERROR,'')=''  THEN 'Actual_Impl_Date Date Cannot be future Date'
													ELSE ISNULL(ERROR,'')+','+SPACE(1)+ 'Actual_Impl_Date Date Cannot be future Date'
								END
				 FROM #RPPortfoilioData A
				 Where Isdate(A.Actual_Impl_Date)=1
				 --And CONVERT(date,A.Actual_Impl_Date,103)> CONVERT(date,@Date,103)
				 and  (Case When ISDATE(Actual_Impl_Date)=1 Then Case When Cast(Actual_Impl_Date as date)>Cast(@Date as Date) Then 1 Else 0 END END)=1

/****************************************************************************************************************
					
											FOR CHECKING RP_OutOfDateAllBanksDeadline

****************************************************************************************************************/


			--							UPDATE A
			--	SET ERROR = 
			--					CASE	WHEN ISNULL(ERROR,'')=''  AND ISNULL(A.RP_OutOfDateAllBanksDeadline,'')<>'' AND ISNULL(B.correct,0)<>1 
			--								THEN 'Invalid RP_OutOfDateAllBanksDeadline'

			--							WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.RP_OutOfDateAllBanksDeadline,'')<>'' AND ISNULL(B.correct,0)<>1 
			--										THEN ISNULL(ERROR,'')+','+SPACE(1)+ 'RP_OutOfDateAllBanksDeadline Actual_Impl_Date'

			--							WHEN ISNULL(ERROR,'')=''  AND ISNULL(A.RP_OutOfDateAllBanksDeadline,'')='' 
			--										THEN 'RP_OutOfDateAllBanksDeadline cannot be empty'

			--							WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.RP_OutOfDateAllBanksDeadline,'')='' THEN 
			--										ISNULL(ERROR,'')+','+SPACE(1)+ 'RP_OutOfDateAllBanksDeadline cannot be empty'
			--							--WHEN ISNULL(ERROR,'')<>'' AND (Convert(date,A.RP_OutOfDateAllBanksDeadline,103)>convert(date,@Date,103)) THEN 
			--							--			ISNULL(ERROR,'')+','+SPACE(1)+ 'Date Cannot be future Date'

			--						ELSE ERROR
			--					END
			--	 FROM #RPPortfoilioData A
			--	LEFT OUTER JOIN 
			--(
			----SELECT 1
			--	SELECT RowNum ,1 correct FROM #RPPortfoilioData
			--	WHERE ISDATE(RP_OutOfDateAllBanksDeadline)=1
			--	AND (CASE	WHEN SUBSTRING(RTRIM(LTRIM(RP_OutOfDateAllBanksDeadline)),3,1)='-' 
			--					AND (LEN(RTRIM(LTRIM(RP_OutOfDateAllBanksDeadline)))=9 OR LEN(RTRIM(LTRIM(RP_OutOfDateAllBanksDeadline)))=11 )
			--					AND ISNUMERIC(SUBSTRING(RTRIM(LTRIM(RP_OutOfDateAllBanksDeadline)),4,3))=0 
			--					AND  SUBSTRING(RTRIM(LTRIM(RP_OutOfDateAllBanksDeadline)),7,1)='-' 
			--				THEN 1

			--				WHEN SUBSTRING(RTRIM(LTRIM(RP_OutOfDateAllBanksDeadline)),3,1)='/'
			--				AND (LEN(RTRIM(LTRIM(RP_OutOfDateAllBanksDeadline)))=8 OR LEN(RTRIM(LTRIM(RP_OutOfDateAllBanksDeadline)))=10 )
			--				 AND  SUBSTRING(RTRIM(LTRIM(RP_OutOfDateAllBanksDeadline)),6,1)='/' THEN 1
			--		END)=1
			--)B 
			--ON A.RowNum = B.RowNum
			--WHERE ISNULL(B.RowNum,'')='' 

	UPDATE A
		SET ERROR =  CASE	WHEN ISNULL(A.ERROR,'')=''		THEN 'Invalid RP_OutOfDateAllBanksDeadline. Please check the values and upload again'
							Else A.ERROR+','+SPACE(1)+'Invalid RP_OutOfDateAllBanksDeadline. Please check the values and upload again' END

		FROM #RPPortfoilioData A
		Where ISNULL(A.RP_OutOfDateAllBanksDeadline,'')<>''
		AND ISDATE(A.RP_OutOfDateAllBanksDeadline)=0




----------------Added on 22-01-2021

			UPDATE A
				SET ERROR = 
								CASE	WHEN    ISNULL(ERROR,'')=''  THEN 'RP_OutOfDateAllBanksDeadline Date Cannot be future Date'
													ELSE ISNULL(ERROR,'')+','+SPACE(1)+ 'RP_OutOfDateAllBanksDeadline Date Cannot be future Date'
								END

				 FROM #RPPortfoilioData A
				 Where ISDATE(A.RP_OutOfDateAllBanksDeadline)=1
				 --And CONVERT(date,A.RP_OutOfDateAllBanksDeadline,103)> CONVERT(date,@Date,103) 
				 and  (Case When ISDATE(RP_OutOfDateAllBanksDeadline)=1 Then Case When Cast(RP_OutOfDateAllBanksDeadline as date)>Cast(@Date as Date) Then 1 Else 0 END END)=1
/****************************************************************************************************************
					
											FOROUTPUT

****************************************************************************************************************/

IF EXISTS(SELECT 1 FROM #RPPortfoilioData WHERE ISNULL(ERROR,'')<>'')
	BEGIN
		SELECT RowNum	
				,CustomerEntityID
				,UCIC_ID
				,CustomerID
				,PAN_No
				--,CustomerName
				,BankCode
				--,BorrowerDefaultDate
				,ExposureBucketName
				,BankingArrangementName
				,LeadBankName
				,DefaultStatus
				,RP_ApprovalDate
				,RPNatureName
				,If_Other
				,ImplementationStatus
				,Actual_Impl_Date
				,RP_OutOfDateAllBanksDeadline	
				,ERROR
				,'ErrorData' TableName
		FROM #RPPortfoilioData WHERE ISNULL(ERROR,'')<>''
 END
ELSE
		BEGIN
				SELECT RowNum	
				,CustomerEntityID
				,UCIC_ID
				,CustomerID
				,PAN_No
				--,CustomerName
				,BankCode
				--,CASE WHEN  ISDATE(BorrowerDefaultDate)=1 THEN CONVERT(VARCHAR(10),CAST(BorrowerDefaultDate AS DATE),103) ELSE BorrowerDefaultDate END BorrowerDefaultDate
				,ExposureBucketName
				,BankingArrangementName
				,LeadBankName
				,DefaultStatus
				,CASE WHEN  ISDATE(RP_ApprovalDate)=1 THEN CONVERT(VARCHAR(10),CAST(RP_ApprovalDate AS DATE),103) ELSE RP_ApprovalDate END RP_ApprovalDate
				,RPNatureName
				,If_Other
				,ImplementationStatus
				,CASE WHEN  ISDATE(Actual_Impl_Date)=1 THEN CONVERT(VARCHAR(10),CAST(Actual_Impl_Date AS DATE),103) ELSE Actual_Impl_Date END Actual_Impl_Date
				,CASE WHEN  ISDATE(RP_OutOfDateAllBanksDeadline)=1 THEN CONVERT(VARCHAR(10),CAST(RP_OutOfDateAllBanksDeadline AS DATE),103) ELSE RP_OutOfDateAllBanksDeadline END RP_OutOfDateAllBanksDeadline
				,'RPPortfolioData' TableName
				,ERROR as error
				FROM #RPPortfoilioData 
		END
		DROP TABLE #RPPortfoilioData
	END
GO