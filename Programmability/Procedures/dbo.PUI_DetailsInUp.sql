SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROC [dbo].[PUI_DetailsInUp] 
						
						 @CustomerID				VARCHAR (20)=''
						,@CustomerName				VARCHAR (100)=''
						,@AccountID				VARCHAR (30)=''
						,@OriginalEnvisagCompletionDt		VARCHAR(20)=NULL
						,@RevisedCompletionDt		VARCHAR(20)=NULL
						,@ActualCompletionDt		VARCHAR(20)=NULL
						,@ProjectCatgAlt_Key		SMALLINT=0
						,@ProjectDelReason_AltKey		SMALLINT=0
						,@StandardRestruct_AltKey		SMALLINT=0
										
						---------D2k System Common Columns		--
						,@Remark					VARCHAR(500)	= ''
						,@MenuID                    Int=0
						,@OperationFlag				TINYINT			= 0
						,@AuthMode					CHAR(1)			= 'N'
						,@EffectiveFromTimeKey		INT		= 0
						,@EffectiveToTimeKey		INT		= 0
						,@TimeKey					INT		= 0
						,@CrModApBy					VARCHAR(20)		=''
						,@ScreenEntityId			INT				=null
						,@Result					INT				=0 OUTPUT
						
						
AS
BEGIN
	SET NOCOUNT ON;
		PRINT 1
	
		SET DATEFORMAT DMY
	
		DECLARE 
						 @AuthorisationStatus		VARCHAR(2)			= NULL 
						,@CreatedBy					VARCHAR(20)		= NULL
						,@DateCreated				SMALLDATETIME	= NULL
						,@ModifiedBy				VARCHAR(20)		= NULL
						,@DateModified				SMALLDATETIME	= NULL
						,@ApprovedBy				VARCHAR(20)		= NULL
						,@DateApproved				SMALLDATETIME	= NULL
						,@ErrorHandle				int				= 0
						,@ExEntityKey				int				= 0  
						
------------Added for Rejection Screen  29/06/2020   ----------

		DECLARE			@Uniq_EntryID			int	= 0
						,@RejectedBY			Varchar(50)	= NULL
						,@RemarkBy				Varchar(50)	= NULL
						,@RejectRemark			Varchar(200) = NULL
						,@ScreenName			Varchar(200) = NULL

				SET @ScreenName = 'PUI'

	-------------------------------------------------------------

 SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C') 

 SET @EffectiveFromTimeKey  = @TimeKey

	SET @EffectiveToTimeKey = 49999

	DECLARE @ArrangementName as Varchar(100)

	----------------Added for Alt_keys 24/12/2020

	--SET @BankingArrangementAlt_Key =(SELECT  BankingArrangementAlt_Key FROM AdvAcProjectDetail WHERE CustomerID = @CustomerID AND EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey)

	--SET @LeadBankAlt_Key =(SELECT  LeadBankAlt_Key FROM AdvAcProjectDetail WHERE CustomerID = @CustomerID AND EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey)

	--SET @ExposureBucketAlt_Key =(SELECT  ExposureBucketAlt_Key FROM AdvAcProjectDetail WHERE CustomerID = @CustomerID AND EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey)

	--SET @RPNatureAlt_Key =(SELECT  RPNatureAlt_Key FROM AdvAcProjectDetail WHERE CustomerID = @CustomerID AND EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey)

	--SET @AssetClassAlt_Key =(SELECT  AssetClassAlt_Key FROM AdvAcProjectDetail WHERE CustomerID = @CustomerID AND EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey)
											
	PRINT 'A'
	

			DECLARE @AppAvail CHAR
					SET @AppAvail = (Select ParameterValue FROM SysSolutionParameter WHERE Parameter_Key=6)
				IF(@AppAvail='N')                         
					BEGIN
						SET @Result=-11
						RETURN @Result
					END

				

	IF @OperationFlag=1  --- add
	BEGIN
	PRINT 1
			IF not EXISTS(				                
					SELECT  1 FROM pro.CustomerCal WHERE RefCustomerID = @CustomerID AND  EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey
				
				)	
				BEGIN
				   PRINT 2
					SET @Result=-5
					RETURN @Result --Customer Id Not Exist

				END
				IF not EXISTS(				                
					SELECT  1 FROM pro.AccountCal WHERE CustomerAcID = @AccountID AND  EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey
				
				)	
				BEGIN
				   PRINT 2
					SET @Result=-6
					RETURN @Result --Customer Id Not Exist

				END
				IF not EXISTS(				                
					SELECT  1 FROM pro.CustomerCal WHERE CustomerName = @CustomerName AND  EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey
				)	
				BEGIN
				   PRINT 2
					SET @Result=-7
					RETURN @Result --Customer Id Not Exist

				END

		
		IF EXISTS(				                
					SELECT  1 FROM AdvAcProjectDetail WHERE AccountId = @AccountID AND ISNULL(AuthorisationStatus,'A')='A' and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey
					UNION
					SELECT  1 FROM AdvAcProjectDetail_Mod WHERE (EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey)
															AND AccountId = @AccountID
															AND   ISNULL(AuthorisationStatus,'A') in('NP','MP','DP','RM') 
				)	
				BEGIN
				   PRINT 2
					SET @Result=-4
					RETURN @Result -- USER ALEADY EXISTS

				END
		----ELSE
		----	BEGIN
		----	   PRINT 3
		----		SELECT @CustomerID=NEXT VALUE FOR Seq_@CustomerID
		----		PRINT @CustomerID
		----	END
		---------------------Added on 29/05/2020 for user allocation rights
		/*
		IF @AccessScopeAlt_Key in (1,2)
		BEGIN
		PRINT 'Sunil'

		IF EXISTS(				                
					SELECT  1 FROM DimUserinfo WHERE UserLoginID=@CustomerID AND ISNULL(AuthorisationStatus,'A')='A' and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey
					And IsChecker='N'
				)	
				BEGIN
				   PRINT 2
					SET @Result=-6
					RETURN @Result -- USER SHOULD HAVE CHECKER RIGHTS 
				END
		END

		
		IF @AccessScopeAlt_Key in (3)
		BEGIN
		PRINT 'Sunil1'

		IF EXISTS(				                
					SELECT  1 FROM DimUserinfo WHERE UserLoginID=@CustomerID AND ISNULL(AuthorisationStatus,'A')='A' and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey
					And IsChecker='Y'
				)	
				BEGIN
				   PRINT 2
					SET @Result=-8
					RETURN @Result -- USER SHOULD NOT HAVE CHECKER RIGHTS 
				END
		END
		*/
----------------------------------------
	END

	
	BEGIN TRY
	BEGIN TRANSACTION	
	-----
	
	PRINT 3	
		--np- new,  mp - modified, dp - delete, fm - further modifief, A- AUTHORISED , 'RM' - REMARK 
	IF @OperationFlag =1 AND @AuthMode ='Y' -- ADD
		BEGIN
				     PRINT 'Add'
					 SET @CreatedBy =@CrModApBy 
					 SET @DateCreated = GETDATE()
					 SET @AuthorisationStatus='NP'
					 GOTO PUI_Insert
					PUI_Insert_Add:
			END


			ELSE IF(@OperationFlag = 2 OR @OperationFlag = 3) AND @AuthMode = 'Y' --EDIT AND DELETE
			BEGIN
				Print 4
				SET @CreatedBy= @CrModApBy
				SET @DateCreated = GETDATE()
				Set @Modifiedby=@CrModApBy   
				Set @DateModified =GETDATE() 

					PRINT 5

					IF @OperationFlag = 2
						BEGIN
							PRINT 'Edit'
							SET @AuthorisationStatus ='MP'
							
						END

					ELSE
						BEGIN
							PRINT 'DELETE'
							SET @AuthorisationStatus ='DP'
							
						END

						---FIND CREATED BY FROM MAIN TABLE
					SELECT  @CreatedBy		= CreatedBy
							,@DateCreated	= DateCreated 
					FROM AdvAcProjectDetail  
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND CustomerID =@CustomerID	

				---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
				IF ISNULL(@CreatedBy,'')=''
				BEGIN
					PRINT 'NOT AVAILABLE IN MAIN'
					SELECT  @CreatedBy		= CreatedBy
							,@DateCreated	= DateCreated 
					FROM AdvAcProjectDetail 
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND CustomerID =@CustomerID 						
							AND AuthorisationStatus IN('NP','MP','A','RM')
															
				END
				ELSE ---IF DATA IS AVAILABLE IN MAIN TABLE
					BEGIN
					       Print 'AVAILABLE IN MAIN'
						----UPDATE FLAG IN MAIN TABLES AS MP
						UPDATE AdvAcProjectDetail
							SET AuthorisationStatus=@AuthorisationStatus
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND CustomerID =@CustomerID

					END

					--UPDATE NP,MP  STATUS 
					IF @OperationFlag=2
					BEGIN	

						UPDATE AdvAcProjectDetail_Mod
							SET AuthorisationStatus='FM'
							,ModifiedBy=@Modifiedby
							,DateModified=@DateModified
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND CustomerID =@CustomerID
								AND AuthorisationStatus IN('NP','MP','RM')
					END

					GOTO PUI_Insert
					PUI_Insert_Edit_Delete:
				END

		ELSE IF @OperationFlag =3 AND @AuthMode ='N'
		BEGIN
		-- DELETE WITHOUT MAKER CHECKER
											
						SET @Modifiedby   = @CrModApBy 
						SET @DateModified = GETDATE() 

						UPDATE AdvAcProjectDetail SET
									ModifiedBy =@Modifiedby 
									,DateModified =@DateModified 
									,EffectiveToTimeKey =@EffectiveFromTimeKey-1
								WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) AND CustomerID=@CustomerID
				

		end
	
	
	ELSE IF @OperationFlag=17 AND @AuthMode ='Y' 
		BEGIN
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE AdvAcProjectDetail_Mod
					SET AuthorisationStatus='R'
					,ApprovedBy	 =@ApprovedBy
					,DateApproved=@DateApproved
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						AND CustomerID =@CustomerID
						AND AuthorisationStatus in('NP','MP','DP','RM')	

---------------Added for Rejection Pop Up Screen  29/06/2020   ----------

		Print 'Sunil'

--		DECLARE @EntityKey as Int 
--		SELECT	@CreatedBy=CreatedBy,@DateCreated=DATECreated,@EntityKey=EntityKey
--							 FROM AdvAcProjectDetail_Mod 
--								WHERE (EffectiveToTimeKey =@EffectiveFromTimeKey-1 )
--									AND CustomerID=@CustomerID And ISNULL(AuthorisationStatus,'A')='R'
		
--	EXEC [AxisIntReversalDB].[RejectedEntryDtlsInsert]  @Uniq_EntryID = @EntityKey, @OperationFlag = @OperationFlag ,@AuthMode = @AuthMode ,@RejectedBY = @CrModApBy
--,@RemarkBy = @CreatedBy,@DateCreated=@DateCreated ,@RejectRemark = @Remark ,@ScreenName = @ScreenName
		

--------------------------------

				IF EXISTS(SELECT 1 FROM AdvAcProjectDetail WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) AND CustomerID=@CustomerID)
				BEGIN
					UPDATE AdvAcProjectDetail
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND CustomerID =@CustomerID
							AND AuthorisationStatus IN('MP','DP','RM') 	
				END
		END	

	ELSE IF @OperationFlag=18
	BEGIN
		PRINT 18
		SET @ApprovedBy=@CrModApBy
		SET @DateApproved=GETDATE()
		UPDATE AdvAcProjectDetail_Mod
		SET AuthorisationStatus='RM'
		WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
		AND AuthorisationStatus IN('NP','MP','DP','RM')
		AND CustomerID=@CustomerID 

	END

	ELSE IF @OperationFlag=16 OR @AuthMode='N'
		BEGIN
			
			Print 'Authorise'
	-------set parameter for  maker checker disabled
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
					 FROM AdvAcProjectDetail 
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey >=@TimeKey )
							AND CustomerID=@CustomerID 
					
					SET @ApprovedBy = @CrModApBy			
					SET @DateApproved=GETDATE()
					END
			END	
			
	---set parameters and UPDATE mod table in case maker checker enabled
			IF @AuthMode='Y'
				BEGIN
				    Print 'B'
					DECLARE @DelStatus CHAR(2)
					DECLARE @CurrRecordFromTimeKey smallint=0

					Print 'C'
					SELECT @ExEntityKey= MAX(EntityKey) FROM AdvAcProjectDetail_Mod 
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
							AND CustomerID=@CustomerID
							AND AuthorisationStatus IN('NP','MP','DP','RM')	

					SELECT	@DelStatus=AuthorisationStatus,@CreatedBy=CreatedBy,@DateCreated=DATECreated
						,@ModifiedBy=ModifiedBy, @DateModified=DateModified
					 FROM AdvAcProjectDetail_Mod
						WHERE EntityKey=@ExEntityKey
					
					SET @ApprovedBy = @CrModApBy			
					SET @DateApproved=GETDATE()
				
					
					DECLARE @CurEntityKey INT=0

					SELECT @ExEntityKey= MIN(EntityKey) FROM AdvAcProjectDetail_Mod 
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
							AND CustomerID=@CustomerID
							AND AuthorisationStatus IN('NP','MP','DP','RM')	
				
					SELECT	@CurrRecordFromTimeKey=EffectiveFromTimeKey 
						 FROM AdvAcProjectDetail_Mod
							WHERE EntityKey=@ExEntityKey

					UPDATE AdvAcProjectDetail_Mod
						SET  EffectiveToTimeKey =@CurrRecordFromTimeKey-1
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
						AND CustomerID=@CustomerID
						AND AuthorisationStatus='A'	

		-------DELETE RECORD AUTHORISE
					IF @DelStatus='DP' 
					BEGIN	
						UPDATE AdvAcProjectDetail_Mod
						SET AuthorisationStatus ='A'
							,ApprovedBy=@ApprovedBy
							,DateApproved=@DateApproved
							,EffectiveToTimeKey =@EffectiveFromTimeKey -1
						WHERE CustomerID=@CustomerID
							AND AuthorisationStatus in('NP','MP','DP','RM')
						
						IF EXISTS(SELECT 1 FROM AdvAcProjectDetail WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
										AND CustomerID=@CustomerID)
						BEGIN
								UPDATE AdvAcProjectDetail
									SET AuthorisationStatus ='A'
										,ModifiedBy=@ModifiedBy
										,DateModified=@DateModified
										,ApprovedBy=@ApprovedBy
										,DateApproved=@DateApproved
										,EffectiveToTimeKey =@EffectiveFromTimeKey-1
									WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
											AND CustomerID=@CustomerID

								
						END
					END -- END OF DELETE BLOCK

					ELSE  -- OTHER THAN DELETE STATUS
					BEGIN
							UPDATE AdvAcProjectDetail_Mod
								SET AuthorisationStatus ='A'
									,ApprovedBy=@ApprovedBy
									,DateApproved=@DateApproved
								WHERE CustomerID=@CustomerID				
									AND AuthorisationStatus in('NP','MP','RM')

			

									
					END		
				END



		IF @DelStatus <>'DP' OR @AuthMode ='N'
				BEGIN
						DECLARE @IsAvailable CHAR(1)='N'
						,@IsSCD2 CHAR(1)='N'
								SET @AuthorisationStatus='A' --changedby siddhant 5/7/2020

						IF EXISTS(SELECT 1 FROM AdvAcProjectDetail WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
									 AND CustomerID=@CustomerID)
							BEGIN
								SET @IsAvailable='Y'
								--SET @AuthorisationStatus='A'


								IF EXISTS(SELECT 1 FROM AdvAcProjectDetail WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND EffectiveFromTimeKey=@TimeKey AND CustomerID=@CustomerID)
									BEGIN

------------------For Lead Bank Alt Key Manage  Added 11-01-2021


											PRINT 'BBBB'
										UPDATE AdvAcProjectDetail SET
															
												CustomerID											=@CustomerID				
												,CustomerName										=@CustomerName				
												,AccountId						                	=@AccountID	
												,OriginalEnvisagCompletionDt						=@OriginalEnvisagCompletionDt
												,RevisedCompletionDt								=@RevisedCompletionDt
												,ActualCompletionDt								    =@ActualCompletionDt
												,ProjectCatgAlt_Key								    =@ProjectCatgAlt_Key		
												,ProjectDelReason_AltKey							=@ProjectDelReason_AltKey				
												,StandardRestruct_AltKey						    =@StandardRestruct_AltKey			
												,ModifiedBy											= @ModifiedBy
												,DateModified										= @DateModified
												,ApprovedBy											= CASE WHEN @AuthMode ='Y' THEN @ApprovedBy ELSE NULL END
												,DateApproved										= CASE WHEN @AuthMode ='Y' THEN @DateApproved ELSE NULL END
												,AuthorisationStatus								= CASE WHEN @AuthMode ='Y' THEN  'A' ELSE NULL END
												
											 WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND EffectiveFromTimeKey=@EffectiveFromTimeKey AND CustomerID=@CustomerID
									END	

									ELSE
										BEGIN
											SET @IsSCD2='Y'
										END
								END

								IF @IsAvailable='N' OR @IsSCD2='Y'
									BEGIN


------------------For Lead Bank Alt Key Manage  Added 11-01-2021


										INSERT INTO AdvAcProjectDetail
												(
												  CustomerEntityID
												, RefAccountEntityId
												 ,CustomerID					
												 ,CustomerName				
												 ,AccountId	
												 ,OriginalEnvisagCompletionDt
												 ,RevisedCompletionDt
												 ,ActualCompletionDt			
												 ,ProjectCatgAlt_Key		
												 ,ProjectDelReason_AltKey				
												 ,StandardRestruct_AltKey			
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
													0
													,'NULL'			
													,@CustomerID					
													,@CustomerName				
													,@AccountID	
													,@OriginalEnvisagCompletionDt
													,@RevisedCompletionDt			
													,@ActualCompletionDt		
													,@ProjectCatgAlt_Key				
													,@ProjectDelReason_AltKey			
													,@StandardRestruct_AltKey			
													,CASE WHEN @AUTHMODE= 'Y' THEN   @AuthorisationStatus ELSE NULL END
													,@EffectiveFromTimeKey
													,@EffectiveToTimeKey
													,@CreatedBy 
													,@DateCreated
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy  ELSE NULL END
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified  ELSE NULL END
													,CASE WHEN @AUTHMODE= 'Y' THEN    @ApprovedBy ELSE NULL END
													,CASE WHEN @AUTHMODE= 'Y' THEN    @DateApproved  ELSE NULL END
													
										Update A
										SET A.CustomerEntityID=B.CustomerEntityID,
										 A.RefAccountEntityId=B.AccountEntityID
										FROM advacprojectdetail A INNER JOIN PRO.Accountcal B
										ON A.AccountId=B.CustomerAcID
										where B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey
										and A.AccountId = @AccountID
									END

					
									IF @IsSCD2='Y' 
								BEGIN
								UPDATE AdvAcProjectDetail SET
										EffectiveToTimeKey=@EffectiveFromTimeKey-1
										,AuthorisationStatus =CASE WHEN @AUTHMODE='Y' THEN  'A' ELSE NULL END
									WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) AND CustomerID=@CustomerID
											AND EffectiveFromTimekey<@EffectiveFromTimeKey
								END
							END

		IF @AUTHMODE='N'
			BEGIN
					SET @AuthorisationStatus='A'
					GOTO PUI_Insert
					HistoryRecordInUp:
			END						



		END 

PRINT 6
SET @ErrorHandle=1

PUI_Insert:
IF @ErrorHandle=0
	BEGIN

	
------------------For Lead Bank Alt Key Manage  Added 11-01-2021



			INSERT INTO AdvAcProjectDetail_Mod  
											( 
											      RefAccountEntityId
												 ,CustomerID					
												 ,CustomerName				
												 ,AccountId	
												 ,OriginalEnvisagCompletionDt
												 ,RevisedCompletionDt
												 ,ActualCompletionDt			
												 ,ProjectCatgAlt_Key		
												 ,ProjectDelReason_AltKey				
												 ,StandardRestruct_AltKey	
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
								VALUES
											( 
											        'NULL'
													,@CustomerID					
													,@CustomerName				
													,@AccountID	
													,Convert(date,@OriginalEnvisagCompletionDt,103)
													,@RevisedCompletionDt			
													,@ActualCompletionDt		
													,@ProjectCatgAlt_Key				
													,@ProjectDelReason_AltKey			
													,@StandardRestruct_AltKey	
													,@AuthorisationStatus
													,@EffectiveFromTimeKey
													,@EffectiveToTimeKey 
													,@CreatedBy
													,@DateCreated
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy ELSE NULL END
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified ELSE NULL END
													,CASE WHEN @AuthMode='Y' THEN @ApprovedBy    ELSE NULL END
													,CASE WHEN @AuthMode='Y' THEN @DateApproved  ELSE NULL END
													
											)
	
									

		         IF @OperationFlag =1 AND @AUTHMODE='Y'
					BEGIN
						PRINT 3
						GOTO PUI_Insert_Add
					END
				ELSE IF (@OperationFlag =2 OR @OperationFlag =3)AND @AUTHMODE='Y'
					BEGIN
						GOTO PUI_Insert_Edit_Delete
					END
					

				
	END



	-------------------
PRINT 7
		COMMIT TRANSACTION

		--SELECT @D2Ktimestamp=CAST(D2Ktimestamp AS INT) FROM AdvAcProjectDetail WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) 
		--															AND CustomerID=@CustomerID

		IF @OperationFlag =3
			BEGIN
				SET @Result=0
			END
		ELSE
			BEGIN
				SET @Result=1
			END
END TRY
BEGIN CATCH
	ROLLBACK TRAN

		INSERT INTO dbo.Error_Log
				SELECT ERROR_LINE() as ErrorLine,ERROR_MESSAGE()ErrorMessage,ERROR_NUMBER()ErrorNumber
				,ERROR_PROCEDURE()ErrorProcedure,ERROR_SEVERITY()ErrorSeverity,ERROR_STATE()ErrorState
				,GETDATE()

	SELECT ERROR_MESSAGE()
	RETURN -1
   
END CATCH
---------
END


GO