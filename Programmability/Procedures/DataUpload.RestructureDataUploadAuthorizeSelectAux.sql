SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/* =============================================
 AUTHER : SANJEEV KUMAR SHARMA
 CREATE BY : 28-12-2018
 MODIFY DATE : 28-12-2018
 DESCRIPTION : SELECT DATA FROM  RestructureDataUpload 
 ===============================================*/
CREATE PROCEDURE [DataUpload].[RestructureDataUploadAuthorizeSelectAux]
	@OperationFlag			INT
	,@UserId				VARCHAR(30)
	,@TimeKey INT
AS
BEGIN
	SET NOCOUNT ON;

		--	IF @OperationFlag=2
		--	BEGIN
		--			SELECT 						
		--				CUSTOMERID	CUSTOMERID
		--				,CustomerAcID	ACCOUNTID
		--				,convert (varchar(20),RestructureDate, 103) RESTRUCTUREDATE
		--				,convert (varchar(20),OriginalDCCODate,103)  ORIGINALDCCODATE
		--				,convert (varchar(20),ExtendedDCCODate,103)  EXTENDEDDCCODATE
		--				,convert (varchar(20),ActualDCCODate,103)  ACTUALDCCODATE
		--				,Infrastructure	INFRASTRUCTURE
		--				,DFVAmount	DFVAMOUNT
		--			,'RestructureDataUpload' TableName
		--			FROM DATAUPLOAD.RestructureDataUpload TXN
		--			WHERE ISNULL(TXN.AuthorisationStatus,'A')='A'
		--		UNION

		--			SELECT 						
		--				CUSTOMERID	CUSTOMERID
		--				,CustomerAcID	ACCOUNTID
		--				,convert (varchar(20),RestructureDate, 103) RESTRUCTUREDATE
		--				,convert (varchar(20),OriginalDCCODate,103)  ORIGINALDCCODATE
		--				,convert (varchar(20),ExtendedDCCODate,103)  EXTENDEDDCCODATE
		--				,convert (varchar(20),ActualDCCODate,103)  ACTUALDCCODATE
		--				,Infrastructure	INFRASTRUCTURE
		--				,DFVAmount	DFVAMOUNT
		--			,'RestructureDataUpload' TableName
		--			FROM DATAUPLOAD.RestructureDataUpload_mod TXN
		--			WHERE TXN.AuthorisationStatus IN('NP','MP','RM')

		--	END
		--ELSE
		--	BEGIN
		--		select 
		--			CUSTOMERID	CUSTOMERID
		--				,CustomerAcID	ACCOUNTID
		--				,convert (varchar(20),RestructureDate, 103) RESTRUCTUREDATE
		--				,convert (varchar(20),OriginalDCCODate,103)  ORIGINALDCCODATE
		--				,convert (varchar(20),ExtendedDCCODate,103)  EXTENDEDDCCODATE
		--				,convert (varchar(20),ActualDCCODate,103)  ACTUALDCCODATE
		--				,Infrastructure	INFRASTRUCTURE
		--				,DFVAmount	DFVAMOUNT
		--			,'RestructureDataUpload' TableName
		--		FROM DATAUPLOAD.RestructureDataUpload_mod TXN
		--		WHERE TXN.AuthorisationStatus IN('NP','MP','RM')
		--		AND TXN.CreatedBy<>@UserId
		--	END

			IF OBJECT_ID('Tempdb..#RestructureDataUpload')	IS NOT NULL
			DROP TABLE #RestructureDataUpload

		SELECT	 RestructureDataEntityId
				,A.CustomerID AS CUSTOMERID
				,A.CustomerAcID AS CUSTOMERACID
				,CONVERT(VARCHAR(10),RestructureDate,103)RESTRUCTUREDATE
				,CASE WHEN ISNULL(OriginalDCCODate,'')<>'' THEN CONVERT(VARCHAR(10),OriginalDCCODate,103) ELSE NULL END ORIGINALDCCODATE
				,CASE WHEN ISNULL(ExtendedDCCODate,'')<>'' THEN CONVERT(VARCHAR(10),ExtendedDCCODate,103) ELSE NULL END EXTENDEDDCCODATE
				,CASE WHEN ISNULL(ActualDCCODate,'')<>'' THEN CONVERT(VARCHAR(10),ActualDCCODate,103) ELSE NULL END  ACTUALDCCODATE
				,Infrastructure AS INFRASTRUCTUREYN
				,DFVAmount AS DFVAMOUNT
				,ISNULL(A.AuthorisationStatus,'A') as AuthorisationStatus
				,ISNULL(A.ModifiedBy,A.CreatedBy) CrModApBy
				,CAST(A.D2Ktimestamp AS INT)D2Ktimestamp
				,ChangeFields
				,'N' IsMainTable
				,CASE WHEN ISNULL(EFFECTIVENPADATE,'')<>'' THEN CONVERT(VARCHAR(10),EFFECTIVENPADATE,103) ELSE NULL END EFFECTIVENPADATE
				,A.NPAREASON AS NPAREASON
		INTO #RestructureDataUpload
		FROM DATAUPLOAD.RestructureDataUpload_Mod A
		INNER JOIN 
		(
			SELECT CustomerID,CustomerAcID,MAX(Entitykey)Entitykey
			FROM DataUpload.RestructureDataUpload_Mod
			WHERE EffectiveFromTimeKey<= @TimeKey AND EffectiveToTimeKey >= @TimeKey
			AND   AuthorisationStatus in('NP','MP','DP','RM')
			GROUP BY CustomerID,CustomerAcID
		)B
		ON A.Entitykey = B.Entitykey
		WHERE ISNULL(A.ModifiedBy,A.CreatedBy)<> @UserId

		IF @OperationFlag<>16
		BEGIN
			INSERT INTO #RestructureDataUpload
			SELECT  RestructureDataEntityId
					,A.CustomerID AS CUSTOMERID
					,A.CustomerAcID AS CUSTOMERACID
					,CONVERT(VARCHAR(10),RestructureDate,103) RESTRUCTUREDATE
					,CASE WHEN ISNULL(OriginalDCCODate,'')<>'' THEN CONVERT(VARCHAR(10),OriginalDCCODate,103) ELSE NULL END ORIGINALDCCODATE
					,CASE WHEN ISNULL(ExtendedDCCODate,'')<>'' THEN CONVERT(VARCHAR(10),ExtendedDCCODate,103) ELSE NULL END EXTENDEDDCCODATE
					,CASE WHEN ISNULL(ActualDCCODate,'')<>'' THEN CONVERT(VARCHAR(10),ActualDCCODate,103) ELSE NULL END  ACTUALDCCODATE
					,Infrastructure AS INFRASTRUCTUREYN
					,DFVAmount AS DFVAMOUNT
					,ISNULL(AuthorisationStatus,'A') as AuthorisationStatus
					,ISNULL(ModifiedBy,CreatedBy) CrModApBy
					,CAST(D2Ktimestamp AS INT)D2Ktimestamp
					,NULL ChangeFields
					,'Y' IsMainTable 
					,CASE WHEN ISNULL(EFFECTIVENPADATE,'')<>'' THEN CONVERT(VARCHAR(10),EFFECTIVENPADATE,103) ELSE NULL END  EFFECTIVENPADATE
					,A.NPAREASON AS NPAREASON
			FROM DataUpload.RestructureDataUpload A
			WHERE EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey
			AND ISNULL(AuthorisationStatus,'A')='A'
		END

	IF 	@OperationFlag=16
	BEGIN
		SELECT *, 'RestructureDataUpload' AS TableName FROM #RestructureDataUpload  WHERE IsMainTable='N'
	END
	ELSE
	BEGIN
		SELECT * FROM #RestructureDataUpload
	END	
END


GO