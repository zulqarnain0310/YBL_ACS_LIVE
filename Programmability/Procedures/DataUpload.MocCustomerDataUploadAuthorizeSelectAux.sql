SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


/* =============================================
 AUTHER : SANJEEV KUMAR SHARMA
 CREATE BY : 28-12-2018
 MODIFY DATE : 28-12-2018
 DESCRIPTION : SELECT DATA FROM  MocCustomerDataUpload 
 ===============================================*/
CREATE PROCEDURE [DataUpload].[MocCustomerDataUploadAuthorizeSelectAux]
	@OperationFlag			INT
	,@UserId				VARCHAR(30)
	,@TimeKey INT
AS
BEGIN
	SET NOCOUNT ON;

			IF @OperationFlag=2
			BEGIN
					SELECT 						
					TXN.MocCustomerDataEntityId
					,CustomerID 	CUSTOMERID
					,AssetClassification	ASSETCLASSIFICATION
					,convert (varchar(20), NPADate,103)	NPADATE
					,SecurityValue	SECURITYVALUE
					,AdditionalProvision	ADDITIONALPROVISION
					,MOCReason	MOCREASON
					,MOCTYPE
					,convert (varchar(20), DbtDt,103)	DOUBTFULDATE
				    ,'MocCustomerDataUpload' TableName
					 FROM DATAUPLOAD.MocCustomerDataUpload TXN
						WHERE ISNULL(TXN.AuthorisationStatus,'A')='A'
				UNION

					SELECT 						
					TXN.MocCustomerDataEntityId
					,CustomerID 	CUSTOMERID
					,AssetClassification	ASSETCLASSIFICATION
					,convert (varchar(20), NPADate,103)	NPADATE
					,SecurityValue	SECURITYVALUE
					,AdditionalProvision	ADDITIONALPROVISION
					,MOCReason	MOCREASON
					,MOCTYPE
					,convert (varchar(20), DbtDt,103)	DOUBTFULDATE
				    ,'MocCustomerDataUpload' TableName
					 FROM DATAUPLOAD.MocCustomerDataUpload_mod TXN
							WHERE TXN.AuthorisationStatus IN('NP','MP','RM')

			END
		ELSE
			BEGIN
					SELECT 						
					TXN.MocCustomerDataEntityId
					,CustomerID 	CUSTOMERID
					,AssetClassification	ASSETCLASSIFICATION
					,convert (varchar(20), NPADate,103)	NPADATE
					,SecurityValue	SECURITYVALUE
					,AdditionalProvision	ADDITIONALPROVISION
					,MOCReason	MOCREASON
					,MOCTYPE
					,convert (varchar(20), DbtDt,103)	DOUBTFULDATE
				    ,'MocCustomerDataUpload' TableName
					 FROM DATAUPLOAD.MocCustomerDataUpload_mod TXN
						WHERE TXN.AuthorisationStatus IN('NP','MP','RM')
						AND TXN.CreatedBy<>@UserId
			END
END


GO