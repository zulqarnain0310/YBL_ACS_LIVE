SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/* =============================================
 AUTHER : SANJEEV KUMAR SHARMA
 CREATE BY : 28-12-2018
 MODIFY DATE : 28-12-2018
 DESCRIPTION : SELECT DATA FROM  StockStatementDataUpload 
 ===============================================*/
CREATE PROCEDURE [DataUpload].[StockStatementDataUploadAuthorizeSelectAux]
	@OperationFlag					INT
	,@UserId				VARCHAR(30)
	,@TimeKey				INT
AS

--DECLARE 
--	@OperationFlag					INT=16
--	,@UserId				VARCHAR(30)='mischecker'
--	,@TimeKey				INT=25141

BEGIN
	SET NOCOUNT ON;

	--IF @Menuid=621
	--	BEGIN
	--		SELECT 				
	--				FraudAccountDataEntityId
	--				,UCIF_ID
	--				,CustomerID
	--				,CustomerName
	--				,CustomerAcID
	--				,DateofFraud
	--				,AmountofFraud
	--				,AuthorisationStatus														
	--		 FROM DataUpload.FraudAccountsDataUpload
	--				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
	--				AND AuthorisationStatus in('NP','MP','DP')
	--	END
	--IF @Menuid=616
	--	BEGIN
	--			SELECT 
					
	--				ProvisionDataEntityId
	--				,UCIF_ID
	--				,CustomerID
	--				,CustomerName
	--				,CustomerAcID
	--				,AssetClass
	--				,AssetSubclass
	--				,ProvisionPercent
	--				,AuthorisationStatus										
	--			 FROM DataUpload.ProvisionDataUpload
	--						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
	--						AND AuthorisationStatus in('NP','MP','DP')
	--	END
	--IF @Menuid=641
	--	BEGIN
	--		SELECT 
	--			RePossessedDataEntityId
	--			,CustomerID
	--			,CustomerAcID
	--			,CustomerName
	--			,RepossessionDate
	--			,AuthorisationStatus														
	--			 FROM DataUpload.RePossessedAccountDataUpload
	--						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
	--						AND AuthorisationStatus in('NP','MP','DP')
	--	END
	--IF @Menuid=620
	--	BEGIN
	--		SELECT 				
	--			RestructureDataEntityId
	--			,CustomerID
	--			,CustomerAcID
	--			,CustomerName
	--			,RestructureDate
	--			,OriginalDCCODate
	--			,ExtendedDCCODate
	--			,ActualDCCODate
	--			,Infrastructure
	--			,DFVAmount
	--			,AuthorisationStatus								
	--			 FROM DataUpload.RestructureDataUpload
	--						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
	--						AND AuthorisationStatus in('NP','MP','DP')
	--	END		
	--IF @Menuid=622
	--BEGIN
	--	SELECT 								
	--		ReviewDataEntityId
	--		,CustomerAcID
	--		,CustomerID
	--		,CustomerName
	--		,ReviewDate
	--		,ReviewExpiryDate
	--		,FacilityType
	--		,Remarks
	--		,AuthorisationStatus										
	--		 FROM DataUpload.ReviewRenewalDataUpload
	--					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
	--					AND AuthorisationStatus in('NP','MP','DP')
	--	END
	--IF @Menuid=607
	--	BEGIN
	--	SELECT 											
	--		SecurityDataEntityId
	--		,UCIF_ID
	--		,CustomerID
	--		,SourceSystemCustomerID
	--		,CustomerName
	--		,CustomerAcID
	--		,SecurityCode
	--		,SecurityDescription
	--		,SecurityName
	--		,SecurityType
	--		,CurrentValue
	--		,CONVERT(VARCHAR(10),ValuationDt,103) ValuationDt
	--		,AuthorisationStatus												
	--		 FROM DataUpload.SecurityDataUpload
	--					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
	--					AND AuthorisationStatus in('NP','MP','DP')
	--	END

	--IF @Menuid=602
	--	BEGIN
	--	SELECT 												
	--		StockDataEntityId
	--		,CustomerAcID
	--		,CustomerID
	--		,ICRABorrowerId
	--		,CustomerName
	--		,convert(VARCHAR(10),StockStatementDate,103)StockStatementDate
	--		,StockValue
	--		,AuthorisationStatus
	--		,'StockStatement' TableName												
	--		 FROM DataUpload.StockStatementDataUpload
	--					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
	--					AND AuthorisationStatus in('NP','MP','DP')
	--	END



		----	IF @OperationFlag=2
		----	BEGIN
		----			SELECT 		
		----				CUSTOMERID CUSTOMERID				
		----				,CustomerAcID	ACCOUNTID
		----				,convert(varchar(20), StockStatementDate,103)	STOCKSTATEMENTDATE
		----				,StockValue	STOCKVALUE
		----				,ICRABorrowerId ICRABORROWERID
		----			,'StockStatementDataUpload' TableName
		----			FROM DATAUPLOAD.StockStatementDataUpload TXN
		----			WHERE ISNULL(TXN.AuthorisationStatus,'A')='A'
		----		UNION

		----			SELECT 						
		----				CUSTOMERID CUSTOMERID				
		----				,CustomerAcID	ACCOUNTID
		----				,convert(varchar(20), StockStatementDate,103)	STOCKSTATEMENTDATE
		----				,StockValue	STOCKVALUE
		----				,ICRABorrowerId ICRABORROWERID
		----			,'StockStatementDataUpload' TableName
		----			FROM DATAUPLOAD.StockStatementDataUpload_mod TXN
		----			WHERE TXN.AuthorisationStatus IN('NP','MP','RM')

		----	END
		----ELSE
		----	BEGIN
		----		select 
		----				CUSTOMERID CUSTOMERID				
		----				,CustomerAcID	ACCOUNTID
		----				,convert(varchar(20), StockStatementDate,103)	STOCKSTATEMENTDATE
		----				,StockValue	STOCKVALUE
		----				,ICRABorrowerId ICRABORROWERID
		----			,'StockStatementDataUpload' TableName
		----		FROM DATAUPLOAD.StockStatementDataUpload_mod TXN
		----		WHERE TXN.AuthorisationStatus IN('NP','MP','RM')
		----		AND TXN.CreatedBy<>@UserId
		----	END

		IF OBJECT_ID('Tempdb..#StockStatementDataUpload')	IS NOT NULL
			DROP TABLE #StockStatementDataUpload

		SELECT	 
				StockDataEntityId
				,A.CUSTOMERID	
				,A.CUSTOMERACID	
				,ICRABORROWERID	
				,CONVERT(VARCHAR(10),StockStatementDate,103)STOCKSTATEMENTDATE
				,STOCKVALUE
				,ISNULL(A.AuthorisationStatus,'A') as AuthorisationStatus
				,ISNULL(A.ModifiedBy,A.CreatedBy) CrModApBy
				,CAST(A.D2Ktimestamp AS INT)D2Ktimestamp
				,ChangeFields
				,'N' IsMainTable
		INTO #StockStatementDataUpload
		FROM DataUpload.StockStatementDataUpload_Mod A
		INNER JOIN 
		(
			SELECT CUSTOMERID,CUSTOMERACID,MAX(Entitykey)Entitykey
			FROM DataUpload.StockStatementDataUpload_Mod
			WHERE EffectiveFromTimeKey<= @TimeKey AND EffectiveToTimeKey >= @TimeKey
			AND   AuthorisationStatus in('NP','MP','DP','RM')
			GROUP BY CustomerID,CustomerAcID,StockStatementDate
		)B
		ON A.Entitykey = B.Entitykey

		IF @OperationFlag<>16
		BEGIN
			INSERT INTO #StockStatementDataUpload
			SELECT StockDataEntityId
					,CustomerID	CUSTOMERID
					,CustomerAcID	CUSTOMERACID
					,ICRABorrowerId	ICRABORROWERID
					,CONVERT(VARCHAR(10),StockStatementDate,103)STOCKSTATEMENTDATE
					,STOCKVALUE
					,ISNULL(AuthorisationStatus,'A') as AuthorisationStatus
					,ISNULL(ModifiedBy,CreatedBy) CrModApBy
					,CAST(D2Ktimestamp AS INT)D2Ktimestamp
					,NULL ChangeFields
					,'Y' IsMainTable 
			FROM DataUpload.StockStatementDataUpload
			WHERE EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey
			AND ISNULL(AuthorisationStatus,'A')='A'
		END

	IF 	@OperationFlag=16
	BEGIN
		SELECT *, 'StockStatementDataUpload' as TableName FROM #StockStatementDataUpload  WHERE IsMainTable='N'
	END
	ELSE
	BEGIN
		SELECT *, 'StockStatementDataUpload' as TableName FROM #StockStatementDataUpload
	END	
END


GO