SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


Create PROC [dbo].[PUIdropdown]

  
AS
  BEGIN

  Declare @TimeKey as Int 

	Set @TimeKey = (Select Timekey from SysDataMatrix where CurrentStatus='C')
		
	


		Select ParameterAlt_Key
		,ParameterName
		,'ProjectCategory' as Tablename 
		from DimParameter where DimParameterName='ProjectCategory'
		And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey

		
		Select ParameterAlt_Key
		,ParameterName
		,'ProdectDelReson' as Tablename 
		from DimParameter where DimParameterName='ProdectDelReson'
		And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey

			Select ParameterAlt_Key
		,ParameterName
		,'StandardRestruct' as Tablename 
		from DimParameter where DimParameterName='DimYesNo'
		And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey

END







GO