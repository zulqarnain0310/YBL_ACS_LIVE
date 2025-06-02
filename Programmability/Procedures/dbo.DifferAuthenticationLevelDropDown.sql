SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROC [dbo].[DifferAuthenticationLevelDropDown]

AS

BEGIN

 Declare @TimeKey as Int 

	Set @TimeKey = (Select Timekey from SysDataMatrix where CurrentStatus='C')


	
		Select  ParameterAlt_Key
		,ParameterAlt_Key AS ParameterName
		,'FirstAuthDropdown' as Tablename 
		from DimParameter where DimParameterName ='ExistingAuthenticationLevel'
		And ParameterAlt_Key in(0,1)
		And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey

			Select  ParameterAlt_Key
			,ParameterAlt_Key AS ParameterName
		,'SecondAuthDropdown' as Tablename 
		from DimParameter where DimParameterName ='ExistingAuthenticationLevel'
		And ParameterAlt_Key in(0,2)
		And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey

			Select  ParameterAlt_Key
			,ParameterAlt_Key AS ParameterName
		,'ThirdAuthDropdown' as Tablename 
		from DimParameter where DimParameterName ='ExistingAuthenticationLevel'
		And ParameterAlt_Key in(1,2)
		And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey

END	
GO