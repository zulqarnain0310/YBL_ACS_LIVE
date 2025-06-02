SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO




CREate PROCEDURE [dbo].[SysCrisMACAllMenu]
--DECLARE
@UserLoginID Varchar(20)='mahesh123',
@TimeKey INT = 49999
AS
--Declare @UserLoginID Varchar(20)='mahesh123',
--@TimeKey INT = 25013
BEGIN
	Declare @DeptGrpCode int, @MenuID varchar(Max),@UserRoleAlt_Key SMALLINT
	PRINT 'A' 
	SET @DeptGrpCode = (Select DeptGroupCode from DimUserInfo where UserLoginID = @UserLoginID AND EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey)
	PRINT @DeptGrpCode
	PRINT 'B'
	SET @MenuID = (Select Menus from DimUserDeptGroup where DeptGroupId = @DeptGrpCode AND EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey)
	PRINT 'C'
	SET @UserRoleAlt_Key = (Select UserRoleAlt_Key from DimUserInfo where UserLoginID = @UserLoginID AND EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey)
	PRINT @UserRoleAlt_Key

	IF OBJECT_ID('TEMPDB..#Menu')IS NOT NULL
	DROP TABLE  #Menu


	Select   ISNULL(M.MenuId,0) MenuId ,ISNULL(M.ParentId,0) ParentId, M.MenuCaption AS MenuCaption  ,
	ActionName,M.Viewpath,M.ngController,
	M.EnableMakerChecker,M.NonAllowOperation,ISNULL(M.AccessLevel,'VIEWER')AccessLevel, M.ScreenType,M.MenuCaption ParentMenuCaption,M.ReportId AS ReportId,AvailableFor AS AvailableFor,
	CASE M.ScreenFrequency
    WHEN  'Y' THEN 'Year'
    WHEN  'H' THEN 'HalfYear'
	WHEN  'Q' THEN 'Quarter'
	WHEN  'M' THEN 'Month'
	WHEN  'W' THEN 'Week'
	WHEN  'D' THEN 'Daily'
	WHEN  'F' THEN 'Freeze'
    ELSE Null 
	END AS ScreenFrequency
	,M.CarryForwordFlag CarryForwordFlag,
	'SysCRisMacMenu' TableName INTO #Menu
		FROM SysCRisMacMenu M 
				
		WHERE  M.visible=1  and ISNULL(M.MenuId,0)<>0
		and M.MenuId IN
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
		
	
		ORDER BY MenuTitleID, DataSeq
		
		--/*Parent Id select*/
		SELECT MenuID ,
		MenuCaption AS ParentCaption,
		ParentId AS MainParentID,
		'ParentTable' AS TableName
		 FROM #Menu
		WHERE ParentId IN (0,9999) AND MenuID NOT IN (10700,10701,2)
		ORDER BY ParentId,MenuID,MenuCaption
		


		select A.*,case when B.ActionName='#'  then B.ParentId else (case when A.ParentId=9999 then A.MenuId else A.ParentId END)   End AS MainParentId FROM #Menu A
		left join #Menu B on B.MenuId=A.ParentId AND  B.ParentId NOT IN (0,9999) AND B.ParentId  IN (50,600)
		WHERE A.ReportId IS NULL AND A.MenuId not in (10700,10701,2) AND A.ActionName NOT IN ('#')
		ORDER BY ParentId,MenuID 

	
	
	--Get Location --


			SET NOCOUNT ON;    
		   DECLARE  @Tier INT  
		   DECLARE  @UserLocation VARCHAR(50)  
		   SET @Tier = (SELECT Tier from SysReportformat )  
		
		   
		   SET @UserLocation=(SELECT UserLocation  FROM DimUserInfo WHERE  
		                     (DimUserInfo.EffectiveFromTimekey<=@TimeKey AND DimUserInfo.EffectiveToTimekey>=@TimeKey) and  UserLoginID =@UserLoginID)   
		
		    
		
		  print @UserLocation  
		  print @tier  
-------  
				IF (@Tier = '4')  
				     BEGIN  
							PRINT CAST(@Tier AS  VARCHAR(1))+'Tier'
								   IF  @UserLocation = 'HO'  
								         SELECT UserLocationAlt_Key ,LocationShortName,LocationName as  'LocationDescription' ,'Location' TableName FROM  dimuserlocation    
								       Where  UserLocationAlt_Key IN(1,2,3,4) --ii ,4
								        
								   ELSE IF  @UserLocation = 'ZO'  
								      SELECT UserLocationAlt_Key ,LocationShortName,LocationName as  'LocationDescription' ,'Location' TableName FROM  dimuserlocation    
								      Where  UserLocationAlt_Key IN(2,3,4)  --ii ,4 
								       
								   ELSE IF  @UserLocation = 'RO'  
								      SELECT UserLocationAlt_Key ,LocationShortName,LocationName as  'LocationDescription' ,'Location' TableName FROM  dimuserlocation    
								      Where   UserLocationAlt_Key IN(3,4)   --ii ,4
								       
								   ELSE IF  @UserLocation = 'BO'  
								      SELECT UserLocationAlt_Key ,LocationShortName,LocationName as  'LocationDescription' ,'Location' TableName FROM  dimuserlocation    
								      Where   EffectiveFromTimekey<=@TimeKey   
								     AND EffectiveToTimekey>=@TimeKey  AND UserLocationAlt_Key IN(4)  
				     
				  
				      END  
				ELSE IF (@Tier = '3')  
				     BEGIN  
								 IF  @UserLocation = 'HO'  
								         SELECT UserLocationAlt_Key ,LocationShortName,LocationName as  'LocationDescription' ,'Location' TableName FROM  dimuserlocation    
								       Where  UserLocationAlt_Key IN(1,3,4) --ii ,4
								
								   ELSE IF  @UserLocation = 'RO'  
								      SELECT UserLocationAlt_Key ,LocationShortName,LocationName as  'LocationDescription' ,'Location' TableName FROM  dimuserlocation    
								      Where   UserLocationAlt_Key IN(3,4)   --ii ,4
								       
								   ELSE IF  @UserLocation = 'BO'  
								      SELECT UserLocationAlt_Key ,LocationShortName,LocationName as  'LocationDescription' ,'Location' TableName FROM  dimuserlocation    
								      Where   EffectiveFromTimekey<=@TimeKey   
								     AND EffectiveToTimekey>=@TimeKey  AND UserLocationAlt_Key IN(4)  
								   END  
				ELSE IF (@Tier = '2')  
				    BEGIN  
								   IF  @UserLocation = 'HO'  
								      SELECT UserLocationAlt_Key ,LocationShortName,LocationName as  'LocationDescription' ,'Location' TableName FROM  dimuserlocation    
								      Where UserLocationAlt_Key IN(1)  --ii ,4 
								      
								ELSE IF  @UserLocation = 'BO'  
								      SELECT UserLocationAlt_Key ,LocationShortName,LocationName as  'LocationDescription' ,'Location' TableName FROM  dimuserlocation    
								      --ii Where UserLocationAlt_Key IN(4)  
					  END
END









GO