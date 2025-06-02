SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



Create PROCEDURE [dbo].[PUIValidation_1]

@xmlDocument XML=''
,@Timekey	INT = 49999
,@ScreenFlag VARCHAR(20)='PUI' 
AS
SET DATEFORMAT DMY

--declare @todaydate date = (select StartDate from pro.EXTDATE_MISDB where TimeKey=@Timekey)

IF @ScreenFlag = 'PUI'
BEGIN
		IF OBJECT_ID('TEMPDB..##PUIData') IS NOT NULL
				DROP TABLE ##PUIData

SELECT 
ROW_NUMBER()OVER(ORDER BY (SELECT  (1))) RowNum
,C.value('./CustomerEntityID[1]','VARCHAR(30)') CustomerEntityID
,C.value('./CustomerID [1]','VARCHAR(30)') CustomerID 
 ,C.value('./CustomerName [1]','VARCHAR(255)') CustomerName
,C.value('./AccountID [1]','VARCHAR(30)') AccountID 
,CASE WHEN C.value('./OriginalSCOD	[1]','VARCHAR(20)')='' THEN NULL ELSE C.value('./OriginalSCOD[1]','VARCHAR(20)') END AS OriginalEnvisagCompletionDt
,CASE WHEN C.value('./RevisedSCOD	[1]','VARCHAR(20)')='' THEN NULL ELSE C.value('./RevisedSCOD[1]','VARCHAR(20)') END AS RevisedCompletionDt
,CASE WHEN C.value('./ActualDCCO	[1]','VARCHAR(20)')='' THEN NULL ELSE C.value('./ActualDCCO[1]','VARCHAR(20)') END AS ActualCompletionDt
,C.value('./ProjectCategory [1]','VARCHAR(100)') ProjectCat
,C.value('./ProjectDelayReason [1]','VARCHAR(100)') ProjectDelReason
,C.value('./StandardRestructured [1]','VARCHAR(20)') StandardRestruct
,CAST(NULL AS VARCHAR(MAX))ERROR
INTO ##PUIData
FROM @XMLDocument.nodes('/DataSet/Gridrow') AS t(c)


select * from ##PUIData




		
/****************************************************************************************************************
					
											FOR CHECKING A CUSTOMER  ID 

****************************************************************************************************************/

		--UPDATE A
		--SET ERROR = CASE	WHEN ISNULL(A.CustomerID,'')=''		THEN 'Customer Id should not be Empty'
		--					WHEN ISNULL(C.RefCustomerID,'')=''	THEN 'Invalid Customer Id'
		--					ELSE ERROR
		--			END
		--FROM ##PUIData A
		--LEFT OUTER JOIN PRO.CustomerCal C
		--	ON A.CustomerID = C.RefCustomerID --C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey	AND A.CUSTOMERID = C.RefCustomerID
		

			UPDATE A
		SET ERROR = CASE	WHEN ISNULL(A.ERROR,'')=''		THEN 'Customer Id should not be Empty'
							Else A.ERROR+','+SPACE(1)+'Customer Id should not be Empty' END
							
		FROM ##PUIData A
		where A.CustomerID = ''
		
		UPDATE A
		SET ERROR = CASE	WHEN ISNULL(A.ERROR,'')=''		THEN 'Invalid Customer Id'
							Else A.ERROR+','+SPACE(1)+'Invalid Customer Id' END
		FROM ##PUIData A
		where  A.CustomerID <> ''
		and  A.CustomerID not in (select C.RefCustomerID from PRO.CustomerCal C
		where C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey)

		
				
		
		
		
		
/****************************************************************************************************************
					
											FOR CHECKING A CustomerName

****************************************************************************************************************/

		--		UPDATE A
		--SET ERROR = CASE	WHEN ISNULL(A.CustomerName,'')=''		THEN 'CustomerName should not be Empty'
		--					WHEN ISNULL(C.CustomerName,'')=''	THEN 'Invalid Customer Name'
		--					ELSE ERROR
		--			END
		--FROM ##PUIData A
		--LEFT OUTER JOIN PRO.CustomerCal C
		--	ON A.CustomerName = C.CustomerName --C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey	AND A.CUSTOMERID = C.RefCustomerID

			
		UPDATE A
		SET ERROR = CASE	WHEN ISNULL(A.ERROR,'')=''		THEN 'CustomerName should not be Empty'
							Else A.ERROR+','+SPACE(1)+'CustomerName should not be Empty' END
							
		FROM ##PUIData A
		where A.CustomerName = ''
		
		UPDATE A
		SET ERROR = CASE	WHEN ISNULL(A.ERROR,'')=''		THEN 'Invalid Customer Name'
							Else A.ERROR+','+SPACE(1)+'Invalid Customer Name' END
		FROM ##PUIData A
		where  A.CustomerName <> ''
		and  A.CustomerName not in (select C.CustomerName from PRO.CustomerCal C
		where C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey)


/****************************************************************************************************************
					
											FOR CHECKING A AccountID

****************************************************************************************************************/

		--		UPDATE A
		--SET ERROR = CASE	WHEN ISNULL(A.AccountID,'')=''		THEN 'Account ID should not be Empty'
		--					WHEN ISNULL(C.CustomerAcID,'')=''	THEN 'Invalid Account ID'
		--					ELSE ERROR
		--			END
		--FROM ##PUIData A
		--LEFT OUTER JOIN PRO.AccountCal C
		--	ON A.AccountID = C.CustomerAcID --C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey	AND A.CUSTOMERID = C.RefCustomerID

			UPDATE A
		SET ERROR = CASE	WHEN ISNULL(A.ERROR,'')=''		THEN 'Account ID should not be Empty'
							Else A.ERROR+','+SPACE(1)+'Account ID should not be Empty' END
							
		FROM ##PUIData A
		where A.AccountID = ''
		
		UPDATE A
		SET ERROR = CASE	WHEN ISNULL(A.ERROR,'')=''		THEN 'Invalid Account ID'
							Else A.ERROR+','+SPACE(1)+'Invalid Account ID' END
		FROM ##PUIData A
		where  A.AccountID <> ''
		and  A.AccountID not in (select C.CustomerAcID from PRO.AccountCal C
		where C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey)



/****************************************************************************************************************
					
											FOR CHECKING A OriginalEnvisagCompletionDt

****************************************************************************************************************/
			
		SET DATEFORMAT DMY
				
				UPDATE A
				SET ERROR = 
								CASE	WHEN ISNULL(ERROR,'')=''  AND ISNULL(A.OriginalEnvisagCompletionDt,'')<>'' AND ISNULL(B.correct,0)<>1 
											THEN 'Invalid OriginalEnvisagCompletionDt'

										WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.OriginalEnvisagCompletionDt,'')<>'' AND ISNULL(B.correct,0)<>1 
													THEN ISNULL(ERROR,'')+','+SPACE(1)+ 'Invalid OriginalEnvisagCompletionDt'

										WHEN ISNULL(ERROR,'')=''  AND ISNULL(A.OriginalEnvisagCompletionDt,'')='' 
													THEN 'OriginalEnvisagCompletionDt cannot be empty'

										WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.OriginalEnvisagCompletionDt,'')='' THEN 
													ISNULL(ERROR,'')+','+SPACE(1)+ 'OriginalEnvisagCompletionDt cannot be empty'

									ELSE ERROR
								END
				 FROM ##PUIData A
				LEFT OUTER JOIN 
			(
			--SELECT 1
				SELECT RowNum ,1 correct FROM ##PUIData
				WHERE (Case When ISDATE(OriginalEnvisagCompletionDt)=0 AND ISNULL(OriginalEnvisagCompletionDt,'')<>'' Then 1 Else 0 END)=1
			)B 
			ON A.RowNum = B.RowNum
			WHERE ISNULL(B.RowNum,'')='' 




/****************************************************************************************************************
					
											FOR CHECKING RevisedCompletionDt

****************************************************************************************************************/


	UPDATE A
				SET ERROR = 
								CASE	WHEN ISNULL(ERROR,'')=''  AND ISNULL(A.RevisedCompletionDt,'')<>'' AND ISNULL(B.correct,0)<>1 
											THEN 'Invalid RevisedCompletionDt'

										WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.RevisedCompletionDt,'')<>'' AND ISNULL(B.correct,0)<>1 
													THEN ISNULL(ERROR,'')+','+SPACE(1)+ 'Invalid RevisedCompletionDt'

										WHEN ISNULL(ERROR,'')=''  AND ISNULL(A.RevisedCompletionDt,'')='' 
													THEN 'RevisedCompletionDt cannot be empty'

										WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.RevisedCompletionDt,'')='' THEN 
													ISNULL(ERROR,'')+','+SPACE(1)+ 'RevisedCompletionDt cannot be empty'
										WHEN ISNULL(ERROR,'')<>'' AND (Convert(date,A.RevisedCompletionDt,103)>convert(date,A.OriginalEnvisagCompletionDt,103)) THEN 
													ISNULL(ERROR,'')+','+SPACE(1)+ 'RevisedCompletionDt cannot be empty'

									ELSE ERROR
								END
				 FROM ##PUIData A
				LEFT OUTER JOIN 
			(
			--SELECT 1
				SELECT RowNum ,1 correct FROM ##PUIData
				WHERE ISDATE(RevisedCompletionDt)=1
				AND (CASE	WHEN SUBSTRING(RTRIM(LTRIM(RevisedCompletionDt)),3,1)='-' 
								AND (LEN(RTRIM(LTRIM(RevisedCompletionDt)))=9 OR LEN(RTRIM(LTRIM(RevisedCompletionDt)))=11 )
								AND ISNUMERIC(SUBSTRING(RTRIM(LTRIM(RevisedCompletionDt)),4,3))=0 
								AND  SUBSTRING(RTRIM(LTRIM(RevisedCompletionDt)),7,1)='-' 
							THEN 1

							WHEN SUBSTRING(RTRIM(LTRIM(RevisedCompletionDt)),3,1)='/'
							AND (LEN(RTRIM(LTRIM(RevisedCompletionDt)))=8 OR LEN(RTRIM(LTRIM(RevisedCompletionDt)))=10 )
							 AND  SUBSTRING(RTRIM(LTRIM(RevisedCompletionDt)),6,1)='/' THEN 1
					END)=1
			)B 
			ON A.RowNum = B.RowNum
			WHERE ISNULL(B.RowNum,'')='' 


print 'A'
	UPDATE A
				SET ERROR = 
								CASE	
										WHEN  ISNULL(ERROR,'')='' and (Convert(date,A.RevisedCompletionDt,103)<convert(date,A.OriginalEnvisagCompletionDt,103)) THEN 
													 'RevisedCompletionDt should be greater OriginalEnvisagCompletionDt'
										WHEN ISNULL(ERROR,'')<>'' and (Convert(date,A.RevisedCompletionDt,103)<convert(date,A.OriginalEnvisagCompletionDt,103)) THEN
										ISNULL(ERROR,'')+','+SPACE(1)+ 'RevisedCompletionDt should be greater OriginalEnvisagCompletionDt'
										ELSE ERROR END 
								
				 FROM ##PUIData A




/****************************************************************************************************************
					
											FOR CHECKING ProjectCategory

****************************************************************************************************************/


		--UPDATE A
		--SET ERROR = CASE	WHEN ISNULL(A.ProjectCat,'')=''	THEN 'Project Category should not be Empty'
		--					WHEN ISNULL(B.ParameterName,'')=''	THEN 'Invalid Project Category'
		--					ELSE ERROR
		--			END
		--FROM ##PUIData A
		--LEFT OUTER JOIN DimParameter B
		--ON A.ProjectCat=B.ParameterName and b.DimParameterName='ProjectCategory'

		UPDATE A
		SET ERROR = CASE	WHEN ISNULL(A.ERROR,'')=''	THEN 'Project Category should not be Empty'
		Else A.ERROR+','+SPACE(1)+'Project Category should not be Empty' END
		FROM ##PUIData A
		WHERE ProjectCat=''

		UPDATE A
		SET ERROR = CASE	WHEN ISNULL(A.ERROR,'')=''	THEN 'Invalid Project Category'
		Else A.ERROR+','+SPACE(1)+'Project Category should not be Empty' END
		FROM ##PUIData A
		where A.ProjectCat<>''
		and A.ProjectCat not in (select ParameterName from DimParameter where DimParameterName='ProjectCategory')


/****************************************************************************************************************
					
											FOR CHECKING ProjectDelayReason

****************************************************************************************************************/


		UPDATE A
		SET ERROR = CASE	--WHEN ISNULL(A.ProjectDelReason,'')=''	THEN 'Project Delay Reason should not be Empty'
							WHEN ISNULL(A.ERROR,'')=''	THEN 'Invalid Project Delay Reason'
							--ELSE ERROR
							Else A.ERROR+','+SPACE(1)+'Invalid Project Delay Reason' END
					--END
		FROM ##PUIData A
		--LEFT OUTER JOIN DimParameter B
		--ON A.ProjectDelReason=B.ParameterName and b.DimParameterName='ProdectDelReson'
		where A.ProjectDelReason<>''
		and A.ProjectDelReason not in (select ParameterName from DimParameter where DimParameterName='ProdectDelReson')



/****************************************************************************************************************
					
											FOR CHECKING StandardRestruct

****************************************************************************************************************/


		
		UPDATE A
		SET ERROR = CASE	--WHEN ISNULL(A.StandardRestruct,'')=''	THEN 'StandardRestruct should not be Empty'
							WHEN ISNULL(A.ERROR,'')=''	THEN 'Invalid StandardRestruct'
							--ELSE ERROR
							Else A.ERROR+','+SPACE(1)+'Invalid StandardRestruct' END
					--END
		FROM ##PUIData A
		--LEFT OUTER JOIN DimParameter B
		--ON A.StandardRestruct =B.ParameterName and b.DimParameterName ='DimYesNo'
		WHERE A.StandardRestruct <>''
		and A.StandardRestruct not in (select ParameterName from DimParameter where DimParameterName ='DimYesNo')
		Print 'Sachin'
		Select '##PUIDataFinal',* from ##PUIData

/****************************************************************************************************************
					
											FOROUTPUT

****************************************************************************************************************/

IF EXISTS(SELECT 1 FROM ##PUIData WHERE ISNULL(ERROR,'')<>'')
	BEGIN
		SELECT RowNum	
				,CustomerEntityID
				,CustomerID
				,CustomerName
				,AccountID
				,OriginalEnvisagCompletionDt
				,RevisedCompletionDt
				,ActualCompletionDt
				,ProjectCat
				,ProjectDelReason
				,StandardRestruct
				,ERROR
				,'ErrorData' TableName
		FROM ##PUIData WHERE ISNULL(ERROR,'')<>''
 END
ELSE
		BEGIN
				SELECT RowNum	
				,CustomerID
				,CustomerName
				,AccountID
				,CASE WHEN  ISDATE(OriginalEnvisagCompletionDt)=1 THEN CONVERT(VARCHAR(10),CAST(OriginalEnvisagCompletionDt AS DATE),103) ELSE OriginalEnvisagCompletionDt END OriginalEnvisagCompletionDt
				,CASE WHEN  ISDATE(RevisedCompletionDt)=1 THEN CONVERT(VARCHAR(10),CAST(RevisedCompletionDt AS DATE),103) ELSE RevisedCompletionDt END RevisedCompletionDt
				,CASE WHEN  ISDATE(ActualCompletionDt)=1 THEN CONVERT(VARCHAR(10),CAST(ActualCompletionDt AS DATE),103) ELSE ActualCompletionDt END ActualCompletionDt
				,ProjectCat
				,ProjectDelReason
				,StandardRestruct
		        ,'PUIData' TableName
				FROM ##PUIData 
		END
		--DROP TABLE ##PUIData
	END


GO