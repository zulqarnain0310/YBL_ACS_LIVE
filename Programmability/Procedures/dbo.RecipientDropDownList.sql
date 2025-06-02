SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



CREATE PROC [dbo].[RecipientDropDownList]

  
AS
  BEGIN

  Declare @TimeKey as Int 

	Set @TimeKey = (Select Timekey from SysDataMatrix where CurrentStatus='C')

	BEGIN TRY

	/*	This is for Drop down list of Department Name */

		Select distinct 
		DeptGroupName,
		DeptGroupId,
		'DeptNameList' as TableName
		from DimUserInfo A
		INNER JOIN DimUserDeptGroup B
		ON A.DeptGroupCode=DeptGroupId
		Where A.EffectiveFromTimeKey<=@TimeKey
		And A.EffectiveToTimeKey>=@TimeKey
		
	
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