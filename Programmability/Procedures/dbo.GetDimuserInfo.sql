SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[GetDimuserInfo]
@UseLoginId varchar(20)
AS 

Declare @TimeKey     INT  = 0

  
 SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')   
  

BEGIN

select UserLoginID
  ,LoginPassword
  ,Activate
  ,IsChecker
  ,SuspendedUser AS 'SUSPEND'
  ,'Y' AllowLogin
  ,90 AS ExpiredUserDay
  ,'6' AS MaxUserLogin
  ,'N' AS  SUSPEND
  ,'N' AS  ExpiredUser
  ,'Y' AS PasswordChanged
  ,R.UserRoleName RoleDescription
  ,D.UserLocation
  ,D.UserLocationCode
  ,CASE WHEN D.UserLocation = 'RO' then 'Region'
 WHEN  D.UserLocation = 'ZO' then 'Zone'
 WHEN  D.UserLocation = 'BO' then 'Branch'
 WHEN  D.UserLocation = 'HO' then 'Bank'
 End AS UserLocationName
  ,0 AS UserLoginCount
  ,D.UserName
  ,D.IsChecker
  ,R.UserRole_Key
  ,D.UserRoleALT_Key

  from DimUserInfo D
  JOIN DimUserRole R
   ON D.UserRoleAlt_Key = R.UserRoleAlt_Key
   WHERE UserLoginID=@UseLoginId
   AND (D.EffectiveFromTimeKey < = @Timekey AND D.EffectiveToTimeKey  > = @Timekey)

   SELECT ParameterName, ParameterValue FROM SysSolutionParameter
WHERE (EffectiveFromTimeKey < = 49999 AND EffectiveToTimeKey  > = 49999)
END


GO