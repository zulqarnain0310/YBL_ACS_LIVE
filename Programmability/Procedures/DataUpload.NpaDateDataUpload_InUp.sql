SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/*===================================================
AUTHER : SANJEEV KUMAR SHARMA
CREATE DATE :21-12-2018
MODIFY DATE :21-12-2018
DESCRIPTION : DATA UPLOAD FOR NpaDate
=====================================================*/
Create PROCEDURE [DataUpload].[NpaDateDataUpload_InUp]
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
		@NpaDateDataEntityId	INT
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


IF OBJECT_ID('TEMPDB..#NpaDateDATAUPLOAD') IS NOT NULL
        DROP TABLE #NpaDateDATAUPLOAD

SELECT 
 C.value('./UCIFID[1]','VARCHAR(30)') UCIF_ID
,CASE WHEN C.value('./NPADATE [1]','VARCHAR(20)')='' THEN NULL ELSE C.value('./NPADATE [1]','VARCHAR(20)') END   NPADate     
,C.value('./NPADATECHANGEREASON[1]','VARCHAR(500)') NPADATECHANGEREASON
,C.value('./NpaDateDataEntityId [1]','INT') NpaDateDataEntityId 
INTO #NpaDateDATAUPLOAD
FROM @XMLDocument.nodes('/DataSet/Gridrow') AS t(c)

--select * from #NpaDateDATAUPLOAD
--return

IF @OperationFlag=1
BEGIN
	PRINT '1'
	IF EXISTS(
			Select 1 From DATAUPLOAD.NpaDateDataUpload_Mod  D
						INNER JOIN #NpaDateDATAUPLOAD GD 
						ON (EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey) 
							AND D.UCIF_ID = GD.UCIF_ID
						WHERE D.AuthorisationStatus in('MP','NP','DP','RM') )

	BEGIN
		PRINT 'EXISTS'
		Set @Result=-4
		SELECT DISTINCT @ErrorMsg=
								STUFF((SELECT distinct ', ' + CAST(UCIF_ID as varchar(max))
								 FROM #NpaDateDATAUPLOAD t2
								 FOR XML PATH('')),1,1,'') 
							From DATAUPLOAD.NpaDateDataUpload_Mod  D
							INNER JOIN #NpaDateDATAUPLOAD GD 
								ON (EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey) 
								AND D.UCIF_ID = GD.UCIF_ID
							WHERE D.AuthorisationStatus in('MP','NP','DP','RM') 

		SET @ErrorMsg='Authorization Pending for UCIF_ID id '+CAST(@ErrorMsg AS VARCHAR(MAX))+' Please Authorize first'
		Return @Result
	END
	--ELSE 
	BEGIN	
		--SET @NpaDateDataEntityId = 
		 SELECT @NpaDateDataEntityId= MAX(NpaDateDataEntityId)  FROM  
										(SELECT MAX(Entitykey) NpaDateDataEntityId FROM DATAUPLOAD.NpaDateDataUpload
										 UNION 
										 SELECT MAX(Entitykey) NpaDateDataEntityId FROM DATAUPLOAD.NpaDateDataUpload_Mod
										)A
		SET @NpaDateDataEntityId = ISNULL(@NpaDateDataEntityId,0)
		--SELECT @NpaDateDataEntityId
	END
END

BEGIN TRY


BEGIN TRAN


Declare @AuthLevel int,@ApprovedByFirstLevel VARCHAR(50),@DateApprovedFirstLevel DATETIME

					SELECT @AuthLevel=ISNULL(AuthLevel,1) FROM SysCRisMacMenu WHERE MenuId=@MenuId
			


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
					FROM DATAUPLOAD.NpaDateDataUpload D
					INNER JOIN  #NpaDateDATAUPLOAD GD	
					ON  D.UCIF_ID = GD.UCIF_ID
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
		
				PRINT @CreatedBy
				PRINT @DateCreated
				IF ISNULL(@CreatedBy,'')=''
					BEGIN
						PRINT 44
						SELECT  @CreatedBy			= CreatedBy
									,@DateCreated	= DateCreated
							FROM DATAUPLOAD.NpaDateDataUpload_Mod D
							INNER JOIN  #NpaDateDATAUPLOAD GD	
							ON  D.UCIF_ID			= GD.UCIF_ID
							WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
							AND    D.AuthorisationStatus IN('NP','MP','DP','RM')
	
																
					END
				ELSE ---IF DATA IS AVAILABLE IN MAIN TABLE
					BEGIN
						PRINT 'OperationFlag'
						----UPDATE FLAG IN MAIN TABLES AS MP
						UPDATE  D
						SET D.AuthorisationStatus=@AuthorisationStatus
						FROM DATAUPLOAD.NpaDateDataUpload D
						INNER JOIN  #NpaDateDATAUPLOAD GD 
						ON  D.UCIF_ID			= GD.UCIF_ID
						AND D.NpaDateDataEntityId=GD.NpaDateDataEntityId
						AND D.NPADATECHANGEREASON=GD.NPADATECHANGEREASON
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
					END
			IF @OperationFlag=2
				BEGIN	
					PRINT 'FM'	
					UPDATE  D
						SET D.AuthorisationStatus='FM'
						,D.ModifiedBy=@Modifiedby
						,D.DateModified=@DateModified
					 
					FROM DATAUPLOAD.NpaDateDataUpload_Mod D
						INNER JOIN  #NpaDateDATAUPLOAD GD 
							ON  D.UCIF_ID			= GD.UCIF_ID
							AND D.NpaDateDataEntityId=GD.NpaDateDataEntityId
							AND D.NPADATECHANGEREASON=GD.NPADATECHANGEREASON
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
								FROM DATAUPLOAD.NpaDateDataUpload D
						INNER JOIN  #NpaDateDATAUPLOAD GD	
							ON D.UCIF_ID			= GD.UCIF_ID
							AND D.NpaDateDataEntityId=GD.NpaDateDataEntityId
							AND D.NPADATECHANGEREASON=GD.NPADATECHANGEREASON
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)

						PRINT CAST(@@ROWCOUNT as VARCHAR(2))+SPACE(1)+'ROW DELETED'

				SET @RESULT=@NpaDateDataEntityId

		END

ELSE IF @OperationFlag=17 AND @AuthMode ='Y' 
		BEGIN
				Print 'REJECT'
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE D
					SET AuthorisationStatus='R'
					--,ApprovedByFirstLevel	 =@ApprovedBy
					,ApprovedBy=@ApprovedBy---------------------Added on 06May By Tarkeshwar Singh instead of above commented line
					--,DateApprovedFirstLevel=@DateApproved
					,DateApproved=@DateApproved---------------------Added on 06May By Tarkeshwar Singh instead of above commented line
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
				FROM DATAUPLOAD.NpaDateDataUpload_Mod D
						INNER JOIN  #NpaDateDATAUPLOAD GD	
							ON D.UCIF_ID			= GD.UCIF_ID
							AND D.NpaDateDataEntityId=GD.NpaDateDataEntityId
							AND D.NPADATECHANGEREASON=GD.NPADATECHANGEREASON
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						and D.AuthorisationStatus IN('NP','MP','DP','RM')


			IF EXISTS(Select 1 From DATAUPLOAD.NpaDateDataUpload D
						INNER JOIN #NpaDateDATAUPLOAD GD 
						ON (EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey) 
							AND  D.UCIF_ID			= GD.UCIF_ID
							AND D.NpaDateDataEntityId=GD.NpaDateDataEntityId
							AND D.NPADATECHANGEREASON=GD.NPADATECHANGEREASON
							)
					BEGIN

						UPDATE D
							SET AuthorisationStatus='A'
							FROM DATAUPLOAD.NpaDateDataUpload D
						INNER JOIN  #NpaDateDATAUPLOAD GD	
						ON D.UCIF_ID			= GD.UCIF_ID
						AND D.NpaDateDataEntityId=GD.NpaDateDataEntityId
						AND D.NPADATECHANGEREASON=GD.NPADATECHANGEREASON
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
								AND D.AuthorisationStatus IN('MP','DP','RM') 	


					END


				
		END


ELSE IF  @OperationFlag=21 AND @AuthMode ='Y' AND @AuthLevel=2
		BEGIN
				Print 'REJECT'
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE D
					SET AuthorisationStatus='R'
					,ApprovedBy	 =@ApprovedBy
					,DateApproved=@DateApproved
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
				FROM DATAUPLOAD.NpaDateDataUpload_Mod D
						INNER JOIN  #NpaDateDATAUPLOAD GD	
							ON D.UCIF_ID			= GD.UCIF_ID
							AND D.NpaDateDataEntityId=GD.NpaDateDataEntityId
							AND D.NPADATECHANGEREASON=GD.NPADATECHANGEREASON
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						and D.AuthorisationStatus IN('NP','MP','DP','RM','1A','1D')


			IF EXISTS(Select 1 From DATAUPLOAD.NpaDateDataUpload D
						INNER JOIN #NpaDateDATAUPLOAD GD 
						ON (EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey) 
							AND  D.UCIF_ID			= GD.UCIF_ID
							AND D.NpaDateDataEntityId=GD.NpaDateDataEntityId
							AND D.NPADATECHANGEREASON=GD.NPADATECHANGEREASON
							)
					BEGIN

						UPDATE D
							SET AuthorisationStatus='A'
							FROM DATAUPLOAD.NpaDateDataUpload D
						INNER JOIN  #NpaDateDATAUPLOAD GD	
						ON D.UCIF_ID			= GD.UCIF_ID
						AND D.NpaDateDataEntityId=GD.NpaDateDataEntityId
						AND D.NPADATECHANGEREASON=GD.NPADATECHANGEREASON
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
								AND D.AuthorisationStatus IN('MP','DP','RM','1D') 	


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
				FROM DATAUPLOAD.NpaDateDataUpload_Mod D
						INNER JOIN  #NpaDateDATAUPLOAD GD	
						ON   D.UCIF_ID			= GD.UCIF_ID
						AND D.NpaDateDataEntityId=GD.NpaDateDataEntityId
						AND D.NPADATECHANGEREASON=GD.NPADATECHANGEREASON
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						and D.AuthorisationStatus IN('NP','MP','DP')
		   END




ELSE IF @OperationFlag=16 AND @AuthMode ='Y' AND @AuthLevel=2
		BEGIN
				Print 'First level Approve '
				PRINT 'TRILOKI'
				
				SET @ApprovedByFirstLevel		= @CrModApBy 
				SET @DateApprovedFirstLevel	= GETDATE()
				--SET @ApprovedBy	   = @CrModApBy 
				--SET @DateApproved  = GETDATE()
				
			

				DECLARE @DelStatus1 CHAR(2)
				DECLARE @CurrRecordFromTimeKey1 smallint=0

					
				--SELECT  * FROM ##DimBSCodeStructure
				Print 'C'
				SELECT @ExEntityKey= MAX(Entitykey) FROM DATAUPLOAD.NpaDateDataUpload_Mod D
						INNER JOIN  #NpaDateDATAUPLOAD GD	
							ON D.UCIF_ID			= GD.UCIF_ID
							AND D.NpaDateDataEntityId=GD.NpaDateDataEntityId	
							AND D.NPADATECHANGEREASON=GD.NPADATECHANGEREASON
							WHERE (D.EffectiveFromTimeKey<=@Timekey and d.EffectiveToTimeKey>=@Timekey) 
							AND D.AuthorisationStatus IN('NP','MP','DP','RM')	

				SELECT	@DelStatus1=d.AuthorisationStatus
							,@CreatedBy=CreatedBy
							,@DateCreated=DATECreated
							,@ModifiedBy=ModifiedBy
							, @DateModified=DateModified
					 FROM DATAUPLOAD.NpaDateDataUpload_Mod D
						INNER JOIN  #NpaDateDATAUPLOAD GD	
							ON D.UCIF_ID			= GD.UCIF_ID
							AND D.NpaDateDataEntityId=GD.NpaDateDataEntityId
							AND D.NPADATECHANGEREASON=GD.NPADATECHANGEREASON
						WHERE(D.EffectiveFromTimeKey<=@Timekey and d.EffectiveToTimeKey>=@Timekey)    
						AND Entitykey=@ExEntityKey
					

			IF @DelStatus1='DP'
				BEGIN 
					UPDATE D
					SET AuthorisationStatus='1D'
					,ApprovedByFirstLevel	 =@ApprovedBy
					,DateApprovedFirstLevel=@DateApproved					
				FROM DATAUPLOAD.NpaDateDataUpload_Mod D
						INNER JOIN  #NpaDateDATAUPLOAD GD	
							ON D.UCIF_ID			= GD.UCIF_ID
							AND D.NpaDateDataEntityId=GD.NpaDateDataEntityId
							AND D.NPADATECHANGEREASON=GD.NPADATECHANGEREASON
						WHERE(D.EffectiveFromTimeKey<=@Timekey and d.EffectiveToTimeKey>=@Timekey)    
					
						and D.AuthorisationStatus IN('NP','MP','DP','RM')
					
				END 

				ELSE
				BEGIN 
				PRINT 'update in mode table for fist level authentication'
					
					UPDATE D
					SET AuthorisationStatus='1A'
					,ApprovedByFirstLevel	 =@ApprovedByFirstLevel
					,DateApprovedFirstLevel=@DateApprovedFirstLevel					
				FROM DATAUPLOAD.NpaDateDataUpload_Mod D
						INNER JOIN  #NpaDateDATAUPLOAD GD	
							ON D.UCIF_ID			= GD.UCIF_ID
							AND D.NpaDateDataEntityId=GD.NpaDateDataEntityId
							AND D.NPADATECHANGEREASON=GD.NPADATECHANGEREASON
						WHERE(D.EffectiveFromTimeKey<=@Timekey and d.EffectiveToTimeKey>=@Timekey)    					
						and D.AuthorisationStatus IN('NP','MP','DP','RM')
					
				END 
							
		END

 ELSE IF ((@OperationFlag=20 AND @AuthLevel=2)OR(@OperationFlag=16 AND @AuthLevel=1) OR @AuthMode='N')
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
					             	FROM DATAUPLOAD.NpaDateDataUpload  D
									INNER JOIN  #NpaDateDATAUPLOAD GD	
									ON D.UCIF_ID			= GD.UCIF_ID
									AND D.NpaDateDataEntityId=GD.NpaDateDataEntityId
									AND D.NPADATECHANGEREASON=GD.NPADATECHANGEREASON
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
					SELECT @ExEntityKey= MAX(Entitykey) FROM DATAUPLOAD.NpaDateDataUpload_Mod A
					 INNER JOIN #NpaDateDATAUPLOAD C
						ON (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
						 AND A.UCIF_ID			= C.UCIF_ID
						 AND A.NpaDateDataEntityId=C.NpaDateDataEntityId
						 AND A.NPADATECHANGEREASON=C.NPADATECHANGEREASON
						WHERE  a.AuthorisationStatus IN('NP','MP','DP','RM','1A','1D')	


					PRINT @@ROWCOUNT

					SELECT	@DelStatus=a.AuthorisationStatus
							,@CreatedBy=CreatedBy
							,@DateCreated=DATECreated
							,@ModifiedBy=ModifiedBy
							, @DateModified=DateModified
					 FROM DATAUPLOAD.NpaDateDataUpload_Mod A
					  INNER JOIN #NpaDateDATAUPLOAD C
						ON (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey) 
						AND A.UCIF_ID			= C.UCIF_ID
						AND A.NpaDateDataEntityId=C.NpaDateDataEntityId
						AND A.NPADATECHANGEREASON=C.NPADATECHANGEREASON
						WHERE   Entitykey=@ExEntityKey
					
					SET @ApprovedBy = @CrModApBy			
					SET @DateApproved=GETDATE()

					 
				
					
					DECLARE @CurEntityKey INT=0

					SELECT @ExEntityKey= MIN(Entitykey) FROM DATAUPLOAD.NpaDateDataUpload_Mod A 
					 INNER JOIN #NpaDateDATAUPLOAD C
						ON (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey) 
						AND A.UCIF_ID			= C.UCIF_ID
						AND A.NpaDateDataEntityId=C.NpaDateDataEntityId
						AND A.NPADATECHANGEREASON=C.NPADATECHANGEREASON
						WHERE  a.AuthorisationStatus IN('NP','MP','DP','RM','1A','1D')	
				
					SELECT	@CurrRecordFromTimeKey=A.EffectiveFromTimeKey 
						 FROM DATAUPLOAD.NpaDateDataUpload_Mod A
						  INNER JOIN #NpaDateDATAUPLOAD C
						ON (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey) 
							AND  A.UCIF_ID			= C.UCIF_ID
							AND A.NpaDateDataEntityId=C.NpaDateDataEntityId
							AND A.NPADATECHANGEREASON=C.NPADATECHANGEREASON
							AND Entitykey=@ExEntityKey
			
					UPDATE A
					
						SET  EffectiveToTimeKey =@CurrRecordFromTimeKey-1
						FROM DATAUPLOAD.NpaDateDataUpload_Mod A
						INNER JOIN #NpaDateDATAUPLOAD C
						ON (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey) 
						AND A.UCIF_ID			= C.UCIF_ID
						AND A.NpaDateDataEntityId=C.NpaDateDataEntityId
						AND A.NPADATECHANGEREASON=C.NPADATECHANGEREASON
						 Where  a.AuthorisationStatus='A'	


					PRINT 'A'
							
								  IF @DelStatus IN('DP' ,'1D') 
					                 BEGIN	
					                      Print 'Delete Authorise'
						                 UPDATE G 
						                 SET G.AuthorisationStatus ='A'
						                 	,ApprovedBy=@ApprovedBy
						                 	,DateApproved=@DateApproved
						                 	,EffectiveToTimeKey =@EffectiveFromTimeKey -1
										FROM DATAUPLOAD.NpaDateDataUpload_Mod G
										INNER JOIN #NpaDateDATAUPLOAD GD 
										ON  G.UCIF_ID			= GD.UCIF_ID
										AND G.NpaDateDataEntityId=GD.NpaDateDataEntityId
										AND G.NPADATECHANGEREASON=GD.NPADATECHANGEREASON
										--AND G.CounterPart_BranchCode	= GD.CounterPart_BranchCode
						                 WHERE G.AuthorisationStatus in('NP','MP','DP','RM','1D')

										PRINT 'BE'
						                  IF EXISTS(SELECT 1 FROM DATAUPLOAD.NpaDateDataUpload G
										INNER JOIN #NpaDateDATAUPLOAD GD 
										ON  G.UCIF_ID			= GD.UCIF_ID
										AND G.NpaDateDataEntityId=GD.NpaDateDataEntityId
										AND G.NPADATECHANGEREASON=GD.NPADATECHANGEREASON
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
													FROM DATAUPLOAD.NpaDateDataUpload G
													INNER JOIN #NpaDateDATAUPLOAD GD 
													ON G.UCIF_ID			= GD.UCIF_ID
													AND G.NpaDateDataEntityId=GD.NpaDateDataEntityId
													AND G.NPADATECHANGEREASON=GD.NPADATECHANGEREASON
									               WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
											       	
										 END
									END
									ELSE 

									BEGIN
										 UPDATE G 
										 SET AuthorisationStatus ='A'
										 ,ApprovedBy=@ApprovedBy
										 ,DateApproved=@DateApproved
										 FROM DATAUPLOAD.NpaDateDataUpload_Mod G
										 INNER JOIN #NpaDateDATAUPLOAD GD 
											ON  G.UCIF_ID			= GD.UCIF_ID
											AND G.NpaDateDataEntityId=GD.NpaDateDataEntityId
											AND G.NPADATECHANGEREASON=GD.NPADATECHANGEREASON
										  WHERE G.AuthorisationStatus in('NP','MP','RM','1A')
									END
					END

						IF ISNULL(@DelStatus,'A') NOT IN('DP','1D') OR @AuthMode ='N'
									BEGIN
											
											PRINT @AuthorisationStatus +'AuthorisationStatus'	
                                             PRINT @AUTHMODE +'Authmode'


											 SET  @AuthorisationStatus ='A' 
										
                                                   DELETE G
                                                        FROM DATAUPLOAD.NpaDateDataUpload G
                                                       INNER JOIN #NpaDateDATAUPLOAD GD ON (G.EffectiveFromTimeKey<=@TimeKey AND G.EffectiveToTimeKey>=@TimeKey )
													    AND G.UCIF_ID			= GD.UCIF_ID
														AND G.NpaDateDataEntityId=GD.NpaDateDataEntityId
														AND G.NPADATECHANGEREASON=GD.NPADATECHANGEREASON
                                                       WHERE G.EffectiveFromTimeKey=@EffectiveFromTimeKey  --and ISNULL(GD.AuthorisationStatus,'A')<>'DP'
													


													print 'ROW deleted'+CAST(@@ROWCOUNT AS VARCHAR(10)) +'Deleted'
													
													
                                                    UPDATE G
                                                       SET  
													   G.EffectiveTOTimeKey=@EffectiveFromTimeKey-1
													   ,G.AuthorisationStatus ='A'  --ADDED ON 12 FEB 2018
                                                       FROM DATAUPLOAD.NpaDateDataUpload G
                                                       INNER JOIN #NpaDateDATAUPLOAD GD ON (G.EffectiveFromTimeKey<=@TimeKey AND G.EffectiveToTimeKey>=@TimeKey )
														AND G.UCIF_ID			= GD.UCIF_ID
														AND G.NpaDateDataEntityId=GD.NpaDateDataEntityId
														AND G.NPADATECHANGEREASON=GD.NPADATECHANGEREASON
                                                       WHERE G.EffectiveFromTimeKey<@EffectiveFromTimeKey  --and ISNULL(GD.AuthorisationStatus,'A')<>'DP'
													
													print 'ROW deleted'+CAST(@@ROWCOUNT AS VARCHAR(10))

												
												IF @AuthMode='N' 
												BEGIN
													SET @AuthorisationStatus='A'
												END
												INSERT INTO DATAUPLOAD.NpaDateDataUpload
														(
														NpaDateDataEntityId
														,UCIF_ID
														,NPADate 
														,NPADATECHANGEREASON
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
														NpaDateDataEntityId
													     ,UCIF_ID
														,convert(date,NPADate,103) NPADate
														,NPADATECHANGEREASON
														,CASE WHEN @AuthMode ='Y' THEN @AuthorisationStatus ELSE NULL END
														,@EffectiveFromTimeKey
														,@EffectiveToTimeKey
														,@CreatedBy
														,@DateCreated
														,@ModifiedBy
														,@DateModified
														,CASE WHEN @AuthMode ='Y' THEN @ApprovedBy ELSE NULL END
														,CASE WHEN @AuthMode ='Y' THEN @DateApproved ELSE NULL END
														FROM #NpaDateDATAUPLOAD S

									
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
									@NpaDateDataEntityId,-- ReferenceID ,
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
								@NpaDateDataEntityId ,-- ReferenceID ,
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
								Print 'insert into DATAUPLOAD.NpaDateDataUpload_Mod'

									PRINT '@ErrorHandle'
									INSERT INTO DATAUPLOAD.NpaDateDataUpload_Mod
											(
											NpaDateDataEntityId
											,UCIF_ID
											,NPADate 
											,NPADATECHANGEREASON
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
											@NpaDateDataEntityId+ROW_NUMBER()OVER(ORDER BY (SELECT 1))
											,UCIF_ID
											,convert(date,NPADate,103) NPADate
											,NPADATECHANGEREASON
											,CASE WHEN @AuthMode ='Y' THEN @AuthorisationStatus ELSE NULL END
											,@EffectiveFromTimeKey
											,@EffectiveToTimeKey
											,@CreatedBy
											,@DateCreated
											,@ModifiedBy
											,@DateModified
											,CASE WHEN @AuthMode ='Y' THEN @ApprovedBy ELSE NULL END
											,CASE WHEN @AuthMode ='Y' THEN @DateApproved ELSE NULL END
											FROM #NpaDateDATAUPLOAD S
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
	
		SELECT @D2Ktimestamp=CAST(D2Ktimestamp AS INT) FROM DATAUPLOAD.NpaDateDataUpload_Mod D
							--INNER JOIN #BusinessMatrix T	ON	D.BusinessMatrixAlt_key = T.BusinessMatrixAlt_key
							WHERE (EffectiveFromTimeKey<=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) 



									

	
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