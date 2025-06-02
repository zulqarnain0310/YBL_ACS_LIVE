SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROC [dbo].[UserResponseInsert]
--declare
 @XMLDocument  XML=N'',
 @UserLoginID Varchar(20)='DM735'
 ,@Result			   INT=0 output


As
BEGIN
	BEGIN TRY
	 BEGIN TRAN


      DECLARE
	    @EntityId				INT
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

	   ,@EffectiveFromTimeKey INT=0
      ,@EffectiveToTimeKey   INT=0
	 
	 SET @EffectiveFromTimeKey=1400
	 SET @EffectiveToTimeKey = 49999
	 set DATEFORMAT DMY
IF OBJECT_ID('Tempdb..#UploadEntry') IS NOT NULL
DROP TABLE #UploadEntry
 
SELECT 
C.value('./FavPlace								    [1]','VARCHAR(100)'	 )FavPlace
,C.value('./CollageName							    [1]','VARCHAR(100)'	 )CollageName
,C.value('./LastName						        [1]','VARCHAR(100)'	 )LastName
,C.value('./firstvehicle						    [1]','VARCHAR(100)'	 )firstvehicle
,C.value('./CityName						        [1]','VARCHAR(100)'	 )CityName
,C.value('./favcolor					            [1]','VARCHAR(100)'	 )favcolor

,C.value('./BirthYear						        [1]','VARCHAR(100)'	 )BirthYear
,C.value('./PetName						            [1]','VARCHAR(100)'	 )PetName
,C.value('./quest1					                [1]','VARCHAR(100)'	 )quest1


,C.value('./quest2						           [1]','VARCHAR(100)'	 )quest2
,C.value('./quest3						           [1]','VARCHAR(100)'	 )quest3
,C.value('./quest4						           [1]','VARCHAR(100)'	 )quest4
,C.value('./quest5					               [1]','VARCHAR(100)'	 )quest5

,C.value('./quest6						           [1]','VARCHAR(100)'	 )quest6
,C.value('./quest7						           [1]','VARCHAR(100)'	 )quest7
,C.value('./quest8					               [1]','VARCHAR(100)'	 )quest8
INTO #UploadEntry

FROM @XMLDocument.nodes('/root') AS t(c)

--print 'revert'

--

/*ADDED BY ZAIN ON 20241014 AS OF PRODUCTION AUDIT OBSERVATION REPORTED ON TEAMS BY TEJAS HALKATTI GETTING EXPIRING OLD RECORDS*/
IF(
	(SELECT COUNT(1) FROM USERTWOFACTORINFO WHERE USERLOGINID=@UserLoginID)>0
	)
	BEGIN
		UPDATE USERTWOFACTORINFO SET EFFECTIVETOTIMEKEY=(SELECT TIMEKEY-1 FROM SYSDATAMATRIX WHERE CURRENTSTATUS='C') 
									,ModifyBy=@UserLoginID
									,DateModified=GETDATE()
		WHERE USERLOGINID=@UserLoginID
		AND EffectiveToTimeKey=49999
	END
/*ADDED BY ZAIN ON 20241014 AS OF PRODUCTION AUDIT OBSERVATION REPORTED ON TEAMS BY TEJAS HALKATTI END*/


/*INSERTION OF NEW RECORDS*/
Insert INTO UserTwoFactorInfo(UserLoginID,	QuestionID,	Answer,EffectiveFromTimeKey	,EffectiveToTimeKey,CreatedBy,DateCreated)
Select @UserLoginID,quest1,FavPlace,@EffectiveFromTimeKey,@EffectiveToTimeKey,'D2k',Getdate()
from #UploadEntry


Insert INTO UserTwoFactorInfo(UserLoginID,	QuestionID,	Answer,EffectiveFromTimeKey	,EffectiveToTimeKey,CreatedBy,DateCreated)
Select @UserLoginID,quest2,CollageName,@EffectiveFromTimeKey,@EffectiveToTimeKey,'D2k',Getdate()
from #UploadEntry

Insert INTO UserTwoFactorInfo(UserLoginID,	QuestionID,	Answer,EffectiveFromTimeKey	,EffectiveToTimeKey,CreatedBy,DateCreated)
Select @UserLoginID,quest3,LastName,@EffectiveFromTimeKey,@EffectiveToTimeKey,'D2k',Getdate()
from #UploadEntry

Insert INTO UserTwoFactorInfo(UserLoginID,	QuestionID,	Answer,EffectiveFromTimeKey	,EffectiveToTimeKey,CreatedBy,DateCreated)
Select @UserLoginID,quest4,firstvehicle,@EffectiveFromTimeKey,@EffectiveToTimeKey,'D2k',Getdate()
from #UploadEntry

Insert INTO UserTwoFactorInfo(UserLoginID,	QuestionID,	Answer,EffectiveFromTimeKey	,EffectiveToTimeKey,CreatedBy,DateCreated)
Select @UserLoginID,quest5,CityName,@EffectiveFromTimeKey,@EffectiveToTimeKey,'D2k',Getdate()
from #UploadEntry


Insert INTO UserTwoFactorInfo(UserLoginID,	QuestionID,	Answer,EffectiveFromTimeKey	,EffectiveToTimeKey,CreatedBy,DateCreated)
Select @UserLoginID,quest6,favcolor,@EffectiveFromTimeKey,@EffectiveToTimeKey,'D2k',Getdate()
from #UploadEntry



Insert INTO UserTwoFactorInfo(UserLoginID,	QuestionID,	Answer,EffectiveFromTimeKey	,EffectiveToTimeKey,CreatedBy,DateCreated)
Select @UserLoginID,quest7,BirthYear,@EffectiveFromTimeKey,@EffectiveToTimeKey,'D2k',Getdate()
from #UploadEntry

Insert INTO UserTwoFactorInfo(UserLoginID,	QuestionID,	Answer,EffectiveFromTimeKey	,EffectiveToTimeKey,CreatedBy,DateCreated)
Select @UserLoginID,quest8,PetName,@EffectiveFromTimeKey,@EffectiveToTimeKey,'D2k',Getdate()
from #UploadEntry

/*INSERTION OF NEW RECORDS END*/

 COMMIT TRANSACTION

	SET @RESULT=1
	RETURN  @RESULT

	
END TRY
    BEGIN CATCH
	    SELECT ERROR_MESSAGE() ERRORDESC,ERROR_LINE() as LineNum
		ROLLBACK TRAN
		SET @RESULT=-1
		RETURN @RESULT
		
END  CATCH
END		
			            


GO