SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create PROCEDURE [dbo].[SysCrisMAcModuleMenu_mvc_25022025]--'DM585' , 26886
@UserLoginID Varchar(30)='',
@TimeKey INT = 49999,
@SessionId Varchar(200)=''

AS
--Declare 
--@UserLoginID Varchar(30)='akshay.kale',
--@TimeKey INT = 26886
Declare 
@Ischecker char,
@Ischecker2 char,
@SpecialUser_Flg char,
@SpecialScreen_Flg char

BEGIN

Select @Ischecker=ISNULL(IsChecker,'N'),@Ischecker2=ISNULL(IsChecker2,'N')
/*ADDED BY ZAIN BASED ON RCAI MATRIX SPECIAL SCREEN DEVELOPMENT ON LOCAL 20241031*/
		,@SpecialUser_Flg=ISNULL(A.SpecialUser_Flg,'N')
		,@SpecialScreen_Flg=ISNULL(A.SpecialScreen_Flg,'N')	
/*ADDED BY ZAIN BASED ON RCAI MATRIX SPECIAL SCREEN DEVELOPMENT ON LOCAL 20241031 END*/
From DimUserInfo a 
INNER JOIN DimUserDeptGroup b on a.DeptGroupCode=b.DeptGroupId
where a.EffectiveToTimeKey =49999
	AND b.EffectiveToTimeKey =49999
	AND a.UserLoginID=@UserLoginID

PRINT '@SpecialUser_Flg'
PRINT @SpecialUser_Flg
PRINT '@SpecialScreen_Flg'
PRINT @SpecialScreen_Flg

	Declare @DeptGrpCode int, @MenuID varchar(Max),
	@MenuID1 varchar(Max),
	@MenuID2 varchar(Max),
	@UserRoleAlt_Key SMALLINT, @USerLocation VARCHAR(10)
	PRINT 'A' 
	--SET @DeptGrpCode = (
	SELECT @DeptGrpCode = DeptGroupCode , @USerLocation = UserLocation  from DimUserInfo where UserLoginID = @UserLoginID AND EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey
	PRINT @DeptGrpCode
	PRINT 'B'
	/*PATCH FOR OBSERVATION OF DEPT LEVEL UNABLE TO SEE SCREEN RAISED BY FM ON 2024-12-11*/
	SET @MenuID1 = (Select DISTINCT Menus from DimUserDeptGroup where DeptGroupId = @DeptGrpCode AND 
						EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey)
 
	
	SET @MenuID2 = (SELECT  
						   DISTINCT STUFF((SELECT ', ' + CAST(MenuId AS VARCHAR(10)) [text()]
							 FROM SysCRisMacMenu 
							 WHERE Spl_Screenflg = 'Y'
							 FOR XML PATH(''), TYPE)
							.value('.','NVARCHAR(MAX)'),1,2,' ') 
					FROM SysCRisMacMenu t
					GROUP BY MenuId)

	SET @MenuID=CONCAT(@MenuID1,',',@MenuID2)
	PRINT 'MenuID'
	PRINT @MenuID
	/*PATCH FOR OBSERVATION OF DEPT LEVEL UNABLE TO SEE SCREEN RAISED BY FM ON 2024-12-11 END*/
	PRINT 'C'
/*ADDED BY ZAIN ON 2024-10-19 TO HANDLE MULTIPLE NP,MP & A STATUS DATA*/
	SET @UserRoleAlt_Key = (Select distinct UserRoleAlt_Key from DimUserInfo 
			where UserLoginID = @UserLoginID AND EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey and AuthorisationStatus='A')
/*COMMENTED BY ZAIN ON 2024-10-19 TO HANDLE MULTIPLE NP,MP & A STATUS DATA END*/

/*COMMENTED BY ZAIN ON 2024-10-19 TO HANDLE MULTIPLE NP,MP & A STATUS DATA*/
	---SET @UserRoleAlt_Key = (Select UserRoleAlt_Key from DimUserInfo where UserLoginID = @UserLoginID AND EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey and AuthorisationStatus='A')
/*COMMENTED BY ZAIN TO HANDLE MULTIPLE NP,MP & A STATUS DATA END*/

	PRINT @UserRoleAlt_Key
	--SET @UserRoleAlt_Key = 3
	PRINT 'D'
	--SET @USerLocation = (SELECT  UserLocation FROM  DimUserInfo WHERE EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey AND UserLoginID = @UserLoginID)
	--PRINT @USerLocation
	DECLARE

			@UserType varchar(10)


		--	select @UserType=WFR.WorkFlowUserRoleShortName from DimWorkFlowUserRole WFR
		--			INNER JOIN DimUserInfo DU
		--				ON WFR.WorkFlowUserRoleAlt_Key=DU.WorkFlowUserRoleAlt_Key
		--			WHERE DU.UserLoginID=@UserLoginID
		--PRINT @UserType

	
	--DROP TABLE IF EXISTS #SysCRisMacMenu

	IF OBJECT_ID('tempdb..#SysCRisMacMenu') IS NOT NULL
		DROP TABLE #SysCRisMacMenu

	Select  EntityKey, MenuTitleId,DataSeq, ISNULL(MenuId,0) MenuId ,ISNULL(ParentId,0) ParentId,MenuCaption, ISNULL(CAST(ActionName AS VARCHAR(MAX)),ReportUrl)  
	ActionName,Viewpath,ngController,
	BusFld,EnableMakerChecker,AuthLevel,NonAllowOperation,ISNULL(AccessLevel,'VIEWER')AccessLevel, ScreenType
	,
	CASE ScreenFrequency
    WHEN  'Y' THEN 'Year'
    WHEN  'H' THEN 'HalfYear'
	WHEN  'Q' THEN 'Quarter'
	WHEN  'M' THEN 'Month'
	WHEN  'W' THEN 'Week'
	WHEN  'D' THEN 'Daily'
	WHEN  'F' THEN 'Freeze'
    ELSE Null 
	END AS ScreenFrequency
	,CarryForwordFlag,FreqEndPeriod
	INTO #SysCRisMacMenu
		FROM SysCRisMacMenu M 
			LEFT JOIN SysReportDirectory R
				ON M.MenuId = R.ReportMenuId
		WHERE  visible=1  --and  MenuTitleId<>50 
		and MenuId IN
		(
			SELECT 	Split.a.value('.', 'VARCHAR(100)') AS MenuId  
			FROM  (
					SELECT CAST ('<M>' + REPLACE(@MenuID, ',', '</M><M>') + '</M>' AS XML) AS MenuId  
				  ) AS A CROSS APPLY MenuId.nodes ('/M') AS Split(a)   

		   UNION 

			SELECT ParentId AS MenuId   FROM SysCRisMacMenu WHERE  MenuId IN (SELECT 	Split.a.value('.', 'VARCHAR(100)') AS MenuId  
			FROM  (
					SELECT CAST ('<M>' + REPLACE(@MenuID, ',', '</M><M>') + '</M>' AS XML) AS MenuId  
				  ) AS A CROSS APPLY MenuId.nodes ('/M') AS Split(a)   )
		)
		
		--AND ParentId = 0 
	--UNION
	--	SELECT  EntityKey, MenuTitleId,DataSeq, ISNULL(MenuId,0) MenuId ,ISNULL(ParentId,0) ParentId,
	--		MenuCaption,  ISNULL(CAST(ActionName AS VARCHAR(MAX)),ReportUrl)  
	--		ActionName,Viewpath,ngController,BusFld,EnableMakerChecker,
	--			NonAllowOperation,ISNULL(AccessLevel,'VIEWER')AccessLevel, ScreenType
	--	FROM SysCRisMacMenu M 
	--		LEFT JOIN SysReportDirectory R
	--		ON M.MenuId = R.ReportMenuId
	--	WHERE --DeptGroupCode='ALL' and 
	--	visible=1 --and  MenuTitleId<>50 
	--	AND (CASE WHEN @UserRoleAlt_Key = 1 AND M.MenuId<>0 THEN 1 
	--			  WHEN @UserRoleAlt_Key <> 1 AND M.MenuId NOT IN (52,56,58,60,62,64,65,66,67,68,150,305) THEN 1 END )= 1
		
	--ORDER BY MenuTitleID, DataSeq

	--SELECT AvailableFor, * FROM SysCRisMacMenu s


IF (@SpecialUser_Flg='N' AND @SpecialScreen_Flg='Y')
	BEGIN
		SELECT DISTINCT S.*,
		ISNULL(Case When u.IsViewer is null AND u.UserRole in (1,2,3,4) Then 1 Else u.IsViewer End,0) as IsViewer,
		ISNULL(Case When u.IsMaker is null AND u.UserRole in (1,2,3) Then 1 Else u.IsMaker End,0) as IsMaker,
		ISNULL(Case When u.IsLV1checker is null AND u.UserRole in (1,2,3,4) AND ss.AuthLevel=NULL AND SS.Spl_Screenflg='Y' Then 0 -------ADDED BY ZAIN ON 2024-10-19 TO HANDLE CHECKER LEVEL1 
					When u.IsLV1checker is null AND u.UserRole in (1,2,3,4) AND ss.AuthLevel=NULL Then 0 
					Else (Case When @Ischecker ='Y' AND ss.AuthLevel in (1,2) AND u.IsLV1checker is null Then 1--CHANGED FROM 0-1 AS PER OBSERVATION RAISE BY FM ON 2024-12-10
					Else u.IsLV1checker End) End,0) as IsLV1checker,
		ISNULL(Case When u.IsLV2checker is null AND u.UserRole in (1,2,3,4) AND ss.AuthLevel=NULL AND SS.Spl_Screenflg='Y' Then 0 -------ADDED BY ZAIN ON 2024-10-19 TO HANDLE CHECKER LEVEL1 
				When u.IsLV2checker is null AND u.UserRole in (1,2,3,4) AND ss.AuthLevel=NULL Then 0 
				Else (Case When @Ischecker2 ='Y' AND ss.AuthLevel in (2) AND u.IsLV2checker is null Then 1 
				Else u.IsLV2checker End) End,0)as IsLV2checker 
		FROM #SysCRisMacMenu S
		INNER JOIN SysCRisMacMenu SS
			ON S.ParentId	= SS.ParentId
			AND S.MenuId	= SS.MenuId
		LEFT JOIN .DBO.UserRoleWiseMatrix U  ---- Added By shubham on 2023-10-25 For Changes against userwise screen to disply only screens which user is authorized for with the level of authority it is currently possesing 
			ON S.ParentId	= U.ParentId
			AND S.MenuId	= U.MenuId
			AND U.ADID=@UserLoginID
			AND ISNULL(U.AuthorisationStatus,'A')='A'-------ADDED BY ZAIN ON 2024-10-19 TO HANDLE CHECKER LEVEL 1 & 2 
			AND U.EffectiveFromTimeKey<=@TimeKey AND U.EffectiveToTimeKey>=@TimeKey
			--AND SS.AvailableFor LIKE '%'+@USerLocation+'%'
			
		
		EXCEPT

				SELECT DISTINCT S.*,
		ISNULL(Case When u.IsViewer is null AND u.UserRole in (1,2,3,4) Then 1 Else u.IsViewer End,0) as IsViewer,
		ISNULL(Case When u.IsMaker is null AND u.UserRole in (1,2,3) Then 1 Else u.IsMaker End,0) as IsMaker,
		ISNULL(Case When u.IsLV1checker is null AND u.UserRole in (1,2,3,4) AND ss.AuthLevel=NULL AND SS.Spl_Screenflg='Y' Then 0 -------ADDED BY ZAIN ON 2024-10-19 TO HANDLE CHECKER LEVEL1 
					When u.IsLV1checker is null AND u.UserRole in (1,2,3,4) AND ss.AuthLevel=NULL Then 0 
					Else (Case When @Ischecker ='Y' AND ss.AuthLevel in (1,2) AND u.IsLV1checker is null Then 1--CHANGED FROM 0-1 AS PER OBSERVATION RAISE BY FM ON 2024-12-10
					Else u.IsLV1checker End) End,0) as IsLV1checker,
		ISNULL(Case When u.IsLV2checker is null AND u.UserRole in (1,2,3,4) AND ss.AuthLevel=NULL AND SS.Spl_Screenflg='Y' Then 0 -------ADDED BY ZAIN ON 2024-10-19 TO HANDLE CHECKER LEVEL1 
				When u.IsLV2checker is null AND u.UserRole in (1,2,3,4) AND ss.AuthLevel=NULL Then 0 
				Else (Case When @Ischecker2 ='Y' AND ss.AuthLevel in (2) AND u.IsLV2checker is null Then 1 
				Else u.IsLV2checker End) End,0)as IsLV2checker 
		FROM #SysCRisMacMenu S
		INNER JOIN SysCRisMacMenu SS
			ON S.ParentId	= SS.ParentId
			AND S.MenuId	= SS.MenuId
		LEFT JOIN .DBO.UserRoleWiseMatrix U  ---- Added By shubham on 2023-10-25 For Changes against userwise screen to disply only screens which user is authorized for with the level of authority it is currently possesing 
			ON S.ParentId	= U.ParentId
			AND S.MenuId	= U.MenuId
			AND U.ADID=@UserLoginID
			AND ISNULL(U.AuthorisationStatus,'A')='A'-------ADDED BY ZAIN ON 2024-10-19 TO HANDLE CHECKER LEVEL 1 & 2 
			AND U.EffectiveFromTimeKey<=@TimeKey AND U.EffectiveToTimeKey>=@TimeKey
			--AND SS.AvailableFor LIKE '%'+@USerLocation+'%'
			WHERE (ISNULL(ISMAKER,'0')='0' AND ISNULL(ISVIEWER,'0')='0' 
											AND ISNULL(IsLV1checker,'0')='0' AND ISNULL(IsLV2checker,'0')='0')
				AND Spl_Screenflg='Y'
		
		ORDER BY S.MenuTitleID, S.DataSeq
	END

ELSE IF (@SpecialUser_Flg='N' AND @SpecialScreen_Flg='N')
	BEGIN
		SELECT DISTINCT S.*,
		ISNULL(Case When u.IsViewer is null AND u.UserRole in (1,2,3,4) Then 1 Else u.IsViewer End,0) as IsViewer,
		ISNULL(Case When u.IsMaker is null AND u.UserRole in (1,2,3) Then 1 Else u.IsMaker End,0) as IsMaker,
		ISNULL(Case When u.IsLV1checker is null AND u.UserRole in (1,2,3,4) AND ss.AuthLevel=NULL AND SS.Spl_Screenflg='Y' Then 0 -------ADDED BY ZAIN ON 2024-10-19 TO HANDLE CHECKER LEVEL1 
					When u.IsLV1checker is null AND u.UserRole in (1,2,3,4) AND ss.AuthLevel=NULL Then 0 
					Else (Case When @Ischecker ='Y' AND ss.AuthLevel in (1,2) AND u.IsLV1checker is null Then 1 --CHANGED FROM 0-1 AS PER OBSERVATION RAISE BY FM ON 2024-12-10
					Else u.IsLV1checker End) End,0) as IsLV1checker,
		ISNULL(Case When u.IsLV1checker is null AND u.UserRole in (1,2,3,4) AND ss.AuthLevel=NULL AND SS.Spl_Screenflg='Y' Then 0 -------ADDED BY ZAIN ON 2024-10-19 TO HANDLE CHECKER LEVEL1 
				When u.IsLV2checker is null AND u.UserRole in (1,2,3,4) AND ss.AuthLevel=NULL Then 0 
				Else (Case When @Ischecker2 ='Y' AND ss.AuthLevel in (2) AND u.IsLV2checker is null Then 1 
				Else u.IsLV2checker End) End,0)as IsLV2checker 
		FROM #SysCRisMacMenu S
		INNER JOIN SysCRisMacMenu SS
			ON S.ParentId	= SS.ParentId
			AND S.MenuId	= SS.MenuId
		LEFT JOIN .DBO.UserRoleWiseMatrix U  ---- Added By shubham on 2023-10-25 For Changes against userwise screen to disply only screens which user is authorized for with the level of authority it is currently possesing 
			ON S.ParentId	= U.ParentId
			AND S.MenuId	= U.MenuId
			AND U.ADID=@UserLoginID
			AND ISNULL(U.AuthorisationStatus,'A')='A'-------ADDED BY ZAIN ON 2024-10-19 TO HANDLE CHECKER LEVEL 1 & 2 
			AND U.EffectiveFromTimeKey<=@TimeKey AND U.EffectiveToTimeKey>=@TimeKey
			WHERE ISNULL(SS.Spl_Screenflg,'N') ='N'  /*ADDED BY ZAIN TO GET ONLY USER WITH NORMAL SCREEN RIGHTS ON LOCAL 20241031*/
			--AND SS.AvailableFor LIKE '%'+@USerLocation+'%'
	
		ORDER BY S.MenuTitleID, S.DataSeq
	END

ELSE IF (@SpecialUser_Flg='Y' AND @SpecialScreen_Flg='N')
	BEGIN
		SELECT DISTINCT S.*,
		ISNULL(Case When u.IsViewer is null AND u.UserRole in ('SUPER ADMIN','ADMIN','OPERATOR','VIEWER') Then 1 Else u.IsViewer End,0) as IsViewer,
		ISNULL(Case When u.IsMaker is null AND u.UserRole in ('SUPER ADMIN','ADMIN','OPERATOR') Then 1 Else u.IsMaker End,0) as IsMaker,
		ISNULL(Case When u.IsLV1checker is null AND u.UserRole in ('SUPER ADMIN','ADMIN','OPERATOR','VIEWER') AND ss.AuthLevel=NULL AND SS.Spl_Screenflg='Y' Then 0 -------ADDED BY ZAIN ON 2024-10-19 TO HANDLE CHECKER LEVEL1 
					When u.IsLV1checker is null AND u.UserRole in ('SUPER ADMIN','ADMIN','OPERATOR','VIEWER') AND ss.AuthLevel=NULL Then 0 
					Else (Case When @Ischecker ='Y' AND ss.AuthLevel in ('SUPER ADMIN','ADMIN') AND u.IsLV1checker is null Then 1 
					Else u.IsLV1checker End) End,0) as IsLV1checker,
		ISNULL(Case When u.IsLV1checker is null AND u.UserRole in ('SUPER ADMIN','ADMIN','OPERATOR','VIEWER') AND ss.AuthLevel=NULL AND Spl_Screenflg='Y' Then 0 -------ADDED BY ZAIN ON 2024-10-19 TO HANDLE CHECKER LEVEL 2 
				When u.IsLV2checker is null AND u.UserRole in ('SUPER ADMIN','ADMIN','OPERATOR','VIEWER') AND ss.AuthLevel=NULL Then 0 
				Else (Case When @Ischecker2 ='Y' AND ss.AuthLevel in (2) AND u.IsLV2checker is null Then 1 
				Else u.IsLV2checker End) End,0)as IsLV2checker 
		FROM #SysCRisMacMenu S
		INNER JOIN SysCRisMacMenu SS
			ON S.ParentId	= SS.ParentId
			AND S.MenuId	= SS.MenuId
		/*ADDED BY ZAIN TAKING INNER JOIN INSTEAD OF LEFT JOIN TO GET ONLY USER WITH SPECIAL SCREEN RIGHTS ON LOCAL 20241031*/
		LEFT JOIN .DBO.UserRoleWiseMatrix U  ---- Added By shubham on 2023-10-25 For Changes against userwise screen to disply only screens which user is authorized for with the level of authority it is currently possesing 
			ON S.ParentId	= U.ParentId
			AND S.MenuId	= U.MenuId
			AND U.ADID=@UserLoginID
			AND ISNULL(U.AuthorisationStatus,'A')='A'-------ADDED BY ZAIN ON 2024-10-19 TO HANDLE CHECKER LEVEL 1 & 2 
			AND U.EffectiveFromTimeKey<=@TimeKey AND U.EffectiveToTimeKey>=@TimeKey
			--AND SS.AvailableFor LIKE '%'+@USerLocation+'%'
			WHERE ISNULL(SS.Spl_Screenflg,'N') ='Y'  /*ADDED BY ZAIN TO GET ONLY USER WITH SPECIAL SCREEN RIGHTS ON LOCAL 20241031*/
			AND (ISNULL(ISMAKER,'0')<>'0' OR ISNULL(ISVIEWER,'0')<>'0' 
											OR ISNULL(IsLV1checker,'0')<>'0' OR ISNULL(IsLV2checker,'0')<>'0')
		
		EXCEPT

				SELECT DISTINCT S.*,
		ISNULL(Case When u.IsViewer is null AND u.UserRole in (1,2,3,4) Then 1 Else u.IsViewer End,0) as IsViewer,
		ISNULL(Case When u.IsMaker is null AND u.UserRole in (1,2,3) Then 1 Else u.IsMaker End,0) as IsMaker,
		ISNULL(Case When u.IsLV1checker is null AND u.UserRole in (1,2,3,4) AND ss.AuthLevel=NULL AND SS.Spl_Screenflg='Y' Then 0 -------ADDED BY ZAIN ON 2024-10-19 TO HANDLE CHECKER LEVEL1 
					When u.IsLV1checker is null AND u.UserRole in (1,2,3,4) AND ss.AuthLevel=NULL Then 0 
					Else (Case When @Ischecker ='Y' AND ss.AuthLevel in (1,2) AND u.IsLV1checker is null Then 0
					Else u.IsLV1checker End) End,0) as IsLV1checker,
		ISNULL(Case When u.IsLV2checker is null AND u.UserRole in (1,2,3,4) AND ss.AuthLevel=NULL AND SS.Spl_Screenflg='Y' Then 0 -------ADDED BY ZAIN ON 2024-10-19 TO HANDLE CHECKER LEVEL1 
				When u.IsLV2checker is null AND u.UserRole in (1,2,3,4) AND ss.AuthLevel=NULL Then 0 
				Else (Case When @Ischecker2 ='Y' AND ss.AuthLevel in (2) AND u.IsLV2checker is null Then 1 
				Else u.IsLV2checker End) End,0)as IsLV2checker 
		FROM #SysCRisMacMenu S
		INNER JOIN SysCRisMacMenu SS
			ON S.ParentId	= SS.ParentId
			AND S.MenuId	= SS.MenuId
		LEFT JOIN .DBO.UserRoleWiseMatrix U  ---- Added By shubham on 2023-10-25 For Changes against userwise screen to disply only screens which user is authorized for with the level of authority it is currently possesing 
			ON S.ParentId	= U.ParentId
			AND S.MenuId	= U.MenuId
			AND U.ADID=@UserLoginID
			AND ISNULL(U.AuthorisationStatus,'A')='A'-------ADDED BY ZAIN ON 2024-10-19 TO HANDLE CHECKER LEVEL 1 & 2 
			AND U.EffectiveFromTimeKey<=@TimeKey AND U.EffectiveToTimeKey>=@TimeKey
			--AND SS.AvailableFor LIKE '%'+@USerLocation+'%'
			WHERE (ISNULL(ISMAKER,'0')='0' AND ISNULL(ISVIEWER,'0')='0' 
											AND ISNULL(IsLV1checker,'0')='0' AND ISNULL(IsLV2checker,'0')='0')
				AND Spl_Screenflg='Y'
		
		ORDER BY S.MenuTitleID, S.DataSeq
	END
	--This is for concurrent User change
	Update DimUserInfo set SessionId = @SessionId where UserLoginID=@UserLoginID
END








GO