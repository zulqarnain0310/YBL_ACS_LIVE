SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--RP_Lender_Details
CREATE PROC [dbo].[RPLenderDetailsSelect] 
							
								@CustomerID VARCHAR(20)=''

AS
	BEGIN	

		Declare @TimeKey Int

			SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C') 
			
			 SELECT A.CustomerID
				   ,B.BankName ReportingLenderName
				   ,A.InDefaultDate
				   ,A.OutOfDefaultDate
				   ,A.DefaultStatus
				   ,'LenderGridData' as TableName
				   from RP_Lender_Details A
				   Inner Join DimBankRP B ON A.ReportingLenderAlt_Key=B.BankRPAlt_Key
				   And B.EffectiveFromTimeKey<=@Timekey And B.EffectiveToTimeKey>=@TimeKey
				   where A.CustomerID=@CustomerID
				   And A.EffectiveFromTimeKey<=@Timekey And A.EffectiveToTimeKey>=@TimeKey


	END


--exec RPLenderDetailsSelect @CustomerID=1





GO