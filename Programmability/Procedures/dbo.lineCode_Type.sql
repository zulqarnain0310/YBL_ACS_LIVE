SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE proc [dbo].[lineCode_Type]
@Source Varchar(20)
As

--declare @Source varchar(20)='FCR'
Declare @TimeKey AS INT
	SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')

	IF @Source='FCC'
	BEGIN
	select ParameterAlt_Key,ParameterName 
	from DimParameter
	where EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey
	and DimParameterName='LineCodeType'
	and ParameterAlt_Key in (1,2)
    END
IF @Source='FCR'
	BEGIN
	select ParameterAlt_Key,ParameterName 
	from DimParameter
	where EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey
	and DimParameterName='LineCodeType'
	and ParameterAlt_Key in (1,2,3)
    END
IF @Source='VISIONPLUS'
	BEGIN
	select ParameterAlt_Key,ParameterName 
	from DimParameter
	where EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey
	and DimParameterName='LineCodeType'
	and ParameterAlt_Key in (3)
    END
GO