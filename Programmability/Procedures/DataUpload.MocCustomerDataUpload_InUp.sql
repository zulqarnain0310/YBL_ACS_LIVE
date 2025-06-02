SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO




CREATE PROCEDURE [DataUpload].[MocCustomerDataUpload_InUp]
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
		 @BusinessMatrixAlt_key	INT
	    ,@CreatedBy				VARCHAR(50)
	   ,@DateCreated			DATETIME
	   ,@ModifiedBy				VARCHAR(50)
	   ,@DateModified			DATETIME
	   ,@ApprovedBy				VARCHAR(50)
	   ,@DateApproved			DATETIME
	   ,@AuthorisationStatus	CHAR(2)
	   ,@ErrorHandle			SMALLINT =0
	   ,@ExEntityKey			INT	    =0
	   ,@Data_Sequence			INT = 0

--case when C.value('./ADDITIONALPROVISION [1]','varchar(20)')='' Then NULL ELSE C.value('./ADDITIONALPROVISION [1]','Decimal(18,2)') END   ADDITIONALPROVISION
IF OBJECT_ID('TEMPDB..#MocCustomerDataUpload') IS NOT NULL
        DROP TABLE #MocCustomerDataUpload

SELECT 
 C.value('./CUSTOMERID[1]','VARCHAR(30)') CustomerID 
,C.value('./ASSETCLASSIFICATION [1]','VARCHAR(20)') AssetClassification    
,CASE WHEN C.value('./NPADATE [1]','VARCHAR(20)')='' THEN NULL ELSE C.value('./NPADATE [1]','VARCHAR(20)') END NPADate
,case when C.value('./SECURITYVALUE [1]','varchar(20)')='' Then NULL ELSE C.value('./SECURITYVALUE [1]','Decimal(18,2)') END   SECURITYVALUE
,case when C.value('./ADDITIONALPROVISION [1]','varchar(20)')='' Then NULL ELSE C.value('./ADDITIONALPROVISION [1]','Decimal(18,2)') END   ADDITIONALPROVISION    
,C.value('./MOCTYPE [1]','VARCHAR(15)')  MOCType
,C.value('./MOCREASON [1]','VARCHAR(500)')  MOCReason     
,C.value('./MocCustomerDataEntityId [1]','int')  MocCustomerDataEntityId 
,CASE WHEN C.value('./DOUBTFULDATE [1]','VARCHAR(20)')='' THEN NULL ELSE C.value('./DOUBTFULDATE [1]','VARCHAR(20)') END DOUBTFULDATE
INTO  #MocCustomerDataUpload
FROM @XMLDocument.nodes('/DataSet/Gridrow') AS t(c)

--Select '#MocCustomerDataUpload', * from #MocCustomerDataUpload
IF @OperationFlag=1
BEGIN
	PRINT '1'
	IF EXISTS(
			Select 1 From DATAUPLOAD.MocCustomerDataUpload_Mod  D
						INNER JOIN #MocCustomerDataUpload GD 
						ON (EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey) 
							AND D.CustomerID  = GD.CustomerID 
						WHERE D.AuthorisationStatus in('MP','NP','DP','RM') )

	BEGIN
		PRINT 'EXISTS'
		Set @Result=-4
		SELECT DISTINCT @ErrorMsg=
								STUFF((SELECT distinct ', ' + CAST(CustomerID as varchar(max))
								 FROM #MocCustomerDataUpload t2
								 FOR XML PATH('')),1,1,'') 
							From DATAUPLOAD.MocCustomerDataUpload_Mod  D
							INNER JOIN #MocCustomerDataUpload GD 
								ON (EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey) 
								AND D.CustomerID = GD.CustomerID
							WHERE D.AuthorisationStatus in('MP','NP','DP','RM') 

							
		
		SET @ErrorMsg='Authorization Pending for Customer id '+CAST(@ErrorMsg AS VARCHAR(500))+' Please Authorize first'

	
		Return @Result
		
	END
	--ELSE 
	BEGIN	
		--SET @BusinessMatrixAlt_key = 
		 SELECT @BusinessMatrixAlt_key= MAX(BusinessMatrixAlt_key)  FROM  
										(SELECT MAX(Entitykey) BusinessMatrixAlt_key FROM DATAUPLOAD.MocCustomerDataUpload
										 UNION 
										 SELECT MAX(Entitykey) BusinessMatrixAlt_key FROM DATAUPLOAD.MocCustomerDataUpload_Mod
										)A
		SET @BusinessMatrixAlt_key = ISNULL(@BusinessMatrixAlt_key,0)
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
					FROM DATAUPLOAD.MocCustomerDataUpload D
					INNER JOIN  #MocCustomerDataUpload GD	
					ON  D.CustomerID  = GD.CustomerID 
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
		
				PRINT @CreatedBy
				PRINT @DateCreated
				IF ISNULL(@CreatedBy,'')=''
					BEGIN
						PRINT 44
						SELECT  @CreatedBy			= CreatedBy
									,@DateCreated	= DateCreated
							FROM DATAUPLOAD.MocCustomerDataUpload_Mod D
							INNER JOIN  #MocCustomerDataUpload GD	
							ON  D.CustomerID 			= GD.CustomerID 
							WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
							AND    D.AuthorisationStatus IN('NP','MP','DP','RM')
	
																
					END
				ELSE ---IF DATA IS AVAILABLE IN MAIN TABLE
					BEGIN
						PRINT 'OperationFlag'
						----UPDATE FLAG IN MAIN TABLES AS MP
						UPDATE  D
						SET D.AuthorisationStatus=@AuthorisationStatus
						FROM DATAUPLOAD.MocCustomerDataUpload D
						INNER JOIN  #MocCustomerDataUpload GD 
						ON  D.CustomerID 			= GD.CustomerID 
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
					END
			IF @OperationFlag=2
				BEGIN	
					PRINT 'FM'	
					UPDATE  D
						SET D.AuthorisationStatus='FM'
						,D.ModifiedBy=@Modifiedby
						,D.DateModified=@DateModified
					 
					FROM DATAUPLOAD.MocCustomerDataUpload_Mod D
						INNER JOIN  #MocCustomerDataUpload GD 
							ON  D.CustomerID 			= GD.CustomerID 
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
								FROM DATAUPLOAD.MocCustomerDataUpload D
						INNER JOIN  #MocCustomerDataUpload GD	
							ON D.CustomerID 			= GD.CustomerID 
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)

						PRINT CAST(@@ROWCOUNT as VARCHAR(2))+SPACE(1)+'ROW DELETED'

				SET @RESULT=@BusinessMatrixAlt_key

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
				FROM DATAUPLOAD.MocCustomerDataUpload_Mod D
						INNER JOIN  #MocCustomerDataUpload GD	
							ON D.CustomerID 			= GD.CustomerID 
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						and D.AuthorisationStatus IN('NP','MP','DP','RM')


			IF EXISTS(Select 1 From DATAUPLOAD.MocCustomerDataUpload D
						INNER JOIN #MocCustomerDataUpload GD 
						ON (EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey) 
							AND  D.CustomerID 			= GD.CustomerID 
							)
					BEGIN

						UPDATE D
							SET AuthorisationStatus='A'
							FROM DATAUPLOAD.MocCustomerDataUpload D
						INNER JOIN  #MocCustomerDataUpload GD	
						ON D.CustomerID 			= GD.CustomerID 
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
				FROM DATAUPLOAD.MocCustomerDataUpload_Mod D
						INNER JOIN  #MocCustomerDataUpload GD	
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
					             	FROM DATAUPLOAD.MocCustomerDataUpload  D
									INNER JOIN  #MocCustomerDataUpload GD	
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
					SELECT @ExEntityKey= MAX(Entitykey) FROM DATAUPLOAD.MocCustomerDataUpload_Mod A
					 INNER JOIN #MocCustomerDataUpload C
						ON (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
						 AND A.CustomerID			= C.CustomerID
						WHERE  a.AuthorisationStatus IN('NP','MP','DP','RM')	


					PRINT @@ROWCOUNT

					SELECT	@DelStatus=a.AuthorisationStatus
							,@CreatedBy=CreatedBy
							,@DateCreated=DATECreated
							,@ModifiedBy=ModifiedBy
							, @DateModified=DateModified
					 FROM DATAUPLOAD.MocCustomerDataUpload_Mod A
					  INNER JOIN #MocCustomerDataUpload C
						ON (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey) 
						AND A.CustomerID			= C.CustomerID
						WHERE   Entitykey=@ExEntityKey
					
					SET @ApprovedBy = @CrModApBy			
					SET @DateApproved=GETDATE()

					 
				
					
					DECLARE @CurEntityKey INT=0

					SELECT @ExEntityKey= MIN(Entitykey) FROM DATAUPLOAD.MocCustomerDataUpload_Mod A 
					 INNER JOIN #MocCustomerDataUpload C
						ON (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey) 
						AND A.CustomerID			= C.CustomerID
						WHERE  a.AuthorisationStatus IN('NP','MP','DP','RM')	
				
					SELECT	@CurrRecordFromTimeKey=A.EffectiveFromTimeKey 
						 FROM DATAUPLOAD.MocCustomerDataUpload_Mod A
						  INNER JOIN #MocCustomerDataUpload C
						ON (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey) 
							AND  A.CustomerID			= C.CustomerID
							AND Entitykey=@ExEntityKey
			
					UPDATE A
					
						SET  EffectiveToTimeKey =@CurrRecordFromTimeKey-1
						FROM DATAUPLOAD.MocCustomerDataUpload_Mod A
						INNER JOIN #MocCustomerDataUpload C
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
										FROM DATAUPLOAD.MocCustomerDataUpload_Mod G
										INNER JOIN #MocCustomerDataUpload GD 
										ON  G.CustomerID			= GD.CustomerID
										--AND G.CounterPart_BranchCode	= GD.CounterPart_BranchCode
						                 WHERE G.AuthorisationStatus in('NP','MP','DP','RM')

										PRINT 'BE'
						                  IF EXISTS(SELECT 1 FROM DATAUPLOAD.MocCustomerDataUpload G
										INNER JOIN #MocCustomerDataUpload GD 
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
													FROM DATAUPLOAD.MocCustomerDataUpload G
													INNER JOIN #MocCustomerDataUpload GD 
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
										 FROM DATAUPLOAD.MocCustomerDataUpload_Mod G
										 INNER JOIN #MocCustomerDataUpload GD 
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
                                                        FROM DATAUPLOAD.MocCustomerDataUpload G
                                                       INNER JOIN #MocCustomerDataUpload GD ON (G.EffectiveFromTimeKey<=@TimeKey AND G.EffectiveToTimeKey>=@TimeKey )
													    AND G.CustomerID			= GD.CustomerID
                                                       WHERE G.EffectiveFromTimeKey=@EffectiveFromTimeKey  --and ISNULL(GD.AuthorisationStatus,'A')<>'DP'
													


													print 'ROW deleted'+CAST(@@ROWCOUNT AS VARCHAR(10)) +'Deleted'
													
													
                                                    UPDATE G
                                                       SET  
													   G.EffectiveTOTimeKey=@EffectiveFromTimeKey-1
													   ,G.AuthorisationStatus ='A'  --ADDED ON 12 FEB 2018
                                                       FROM DATAUPLOAD.MocCustomerDataUpload G
                                                       INNER JOIN #MocCustomerDataUpload GD ON (G.EffectiveFromTimeKey<=@TimeKey AND G.EffectiveToTimeKey>=@TimeKey )
														AND G.CustomerID			= GD.CustomerID
                                                       WHERE G.EffectiveFromTimeKey<@EffectiveFromTimeKey  --and ISNULL(GD.AuthorisationStatus,'A')<>'DP'
													
													print 'ROW deleted'+CAST(@@ROWCOUNT AS VARCHAR(10))

												
												IF @AuthMode='N' 
												BEGIN
													SET @AuthorisationStatus='A'
												END

												-- SELECT @BusinessMatrixAlt_key= MAX(BusinessMatrixAlt_key)  FROM  
												--	(SELECT MAX(Entitykey) BusinessMatrixAlt_key FROM DATAUPLOAD.MocCustomerDataUpload
												--	 UNION 
												--	 SELECT MAX(Entitykey) BusinessMatrixAlt_key FROM DATAUPLOAD.MocCustomerDataUpload_Mod
												--	)A
												--SET @BusinessMatrixAlt_key = ISNULL(@BusinessMatrixAlt_key,0)


												INSERT INTO DATAUPLOAD.MocCustomerDataUpload
														(
														 MocCustomerDataEntityId
														 ,CustomerID
														,AssetClassification
														,NPADate
														,SecurityValue
														,AdditionalProvision
														,MOCReason
														,MOCTYPE
														,AuthorisationStatus
														,EffectiveFromTimeKey
														,EffectiveToTimeKey
														,CreatedBy
														,DateCreated
														,ModifiedBy
														,DateModified
														,ApprovedBy
														,DateApproved
													    ,DbtDt
														)
													SELECT
													    MocCustomerDataEntityId
														,CustomerID
														,AssetClassification
														,convert(date,NPADate,103)
														,SecurityValue
														,AdditionalProvision
														,MOCReason
														,MOCTYPE
														,CASE WHEN @AuthMode ='Y' THEN @AuthorisationStatus ELSE NULL END
														,@EffectiveFromTimeKey
														,@EffectiveToTimeKey
														,@CreatedBy
														,@DateCreated
														,@ModifiedBy
														,@DateModified
														,CASE WHEN @AuthMode ='Y' THEN @ApprovedBy ELSE NULL END
														,CASE WHEN @AuthMode ='Y' THEN @DateApproved ELSE NULL END
														,convert(date,DOUBTFULDATE,103)
														FROM #MocCustomerDataUpload S

												--/*ADDED TO UPGRADE CUSTOMER IN COBORRWER MAPPING AND DEGRADE CUSTOMER IN COBORROWER MAPPING AS PER MOC BY ZAIN 0N 20241223*/

												--/*ADDED TO EXPIRE OLD DATA IN CUSTNPADETAILS TABLE AS PER MOC BY ZAIN 0N 20250217 */

												--SELECT A.* INTO #ADVCUSTNPADETAIL
												--FROM CURDAT.ADVCUSTNPADETAIL A 
												--INNER JOIN #MOCCUSTOMERDATAUPLOAD B ON A.REFCUSTOMERID=B.CUSTOMERID
												--INNER JOIN DIMASSETCLASS C ON B.ASSETCLASSIFICATION=C.ASSETCLASSSHORTNAME
												--WHERE A.EFFECTIVETOTIMEKEY=49999

												--UPDATE A SET A.Cust_AssetClassAlt_Key=C.AssetClassAlt_Key
												--			,A.NPADt=(CASE WHEN C.AssetClassAlt_Key=1 THEN NULL ELSE B.NPADate END)
												--			,DbtDt=(CASE WHEN C.AssetClassAlt_Key=1 THEN NULL ELSE B.DOUBTFULDATE END)
												--			,LosDt=NULL
												--			,EffectiveFromTimeKey=@TimeKey
												--			,EffectiveToTimeKey=@TimeKey
												--			,NPA_Reason=B.MOCReason
												--FROM #ADVCUSTNPADETAIL A 
												--INNER JOIN #MocCustomerDataUpload B ON A.RefCustomerID=B.CustomerID
												--INNER JOIN DimAssetClass C ON B.AssetClassification=C.AssetClassShortName
												--WHERE A.EFFECTIVETOTIMEKEY=49999


												--UPDATE A SET EFFECTIVETOTIMEKEY=@TIMEKEY-1
												--			,NPA_REASON=B.MOCREASON
												--FROM CURDAT.ADVCUSTNPADETAIL A INNER JOIN #MOCCUSTOMERDATAUPLOAD B ON A.REFCUSTOMERID=B.CUSTOMERID
												--INNER JOIN DIMASSETCLASS C ON B.ASSETCLASSIFICATION=C.ASSETCLASSSHORTNAME

												--INSERT INTO CURDAT.ADVCUSTNPADETAIL
												--(CustomerEntityId,Cust_AssetClassAlt_Key,NPADt,LastInttChargedDt,DbtDt,LosDt,DefaultReason1Alt_Key,DefaultReason2Alt_Key,StaffAccountability,LastIntBooked,RefCustomerID,AuthorisationStatus,EffectiveFromTimeKey,EffectiveToTimeKey,CreatedBy,DateCreated,ModifiedBy,DateModified,ApprovedBy,DateApproved,MocStatus,MocDate,MocTypeAlt_Key,WillfulDefault,WillfulDefaultReasonAlt_Key,WillfulRemark,WillfulDefaultDate,NPA_Reason,SourceSystemCustomerID,cOVID)
												--SELECT CustomerEntityId,Cust_AssetClassAlt_Key,NPADt,LastInttChargedDt,DbtDt,LosDt,DefaultReason1Alt_Key,DefaultReason2Alt_Key,StaffAccountability,LastIntBooked,RefCustomerID,AuthorisationStatus,EffectiveFromTimeKey,EffectiveToTimeKey,CreatedBy,DateCreated,ModifiedBy,DateModified,ApprovedBy,DateApproved,MocStatus,MocDate,MocTypeAlt_Key,WillfulDefault,WillfulDefaultReasonAlt_Key,WillfulRemark,WillfulDefaultDate,NPA_Reason,SourceSystemCustomerID,cOVID 
												--FROM #ADVCUSTNPADETAIL
												--WHERE CUST_ASSETCLASSALT_KEY>1

												--/*ADDED TO EXPIRE OLD DATA IN CUSTNPADETAILS TABLE AS PER MOC BY ZAIN 0N 20250217 END*/

												--UPDATE A SET A.EffectiveToTimeKey=A.EffectiveFromTimeKey-1
												--FROM DATAUPLOAD.MocCustomerDataUpload_Mod A INNER JOIN #MOCCUSTOMERDATAUPLOAD B ON A.CustomerID=B.CustomerID
												--WHERE A.EffectiveToTimeKey=49999
												----/*ADDED TO UPGRADE CUSTOMER IN COBORRWER MAPPING AND DEGRADE CUSTOMER IN COBORROWER MAPPING AS PER MOC BY ZAIN 0N 20241223 END*/
									
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
					IF @OperationFlag IN(16,17) 
						BEGIN 
							SET @DateCreated= GETDATE()
					
								EXEC LogDetailsInsertUpdate_Attendence -- MAINTAIN LOG TABLE
									'' ,
									@MenuID,
									@BusinessMatrixAlt_key,-- ReferenceID ,
									@CreatedBy,
									@ApprovedBy,-- @ApproveBy 
									@DateCreated,
									@Remark,
									@MenuID, -- for FXT060 screen
									@OperationFlag,
									@AuthMode
						END
					ELSE
						BEGIN
					
						--Print @Sc
							EXEC LogDetailsInsertUpdate_Attendence -- MAINTAIN LOG TABLE
								'' ,
								@MenuID,
								@BusinessMatrixAlt_key ,-- ReferenceID ,
								@CreatedBy,
								NULL,-- @ApproveBy 
								@DateCreated,
								@Remark,
								@MenuID, -- for FXT060 screen
								@OperationFlag,
								@AuthMode
						END
			END	


SET @ErrorHandle=1


BusinessMatrix_Insert:
PRINT 'A'
--SELECT  @ErrorHandle
IF @ErrorHandle=0
								
  	BEGIN
								Print 'insert into DATAUPLOAD.MocCustomerDataUpload_Mod'

									PRINT '@ErrorHandle'
									INSERT INTO DATAUPLOAD.MocCustomerDataUpload_Mod
											(
											MocCustomerDataEntityId
											,CustomerID
											,AssetClassification
											,NPADate
											,SecurityValue
											,AdditionalProvision
											,MOCReason
											,MOCTYPE
											,AuthorisationStatus
											,EffectiveFromTimeKey
											,EffectiveToTimeKey
											,CreatedBy
											,DateCreated
											,ModifiedBy
											,DateModified
											,ApprovedBy
											,DateApproved
											,DbtDt
											)
										SELECT
											@BusinessMatrixAlt_key+ROW_NUMBER()OVER(ORDER BY (SELECT 1))
											,CustomerID
											,AssetClassification
											,convert(date,NPADate,103)
											,SecurityValue
											,AdditionalProvision
											,MOCReason
											,MOCTYPE
											,CASE WHEN @AuthMode ='Y' THEN @AuthorisationStatus ELSE NULL END
											,@EffectiveFromTimeKey
											,@EffectiveToTimeKey
											,@CreatedBy
											,@DateCreated
											,@ModifiedBy
											,@DateModified
											,CASE WHEN @AuthMode ='Y' THEN @ApprovedBy ELSE NULL END
											,CASE WHEN @AuthMode ='Y' THEN @DateApproved ELSE NULL END
											,convert(date,DOUBTFULDATE,103)
											FROM #MocCustomerDataUpload S
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
	
		SELECT @D2Ktimestamp=CAST(D2Ktimestamp AS INT) FROM DATAUPLOAD.MocCustomerDataUpload_Mod D
							--INNER JOIN #BusinessMatrix T	ON	D.BusinessMatrixAlt_key = T.BusinessMatrixAlt_key
							WHERE (EffectiveFromTimeKey<=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) 
		
		
			UPDATE A SET CustomerName=B.CustomerName 		FROM  DATAUPLOAD.MocCustomerDataUpload A 		INNER JOIN PRO.customercal B ON A.CustomerID=B.RefCustomerID WHERE A.CUSTOMERNAME IS NULL		
		    UPDATE A SET CustomerName=B.CustomerName 		FROM  DATAUPLOAD.MocCustomerDataUpload_Mod A 		INNER JOIN PRO.customercal B ON A.CustomerID=B.RefCustomerID	 WHERE A.CUSTOMERNAME IS NULL
		    UPDATE A SET CustomerName=B.CustomerName 		FROM  DATAUPLOAD.MocCustomerDataUpload A 		INNER JOIN PRO.customercal B ON A.CustomerID=B.RefCustomerID WHERE A.CUSTOMERNAME=''
		    UPDATE A SET CustomerName=B.CustomerName 		FROM  DATAUPLOAD.MocCustomerDataUpload_Mod A 		INNER JOIN PRO.customercal B ON A.CustomerID=B.RefCustomerID	 WHERE A.CUSTOMERNAME=''
		
							


	
			SET @RESULT=1
			RETURN  @RESULT
			RETURN @D2Ktimestamp
END

ELSE
		BEGIN
				SET @Result=0
				RETURN  @RESULT
		END
		
 END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE() ERRORDESC
	ROLLBACK TRAN


		

	
		
			SET @RESULT=-1
	RETURN @RESULT

		

END  CATCH

	


END						            


GO