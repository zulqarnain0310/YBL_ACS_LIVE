SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------CollateralValueSearchList-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------






-----------------------

--CollateralValueSearchList 1,'1000278'

Create PROC [dbo].[CollateralValueSearchList]  
--Declare  
               
             --@PageNo         INT         = 1,   
             --@PageSize       INT         = 10,   
             @OperationFlag  INT         = 1,  
             @CollateralID Varchar(30) = ''  
AS  
       
  BEGIN  
  
SET NOCOUNT ON;  
Declare @TimeKey as Int  
 SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')  
       
  
BEGIN TRY  
  
/*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */  
  
   IF(@OperationFlag not in ( 16,17,20))  
             BEGIN  
    IF OBJECT_ID('TempDB..#temp') IS NOT NULL DROP TABLE  #temp;  
	 IF OBJECT_ID('TempDB..#temp1') IS NOT NULL DROP TABLE  temp1;  
        PRINT 'SachinSac'  
                   
                 SELECT  A.CollateralID  
         
       ,ValuationDate  
       ,A.LatestCollateralValueinRs  
       ,A.ExpiryBusinessRule  
       ,A.Periodinmonth  
       ,A.ValueExpirationDate  
       ,A.AuthorisationStatus, 
	      A.SecurityEntityID,
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
         
                 INTO #temp  
                 FROM   
                 (  
                     SELECT  B.CollateralID  
         
         
       ,Convert(Varchar(10),B.ValuationDate,103) ValuationDate  
       ,Substring(Convert(Varchar(22),B.CurrentValue),1,14) as LatestCollateralValueinRs  
       ,B.ExpiryBusinessRule  
       ,B.Periodinmonth  
       ,Convert(Varchar(10),B.ValuationExpiryDate,103) as ValueExpirationDate  
       ,isnull(B.AuthorisationStatus, 'A') AuthorisationStatus, 
	   B.SecurityEntityID,
                            B.EffectiveFromTimeKey,   
                            B.EffectiveToTimeKey,   
                            B.CreatedBy,   
                            B.DateCreated,   
                            B.ApprovedBy,   
                            B.DateApproved,   
                            B.ModifiedBy,   
                            B.DateModified  
       ,IsNull(B.ModifiedBy,B.CreatedBy)as CrModBy  
       ,IsNull(B.DateModified,B.DateCreated)as CrModDate  
       ,ISNULL(B.ApprovedBy,B.CreatedBy) as CrAppBy  
       ,ISNULL(B.DateApproved,B.DateCreated) as CrAppDate  
       ,ISNULL(B.ApprovedBy,B.ModifiedBy) as ModAppBy  
       ,ISNULL(B.DateApproved,B.DateModified) as ModAppDate  
         
         
                     
      FROM Curdat.AdvSecurityValueDetail B   
      
  
      --inner join DIMSOURCEDB B  
      --ON B.ValuationSourceNameAlt_Key=B.SourceAlt_Key  
      --AND B.EffectiveFromTimeKey <= @TimeKey  
      --                     AND B.EffectiveToTimeKey >= @TimeKey  
      WHERE   
      B.EffectiveFromTimeKey <= @TimeKey  
                           AND B.EffectiveToTimeKey >= @TimeKey AND  
           ISNULL(B.AuthorisationStatus, 'A') = 'A'  
       AND  B.CollateralID=@CollateralID  
                    UNION ALL  
                          SELECT  B.CollateralID  
         
       ,Convert(Varchar(10),B.ValuationDate,103) ValuationDate  
       ,Substring(Convert(Varchar(22),B.CurrentValue),1,14) as LatestCollateralValueinRs  
       ,B.ExpiryBusinessRule  
       ,B.Periodinmonth  
       ,Convert(Varchar(10),B.ValuationExpiryDate,103) as ValueExpirationDate  
       ,isnull(B.AuthorisationStatus, 'A') AuthorisationStatus,   
	      B.SecurityEntityID,
                            B.EffectiveFromTimeKey,   
                            B.EffectiveToTimeKey,   
                            B.CreatedBy,   
               B.DateCreated,   
B.ApprovedBy,   
                 B.DateApproved,   
                            B.ModifiedBy,   
                            B.DateModified  
       ,IsNull(B.ModifiedBy,B.CreatedBy)as CrModBy  
       ,IsNull(B.DateModified,B.DateCreated)as CrModDate  
       ,ISNULL(B.ApprovedBy,B.CreatedBy) as CrAppBy  
       ,ISNULL(B.DateApproved,B.DateCreated) as CrAppDate  
       ,ISNULL(B.ApprovedBy,B.ModifiedBy) as ModAppBy  
       ,ISNULL(B.DateApproved,B.DateModified) as ModAppDate  
         
                    FROM dbo.AdvSecurityValueDetail_Mod B   
     
      ----inner join DIMSOURCEDB B  
      ----ON B.ValuationSourceNameAlt_Key=B.SourceAlt_Key  
      ----AND B.EffectiveFromTimeKey <= 26002  
      ----                     AND B.EffectiveToTimeKey >= 26002  
      WHERE B.EffectiveFromTimeKey <= @TimeKey  
               AND B.EffectiveToTimeKey >= @TimeKey  
      AND  B.CollateralID=@CollateralID  
	  AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')  
                           --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')  
                     --      AND B.ENTITYKEY  
                     --  IN  
                     --(  
                     --    SELECT MAX(ENTITYKEY)  
                     --    FROM dbo.AdvSecurityValueDetail_Mod 
                     --    WHERE EffectiveFromTimeKey <= @TimeKey  
                     --          AND EffectiveToTimeKey >= @TimeKey  
                     --          AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')  
                     --    GROUP BY CollateralID  
                     --)  
                 ) A   
                        
            
        
  --Select '#temp',* from #temp
  
       --Select '#temp',* from #temp Where CollateralID='1000034'  
                 SELECT * into #temp1
                 FROM  
                 (  
                     SELECT ROW_NUMBER() OVER(ORDER BY ValuationDate Desc) AS RowNumber,   
                            COUNT(*) OVER() AS TotalCount,   
                            'CollateralValue' TableName,   
                            *  
                     FROM  
                     (  
        SELECT *  
                         FROM #temp A Where A.CollateralID=@CollateralID  
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'  
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'  
                     ) AS DataPointOwner  
                 ) AS DataPointOwner  
				 

				 Select * from #temp1

				 --Select A.CollateralID   ,ValuationDate ,A.LatestCollateralValueinRs,B.Documents,A.Periodinmonth 
     -- ,A.ValueExpirationDate ,A.AuthorisationStatus,  A.EffectiveFromTimeKey, A.EffectiveToTimeKey, 
     --  A.CreatedBy,A.DateCreated,A.ApprovedBy,  A.DateApproved, A.ModifiedBy,A.DateModified,  A.CrModBy, 
     -- A.CrModDate, A.CrAppBy,  A.CrAppDate,  A.ModAppBy,  A.ModAppDate   from #temp1 A
				 --INNER JOIN DimValueExpiration B ON A.ExpiryBusinessRule=b.ValueExpirationAltKey
   
  
     ---------------------------------------------------For Max Default Values check--------------  
  
  select CollateralID,CurrentValue As CollateralValueatthetimeoflastreviewinRs  
  ,'CollateralDefaultValue' TableName  
   from CurDat.AdvSecurityValueDetail  Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey And CollateralID=@CollateralID  
  And ValuationDate=(select Max(ValuationDate)ValuationDate from CurDat.AdvSecurityValueDetail where EffectiveFromTimeKey<=@TimeKey   
  and EffectiveToTimeKey>=@TimeKey And CollateralID=@CollateralID)  
  
  
             END;  
             ELSE  
  
    /*  IT IS Used For GRID Search which are Pending for Authorization    */  
    IF (@OperationFlag in (16))  
  
             BEGIN  
    IF OBJECT_ID('TempDB..#temp16') IS NOT NULL  
       DROP TABLE #temp16; 
	   
	   PRINT 'Sachin16'
                 SELECT A.CollateralID  
         
       ,A.ValuationDate  
       ,A.LatestCollateralValueinRs  
       ,A.ExpiryBusinessRule  
       ,A.Periodinmonth  
       ,A.ValueExpirationDate  
       ,A.AuthorisationStatus,   
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
                 INTO #temp16  
                 FROM   
                 (  
                   SELECT  B.CollateralID  
         
       ,Convert(Varchar(10),B.ValuationDate,103) ValuationDate  
       ,Substring(Convert(Varchar(22),B.CurrentValue),1,14) as LatestCollateralValueinRs  
       ,B.ExpiryBusinessRule  
       ,B.Periodinmonth  
       ,Convert(Varchar(10),B.ValuationExpiryDate,103) as ValueExpirationDate  
       ,isnull(B.AuthorisationStatus, 'A') AuthorisationStatus,   
                            B.EffectiveFromTimeKey,   
                            B.EffectiveToTimeKey,   
                            B.CreatedBy,   
                            B.DateCreated,   
                            B.ApprovedBy,   
                            B.DateApproved,   
                            B.ModifiedBy,   
                            B.DateModified  
       ,IsNull(B.ModifiedBy,B.CreatedBy)as CrModBy  
       ,IsNull(B.DateModified,B.DateCreated)as CrModDate  
       ,ISNULL(B.ApprovedBy,B.CreatedBy) as CrAppBy  
       ,ISNULL(B.DateApproved,B.DateCreated) as CrAppDate  
       ,ISNULL(B.ApprovedBy,B.ModifiedBy) as ModAppBy  
       ,ISNULL(B.DateApproved,B.DateModified) as ModAppDate  
         
                    FROM DBO.AdvSecurityValueDetail_MOD B-- ON A.CollateralID=B.CollateralID  
       
      WHERE B.EffectiveFromTimeKey <= @TimeKey  
               AND B.EffectiveToTimeKey >= @TimeKey  
       AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')                  
      --AND B.ENTITYKEY  
      --                 IN  
      --               (  
      --                   SELECT MAX(ENTITYKEY)  
      --                   FROM DBO.AdvSecurityValueDetail_MOD 
      --                   WHERE EffectiveFromTimeKey <= @TimeKey  
      --                         AND EffectiveToTimeKey >= @TimeKey  
      --                         AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')  
      --       GROUP BY CollateralID  
      --               )  
                 ) A   
                        
                  --Select '#temp16',* from #temp16 
       --          GROUP BY A.CollateralID  
       --,A.CollateralValueatSanctioninRs  
       --,A.CollateralValueasonNPAdateinRs  
       --,A.CollateralValueatthetimeoflastreviewinRs  
       --,A.ValuationSourceNameAlt_Key  
       --,A.SourceName  
       --,A.ValuationDate  
       --,A.LatestCollateralValueinRs  
       --,A.ExpiryBusinessRule  
       --,A.Periodinmonth  
       --,A.ValueExpirationDate  
       --,A.AuthorisationStatus,   
       --                     A.EffectiveFromTimeKey,   
       --          A.EffectiveToTimeKey,   
       --                     A.CreatedBy,   
       --                     A.DateCreated,   
       --                     A.ApprovedBy,   
       --                     A.DateApproved,   
       --                     A.ModifiedBy,   
       --                     A.DateModified  
  
  
    --Select * from #temp16  
                 SELECT *  
                 FROM  
                 (  
                     SELECT ROW_NUMBER() OVER(ORDER BY ValuationDate Desc) AS RowNumber,   
           COUNT(*) OVER() AS TotalCount,   
               'CollateralValue' TableName,   
                           *  
           FROM  
                     (  
             SELECT *  
                         FROM #temp16 A where A.CollateralID=@CollateralID  
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'  
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'  
                     ) AS DataPointOwner  
                 ) AS DataPointOwner  
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1  
         --      AND RowNumber <= (@PageNo * @PageSize)  
  
   END;  
    ELSE  
  
    /*  IT IS Used For GRID Search which are Pending for Authorization    */  
    IF (@OperationFlag in (161))  
  
             BEGIN  
    IF OBJECT_ID('TempDB..#temp160') IS NOT NULL  
                 DROP TABLE #temp160;  
     Print 'Sachin'  
                 SELECT A.CollateralID  
         
       ,A.ValuationDate  
       ,A.LatestCollateralValueinRs  
       ,A.ExpiryBusinessRule  
       ,A.Periodinmonth  
       ,A.ValueExpirationDate  
       ,A.AuthorisationStatus,   
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
                 INTO #temp160  
                 FROM   
                 (  
                     SELECT  A.CollateralID  
        
       ,Convert(Varchar(10),B.ValuationDate,103) ValuationDate  
       ,Substring(Convert(Varchar(22),B.CurrentValue),1,14) as LatestCollateralValueinRs  
       ,B.ExpiryBusinessRule  
       ,B.Periodinmonth  
       ,Convert(Varchar(10),B.ValuationExpiryDate,103) as ValueExpirationDate  
       ,isnull(A.AuthorisationStatus, 'A') AuthorisationStatus,   
                            A.EffectiveFromTimeKey,   
                            A.EffectiveToTimeKey,   
                            A.CreatedBy,   
                            A.DateCreated,   
                            A.ApprovedBy,   
                      A.DateApproved,   
                            A.ModifiedBy,   
                            A.DateModified  
       ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy  
       ,IsNull(A.DateModified,A.DateCreated)as CrModDate  
       ,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy  
       ,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate  
       ,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy  
       ,ISNULL(A.DateApproved,A.DateModified) as ModAppDate  
         
         
       FROM Dbo.AdvSecurityDetail_Mod A --1  
      INNER JOIN Curdat.AdvSecurityValueDetail B ON A.CollateralID=B.CollateralID  
  
      --inner join DIMSOURCEDB B  
      --ON A.ValuationSourceNameAlt_Key=B.SourceAlt_Key  
      --AND B.EffectiveFromTimeKey <= @TimeKey  
      --                     AND B.EffectiveToTimeKey >= @TimeKey  
      WHERE A.EffectiveFromTimeKey <= @TimeKey  
                           AND A.EffectiveToTimeKey >= @TimeKey  
                           AND ISNULL(A.AuthorisationStatus, 'A') = 'A'  
                     
   ) A 
          
                 --Select * from #temp160  
       --          GROUP BY A.CollateralID  
       --,A.CollateralValueatSanctioninRs  
       --,A.CollateralValueasonNPAdateinRs  
       --,A.CollateralValueatthetimeoflastreviewinRs  
       --,A.ValuationSourceNameAlt_Key  
       --,A.SourceName  
       --,A.ValuationDate  
       --,A.LatestCollateralValueinRs  
       --,A.ExpiryBusinessRule  
       --,A.Periodinmonth  
       --,A.ValueExpirationDate  
       --,A.AuthorisationStatus,   
       --                     A.EffectiveFromTimeKey,   
       --                     A.EffectiveToTimeKey,   
       --                     A.CreatedBy,   
       --            A.DateCreated,   
       --               A.ApprovedBy,   
 --                     A.DateApproved,   
   --                     A.ModifiedBy,   
       --                     A.DateModified  
  
  
    --Select * from #temp16  
                 SELECT *  
                 FROM  
                 (  
                     SELECT ROW_NUMBER() OVER(ORDER BY ValuationDate Desc) AS RowNumber,   
                            COUNT(*) OVER() AS TotalCount,   
                            'CollateralValue' TableName,   
                            *  
                     FROM  
                     (  
             SELECT *  
                         FROM #temp160 A where A.CollateralID=@CollateralID  
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'  
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'  
                     ) AS DataPointOwner  
                 ) AS DataPointOwner  
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1  
         --      AND RowNumber <= (@PageNo * @PageSize)  
  
   END;  
  
     ELSE  
  
    /*  IT IS Used For GRID Search which are Pending for Authorization    */  
    IF (@OperationFlag=20)  
  
             BEGIN  
    IF OBJECT_ID('TempDB..#temp20') IS NOT NULL  
                 DROP TABLE #temp20;  
                 SELECT A.CollateralID  
         
         
       ,A.ValuationDate  
       ,A.LatestCollateralValueinRs  
       ,A.ExpiryBusinessRule  
       ,A.Periodinmonth  
       ,A.ValueExpirationDate  
       ,A.AuthorisationStatus,   
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
                 INTO #temp20  
    FROM   
(  
                     SELECT  A.CollateralID  
         
       ,Convert(Varchar(10),B.ValuationDate,103) ValuationDate  
       ,Substring(Convert(Varchar(22),B.CurrentValue),1,14) as LatestCollateralValueinRs  
       ,B.ExpiryBusinessRule  
       ,B.Periodinmonth  
       ,Convert(Varchar(10),B.ValuationExpiryDate,103)as ValueExpirationDate  
       ,isnull(A.AuthorisationStatus, 'A') AuthorisationStatus,   
                            A.EffectiveFromTimeKey,   
                            A.EffectiveToTimeKey,   
                            A.CreatedBy,   
                            A.DateCreated,   
  A.ApprovedBy,   
                            A.DateApproved,   
                            A.ModifiedBy,   
A.DateModified  
       ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy  
       ,IsNull(A.DateModified,A.DateCreated)as CrModDate  
       ,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy  
       ,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate  
       ,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy  
       ,ISNULL(A.DateApproved,A.DateModified) as ModAppDate  
         
                    FROM dbo.AdvSecurityDetail_Mod A --1 
      INNER JOIN Curdat.AdvSecurityValueDetail B ON A.CollateralID=B.CollateralID  
      --inner join DIMSOURCEDB B  
      --ON A.ValuationSourceNameAlt_Key=B.SourceAlt_Key 
      --AND B.EffectiveFromTimeKey <= @TimeKey  
      --                     AND B.EffectiveToTimeKey >= @TimeKey  
      WHERE A.EffectiveFromTimeKey <= @TimeKey  
               AND A.EffectiveToTimeKey >= @TimeKey  
                           --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')  
                           AND A.ENTITYKEY  
                       IN  
                     (  
                         SELECT MAX(ENTITYKEY)  
                         FROM dbo.AdvSecurityDetail_Mod  
                         WHERE EffectiveFromTimeKey <= @TimeKey  
                               AND EffectiveToTimeKey >= @TimeKey  
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')  
           GROUP BY CollateralID  
                     )  
                 ) A   
                        
                   
       --          GROUP BY A.CollateralID  
       --,A.CollateralValueatSanctioninRs  
       --,A.CollateralValueasonNPAdateinRs  
       --,A.CollateralValueatthetimeoflastreviewinRs  
       --,A.ValuationSourceNameAlt_Key  
       --,A.SourceName  
       --,A.ValuationDate  
       --,A.LatestCollateralValueinRs  
       --,A.ExpiryBusinessRule  
       --,A.Periodinmonth  
       --,A.ValueExpirationDate  
       --,A.AuthorisationStatus,   
       --                     A.EffectiveFromTimeKey,   
       --                     A.EffectiveToTimeKey,   
       --                     A.CreatedBy,   
       --                     A.DateCreated,   
       --                     A.ApprovedBy,   
       --                     A.DateApproved,   
       --                     A.ModifiedBy,   
       --                     A.DateModified  
                 SELECT *  
                 FROM  
                 (  
                     SELECT ROW_NUMBER() OVER(ORDER BY ValuationDate Desc) AS RowNumber,   
                            COUNT(*) OVER() AS TotalCount,   
                            'CollateralValue' TableName,   
                            *  
                     FROM  
                     (  
             SELECT *  
                         FROM #temp20 A where A.CollateralID=@CollateralID  
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
  
  
    
    
    END;  
GO