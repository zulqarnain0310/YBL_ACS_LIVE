SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROC [dbo].[DeptNameUserRecipientSelect] 

										@DeptGroupCode AS VARCHAR(10) = '' 
                                        --@AllUsers      INT         = 0

AS

IF OBJECT_ID('TempDB..#UserInfo') IS NOT NULL
DROP TABLE #UserInfo

Select * into #UserInfo From DimUserinfo where DEPTGROUPCODE NOT LIKE('%,%')

BEGIN
         Declare @TimeKey as Int 

	Set @TimeKey = (Select Timekey from SysDataMatrix where CurrentStatus='C')         
	

BEGIN TRY
         --    BEGIN

                 SELECT 'DimUserinfo' AS TableName,
						UserLoginID AS UserLoginID, 
                        i.UserName AS UserName, 
                        i.Email_ID AS Email_ID,
                        o.ContactNo AS ContactNo,
						i.MobileNo AS MobileNo
                 FROM #UserInfo i
                      LEFT JOIN --(
                      --select distinct UserId, AccessScopeAlt_Key from
                 (
                     SELECT AlertRecipientUserId, 
                            ContactNo
                     FROM DimAlertRecipientMaster
                     WHERE EffectiveFromTimeKey <= @TimeKey
                           AND EffectiveToTimeKey >= @TimeKey
                           AND isnull(AuthorisationStatus, 'A') IN('A')
                     UNION
                     SELECT AlertRecipientUserId, 
                            ContactNo
                     FROM DimAlertRecipientMaster_Mod
                     WHERE EffectiveFromTimeKey <= @TimeKey
                           AND EffectiveToTimeKey >= @TimeKey
                           AND isnull(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')
                 ) o --) o
                 ON i.UserLoginID = o.AlertRecipientUserId
                 WHERE i.EffectiveFromTimeKey <= @TimeKey
                       AND i.EffectiveToTimeKey >= @TimeKey
                       AND i.DEPTGROUPCODE NOT LIKE('%,%')
                       AND i.DeptGroupCode = @DeptGroupCode
                       
                 ORDER BY UserLoginID;
             --END;
         /*
		 IF(@AllUsers = 1)
             BEGIN
                 SELECT 'DimUserinfo' AS TableName,
						UserLoginID AS UserLoginID, 
                        i.UserName AS UserName, 
                        i.Email_ID AS Email_ID,
                        o.ContactNo AS ContactNo,
						i.MobileNo AS MobileNo
                 FROM #UserInfo i
                      LEFT JOIN --(
                      --select distinct UserId, AccessScopeAlt_Key from
                 (
                     SELECT AlertRecipientUserId, 
                            ContactNo
                     FROM RAM.DimReportAlertRecipientMaster
                     WHERE EffectiveFromTimeKey <= @TimeKey
                           AND EffectiveToTimeKey >= @TimeKey
                           AND isnull(AuthorisationStatus, 'A') IN('A')
                     UNION
                     SELECT AlertRecipientUserId, 
                            ContactNo
                     FROM RAM.DimReportAlertRecipientMaster_Mod
                     WHERE EffectiveFromTimeKey <= @TimeKey
                           AND EffectiveToTimeKey >= @TimeKey
                           AND isnull(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')
                 ) o --) o
                 ON i.UserLoginID = o.AlertRecipientUserId
                 WHERE i.EffectiveFromTimeKey <= @TimeKey
                       AND i.EffectiveToTimeKey >= @TimeKey
                       AND i.DEPTGROUPCODE NOT LIKE('%,%')
                       AND i.DeptGroupCode = @DeptGroupCode
                 --AND isnull(AccessScopeAlt_Key, 0) = 0;
                 ORDER BY UserLoginID;
             END;

			 */
     END TRY
	BEGIN CATCH
	
	INSERT INTO dbo.Error_Log
				SELECT ERROR_LINE() as ErrorLine,ERROR_MESSAGE()ErrorMessage,ERROR_NUMBER()ErrorNumber
				,ERROR_PROCEDURE()ErrorProcedure,ERROR_SEVERITY()ErrorSeverity,ERROR_STATE()ErrorState
				,GETDATE()

	SELECT ERROR_MESSAGE()
	--RETURN -1
   
	END CATCH
       
END

--exec DeptNameUserRecipientSelect 
GO