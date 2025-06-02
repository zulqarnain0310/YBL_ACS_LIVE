SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



create PROC [dbo].[RefPeriodMasterInUp_FirstLevelAuth_Live]
						@Rule_Key Int=0
						,@RuleAlt_Key Int=0
						,@RuleType Varchar(50)=null
						,@RefValue  Varchar(100)=null
						,@RefUnit	Varchar(100)=null
						,@BusinessRule Varchar(100)	= ''
						,@BusienssRuleName Varchar(100)=null
						,@ColumnName     Varchar(100)=null
						--,@LogicSql       Varchar(1000)=null
						,@RefPeriodMaster_ChangeFields varchar(100)=null
						,@SourceSystemAlt_Key Int=1
						,@IRACParameter Varchar(100)=null
						,@Grade Varchar(50)=null
						
						
						---------D2k System Common Columns		--
						,@Remark					VARCHAR(500)	= ''
						--,@MenuID					SMALLINT		= 0  change to Int
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
						@AuthorisationStatus		varchar(5)		= NULL 
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
						,@AuthLevel				Varchar(3)=NULL
				SET @ScreenName = 'RefPeriodMaster'

	-------------------------------------------------------------

 SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C') 

 SET @EffectiveFromTimeKey  = @TimeKey

	SET @EffectiveToTimeKey = 49999
	--SELECT @AuthLevel=AuthLevel FROM SysCRisMacMenu WHERE MenuId=@MenuID
	SET @AuthLevel=1
	--SET @BankRPAlt_Key = (Select ISNULL(Max(BankRPAlt_Key),0)+1 from DimBankRP)
												
	PRINT 'A'
	
	--SET @RuleAlt_Key = (select Rule_Key from pro.RefPeriod_Mod where RuleAlt_Key = @RuleAlt_Key)

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
		-----CHECK DUPLICATE
		IF EXISTS(				                
					SELECT  1 FROM pro.RefPeriod WHERE BusinessRule=@BusinessRule AND ISNULL(AuthorisationStatus,'A')='A' and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey
					UNION
					SELECT  1 FROM pro.RefPeriod_Mod  WHERE (EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey)
															AND BusinessRule=@BusinessRule
															AND   ISNULL(AuthorisationStatus,'A') in('NP','MP','DP','RM') 
				)	
				BEGIN
				   PRINT 2
					SET @Result=-4
					RETURN @Result -- USER ALEADY EXISTS
				END
		ELSE
			BEGIN
			   PRINT 3
				 SET @RuleAlt_Key = (Select ISNULL(Max(RuleAlt_Key),0)+1 from 
												(Select RuleAlt_Key from pro.RefPeriod
												 UNION 
												 Select RuleAlt_Key from pro.RefPeriod_Mod
												)A)
			END
		---------------------Added on 29/05/2020 for user allocation rights
		/*
		IF @AccessScopeAlt_Key in (1,2)
		BEGIN
		PRINT 'Sunil'

		IF EXISTS(				                
					SELECT  1 FROM DimUserinfo WHERE UserLoginID=@BankRPAlt_Key AND ISNULL(AuthorisationStatus,'A')='A' and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey
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
					SELECT  1 FROM DimUserinfo WHERE UserLoginID=@BankRPAlt_Key AND ISNULL(AuthorisationStatus,'A')='A' and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey
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

					 --SET @RuleAlt_Key = (Select ISNULL(Max(RuleAlt_Key),0)+1 from 
						--						(Select RuleAlt_Key from pro.RefPeriod
						--						 UNION 
						--						 Select RuleAlt_Key from pro.RefPeriod_Mod
						--						)A)

					 GOTO RefPeriodMaster_Insert
					RefPeriodMaster_Insert_Add:
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
					FROM pro.RefPeriod  
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND RuleAlt_Key =@RuleAlt_Key

				---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
				IF ISNULL(@CreatedBy,'')=''
				BEGIN
					PRINT 'NOT AVAILABLE IN MAIN'
					SELECT  @CreatedBy		= CreatedBy
							,@DateCreated	= DateCreated 
					FROM pro.RefPeriod_Mod 
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND RuleAlt_Key =@RuleAlt_Key
							AND AuthorisationStatus IN('NP','MP','A','RM')
															
				END
				ELSE ---IF DATA IS AVAILABLE IN MAIN TABLE
					BEGIN
					       Print 'AVAILABLE IN MAIN'
						----UPDATE FLAG IN MAIN TABLES AS MP
						UPDATE pro.RefPeriod
							SET AuthorisationStatus=@AuthorisationStatus
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND RuleAlt_Key =@RuleAlt_Key

					END

					--UPDATE NP,MP  STATUS 
					IF @OperationFlag=2
					BEGIN	

						UPDATE pro.RefPeriod_Mod
							SET AuthorisationStatus='FM'
							,ModifiedBy=@Modifiedby
							,DateModified=@DateModified
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND RuleAlt_Key =@RuleAlt_Key
								AND AuthorisationStatus IN('NP','MP','RM')
					END

					GOTO RefPeriodMaster_Insert
					RefPeriodMaster_Insert_Edit_Delete:
				END

		ELSE IF @OperationFlag =3 AND @AuthMode ='N'
		BEGIN
		-- DELETE WITHOUT MAKER CHECKER
											
						SET @Modifiedby   = @CrModApBy 
						SET @DateModified = GETDATE() 

						UPDATE pro.RefPeriod SET
									ModifiedBy =@Modifiedby 
									,DateModified =@DateModified 
									,EffectiveToTimeKey =@EffectiveFromTimeKey-1
								WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) AND RuleAlt_Key=@RuleAlt_Key
								and SourceSystemAlt_Key=@SourceSystemAlt_Key
				

		end

		-----------------------------------------first lvel auth.---------
		ELSE IF @OperationFlag in(21,17) AND @AuthMode ='Y'   
		BEGIN
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE pro.RefPeriod_Mod
					SET AuthorisationStatus='R'
					--,ApprovedByFirstLevel	 =@ApprovedBy
					--,DateApprovedFirstLevel =@DateApproved
					,ApprovedBy=@ApprovedBy
					,DateApproved=@DateApproved
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						AND RuleAlt_Key =@RuleAlt_Key
						AND AuthorisationStatus in('NP','MP','DP','RM','1A','1D')	

		IF EXISTS(SELECT 1 FROM pro.RefPeriod WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) 
		                                        AND RuleAlt_Key =@RuleAlt_Key)
				BEGIN
					UPDATE pro.RefPeriod
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND RuleAlt_Key =@RuleAlt_Key
							AND AuthorisationStatus IN('MP','DP','RM','1D') 	
				END
		END

		---------------------------------------------------------------------------
	
	
	--------ELSE IF @OperationFlag=17 AND @AuthMode ='Y' 
	--------	BEGIN
	--------			SET @ApprovedBy	   = @CrModApBy 
	--------			SET @DateApproved  = GETDATE()

	--------			UPDATE pro.RefPeriod_Mod
	--------				SET AuthorisationStatus='R'
	--------				,ApprovedByFirstLevel	 =@ApprovedBy
	--------				,DateApprovedFirstLevel =@DateApproved
	--------				,EffectiveToTimeKey =@EffectiveFromTimeKey-1
	--------			WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
	--------					AND RuleAlt_Key =@RuleAlt_Key
	--------					AND AuthorisationStatus in('NP','MP','DP','RM')	



	--------			IF EXISTS(SELECT 1 FROM pro.RefPeriod WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) AND RuleAlt_Key=@RuleAlt_Key)
	--------			BEGIN
	--------				UPDATE pro.RefPeriod
	--------					SET AuthorisationStatus='A'
	--------				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
	--------						AND RuleAlt_Key =@RuleAlt_Key
	--------						AND AuthorisationStatus IN('MP','DP','RM') 	
	--------			END
	--------	END	

	ELSE IF @OperationFlag=18
	BEGIN
		PRINT 18
		SET @ApprovedBy=@CrModApBy
		SET @DateApproved=GETDATE()
		UPDATE pro.RefPeriod_Mod
		SET AuthorisationStatus='RM'
		WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
		AND AuthorisationStatus IN('NP','MP','DP','RM')
		AND RuleAlt_Key=@RuleAlt_Key
		and SourceSystemAlt_Key=@SourceSystemAlt_Key

	END

	-----new add
	ELSE IF @OperationFlag=16  and @AuthLevel =2 

		BEGIN

			SET @ApprovedBy	   = @CrModApBy 
			SET @DateApproved  = GETDATE()

			UPDATE pro.RefPeriod_Mod
							SET AuthorisationStatus ='1A'
								--,ApprovedByFirstLevel	 =@ApprovedBy
						--,DateApprovedFirstLevel =@DateApproved
								WHERE RuleAlt_Key=@RuleAlt_Key
								AND AuthorisationStatus in('NP','MP','DP','RM')
								and SourceSystemAlt_Key=@SourceSystemAlt_Key
print @AuthLevel+'2 level'
		END

	---------------------------

	ELSE IF (@OperationFlag in(20,16) OR  @AuthMode='N')
		BEGIN
			print @AuthLevel+'2 level'
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
					 FROM pro.RefPeriod 
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey >=@TimeKey )
							AND RuleAlt_Key=@RuleAlt_Key
							and SourceSystemAlt_Key=@SourceSystemAlt_Key
					
					SET @ApprovedBy = @CrModApBy			
					SET @DateApproved=GETDATE()
					END
			END	
			
	---set parameters and UPDATE mod table in case maker checker enabled
			IF @AuthMode='Y'
				BEGIN
				    Print 'B'
					DECLARE @DelStatus CHAR(2)=''
					DECLARE @CurrRecordFromTimeKey smallint=0

					Print 'C'
					SELECT @ExEntityKey= MAX(EntityKey) FROM pro.RefPeriod_Mod 
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
							AND RuleAlt_Key=@RuleAlt_Key
							AND AuthorisationStatus IN('NP','MP','DP','RM','1A')
							and SourceSystemAlt_Key=@SourceSystemAlt_Key

					SELECT	@DelStatus=AuthorisationStatus,@CreatedBy=CreatedBy,@DateCreated=DATECreated
						,@ModifiedBy=ModifiedBy, @DateModified=DateModified
					 FROM pro.RefPeriod_Mod
						WHERE EntityKey=@ExEntityKey
					
					SET @ApprovedBy = @CrModApBy			
					SET @DateApproved=GETDATE()
				
					
					DECLARE @CurEntityKey INT=0

					SELECT @ExEntityKey= MIN(EntityKey) FROM pro.RefPeriod_Mod 
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
							AND RuleAlt_Key=@RuleAlt_Key
							AND AuthorisationStatus IN('NP','MP','DP','RM','1A')
							and SourceSystemAlt_Key=@SourceSystemAlt_Key
				
					SELECT	@CurrRecordFromTimeKey=EffectiveFromTimeKey 
						 FROM pro.RefPeriod_Mod
							WHERE EntityKey=@ExEntityKey

					UPDATE pro.RefPeriod_Mod
						SET  EffectiveToTimeKey =@CurrRecordFromTimeKey-1
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
						AND RuleAlt_Key=@RuleAlt_Key
						AND AuthorisationStatus='A'	
						and SourceSystemAlt_Key=@SourceSystemAlt_Key

		-------DELETE RECORD AUTHORISE
					IF @DelStatus='DP' 
					BEGIN	
						UPDATE pro.RefPeriod_Mod
						SET AuthorisationStatus ='A'
							,ApprovedBy=@ApprovedBy
							,DateApproved=@DateApproved
							,EffectiveToTimeKey =@EffectiveFromTimeKey -1
						WHERE RuleAlt_Key=@RuleAlt_Key
							AND AuthorisationStatus in('NP','MP','DP','RM','1A')
							and SourceSystemAlt_Key=@SourceSystemAlt_Key
						
						IF EXISTS(SELECT 1 FROM pro.RefPeriod WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
										AND RuleAlt_Key=@RuleAlt_Key and SourceSystemAlt_Key=@SourceSystemAlt_Key)

						BEGIN
								UPDATE pro.RefPeriod
									SET AuthorisationStatus ='A'
										,ModifiedBy=@ModifiedBy
										,DateModified=@DateModified
										,ApprovedBy=@ApprovedBy
										,DateApproved=@DateApproved
										,EffectiveToTimeKey =@EffectiveFromTimeKey-1
									WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
											AND RuleAlt_Key=@RuleAlt_Key
											and SourceSystemAlt_Key=@SourceSystemAlt_Key

								
						END
					END -- END OF DELETE BLOCK

					ELSE  -- OTHER THAN DELETE STATUS
					BEGIN
							UPDATE pro.RefPeriod_Mod
								SET AuthorisationStatus ='A'
									,ApprovedBy=@ApprovedBy
									,DateApproved=@DateApproved
								WHERE RuleAlt_Key=@RuleAlt_Key				
									AND AuthorisationStatus in('NP','MP','RM','1A')
									and SourceSystemAlt_Key=@SourceSystemAlt_Key

			

									
					END		
				END



		IF @DelStatus <>'DP' OR @AuthMode ='N'
				BEGIN
						DECLARE @IsAvailable CHAR(1)='N'
						,@IsSCD2 CHAR(1)='N'
								SET @AuthorisationStatus='A' --changedby siddhant 5/7/2020

						IF EXISTS(SELECT 1 FROM pro.RefPeriod WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
									 AND RuleAlt_Key=@RuleAlt_Key and SourceSystemAlt_Key=@SourceSystemAlt_Key)
							BEGIN
								SET @IsAvailable='Y'
								--SET @AuthorisationStatus='A'


								IF EXISTS(SELECT 1 FROM pro.RefPeriod WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND EffectiveFromTimeKey=@TimeKey AND RuleAlt_Key=@RuleAlt_Key and SourceSystemAlt_Key=@SourceSystemAlt_Key)
									BEGIN
											PRINT 'BBBB'
										UPDATE pro.RefPeriod SET
												 RuleAlt_Key				=@RuleAlt_Key
												 ,RuleType				=@RuleType
												 ,RefUnit				=@RefUnit
												 ,RefValue				=@RefValue
												,BusinessRule					= @BusinessRule
												,ModifiedBy					= @ModifiedBy
												,DateModified				= @DateModified
												,ApprovedBy					= CASE WHEN @AuthMode ='Y' THEN @ApprovedBy ELSE NULL END
												,DateApproved				= CASE WHEN @AuthMode ='Y' THEN @DateApproved ELSE NULL END
												,AuthorisationStatus		= CASE WHEN @AuthMode ='Y' THEN  'A' ELSE NULL END
												
											 WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND EffectiveFromTimeKey=@EffectiveFromTimeKey AND RuleAlt_Key=@RuleAlt_Key
												and SourceSystemAlt_Key=@SourceSystemAlt_Key
									END	

									ELSE
										BEGIN
											SET @IsSCD2='Y'
										END
								END

								IF @IsAvailable='N' OR @IsSCD2='Y'
									BEGIN
										INSERT INTO pro.RefPeriod
												(	
												Rule_Key
													,RuleAlt_Key
													,RuleType
													,BusinessRule
													,BusienssRuleName
													,ColumnName
													,RefValue
													,RefUnit
													--,LogicSql
													,SourceSystemAlt_Key
													,IRACParameter
													,Grade
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

										SELECT		@Rule_Key
													,@RuleAlt_Key
													,@RuleType
													,@BusinessRule
													,@BusienssRuleName
													,@ColumnName
													,@RefValue
													,@RefUnit
													--,@LogicSql
													,@SourceSystemAlt_Key
													,ISNULL(@IRACParameter,'')
													,@Grade
													,CASE WHEN @AUTHMODE= 'Y' THEN   @AuthorisationStatus ELSE NULL END
													,@EffectiveFromTimeKey
													,@EffectiveToTimeKey
													
													,@CreatedBy 
													,@DateCreated
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy  ELSE NULL END
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified  ELSE NULL END
													,CASE WHEN @AUTHMODE= 'Y' THEN    @ApprovedBy ELSE NULL END
													,CASE WHEN @AUTHMODE= 'Y' THEN    @DateApproved  ELSE NULL END

													
													
										
									END


									IF @IsSCD2='Y' 
								BEGIN
								UPDATE pro.RefPeriod SET
										EffectiveToTimeKey=@EffectiveFromTimeKey-1
										,AuthorisationStatus =CASE WHEN @AUTHMODE='Y' THEN  'A' ELSE NULL END
									WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) AND RuleAlt_Key=@RuleAlt_Key
											AND EffectiveFromTimekey<@EffectiveFromTimeKey
											and SourceSystemAlt_Key=@SourceSystemAlt_Key
								END
							END

		IF @AUTHMODE='N'
			BEGIN
					SET @AuthorisationStatus='A'
					GOTO RefPeriodMaster_Insert
					HistoryRecordInUp:
			END						



		END 

PRINT 6
SET @ErrorHandle=1

RefPeriodMaster_Insert:
IF @ErrorHandle=0
	BEGIN
			INSERT INTO pro.RefPeriod_Mod  
											( 
												Rule_Key
													,RuleAlt_Key
													,RuleType
													,BusinessRule
													,BusienssRuleName
													,ColumnName
													,RefValue
													,RefUnit
													--,LogicSql
													,SourceSystemAlt_Key
													,IRACParameter
													,Grade
												,AuthorisationStatus	
												,EffectiveFromTimeKey
												,EffectiveToTimeKey
												,CreatedBy
												,DateCreated
												,ModifiedBy
												,DateModified
												,ApprovedBy
												,DateApproved
												,changefields
																								
											)
								VALUES
											( 
													@Rule_Key
													,@RuleAlt_Key
													,@RuleType
													,@BusinessRule
													,@BusienssRuleName
													,@ColumnName
													,@RefValue
													,@RefUnit
													--,@LogicSql
													,@SourceSystemAlt_Key
													,ISNULL(@IRACParameter,'')
													,@Grade
													,@AuthorisationStatus
													,@EffectiveFromTimeKey
													,@EffectiveToTimeKey 
													,@CreatedBy
													,@DateCreated
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy ELSE NULL END
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified ELSE NULL END
													,CASE WHEN @AuthMode='Y' THEN @ApprovedBy    ELSE NULL END
													,CASE WHEN @AuthMode='Y' THEN @DateApproved  ELSE NULL END
													,@RefPeriodMaster_ChangeFields 
											)
	DECLARE @Parameter3 varchar(50)
	DECLARE @FinalParameter3 varchar(50)
	SET @Parameter3 = (select STUFF((	SELECT Distinct ',' +ChangeFields
											from pro.RefPeriod_Mod   where  RuleAlt_Key=@RuleAlt_Key and SourceSystemAlt_Key=@SourceSystemAlt_Key
											and ISNULL(AuthorisationStatus,'CustomerACID=A')  in ( 'A','MP')
											 for XML PATH('')),1,1,'') )

											If OBJECT_ID('#AA') is not null
											drop table #AA

select DISTINCT Items 
into #AA 
from (
		SELECT 	CHARINDEX('|',Items) CHRIDX,Items
		FROM( SELECT Items FROM [Split](@Parameter3,',')
 ) A
 )X
 SET @FinalParameter3 = (select STUFF((	SELECT Distinct ',' + Items from #AA  for XML PATH('')),1,1,''))
 
							UPDATE		A
							set			a.ChangeFields = @FinalParameter3							 																																	
							from		pro.RefPeriod_Mod     A
							WHERE		(EffectiveFromTimeKey<=@tiMEKEY AND EffectiveToTimeKey>=@tiMEKEY) 
							and			   RuleAlt_Key=@RuleAlt_Key and SourceSystemAlt_Key=@SourceSystemAlt_Key
	
	
	

		         IF @OperationFlag =1 AND @AUTHMODE='Y'
					BEGIN
						PRINT 3
						GOTO RefPeriodMaster_Insert_Add
					END
				ELSE IF (@OperationFlag =2 OR @OperationFlag =3)AND @AUTHMODE='Y'
					BEGIN
						GOTO RefPeriodMaster_Insert_Edit_Delete
					END
					

				
	END


	IF @OperationFlag IN (1,2,3,16,17,18,20,21) AND @AuthMode ='Y'
		BEGIN
					print 'log table'

					
				SET	@DateCreated     =Getdate()

					IF @OperationFlag IN(16,17,18,20,21) 
						BEGIN 
						       Print 'Authorised'
					
			
								EXEC LogDetailsInsertUpdate_Attendence -- MAINTAIN LOG TABLE
							    @BranchCode=''   ,  ----BranchCode
								@MenuID=@MenuID,
								@ReferenceID=@BusinessRule ,-- ReferenceID ,
								@CreatedBy=NULL,
								@ApprovedBy=@CrModApBy, 
								@CreatedCheckedDt=@DateCreated,
								@Remark=@Remark,
								@ScreenEntityAlt_Key=16  ,---ScreenEntityId -- for FXT060 screen
								@Flag=@OperationFlag,
								@AuthMode=@AuthMode
						END
					ELSE
						BEGIN
						       Print 'UNAuthorised'
						    -- Declare
						     set @CreatedBy  =@CrModApBy
							 
							EXEC LogDetailsInsertUpdate_Attendence -- MAINTAIN LOG TABLE
								@BranchCode=''   ,  ----BranchCode
								@MenuID=@MenuID,
								@ReferenceID=@BusinessRule ,-- ReferenceID ,
								@CreatedBy=@CrModApBy,
								@ApprovedBy=NULL, 						
								@CreatedCheckedDt=@DateCreated,
								@Remark=@Remark,
								@ScreenEntityAlt_Key=16  ,---ScreenEntityId -- for FXT060 screen
								@Flag=@OperationFlag,
								@AuthMode=@AuthMode
						END

		END
	-------------------
PRINT 7
		COMMIT TRANSACTION

		--SELECT @D2Ktimestamp=CAST(D2Ktimestamp AS INT) FROM DimBankRP WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) 
		--															AND BankRPAlt_Key=@BankRPAlt_Key

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