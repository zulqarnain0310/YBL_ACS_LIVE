SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/* =============================================
 AUTHER : SANJEEV KUMAR SHARMA
 CREATE BY : 28-12-2018
 MODIFY DATE : 28-12-2018
 DESCRIPTION : SELECT DATA FROM  MocAccountDataUpload 
 ===============================================*/
CREATE PROCEDURE [DataUpload].[MocAccountDataUploadAuthorizeSelectAux]
	@OperationFlag			INT
	,@UserId				VARCHAR(30)
	,@TimeKey INT
AS
BEGIN
	SET NOCOUNT ON;
	
			IF @OperationFlag=2
			BEGIN
					SELECT 						
					TXN.MocAccountDataEntityId
					,CustomerID  CUSTOMERID
					,CustomerAcID CUSTOMERACID	--ACCOUNTID
					,Balance BALANCE
					,AdditionalProvision ADDITIONALPROVISION
					,AdditionalProvisionAmount ADDITIONALPROVISIONAMOUNT
					,AppropriateSecurity APPROPRIATESECURITY
					,FITL FITL
					,DFVAmount DFVAMOUNT
					,convert (varchar(20), RePossessionDate,103) REPOSSESSIONDATE
					,convert (varchar(20), RestructureDate ,103) RESTRUCTUREDATE
					,convert (varchar(20), OriginalDCCODate,103) ORIGINALDCCODATE
					,convert (varchar(20), ExtendedDCCODate,103) EXTENDEDDCCODATE
					,convert (varchar(20), ActualDCCODate  ,103) ACTUALDCCODATE
					,Infrastructure INFRASTRUCTUREYN
					,MOCReason MOCREASON
				    ,'MocAccountDataUpload' TableName
					 FROM DATAUPLOAD.MocAccountDataUpload TXN
						WHERE ISNULL(TXN.AuthorisationStatus,'A')='A'
				UNION

					SELECT 						
					TXN.MocAccountDataEntityId
					,CustomerID  CUSTOMERID
					,CustomerAcID CUSTOMERACID	--ACCOUNTID
					,Balance BALANCE
					,AdditionalProvision ADDITIONALPROVISION
					,AdditionalProvisionAmount ADDITIONALPROVISIONAMOUNT
					,AppropriateSecurity APPROPRIATESECURITY
					,FITL FITL
					,DFVAmount DFVAMOUNT
					,convert (varchar(20), RePossessionDate,103) REPOSSESSIONDATE
					,convert (varchar(20), RestructureDate ,103) RESTRUCTUREDATE
					,convert (varchar(20), OriginalDCCODate,103) ORIGINALDCCODATE
					,convert (varchar(20), ExtendedDCCODate,103) EXTENDEDDCCODATE
					,convert (varchar(20), ActualDCCODate  ,103) ACTUALDCCODATE
					,Infrastructure INFRASTRUCTUREYN
					,MOCReason MOCREASON
				    ,'MocAccountDataUpload' TableName
					 FROM DATAUPLOAD.MocAccountDataUpload_mod TXN
							WHERE TXN.AuthorisationStatus IN('NP','MP','RM')

			END
		ELSE
			BEGIN
					SELECT 						
					TXN.MocAccountDataEntityId
					,CustomerID  CUSTOMERID
					,CustomerAcID CUSTOMERACID	-- ACCOUNTID
					,Balance BALANCE
					,AdditionalProvision ADDITIONALPROVISION
					,AdditionalProvisionAmount ADDITIONALPROVISIONAMOUNT
					,AppropriateSecurity APPROPRIATESECURITY
					,FITL FITL
					,DFVAmount DFVAMOUNT
					,convert (varchar(20), RePossessionDate,103) REPOSSESSIONDATE
					,convert (varchar(20), RestructureDate ,103) RESTRUCTUREDATE
					,convert (varchar(20), OriginalDCCODate,103) ORIGINALDCCODATE
					,convert (varchar(20), ExtendedDCCODate,103) EXTENDEDDCCODATE
					,convert (varchar(20), ActualDCCODate  ,103) ACTUALDCCODATE
					,Infrastructure INFRASTRUCTUREYN
					,MOCReason MOCREASON
				    ,'MocAccountDataUpload' TableName
					 FROM DATAUPLOAD.MocAccountDataUpload_mod TXN
						WHERE TXN.AuthorisationStatus IN('NP','MP','RM')
						AND TXN.CreatedBy<>@UserId
			END
END


GO