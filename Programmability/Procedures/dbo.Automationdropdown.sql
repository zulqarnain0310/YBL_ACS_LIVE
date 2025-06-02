SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROC [dbo].[Automationdropdown]

  
AS
  BEGIN

  Declare @TimeKey as Int 

	Set @TimeKey = (Select Timekey from SysDataMatrix where CurrentStatus='C')
		
		Select 
		BankingArrangementAlt_Key
		,ArrangementDescription
		,'BankingArrangement' TableName
		from DimBankingArrangement 
		Where EffectiveFromTimeKey<=@TimeKey
		And EffectiveToTimeKey>=@TimeKey

		Select 
		BankRPAlt_Key
		,BankName
		,'NameofLeadBank' TableName
		from DimBankRP 
		Where EffectiveFromTimeKey<=@TimeKey
		And EffectiveToTimeKey>=@TimeKey
		
		Select ParameterAlt_Key
		,ParameterName
		,'BorrowerDefaultStatus' as Tablename 
		from DimParameter 
		where DimParameterName='BorrowerDefaultStatus'
		And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey	

		Select 
		ExposureBucketAlt_Key
		,BucketName
		,'ExposureBucketing' TableName
		from DimExposureBucket 
		Where EffectiveFromTimeKey<=@TimeKey
		And EffectiveToTimeKey>=@TimeKey



		Select 
		RPNatureAlt_Key
		,RPDescription
		,'NatureofResolutionPlan' TableName
		from DimResolutionPlanNature 
		Where EffectiveFromTimeKey<=@TimeKey
		And EffectiveToTimeKey>=@TimeKey


		Select ParameterAlt_Key
		,ParameterName
		,'ImplementationStatus' as Tablename 
		from DimParameter where DimParameterName='ImplementationStatus'
		And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey

END








GO