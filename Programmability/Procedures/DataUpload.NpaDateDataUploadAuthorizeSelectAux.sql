SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* =============================================
 AUTHER : SANJEEV KUMAR SHARMA
 CREATE BY : 28-12-2018
 MODIFY DATE : 28-12-2018
 DESCRIPTION : SELECT DATA FROM  NpaDateDataUpload 
 ===============================================*/
Create PROCEDURE [DataUpload].[NpaDateDataUploadAuthorizeSelectAux]
	@OperationFlag			INT
	,@UserId				VARCHAR(30)
	,@TimeKey INT
AS
BEGIN
	SET NOCOUNT ON;

		
		IF OBJECT_ID('Tempdb..#NpaDateDATAUPLOAD')	IS NOT NULL
			DROP TABLE #NpaDateDATAUPLOAD

			CREATE TABLE #NpaDateDATAUPLOAD (
				NpaDateDataEntityId		INT
				, UCIFID				VARCHAR(100)
				, NPADATE				VARCHAR(10)
				, NPADATECHANGEREASON   VARCHAR(500) --ADDED by Shubham on 2024-01-16 For addition of NPADATECHANGEREASON
				, AuthorisationStatus	VARCHAR(2)
				, CrModApBy				VARCHAR(50)
				, D2Ktimestamp			TIMESTAMP
				, ChangeFields			VARCHAR(100)
				, IsMainTable			VARCHAR(1)
			)

		IF @OperationFlag = 16
		BEGIN
			INSERT INTO #NpaDateDATAUPLOAD (
					NpaDateDataEntityId		
					, UCIFID				
					, NPADATE				
					, NPADATECHANGEREASON --ADDED by Shubham on 2024-01-16 For addition of NPADATECHANGEREASON
					, AuthorisationStatus	
					, CrModApBy				
					--, D2Ktimestamp			
					, ChangeFields			
					, IsMainTable			
				)
			SELECT
				A.NpaDateDataEntityId
				,A.UCIF_ID AS UCIFID
				,CONVERT(VARCHAR(10),A.NPADate,103) NPADATE
				,A.NPADATECHANGEREASON --ADDED by Shubham on 2024-01-16 For addition of NPADATECHANGEREASON
				,ISNULL(A.AuthorisationStatus,'A') as AuthorisationStatus
				,ISNULL(A.ModifiedBy,A.CreatedBy) CrModApBy
				--,CAST(A.D2Ktimestamp AS INT)D2Ktimestamp
				,ChangeFields
				,'N' IsMainTable
				--INTO #NpaDateDATAUPLOAD
			FROM DataUpload.NpaDateDATAUPLOAD_Mod A
			INNER JOIN 
			(
				SELECT UCIF_ID,NpaDateDataEntityId,NPADate,NPADATECHANGEREASON,MAX(Entitykey)Entitykey --ADDED by Shubham on 2024-01-16 For addition of NPADATECHANGEREASON
				FROM DataUpload.NpaDateDATAUPLOAD_Mod
				WHERE EffectiveFromTimeKey<= @TimeKey AND EffectiveToTimeKey >= @TimeKey
				AND   AuthorisationStatus in('NP','MP','RM','DP')
				GROUP BY UCIF_ID,NpaDateDataEntityId,NPADate,NPADATECHANGEREASON --ADDED by Shubham on 2024-01-16 For addition of NPADATECHANGEREASON
			) B
			ON A.Entitykey = B.Entitykey
			WHERE ISNULL(A.ModifiedBy,A.CreatedBy) <> @UserId
			AND  A.AuthorisationStatus in('NP','MP','RM')

		END
		ELSE IF @OperationFlag = 20
		BEGIN

			INSERT INTO #NpaDateDATAUPLOAD (
					NpaDateDataEntityId		
					, UCIFID				
					, NPADATE			
					, NPADATECHANGEREASON --ADDED by Shubham on 2024-01-16 For addition of NPADATECHANGEREASON
					, AuthorisationStatus	
					, CrModApBy				
					--, D2Ktimestamp			
					, ChangeFields			
					, IsMainTable			
				)
			SELECT	 
					A.NpaDateDataEntityId
					,A.UCIF_ID AS UCIFID
					,CONVERT(VARCHAR(10),A.NPADate,103) NPADATE
					,A.NPADATECHANGEREASON --ADDED by Shubham on 2024-01-16 For addition of NPADATECHANGEREASON
					,ISNULL(A.AuthorisationStatus,'A') as AuthorisationStatus
					,Coalesce(A.ApprovedByFirstLevel,A.ModifiedBy,A.CreatedBy) CrModApBy
					--,CAST(A.D2Ktimestamp AS INT)D2Ktimestamp
					,ChangeFields
					,'N' IsMainTable
			--INTO #StockStatementDataUpload
			FROM DataUpload.NpaDateDATAUPLOAD_Mod A
			INNER JOIN 
			(
				SELECT UCIF_ID,NpaDateDataEntityId,NPADate,NPADATECHANGEREASON,MAX(Entitykey)Entitykey   --ADDED by Shubham on 2024-01-16 For addition of NPADATECHANGEREASON
				FROM DataUpload.NpaDateDATAUPLOAD_Mod
				WHERE EffectiveFromTimeKey<= @TimeKey AND EffectiveToTimeKey >= @TimeKey
				AND   AuthorisationStatus in('1A')
				GROUP BY UCIF_ID,NpaDateDataEntityId,NPADate,NPADATECHANGEREASON   --ADDED by Shubham on 2024-01-16 For addition of NPADATECHANGEREASON
			)B
			ON A.Entitykey = B.Entitykey
			WHERE ISNULL(ISNULL(A.ApprovedByFirstLevel,''),ISNULL(A.ModifiedBy,'')) <> @UserId
					AND ISNULL(A.ModifiedBy,A.CreatedBy) <> @UserId
					AND ISNULL(A.CreatedBy, '') <> @UserId

		END
		ELSE
		BEGIN
			
			INSERT INTO #NpaDateDATAUPLOAD (
					NpaDateDataEntityId		
					, UCIFID				
					, NPADATE				
					, NPADATECHANGEREASON --ADDED by Shubham on 2024-01-16 For addition of NPADATECHANGEREASON
					, AuthorisationStatus	
					, CrModApBy				
					--, D2Ktimestamp			
					--, ChangeFields			
					, IsMainTable			
				)
			SELECT A.NpaDateDataEntityId
				,A.UCIF_ID AS UCIFID
				,CONVERT(VARCHAR(10),NPADate,103) NPADATE
				,A.NPADATECHANGEREASON --ADDED by Shubham on 2024-01-16 For addition of NPADATECHANGEREASON
				,ISNULL(A.AuthorisationStatus,'A') as AuthorisationStatus
				,ISNULL(A.ModifiedBy,A.CreatedBy) CrModApBy
				--,CAST(A.D2Ktimestamp AS INT)D2Ktimestamp
				--,ChangeFields
				,'Y' IsMainTable
	
			FROM DataUpload.NpaDateDATAUPLOAD A
			WHERE EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey
			AND ISNULL(AuthorisationStatus,'A')='A'

			UNION
			SELECT	 
					A.NpaDateDataEntityId
				,A.UCIF_ID AS UCIFID
				,CONVERT(VARCHAR(10),A.NPADate,103) NPADATE
				,A.NPADATECHANGEREASON --ADDED by Shubham on 2024-01-16 For addition of NPADATECHANGEREASON
				,ISNULL(A.AuthorisationStatus,'A') as AuthorisationStatus
				,ISNULL(A.ModifiedBy,A.CreatedBy) CrModApBy
				--,CAST(A.D2Ktimestamp AS INT)D2Ktimestamp
				--,ChangeFields
				,'N' IsMainTable
			FROM DataUpload.NpaDateDATAUPLOAD_Mod A
			INNER JOIN 
			(
				SELECT UCIF_ID,NpaDateDataEntityId,NPADate,NPADATECHANGEREASON,MAX(Entitykey)Entitykey
				FROM DataUpload.NpaDateDATAUPLOAD_Mod
				WHERE EffectiveFromTimeKey<= @TimeKey AND EffectiveToTimeKey >= @TimeKey
				AND   AuthorisationStatus in('NP','MP','DP','RM','1A','1D')
				GROUP BY UCIF_ID,NpaDateDataEntityId,NPADate,NPADATECHANGEREASON
			)B
			ON A.Entitykey = B.Entitykey
			AND   A.AuthorisationStatus in('NP','MP','RM','1A')

		END

		SELECT *,'NPADateDataUpload' AS TableName FROM #NpaDateDATAUPLOAD

	--	SELECT	
	--			A.NpaDateDataEntityId
	--			,A.UCIF_ID AS UCIFID
	--			,CONVERT(VARCHAR(10),NPADate,103) NPADATE
	--			,ISNULL(A.AuthorisationStatus,'A') as AuthorisationStatus
	--			,ISNULL(A.ModifiedBy,A.CreatedBy) CrModApBy
	--			,CAST(A.D2Ktimestamp AS INT)D2Ktimestamp
	--			,ChangeFields
	--			,'N' IsMainTable
	--			INTO #NpaDateDATAUPLOAD
	--	FROM DataUpload.NpaDateDATAUPLOAD_Mod A
	--	INNER JOIN 
	--	(
	--		SELECT UCIF_ID,MAX(Entitykey)Entitykey
	--		FROM DataUpload.NpaDateDATAUPLOAD_Mod
	--		WHERE EffectiveFromTimeKey<= @TimeKey AND EffectiveToTimeKey >= @TimeKey
	--		AND   AuthorisationStatus in('NP','MP','DP','RM')
	--		GROUP BY UCIF_ID
	--	)B
	--	ON A.Entitykey = B.Entitykey
	--	WHERE ISNULL(A.ModifiedBy,A.CreatedBy) <> @UserId

	--	IF @OperationFlag<>16
	--	BEGIN
	--		INSERT INTO #NpaDateDATAUPLOAD
	--		SELECT  
	--				A.NpaDateDataEntityId
	--				,UCIF_ID AS UCIFID
	--				,CONVERT(VARCHAR(10),NPADate,103) NPADATE
	--				,ISNULL(AuthorisationStatus,'A') as AuthorisationStatus
	--				,ISNULL(ModifiedBy,CreatedBy) CrModApBy
	--				,CAST(D2Ktimestamp AS INT)D2Ktimestamp
	--				,NULL ChangeFields
	--				,'Y' IsMainTable 
	--				FROM DataUpload.NpaDateDATAUPLOAD A
	--		WHERE EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey
	--		AND ISNULL(AuthorisationStatus,'A')='A'
	--	END

	--IF 	@OperationFlag=16
	--BEGIN
	--	SELECT *, 'NPADateDataUpload' AS TableName FROM #NpaDateDATAUPLOAD  WHERE IsMainTable='N'
	--END
	--ELSE
	--BEGIN
	--	SELECT *,'NPADateDataUpload' AS TableName FROM #NpaDateDATAUPLOAD
	--END	
END



GO