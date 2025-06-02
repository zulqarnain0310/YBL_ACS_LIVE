SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO





/* =============================================
 AUTHER : ANSARI HAMID RAZA
 CREATED BY : 01-MAR-2019
 MODIFY DATE : 
 DESCRIPTION : EXCEL VALIDATION 			FOR  STOCK
 ===============================================*/
Create PROCEDURE [DataUpload].[ExcelValidation]

--DECLARE 
@xmlDocument XML='',
--N'''<DataSet>
--<Gridrow>
--	<CUSTOMERID>1</CUSTOMERID><ACCOUNTID>1</ACCOUNTID>
--	<STOCKSTATEMENTDATE>01-FEB-2019</STOCKSTATEMENTDATE>
--	<STOCKVALUE>10</STOCKVALUE>
--</Gridrow>
--<Gridrow><CUSTOMERID></CUSTOMERID><ACCOUNTID>1</ACCOUNTID><STOCKVALUE>10</STOCKVALUE></Gridrow>
--<Gridrow><CUSTOMERID>4</CUSTOMERID><ACCOUNTID>1</ACCOUNTID><STOCKVALUE>10</STOCKVALUE></Gridrow>
--<Gridrow><CUSTOMERID></CUSTOMERID><ACCOUNTID>1</ACCOUNTID><STOCKVALUE>10</STOCKVALUE>
--<STOCKSTATEMENTDATE></STOCKSTATEMENTDATE>
--</Gridrow>
--</DataSet>'''

@Timekey		INT
,@ScreenFlag VARCHAR(20) 
,@UserLoginId varchar(20) ------Added by Tarkeshwar Singh on 20th July
,@filepath varchar(500)   ------Added by Tarkeshwar Singh on 20th July



AS

BEGIN
SET DATEFORMAT DMY
DECLARE @AbsProvMOCEntityId int = (Select IDENT_CURRENT('DATAUPLOAD.AbsoluteBackdatedMOC_Mod'))------Added by Tarkeshwar Singh on 20th July
declare @todaydate date = (select StartDate from pro.EXTDATE_MISDB where TimeKey=@Timekey)
declare @LastMonthDateKey int = (Select LastMonthDateKey From YBL_ACS.DBO.SysDayMatrix Where TimeKey = @Timekey)
declare @LastMonthDate date = (Select LastMonthDate From YBL_ACS.DBO.SysDayMatrix Where TimeKey = @Timekey)

Declare @YEAR VARCHAR(4) =(Select DATEPART(YEAR,@LastMonthDate))
Declare @Month VARCHAR(3) = (Select CASE WHEN DATEPART(MONTH,@LastMonthDate) = 1 THEN 'JAN'
            WHEN DATEPART(MONTH,@LastMonthDate) = 2 THEN 'FEB'
			WHEN DATEPART(MONTH,@LastMonthDate) = 3 THEN 'MAR'
			WHEN DATEPART(MONTH,@LastMonthDate) = 4 THEN 'APR'
			WHEN DATEPART(MONTH,@LastMonthDate) = 5 THEN 'MAY'
			WHEN DATEPART(MONTH,@LastMonthDate) = 6 THEN 'JUN'
			WHEN DATEPART(MONTH,@LastMonthDate) = 7 THEN 'JUL'
			WHEN DATEPART(MONTH,@LastMonthDate) = 8 THEN 'AUG'
			WHEN DATEPART(MONTH,@LastMonthDate) = 9 THEN 'SEP'
			WHEN DATEPART(MONTH,@LastMonthDate) = 10 THEN 'OCT'
			WHEN DATEPART(MONTH,@LastMonthDate) = 11 THEN 'NOV'
			WHEN DATEPART(MONTH,@LastMonthDate) = 12 THEN 'DEC'
      END )

IF @ScreenFlag = 'Stock'
BEGIN
		IF OBJECT_ID('TEMPDB..#StockStatementDataUpload') IS NOT NULL
				DROP TABLE #StockStatementDataUpload

		SELECT 
		ROW_NUMBER()OVER(ORDER BY (SELECT  (1))) RowNum
		,C.value('./CUSTOMERID						[1]','VARCHAR(50)') CUSTOMERID  
		,C.value('./ACCOUNTID						[1]','VARCHAR(30)') CustomerAcID
		,CASE WHEN C.value('./STOCKSTATEMENTDATE	[1]','VARCHAR(20)')='' THEN NULL ELSE C.value('./STOCKSTATEMENTDATE[1]','VARCHAR(20)') END AS  StockStatementDate  
		,CASE WHEN C.value('./STOCKVALUE			[1]','VARCHAR(20)')='' THEN NULL ELSE C.value('./STOCKVALUE[1]','DECIMAL(18,2)') END AS  StockValue  
		,CASE WHEN C.value('./ICRABORROWERID		[1]','VARCHAR(100)')='' THEN NULL ELSE C.value('./ICRABORROWERID[1]','VARCHAR(100)') END AS  ICRABorrowerId      
		,CAST(NULL AS VARCHAR(MAX))ERROR
		INTO #StockStatementDataUpload
		FROM @XMLDocument.nodes('/DataSet/Gridrow') AS t(c)

		
		

		
		
		/****************************************************************************************************************
					
											FOR CHECKING A CUSTOMER ID 
											 
		****************************************************************************************************************/
		
		UPDATE A
		SET ERROR = CASE	WHEN ISNULL(A.CUSTOMERID,'')=''		THEN 'Customer Id should not be Empty'
							WHEN ISNULL(C.RefCustomerID,'')=''	THEN 'Invalid Customer Id'
							ELSE ERROR
					END
		FROM #StockStatementDataUpload A
		LEFT OUTER JOIN PRO.CustomerCal C
			ON A.CUSTOMERID = C.RefCustomerID --C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey	AND A.CUSTOMERID = C.RefCustomerID

		
		/****************************************************************************************************************
					
											FOR CHECKING A ACCOUNT  ID 

		****************************************************************************************************************/

		UPDATE A
		SET ERROR = CASE	WHEN ISNULL(C.CustomerAcID,'')='' AND ISNULL(ERROR,'')=''	THEN 'Invalid Account Id'
							WHEN ISNULL(C.CustomerAcID,'')='' AND ISNULL(ERROR,'')<>'' THEN ERROR+','+SPACE(1)+'Invalid Account Id'
							ELSE ERROR
					END
		FROM #StockStatementDataUpload A
		LEFT OUTER JOIN PRO.AccountCal C
			ON C.CustomerAcID = A.CustomerAcID --C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey AND C.CustomerAcID = A.CustomerAcID
		WHERE ISNULL(A.CustomerAcID,'')<>''


		
		UPDATE A
		SET ERROR = CASE	WHEN  ISNULL(C.CustomerAcID,'')='' AND ISNULL(ERROR,'')=''	THEN 'Account Id Not Belong to that Customer Id'

							WHEN ISNULL(C.CustomerAcID,'')='' AND ISNULL(ERROR,'')<>''	THEN  ISNULL(ERROR,'')+','+SPACE(1)+'Account Id Not Belong to that Customer Id'
							ELSE ERROR
					END
		
		FROM #StockStatementDataUpload A
		LEFT OUTER JOIN PRO.AccountCal C
			ON A.CUSTOMERID = C.RefCustomerID AND A.CustomerAcID = C.CustomerAcID --C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey		AND A.CUSTOMERID = C.RefCustomerID			AND A.CustomerAcID = C.CustomerAcID
			
		WHERE  ISNULL(A.CustomerAcID,'')<>''
		




		/****************************************************************************************************************
					
											FOR CHECKING A STOCK STATEMENT DATE

		****************************************************************************************************************/
			
		
				
				UPDATE A
				SET ERROR = 
								CASE	WHEN ISNULL(ERROR,'')=''  AND ISNULL(A.StockStatementDate,'')<>'' AND ISNULL(B.correct,0)<>1 
											THEN 'Invalid Stock Statement Date'

										WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.StockStatementDate,'')<>'' AND ISNULL(B.correct,0)<>1 
													THEN ISNULL(ERROR,'')+','+SPACE(1)+ 'Invalid Stock Statement Date'

										WHEN ISNULL(ERROR,'')=''  AND ISNULL(A.StockStatementDate,'')='' 
													THEN 'Stock Statement Date cannot be empty'

										WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.StockStatementDate,'')='' THEN 
													ISNULL(ERROR,'')+','+SPACE(1)+ 'Stock Statement Date cannot be empty'

									ELSE ERROR
								END
				 FROM #StockStatementDataUpload A
				LEFT OUTER JOIN 
			(
			--SELECT 1
				SELECT RowNum ,1 correct FROM #StockStatementDataUpload
				WHERE ISDATE(StockStatementDate)=1
				AND (CASE	WHEN SUBSTRING(RTRIM(LTRIM(StockStatementDate)),3,1)='-' 
								AND (LEN(RTRIM(LTRIM(StockStatementDate)))=9 OR LEN(RTRIM(LTRIM(StockStatementDate)))=11 )
								AND ISNUMERIC(SUBSTRING(RTRIM(LTRIM(StockStatementDate)),4,3))=0 
								AND  SUBSTRING(RTRIM(LTRIM(StockStatementDate)),7,1)='-' 
							THEN 1

							WHEN SUBSTRING(RTRIM(LTRIM(StockStatementDate)),3,1)='/'
							AND (LEN(RTRIM(LTRIM(StockStatementDate)))=8 OR LEN(RTRIM(LTRIM(StockStatementDate)))=10 )
							 AND  SUBSTRING(RTRIM(LTRIM(StockStatementDate)),6,1)='/' THEN 1
					END)=1
			)B 
			ON A.RowNum = B.RowNum
			WHERE ISNULL(B.RowNum,'')='' 

			
		
		

		/****************************************************************************************************************
					
											FOR CHECKING A STOCKVALUE

		****************************************************************************************************************/

		UPDATE #StockStatementDataUpload
		SET ERROR = CASE	WHEN ISNUMERIC(StockValue)= 0 AND  ISNULL(ERROR,'')=''	THEN 'Incorrect Stock Value' 
							WHEN ISNUMERIC(StockValue)= 0 AND  ISNULL(ERROR,'')<>''	THEN ISNULL(ERROR,'')+','+SPACE(1)+'Incorrect Stock Value' 
							WHEN LEN(CAST(StockValue AS DECIMAL(18,2)))>19  AND ISNULL(ERROR,'')=''		THEN 'Length of stock value should be less then 20'
							WHEN LEN(CAST(StockValue AS DECIMAL(18,2)))>19  AND ISNULL(ERROR,'')<>''	THEN  ISNULL(ERROR,'')+','+SPACE(1)+'Length of stock value should be less then 20'
							ELSE ERROR
					END
		WHERE ISNULL(StockValue,0)<>0  --AND ISNUMERIC(StockValue)= 0 
		
		
		/****************************************************************************************************************
					
											FOR CHECKING A ICRA Borrower Id

		****************************************************************************************************************/

		UPDATE #StockStatementDataUpload
		SET ERROR = CASE	WHEN LEN(ICRABorrowerId)>30 AND ISNULL(ERROR,'')=''	 THEN 'ICRA Borrower Id should be Less then 30 Charatcer'
							WHEN LEN(ICRABorrowerId)>30 AND ISNULL(ERROR,'')<>'' THEN ISNULL(ERROR,'')+','+SPACE(1)+'ICRA Borrower Id should be Less then 30 Charatcer'
							ELSE ERROR
					END
		WHERE ISNULL(ICRABorrowerId,'')<>''

	
		/****************************************************************************************************************
					
											FOR STOCK STATEMENT SELECT OUTPUT

		****************************************************************************************************************/
		IF EXISTS(SELECT 1 FROM #StockStatementDataUpload WHERE ISNULL(ERROR,'')<>'')
		BEGIN
		SELECT RowNum	
				,CUSTOMERID	
				,CUSTOMERACID	
				,STOCKSTATEMENTDATE
				--,STOCKSTATEMENTDATE
				,STOCKVALUE	
				,ICRABORROWERID	
				,ERROR
				,'ErrorData' TableName
		FROM #StockStatementDataUpload WHERE ISNULL(ERROR,'')<>''
		END
		ELSE
		BEGIN
				SELECT RowNum	
				,CUSTOMERID	
				,CUSTOMERACID	
				,CASE WHEN  ISDATE(StockStatementDate)=1 THEN CONVERT(VARCHAR(10),CAST(StockStatementDate AS DATE),103) ELSE StockStatementDate END STOCKSTATEMENTDATE
				--,StockStatementDate
				,STOCKVALUE	
				,ICRABORROWERID	
				,'StockData' TableName
				FROM #StockStatementDataUpload 
		END
		DROP TABLE #StockStatementDataUpload
END
			
ELSE IF @ScreenFlag = 'Restructure'
BEGIN
	
	IF OBJECT_ID('TEMPDB..#Restructure') IS NOT NULL
				DROP TABLE #Restructure

		
		SELECT
		
		ROW_NUMBER()OVER(ORDER BY (SELECT  (1))) RowNum
		,C.value('./CUSTOMERID			[1]','VARCHAR(50)') CUSTOMERID  
		,C.value('./ACCOUNTID			[1]','VARCHAR(30)') CustomerAcID
		,C.value('./RESTRUCTUREDATE		[1]','VARCHAR(30)') RestructureDate  
		,C.value('./ORIGINALDCCODATE	[1]','VARCHAR(30)') OriginalDCCODate  
		,C.value('./EXTENDEDDCCODATE	[1]','VARCHAR(30)') ExtendedDCCODate  
		,C.value('./ACTUALDCCODATE		[1]','VARCHAR(30)') ActualDCCODate  
		,C.value('./INFRASTRUCTUREYN	[1]','VARCHAR(30)') InfrastructureYN  
		,CASE WHEN C.value('./DFVAMOUNT	[1]','VARCHAR(30)')='' THEN NULL ELSE C.value('./DFVAMOUNT [1]','DECIMAL(18,2)') END DFVAmount  
		,CAST(NULL AS VARCHAR(MAX))ERROR
		,C.value('./EFFECTIVENPADATE		[1]','VARCHAR(30)') EffectiveNPADate
		,C.value('./NPAREASON	[1]','VARCHAR(500)') NPAReason  
		INTO #Restructure
		FROM @XMLDocument.nodes('/DataSet/Gridrow') AS t(c)

		--select * FROM #Restructure

		/****************************************************************************************************************
					
											FOR CHECKING A CUSTOMER ID 

		****************************************************************************************************************/
		
		UPDATE A
		SET ERROR = 
							CASE	WHEN ISNULL(A.CUSTOMERID,'')=''		THEN 'Customer Id should not be Empty'
									WHEN ISNULL(C.RefCustomerID,'')=''	THEN 'Invalid Customer Id'
									ELSE ERROR
								END
		FROM #Restructure A
		LEFT OUTER JOIN PRO.CustomerCal C
			ON A.CUSTOMERID = C.RefCustomerID-- C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey	AND A.CUSTOMERID = C.RefCustomerID

		

		
		/****************************************************************************************************************
					
											FOR CHECKING A ACCOUNT ID 

		****************************************************************************************************************/
	 
		UPDATE R
		SET ERROR = CASE	WHEN ISNULL(R.CustomerAcID,'')='' AND ISNULL(ERROR,'')=''  THEN 'Account Id should not be Empty'
							WHEN ISNULL(R.CustomerAcID,'')='' AND ISNULL(ERROR,'')<>''  THEN ERROR+','+SPACE(1)+ 'Account Id should not be Empty'

							WHEN ISNULL(A.CustomerAcID,'')='' THEN 'Invalid Account Id'
						 ELSE ERROR
					END
		FROM #Restructure R
		LEFT OUTER JOIN PRo.AccountCal A
			ON  A.CustomerAcID = R.CustomerAcID -- A.EffectiveFromTimeKey <= @Timekey AND A.EffectiveToTimeKey >= @Timekey	AND A.CustomerAcID = R.CustomerAcID


          /****************************************************************************************************************
					
											FOR CHECKING A ACCOUNT ID 

		****************************************************************************************************************/
	 

			UPDATE R
		SET ERROR = CASE	WHEN  ISNULL(C.CustomerAcID,'')='' AND ISNULL(ERROR,'')=''	THEN 'Account Id Not Belong to that Customer Id'

							WHEN ISNULL(C.CustomerAcID,'')='' AND ISNULL(ERROR,'')<>''	THEN  ISNULL(ERROR,'')+','+SPACE(1)+'Account Id Not Belong to that Customer Id'
							ELSE ERROR
					END
		
		FROM #Restructure R
		LEFT OUTER JOIN PRO.AccountCal C
			ON R.CUSTOMERID = C.RefCustomerID	AND R.CustomerAcID = C.CustomerAcID --C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey	AND R.CUSTOMERID = C.RefCustomerID	AND R.CustomerAcID = C.CustomerAcID
		WHERE  ISNULL(R.CustomerAcID,'')<>''

		
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
				 FROM #Restructure A
				LEFT OUTER JOIN 
			(
			--SELECT 1
				SELECT RowNum ,1 correct FROM #Restructure
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
			--AND ISNULL(A.RestructureDate,'')<>''
			
		
		/****************************************************************************************************************
					
											FOR CHECKING A OriginalDCCODate DATE

		****************************************************************************************************************/
	
				
				UPDATE A
				SET ERROR = 
							--	CASE	WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.OriginalDCCODate,'')<>''	THEN ERROR+','+'Invalid OriginalDCCO Date'
							--		WHEN ISNULL(ERROR,'')='' AND ISNULL(A.OriginalDCCODate,'')<>''	THEN 'Invalid OriginalDCCO Date'
							--		--WHEN ISNULL(ERROR,'')='' AND ISNULL(A.OriginalDCCODate,'')=''	THEN 'OriginalDCCO Date cannot be empty/ Invalid  Date'
							--		--WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.OriginalDCCODate,'')=''	THEN ERROR+','+'Restructure Date cannot be empty'

							--	ELSE ERROR
							--END
							CASE	WHEN ISNULL(ERROR,'')=''  AND ISNULL(A.OriginalDCCODate,'')<>'' AND ISNULL(B.correct,0)<>1 
											THEN 'Invalid Original DCCO Date'

										WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.OriginalDCCODate,'')<>'' AND ISNULL(B.correct,0)<>1 
													THEN ISNULL(ERROR,'')+','+SPACE(1)+ 'Invalid Original DCCO Date'

										WHEN ISNULL(ERROR,'')=''  AND ISNULL(A.OriginalDCCODate,'')='' 
													THEN 'Original DCCO Date cannot be empty'

										WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.OriginalDCCODate,'')='' THEN 
													ISNULL(ERROR,'')+','+SPACE(1)+ 'Original DCCO Date cannot be empty'

									ELSE ERROR
							END
				
				 FROM #Restructure A
				LEFT OUTER JOIN 
			(
			--SELECT 1
				SELECT RowNum ,1 correct FROM #Restructure
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
						 -- CASE	WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.ExtendedDCCODate,'')<>''	THEN ERROR+','+'Invalid OriginalDCCO Date'
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
				 FROM #Restructure A
				LEFT OUTER JOIN 
			(
			
				SELECT RowNum ,1 correct FROM #Restructure
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
				 FROM #Restructure A
				LEFT OUTER JOIN 
			(
			--SELECT 1
				SELECT RowNum ,1 correct FROM #Restructure
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
					
											FOR CHECKING A EffectiveNPADate DATE

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
				 FROM #Restructure A
				LEFT OUTER JOIN 
			(
				SELECT RowNum ,1 correct FROM #Restructure
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
			WHERE ISNULL(A.EffectiveNPADate,'')<>'' AND ISNULL(B.RowNum,'')=''  
			
			/****************************************************************************************************************
					
											FOR CHECKING A NPAReason

		****************************************************************************************************************/


		UPDATE #Restructure
		SET ERROR = CASE	WHEN ISNULL(ERROR,'')=''	THEN 'NPA Reason Length should not be greater then 500 Chararter'
							WHEN ISNULL(ERROR,'')<>''	THEN ERROR+','+SPACE(1)+ 'NPA Reason Length should not be  greater then 500 Chararter'
							ELSE ERROR
					END
		WHERE LEN(NPAReason)>500

	
		/****************************************************************************************************************
					
											FOR CHECKING A DFV Amount 

		****************************************************************************************************************/
		
		UPDATE #Restructure
		SET ERROR = CASE	WHEN  ISNULL(ERROR,'')=''  AND ISNUMERIC(DFVAmount)= 0 	THEN 'Incorrect DFVAmount' 
								WHEN ISNULL(ERROR,'')<>'' AND ISNUMERIC(DFVAmount)= 0 	THEN ERROR+','+SPACE(1)+'Incorrect DFVAmount' 

								WHEN ISNULL(ERROR,'')=''	AND LEN(CAST(DFVAmount AS DECIMAL(18,2)))>19 	THEN 'Length of DFV Amount should be less then 20' 
								WHEN ISNULL(ERROR,'')<>''	AND LEN(CAST(DFVAmount AS DECIMAL(18,2)))>19 	THEN ERROR+','+SPACE(1)+'Length of DFV Amount should be less then 20' 
							ELSE ERROR
					END
		WHERE ISNULL(DFVAmount,0)<>0
		--print 


		IF EXISTS(SELECT 1 FROM #Restructure WHERE ISNULL(ERROR,'')<>'')
		BEGIN
			SELECT RowNum
					,CUSTOMERID
					,CUSTOMERACID
					,RESTRUCTUREDATE
					,ORIGINALDCCODATE
					,EXTENDEDDCCODATE
					,ACTUALDCCODATE
					,INFRASTRUCTUREYN
					,DFVAMOUNT
					,EFFECTIVENPADATE
					,NPAREASON
					,ERROR
					,'ErrorData' TableName
			FROM #Restructure 
			WHERE ISNULL(ERROR,'')<>''
		END
		ELSE 
		BEGIN
			SELECT RowNum
					, CUSTOMERID
					,CUSTOMERACID
					--,CONVERT(VARCHAR(10),CAST(RestructureDate AS DATE),103)RESTRUCTUREDATE
					,CASE WHEN  ISNULL(RestructureDate,'')<>'' THEN CONVERT(VARCHAR(10),CAST(RestructureDate AS DATE),103) ELSE NULL END RESTRUCTUREDATE
					,CASE WHEN  ISNULL(OriginalDCCODate,'')<>'' THEN CONVERT(VARCHAR(10),CAST(OriginalDCCODate AS DATE),103) ELSE NULL END ORIGINALDCCODATE
					,CASE WHEN  ISNULL(ExtendedDCCODate,'')<>'' THEN CONVERT(VARCHAR(10),CAST(ExtendedDCCODate AS DATE),103) ELSE NULL END EXTENDEDDCCODATE
					,CASE WHEN  ISNULL(ActualDCCODate,'')<>'' THEN CONVERT(VARCHAR(10),CAST(ActualDCCODate AS DATE),103) ELSE NULL END ACTUALDCCODATE
					,INFRASTRUCTUREYN
					,DFVAMOUNT
					,CASE WHEN  ISNULL(EffectiveNPADate,'')<>'' THEN CONVERT(VARCHAR(10),CAST(EffectiveNPADate AS DATE),103) ELSE NULL END EFFECTIVENPADATE
					,NPAREASON
					,'RestructureData' TableName
			FROM #Restructure 
		END
		DROP TABLE #Restructure
END

ELSE IF @ScreenFlag = 'Fraud'
BEGIN
	
	
		IF OBJECT_ID('TEMPDB..#Fraud') IS NOT NULL
				DROP TABLE #Fraud

		SELECT 
		ROW_NUMBER()OVER(ORDER BY (SELECT  (1))) RowNum
		
		,C.value('./UCICID				[1]','VARCHAR(30)') UCICID  
		,C.value('./CUSTOMERID			[1]','VARCHAR(50)') CUSTOMERID  
		,C.value('./CUSTOMERNAME		[1]','VARCHAR(225)') CUSTOMERNAME  
		,C.value('./ACCOUNTID			[1]','VARCHAR(30)') CustomerAcID
		,C.value('./DATEOFFRAUD			[1]','VARCHAR(30)') FraudDate
		,CASE WHEN C.value('./AMOUNTOFFRAUD		[1]','VARCHAR(30)')='' THEN NULL ELSE C.value('./AMOUNTOFFRAUD		[1]','DECIMAL(18,2)') END FraudAmt
		,CAST(NULL AS VARCHAR(MAX))ERROR
		,C.value('./EFFECTIVENPADATE			[1]','VARCHAR(30)') EffectiveNPADate
		INTO #Fraud
		FROM @XMLDocument.nodes('/DataSet/Gridrow') AS t(c)

		
		
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
		END
		DROP TABLE #Fraud
END			
			
ELSE IF @ScreenFlag = 'Review'
BEGIN
	


	IF OBJECT_ID('TEMPDB..#Review') IS NOT NULL
				DROP TABLE #Review

		SELECT 
		ROW_NUMBER()OVER(ORDER BY (SELECT  (1))) RowNum
		,C.value('./CUSTOMERID			[1]','VARCHAR(50)') CUSTOMERID  
		,C.value('./ACCOUNTID			[1]','VARCHAR(30)') CustomerAcID
		,C.value('./REVIEWDATE			[1]','VARCHAR(30)') ReviewDate
		,C.value('./REVIEWEXPIRYDATE	[1]','VARCHAR(30)') ReviewExpDt
		,C.value('./FACILITY_TYPE		[1]','VARCHAR(30)') FacilityType		
		,C.value('./REMARKS				[1]','VARCHAR(500)') Remarks		
		,CAST(NULL AS VARCHAR(MAX))ERROR
		INTO #Review
		FROM @XMLDocument.nodes('/DataSet/Gridrow') AS t(c)

	
		
		/****************************************************************************************************************
					
											FOR CHECKING A CUSTOMER ID 

		****************************************************************************************************************/
		UPDATE F
		SET ERROR = CASE WHEN ISNULL(F.CUSTOMERID,'')='' THEN 'Customer Id should not be Empty'
						 WHEN ISNULL(C.RefCustomerID,'')='' THEN 'Invalid Customer Id'
						 ELSE ERROR
					END
		FROM #Review F
		LEFT OUTER JOIN PRO.CustomerCal C
			ON C.RefCustomerID = F.CUSTOMERID-- C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey	AND C.RefCustomerID = F.CUSTOMERID

			/****************************************************************************************************************
					
											FOR CHECKING A ACCOUNT ID 

		****************************************************************************************************************/

		UPDATE F
		SET ERROR = CASE	WHEN ISNULL(A.CustomerAcID,'')='' AND ISNULL(ERROR,'')=''	THEN 'Invalid Account Id'
							WHEN ISNULL(A.CustomerAcID,'')='' AND ISNULL(ERROR,'')<>'' THEN ERROR+','+SPACE(1)+'Invalid Account Id'
							ELSE ERROR
					END
		FROM #Review F
		LEFT OUTER JOIN PRO.AccountCal A
			ON A.CustomerAcID = F.CustomerAcID --A.EffectiveFromTimeKey <= @Timekey AND A.EffectiveToTimeKey >= @Timekey	AND A.CustomerAcID = F.CustomerAcID
		WHERE ISNULL(F.CustomerAcID,'')<>''




		UPDATE F
		SET ERROR = CASE	WHEN  ISNULL(C.CustomerAcID,'')='' AND ISNULL(ERROR,'')=''	THEN 'Account Id Not Belong to that Customer Id'

							WHEN ISNULL(C.CustomerAcID,'')='' AND ISNULL(ERROR,'')<>''	THEN  ISNULL(ERROR,'')+','+SPACE(1)+'Account Id Not Belong to that Customer Id'
							ELSE ERROR
					END
		
		FROM #Review F
		LEFT OUTER JOIN PRO.AccountCal C
			ON F.CUSTOMERID = C.RefCustomerID	AND F.CustomerAcID = C.CustomerAcID-- C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey	AND F.CUSTOMERID = C.RefCustomerID	AND F.CustomerAcID = C.CustomerAcID
		WHERE  ISNULL(F.CustomerAcID,'')<>''


			
		/****************************************************************************************************************
					
											FOR CHECKING A REVIEW RENEWAL DATGE

		****************************************************************************************************************/
		


				UPDATE A
				SET ERROR = 
							--CASE	WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.ReviewDate,'')<>''	THEN ERROR+','+'Invalid Review Renewal Date'
							--		WHEN ISNULL(ERROR,'')='' AND ISNULL(A.ReviewDate,'')<>''	THEN 'Invalid Review Renewal Date'
							--	ELSE ERROR
							--END
							CASE	WHEN ISNULL(ERROR,'')=''  AND ISNULL(A.ReviewDate,'')<>'' AND ISNULL(B.correct,0)<>1 
											THEN 'Invalid Review Date'

										WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.ReviewDate,'')<>'' AND ISNULL(B.correct,0)<>1 
													THEN ISNULL(ERROR,'')+','+SPACE(1)+ 'Invalid Review Date'

										WHEN ISNULL(ERROR,'')=''  AND ISNULL(A.ReviewDate,'')='' 
													THEN 'Review Date cannot be empty'

										WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.ReviewDate,'')='' THEN 
													ISNULL(ERROR,'')+','+SPACE(1)+ 'Review Date cannot be empty'

									ELSE ERROR
								END
				
				 FROM #Review A
				LEFT OUTER JOIN 
			(
			
				SELECT RowNum ,1 correct FROM #Review
				WHERE ISDATE(ReviewDate)=1
				AND (CASE	WHEN SUBSTRING(RTRIM(LTRIM(ReviewDate)),3,1)='-' 
								AND (LEN(RTRIM(LTRIM(ReviewDate)))=9 OR LEN(RTRIM(LTRIM(ReviewDate)))=11 )
								AND ISNUMERIC(SUBSTRING(RTRIM(LTRIM(ReviewDate)),4,3))=0 
								AND  SUBSTRING(RTRIM(LTRIM(ReviewDate)),7,1)='-' 
							THEN 1

							WHEN SUBSTRING(RTRIM(LTRIM(ReviewDate)),3,1)='/'
							AND (LEN(RTRIM(LTRIM(ReviewDate)))=8 OR LEN(RTRIM(LTRIM(ReviewDate)))=10 )
							 AND  SUBSTRING(RTRIM(LTRIM(ReviewDate)),6,1)='/' THEN 1
					END)=1
			)B 
			ON A.RowNum = B.RowNum
			WHERE ISNULL(B.RowNum,'')='' 
			AND ISNULL(A.ReviewDate,'')<>''

		
		/****************************************************************************************************************
					
											FOR CHECKING A REVIEW Expiry DATGE

		****************************************************************************************************************/
			
			UPDATE A
				SET ERROR = 
							--CASE	WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.ReviewExpDt,'')<>''	THEN ERROR+','+'Invalid Review Expiry Date'
							--		WHEN ISNULL(ERROR,'')='' AND ISNULL(A.ReviewExpDt,'')<>''	THEN 'Invalid Review Expiry Date'
							--	ELSE ERROR
							--END
							CASE	WHEN ISNULL(ERROR,'')=''  AND ISNULL(A.ReviewExpDt,'')<>'' AND ISNULL(B.correct,0)<>1 
											THEN 'Invalid Review Expiry Date'

										WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.ReviewExpDt,'')<>'' AND ISNULL(B.correct,0)<>1 
													THEN ISNULL(ERROR,'')+','+SPACE(1)+ 'Invalid Review Expiry Date'

										WHEN ISNULL(ERROR,'')=''  AND ISNULL(A.ReviewExpDt,'')='' 
													THEN 'Review Expiry Date cannot be empty'

										WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.ReviewExpDt,'')='' THEN 
													ISNULL(ERROR,'')+','+SPACE(1)+ 'Review Expiry Date cannot be empty'

									ELSE ERROR
								END
				
				 FROM #Review A
				LEFT OUTER JOIN 
			(
			
				SELECT RowNum ,1 correct FROM #Review
				WHERE ISDATE(ReviewExpDt)=1
				AND (CASE	WHEN SUBSTRING(RTRIM(LTRIM(ReviewExpDt)),3,1)='-' 
								AND (LEN(RTRIM(LTRIM(ReviewExpDt)))=9 OR LEN(RTRIM(LTRIM(ReviewExpDt)))=11 )
								AND ISNUMERIC(SUBSTRING(RTRIM(LTRIM(ReviewExpDt)),4,3))=0 
								AND  SUBSTRING(RTRIM(LTRIM(ReviewExpDt)),7,1)='-' 
							THEN 1

							WHEN SUBSTRING(RTRIM(LTRIM(ReviewExpDt)),3,1)='/'
							AND (LEN(RTRIM(LTRIM(ReviewExpDt)))=8 OR LEN(RTRIM(LTRIM(ReviewExpDt)))=10 )
							 AND  SUBSTRING(RTRIM(LTRIM(ReviewExpDt)),6,1)='/' THEN 1
					END)=1
			)B 
			ON A.RowNum = B.RowNum
			WHERE ISNULL(B.RowNum,'')='' 
			AND ISNULL(A.ReviewExpDt,'')<>''


		


		
		IF EXISTS(SELECT 1 FROM #Review WHERE ISNULL(ERROR,'')<>'')
		BEGIN
			SELECT RowNum
					, CUSTOMERID
					,CUSTOMERACID
					,REVIEWDATE
					,REVIEWEXPDT 
					,FACILITYTYPE
					,REMARKS
					,ERROR
					,'ErrorData' TableName
			FROM #Review WHERE ISNULL(ERROR,'')<>''
		END
		ELSE
		BEGIN	
			
			SELECT RowNum
					, CUSTOMERID
					,CUSTOMERACID
					,CASE WHEN ISNULL(ReviewDate,'')<>'' THEN CONVERT(VARCHAR(10),CAST(ReviewDate AS DATE),103) ELSE ReviewDate END REVIEWDATE
					,CASE WHEN ISNULL(ReviewExpDt,'')<>'' THEN CONVERT(VARCHAR(10),CAST(ReviewExpDt AS DATE),103) ELSE ReviewExpDt END REVIEWEXPDT 
					,FACILITYTYPE
					,REMARKS
					,'ReviewData' TableName
			FROM #Review WHERE ISNULL(ERROR,'')=''
		END

		DROP TABLE #Review
END						

ELSE IF @ScreenFlag = 'RePossessed'
BEGIN
	IF OBJECT_ID('TEMPDB..#RePossessed') IS NOT NULL
				DROP TABLE #RePossessed

		SELECT 
		ROW_NUMBER()OVER(ORDER BY (SELECT  (1))) RowNum
		,C.value('./ACCOUNTID			[1]','VARCHAR(30)') CustomerAcID
		,C.value('./REPOSSESSIONDATE	[1]','VARCHAR(30)') RepossessionDate

		,CAST(NULL AS VARCHAR(MAX))ERROR
		INTO #RePossessed
		FROM @XMLDocument.nodes('/DataSet/Gridrow') AS t(c)

		
		SELECT * FROM #RePossessed

		/****************************************************************************************************************
					
											FOR CHECKING A ACCOUNT ID 

		****************************************************************************************************************/

		UPDATE F
		SET ERROR = CASE	WHEN ISNULL(F.CustomerAcID,'')='' AND ISNULL(ERROR,'') =''		THEN 'Account Id should not be Empty'
							WHEN ISNULL(F.CustomerAcID,'')='' AND ISNULL(ERROR,'') <>''		THEN ERROR+',' +SPACE(1)+'Account Id should not be Empty'

							WHEN ISNULL(A.CustomerAcID,'')='' AND ISNULL(ERROR,'')=''	THEN 'Invalid Account Id'
							WHEN ISNULL(A.CustomerAcID,'')='' AND ISNULL(ERROR,'')<>'' THEN ERROR+','+SPACE(1)+'Invalid Account Id'

							ELSE ERROR
					END
		FROM #RePossessed F
		LEFT OUTER JOIN PRO.AccountCal A
			ON A.CustomerAcID = F.CustomerAcID-- A.EffectiveFromTimeKey <= @Timekey AND A.EffectiveToTimeKey >= @Timekey	AND A.CustomerAcID = F.CustomerAcID
		--WHERE ISNULL(F.CustomerAcID,'')<>''


		/****************************************************************************************************************
					
											FOR CHECKING A Repossession Date

		****************************************************************************************************************/
			
			UPDATE A
				SET ERROR = 
							--CASE	WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.RepossessionDate,'')<>''THEN ERROR+','+'Invalid Repossession Date'
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
				
				 FROM #RePossessed A
				LEFT OUTER JOIN 
			(
			
				SELECT RowNum ,1 correct FROM #RePossessed
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
			WHERE ISNULL(B.RowNum,'')='' 

		
			
		IF EXISTS(SELECT 1 FROM #RePossessed WHERE ISNULL(ERROR,'')<>'')
		BEGIN
			SELECT RowNum
					,CUSTOMERACID
					,REPOSSESSIONDATE
					,ERROR
					,'ErrorData' TableName
			FROM #RePossessed WHERE ISNULL(ERROR,'')<>''
		END
		ELSE
		BEGIN	
			
			SELECT  RowNum
					,CUSTOMERACID
					,CONVERT(VARCHAR(10),CAST(RepossessionDate AS DATE), 103)REPOSSESSIONDATE
					,ERROR
					,'RePossessedData' TableName
			FROM #RePossessed WHERE ISNULL(ERROR,'')=''
		END

		DROP TABLE #RePossessed
END

ELSE IF @ScreenFlag = 'Provision'
BEGIN
	IF OBJECT_ID('TEMPDB..#ProvisionData') IS NOT NULL
				DROP TABLE #ProvisionData

		SELECT 
		ROW_NUMBER()OVER(ORDER BY (SELECT  (1))) RowNum
		
		,C.value('./UCIFID				[1]','VARCHAR(30)') UCICID  
		,C.value('./CUSTOMERID			[1]','VARCHAR(50)') CUSTOMERID  
		,C.value('./CUSTOMERNAME		[1]','VARCHAR(225)') CUSTOMERNAME  
		,C.value('./REFCUSTOMERID		[1]','VARCHAR(50)') REFCUSTOMERID  
		,C.value('./ASSETCLASS			[1]','VARCHAR(30)') AssetClass
		,C.value('./ASSETSUBCLASS		[1]','VARCHAR(30)') AssetSubclass
		,C.value('./PROVISIONPERCENT	[1]','VARCHAR(30)') ProvisionPercent
		,C.value('./ACCOUNTID			[1]','VARCHAR(30)') CustomerAcID
		,CAST(NULL AS VARCHAR(MAX))ERROR
		INTO #ProvisionData
		FROM @XMLDocument.nodes('/DataSet/Gridrow') AS t(c)


		/****************************************************************************************************************
					
											FOR CHECKING A UCIF ID 

		****************************************************************************************************************/

		
		UPDATE #ProvisionData
		SET  ERROR = 
		CASE	WHEN ISNULL(C.UCIF_ID,'')='' AND ISNULL(ERROR,'')='' THEN 'Invalid UCIF_ID Id'
							WHEN ISNULL(C.UCIF_ID,'')=''AND ISNULL(ERROR,'')<>'' THEN ERROR+','+SPACE(1)+ 'Invalid UCIF_ID Id'
							ELSE ERROR
					END
		FROM 
		#ProvisionData F
		LEFT OUTER  JOIN pro.customercal  C
			ON  C.UCIF_ID = F.UCICID --C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey		AND C.UCIF_ID = F.UCICID
		WHERE ISNULL(F.UCICID,'')<>''

		--SELECT * FROM #ProvisionData
	
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
		FROM #ProvisionData F
		LEFT OUTER JOIN PRO.CustomerCal C
			ON C.RefCustomerID = F.CUSTOMERID --C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey	AND C.RefCustomerID = F.CUSTOMERID




			/****************************************************************************************************************
					
											FOR CHECKING A REF CUSTOMER ID 

		****************************************************************************************************************/
	

		UPDATE F
		SET ERROR = CASE	WHEN ISNULL(F.CUSTOMERID,'')='' AND ISNULL(ERROR,'')=''		THEN 'RefCustomer Id should not be Empty'
							WHEN ISNULL(F.CUSTOMERID,'')='' AND ISNULL(ERROR,'')<>''	THEN ERROR+','+SPACE(1) +'RefCustomer Id should not be Empty'
							WHEN ISNULL(C.RefCustomerID,'')='' AND ISNULL(ERROR,'')=''	THEN 'Invalid RefCustomer Id'
							WHEN ISNULL(C.RefCustomerID,'')='' AND ISNULL(ERROR,'')<>''	THEN ERROR+','+SPACE(1) +'Invalid RefCustomer Id'
							ELSE ERROR
					END
		FROM #ProvisionData F
		LEFT OUTER JOIN PRO.CustomerCal C
			ON C.RefCustomerID = F.REFCUSTOMERID --C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey	AND C.RefCustomerID = F.REFCUSTOMERID
			AND ISNULL(F.REFCUSTOMERID,'')<>''
					
		/****************************************************************************************************************
					
											FOR CHECKING A ACCOUNT ID 

		****************************************************************************************************************/

		UPDATE F
		SET ERROR = CASE	WHEN ISNULL(A.CustomerAcID,'')='' AND ISNULL(ERROR,'')=''	THEN 'Invalid Account Id'
							WHEN ISNULL(A.CustomerAcID,'')='' AND ISNULL(ERROR,'')<>'' THEN ERROR+','+SPACE(1)+'Invalid Account Id'
							ELSE ERROR
					END
		FROM #ProvisionData F
		LEFT OUTER JOIN PRO.AccountCal A
			ON F.CUSTOMERID = A.RefCustomerID AND F.CustomerAcID = A.CustomerAcID  --A.EffectiveFromTimeKey <= @Timekey AND A.EffectiveToTimeKey >= @Timekey	AND F.CUSTOMERID = A.RefCustomerID AND F.CustomerAcID = A.CustomerAcID
		WHERE ISNULL(F.CustomerAcID,'')<>''




		UPDATE A
		SET ERROR = CASE	WHEN  ISNULL(C.CustomerAcID,'')='' AND ISNULL(ERROR,'')=''	THEN 'Account Id Not Belong to that Customer Id'

							WHEN ISNULL(C.CustomerAcID,'')='' AND ISNULL(ERROR,'')<>''	THEN  ISNULL(ERROR,'')+','+SPACE(1)+'Account Id Not Belong to that Customer Id'
							ELSE ERROR
					END
		
		FROM #ProvisionData A
		LEFT OUTER JOIN PRO.AccountCal C
			ON A.CUSTOMERID = C.RefCustomerID	AND A.CustomerAcID = C.CustomerAcID --C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey	AND A.CUSTOMERID = C.RefCustomerID	AND A.CustomerAcID = C.CustomerAcID
		WHERE  ISNULL(A.CustomerAcID,'')<>''


		UPDATE F
		SET ERROR = CASE	WHEN  ISNULL(C.UCIF_ID,'')='' AND ISNULL(ERROR,'')=''	THEN 'UCIC ID  Not Belong to that Customer Id'

							WHEN ISNULL(C.UCIF_ID,'')='' AND ISNULL(ERROR,'')<>''	THEN  ISNULL(ERROR,'')+','+SPACE(1)+'UCIC ID  Not Belong to that Customer Id'
							ELSE ERROR
					END
		
		FROM #ProvisionData F
		LEFT OUTER JOIN PRO.CustomerCal C
			ON F.CUSTOMERID = C.RefCustomerID	AND F.UCICID = C.UCIF_ID --C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey		AND F.CUSTOMERID = C.RefCustomerID	AND F.UCICID = C.UCIF_ID
		WHERE  ISNULL(F.UCICID,'')<>''


		/****************************************************************************************************************
					
											FOR CHECKING A AssetClass

		****************************************************************************************************************/


		UPDATE #ProvisionData
		SET ERROR = CASE	WHEN ISNULL(AssetClass,'')='' AND ISNULL(ERROR,'')=''		THEN 'AssetClass should not be Empty'
							WHEN ISNULL(AssetClass,'')='' AND ISNULL(ERROR,'')<>''		THEN ERROR+','+SPACE(1)+ 'AssetClass should not be Empty'
							WHEN ISNULL(AssetClass,'')<>'NPA' AND ISNULL(ERROR,'')=''	THEN 'Asset Class Should be NPA'
							WHEN ISNULL(AssetClass,'')<>'NPA' AND ISNULL(ERROR,'')<>''	THEN ERROR+','+SPACE(1)+ 'Asset Class Should be NPA'
					ELSE ERROR
					END
		WHERE ISNULL(AssetClass,'')='' OR ISNULL(AssetClass,'')<>'NPA'


		/****************************************************************************************************************
					
											FOR CHECKING A Asset SUB Class

		****************************************************************************************************************/


		UPDATE #ProvisionData
		SET ERROR = CASE	WHEN ISNULL(AssetSubclass,'')='' AND ISNULL(ERROR,'')=''		THEN 'AssetSubclass should not be Empty'
							WHEN ISNULL(AssetSubclass,'')='' AND ISNULL(ERROR,'')<>''		THEN ERROR+','+SPACE(1)+ 'AssetSubclass should not be Empty'
							WHEN ISNULL(AssetSubclass,'')<>'SUB' AND ISNULL(ERROR,'')=''	THEN 'AssetSubclass Should be SUB'
							WHEN ISNULL(AssetSubclass,'')<>'SUB' AND ISNULL(ERROR,'')<>''	THEN ERROR+','+SPACE(1)+ 'AssetSubclass Should be SUB'
					ELSE ERROR
					END
		WHERE ISNULL(AssetSubclass,'')='' OR ISNULL(AssetSubclass,'')<>'SUB'


			/****************************************************************************************************************
					
											FOR CHECKING A Provsion PERCENT


		****************************************************************************************************************/


		--UPDATE #ProvisionData
		--SET ERROR = CASE WHEN ISNULL(ERROR,'')='' THEN 'Incorrect ProvisionPercent'
		--				WHEN ISNULL(ERROR,'')<>'' THEN ERROR+','+SPACE(1)+'Incorrect ProvisionPercent'
		--			END
		--WHERE ISNULL(ProvisionPercent,'')<>'' AND ISNUMERIC(ProvisionPercent)=0


			UPDATE #ProvisionData
		SET ERROR = CASE	WHEN ISNUMERIC(ProvisionPercent)= 0 AND  ISNULL(ERROR,'')=''	THEN 'Incorrect Provision Percent' 
							WHEN ISNUMERIC(ProvisionPercent)= 0 AND  ISNULL(ERROR,'')<>''	THEN ERROR+','+SPACE(1)+'Incorrect Provision Percent' 
							WHEN (ISNULL(CAST(ProvisionPercent as DECIMAL (6,2)),0) NOT BETWEEN 0 AND 100)  AND ISNULL(ERROR,'')=''		THEN 'Provision Percentage Should be between 0 to 100'
							WHEN (ISNULL(CAST(ProvisionPercent as DECIMAL (6,2)),0) NOT BETWEEN 0 AND 100)  AND ISNULL(ERROR,'')<>''	THEN ERROR+','+SPACE(1)+ 'Provision Percentage Should be between 0 to 100'
							ELSE ERROR
					END
		WHERE ISNULL(ProvisionPercent,'')<>'' 

			IF EXISTS(SELECT 1 FROM #ProvisionData WHERE ISNULL(ERROR,'')<>'')
		BEGIN
			SELECT RowNum
					,UCICID  
					,CUSTOMERID  
					,CUSTOMERNAME  
					,REFCUSTOMERID
					,ASSETCLASS
					,ASSETSUBCLASS
					,PROVISIONPERCENT
					,CUSTOMERACID
					,ERROR
					,'ErrorData' TableName
			FROM #ProvisionData WHERE ISNULL(ERROR,'')<>''
		END
		ELSE
		BEGIN	
			
			SELECT RowNum
					,UCICID  
					,CUSTOMERID  
					,CUSTOMERNAME  
					,REFCUSTOMERID
					,ASSETCLASS
					,ASSETSUBCLASS
					,PROVISIONPERCENT
					,CUSTOMERACID
					,ERROR
					,'ProvisionData' TableName
			FROM #ProvisionData WHERE ISNULL(ERROR,'')=''
		END

		DROP TABLE #ProvisionData
END

ELSE IF @ScreenFlag = 'Security'
BEGIN

		

		IF OBJECT_ID('TEMPDB..#Security') IS NOT NULL
				DROP TABLE #Security

		SELECT 
		ROW_NUMBER()OVER(ORDER BY (SELECT  (1))) RowNum
		
		,C.value('./UCIFID				[1]','VARCHAR(30)')UCICID  
		,C.value('./CUSTOMERID			[1]','VARCHAR(50)')CUSTOMERID  
		,C.value('./SECURITYCODE		[1]','VARCHAR(30)')SecurityCode
		,C.value('./REFCUSTOMERID		[1]','VARCHAR(50)')RefCustomerID
		,C.value('./SECURITYDESCRIPTION	[1]','VARCHAR(250)')SecurityDescription
		,C.value('./SECURITYNAME		[1]','VARCHAR(100)')SecurityName
		,C.value('./ACCOUNTID			[1]','VARCHAR(30)')CustomerAcID
		,C.value('./SECURITYTYPE		[1]','VARCHAR(50)')SecurityType
		,CASE WHEN C.value('./CURRENTVALUE		[1]','VARCHAR(30)')='' THEN NULL 
			  WHEN C.value('./CURRENTVALUE		[1]','VARCHAR(30)')='NULL' THEN NULL 
			  ELSE C.value('./CURRENTVALUE		[1]','DECIMAL(18,2)') END CurrentValue
		,C.value('./VALUATIONDATE		[1]','VARCHAR(30)')ValuationDate

		,CAST(NULL AS VARCHAR(MAX))ERROR
		,C.value('./EFFECTIVENPADATE			[1]','VARCHAR(30)') EffectiveNPADate
		INTO #Security
		FROM @XMLDocument.nodes('/DataSet/Gridrow') AS t(c)

		
		
		/****************************************************************************************************************
					
											FOR CHECKING A UCIF ID 

		****************************************************************************************************************/
		UPDATE F
		SET ERROR = CASE	WHEN ISNULL(C.UCIF_ID,'')=''AND ISNULL(ERROR,'')='' THEN 'Invalid UCIF ID'
							WHEN ISNULL(C.UCIF_ID,'')=''AND ISNULL(ERROR,'')<>'' THEN ERROR+','+SPACE(1)+ 'Invalid UCIF ID'

							ELSE ERROR
					END
		FROM 
		#Security F
		LEFT OUTER  JOIN pro.customercal  C
			ON C.UCIF_ID = F.UCICID-- C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey	AND C.UCIF_ID = F.UCICID
		WHERE ISNULL(UCICID,'')<>''


		UPDATE F
		SET ERROR = CASE	WHEN  ISNULL(C.UCIF_ID,'')='' AND ISNULL(ERROR,'')=''	THEN 'UCIC ID  Not Belong to that Customer Id'

							WHEN ISNULL(C.UCIF_ID,'')='' AND ISNULL(ERROR,'')<>''	THEN  ISNULL(ERROR,'')+','+SPACE(1)+'UCIC ID  Not Belong to that Customer Id'
							ELSE ERROR
					END
		
		FROM #Security F
		LEFT OUTER JOIN PRO.CustomerCal C
			ON F.CUSTOMERID = C.RefCustomerID	AND F.UCICID = C.UCIF_ID ---C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey	AND F.CUSTOMERID = C.RefCustomerID	AND F.UCICID = C.UCIF_ID
		WHERE  ISNULL(F.UCICID,'')<>''

		/****************************************************************************************************************
					
											FOR CHECKING A CUSTOMER ID 

		****************************************************************************************************************/
		
		UPDATE A
		SET ERROR = CASE	WHEN ISNULL(A.CUSTOMERID,'')=''		THEN 'Customer Id should not be Empty'
							WHEN ISNULL(C.RefCustomerID,'')=''	THEN 'Invalid Customer Id'
							ELSE ERROR
					END
		FROM #Security A
		LEFT OUTER JOIN PRO.CustomerCal C
			ON A.CUSTOMERID = C.RefCustomerID --C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey	AND A.CUSTOMERID = C.RefCustomerID


/****************************************************************************************************************
					
											FOR CHECKING A ACCOUNT ID 

		****************************************************************************************************************/
		
			UPDATE A
		SET ERROR = CASE	WHEN  ISNULL(C.CustomerAcID,'')='' AND ISNULL(ERROR,'')=''	THEN 'Account Id Not Belong to that Customer Id'

							WHEN ISNULL(C.CustomerAcID,'')='' AND ISNULL(ERROR,'')<>''	THEN  ISNULL(ERROR,'')+','+SPACE(1)+'Account Id Not Belong to that Customer Id'
							ELSE ERROR
					END
		
		FROM #Security A
		LEFT OUTER JOIN PRO.AccountCal C
			ON A.CUSTOMERID = C.RefCustomerID	AND A.CustomerAcID = C.CustomerAcID --C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey	AND A.CUSTOMERID = C.RefCustomerID	AND A.CustomerAcID = C.CustomerAcID
		WHERE  ISNULL(A.CustomerAcID,'')<>''



			/****************************************************************************************************************
					
											FOR CHECKING A REF CUSTOMER ID 

		****************************************************************************************************************/

		UPDATE A
		SET ERROR = CASE	WHEN ISNULL(A.CUSTOMERID,'')=''	AND ISNULL(ERROR,'')=''		THEN 'RefCustomer Id should not be Empty'
							WHEN ISNULL(A.CUSTOMERID,'')=''	AND ISNULL(ERROR,'')<>''	THEN ISNULL( ERROR,'')+','+SPACE(1)+'RefCustomer Id should not be Empty'
							WHEN ISNULL(C.RefCustomerID,'')='' AND ISNULL(ERROR,'')=''	THEN 'Invalid RefCustomer Id'
							WHEN ISNULL(C.RefCustomerID,'')='' AND ISNULL(ERROR,'')<>''	THEN ISNULL(ERROR,'')+','+SPACE(1)+ 'Invalid RefCustomer Id'
							ELSE ERROR
					END
		FROM #Security A
		LEFT OUTER JOIN PRO.CustomerCal C
			ON A.CUSTOMERID = C.RefCustomerID --C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey		AND A.CUSTOMERID = C.RefCustomerID
		WHERE ISNULL(A.RefCustomerID,'')<>''

		
		/****************************************************************************************************************
					
											FOR CHECKING A SECURITY CODE

		****************************************************************************************************************/

		UPDATE #Security
		SET ERROR = CASE	WHEN ISNULL(ERROR,'')<>'' THEN ERROR+','+SPACE(1)+'SecurityCode Length should not be  greater then 30 Chararter' 
							WHEN ISNULL(ERROR,'')='' THEN  'SecurityCode Length should not be  greater then 30 Chararter' 

							ELSE ERROR
					END
		WHERE LEN(SecurityCode)>30


		/****************************************************************************************************************
					
											FOR CHECKING A SecurityDescription

		****************************************************************************************************************/


		UPDATE #Security
		SET ERROR = CASE	WHEN ISNULL(ERROR,'')<>'' THEN ERROR+','+SPACE(1)+'Security Description Length should not be  greater then 250 Chararter' 
							WHEN ISNULL(ERROR,'')='' THEN  'Security Description Length should not be  greater then 250 Chararter' 
							ELSE ERROR
					END
		WHERE LEN(SecurityDescription)>250


		/****************************************************************************************************************
					
											FOR CHECKING A SecurityDescription

		****************************************************************************************************************/


		UPDATE #Security
		SET ERROR = CASE	WHEN ISNULL(ERROR,'')<>'' THEN ERROR+','+SPACE(1)+'Security Name Length should not be  greater then 100 Chararter' 
							WHEN ISNULL(ERROR,'')='' THEN  'Security Name Length should not be  greater then 100 Chararter' 
							ELSE ERROR
					END
		WHERE LEN(SecurityName)>100



		/****************************************************************************************************************
					
											FOR CHECKING A ACCOUNT  ID 

		****************************************************************************************************************/


		
		UPDATE A
		SET ERROR = CASE	WHEN  ISNULL(C.CustomerAcID,'')='' AND ISNULL(ERROR,'')=''	THEN 'Invalid Account Id'

							WHEN ISNULL(C.CustomerAcID,'')='' AND ISNULL(ERROR,'')<>''	THEN  ISNULL(ERROR,'')+','+SPACE(1)+'Invalid Account Id'
							ELSE ERROR
					END
		
		FROM #Security A
		LEFT OUTER JOIN PRO.AccountCal C
			ON A.CUSTOMERID = C.RefCustomerID	AND A.CustomerAcID = C.CustomerAcID --C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey	AND A.CUSTOMERID = C.RefCustomerID	AND A.CustomerAcID = C.CustomerAcID
		WHERE  ISNULL(A.CustomerAcID,'')<>''

			/****************************************************************************************************************
					
											FOR CHECKING A Security Type

		****************************************************************************************************************/


		UPDATE #Security
		SET ERROR = CASE	WHEN ISNULL(ERROR,'')<>'' THEN ERROR+','+SPACE(1)+'Security Type Length should not be  greater then 50 Chararter' 
							WHEN ISNULL(ERROR,'')='' THEN  'Security Type Length should not be  greater then 50 Chararter' 
							ELSE ERROR
					END
		WHERE LEN(SecurityType)>50

		print 11111

		/****************************************************************************************************************
					
											FOR CHECKING A STOCKVALUE

		****************************************************************************************************************/

		UPDATE #Security
		SET ERROR = CASE	WHEN ISNUMERIC(CurrentValue)= 0 AND  ISNULL(ERROR,'')=''	THEN 'Incorrect Security Value' 
							WHEN ISNUMERIC(CurrentValue)= 0 AND  ISNULL(ERROR,'')<>''	THEN ERROR+','+SPACE(1)+'Incorrect Security Value' 
							WHEN LEN(CurrentValue)>19  AND ISNULL(ERROR,'')=''		THEN 'Lengh is Security value should be less then 20'
							WHEN LEN(CurrentValue)>19  AND ISNULL(ERROR,'')<>''		THEN 'Lengh is Security value should be less then 20'
							ELSE ERROR
					END
		WHERE ISNULL(CurrentValue,0)<>0  --AND ISNUMERIC(StockValue)= 0 

		print 11111
		/****************************************************************************************************************
					
											FOR CHECKING A STOCK STATEMENT DATE

		****************************************************************************************************************/
	
		--SELECT * FROM #Security

				UPDATE A
				SET ERROR = 
							--CASE	WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.ValuationDate,'')<>''	THEN ERROR+','+'Invalid valuation Date'
							--		WHEN ISNULL(ERROR,'')='' AND ISNULL(A.ValuationDate,'')<>''	THEN 'Invalid valuation Date'
							--		WHEN ISNULL(ERROR,'')='' AND ISNULL(A.ValuationDate,'')=''		THEN 'valuation Date cannot be empty/ Invalid  Date'
							--		WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.ValuationDate,'')=''	THEN ERROR+','+'valuation Date cannot be empty'

							--	ELSE ERROR
							--END
							CASE	WHEN ISNULL(ERROR,'')=''  AND ISNULL(A.ValuationDate,'')<>'' AND ISNULL(B.correct,0)<>1 
											THEN 'Invalid valuation Date'

										WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.ValuationDate,'')<>'' AND ISNULL(B.correct,0)<>1 
													THEN ISNULL(ERROR,'')+','+SPACE(1)+ 'Invalid valuation Date'

										WHEN ISNULL(ERROR,'')=''  AND ISNULL(A.ValuationDate,'')='' 
													THEN 'valuation Date cannot be empty'

										WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.ValuationDate,'')='' THEN 
													ISNULL(ERROR,'')+','+SPACE(1)+ 'valuation Date cannot be empty'

									ELSE ERROR
								END
				 FROM #Security A
				LEFT OUTER JOIN 
			(
			--SELECT 1
				SELECT RowNum ,1 correct FROM #Security
				WHERE ISDATE(ValuationDate)=1
				AND (CASE	WHEN SUBSTRING(RTRIM(LTRIM(ValuationDate)),3,1)='-' 
								AND (LEN(RTRIM(LTRIM(ValuationDate)))=9 OR LEN(RTRIM(LTRIM(ValuationDate)))=11 )
								AND ISNUMERIC(SUBSTRING(RTRIM(LTRIM(ValuationDate)),4,3))=0 
								AND  SUBSTRING(RTRIM(LTRIM(ValuationDate)),7,1)='-' 
							THEN 1

							WHEN SUBSTRING(RTRIM(LTRIM(ValuationDate)),3,1)='/'
							AND (LEN(RTRIM(LTRIM(ValuationDate)))=8 OR LEN(RTRIM(LTRIM(ValuationDate)))=10 )
							 AND  SUBSTRING(RTRIM(LTRIM(ValuationDate)),6,1)='/' THEN 1
					END)=1
			)B 
			ON A.RowNum = B.RowNum
			WHERE ISNULL(B.RowNum,'')='' 
			AND ISNULL(A.ValuationDate,'')<>''



		/****************************************************************************************************************
					
											FOR CHECKING A Effective Date of NPA

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
				 FROM #Security A
				LEFT OUTER JOIN 
			(
			--SELECT 1
				SELECT RowNum ,1 correct FROM #Security
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
			WHERE ISNULL(B.RowNum,'')='' 
			AND ISNULL(A.EffectiveNPADate,'')<>''

			
			/****************************************************************************************************************
					
											FOR CHECKING A STOCK Valuation DATE

		****************************************************************************************************************/

		IF EXISTS(SELECT 1 FROM #Security WHERE ISNULL(ERROR,'')<>'')
		BEGIN
			SELECT	  RowNum
					, UCICID  
					,CUSTOMERID  
					,REFCUSTOMERID
					,SECURITYCODE
					,SECURITYDESCRIPTION
					,SECURITYNAME
					,CUSTOMERACID
					,SECURITYTYPE
					,CURRENTVALUE
					,VALUATIONDATE
					,EFFECTIVENPADATE
					,ERROR
					,'ErrorData' TableName
			FROM #Security WHERE ISNULL(ERROR,'')<>''
		END
		ELSE
		BEGIN	
			
			SELECT  RowNum
					, UCICID  
					,CUSTOMERID  
					,REFCUSTOMERID
					,SECURITYCODE
					,SECURITYDESCRIPTION
					,SECURITYNAME
					,CUSTOMERACID
					,SECURITYTYPE
					,CURRENTVALUE
					,CASE WHEN  ISNULL(ValuationDate,'')<>'' THEN CONVERT(VARCHAR(10),CAST(ValuationDate AS DATE),103) ELSE NULL END VALUATIONDATE
					,CASE WHEN  ISNULL(EffectiveNPADate,'')<>'' THEN CONVERT(VARCHAR(10),CAST(EffectiveNPADate AS DATE),103) ELSE NULL END EFFECTIVENPADATE
					,'SecurityData' TableName
			FROM #Security WHERE ISNULL(ERROR,'')=''
		END

		DROP TABLE #Security


END

ELSE IF @ScreenFlag = 'Customer'
BEGIN
		IF OBJECT_ID('TEMPDB..#Customer') IS NOT NULL
				DROP TABLE #Customer

		SELECT 
		ROW_NUMBER()OVER(ORDER BY (SELECT  (1))) RowNum
		 
		,C.value('./CUSTOMERID			[1]','VARCHAR(50)')CUSTOMERID  
		,C.value('./ASSETCLASSIFICATION	[1]','VARCHAR(30)')AssetClassification
		,C.value('./NPADATE				[1]','VARCHAR(30)')NPADate
		,C.value('./SECURITYVALUE		[1]','VARCHAR(30)')SecurityValue
		,CASE WHEN C.value('./ADDITIONALPROVISION	[1]','VARCHAR(30)')= '' THEN NULL ELSE C.value('./ADDITIONALPROVISION	[1]','DECIMAL(18,2)') END AdditionalProvision 
		,C.value('./MOCTYPE			[1]','VARCHAR(15)')MOCTYPE
		,C.value('./MOCREASON			[1]','VARCHAR(500)')MOCReason
		,CAST(NULL AS VARCHAR(MAX))ERROR
		,CASE WHEN C.value('./DOUBTFULDATE [1]','VARCHAR(30)')='' THEN NULL ELSE C.value('./DOUBTFULDATE [1]','VARCHAR(30)') END DOUBTFULDATE
		INTO #Customer
		FROM @XMLDocument.nodes('/DataSet/Gridrow') AS t(c)
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
		END

		DROP TABLE #Customer
END


ELSE IF @ScreenFlag = 'Account'
BEGIN
	IF OBJECT_ID('TEMPDB..#Account') IS NOT NULL
				DROP TABLE #Account

		SELECT 
		ROW_NUMBER()OVER(ORDER BY (SELECT  (1))) RowNum
		 
		,C.value('./CUSTOMERID			[1]','VARCHAR(50)')CUSTOMERID  
		,C.value('./ACCOUNTID			[1]','VARCHAR(30)')CUSTOMERAcID
		,C.value('./BALANCE 			[1]','VARCHAR(100)')Balance 
		,CASE WHEN C.value('./ADDITIONALPROVISION	[1]','VARCHAR(30)')= '' THEN NULL ELSE C.value('./ADDITIONALPROVISION	[1]','DECIMAL(18,2)') END AdditionalProvision
		,CASE WHEN C.value('./ADDITIONALPROVISIONAMOUNT	[1]','VARCHAR(30)')= '' THEN NULL ELSE C.value('./ADDITIONALPROVISIONAMOUNT	[1]','DECIMAL(18,2)') END AdditionalProvisionAmount 
  		,C.value('./APPROPRIATESECURITY [1]','VARCHAR(30)')AppropriateSecurity
		,C.value('./FITL				[1]','VARCHAR(30)')FITL  
		,CASE WHEN C.value('./DFVAMOUNT			[1]','VARCHAR(30)')='' THEN NULL ELSE C.value('./DFVAMOUNT			[1]','DECIMAL(18,2)') END DFVAmount  
		,C.value('./INFRASTRUCTUREYN		[1]','VARCHAR(30)') InfrastructureYN  
		,C.value('./REPOSSESSIONDATE	[1]','VARCHAR(30)') RepossessionDate  
		,C.value('./RESTRUCTUREDATE		[1]','VARCHAR(30)') RestructureDate  
		,C.value('./ORIGINALDCCODATE	[1]','VARCHAR(30)') OriginalDCCODate  
		,C.value('./EXTENDEDDCCODATE	[1]','VARCHAR(30)') ExtendedDCCODate  
		,C.value('./ACTUALDCCODATE		[1]','VARCHAR(30)') ActualDCCODate
		,C.value('./MOCREASON			[1]','VARCHAR(500)') MocReason
		,CAST(NULL AS VARCHAR(MAX))ERROR
		INTO #Account
		FROM @XMLDocument.nodes('/DataSet/Gridrow') AS t(c)


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
		END

		DROP TABLE #Account
END


ELSE IF @ScreenFlag = 'NPADate'
BEGIN

		

		IF OBJECT_ID('TEMPDB..#NPADate') IS NOT NULL
				DROP TABLE #NPADate

		SELECT 
		ROW_NUMBER()OVER(ORDER BY (SELECT  (1))) RowNum
		
		,C.value('./UCIFID				[1]','VARCHAR(30)')UCICID
		,CAST(NULL AS VARCHAR(MAX))ERROR
		,CASE WHEN C.value('./NPADATE			[1]','VARCHAR(30)') = '' THEN NULL ELSE C.value('./NPADATE			[1]','VARCHAR(30)')	END	NPADate
		,C.value('./NPADATECHANGEREASON				[1]','VARCHAR(500)')NPADATECHANGEREASON
		INTO #NPADate
		FROM @XMLDocument.nodes('/DataSet/Gridrow') AS t(c)

		
		
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
		END

		DROP TABLE #NPADate


END

ELSE IF @ScreenFlag = 'BackDated' -- Code Added for New Screen 
BEGIN


IF OBJECT_ID('TEMPDB..##AccountCal_HIST') IS NOT NULL
DROP TABLE ##AccountCal_HIST
CREATE Table ##AccountCal_HIST(CustomerACID varchar(30),
                               AccountEntityID int,
							   BranchCode VARCHAR(20),
							   TotalProvision DECIMAL(22,2),
							   RefCustomerID VARCHAR(50),
							   SourceSystemCustomerID VARCHAR(50),
							   UCIF_ID VARCHAR(50),
							   EffectiveFromTimeKey int,
							   NetBalance DECIMAL(22,2))
Declare @SQL Varchar(1000) = 'Select CustomerAcID,AccountEntityID,BranchCode,TotalProvision,RefCustomerID,SourceSystemCustomerID,UCIF_ID,EffectiveFromTimeKey,NetBalance From YBL_ACS_'+@Year+'.DBO.AccountCal_Main_'+@YEAR+'_'+@Month+' Where EffectiveFromTimeKey = '+CAST(@LastMonthDateKey as varchar(5))--+'AND FinalAssetClassAlt_Key <> 1' --Commented by shubham on 2024-04-11 since bank will pass provision for all accounts

--Select @SQL
Insert into  ##AccountCal_HIST
EXEC (@SQL) -- To be changed to DYNAMIC View Partioning

/*	-------------Commented By Tarkeshwar Singh on 20th July----------------------------------------


	IF OBJECT_ID('TEMPDB..#AbsoluteProvisionMOC_v') IS NOT NULL
				DROP TABLE #AbsoluteProvisionMOC_v

		SELECT		
		 ROW_NUMBER()OVER(ORDER BY (SELECT  (1))) RowNum
		,C.value('./CUSTOMERACID			[1]','VARCHAR(30)') CustomerACID
		,CASE WHEN C.value('./PROVISIONABSOLUTE	[1]','VARCHAR(30)')= '' THEN NULL ELSE C.value('./PROVISIONABSOLUTE	[1]','DECIMAL(18,2)') END AdditionalProvision
		,C.value('./MOCREASON			[1]','VARCHAR(500)')MOCReason
		,CAST(NULL AS VARCHAR(MAX))ERROR

		INTO #AbsoluteProvisionMOC_v
		FROM @XMLDocument.nodes('/DataSet/Gridrow') AS t(c)

	IF OBJECT_ID('TEMPDB..#AbsoluteProvisionMOCAmount') IS NOT NULL
			DROP TABLE #AbsoluteProvisionMOCAmount


*/
------------------Added By Tarkeshwar Singh 20th July---------------------
	
		
		--Declare @UserLoginId varchar(20)='dm585'
	 --   Declare @filepath varchar(500)='BackDatedUploadFormat'
    	DECLARE @FilePathUpdated VARCHAR(500)
	    SELECT @FilePathUpdated=@UserLoginId+'_'+@filepath
		print @FilePathUpdated

	IF OBJECT_ID('TEMPDB..#AbsoluteProvisionMOC_v') IS NOT NULL
				DROP TABLE #AbsoluteProvisionMOC_v
 
     

		SELECT		
		 ROW_NUMBER()OVER(ORDER BY (SELECT  (1))) RowNum
		,CustomerACID
		,CASE WHEN AbsoluteProvision	= '' THEN NULL ELSE cast(AbsoluteProvision	as DECIMAL(18,2)) END AdditionalProvision
		,MOCReason
		,CAST(NULL AS VARCHAR(MAX))ERROR
		INTO #AbsoluteProvisionMOC_v
		FROM DataUpload.AbsoluteProvisionMOC
		Where Filname=@FilePathUpdated

		--Select * from DataUpload.AbsoluteProvisionMOC
		--Select * from DimUploadTempMaster where MenuId=10995
--------------------------------------------------------------------


	IF OBJECT_ID('TEMPDB..#AbsoluteProvisionMOCAmount') IS NOT NULL
			DROP TABLE #AbsoluteProvisionMOCAmount

		Select 
		  CustomerACID
		 ,Sum(ISNULL(AdditionalProvision,0)) as AdditionalProvision 

		into #AbsoluteProvisionMOCAmount
		From YBL_ACS.DataUpload.AbsoluteBackdatedMOC 
		Where EffectiveToTimeKey = 49999
		AND MOC_Date=@LastMonthDate
		Group by CustomerACID,MOC_Date


	IF OBJECT_ID('TEMPDB..#AbsoluteProvisionMOC') IS NOT NULL
			DROP TABLE #AbsoluteProvisionMOC

		Select 
		  RowNum
		 ,c.AccountEntityID
		 ,c.UCIF_ID
		 ,c.RefCustomerID
		 ,c.SourceSystemCustomerID
		 ,c.BranchCode
		 ,a.CustomerACID
		 ,c.CustomerACID as CustomerACID_Accountcal
		 ,C.TotalProvision as OriginalProvision
		 ,B.AdditionalProvision as PrevAdditionalProvision
		 ,c.TotalProvision + ISNULL(B.AdditionalProvision,0) as TotalProvision
		 ,a.AdditionalProvision
		 ,(c.TotalProvision+ISNULL(B.AdditionalProvision,0)+a.AdditionalProvision) as FinalProvision
		 ,a.MOCReason
		 ,c.NetBalance
		 ,ERROR 
		
		INTO #AbsoluteProvisionMOC
		FROM #AbsoluteProvisionMOC_v a 
		LEFT OUTER JOIN ##AccountCal_HIST C
		ON C.CustomerAcID = A.CustomerAcID 
		LEFT OUTER JOIN #AbsoluteProvisionMOCAmount B
		ON A.CustomerACID=B.CustomerACID
		


		


		
		/****************************************************************************************************************
					
											FOR CHECKING A ACCOUNT  ID 

		****************************************************************************************************************/

		UPDATE A
		SET ERROR = CASE	WHEN (ISNULL(A.CustomerAcID,'')='') AND ISNULL(ERROR,'')=''THEN 'Account ID cannot be blank'
							WHEN (ISNULL(A.CustomerAcID,'')='') AND ISNULL(ERROR,'')<>'' THEN ERROR+','+SPACE(1)+'Account ID cannot be blank'
							WHEN (ISNULL(A.CustomerAcID,'')<>ISNULL(A.CustomerACID_Accountcal,'')) AND ISNULL(ERROR,'')=''THEN 'Invalid Account ID'
							WHEN (ISNULL(A.CustomerAcID,'')<>ISNULL(A.CustomerACID_Accountcal,'')) AND ISNULL(ERROR,'')<>'' THEN ERROR+','+SPACE(1)+'Invalid Account ID'
							ELSE ERROR
					END
		FROM #AbsoluteProvisionMOC A
		--LEFT OUTER JOIN ##AccountCal_HIST C
		--	ON C.CustomerAcID = A.CustomerAcID --C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey AND C.CustomerAcID = A.CustomerAcID
		--WHERE ISNULL(A.CustomerAcID,'')<>''


		/****************************************************************************************************************
					
											FOR CHECKING A STOCKVALUE

		****************************************************************************************************************/

		UPDATE #AbsoluteProvisionMOC
		SET ERROR = 
		--Select ADDITIONALPROVISION,ISNULL(ISNUMERIC(ADDITIONALPROVISION),0),LEN(ADDITIONALPROVISION),
		            CASE	WHEN ISNULL(ISNUMERIC(ADDITIONALPROVISION),0)= '' AND  ISNULL(ERROR,'')=''	THEN 'Absolute Provision amount cannot be left blank' 
							WHEN ISNULL(ISNUMERIC(ADDITIONALPROVISION),0)= '' AND  ISNULL(ERROR,'')<>''	THEN ISNULL(ERROR,'')+','+SPACE(1)+'Absolute Provision amount cannot be left blank' 
							WHEN ISNULL((ADDITIONALPROVISION),0)= 0 AND  ISNULL(ERROR,'')=''	THEN 'Absolute Provision amount cannot be 0' 
							WHEN ISNULL((ADDITIONALPROVISION),0)= 0 AND  ISNULL(ERROR,'')<>''	THEN ISNULL(ERROR,'')+','+SPACE(1)+'Absolute Provision amount cannot be 0' 
							WHEN ISNULL((FinalProvision),0) > ISNULL((NetBalance),0) AND ISNULL(ERROR,'')=''	THEN 'Absolute Provision amount cannot exceed Net Ouststanding balance'
							WHEN ISNULL((FinalProvision),0) > ISNULL((NetBalance),0) AND ISNULL(ERROR,'')<>''	THEN ISNULL(ERROR,'')+','+SPACE(1)+'Absolute Provision amount cannot exceed Net Ouststanding balance'
							WHEN ISNULL((FinalProvision),0) < 0 AND ISNULL(ERROR,'')=''	THEN 'Additional Provision Amount is Resulting in Negative Provision by ('+CAST(FinalProvision as varchar)+')'
							WHEN ISNULL((FinalProvision),0) < 0 AND ISNULL(ERROR,'')<>''	THEN ISNULL(ERROR,'')+','+SPACE(1)+'Additional Provision Amount is Resulting in Negative Provision by ('+CAST(FinalProvision as varchar)+')'
							WHEN LEN(ADDITIONALPROVISION)>19  AND ISNULL(ERROR,'')=''	THEN 'Length of Additional Provision Amount should be less then 20'
							WHEN LEN(ADDITIONALPROVISION)>19  AND ISNULL(ERROR,'')<>''	THEN  ISNULL(ERROR,'')+','+SPACE(1)+'Length of Additional Provision Amount should be less then 20'
							ELSE ERROR
					END
					From #AbsoluteProvisionMOC
		--WHERE ISNULL(ADDITIONALPROVISION,0)<>0  

		/****************************************************************************************************************
					
											FOR CHECKING A Moc Reason

		****************************************************************************************************************/  ---Added by shubham on 2024-04-15 for Adding MOCREASON Column

		UPDATE #AbsoluteProvisionMOC
		SET ERROR = CASE	WHEN LEN(ISNULL(MOCReason,''))>500 AND ISNULL(ERROR,'')=''	THEN 'MOC Reason Length should not be  greater then 500 Chararter'
							WHEN LEN(ISNULL(MOCReason,''))>500 AND ISNULL(ERROR,'')<>''	THEN ISNULL(ERROR,'')+','+SPACE(1)+ 'MOC Reason Length should not be  greater then 500 Chararter'
							WHEN ISNULL(MOCReason,'')=''AND ISNULL(ERROR,'')='' THEN 'MOC Reason is mandatory'
							WHEN ISNULL(MOCReason,'')=''AND ISNULL(ERROR,'')<>'' THEN ERROR+','+SPACE(1)+ 'MOC Reason is mandatory'
							ELSE ERROR
					END
		--WHERE LEN(MOCReason)>500

		/****************************************************************************************************************
					
											FOR AbsoluteProvisionMOC SELECT OUTPUT

		****************************************************************************************************************/
		IF EXISTS(SELECT 1 FROM #AbsoluteProvisionMOC WHERE ISNULL(ERROR,'')<>'')
		BEGIN
		SELECT   RowNum		
		        ,A.AccountEntityID --Columns added to Remove iterations by shubham on 2024-04-27
		        ,A.UCIF_ID --Columns added to Remove iterations by shubham on 2024-04-27
		        ,A.RefCustomerID as CustomerID--Columns added to Remove iterations by shubham on 2024-04-27
		        ,A.SourceSystemCustomerID --Columns added to Remove iterations by shubham on 2024-04-27
		        ,A.BranchCode --Columns added to Remove iterations by shubham on 2024-04-27
				,A.OriginalProvision --Columns added to Remove iterations by shubham on 2024-04-27
				,A.NetBalance --Columns added to Remove iterations by shubham on 2024-04-27
		        ,A.CustomerACID	
				,a.TotalProvision as ExistingProvision
				--,a.PrevAdditionalProvision
				--,a.ExistingProvision as PrevExistingProvision
				,AdditionalProvision	
				,FinalProvision
				,MOCReason as MOCREASON
				,ERROR
				,'ErrorData' TableName
		FROM #AbsoluteProvisionMOC A
		WHERE ISNULL(ERROR,'')<>''
		Order by 1 --Added by shubham on 2024-03-20 for error to be in ordered form
		END
		ELSE
		BEGIN
        SELECT   RowNum	
		        ,A.AccountEntityID --Columns added to Remove iterations by shubham on 2024-04-27
		        ,A.UCIF_ID --Columns added to Remove iterations by shubham on 2024-04-27
		        ,A.RefCustomerID as CustomerID--Columns added to Remove iterations by shubham on 2024-04-27
		        ,A.SourceSystemCustomerID --Columns added to Remove iterations by shubham on 2024-04-27
		        ,A.BranchCode --Columns added to Remove iterations by shubham on 2024-04-27
				,A.OriginalProvision --Columns added to Remove iterations by shubham on 2024-04-27
				,A.NetBalance --Columns added to Remove iterations by shubham on 2024-04-27
				,A.CustomerACID	
				,a.TotalProvision as ExistingProvision
				--,a.PrevAdditionalProvision
				--,a.ExistingProvision as PrevExistingProvision
				,AdditionalProvision	
				,FinalProvision
				,MOCReason as MOCREASON
				,'AbsoluteProvisionMOC' TableName
		FROM #AbsoluteProvisionMOC A
		Order by 1 ----Added by shubham on 2024-03-20 for error to be in ordered form

---------------------Added by Tarkeshwar Singh 20th July--------------------------

Delete from  AbsoluteProvisionMOC_Final where FILENAME=@FilePathUpdated
--Select  * from AbsoluteProvisionMOC_Final
--Create NonClustered Index AbsoluteProvisionMOC_Final_INDX on AbsoluteProvisionMOC_Final(AccountEntityID)

Insert into AbsoluteProvisionMOC_Final
(
AccountEntityID			
,UCIF_ID			    
,CustomerID			    
,SourceSystemCustomerID	
,BranchCode			    
,OriginalProvision	    
,NetBalance	            
,CustomerACID			
,ExistingProvision    	
,AdditionalProvision 	
,FinalProvision	        
,MOCREASON	            
,AbsProvMOCEntityId
,FILENAME
)
select
AccountEntityID			
,UCIF_ID			    
,RefCustomerID CustomerID			    
,SourceSystemCustomerID	
,BranchCode			    
,OriginalProvision	    
,NetBalance	            
,CustomerACID			
,TotalProvision ExistingProvision    	
,AdditionalProvision 	
,FinalProvision	        
,MOCREASON	            
,@AbsProvMOCEntityId+ROW_NUMBER() over (order by RefCustomerID) AbsProvMOCEntityId
,@FilePathUpdated Filname
FROM #AbsoluteProvisionMOc
----------------------------------------------------------------------------
 
		END
		DROP TABLE #AbsoluteProvisionMOC

		--Truncate table  DataUpload.AbsoluteProvisionMOC 
		  Delete from DataUpload.AbsoluteProvisionMOC where Filname=@FilePathUpdated
--Select row_number() over (partition by CustomerID order by CustomerID) from AbsoluteProvisionMOC_Final

END
END

--Select * from AbsoluteProvisionMOC_Final
GO