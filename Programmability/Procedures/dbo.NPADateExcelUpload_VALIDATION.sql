SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE Procedure [dbo].[NPADateExcelUpload_VALIDATION]
(
@UserLoginId varchar(20),
@filepath varchar(600),
@todaydate date
)
As
Begin

IF OBJECT_ID('TEMPDB..#NPADate') IS NOT NULL
				DROP TABLE #NPADate

		--SELECT 
		--ROW_NUMBER()OVER(ORDER BY (SELECT  (1))) RowNum
		
		--,C.value('./UCIFID				[1]','VARCHAR(30)')UCICID
		--,CAST(NULL AS VARCHAR(MAX))ERROR
		--,CASE WHEN C.value('./NPADATE			[1]','VARCHAR(30)') = '' THEN NULL ELSE C.value('./NPADATE			[1]','VARCHAR(30)')	END	NPADate
		--,C.value('./NPADATECHANGEREASON				[1]','VARCHAR(500)')NPADATECHANGEREASON
		--INTO #NPADate
		--FROM @XMLDocument.nodes('/DataSet/Gridrow') AS t(c)


		select
		ROW_NUMBER()OVER(ORDER BY (SELECT  (1))) RowNum,
		UCICID,
		nullif(NPADate,'') NPADate,
		NPADATECHANGEREASON,
		CAST(NULL AS VARCHAR(MAX))ERROR
		into #NPADate
		from dbo.NPADateDataUpload 

		
		
		/****************************************************************************************************************
					
											FOR CHECKING A UCIF ID 

		****************************************************************************************************************/
		--UPDATE F
		--SET ERROR = CASE	WHEN ISNULL(C.UCIF_ID,'')=''AND ISNULL(ERROR,'')='' THEN 'Invalid UCIF ID'
		--					WHEN ISNULL(C.UCIF_ID,'')=''AND ISNULL(ERROR,'')<>'' THEN ERROR+','+SPACE(1)+ 'Invalid UCIF ID'

		--					ELSE ERROR
		--			END
		--FROM 
		--#NPADate F
		--LEFT OUTER  JOIN pro.customercal  C
		--	ON C.UCIF_ID = F.UCICID-- C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey	AND C.UCIF_ID = F.UCICID
		--WHERE ISNULL(UCICID,'')<>''

		/*******************************************************************************/

		
		UPDATE F
		SET ERROR = CASE	WHEN ISNULL(F.UCICID,'')='' AND ISNULL(ERROR,'')=''		THEN 'UCIF ID should not be Empty'
							WHEN ISNULL(F.UCICID,'')='' AND ISNULL(ERROR,'')<>''	THEN ERROR+','+SPACE(1) +'UCIF ID should not be Empty'
							WHEN ISNULL(C.UCIF_ID,'')='' AND ISNULL(ERROR,'')=''	THEN 'Invalid UCIF ID'
							WHEN ISNULL(C.UCIF_ID,'')='' AND ISNULL(ERROR,'')<>''	THEN ERROR+','+SPACE(1) +'Invalid UCIF ID'
							ELSE ERROR
					END
		FROM #NPADate F
		LEFT OUTER JOIN PRO.CustomerCal C
			ON C.UCIF_ID = F.UCICID 



		/****************************************************************************************************************
					
											FOR CHECKING A Date of NPA

		****************************************************************************************************************/
	--SELECT * FROM #NPADate A LEFT OUTER JOIN  (SELECT RowNum ,1 correct FROM #NPADate) B 
	--		ON A.RowNum = B.RowNum
	--		WHERE ISNULL(B.RowNum,'')='' 
	--		AND ISNULL(A.NPADate,'')<>''

				UPDATE A
				SET ERROR = 
							CASE	WHEN ISNULL(ERROR,'')=''  AND ISNULL(A.NPADate,'')<>'' AND ISNULL(B.correct,0)<>1 
											THEN 'Invalid Date of NPA'

										WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.NPADate,'')<>'' AND ISNULL(B.correct,0)<>1 
													THEN ISNULL(ERROR,'')+','+SPACE(1)+ 'Invalid Date of NPA'

										WHEN ISNULL(ERROR,'')=''  AND ISNULL(A.NPADate,'')='' 
													THEN 'Date of NPA cannot be empty'

										WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.NPADate,'')='' THEN 
													ISNULL(ERROR,'')+','+SPACE(1)+ 'Date of NPA cannot be empty'

									ELSE ERROR
								END
				 FROM #NPADate A
				LEFT OUTER JOIN 
			(
			--SELECT 1
				SELECT RowNum ,1 correct FROM #NPADate
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
			--AND ISNULL(A.NPADate,'')<>''

/****************************************************************************************************************
					
											FOR CHECKING A NPA REASON

****************************************************************************************************************/
UPDATE F
SET ERROR = CASE	WHEN ISNULL(F.NPADATECHANGEREASON,'')=''AND ISNULL(ERROR,'')='' THEN 'NPA Date change reason is mandatory'
					WHEN ISNULL(F.NPADATECHANGEREASON,'')=''AND ISNULL(ERROR,'')<>'' THEN ERROR+','+SPACE(1)+ 'NPA Date change reason is mandatory'

					ELSE ERROR
			END
FROM 
#NPADate F


/*******************************************************************************/
	/****************************************************************************************************************
			
									FOR CHECKING A STOCK Valuation DATE

****************************************************************************************************************/


		UPDATE #NPADate
		SET ERROR = CASE	WHEN ISNULL(ERROR,'')=''	THEN 'NPA Date should not be greater that system date'
							WHEN ISNULL(ERROR,'')<>''	THEN ERror+','+SPACE(1)+ 'NPA Date should not be greater that system date'
							ELSE ERROR
					END

					-----Error While upload date as report by Kuldeep on 24-04-2020------
		--WHERE CONVERT(VARCHAR(10),CAST(NPADate AS DATE),103) >  CONVERT(VARCHAR(10),CAST(@todaydate AS DATE),103) 
		WHERE CONVERT(date,CAST(NPADate AS DATE),103) >  CONVERT(date,CAST(@todaydate AS DATE),103) 


		-- Added By Sourangshu 20241105

		DECLARE @FilePathUpdated_Npadt VARCHAR(500)
	    SELECT @FilePathUpdated_Npadt=@UserLoginId+'_'+@filepath

		Delete from  dbo.NPADateDataUploadFinal where FILENAME=@FilePathUpdated_Npadt

		--Added By Sourangshu 

		Declare	@Fraentid int= (Select IDENT_CURRENT('dbo.NPADateDataUpload'))

		IF EXISTS(SELECT 1 FROM #NPADate WHERE ISNULL(ERROR,'')<>'')
		BEGIN
			SELECT	  RowNum
					, UCICID AS UCIFID
					, NPADATE
					, NPADATECHANGEREASON
					, ERROR
					,'ErrorData' TableName
			FROM #NPADate WHERE ISNULL(ERROR,'')<>''
			Order by 1 ----Added by shubham on 2024-04-15 for error to be in ordered form
		END
		ELSE
		BEGIN	
			
			SELECT  RowNum
					, UCICID AS UCIFID
					, CASE WHEN  ISNULL(NPADate,'')<>'' THEN CONVERT(VARCHAR(10),CAST(NPADate AS DATE),103) ELSE NULL END NPADATE
					, NPADATECHANGEREASON
					,'NPADateData' TableName
			FROM #NPADate WHERE ISNULL(ERROR,'')=''
			Order by 1 ----Added by shubham on 2024-04-15 for error to be in ordered form

			insert into dbo.NPADateDataUploadFinal
			(
			  UCICID ,
	          NPADate ,
	          NPADATECHANGEREASON ,
		      NpaDateDataEntityId 		
			 )
			 select
			 d.UCICID,
			 d.NPADate,
			 d.NPADATECHANGEREASON,
			 @Fraentid+(ROW_NUMBER() over(order by UCICID))
			 from
			 #NPADate d


		END

		DROP TABLE #NPADate

End
GO