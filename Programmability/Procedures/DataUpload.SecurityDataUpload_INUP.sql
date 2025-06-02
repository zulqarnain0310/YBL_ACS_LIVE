SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/*===================================================
AUTHER : SANJEEV KUMAR SHARMA
CREATE DATE :21-12-2018
MODIFY DATE :21-12-2018
DESCRIPTION : DATA UPLOAD FOR SECURITY DATA IN ACCOUNT 
=====================================================*/
CREATE PROCEDURE [DataUpload].[SecurityDataUpload_INUP]
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

IF OBJECT_ID('TEMPDB..#SecurityDataUpload') IS NOT NULL
        DROP TABLE #SecurityDataUpload

SELECT 
 C.value('./UCICID [1]','VARCHAR(30)') UCIF_ID
,C.value('./CUSTOMERID [1]','VARCHAR(30)')CUSTOMERID    
,C.value('./REFCUSTOMERID [1]','VARCHAR(30)')REFCUSTOMERID
,C.value('./SECURITYCODE [1]','VARCHAR(30)') SecurityCode
,C.value('./SECURITYDESCRIPTION [1]','VARCHAR(250)') SecurityDescription
,C.value('./SECURITYNAME [1]','VARCHAR(100)') SecurityName
,CASE WHEN C.value('./CUSTOMERACID [1]','VARCHAR(30)')='' THEN NULL ELSE C.value('./CUSTOMERACID [1]','VARCHAR(30)') END CustomerAcID
,C.value('./SECURITYTYPE [1]','VARCHAR(30)') SecurityType  
,CASE WHEN C.value('./CURRENTVALUE [1]','VARCHAR(20)')='' THEN NULL ELSE C.value('./CURRENTVALUE [1]','Decimal(18,2)') END CurrentValue  
,CASE WHEN C.value('./VALUATIONDATE [1]','VARCHAR(20)')='' THEN NULL ELSE C.value('./VALUATIONDATE [1]','VARCHAR(20)') END ValuationDt   
,C.value('./SecurityDataEntityId [1]','INT') SecurityDataEntityId
,CASE WHEN C.value('./EFFECTIVENPADATE [1]','VARCHAR(20)')='' THEN NULL ELSE C.value('./EFFECTIVENPADATE [1]','VARCHAR(20)') END EffectiveNPADate   
INTO #SecurityDataUpload
FROM @XMLDocument.nodes('/DataSet/Gridrow') AS t(c)


IF @OperationFlag=1
BEGIN

	PRINT '1'
	IF EXISTS(
			Select 1 From DATAUPLOAD.SecurityDataUpload_Mod  D
						INNER JOIN #SecurityDataUpload GD 
						ON (EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey) 
							AND D.CustomerAcID = GD.CustomerAcID
						WHERE D.AuthorisationStatus in('MP','NP','DP','RM') )

	BEGIN
		PRINT 'EXISTS'
		Set @Result=-4
		SELECT DISTINCT @ErrorMsg=
								STUFF((SELECT distinct ', ' + CAST(CustomerID as varchar(max))
								 FROM #SecurityDataUpload t2
								 FOR XML PATH('')),1,1,'') 
							From DATAUPLOAD.SecurityDataUpload_Mod  D
							INNER JOIN #SecurityDataUpload GD 
								ON (EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey) 
								AND D.CustomerID = GD.CustomerID
							WHERE D.AuthorisationStatus in('MP','NP','DP','RM') 

		SET @ErrorMsg='Authorization Pending for Customer id '+CAST(@ErrorMsg AS VARCHAR(MAX))+' Please Authorize first'
		Return @Result
	END
	ELSE 
	BEGIN	
		--SET @BusinessMatrixAlt_key = 
		 SELECT @BusinessMatrixAlt_key= MAX(BusinessMatrixAlt_key)  FROM  
										(SELECT MAX(Entitykey) BusinessMatrixAlt_key FROM DATAUPLOAD.SecurityDataUpload
										 UNION 
										 SELECT MAX(Entitykey) BusinessMatrixAlt_key FROM DATAUPLOAD.SecurityDataUpload_Mod
										)A
		SET @BusinessMatrixAlt_key = ISNULL(@BusinessMatrixAlt_key,0)
	END
END

BEGIN TRY


BEGIN TRAN


/*     
			FOR VERTICAL BALANCESHEET INSERT UPDATE THIS SCENERIO IS NOT REQUIRED
*/

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
					FROM DATAUPLOAD.SecurityDataUpload D
					INNER JOIN  #SecurityDataUpload GD	
					ON  D.CustomerAcID = GD.CustomerAcID
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
		
				PRINT @CreatedBy
				PRINT @DateCreated
				IF ISNULL(@CreatedBy,'')=''
					BEGIN
						PRINT 44
						SELECT  @CreatedBy			= CreatedBy
									,@DateCreated	= DateCreated
							FROM DATAUPLOAD.SecurityDataUpload_Mod D
							INNER JOIN  #SecurityDataUpload GD	
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
						FROM DATAUPLOAD.SecurityDataUpload D
						INNER JOIN  #SecurityDataUpload GD 
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
					 
					FROM DATAUPLOAD.SecurityDataUpload D
						INNER JOIN  #SecurityDataUpload GD 
							ON  D.CustomerAcID			= GD.CustomerAcID
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
								FROM DATAUPLOAD.SecurityDataUpload D
						INNER JOIN  #SecurityDataUpload GD	
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
				FROM DATAUPLOAD.SecurityDataUpload_Mod D
						INNER JOIN  #SecurityDataUpload GD	
							ON D.CustomerAcID			= GD.CustomerAcID
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						and D.AuthorisationStatus IN('NP','MP','DP','RM')


			IF EXISTS(Select 1 From DATAUPLOAD.SecurityDataUpload D
						INNER JOIN #SecurityDataUpload GD 
						ON (EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey) 
							AND  D.CustomerAcID			= GD.CustomerAcID
							)
					BEGIN

						UPDATE D
							SET AuthorisationStatus='A'
							FROM DATAUPLOAD.SecurityDataUpload D
						INNER JOIN  #SecurityDataUpload GD	
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
			   --SET @FactTargetEntityId=(select FactTargetEntityId from #FactTarget)
			   
			   --select @GroupAlt_Key
					  		UPDATE D
					SET AuthorisationStatus='RM'
					,ApprovedBy	 =@ApprovedBy
					,DateApproved=@DateApproved
					
		
				FROM DATAUPLOAD.SecurityDataUpload_MOD D
						INNER JOIN  #SecurityDataUpload GD	
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
					             	FROM DATAUPLOAD.SecurityDataUpload  D
									INNER JOIN  #SecurityDataUpload GD	
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

					
					--SELECT  * FROM ##DimBSCodeStructure
					Print 'C'
					SELECT @ExEntityKey= MAX(Entitykey) FROM DATAUPLOAD.SecurityDataUpload_MOD A
					 INNER JOIN #SecurityDataUpload C
						ON (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
						 AND A.CustomerAcID			= C.CustomerAcID
						WHERE  a.AuthorisationStatus IN('NP','MP','DP','RM')	


					PRINT @@ROWCOUNT

					SELECT	@DelStatus=a.AuthorisationStatus
							,@CreatedBy=CreatedBy
							,@DateCreated=DATECreated
							,@ModifiedBy=ModifiedBy
							, @DateModified=DateModified
					 FROM DATAUPLOAD.SecurityDataUpload_MOD A
					  INNER JOIN #SecurityDataUpload C
						ON (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey) 
						AND A.CustomerAcID			= C.CustomerAcID
						WHERE   Entitykey=@ExEntityKey
					
					SET @ApprovedBy = @CrModApBy			
					SET @DateApproved=GETDATE()

					 
				
					
					DECLARE @CurEntityKey INT=0

					SELECT @ExEntityKey= MIN(Entitykey) FROM DATAUPLOAD.SecurityDataUpload_Mod A 
					 INNER JOIN #SecurityDataUpload C
						ON (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey) 
						AND A.CustomerAcID			= C.CustomerAcID
						WHERE  a.AuthorisationStatus IN('NP','MP','DP','RM')	
				
					SELECT	@CurrRecordFromTimeKey=A.EffectiveFromTimeKey 
						 FROM DATAUPLOAD.SecurityDataUpload_Mod A
						  INNER JOIN #SecurityDataUpload C
						ON (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey) 
							AND  A.CustomerAcID			= C.CustomerAcID
							AND Entitykey=@ExEntityKey
			
					UPDATE A
					
						SET  EffectiveToTimeKey =@CurrRecordFromTimeKey-1
						FROM DATAUPLOAD.SecurityDataUpload_Mod A
						INNER JOIN #SecurityDataUpload C
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
										FROM DATAUPLOAD.SecurityDataUpload_Mod G
										INNER JOIN #SecurityDataUpload GD 
										ON  G.CustomerAcID			= GD.CustomerAcID
										--AND G.CounterPart_BranchCode	= GD.CounterPart_BranchCode
						                 WHERE G.AuthorisationStatus in('NP','MP','DP','RM')

										PRINT 'BE'
						                  IF EXISTS(SELECT 1 FROM DATAUPLOAD.SecurityDataUpload G
										INNER JOIN #SecurityDataUpload GD 
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
													FROM DATAUPLOAD.SecurityDataUpload G
													INNER JOIN #SecurityDataUpload GD 
													ON G.CustomerAcID			= GD.CustomerAcID
									               WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
											       	
										 END
									END
									ELSE 

									BEGIN
										print 'mod table np to a'
										 UPDATE G 
										 SET AuthorisationStatus ='A'
										 ,ApprovedBy=@ApprovedBy
										 ,DateApproved=@DateApproved
										 FROM DATAUPLOAD.SecurityDataUpload_Mod G
										 INNER JOIN #SecurityDataUpload GD 
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
                                                        FROM DATAUPLOAD.SecurityDataUpload G
                                                       INNER JOIN #SecurityDataUpload GD ON (G.EffectiveFromTimeKey<=@TimeKey AND G.EffectiveToTimeKey>=@TimeKey )
													    AND G.CustomerAcID			= GD.CustomerAcID
                                                       WHERE G.EffectiveFromTimeKey=@EffectiveFromTimeKey  --and ISNULL(GD.AuthorisationStatus,'A')<>'DP'
													


													print 'ROW deleted'+CAST(@@ROWCOUNT AS VARCHAR(10)) +'Deleted'
													
													
                                                    UPDATE G
                                                       SET  
													   G.EffectiveTOTimeKey=@EffectiveFromTimeKey-1
													   ,G.AuthorisationStatus ='A'  --ADDED ON 12 FEB 2018
                                                       FROM DATAUPLOAD.SecurityDataUpload G
                                                       INNER JOIN #SecurityDataUpload GD ON (G.EffectiveFromTimeKey<=@TimeKey AND G.EffectiveToTimeKey>=@TimeKey )
														AND G.CustomerAcID			= GD.CustomerAcID
														--AND G.CounterPart_BranchCode	= GD.CounterPart_BranchCode
                                                       WHERE G.EffectiveFromTimeKey<@EffectiveFromTimeKey  --and ISNULL(GD.AuthorisationStatus,'A')<>'DP'
													
													print 'ROW deleted'+CAST(@@ROWCOUNT AS VARCHAR(10))

												
												IF @AuthMode='N' 
												BEGIN
													SET @AuthorisationStatus='A'
												END

												-- SELECT @BusinessMatrixAlt_key= MAX(BusinessMatrixAlt_key)  FROM  
												--	(SELECT MAX(Entitykey) BusinessMatrixAlt_key FROM DATAUPLOAD.SecurityDataUpload
												--	 UNION 
												--	 SELECT MAX(Entitykey) BusinessMatrixAlt_key FROM DATAUPLOAD.SecurityDataUpload_Mod
												--	)A
												--SET @BusinessMatrixAlt_key = ISNULL(@BusinessMatrixAlt_key,0)


												INSERT INTO DATAUPLOAD.SecurityDataUpload
														(
														SecurityDataEntityId
														,UCIF_ID
														,CUSTOMERID
														,SourceSystemCustomerID
														,CustomerAcID
														,SecurityCode
														,SecurityDescription
														,SecurityName
														,SecurityType
														,CurrentValue
														,ValuationDt
														,AuthorisationStatus
														,EffectiveFromTimeKey
														,EffectiveToTimeKey
														,CreatedBy
														,DateCreated
														,ModifiedBy
														,DateModified
														,ApprovedBy
														,DateApproved
														,EffectiveNPADate
														)
													SELECT
														SecurityDataEntityId
													    ,UCIF_ID
														,CUSTOMERID
														,REFCUSTOMERID
														,CustomerAcID
														,SecurityCode
														,SecurityDescription
														,SecurityName
														,SecurityType
														,CurrentValue
														,convert(date,ValuationDt,103)
														,CASE WHEN @AuthMode ='Y' THEN @AuthorisationStatus ELSE NULL END
														,@EffectiveFromTimeKey
														,@EffectiveToTimeKey
														,@CreatedBy
														,@DateCreated
														,@ModifiedBy
														,@DateModified
														,CASE WHEN @AuthMode ='Y' THEN @ApprovedBy ELSE NULL END
														,CASE WHEN @AuthMode ='Y' THEN @DateApproved ELSE NULL END
														,convert(date,EffectiveNPADate,103)
														FROM #SecurityDataUpload S

									
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
								Print 'INSERT INTO DATAUPLOAD.SecurityDataUpload_Mod'

									PRINT '@ErrorHandle'
									INSERT INTO DATAUPLOAD.SecurityDataUpload_Mod
									(
									SecurityDataEntityId
									,UCIF_ID
									,CUSTOMERID
									,SourceSystemCustomerID
									,CustomerAcID
									,SecurityCode
									,SecurityDescription
									,SecurityName
									,SecurityType
									,CurrentValue
									,ValuationDt
									,AuthorisationStatus
									,EffectiveFromTimeKey
									,EffectiveToTimeKey
									,CreatedBy
									,DateCreated
									,ModifiedBy
									,DateModified
									,ApprovedBy
									,DateApproved
									,EffectiveNPADate
										)
										SELECT
											@BusinessMatrixAlt_key+ROW_NUMBER()OVER(ORDER BY (SELECT 1))
											,UCIF_ID
											,CUSTOMERID
											,REFCUSTOMERID
											,CustomerAcID
											,SecurityCode
											,SecurityDescription
											,SecurityName
											,SecurityType
											,CurrentValue
											,convert(date,ValuationDt,103)
											,CASE WHEN @AuthMode ='Y' THEN @AuthorisationStatus ELSE NULL END
											,@EffectiveFromTimeKey
											,@EffectiveToTimeKey
											,@CreatedBy
											,@DateCreated
											,@ModifiedBy
											,@DateModified
											,CASE WHEN @AuthMode ='Y' THEN @ApprovedBy ELSE NULL END
											,CASE WHEN @AuthMode ='Y' THEN @DateApproved ELSE NULL END
											,convert(date,EffectiveNPADate,103)
											FROM #SecurityDataUpload S
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
	
		SELECT @D2Ktimestamp=CAST(D2Ktimestamp AS INT) FROM DATAUPLOAD.SecurityDataUpload_Mod D
											WHERE (EffectiveFromTimeKey<=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) 
							
			
		UPDATE A SET CustomerName=B.CustomerName 		FROM  DATAUPLOAD.SecurityDataUpload A 		INNER JOIN PRO.customercal B ON A.CustomerID=B.RefCustomerID WHERE A.CUSTOMERNAME IS NULL
		UPDATE A SET CustomerName=B.CustomerName		FROM  DATAUPLOAD.SecurityDataUpload_Mod A 		INNER JOIN PRO.customercal B ON A.CustomerID=B.RefCustomerID WHERE A.CUSTOMERNAME IS NULL 											
		UPDATE A SET UCIF_ID=B.UCIF_ID 		            FROM  DATAUPLOAD.SecurityDataUpload A 		INNER JOIN PRO.customercal B ON A.CustomerID=B.RefCustomerID		where A.UCIF_ID IS NULL
		UPDATE A SET UCIF_ID=B.UCIF_ID		            FROM  DATAUPLOAD.SecurityDataUpload_Mod A 		INNER JOIN PRO.customercal B ON A.CustomerID=B.RefCustomerID	where A.UCIF_ID IS NULL					
		UPDATE A SET CustomerName=B.CustomerName 		FROM  DATAUPLOAD.SecurityDataUpload A 		INNER JOIN PRO.customercal B ON A.CustomerID=B.RefCustomerID WHERE A.CUSTOMERNAME =''
		UPDATE A SET CustomerName=B.CustomerName		FROM  DATAUPLOAD.SecurityDataUpload_Mod A 		INNER JOIN PRO.customercal B ON A.CustomerID=B.RefCustomerID WHERE A.CUSTOMERNAME =''											
		UPDATE A SET UCIF_ID=B.UCIF_ID 		            FROM  DATAUPLOAD.SecurityDataUpload A 		INNER JOIN PRO.customercal B ON A.CustomerID=B.RefCustomerID		where A.UCIF_ID =''
		UPDATE A SET UCIF_ID=B.UCIF_ID		            FROM  DATAUPLOAD.SecurityDataUpload_Mod A 		INNER JOIN PRO.customercal B ON A.CustomerID=B.RefCustomerID	where A.UCIF_ID =''				
		UPDATE DATAUPLOAD.SECURITYDATAUPLOAD SET VALUATIONDT=NULL WHERE VALUATIONDT='1900-01-01'
        UPDATE DATAUPLOAD.SECURITYDATAUPLOAD_MOD SET VALUATIONDT=NULL WHERE VALUATIONDT='1900-01-01'		
		UPDATE DATAUPLOAD.SECURITYDATAUPLOAD SET EffectiveNPADate=NULL WHERE EffectiveNPADate='1900-01-01'
        UPDATE DATAUPLOAD.SECURITYDATAUPLOAD_MOD SET EffectiveNPADate=NULL WHERE EffectiveNPADate='1900-01-01'		
	
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