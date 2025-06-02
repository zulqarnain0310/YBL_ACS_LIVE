SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



CREATE PROC [dbo].[RP_LenderAuthorizeSelect]

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
							,A.UCIC_ID
							,A.CustomerID
							,A.PAN_No
							,A.CustomerName
							,A.LenderName
							,A.InDefaultDate
							,A.OutOfDefaultDate,
							isnull(A.AuthorisationStatus, 'A') AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified,
							'LenderDataUpload' TableName
                     FROM RP_Lender_Upload_Mod A
					 
					WHERE ISNULL(A.AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')
                         
                   
             END;



			IF(@OperationFlag = 16)

			   BEGIN
			 
                     SELECT 
							A.CustomerEntityID
							,A.UCIC_ID
							,A.CustomerID
							,A.PAN_No
							,A.CustomerName
							,A.LenderName
							,A.InDefaultDate
							,A.OutOfDefaultDate,
							isnull(A.AuthorisationStatus, 'A') AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified,
							'LenderDataUpload' TableName
                     FROM RP_Lender_Upload_Mod A
					 
					WHERE ISNULL(A.AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM') and a.CreatedBy<>@UserId
                         
                   
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