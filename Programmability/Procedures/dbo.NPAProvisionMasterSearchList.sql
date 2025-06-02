SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

  
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------  
CREATE PROC [dbo].[NPAProvisionMasterSearchList]  
--Declare  
             --@PageNo         INT         = 1,   
             --@PageSize       INT         = 10,   
             @OperationFlag  INT         = 1  
AS  
       
  BEGIN  
  
SET NOCOUNT ON;  
Declare @TimeKey as Int  
 SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')  
       
  
BEGIN TRY  
  
/*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */  
  
   IF(@OperationFlag not in (16,17,20))  
             BEGIN  
    IF OBJECT_ID('TempDB..#temp') IS NOT NULL  
                 DROP TABLE  #temp;  
                 SELECT  A.ProvisionAlt_Key,  
       A.ProvisionName,  
       A.CODE,  
       A.ProvisionSecured,  
       A.ProvisionUnSecured,  
       A.AuthorisationStatus,   
	   A.AuthorisationStatusName, 
                            A.EffectiveFromTimeKey,   
                            A.EffectiveToTimeKey,   
                            A.CreatedBy,   
                            A.DateCreated,   
                            A.ApprovedBy,   
                            A.DateApproved,   
                            A.ModifiedBy,   
                            A.DateModified,  
       A.CrModBy,  
       A.CrModDate,  
       A.CrAppBy,  
       A.CrAppDate,  
       A.ModAppBy,  
       A.ModAppDate  
       ,A.LowerDPD  
       ,A.UpperDPD  
       ,A.Segment
	   ,ProvisionRule
	   ,RBIProvisionSecured
	   ,RBIProvisionUnSecured
	   ,FacilityType
     --  ,A.ChangeFields  
	    --,A.EffectiveFromDate
                 INTO #temp  
                 FROM   
                 (  
                     SELECT   
       A.ProvisionAlt_Key,  
       A.ProvisionName   ProvisionName,  
       B.AssetClassAlt_Key CODE,  
       A.ProvisionSecured,  
       A.ProvisionUnSecured,  
       isnull(A.AuthorisationStatus, 'A') AuthorisationStatus,
							Case when  isnull(A.AuthorisationStatus, 'A')='A' THen 'Authorized'
							when  isnull(A.AuthorisationStatus, 'A') in ('NP','MP','FM','1A') THen 'Pending Authorisation'
							--when  isnull(A.AuthorisationStatus, 'A')='MP' THen 'Modified Pending'
							--when  isnull(A.AuthorisationStatus, 'A')='FM' THen 'Further Modified'
							--when  isnull(A.AuthorisationStatus, 'A')='R' THen 'Reject'
							--when  isnull(A.AuthorisationStatus, 'A')='1A' THen 'First Authorized'
							ENd AS AuthorisationStatusName, 
                            A.EffectiveFromTimeKey,   
                            A.EffectiveToTimeKey,   
                            A.CreatedBy,   
                            A.DateCreated,   
                            A.ApprovedBy,   
                            convert(varchar(20),A.DateApproved,103) DateApproved,   
                            A.ModifiedBy,   
                            A.DateModified  
       ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy  
       ,IsNull(A.DateModified,A.DateCreated)as CrModDate  
       ,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy  
       ,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate  
       ,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy  
       ,ISNULL(A.DateApproved,A.DateModified) as ModAppDate  
       ,A.LowerDPD  
       ,A.UpperDPD  
       ,A.Segment
	   ,ProvisionRule
	   ,RBIProvisionSecured
	   ,RBIProvisionUnSecured
	   ,a.ProvisionShortNameEnum as FacilityType
       --,A.ChangeFields  
	   --,Convert(Varchar(10),A.EffectiveFromDate,103) EffectiveFromDate
                     FROM DimProvision_Seg A   
      left join dimassetclass B  
      on a.ProvisionName=b.AssetClassShortNameEnum  
      WHERE   
      --A.ProvisionName  in ('002 - Sub Standard'  
      --    ,'Sub Standard Infrastructure'  
      --    ,'Sub Standard Ab initio Unsecured'  
      --    ,'003 - Doubtful'  
      --    ,'Doubtful-II'  
      --    ,'Doubtful-III'  
      --    ,'004-Loss' )  
        
      --('Sub Standard Ab initio Unsecured'  
      -- ,'Direct advances to agricultural sectors'  
      -- ,'Direct advances to SME sectors'  
      -- ,'Commercial Real Estate (CRE) Sector'  
      -- ,'Commercial Real Estate - Residential Housing Sector (CRE - RH)'  
      -- ,'Housing loans at teaser rates'  
      -- ,'Standard Restructured accounts'  
      -- ,'Home loans with adequate Loan to Value Ratio (LTV) as prescribed by RBI'  
      -- ,'All other advances not included above')  
         --AND   
         A.EffectiveFromTimeKey <= @TimeKey  
                           AND A.EffectiveToTimeKey >= @TimeKey  
                           AND ISNULL(A.AuthorisationStatus, 'A') = 'A'  
                     UNION  
                     SELECT A.ProvisionAlt_Key,  
       A.ProvisionName ProvisionName,  
       B.AssetClassAlt_Key CODE,  
       A.ProvisionSecured,  
       A.ProvisionUnSecured,  
       isnull(A.AuthorisationStatus, 'A') AuthorisationStatus,  
							Case when  isnull(A.AuthorisationStatus, 'A')='A' THen 'Authorized'
							when  isnull(A.AuthorisationStatus, 'A') in ('NP','MP','FM','1A') THen 'Pending Authorisation'
							--when  isnull(A.AuthorisationStatus, 'A')='MP' THen 'Modified Pending'
							--when  isnull(A.AuthorisationStatus, 'A')='FM' THen 'Further Modified'
							--when  isnull(A.AuthorisationStatus, 'A')='R' THen 'Reject'
							--when  isnull(A.AuthorisationStatus, 'A')='1A' THen 'First Authorized'
							ENd AS AuthorisationStatusName,   
                            A.EffectiveFromTimeKey,   
                            A.EffectiveToTimeKey,   
                            A.CreatedBy,   
                            A.DateCreated,   
                            A.ApprovedBy,   
                             convert(varchar(20),A.DateApproved,103) DateApproved,   
                            A.ModifiedBy,   
                            A.DateModified  
       ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy  
       ,IsNull(A.DateModified,A.DateCreated)as CrModDate  
       ,ISNULL('',A.CreatedBy) as CrAppBy --,ISNULL(A.ApprovedByFirstLevel,A.CreatedBy) as CrAppBy  
       ,ISNULL('',A.DateCreated) as CrAppDate  --,ISNULL(A.DateApprovedFirstLevel,A.DateCreated) as CrAppDate  
       ,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy  
       ,ISNULL(A.DateApproved,A.DateModified) as ModAppDate  
       ,A.LowerDPD  
       ,A.UpperDPD
	   ,Segment
	   ,ProvisionRule
	   ,RBIProvisionSecured
	   ,RBIProvisionUnSecured
	   ,ProvisionShortNameEnum as FacilityType
       --,A.Segment  
       --,A.ChangeFields  
	 --,Convert(Varchar(10),A.EffectiveFromDate,103) EffectiveFromDate
                     FROM DimNPAProvision_Mod A  
      left join dimassetclass B  
      on a.ProvisionName=b.AssetClassShortNameEnum  
      WHERE A.EffectiveFromTimeKey <= @TimeKey  
                           AND A.EffectiveToTimeKey >= @TimeKey  
                           --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')  
                           AND A.EntityKey IN  
                     (  
                         SELECT MAX(EntityKey)  
                         FROM DimNPAProvision_Mod  
                         WHERE EffectiveFromTimeKey <= @TimeKey  
                               AND EffectiveToTimeKey >= @TimeKey  
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')  
                         GROUP BY ProvisionAlt_Key  
                     )  
                 ) A   
                        
                   
                 GROUP BY A.ProvisionAlt_Key,  
       A.ProvisionName,  
       A.CODE,  
       A.ProvisionSecured,  
       A.ProvisionUnSecured,  
       A.AuthorisationStatus, 
	   A.AuthorisationStatusName,   
                            A.EffectiveFromTimeKey,   
                            A.EffectiveToTimeKey,   
                            A.CreatedBy,   
                            A.DateCreated,   
                            A.ApprovedBy,   
                            A.DateApproved,   
                            A.ModifiedBy,   
                            A.DateModified,  
       A.CrModBy,  
       A.CrModDate,  
       A.CrAppBy,  
       A.CrAppDate,  
       A.ModAppBy,  
       A.ModAppDate  
       ,A.LowerDPD  
       ,A.UpperDPD  
       ,A.Segment
	   ,ProvisionRule
	   ,RBIProvisionSecured
	   ,RBIProvisionUnSecured
	   ,FacilityType
     --  ,A.ChangeFields
	    --,A.EffectiveFromDate;
  
                 SELECT *  
                 FROM  
                 (  
                     SELECT ROW_NUMBER() OVER(ORDER BY ProvisionAlt_Key) AS RowNumber,   
                            COUNT(*) OVER() AS TotalCount,   
                            'NPAProvisionMaster' TableName,   
                            *  
                     FROM  
                     (  
                         SELECT *  
                         FROM #temp A  
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'  
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'  
                     ) AS DataPointOwner  
                 ) AS DataPointOwner  
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1  
                 --      AND RowNumber <= (@PageNo * @PageSize);  
             END;  
             
			 ELSE  
  
    /*  IT IS Used For GRID Search which are Pending for Authorization    */  
  
       IF(@OperationFlag in (16,17))  
  
  
             BEGIN  
    IF OBJECT_ID('TempDB..#temp16') IS NOT NULL  
                 DROP TABLE #temp16;  
                 SELECT  A.ProvisionAlt_Key,  
       A.ProvisionName,  
       A.CODE,  
       A.ProvisionSecured,  
       A.ProvisionUnSecured,  
       A.AuthorisationStatus,   
	   A.AuthorisationStatusName, 
                            A.EffectiveFromTimeKey,   
                    A.EffectiveToTimeKey,   
                            A.CreatedBy,   
                            A.DateCreated,   
                            A.ApprovedBy,   
                            A.DateApproved,   
                            A.ModifiedBy,   
                            A.DateModified,  
       A.CrModBy,  
       A.CrModDate,  
       A.CrAppBy,  
       A.CrAppDate,  
       A.ModAppBy,  
       A.ModAppDate  
       ,A.LowerDPD  
       ,A.UpperDPD  
       ,A.Segment 
	   ,ProvisionRule
	   ,RBIProvisionSecured
	   ,RBIProvisionUnSecured
	   ,FacilityType
     --  ,A.ChangeFields  
	    --,A.EffectiveFromDate
                 INTO #temp16  
                 FROM   
                 (  
                     SELECT A.ProvisionAlt_Key,  
       A.ProvisionName ProvisionName,  
       B.AssetClassAlt_Key CODE,  
       A.ProvisionSecured,  
       A.ProvisionUnSecured,  
       isnull(A.AuthorisationStatus, 'A') AuthorisationStatus, 
							Case when  isnull(A.AuthorisationStatus, 'A')='A' THen 'Authorized'
							when  isnull(A.AuthorisationStatus, 'A') in ('NP','MP','FM','1A') THen 'Pending Authorisation'
							--when  isnull(A.AuthorisationStatus, 'A')='MP' THen 'Modified Pending'
							--when  isnull(A.AuthorisationStatus, 'A')='FM' THen 'Further Modified'
							--when  isnull(A.AuthorisationStatus, 'A')='R' THen 'Reject'
							--when  isnull(A.AuthorisationStatus, 'A')='1A' THen 'First Authorized'
							ENd AS AuthorisationStatusName,   
                            A.EffectiveFromTimeKey,   
                            A.EffectiveToTimeKey,   
                            A.CreatedBy,   
                            A.DateCreated,   
                            A.ApprovedBy,   
                             convert(varchar(20),A.DateApproved,103) DateApproved,   
                            A.ModifiedBy,   
                            A.DateModified  
       ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy  
       ,IsNull(A.DateModified,A.DateCreated)as CrModDate  
       ,ISNULL('',A.CreatedBy) as CrAppBy --,ISNULL(A.ApprovedByFirstLevel,A.CreatedBy) as CrAppBy  
       ,ISNULL('',A.DateCreated) as CrAppDate--,ISNULL(A.DateApprovedFirstLevel,A.DateCreated) as CrAppDate  
       ,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy  
       ,ISNULL(A.DateApproved,A.DateModified) as ModAppDate  
       ,A.LowerDPD  
       ,A.UpperDPD  
       ,A.Segment
	   ,ProvisionRule
	   ,RBIProvisionSecured
	   ,RBIProvisionUnSecured
	   ,ProvisionShortNameEnum
	   ,a.ProvisionShortNameEnum as FacilityType
    --   ,A.ChangeFields  
	   --,Convert(Varchar(10),A.EffectiveFromDate,103) EffectiveFromDate
                     FROM DimNPAProvision_Mod A  
      left join dimassetclass B  
      on a.ProvisionName=b.AssetClassShortNameEnum  
      WHERE A.EffectiveFromTimeKey <= @TimeKey  
                           AND A.EffectiveToTimeKey >= @TimeKey  
                           --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')  
                           AND A.EntityKey IN  
                     (  
                         SELECT MAX(EntityKey)  
                         FROM DimNPAProvision_Mod  
                         WHERE EffectiveFromTimeKey <= @TimeKey  
                               AND EffectiveToTimeKey >= @TimeKey  
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')  
                         GROUP BY ProvisionAlt_Key  
                     )  
                 ) A   
                        
                   
                 GROUP BY A.ProvisionAlt_Key,  
       A.ProvisionName,  
       A.CODE,  
       A.ProvisionSecured,  
       A.ProvisionUnSecured,  
       A.AuthorisationStatus,   
	   A.AuthorisationStatusName, 
                            A.EffectiveFromTimeKey,   
                            A.EffectiveToTimeKey,   
                            A.CreatedBy,   
                            A.DateCreated,   
                            A.ApprovedBy,   
                            A.DateApproved,   
                            A.ModifiedBy,   
                            A.DateModified,  
       A.CrModBy,  
       A.CrModDate,  
       A.CrAppBy,  
       A.CrAppDate,  
       A.ModAppBy,  
       A.ModAppDate  
       ,A.LowerDPD  
       ,A.UpperDPD  
       ,A.Segment
	   ,ProvisionRule
	   ,RBIProvisionSecured
	   ,RBIProvisionUnSecured
	   ,ProvisionShortNameEnum
	   ,FacilityType
     --  ,A.ChangeFields
	    --,A.EffectiveFromDate
  
                 SELECT *  
                 FROM  
                 (  
                     SELECT ROW_NUMBER() OVER(ORDER BY ProvisionAlt_Key) AS RowNumber,   
                            COUNT(*) OVER() AS TotalCount,   
                            'NPAProvisionMaster' TableName,   
                            *  
                     FROM  
                     (  
                         SELECT *  
                         FROM #temp16 A  
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'  
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'  
                     ) AS DataPointOwner  
                 ) AS DataPointOwner  
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1  
                 --      AND RowNumber <= (@PageNo * @PageSize)  
  
   END;  
  
   Else  
  
   IF (@OperationFlag =20)  
             BEGIN  
    IF OBJECT_ID('TempDB..#temp20') IS NOT NULL  
                 DROP TABLE #temp20;  
                 SELECT A.ProvisionAlt_Key,  
       A.ProvisionName,  
       A.CODE,  
       A.ProvisionSecured,  
       A.ProvisionUnSecured,  
       A.AuthorisationStatus,   
                            A.EffectiveFromTimeKey,   
                            A.EffectiveToTimeKey,   
                            A.CreatedBy,   
                            A.DateCreated,   
                            A.ApprovedBy,   
                            A.DateApproved,   
                            A.ModifiedBy,   
                            A.DateModified,  
       A.CrModBy,  
       A.CrModDate,  
       A.CrAppBy,  
       A.CrAppDate,  
       A.ModAppBy,  
       A.ModAppDate  
       ,A.LowerDPD  
       ,A.UpperDPD  
       ,A.Segment 
	   ,ProvisionRule
	   ,RBIProvisionSecured
	   ,RBIProvisionUnSecured
	   --,FacilityType
     --  ,A.ChangeFields  
	    --,A.EffectiveFromDate
                 INTO #temp20  
                 FROM   
                 (  
                     SELECT A.ProvisionAlt_Key,  
       A.ProvisionName ProvisionName,  
       B.AssetClassAlt_Key CODE,  
       A.ProvisionSecured,  
       A.ProvisionUnSecured,  
       --isnull(A.AuthorisationStatus, 'A')   
       A.AuthorisationStatus,   
                            A.EffectiveFromTimeKey,   
                            A.EffectiveToTimeKey,   
                            A.CreatedBy,   
                    A.DateCreated,   
                            A.ApprovedBy,   
                             convert(varchar(20),A.DateApproved,103) DateApproved,   
                            A.ModifiedBy,   
                            A.DateModified  
       ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy  
       ,IsNull(A.DateModified,A.DateCreated)as CrModDate  
   --- ,ISNULL('',A.CreatedBy) as CrAppBy --Commented & Replaced by below line Tarkeshwar Singh on 27May2024
	   ,ISNULL(A.ApprovedByFirstLevel,A.CreatedBy) as CrAppBy  
   --- ,ISNULL('',A.DateCreated) as CrAppDate ----Commented & Replaced by below line Tarkeshwar Singh on 27May2024
	   ,ISNULL(A.DateApprovedFirstLevel,A.DateCreated) as CrAppDate  
       ,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy  
       ,ISNULL(A.DateApproved,A.DateModified) as ModAppDate  
       ,A.LowerDPD  
       ,A.UpperDPD  
       ,A.Segment
	   ,ProvisionRule
	   ,RBIProvisionSecured
	   ,RBIProvisionUnSecured
	   --,ProvisionShortNameEnum as FacilityType
    --   ,A.ChangeFields  
	   --,Convert(Varchar(10),A.EffectiveFromDate,103) EffectiveFromDate
                     FROM DimNPAProvision_Mod A  
      left join dimassetclass B  
      on a.ProvisionName=b.AssetClassShortNameEnum  
      WHERE A.EffectiveFromTimeKey <= @TimeKey  
                           AND A.EffectiveToTimeKey >= @TimeKey  
                           AND ISNULL(A.AuthorisationStatus, 'A') IN('1A')  
                           AND A.EntityKey IN  
                     (  
                         SELECT MAX(EntityKey)  
                         FROM DimNPAProvision_Mod  
                         WHERE EffectiveFromTimeKey <= @TimeKey  
                               AND EffectiveToTimeKey >= @TimeKey  
                               AND AuthorisationStatus IN('1A')  
                         GROUP BY ProvisionAlt_Key  
                     )  
                 ) A   
                        
                   
                 GROUP BY A.ProvisionAlt_Key,  
       A.ProvisionName,  
       A.CODE,  
       A.ProvisionSecured,  
       A.ProvisionUnSecured,  
       A.AuthorisationStatus,   
                            A.EffectiveFromTimeKey,   
                            A.EffectiveToTimeKey,   
                            A.CreatedBy,   
                            A.DateCreated,   
                            A.ApprovedBy,   
                            A.DateApproved,   
                            A.ModifiedBy,   
                            A.DateModified,  
       A.CrModBy,  
       A.CrModDate,  
       A.CrAppBy,  
       A.CrAppDate,  
       A.ModAppBy,  
       A.ModAppDate  
       ,A.LowerDPD  
       ,A.UpperDPD  
       ,A.Segment
	   ,ProvisionRule
	   ,RBIProvisionSecured
	   ,RBIProvisionUnSecured
	   --,ProvisionShortNameEnum
     --  ,A.ChangeFields  
	    --,A.EffectiveFromDate
                 SELECT *  
                 FROM  
                 (  
                     SELECT ROW_NUMBER() OVER(ORDER BY ProvisionAlt_Key) AS RowNumber,   
 COUNT(*) OVER() AS TotalCount,   
                            'NPAProvisionMaster' TableName,   
                            *  
                     FROM  
                     (  
                         SELECT *  
                         FROM #temp20 A  
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'  
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'  
                     ) AS DataPointOwner  
                 ) AS DataPointOwner  
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1  
                 --      AND RowNumber <= (@PageNo * @PageSize)  
  
   END;  
  
  
   END TRY  
 BEGIN CATCH  
   
 INSERT INTO dbo.Error_Log  
    SELECT ERROR_LINE() as ErrorLine,ERROR_MESSAGE()ErrorMessage,ERROR_NUMBER()ErrorNumber  
    ,ERROR_PROCEDURE()ErrorProcedure,ERROR_SEVERITY()ErrorSeverity,ERROR_STATE()ErrorState  
    ,GETDATE()  
  
 SELECT ERROR_MESSAGE()  
 --RETURN -1  
     
 END CATCH  
  
  --SELECT *, 'RBIProvisionRateMaster' AS TableName FROM MetaScreenFieldDetail WHERE ScreenName='NPAProvisionRateMaster'          
    
    
    END;  
  
  
  
  
GO