SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/*===================================================
AUTHOR : SHUBHAM MANKAME
CREATE DATE :20-02-2024
MODIFY DATE :20-02-2024
DESCRIPTION : DATA UPLOAD FOR ABSOLUTE PROVISON MOC 
=====================================================*/
CREATE PROCEDURE [DataUpload].[AbsoluteBackdatedMOCUpload_INUP]
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
,@MenuId			   INT = 6100
,@ErrorMsg			   VARCHAR(MAX)='' output
,@filepath             VARCHAR(500)=''       ------Added by Tarkeshwar Singh on 24 July 2024

As
BEGIN
DECLARE
		@AbsProvMOCEntityId	INT
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
       ,@LastMonthDateKey int = (Select LastMonthDateKey From YBL_ACS.DBO.SysDayMatrix Where TimeKey = @Timekey)
	   ,@LastMonthDate date = (Select LastMonthDate From YBL_ACS.DBO.SysDayMatrix Where TimeKey = @TimeKey)
	   ,@FilePathUpdated VARCHAR(500)=@CrModApBy+'_'+@filepath  -------Added by Tarkeshwar Singh on 24 July 2024

--Code Commented to Remove iterations by shubham on 2024-04-27

--Declare @YEAR VARCHAR(4) =(Select DATEPART(YEAR,@LastMonthDate))
--Declare @Month VARCHAR(3) = (Select CASE WHEN DATEPART(MONTH,@LastMonthDate) = 1 THEN 'JAN'
--            WHEN DATEPART(MONTH,@LastMonthDate) = 2 THEN 'FEB'
--			WHEN DATEPART(MONTH,@LastMonthDate) = 3 THEN 'MAR'
--			WHEN DATEPART(MONTH,@LastMonthDate) = 4 THEN 'APR'
--			WHEN DATEPART(MONTH,@LastMonthDate) = 5 THEN 'MAY'
--			WHEN DATEPART(MONTH,@LastMonthDate) = 6 THEN 'JUN'
--			WHEN DATEPART(MONTH,@LastMonthDate) = 7 THEN 'JUL'
--			WHEN DATEPART(MONTH,@LastMonthDate) = 8 THEN 'AUG'
--			WHEN DATEPART(MONTH,@LastMonthDate) = 9 THEN 'SEP'
--			WHEN DATEPART(MONTH,@LastMonthDate) = 10 THEN 'OCT'
--			WHEN DATEPART(MONTH,@LastMonthDate) = 11 THEN 'NOV'
--			WHEN DATEPART(MONTH,@LastMonthDate) = 12 THEN 'DEC'
--      END )

--IF OBJECT_ID('TEMPDB..##AccountCal_HIST') IS NOT NULL
--DROP TABLE ##AccountCal_HIST
--CREATE Table ##AccountCal_HIST(CustomerACID varchar(30),
--                               AccountEntityID int,
--							   BranchCode VARCHAR(20),
--							   TotalProvision DECIMAL(22,2),
--							   RefCustomerID VARCHAR(50),
--							   SourceSystemCustomerID VARCHAR(50),
--							   UCIF_ID VARCHAR(50),
--							   EffectiveFromTimeKey int)
--Declare @SQL Varchar(1000) = 'Select CustomerAcID,AccountEntityID,BranchCode,TotalProvision,RefCustomerID,SourceSystemCustomerID,UCIF_ID,EffectiveFromTimeKey From YBL_ACS_'+@Year+'.DBO.AccountCal_Main_'+@YEAR+'_'+@Month+' Where EffectiveFromTimeKey = '+CAST(@LastMonthDateKey as varchar(5))--+'AND FinalAssetClassAlt_Key <> 1' --Commented by shubham on 2024-04-11 since bank will pass provision for all accounts

--Select @SQL
--Insert into  ##AccountCal_HIST
--EXEC (@SQL)-- To bechanged to dynamic view Partioning

IF OBJECT_ID('TEMPDB..#AbsProvMOC') IS NOT NULL
        DROP TABLE #AbsProvMOC

Create Table #AbsProvMOC
(
AccountEntityID			VARCHAR(30)
,UCIF_ID			        VARCHAR(30)
,CustomerID			    VARCHAR(30)
,SourceSystemCustomerID	VARCHAR(30)
,BranchCode			    VARCHAR(30)
,OriginalProvision	    VARCHAR(30)
,NetBalance	            VARCHAR(30)
,CustomerACID			VARCHAR(30)
,ExistingProvision    	VARCHAR(30)
,AdditionalProvision 	VARCHAR(30)
,FinalProvision	        VARCHAR(30)
,MOCREASON	            VARCHAR(500)
,AbsProvMOCEntityId      INT
,MOC_DATE               Date
)

/*-----------------Commented by Tarkeshwar Singh on 20th July---------------------------------------


SELECT 
		 C.value('./AccountEntityID			[1]','VARCHAR(30)') AccountEntityID --Columns added to Remove iterations by shubham on 2024-04-27
		,C.value('./UCIF_ID			[1]','VARCHAR(30)') UCIF_ID --Columns added to Remove iterations by shubham on 2024-04-27
		,C.value('./CustomerID			[1]','VARCHAR(30)') CustomerID --Columns added to Remove iterations by shubham on 2024-04-27
        ,C.value('./SourceSystemCustomerID			[1]','VARCHAR(30)') SourceSystemCustomerID --Columns added to Remove iterations by shubham on 2024-04-27
		,C.value('./BranchCode			[1]','VARCHAR(30)') BranchCode --Columns added to Remove iterations by shubham on 2024-04-27
		,CASE WHEN C.value('./OriginalProvision	[1]','VARCHAR(30)')= '' THEN NULL ELSE C.value('./OriginalProvision	[1]','DECIMAL(18,2)') END OriginalProvision --Columns added to Remove iterations by shubham on 2024-04-27
		,CASE WHEN C.value('./NetBalance	[1]','VARCHAR(30)')= '' THEN NULL ELSE C.value('./NetBalance	[1]','DECIMAL(18,2)') END NetBalance --Columns added to Remove iterations by shubham on 2024-04-27
		,C.value('./CustomerACID			[1]','VARCHAR(30)') CustomerAcID 
		,CASE WHEN C.value('./ExistingProvision	[1]','VARCHAR(30)')= '' THEN NULL ELSE C.value('./ExistingProvision	[1]','DECIMAL(18,2)') END ExistingProvision
		,CASE WHEN C.value('./AdditionalProvision	[1]','VARCHAR(30)')= '' THEN NULL ELSE C.value('./AdditionalProvision	[1]','DECIMAL(18,2)') END AdditionalProvision
		,CASE WHEN C.value('./FinalProvision	[1]','VARCHAR(30)')= '' THEN NULL ELSE C.value('./FinalProvision	[1]','DECIMAL(18,2)') END FinalProvision 
		,C.value('./MOCREASON	[1]','VARCHAR(500)')  MOCREASON --Added by Shubham on 2024-04-15 for addition of MOCREASON
		,C.value('./AbsProvMOCEntityId [1]','INT') AbsProvMOCEntityId 
		,@LastMonthDate as MOC_DATE

INTO #AbsProvMOC
FROM @XMLDocument.nodes('/DataSet/Gridrow') AS t(c)

*/

--select * from #AbsProvMOC
--Select

---------------Added by Tarkeshwar Singh on 20th July-----------------------------------------
 IF @OperationFlag in (1,2,3)
BEGIN


Insert into   #AbsProvMOC
(
AccountEntityID			
,UCIF_ID			   
,CustomerID			   
,SourceSystemCustomerID
,BranchCode			   
,OriginalProvision	   
,NetBalance	           
,CustomerACID			
,ExistingProvision    	
,AdditionalProvision 	
,FinalProvision	       
,MOCREASON	           
,AbsProvMOCEntityId 
,MOC_DATE
)
Select
AccountEntityID			
,UCIF_ID			    
,CustomerID			    
,SourceSystemCustomerID	
,BranchCode			    
,Case  when A.OriginalProvision='' then NULL else  cast(A.OriginalProvision	as decimal(18,2)) end OriginalProvision
,case when A.NetBalance='' then NULL else cast(A.NetBalance as decimal(18,2)) end NetBalance    
,CustomerACID			
,case when A.ExistingProvision='' then NULL else cast(A.ExistingProvision as decimal(18,2)) end    ExistingProvision    	
,case when A.AdditionalProvision='' then NULL else cast(A.AdditionalProvision as decimal(18,2)) end AdditionalProvision    	
,case when A.FinalProvision='' then NULL else cast(A.FinalProvision as decimal(18,2)) end FinalProvision   	        
,MOCREASON	            
,AbsProvMOCEntityId
,@LastMonthDate as MOC_DATE
from
AbsoluteProvisionMOC_Final A
where filename=@FilePathUpdated
END


IF @OperationFlag in (16,17)
BEGIN
Insert into   #AbsProvMOC
(
AccountEntityID			
,UCIF_ID			   
,CustomerID			   
,SourceSystemCustomerID
,BranchCode			   
,OriginalProvision	   
,NetBalance	           
,CustomerACID			
,ExistingProvision    	
,AdditionalProvision 	
,FinalProvision	       
,MOCREASON	           
,AbsProvMOCEntityId
,MOC_DATE
)
Select
AccountEntityID			
,UCIF_ID			    
,CustomerID			    
,SourceSystemCustomerID	
,BranchCode			    
,Case  when A.OriginalProvision='' then NULL else  cast(A.OriginalProvision	as decimal(18,2)) end OriginalProvision
,case when A.NetBalance='' then NULL else cast(A.NetBalance as decimal(18,2)) end NetBalance    
,CustomerACID			
,case when A.ExistingProvision='' then NULL else cast(A.ExistingProvision as decimal(18,2)) end    ExistingProvision    	
,case when A.AdditionalProvision='' then NULL else cast(A.AdditionalProvision as decimal(18,2)) end AdditionalProvision    	
,case when A.FinalProvision='' then NULL else cast(A.FinalProvision as decimal(18,2)) end FinalProvision   	        
,MOCREASON	            
,AbsProvMOCEntityId
,@LastMonthDate as MOC_DATE
from
AbsProvMOC_Auth A
where userid=@CrModApBy
END


--Select * from #AbsProvMOC
--Select * from AbsoluteProvisionMOC_Final
--------------------------------------------------------------------------------------------


IF @OperationFlag=1
BEGIN
	PRINT '1'
	IF EXISTS(
			Select 1 From DATAUPLOAD.AbsoluteBackdatedMOC_Mod  D
						INNER JOIN #AbsProvMOC GD 
						ON (EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey) 
							AND D.CustomerACID = GD.CustomerACID
							AND D.MOC_Date     = GD.MOC_DATE
						WHERE D.AuthorisationStatus in('MP','NP','DP','RM') )

	BEGIN
		PRINT 'EXISTS'
		Set @Result=-6
		SELECT DISTINCT @ErrorMsg=
								STUFF((SELECT distinct ', ' + CAST(CustomerACID as varchar(max))
								 FROM #AbsProvMOC t2
								 FOR XML PATH('')),1,1,'') 
							From DATAUPLOAD.AbsoluteBackdatedMOC_Mod  D
							INNER JOIN #AbsProvMOC GD 
								ON (EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey) 
								AND D.CustomerACID = GD.CustomerACID
								AND D.MOC_Date     = GD.MOC_DATE
							WHERE D.AuthorisationStatus in('MP','NP','DP','RM')  

		SET @ErrorMsg='Authorization Pending for CustomerACID '+CAST(@ErrorMsg AS VARCHAR(MAX))+' Please Authorize first'
		Return @Result
	END
	--ELSE 
	BEGIN	
		--SET @AbsProvMOCEntityId = 

		             ---Commented by Tarkeshwar on 25July02024--------

		 --SELECT @AbsProvMOCEntityId= MAX(AbsProvMOCEntityId)  FROM  
			--							(SELECT MAX(Entitykey) AbsProvMOCEntityId FROM DATAUPLOAD.AbsoluteBackdatedMOC
			--							 UNION 
			--							 SELECT MAX(Entitykey) AbsProvMOCEntityId FROM DATAUPLOAD.AbsoluteBackdatedMOC_Mod
			--							)A

			 ---Added by Tarkeshwar on 25July02024--------
        SELECT @AbsProvMOCEntityId=(Select IDENT_CURRENT('DATAUPLOAD.AbsoluteBackdatedMOC_Mod'))
		SET @AbsProvMOCEntityId = ISNULL(@AbsProvMOCEntityId,0)
		--SELECT @AbsProvMOCEntityId
	END
END

BEGIN TRY


BEGIN TRAN


Declare @AuthLevel int,@ApprovedByFirstLevel VARCHAR(50),@DateApprovedFirstLevel DATETIME

					---SELECT @AuthLevel=ISNULL(AuthLevel,1) FROM SysCRisMacMenu WHERE MenuId=@MenuId--Changed by shubham on 2024-03-14 due to column not available on UAT / Prodcution
				       Set @AuthLevel=1 -- Setting it by default to 1--Commented on 17 May by Tarkeshwar Singh & above line is uncommented
			

IF @OperationFlag=1 AND @AuthMode='Y'
	BEGIN
	         PRINT 2
			 SET @CreatedBy =@CrModApBy 
	         SET @DateCreated = GETDATE()
	         SET @AuthorisationStatus='NP'
	   
			GOTO AbsoluteProvisionMOC_Insert
	        AbsoluteProvisionMOC_Insert_Add:

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
					FROM DATAUPLOAD.AbsoluteBackdatedMOC D
					INNER JOIN  #AbsProvMOC GD	
					ON  D.CustomerACID = GD.CustomerACID
					AND D.AbsProvMOCEntityId=GD.AbsProvMOCEntityId
					AND D.MOC_Date	   = GD.MOC_DATE
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
		
				PRINT @CreatedBy
				PRINT @DateCreated
				IF ISNULL(@CreatedBy,'')=''
					BEGIN
						PRINT 44
						SELECT  @CreatedBy			= CreatedBy
									,@DateCreated	= DateCreated
							FROM DATAUPLOAD.AbsoluteBackdatedMOC_Mod D
							INNER JOIN  #AbsProvMOC GD	
							ON  D.CustomerACID = GD.CustomerACID
							AND D.AbsProvMOCEntityId=GD.AbsProvMOCEntityId
							AND D.MOC_Date     = GD.MOC_DATE
							WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
							AND    D.AuthorisationStatus IN('NP','MP','DP','RM')
	
																
					END
				ELSE ---IF DATA IS AVAILABLE IN MAIN TABLE
					BEGIN
						PRINT 'OperationFlag'
						----UPDATE FLAG IN MAIN TABLES AS MP
						UPDATE  D
						SET D.AuthorisationStatus=@AuthorisationStatus
						FROM DATAUPLOAD.AbsoluteBackdatedMOC D
						INNER JOIN  #AbsProvMOC GD 
						ON  D.CustomerACID		= GD.CustomerACID
						AND D.AbsProvMOCEntityId=GD.AbsProvMOCEntityId
						AND D.MOC_Date			= GD.MOC_DATE
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
					END
			IF @OperationFlag=2
				BEGIN	
					PRINT 'FM'	
					UPDATE  D
						SET D.AuthorisationStatus='FM'
						,D.ModifyBy=@Modifiedby
						,D.DateModified=@DateModified
					 
					FROM DATAUPLOAD.AbsoluteBackdatedMOC_Mod D
						INNER JOIN  #AbsProvMOC GD 
							ON  D.CustomerACID		= GD.CustomerACID
							AND D.AbsProvMOCEntityId=GD.AbsProvMOCEntityId
							AND D.MOC_Date			= GD.MOC_DATE
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						and D.AuthorisationStatus IN('NP','MP','DP','RM')
				END
				GOTO AbsoluteProvisionMOC_Insert
				AbsoluteProvisionMOC_Insert_Edit_Delete:
		 END 
ELSE IF @OperationFlag =3 AND @AuthMode ='N'
		BEGIN
				--SELECT * FROM ##DimBSCodeStructure
				-- DELETE WITHOUT MAKER CHECKER
						PRINT 'DELETE'					
						SET @Modifiedby   = @CrModApBy 
						SET @DateModified = GETDATE() 
						UPDATE D SET
									 ModifyBy =@Modifiedby 
									,DateModified =@DateModified 
									,EffectiveToTimeKey =@EffectiveFromTimeKey-1
								FROM DATAUPLOAD.AbsoluteBackdatedMOC D
						INNER JOIN  #AbsProvMOC GD	
							ON D.CustomerACID		= GD.CustomerACID
							AND D.AbsProvMOCEntityId=GD.AbsProvMOCEntityId
							AND D.MOC_Date			= GD.MOC_DATE
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)

						PRINT CAST(@@ROWCOUNT as VARCHAR(2))+SPACE(1)+'ROW DELETED'

				SET @RESULT=@AbsProvMOCEntityId

		END

ELSE IF @OperationFlag=17 AND @AuthMode ='Y' 
		BEGIN
				Print 'REJECT'
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE D
					SET AuthorisationStatus='R'
			---		,ApprovedByLevel1	 =@ApprovedBy-------Commented on 07 May 2024 & replaced by below code by Tarkeshwar Singh
			        ,ApprovedBy	 =@ApprovedBy
			---		,DateApprovedByLevel1=@DateApproved-----Commented on 07 May 2024 & replaced by below code by Tarkeshwar Singh
			        ,DateApproved=@DateApproved
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
				FROM DATAUPLOAD.AbsoluteBackdatedMOC_Mod D
						INNER JOIN  #AbsProvMOC GD	
							ON D.CustomerACID			= GD.CustomerACID
							AND D.AbsProvMOCEntityId=GD.AbsProvMOCEntityId
							AND D.MOC_Date			= GD.MOC_DATE
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						and D.AuthorisationStatus IN('NP','MP','DP','RM')


			IF EXISTS(Select 1 From DATAUPLOAD.AbsoluteBackdatedMOC D
						INNER JOIN #AbsProvMOC GD 
						ON (EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey) 
							AND  D.CustomerACID			= GD.CustomerACID
							AND  D.AbsProvMOCEntityId=GD.AbsProvMOCEntityId
							AND  D.MOC_Date			= GD.MOC_DATE
							)
					BEGIN

						UPDATE D
							SET AuthorisationStatus='A'
							FROM DATAUPLOAD.AbsoluteBackdatedMOC D
						INNER JOIN  #AbsProvMOC GD	
						ON D.CustomerACID			= GD.CustomerACID
						AND D.AbsProvMOCEntityId=GD.AbsProvMOCEntityId
						AND D.MOC_Date			= GD.MOC_DATE
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
								AND D.AuthorisationStatus IN('MP','DP','RM') 	


					END

--Delete from AbsoluteProvisionMOC_Final  where filename=@FilePathUpdated---- Added by Tarkeshwar on 24 July 2024
				
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
				FROM DATAUPLOAD.AbsoluteBackdatedMOC_Mod D
						INNER JOIN  #AbsProvMOC GD	
							ON D.CustomerACID			= GD.CustomerACID
							AND D.AbsProvMOCEntityId=GD.AbsProvMOCEntityId
							AND D.MOC_Date			= GD.MOC_DATE
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						and D.AuthorisationStatus IN('NP','MP','DP','RM','1A','1D')


			IF EXISTS(Select 1 From DATAUPLOAD.AbsoluteBackdatedMOC D
						INNER JOIN #AbsProvMOC GD 
						ON (EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey) 
							AND  D.CustomerACID			= GD.CustomerACID
							AND D.AbsProvMOCEntityId=GD.AbsProvMOCEntityId
							AND D.MOC_Date			= GD.MOC_DATE
							)
					BEGIN

						UPDATE D
							SET AuthorisationStatus='A'
							FROM DATAUPLOAD.AbsoluteBackdatedMOC D
						INNER JOIN  #AbsProvMOC GD	
						ON D.CustomerACID			= GD.CustomerACID
						AND D.AbsProvMOCEntityId=GD.AbsProvMOCEntityId
						AND D.MOC_Date			= GD.MOC_DATE
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
								AND D.AuthorisationStatus IN('MP','DP','RM','1D') 	


					END

--Delete from AbsoluteProvisionMOC_Final  where filename=@FilePathUpdated---- Added by Tarkeshwar on 24 July 2024

				
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
				FROM DATAUPLOAD.AbsoluteBackdatedMOC_Mod D
						INNER JOIN  #AbsProvMOC GD	
						ON   D.CustomerACID			= GD.CustomerACID
						AND D.AbsProvMOCEntityId=GD.AbsProvMOCEntityId
						AND D.MOC_Date			= GD.MOC_DATE
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
				SELECT @ExEntityKey= MAX(Entitykey) FROM DATAUPLOAD.AbsoluteBackdatedMOC_Mod D
						INNER JOIN  #AbsProvMOC GD	
							ON D.CustomerACID			= GD.CustomerACID
							AND D.AbsProvMOCEntityId=GD.AbsProvMOCEntityId
							AND D.MOC_Date			= GD.MOC_DATE
							WHERE (D.EffectiveFromTimeKey<=@Timekey and d.EffectiveToTimeKey>=@Timekey) 
							AND D.AuthorisationStatus IN('NP','MP','DP','RM')	

				SELECT	@DelStatus1=d.AuthorisationStatus
							,@CreatedBy=CreatedBy
							,@DateCreated=DATECreated
							,@ModifiedBy=ModifyBy
							, @DateModified=DateModified
					 FROM DATAUPLOAD.AbsoluteBackdatedMOC_Mod D
						INNER JOIN  #AbsProvMOC GD	
							ON D.CustomerACID			= GD.CustomerACID
							AND D.AbsProvMOCEntityId=GD.AbsProvMOCEntityId
							AND D.MOC_Date			= GD.MOC_DATE
						WHERE(D.EffectiveFromTimeKey<=@Timekey and d.EffectiveToTimeKey>=@Timekey)    
						AND Entitykey=@ExEntityKey
					

			IF @DelStatus1='DP'
				BEGIN 
					UPDATE D
					SET AuthorisationStatus='1D'
					,ApprovedByLevel1	 =@ApprovedBy
					,DateApprovedByLevel1=@DateApproved					
				FROM DATAUPLOAD.AbsoluteBackdatedMOC_Mod D
						INNER JOIN  #AbsProvMOC GD	
							ON D.CustomerACID			= GD.CustomerACID
							AND D.AbsProvMOCEntityId=GD.AbsProvMOCEntityId
							AND D.MOC_Date			= GD.MOC_DATE
						WHERE(D.EffectiveFromTimeKey<=@Timekey and d.EffectiveToTimeKey>=@Timekey)    
					
						and D.AuthorisationStatus IN('NP','MP','DP','RM')
					
				END 

				ELSE
				BEGIN 
				PRINT 'update in mode table for fist level authentication'
					
					UPDATE D
					SET AuthorisationStatus='1A'
					,ApprovedByLevel1	 =@ApprovedByFirstLevel
					,DateApprovedByLevel1=@DateApprovedFirstLevel					
				FROM DATAUPLOAD.AbsoluteBackdatedMOC_Mod D
						INNER JOIN  #AbsProvMOC GD	
							ON D.CustomerACID			= GD.CustomerACID
							AND D.AbsProvMOCEntityId=GD.AbsProvMOCEntityId
							AND D.MOC_Date			= GD.MOC_DATE
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
					             	FROM DATAUPLOAD.AbsoluteBackdatedMOC  D
									INNER JOIN  #AbsProvMOC GD	
									ON D.CustomerACID			= GD.CustomerACID
									AND D.AbsProvMOCEntityId=GD.AbsProvMOCEntityId
							        AND D.MOC_Date			= GD.MOC_DATE
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
					SELECT @ExEntityKey= MAX(Entitykey) FROM DATAUPLOAD.AbsoluteBackdatedMOC_Mod A
					 INNER JOIN #AbsProvMOC C
						ON (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
						 AND A.CustomerACID		 = C.CustomerACID
						 AND A.AbsProvMOCEntityId= C.AbsProvMOCEntityId
						 AND A.MOC_Date			 = C.MOC_DATE
						WHERE  a.AuthorisationStatus IN('NP','MP','DP','RM','1A','1D')	


					PRINT @@ROWCOUNT

					SELECT	@DelStatus=a.AuthorisationStatus
							,@CreatedBy=CreatedBy
							,@DateCreated=DATECreated
							,@ModifiedBy=ModifyBy
							, @DateModified=DateModified
					 FROM DATAUPLOAD.AbsoluteBackdatedMOC_Mod A
					  INNER JOIN #AbsProvMOC C
						ON (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey) 
						AND A.CustomerACID		 = C.CustomerACID
						AND A.AbsProvMOCEntityId = C.AbsProvMOCEntityId
						AND A.MOC_Date			 = C.MOC_DATE
						WHERE   Entitykey=@ExEntityKey
					
					SET @ApprovedBy = @CrModApBy			
					SET @DateApproved=GETDATE()

					 
				
					
					DECLARE @CurEntityKey INT=0

					SELECT @ExEntityKey= MIN(Entitykey) FROM DATAUPLOAD.AbsoluteBackdatedMOC_Mod A 
					 INNER JOIN #AbsProvMOC C
						ON (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey) 
						AND A.CustomerACID	   	 = C.CustomerACID
						AND A.AbsProvMOCEntityId = C.AbsProvMOCEntityId
						AND A.MOC_Date			 = C.MOC_DATE
						WHERE  a.AuthorisationStatus IN('NP','MP','DP','RM','1A','1D')	
				
					SELECT	@CurrRecordFromTimeKey=A.EffectiveFromTimeKey 
						 FROM DATAUPLOAD.AbsoluteBackdatedMOC_Mod A
						  INNER JOIN #AbsProvMOC C
						ON (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey) 
							AND A.CustomerACID		 = C.CustomerACID
							AND A.AbsProvMOCEntityId = C.AbsProvMOCEntityId
					    	AND A.MOC_Date			 = C.MOC_DATE
							AND Entitykey=@ExEntityKey
			
					UPDATE A
					
						SET  EffectiveToTimeKey =@CurrRecordFromTimeKey-1
						FROM DATAUPLOAD.AbsoluteBackdatedMOC_Mod A
						INNER JOIN #AbsProvMOC C
						ON (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey) 
						AND A.CustomerACID		 = C.CustomerACID
						AND A.AbsProvMOCEntityId = C.AbsProvMOCEntityId
						AND A.MOC_Date			 = C.MOC_DATE
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
										FROM DATAUPLOAD.AbsoluteBackdatedMOC_Mod G
										INNER JOIN #AbsProvMOC GD 
										ON  G.CustomerACID		 = GD.CustomerACID
										AND G.AbsProvMOCEntityId = GD.AbsProvMOCEntityId
					                	AND G.MOC_Date			 = GD.MOC_DATE
										--AND G.CounterPart_BranchCode	= GD.CounterPart_BranchCode
						                 WHERE G.AuthorisationStatus in('NP','MP','DP','RM','1D')

										PRINT 'BE'
						                  IF EXISTS(SELECT 1 FROM DATAUPLOAD.AbsoluteBackdatedMOC G
										INNER JOIN #AbsProvMOC GD 
										ON  G.CustomerACID		 = GD.CustomerACID
										AND G.AbsProvMOCEntityId = GD.AbsProvMOCEntityId
					                	AND G.MOC_Date			 = GD.MOC_DATE
										   WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) )
						                  BEGIN

												  PRINT 'EXPIRE'
								                   UPDATE G 
									               SET AuthorisationStatus ='A'
									          	    ,ModifyBy=@ModifiedBy
									          	    ,DateModified=@DateModified
									          	    ,ApprovedBy=@ApprovedBy
									          	    ,DateApproved=@DateApproved
									          	    ,EffectiveToTimeKey =@EffectiveFromTimeKey-1
													FROM DATAUPLOAD.AbsoluteBackdatedMOC G
													INNER JOIN #AbsProvMOC GD 
													ON  G.CustomerACID		 = GD.CustomerACID
													AND G.AbsProvMOCEntityId = GD.AbsProvMOCEntityId
					                				AND G.MOC_Date			 = GD.MOC_DATE
									               WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
											       	
										 END
									END
									ELSE 

									BEGIN
										 UPDATE G 
										 SET AuthorisationStatus ='A'
										 ,ApprovedBy=@ApprovedBy
										 ,DateApproved=@DateApproved
										 FROM DATAUPLOAD.AbsoluteBackdatedMOC_Mod G
										 INNER JOIN #AbsProvMOC GD 
											ON  G.CustomerACID		 = GD.CustomerACID
											AND G.AbsProvMOCEntityId = GD.AbsProvMOCEntityId
											AND G.MOC_Date			 = GD.MOC_DATE
										  WHERE G.AuthorisationStatus in('NP','MP','RM','1A')
									END
					END

						IF ISNULL(@DelStatus,'A') NOT IN('DP','1D') OR @AuthMode ='N'
									BEGIN
											
											PRINT @AuthorisationStatus +'AuthorisationStatus'	
                                             PRINT @AUTHMODE +'Authmode'


											 SET  @AuthorisationStatus ='A' 
										
                                                   DELETE G
                                                        FROM DATAUPLOAD.AbsoluteBackdatedMOC G
                                                       INNER JOIN #AbsProvMOC GD ON (G.EffectiveFromTimeKey<=@TimeKey AND G.EffectiveToTimeKey>=@TimeKey )
													    AND G.CustomerACID		 = GD.CustomerACID
														AND G.AbsProvMOCEntityId = GD.AbsProvMOCEntityId
														AND G.MOC_Date			 = GD.MOC_DATE
                                                       WHERE G.EffectiveFromTimeKey=@EffectiveFromTimeKey  --and ISNULL(GD.AuthorisationStatus,'A')<>'DP'
													


													print 'ROW deleted'+CAST(@@ROWCOUNT AS VARCHAR(10)) +'Deleted'
													
													
                                                    UPDATE G
                                                       SET  
													   G.EffectiveTOTimeKey=@EffectiveFromTimeKey-1
													   ,G.AuthorisationStatus ='A'  --ADDED ON 12 FEB 2018
                                                       FROM DATAUPLOAD.AbsoluteBackdatedMOC G
                                                       INNER JOIN #AbsProvMOC GD ON (G.EffectiveFromTimeKey<=@TimeKey AND G.EffectiveToTimeKey>=@TimeKey )
														AND G.CustomerACID			= GD.CustomerACID
														AND G.AbsProvMOCEntityId    = GD.AbsProvMOCEntityId
														AND G.MOC_Date			    = GD.MOC_DATE
                                                       WHERE G.EffectiveFromTimeKey<@EffectiveFromTimeKey  --and ISNULL(GD.AuthorisationStatus,'A')<>'DP'
													
													print 'ROW deleted'+CAST(@@ROWCOUNT AS VARCHAR(10))

												
												IF @AuthMode='N' 
												BEGIN
													SET @AuthorisationStatus='A'
												END
												INSERT INTO DATAUPLOAD.AbsoluteBackdatedMOC
														(
														 AbsProvMOCEntityId
														,AccountEntityID
														,MOC_Date
														,UCIF_ID
														,CustomerID
														,SourceSystemCustomerID
														,Netbalance --Columns added to Remove iterations by shubham on 2024-04-27
														,OriginalProvision --Columns added to Remove iterations by shubham on 2024-04-27
														,CustomerACID
														,BranchCode
														,AdditionalProvision
														,ExistingProvision
														,FinalProvision
														,MOCREASON --Added by Shubham on 2024-04-15 for addition of MOCREASON
														,AuthorisationStatus
														,EffectiveFromTimeKey
														,EffectiveToTimeKey
														,CreatedBy
														,DateCreated
														,ModifyBy
														,DateModified
														,ApprovedBy
														,DateApproved
														)
													SELECT
													 	 AbsProvMOCEntityId
														,s.AccountEntityID
														,s.MOC_DATE
														,s.UCIF_ID
														,s.CustomerID
														,s.SourceSystemCustomerID
														,s.NetBalance --Columns added to Remove iterations by shubham on 2024-04-27
														,s.OriginalProvision --Columns added to Remove iterations by shubham on 2024-04-27
													    ,S.CustomerAcID
														,s.BranchCode
														,s.AdditionalProvision
														,s.ExistingProvision--TotalProvision --Changed by shubham on 2024-04-12 Against observation for Existing Provision
														,s.FinalProvision
														,s.MOCREASON --Added by Shubham on 2024-04-15 for addition of MOCREASON
														,CASE WHEN @AuthMode ='Y' THEN @AuthorisationStatus ELSE NULL END
														,@EffectiveFromTimeKey
														,@EffectiveToTimeKey
														,@CreatedBy
														,@DateCreated
														,@ModifiedBy
														,@DateModified
														,CASE WHEN @AuthMode ='Y' THEN @ApprovedBy ELSE NULL END
														,CASE WHEN @AuthMode ='Y' THEN @DateApproved ELSE NULL END
												FROM #AbsProvMOC S 
												--inner join ##AccountCal_Hist a  --Code Commented to Remove iterations by shubham on 2024-04-27
											 --   on s.CustomerAcID = a.CustomerAcID
											 --   AND a.EffectiveFromTimeKey = @LastMonthDateKey 
									
										END


	IF @AUTHMODE='N'
			BEGIN
					SET @AuthorisationStatus='A'
					GOTO AbsoluteProvisionMOC_Insert
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
									@AbsProvMOCEntityId,-- ReferenceID ,
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
								@AbsProvMOCEntityId ,-- ReferenceID ,
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


AbsoluteProvisionMOC_Insert:
PRINT 'A1'
--SELECT  @ErrorHandle
IF @ErrorHandle=0
								
  	BEGIN
		
								Print 'insert into DATAUPLOAD.AbsoluteBackdatedMOC_Mod'

									PRINT '@ErrorHandle'
									INSERT INTO DATAUPLOAD.AbsoluteBackdatedMOC_Mod
											(
											AbsProvMOCEntityId
											,AccountEntityID
											,MOC_Date
											,UCIF_ID
											,CustomerID
											,SourceSystemCustomerID
											,Netbalance --Columns added to Remove iterations by shubham on 2024-04-27
											,OriginalProvision --Columns added to Remove iterations by shubham on 2024-04-27
											,CustomerACID
											,BranchCode
											,AdditionalProvision
											,ExistingProvision
											,FinalProvision
											,MOCREASON --Added by Shubham on 2024-04-15 for addition of MOCREASON
											,AuthorisationStatus
											,EffectiveFromTimeKey
											,EffectiveToTimeKey
											,CreatedBy
											,DateCreated
											,ModifyBy
											,DateModified
											,ApprovedBy
											,DateApproved
												)
										SELECT
											 @AbsProvMOCEntityId+ROW_NUMBER()OVER(ORDER BY (SELECT 1))
											,s.AccountEntityID
											,s.MOC_DATE
											,s.UCIF_ID
											,S.CustomerID
											,s.SourceSystemCustomerID
											,s.NetBalance --Columns added to Remove iterations by shubham on 2024-04-27
											,s.OriginalProvision --Columns added to Remove iterations by shubham on 2024-04-27
										    ,S.CustomerAcID
											,s.BranchCode
											,s.AdditionalProvision
											,s.ExistingProvision--TotalProvision --Changed by shubham on 2024-04-12 Against observation for Existing Provision
										    ,s.FinalProvision
											,s.MOCREASON --Added by Shubham on 2024-04-15 for addition of MOCREASON
											,CASE WHEN @AuthMode ='Y' THEN @AuthorisationStatus ELSE NULL END
											,@EffectiveFromTimeKey
											,@EffectiveToTimeKey
											,@CreatedBy
											,@DateCreated
											,@ModifiedBy
											,@DateModified
											,CASE WHEN @AuthMode ='Y' THEN @ApprovedBy ELSE NULL END
											,CASE WHEN @AuthMode ='Y' THEN @DateApproved ELSE NULL END
											FROM #AbsProvMOC S 
											--inner join ##AccountCal_Hist a  --Code Commented to Remove iterations by shubham on 2024-04-27
											--	on s.CustomerAcID = a.CustomerAcID
											--	AND a.EffectiveFromTimeKey = @LastMonthDateKey 
							
								PRINT CAST(@@ROWCOUNT AS VARCHAR)+'INSERTED'
								

				IF @OperationFlag =1 AND @AUTHMODE='Y'
					BEGIN
						PRINT 3
						GOTO AbsoluteProvisionMOC_Insert_Add
					END
				ELSE
				 IF (@OperationFlag =2 OR @OperationFlag =3) AND @AUTHMODE='Y'

					BEGIN
						GOTO AbsoluteProvisionMOC_Insert_Edit_Delete
					END

	END			
	
 COMMIT TRANSACTION
IF @OperationFlag <>3
	BEGIN
	
		SELECT @D2Ktimestamp=CAST(D2Ktimestamp AS INT) FROM DATAUPLOAD.AbsoluteBackdatedMOC_Mod D
							--INNER JOIN #AbsoluteProvisionMOC T	ON	D.AbsoluteProvisionMOCAlt_key = T.AbsoluteProvisionMOCAlt_key
							WHERE (EffectiveFromTimeKey<=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) 



									

	
			SET @RESULT=1
			Return  @RESULT
			Return @D2Ktimestamp
END

ELSE
		BEGIN
				SET @Result=0
				Return  @RESULT
		END
		
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE() ERRORDESC
	ROLLBACK TRAN
	

		
	SET @RESULT=-1
	
	Return @RESULT

		

END  CATCH

	


END						            


GO