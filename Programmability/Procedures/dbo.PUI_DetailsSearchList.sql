SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROC [dbo].[PUI_DetailsSearchList] 
--Declare
						 
						@CustomerID				Varchar(20)	= ''
						,@AccountID	                Varchar(30)	= ''
						,@OperationFlag  INT         = 1
AS
     
	 BEGIN

SET NOCOUNT ON;
Declare @TimeKey as Int
	SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')

	SET @CustomerID =case when  @CustomerID='' then NULL Else @CustomerID end
	SET @AccountID =case when  @AccountID='' then NULL  else @AccountID end

if @CustomerID is not null
	Begin
		if not EXISTS (Select 1 From AdvAcProjectDetail A
												  
												  Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
												  And A.CustomerId=@CustomerID 
												  union
												  Select 1 From AdvAcProjectDetail_Mod A
												  
												  Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
												   And A.CustomerId=@CustomerID  )
												   begin
												   Select 'Customer Id Not Exists' as Errormsg,'ErrorTable' as TableName
												   end
			End
			
	if @AccountID is not null
	Begin
		if not EXISTS (Select 1 From AdvAcProjectDetail A
												  
												  Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
												  And A.AccountId=@AccountID 
												  union
												  Select 1 From AdvAcProjectDetail_Mod A
												  
												  Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
												    And A.AccountId=@AccountID   )
												   begin
												   Select 'Account Id Not Exists'  as Errormsg,'ErrorTable' as TableName
												   end
			End
					

BEGIN TRY

/*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */


			IF(@OperationFlag <> 16)
             BEGIN
			 IF OBJECT_ID('TempDB..#temp') IS NOT NULL
                 DROP TABLE  #temp;
                 SELECT     A.CustomerID,
							A.CustomerName,
							A.AccountId,
							A.OriginalEnvisagCompletionDt,
							A.RevisedCompletionDt,
					        A.ActualCompletionDt,
							a.ProjectCatgAlt_Key,
							A.ProjectCategory,
							A.ProjectDelReason_AltKey,
							A.ProjectDelReason,
							A.StandardRestruct_Altkey,
							A.StandardRestruct,
						    A.AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified
                 INTO #temp
                 FROM 
                 (
                     SELECT 
							
							A.CustomerID,
							A.CustomerName,
							A.AccountId,
							convert(varchar(20),A.OriginalEnvisagCompletionDt,103) OriginalEnvisagCompletionDt,
							convert(varchar(20),A.RevisedCompletionDt,103) RevisedCompletionDt,
						    convert(varchar(20),A.ActualCompletionDt,103) ActualCompletionDt,
							a.ProjectCatgAlt_Key,
							H.ParameterName ProjectCategory,
							A.ProjectDelReason_AltKey,
							i.ParameterName ProjectDelReason,
							A.StandardRestruct_Altkey,
							J.ParameterName StandardRestruct,
							isnull(A.AuthorisationStatus, 'A') AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified
                     FROM AdvAcProjectDetail A
						 Inner Join (Select ParameterAlt_Key,ParameterName,'ProjectCategory' as Tablename 
						  from DimParameter where DimParameterName='ProjectCategory'
						  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)H
						  ON H.ParameterAlt_Key=A.ProjectCatgAlt_Key
						  left join (Select ParameterAlt_Key,ParameterName,'ProdectDelReson' as Tablename 
						  from DimParameter where DimParameterName='ProdectDelReson'
						  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)I
						  ON I.ParameterAlt_Key=A.ProjectDelReason_AltKey
						  left join (Select ParameterAlt_Key,ParameterName,'StandardRestruct' as Tablename 
						  from DimParameter where DimParameterName='DimYesNo'
						  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)j
						  ON j.ParameterAlt_Key=A.StandardRestruct_AltKey
						  WHERE A.EffectiveFromTimeKey <= @TimeKey
                          AND A.EffectiveToTimeKey >= @TimeKey
                          AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
					
                     UNION
                     SELECT A.CustomerID,
							A.CustomerName,
							A.AccountId,
							convert(varchar(20),A.OriginalEnvisagCompletionDt,103) OriginalEnvisagCompletionDt,
							convert(varchar(20),A.RevisedCompletionDt,103) RevisedCompletionDt,
						    convert(varchar(20),A.ActualCompletionDt,103) ActualCompletionDt,
							a.ProjectCatgAlt_Key,
							H.ParameterName ProjectCategory,
							A.ProjectDelReason_AltKey,
							i.ParameterName ProjectDelReason,
							A.StandardRestruct_Altkey,
							J.ParameterName StandardRestruct,
							isnull(A.AuthorisationStatus, 'A') AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified
                     FROM AdvAcProjectDetail_Mod A
						 Inner Join (Select ParameterAlt_Key,ParameterName,'ProjectCategory' as Tablename 
						  from DimParameter where DimParameterName='ProjectCategory'
						  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)H
						  ON H.ParameterAlt_Key=A.ProjectCatgAlt_Key
						  left join (Select ParameterAlt_Key,ParameterName,'ProdectDelReson' as Tablename 
						  from DimParameter where DimParameterName='ProdectDelReson'
						  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)I
						  ON I.ParameterAlt_Key=A.ProjectDelReason_AltKey
						  left join (Select ParameterAlt_Key,ParameterName,'StandardRestruct' as Tablename 
						  from DimParameter where DimParameterName='DimYesNo'
						  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)j
						  ON j.ParameterAlt_Key=A.StandardRestruct_AltKey
						  WHERE A.EffectiveFromTimeKey <= @TimeKey
                          AND A.EffectiveToTimeKey >= @TimeKey
					--AND ((H.ParameterName NOT IN('Out Default') and I.ParameterName NOT IN('Implemented'))
					--AND (H.ParameterName NOT IN('Out Default') and I.ParameterName NOT IN('Implemented with Extension')))
                    --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                    AND A.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM AdvAcProjectDetail_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')
                         GROUP BY CustomerID
                     )
                 ) A 
                      
                 
                 GROUP BY 
							A.CustomerID,
							A.CustomerName,
							A.AccountId,
							A.OriginalEnvisagCompletionDt,
							A.RevisedCompletionDt,
							A.ActualCompletionDt,
							a.ProjectCatgAlt_Key,
							A.ProjectCategory,
							A.ProjectDelReason_AltKey,
							A.ProjectDelReason,
							A.StandardRestruct_Altkey,
							A.StandardRestruct,
							A.AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified;

                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY CustomerID) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'PUIMaster' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp A
                         WHERE ISNULL(AccountId, '') =isnull(@AccountID,'')
                               or ISNULL(CustomerID, '') =isnull(@CustomerID,'')
							  
							   							   
							   
                     ) AS DataPointOwner
                 ) AS DataPointOwner
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                 --      AND RowNumber <= (@PageNo * @PageSize);
             END;
             ELSE

			 
			 /*  IT IS Used For GRID Search which are Pending for Authorization    */


             BEGIN
			 IF OBJECT_ID('TempDB..#temp16') IS NOT NULL
                 DROP TABLE #temp16;
                 SELECT A.CustomerID,
							A.CustomerName,
							A.AccountId,
							A.OriginalEnvisagCompletionDt,
							A.RevisedCompletionDt,
					        A.ActualCompletionDt,
							a.ProjectCatgAlt_Key,
							A.ProjectCategory,
							A.ProjectDelReason_AltKey,
							A.ProjectDelReason,
							A.StandardRestruct_Altkey,
							A.StandardRestruct,
							A.AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified
                 INTO #temp16
                 FROM 
                 (
                     SELECT  A.CustomerID,
							A.CustomerName,
							A.AccountId,
							convert(varchar(20),A.OriginalEnvisagCompletionDt,103) OriginalEnvisagCompletionDt,
							convert(varchar(20),A.RevisedCompletionDt,103) RevisedCompletionDt,
						    convert(varchar(20),A.ActualCompletionDt,103) ActualCompletionDt,
							a.ProjectCatgAlt_Key,
							H.ParameterName ProjectCategory,
							A.ProjectDelReason_AltKey,
							i.ParameterName ProjectDelReason,
							A.StandardRestruct_Altkey,
							J.ParameterName StandardRestruct,
							isnull(A.AuthorisationStatus, 'A') AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified
                     FROM AdvAcProjectDetail_Mod A
						 Inner Join (Select ParameterAlt_Key,ParameterName,'ProjectCategory' as Tablename 
						  from DimParameter where DimParameterName='ProjectCategory'
						  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)H
						  ON H.ParameterAlt_Key=A.ProjectCatgAlt_Key
						  left join (Select ParameterAlt_Key,ParameterName,'ProdectDelReson' as Tablename 
						                  from DimParameter where DimParameterName='ProdectDelReson'
						                     And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)I
						                    ON I.ParameterAlt_Key=A.ProjectDelReason_AltKey
						  left join (Select ParameterAlt_Key,ParameterName,'StandardRestruct' as Tablename 
						                   from DimParameter where DimParameterName='DimYesNo'
						                   And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)j
						  ON j.ParameterAlt_Key=A.StandardRestruct_AltKey
						  WHERE A.EffectiveFromTimeKey <= @TimeKey
                          AND A.EffectiveToTimeKey >= @TimeKey
					--AND ((H.ParameterName NOT IN('Out Default') and I.ParameterName NOT IN('Implemented'))
					--AND (H.ParameterName NOT IN('Out Default') and I.ParameterName NOT IN('Implemented with Extension')))
                    --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                    AND A.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM AdvAcProjectDetail_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')
                         GROUP BY CustomerID
                     )
                 ) A 
                      
                 
                 GROUP BY 
							A.CustomerID,
							A.CustomerName,
							A.AccountId,
							A.OriginalEnvisagCompletionDt,
							A.RevisedCompletionDt,
							A.ActualCompletionDt,
							a.ProjectCatgAlt_Key,
							A.ProjectCategory,
							A.ProjectDelReason_AltKey,
							A.ProjectDelReason,
							A.StandardRestruct_Altkey,
							A.StandardRestruct,
							A.AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified;
                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY CustomerID) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'PUIMaster' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp16 A
                         WHERE ISNULL(AccountId, '') LIKE '%'+ISNULL(@CustomerID,'')+'%'
                              AND ISNULL(CustomerID, '') LIKE '%'+ISNULL(@CustomerID,'')+'%'
							   							   

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
					BEGIN

					Declare @Cust_Id Varchar(20)=(Select CustomerID From AdvAcProjectDetail A
												  
												  Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
												  And A.AccountId=@AccountID 
												 
												  --AND ((H.ParameterName NOT IN('Out Default') and I.ParameterName NOT IN('Implemented'))
												  --AND (H.ParameterName NOT IN('Out Default') and I.ParameterName NOT IN('Implemented with Extension')))
												 )

						--EXEC RPLenderDetailsSelect @CustomerID=@Cust_Id

					END

     END;
GO