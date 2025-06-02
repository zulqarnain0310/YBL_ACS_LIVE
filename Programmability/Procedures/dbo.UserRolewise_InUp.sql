SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Shubham Mankame>
-- Create date: <20102023>
-- Description:	<Insertion of User Roles for Different Screensd>
-- =============================================


CREATE PROCEDURE [dbo].[UserRolewise_InUp]--@XMLDocument=N'<DataSet />',@DeptGroupName=N'all',@UserRole=N'OPERATOR',@EmployeeID=N'AKSHAY.KALE',@Username=N'AKSHAY.KALE',@ADID=N'AKSHAY.KALE',@AuthMode=N'Y',@TimeKey=26886,@OperationFlag=1,@UserLogin=N'DM410',@SpecialUser='N',@SpecialScreen='Y'
	 @XMLDocument XML=N''
	,@UserLogin VARCHAR(30)=''
	,@ADID VARCHAR(30)
	,@Username VARCHAR(30)
	,@EmployeeID VARCHAR(30)
	,@UserRole VARCHAR(30)
	,@DeptGroupName VARCHAR(30)
	,@TimeKey INT
	,@OperationFlag INT
	,@AuthMode CHAR
	,@SpecialUser char(1)		/*ADDED BY ZAIN ON 20241115 FOR RCAI MATRIX USER WISE ACCESS TO SPECIAL SCREEN ON LOCAL*/
	,@SpecialScreen Char(1)		/*ADDED BY ZAIN ON 20241115 FOR RCAI MATRIX USER WISE ACCESS TO SPECIAL SCREEN ON LOCAL*/
	,@Result  INT =0  OUTPUT


--@XMLDocument XML=N'
--<DataSet>
--<GridData>
--<MenuId>109946</MenuId>
--<ParentId>9999</ParentId>
--<MenuCaption>Parameter Master Maintenance</MenuCaption>
--<IsViewer>false</IsViewer>
--<IsMaker>false</IsMaker>
--<IsLV1checker>false</IsLV1checker>
--<IsLV2checker>false</IsLV2checker>
--<AuthLevel>0</AuthLevel>
--<Userrole>3</Userrole>
--<IsChecker>0</IsChecker>
--<IsChecker2>0</IsChecker2>
--</GridData>
--<GridData>
--<MenuId>109944</MenuId>
--<ParentId>109946</ParentId>
--<MenuCaption>Provision Paramater Master</MenuCaption>
--<IsViewer>false</IsViewer>
--<IsMaker>false</IsMaker>
--<IsLV1checker>false</IsLV1checker>
--<IsLV2checker>false</IsLV2checker>
--<AuthLevel>2</AuthLevel>
--<Userrole>3</Userrole>
--<IsChecker>1</IsChecker>
--<IsChecker2>0</IsChecker2>
--</GridData>
--<GridData>
--<MenuId>109945</MenuId>
--<ParentId>109946</ParentId>
--<MenuCaption>NPA Paramater Master</MenuCaption>
--<IsViewer>false</IsViewer>
--<IsMaker>false</IsMaker>
--<IsLV1checker>false</IsLV1checker>
--<IsLV2checker>false</IsLV2checker>
--<AuthLevel>2</AuthLevel>
--<Userrole>3</Userrole>
--<IsChecker>1</IsChecker>
--<IsChecker2>0</IsChecker2>
--</GridData>
--</DataSet>'
--,@DeptGroupName varchar(200)=N'CAD'
--,@UserRole varchar(200)=N'OPERATOR'
--,@EmployeeID varchar(200)=N'AKSHAY.KALE'
--,@Username varchar(200)=N'shailu'
--,@ADID varchar(200)=N'AKSHAY.KALE'
--,@TimeKey int=26886
--,@OperationFlag INT=16
--,@UserLogin VARCHAR(30)=N'dm585'
--,@Authmode CHAR=N'Y'
--,@SpecialUser char(1)=N'N'
--,@SpecialScreen char(1)=N'N'


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
	,@SpecialUser_Flg_USERROLEMATRIX	CHAR(1)/*ADDED BY ZAIN ON 20241115 FOR RCAI MATRIX USER WISE ACCESS TO SPECIAL SCREEN ON LOCAL*/
	,@SpecialScreen_Flg_USERROLEMATRIX	CHAR(1)/*ADDED BY ZAIN ON 20241115 FOR RCAI MATRIX USER WISE ACCESS TO SPECIAL SCREEN ON LOCAL*/




--Authentication rights changes to be stored as well as 
Select @isChecker=ISNULL(IsChecker,'N'),@isChecker2=ISNULL(IsChecker2,'N') From YBL_ACS.DBO.DimUserInfo Where UserLoginID=@ADID AND EffectiveToTimeKey=49999  -- Added by shubham on 2024-02-09 for Old IDs which were created before Checker 2 Functionality

    BEGIN TRY
    BEGIN TRANSACTION

--Save in Temp Table For Further Actioncs as per NP/MP/DP
IF @OperationFlag NOT IN (16,17)
BEGIN
PRINT 'Records insertingfor NP/MP/DP'
IF OBJECT_ID('Tempdb..#Userrole') IS NOT NULL  
DROP TABLE #Userrole
   
         SELECT   
	
         C.value('./MenuId[1]', 'INT')MenuId  
		,C.value('./ParentId[1]', 'INT')ParentId  
		,C.value('./MenuCaption[1]', 'VARCHAR(200)') MenuCaption  
		,C.value('./IsViewer[1]','bit')  IsViewer  
		,C.value('./IsMaker[1]', 'bit' ) IsMaker  
		,C.value('./IsLV1checker[1]', 'bit' ) IsLV1checker  
		,C.value('./IsLV2checker[1]','bit') IsLV2checker



	INTO #Userrole 
	FROM @XMLDocument.nodes('/DataSet/GridData') AS t(c)  
--Select * From #Userrole


	Print 'DATA Screen Varna AALA'


	IF OBJECT_ID('Tempdb..#Userroleinsert') IS NOT NULL  
	DROP TABLE #Userroleinsert
   
         SELECT   
	
		 @ADID as ADID
		,MenuId  
		,ParentId  
		,MenuCaption  
		,isnull(IsViewer,'False') IsViewer--Case When ViewerChecked ='TRUE' THEN 1 ELSE 0 END AS IsViewer
		,isnull(IsMaker,'False')  IsMaker--Case When MakerChecked  ='TRUE' THEN 1 ELSE 0 END AS IsMaker
		,isnull(IsLV1checker,'False')  IsLV1checker--Case When FirstChecked  ='TRUE' THEN 1 ELSE 0 END AS IsLV1checker
		,isnull(IsLV2checker,'False') IsLV2checker--Case When SecondChecked ='TRUE' THEN 1 ELSE 0 END AS IsLV2checker
		,@UserRole as UserRole
		,@isChecker as isChecker 
		,@isChecker2 as isChecker2
		,NULL as isChanged 
		,@SpecialUser SpecialUser_Flg			/*ADDED BY ZAIN ON 20241115 FOR RCAI MATRIX USER WISE ACCESS TO SPECIAL SCREEN ON LOCAL*/
		,@SpecialScreen SpecialScreen_Flg 		/*ADDED BY ZAIN ON 20241115 FOR RCAI MATRIX USER WISE ACCESS TO SPECIAL SCREEN ON LOCAL*/
		,49999 as EffectivetoTimekey

	INTO #Userroleinsert 
	FROM #Userrole
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
		   [ADID]
          ,[Username]
          ,[EmployeeID]
          ,[UserRole]
          ,[DeptGroupName]
          ,[MenuID]
		  ,[MenuCaption]
          ,[ParentID]
          ,[IsViewer]
          ,[IsMaker]
          ,[IsLV1checker]
          ,[IsLV2checker]
		  ,[Ischecker]
		  ,[Ischecker2]
          ,[AuthorisationStatus]
          ,[EffectiveFromTimeKey]
          ,[EffectiveToTimeKey]
          ,[CreatedBy]
          ,[DateCreated]
          ,[ModifyBy]
          ,[DateModified]
          ,[ApprovedBy]
          ,[DateApproved]
		  ,SpecialUser_Flg		/*ADDED BY ZAIN ON 20241115 FOR RCAI MATRIX USER WISE ACCESS TO SPECIAL SCREEN ON LOCAL*/
		  ,SpecialScreen_Flg	/*ADDED BY ZAIN ON 20241115 FOR RCAI MATRIX USER WISE ACCESS TO SPECIAL SCREEN ON LOCAL*/
       INTO #AuthRej
       from YBL_ACS.DBO.UserRoleWiseMatrix_Mod
       where  AuthorisationStatus IN ('NP','MP','DP','FM')-- COMMENTED BY ZAIN ON 20241030 FOR THE OBSERVATION WHERE FURTHER MODIFIED RECORDS WAS NOT DISPLAYING('NP','MP','DP')
       and EffectiveFromTimeKey=@EffectiveFromTimeKey
	   And ADID = @ADID


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
			FROM YBL_ACS.DBO.UserRoleWiseMatrix A
				WHERE EffectiveFromTimeKey=@TimeKey
				And ADID = @ADID

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

									print 'ShubhamJ123'
								END
							ELSE			
								BEGIN
									SET @AuthorisationStatus='DP'
								END

							---FIND CREADED BY FROM MAIN TABLE
							SELECT  @CreatedBy		= CreatedBy
									,@DateCreated	= DateCreated 
								FROM YBL_ACS.DBO.UserRoleWiseMatrix
								WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								And ADID = @ADID


							---FIND CREADED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
							IF ISNULL(@CreatedBy,'')=''
							BEGIN
								PRINT 44
								SELECT  @CreatedBy		= CreatedBy
										,@DateCreated	= DateCreated 
								FROM YBL_ACS.DBO.UserRoleWiseMatrix_Mod
								WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)	
								And ADID = @ADID
								AND AuthorisationStatus IN('NP','MP','FM','A')-- COMMENTED BY ZAIN ON 20241030 FOR THE OBSERVATION WHERE FURTHER MODIFIED RECORDS WAS NOT DISPLAYING('NP','MP','A')

							END
							ELSE ---IF DATA IS AVAILABLE IN MAIN TABLE
								BEGIN

									----UPDATE FLAG IN MAIN TABLES AS MP
									
									UPDATE YBL_ACS.DBO.UserRoleWiseMatrix
										SET AuthorisationStatus=@AuthorisationStatus
									WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  	
									And ADID = @ADID

								END

							--UPDATE NP,MP  STATUS 
							IF @OperationFlag=2
							BEGIN	
								UPDATE YBL_ACS.DBO.UserRoleWiseMatrix_Mod
									SET AuthorisationStatus='FM'
									,ModifyBy=@Modifiedby
									,DateModified=@DateModifie
								WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)	  		
										AND AuthorisationStatus IN('NP','MP','FM')-- COMMENTED BY ZAIN ON 20241030 FOR THE OBSERVATION WHERE FURTHER MODIFIED RECORDS WAS NOT DISPLAYING('NP','MP')
										And ADID = @ADID
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

						UPDATE YBL_ACS.DBO.UserRoleWiseMatrix SET
									ModifyBy =@Modifiedby 
									,DateModified=@DateModifie 
									,EffectiveToTimeKey =@EffectiveFromTimeKey-1
						WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey)
								And ADID = @ADID

								
				END

		END

	ELSE IF @OperationFlag=17 AND @AuthMode ='Y' 
		BEGIN
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE YBL_ACS.DBO.UserRoleWiseMatrix_Mod
					SET AuthorisationStatus='R'
					,ApprovedBy	 =@ApprovedBy
					,DateApproved=@DateApproved
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
				And ADID = @ADID
						AND AuthorisationStatus in('NP','MP','DP','FM')-- COMMENTED BY ZAIN ON 20241030 FOR THE OBSERVATION WHERE FURTHER MODIFIED RECORDS WAS NOT DISPLAYING('NP','MP','DP','FM')

				IF EXISTS(SELECT 1 FROM YBL_ACS.DBO.UserRoleWiseMatrix WHERE (ADID=@ADID AND EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey))

					BEGIN
						UPDATE YBL_ACS.DBO.UserRoleWiseMatrix
							SET AuthorisationStatus='A'
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						And ADID = @ADID
						AND AuthorisationStatus IN('NP','MP','DP','FM')-- COMMENTED BY ZAIN ON 20241030 FOR THE OBSERVATION WHERE FURTHER MODIFIED RECORDS WAS NOT DISPLAYING(,'MP','DP','FM') 	
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
					 FROM YBL_ACS.DBO.UserRoleWiseMatrix_Mod
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey >=@TimeKey )
						And ADID = @ADID
						
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

						SELECT @ExEntityKey= MAX(EntityKey) FROM YBL_ACS.DBO.UserRoleWiseMatrix_Mod 
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
							AND AuthorisationStatus IN('NP','MP','DP','FM')-- COMMENTED BY ZAIN ON 20241030 FOR THE OBSERVATION WHERE FURTHER MODIFIED RECORDS WAS NOT DISPLAYING('NP','MP','DP')
							And ADID = @ADID

					SELECT	@DelStatus=AuthorisationStatus
							,@CreatedBy=CreatedBy
							,@DateCreated=DATECreated
							,@ModifiedBy=ModifyBy
							,@DateModifie=DateModified
					 FROM YBL_ACS.DBO.UserRoleWiseMatrix_Mod
						WHERE EntityKey=@ExEntityKey
					------
					SET @ApprovedBy = @CrModApBy			
					SET @DateApproved=GETDATE()
				
					
					DECLARE @CurEntityKey INT=0

					SELECT @ExEntityKey= MIN(EntityKey) FROM YBL_ACS.DBO.UserRoleWiseMatrix_Mod 
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
						AND AuthorisationStatus IN('NP','MP','DP','FM')-- COMMENTED BY ZAIN ON 20241030 FOR THE OBSERVATION WHERE FURTHER MODIFIED RECORDS WAS NOT DISPLAYING('NP','MP','DP')
						And ADID = @ADID

					SELECT	@CurrRecordFromTimeKey=EffectiveFromTimeKey 
						 FROM YBL_ACS.DBO.UserRoleWiseMatrix_Mod
							WHERE EntityKey=@ExEntityKey
							And ADID = @ADID

					UPDATE YBL_ACS.DBO.UserRoleWiseMatrix_Mod
						SET  EffectiveToTimeKey =@CurrRecordFromTimeKey-1
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
						And ADID = @ADID
						AND AuthorisationStatus='A'

		
					-------DELETE RECORD AUTHORISE
					IF @DelStatus='DP' 
					BEGIN	
						UPDATE YBL_ACS.DBO.UserRoleWiseMatrix_Mod
						SET AuthorisationStatus ='A'
							,ApprovedBy=@ApprovedBy
							,DateApproved=@DateApproved
							,EffectiveToTimeKey =@EffectiveFromTimeKey-1			
							WHERE AuthorisationStatus in('NP','MP','DP','FM')-- COMMENTED BY ZAIN ON 20241030 FOR THE OBSERVATION WHERE FURTHER MODIFIED RECORDS WAS NOT DISPLAYING('NP','MP','DP')
							And ADID = @ADID
						
						IF EXISTS(SELECT 1 FROM YBL_ACS.DBO.UserRoleWiseMatrix 
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND ADID = @ADID))----ADDED BY ZAIN ON 2024-10-21 FOR DUPLICATE ENTRY IN MOD TABLE OBSERVATION CHANGED MOD TABLE TO MAIN TABLE

						BEGIN
								UPDATE YBL_ACS.DBO.UserRoleWiseMatrix
									SET AuthorisationStatus ='A'
										,ModifyBy=@ModifiedBy
										,DateModified=@DateModifie
										,ApprovedBy=@ApprovedBy
										,DateApproved=@DateApproved
										,EffectiveToTimeKey =@EffectiveFromTimeKey-1
									WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
									And ADID = @ADID
						END
					END -- END OF DELETE BLOCK
			
					ELSE  -- OTHER THAN DELETE STATUS
					BEGIN
					
							UPDATE YBL_ACS.DBO.UserRoleWiseMatrix_Mod
								SET AuthorisationStatus ='A'
									,ApprovedBy=@ApprovedBy
									,DateApproved=@DateApproved
									,EffectiveToTimeKey =@EffectiveFromTimeKey-1----ADDED BY ZAIN ON 2024-10-21 FOR DUPLICATE ENTRY IN MOD TABLE OBSERVATION
								WHERE AuthorisationStatus in('NP','MP','FM')-- COMMENTED BY ZAIN ON 20241030 FOR THE OBSERVATION WHERE FURTHER MODIFIED RECORDS WAS NOT DISPLAYING('NP','MP','DP')
								And ADID = @ADID
					END		
				END

				IF @DelStatus <>'DP' OR @AuthMode ='N'
				BEGIN
						DECLARE @IsAvailable CHAR(1)='N'
						,@IsSCD2 CHAR(1)='N'

						IF EXISTS(SELECT 1 FROM YBL_ACS.DBO.UserRoleWiseMatrix WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) And ADID = @ADID --and datatype=@DataType
						)
							
							
							BEGIN
								SET @IsAvailable='Y'
								SET @AuthorisationStatus='A'

								IF EXISTS(SELECT 1 FROM YBL_ACS.DBO.UserRoleWiseMatrix WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND EffectiveFromTimeKey=@EffectiveFromTimeKey And ADID = @ADID)
									BEGIN
									PRINT 'ITHE ALA'
									/* ADDED BY ZAIN ON 2024-10-21 FOR DUPLICATE ENTRY IN MOD TABLE OBSERVATION CHANGED MOD TABLE TO MAIN TABLE
									delete from YBL_ACS.DBO.UserRoleWiseMatrix where EffectiveFromTimeKey=@TimeKey And ADID = @ADID
									*/

									/*ADDED BY ZAIN ON 2024-10-21 FOR DUPLICATE ENTRY IN MOD TABLE OBSERVATION CHANGED MOD TABLE TO MAIN TABLE*/

									UPDATE U SET EffectiveToTimeKey=@TimeKey-1
									from YBL_ACS.DBO.UserRoleWiseMatrix U where EffectiveFromTimeKey=@TimeKey And ADID = @ADID

									/*ADDED BY ZAIN ON 2024-10-21 FOR DUPLICATE ENTRY IN MOD TABLE OBSERVATION CHANGED MOD TABLE TO MAIN TABLE END*/

							INSERT INTO YBL_ACS.DBO.UserRoleWiseMatrix 
												(
                                                     [ADID]
                                                    ,[Username]
                                                    ,[EmployeeID]
                                                    ,[UserRole]
                                                    ,[DeptGroupName]
                                                    ,[MenuID]
                                         		    ,[MenuCaption]
                                                    ,[ParentID]
                                                    ,[IsViewer]
                                                    ,[IsMaker]
                                                    ,[IsLV1checker]
                                                    ,[IsLV2checker]
                                         		    ,[Ischecker]
                                         		    ,[Ischecker2]
                                                    ,[AuthorisationStatus]
												    ,[CreatedBy]
                                                    ,[DateCreated]
                                                    ,[ModifyBy]
                                                    ,[DateModified]
                                                    ,[ApprovedBy]
                                                    ,[DateApproved]
                                                    ,[EffectiveFromTimeKey]
                                                    ,[EffectiveToTimeKey]
													,SpecialUser_Flg	/*ADDED BY ZAIN ON 20241115 FOR RCAI MATRIX USER WISE ACCESS TO SPECIAL SCREEN ON LOCAL*/
													,SpecialScreen_Flg	/*ADDED BY ZAIN ON 20241115 FOR RCAI MATRIX USER WISE ACCESS TO SPECIAL SCREEN ON LOCAL*/
												)
												SELECT
                                                     [ADID]
                                                    ,[Username]
                                                    ,[EmployeeID]
                                                    ,[UserRole]
                                                    ,[DeptGroupName]
                                                    ,[MenuID]
                                         		    ,[MenuCaption]
                                                    ,[ParentID]
                                                    ,[IsViewer]
                                                    ,[IsMaker]
                                                    ,[IsLV1checker]
                                                    ,[IsLV2checker]
                                         		    ,[Ischecker]
                                         		    ,[Ischecker2]
													,CASE WHEN @AUTHMODE= 'Y' THEN   @AuthorisationStatus ELSE 'A' END 
													,@CreatedBy
													, @DateCreated
												    ,CASE WHEN @IsAvailable='Y' THEN  @ModifiedBy ELSE NULL END 
													,CASE WHEN @IsAvailable='Y' THEN  @DateModifie ELSE NULL END 
												    ,CASE WHEN @AUTHMODE= 'Y' THEN    @ApprovedBy ELSE NULL END
													,CASE WHEN @AUTHMODE= 'Y' THEN    @DateApproved  ELSE NULL END 
													,@EffectiveFromTimeKey  
													,49999
													,@SpecialUser	/*ADDED BY ZAIN ON 20241115 FOR RCAI MATRIX USER WISE ACCESS TO SPECIAL SCREEN ON LOCAL*/
													,@SpecialScreen	/*ADDED BY ZAIN ON 20241115 FOR RCAI MATRIX USER WISE ACCESS TO SPECIAL SCREEN ON LOCAL*/
													
												FROM #AuthRej
												Where ADID = @ADID

												UPDATE A SET AUTHORISATIONSTATUS='A'
												FROM USERROLEWISEMATRIX A WHERE A.ADID=@ADID
												AND  A.EFFECTIVETOTIMEKEY=49999		
												
PRINT 'ZAIN'
												/*ADDED BY ZAIN ON 20241115 FOR RCAI MATRIX USER WISE ACCESS TO SPECIAL SCREEN ON LOCAL*/
												
												SET @SpecialUser_Flg_USERROLEMATRIX=@SpecialUser
												--(SELECT DISTINCT SpecialUser_Flg
												--								FROM UserRoleWiseMatrix
												--									WHERE ADID = 'AKSHAY.KALE'
												--									AND EffectiveFromTimeKey<=26886 AND EffectiveToTimeKey>=26886
												--								)
PRINT 'ZAIN1'
												SET @SpecialScreen_Flg_USERROLEMATRIX=@SpecialScreen
												--(SELECT DISTINCT SpecialScreen_Flg
												--								FROM UserRoleWiseMatrix
												--									WHERE ADID = 'AKSHAY.KALE'
												--									AND EffectiveFromTimeKey<=26886 AND EffectiveToTimeKey>=26886
												--								)
PRINT 'ZAIN2'
												UPDATE A set A.SpecialUser_Flg=@SpecialUser_Flg_USERROLEMATRIX
															,A.SpecialScreen_Flg=@SpecialScreen_Flg_USERROLEMATRIX
												FROM DimUserInfo A
												WHERE A.UserLoginID=@ADID 
													AND	A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
												/*ADDED BY ZAIN ON 20241115 FOR RCAI MATRIX USER WISE ACCESS TO SPECIAL SCREEN ON LOCAL END*/
PRINT 'ZAIN3'
								END	
								ELSE
									BEGIN
										SET @IsSCD2='Y'
									END
							END

						IF @IsAvailable='N' OR @IsSCD2='Y'
							BEGIN
							print 'Shubham J.123'

							INSERT INTO YBL_ACS.DBO.UserRoleWiseMatrix
												(
			                                        [ADID]
                                                    ,[Username]
                                                    ,[EmployeeID]
                                                    ,[UserRole]
                                                    ,[DeptGroupName]
                                                    ,[MenuID]
                                         		    ,[MenuCaption]
                                                    ,[ParentID]
                                                    ,[IsViewer]
                                                    ,[IsMaker]
                                                    ,[IsLV1checker]
                                                    ,[IsLV2checker]
                                         		    ,[Ischecker]
                                         		    ,[Ischecker2]
                                                    ,[AuthorisationStatus]
												    ,[CreatedBy]
                                                    ,[DateCreated]
                                                    ,[ModifyBy]
                                                    ,[DateModified]
                                                    ,[ApprovedBy]
                                                    ,[DateApproved]
                                                    ,[EffectiveFromTimeKey]
                                                    ,[EffectiveToTimeKey]
													,SpecialUser_Flg		/*ADDED BY ZAIN ON 20241115 FOR RCAI MATRIX USER WISE ACCESS TO SPECIAL SCREEN ON LOCAL*/
													,SpecialScreen_Flg		/*ADDED BY ZAIN ON 20241115 FOR RCAI MATRIX USER WISE ACCESS TO SPECIAL SCREEN ON LOCAL*/
												)
												SELECT
                                                     [ADID]
                                                    ,[Username]
                                                    ,[EmployeeID]
                                                    ,[UserRole]
                                                    ,[DeptGroupName]
                                                    ,[MenuID]
                                         		    ,[MenuCaption]
                                                    ,[ParentID]
                                                    ,[IsViewer]
                                                    ,[IsMaker]
                                                    ,[IsLV1checker]
                                                    ,[IsLV2checker]
                                         		    ,[Ischecker]
                                         		    ,[Ischecker2]
													,CASE WHEN @AUTHMODE= 'Y' THEN   @AuthorisationStatus ELSE NULL END 
													,@CreatedBy
													, @DateCreated
												    ,CASE WHEN @IsAvailable='Y' THEN  @ModifiedBy ELSE NULL END 
													,CASE WHEN @IsAvailable='Y' THEN  @DateModifie ELSE NULL END 
												    ,CASE WHEN @AUTHMODE= 'Y' THEN    @ApprovedBy ELSE NULL END
													,CASE WHEN @AUTHMODE= 'Y' THEN    @DateApproved  ELSE NULL END 
													,@EffectiveFromTimeKey  
													,@EffectiveToTimeKey
													,SpecialUser_Flg	/*ADDED BY ZAIN ON 20241115 FOR RCAI MATRIX USER WISE ACCESS TO SPECIAL SCREEN ON LOCAL*/
													,SpecialScreen_Flg	/*ADDED BY ZAIN ON 20241115 FOR RCAI MATRIX USER WISE ACCESS TO SPECIAL SCREEN ON LOCAL*/
													
												FROM #AuthRej
												Where ADID = @ADID

					/*ADDED BY ZAIN ON 20241115 FOR RCAI MATRIX USER WISE ACCESS TO SPECIAL SCREEN ON LOCAL*/
							
							SET @SpecialUser_Flg_USERROLEMATRIX=(SELECT DISTINCT SpecialUser_Flg
															FROM UserRoleWiseMatrix
																WHERE ADID = @ADID
																AND EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey
															)
							
							SET @SpecialScreen_Flg_USERROLEMATRIX=(SELECT DISTINCT SpecialScreen_Flg
															FROM UserRoleWiseMatrix
																WHERE ADID = @ADID
																AND EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey
															)
							
							UPDATE A set A.SpecialUser_Flg=@SpecialUser_Flg_USERROLEMATRIX
										,A.SpecialScreen_Flg=@SpecialScreen_Flg_USERROLEMATRIX
							FROM DimUserInfo A
								WHERE A.UserLoginID=@ADID 
									AND	A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
					/*ADDED BY ZAIN ON 20241115 FOR RCAI MATRIX USER WISE ACCESS TO SPECIAL SCREEN ON LOCAL END*/


													print '  @AuthorisationStatus '
													print   @AuthorisationStatus 

							END
						IF @IsSCD2='Y' 
						BEGIN
						print 'a'
							UPDATE YBL_ACS.DBO.UserRoleWiseMatrix SET
										EffectiveToTimeKey=@EffectiveFromTimeKey-1
										,AuthorisationStatus =CASE WHEN @AUTHMODE='Y' THEN  'A' ELSE NULL END
									WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
											               --AND EffectiveFromTimekey<@EffectiveFromTimeKey COMMENTED BY ZAIN AS IT WAS NOT WORKING FINE ON 20241031
														   And ADID = @ADID
					/*ADDED BY ZAIN ON 20241115 FOR RCAI MATRIX USER WISE ACCESS TO SPECIAL SCREEN ON LOCAL*/
							
							SET @SpecialUser_Flg_USERROLEMATRIX=(SELECT DISTINCT SpecialUser_Flg
															FROM UserRoleWiseMatrix
																WHERE ADID = @ADID
																AND EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey
															)
							
							SET @SpecialScreen_Flg_USERROLEMATRIX=(SELECT DISTINCT SpecialScreen_Flg
															FROM UserRoleWiseMatrix
																WHERE ADID = @ADID
																AND EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey
															)
							
												UPDATE A set A.SpecialUser_Flg=@SpecialUser_Flg_USERROLEMATRIX
															,A.SpecialScreen_Flg=@SpecialScreen_Flg_USERROLEMATRIX
												FROM DimUserInfo A
												WHERE A.UserLoginID=@ADID 
													AND	A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
					/*ADDED BY ZAIN ON 20241115 FOR RCAI MATRIX USER WISE ACCESS TO SPECIAL SCREEN ON LOCAL END*/

						END

				
				END
		END 


		SET @ErrorHandle=1
MstGapCyberSecPreparedness_Insert:
IF @ErrorHandle=0
	BEGIN


/*OBSERVATION RAISED BY NIKHIL WHERE MULTIPLE OPERATION MODES WERE 
LIVE ON 'MP' STATUS
AUTO REJECT PREVIOUS LIVE MOD TABLE RECORDS BY ZAIN ON 20241121*/

UPDATE UserRoleWiseMatrix_Mod 
	SET EffectiveToTimeKey=EffectiveFromTimeKey-1
							,AuthorisationStatus='R'
							,ApprovedBy='AUTO'+@UserLogin
							,DateApproved=GETDATE()
				 Where ADID = @ADID
				 AND EffectiveToTimeKey=49999
/*OBSERVATION RAISED BY NIKHIL WHERE MULTIPLE OPERATION MODES WERE 
LIVE ON 'MP' STATUS
AUTO REJECT PREVIOUS LIVE MOD TABLE RECORDS BY ZAIN ON 20241121 END*/


	print 'ShubhamJ123'
			INSERT INTO YBL_ACS.DBO.UserRoleWiseMatrix_Mod             
				(
			    [ADID]
                                                    ,[Username]
                                                    ,[EmployeeID]
                                                    ,[UserRole]
                                                    ,[DeptGroupName]
                                                    ,[MenuID]
                                         		    ,[MenuCaption]
                                                    ,[ParentID]
                                                    ,[IsViewer]
                                                    ,[IsMaker]
                                                    ,[IsLV1checker]
                                                    ,[IsLV2checker]
                                         		    ,[Ischecker]
                                         		    ,[Ischecker2]
                                                    ,[AuthorisationStatus]
												    ,[CreatedBy]
                                                    ,[DateCreated]
                                                    ,[ModifyBy]
                                                    ,[DateModified]
                                                    ,[ApprovedBy]
                                                    ,[DateApproved]
                                                    ,[EffectiveFromTimeKey]
                                                    ,[EffectiveToTimeKey]
													,SpecialUser_Flg	/*ADDED BY ZAIN ON 20241115 FOR RCAI MATRIX USER WISE ACCESS TO SPECIAL SCREEN ON LOCAL*/
													,SpecialScreen_Flg	/*ADDED BY ZAIN ON 20241115 FOR RCAI MATRIX USER WISE ACCESS TO SPECIAL SCREEN ON LOCAL*/
												)
												SELECT
                                                     [ADID]
                                                    ,@Username
                                                    ,@EmployeeID
                                                    ,[UserRole]
                                                    ,@DeptGroupName
                                                    ,[MenuID]
                                         		    ,[MenuCaption]
                                                    ,[ParentID]
                                                    ,[IsViewer]
                                                    ,[IsMaker]
                                                    ,[IsLV1checker]
                                                    ,[IsLV2checker]
                                         		    ,[Ischecker]
                                         		    ,[Ischecker2]
													,CASE WHEN @AUTHMODE= 'Y' THEN   @AuthorisationStatus ELSE NULL END 
													,@UserLogin /*ADDED BY ZAIN ON 20241219 FOR OBSERVATION OF ANY USER CAN MODIFY MP RECORDS*/
													, GETDATE() /*ADDED BY ZAIN ON 20241219 FOR OBSERVATION OF ANY USER CAN MODIFY MP RECORDS*/
													
											--	    ,CASE WHEN @IsAvailable='Y' THEN  @ModifiedBy ELSE NULL END   ------Commented by Tarkeshwar & replaced by below code on 24May2024
											        , @ModifiedBy /*ADDED BY ZAIN ON 20241219 FOR OBSERVATION OF ANY USER CAN MODIFY MP RECORDS*/
											--		,CASE WHEN @IsAvailable='Y' THEN  @DateModifie ELSE NULL END  ------Commented by Tarkeshwar & replaced by below code on 24May2024
											        ,@DateModifie /*ADDED BY ZAIN ON 20241219 FOR OBSERVATION OF ANY USER CAN MODIFY MP RECORDS*/
												    ,CASE WHEN @AUTHMODE= 'Y' THEN    @ApprovedBy ELSE NULL END
													,CASE WHEN @AUTHMODE= 'Y' THEN    @DateApproved  ELSE NULL END 
													,@EffectiveFromTimeKey  
													,@EffectiveToTimeKey
													,@SpecialUser		/*ADDED BY ZAIN ON 20241115 FOR RCAI MATRIX USER WISE ACCESS TO SPECIAL SCREEN ON LOCAL*/
													,@SpecialScreen		/*ADDED BY ZAIN ON 20241115 FOR RCAI MATRIX USER WISE ACCESS TO SPECIAL SCREEN ON LOCAL*/
													
				 FROM #Userroleinsert
				 Where ADID = @ADID

				 UPDATE A SET AUTHORISATIONSTATUS='A'
				FROM USERROLEWISEMATRIX A WHERE A.ADID=@ADID
				AND  A.EFFECTIVETOTIMEKEY=49999	
				
				/*ADDED BY ZAIN ON 20241115 FOR RCAI MATRIX USER WISE ACCESS TO SPECIAL SCREEN ON LOCAL*/
												
												SET @SpecialUser_Flg_USERROLEMATRIX=(SELECT DISTINCT SpecialUser_Flg
																				FROM UserRoleWiseMatrix
																					WHERE ADID = @ADID
																					AND EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey
																				)

												SET @SpecialScreen_Flg_USERROLEMATRIX=(SELECT DISTINCT SpecialScreen_Flg
																				FROM UserRoleWiseMatrix
																					WHERE ADID = @ADID
																					AND EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey
																				)

												UPDATE A set A.SpecialUser_Flg=@SpecialUser_Flg_USERROLEMATRIX
															,A.SpecialScreen_Flg=@SpecialScreen_Flg_USERROLEMATRIX
												FROM DimUserInfo A
												WHERE A.UserLoginID=@ADID 
													AND	A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
												/*ADDED BY ZAIN ON 20241115 FOR RCAI MATRIX USER WISE ACCESS TO SPECIAL SCREEN ON LOCAL END*/


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