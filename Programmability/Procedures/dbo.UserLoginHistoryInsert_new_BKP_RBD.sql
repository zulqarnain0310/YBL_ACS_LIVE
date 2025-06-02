SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[UserLoginHistoryInsert_new_BKP_RBD]  
 @UserID VARCHAR(20),  
 @IPAdress VARCHAR(20),  
 @LoginTime SMALLDATETIME,  
 @LogoutTime SMALLDATETIME,  
 @LoginSucceeded CHAR(1),  
 @Result int = -1 output,  
 @LastLoginOut VARCHAR(200) output,  
 @LastUnsuccessfulAttempt VARCHAR(200) output  
AS  
  
 DECLARE @UNLOGON AS SMALLINT  
 Declare @TimeKey INT  
 Declare @TimeKeyCurrent INT  
BEGIN  
  
 -- SET @TimeKey = (SELECT  TimeKey  FROM    SysDataMatrix WHERE  CurrentStatus = 'C' )  
  
 --By Komal  
  
 SET @TimeKey = (SELECT  TimeKey  FROM   SysDayMatrix WHERE CAST (DATE AS DATE)= CAST (GETDATE() AS Date))  
  
 select @TimeKeyCurrent =TimeKey from sysdaymatrix where date=convert(date,getdate(),103)  
 SET @UNLOGON = (SELECT ParameterValue FROM  DimUserParameters  
     WHERE (EffectiveFromTimeKey < = @TimeKey  AND EffectiveToTimeKey  > = @TimeKey)  
     AND ShortNameEnum='UNLOGON')  
 Print @UNLOGON  
   
 SELECT @LastLoginOut= 'Last Successful login at ' +Convert(Varchar(5),CONVERT(TIME,MAX(LoginTime))) +' on '+ CONVERT(varchar(11),MAX(LoginTime),100)   
 FROM  UserLoginHistory   
 WHERE UserID=@UserID   AND LoginSucceeded='Y'
  
 IF @LastLoginOut = '' OR @LastLoginOut IS NULL  
  SET @LastLoginOut = 'Last Successful login at  00:00'  
 
 
 SELECT @LastUnsuccessfulAttempt= 'Last Unsuccessful login at ' +Convert(Varchar(5),CONVERT(TIME,MAX(LoginTime))) +' on '+ CONVERT(varchar(11),MAX(LoginTime),100)   
 FROM  UserLoginHistory   
 WHERE UserID=@UserID  AND (LoginSucceeded='W' OR LoginSucceeded='N')

 IF @LastUnsuccessfulAttempt = '' OR @LastUnsuccessfulAttempt IS NULL  
  SET @LastUnsuccessfulAttempt = 'Last Unsuccessful login at 00:00'  


 IF(@LoginSucceeded='Y')  
  BEGIN  
     BEGIN TRANSACTION  
  BEGIN TRY  
  PRINT 'INSERT IN UserLoginHistoryTable'  
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
      @UserID,  
      @IPAdress,  
      @LoginTime,  
      @LogoutTime,  ----change (as Discussed with Amol)  
      NULL,  
      @LoginSucceeded  
     )  
	 --Changes by Sunny for Security Audit Point on 08-Feb-2023
      --UPDATE UserLoginHistory SET LoginSucceeded='Y'  
      --    WHERE  UserID=@UserID  
      --    AND LoginSucceeded='W'  
      Update  DimUserInfo SET UserLogged=1 ,CurrentLoginDate=GETDATE()   
      where (EffectiveFromTimeKey<=@TimeKeyCurrent AND EffectiveToTimeKey>=@TimeKeyCurrent)  
      AND   UserLoginID=@UserID  
  
   COMMIT TRANSACTION  
  END TRY  
  BEGIN CATCH  
   PRINT 'error'  
   PRINT ERROR_MESSAGE()  
   ROLLBACK TRANSACTION  
   SET @Result= -1  
   RETURN -1  
   SELECT -1  
  END CATCH  
   SELECT @Result = MAX(EntityKey) FROM  UserLoginHistory   
   WHERE UserID=@UserID  
    AND IP_Address=@IPAdress  
    AND LoginTime=@LoginTime  
    AND LoginSucceeded=@LoginSucceeded  
  END  
  
  
 ELSE IF(@LoginSucceeded='W')  
  BEGIN  
     BEGIN TRANSACTION  
  BEGIN TRY  
  PRINT 'INSERTING INTO UserLoginHistory For Login Succeeded W'  
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
      @UserID,  
      @IPAdress,  
      @LoginTime,  
      NULL,  
      NULL,  
      @LoginSucceeded  
     )  
   PRINT 'Insertion Done'  
     IF ((SELECT COUNT(LoginSucceeded) FROM UserLoginHistory   
               WHERE  UserID=@UserID  AND LoginSucceeded='W'  
               AND LoginSucceeded=@LoginSucceeded) >= @UNLOGON )  
  
     BEGIN  
       
      UPDATE DimUserInfo SET SuspendedUser='Y',UserLogged=0  
          WHERE  UserLoginID=@UserID AND (EffectiveFromTimeKey < = @TimeKey  AND EffectiveToTimeKey  > = @TimeKey)  
  
     END  
  
   COMMIT TRANSACTION  
  END TRY  
  BEGIN CATCH  
   PRINT 'error'  
   PRINT ERROR_MESSAGE()  
   ROLLBACK TRANSACTION  
   SET @Result= -1  
   RETURN -1  
   SELECT -1  
  END CATCH  
  
  
   DECLARE @LastLoginKey INT  
   PRINT 'A'  
   SELECT @LastLoginKey=MAX(EntityKey) FROM  UserLoginHistory   
    WHERE  UserID=@UserID  
      AND LoginSucceeded='Y'  
   SET @LastLoginKey=ISNULL(@LastLoginKey,0)  
   SELECT @Result=COUNT(LoginSucceeded)  
       FROM UserLoginHistory   
       WHERE  UserID=@UserID  
      AND LoginSucceeded='W'  
      AND EntityKey>@LastLoginKey  
    
     
  
  END  
  
 ELSE  
  begin  
  BEGIN TRANSACTION  
  BEGIN TRY  
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
     @UserID,  
     @IPAdress,  
     @LoginTime,  
     @LogoutTime,  
     NULL,  
     @LoginSucceeded  
     )  
     
  COMMIT TRANSACTION  
  END TRY  
  BEGIN CATCH  
   PRINT 'error'  
   PRINT ERROR_MESSAGE()  
   ROLLBACK TRANSACTION  
   SET @Result= -1  
   RETURN -1  
   SELECT -1  
  END CATCH  
     
  
  
   SELECT  @Result =  MAX(EntityKey) FROM  UserLoginHistory   
  WHERE  UserID=@UserID  
   AND IP_Address=@IPAdress  
   AND LoginTime=@LoginTime  
   AND LoginSucceeded=@LoginSucceeded  
    
  END  
END  
  
  
--SELECT * FROM  UserLoginHistory   
  
  
  
  
  
  
  
GO