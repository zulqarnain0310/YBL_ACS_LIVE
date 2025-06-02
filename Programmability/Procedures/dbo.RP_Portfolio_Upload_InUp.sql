SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


create PROC [dbo].[RP_Portfolio_Upload_InUp]
 
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


IF OBJECT_ID('TEMPDB..#PORTFOLIODATAUPLOAD') IS NOT NULL
        DROP TABLE #PORTFOLIODATAUPLOAD

SELECT 
 C.value('./UCIC_ID[1]','VARCHAR(30)') UCIC_ID
,C.value('./CustomerID [1]','VARCHAR(30)') CustomerID 
,C.value('./PAN_No [1]','VARCHAR(20)') Pan_No     
,C.value('./CustomerName [1]','VARCHAR(255)') CustomerName
,C.value('./BankCode [1]','VARCHAR(20)') BankCode
,C.value('./ExposureBucketName [1]','VARCHAR(100)') ExposureBucketName
,C.value('./BankingArrangementName [1]','VARCHAR(100)') BankingArrangementName
,C.value('./LeadBankName [1]','VARCHAR(100)') LeadBankName
,C.value('./DefaultStatus [1]','VARCHAR(100)') DefaultStatus
,C.value('./RP_ApprovalDate [1]','VARCHAR(20)') RP_ApprovalDate
,C.value('./RPNatureName [1]','VARCHAR(100)') RPNatureName
,C.value('./If_Other [1]','VARCHAR(500)') If_Other
,C.value('./ImplementationStatus [1]','VARCHAR(100)') ImplementationStatus
,C.value('./Actual_Impl_Date [1]','VARCHAR(20)') Actual_ImplDate
,C.value('./RP_OutOfDateAllBanksDeadline [1]','VARCHAR(20)') RP_OutOfDateAllBanksDeadline

INTO #PORTFOLIODATAUPLOAD
FROM @XMLDocument.nodes('/DataSet/Gridrow') AS t(c)

--select * from #PORTFOLIODATAUPLOAD
--return

IF @OperationFlag=1
BEGIN

--------------------------Added on 11-01-2021  Mod Table Authorize Data to be Expired If Again Uploading after Authorized Data

PRINT 'SUNIL'
			IF EXISTS(
			Select 1 From  RP_Portfolio_Upload_Mod  D
						INNER JOIN #PORTFOLIODATAUPLOAD GD 
						ON (EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey) 
							AND D.CustomerID = GD.CustomerID
						WHERE D.AuthorisationStatus in('A') )

	BEGIN
		PRINT 'EXISTS'

		UPDATE D SET D.EffectiveToTimeKey =@EffectiveFromTimeKey-1
		From  RP_Portfolio_Upload_Mod  D
						INNER JOIN #PORTFOLIODATAUPLOAD GD 
						ON (EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey) 
							AND D.CustomerID = GD.CustomerID
						WHERE D.AuthorisationStatus in('A')
	END
--------------------------------------------------------------------

	PRINT '1'
	IF EXISTS(
			Select 1 From  RP_Portfolio_Upload_Mod  D
						INNER JOIN #PORTFOLIODATAUPLOAD GD 
						ON (EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey) 
							AND D.CustomerID = GD.CustomerID
						WHERE D.AuthorisationStatus in('MP','NP','DP','RM') )

	BEGIN
		PRINT 'EXISTS'
		Set @Result=-4
		SELECT DISTINCT @ErrorMsg=
								STUFF((SELECT distinct ', ' + CAST(CustomerID as varchar(max))
								 FROM #PORTFOLIODATAUPLOAD t2
								 FOR XML PATH('')),1,1,'') 
							From  RP_Portfolio_Upload_Mod  D
							INNER JOIN #PORTFOLIODATAUPLOAD GD 
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
										(SELECT MAX(Entitykey) CustomerEntityId FROM RP_Portfolio_Details
										 UNION 
										 SELECT MAX(Entitykey) CustomerEntityId FROM  RP_Portfolio_Upload_Mod
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
					FROM RP_Portfolio_Details D
					INNER JOIN  #PORTFOLIODATAUPLOAD GD	
					ON  D.CustomerID = GD.CustomerID
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
		
				PRINT @CreatedBy
				PRINT @DateCreated
				IF ISNULL(@CreatedBy,'')=''
					BEGIN
						PRINT 44
						SELECT  @CreatedBy			= CreatedBy
									,@DateCreated	= DateCreated
							FROM  RP_Portfolio_Upload_Mod D
							INNER JOIN  #PORTFOLIODATAUPLOAD GD	
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
						FROM RP_Portfolio_Details D
						INNER JOIN  #PORTFOLIODATAUPLOAD GD 
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
					 
					FROM  RP_Portfolio_Upload_Mod D
						INNER JOIN  #PORTFOLIODATAUPLOAD GD 
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
								FROM RP_Portfolio_Details D
						INNER JOIN  #PORTFOLIODATAUPLOAD GD	
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
				FROM  RP_Portfolio_Upload_Mod D
						INNER JOIN  #PORTFOLIODATAUPLOAD GD	
							ON D.CustomerID			= GD.CustomerID
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						and D.AuthorisationStatus IN('NP','MP','DP','RM')


			IF EXISTS(Select 1 From RP_Portfolio_Details D
						INNER JOIN #PORTFOLIODATAUPLOAD GD 
						ON (EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey) 
							AND  D.CustomerID			= GD.CustomerID
							)
					BEGIN

						UPDATE D
							SET AuthorisationStatus='A'
							FROM RP_Portfolio_Details D
						INNER JOIN  #PORTFOLIODATAUPLOAD GD	
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
				FROM  RP_Portfolio_Upload_Mod D
						INNER JOIN  #PORTFOLIODATAUPLOAD GD	
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
					             	FROM RP_Portfolio_Details  D
									INNER JOIN  #PORTFOLIODATAUPLOAD GD	
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
					SELECT @ExEntityKey= MAX(Entitykey) FROM  RP_Portfolio_Upload_Mod A
					 INNER JOIN #PORTFOLIODATAUPLOAD C
						ON (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
						 AND A.CustomerID			= C.CustomerID
						WHERE  a.AuthorisationStatus IN('NP','MP','DP','RM')	


					PRINT @@ROWCOUNT

					SELECT	@DelStatus=a.AuthorisationStatus
							,@CreatedBy=CreatedBy
							,@DateCreated=DATECreated
							,@ModifiedBy=ModifiedBy
							, @DateModified=DateModified
					 FROM  RP_Portfolio_Upload_Mod A
					  INNER JOIN #PORTFOLIODATAUPLOAD C
						ON (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey) 
						AND A.CustomerID			= C.CustomerID
						WHERE   Entitykey=@ExEntityKey
					
					SET @ApprovedBy = @CrModApBy			
					SET @DateApproved=GETDATE()

					 
				
					
					DECLARE @CurEntityKey INT=0

					SELECT @ExEntityKey= MIN(Entitykey) FROM  RP_Portfolio_Upload_Mod A 
					 INNER JOIN #PORTFOLIODATAUPLOAD C
						ON (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey) 
						AND A.CustomerID			= C.CustomerID
						WHERE  a.AuthorisationStatus IN('NP','MP','DP','RM')	
				
					SELECT	@CurrRecordFromTimeKey=A.EffectiveFromTimeKey 
						 FROM  RP_Portfolio_Upload_Mod A
						  INNER JOIN #PORTFOLIODATAUPLOAD C
						ON (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey) 
							AND  A.CustomerID			= C.CustomerID
							AND Entitykey=@ExEntityKey
			
					UPDATE A
					
						SET  EffectiveToTimeKey =@CurrRecordFromTimeKey-1
						FROM  RP_Portfolio_Upload_Mod A
						INNER JOIN #PORTFOLIODATAUPLOAD C
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
										FROM  RP_Portfolio_Upload_Mod G
										INNER JOIN #PORTFOLIODATAUPLOAD GD 
										ON  G.CustomerID			= GD.CustomerID
										--AND G.CounterPart_BranchCode	= GD.CounterPart_BranchCode
						                 WHERE G.AuthorisationStatus in('NP','MP','DP','RM')

										PRINT 'BE'
						                  IF EXISTS(SELECT 1 FROM RP_Portfolio_Details G
										INNER JOIN #PORTFOLIODATAUPLOAD GD 
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
													FROM RP_Portfolio_Details G
													INNER JOIN #PORTFOLIODATAUPLOAD GD 
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
										 FROM  RP_Portfolio_Upload_Mod G
										 INNER JOIN #PORTFOLIODATAUPLOAD GD 
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
                                                        FROM RP_Portfolio_Details G
                                                       INNER JOIN #PORTFOLIODATAUPLOAD GD ON (G.EffectiveFromTimeKey<=@TimeKey AND G.EffectiveToTimeKey>=@TimeKey )
													    AND G.CustomerID			= GD.CustomerID
                                                       WHERE G.EffectiveFromTimeKey=@EffectiveFromTimeKey  --and ISNULL(GD.AuthorisationStatus,'A')<>'DP'
													


													print 'ROW deleted'+CAST(@@ROWCOUNT AS VARCHAR(10)) +'Deleted'
													
													
                                                    UPDATE G
                                                       SET  
													   G.EffectiveTOTimeKey=@EffectiveFromTimeKey-1
													   ,G.AuthorisationStatus ='A'  --ADDED ON 12 FEB 2018
                                                       FROM RP_Portfolio_Details G
                                                       INNER JOIN #PORTFOLIODATAUPLOAD GD ON (G.EffectiveFromTimeKey<=@TimeKey AND G.EffectiveToTimeKey>=@TimeKey )
														AND G.CustomerID			= GD.CustomerID
                                                       WHERE G.EffectiveFromTimeKey<@EffectiveFromTimeKey  --and ISNULL(GD.AuthorisationStatus,'A')<>'DP'
													
													print 'ROW deleted'+CAST(@@ROWCOUNT AS VARCHAR(10))

												
												IF @AuthMode='N' 
												BEGIN
													SET @AuthorisationStatus='A'
												END

												-- SELECT @CustomerEntityId= MAX(CustomerEntityId)  FROM  
												--	(SELECT MAX(Entitykey) CustomerEntityId FROM RP_Portfolio_Details
												--	 UNION 
												--	 SELECT MAX(Entitykey) CustomerEntityId FROM  RP_Portfolio_Upload_Mod
												--	)A
												--SET @CustomerEntityId = ISNULL(@CustomerEntityId,0)


--------------------------Added on 11-01-2021  Main Table Authorize Data to be Expired If Again Uploading after Authorized Data

PRINT 'SUNIL1'
			IF EXISTS(
			Select 1 From  RP_Portfolio_Details  D
						INNER JOIN #PORTFOLIODATAUPLOAD GD 
						ON (EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey) 
							AND D.CustomerID = GD.CustomerID
						WHERE D.AuthorisationStatus in('A') )

	BEGIN
		PRINT 'EXISTS'

		UPDATE D SET D.EffectiveToTimeKey =@EffectiveFromTimeKey-1
		From  RP_Portfolio_Details  D
						INNER JOIN #PORTFOLIODATAUPLOAD GD 
						ON (EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey) 
							AND D.CustomerID = GD.CustomerID
						WHERE D.AuthorisationStatus in('A')
	END
--------------------------------------------------------------------

		print 'abc'

												INSERT INTO RP_Portfolio_Details
														(
														PAN_No
														,UCIC_ID
														,CustomerID
														,CustomerName
														,BankingArrangementAlt_Key
														,LeadBankAlt_Key
														,DefaultStatusAlt_Key
														,ExposureBucketAlt_Key
														,ReferenceDate
														--,ReviewExpiryDate
														,RP_ApprovalDate
														,RPNatureAlt_Key
														,If_Other
														--,RP_ExpiryDate
														--,RP_ImplDate
														,RP_ImplStatusAlt_Key
														--,RP_failed
														--,Revised_RP_Expiry_Date
														,Actual_Impl_Date
														,RP_OutOfDateAllBanksDeadline
														--,IsBankExposure
														--,AssetClassAlt_Key
														--,RiskReviewExpiryDate
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
														PAN_No
													    ,UCIC_ID
														,CustomerID
														,CustomerName
														,DA.BankingArrangementAlt_Key
														,DB.BankRPAlt_Key
														,DH.ParameterAlt_Key as DefaultStatusAlt_Key
														,DE.ExposureBucketAlt_Key
														,(Case When S.ExposureBucketName='1500 Crs To 2000 Crs' Then '2020-01-01'
																When S.ExposureBucketName='Greater Than 2000 Crs' Then '2019-06-07' End) ReferenceDate
														--,Convert(Date,RP_ApprovalDate,103) as RP_ApprovalDate
														,Case When isnull(RP_ApprovalDate,'')<>''	Then Convert(Date,RP_ApprovalDate,103) Else NULL END RP_ApprovalDate
														,DR.RPNatureAlt_Key
														,If_Other
														,DP.ParameterAlt_Key as ImplementationStatus
														--,Convert(Date,Actual_ImplDate,103) as Actual_ImplDate
														,Case When isnull(Actual_ImplDate,'')<>''	Then Convert(Date,Actual_ImplDate,103) Else NULL END Actual_ImplDate
														--,Convert(Date,RP_OutOfDateAllBanksDeadline,103) as RP_OutOfDateAllBanksDeadline
														,Case When isnull(RP_OutOfDateAllBanksDeadline,'')<>''	Then Convert(Date,RP_OutOfDateAllBanksDeadline,103) Else NULL END RP_OutOfDateAllBanksDeadline
														--,Convert(Date,RP_OutOfDateAllBanksDeadline,103) as RP_OutOfDateAllBanksDeadline
														,CASE WHEN @AuthMode ='Y' THEN @AuthorisationStatus ELSE NULL END
														,@EffectiveFromTimeKey
														,@EffectiveToTimeKey
														,@CreatedBy
														,@DateCreated
														,@ModifiedBy
														,@DateModified
														,CASE WHEN @AuthMode ='Y' THEN @ApprovedBy ELSE NULL END
														,CASE WHEN @AuthMode ='Y' THEN @DateApproved ELSE NULL END
														
														FROM #PORTFOLIODATAUPLOAD S
														Left Join DimBankRP DB ON DB.BankName=S.LeadBankName
														AND DB.EffectiveFromTimeKey<=@TimeKey And DB.EffectiveToTimeKey>=@TimeKey
														Inner Join DimBankingArrangement DA ON DA.ArrangementDescription=S.BankingArrangementName
														AND DA.EffectiveFromTimeKey<=@TimeKey And DA.EffectiveToTimeKey>=@TimeKey
														Inner Join DimExposureBucket DE ON DE.BucketName=S.ExposureBucketName
														AND DE.EffectiveFromTimeKey<=@TimeKey And DE.EffectiveToTimeKey>=@TimeKey
														Inner Join DimResolutionPlanNature DR ON DR.RPDescription=S.RPNatureName
														AND DR.EffectiveFromTimeKey<=@TimeKey And DR.EffectiveToTimeKey>=@TimeKey
														Inner Join (Select * from DimParameter where DimParameterName='ImplementationStatus'
														And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)DP ON DP.ParameterName=S.ImplementationStatus
														Inner Join (Select * from DimParameter where DimParameterName='BorrowerDefaultStatus'
														And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)DH ON DH.ParameterName=S.DefaultStatus

-----------------------------------------------------Calculated Columns Update Added on 08-01-2021 ------------


-------------Portfolio Main

IF OBJECT_ID('TempDB..#PortfolioCustomer') Is Not Null
Drop Table #PortfolioCustomer

Select A.CustomerID,A.ReferenceDate Into #PortfolioCustomer from RP_PortFolio_Details A
Inner Join DimExposureBucket DE ON DE.ExposureBucketAlt_key=A.ExposureBucketAlt_Key
And DE.EffectiveFromTimeKey<=@TimeKey And DE.EffectiveToTimeKey>=@TimeKey
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
And DE.BucketName In ('1500 Crs To 2000 Crs','Greater Than 2000 Crs')



Update P set P.ReviewExpiryDate=DATEADD(D,30,L.ReferenceDate),
			P.RP_ExpiryDate=DATEADD(D,210,L.ReferenceDate),
			P.Revised_RP_Expiry_Date=DATEADD(D,180,P.RP_OutOfDateAllBanksDeadline),
			P.RiskReviewExpiryDate=DATEADD(D,75,L.ReferenceDate)
 from RP_PortFolio_Details P
Inner Join #PortfolioCustomer L ON P.CustomerID=L.CustomerID
Where P.EffectiveFromTimeKey<=@TimeKey And P.EffectiveToTimeKey>=@TimeKey


----------ISBANKExposure

IF OBJECT_ID('TempDB..#Portfolio') Is Not Null
Drop Table #Portfolio

Select A.CustomerID,SUM(ISNULL(DE.Balance,0))Balance Into #Portfolio from RP_PortFolio_Details A
Inner Join PRO.AccountCal DE ON DE.RefCustomerID=A.CustomerID
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
Group By A.CustomerID


--Select * 

Update A Set A.IsBankExposure=(Case When B.Balance>0 Then 'Y' Else 'N' End)
from RP_PortFolio_Details A
INNER JOIN #Portfolio B ON A.CustomerID=B.CustomerID
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey

------------Asset Class


IF OBJECT_ID('TempDB..#PortfolioAsset') Is Not Null
Drop Table #PortfolioAsset

Select A.CustomerID,DE.SysAssetClassAlt_Key Into #PortfolioAsset from RP_PortFolio_Details A
Inner Join PRO.CustomerCal DE ON DE.RefCustomerID=A.CustomerID
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey


--Select * 

Update A Set A.AssetClassAlt_Key=B.SysAssetClassAlt_Key
from RP_PortFolio_Details A
INNER JOIN #PortfolioAsset B ON A.CustomerID=B.CustomerID
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey

-----------Added on 22nd Jan 2021----------------

UPDATE RP_Portfolio_Details SET
CustomerName=B.CustomerName
from RP_Portfolio_Details A
INNER JOIN pro.CustomerCal B
ON A.customerid=B.RefCustomerID
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey 
								


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
								Print 'insert into  RP_Portfolio_Upload_Mod'

									PRINT '@ErrorHandle'
									INSERT INTO  RP_Portfolio_Upload_Mod
											(
											CustomerEntityID
											,UCIC_ID
											,CustomerID
											,PAN_No
											,CustomerName
											,BankCode
											,ExposureBucketName
											,BankingArrangementName
											,LeadBankName
											,DefaultStatus
											,RP_ApprovalDate
											,RPNatureName
											,If_Other
											,ImplementationStatus
											,Actual_Impl_Date
											,RP_OutOfDateAllBanksDeadline
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
											,BankCode
											,ExposureBucketName
											,BankingArrangementName
											,LeadBankName
											,DefaultStatus
											--,Convert(Date,RP_ApprovalDate,103) as RP_ApprovalDate
											,Case When isnull(RP_ApprovalDate,'')<>''	Then Convert(Date,RP_ApprovalDate,103) Else NULL END RP_ApprovalDate
											,RPNatureName
											,If_Other
											,ImplementationStatus
											--,Convert(Date,Actual_ImplDate,103) as Actual_ImplDate
											,Case When isnull(Actual_ImplDate,'')<>''	Then Convert(Date,Actual_ImplDate,103) Else NULL END Actual_ImplDate
											--,Convert(Date,RP_OutOfDateAllBanksDeadline,103) as RP_OutOfDateAllBanksDeadline
											,Case When isnull(RP_OutOfDateAllBanksDeadline,'')<>''	Then Convert(Date,RP_OutOfDateAllBanksDeadline,103) Else NULL END RP_OutOfDateAllBanksDeadline
											,@EffectiveFromTimeKey
											,@EffectiveToTimeKey
											,CASE WHEN @AuthMode ='Y' THEN @AuthorisationStatus ELSE NULL END
											,@CreatedBy
											,@DateCreated
											,@ModifiedBy
											,@DateModified
											,CASE WHEN @AuthMode ='Y' THEN @ApprovedBy ELSE NULL END
											,CASE WHEN @AuthMode ='Y' THEN @DateApproved ELSE NULL END
											
											FROM #PORTFOLIODATAUPLOAD S
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
	
		--SELECT @D2Ktimestamp=CAST(D2Ktimestamp AS INT) FROM  RP_Portfolio_Upload_Mod D
		--					--INNER JOIN #BusinessMatrix T	ON	D.BusinessMatrixAlt_key = T.BusinessMatrixAlt_key
		--					WHERE (EffectiveFromTimeKey<=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) 



		--UPDATE A SET CustomerName=B.CustomerName 		FROM  RP_Portfolio_Details A 		INNER JOIN PRO.customercal B ON A.CustomerID=B.RefCustomerID		where A.CustomerName IS NULL
		--UPDATE A SET CustomerName=B.CustomerName		FROM   RP_Portfolio_Upload_Mod A 		INNER JOIN PRO.customercal B ON A.CustomerID=B.RefCustomerID	where A.CustomerName IS NULL					

									

	
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