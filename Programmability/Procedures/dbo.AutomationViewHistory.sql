SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROC [dbo].[AutomationViewHistory]
					
					@CustomerID VARCHAR(20)=''

					

AS

	Declare @TimeKey Int

			SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')

		BEGIN
				
				Select 
				A.PAN_No,
				A.UCIC_ID,
				A.CustomerID,
				A.CustomerName,
				C.BankingArrangementAlt_Key,			
				C.ArrangementDescription,
				Convert(varchar(20),A.BorrowerDefaultDate,103) BorrowerDefaultDate,
				A.LeadBankAlt_Key,
				B.BankName,
				H.ParameterName DefaultStatus,
				D.ExposureBucketAlt_Key,
				D.BucketName,
				Convert(varchar(20),A.ReferenceDate,103) ReferenceDate,
				Convert(varchar(20),A.ReviewExpiryDate,103) ReviewExpiryDate,
				Convert(varchar(20),A.RP_ApprovalDate,103) RP_ApprovalDate,
				E.RPNatureAlt_Key,
				E.RpDescription,
				A.If_other,
				Convert(varchar(20),A.RP_ExpiryDate,103) RP_ExpiryDate,
				Convert(varchar(20),A.RP_ImplDate,103) RP_ImplDate,
				I.ParameterName RP_ImplStatus,
				A.RP_failed,
				Convert(varchar(20),A.Revised_RP_Expiry_Date,103) Revised_RP_Expiry_Date,
				convert(varchar(20),A.Actual_Impl_Date,103) Actual_Impl_Date,
				convert(varchar(20),A.RP_OutOfDateAllBanksDeadline,103) RP_OutOfDateAllBanksDeadline,
				A.IsBankExposure,
				G.AssetClassAlt_Key,
				G.AssetClassName,
				Convert(varchar(20),RiskReviewExpiryDate,103) RiskReviewExpiryDate,
				'RPHIstory' as TableName
				FROM RP_Portfolio_Details A
				Left Join DimBankRP B ON A.LeadBankAlt_Key=B.BankRPAlt_Key
			    Inner Join DimBankingArrangement C ON A.BankingArrangementAlt_Key=C.BankingArrangementAlt_Key
			    Inner Join DimExposureBucket D ON A.ExposureBucketAlt_Key=D.ExposureBucketAlt_Key
			    left Join DimResolutionPlanNature E ON A.RPNatureAlt_Key=E.RPNatureAlt_Key
				left Join DimAssetClass G ON A.AssetClassAlt_Key=G.AssetClassAlt_Key
				left Join (Select ParameterAlt_Key,ParameterName,'BorrowerDefaultStatus' as Tablename 
					from DimParameter where DimParameterName='BorrowerDefaultStatus'
					And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey	)H
					ON H.ParameterAlt_Key=A.DefaultStatusAlt_Key
					left join (Select ParameterAlt_Key,ParameterName,'ImplementationStatus' as Tablename 
					from DimParameter where DimParameterName='ImplementationStatus'
					And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey	)I
					ON I.ParameterAlt_Key=A.RP_ImplStatusAlt_Key
				Where A.CustomerID=@CustomerID
				Order by A.ReferenceDate

		END
GO