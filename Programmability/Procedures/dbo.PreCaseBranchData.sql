SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[PreCaseBranchData]
	@UserLoginID varchar(20)=''
	,@TimeKey INT=49999
AS
BEGIN
	
	DECLARE @LocatationCode VARCHAR(10), @Location char(2)='HO'
	SELECT @Location=ISNULL(UserLocation,''),@LocatationCode=ISNULL(UserLocationCode,'') FROM DimUserInfo WHERE UserLoginID=@UserLoginID
	PRINT @Location
	PRINT @LocatationCode

	IF OBJECT_ID('Tempdb..#TempBrData') IS NOT NULL 
		DROP TABLE #TempBrData
	CREATE TABLE #TempBrData (BranchCode VARCHAR(10), BranchName VARCHAR(40))

	INSERT INTO #TempBrData
	
	SELECT BranchCode, BranchName from DimBranch A
	WHERE (EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey)
	AND @LocatationCode= CASE WHEN @Location='HO' THEN @LocatationCode 
							  WHEN @Location='ZO' THEN CAST(A.BranchZoneAlt_Key AS varchar(10))
							  WHEN @Location='RO' THEN CAST(A.BranchRegionAlt_Key AS varchar(10))
							  WHEN @Location='BO' THEN CAST(A.BranchCode AS varchar(10))
						  END
	  
	 select * from #TempBrData


END



GO