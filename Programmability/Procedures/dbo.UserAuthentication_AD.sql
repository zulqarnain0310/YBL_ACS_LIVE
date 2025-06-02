SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


Create PROCEDURE [dbo].[UserAuthentication_AD] 
	
	@UserLoginID varchar(20),
	@LoginPassword varchar(100)='',
	@authType char(1)='DB',
	@AuthSuccess char(1)='N'
AS 

--DECLARE
--	@UserLoginID varchar(20)='dm585',
--	@LoginPassword varchar(100)='',
--	@authType char(1)='AD',
--	@AuthSuccess char(1)='Y'


BEGIN
		Declare @TimeKey INT
		DECLARE @NONUSE AS SMALLINT
		DECLARE @LoginDate AS SMALLDATETIME
		DECLARE @Suspended AS SMALLINT		
		DECLARE @PwdChangeDate AS SMALLDATETIME
		DECLARE @PWDCHNG AS SMALLINT
		DECLARE @ExpiredUserDay AS SMALLINT
	    DECLARE @DateCreated AS SMALLDATETIME
		DECLARE @SuspendedUser AS char(1)='N'
		DECLARE @UserLogged AS bit=0
		DECLARE @LastRequestTime AS DATETIME
		DECLARE @LastRequestDiff AS INT -- Changed by Sunny on 16/07/2022
		DECLARE @SessionTimeout INT -- Added by Sunny on 02/06/2022

 	  IF OBJECT_ID('Tempdb..##tmpUserInfo')	IS NOT NULL
		BEGIN
			DROP TABLE ##tmpUserInfo
		END   
	   

	   --  SET @TimeKey =(SELECT  TimeKey  FROM    SysDataMatrix_New WHERE  CurrentStatus = 'C' )
	   print 01
	   SET @TimeKey=(SELECT TimeKey FROM SysDayMatrix WHERE CAST(Date AS DATE)=CAST(GETDATE() AS DATE))
		SET @NONUSE=(SELECT ParameterValue FROM  DimUserParameters
			WHERE (EffectiveFromTimeKey < = @TimeKey  AND EffectiveToTimeKey  > = @TimeKey)
				  AND ShortNameEnum='NONUSE')
				  
		PRINT '@NONUSE: ' + CAST(@NONUSE AS VARCHAR(100))
	print 02
		SET @PWDCHNG=(SELECT ParameterValue  FROM  DimUserParameters
			WHERE (EffectiveFromTimeKey < = @TimeKey  AND EffectiveToTimeKey  > = @TimeKey)
				  AND ShortNameEnum='PWDCHNG')
		PRINT '@PWDCHNG: ' + CAST(@PWDCHNG AS VARCHAR(100))
		 		
		print 0
		SELECT  @LoginDate=CurrentLoginDate,
				 @PwdChangeDate=PasswordChangeDate,
				 @DateCreated=DateApproved,
				 @SuspendedUser=SuspendedUser,
				  @UserLogged=UserLogged,
				  @LastRequestTime = LastRequestTime
		FROM DimUserInfo
			WHERE (EffectiveFromTimeKey < = @TimeKey AND EffectiveToTimeKey  > = @TimeKey)
				  AND UserLoginID =@UserLoginID

		--SET SessionTimeout -- Added by Sunny on 02/06/2022
		SELECT @SessionTimeout=ParameterValue FROM SysSolutionParameter WHERE (EffectiveFromTimeKey < = @TimeKey  AND EffectiveToTimeKey  > = @TimeKey)
		AND ParameterAlt_Key=201 
		
		PRINT '@LoginDate: ' + CAST(@LoginDate AS VARCHAR(100))
		PRINT '@PwdChangeDate: ' + CAST(@PwdChangeDate AS VARCHAR(100))
		PRINT '@DateCreated: ' + CAST(@DateCreated AS VARCHAR(100))
		PRINT '@UserLogged: ' + CAST(@UserLogged AS VARCHAR(100))

		IF  @LoginDate IS NOT NULL
			BEGIN
				SET @Suspended= (SELECT datediff(d,@LoginDate,GETDATE()) AS 'Days')
			END
		ELSE
			BEGIN
				SET @Suspended= (SELECT datediff(d,@DateCreated,GETDATE()) AS 'Days')
			END
		
		
		IF	@PwdChangeDate IS NOT NULL
			BEGIN
				SET @ExpiredUserDay= (SELECT datediff(d,@PwdChangeDate,GETDATE()) AS 'Days')
			END
	    ELSE
			BEGIN
				SET @ExpiredUserDay= (SELECT datediff(d,@DateCreated,GETDATE()) AS 'Days')
			END
		 PRINT 1

		 ----------------Added for user logged update on basis of last request time .05/06/2022
		 PRINT '@LastRequestTime'
		 PRINT @LastRequestTime
		 set @LastRequestDiff = (SELECT datediff(MINUTE,@LastRequestTime,GETDATE()))
		 PRINT '@LastRequestDiff'
		 PRINT @LastRequestDiff
		 Print @UserLogged
		 IF @UserLogged=1 
		 BEGIN
			 IF  @LastRequestDiff > @SessionTimeout			--set Session time out -- @SessionTimeout Added by Sunny on 02/06/2022
				BEGIN
				print 'userlogged0'
					Update DimUserInfo set Userlogged = 0  where UserLoginID = @UserLoginID;
				END
			ELSE
				BEGIN
				print 'userlogged1'
					Update DimUserInfo set Userlogged = 1  where UserLoginID = @UserLoginID;
				END
		END

		--Update DimUserInfo set Userlogged = 0  where UserLoginID = @UserLoginID;

		---------------------------------------------------------------------------------
		 
		PRINT '@Suspended: ' + CAST(@Suspended AS VARCHAR(100))
		PRINT '@ExpiredUserDay: ' + CAST(@ExpiredUserDay AS VARCHAR(100))
		print 'NONUSE'
		print @NONUSE
		IF @Suspended>@NONUSE AND @NONUSE<>0 
		BEGIN              
		UPDATE  DimUserInfo         
			SET   SuspendedUser='Y' 
	 			WHERE (EffectiveFromTimeKey < = @TimeKey AND EffectiveToTimeKey  > = @TimeKey)
					  AND UserLoginID=@UserLoginID
		END

		 IF @AuthSuccess='N'
		 BEGIN
		 PRINT 'Started In AuthSuccess N Mode'
			IF @Suspended>@NONUSE AND @NONUSE<>0 
				BEGIN
				 PRINT 2               
				UPDATE  DimUserInfo         
					SET   SuspendedUser='Y' 
	 					WHERE (EffectiveFromTimeKey < = @TimeKey AND EffectiveToTimeKey  > = @TimeKey)
							  AND UserLoginID=@UserLoginID		--AND @authType<> 'AD'				
	 				
				------SELECT  'SUSPEND' AS SUSPEND ,'NOTExpiredUser' AS ExpiredUser

				SELECT  NULL AS UserLoginID,
						NULL AS UserName,
						LoginPassword,
						NULL AS UserLocation,
						NULL AS UserLocationName,
						NULL AS UserLocationCode,
						CAST(0 AS SMALLINT) AS UserRoleALT_Key,
						CAST(0 AS SMALLINT) AS UserRole_Key,
						NULL AS PasswordChanged,
						NULL AS Activate,
						'SUSPEND' AS SUSPEND,
						'NOTExpiredUser' AS ExpiredUser,	
						CAST(0 AS SMALLINT) AS ExpiredUserDay,
						CAST(0 AS SMALLINT) AS MaxUserLogin,
						CAST(0 AS SMALLINT) AS UserLoginCount,
						NULL AS RoleDescription,
						NULL AS AllowLogin,
						NULL AS MIS_APP_USR_ID,
						NULL AS	MIS_APP_USR_PASS,
						NULL IsChecker,
						NULL IsChecker2,
						NULL AS UserType
						,NULL as UserLogged
					FROM DimUserInfo
						WHERE (EffectiveFromTimeKey < = @TimeKey AND EffectiveToTimeKey  > = @TimeKey)
							   AND UserLoginID=@UserLoginID 
	 			
			END

			
			ELSE IF @ExpiredUserDay>@PWDCHNG  
			
				BEGIN
			print 'ree'
			print @ExpiredUserDay
			print @PWDCHNG
				PRINT 4   	         
				
				SELECT  DimUserInfo.UserLoginID as UserLoginID,
						DimUserInfo.UserName as UserName,
						LoginPassword,
						NULL AS UserLocation,
						NULL AS UserLocationName,
						NULL AS UserLocationCode,
						CAST(0 AS SMALLINT) AS UserRoleALT_Key,
						CAST(0 AS SMALLINT) AS UserRole_Key,
						NULL AS PasswordChanged,
						NULL AS Activate,
						'NOTSUSPEND' AS SUSPEND,
						'ExpiredUser' AS ExpiredUser,	
						--CAST(0 AS SMALLINT) AS ExpiredUserDay,
					   ISNULL(@PWDCHNG,0)-ISNULL(@ExpiredUserDay,0) AS ExpiredUserDay,
						CAST(0 AS SMALLINT) AS MaxUserLogin,
						CAST(0 AS SMALLINT) AS UserLoginCount,
						NULL AS RoleDescription,
						NULL AS AllowLogin,
						NULL AS MIS_APP_USR_ID,
						NULL AS	MIS_APP_USR_PASS,
						NULL IsChecker,
						NULL IsChecker2,
						NULL AS UserType
						,NULL as UserLogged
					FROM DimUserInfo
					WHERE (EffectiveFromTimeKey < = @TimeKey AND EffectiveToTimeKey  > = @TimeKey)
						AND UserLoginID=@UserLoginID 
			END

			----------Checking to User has Expired Or Not 

			ELSE IF @SuspendedUser='Y'
				BEGIN 
				PRINT 5 
				PRINT '@SuspendedUser'	       
				PRINT @SuspendedUser
				SELECT  NULL AS UserLoginID,
						NULL AS UserName,
						LoginPassword,
						NULL AS UserLocation,
						NULL AS UserLocationName,
						NULL AS UserLocationCode,
						CAST(0 AS SMALLINT) AS UserRoleALT_Key,
						CAST(0 AS SMALLINT) AS UserRole_Key,
						NULL AS PasswordChanged,
						NULL AS Activate,
						'SUSPEND' AS SUSPEND,
						'NOTExpiredUser' AS ExpiredUser,
						CAST(0 AS SMALLINT) AS ExpiredUserDay,
						CAST(0 AS SMALLINT) AS MaxUserLogin,
						CAST(0 AS SMALLINT) AS UserLoginCount,
						NULL AS RoleDescription,
						NULL AS AllowLogin,
						NULL AS MIS_APP_USR_ID,
						NULL AS	MIS_APP_USR_PASS,
						NULL IsChecker,
						NULL IsChecker2,
						NULL AS UserType
						,NULL as UserLogged
				FROM DimUserInfo
				WHERE (EffectiveFromTimeKey < = @TimeKey AND EffectiveToTimeKey  > = @TimeKey)
					  AND UserLoginID=@UserLoginID 
			--amol end
			END

			ELSE
				BEGIN
					PRINT 'REEMA1'
					PRINT @PWDCHNG	
					PRINT @ExpiredUserDay
					SELECT
					
					DimUserInfo.UserLoginID as UserLoginID,
					DimUserInfo.UserName as UserName,
					DimUserInfo.LoginPassword,
					DimUserInfo.UserLocation ,
					CASE WHEN DimUserInfo.UserLocation = 'RO' then 'Region'
						 WHEN  DimUserInfo.UserLocation = 'ZO' then 'Zone'
						 WHEN  DimUserInfo.UserLocation = 'BO' then 'Branch'
						 WHEN  DimUserInfo.UserLocation = 'HO' then 'Bank'
						 End AS UserLocationName,
					DimUserInfo.UserLocationCode,
					DimUserInfo.UserRoleALT_Key,
					--DimUserInfo.IsAdmin,
					--DimUserInfo.IsAdmin,
					DimUserRole.UserRole_Key,
					DimUserInfo.PasswordChanged,
					DimUserInfo.Activate,
					'NOTSUSPEND' SUSPEND,
					'NOTExpiredUser' AS ExpiredUser, 
					ISNULL(@PWDCHNG,0)-ISNULL(@ExpiredUserDay,0) AS ExpiredUserDay,
					ISNULL( DimMaxLoginAllow.MaxUserLogin,0) AS MaxUserLogin,				
					ISNULL(DimMaxLoginAllow.UserLoginCount,0) AS UserLoginCount,
					DimUserRole.UserRoleShortNameEnum As RoleDescription,
					DimUserInfo.MIS_APP_USR_ID,
					DimUserInfo.MIS_APP_USR_PASS,
					DimUserInfo.IsChecker,
					ISNULL(DimUserInfo.IsChecker2,'N') IsChecker2,
					Case WHEN DimUserInfo.UserLocation = 'BO' THEN (SELECT ISNULL(AllowLogin,'N') FROM DimBranch 
																		WHERE (DimBranch.EffectiveFromTimeKey <=@TimeKey AND DimBranch.EffectiveToTimeKey> = @TimeKey) 
																		AND BranchCode=DimUserinfo.UserLocationCode)
						 WHEN DimUserInfo.UserLocation = 'RO'	AND (SELECT COUNT(*) FROM DimBranch 
																		WHERE BranchRegionAlt_Key=DimUserinfo.UserLocationCode 
																			AND (DimBranch.EffectiveFromTimeKey <=@TimeKey AND DimBranch.EffectiveToTimeKey> = @TimeKey)
																			AND ISNULL(AllowLogin,'N')='Y')>0 THEN 'Y'
						 WHEN DimUserInfo.UserLocation = 'RO'	AND (SELECT COUNT(*) FROM DimBranch 
																		WHERE BranchRegionAlt_Key=DimUserinfo.UserLocationCode
																			AND  (DimBranch.EffectiveFromTimeKey <=@TimeKey AND DimBranch.EffectiveToTimeKey> = @TimeKey) 
																			AND ISNULL(AllowLogin,'N')='Y')=0 THEN 'N'
						 WHEN DimUserInfo.UserLocation = 'HO'	AND (SELECT COUNT(*) FROM DimBranch 
																		WHERE (DimBranch.EffectiveFromTimeKey <=@TimeKey AND DimBranch.EffectiveToTimeKey> = @TimeKey)
																			AND ISNULL(AllowLogin,'N')='Y')>0 THEN 'Y'  
						 WHEN DimUserInfo.UserLocation = 'HO'	AND (SELECT COUNT(*) FROM DimBranch 
																		WHERE (DimBranch.EffectiveFromTimeKey <=@TimeKey AND DimBranch.EffectiveToTimeKey> = @TimeKey)
																			 AND ISNULL(AllowLogin,'N')='Y')=0 THEN 'N'  
					END AS AllowLogin,		
					Case WHEN DimUserInfo.UserType = 'Employee' THEN 'Y' ELSE 'N' END AS UserType
					,Case WHEN UserLogged = 1 THEN 'Y' ELSE 'N' END AS  UserLogged		
					--,'N' as UserLogged		
						--INTO ##tmpUserInfo
				FROM DimUserInfo
					INNER JOIN DimUserRole
						ON DimUserInfo.UserRoleAlt_Key = DimUserRole.UserRoleAlt_Key
					LEFT OUTER JOIN DimMaxLoginAllow 
						ON DimMaxLoginAllow.UserLocation=DimUserInfo.UserLocation 
						AND DimMaxLoginAllow.UserLocationCode=DimUserInfo.UserLocationCode			
				WHERE (DimUserInfo.EffectiveFromTimekey<=@TimeKey AND DimUserInfo.EffectiveToTimekey>=@TimeKey)
						AND	DimUserInfo.UserLoginID=@UserLoginID 
						AND ISNULL(SuspendedUser,'N')='N'	 
				END
		END
		ELSE	
			BEGIN
			
		
				PRINT 6
				PRINT 'AD Login Fetch'

				SELECT
					
					DimUserInfo.UserLoginID as UserLoginID,
					DimUserInfo.UserName as UserName,
					DimUserInfo.LoginPassword,
					DimUserInfo.UserLocation ,
					CASE WHEN DimUserInfo.UserLocation = 'RO' then 'Region'
						 WHEN  DimUserInfo.UserLocation = 'ZO' then 'Zone'
						 WHEN  DimUserInfo.UserLocation = 'BO' then 'Branch'
						 WHEN  DimUserInfo.UserLocation = 'HO' then 'Bank'
						 End AS UserLocationName,
					DimUserInfo.UserLocationCode,
					DimUserInfo.UserRoleALT_Key,
					--DimUserInfo.IsAdmin,
					--DimUserInfo.IsAdmin,
					DimUserRole.UserRole_Key,
					DimUserInfo.PasswordChanged,
					DimUserInfo.Activate,
					Case WHEN SuspendedUser = 'Y' THEN 'SUSPEND' ELSE 'NOTSUSPEND' END AS  SUSPEND,			
					'NOTExpiredUser' AS ExpiredUser, 
					isnull(@PWDCHNG,0)-isnull(@ExpiredUserDay,0) AS ExpiredUserDay,
					ISNULL( DimMaxLoginAllow.MaxUserLogin,0) AS MaxUserLogin,				
					ISNULL(DimMaxLoginAllow.UserLoginCount,0) AS UserLoginCount,
					DimUserRole.UserRoleShortNameEnum As RoleDescription,
					DimUserInfo.MIS_APP_USR_ID,
					DimUserInfo.MIS_APP_USR_PASS,
					DimUserInfo.IsChecker,
					ISNULL(DimUserInfo.IsChecker2,'N') IsChecker2,
					Case WHEN DimUserInfo.UserLocation = 'BO' THEN (SELECT ISNULL(AllowLogin,'N') FROM DimBranch 
																		WHERE (DimBranch.EffectiveFromTimeKey <=@TimeKey AND DimBranch.EffectiveToTimeKey> = @TimeKey) 
																		AND BranchCode=DimUserinfo.UserLocationCode)
						 WHEN DimUserInfo.UserLocation = 'RO'	AND (SELECT COUNT(*) FROM DimBranch 
																		WHERE BranchRegionAlt_Key=DimUserinfo.UserLocationCode 
																			AND (DimBranch.EffectiveFromTimeKey <=@TimeKey AND DimBranch.EffectiveToTimeKey> = @TimeKey)
																			AND ISNULL(AllowLogin,'N')='Y')>0 THEN 'Y'
						 WHEN DimUserInfo.UserLocation = 'RO'	AND (SELECT COUNT(*) FROM DimBranch 
																		WHERE BranchRegionAlt_Key=DimUserinfo.UserLocationCode
																			AND  (DimBranch.EffectiveFromTimeKey <=@TimeKey AND DimBranch.EffectiveToTimeKey> = @TimeKey) 
																			AND ISNULL(AllowLogin,'N')='Y')=0 THEN 'N'
						 WHEN DimUserInfo.UserLocation = 'HO'	AND (SELECT COUNT(*) FROM DimBranch 
																		WHERE (DimBranch.EffectiveFromTimeKey <=@TimeKey AND DimBranch.EffectiveToTimeKey> = @TimeKey)
																			AND ISNULL(AllowLogin,'N')='Y')>0 THEN 'Y'  
						 WHEN DimUserInfo.UserLocation = 'HO'	AND (SELECT COUNT(*) FROM DimBranch 
																		WHERE (DimBranch.EffectiveFromTimeKey <=@TimeKey AND DimBranch.EffectiveToTimeKey> = @TimeKey)
																			 AND ISNULL(AllowLogin,'N')='Y')=0 THEN 'N'  
					END AS AllowLogin,		
					Case WHEN DimUserInfo.UserType = 'Employee' THEN 'Y' ELSE 'N' END AS UserType
					,Case WHEN UserLogged = 1 THEN 'Y' ELSE 'N' END AS  UserLogged	
					--,'N' as UserLogged									
						--INTO ##tmpUserInfo
				FROM DimUserInfo
					INNER JOIN DimUserRole
						ON DimUserInfo.UserRoleAlt_Key = DimUserRole.UserRoleAlt_Key
					LEFT OUTER JOIN DimMaxLoginAllow 
						ON DimMaxLoginAllow.UserLocation=DimUserInfo.UserLocation 
						AND DimMaxLoginAllow.UserLocationCode=DimUserInfo.UserLocationCode			
				WHERE (DimUserInfo.EffectiveFromTimekey<=@TimeKey AND DimUserInfo.EffectiveToTimekey>=@TimeKey)
						AND	DimUserInfo.UserLoginID=@UserLoginID 
						--AND ISNULL(SuspendedUser,'N')='N'	 				
			

			--IF @authType = 'AD'				
			--BEGIN
			--	update ##tmpUserInfo set PasswordChanged='Y',	Activate='Y',	SUSPEND='NOTSUSPEND',	ExpiredUser='NOTExpiredUser',	ExpiredUserDay='0' 
			--	--update ##tmpUserInfo set UserType='Employee' where UserType='Y'
			--END
				

				PRINT 66
				 DECLARE @ChangePwdMax AS INT=0
				 SET @ChangePwdMax=(SELECT ParameterValue  FROM  DimUserParameters
										WHERE  (EffectiveFromTimeKey < = @TimeKey  AND EffectiveToTimeKey  > = @TimeKey)
												AND ShortNameEnum='PWDCHNG')
			
			END



			--SELECT * FROM ##tmpUserInfo
		PRINT 7
	SELECT ParameterName, ParameterValue FROM SysSolutionParameter
	WHERE (EffectiveFromTimeKey < = @TimeKey AND EffectiveToTimeKey  > = @TimeKey)

	Select ParameterValue from DimUserParameters 
	Where ParameterType ='Suspend User after Maximum Unsuccessful Log-On attempts' AND (EffectiveFromTimeKey <= @TimeKey	AND EffectiveToTimeKey >= @TimeKey)

	SELECT Count(UserLoginID) AS UserRegisteredCount FROM DIMUSERINFO_MOD WHERE CreatedBy = 'self'

	--Select ParameterName, ParameterValue from SysSolutionParameter Where ParameterName IN('TierValue','RegionCap','AllowHigherLevelAuth')
END






GO