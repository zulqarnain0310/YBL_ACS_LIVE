SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create PROC [dbo].[MocFreezeSelect]
--DECLARE 
		 @LastQtrDateKey INT = 24927
		,@TImekey		INT =49999
		,@UserLoginID VARCHAR(20)='komalhu'
AS	
	DECLARE @UserLocation VARCHAR(10),@UserLocationCode VARCHAR(10) 
	DECLARE @Code VARCHAR(20)  
	--SELECT * FROM SysDataMatrix WHERE 


	SELECT	@UserLocation= UserLocation	
			,@UserLocationCode= UserLocationCode
	 FROM DimUserInfo
	WHERE EffectiveFromTimeKey<= @TImekey AND EffectiveToTimeKey >= @TImekey
	AND UserLoginID = @UserLoginID


	SET @Code=(SELECT UserLocationCode  FROM DimUserInfo WHERE   
                     (DimUserInfo.EffectiveFromTimekey<=@TimeKey AND DimUserInfo.EffectiveToTimekey>=@TimeKey) and UserLoginID =@UserLoginID )  
	IF  @UserLocation = 'HO'  
         SELECT UserLocationAlt_Key ,LocationShortName Code,LocationName as  'Description','UserLevelType' TableName  FROM  dimuserlocation    
       Where  UserLocationAlt_Key IN(1,2,3,4) --ii ,4
        
   ELSE IF  @UserLocation = 'ZO'  
      SELECT UserLocationAlt_Key ,LocationShortName Code,LocationName as  'Description','UserLevelType' TableName  FROM  dimuserlocation    
      Where  UserLocationAlt_Key IN(2,3,4)  --ii ,4 
       
   ELSE IF  @UserLocation = 'RO'  
      SELECT UserLocationAlt_Key ,LocationShortName Code,LocationName as  'Description','UserLevelType' TableName  FROM  dimuserlocation    
      Where   UserLocationAlt_Key IN(3,4)   --ii ,4
       
   ELSE IF  @UserLocation = 'BO'  
      SELECT UserLocationAlt_Key ,LocationShortName,LocationName as  'Description','UserLevelType' TableName  FROM  dimuserlocation    
      Where   EffectiveFromTimekey<=@TimeKey   
     AND EffectiveToTimekey>=@TimeKey  AND UserLocationAlt_Key IN(4)  
     
  
  IF  @UserLocation = 'ZO'  
   BEGIN  
			PRINT 'ZO'
         --BRANCH
			SELECT DISTINCT BranchCode Code  ,BranchName Description,'DimBranch' TableName
			                  FROM DimBranch   
			    
			      WHERE   
			      (DimBranch.EffectiveFromTimeKey    < = @TimeKey     
			      AND DimBranch.EffectiveToTimeKey  > = @TimeKey)  
			      and  DimBranch.BranchZoneAlt_Key  = @Code  
			      AND ISNULL(DimBranch.AllowLogin,'N')='Y'  
				  AND EXISTS
						(SELECT BranchCode FROM FactBranch_Moc 
						WHERE FactBranch_Moc.TimeKey = @LastQtrDateKey
						AND FactBranch_Moc.BranchCode = DimBranch.BranchCode
						AND ISNULL(FactBranch_Moc.BO_MOC_Frozen,'N')='N')      
			      ORDER BY DimBranch.BranchName     
            
				--REGION
				SELECT DISTINCT RegionAlt_Key Code  , RegionName   Description,'DimRegion' TableName
				  FROM DimBranch   
				    
				   INNER JOIN DimRegion ON DimBranch.BranchRegionAlt_Key = DimRegion.RegionAlt_Key  
				     
				      WHERE   
				           (DimRegion.EffectiveFromTimeKey    < = @TimeKey     
				      AND DimRegion.EffectiveToTimeKey  > = @TimeKey)  
					  AND EXISTS
						(SELECT BranchCode FROM FactBranch_Moc 
						WHERE FactBranch_Moc.TimeKey = @LastQtrDateKey
						AND FactBranch_Moc.BranchCode = DimBranch.BranchCode
						AND ISNULL(FactBranch_Moc.RO_MOC_Frozen,'N')='N')   
				      and ZoneAlt_Key = @Code  
				  
				      ORDER BY RegionName     
         

				--ZONE
				SELECT DISTINCT ZoneAlt_Key Code  ,DimZone.ZoneName    Description,'DimZone' TableName
				              FROM DimBranch  
				 
				INNER JOIN DimZone ON DimBranch.BranchZoneAlt_Key = DimZone.ZoneAlt_Key  
				 
				               WHERE   
				               (DimZone.EffectiveFromTimeKey    < = @TimeKey     
				         AND DimZone.EffectiveToTimeKey  > = @TimeKey)  
						  AND EXISTS
						(SELECT BranchCode FROM FactBranch_Moc 
						WHERE FactBranch_Moc.TimeKey = @LastQtrDateKey
						AND FactBranch_Moc.BranchCode = DimBranch.BranchCode
						AND ISNULL(FactBranch_Moc.ZO_MOC_Frozen,'N')='N')   
				               and ZoneAlt_Key = @Code   
				                 ORDER BY DimZone.ZoneName    

    END  
  
   ELSE IF @UserLocation = 'RO'
      BEGIN  
	  PRINT 'RO'
				--BRANCH
				SELECT DISTINCT BranchCode Code ,BranchName Description,'DimBranch' TableName
				                    FROM DimBranch   
				     
				        WHERE    
				        (DimBranch.EffectiveFromTimeKey    < = @TimeKey     
				        AND DimBranch.EffectiveToTimeKey  > = @TimeKey)  
				       AND DimBranch.BranchRegionAlt_Key    = @Code  
				        AND (ISNULL(DimBranch.AllowLogin,'N')='Y'  or ISNULL(DimBranch.AllowMakerChecker,'N')='Y')       
						 AND EXISTS
						(SELECT BranchCode FROM FactBranch_Moc 
						WHERE FactBranch_Moc.TimeKey = @LastQtrDateKey
						AND FactBranch_Moc.BranchCode = DimBranch.BranchCode
						AND ISNULL(FactBranch_Moc.BO_MOC_Frozen,'N')='N')   
				        ORDER BY DimBranch.BranchName     

				 --REGION      
				 SELECT   RegionAlt_Key Code,RegionName  Description ,'DimRegion' TableName FROM  
				         (SELECT DISTINCT RegionAlt_Key, RegionName, 1 AS CODE 
				           FROM DimBranch  
				            
				           INNER JOIN DimRegion ON DimBranch.BranchRegionAlt_Key = DimRegion.RegionAlt_Key  
				            
				           WHERE   
				            (DimRegion.EffectiveFromTimeKey    < = @TimeKey     
				           AND DimRegion.EffectiveToTimeKey  > = @TimeKey)   
						   AND EXISTS
						(SELECT BranchCode FROM FactBranch_Moc 
						WHERE FactBranch_Moc.TimeKey = @LastQtrDateKey
						AND FactBranch_Moc.BranchCode = DimBranch.BranchCode
						AND ISNULL(FactBranch_Moc.RO_MOC_Frozen,'N')='N')   
				           AND RegionAlt_Key = @Code  
				             
				           
				         UNION  
				         SELECT DISTINCT BranchCode  AS RegionAlt_Key, BranchName AS RegionName, 2 AS CODE   
				           FROM DimBranch   
				           WHERE BranchType='RI'
						    AND EXISTS
						(SELECT BranchCode FROM FactBranch_Moc 
						WHERE FactBranch_Moc.TimeKey = @LastQtrDateKey
						AND FactBranch_Moc.BranchCode = DimBranch.BranchCode
						AND ISNULL(FactBranch_Moc.RO_MOC_Frozen,'N')='N')   )  

				      DimBranch ORDER BY CODE  
     
  
     END


   ELSE IF @UserLocation = 'BO'  
        BEGIN  
		PRINT 'BO'
					  SELECT DISTINCT BranchCode Code,BranchName Description,'DimBranch' TableName
					              FROM DimBranch   
       
					           WHERE   
					           (DimBranch.EffectiveFromTimeKey    < = @TimeKey     
					           AND DimBranch.EffectiveToTimeKey  > = @TimeKey)  
							   AND EXISTS
						(SELECT BranchCode FROM FactBranch_Moc 
						WHERE FactBranch_Moc.TimeKey = @LastQtrDateKey
						AND FactBranch_Moc.BranchCode = DimBranch.BranchCode
						AND ISNULL(FactBranch_Moc.BO_MOC_Frozen,'N')='N')   
					           AND BranchCode  = @Code  
					           ORDER BY BranchName    
	
	
	
     END   
   ELSE IF  @UserLocation = 'HO'  
    BEGIN  
	PRINT 'HO'
					--BRANCH
					 SELECT DISTINCT BranchCode Code,BranchName Description,'DimBranch' TableName
					                    FROM DimBranch   
					                 WHERE  (DimBranch.EffectiveFromTimeKey    < = @TimeKey     
					              AND DimBranch.EffectiveToTimeKey  > = @TimeKey)   
					              --AND ISNULL(BranchType,'ZO') NOT IN ('HO','HI','RI','RO')  
					              --AND BranchName IS NOT NULL  
					                
					              AND (ISNULL(DimBranch.AllowLogin,'Y')='Y'  or ISNULL(DimBranch.AllowMakerChecker,'Y')='Y')    
								  AND EXISTS
						(SELECT BranchCode FROM FactBranch_Moc 
						WHERE FactBranch_Moc.TimeKey = @LastQtrDateKey
						AND FactBranch_Moc.BranchCode = DimBranch.BranchCode
						AND ISNULL(FactBranch_Moc.BO_MOC_Frozen,'N')='N')
					                    ORDER BY Dimbranch.BranchName     

					--REGION
					  SELECT   RegionAlt_Key Code,RegionName Description,'DimRegion' TableName FROM  
					          (SELECT DISTINCT RegionAlt_Key, RegionName, 1 AS CODE   -- 'RO - '+RegionName AS RegionName
					            FROM DimBranch   
					             
					            INNER JOIN DimRegion ON DimBranch.BranchRegionAlt_Key = DimRegion.RegionAlt_Key  
					             
					            WHERE (DimRegion.EffectiveFromTimeKey    < = @TimeKey     
					            AND DimRegion.EffectiveToTimeKey  > = @TimeKey)   
								AND EXISTS
						(SELECT BranchCode FROM FactBranch_Moc 
						WHERE FactBranch_Moc.TimeKey = @LastQtrDateKey
						AND FactBranch_Moc.BranchCode = DimBranch.BranchCode
						AND ISNULL(FactBranch_Moc.RO_MOC_Frozen,'N')='N')
					            
					          UNION  
					          SELECT DISTINCT BranchCode AS RegionAlt_Key, BranchName AS RegionName, 2 AS CODE   
					            FROM DimBranch   
					            WHERE BranchType='RI'
								AND EXISTS
						(SELECT BranchCode FROM FactBranch_Moc 
						WHERE FactBranch_Moc.TimeKey = @LastQtrDateKey
						AND FactBranch_Moc.BranchCode = DimBranch.BranchCode
						AND ISNULL(FactBranch_Moc.RO_MOC_Frozen,'N')='N')
						)  
					       DimBranch ORDER BY CODE  


					--ZONE
					 SELECT DISTINCT ZoneAlt_Key Code,DimZone.ZoneName    Description,'DimZone' TableName
					                   FROM    DimBranch   
					    
					     LEFT JOIN DimZone ON DimBranch.BranchZoneAlt_Key = DimZone.ZoneAlt_Key  
					     
					                    WHERE (DimZone.EffectiveFromTimeKey    < = @TimeKey     
					              AND DimZone.EffectiveToTimeKey  > = @TimeKey) 
								  AND EXISTS
						(SELECT BranchCode FROM FactBranch_Moc 
						WHERE FactBranch_Moc.TimeKey = @LastQtrDateKey
						AND FactBranch_Moc.BranchCode = DimBranch.BranchCode
						AND ISNULL(FactBranch_Moc.ZO_MOC_Frozen,'N')='N')  
								  ORDER BY ZoneName    
					    
   
   
      END  
   


GO