SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROC [dbo].[UserSessionClear]
(
	@UserLoginID varchar(50)=''
)
AS
		DECLARE @TimeKey INT
BEGIN
	
	SET @TimeKey=(SELECT TimeKey FROM SysDayMatrix WHERE CAST(Date AS DATE)=CAST(GETDATE() AS DATE))
	
	UPDATE DimUserInfo SET UserLogged=0, LastRequestTime=NULL 
	WHERE (EffectiveFromTimeKey < = @TimeKey  AND EffectiveToTimeKey  > = @TimeKey)
				  AND UserLoginID=@UserLoginID
	SELECT @UserLoginID AS UserLoginID
END
GO