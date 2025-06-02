SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROC [dbo].[RPPortfolioViewHistory] 
									
									@CustomerID VARCHAR(20)='',
									@Bankname	VARCHAR(100)=''
								
								
AS
	BEGIN
					Select A.CustomerID
					,B.BankName
					,Convert(varchar(20),A.InDefaultDate,103) InDefaultDate
					,Convert(varchar(20),A.OutOfDefaultDate,103) OutOfDefaultDate
					,A.DefaultStatus
					,'LenderGridData' TableName 
					from RP_Lender_Details A
					INNER JOIN DimBankRP B 
					ON A.ReportingLenderAlt_Key=B.BankRPAlt_Key
					where CustomerID=@CustomerID and BankName=@Bankname
	END


GO