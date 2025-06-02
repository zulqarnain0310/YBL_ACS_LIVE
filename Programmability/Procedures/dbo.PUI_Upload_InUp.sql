SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO




CREATE PROC [dbo].[PUI_Upload_InUp]
 
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
,@AuthorisationStatus	VARCHAR(2)
,@ErrorHandle			SMALLINT =0
,@ExEntityKey			INT	    =0
,@Data_Sequence			INT = 0


IF OBJECT_ID('TEMPDB..#PUIDATAUPLOAD') IS NOT NULL
DROP TABLE #PUIDATAUPLOAD

SELECT 
C.value('./CustomerEntityID [1]','VARCHAR(30)') CustomerEntityID 
,C.value('./CustomerID [1]','VARCHAR(30)') CustomerID 
,C.value('./CustomerName [1]','VARCHAR(255)') CustomerName
,C.value('./AccountID [1]','VARCHAR(30)') AccountID
,C.value('./OriginalEnvisagCompletionDt [1]','VARCHAR(20)') OriginalEnvisagCompletionDt
,C.value('./RevisedCompletionDt [1]','VARCHAR(20)') RevisedCompletionDt
,C.value('./ActualCompletionDt [1]','VARCHAR(20)') ActualCompletionDt
,C.value('./ProjectCat [1]','VARCHAR(50)') ProjectCat
,C.value('./ProjectDelReason [1]','VARCHAR(50)') ProjectDelReason
,C.value('./StandardRestruct [1]','VARCHAR(20)') StandardRestruct

INTO #PUIDATAUPLOAD
FROM @XMLDocument.nodes('/DataSet/Gridrow') AS t(c)

select * from #PUIDATAUPLOAD
--return

IF @OperationFlag=1
BEGIN

--------------------------Added on 11-01-2021  Mod Table Authorize Data to be Expired If Again Uploading after Authorized Data

PRINT 'SUNIL'
	IF EXISTS(
	Select 1 From  AdvAcProjectDetail_Upload_Mod  D
				INNER JOIN #PUIDATAUPLOAD GD 
				ON (EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey) 
					AND D.CustomerID = GD.CustomerID
				WHERE D.AuthorisationStatus in('A') )

BEGIN
PRINT 'EXISTS'

UPDATE D SET D.EffectiveToTimeKey =@EffectiveFromTimeKey-1
From  AdvAcProjectDetail_Upload_Mod  D
				INNER JOIN #PUIDATAUPLOAD GD 
				ON (EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey) 
					AND D.CustomerID = GD.CustomerID
				WHERE D.AuthorisationStatus in('A')
END
--------------------------------------------------------------------

PRINT '1'
IF EXISTS(
	Select 1 From  AdvAcProjectDetail_Upload_Mod  D
				INNER JOIN #PUIDATAUPLOAD GD 
				ON (EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey) 
					AND D.CustomerID = GD.CustomerID
				WHERE D.AuthorisationStatus in('MP','NP','DP','RM') )

BEGIN
PRINT 'EXISTS'
Set @Result=-4
SELECT DISTINCT @ErrorMsg=
						STUFF((SELECT distinct ', ' + CAST(CustomerID as varchar(max))
							FROM #PUIDATAUPLOAD t2
							FOR XML PATH('')),1,1,'') 
					From  AdvAcProjectDetail_Upload_Mod  D
					INNER JOIN #PUIDATAUPLOAD GD 
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
								(SELECT MAX(Entitykey) CustomerEntityId FROM advacprojectdetail
									UNION 
									SELECT MAX(Entitykey) CustomerEntityId FROM  AdvAcProjectDetail_Upload_Mod
								)A
SET @CustomerEntityId = ISNULL(@CustomerEntityId,0)
print 'jayadev'
print @CustomerEntityId
print 'epili'
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
			FROM advacprojectdetail D
			INNER JOIN  #PUIDATAUPLOAD GD	
			ON  D.CustomerID = GD.CustomerID
			WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
		
		PRINT @CreatedBy
		PRINT @DateCreated
		IF ISNULL(@CreatedBy,'')=''
			BEGIN
				PRINT 44
				SELECT  @CreatedBy			= CreatedBy
							,@DateCreated	= DateCreated
					FROM  AdvAcProjectDetail_Upload_Mod D
					INNER JOIN  #PUIDATAUPLOAD GD	
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
				FROM advacprojectdetail D
				INNER JOIN  #PUIDATAUPLOAD GD 
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
					 
			FROM  AdvAcProjectDetail_Upload_Mod D
				INNER JOIN  #PUIDATAUPLOAD GD 
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
						FROM advacprojectdetail D
				INNER JOIN  #PUIDATAUPLOAD GD	
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
		FROM  AdvAcProjectDetail_Upload_Mod D
				INNER JOIN  #PUIDATAUPLOAD GD	
					ON D.CustomerID			= GD.CustomerID
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
				and D.AuthorisationStatus IN('NP','MP','DP','RM')


	IF EXISTS(Select 1 From advacprojectdetail D
				INNER JOIN #PUIDATAUPLOAD GD 
				ON (EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey) 
					AND  D.CustomerID			= GD.CustomerID
					)
			BEGIN

				UPDATE D
					SET AuthorisationStatus='A'
					FROM advacprojectdetail D
				INNER JOIN  #PUIDATAUPLOAD GD	
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
		FROM  AdvAcProjectDetail_Upload_Mod D
				INNER JOIN  #PUIDATAUPLOAD GD	
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
					        FROM advacprojectdetail  D
							INNER JOIN  #PUIDATAUPLOAD GD	
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
			SELECT @ExEntityKey= MAX(Entitykey) FROM  AdvAcProjectDetail_Upload_Mod A
				INNER JOIN #PUIDATAUPLOAD C
				ON (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
					AND A.CustomerID			= C.CustomerID
				WHERE  a.AuthorisationStatus IN('NP','MP','DP','RM')	


			PRINT @@ROWCOUNT

			SELECT	@DelStatus=a.AuthorisationStatus
					,@CreatedBy=CreatedBy
					,@DateCreated=DATECreated
					,@ModifiedBy=ModifiedBy
					, @DateModified=DateModified
				FROM  AdvAcProjectDetail_Upload_Mod A
				INNER JOIN #PUIDATAUPLOAD C
				ON (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey) 
				AND A.CustomerID			= C.CustomerID
				WHERE   Entitykey=@ExEntityKey
					
			SET @ApprovedBy = @CrModApBy			
			SET @DateApproved=GETDATE()

					 
				
					
			DECLARE @CurEntityKey INT=0

			SELECT @ExEntityKey= MIN(Entitykey) FROM  AdvAcProjectDetail_Upload_Mod A 
				INNER JOIN #PUIDATAUPLOAD C
				ON (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey) 
				AND A.CustomerID			= C.CustomerID
				WHERE  a.AuthorisationStatus IN('NP','MP','DP','RM')	
				
			SELECT	@CurrRecordFromTimeKey=A.EffectiveFromTimeKey 
					FROM  AdvAcProjectDetail_Upload_Mod A
					INNER JOIN #PUIDATAUPLOAD C
				ON (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey) 
					AND  A.CustomerID			= C.CustomerID
					AND Entitykey=@ExEntityKey
			
			UPDATE A
					
				SET  EffectiveToTimeKey =@CurrRecordFromTimeKey-1
				FROM  AdvAcProjectDetail_Upload_Mod A
				INNER JOIN #PUIDATAUPLOAD C
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
								FROM  AdvAcProjectDetail_Upload_Mod G
								INNER JOIN #PUIDATAUPLOAD GD 
								ON  G.CustomerID			= GD.CustomerID
								--AND G.CounterPart_BranchCode	= GD.CounterPart_BranchCode
						            WHERE G.AuthorisationStatus in('NP','MP','DP','RM')

								PRINT 'BE'
						            IF EXISTS(SELECT 1 FROM advacprojectdetail G
								INNER JOIN #PUIDATAUPLOAD GD 
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
											FROM advacprojectdetail G
											INNER JOIN #PUIDATAUPLOAD GD 
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
									FROM  AdvAcProjectDetail_Upload_Mod G
									INNER JOIN #PUIDATAUPLOAD GD 
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
                                                FROM advacprojectdetail G
                                                INNER JOIN #PUIDATAUPLOAD GD ON (G.EffectiveFromTimeKey<=@TimeKey AND G.EffectiveToTimeKey>=@TimeKey )
												AND G.CustomerID			= GD.CustomerID
                                                WHERE G.EffectiveFromTimeKey=@EffectiveFromTimeKey  --and ISNULL(GD.AuthorisationStatus,'A')<>'DP'
													


											print 'ROW deleted'+CAST(@@ROWCOUNT AS VARCHAR(10)) +'Deleted'
													
													
                                            UPDATE G
                                                SET  
												G.EffectiveTOTimeKey=@EffectiveFromTimeKey-1
												,G.AuthorisationStatus ='A'  --ADDED ON 12 FEB 2018
                                                FROM advacprojectdetail G
                                                INNER JOIN #PUIDATAUPLOAD GD ON (G.EffectiveFromTimeKey<=@TimeKey AND G.EffectiveToTimeKey>=@TimeKey )
												AND G.CustomerID			= GD.CustomerID
                                                WHERE G.EffectiveFromTimeKey<@EffectiveFromTimeKey  --and ISNULL(GD.AuthorisationStatus,'A')<>'DP'
													
											print 'ROW deleted'+CAST(@@ROWCOUNT AS VARCHAR(10))

												
										IF @AuthMode='N' 
										BEGIN
											SET @AuthorisationStatus='A'
										END

										-- SELECT @CustomerEntityId= MAX(CustomerEntityId)  FROM  
										--	(SELECT MAX(Entitykey) CustomerEntityId FROM advacprojectdetail
										--	 UNION 
										--	 SELECT MAX(Entitykey) CustomerEntityId FROM  AdvAcProjectDetail_Upload_Mod
										--	)A
										--SET @CustomerEntityId = ISNULL(@CustomerEntityId,0)


--------------------------Added on 11-01-2021  Main Table Authorize Data to be Expired If Again Uploading after Authorized Data

PRINT 'SUNIL1'
	IF EXISTS(
	Select 1 From  advacprojectdetail  D
				INNER JOIN #PUIDATAUPLOAD GD 
				ON (EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey) 
					AND D.CustomerID = GD.CustomerID
				WHERE D.AuthorisationStatus in('A') )

BEGIN
PRINT 'EXISTS'

UPDATE D SET D.EffectiveToTimeKey =@EffectiveFromTimeKey-1
From  advacprojectdetail  D
				INNER JOIN #PUIDATAUPLOAD GD 
				ON (EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey) 
					AND D.CustomerID = GD.CustomerID
				WHERE D.AuthorisationStatus in('A')
END
--------------------------------------------------------------------

		PRINT 'CustomerEntityID'
		
		PRINT @CustomerEntityID

										INSERT INTO advacprojectdetail
												(
												CustomerEntityID
												,RefAccountEntityId
													, CustomerID
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
												CustomerEntityID
												,'NULL'
												, CustomerID
												,CustomerName
												,AccountID
												,convert (date,OriginalEnvisagCompletionDt,103) OriginalEnvisagCompletionDt
												,Case When RevisedCompletionDt<>'' then convert (date,RevisedCompletionDt,103) ELSE NULL END RevisedCompletionDt
												--,convert (date,ISNULL(ActualCompletionDt,NULL),103) ActualCompletionDt
							--,Case When ISNULL(ActualCompletionDt,NULL)<>''	Then ActualCompletionDt Else NULL END ActualCompletionDt
							,Case When ActualCompletionDt<>''	Then Convert(Date,ActualCompletionDt,103) Else NULL END ActualCompletionDt
												,PC.ParameterAlt_Key
												,PDR.ParameterAlt_Key
												,STD.ParameterAlt_Key
												,CASE WHEN @AuthMode ='Y' THEN @AuthorisationStatus ELSE NULL END
												,@EffectiveFromTimeKey
												,@EffectiveToTimeKey
												,@CreatedBy
												,@DateCreated
												,@ModifiedBy
												,@DateModified
												,CASE WHEN @AuthMode ='Y' THEN @ApprovedBy ELSE NULL END
												,CASE WHEN @AuthMode ='Y' THEN @DateApproved ELSE NULL END
														
												FROM #PUIDATAUPLOAD S
												Inner Join (Select ParameterAlt_Key,ParameterName from DimParameter where DimparameterName='ProjectCategory'  
												AND EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) PC
												ON PC.ParameterName=S.ProjectCat 
												left Join (Select ParameterAlt_Key,ParameterName from DimParameter where DimparameterName='ProdectDelReson'  
												AND EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) PDR
												ON PDR.ParameterName=S.ProjectDelReason 
												left Join (Select ParameterAlt_Key,ParameterName from DimParameter where DimparameterName='DimYesNo'  
												AND EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) STD
												ON STD.ParameterName=S.StandardRestruct 
														
													
												Update A
								SET A.CustomerEntityID=B.CustomerEntityID,
									A.RefAccountEntityId=B.AccountEntityID
								FROM advacprojectdetail A INNER JOIN PRO.Accountcal B
								ON A.AccountId=B.CustomerAcID
								where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
								and B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey
-----------------------------------------------------Calculated Columns Update Added on 08-01-2021 ------------


-------------Portfolio Main




--Select * 






----------------------------------------------------------------------------------------
									
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
			IF @OperationFlag =17 and @Remark is null
				BEGIN 

							PRINT '@ErrorHandle'
							INSERT INTO  AdvAcProjectDetail_Upload_Mod
									(
									CustomerEntityID
											
									,CustomerID
											
									,CustomerName
									,AccountID
									,OriginalEnvisagCompletionDt
									,RevisedCompletionDt
									,ActualCompletionDt
									,ProjectCat
									,ProjectDelReason
									,StandardRestruct
											
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
									ISNULL(CustomerEntityID,0)
									,CustomerID
									,CustomerName
									,AccountID
									,CONVERT(Date,OriginalEnvisagCompletionDt,103) as OriginalEnvisagCompletionDt
									,Case When RevisedCompletionDt='' Then NUll else Convert(Date,RevisedCompletionDt,103) END as RevisedCompletionDt
									--,Convert(Date,ISNULL(ActualCompletionDt,NULL),103) as ActualCompletionDt
									,Case When ActualCompletionDt<>''	Then ActualCompletionDt Else NULL END ActualCompletionDt
									,ProjectCat
									,ProjectDelReason
									,StandardRestruct
									,@EffectiveFromTimeKey
									,@EffectiveToTimeKey
									,'NP'
									,CASE WHEN @AuthMode ='Y' THEN @ApprovedBy ELSE NULL END
									,CASE WHEN @AuthMode ='Y' THEN @DateApproved ELSE NULL END
									,@CreatedBy
									,@DateCreated
									,@ModifiedBy
									,@DateModified
										
									FROM #PUIDATAUPLOAD S


	END	
	END	

SET @ErrorHandle=1


BusinessMatrix_Insert:
PRINT 'A'
--SELECT  @ErrorHandle
IF @ErrorHandle=0
								
BEGIN
						Print 'insert into  AdvAcProjectDetail_Upload_Mod'

							PRINT '@ErrorHandle'
							INSERT INTO  AdvAcProjectDetail_Upload_Mod
									(
									CustomerEntityID
											
									,CustomerID
											
									,CustomerName
									,AccountID
									,OriginalEnvisagCompletionDt
									,RevisedCompletionDt
									,ActualCompletionDt
									,ProjectCat
									,ProjectDelReason
									,StandardRestruct
											
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
									ISNULL(@CustomerEntityId,0)+ROW_NUMBER()OVER(ORDER BY (SELECT 1))
									,CustomerID
									,CustomerName
									,AccountID
									,CONVERT(Date,OriginalEnvisagCompletionDt,103) as OriginalEnvisagCompletionDt
									,Case When RevisedCompletionDt<>'' then Convert(Date,RevisedCompletionDt,103) ELSE NULL END as RevisedCompletionDt
									--,Convert(Date,ISNULL(ActualCompletionDt,NULL),103) as ActualCompletionDt
									
									,Case When ActualCompletionDt<>''	Then Convert(Date,ActualCompletionDt,103) Else NULL END ActualCompletionDt
									,ProjectCat
									,ProjectDelReason
									,StandardRestruct
									,@EffectiveFromTimeKey
									,@EffectiveToTimeKey
									,CASE WHEN @AuthMode ='Y' THEN @AuthorisationStatus ELSE NULL END
									,@CreatedBy
									,@DateCreated
									,@ModifiedBy
									,@DateModified
									,CASE WHEN @AuthMode ='Y' THEN @ApprovedBy ELSE NULL END
									,CASE WHEN @AuthMode ='Y' THEN @DateApproved ELSE NULL END
											
									FROM #PUIDATAUPLOAD S
									--WHERE Amount<>0
							
									Update A
								SET A.CustomerEntityID=B.CustomerEntityID
									--A.RefAccountEntityId=B.AccountEntityID
								FROM AdvAcProjectDetail_Upload_Mod A INNER JOIN PRO.Accountcal B
								ON A.AccountId=B.CustomerAcID
								where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
								and B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey			
									
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
	
--SELECT @D2Ktimestamp=CAST(D2Ktimestamp AS INT) FROM  AdvAcProjectDetail_Upload_Mod D
--					--INNER JOIN #BusinessMatrix T	ON	D.BusinessMatrixAlt_key = T.BusinessMatrixAlt_key
--					WHERE (EffectiveFromTimeKey<=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) 



--UPDATE A SET CustomerName=B.CustomerName 		FROM  advacprojectdetail A 		INNER JOIN PRO.customercal B ON A.CustomerID=B.RefCustomerID		where A.CustomerName IS NULL
--UPDATE A SET CustomerName=B.CustomerName		FROM   AdvAcProjectDetail_Upload_Mod A 		INNER JOIN PRO.customercal B ON A.CustomerID=B.RefCustomerID	where A.CustomerName IS NULL					

									

	
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
SELECT ERROR_MESSAGE() ERRORDESC
ROLLBACK TRAN
	

		
SET @RESULT=-1
	
RETURN @RESULT

		

END  CATCH


END						            




GO