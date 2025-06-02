SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		<SHUBHAM MANKAME>
-- Create date: <10-10-2023>
-- Description:	<Get menu master data>
-- =============================================
CREATE PROCEDURE [dbo].[UserwiseMenuselect_MasterSelect]--'DM585','dm410',1,26886
@UserloginID Varchar(30),
@AD_ID varchar(30),
@OperationFlag int,
@Timekey int

--Declare
--@UserloginID Varchar(30)='dm585',
--@AD_ID Varchar(30)='reema',
--@OperationFlag int=16,
--@Timekey int=26886

AS

BEGIN

Declare @Menus Varchar(1000),
@UserRole int,
@USERROLENAME Varchar (30),
@Ischecker char,
@Ischecker2 char

--SELECT @Timekey=TimeKey FROM YBL_ACS.DBO.SysDayMatrix WHERE Date=CAST(GETDATE() as date)--FLG = 'Y'

		BEGIN


IF OBJECT_ID('Tempdb..#MENUS') IS NOT NULL  
DROP TABLE #MENUS

SELECT DISTINCT A.MENUID INTO #MENUS 
		FROM SYSCRISMACMENU A WHERE 1=2
/* ADDED ON 20250130 BY ZAIN RAISED BY FM */
IF(SELECT COUNT(1) FROM UserRoleWiseMatrix WHERE EffectiveToTimeKey=49999)=0
BEGIN

INSERT INTO #MENUS 
SELECT DISTINCT A.MENUID 
		FROM SYSCRISMACMENU A 
		--INNER JOIN USERROLEWISEMATRIX B 
			--ON A.MENUID=B.MENUID
			WHERE SPL_SCREENFLG='Y'
			--AND B.ADID=@AD_ID
			--AND B.EffectiveFromTimeKey<=@Timekey AND B.EffectiveToTimeKey>=@Timekey
END
ELSE
BEGIN
INSERT INTO #MENUS 
SELECT DISTINCT A.MENUID 
		FROM SYSCRISMACMENU A 
		INNER JOIN USERROLEWISEMATRIX B 
			ON A.MENUID=B.MENUID
			WHERE SPL_SCREENFLG='Y'
			--AND B.ADID=@AD_ID
			AND B.EffectiveFromTimeKey<=@Timekey AND B.EffectiveToTimeKey>=@Timekey
END			
			IF (SELECT count(1) FROM #MENUS)=1
			BEGIN
				SET @Menus=(SELECT MENUID FROM #MENUS)
			END
			ELSE
			BEGIN
				SET @MENUS=(SELECT STUFF((SELECT ','+CAST(MENUID AS VARCHAR(20))
				FROM #MENUS FOR XML PATH('')),1,1,'') AS RESULT)
			END

/* ADDED ON 20250130 BY ZAIN RAISED BY FM */

Select @UserRole=a.UserRoleAlt_Key,@USERROLENAME=b.UserRoleName,@Ischecker=ISNULL(IsChecker,'N'),@Ischecker2=ISNULL(IsChecker2,'N')
			From DimUserInfo a 
INNER JOIN YBL_ACS.DBO.DimUserRole b on a.UserRoleAlt_Key=b.UserRoleAlt_Key
--INNER JOIN DimUserDeptGroup b on a.DeptGroupCode=b.DeptGroupId
AND a.EffectiveToTimeKey =49999
--AND b.EffectiveToTimeKey =49999
AND a.UserLoginID=@AD_ID
		 
---Added For Checker Initially Selecting NEW/MODIFED/DELETE Pending Records To be Authorized or Rejected
If @OperationFlag in (16,17) 

Begin 

Select a.MenuId,a.ParentId,a.MenuCaption,
(ISNULL(b.IsViewer,0)) as IsViewer,
(ISNULL(b.IsMaker,0)) as IsMaker,
(ISNULL(b.IsLV1checker,0)) as IsLV1checker,
(ISNULL(b.IsLV2checker,0)) as IsLV2checker,
ISNULL(a.AuthLevel,0) AuthLevel,
@UserRole as Userrole,
CASE When @Ischecker = 'Y' AND AuthLevel in ('1','2') Then 1 Else 0 End as IsChecker,
CASE When @Ischecker2 = 'Y' AND AuthLevel in ('2') Then 1 Else 0 End as IsChecker2,
ISNULL(ModifyBy,Createdby) Createdby,
0 as OperationFLG--1 as OperationFLG CHANGE TO HANDLE VALIDATION FROM FRONT-END ON 2024-11-09
,b.SpecialUser_Flg SpecialUser /*ADDED BY ZAIN FOR USER SCREEN TOGGLE BUTTONS ON 20242111*/
,b.SpecialScreen_Flg SpecialScreen /*ADDED BY ZAIN FOR USER SCREEN TOGGLE BUTTONS ON 20242111*/
From YBL_ACS.DBO.SysCRisMacMenu a
Left Join YBL_ACS.DBO.UserRoleWiseMatrix_Mod b
on a.MenuId=b.MenuID 
AND a.ParentId=b.ParentID 
--AND b.UserRole=@USERROLENAME 
AND ISNULL(b.IsChecker,'N')=@Ischecker   -- Added by shubham on 2024-02-09 for Old IDs which were created before Checker 2 Functionality
AND ISNULL(b.Ischecker2,'N')=@Ischecker2    -- Added by shubham on 2024-02-09 for Old IDs which were created before Checker 2 Functionality
AND b.EffectiveToTimeKey=49999 
AND ISNULL(b.ADID,'')=@AD_ID 
Where a.MenuId IN
(
	SELECT 	Split.a.value('.', 'VARCHAR(100)') AS MenuId  
	FROM  (
			SELECT CAST ('<M>' + REPLACE(@Menus, ',', '</M><M>') + '</M>' AS XML) AS MenuId  
		  ) AS A CROSS APPLY MenuId.nodes ('/M') AS Split(a)   

/* ONLY CHILD MENUS TO BE SHARED AS PER THE DEVELOPMENT WHERE BOTH SCREEN SHOULD BE INDIVIDUAL  BY ZAIN ON 20241029*/
   UNION 

	SELECT ParentId AS MenuId   FROM SysCRisMacMenu WHERE  MenuId IN (SELECT 	Split.a.value('.', 'VARCHAR(100)') AS MenuId  
	FROM  (
			SELECT CAST ('<M>' + REPLACE(@Menus, ',', '</M><M>') + '</M>' AS XML) AS MenuId  
		  ) AS A CROSS APPLY MenuId.nodes ('/M') AS Split(a)   )
)order by MenuId desc


End

---Added For Maker Initially Selecting NEW/MODIFED/DELETE Pending Records From MOD and Authorized data from MAIN for CREATE/UPDATE/DELETE Operations
ELSE 

Begin 
--Selecting NP/MP/DP Records From mod Table
IF OBJECT_ID('Tempdb..##MOD_DEFAULT') IS NOT NULL  
DROP TABLE ##MOD_DEFAULT
Select a.MenuId,a.ParentId,a.MenuCaption,
(ISNULL(b.IsViewer,0)) as IsViewer,
(ISNULL(b.IsMaker,0)) as IsMaker,
(ISNULL(b.IsLV1checker,0)) as IsLV1checker,
(ISNULL(b.IsLV2checker,0)) as IsLV2checker,
ISNULL(a.AuthLevel,0) AuthLevel,
@UserRole as Userrole,
CASE When @Ischecker = 'Y' AND AuthLevel in ('1','2') Then 1 Else 0 End as IsChecker,
CASE When @Ischecker2 = 'Y' AND AuthLevel in ('2') Then 1 Else 0 End as IsChecker2,
case when b.AuthorisationStatus='A' THEN NULL ELSE b.CreatedBy END AS CREATEDBY,----CHANGED ON 202412120 BY ZAIN AS PER OBSERVATION RAISED BY NIKHIL KESKAR
0 as OperationFLG--1 as OperationFLG CHANGE TO HANDLE VALIDATION FROM FRONT-END ON 2024-11-09
,b.SpecialUser_Flg SpecialUser /*ADDED BY ZAIN FOR USER SCREEN TOGGLE BUTTONS ON 20242111*/
,b.SpecialScreen_Flg SpecialScreen /*ADDED BY ZAIN FOR USER SCREEN TOGGLE BUTTONS ON 20242111*/
into ##MOD_DEFAULT
From YBL_ACS.DBO.SysCRisMacMenu a
Left Join YBL_ACS.DBO.UserRoleWiseMatrix_Mod b
on a.MenuId=b.MenuID 
AND a.ParentId=b.ParentID
--AND b.UserRole=@USERROLENAME
AND ISNULL(b.IsChecker,'N')=@Ischecker   -- Added by shubham on 2024-02-09 for Old IDs which were created before Checker 2 Functionality
AND ISNULL(b.Ischecker2,'N')=@Ischecker2    -- Added by shubham on 2024-02-09 for Old IDs which were created before Checker 2 Functionality
AND ISNULL(b.ADID,'')=@AD_ID 
AND b.EffectiveToTimeKey=49999 
Where ISNULL(b.AuthorisationStatus,'A') IN ('NP','MP','DP')
AND a.MenuId IN
(
	SELECT 	Split.a.value('.', 'VARCHAR(100)') AS MenuId  
	FROM  (
			SELECT CAST ('<M>' + REPLACE(@Menus, ',', '</M><M>') + '</M>' AS XML) AS MenuId  
		  ) AS A CROSS APPLY MenuId.nodes ('/M') AS Split(a)   

/* ONLY CHILD MENUS TO BE SHARED AS PER THE DEVELOPMENT WHERE BOTH SCREEN SHOULD BE INDIVIDUAL  BY ZAIN ON 20241029*/
   UNION 

	SELECT ParentId AS MenuId   FROM SysCRisMacMenu WHERE  MenuId IN (SELECT 	Split.a.value('.', 'VARCHAR(100)') AS MenuId  
	FROM  (
			SELECT CAST ('<M>' + REPLACE(@Menus, ',', '</M><M>') + '</M>' AS XML) AS MenuId  
		  ) AS A CROSS APPLY MenuId.nodes ('/M') AS Split(a)   )
)

--UNION 

Insert into ##MOD_DEFAULT
--Selecting Authorized Records From main Table
Select a.MenuId,a.ParentId,a.MenuCaption,
(ISNULL(b.IsViewer,0)) as IsViewer,
(ISNULL(b.IsMaker,0)) as IsMaker,
(ISNULL(b.IsLV1checker,0)) as IsLV1checker,
(ISNULL(b.IsLV2checker,0)) as IsLV2checker,
ISNULL(a.AuthLevel,0) AuthLevel,
@UserRole as Userrole,
CASE When @Ischecker = 'Y' AND AuthLevel in ('1','2') Then 1 Else 0 End as IsChecker,
CASE When @Ischecker2 = 'Y' AND AuthLevel in ('2') Then 1 Else 0 End as IsChecker2,
NULL CREATEDBY,----CHANGED ON 202412123 BY ZAIN AS PER OBSERVATION RAISED BY NIKHIL KESKAR
0 as OperationFLG--1 as OperationFLG CHANGE TO HANDLE VALIDATION FROM FRONT-END ON 2024-11-09
,b.SpecialUser_Flg SpecialUser /*ADDED BY ZAIN FOR USER SCREEN TOGGLE BUTTONS ON 20242111*/
,b.SpecialScreen_Flg SpecialScreen /*ADDED BY ZAIN FOR USER SCREEN TOGGLE BUTTONS ON 20242111*/
From YBL_ACS.DBO.SysCRisMacMenu a
Left Join YBL_ACS.DBO.UserRoleWiseMatrix b
on a.MenuId=b.MenuID 
AND a.ParentId=b.ParentID 
--AND b.UserRole=@USERROLENAME 
/*COMMENTED BY ZAIN ON 2024-10-22 BECAUSE THERE SHOULD BE NO IMPACT FROM USER MAINTENANCE ON USER ROLE WISE MATRIX AS PER OOBSERVATION RAISED BY SANKET*/

--AND ISNULL(b.IsChecker,'N')=@Ischecker   -- Added by shubham on 2024-02-09 for Old IDs which were created before Checker 2 Functionality
--AND ISNULL(b.Ischecker2,'N')=@Ischecker2    -- Added by shubham on 2024-02-09 for Old IDs which were created before Checker 2 Functionality
/*COMMENTED BY ZAIN ON 2024-10-22 BECAUSE THERE SHOULD BE NO IMPACT FROM USER MAINTENANCE ON USER ROLE WISE MATRIX AS PER OOBSERVATION RAISED BY SANKET END*/
AND ISNULL(b.ADID,'')=@AD_ID 
AND b.EffectiveToTimeKey=49999 
Where ISNULL(b.AuthorisationStatus,'A') IN ('A')
AND a.MenuId IN
(
	SELECT 	Split.a.value('.', 'VARCHAR(100)') AS MenuId  
	FROM  (
			SELECT CAST ('<M>' + REPLACE(@Menus, ',', '</M><M>') + '</M>' AS XML) AS MenuId  
		  ) AS A CROSS APPLY MenuId.nodes ('/M') AS Split(a)   


		  /* ONLY CHILD MENUS TO BE SHARED AS PER THE DEVELOPMENT WHERE BOTH SCREEN SHOULD BE INDIVIDUAL BY ZAIN ON 20241029*/
   UNION 

	SELECT ParentId AS MenuId   FROM SysCRisMacMenu WHERE  MenuId IN (SELECT 	Split.a.value('.', 'VARCHAR(100)') AS MenuId  
	FROM  (
			SELECT CAST ('<M>' + REPLACE(@Menus, ',', '</M><M>') + '</M>' AS XML) AS MenuId  
		  ) AS A CROSS APPLY MenuId.nodes ('/M') AS Split(a)   )
)
AND A.MenuId NOT In (Select MenuID From ##MOD_DEFAULT)
			
						Select * From ##MOD_DEFAULT order by MenuId desc

End




		
		END
END


GO