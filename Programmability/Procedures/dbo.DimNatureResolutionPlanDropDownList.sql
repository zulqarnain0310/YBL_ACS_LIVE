SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



CREATE PROC [dbo].[DimNatureResolutionPlanDropDownList]

								@TableName varchar(100)=''
AS

BEGIN
Declare @TimeKey as Int 

Set @TimeKey = (Select Timekey from SysDataMatrix where CurrentStatus='C')


IF @TableName='Rectification'
	BEGIN
		Select 
		Parameter_Key
		,ParameterAlt_Key
		,ParameterName
		,'Rectification' TableName
		
		 from DimParameter 
		Where EffectiveFromTimeKey<=@TimeKey
		And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='DimNatureResolutionPlan'
	END


IF @TableName='Restructuring'
	BEGIN
		Select 
		Parameter_Key
		,ParameterAlt_Key
		,ParameterName
		,'Restructuring' TableName
		
		 from DimParameter 
		Where EffectiveFromTimeKey<=@TimeKey
		And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='DimNatureResolutionPlan'
	END

IF @TableName='Change in Ownership'
	BEGIN
		Select 
		Parameter_Key
		,ParameterAlt_Key
		,ParameterName
		,'Change in Ownership' TableName
		
		 from DimParameter 
		Where EffectiveFromTimeKey<=@TimeKey
		And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='DimNatureResolutionPlan'
	END

IF @TableName='IBC'
	BEGIN
		Select 
		Parameter_Key
		,ParameterAlt_Key
		,ParameterName
		,'IBC' TableName
		
		 from DimParameter 
		Where EffectiveFromTimeKey<=@TimeKey
		And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='DimNatureResolutionPlan'
	END

IF @TableName='Other'
	BEGIN
		Select 
		Parameter_Key
		,ParameterAlt_Key
		,ParameterName
		,'Other' TableName
		
		 from DimParameter 
		Where EffectiveFromTimeKey<=@TimeKey
		And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='DimNatureResolutionPlan'
	END
END

--exec DimNatureResolutionPlanDropDownList
GO