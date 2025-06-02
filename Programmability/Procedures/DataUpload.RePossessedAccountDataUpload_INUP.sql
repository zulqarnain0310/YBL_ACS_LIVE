SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/*===================================================
AUTHER : TRILOKI KHANNA
CREATE DATE :21-12-2018
MODIFY DATE :21-12-2018
DESCRIPTION : DATA UPLOAD FOR REPOSSESSION DATE
=====================================================*/
CREATE PROCEDURE [DataUpload].[RePossessedAccountDataUpload_INUP]
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
	    @BusinessMatrixAlt_key INT
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

IF OBJECT_ID('TEMPDB..#RePossessedAccountDataUpload') IS NOT NULL
        DROP TABLE #RePossessedAccountDataUpload

SELECT 
 CASE WHEN C.value('./CUSTOMERACID [1]','VARCHAR(30)')='' THEN NULL ELSE C.value('./CUSTOMERACID [1]','VARCHAR(30)') END CustomerAcID
,CASE WHEN C.value('./REPOSSESSIONDATE [1]','VARCHAR(20)')='' THEN NULL ELSE C.value('./REPOSSESSIONDATE [1]','VARCHAR(20)') END RepossessionDate  
,C.value('./RePossessedDataEntityId [1]','INT') RePossessedDataEntityId
INTO #RePossessedAccountDataUpload
FROM @XMLDocument.nodes('/DataSet/Gridrow') AS t(c)



IF @OperationFlag=1
BEGIN

	PRINT '1'
	IF EXISTS(
				Select 1 From DATAUPLOAD.RePossessedAccountDataUpload_Mod  D
						INNER JOIN #RePossessedAccountDataUpload GD 
						ON (EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey) 
							AND D.CustomerAcID = GD.CustomerAcID
						WHERE D.AuthorisationStatus in('MP','NP','DP','RM') )

	BEGIN
		PRINT 'EXISTS'
		Set @Result=-4
		SELECT DISTINCT @ErrorMsg=
								STUFF((SELECT distinct ', ' + CAST(CustomerID as varchar(max))
								 FROM #RePossessedAccountDataUpload t2
								 FOR XML PATH('')),1,1,'') 
							From DATAUPLOAD.RePossessedAccountDataUpload_Mod  D
							INNER JOIN #RePossessedAccountDataUpload GD 
								ON (EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey) 
								AND D.CustomerAcID = GD.CustomerAcID
							WHERE D.AuthorisationStatus in('MP','NP','DP','RM') 

		SET @ErrorMsg='Authorization Pending for Customer id '+CAST(@ErrorMsg AS VARCHAR(MAX))+' Please Authorize first'
		Return @Result
	END
	--ELSE 
	BEGIN	
		--SET @BusinessMatrixAlt_key = 
		 SELECT @BusinessMatrixAlt_key= MAX(BusinessMatrixAlt_key)  FROM  
										(SELECT MAX(Entitykey) BusinessMatrixAlt_key FROM DATAUPLOAD.RePossessedAccountDataUpload
										 UNION 
										 SELECT MAX(Entitykey) BusinessMatrixAlt_key FROM DATAUPLOAD.RePossessedAccountDataUpload_Mod
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
	   
	   GOTO RePossessedAccountDataUpload_Insert
	        RePossessedAccountDataUpload_Insert_Add:

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
					FROM DATAUPLOAD.RePossessedAccountDataUpload D
					INNER JOIN  #RePossessedAccountDataUpload GD	
					ON  D.CustomerAcID = GD.CustomerAcID
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
		
				PRINT @CreatedBy
				PRINT @DateCreated
				IF ISNULL(@CreatedBy,'')=''
					BEGIN
						PRINT 44
						SELECT  @CreatedBy			= CreatedBy
									,@DateCreated	= DateCreated
							FROM DATAUPLOAD.RePossessedAccountDataUpload_Mod D
							INNER JOIN  #RePossessedAccountDataUpload GD	
							ON  D.CustomerAcID			= GD.CustomerAcID
							WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
							AND    D.AuthorisationStatus IN('NP','MP','DP','RM')
	
																
					END
				ELSE ---IF DATA IS AVAILABLE IN MAIN TABLE
					BEGIN
						PRINT 'OperationFlag'
						----UPDATE FLAG IN MAIN TABLES AS MP
						UPDATE  D
						SET D.AuthorisationStatus=@AuthorisationStatus
						FROM DATAUPLOAD.RePossessedAccountDataUpload D
						INNER JOIN  #RePossessedAccountDataUpload GD 
						ON  D.CustomerAcID			= GD.CustomerAcID
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
					END
			IF @OperationFlag=2
				BEGIN	

					PRINT 'FM'	
					UPDATE  D
						SET D.AuthorisationStatus='FM'
						,D.ModifiedBy=@Modifiedby
						,D.DateModified=@DateModified
					 
					FROM DATAUPLOAD.RePossessedAccountDataUpload D
						INNER JOIN  #RePossessedAccountDataUpload GD 
							ON  D.CustomerAcID			= GD.CustomerAcID
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						and D.AuthorisationStatus IN('NP','MP','DP','RM')
				END
				GOTO RePossessedAccountDataUpload_Insert
				RePossessedAccountDataUpload_Insert_Edit_Delete:
		 END 
ELSE IF @OperationFlag =3 AND @AuthMode ='N'
		BEGIN
				
				-- DELETE WITHOUT MAKER CHECKER
						PRINT 'DELETE'					
						SET @Modifiedby   = @CrModApBy 
						SET @DateModified = GETDATE() 
						UPDATE D SET
									ModifiedBy =@Modifiedby 
									,DateModified =@DateModified 
									,EffectiveToTimeKey =@EffectiveFromTimeKey-1
								FROM DATAUPLOAD.RePossessedAccountDataUpload D
						INNER JOIN  #RePossessedAccountDataUpload GD	
							ON D.CustomerAcID			= GD.CustomerAcID
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
				FROM DATAUPLOAD.RePossessedAccountDataUpload_Mod D
						INNER JOIN  #RePossessedAccountDataUpload GD	
							ON D.CustomerAcID			= GD.CustomerAcID
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						and D.AuthorisationStatus IN('NP','MP','DP','RM')


			IF EXISTS(Select 1 From DATAUPLOAD.RePossessedAccountDataUpload D
						INNER JOIN #RePossessedAccountDataUpload GD 
						ON (EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey) 
							AND  D.CustomerAcID			= GD.CustomerAcID
							)
					BEGIN

						UPDATE D
							SET AuthorisationStatus='A'
							FROM DATAUPLOAD.RePossessedAccountDataUpload D
						INNER JOIN  #RePossessedAccountDataUpload GD	
						ON D.CustomerAcID			= GD.CustomerAcID
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
								AND D.AuthorisationStatus IN('MP','DP','RM') 	


					END


				
		END
		
ELSE IF @OperationFlag=18 AND @AuthMode='Y'
		   BEGIN
		        PRINT 'remarks'
               Set @ApprovedBy=@CrModApBy
			   Set @DateApproved=Getdate()
			  
			  					  		UPDATE D
					SET AuthorisationStatus='RM'
					,ApprovedBy	 =@ApprovedBy
					,DateApproved=@DateApproved
					
		
				FROM DATAUPLOAD.RePossessedAccountDataUpload_MOD D
						INNER JOIN  #RePossessedAccountDataUpload GD	
						ON   D.CustomerAcID			= GD.CustomerAcID
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
					             	FROM DATAUPLOAD.RePossessedAccountDataUpload  D
									INNER JOIN  #RePossessedAccountDataUpload GD	
									ON D.CustomerAcID			= GD.CustomerAcID
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

					
					
					Print 'C'
					SELECT @ExEntityKey= MAX(Entitykey) FROM DATAUPLOAD.RePossessedAccountDataUpload_MOD A
					 INNER JOIN #RePossessedAccountDataUpload C
						ON (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
						 AND A.CustomerAcID			= C.CustomerAcID
						WHERE  a.AuthorisationStatus IN('NP','MP','DP','RM')	


					PRINT @@ROWCOUNT

					SELECT	@DelStatus=a.AuthorisationStatus
							,@CreatedBy=CreatedBy
							,@DateCreated=DATECreated
							,@ModifiedBy=ModifiedBy
							, @DateModified=DateModified
					 FROM DATAUPLOAD.RePossessedAccountDataUpload_MOD A
					  INNER JOIN #RePossessedAccountDataUpload C
						ON (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey) 
						AND A.CustomerAcID			= C.CustomerAcID
						WHERE   Entitykey=@ExEntityKey
					
					SET @ApprovedBy = @CrModApBy			
					SET @DateApproved=GETDATE()

					 
				
					
					DECLARE @CurEntityKey INT=0

					SELECT @ExEntityKey= MIN(Entitykey) FROM DATAUPLOAD.RePossessedAccountDataUpload_Mod A 
					 INNER JOIN #RePossessedAccountDataUpload C
						ON (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey) 
						AND A.CustomerAcID			= C.CustomerAcID
						WHERE  a.AuthorisationStatus IN('NP','MP','DP','RM')	
				
					SELECT	@CurrRecordFromTimeKey=A.EffectiveFromTimeKey 
						 FROM DATAUPLOAD.RePossessedAccountDataUpload_Mod A
						  INNER JOIN #RePossessedAccountDataUpload C
						ON (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey) 
							AND  A.CustomerAcID			= C.CustomerAcID
							AND Entitykey=@ExEntityKey
			
					UPDATE A
					
						SET  EffectiveToTimeKey =@CurrRecordFromTimeKey-1
						FROM DATAUPLOAD.RePossessedAccountDataUpload_Mod A
						INNER JOIN #RePossessedAccountDataUpload C
						ON (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey) 
						AND A.CustomerAcID			= C.CustomerAcID
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
										FROM DATAUPLOAD.RePossessedAccountDataUpload_Mod G
										INNER JOIN #RePossessedAccountDataUpload GD 
										ON  G.CustomerAcID			= GD.CustomerAcID
										      WHERE G.AuthorisationStatus in('NP','MP','DP','RM')

										PRINT 'BE'
						                  IF EXISTS(SELECT 1 FROM DATAUPLOAD.RePossessedAccountDataUpload G
										INNER JOIN #RePossessedAccountDataUpload GD 
										ON  G.CustomerAcID			= GD.CustomerAcID
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
													FROM DATAUPLOAD.RePossessedAccountDataUpload G
													INNER JOIN #RePossessedAccountDataUpload GD 
													ON G.CustomerAcID			= GD.CustomerAcID
									               WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
											       	
										 END
									END
									ELSE 

									BEGIN
										 UPDATE G 
										 SET AuthorisationStatus ='A'
										 ,ApprovedBy=@ApprovedBy
										 ,DateApproved=@DateApproved
										 FROM DATAUPLOAD.RePossessedAccountDataUpload_Mod G
										 INNER JOIN #RePossessedAccountDataUpload GD 
											ON  G.CustomerAcID			= GD.CustomerAcID
										  WHERE G.AuthorisationStatus in('NP','MP','RM')
									END
					END

						IF ISNULL(@DelStatus,'A') <>'DP' OR @AuthMode ='N'
									BEGIN
											
											PRINT @AuthorisationStatus +'AuthorisationStatus'	
                                             PRINT @AUTHMODE +'Authmode'


											 SET  @AuthorisationStatus ='A'
												 
												 --SELECT * FROM #BusinessMatrix
												 --SELECT @EffectiveFromTimeKey, @TimeKey
                                                   DELETE G
                                                        FROM DATAUPLOAD.RePossessedAccountDataUpload G
                                                       INNER JOIN #RePossessedAccountDataUpload GD ON (G.EffectiveFromTimeKey<=@TimeKey AND G.EffectiveToTimeKey>=@TimeKey )
													    AND G.CustomerAcID			= GD.CustomerAcID
                                                       WHERE G.EffectiveFromTimeKey=@EffectiveFromTimeKey  --and ISNULL(GD.AuthorisationStatus,'A')<>'DP'
													


													print 'ROW deleted'+CAST(@@ROWCOUNT AS VARCHAR(10)) +'Deleted'
													
													
                                                    UPDATE G
                                                       SET  
													   G.EffectiveTOTimeKey=@EffectiveFromTimeKey-1
													   ,G.AuthorisationStatus ='A'  
                                                       FROM DATAUPLOAD.RePossessedAccountDataUpload G
                                                       INNER JOIN #RePossessedAccountDataUpload GD ON (G.EffectiveFromTimeKey<=@TimeKey AND G.EffectiveToTimeKey>=@TimeKey )
														AND G.CustomerAcID			= GD.CustomerAcID
												    WHERE G.EffectiveFromTimeKey<@EffectiveFromTimeKey  --and ISNULL(GD.AuthorisationStatus,'A')<>'DP'
													
													print 'ROW deleted'+CAST(@@ROWCOUNT AS VARCHAR(10))

												
												IF @AuthMode='N' 
												BEGIN
													SET @AuthorisationStatus='A'
												END

												-- SELECT @BusinessMatrixAlt_key= MAX(BusinessMatrixAlt_key)  FROM  
												--	(SELECT MAX(Entitykey) BusinessMatrixAlt_key FROM DATAUPLOAD.RePossessedAccountDataUpload
												--	 UNION 
												--	 SELECT MAX(Entitykey) BusinessMatrixAlt_key FROM DATAUPLOAD.RePossessedAccountDataUpload_Mod
												--	)A
												--SET @BusinessMatrixAlt_key = ISNULL(@BusinessMatrixAlt_key,0)


												INSERT INTO DATAUPLOAD.RePossessedAccountDataUpload
														(
														 RePossessedDataEntityId
														 ,CustomerAcID
														 ,RepossessionDate
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
													     RePossessedDataEntityId
														 ,CustomerAcID
														 ,convert(date,RepossessionDate,103)
														 ,CASE WHEN @AuthMode ='Y' THEN @AuthorisationStatus ELSE NULL END
														,@EffectiveFromTimeKey
														,@EffectiveToTimeKey
														,@CreatedBy
														,@DateCreated
														,@ModifiedBy
														,@DateModified
														,CASE WHEN @AuthMode ='Y' THEN @ApprovedBy ELSE NULL END
														,CASE WHEN @AuthMode ='Y' THEN @DateApproved ELSE NULL END
														FROM #RePossessedAccountDataUpload S

									
										END


	IF @AUTHMODE='N'
			BEGIN
					SET @AuthorisationStatus='A'
					GOTO RePossessedAccountDataUpload_Insert
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


RePossessedAccountDataUpload_Insert:
PRINT 'A'
--SELECT  @ErrorHandle
IF @ErrorHandle=0
								
  	BEGIN
								Print 'Insert into DATAUPLOAD.RePossessedAccountDataUpload_Mod'

									PRINT '@ErrorHandle'
									INSERT INTO DATAUPLOAD.RePossessedAccountDataUpload_Mod
									(
									 RePossessedDataEntityId
									 ,CustomerAcID
									 ,RepossessionDate
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
											 @BusinessMatrixAlt_key+ROW_NUMBER()OVER(ORDER BY (SELECT 1))
											,CustomerAcID
									        ,convert(date,RepossessionDate,103)
									        ,CASE WHEN @AuthMode ='Y' THEN @AuthorisationStatus ELSE NULL END
											,@EffectiveFromTimeKey
											,@EffectiveToTimeKey
											,@CreatedBy
											,@DateCreated
											,@ModifiedBy
											,@DateModified
											,CASE WHEN @AuthMode ='Y' THEN @ApprovedBy ELSE NULL END
											,CASE WHEN @AuthMode ='Y' THEN @DateApproved ELSE NULL END
											FROM #RePossessedAccountDataUpload S
											--WHERE Amount<>0

								PRINT CAST(@@ROWCOUNT AS VARCHAR)+'INSERTED'
								

				IF @OperationFlag =1 AND @AUTHMODE='Y'
					BEGIN
						PRINT 3
						GOTO RePossessedAccountDataUpload_Insert_Add
					END
				ELSE
				 IF (@OperationFlag =2 OR @OperationFlag =3) AND @AUTHMODE='Y'
					BEGIN
						GOTO RePossessedAccountDataUpload_Insert_Edit_Delete
					END

	END			
	
 COMMIT TRANSACTION
 IF @OperationFlag <>3
 BEGIN
	
		SELECT @D2Ktimestamp=CAST(D2Ktimestamp AS INT) FROM DATAUPLOAD.RePossessedAccountDataUpload_Mod D
							--INNER JOIN #BusinessMatrix T	ON	D.BusinessMatrixAlt_key = T.BusinessMatrixAlt_key
							WHERE (EffectiveFromTimeKey<=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) 
							
			
		UPDATE A SET CustomerID=B.RefCustomerID 		FROM  DATAUPLOAD.RePossessedAccountDataUpload A 		INNER JOIN PRO.ACCOUNTCAL B ON A.CUSTOMERACID=B.CUSTOMERACID  WHERE A.CustomerID IS NULL
		UPDATE A  SET CustomerID=B.RefCustomerID 		FROM  DATAUPLOAD.RePossessedAccountDataUpload_MOD A 		INNER JOIN PRO.ACCOUNTCAL B ON A.CUSTOMERACID=B.CUSTOMERACID WHERE A.CustomerID IS NULL
		UPDATE A SET CustomerName=B.CustomerName 		FROM  DATAUPLOAD.RePossessedAccountDataUpload A 		INNER JOIN PRO.customercal B ON A.CustomerID=B.RefCustomerID WHERE A.CUSTOMERNAME IS NULL
		UPDATE A SET CustomerName=B.CustomerName 		FROM  DATAUPLOAD.RePossessedAccountDataUpload_MOD A 		INNER JOIN PRO.customercal B ON A.CustomerID=B.RefCustomerID	 WHERE A.CUSTOMERNAME IS NULL		
										
		


		
	
	
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
		

		

	

			END  CATCH
SET @RESULT=-1
		RETURN @RESULT
	


END						            



GO