SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[SysCrisMACReportMenu] --'addauth11' , 3652
@UserLoginID Varchar(20)='',
@TimeKey INT = 4017
AS
--Declare @UserLoginID Varchar(20)='komal',
--@TimeKey INT = 24933
BEGIN

	DECLARE @UserType varchar(10)


			select @UserType=WFR.WorkFlowUserRoleShortName from DimWorkFlowUserRole WFR
					INNER JOIN DimUserInfo DU
						ON WFR.WorkFlowUserRoleAlt_Key=DU.WorkFlowUserRoleAlt_Key
					WHERE DU.UserLoginID=@UserLoginID
		PRINT @UserType



	Select   M.EntityKey, M.MenuTitleId,M.DataSeq, ISNULL(M.MenuId,0) MenuId ,ISNULL(M.ParentId,0) ParentId, M.MenuCaption AS MenuCaption, ISNULL(CAST(M.ActionName AS VARCHAR(MAX)),ReportUrl)  
	ActionName,M.Viewpath,M.ngController,R.ReportMenuId,R.ReportType,R.ReportUrl,R.ReportID,
	M.BusFld,M.EnableMakerChecker,M.NonAllowOperation,ISNULL(M.AccessLevel,'VIEWER')AccessLevel, M.ScreenType
	--,SC.MenuCaption ParentMenuCaption
	,'ReportMenu' TableName
		FROM SysCRisMacMenu M 
			INNER JOIN SysReportDirectory R
				ON M.MenuId = R.ReportMenuId
				--INNER JOIN SysCRisMacMenu SC
				--ON M.ParentId=SC.MenuId
				
		WHERE  M.visible=1  and ISNULL(M.MenuId,0)<>0 AND M.ParentId=10701	
	
		
	
	ORDER BY MenuTitleID, DataSeq


	
	
	
	select MenuId,MenuCaption AS ParentMenuCaption, 'ParentReportMenu' TableName
	 from SysCRisMacMenu where ParentId=10701--(select MenuId from SysCRisMacMenu where MenuCaption='Reports')


	
END
GO