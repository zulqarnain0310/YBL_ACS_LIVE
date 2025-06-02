SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/* =============================================
 AUTHER : SANJEEV KUMAR SHARMA
 CREATE BY : 28-12-2018
 MODIFY DATE : 28-12-2018
 DESCRIPTION : SELECT DATA FROM  SecurityDataUpload 
 ===============================================*/
CREATE PROCEDURE [DataUpload].[SecurityDataUploadAuthorizeSelectAux]
	@OperationFlag			INT
	,@UserId				VARCHAR(30)
	,@TimeKey INT
AS
BEGIN
	SET NOCOUNT ON;

			IF @OperationFlag=2
			BEGIN
					SELECT 						
						SecurityDataEntityId
						,UCIF_ID	UCIFID
						,CUSTOMERID CUSTOMERID
						,SourceSystemCustomerID AS REFCUSTOMERID
						,CustomerAcID	CUSTOMERACID
						,SecurityCode	SECURITYCODE
						,SecurityDescription	SECURITYDESCRIPTION
						,SecurityName	SECURITYNAME
						,SecurityType	SECURITYTYPE
						,CurrentValue	CURRENTVALUE
						,CONVERT(varchar(20),ValuationDt,103)	VALUATIONDATE
					   ,'SecurityDataUpload' TableName
					,CONVERT(varchar(20),EFFECTIVENPADATE,103) EFFECTIVENPADATE
					FROM DATAUPLOAD.SecurityDataUpload TXN
					WHERE ISNULL(TXN.AuthorisationStatus,'A')='A'
				UNION

					SELECT 						
						SecurityDataEntityId
						,UCIF_ID	UCIFID
						,CustomerID AS CUSTOMERID
						,SourceSystemCustomerID AS REFCUSTOMERID
						,CustomerAcID	CUSTOMERACID
						,SecurityCode	SECURITYCODE
						,SecurityDescription	SECURITYDESCRIPTION
						,SecurityName	SECURITYNAME
						,SecurityType	SECURITYTYPE
						,CurrentValue	CURRENTVALUE
					 ,CONVERT(varchar(20),ValuationDt,103)	VALUATIONDATE
					,'SecurityDataUpload' TableName
					,CONVERT(varchar(20),EFFECTIVENPADATE,103) EFFECTIVENPADATE
					FROM DATAUPLOAD.SecurityDataUpload_mod TXN
					WHERE TXN.AuthorisationStatus IN('NP','MP','RM')

			END
		ELSE
			BEGIN
				select 
						SecurityDataEntityId
						,UCIF_ID	UCICID
						,CUSTOMERID	CUSTOMERID
						,SourceSystemCustomerID AS REFCUSTOMERID
						,CustomerAcID	CUSTOMERACID
						,SecurityCode	SECURITYCODE
						,SecurityDescription	SECURITYDESCRIPTION
						,SecurityName	SECURITYNAME
						,SecurityType	SECURITYTYPE
						,CurrentValue	CURRENTVALUE
						,CONVERT(varchar(20),ValuationDt,103)	VALUATIONDATE
					,'SecurityDataUpload' TableName
					,CONVERT(varchar(20),EFFECTIVENPADATE,103) EFFECTIVENPADATE
				FROM DATAUPLOAD.SecurityDataUpload_mod TXN
				WHERE TXN.AuthorisationStatus IN('NP','MP','RM')
				AND TXN.CreatedBy<>@UserId
			END
END


GO