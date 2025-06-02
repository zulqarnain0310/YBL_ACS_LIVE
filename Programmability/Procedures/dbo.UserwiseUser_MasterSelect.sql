SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Sachin Bonde>
-- Create date: <07042023>
-- Description:	<Get master data>
-- =============================================
CREATE PROCEDURE [dbo].[UserwiseUser_MasterSelect]
--Declare
@UserLoginID varchar(30),
@Timekey int

AS

BEGIN

--Declare @Timekey int,@Date date

--SELECT @Timekey=TimeKey FROM YBL_ACS.DBO.SysDayMatrix WHERE Date=CAST(GETDATE() as date)--FLG = 'Y'

		BEGIN


                Select UserLoginID as ADID,a.UserName,a.EmployeeID,UserRoleName,c.DeptGroupName--,d.MenuID,d.IsViewer,d.IsMaker,d.IsLV1checker,d.IsLV2checker 
                ,a.Activate      --------Column added by Tarkeshwar Singh on 30May2025 as discussed with Akshay Kale
				From YBL_ACS.dbo.DimUserInfo a 
                inner join YBL_ACS.dbo.DimUserRole b 
                on a.UserRoleAlt_Key=b.UserRoleAlt_Key 
                AND a.EffectiveFromTimeKey<=@Timekey AND a.EffectiveToTimeKey>=@Timekey
                AND b.EffectiveFromTimeKey<=@Timekey AND b.EffectiveToTimeKey>=@Timekey
				AND a.UserLoginID <> @UserLoginID
                inner join YBL_ACS.dbo.DimUserDeptGroup c 
                on a.DeptGroupCode=c.DeptGroupId
                AND c.EffectiveFromTimeKey<=@Timekey AND c.EffectiveToTimeKey>=@Timekey

				--LEFT JOIN YBL_ACS.dbo.UserrolewiseMatrix d 
				--on a.UserLoginID=d.ADID 
				--AND d.EffectiveToTimeKey = 49999
		
		END
END


GO