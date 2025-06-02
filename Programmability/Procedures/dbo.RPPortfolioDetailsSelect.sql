SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROC [dbo].[RPPortfolioDetailsSelect] 
	--declare						
								@PAN_No VARCHAR(12)=''
								
								--@PAN_No VARCHAR(12)='1234567765'
AS
	BEGIN	
			
			Declare @TimeKey Int

			SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')
			
			Declare @Date Date
			SET @Date =(Select CAST(B.Date as Date)Date1 from SysDataMatrix A
			Inner Join SysDayMatrix B ON A.TimeKey=B.TimeKey
			 where A.CurrentStatus='C')		

			 
		BEGIN
			 SELECT Convert(varchar(20),@Date,103) as ProcessDate,
					A.PAN_No,
					A.UCIC_ID,
					A.CustomerID,
					A.CustomerName,
					A.BankingArrangementAlt_Key,
					C.ArrangementDescription,
					Convert(varchar(20),A.BorrowerDefaultDate,103) BorrowerDefaultDate,
					A.LeadBankAlt_Key,
					B.BankName LeadBankName,
					A.ExposureBucketAlt_Key,
					D.BucketName,
					A.DefaultStatusAlt_Key,
					H.ParameterName DefaultStatus,
					Convert(varchar(20),A.ReferenceDate,103) ReferenceDate,
					Convert(varchar(20),A.ReviewExpiryDate,103) ReviewExpiryDate,
					Convert(varchar(20),A.RP_ApprovalDate,103) RP_ApprovalDate,
					A.RPNatureAlt_Key,
					E.RPDescription RP_Nature,
					A.If_Other,
					Convert(varchar(20),A.RP_ExpiryDate,103) RP_ExpiryDate,
					Convert(Varchar(20),A.RP_ImplDate,103) RP_ImplDate,
					A.RP_ImplStatusAlt_Key,
					I.ParameterName RP_ImplStatus,
					A.RP_failed,
					Convert(Varchar(20),A.Revised_RP_Expiry_Date,103) Revised_RP_Expiry_Date,
					Convert(Varchar(20),A.Actual_Impl_Date,103) Actual_Impl_Date,
					Convert(varchar(20),A.RP_OutOfDateAllBanksDeadline,103) RP_OutOfDateAllBanksDeadline,
					A.IsBankExposure,
					G.AssetClassName,
					Convert(varchar(20),A.RiskReviewExpiryDate,103) RiskReviewExpiryDate,
					'AutomationRPScreenData' as TableName
					from RP_Portfolio_Details A
					Left Join DimBankRP B ON A.LeadBankAlt_Key=B.BankRPAlt_Key
					And B.EffectiveFromTimeKey<=@Timekey And B.EffectiveToTimeKey>=@TimeKey
					Inner Join DimBankingArrangement C ON A.BankingArrangementAlt_Key=C.BankingArrangementAlt_Key
					And C.EffectiveFromTimeKey<=@Timekey And C.EffectiveToTimeKey>=@TimeKey
					Inner Join DimExposureBucket D ON A.ExposureBucketAlt_Key=D.ExposureBucketAlt_Key
					And D.EffectiveFromTimeKey<=@Timekey And D.EffectiveToTimeKey>=@TimeKey
					left Join DimResolutionPlanNature E ON A.RPNatureAlt_Key=E.RPNatureAlt_Key
					And E.EffectiveFromTimeKey<=@Timekey And E.EffectiveToTimeKey>=@TimeKey
					Left Join DimAssetClass G ON A.AssetClassAlt_Key=G.AssetClassAlt_Key
					And G.EffectiveFromTimeKey<=@Timekey And G.EffectiveToTimeKey>=@TimeKey
					left Join (Select ParameterAlt_Key,ParameterName,'BorrowerDefaultStatus' as Tablename 
					from DimParameter where DimParameterName='BorrowerDefaultStatus'
					And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey	)H
					ON H.ParameterAlt_Key=A.DefaultStatusAlt_Key
					left join (Select ParameterAlt_Key,ParameterName,'ImplementationStatus' as Tablename 
					from DimParameter where DimParameterName='ImplementationStatus'
					And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)I
					ON I.ParameterAlt_Key=A.RP_ImplStatusAlt_Key
					where A.PAN_No=@PAN_No
					And A.EffectiveFromTimeKey<=@Timekey And A.EffectiveToTimeKey>=@TimeKey
					AND ((A.DefaultStatusAlt_Key NOT IN(2) OR A.RP_ImplStatusAlt_Key NOT IN(1,4)))
					--AND ((H.ParameterName NOT IN('Out Default') and I.ParameterName NOT IN('Implemented'))
					--AND (H.ParameterName NOT IN('Out Default') and I.ParameterName NOT IN('Implemented with Extension')))
			END
					BEGIN

					Declare @Cust_Id Varchar(20)=(Select CustomerID From RP_Portfolio_Details A
												  left Join (Select ParameterAlt_Key,ParameterName,'BorrowerDefaultStatus' as Tablename 
												  from DimParameter where DimParameterName='BorrowerDefaultStatus'
												  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey	)H
												  ON H.ParameterAlt_Key=A.DefaultStatusAlt_Key
												  left join (Select ParameterAlt_Key,ParameterName,'ImplementationStatus' as Tablename 
												  from DimParameter where DimParameterName='ImplementationStatus'
												  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)I
												  ON I.ParameterAlt_Key=A.RP_ImplStatusAlt_Key
												  Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
												  And A.PAN_No=@PAN_No
												  --AND ((A.DefaultStatusAlt_Key NOT IN(2) and A.RP_ImplStatusAlt_Key NOT IN(1,4)))
												  --AND ((H.ParameterName NOT IN('Out Default') and I.ParameterName NOT IN('Implemented'))
												  --AND (H.ParameterName NOT IN('Out Default') and I.ParameterName NOT IN('Implemented with Extension')))
												  )
						EXEC RPLenderDetailsSelect @CustomerID=@Cust_Id

					END


	END


--exec RPPortfolioDetailsSelect @PAN_NO=1234567765





GO