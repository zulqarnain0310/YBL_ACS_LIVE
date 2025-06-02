SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
  
CREATE PROCEDURE [dbo].[UserModificationAuxSelect_New]   
 @UserLoginId VARCHAR(20)  
 ,@UserLocationCode Varchar(10)  
 ,@UserLocation Varchar(2)  
 ,@TimeKey INT -- Nitin : 21 Dec 2010  
  
AS  
BEGIN   
 SET NOCOUNT ON;  
   
  DECLARE @UserRoleAlt_Key INT  
    ---------END--------------------------  
   --------------SET VALUE---------------  
   --SET @UserRoleAlt_Key=(SELECT DeptGroupCode FROM dimuserinfo   
   --WHERE    (EffectiveFromTimeKey < = @TimeKey  AND EffectiveToTimeKey  > = @TimeKey) and UserLoginID=@UserLoginID)  
   --PRINT @UserRoleAlt_Key  
   --SET @UserLocation=(SELECT UserLocation FROM dimuserinfo WHERE (EffectiveFromTimeKey < = @TimeKey  AND EffectiveToTimeKey  > = @TimeKey) and UserLoginID=@UserLoginID)  
   --IF   @UserLocation='HI'  
   -- BEGIN  
   --  SET @UserLocationCode=0  
   -- END  
   --ELSE  
   -- BEGIN  
   --  SET @UserLocationCode=(SELECT UserLocationCode FROM dimuserinfo WHERE (EffectiveFromTimeKey < = @TimeKey  AND EffectiveToTimeKey  > = @TimeKey) and UserLoginID=@UserLoginID)  
   -- END  
   -- ------------END-----------------------  
   --IF @UserRoleAlt_Key=1--SUPER ADMIN  
   --BEGIN  
   -- IF @UserLocation='HO'-- OR @UserLocation=''   
   --   BEGIN  
      SELECT DimUserInfo.UserLoginID,  
     DimUserInfo.UserName,  
     DimUserInfo.LoginPassword,  
     DimUserInfo.UserLocation ,  
     case when DimUserInfo.UserLocation = 'RO' then 'Region'  
       when  DimUserInfo.UserLocation = 'ZO' then 'Zone'  
       when  DimUserInfo.UserLocation = 'BO' then 'Branch'  
       --when  DimUserInfo.UserLocation = 'HO' then 'Bank'  
       when  DimUserInfo.UserLocation = 'HO' then 'HO'  
       when  DimUserInfo.UserLocation = 'HI' then 'HI'  
       when  DimUserInfo.UserLocation = 'RI' then 'RI'  
  
       End AS UserLocationName,  
     ISNULL(DimUserInfo.UserLocationCode,'') as UserLocationCode,  
     DimUserRole.UserRoleAlt_Key,  
     DimUserRole.UserRoleShortNameEnum as RoleDescription,  
     DimUserInfo.Activate,  
     DimUserInfo.PasswordChanged,  
     DimUserInfo.IsEmployee,  
     'NOTSUSPEND' SUSPEND,  
     'NOTExpiredUser' AS ExpiredUser,  
     DimUserInfo.IsChecker ,DimUserInfo.EmployeeID,Isnull(DimUserInfo.DeptGroupCode,'ALL') as DeptGroupCode,  
     DimUserInfo.Email_ID, --ad3  
     DimUserInfo.MobileNo,  
     DimUserInfo.DesignationAlt_Key,  
     isnull( isCma,'N')isCma,  
     DimUserInfo.UserType,  
      'Y' as IsMainTable  
     ,DimUserInfo.ProffEntityId  
     ,DimUserInfo.GradeScaleAlt_Key  
     ,DimUserInfo.EmployeeTypeAlt_Key  
     ,DimUserInfo.SourceAlt_Key  
     ,ISNULL(DimUserInfo.ModifyBy,DimUserInfo.CreatedBy)CreatedBy  
     --,DimUserInfo.AuthorisationStatus  
     ,ltrim(rtrim(DimUserInfo.AuthorisationStatus)) AuthorisationStatus  --To handle Space issue in AuthorisationStatus (04/07/2023)  
     FROM dimuserinfo INNER JOIN DimUserRole ON dimuserinfo.UserRoleAlt_Key = DimUserRole.UserRoleAlt_Key  
     WHERE   (dimuserinfo.EffectiveFromTimeKey < = @TimeKey AND dimuserinfo.EffectiveToTimeKey  > = @TimeKey)  
     AND UserLoginID <>(@UserLoginID)  
     AND ISNULL(dimuserinfo.AuthorisationStatus,'A')='A'  
      
    UNION  
     SELECT DU.UserLoginID,  
     DU.UserName,  
     DU.LoginPassword,  
     DU.UserLocation ,  
     case when DU.UserLocation = 'RO' then 'Region'  
       when  DU.UserLocation = 'ZO' then 'Zone'  
       when  DU.UserLocation = 'BO' then 'Branch'  
       --when  DimUserInfo.UserLocation = 'HO' then 'Bank'  
       when  DU.UserLocation = 'HO' then 'HO'  
       when  DU.UserLocation = 'HI' then 'HI'  
       when  DU.UserLocation = 'RI' then 'RI'  
  
       End AS UserLocationName,  
     ISNULL(DU.UserLocationCode,'') as UserLocationCode,  
     DimUserRole.UserRoleAlt_Key,  
     DimUserRole.UserRoleShortNameEnum as RoleDescription,  
     DU.Activate,  
     DU.PasswordChanged,  
     DU.IsEmployee,  
     'NOTSUSPEND' SUSPEND,  
     'NOTExpiredUser' AS ExpiredUser,  
     DU.IsChecker ,DU.EmployeeID,Isnull(DU.DeptGroupCode,'ALL') as DeptGroupCode,  
     DU.Email_ID, --ad3  
     DU.MobileNo,  
     DU.DesignationAlt_Key,  
     isnull( isCma,'N')isCma,  
     DU.UserType,  
     'N' as IsMainTable  
     ,DU.ProffEntityId  
     ,DU.GradeScaleAlt_Key  
     ,DU.EmployeeTypeAlt_Key  
     ,DU.SourceAlt_Key  
     ,ISNULL(DU.ModifyBy,DU.CreatedBy)CreatedBy  
     ,DU.AuthorisationStatus  
       
     FROM dimuserinfo_MOD DU INNER JOIN DimUserRole ON DU.UserRoleAlt_Key = DimUserRole.UserRoleAlt_Key  
     WHERE   (DU.EffectiveFromTimeKey < = @TimeKey AND DU.EffectiveToTimeKey  > = @TimeKey)  
     AND UserLoginID <>(@UserLoginID)  
     AND DU.AuthorisationStatus IN('NP','DP','MP','RM')  
     and EntityKey in(SELECT MAX(EntityKey)EntityKey FROM DimUserInfo_MOD WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND  UserLoginID<>@UserLoginId AND AuthorisationStatus IN('NP','DP','MP','RM') GROUP BY UserLoginID)  
  
  --  END  
  --  END  
     
  --IF @UserRoleAlt_Key=2 -- ADMIN  
  -- BEGIN  
     
  -- print 2  
  
  --   IF @UserLocation='HO'-- OR @UserLocation=''   
  --    BEGIN  
  --    SELECT DimUserInfo.UserLoginID,  
  --   DimUserInfo.UserName,  
  --   DimUserInfo.LoginPassword,  
  --   DimUserInfo.UserLocation ,  
  --   case when DimUserInfo.UserLocation = 'RO' then 'Region'  
  --     when  DimUserInfo.UserLocation = 'ZO' then 'Zone'  
  --     when  DimUserInfo.UserLocation = 'BO' then 'Branch'  
  --     --when  DimUserInfo.UserLocation = 'HO' then 'Bank'  
  --     when  DimUserInfo.UserLocation = 'HO' then 'HO'  
  --     when  DimUserInfo.UserLocation = 'HI' then 'HI'  
  --     when  DimUserInfo.UserLocation = 'RI' then 'RI'  
  
  --     End AS UserLocationName,  
  --   ISNULL(DimUserInfo.UserLocationCode,'') as UserLocationCode,  
  --   DimUserRole.UserRoleAlt_Key,  
  --   DimUserRole.UserRoleShortNameEnum as RoleDescription,  
  --   DimUserInfo.Activate,  
  --   DimUserInfo.PasswordChanged,  
  --   DimUserInfo.IsEmployee,  
  --   'NOTSUSPEND' SUSPEND,  
  --   'NOTExpiredUser' AS ExpiredUser,  
  --   DimUserInfo.IsChecker ,DimUserInfo.EmployeeID,Isnull(DimUserInfo.DeptGroupCode,'ALL') as DeptGroupCode,  
  --   DimUserInfo.Email_ID, --ad3  
  --   DimUserInfo.MobileNo,  
  --   DimUserInfo.DesignationAlt_Key,  
  --   isnull( isCma,'N')isCma,  
  --   DimUserInfo.UserType,  
  --   DimUserInfo.CreatedBy,  
  --   'Y' as IsMainTable  
  --   ,DimUserInfo.ProffEntityId  
  --   ,DimUserInfo.GradeScaleAlt_Key  
  --   ,DimUserInfo.EmployeeTypeAlt_Key  
  --   ,DimUserInfo.SourceAlt_Key  
       
  --   from dimuserinfo INNER JOIN DimUserRole ON dimuserinfo.UserRoleAlt_Key = DimUserRole.UserRoleAlt_Key  
  --   WHERE    (dimuserinfo.EffectiveFromTimeKey < = @TimeKey AND dimuserinfo.EffectiveToTimeKey  > = @TimeKey)  
  --   AND UserLoginID <>(@UserLoginID)  
  --   AND dimuserinfo.UserRoleAlt_Key IN(2,3,4)   
  --   --AND UserLocationCode IN(SELECT RegionAlt_Key from   Dimregion where RegionAlt_Key=@UserLocationCode )  
  --  END  
  --   IF @UserLocation='ZO'  
  --    BEGIN  
  --    SELECT DimUserInfo.UserLoginID,  
  --   DimUserInfo.UserName,  
  --   DimUserInfo.LoginPassword,  
  --   DimUserInfo.UserLocation ,  
  --   case when DimUserInfo.UserLocation = 'RO' then 'Region'  
  --     when  DimUserInfo.UserLocation = 'ZO' then 'Zone'  
  --     when  DimUserInfo.UserLocation = 'BO' then 'Branch'  
  --     --when  DimUserInfo.UserLocation = 'HO' then 'Bank'  
  --     when  DimUserInfo.UserLocation = 'HO' then 'HO'  
  --     when  DimUserInfo.UserLocation = 'HI' then 'HI'  
  --     when  DimUserInfo.UserLocation = 'RI' then 'RI'  
  
  --     End AS UserLocationName,  
  --   ISNULL(DimUserInfo.UserLocationCode,'') as UserLocationCode,  
  --   DimUserRole.UserRoleAlt_Key,  
  --   DimUserRole.UserRoleShortNameEnum as RoleDescription,  
  --   DimUserInfo.Activate,  
  --   DimUserInfo.PasswordChanged,  
  --   DimUserInfo.IsEmployee,  
  --   'NOTSUSPEND' SUSPEND,  
  --   'NOTExpiredUser' AS ExpiredUser,  
  --   DimUserInfo.IsChecker ,DimUserInfo.EmployeeID,Isnull(DimUserInfo.DeptGroupCode,'ALL') as DeptGroupCode,  
  --   DimUserInfo.Email_ID, --ad3  
  --   DimUserInfo.MobileNo,  
  --   DimUserInfo.DesignationAlt_Key,  
  --     'Y' as IsMainTable,  
  --   isnull( isCma,'N')isCma  
  --   ,DimUserInfo.UserType  
  --   ,DimUserInfo.ProffEntityId  
  --   ,DimUserInfo.GradeScaleAlt_Key  
  --   ,DimUserInfo.EmployeeTypeAlt_Key  
  --   ,DimUserInfo.SourceAlt_Key  
       
  --   from dimuserinfo INNER JOIN DimUserRole ON dimuserinfo.UserRoleAlt_Key = DimUserRole.UserRoleAlt_Key  
  --   WHERE (dimuserinfo.EffectiveFromTimeKey < = @TimeKey AND dimuserinfo.EffectiveToTimeKey  > = @TimeKey)  
  --   AND  dimuserinfo.UserRoleAlt_Key IN(2,3,4)   
  --   AND dimuserinfo.UserLocationCode=@UserLocationCode   
  --   AND UserLoginID <>(@UserLoginID)  
  --    AND UserLocation IN('ZO','RO','BO')  
  --    END   
      
  --   IF @UserLocation='HI' --AMAR 15032011  
  --    BEGIN  
  --    SELECT DimUserInfo.UserLoginID,  
  --   DimUserInfo.UserName,  
  --   DimUserInfo.LoginPassword,  
  --   DimUserInfo.UserLocation ,  
  --   case when DimUserInfo.UserLocation = 'RO' then 'Region'  
  --     when  DimUserInfo.UserLocation = 'ZO' then 'Zone'  
  --     when  DimUserInfo.UserLocation = 'BO' then 'Branch'  
  --     --when  DimUserInfo.UserLocation = 'HO' then 'Bank'  
  --     when  DimUserInfo.UserLocation = 'HO' then 'HO'  
  --     when  DimUserInfo.UserLocation = 'HI' then 'HI'  
  --     when  DimUserInfo.UserLocation = 'RI' then 'RI'  
  
  --     End AS UserLocationName,  
  --   ISNULL(DimUserInfo.UserLocationCode,'') as UserLocationCode,  
  --   DimUserRole.UserRoleAlt_Key,  
  --   DimUserRole.UserRoleShortNameEnum as RoleDescription,  
  --   DimUserInfo.Activate,  
  --   DimUserInfo.PasswordChanged,  
  --   DimUserInfo.IsEmployee,  
  --   'NOTSUSPEND' SUSPEND,  
  --   'NOTExpiredUser' AS ExpiredUser,  
  --   DimUserInfo.IsChecker ,DimUserInfo.EmployeeID,Isnull(DimUserInfo.DeptGroupCode,'ALL') as DeptGroupCode,  
  --   DimUserInfo.Email_ID, --ad3  
  --   DimUserInfo.MobileNo,  
  --   DimUserInfo.DesignationAlt_Key,  
  --   isnull( isCma,'N')isCma  
  --   ,DimUserInfo.ProffEntityId  
  --   ,DimUserInfo.GradeScaleAlt_Key  
  --   ,DimUserInfo.EmployeeTypeAlt_Key  
  --   ,DimUserInfo.SourceAlt_Key  
       
  --   from dimuserinfo INNER JOIN DimUserRole ON dimuserinfo.UserRoleAlt_Key = DimUserRole.UserRoleAlt_Key  
  --   WHERE (dimuserinfo.EffectiveFromTimeKey < = @TimeKey AND dimuserinfo.EffectiveToTimeKey  > = @TimeKey)  
  --   AND  dimuserinfo.UserRoleAlt_Key IN(2,3,4)   
  --   --AND dimuserinfo.UserLocationCode=@UserLocationCode   
  --   AND UserLoginID <>(@UserLoginID)  
  --    AND UserLocation IN('HI','RI')  
  --    END   
  
  --   IF @UserLocation='RI'--AMAR 15032011  
  --    BEGIN  
  
  --     print 'RI'  
  --    SELECT DimUserInfo.UserLoginID,  
  --   DimUserInfo.UserName,  
  --   DimUserInfo.LoginPassword,  
  --   DimUserInfo.UserLocation ,  
  --   case when DimUserInfo.UserLocation = 'RO' then 'Region'  
  --     when  DimUserInfo.UserLocation = 'ZO' then 'Zone'  
  --     when  DimUserInfo.UserLocation = 'BO' then 'Branch'  
  --     --when  DimUserInfo.UserLocation = 'HO' then 'Bank'  
  --     when  DimUserInfo.UserLocation = 'HO' then 'HO'  
  --     when  DimUserInfo.UserLocation = 'HI' then 'HI'  
  --     when  DimUserInfo.UserLocation = 'RI' then 'RI'  
  
  --     End AS UserLocationName,  
  --   ISNULL(DimUserInfo.UserLocationCode,'') as UserLocationCode,  
  --   DimUserRole.UserRoleAlt_Key,  
  --   DimUserRole.UserRoleShortNameEnum as RoleDescription,  
  --   DimUserInfo.Activate,  
  --   DimUserInfo.PasswordChanged,  
  --   DimUserInfo.IsEmployee,  
  --   'NOTSUSPEND' SUSPEND,  
  --   'NOTExpiredUser' AS ExpiredUser,  
  --   DimUserInfo.IsChecker ,DimUserInfo.EmployeeID,Isnull(DimUserInfo.DeptGroupCode,'ALL') as DeptGroupCode,  
  --   DimUserInfo.Email_ID, --ad3  
  --   DimUserInfo.MobileNo,  
  --   DimUserInfo.DesignationAlt_Key,  
  --     'Y' as IsMainTable,  
  --   isnull( isCma,'N')isCma  
  --   ,DimUserInfo.ProffEntityId  
  --   ,DimUserInfo.GradeScaleAlt_Key  
  --   ,DimUserInfo.EmployeeTypeAlt_Key  
  --   ,DimUserInfo.SourceAlt_Key  
  --   from dimuserinfo INNER JOIN DimUserRole ON dimuserinfo.UserRoleAlt_Key = DimUserRole.UserRoleAlt_Key  
  --   WHERE (dimuserinfo.EffectiveFromTimeKey < = @TimeKey AND dimuserinfo.EffectiveToTimeKey  > = @TimeKey)  
  --   AND  dimuserinfo.UserRoleAlt_Key IN(2,3,4)   
  --   AND dimuserinfo.UserLocationCode=@UserLocationCode   
  --   AND UserLoginID <>(@UserLoginID)  
  --    AND UserLocation IN('RI')  
  --    END   
      
  -- IF @UserLocation='RO'  
  --   BEGIN  
     
  --  print 'RO'  
              
  --    SELECT DimUserInfo.UserLoginID,  
  --   DimUserInfo.UserName,  
  --   DimUserInfo.LoginPassword,  
  --   DimUserInfo.UserLocation ,  
  --   case when DimUserInfo.UserLocation = 'RO' then 'Region'  
  --     when  DimUserInfo.UserLocation = 'ZO' then 'Zone'  
  --     when  DimUserInfo.UserLocation = 'BO' then 'Branch'  
  --     --when  DimUserInfo.UserLocation = 'HO' then 'Bank'  
  --     when  DimUserInfo.UserLocation = 'HO' then 'HO'  
  --     when  DimUserInfo.UserLocation = 'HI' then 'HI'  
  --     when  DimUserInfo.UserLocation = 'RI' then 'RI'  
  
  --     End AS UserLocationName,  
  --   ISNULL(DimUserInfo.UserLocationCode,'') as UserLocationCode,  
  --   DimUserRole.UserRoleAlt_Key,  
  --   DimUserRole.UserRoleShortNameEnum as RoleDescription,  
  --   DimUserInfo.Activate,  
  --   DimUserInfo.PasswordChanged,  
  --   DimUserInfo.IsEmployee,  
  --   'NOTSUSPEND' SUSPEND,  
  --     'Y' as IsMainTable,  
  --   'NOTExpiredUser' AS ExpiredUser,  
  --   DimUserInfo.IsChecker ,DimUserInfo.EmployeeID,Isnull(DimUserInfo.DeptGroupCode,'ALL') as DeptGroupCode,  
  --   DimUserInfo.Email_ID, --ad3  
  --   DimUserInfo.MobileNo,  
  --   DimUserInfo.DesignationAlt_Key,  
  --   isnull( isCma,'N')isCma  
  --   ,DimUserInfo.UserType  
  --   ,DimUserInfo.ProffEntityId  
  --   ,DimUserInfo.GradeScaleAlt_Key  
  --   ,DimUserInfo.EmployeeTypeAlt_Key  
  --   ,DimUserInfo.SourceAlt_Key  
  --  from dimuserinfo INNER JOIN DimUserRole ON dimuserinfo.UserRoleAlt_Key = DimUserRole.UserRoleAlt_Key  
  --   WHERE (dimuserinfo.EffectiveFromTimeKey < = @TimeKey AND dimuserinfo.EffectiveToTimeKey  > = @TimeKey)  
  --   AND  dimuserinfo.UserRoleAlt_Key IN(2,3,4)   
  --   AND UserLocationCode IN(SELECT BranchCode from DimBranch   
  --   INNER JOIN   
  --   Dimregion ON DimBranch.BranchRegionAlt_Key=DimRegion.RegionAlt_Key where DimRegion.RegionAlt_Key=@UserLocationCode   
  --   )  
  --   AND UserLoginID <>(@UserLoginID)  
  --    AND UserLocation IN('RO','BO')  
  --    UNION   
          
  --  SELECT   
  --    DimUserInfo.UserLoginID,  
  --   DimUserInfo.UserName,  
  --   DimUserInfo.LoginPassword,  
  --   DimUserInfo.UserLocation ,  
  --   case when DimUserInfo.UserLocation = 'RO' then 'Region'  
  --     when  DimUserInfo.UserLocation = 'ZO' then 'Zone'  
  --     when  DimUserInfo.UserLocation = 'BO' then 'Branch'  
  --     --when  DimUserInfo.UserLocation = 'HO' then 'Bank'  
  --     when  DimUserInfo.UserLocation = 'HO' then 'HO'  
  --     when  DimUserInfo.UserLocation = 'HI' then 'HI'  
  --     when  DimUserInfo.UserLocation = 'RI' then 'RI'  
  
  --     End AS UserLocationName,  
  --   ISNULL(DimUserInfo.UserLocationCode,'') as UserLocationCode,  
  --   DimUserRole.UserRoleAlt_Key,  
  --   DimUserRole.UserRoleShortNameEnum as RoleDescription,  
  --   DimUserInfo.Activate,  
  --   DimUserInfo.PasswordChanged,  
  --   DimUserInfo.IsEmployee,  
  --   'NOTSUSPEND' SUSPEND,  
  --   'NOTExpiredUser' AS ExpiredUser,  
  --   DimUserInfo.IsChecker ,DimUserInfo.EmployeeID,Isnull(DimUserInfo.DeptGroupCode,'ALL') as DeptGroupCode,  
  --   DimUserInfo.Email_ID, --ad3  
  --   DimUserInfo.MobileNo,  
  --     'Y' as IsMainTable,  
  --   DimUserInfo.DesignationAlt_Key,  
  --   isnull( isCma,'N')isCma  
  --   ,DimUserInfo.UserType  
  --   ,DimUserInfo.ProffEntityId  
  --   ,DimUserInfo.GradeScaleAlt_Key  
  --   ,DimUserInfo.EmployeeTypeAlt_Key  
  --   ,DimUserInfo.SourceAlt_Key  
  --   from dimuserinfo INNER JOIN DimUserRole ON dimuserinfo.UserRoleAlt_Key = DimUserRole.UserRoleAlt_Key  
  --   WHERE (dimuserinfo.EffectiveFromTimeKey < = @TimeKey AND dimuserinfo.EffectiveToTimeKey  > = @TimeKey)  
  --   AND  dimuserinfo.UserRoleAlt_Key IN(2,3,4)   
  --   AND UserLocationCode IN(SELECT RegionAlt_Key from   Dimregion where RegionAlt_Key=@UserLocationCode )  
  --   AND UserLoginID <>(@UserLoginID)  
  --   AND UserLocation IN('RO','BO')  
            
  --  END   
  --IF @UserLocation='BO'  
  --   BEGIN  
  --   print 'BO'  
  --   SELECT DimUserInfo.UserLoginID,  
  --   DimUserInfo.UserName,  
  --   DimUserInfo.LoginPassword,  
  --   DimUserInfo.UserLocation ,  
  --   case when DimUserInfo.UserLocation = 'RO' then 'Region'  
  --     when  DimUserInfo.UserLocation = 'ZO' then 'Zone'  
  --     when  DimUserInfo.UserLocation = 'BO' then 'Branch'  
  --     --when  DimUserInfo.UserLocation = 'HO' then 'Bank'  
  --     when  DimUserInfo.UserLocation = 'HO' then 'HO'  
  --     when  DimUserInfo.UserLocation = 'HI' then 'HI'  
  --     when  DimUserInfo.UserLocation = 'RI' then 'RI'  
  
  --     End AS UserLocationName,  
  --   ISNULL(DimUserInfo.UserLocationCode,'') as UserLocationCode,  
  --   DimUserRole.UserRoleAlt_Key,  
  --   DimUserRole.UserRoleShortNameEnum as RoleDescription,  
  --   DimUserInfo.Activate,  
  --   DimUserInfo.PasswordChanged,  
  --   DimUserInfo.IsEmployee,  
  --   'NOTSUSPEND' SUSPEND,  
  --   'NOTExpiredUser' AS ExpiredUser,  
  --   DimUserInfo.IsChecker ,DimUserInfo.EmployeeID,Isnull(DimUserInfo.DeptGroupCode,'ALL') as DeptGroupCode,  
  --   DimUserInfo.Email_ID, --ad3  
  --   DimUserInfo.MobileNo,  
  --    'Y' as IsMainTable,  
  --   DimUserInfo.DesignationAlt_Key,  
  --   isnull( isCma,'N')isCma  
  --   ,DimUserInfo.UserType  
  --   ,DimUserInfo.ProffEntityId  
  --   ,DimUserInfo.GradeScaleAlt_Key  
  --   ,DimUserInfo.EmployeeTypeAlt_Key  
  --   ,DimUserInfo.SourceAlt_Key  
  --  from dimuserinfo INNER JOIN DimUserRole ON dimuserinfo.UserRoleAlt_Key = DimUserRole.UserRoleAlt_Key  
  --  WHERE (dimuserinfo.EffectiveFromTimeKey < = @TimeKey AND dimuserinfo.EffectiveToTimeKey  > = @TimeKey)  
  --  AND  dimuserinfo.UserRoleAlt_Key IN(2,3,4)   
  --  AND UserLocationCode IN(SELECT BranchCode from DimBranch WHERE BranchCode =@UserLocationCode)  
  --  AND UserLoginID <>(@UserLoginID)  
  --   AND UserLocation IN('BO')  
  --   END  
  -- END  
  
  -- IF @UserRoleAlt_Key=6 --ARMS  
  -- BEGIN  
  --  IF @UserLocation='HO'-- OR @UserLocation=''   
  --    BEGIN  
  --    SELECT DimUserInfo.UserLoginID,  
  --   DimUserInfo.UserName,  
  --   DimUserInfo.LoginPassword,  
  --   DimUserInfo.UserLocation ,  
  --   case when DimUserInfo.UserLocation = 'RO' then 'Region'  
  --     when  DimUserInfo.UserLocation = 'ZO' then 'Zone'  
  --     when  DimUserInfo.UserLocation = 'BO' then 'Branch'  
  --     --when  DimUserInfo.UserLocation = 'HO' then 'Bank'  
  --     when  DimUserInfo.UserLocation = 'HO' then 'HO'  
  --     when  DimUserInfo.UserLocation = 'HI' then 'HI'  
  --     when  DimUserInfo.UserLocation = 'RI' then 'RI'  
  
  --     End AS UserLocationName,  
  --   ISNULL(DimUserInfo.UserLocationCode,'') as UserLocationCode,  
  --   DimUserRole.UserRoleAlt_Key,  
  --   DimUserRole.UserRoleShortNameEnum as RoleDescription,  
  --   DimUserInfo.Activate,  
  --   DimUserInfo.PasswordChanged,  
  --   DimUserInfo.IsEmployee,  
  --   'NOTSUSPEND' SUSPEND,  
  --   'NOTExpiredUser' AS ExpiredUser,  
  --   DimUserInfo.IsChecker ,DimUserInfo.EmployeeID,Isnull(DimUserInfo.DeptGroupCode,'ALL') as DeptGroupCode,  
  --   DimUserInfo.Email_ID, --ad3  
  --   DimUserInfo.MobileNo,  
  --   DimUserInfo.DesignationAlt_Key,  
  --   isnull( isCma,'N')isCma,  
  --   DimUserInfo.UserType,  
  --    'Y' as IsMainTable  
  --   ,DimUserInfo.ProffEntityId  
  --   ,DimUserInfo.GradeScaleAlt_Key  
  --   ,DimUserInfo.EmployeeTypeAlt_Key  
  --   ,DimUserInfo.SourceAlt_Key  
       
  --   FROM dimuserinfo INNER JOIN DimUserRole ON dimuserinfo.UserRoleAlt_Key = DimUserRole.UserRoleAlt_Key    --   WHERE   (dimuserinfo.EffectiveFromTimeKey < = @TimeKey AND dimuserinfo.EffectiveToTimeKey  > = @TimeKey)  
  --   AND UserLoginID <>(@UserLoginID)  
  --  END  
  --  END  
 END  
  
  
  
GO