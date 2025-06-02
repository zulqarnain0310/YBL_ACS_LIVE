SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--[dbo].[UserDetailInformation] '5209701'
create PROC [dbo].[UserDetailInformation]
--Declare
													
 @UserID Varchar(50)

AS

	BEGIN 

	SET NOCOUNT ON;

	DECLARE @Timekey INT = (SELECT TimeKey FROM DBO.SysDayMatrix WHERE DATE=CAST(GETDATE() AS DATE))

		Select UserLoginID,LoginPassword from DBO.DimUserInfo where UserLoginID=@UserID
		AND EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey	

    END;


GO