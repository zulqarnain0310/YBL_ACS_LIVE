SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



CREATE PROC [dbo].[CollateralSubTypeDropDown]

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
		


		Select CollateralSubTypeAltKey
		,CollateralSubTypeDescription
		,'DimCollateralSubType' as Tablename 
   	from DimCollateralSubType
		Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey

	

END


GO