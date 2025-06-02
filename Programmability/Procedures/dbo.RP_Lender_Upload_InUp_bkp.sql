SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



create PROC [dbo].[RP_Lender_Upload_InUp_bkp]

@XMLDocument          XML=''    
,@EffectiveFromTimeKey INT=0
,@EffectiveToTimeKey   INT=0
,@OperationFlag		   INT=0
,@AuthMode			   CHAR(1)='N'
,@CrModApBy			   VARCHAR(50)=''
,@TimeKey			   INT=0
,@Result			   INT=0 output
,@D2KTimeStamp		   INT=0 output
,@Remark			   VARCHAR(200)=''
,@MenuId				INT = 6100
,@ErrorMsg				VARCHAR(MAX)='' output
As
BEGIN
      DECLARE
		@CustomerEntityId	INT
	    ,@CreatedBy				VARCHAR(50)
	   ,@DateCreated			DATETIME
	   ,@ModifiedBy				VARCHAR(50)
	   ,@DateModified			DATETIME
	   ,@ApprovedBy				VARCHAR(50)
	   ,@DateApproved			DATETIME
	   ,@AuthorisationStatus	VARCHAR(5)
	   ,@ErrorHandle			SMALLINT =0
	   ,@ExEntityKey			INT	    =0
	   ,@Data_Sequence			INT = 0


IF OBJECT_ID('TEMPDB..#LENDERDATAUPLOAD') IS NOT NULL
        DROP TABLE #LENDERDATAUPLOAD

SELECT 
 C.value('./UCIC_ID[1]','VARCHAR(30)') UCIC_ID
,C.value('./CustomerID [1]','VARCHAR(30)') CustomerID 
,C.value('./PAN_No [1]','VARCHAR(20)') Pan_No     
,C.value('./CustomerName [1]','VARCHAR(255)') CustomerName
,C.value('./LenderName [1]','VARCHAR(100)') LenderName
,C.value('./InDefaultDate [1]','VARCHAR(20)') InDefaultDate
,C.value('./OutOfDefaultDate [1]','VARCHAR(20)') OutOfDefaultDate


INTO #LENDERDATAUPLOAD
FROM @XMLDocument.nodes('/DataSet/Gridrow') AS t(c)

--select * from #LENDERDATAUPLOAD
--return

IF @OperationFlag=1
BEGIN


--------------------------Added on 11-01-2021  Mod Table Authorize Data to be Expired If Again Uploading after Authorized Data

PRINT 'SUNIL'
			IF EXISTS(
			Select 1 From  RP_Lender_Upload_Mod  D
						INNER JOIN #LENDERDATAUPLOAD GD 
						ON (EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey) 
							AND D.CustomerID = GD.CustomerID
						WHERE D.AuthorisationStatus in('A') )

	BEGIN
		PRINT 'EXISTS'

		UPDATE D SET D.EffectiveToTimeKey =@EffectiveFromTimeKey-1
		From  RP_Lender_Upload_Mod  D
						INNER JOIN #LENDERDATAUPLOAD GD 
						ON (EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey) 
							AND D.CustomerID = GD.CustomerID
						WHERE D.AuthorisationStatus in('A')
	END
--------------------------------------------------------------------


	PRINT '1'
	IF EXISTS(
			Select 1 From  RP_Lender_Upload_Mod  D
						INNER JOIN #LENDERDATAUPLOAD GD 
						ON (EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey) 
							AND D.CustomerID = GD.CustomerID
						WHERE D.AuthorisationStatus in('MP','NP','DP','RM') )

	BEGIN
		PRINT 'EXISTS'
		Set @Result=-4
		SELECT DISTINCT @ErrorMsg=
								STUFF((SELECT distinct ', ' + CAST(CustomerID as varchar(max))
								 FROM #LENDERDATAUPLOAD t2
								 FOR XML PATH('')),1,1,'') 
							From  RP_Lender_Upload_Mod  D
							INNER JOIN #LENDERDATAUPLOAD GD 
								ON (EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey) 
								AND D.CustomerID = GD.CustomerID
							WHERE D.AuthorisationStatus in('MP','NP','DP','RM') 

		SET @ErrorMsg='Authorization Pending for Customer id '+CAST(@ErrorMsg AS VARCHAR(MAX))+' Please Authorize first'
		Return @Result
	END
	--ELSE 
	BEGIN	
		--SET @CustomerEntityId = 
		 SELECT @CustomerEntityId= MAX(CustomerEntityId)  FROM  
										(SELECT MAX(Entitykey) CustomerEntityId FROM RP_Lender_Details
										 UNION 
										 SELECT MAX(Entitykey) CustomerEntityId FROM  RP_Lender_Upload_Mod
										)A
		SET @CustomerEntityId = ISNULL(@CustomerEntityId,0)
		--SELECT @CustomerEntityId
	END
END

BEGIN TRY


BEGIN TRAN

IF @OperationFlag=1 AND @AuthMode='Y'
	BEGIN
	         PRINT 2
			 SET @CreatedBy =@CrModApBy 
	         SET @DateCreated = GETDATE()
	         SET @AuthorisationStatus='NP'
	   
	   GOTO BusinessMatrix_Insert
	        BusinessMatrix_Insert_Add:

				--SET @Result=1
	   
	END	
	
 --ELSE
  IF (@OperationFlag=3 OR @OperationFlag=2 ) AND @AuthMode ='Y'
		BEGIN
				Print 2
				SET @CreatedBy	  = @CrModApBy 
				SET @DateCreated  = GETDATE()
				SET @Modifiedby   = @CrModApBy 
				SET @DateModified = GETDATE() 
				
				PRINT 22
				IF @OperationFlag=3
							
					BEGIN
						SET @AuthorisationStatus='DP'
					END
					ELSE			
					BEGIN
						SET @AuthorisationStatus='MP'
					END

				---FIND CREADED BY FROM MAIN TABLE 
				SELECT  @CreatedBy		= CreatedBy
						,@DateCreated	= DateCreated 
					FROM RP_Lender_Details D
					INNER JOIN  #LENDERDATAUPLOAD GD	
					ON  D.CustomerID = GD.CustomerID
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
		
				PRINT @CreatedBy
				PRINT @DateCreated
				IF ISNULL(@CreatedBy,'')=''
					BEGIN
						PRINT 44
						SELECT  @CreatedBy			= CreatedBy
									,@DateCreated	= DateCreated
							FROM  RP_Lender_Upload_Mod D
							INNER JOIN  #LENDERDATAUPLOAD GD	
							ON  D.CustomerID			= GD.CustomerID
							WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
							AND    D.AuthorisationStatus IN('NP','MP','DP','RM')
	
																
					END
				ELSE ---IF DATA IS AVAILABLE IN MAIN TABLE
					BEGIN
						PRINT 'OperationFlag'
						----UPDATE FLAG IN MAIN TABLES AS MP
						UPDATE  D
						SET D.AuthorisationStatus=@AuthorisationStatus
						FROM RP_Lender_Details D
						INNER JOIN  #LENDERDATAUPLOAD GD 
						ON  D.CustomerID			= GD.CustomerID
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
					END
			IF @OperationFlag=2
				BEGIN	
					PRINT 'FM'	
					UPDATE  D
						SET D.AuthorisationStatus='FM'
						,D.ModifiedBy=@Modifiedby
						,D.DateModified=@DateModified
					 
					FROM  RP_Lender_Upload_Mod D
						INNER JOIN  #LENDERDATAUPLOAD GD 
							ON  D.CustomerID			= GD.CustomerID
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						and D.AuthorisationStatus IN('NP','MP','DP','RM')
				END
				GOTO BusinessMatrix_Insert
				BusinessMatrix_Insert_Edit_Delete:
		 END 
ELSE IF @OperationFlag =3 AND @AuthMode ='N'
		BEGIN
				--SELECT * FROM ##DimBSCodeStructure
				-- DELETE WITHOUT MAKER CHECKER
						PRINT 'DELETE'					
						SET @Modifiedby   = @CrModApBy 
						SET @DateModified = GETDATE() 
						UPDATE D SET
									ModifiedBy =@Modifiedby 
									,DateModified =@DateModified 
									,EffectiveToTimeKey =@EffectiveFromTimeKey-1
								FROM RP_Lender_Details D
						INNER JOIN  #LENDERDATAUPLOAD GD	
							ON D.CustomerID			= GD.CustomerID
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)

						PRINT CAST(@@ROWCOUNT as VARCHAR(2))+SPACE(1)+'ROW DELETED'

				SET @RESULT=@CustomerEntityId

		END

ELSE IF @OperationFlag=17 AND @AuthMode ='Y' 
		BEGIN
				Print 'REJECT'
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE D
					SET AuthorisationStatus='R'
					,ApprovedBy	 =@ApprovedBy
					,DateApproved=@DateApproved
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
				FROM  RP_Lender_Upload_Mod D
						INNER JOIN  #LENDERDATAUPLOAD GD	
							ON D.CustomerID			= GD.CustomerID
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						and D.AuthorisationStatus IN('NP','MP','DP','RM')


			IF EXISTS(Select 1 From RP_Lender_Details D
						INNER JOIN #LENDERDATAUPLOAD GD 
						ON (EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey) 
							AND  D.CustomerID			= GD.CustomerID
							)
					BEGIN

						UPDATE D
							SET AuthorisationStatus='A'
							FROM RP_Lender_Details D
						INNER JOIN  #LENDERDATAUPLOAD GD	
						ON D.CustomerID			= GD.CustomerID
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
								AND D.AuthorisationStatus IN('MP','DP','RM') 	


					END


				
		END
		
ELSE IF @OperationFlag=18 AND @AuthMode='Y'
		   BEGIN
		        PRINT 'remarks'
               Set @ApprovedBy=@CrModApBy
			   Set @DateApproved=Getdate()
			   --SET @FactTargetEntityId=(select FactTargetEntityId from #FactTarget)
			   
			   --select @GroupAlt_Key
					UPDATE D
					SET AuthorisationStatus='RM'
					,ApprovedBy	 =@ApprovedBy
					,DateApproved=@DateApproved
				FROM  RP_Lender_Upload_Mod D
						INNER JOIN  #LENDERDATAUPLOAD GD	
						ON   D.CustomerID			= GD.CustomerID
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						and D.AuthorisationStatus IN('NP','MP','DP')
		   END


 ELSE IF @OperationFlag=16 OR @AuthMode='N'
	BEGIN
		          print 'a1'
				
				 IF @AuthMode='N'
				     BEGIN
					      IF @OperationFlag=1
					         BEGIN
					         	SET @CreatedBy =@CrModApBy
					         	SET @DateCreated =GETDATE()
					         END
						ELSE
					       BEGIN
								
						         SET @ModifiedBy  =@CrModApBy
						         SET @DateModified =GETDATE()

						        SELECT	@CreatedBy=CreatedBy,@DateCreated=DATECreated
					             	FROM RP_Lender_Details  D
									INNER JOIN  #LENDERDATAUPLOAD GD	
									ON D.CustomerID			= GD.CustomerID
									WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 

					

					             SET @ApprovedBy = @CrModApBy			
					             SET @DateApproved=GETDATE()
					      END

					END	
		IF @AuthMode='Y'
				BEGIN
				    Print 'B'
					DECLARE @DelStatus CHAR(2)
					DECLARE @CurrRecordFromTimeKey smallint=0

					
					--SELECT  * FROM ##DimBSCodeStructure
					Print 'C'
					SELECT @ExEntityKey= MAX(Entitykey) FROM  RP_Lender_Upload_Mod A
					 INNER JOIN #LENDERDATAUPLOAD C
						ON (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
						 AND A.CustomerID			= C.CustomerID
						WHERE  a.AuthorisationStatus IN('NP','MP','DP','RM')	


					PRINT @@ROWCOUNT

					SELECT	@DelStatus=a.AuthorisationStatus
							,@CreatedBy=CreatedBy
							,@DateCreated=DATECreated
							,@ModifiedBy=ModifiedBy
							, @DateModified=DateModified
					 FROM  RP_Lender_Upload_Mod A
					  INNER JOIN #LENDERDATAUPLOAD C
						ON (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey) 
						AND A.CustomerID			= C.CustomerID
						WHERE   Entitykey=@ExEntityKey
					
					SET @ApprovedBy = @CrModApBy			
					SET @DateApproved=GETDATE()

					 
				
					
					DECLARE @CurEntityKey INT=0

					SELECT @ExEntityKey= MIN(Entitykey) FROM  RP_Lender_Upload_Mod A 
					 INNER JOIN #LENDERDATAUPLOAD C
						ON (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey) 
						AND A.CustomerID			= C.CustomerID
						WHERE  a.AuthorisationStatus IN('NP','MP','DP','RM')	
				
					SELECT	@CurrRecordFromTimeKey=A.EffectiveFromTimeKey 
						 FROM  RP_Lender_Upload_Mod A
						  INNER JOIN #LENDERDATAUPLOAD C
						ON (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey) 
							AND  A.CustomerID			= C.CustomerID
							AND Entitykey=@ExEntityKey
			
					UPDATE A
					
						SET  EffectiveToTimeKey =@CurrRecordFromTimeKey-1
						FROM  RP_Lender_Upload_Mod A
						INNER JOIN #LENDERDATAUPLOAD C
						ON (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey) 
						AND A.CustomerID			= C.CustomerID
						 Where  a.AuthorisationStatus='A'	


					PRINT 'A'
							
								  IF @DelStatus='DP' 
					                 BEGIN	
					                      Print 'Delete Authorise'
						                 UPDATE G 
						                 SET G.AuthorisationStatus ='A'
						                 	,ApprovedBy=@ApprovedBy
						                 	,DateApproved=@DateApproved
						                 	,EffectiveToTimeKey =@EffectiveFromTimeKey -1
										FROM  RP_Lender_Upload_Mod G
										INNER JOIN #LENDERDATAUPLOAD GD 
										ON  G.CustomerID			= GD.CustomerID
										--AND G.CounterPart_BranchCode	= GD.CounterPart_BranchCode
						                 WHERE G.AuthorisationStatus in('NP','MP','DP','RM')

										PRINT 'BE'
						                  IF EXISTS(SELECT 1 FROM RP_Lender_Details G
										INNER JOIN #LENDERDATAUPLOAD GD 
										ON  G.CustomerID			= GD.CustomerID
										   WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) )
						                  BEGIN

												  PRINT 'EXPIRE'
								                   UPDATE G 
									               SET AuthorisationStatus ='A'
									          	    ,ModifiedBy=@ModifiedBy
									          	    ,DateModified=@DateModified
									          	    ,ApprovedBy=@ApprovedBy
									          	    ,DateApproved=@DateApproved
									          	    ,EffectiveToTimeKey =@EffectiveFromTimeKey-1
													FROM RP_Lender_Details G
													INNER JOIN #LENDERDATAUPLOAD GD 
													ON G.CustomerID			= GD.CustomerID
									               WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
											       	
										 END
									END
									ELSE 

									BEGIN
										 UPDATE G 
										 SET AuthorisationStatus ='A'
										 ,ApprovedBy=@ApprovedBy
										 ,DateApproved=@DateApproved
										 FROM  RP_Lender_Upload_Mod G
										 INNER JOIN #LENDERDATAUPLOAD GD 
											ON  G.CustomerID			= GD.CustomerID
										  WHERE G.AuthorisationStatus in('NP','MP','RM')
									END
					END

						IF ISNULL(@DelStatus,'A') <>'DP' OR @AuthMode ='N'
									BEGIN
											
											PRINT @AuthorisationStatus +'AuthorisationStatus'	
                                             PRINT @AUTHMODE +'Authmode'


											 SET  @AuthorisationStatus ='A' 
										
                                                   DELETE G
                                                        FROM RP_Lender_Details G
                                                       INNER JOIN #LENDERDATAUPLOAD GD ON (G.EffectiveFromTimeKey<=@TimeKey AND G.EffectiveToTimeKey>=@TimeKey )
													    AND G.CustomerID			= GD.CustomerID
                                                       WHERE G.EffectiveFromTimeKey=@EffectiveFromTimeKey  --and ISNULL(GD.AuthorisationStatus,'A')<>'DP'
													


													print 'ROW deleted'+CAST(@@ROWCOUNT AS VARCHAR(10)) +'Deleted'
													
													
                                                    UPDATE G
                                                       SET  
													   G.EffectiveTOTimeKey=@EffectiveFromTimeKey-1
													   ,G.AuthorisationStatus ='A'  --ADDED ON 12 FEB 2018
                                                       FROM RP_Lender_Details G
                                                       INNER JOIN #LENDERDATAUPLOAD GD ON (G.EffectiveFromTimeKey<=@TimeKey AND G.EffectiveToTimeKey>=@TimeKey )
														AND G.CustomerID			= GD.CustomerID
                                                       WHERE G.EffectiveFromTimeKey<@EffectiveFromTimeKey  --and ISNULL(GD.AuthorisationStatus,'A')<>'DP'
													
													print 'ROW deleted'+CAST(@@ROWCOUNT AS VARCHAR(10))

												
												IF @AuthMode='N' 
												BEGIN
													SET @AuthorisationStatus='A'
												END

												-- SELECT @CustomerEntityId= MAX(CustomerEntityId)  FROM  
												--	(SELECT MAX(Entitykey) CustomerEntityId FROM RP_Lender_Details
												--	 UNION 
												--	 SELECT MAX(Entitykey) CustomerEntityId FROM  RP_Lender_Upload_Mod
												--	)A
												--SET @CustomerEntityId = ISNULL(@CustomerEntityId,0)


--------------------------Added on 11-01-2021  Main Table Authorize Data to be Expired If Again Uploading after Authorized Data

PRINT 'SUNIL1'
			IF EXISTS(
			Select 1 From  RP_Lender_Details  D
						INNER JOIN #LENDERDATAUPLOAD GD 
						ON (EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey) 
							AND D.CustomerID = GD.CustomerID
						WHERE D.AuthorisationStatus in('A') )

	BEGIN
		PRINT 'EXISTS'

		UPDATE D SET D.EffectiveToTimeKey =@EffectiveFromTimeKey-1
		From  RP_Lender_Details  D
						INNER JOIN #LENDERDATAUPLOAD GD 
						ON (EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey) 
							AND D.CustomerID = GD.CustomerID
						WHERE D.AuthorisationStatus in('A')
	END
--------------------------------------------------------------------
		

												INSERT INTO RP_Lender_Details
														(
														CustomerID
														,ReportingLenderAlt_Key
														,InDefaultDate
														,OutOfDefaultDate
														,DefaultStatus
														,AuthorisationStatus
														,EffectiveFromTimeKey
														,EffectiveToTimeKey
														,CreatedBy
														,DateCreated
														,ModifiedBy
														,DateModified
														,ApprovedBy
														,DateApproved
														
														)
													SELECT
														Distinct
													    --UCIC_ID
														CustomerID
														--,PAN_No
														--,CustomerName
														,D.BankRPAlt_Key as LenderAlt_Key
														,(Case when convert(DATE,InDefaultDate)='' then NULL else Convert(VARCHAR(20),InDefaultDate,103) End) InDefaultDate
														,(Case when convert(DATE,OutOfDefaultDate)='' then NULL else Convert(VARCHAR(20),OutOfDefaultDate,103) End) OutOfDefaultDate
														,(Case When OutOfDefaultDate is not null then 'Out Default' else 'In Default' End) DefaultStatus
														,CASE WHEN @AuthMode ='Y' THEN @AuthorisationStatus ELSE NULL END
														,@EffectiveFromTimeKey
														,@EffectiveToTimeKey
														,@CreatedBy
														,@DateCreated
														,@ModifiedBy
														,@DateModified
														,CASE WHEN @AuthMode ='Y' THEN @ApprovedBy ELSE NULL END
														,CASE WHEN @AuthMode ='Y' THEN @DateApproved ELSE NULL END
														
														FROM #LENDERDATAUPLOAD S
														INNER JOIN DimBankRP D ON S.LenderName=D.BankName
														AND D.EffectiveFromTimeKey<=@TimeKey And D.EffectiveToTimeKey>=@TimeKey


----------------------------------------------------------------- From Lender Details Update Calculation for Portfolio Columns Added On 08-01-2021 -------


IF OBJECT_ID('TempDB..#PortfolioCustomer') Is Not Null
Drop Table #PortfolioCustomer

Select A.* Into #PortfolioCustomer from RP_PortFolio_Details A
Inner Join DimExposureBucket DE ON DE.ExposureBucketAlt_key=A.ExposureBucketAlt_Key
And DE.EffectiveFromTimeKey<=@TimeKey And DE.EffectiveToTimeKey>=@TimeKey
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
And DE.BucketName Not In ('1500 Crs To 2000 Crs','Greater Than 2000 Crs')

IF OBJECT_ID('TempDB..#LenderCustomer') Is Not Null
Drop Table #LenderCustomer

Select CustomerID,Min(InDefaultDate)DefaultDate into #LenderCustomer from RP_Lender_Details 
Where EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey
And CustomerID in (Select CustomerID from #PortfolioCustomer)
Group By CustomerID

--Select *

Update P set P.BorrowerDefaultDate=L.DefaultDate,
			P.ReferenceDate=L.DefaultDate,
			P.ReviewExpiryDate=DATEADD(D,30,L.DefaultDate),
			P.RP_ExpiryDate=DATEADD(D,210,L.DefaultDate),
			P.Revised_RP_Expiry_Date=DATEADD(D,180,P.RP_OutOfDateAllBanksDeadline),
			P.RiskReviewExpiryDate=DATEADD(D,75,L.DefaultDate)
 from #PortfolioCustomer P
Inner Join #LenderCustomer L ON P.CustomerID=L.CustomerID

---------UpDate in Main Table----

--Select *

Update A Set  A.BorrowerDefaultDate=P.BorrowerDefaultDate,
			A.ReferenceDate=P.ReferenceDate,
			A.ReviewExpiryDate=P.ReviewExpiryDate,
			A.RP_ExpiryDate=P.RP_ExpiryDate,
			A.Revised_RP_Expiry_Date=P.Revised_RP_Expiry_Date,
			A.RiskReviewExpiryDate=P.RiskReviewExpiryDate
 from RP_PortFolio_Details A
Inner Join #PortfolioCustomer P ON A.CustomerID=P.CustomerID
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey

----------------------------------------Borrower Default for exposure busket >1500crs

IF OBJECT_ID('TempDB..#LenderCustomer1') Is Not Null
Drop Table #LenderCustomer1

Select CustomerID,Min(InDefaultDate)DefaultDate into #LenderCustomer1 from RP_Lender_Details 
Where EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey
And CustomerID Not in (Select CustomerID from #PortfolioCustomer)
Group By CustomerID


Update A Set  A.BorrowerDefaultDate=P.DefaultDate
 from RP_PortFolio_Details A
Inner Join #LenderCustomer1 P ON A.CustomerID=P.CustomerID
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey


-----------Added on 22nd Jan 2021----------------

UPDATE RP_Portfolio_Details SET
CustomerName=B.CustomerName
from RP_Portfolio_Details A
INNER JOIN pro.CustomerCal B
ON A.customerid=B.RefCustomerID
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey 


------------------------------------------------------------------------------------
									
										END


	IF @AUTHMODE='N'
			BEGIN
					SET @AuthorisationStatus='A'
					GOTO BusinessMatrix_Insert
					HistoryRecordInUp:
			END						


										

	
END


	IF (@OperationFlag IN(1,2,3,16,17,18 )AND @AuthMode ='Y')
			BEGIN
		PRINT 5
				IF @OperationFlag=2 
					BEGIN 

						SET @CreatedBy=@ModifiedBy
					--end

				END
					--IF @OperationFlag IN(16,17) 
					--	BEGIN 
					--		SET @DateCreated= GETDATE()
					
					--			EXEC LogDetailsInsertUpdate_Attendence -- MAINTAIN LOG TABLE
					--				'' ,
					--				@MenuID,
					--				@CustomerEntityId,-- ReferenceID ,
					--				@CreatedBy,
					--				@ApprovedBy,-- @ApproveBy 
					--				@DateCreated,
					--				@Remark,
					--				@MenuID, -- for FXT060 screen
					--				@OperationFlag,
					--				@AuthMode
					--	END
					--ELSE
					--	BEGIN
					
					--	--Print @Sc
					--		EXEC LogDetailsInsertUpdate_Attendence -- MAINTAIN LOG TABLE
					--			'' ,
					--			@MenuID,
					--			@CustomerEntityId ,-- ReferenceID ,
					--			@CreatedBy,
					--			NULL,-- @ApproveBy 
					--			@DateCreated,
					--			@Remark,
					--			@MenuID, -- for FXT060 screen
					--			@OperationFlag,
					--			@AuthMode
					--	END
			END	


SET @ErrorHandle=1


BusinessMatrix_Insert:
PRINT 'A'
--SELECT  @ErrorHandle
IF @ErrorHandle=0
								
  	BEGIN
								Print 'insert into  RP_Lender_Upload_Mod'

									PRINT '@ErrorHandle'
									INSERT INTO  RP_Lender_Upload_Mod
											(
											CustomerEntityID
											,UCIC_ID
											,CustomerID
											,PAN_No
											,CustomerName
											,LenderName
											,InDefaultDate
											,OutOfDefaultDate
											,EffectiveFromTimeKey
											,EffectiveToTimeKey
											,AuthorisationStatus
											,CreatedBy
											,DateCreated
											,ModifiedBy
											,DateModified
											,ApprovedBy
											,DateApproved
											)
										SELECT
											@CustomerEntityId+ROW_NUMBER()OVER(ORDER BY (SELECT 1))
											,UCIC_ID
											,CustomerID
											,PAN_No
											,CustomerName
											,LenderName
											,(Case when convert(DATE,InDefaultDate)='' then NULL else Convert(VARCHAR(20),InDefaultDate,103) End) InDefaultDate
											,(Case when convert(DATE,OutOfDefaultDate)='' then NULL else Convert(VARCHAR(20),OutOfDefaultDate,103) End) OutOfDefaultDate
											,@EffectiveFromTimeKey
											,@EffectiveToTimeKey
											,CASE WHEN @AuthMode ='Y' THEN @AuthorisationStatus ELSE NULL END
											,@CreatedBy
											,@DateCreated
											,@ModifiedBy
											,@DateModified
											,CASE WHEN @AuthMode ='Y' THEN @ApprovedBy ELSE NULL END
											,CASE WHEN @AuthMode ='Y' THEN @DateApproved ELSE NULL END
											
											FROM #LENDERDATAUPLOAD S
											--WHERE Amount<>0

								PRINT CAST(@@ROWCOUNT AS VARCHAR)+'INSERTED'
								

				IF @OperationFlag =1 AND @AUTHMODE='Y'
					BEGIN
						PRINT 3
						GOTO BusinessMatrix_Insert_Add
					END
				ELSE
				 IF (@OperationFlag =2 OR @OperationFlag =3) AND @AUTHMODE='Y'

					BEGIN
						GOTO BusinessMatrix_Insert_Edit_Delete
					END

	END			
	
 COMMIT TRANSACTION
 IF @OperationFlag <>3
 BEGIN
	
		--SELECT @D2Ktimestamp=CAST(D2Ktimestamp AS INT) FROM  RP_Lender_Upload_Mod D
		--					--INNER JOIN #BusinessMatrix T	ON	D.BusinessMatrixAlt_key = T.BusinessMatrixAlt_key
		--					WHERE (EffectiveFromTimeKey<=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) 



		--UPDATE A SET CustomerName=B.CustomerName 		FROM  RP_Lender_Details A 		INNER JOIN PRO.customercal B ON A.CustomerID=B.RefCustomerID		where A.CustomerName IS NULL
		--UPDATE A SET CustomerName=B.CustomerName		FROM   RP_Lender_Upload_Mod A 		INNER JOIN PRO.customercal B ON A.CustomerID=B.RefCustomerID	where A.CustomerName IS NULL					

									

	
			SET @RESULT=1
			RETURN  @RESULT
			--RETURN @D2Ktimestamp
END

ELSE
		BEGIN
				SET @Result=0
				RETURN  @RESULT
		END
		
 END TRY
BEGIN CATCH


	INSERT INTO dbo.Error_Log
				SELECT ERROR_LINE() as ErrorLine,ERROR_MESSAGE()ErrorMessage,ERROR_NUMBER()ErrorNumber
				,ERROR_PROCEDURE()ErrorProcedure,ERROR_SEVERITY()ErrorSeverity,ERROR_STATE()ErrorState
				,GETDATE()

	SELECT ERROR_MESSAGE() ERRORDESC,ERROR_LINE() as ErrorLine
	ROLLBACK TRAN
	

		
	SET @RESULT=-1
	
	RETURN @RESULT

		

END  CATCH

	


END						            




GO