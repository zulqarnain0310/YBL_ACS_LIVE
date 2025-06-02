SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/* =============================================
 AUTHER : SANJEEV KUMAR SHARMA
 CREATE BY : 28-12-2018
 MODIFY DATE : 28-12-2018
 DESCRIPTION : SELECT DATA FROM  RePossessedAccountData 
 ===============================================*/
CREATE PROCEDURE [DataUpload].[RePossessedAccountDataUploadAuthorizeSelectAux]
	@OperationFlag			INT
	,@UserId				VARCHAR(30)
	,@TimeKey INT
AS
BEGIN
	SET NOCOUNT ON;

			IF @OperationFlag=2
			BEGIN
					SELECT 						
					RePossessedDataEntityId
					,CUSTOMERID CUSTOMERID
					,CustomerAcID AS CUSTOMERACID--ACCOUNTID
					,convert(varchar(20), RepossessionDate,103) REPOSSESSIONDATE
					,'RePossessedAccountDataUpload' TableName
					FROM DATAUPLOAD.RePossessedAccountDataUpload TXN
					WHERE ISNULL(TXN.AuthorisationStatus,'A')='A'
				UNION

					SELECT 						
					RePossessedDataEntityId
					,CUSTOMERID
					,CustomerAcID AS CUSTOMERACID--ACCOUNTID
					,convert(varchar(20), RepossessionDate,103) REPOSSESSIONDATE
					,'RePossessedAccountDataUpload' TableName
					FROM DATAUPLOAD.RePossessedAccountDataUpload_mod TXN
					WHERE TXN.AuthorisationStatus IN('NP','MP','RM')

			END
		ELSE
			BEGIN
				select 
				RePossessedDataEntityId
				,CUSTOMERID CUSTOMERID
				,CustomerAcID AS CUSTOMERACID --ACCOUNTID
				,convert(varchar(20), RepossessionDate,103) REPOSSESSIONDATE
				,'RePossessedAccountDataUpload' TableName
				FROM DATAUPLOAD.RePossessedAccountDataUpload_mod TXN
				WHERE TXN.AuthorisationStatus IN('NP','MP','RM')
				AND TXN.CreatedBy<>@UserId
			END
END


GO