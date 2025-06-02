SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROC [dbo].[USERQuestionaireDropDown]
@UserLoginId as Varchar(20)
AS

BEGIN


IF OBJECT_ID('TempDB..#UserInfo') Is Not Null
		Drop Table #UserInfo
		 
		Select QuestionID,UserLoginID,Answer 
		Into #UserInfo 
		from UserTwoFactorInfo 
		Where UserLoginID=@UserLoginId and EffectiveToTimeKey=49999 
		
		Declare @Cnt as Int 

		Set @Cnt=(Select ISNUll(count(*),0) from #UserInfo)

		IF @Cnt=8

		BEGIN

		SELECT 'User is Registered' as RegisterStatus

		END

		ELSE IF @Cnt<8

		BEGIN

		Select 'User is Not Registered' as RegisterStatus

		END


SELECT 
QUESTIONID,QUESTIONDESCRIPTION
FROM DIMUSERQUESTIONMASTER WHERE EFFECTIVETOTIMEKEY=49999

END
GO