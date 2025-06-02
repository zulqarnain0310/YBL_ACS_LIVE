SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create PROC [dbo].[AuthenticationLevelDropDown]

AS

BEGIN

 Declare @TimeKey as Int 

	Set @TimeKey = (Select Timekey from SysDataMatrix where CurrentStatus='C')


	
		Select  ParameterAlt_Key
		,ParameterName
		,'AuthenticationLevel' as Tablename 
		from DimParameter where DimParameterName ='ExistingAuthenticationLevel'
		And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey


		Exec [DifferAuthenticationLevelDropDown]

END
GO