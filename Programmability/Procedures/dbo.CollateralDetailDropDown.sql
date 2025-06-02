SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



CREATE PROC [dbo].[CollateralDetailDropDown]

---Exec [dbo].[CollateralDropDown]
  
AS
  BEGIN

  Declare @TimeKey as Int 

	Set @TimeKey = (Select Timekey from SysDataMatrix where CurrentStatus='C')
		
	


		--Select ParameterAlt_Key
		--,ParameterName
		--,'TaggingLevel' as Tablename 
		--from DimParameter where DimParameterName='DimRatingType'
		--and ParameterName not in ('Guarantor')
		--And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		--order by ParameterName Desc
		


		Select SegmentAlt_Key
		,SegmentName
		,'SegmentMaster' as Tablename 
		from DimSegment
		Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey

	   Select ParameterAlt_Key
		,ParameterName
		,'CREMaster' as Tablename 
		from DimParameter where DimParameterName='DimYesNo'
		and EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey

		Select CollateralSubTypeAltKey
		,CollateralSubTypeDescription
		,'CollateralSubType' as Tablename 
		from DimCollateralSubType 
		where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey

		Select ParameterAlt_Key
		,ParameterName
		,'SeniorityOfChargeMaster' as Tablename 
		from DimParameter where DimParameterName='DimSeniorityOfCharge'
		and EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey

		Select ParameterAlt_Key
		,ParameterName
		,'SecurityStatusMaster' as Tablename 
		from DimParameter where DimParameterName='DimSecuritySt'
		and EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey

		Select ParameterAlt_Key
		,ParameterName
		,'ModeOfOperationMaster' as Tablename 
		from DimParameter where DimParameterName='DimModOperation'
		and EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey

		Select ParameterAlt_Key
		,ParameterName
		,'ExceptionalApprovalMaster' as Tablename 
		from DimParameter where DimParameterName='DimExceptionalAppr'
		and EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey

      


	   Select CurrencyAlt_Key,CurrencyName,'CurrencyTable'  as TableName 
		 from DimCurrency
		where EffectiveFromTimeKey<=@TimeKey
	     AND EffectiveToTimeKey >=@TimeKey
		 and CurrencyCode in('INR','USD','GBP','Euro','Yen','Swiss Franc')

		 Select  BankAlt_Key
		,BankName
		,'BankMaster' as TableName 
		from DimBank A 
		where	 A.EffectiveFromTimeKey<=@TimeKey
		AND A.EffectiveToTimeKey >=@TimeKey

END







GO