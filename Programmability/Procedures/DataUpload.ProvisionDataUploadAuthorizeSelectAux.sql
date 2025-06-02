SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/* =============================================
 AUTHER : SANJEEV KUMAR SHARMA
 CREATE BY : 28-12-2018
 MODIFY DATE : 28-12-2018
 DESCRIPTION : SELECT DATA FROM  ProvisionDataUpload 
 ===============================================*/
CREATE PROCEDURE [DataUpload].[ProvisionDataUploadAuthorizeSelectAux]
	@OperationFlag			INT
	,@UserId				VARCHAR(30)
	,@TimeKey INT
AS
BEGIN
	SET NOCOUNT ON;

			IF @OperationFlag=2
			BEGIN
					SELECT 			
						ProvisionDataEntityId			
						,UCIF_ID		UCICID							
						,CustomerID 	CUSTOMERID
						,CustomerID REFCUSTOMERID
						,CustomerName	CUSTOMERNAME
						,CustomerAcID	CUSTOMERACID
						,AssetClass	ASSETCLASS
						,AssetSubclass	ASSETSUBCLASS
						,ProvisionPercent	PROVISIONPERCENT
				    ,'ProvisionDataUpload' TableName
					 FROM DATAUPLOAD.ProvisionDataUpload TXN
						WHERE ISNULL(TXN.AuthorisationStatus,'A')='A'
				UNION

					SELECT 						
						ProvisionDataEntityId			
						,UCIF_ID UCICID
						,CustomerID  CUSTOMERID
						,CustomerID REFCUSTOMERID
						,CustomerName CUSTOMERNAME
						,CustomerAcID	CUSTOMERACID
						,AssetClass	ASSETCLASS
						,AssetSubclass	ASSETSUBCLASS
						,ProvisionPercent	PROVISIONPERCENT
				    ,'ProvisionDataUpload' TableName
					 FROM DATAUPLOAD.ProvisionDataUpload_mod TXN
							WHERE TXN.AuthorisationStatus IN('NP','MP','RM')

			END
		ELSE
			BEGIN
			select 
				ProvisionDataEntityId			
				,UCIF_ID UCICID
				,CustomerID  CUSTOMERID
				,CustomerID REFCUSTOMERID
				,CustomerName CUSTOMERNAME
				,CustomerAcID	CUSTOMERACID
				,AssetClass	ASSETCLASS
				,AssetSubclass 	ASSETSUBCLASS
				,ProvisionPercent	PROVISIONPERCENT
				    ,'ProvisionDataUpload' TableName
					 FROM DATAUPLOAD.ProvisionDataUpload_mod TXN
						WHERE TXN.AuthorisationStatus IN('NP','MP','RM')
						AND TXN.CreatedBy<>@UserId
			END
END


GO