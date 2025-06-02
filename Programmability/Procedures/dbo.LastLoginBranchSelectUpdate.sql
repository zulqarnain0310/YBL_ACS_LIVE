SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO





Create PROCEDURE [dbo].[LastLoginBranchSelectUpdate] 
    @BranchCode		VARCHAR(20),
    @Type			VARCHAR(10),
	@userLoginId	VARCHAR(20)
AS
BEGIN
		DECLARE @Maxkey INT 
		IF	@Type = 'Login'
		BEGIN
			
			SELECT @Maxkey= MAX(EntityKey) FROM UserLoginHistory WHERE UserID =@userLoginId and BranchCode is not null

			SELECT BranchCode FROM UserLoginHistory WHERE EntityKey = @Maxkey

		END
		ELSE IF @Type = 'Logout'
		BEGIN
			
			SELECT @Maxkey= MAX(EntityKey) FROM UserLoginHistory WHERE UserID =@userLoginId
			
			UPDATE UserLoginHistory SET BranchCode = @BranchCode,LogoutTime = Getdate() WHERE EntityKey = @Maxkey ---Added to Update Logout time in User login history Added by shubham on 2024-03-29 against Observation Raised --Changes Deployed on UAT 2024-04-10 Agianst Logouttime not updatebale WHERE EntityKey = @Maxkey

			SELECT BranchCode FROM UserLoginHistory WHERE EntityKey = @Maxkey

				Declare @TimeKeyCurrent INT
			SET @TimeKeyCurrent = (select TimeKey from sysdaymatrix where date=convert(date,getdate(),103))
			Update DimUserInfo Set UserLogged=0 where (EffectiveFromTimeKey<=@TimeKeyCurrent AND EffectiveToTimeKey>=@TimeKeyCurrent)
			AND UserLoginID=@userLoginId

		END
END




















GO