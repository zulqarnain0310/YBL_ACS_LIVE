SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[GetCurrentSessionID]  

	@loginID varchar(MAX)=NULL
	--,@sessionid VARCHAR(MAX)='' output
AS
BEGIN 
		--select @sessionid = SessionId from DimUserInfo where UserLoginID=@loginID
		select SessionId from DimUserInfo where UserLoginID=@loginID
END


GO