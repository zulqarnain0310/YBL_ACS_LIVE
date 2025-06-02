SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Shubham Mankame>
-- Create date: <20102023>
-- Description:	<Insertion of Additional Provision for Different Accounts>
-- =============================================


create PROCEDURE [dbo].[AbsoluteBackdatedMOC_InUp_20240312]
	 @MOCDATE Varchar(30)
	,@AccountID VARCHAR(30)
	,@Branchcode VARCHAR(30)
	,@CustomerID VARCHAR(30)
	,@TotalProvision VARCHAR(30)
	,@AdditionalProvision VARCHAR(30)
	,@FinalProvision VARCHAR(30)
	,@TimeKey INT
	,@OperationFlag INT
	,@AuthMode CHAR
	,@Userlogin varchar(30)
	,@Result  INT =0  OUTPUT



AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE
	 @EffectivefromTimeKey INT = @TimeKey
	,@EffectiveToTimeKey INT   = 49999
	,@isChecker CHAR(1)
	,@CreatedBy	VARCHAR(50)
	,@DateCreated DATETIME
	,@ModifiedBy VARCHAR(50)
	,@DateModifie DATETIME
	,@ApprovedBy VARCHAR(50)
	,@DateApproved DATETIME
	,@AuthorisationStatus CHAR(2)
	,@ExEntityKey INT	  =0
	,@isChecker2 CHAR(1)
	,@ErrorHandle int=0
	,@CrModApBy VARCHAR(50)=@UserLogin
	,@LastMonthDateKey int = (Select LastMonthDateKey From YES_MISDB.DBO.SysDayMatrix Where TimeKey=@TimeKey)
	,@LastMonthDate date = (Select LastMonthDate From YES_MISDB.DBO.SysDayMatrix Where TimeKey=@TimeKey)
	,@MOC_DATE DATe =  CONVERT(date,@MOCDATE, 103)
	

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

IF OBJECT_ID('TEMPDB..##AccountCal_HIST') IS NOT NULL
DROP TABLE ##AccountCal_HIST
CREATE Table ##AccountCal_HIST(CustomerACID varchar(30),
                               AccountEntityID int,
							   BranchCode VARCHAR(20),
							   TotalProvision DECIMAL(22,2),
							   RefCustomerID VARCHAR(50),
							   SourceSystemCustomerID VARCHAR(50),
							   UCIF_ID VARCHAR(50),
							   EffectiveFromTimeKey int)
Declare @SQL Varchar(1000) = 'Select CustomerAcID,AccountEntityID,BranchCode,TotalProvision,RefCustomerID,SourceSystemCustomerID,UCIF_ID,EffectiveFromTimeKey From YES_MISDB_'+@Year+'.DBO.AccountCal_Main_'+@YEAR+'_'+@Month+' Where EffectiveFromTimeKey = '+CAST(@LastMonthDateKey as varchar(5))

Select @SQL
Insert into  ##AccountCal_HIST
EXEC (@SQL) -- To bechanged to dynamic view Partioning

IF @FinalProvision<0 
    Begin 
	Set @Result = -10
    End
Else

    BEGIN TRY
    BEGIN TRANSACTION

--Save in Temp Table For Further Actioncs as per NP/MP/DP
IF @OperationFlag NOT IN (16,17)
BEGIN
PRINT 'Records insertingfor NP/MP/DP'


	Print 'DATA Screen Varna AALA'


	IF OBJECT_ID('Tempdb..#AbsoluteBackdatedMOC') IS NOT NULL  
	DROP TABLE #AbsoluteBackdatedMOC
   
         SELECT   
	
		 @LastMonthDate as MOC_DATE
		,RefCustomerID as CustomerID
		,@AccountID as CustomerACID 
		,Branchcode
		,TotalProvision as ExistingProvision
		,@AdditionalProvision as AdditionalProvision
		,@FinalProvision as FinalProvision
		,NULL as isChanged 
		,49999 as EffectivetoTimekey
    
	INTO #AbsoluteBackdatedMOC 
	FROM ##AccountCal_Hist
	Where CustomerACID=@AccountID
 ----select * from #Userroleinsert
 ----return 1
Print 'Records inserted for NP/MP/DP'

END 
Else
Begin
    print'Records inserting for Auth/Rej'
    IF OBJECT_ID('Tempdb..#AuthRej') IS NOT NULL
    		 DROP TABLE #AuthRej
    	
       SELECT 
		   [AccountEntityID]
          ,[MOC_Date]
          ,[UCIF_ID]
          ,[CustomerID]
          ,[SourceSystemCustomerID]
          ,[CustomerACID]
		  ,[Branchcode]
		  ,[ExistingProvision]
          ,[AdditionalProvision]
          ,[FinalProvision]
          ,[AuthorisationStatus]
          ,[EffectiveFromTimeKey]
          ,[EffectiveToTimeKey]
          ,[CreatedBy]
          ,[DateCreated]
          ,[ModifyBy]
          ,[DateModified]
          ,[ApprovedBy]
          ,[DateApproved]
       INTO #AuthRej
       from YES_MISDB.DataUpload.AbsoluteBackdatedMOC_mod
       where  AuthorisationStatus IN ('NP','MP','DP')
       and EffectiveFromTimeKey=@EffectiveFromTimeKey
	   And CustomerACID = @AccountID

    		--select * from #AuthRej
     print'Records inserted for Auth/Rej'
END

-----------------------------------------------------------------------------------------------------------------------------------------------

IF @OperationFlag=1 AND @AuthMode ='Y'
		BEGIN
		PRINT 1
			SET @CreatedBy =@CrModApBy 
			SET @DateCreated = GETDATE()
			SET @AuthorisationStatus='NP'


			--UPDATE A 
			--SET A.AuthorisationStatus='FM'
			--FROM  Dbo.UpldEODMTMMargin_Mod A
			--	WHERE EffectiveFromTimeKey=@TimeKey 					
			--		and AuthorisationStatus in('NP','MP','DP','A')

	   		UPDATE A 
			SET A.AuthorisationStatus='MP'
			FROM YES_MISDB.DataUpload.AbsoluteBackdatedMOC A
				WHERE EffectiveFromTimeKey=@TimeKey
				And CustomerACID = @AccountID

			GOTO  MstGapCyberSecPreparedness_Insert
			MstGapCyberSecPreparedness_Insert_Add:
			PRINT 7
		END
		ELSE IF (@OperationFlag=2 OR @OperationFlag=3) AND @AuthMode ='Y'
		BEGIN
				SET @Modifiedby   = @CrModApBy 
				SET @DateModifie = GETDATE() 
				
				IF @AuthMode='Y'
					BEGIN
							PRINT 22
							IF @OperationFlag=2
								BEGIN
									SET @AuthorisationStatus='MP'
									PRINT 33
								END
							ELSE			
								BEGIN
									SET @AuthorisationStatus='DP'
								END

							---FIND CREADED BY FROM MAIN TABLE
							SELECT  @CreatedBy		= CreatedBy
									,@DateCreated	= DateCreated 
								FROM YES_MISDB.DataUpload.AbsoluteBackdatedMOC
								WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								And CustomerACID = @AccountID


							---FIND CREADED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
							IF ISNULL(@CreatedBy,'')=''
							BEGIN
								PRINT 44
								SELECT  @CreatedBy		= CreatedBy
										,@DateCreated	= DateCreated 
								FROM YES_MISDB.DataUpload.AbsoluteBackdatedMOC_Mod
								WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)	
								And CustomerACID = @AccountID
								AND AuthorisationStatus IN('NP','MP','A')

							END
							ELSE ---IF DATA IS AVAILABLE IN MAIN TABLE
								BEGIN

									----UPDATE FLAG IN MAIN TABLES AS MP
									UPDATE YES_MISDB.DataUpload.AbsoluteBackdatedMOC
										SET AuthorisationStatus=@AuthorisationStatus
									WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  	
									And CustomerACID = @AccountID

								END

							--UPDATE NP,MP  STATUS 
							IF @OperationFlag=2
							BEGIN	
								UPDATE YES_MISDB.DataUpload.AbsoluteBackdatedMOC_Mod
									SET AuthorisationStatus='FM'
									,ModifyBy=@Modifiedby
									,DateModified=@DateModifie
								WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)	  		
										AND AuthorisationStatus IN('NP','MP')
										And CustomerACID = @AccountID
							END

							GOTO MstGapCyberSecPreparedness_Insert
							MstGapCyberSecPreparedness_Insert_Edit_Delete:
					END

		END
		ELSE IF @OperationFlag =3 AND @AuthMode ='N'
		BEGIN
				-- DELETE WITHOUT MAKER CHECKER
				BEGIN							
						SET @Modifiedby   = @CrModApBy 
						SET @DateModifie = GETDATE() 

						UPDATE YES_MISDB.DataUpload.AbsoluteBackdatedMOC SET
									ModifyBy =@Modifiedby 
									,DateModified=@DateModifie 
									,EffectiveToTimeKey =@EffectiveFromTimeKey-1
						WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey)
						And CustomerACID = @AccountID

								
				END

		END

	ELSE IF @OperationFlag=17 AND @AuthMode ='Y' 
		BEGIN
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE YES_MISDB.DataUpload.AbsoluteBackdatedMOC_Mod
					SET AuthorisationStatus='R'
					,ApprovedBy	 =@ApprovedBy
					,DateApproved=@DateApproved
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
				And CustomerACID = @AccountID
						AND AuthorisationStatus in('NP','MP','DP')

				IF EXISTS(SELECT 1 FROM YES_MISDB.DataUpload.AbsoluteBackdatedMOC WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey))

					BEGIN
						UPDATE YES_MISDB.DataUpload.AbsoluteBackdatedMOC
							SET AuthorisationStatus='A'
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						And CustomerACID = @AccountID
						AND AuthorisationStatus IN('MP','DP') 	
					END
		END
		ELSE IF @OperationFlag=16 OR @AuthMode='N'
		BEGIN
			
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
						SET @DateModifie =GETDATE()
						SELECT	@CreatedBy=CreatedBy,@DateCreated=DATECreated
					 FROM YES_MISDB.DataUpload.AbsoluteBackdatedMOC_Mod
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey >=@TimeKey )
						And CustomerACID = @AccountID
						
					SET @ApprovedBy = @CrModApBy			
					SET @DateApproved=GETDATE()
					END
			END

	--set parameters and upDATE mod tablein case maker checker enabled
	IF @AuthMode='Y'
		BEGIN
				print 'S77' 
					DECLARE @DelStatus CHAR(2)
					DECLARE @CurrRecordFromTimeKey smallint=0

						SELECT @ExEntityKey= MAX(EntityKey) FROM YES_MISDB.DataUpload.AbsoluteBackdatedMOC_Mod 
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
							AND AuthorisationStatus IN('NP','MP','DP')	
							And CustomerACID = @AccountID


					SELECT	@DelStatus=AuthorisationStatus
							,@CreatedBy=CreatedBy
							,@DateCreated=DATECreated
							,@ModifiedBy=ModifyBy
							,@DateModifie=DateModified
					 FROM YES_MISDB.DataUpload.AbsoluteBackdatedMOC_Mod
						WHERE EntityKey=@ExEntityKey
					------
					SET @ApprovedBy = @CrModApBy			
					SET @DateApproved=GETDATE()
				
					
					DECLARE @CurEntityKey INT=0

					SELECT @ExEntityKey= MIN(EntityKey) FROM YES_MISDB.DataUpload.AbsoluteBackdatedMOC_Mod 
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
						AND AuthorisationStatus IN('NP','MP','DP')	
						And CustomerACID = @AccountID


					SELECT	@CurrRecordFromTimeKey=EffectiveFromTimeKey 
						 FROM YES_MISDB.DataUpload.AbsoluteBackdatedMOC_Mod
							WHERE EntityKey=@ExEntityKey
							And CustomerACID = @AccountID

					UPDATE YES_MISDB.DataUpload.AbsoluteBackdatedMOC_Mod
						SET  EffectiveToTimeKey =@CurrRecordFromTimeKey-1
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
						And CustomerACID = @AccountID
						AND AuthorisationStatus='A'

		
					-------DELETE RECORD AUTHORISE
					IF @DelStatus='DP' 
					BEGIN	
						UPDATE YES_MISDB.DataUpload.AbsoluteBackdatedMOC_Mod
						SET AuthorisationStatus ='A'
							,ApprovedBy=@ApprovedBy
							,DateApproved=@DateApproved
							,EffectiveToTimeKey =@EffectiveFromTimeKey-1			
							WHERE AuthorisationStatus in('NP','MP','DP')
							And CustomerACID = @AccountID
						
						IF EXISTS(SELECT 1 FROM YES_MISDB.DataUpload.AbsoluteBackdatedMOC_Mod WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey))

						BEGIN
								UPDATE YES_MISDB.DataUpload.AbsoluteBackdatedMOC
									SET AuthorisationStatus ='A'
										,ModifyBy=@ModifiedBy
										,DateModified=@DateModifie
										,ApprovedBy=@ApprovedBy
										,DateApproved=@DateApproved
										,EffectiveToTimeKey =@EffectiveFromTimeKey-1
									WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
									And CustomerACID = @AccountID
						END
					END -- END OF DELETE BLOCK
			
					ELSE  -- OTHER THAN DELETE STATUS
					BEGIN
					
							UPDATE YES_MISDB.DataUpload.AbsoluteBackdatedMOC_Mod
								SET AuthorisationStatus ='A'
									,ApprovedBy=@ApprovedBy
									,DateApproved=@DateApproved
								WHERE AuthorisationStatus in('NP','MP')
								And CustomerACID = @AccountID
					END		
				END

				IF @DelStatus <>'DP' OR @AuthMode ='N'
				BEGIN
						DECLARE @IsAvailable CHAR(1)='N'
						,@IsSCD2 CHAR(1)='N'

						IF EXISTS(SELECT 1 FROM YES_MISDB.DataUpload.AbsoluteBackdatedMOC WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) And CustomerACID = @AccountID --and datatype=@DataType
						)
							
							
							BEGIN
								SET @IsAvailable='Y'
								SET @AuthorisationStatus='A'

								IF EXISTS(SELECT 1 FROM YES_MISDB.DataUpload.AbsoluteBackdatedMOC WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND EffectiveFromTimeKey=@EffectiveFromTimeKey And CustomerACID = @AccountID)
									BEGIN
									PRINT 'ITHE ALA'
									delete from YES_MISDB.DataUpload.AbsoluteBackdatedMOC where EffectiveFromTimeKey=@TimeKey And CustomerACID = @AccountID

									
							INSERT INTO YES_MISDB.DataUpload.AbsoluteBackdatedMOC 
												(
                                                     [AccountEntityID]
													,[MOC_Date]
													,[UCIF_ID]
													,[CustomerID]
													,[SourceSystemCustomerID]
													,[CustomerACID]
													,[Branchcode]
													,[ExistingProvision]
													,[AdditionalProvision]
													,[FinalProvision]
                                                    ,[AuthorisationStatus]
												    ,[CreatedBy]
                                                    ,[DateCreated]
                                                    ,[ModifyBy]
                                                    ,[DateModified]
                                                    ,[ApprovedBy]
                                                    ,[DateApproved]
                                                    ,[EffectiveFromTimeKey]
                                                    ,[EffectiveToTimeKey]
												)
												SELECT
                                                     [AccountEntityID]
													,[MOC_Date]
													,[UCIF_ID]
													,[CustomerID]
													,[SourceSystemCustomerID]
													,[CustomerACID]
													,[Branchcode]
													,[ExistingProvision]
													,[AdditionalProvision]
													,[FinalProvision]
													,CASE WHEN @AUTHMODE= 'Y' THEN   @AuthorisationStatus ELSE NULL END 
													,@CreatedBy
													, @DateCreated
												    ,CASE WHEN @IsAvailable='Y' THEN  @ModifiedBy ELSE NULL END 
													,CASE WHEN @IsAvailable='Y' THEN  @DateModifie ELSE NULL END 
												    ,CASE WHEN @AUTHMODE= 'Y' THEN    @ApprovedBy ELSE NULL END
													,CASE WHEN @AUTHMODE= 'Y' THEN    @DateApproved  ELSE NULL END 
													,@EffectiveFromTimeKey  
													,@EffectiveToTimeKey
													
												FROM #AuthRej
												Where CustomerACID = @AccountID

								END	
								ELSE
									BEGIN
										SET @IsSCD2='Y'
									END
							END

						IF @IsAvailable='N' OR @IsSCD2='Y'
							BEGIN
							print 'Shubham J.123'

							INSERT INTO YES_MISDB.DataUpload.AbsoluteBackdatedMOC
												(
			                                         [AccountEntityID]
													,[MOC_Date]
													,[UCIF_ID]
													,[CustomerID]
													,[SourceSystemCustomerID]
													,[CustomerACID]
													,[Branchcode]
													,[ExistingProvision]
													,[AdditionalProvision]
													,[FinalProvision]
                                                    ,[AuthorisationStatus]
												    ,[CreatedBy]
                                                    ,[DateCreated]
                                                    ,[ModifyBy]
                                                    ,[DateModified]
                                                    ,[ApprovedBy]
                                                    ,[DateApproved]
                                                    ,[EffectiveFromTimeKey]
                                                    ,[EffectiveToTimeKey]
												)
												SELECT
                                                     [AccountEntityID]
													,[MOC_Date]
													,[UCIF_ID]
													,[CustomerID]
													,[SourceSystemCustomerID]
													,[CustomerACID]
													,[Branchcode]
													,[ExistingProvision]
													,[AdditionalProvision]
													,[FinalProvision]
													,CASE WHEN @AUTHMODE= 'Y' THEN   @AuthorisationStatus ELSE NULL END 
													,@CreatedBy
													, @DateCreated
												    ,CASE WHEN @IsAvailable='Y' THEN  @ModifiedBy ELSE NULL END 
													,CASE WHEN @IsAvailable='Y' THEN  @DateModifie ELSE NULL END 
												    ,CASE WHEN @AUTHMODE= 'Y' THEN    @ApprovedBy ELSE NULL END
													,CASE WHEN @AUTHMODE= 'Y' THEN    @DateApproved  ELSE NULL END 
													,@EffectiveFromTimeKey  
													,@EffectiveToTimeKey
													
												FROM #AuthRej
												Where CustomerACID = @AccountID

													print '  @AuthorisationStatus '
													print   @AuthorisationStatus 

							END
						IF @IsSCD2='Y' 
						BEGIN
						print 'a'
							UPDATE YES_MISDB.DataUpload.AbsoluteBackdatedMOC SET
										EffectiveToTimeKey=@EffectiveFromTimeKey-1
										,AuthorisationStatus =CASE WHEN @AUTHMODE='Y' THEN  'A' ELSE NULL END
									WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
											               AND EffectiveFromTimekey<@EffectiveFromTimeKey 
														   And CustomerACID = @AccountID
						END

				
				END
		END 

		
		SET @ErrorHandle=1
MstGapCyberSecPreparedness_Insert:
IF @ErrorHandle=0
	BEGIN

	print 'ShubhamJ123'
			INSERT INTO YES_MISDB.DataUpload.AbsoluteBackdatedMOC_Mod             
				(
													 [AccountEntityID]
													,[MOC_Date]
													,[UCIF_ID]
													,[CustomerID]
													,[SourceSystemCustomerID]
													,[CustomerACID]
													,[Branchcode]
													,[ExistingProvision]
													,[AdditionalProvision]
													,[FinalProvision]
                                                    ,[AuthorisationStatus]
												    ,[CreatedBy]
                                                    ,[DateCreated]
                                                    ,[ModifyBy]
                                                    ,[DateModified]
                                                    ,[ApprovedBy]
                                                    ,[DateApproved]
                                                    ,[EffectiveFromTimeKey]
                                                    ,[EffectiveToTimeKey]
												)
												SELECT
                                                     a.AccountEntityID
													,[MOC_Date]
													,[UCIF_ID]
													,[CustomerID]
													,[SourceSystemCustomerID]
													,@AccountID
													,a.BranchCode
													,[ExistingProvision]
													,[AdditionalProvision]
													,[FinalProvision]
													,CASE WHEN @AUTHMODE= 'Y' THEN   @AuthorisationStatus ELSE NULL END 
													,@CreatedBy
													, @DateCreated
												    ,CASE WHEN @IsAvailable='Y' THEN  @ModifiedBy ELSE NULL END 
													,CASE WHEN @IsAvailable='Y' THEN  @DateModifie ELSE NULL END 
												    ,CASE WHEN @AUTHMODE= 'Y' THEN    @ApprovedBy ELSE NULL END
													,CASE WHEN @AUTHMODE= 'Y' THEN    @DateApproved  ELSE NULL END 
													,@EffectiveFromTimeKey  
													,@EffectiveToTimeKey
				 FROM #AbsoluteBackdatedMOC m Inner join ##AccountCal_Hist a 
				 on a.CustomerAcID = @AccountID
Print 'Shubham check 1'


				IF @OperationFlag =1
					BEGIN
						PRINT 3
						GOTO MstGapCyberSecPreparedness_Insert_Add

					END
				ELSE IF @OperationFlag =2 OR @OperationFlag =3
					BEGIN
					print 4
						GOTO MstGapCyberSecPreparedness_Insert_Edit_Delete
					END
     END



SET @Result=1	
	
	COMMIT TRANSACTION 
    
	END TRY
		BEGIN CATCH
			ROLLBACK TRAN
			SELECT ERROR_MESSAGE()
			SET    @Result=-1
			RETURN @Result	
		END CATCH

END

GO