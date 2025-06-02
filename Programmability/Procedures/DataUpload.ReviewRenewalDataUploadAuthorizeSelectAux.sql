SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/* =============================================
 AUTHER : SANJEEV KUMAR SHARMA
 CREATE BY : 28-12-2018
 MODIFY DATE : 28-12-2018
 DESCRIPTION : SELECT DATA FROM  ReviewRenewalDataUpload 
 ===============================================*/
CREATE PROCEDURE [DataUpload].[ReviewRenewalDataUploadAuthorizeSelectAux]
	@OperationFlag			INT
	,@UserId				VARCHAR(30)
	,@TimeKey INT
AS
BEGIN
	SET NOCOUNT ON;

		--	IF @OperationFlag=2
		--	BEGIN
		--			SELECT 	
		--			CUSTOMERID CUSTOMERID					
		--			,CustomerAcID ACCOUNTID
		--			,convert(varchar(20), ReviewDate,103) REVIEWDATE
		--			,convert(varchar(20),ReviewExpiryDate,103)	REVIEWEXPIRYDATE
		--			,FacilityType FACILITYTYPE
		--			,Remarks REMARKS
		--			,'ReviewRenewalDataUpload' TableName
		--			FROM DATAUPLOAD.ReviewRenewalDataUpload TXN
		--			WHERE ISNULL(TXN.AuthorisationStatus,'A')='A'
		--		UNION

		--			SELECT 						
		--			CUSTOMERID CUSTOMERID					
		--			,CustomerAcID ACCOUNTID
		--			,convert(varchar(20), ReviewDate,103) REVIEWDATE
		--			,convert(varchar(20),ReviewExpiryDate,103)	REVIEWEXPIRYDATE
		--			,FacilityType FACILITYTYPE
		--			,Remarks REMARKS
		--			,'ReviewRenewalDataUpload' TableName
		--			FROM DATAUPLOAD.ReviewRenewalDataUpload_mod TXN
		--			WHERE TXN.AuthorisationStatus IN('NP','MP','RM')

		--	END
		--ELSE
		--	BEGIN
		--		select 
		--			CUSTOMERID CUSTOMERID					
		--			,CustomerAcID ACCOUNTID
		--			,convert(varchar(20), ReviewDate,103) REVIEWDATE
		--			,convert(varchar(20),ReviewExpiryDate,103)	REVIEWEXPIRYDATE
		--			,FacilityType FACILITYTYPE
		--			,Remarks REMARKS
		--			,'ReviewRenewalDataUpload' TableName
		--		FROM DATAUPLOAD.ReviewRenewalDataUpload_mod TXN
		--		WHERE TXN.AuthorisationStatus IN('NP','MP','RM')
		--		AND TXN.CreatedBy<>@UserId
		--	END
		IF OBJECT_ID('Tempdb..#ReviewRenewalDataUpload')	IS NOT NULL
			DROP TABLE #ReviewRenewalDataUpload

		SELECT	 ReviewDataEntityId
				,A.CustomerAcID AS CUSTOMERACID
				,A.CustomerID AS CUSTOMERID
				,CONVERT(VARCHAR(10),ReviewDate,103) REVIEWDATE
				,CASE WHEN ISNULL(ReviewExpiryDate,'')<>'' THEN CONVERT(VARCHAR(10),ReviewExpiryDate,103) ELSE NULL END REVIEWEXPDT
				,FacilityType AS FACILITYTYPE
				,Remarks AS REMARKS
				,ISNULL(A.AuthorisationStatus,'A') as AuthorisationStatus
				,ISNULL(A.ModifiedBy,A.CreatedBy) CrModApBy
				--,CAST(A.D2Ktimestamp AS INT)D2Ktimestamp
				,ChangeFields
				,'N' IsMainTable
		INTO #ReviewRenewalDataUpload
		FROM DataUpload.ReviewRenewalDataUpload_mod A
		INNER JOIN 
		(
			SELECT CustomerID,CustomerAcID,MAX(Entitykey)Entitykey
			FROM DataUpload.ReviewRenewalDataUpload_mod
			WHERE EffectiveFromTimeKey<= @TimeKey AND EffectiveToTimeKey >= @TimeKey
			AND   AuthorisationStatus in('NP','MP','DP','RM')
			GROUP BY CustomerID,CustomerAcID
		)B
		ON A.Entitykey = B.Entitykey
		WHERE ISNULL(A.ModifiedBy,A.CreatedBy) <> @UserId

		IF @OperationFlag<>16
		BEGIN
			INSERT INTO #ReviewRenewalDataUpload
			SELECT   ReviewDataEntityId
				,A.CustomerAcID AS CUSTOMERACID
				,A.CustomerID AS CUSTOMERID
				,CONVERT(VARCHAR(10),ReviewDate,103) REVIEWDATE
				,CASE WHEN ISNULL(ReviewExpiryDate,'')<>'' THEN CONVERT(VARCHAR(10),ReviewExpiryDate,103) ELSE NULL END REVIEWEXPDT
				,FacilityType AS FACILITYTYPE
				,Remarks AS REMARKS
					,ISNULL(AuthorisationStatus,'A') as AuthorisationStatus
					,ISNULL(ModifiedBy,CreatedBy) CrModApBy
					--,CAST(D2Ktimestamp AS INT)D2Ktimestamp
					,NULL ChangeFields
					,'Y' IsMainTable 
			FROM DataUpload.ReviewRenewalDataUpload A
			WHERE EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey
			AND ISNULL(AuthorisationStatus,'A')='A'
		END

	IF 	@OperationFlag=16
	BEGIN
		SELECT *, 'ReviewRenewalDataUpload' AS TableName FROM #ReviewRenewalDataUpload  WHERE IsMainTable='N'
	END
	ELSE
	BEGIN
		SELECT *, 'ReviewRenewalDataUpload' AS TableName FROM #ReviewRenewalDataUpload
	END	
END


GO