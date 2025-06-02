SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[RPLenderValidation]

@xmlDocument XML=''
,@Timekey	INT = 49999
,@ScreenFlag VARCHAR(20)='Lender' 
AS
SET DATEFORMAT DMY

--declare @todaydate date = (select StartDate from pro.EXTDATE_MISDB where TimeKey=@Timekey)

IF @ScreenFlag = 'Lender'
BEGIN
		IF OBJECT_ID('TEMPDB..#RPLenderData') IS NOT NULL
				DROP TABLE #RPLenderData

SELECT 
ROW_NUMBER()OVER(ORDER BY (SELECT  (1))) RowNum
,C.value('./UCICID[1]','VARCHAR(30)') UCIC_ID
,C.value('./CustomerID [1]','VARCHAR(30)') CustomerID 
,C.value('./BorrowerPAN [1]','VARCHAR(20)') PAN_No     
--,C.value('./BorrowerName [1]','VARCHAR(255)') CustomerName
,C.value('./LenderName [1]','VARCHAR(100)') LenderName
,CASE WHEN C.value('./InDefaultDate	[1]','VARCHAR(20)')='' THEN NULL ELSE C.value('./InDefaultDate[1]','VARCHAR(20)') END AS InDefaultDate
,CASE WHEN C.value('./OutofDefaultDate	[1]','VARCHAR(20)')='' THEN NULL ELSE C.value('./OutofDefaultDate[1]','VARCHAR(20)') END AS OutOfDefaultDate
,CAST(NULL AS VARCHAR(MAX))ERROR
INTO #RPLenderData
FROM @XMLDocument.nodes('/DataSet/Gridrow') AS t(c)


Declare @Date Date

SET @Date =(Select CAST(B.Date as Date)Date1 from SysDataMatrix A
Inner Join SysDayMatrix B ON A.TimeKey=B.TimeKey
 where A.CurrentStatus='C')


 SET DATEFORMAT DMY


/****************************************************************************************************************
					
											FOR CHECKING A UCIC ID 

****************************************************************************************************************/
		
		UPDATE A
		SET ERROR = CASE	WHEN ISNULL(A.UCIC_ID,'')=''		THEN 'UCIC Id should not be Empty'
							WHEN ISNULL(C.UCIF_ID,'')=''	THEN 'Invalid UCIF Id'
							ELSE ERROR
					END
		FROM #RPLenderData A
		LEFT OUTER JOIN PRO.CustomerCal C
			ON A.UCIC_ID = C.UCIF_ID --C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey	AND A.UCIC_ID = C.UCIF_ID

		
/****************************************************************************************************************
					
											FOR CHECKING A CUSTOMER  ID 

****************************************************************************************************************/

		UPDATE A
		SET ERROR = CASE	WHEN ISNULL(A.CustomerID,'')=''		THEN 'Customer Id should not be Empty'
							WHEN ISNULL(C.RefCustomerID,'')=''	THEN 'Invalid Customer Id'
							ELSE ERROR
					END
		FROM #RPLenderData A
		LEFT OUTER JOIN PRO.CustomerCal C
			ON A.CustomerID = C.RefCustomerID --C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey	AND A.CUSTOMERID = C.RefCustomerID
		




/****************************************************************************************************************
					
											FOR CHECKING A PAN_No

****************************************************************************************************************/
			
		UPDATE A
		SET ERROR = CASE	WHEN ISNULL(A.PAN_No,'')=''AND ISNULL(ERROR,'')='' THEN 'Pan No Should Not be Empty'
							WHEN ISNULL(C.PANNO,'')=''AND ISNULL(ERROR,'')<>'' THEN ERROR+','+SPACE(1)+ 'Invalid PAN No'
							ELSE ERROR
					END
		FROM 
		#RPLenderData A
		LEFT OUTER  JOIN PRO.CUSTOMERCAL  C
			ON C.PANNO = A.PAN_No --C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey	AND C.PANNO = A.PAN_No
		WHERE ISNULL(PAN_No,'')<>''



		UPDATE A
		SET ERROR = CASE	WHEN  ISNULL(C.PANNO,'')='' AND ISNULL(ERROR,'')=''	THEN 'PAN No Not Belong to that Customer Id'

							WHEN ISNULL(C.PANNO,'')='' AND ISNULL(ERROR,'')<>''	THEN  ISNULL(ERROR,'')+','+SPACE(1)+'PAN NO Not Belong to that Customer Id'
							ELSE ERROR
					END
		
		FROM #RPLenderData A
		LEFT OUTER JOIN PRO.CustomerCal C
			ON A.CustomerID = C.RefCustomerID	AND A.UCIC_ID = C.UCIF_ID --C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey		AND A.CustomerID = C.RefCustomerID		AND A.UCICID = C.UCIF_ID
		WHERE  ISNULL(A.UCIC_ID,'')<>''
				
		
		
		
		
/****************************************************************************************************************
					
											FOR CHECKING A CustomerName

****************************************************************************************************************

				UPDATE A
		SET ERROR = CASE	WHEN ISNULL(A.CustomerName,'')=''		THEN 'CustomerName should not be Empty'
							--WHEN ISNULL(C.CustomerName,'')=''	THEN 'Invalid Customer Name'
							ELSE ERROR
					END
		FROM #RPLenderData A
		--LEFT OUTER JOIN PRO.CustomerCal C
			
			--ON A.CustomerName = C.CustomerName --C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey	AND A.CUSTOMERID = C.RefCustomerID */



/****************************************************************************************************************
					
											FOR CHECKING A LenderName

****************************************************************************************************************/

				UPDATE A
		SET ERROR = CASE	WHEN ISNULL(A.LenderName,'')=''		THEN 'LenderName should not be Empty'
							WHEN ISNULL(B.BankName,'')=''		THEN 'Invalid BankName'
							ELSE ERROR
					END
		FROM #RPLenderData A
		LEFT OUTER JOIN DimBankRP B
		ON A.LenderName=B.BankName
		

/****************************************************************************************************************
					
											FOR CHECKING A InDefaultDate

****************************************************************************************************************/
			
		
				
				UPDATE A
				SET ERROR = 
								CASE	WHEN ISNULL(ERROR,'')=''  AND ISNULL(A.InDefaultDate,'')<>'' AND ISNULL(B.correct,0)<>1 
											THEN 'Invalid InDefaultDate'

										WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.InDefaultDate,'')<>'' AND ISNULL(B.correct,0)<>1 
													THEN ISNULL(ERROR,'')+','+SPACE(1)+ 'Invalid InDefaultDate'
										--WHEN ISNULL(ERROR,'')<>'' AND (Convert(date,A.InDefaultDate,103)>convert(date,@Date,103)) THEN 
										--			ISNULL(ERROR,'')+','+SPACE(1)+ 'Date Cannot be future Date'

									ELSE ERROR
								END
				 FROM #RPLenderData A
				LEFT OUTER JOIN 
			(
			--SELECT 1
				SELECT RowNum ,1 correct FROM #RPLenderData
				WHERE ISDATE(InDefaultDate)=1
				AND (CASE	WHEN SUBSTRING(RTRIM(LTRIM(InDefaultDate)),3,1)='-' 
								AND (LEN(RTRIM(LTRIM(InDefaultDate)))=9 OR LEN(RTRIM(LTRIM(InDefaultDate)))=11 )
								AND ISNUMERIC(SUBSTRING(RTRIM(LTRIM(InDefaultDate)),4,3))=0 
								AND  SUBSTRING(RTRIM(LTRIM(InDefaultDate)),7,1)='-' 
							THEN 1

							WHEN SUBSTRING(RTRIM(LTRIM(InDefaultDate)),3,1)='/'
							AND (LEN(RTRIM(LTRIM(InDefaultDate)))=8 OR LEN(RTRIM(LTRIM(InDefaultDate)))=10 )
							 AND  SUBSTRING(RTRIM(LTRIM(InDefaultDate)),6,1)='/' THEN 1
					END)=1
			)B 
			ON A.RowNum = B.RowNum
			WHERE ISNULL(B.RowNum,'')=''
			
----------------Added on 22-01-2021

--UPDATE A
--	SET ERROR = 
--					CASE	WHEN    CONVERT(date,A.InDefaultDate,103)> CONVERT(date,@Date,103) THEN 
--										ISNULL(ERROR,'')+','+SPACE(1)+ 'InDefaultDate Date Cannot be future Date'

--						ELSE ERROR
--					END
--	 FROM #RPLenderData A 

	 UPDATE A
	SET  
        ERROR=CASE WHEN ISNULL(ERROR,'')='' THEN 'InDefaultDate Date Cannot be future Date'     
						ELSE ERROR+','+SPACE(1)+'InDefaultDate Date Cannot be future Date'     END
		  
	FROM #RPLenderData A
 WHERE (Case 
        When ISDATE(InDefaultDate)=1  Then 
		Case When Convert(date,@Date)<=Convert(date,InDefaultDate)     Then 1
       Else 0 END END)=1
/****************************************************************************************************************
					
											FOR CHECKING OutOfDefaultDate

****************************************************************************************************************/


										UPDATE A
				SET ERROR = 
								CASE	WHEN ISNULL(ERROR,'')=''  AND ISNULL(A.OutOfDefaultDate,'')<>'' AND ISNULL(B.correct,0)<>1 
											THEN 'Invalid OutOfDefaultDate'

										WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.OutOfDefaultDate,'')<>'' AND ISNULL(B.correct,0)<>1 
													THEN ISNULL(ERROR,'')+','+SPACE(1)+ 'Invalid OutOfDefaultDate '
										--WHEN ISNULL(ERROR,'')<>'' AND (Convert(date,A.OutOfDefaultDate,103)>convert(date,@Date,103)) THEN 
										--			ISNULL(ERROR,'')+','+SPACE(1)+ 'Date Cannot be future Date'

										ELSE ERROR
								END
				 FROM #RPLenderData A
				LEFT OUTER JOIN 
			(
			--SELECT 1
				SELECT RowNum ,1 correct FROM #RPLenderData
				WHERE ISDATE(OutOfDefaultDate)=1
				AND (CASE	WHEN SUBSTRING(RTRIM(LTRIM(OutOfDefaultDate)),3,1)='-' 
								AND (LEN(RTRIM(LTRIM(OutOfDefaultDate)))=9 OR LEN(RTRIM(LTRIM(OutOfDefaultDate)))=11 )
								AND ISNUMERIC(SUBSTRING(RTRIM(LTRIM(OutOfDefaultDate)),4,3))=0 
								AND  SUBSTRING(RTRIM(LTRIM(OutOfDefaultDate)),7,1)='-' 
							THEN 1

							WHEN SUBSTRING(RTRIM(LTRIM(OutOfDefaultDate)),3,1)='/'
							AND (LEN(RTRIM(LTRIM(OutOfDefaultDate)))=8 OR LEN(RTRIM(LTRIM(OutOfDefaultDate)))=10 )
							 AND  SUBSTRING(RTRIM(LTRIM(OutOfDefaultDate)),6,1)='/' THEN 1
					END)=1
			)B 
			ON A.RowNum = B.RowNum
			WHERE ISNULL(B.RowNum,'')='' 

----------------Added on 22-01-2021



UPDATE A
	SET  
        ERROR=CASE WHEN ISNULL(ERROR,'')='' THEN 'OutOfDefaultDate Date Cannot be future Date'     
						ELSE ERROR+','+SPACE(1)+'OutOfDefaultDate Date Cannot be future Date'     END
		  
	FROM #RPLenderData A
 WHERE (Case 
        When ISDATE(OutOfDefaultDate)=1  Then 
		Case When Convert(date,@Date)<=Convert(date,OutOfDefaultDate)     Then 1
       Else 0 END END)=1

/****************************************************************************************************************
					
											FOR OUTPUT

****************************************************************************************************************/

IF EXISTS(SELECT 1 FROM #RPLenderData WHERE ISNULL(ERROR,'')<>'')
	BEGIN
		SELECT RowNum	
				,UCIC_ID
				,CustomerID
				,PAN_No
				--,CustomerName
				,LenderName
				,InDefaultDate
				,OutOfDefaultDate
				,ERROR
				,'ErrorData' TableName
		FROM #RPLenderData WHERE ISNULL(ERROR,'')<>''
 END
ELSE
		BEGIN
				SELECT RowNum	
				,UCIC_ID
				,CustomerID
				,PAN_No
				--,CustomerName
				,LenderName
				,CASE WHEN  ISDATE(InDefaultDate)=1 THEN CONVERT(VARCHAR(10),CAST(InDefaultDate AS DATE),103) ELSE InDefaultDate END InDefaultDate
				,CASE WHEN  ISDATE(OutOfDefaultDate)=1 THEN CONVERT(VARCHAR(10),CAST(OutOfDefaultDate AS DATE),103) ELSE OutOfDefaultDate END OutOfDefaultDate
				,'RPLenderData' TableName
				,Error
				FROM #RPLenderData 
		END
		DROP TABLE #RPLenderData
	END



GO