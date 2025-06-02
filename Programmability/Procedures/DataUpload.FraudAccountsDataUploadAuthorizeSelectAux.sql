SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/* =============================================
 AUTHER : SANJEEV KUMAR SHARMA
 CREATE BY : 28-12-2018
 MODIFY DATE : 28-12-2018
 DESCRIPTION : SELECT DATA FROM  FraudAccountsDataUpload 
 ===============================================*/
CREATE PROCEDURE [DataUpload].[FraudAccountsDataUploadAuthorizeSelectAux]
	@OperationFlag			INT
	,@UserId				VARCHAR(30)
	,@TimeKey INT
AS
BEGIN
	SET NOCOUNT ON;

		--	IF @OperationFlag=2
		--	BEGIN
		--			SELECT 						
		--			UCIF_ID UCIFID
		--			,CustomerID  CUSTOMERID
		--			,CustomerName CUSTOMERNAME
		--			,CustomerAcID ACCOUNTID
		--			,convert (varchar(20), DateofFraud ,103) DATEOFFRAUD
		--			,AmountofFraud AMOUNTOFFRAUD
		--		    ,'FraudAccountsDataUpload' TableName
		--			 FROM DATAUPLOAD.FraudAccountsDataUpload TXN
		--				WHERE ISNULL(TXN.AuthorisationStatus,'A')='A'
		--		UNION

		--			SELECT 						
		--			UCIF_ID UCIFID
		--			,CustomerID  CUSTOMERID
		--			,CustomerName CUSTOMERNAME
		--			,CustomerAcID ACCOUNTID
		--			,convert (varchar(20), DateofFraud ,103) DATEOFFRAUD
		--			,AmountofFraud AMOUNTOFFRAUD
		--		    ,'FraudAccountsDataUpload' TableName
		--			 FROM DATAUPLOAD.FraudAccountsDataUpload_mod TXN
		--					WHERE TXN.AuthorisationStatus IN('NP','MP','RM')

		--	END
		--ELSE
		--	BEGIN
		--			SELECT 						
		--			UCIF_ID UCIFID
		--			,CustomerID  CUSTOMERID
		--			,CustomerName CUSTOMERNAME
		--			,CustomerAcID ACCOUNTID
		--			,convert (varchar(20), DateofFraud ,103) DATEOFFRAUD
		--			,AmountofFraud AMOUNTOFFRAUD
		--		    ,'FraudAccountsDataUpload' TableName
		--			 FROM DATAUPLOAD.FraudAccountsDataUpload_mod TXN
		--				WHERE TXN.AuthorisationStatus IN('NP','MP','RM')
		--				AND TXN.CreatedBy<>@UserId
		--	END


		IF OBJECT_ID('Tempdb..#FraudAccountsDataUpload')	IS NOT NULL
			DROP TABLE #FraudAccountsDataUpload

		SELECT	
				A.FraudAccountDataEntityId
				,UCIF_ID AS UCICID
				,A.CustomerID as CUSTOMERID
				,CustomerName CUSTOMERNAME
				,A.CustomerAcID CUSTOMERACID
				,CONVERT(VARCHAR(10),DateofFraud,103) FRAUDDATE
				,AmountofFraud FRAUDAMT
				,ISNULL(A.AuthorisationStatus,'A') as AuthorisationStatus
				,ISNULL(A.ModifiedBy,A.CreatedBy) CrModApBy
				,CAST(A.D2Ktimestamp AS INT)D2Ktimestamp
				,ChangeFields
				,'N' IsMainTable
				,CONVERT(VARCHAR(10),EFFECTIVENPADATE,103) EFFECTIVENPADATE
		INTO #FraudAccountsDataUpload
		FROM DataUpload.FraudAccountsDataUpload_Mod A
		INNER JOIN 
		(
			SELECT CustomerID,CustomerAcID,MAX(Entitykey)Entitykey
			FROM DataUpload.FraudAccountsDataUpload_Mod
			WHERE EffectiveFromTimeKey<= @TimeKey AND EffectiveToTimeKey >= @TimeKey
			AND   AuthorisationStatus in('NP','MP','DP','RM')
			GROUP BY CustomerID,CustomerAcID
		)B
		ON A.Entitykey = B.Entitykey
		WHERE ISNULL(A.ModifiedBy,A.CreatedBy) <> @UserId

		IF @OperationFlag<>16
		BEGIN
			INSERT INTO #FraudAccountsDataUpload
			SELECT  
					A.FraudAccountDataEntityId
					,UCIF_ID AS UCICID
					,A.CustomerID as CUSTOMERID
					,CustomerName CUSTOMERNAME
					,A.CustomerAcID CUSTOMERACID
					,CONVERT(VARCHAR(10),DateofFraud,103) FRAUDDATE
					,AmountofFraud FRAUDAMT
					,ISNULL(AuthorisationStatus,'A') as AuthorisationStatus
					,ISNULL(ModifiedBy,CreatedBy) CrModApBy
					,CAST(D2Ktimestamp AS INT)D2Ktimestamp
					,NULL ChangeFields
					,'Y' IsMainTable 
					,CONVERT(VARCHAR(10),EFFECTIVENPADATE,103) EFFECTIVENPADATE
			FROM DataUpload.FraudAccountsDataUpload A
			WHERE EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey
			AND ISNULL(AuthorisationStatus,'A')='A'
		END

	IF 	@OperationFlag=16
	BEGIN
		SELECT *, 'FraudAccountsDataUpload' AS TableName FROM #FraudAccountsDataUpload  WHERE IsMainTable='N'
	END
	ELSE
	BEGIN
		SELECT *,'FraudAccountsDataUpload' AS TableName FROM #FraudAccountsDataUpload
	END	
END


GO