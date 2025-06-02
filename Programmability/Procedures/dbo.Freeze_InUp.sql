SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create PROC [dbo].[Freeze_InUp]
			@ScreeName VARCHAR(20)			--QtrFreeze,PostMocFreeze,MasterFreeze
			,@UserLoginId VARCHAR(20)		
			,@TimeKey INT
			,@LastQtrDateKey INT = 24837
			, @Result			INT =0 OUTPUT
			,@D2KTimeStamp		INT=0 OUTPUT

AS
BEGIN


		Declare @LastQtrDateKeyOfCurrentQtr int


		SELECT  @LastQtrDateKeyOfCurrentQtr=MAX(TimeKey) FROM SysDataMatrix 
					WHERE Prev_Qtr_key=(SELECT MAX(TimeKey) FROM SysDataMatrix 
					WHERE ISNULL(QTR_Initialised,'N') ='Y' AND ISNULL(QTR_Frozen,'N')='Y')

						

	UPDATE  SysDataMatrix 
	SET QTR_Initialised = 'Y'
	WHERE Prev_Qtr_key = @LastQtrDateKey 
	AND @ScreeName = 'QtrFreeze'

	IF @@ROWCOUNT>0
	BEGIN
		SET @Result =1
	END

	UPDATE  SysDataMatrix 
	SET QTR_Frozen = 'Y'
	WHERE Prev_Qtr_key = @LastQtrDateKey 
	AND @ScreeName = 'PostMocFreeze'

	IF @@ROWCOUNT>0
	BEGIN
		SET @Result =1
	END

	UPDATE  SysDataMatrix 
	SET MOC_Initialised = 'Y'
	WHERE Prev_Qtr_key = @LastQtrDateKey 
	AND @ScreeName = 'MOCInitialize'

	IF @@ROWCOUNT>0
	BEGIN
		SET @Result =1
	END



	IF @Result<>1
	BEGIN
		SET @Result = -1
	END 
	RETURN @Result
END





GO