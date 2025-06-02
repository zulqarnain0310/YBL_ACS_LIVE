SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


create PROC [dbo].[AlertSecondaryRecipientDropDown]

						@UserId varchar (500)=''
						
						  
AS
  BEGIN

  Declare @TimeKey as Int 

	Set @TimeKey = (Select Timekey from SysDataMatrix where CurrentStatus='C')

BEGIN TRY
			Select AlertRecipientAlt_Key,
			AlertRecipientUserId,
			Email_Id,
			'AlertSecondaryRecipient' as Tablename
			from DimAlertRecipientMaster
			where  AlertRecipientUserId not in ( Select * from Split(@UserId,','))
			And EffectiveFromTimeKey<=@TimeKey
			And EffectiveToTimeKey>=@TimeKey

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