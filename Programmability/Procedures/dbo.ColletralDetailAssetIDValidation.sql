SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

  
  CREATE PROCEDURE [dbo].[ColletralDetailAssetIDValidation]

	@AssetID		varchar(200) = ''
	,@Timekey		INT = 0
	,@Result		INT=0 OUTPUT
  AS
  BEGIN
  Set @Timekey=(
			select CAST(B.timekey as int)from SysDataMatrix A
			Inner Join SysDayMatrix B ON A.TimeKey=B.TimeKey
			 where A.CurrentStatus='C'
			 )

  IF EXISTS(				                
					SELECT  1 FROM Curdat.AdvSecurityDetail 
					WHERE  AssetID=@AssetID AND ISNULL(AuthorisationStatus,'A')='A' 
					and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey
					UNION
					SELECT		1
					FROM		DBO.AdvSecurityDetail_Mod  V
					FULL OUTER Join	CollateralDetailUpload_Mod C 
					ON			V.AssetID=C.AssetID 
					AND			(V.AssetID is not NULL or C.AssetID is not NULL)
					WHERE		(V.AssetID=@AssetID  or C.AssetID=@AssetID )
					--AND   ISNULL(AuthorisationStatus,'A') in('NP','MP','DP','RM') 

				)	
				BEGIN
			SELECT '1' CODE, 'Data Exist' Status
		END
		ELSE
		BEGIN
			SELECT '0' CODE, 'Data Not Exist' Status
		END 

		END
	
GO