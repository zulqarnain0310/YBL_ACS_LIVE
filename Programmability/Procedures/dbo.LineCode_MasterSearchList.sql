SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
--USE YES_MISDB  
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------  
CREATE PROC [dbo].[LineCode_MasterSearchList]  
--Declare  
               
             --@PageNo         INT         = 1,   
             --@PageSize       INT         = 10,   
               @OperationFlag  INT         = 1  
              ,@MenuID  INT  =2  
  
AS  
----select AuthLevel,* from SysCRisMacMenu where Menuid=14551 Caption like '%Product%'  
--update SysCRisMacMenu set AuthLevel=2 where Menuid=14551  
       
 BEGIN   
  
SET NOCOUNT ON;  
Declare @TimeKey AS INT  
 SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')  
  
--Declare @Authlevel InT  
   
--select @Authlevel=AuthLevel from SysCRisMacMenu    
-- where MenuId=@MenuID   
   
       
  
BEGIN TRY  
/*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */  
  
   IF(@OperationFlag not in (16,17,20))  
             BEGIN  
     PRINT 'Anuj'  
    IF OBJECT_ID('TempDB..#temp') IS NOT NULL  
                 DROP TABLE  #temp;  
                 SELECT  A.ReviewLinecodeAlt_Key,  
       A.ReviewLineCodeName,  
       A.ReviewLineCode,  
       A.ReviewLineCodeGroup,  
       A.CodeType,  
  
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
                 INTO #temp  
                 FROM   
                  
     --declare @Timekey int=25999  
     (  
                     SELECT   
       A.ReviewLinecodeAlt_Key AS ReviewLinecodeAlt_Key,  
       A.ReviewLineCodeName AS ReviewLineCodeName,  
       A.ReviewLineCode AS ReviewLineCode,  
       A.ReviewLineCodeGroup AS ReviewLineCodeGroup,  
       A.CodeType AS CodeType ,  
  
       isnull(A.AuthorisationStatus, 'A') AuthorisationStatus,   
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
       --select *  
                     --FROM DimSeniorityChargeMaster A  
      FROM DimLineCodeReview A  
  
      WHERE A.EffectiveFromTimeKey <= @TimeKey  
                           AND A.EffectiveToTimeKey >= @TimeKey  
                           AND ISNULL(A.AuthorisationStatus, 'A') = 'A'  
  
  
                     UNION  
                     SELECT  A.ReviewLinecodeAlt_Key AS ReviewLinecodeAlt_Key,  
       A.ReviewLineCodeName AS ReviewLineCodeName,  
       A.ReviewLineCode AS ReviewLineCode,  
       A.ReviewLineCodeGroup AS ReviewLineCodeGroup,  
       A.CodeType AS CodeType ,  
  
  
       isnull(A.AuthorisationStatus, 'A') AuthorisationStatus,   
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
                     FROM DimLineCodeReview_Mod A  
      WHERE A.EffectiveFromTimeKey <= @TimeKey  AND A.EffectiveToTimeKey >= @TimeKey  
      AND ISNULL(A.AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')  
                           AND A.ReviewLineCode_Key IN  
                     (  
                         SELECT MAX(ReviewLineCode_Key)  
                         FROM DimLineCodeReview_Mod  
                         WHERE EffectiveFromTimeKey <= @TimeKey  
                               AND EffectiveToTimeKey >= @TimeKey  
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')  
                         GROUP BY ReviewLineCode_Key  
                     )  
                 --) A   
           -------------------------2  
     UNION ALL  
     ---Declare @Timekey int =25999  
     SELECT            
  
       A.StockLineCodeAlt_Key AS ReviewLinecodeAlt_Key,  
       A.StockLineCodeName AS ReviewLineCodeName,  
       A.StockLineCode AS ReviewLineCode,  
       A.StockLineCodeGroup AS ReviewLineCodeGroup,  
       A.CodeType AS CodeType ,  
  
       isnull(A.AuthorisationStatus, 'A') AuthorisationStatus,   
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
       --select *  
  
      FROM DimLinecodeStockStatement A  
  
      WHERE A.EffectiveFromTimeKey <= @TimeKey  
                           AND A.EffectiveToTimeKey >= @TimeKey  
                           AND ISNULL(A.AuthorisationStatus, 'A') = 'A'  
  
  
                     UNION  
                     SELECT    
  
             A.StockLineCodeAlt_Key AS ReviewLinecodeAlt_Key,  
       A.StockLineCodeName AS ReviewLineCodeName,  
       A.StockLineCode AS ReviewLineCode,  
       A.StockLineCodeGroup AS ReviewLineCodeGroup,  
       A.CodeType AS CodeType ,  
  
       isnull(A.AuthorisationStatus, 'A') AuthorisationStatus,   
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
                     FROM DimLinecodeStockStatement_Mod A  
     WHERE A.EffectiveFromTimeKey <= @TimeKey  AND A.EffectiveToTimeKey >= @TimeKey  
       AND ISNULL(A.AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')  
                           AND A.StockLineCode_Key IN  
                     (  
                         SELECT MAX(StockLineCode_Key)  
                         FROM DimLinecodeStockStatement_Mod  
                         WHERE EffectiveFromTimeKey <= @TimeKey  
                               AND EffectiveToTimeKey >= @TimeKey  
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')  
                         GROUP BY StockLineCode_Key  
                     )  
                               
                ------------------------------------3  
    UNION ALL  
    SELECT    
  
       A.ReviewLineProductCodeAlt_Key AS ReviewLinecodeAlt_Key,  
       A.ReviewLineProductCodeName AS ReviewLineCodeName,  
       A.ReviewLineProductCode AS ReviewLineCode,  
       A.ReviewLineProductCodeGroup AS ReviewLineCodeGroup,  
       A.CodeType AS CodeType ,  
  
        
       isnull(A.AuthorisationStatus, 'A') AuthorisationStatus,   
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
       --select *  
                     FROM DimLineProductCodeReview A  
  
      WHERE A.EffectiveFromTimeKey <= @TimeKey  
                           AND A.EffectiveToTimeKey >= @TimeKey  
                           AND ISNULL(A.AuthorisationStatus, 'A') = 'A'  
  
  
                     UNION  
                     SELECT   
  
       A.ReviewLineProductCodeAlt_Key AS ReviewLinecodeAlt_Key,  
       A.ReviewLineProductCodeName AS ReviewLineCodeName,  
       A.ReviewLineProductCode AS ReviewLineCode,  
       A.ReviewLineProductCodeGroup AS ReviewLineCodeGroup,  
       A.CodeType AS CodeType ,  
         
       isnull(A.AuthorisationStatus, 'A') AuthorisationStatus,   
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
                     FROM DimLineProductCodeReview_Mod A  
      WHERE A.EffectiveFromTimeKey <= @TimeKey  AND A.EffectiveToTimeKey >= @TimeKey  
      AND ISNULL(A.AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')  
                           AND A.ReviewLineProductCode_Key IN  
                     (  
                         SELECT MAX(ReviewLineProductCode_Key)  
                         FROM DimLineProductCodeReview_Mod  
                         WHERE EffectiveFromTimeKey <= @TimeKey  
                               AND EffectiveToTimeKey >= @TimeKey  
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')  
                         GROUP BY ReviewLineProductCode_Key  
                     )  
                 )A  
       
                 GROUP BY A.ReviewLinecodeAlt_Key,  
       A.ReviewLineCodeName,  
       A.ReviewLineCode,  
       A.ReviewLineCodeGroup,  
       A.CodeType,  
  
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
  
                 SELECT *  
                 FROM  
                 (  
                     SELECT ROW_NUMBER() OVER(ORDER BY ReviewLineCodeAlt_Key) AS RowNumber,   
                            COUNT(*) OVER() AS TotalCount,   
                            'DimLineCodeReview' TableName,   
                            *  
                     FROM  
                     (  
                         SELECT *  
                         FROM #temp A  
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'  
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'  
                     ) AS DataPointOwner  
                 ) AS DataPointOwner  
     Order By DataPointOwner.DateCreated Desc  
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1  
                 --      AND RowNumber <= (@PageNo * @PageSize);  
             END;  
             ELSE  
  
    /*  IT IS Used For GRID Search which are Pending for Authorization    */  
    IF(@OperationFlag  in (16,17))  
  
             BEGIN  
    IF OBJECT_ID('TempDB..#temp16') IS NOT NULL  
                 DROP TABLE #temp16;  
                 SELECT   
               A.ReviewLinecodeAlt_Key,  
       A.ReviewLineCodeName,  
       A.ReviewLineCode,  
       A.ReviewLineCodeGroup,  
       A.CodeType,  
  
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
                 INTO #temp16  
                 FROM   
                 (  
                    SELECT   
         
       A.ReviewLinecodeAlt_Key AS ReviewLinecodeAlt_Key,  
       A.ReviewLineCodeName AS ReviewLineCodeName,  
       A.ReviewLineCode AS ReviewLineCode,  
       A.ReviewLineCodeGroup AS ReviewLineCodeGroup,  
       A.CodeType AS CodeType ,  
  
       isnull(A.AuthorisationStatus, 'A') AuthorisationStatus,   
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
       
       --select *  
                     --FROM DimSeniorityChargeMaster A  
      FROM DimLineCodeReview_MOD A  
      
      WHERE A.EffectiveFromTimeKey <= @TimeKey  
                           AND A.EffectiveToTimeKey >= @TimeKey  
                      AND ISNULL(A.AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')  
                           AND A.ReviewLineCode_Key IN  
                     (  
                         SELECT MAX(ReviewLineCode_Key)  
                       FROM DimLineCodeReview_Mod  
                         WHERE EffectiveFromTimeKey <= @TimeKey  
                               AND EffectiveToTimeKey >= @TimeKey  
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')  
                         GROUP BY ReviewLineCode_Key  
                     )  
                  ----------2  
      UNION ALL  
     --       SELECT   
                   
  
     --  A.StockLineCodeAlt_Key AS ReviewLinecodeAlt_Key,  
     --  A.StockLineCodeName AS ReviewLineCodeName,  
     --  A.StockLineCode AS ReviewLineCode,  
     --  A.StockLineCodeGroup AS ReviewLineCodeGroup,  
     --  A.CodeType AS CodeType ,  
  
     --  isnull(A.AuthorisationStatus, 'A') AuthorisationStatus,   
     --                       A.EffectiveFromTimeKey,   
     --                       A.EffectiveToTimeKey,   
     --                       A.CreatedBy,   
     --                       A.DateCreated,   
     --                       A.ApprovedBy,   
     --                       A.DateApproved,   
     --                       A.ModifiedBy,   
     --                       A.DateModified  
     --  ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy  
     --  ,IsNull(A.DateModified,A.DateCreated)as CrModDate  
     --  ,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy  
     --  ,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate  
     --  ,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy  
     --  ,ISNULL(A.DateApproved,A.DateModified) as ModAppDate  
     
     ----select *  
                       
     -- FROM DimLinecodeStockStatement A  
     -- WHERE A.EffectiveFromTimeKey <= @TimeKey  
     --                      AND A.EffectiveToTimeKey >= @TimeKey  
     --                      AND ISNULL(A.AuthorisationStatus, 'A') = 'A'  
  
  
     --                UNION  
                     SELECT            
  
       A.StockLineCodeAlt_Key AS ReviewLinecodeAlt_Key,  
       A.StockLineCodeName AS ReviewLineCodeName,  
       A.StockLineCode AS ReviewLineCode,  
       A.StockLineCodeGroup AS ReviewLineCodeGroup,  
       A.CodeType AS CodeType ,  
  
       isnull(A.AuthorisationStatus, 'A') AuthorisationStatus,   
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
     
                     FROM DimLinecodeStockStatement_Mod A  
     WHERE A.EffectiveFromTimeKey <= @TimeKey  AND A.EffectiveToTimeKey >= @TimeKey  
       AND ISNULL(A.AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')  
                           AND A.StockLineCode_Key IN  
                     (  
                         SELECT MAX(StockLineCode_Key)  
                         FROM DimLinecodeStockStatement_Mod  
                         WHERE EffectiveFromTimeKey <= @TimeKey  
                               AND EffectiveToTimeKey >= @TimeKey  
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')  
                         GROUP BY StockLineCode_Key  
                     )  
                               
                ------------------------------------3  
    UNION ALL  
    --SELECT    
  
    --   A.ReviewLineProductCodeAlt_Key AS ReviewLinecodeAlt_Key,  
    --   A.ReviewLineProductCodeName AS ReviewLineCodeName,  
    --   A.ReviewLineProductCode AS ReviewLineCode,  
    --   A.ReviewLineProductCodeGroup AS ReviewLineCodeGroup,  
    --   A.CodeType AS CodeType ,  
  
        
    --   isnull(A.AuthorisationStatus, 'A') AuthorisationStatus,   
    --                        A.EffectiveFromTimeKey,   
    --                        A.EffectiveToTimeKey,   
    --                        A.CreatedBy,   
    --                        A.DateCreated,   
    --                        A.ApprovedBy,   
    --                        A.DateApproved,   
    --                        A.ModifiedBy,   
    --                        A.DateModified  
    --   ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy  
    --   ,IsNull(A.DateModified,A.DateCreated)as CrModDate  
    --   ,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy  
    --   ,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate  
    --   ,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy  
    --   ,ISNULL(A.DateApproved,A.DateModified) as ModAppDate  
    --      --select *  
    --                 FROM DimLineProductCodeReview A  
    ----select top 2 * from DimLineCodeReview  
    ----select top 2 * from DimLinecodeStockStatement  
    ----select top 2 * from DimLineProductCodeReview   
    --  WHERE A.EffectiveFromTimeKey <= @TimeKey  
    --                       AND A.EffectiveToTimeKey >= @TimeKey  
    --                       AND ISNULL(A.AuthorisationStatus, 'A') = 'A'  
  
  
    --                 UNION  
                   SELECT    
  
       A.ReviewLineProductCodeAlt_Key AS ReviewLinecodeAlt_Key,  
       A.ReviewLineProductCodeName AS ReviewLineCodeName,  
       A.ReviewLineProductCode AS ReviewLineCode,  
       A.ReviewLineProductCodeGroup AS ReviewLineCodeGroup,  
       A.CodeType AS CodeType ,  
  
        
       isnull(A.AuthorisationStatus, 'A') AuthorisationStatus,   
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
         FROM DimLineProductCodeReview_Mod A  
      WHERE A.EffectiveFromTimeKey <= @TimeKey  AND A.EffectiveToTimeKey >= @TimeKey  
      AND ISNULL(A.AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')  
                           AND A.ReviewLineProductCode_Key IN  
                     (  
                         SELECT MAX(ReviewLineProductCode_Key)  
                         FROM DimLineProductCodeReview_Mod  
                         WHERE EffectiveFromTimeKey <= @TimeKey  
                               AND EffectiveToTimeKey >= @TimeKey  
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')  
                         GROUP BY ReviewLineProductCode_Key  
                     )  
                 )A  
   GROUP BY A.ReviewLinecodeAlt_Key,  
       A.ReviewLineCodeName,  
       A.ReviewLineCode,  
       A.ReviewLineCodeGroup,  
       A.CodeType,  
  
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
                 SELECT *  
                 FROM  
                 (  
            SELECT ROW_NUMBER() OVER(ORDER BY ReviewLineCodeAlt_Key) AS RowNumber,   
                            COUNT(*) OVER() AS TotalCount,   
                            'DimLineCodeReview' TableName,   
                            *  
                     FROM  
                     (  
                         SELECT *  
                         FROM #temp16 A  
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'  
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'  
                     ) AS DataPointOwner  
                 ) AS DataPointOwner  
     Order By DataPointOwner.DateCreated Desc  
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1  
                 --      AND RowNumber <= (@PageNo * @PageSize)  
  
   END;  
  
   IF(@OperationFlag  in (20))  
  
             BEGIN  
    IF OBJECT_ID('TempDB..#temp20') IS NOT NULL  
                 DROP TABLE #temp20;  
                 SELECT A.ReviewLineCodeAlt_Key,  
       A.ReviewLineCodeName,  
  
       A.StockLineCodeAlt_Key,  
       A.StockLineCodeName,  
  
       A.ReviewLineProductCodeAlt_Key,  
       A.ReviewLineProductCodeName,  
  
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
                 INTO #temp20  
                 FROM   
                 (  
                     SELECT   
       A.ReviewLinecodeAlt_Key,  
       A.ReviewLineCodeName,  
          NULL StockLineCodeAlt_Key,  
       NULL StockLineCodeName,  
       Null ReviewLineProductCodeAlt_Key,  
       NULL ReviewLineProductCodeName,  
       isnull(A.AuthorisationStatus, 'A') AuthorisationStatus,   
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
       --select *  
                     --FROM DimSeniorityChargeMaster A  
      FROM DimLineCodeReview A  
      
      WHERE A.EffectiveFromTimeKey <= @TimeKey  
                           AND A.EffectiveToTimeKey >= @TimeKey  
                      --AND ISNULL(A.AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')  
                           AND A.ReviewLineCodeAlt_Key IN  
                     (  
                         SELECT MAX(ReviewLineCodeAlt_Key)  
                       FROM DimLineCodeReview_Mod  
                         WHERE EffectiveFromTimeKey <= @TimeKey  
                               AND EffectiveToTimeKey >= @TimeKey  
                               AND ISNULL(AuthorisationStatus, 'A') IN('1A')  
                         GROUP BY ReviewLineCodeAlt_Key  
                     )  
          UNION ALL  
              SELECT          NULL ReviewLinecodeAlt_Key,  
       NULL ReviewLineCodeName,  
       A.StockLineCodeAlt_Key,  
       A.StockLineCodeName,  
          Null ReviewLineProductCodeAlt_Key,  
       NULL ReviewLineProductCodeName,  
       isnull(A.AuthorisationStatus, 'A') AuthorisationStatus,   
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
       --select *  
                       
      FROM DimLinecodeStockStatement A  
      WHERE A.EffectiveFromTimeKey <= @TimeKey  
                           AND A.EffectiveToTimeKey >= @TimeKey  
                           AND ISNULL(A.AuthorisationStatus, 'A') = 'A'  
  
  
                     UNION  
                     SELECT    
                 NULL ReviewLinecodeAlt_Key,  
          NULL ReviewLineCodeName,  
        
                A.StockLineCodeAlt_Key,  
           A.StockLineCodeName,  
       Null ReviewLineProductCodeAlt_Key,  
       NULL ReviewLineProductCodeName,  
       isnull(A.AuthorisationStatus, 'A') AuthorisationStatus,   
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
                     FROM DimLinecodeStockStatement_Mod A  
     WHERE A.EffectiveFromTimeKey <= @TimeKey  AND A.EffectiveToTimeKey >= @TimeKey  
       AND ISNULL(A.AuthorisationStatus, 'A') IN('1A')  
                           AND A.StockLineCodeAlt_Key IN  
                     (  
                         SELECT MAX(StockLineCodeAlt_Key)  
                         FROM DimLinecodeStockStatement_Mod  
                         WHERE EffectiveFromTimeKey <= @TimeKey  
                               AND EffectiveToTimeKey >= @TimeKey  
                               AND ISNULL(AuthorisationStatus, 'A') IN('1A')  
                         GROUP BY StockLineCodeAlt_Key  
                     )  
                               
                ------------------------------------3  
    UNION ALL  
    SELECT    NULL ReviewLinecodeAlt_Key,  
          NULL ReviewLineCodeName,  
  
                NULL StockLineCodeAlt_Key,  
       NULL StockLineCodeName,  
       A.ReviewLineProductCodeAlt_Key,  
       A.ReviewLineProductCodeName,  
        
       isnull(A.AuthorisationStatus, 'A') AuthorisationStatus,   
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
       --select *  
                     FROM DimLineProductCodeReview A  
    --select top 2 * from DimLineCodeReview  
    --select top 2 * from DimLinecodeStockStatement  
    --select top 2 * from DimLineProductCodeReview   
      WHERE A.EffectiveFromTimeKey <= @TimeKey  
                           AND A.EffectiveToTimeKey >= @TimeKey  
                           AND ISNULL(A.AuthorisationStatus, 'A') = 'A'  
  
  
                     UNION  
                     SELECT   NULL ReviewLinecodeAlt_Key,  
          NULL ReviewLineCodeName,  
  
             NULL StockLineCodeAlt_Key,  
       NULL StockLineCodeName,  
          A.ReviewLineProductCodeAlt_Key,  
       A.ReviewLineProductCodeName,  
         
       isnull(A.AuthorisationStatus, 'A') AuthorisationStatus,   
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
                     FROM DimLineProductCodeReview_Mod A  
      WHERE A.EffectiveFromTimeKey <= @TimeKey  AND A.EffectiveToTimeKey >= @TimeKey  
      AND ISNULL(A.AuthorisationStatus, 'A') IN('1A')  
                           AND A.ReviewLineProductCodeAlt_Key IN  
                     (  
                         SELECT MAX(ReviewLineProductCodeAlt_Key)  
                         FROM DimLineProductCodeReview_Mod  
                         WHERE EffectiveFromTimeKey <= @TimeKey  
                               AND EffectiveToTimeKey >= @TimeKey  
                               AND ISNULL(AuthorisationStatus, 'A') IN('1A')  
                         GROUP BY ReviewLineProductCodeAlt_Key  
                     )  
  
                 ) A   
                        
                   
                    GROUP BY A.ReviewLineCodeAlt_Key,  
       A.ReviewLineCodeName,  
       A.StockLineCodeAlt_Key,  
       A.StockLineCodeName,  
  
       A.ReviewLineProductCodeAlt_Key,  
       A.ReviewLineProductCodeName,  
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
                 SELECT *  
                 FROM  
                 (  
                     SELECT ROW_NUMBER() OVER(ORDER BY SeniorityChargeAltKey) AS RowNumber,   
                            COUNT(*) OVER() AS TotalCount,   
                            'ProductCodeMaster' TableName,   
                            *  
                     FROM  
                     (  
                         SELECT *  
                         FROM #temp20 A  
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'  
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'  
                     ) AS DataPointOwner  
                 ) AS DataPointOwner  
     Order By DataPointOwner.DateCreated Desc  
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1  
                 --      AND RowNumber <= (@PageNo * @PageSize)  
END  
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