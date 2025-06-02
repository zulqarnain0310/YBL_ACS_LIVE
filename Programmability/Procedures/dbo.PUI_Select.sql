SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROC [dbo].[PUI_Select]

				@OperationFlag			INT         
				,@UserId				VARCHAR(30)
AS
     
	 BEGIN

SET NOCOUNT ON;
Declare @TimeKey as Int
	SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')
					

BEGIN TRY



			IF(@OperationFlag = 2)

			   BEGIN
			 
                     SELECT 
							A.CustomerEntityID
							
							,A.CustomerID
							
							,A.CustomerName
							
							,A.AccountID
							,convert(varchar(20),A.OriginalEnvisagCompletionDt,103) OriginalEnvisagCompletionDt
							,convert(varchar(20),A.RevisedCompletionDt,103) RevisedCompletionDt
							,convert(varchar(20),A.ActualCompletionDt,103) ActualCompletionDt
							,A.ProjectCat
							,A.ProjectDelReason
							,A.StandardRestruct
							,isnull(A.AuthorisationStatus, 'A') AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            convert(varchar(20),A.DateCreated,103) DateCreated, 
                            A.ApprovedBy, 
                            convert(varchar(20),A.DateApproved,103) DateApproved, 
                            A.ModifiedBy, 
                            convert(varchar(20),A.DateModified,103) DateModified,
							'PUIUpload' TableName
                     FROM AdvAcProjectDetail_Upload_Mod A
					 
					WHERE ISNULL(A.AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')
                         
                   
             END;



			IF(@OperationFlag = 16)

			   BEGIN
			 
                     SELECT 
							A.CustomerEntityID
							
							,A.CustomerID
							
							,A.CustomerName
							
							,A.AccountID
							,convert(varchar(20),A.OriginalEnvisagCompletionDt,103) OriginalEnvisagCompletionDt
							,convert(varchar(20),A.RevisedCompletionDt,103) RevisedCompletionDt
							,convert(varchar(20),A.ActualCompletionDt,103) ActualCompletionDt
							,A.ProjectCat
							,A.ProjectDelReason
							,A.StandardRestruct,
							isnull(A.AuthorisationStatus, 'A') AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                             convert(varchar(20),A.DateCreated,103) DateCreated, 
                            A.ApprovedBy, 
                            convert(varchar(20),A.DateApproved,103) DateApproved, 
                            A.ModifiedBy, 
                            convert(varchar(20),A.DateModified,103) DateModified,
							'PUIUpload' TableName
                     FROM AdvAcProjectDetail_Upload_Mod A
					 
					WHERE ISNULL(A.AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM') and CreatedBy <> @UserId
                         
                   
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

	END
GO