SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROC [dbo].[UserTwoFactorCheckInfo_bkp_RDB]   
@Count as Int,  
@UserLoginId as Varchar(20),  
@Answer as Varchar(2000),  
@QuestionID as Int,
@IPAdress VARCHAR(20),  
@LoginTime SMALLDATETIME,  
@LogoutTime SMALLDATETIME,
@Result     INT    =0 OUTPUT    
  
AS  
  
BEGIN  
  
--Declare @Count as Int=3,  
--  @UserLoginId as Varchar(20)='mismaker',  
--  @Answer as Varchar(2000)='ABCD',  
--  @QuestionID as Int=1  
  
  
  
  IF OBJECT_ID('TempDB..#UserInfo') Is Not Null  
  Drop Table #UserInfo  
  
  Select QuestionID,UserLoginID,Answer   
  Into #UserInfo   
  from UserTwoFactorInfo   
  Where QuestionID=@QuestionID   
  And UserLoginID=@UserLoginId   
  And Answer=@Answer  
  
  
  Declare @Cnt as Int   
  
  Set @Cnt=(Select ISNUll(count(*),0) from #UserInfo)  
  
  IF @Cnt>0  
  
  BEGIN  
     
  SELECT 'The Given Answer is Correct'  
  SELECT 1  
     
    
  
  END  
  
  ELSE IF @Cnt=0  
  
  BEGIN  
  INSERT INTO  UserLoginHistory  
      (  
       UserID  
       ,IP_Address  
       ,LoginTime  
       ,LogoutTime  
       ,DurationMin  
       ,LoginSucceeded  
      )  
    VALUES  
     (  
      @UserLoginId,  
      @IPAdress,  
      @LoginTime,  
      @LogoutTime,
      NULL,  
      'W'  
     )
  
  Select 'The Answer is Incorrect. Try once Again or select Another Question'  
  SELECT 2  
      
  END  
  

  DECLARE @WCount INT=0
  DECLARE @MaxW INT=(select MAX(EntityKey) from [dbo].[UserLoginHistory]
  WHERE UserID=@UserLoginId AND LoginSucceeded='W')
  DECLARE @MaxY INT=(select MAX(EntityKey) from [dbo].[UserLoginHistory]
  WHERE UserID=@UserLoginId AND LoginSucceeded='Y')
  
  IF(@MaxW>@MaxY)
  BEGIN
  
  SELECT @WCount=COUNT(*) FROM [dbo].[UserLoginHistory]
  WHERE UserID=@UserLoginId AND LoginSucceeded='W'
  AND EntityKey>@MaxY
  
  END

  IF (@WCount >= 3 AND @cnt=0)
  
  BEGIN
  		PRINT 'SUSPEND'
  		UPDATE DimUserInfo SET SuspendedUser='Y',UserLogged=0
  			WHERE  UserLoginID=@UserLoginId AND EffectiveToTimeKey=49999
  
  END

  
  IF @Count=3 And @cnt=0  
  
  BEGIN  
  
  --Select UserLoginID,SuspendedUser   
  Update DimuserInfo set SuspendedUser='Y' from DimuserInfo where UserLoginID=@UserLoginId And EffectiveToTimeKey=49999  
  
  
  Select 'You have exceeded permitted attempts. Kindly contact system administrator.'  
   SELECT 2  
         
  END  
  
  
  
END  
  
GO